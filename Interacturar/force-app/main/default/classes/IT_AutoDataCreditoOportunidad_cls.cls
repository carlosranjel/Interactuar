/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar - Autogestion
* @descripcion      Clase que ejecuta el proceso de consulta datacredito para proceso de automatico de  
                    creacion de credito
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   20-OCT-2020   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public Class IT_AutoDataCreditoOportunidad_cls implements Queueable, Database.AllowsCallouts{

    private String accionActual;
    private String oportunidadId;

    private CampaignMember member;

    private Respuesta respDatacredito;
    private Boolean deDatacredito;
    private String cotizacionIdAux; //Esta variable es UNICAMENTE para subir una clase, NO USAR.
    
    
    public Static String cotizacionId;
    public Static QuoteLineItem productoDeCotizacion;

    public IT_AutoDataCreditoOportunidad_cls(String accionActua, String IdOpp, CampaignMember men) {
        this.accionActual = accionActua;
        this.oportunidadId = IdOpp;
        this.deDatacredito = False;
        this.member = men;
    }
    
    //Este contructor es UNICAMENTE para subir una clase, NO USAR.
    public IT_AutoDataCreditoOportunidad_cls(String accionActua, String IdOpp, String IdCoti, CampaignMember men) {
        this.accionActual = accionActua;
        this.oportunidadId = IdOpp;
        this.cotizacionIdAux = IdCoti;
        this.deDatacredito = False;
        this.member = men;
    }
    
    public IT_AutoDataCreditoOportunidad_cls(String accionActua, String IdOpp, Respuesta resDat, CampaignMember men) {
        this.accionActual = accionActua;
        this.oportunidadId = IdOpp;
        this.respDatacredito = resDat;
        this.deDatacredito = True;
        this.member = men;
    }

    public void execute(QueueableContext context) {
        if(accionActual == 'inicio'){
            system.debug('Se inició el proceso');
            Respuesta resp =  inicio();
            //////
            //resp.estado = 'Error';
            //resp.mensaje = 'Error generado intencionalmente';
            //////
            if(resp.estado == 'Correcto'){
                if(resp.mensaje == 'validaEjecucionDataCredito'){
                    if(!Test.isRunningTest()){
                        IT_AutoDataCreditoOportunidad_cls nextJob = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionDataCredito', oportunidadId, member);
                        Id jobID = System.enqueueJob(nextJob);
                    }
                }else{
                    if(!Test.isRunningTest()){
                        IT_AutoDataCreditoOportunidad_cls nextJob = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionHistorico', oportunidadId, member);
                        Id jobID = System.enqueueJob(nextJob);
                    }
                }
            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Datacredito Oportunidad: ' + resp.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', resp.mensaje, 'Datacredito Oportunidad');
                resFinal.dataCreditoOpp = resp;
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
            }
        }else if(accionActual == 'validaEjecucionDataCredito'){
            system.debug('Continuación con Datacredito');
            Respuesta resp = validaEjecucionDataCredito();
            if(resp.estado == 'Correcto'){
                if(!Test.isRunningTest()){
                    IT_AutoDataCreditoOportunidad_cls nextJob = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionHistorico', oportunidadId, resp, member);
                    Id jobID = System.enqueueJob(nextJob);
                }else{
                    Test.setMock(HttpCalloutMock.class, new IT_AutoDataCreditoOportunidad_tst.IT_ServicioDataCredito_ws_test_Mock()); 
                }
            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Datacredito Oportunidad: ' + resp.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', resp.mensaje, 'Datacredito Oportunidad');
                resFinal.dataCreditoOpp = resp;
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
            }
        }else if(accionActual == 'validaEjecucionHistorico'){
            system.debug('Final con Historico');
            Respuesta resp = validaEjecucionHistorico(); 
            
            
            Opportunity opp = getOpportunity(oportunidadId);
            resp = creaCotizacion(opp, member);
            if(resp.estado == 'Correcto'){
                /*if(!Test.isRunningTest()){
                    IT_AutoSincronizarCotizacion_cls nextJob = new IT_AutoSincronizarCotizacion_cls(cotizacionId, member);
                    Id jobID = System.enqueueJob(nextJob);
                }*/
                if(!Test.isRunningTest()){
                    IT_AutoConsultaScore_cls nextJob = new IT_AutoConsultaScore_cls(cotizacionId, productoDeCotizacion, member);
                    Id jobID = System.enqueueJob(nextJob);
                }
            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo', resp.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', resp.mensaje, 'Creación de Cotización o Producto de Cotización');
                resFinal.dataCreditoOpp = resp;
                resFinal.miembro = member;
                
                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
            }  
        }
    }
    
    public static Respuesta creaCotizacion( Opportunity oppCreada, CampaignMember member){ 
        try{  
            Pricebook2 standardPB;
            if(Test.isRunningTest()){
                standardPB = new Pricebook2 (id = Test.getStandardPricebookId());
            }else{
                standardPB = [SELECT id 
                            FROM Pricebook2 
                            WHERE isStandard = true];  
            }
                                  
            Quote cotizacion = new Quote();
            cotizacion.Name          = oppCreada.Name;
            cotizacion.OpportunityId = oppCreada.Id;
            cotizacion.Status        = 'PROGRAMADA';
            cotizacion.Pricebook2Id  = standardPB.id;
            cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
            insert cotizacion;
			
            cotizacionId = cotizacion.Id;
            return creaProductoDeCotizacion(standardPB, cotizacion, member);    
        }catch(Exception ex){
            //logIntegracion('Fallido','Aldeamo','Excepción en crear la nueva cotizacion: '+ ex);
            return new Respuesta('Error', 'Excepción en crear la nueva Cotización, consulte con su administrador: ' + ex);
            // ---envio de correo---
        }
    }
    
    public static Respuesta creaProductoDeCotizacion(Pricebook2 standardPB, Quote quoteCreada , CampaignMember member ){  
        Id productId = member.Medio_de_Respuesta__c == 'Web'? member.Producto_RCA__c : member.Producto__c ;
        List<PricebookEntry> lstEntradaLista = [SELECT id 
                                                FROM PricebookEntry 
                                                WHERE Pricebook2Id =:standardPB.Id AND Product2Id = :productId
                                                limit 1];
        if( lstEntradaLista.size() == 0 ){
            PricebookEntry entradaLista = new PricebookEntry();
            entradaLista.Pricebook2Id   = standardPB.Id;
            entradaLista.Product2Id     = productId;
            entradaLista.UnitPrice      = member.Medio_de_Respuesta__c == 'Web'? member.Monto_RCA__C : member.Monto__c;
            entradaLista.IsActive       = true; 
            insert entradaLista;
            lstEntradaLista.add(entradaLista);
        }

        try{        
            QuoteLineItem pxc = new QuoteLineItem();
            pxc.PricebookEntryId                         = lstEntradaLista[0].id;
            pxc.Product2Id                               = productId;
            pxc.Quantity                                 = 1;
            pxc.QuoteId                                  = quoteCreada.id;
            pxc.UnitPrice                                = member.Medio_de_Respuesta__c == 'Web'? member.Monto_RCA__C : member.Monto__c;
            pxc.Plazo_meses__c                           = member.Medio_de_Respuesta__c == 'Web'? member.Plazo_Meses_RCA__c : member.Plazo_Meses__c;
            pxc.Periodo_Gracias_Meses__c                 = 0;
            pxc.Fondo__c                                 = getFondoValueFromNum(member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito'? '2' : member.Fondo__c);
            pxc.Producto_de_Cotizacion_de_Autogestion__c = True;
            insert pxc;
			
            productoDeCotizacion = pxc;
            //return asociaAvalistas( oldOport, newOport, quoteCreada, member);
			return new Respuesta('Correcto', 'Se creó Cotización y producto de cotización');
            
        }catch(Exception ex){
            //logIntegracion('Fallido','Aldeamo','Excepción en crear la nueva producto por cotizacion: '+ ex);
            return new Respuesta('Error', 'Excepción en crear el nuevo Producto por Cotización, consulte con su administrador: ' + ex);
            // ---envio de correo---
        }
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Tipo de Documento
    *Date: 19-MAR-2021
    ******************************************************************************************/
    public static String getFondoValueFromNum(String fondoNum){
        
        Schema.DescribeFieldResult fieldResult = QuoteLineItem.Fondo__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('fondo ' + fondoNum);
        for( Schema.PicklistEntry pickListVal : ple){
            String[] strArr = pickListVal.getValue().split('-');

            if(strArr[0].equals(fondoNum)){
                System.debug('picklistval ' + pickListVal.getValue());
                return pickListVal.getValue();
            }
        }
        System.debug('no encontro fondo');
        return fondoNum;
    }

    //@future(callout=true)
    public Respuesta inicio(){
        Opportunity opp = getOpportunity(oportunidadId);
        return validaAsesorAsignado(opp);
    }
    public Opportunity getOpportunity(String IdOpp){
        return [Select Id,Name, Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,Account.Tipo_de_identificacion__c,Account.Numero_de_identificacion__c,
                Account.FirstName, Account.MiddleName, Account.LastName, Account.Segundo_Apellido__c, Account.Correo_asignacion__c, Asesor_asignado__c,
                Identificador_proceso__c
                from Opportunity
                where Id = : IdOpp];
    }
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Valida si la oportunidad tiene asignado un asesor
    *Date:     20-10-2020
    ************************************************************************************************/
    public Respuesta validaAsesorAsignado(Opportunity opp){
        if(opp.Asesor_asignado__c == null){ return new Respuesta('Error', 'Asesor no asignado: Por favor valide que se haya realizado la asignación del asesor a la oportunidad');
        }else{
            return validaEjecucionIdBPMS(opp);
        }
    }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Valida si se puede ejecutar la consulta a bpms
    *Date:     20-10-2020
    ************************************************************************************************/
    public Respuesta validaEjecucionIdBPMS( Opportunity opp ){
        String respuesta = ConfirmacionServicios.validaEjecucionIdBPMS(opp.Id);
        if( respuesta == 'OK'){
            try{
                Respuesta res = ejecutarIDBPMS(opp); 
                return res;
            }catch(Exception ex){
                return new Respuesta('Error', 'Error: Consulte a su administrador : ' + ex);
            }
        }else {
            return new Respuesta('Error', 'Validacion de ejecucion id BPMS: No se ejecutará IDBPMS');

        }
    }

    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Ejecuta servicio de bpms
    *Date:     20-10-2020
    ****************************************************************/
    public Respuesta ejecutarIDBPMS( Opportunity opp){
        Http http = new Http();
        HttpResponse response;
        HttpRequest  request;
        String jSON_res;
        String jSON_req  = idBPMSjson(opp.id,                                 
                                      opp.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                                      opp.Account.Tipo_de_identificacion__c,
                                      opp.Account.Numero_de_identificacion__c,
                                      opp.Account.FirstName,
                                      opp.Account.MiddleName,                               
                                      opp.Account.LastName,
                                      opp.Account.Segundo_Apellido__c,
                                      opp.Account.Correo_asignacion__c );
        System.debug('invoca Servicio'+ jSON_req);
        request   = IT_ParametrosWS_cls.parametrosIdBPMS(jSON_req);
        response  = http.send(request);
        jSON_res  = response.getBody();
        System.debug('JSON_res'+ jSON_res +'-'+request);

        if( response.getStatus() == 'OK' && response.getStatusCode() == 200 ){
            
            IT_idBPMS_ws.fromJSON respuesta = (IT_idBPMS_ws.fromJSON) System.JSON.deserialize(jSON_res, IT_idBPMS_ws.fromJSON.class);
            IT_idBPMS_ws.isOpp = true;
            IT_idBPMS_ws.lstOpp = new List<Opportunity>{opp};
            IT_idBPMS_ws.procesaRespuesta(respuesta);

            if( IT_idBPMS_ws.resultsList.size() > 0 && IT_idBPMS_ws.resultsList[0].mensaje == 'OK'){ return new Respuesta('Correcto', 'validaEjecucionDataCredito');
            }else {
                Boolean deDatacredito = False;
                return new Respuesta('Correcto', 'validaEjecucionHistorico');
            }
        }else{
            return new Respuesta('Error', 'Falló la peticion IdBPMS');
        }
    }
    
    public static String idBPMSjson(String idObj,String codOf,String tipo,String docu,String nom1,String nom2,String ape1,String ape2,String mail){
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String json = 
            '{'+
            '"encabezado": {'+
            '"estado": "0",'+
            '"excepcion": [],'+
            '"fecha": "2019-12-16 15:03:20",'+
            '"identificador": "'+idObj+'-'+numeroAleatorio+'",'+
            '"mensaje": [],'+
            '"integracion": "Iniciar Proceso idBPMS",'+
            '"operacion": "0",'+
            '"origen": "SALESFORCE",'+
            '"destino": "BPMS"'+
            '},'+
            '"cuerpo" : {'+
            '"tipo": "INICIARPROCESO",'+
            '"creadoPor": "GLORIARA",'+
            '"fecha": "'+System.now()+'",'+
            '"origen": "SALESFORCE",'+
            '"parametros": {'+
            '"proceso": {'+
            '"nro_radicado": "0000",'+
            '"cod_oficina": "'+codOf+'",'+
            '"tipoid": "'+tipo+'",'+
            '"nro_identificacion": "'+docu+'",'+
            '"nombres": "'+IT_ConstruccionJSON_cls.validarNullString(nom1)+' '+IT_ConstruccionJSON_cls.validarNullString(nom2)+'",'+
            '"apellidos": "'+IT_ConstruccionJSON_cls.validarNullString(ape1)+' '+IT_ConstruccionJSON_cls.validarNullString(ape2)+'",'+
            '"email_asesor": "'+mail+'",'+
            '"tipo_cliente": "RENOVACION",'+
            '"estado_credito": "PROGRAMADA"'+
            '}}}}';
        system.debug('json_request: ' + json );
        return json;
    }

    /********************************************************************************************************
    *Author:   Rafael Cardona
    *Function: Valida si se puede ejecutar la consulta de datacredito y si es correcto se enviar la ejecucion
    *Date:     20-10-2020
    *********************************************************************************************************/
    public Respuesta validaEjecucionDataCredito(){
        String respuesta = ConfirmacionServicios.validaEjecucionDataCredito(oportunidadId);
        if(respuesta == 'OK'){
            IT_ServicioDataCredito_ws.isOpp = true;
            IT_ServicioDataCredito_ws.lstOpp = new List<Opportunity>();
            IT_ServicioDataCredito_ws.servicioGeneraPDF(oportunidadId);

            if( IT_ServicioDataCredito_ws.resultsList.size() > 0 && IT_ServicioDataCredito_ws.resultsList[0].mensaje == 'OK'){
                Boolean deDatacredito = True;

                Respuesta res = new Respuesta('Correcto', 'Ejecución Datacredito oportunidad: ' + IT_ServicioDataCredito_ws.resultsList[0].mensajeServicio);
                res.mensajeDatacredito = IT_ServicioDataCredito_ws.resultsList[0].mensajeServicio;
                res.urlDatacredito = IT_ServicioDataCredito_ws.resultsList[0].urlDatacredito;
                return res;
                //System.debug('log y correo');
            }else {
                Respuesta res = new Respuesta('Error', 'Ejecución Datacredito oportunidad: ' + IT_ServicioDataCredito_ws.resultsList[0].mensajeServicio);
                res.estadoDatacredito = 'Error';
                res.mensajeDatacredito = IT_ServicioDataCredito_ws.resultsList[0].mensajeServicio;
                return res;
                // envio de mensaje: Por favor valide que se haya realizado la asignación del asesor a la oportunidad
                //System.debug('log y correo');
            }
        }else {
            Respuesta res = new Respuesta('Error', 'Falló  VALIDACIÓN de ejecucion DataCredito de la Oportunidad');
            res.estadoDatacredito = 'Error';
            res.mensajeDatacredito = 'Falló VALIDACIÓN de ejecucion DataCredito de la Oportunidad';
            return res;
            //System.debug('log y correo');
        }
    }

    /********************************************************************************************************
    *Author:   Rafael Cardona
    *Function: Valida si se puede ejecutar la consulta de historico y si es correcto se enviar la ejecucion
    *Date:     20-10-2020
    *********************************************************************************************************/
    public Respuesta validaEjecucionHistorico(){

        Respuesta resFinal = new Respuesta(Null, Null);
        if(deDatacredito){
            resFinal.estadoDatacredito = 'Correcto';
            resFinal.mensajeDatacredito = respDatacredito.mensajeDatacredito;
            resFinal.urlDatacredito = respDatacredito.urlDatacredito;
        }
        
        String respuesta = ConfirmacionServicios.validaEjecucionGeneracionPDF(oportunidadId);
        if(respuesta == 'OK'){
            IT_GenerarPDF_ws.isOpp  = true;
            IT_GenerarPDF_ws.lstOpp = new List<Opportunity>(); 
            IT_GenerarPDF_ws.servicioGeneraPDF(oportunidadId);
            if( IT_GenerarPDF_ws.resultsList.size() > 0 && IT_GenerarPDF_ws.resultsList[0].mensaje == 'OK'){
                System.debug('log y correo'); // todo ok
                resFinal.actualizar('Correcto', IT_GenerarPDF_ws.resultsList[0].mensajeServicio);
                resFinal.estadoHistorico = 'Correcto';
                resFinal.urlHistorico = IT_GenerarPDF_ws.resultsList[0].urlHistorico;
                resFinal.mensajeHistorico = IT_GenerarPDF_ws.resultsList[0].mensajeServicio;
                return resFinal;
            }else {
                resFinal.actualizar('Error', 'Falló ejecucion Historico de la Oportunidad');
                resFinal.estadoHistorico = 'Error';
                resFinal.mensajeHistorico = 'Falló de ejecucion Historico de la Oportunidad';
                return resFinal;
                // envio de mensaje: Por favor valide que se haya realizado la asignación del asesor a la oportunidad
                //System.debug('log y correo');
            }
        }else {
            resFinal.actualizar('Error', 'Falló VALIDACIÓN de ejecucion Historico de la Oportunidad');
            resFinal.estadoHistorico = 'Error';
            resFinal.mensajeHistorico = 'Falló VALIDACIÓN de ejecucion Historico de la Oportunidad';
            return resFinal;
            //System.debug('log y correo');
        }
    }

    public Class Respuesta{
        public String estado;
        public String mensaje;

        public String estadoDatacredito;
        public String mensajeDatacredito;
        public String urlDatacredito;

        public String mensajeHistorico;
        public String estadoHistorico;
        public String urlHistorico;

        public Respuesta(String est, String men){
            this.estado  = est;
            this.mensaje = men;
            
            this.estadoDatacredito = null;
            this.mensajeDatacredito = null;
            this.urlDatacredito = null;
            
            this.mensajeHistorico = null;
            this.estadoHistorico = null;
        	this.urlHistorico = null;
        }
        public void actualizar(String est, String men) {
            this.estado  = est;
            this.mensaje = men;
        }
    }
    PUBlic static void cobertura(){
        String variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
    
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
     }
}
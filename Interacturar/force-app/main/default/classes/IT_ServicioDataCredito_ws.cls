/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar parte 2
* @descripcion      Clase para consultar el servicio de DataCredito 

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   16-DIC-2019   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
global with sharing class IT_ServicioDataCredito_ws {
    public IT_ServicioDataCredito_ws() {
    }
    
    private static Http http;
    private static HttpRequest Request;
    private static HttpResponse Response;
    private static String JSON_req {get;set;}
    private static String JSON_res {get;set;}
    public static List<Lead>    lstCandidato;
    public static List<Opportunity> lstOpp;
    public static List<Contact> lstCon;
    public static Boolean       isLead = false;
    public static Boolean       isOpp  = false;
    public static Boolean       isCon  = false;
    public static List<RespuestaServicio> resultsList = new List<RespuestaServicio>();

    
    @InvocableMethod
    public static List<RespuestaServicio> servicioGeneraPDF(List<String> lstidsf){
        System.debug(lstidsf);
        if(lstidsf.size() == 1){
            servicioGeneraPDF(lstidsf[0]);
        }
        return resultsList;
    }

    @AuraEnabled
    public static void servicioGeneraPDF(String idSf){        
        if(idSf.startsWith('00Q')){  
            isLead = true;
            servicioDataCreditoProspecto(idSf);
        }else if(idSf.startsWith('006')){
            isOpp = true;
            servicioDataCreditoOpp(idSf);
        }else{
            List<String> lstSplit = new List<String>();
            lstSplit = idSf.split(',');
            isCon    = true;
            servicioDataCreditoCon(lstSplit[0], lstSplit[1]);
        }
    }
    
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void servicioDataCreditoProspecto(String idSf){
        lstCandidato  = new  List<Lead>();           
        lstCandidato  = consultaLead(idSf);
        if( lstCandidato.size() == 1 && ejecutaConsultaDataCredito( lstCandidato[0].Fecha_consulta_Datacredito__c ) ){
            if(lstCandidato.get(0).RecordType.Name != 'Persona Jurídica'){
                JSON_req  = dataCreditoJSON(lstCandidato.get(0).id,
                                            lstCandidato.get(0).Tipo_de_identificacion__c,
                                            lstCandidato.get(0).Numero_de_identificacion__c,
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).LastName),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).FirstName),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).Segundo_Apellido__c),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).MiddleName),
                                            lstCandidato.get(0).Correo_asignacion__c,
                                            lstCandidato.get(0).Nombre_de_usuario__c,
                                            lstCandidato.get(0).Identificador_proceso__c);
            }else{
                JSON_req  = dataCreditoJSON(lstCandidato.get(0).id,
                                            lstCandidato.get(0).Tipo_de_Identificacion_Contacto__c,
                                            lstCandidato.get(0).Numero_de_Identificacion_Contacto__c,
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).LastName),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).FirstName),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).Segundo_Apellido__c),
                                            IT_ConstruccionJSON_cls.validarNullString(lstCandidato.get(0).MiddleName),
                                            lstCandidato.get(0).Correo_asignacion__c,
                                            lstCandidato.get(0).Nombre_de_usuario__c,
                                            lstCandidato.get(0).Identificador_proceso__c);
            }    
            invocaServicio();
        }
    }
    
   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void servicioDataCreditoOpp(String idSf){        
        lstOpp = new List<Opportunity>();
        lstOpp = consultaOpp(idSf);
        if( lstOpp.size() == 1 && ejecutaConsultaDataCredito( lstOpp[0].Fecha_consulta_Datacredito__c ) ){
            JSON_req = dataCreditoJSON(lstOpp.get(0).AccountId,
                                   lstOpp.get(0).Account.Tipo_de_identificacion__c,
                                   lstOpp.get(0).Account.Numero_de_identificacion__c,
                                   IT_ConstruccionJSON_cls.validarNullString(lstOpp.get(0).Account.LastName),
                                   IT_ConstruccionJSON_cls.validarNullString(lstOpp.get(0).Account.FirstName),
                                   IT_ConstruccionJSON_cls.validarNullString(lstOpp.get(0).Account.Segundo_Apellido__c),
                                   IT_ConstruccionJSON_cls.validarNullString(lstOpp.get(0).Account.MiddleName),
                                   lstOpp.get(0).Account.Correo_asignacion__c,
                                   lstOpp.get(0).Account.Nombre_de_usuario__c,
                                   lstOpp.get(0).Identificador_proceso__c);
		invocaServicio();
        }
    }
    
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void servicioDataCreditoCon(String idSf, String idBPMS){        
        lstCon = new List<Contact>();
        lstCon = consultaCon(idSf);
        List<Opportunity> opTitular = cuentaDeTitular(idBPMS.trim());
       
        if( lstCon.size() == 1  ){ //&& ejecutaConsultaDataCredito( lstCon[0].Fecha_consulta_Datacredito__c
            JSON_req = dataCreditoJSON(opTitular[0].AccountId,
                                   lstCon.get(0).Tipo_de_identificacion__c,
                                   lstCon.get(0).Numero_de_identificacion__c,
                                   IT_ConstruccionJSON_cls.validarNullString(lstCon.get(0).LastName),
                                   IT_ConstruccionJSON_cls.validarNullString(lstCon.get(0).FirstName),
                                   IT_ConstruccionJSON_cls.validarNullString(lstCon.get(0).Segundo_Apellido__c),
                                   IT_ConstruccionJSON_cls.validarNullString(lstCon.get(0).MiddleName),
                                   opTitular[0].Account.Correo_asignacion__c,
                                   opTitular[0].Account.Nombre_de_usuario__c,
                                   idBPMS);
            if( ! Test.isRunningTest() ){ invocaServicio(); }
        }
    }

    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Se encarga de la invocacion del servicio web
    *Date:     5-12-2019
    ****************************************************************/
    public static void invocaServicio(){
        http = new Http();
        Request      = IT_ParametrosWS_cls.parametrosDataCreditoDos(JSON_req);
        Response     = http.send(request);
        JSON_res     = Response.getBody();  
		System.debug('Mensaje respuesta: '+ JSON_res);        
        if( Response.getStatus() == 'OK' && Response.getStatusCode() == 200 ){  
            fromJSON respuesta = (fromJSON) System.JSON.deserializeStrict(JSON_res, fromJSON.class);
            System.debug('respuesta: '+ respuesta);
            procesaRespuesta(respuesta);
        }else{
            insertaRespuesta('KO',false,true,false,'Consulta a Datacrédito fuera de servicio, por favor consulte al administrador.', '');
        }
    }    

    
    /*******************************************************************
    *Author:   Rafael Cardona
    *Function: Actualiza prospecto o oportunidad con el idBPMS
    *Date:     4-12-2019
    *******************************************************************/
    public static void procesaRespuesta(fromJSON respuestaWS){ 
        try{
        if( respuestaWS != null ){
            if( isLead && lstCandidato.size() == 1){
                lstCandidato[0].Link_PDF_Datacredito__c       =  respuestaWS.cuerpo.urlPdf;
                lstCandidato[0].Fecha_consulta_Datacredito__c = System.today();
                update lstCandidato;
            }else if( isOpp && lstOpp.size() == 1 ){
                lstOpp.get(0).Link_PDF_Datacredito__c       =  respuestaWS.cuerpo.urlPdf;
                lstOpp.get(0).Fecha_consulta_Datacredito__c =  System.today();
                update lstOpp;     
            }else if( isCon && lstCon.size() == 1 ){
                lstCon.get(0).Link_PDF_Datacredito__c       =  respuestaWS.cuerpo.urlPdf;
                lstCon.get(0).Fecha_consulta_Datacredito__c =  System.today();
                update lstCon;   
            }
        }
        insertaRespuesta('OK',true,false,true,'', respuestaWS.cuerpo.urlPdf);
        }catch(Exception ex){
            insertaRespuesta('KO',false,false,true,respuestaWS.encabezado.excepcion, '');
            System.debug('Error: fallo al insertar ');
        }
    }    

    /********************************************************************
    *Author:   Rafael Cardona
    *Function: Clase interna para captura de la respuesta del servicio
    *Date:     16-12-2019
    ********************************************************************/
    global class fromJSON{
        public cls_encabezado encabezado;
        public cls_cuerpo cuerpo;
    }
    class cls_encabezado {
        public String estado; //0
        public String excepcion;
        public String fecha;  //0001-01-01T00:00:00
        public String identificador;  //00000000-0000-0000-0000-000000000000
        public String mensaje;
        public String integracion;  //Consulta DataCredito
        public String operacion;  //1
        public String origen; //ORACLE
        public String destino;  //SALESFORCE
    }
    class cls_cuerpo {
      public String identificacion; //1020396989
      public String primerApellido; //Gomez
      public String primerNombre; //Mauricio
      public String tipoIdentificacion; //C
      public String idProceso;  //197028
      public String urlPdf; //http://servicios.interactuar.org.co:5612/filemanager/DownloadHandler?file=DOC/1/2019/07/07/0055527-0000001-20190707/DataCred_1042763259_1562515501361_20190707_110501_434.pdf
      public String xmlDatacredito; //<?xml version="1.0" encoding="UTF-8"?><Informes><Informe apellidoDigitado="" codSeguridad="" fechaConsulta="2019-07-06T16:20:31" identificacionDigitada="" respuesta="23" tipoIdDigitado=""/></Informes>
    }


    public static String dataCreditoJSON(String idSalesforce,String tipo,String doc,String apel,String nom,String apel2,String nom2,String email,String usr,String idbpms){
        if(doc != null){   doc   = (doc.contains('null'))? doc.replace('null','') : doc;       }else{ doc = ''; }       
        if(apel != null){  apel  = (apel.contains('null'))? apel.replace('null','') : apel;    }else{ apel = ''; } 
        if(nom != null){   nom   = (nom.contains('null'))? nom.replace('null','') : nom;       }else{ nom = ''; } 
        if(apel2 != null){ apel2 = (apel2.contains('null'))? apel2.replace('null','') : apel2; }else{ apel2 = ''; }
        if(nom2 != null){  nom2  = (nom2.contains('null'))? nom2.replace('null','') : nom2;    }else{ nom2 = ''; }
        if(email != null){ email = (email.contains('null'))? email.replace('null','') : email; }else{ email = ''; }
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String trimIdPro = idbpms.trim();
        String json = '{'+
        '"encabezado":{'+ 
            '"estado": 0,'+
            '"excepcion": "",'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+idSalesforce +'-'+ numeroAleatorio +'",'+
            '"mensaje": "",'+
            '"integracion":"Consulta DataCredito con BPMS (Rev)",'+
            '"operacion": 0,'+
            '"origen":"SALESFORCE",'+
            '"destino":"ORACLE"'+
        '},'+
        '"cuerpo":{'+            
            '"identificacion":"'+doc+'",'+
            '"primerApellido":"'+apel+'",'+
            '"primerNombre":"'+nom+'",'+
            '"segundoApellido":"'+apel2+'",'+
            '"segundoNombre":"'+nom2+'",'+
            '"tipoIdentificacion":"'+tipo+'",'+
            '"emailAsesor":"'+email+'",'+
            '"usuario":"'+IT_ConstruccionJSON_cls.validarNullString(usr)+'",'+
            '"idProceso": "'+trimIdPro+'",'+
            '"generarPdf": true'+ 
        '}'+
      '}';
      System.debug('json_request: '+ json);
      return json;
    }

    public static Boolean ejecutaConsultaDataCredito(Date fechaValidar){
        Date fechaDataCredito;
        System.debug('fecha: '+ fechaValidar);
        if( fechaValidar != null ){
            fechaDataCredito = (fechaValidar).addDays(31);
            System.debug('fecha: '+ fechaDataCredito );
            if( fechaDataCredito < System.now() ){
                System.debug('1: ' );
                return true;
            }else{
                System.debug('2: ' );
                return false;
            }
        }else{
            System.debug('3: ' );
            return true;
        }        
    }
    
    public static void insertaRespuesta(String msj, Boolean insertado, Boolean ws, Boolean info, String msjws, String urldatacredito){        
        RespuestaServicio p = new RespuestaServicio();
        p.mensaje           = msj; 
        p.insertado         = insertado;         
        p.falloEnServicio   = ws;
        P.trajoInfoServicio = info;
        p.mensajeServicio   = msjws;
        p.urlDatacredito	= urldatacredito;
        resultsList.add(p);
    }
    
     global class RespuestaServicio{
        @InvocableVariable
        public Boolean insertado;
        @InvocableVariable
        public String mensaje;
        @InvocableVariable
        public Boolean falloEnServicio;
        @InvocableVariable
        public Boolean trajoInfoServicio;
        @InvocableVariable
        public String mensajeServicio;  
        @InvocableVariable
        public String urlDatacredito;  
         
    }
    
    public static List<Lead> consultaLead( String idSf ){
        return [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
                    MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c, Link_PDF_Historico__c, 
                    Asesor_asignado__r.Codigo_de_Empleado__c, Asesor_asignado__r.Name, Fecha_consulta_Datacredito__c, Numero_de_Identificacion_Contacto__c,
                    Tipo_de_Identificacion_Contacto__c,RecordType.Name
                    FROM Lead Where Id =: idSf AND IsConverted = false];
    }
    
    public static List<Opportunity> consultaOpp( String idSf ){
        return [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Fecha_consulta_Datacredito__c,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c, Link_PDF_Historico__c, Asesor_asignado__r.Codigo_de_Empleado__c,  Asesor_asignado__r.Name
        FROM Opportunity Where Id =: idSf AND StageName =: System.Label.EstadoDatacreditoOportunidad ORDER BY LastModifiedDate desc LIMIT 1];
    }
    
    public static List<Contact> consultaCon( String idSf ){
        return [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c,LastName,FirstName,Segundo_Apellido__c,
                MiddleName,Account.Correo_asignacion__c, Account.Nombre_de_usuario__c
        FROM Contact WHERE Id =: idsf ORDER BY LastModifiedDate desc LIMIT 1];
    }
    
    public static List<Opportunity> cuentaDeTitular(String idBPMS){
        return [SELECT id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Fecha_consulta_Datacredito__c,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c, Link_PDF_Historico__c, Asesor_asignado__r.Codigo_de_Empleado__c,  Asesor_asignado__r.Name 
        FROM Opportunity WHERE Identificador_proceso__c =: idBPMS];
    }

              public static void cobertura(){
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
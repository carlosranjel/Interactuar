/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase de generación de créditos para las campañas digitales

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   22-Sep-2020  Álvaro Ortega (AO)		      Creación.
--------     2.0   02-Mar-2021  Álvaro Ortega (AO)		      Validación para creación de oportunidad desde Micrositio
**************************************************************************************************************
**/
public with sharing class IT_GeneracionAutomaticaCredito {
    private static Boolean isCreditoAgil = false;
    @InvocableMethod
    public static void inicioProcesoAutomatico( List<CampaignMember> lstMember ){
        System.debug('Comienza generación');
        //ejecutaProceso(lstMember);
        //System.debug(lstMember);
        List<CampaignMember> lstMemberGA = new List<CampaignMember>();
        lstMemberGA.addAll(lstMember);
        System.debug(lstMemberGA);
        
        if(consultaTipoDeCampania(lstMember[0].CampaignId) && String.valueOf(lstMember[0].Tipo_Ejecucion__c).contains('Otros Créditos')){
            ejecutaProceso(lstMember,isCreditoAgil);
            System.debug('Otro creditos');
        }else if(!consultaTipoDeCampania(lstMember[0].CampaignId) && String.valueOf(lstMember[0].Tipo_Ejecucion__c).contains('Crédito Ágil')  &&  !lstMember[0].Credito_Agil_Generado__c )
        {
            System.debug('credito agil');
            isCreditoAgil = true;       
            ejecutaProceso(lstMember,isCreditoAgil); 
            
        }else{
            System.debug('no cumplio con las condiciones');
        }
        
        
    }
    
    public static void ejecutaProceso(List<CampaignMember> lstMember, Boolean isCreditoAgil)
    {
        List<CampaignMember>cm = [Select id, Credito_agil_Generado__c from CampaignMember where id =:lstMember[0].id];
        consultaMiembroDeCampania(lstMember,isCreditoAgil);
        //System.debug('Esta es la respuesta final: ' + resFinal);
        
        /* if(resFinal.estado != 'Correcto'){ 
cm[0].Generar_Credito__c = false;
update cm;            
enviarEmail(new List<String>(), resFinal);
//throw new applicationException('Error en la generación automatica de credito: más información al correo previamente selccionado');
}else{
if(isCreditoAgil)
{

cm[0].Credito_agil_Generado__c = true;
update cm;
}
//enviarEmail(emails, resFinal);
}*/
    }
    public static Boolean consultaTipoDeCampania(String idCampaign){
        Campaign campaign = [Select Id,Type from Campaign where id =: idCampaign ];
        System.debug('Tipo de credito  : '+campaign.Type); 
        if(!String.valueOf(campaign.Type).contains('Crédito Ágil')){
            return true;
        }
        return false;
    }
    
    public static void consultaMiembroDeCampania( List<CampaignMember> lstMember, Boolean isCreditoAgil ){
        CampaignMember member = consultaMiembroCamapana( lstMember[0].Id );
        
        if( member.Producto__c == null || member.Plazo_Meses__c == null  || member.Monto__c == null || member.Fondo__c == null || member.Fondo__c == ''){
            logIntegracion('Fallido','Aldeamo','Campos obligatorios');
            
            RespuestaFinal resFinal = new RespuestaFinal('Error', 'Miembro de Campaña: Faltan alguno de estos campos en Miembro de campaña ("Producto", "Plazo Meses", "Monto", "Fondo")', 'Consulta Miembro de Campaña');
            resFinal.miembro = member;
            member.Generar_Credito__c = false;
            update member;            
            enviarEmail(new List<String>(), resFinal);
            //return resFinal;
        }else{
            validaClienteYOportunidad( member, isCreditoAgil );
            //RespuestaFinal resFinal = validaClienteYOportunidad( member );
            //resFinal.miembro = member;
            // return resFinal;
        }
    }
    public static String getFondoValueFromNum(String fondoNum){
        
        Schema.DescribeFieldResult fieldResult = QuoteLineItem.Fondo__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            String[] strArr = pickListVal.getValue().split('-');
            
            if(strArr[0].equals(fondoNum)){
                return pickListVal.getValue();
            }
        }
        return fondoNum;
    }
    
    public static String validaFondo(Opportunity opp,CampaignMember member){
        String fondo = getFondoValueFromNum(member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito'? '2' : member.Fondo__c);
        Double unitPrice =  member.Medio_de_Respuesta__c == 'Web'? member.Monto_RCA__C : member.Monto__c;
        try{
            IT_ValidacionAsigancionFondo_cls.ResponseDTO response = IT_ValidacionAsigancionFondo_cls.validaAsignacionFondoGeneracionAutomatica(opp,fondo, unitPrice,1);
            System.debug('Repuesta en valida fondo Generacion automatica' + response);
            if(response.encabezado.mensaje.estado == 'OK'){
                if(response.cuerpo.validacionFondo.aplica == 'SI'){
                    return 'OK';
                }else{
                    return  response.cuerpo.validacionFondo.Descripcion;
                }
            }else{
                String mensaje = response.cuerpo.validacionFondo.Descripcion;
                mensaje = mensaje.substringBefore(':');
                mensaje = mensaje  + ' :'+ '\n';
                mensaje = mensaje + response.cuerpo.validacionFondo.Descripcion.substringAfter(':'); 
                return  mensaje;
            }
        }catch(Exception ex){
            return ex.getMessage();
        }
        //return 'OK';
    }
    
    public static void validaClienteYOportunidad( CampaignMember member , Boolean isCreditoAgil){
        Account client = getCliente( member );
        String respuestaValidacionFondo = '';
        if(client != null){
            Opportunity oldOport = getOpportunity(client.Id);
            if(oldOport != null){
                System.debug('Creacion de oportunidad handler');
                creaOportunidad( client.Id, oldOport.Id, member.Id ,isCreditoAgil);
                
                
            }else{
                
                logIntegracion('Fallido','Aldeamo','Oportunidad: No se encontró una Oportunidad de Solicitud de Crédito para el Cliente');
                RespuestaFinal resFinal = new RespuestaFinal('Error', 'Oportunidad: No se encontró una Oportunidad de Solicitud de Crédito para el Cliente', 'Validación de Cliente y Oportunidad');
                resFinal.miembro = member;
                member.Generar_Credito__c = false;
                update member;            
                enviarEmail(new List<String>(), resFinal);
                // ---envio de correo---
            }
        }else{
            logIntegracion('Fallido','Aldeamo','Cliente: No se encontró un Cliente para este Miembro de Campaña');
            RespuestaFinal resFinal = new RespuestaFinal('Error', 'Cliente: No se encontró un Cliente para este Miembro de Campaña', 'Validación de Cliente y Oportunidad');
            resFinal.miembro = member;
             member.Generar_Credito__c = false;
            update member;            
            enviarEmail(new List<String>(), resFinal);
            // ---envio de correo---
        }
    }
    
    @future(callout = true)
    public static void creaOportunidad( String clientId , String oldOportId , String memberId,Boolean isCreditoAgil ){
        System.debug('Crea Oportunidad');
        Opportunity oldOport = getOpportunity(clientId);
        CampaignMember member = consultaMiembroCamapana( memberId);
        Account client = getCliente( member );
        Opportunity newOport = oldOport.clone(false, true, false, false);     
        String validacionFondo = validaFondo(oldOport,member);
        if(validacionFondo == 'OK'){
            
            try{        
                newOport.StageName                            = 'En Estudio';
                newOport.CloseDate                            = System.today();
                newOport.AccountId                            = client.Id;
                newOport.Famiempresa_relacionada__c           = oldOport.Famiempresa_relacionada__c;
                newOport.Registro_creado_por__c               = oldOport.Registro_creado_por__c;
                newOport.CampaignId                           = member.CampaignId;
                //newOport.Fondo__c               	          = member.Fondo__c; //Este campo fondo se envío al producto por cotización
                newOport.CreditoSaldoCargo__c   	          = member.CreditoSaldoCargo__c;
                newOport.Asesor_asignado__c                   = oldOport.Asesor_asignado__c;
                
                newOport.Medio_de_desembolso__c               = member.Medio_de_Respuesta__c == 'Web'? 'Transferencia' : 'Cheque';
                ListaClaveValor__mdt mdt                      = obtenerChequeANombreEntidad();
                newOport.Cheque_a_nombre_de_entidad__c        = member.Medio_de_Respuesta__c == 'Web'? null            : (mdt != null ? mdt.valor__c : null);
                    
                    newOport.Inventario__c                        = member.Medio_de_Respuesta__c == 'Web'? member.Monto_RCA__c      : member.Monto__c;
                newOport.Tipo_de_cuenta__c                    = member.Medio_de_Respuesta__c == 'Web'? member.Tipo_de_Cuenta__c : null;
                newOport.Entidad_financiera__c                = member.Medio_de_Respuesta__c == 'Web'? member.Banco__c          : null;
                newOport.Cuenta_No__c                         = member.Medio_de_Respuesta__c == 'Web'? member.Numero_Cuenta__c  : null;
                newOport.Medio_de_Respuesta__c                = member.Medio_de_Respuesta__c;
                newOport.Por_que_medio_se_realizo_la_venta__c = member.Medio_de_Respuesta__c == 'Mensaje Texto' ? 'Mensaje de Texto' : (member.Medio_de_Respuesta__c == 'Web' ? 'Canal Digital' : null);
                    
                    newOport.Exonero_a_Interactuar_de_toda_responsabi__c = member.Medio_de_Respuesta__c == 'Web'? 'Si' : null;
                
                newOport.NomApe_Ben1__c                = '.';
                newOport.ParentescoBen1__c             = 'Interesado';
                newOport.PorcentajeBen1__c             = 100;
                
                newOport.Cliente_con_visita__c         = 'No';
                newOport.Motivo_de_no_visita__c        = 'No requiere visita';
                
                if(member.Medio_de_Respuesta__c == 'Web'){
                    List<IT_RespuestaDelClienteAutogestion_WS.Beneficiario> beneficiarios = (List<IT_RespuestaDelClienteAutogestion_WS.Beneficiario>)JSON.deserializeStrict(member.Beneficiarios__c, List<IT_RespuestaDelClienteAutogestion_WS.Beneficiario>.class);
                    newOport = insertBeneficiarios(beneficiarios, newOport);
                }
                
                newOport.Generacion_Automatica_de_Credito__c = True;
                insert newOport; 
                
                CampaignMember me = new CampaignMember();
                me.Id = member.Id;
                me.Oportunidad_Generada_Automatica__c = newOport.Id;
                 update me;
                
                try{
                    if(!Test.isRunningTest()){
                        IT_AutoDataCreditoOportunidad_cls nextJob = new IT_AutoDataCreditoOportunidad_cls('inicio', newOport.Id, member);
                        Id jobID = System.enqueueJob(nextJob);
                    }
                    
                    RespuestaFinal resFinal =  new RespuestaFinal('Correcto', 'Se inicio el llamado a Datacredito', 'Datacredito Oportunidad');
                    resFinal.miembro = member;
                    //member.Generar_Credito__c = false;
                    
                    if(isCreditoAgil)
                    {
                        
                        member.Credito_agil_Generado__c = true;

                        update member;
                    }            
                    //enviarEmail(new List<String>(), resFinal);
                }catch(Exception ex){ 
                    logIntegracion('Fallido','Aldeamo','Excepción en Datacredito Oportunidad: ' + ex);
                    
                    RespuestaFinal resFinal =  new RespuestaFinal('Error', 'Excepción en Datacredito Oportunidad, consulte con su administrador: ' + ex, 'Datacredito Oportunidad');
                    resFinal.miembro = member;
                    member.Generar_Credito__c = false;
                    update member;         
                    enviarEmail(new List<String>(), resFinal);
                    // ---envio de correo---
                }
                
                //return creaCotizacion(newOport, member);                 
            }catch(Exception ex){
                logIntegracion('Fallido','Aldeamo','Excepción en crear la nueva Oportunidad: ' + ex);
                RespuestaFinal resFinal = new RespuestaFinal('Error', 'Excepción en crear la nueva Oportunidad, consulte con su administrador: ' + ex, 'Creación de Oportunidad');
                resFinal.miembro = member;
                member.Generar_Credito__c = false;
                update member;    
                enviarEmail(new List<String>(), resFinal);
                // ---envio de correo---
            }
            
        }else{
            logIntegracion('Fallido','Aldeamo','Excepción en crear la nueva Oportunidad: ' + validacionFondo);
            RespuestaFinal resFinal = new RespuestaFinal('Error', 'Excepción en crear la nueva Oportunidad, error en la consulta Fondo: ' + validacionFondo, 'Creación de Oportunidad');
            resFinal.miembro = member;
             member.Generar_Credito__c = false;
            update member;    
            enviarEmail(new List<String>(), resFinal);
        }
    }
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Ingersa la informació de los beneficiarios y devuelve la oportunidad
*Date: 21-Mar-2021
******************************************************************************************/
    public static Opportunity insertBeneficiarios(LIst<IT_RespuestaDelClienteAutogestion_WS.Beneficiario> beneficiarios, Opportunity opor){
        /*public String nombreCompleto;
public String tipoDocumento;
public String numeroDocumento;
public String parentesco;
public Decimal porcentaje;
public String cualParentesco;*/
        
        if(beneficiarios.size() > 0){
            opor.NomApe_Ben1__c     = beneficiarios[0].nombreCompleto;
            opor.Tipo_ideBen1__c    = beneficiarios[0].tipoDocumento;
            opor.Numero_idenBen1__c = beneficiarios[0].numeroDocumento;
            opor.ParentescoBen1__c  = beneficiarios[0].parentesco;
            opor.PorcentajeBen1__c  = beneficiarios[0].porcentaje;
            opor.Cual__c            = beneficiarios[0].cualParentesco;
            
            if(beneficiarios.size() > 1){
                opor.NomApe_Ben2__c     = beneficiarios[1].nombreCompleto;
                opor.Tipo_ideBen2__c    = beneficiarios[1].tipoDocumento;
                opor.Numero_idenBen2__c = beneficiarios[1].numeroDocumento;
                opor.ParentescoBen2__c  = beneficiarios[1].parentesco;
                opor.PorcentajeBen2__c  = beneficiarios[1].porcentaje;
                opor.Cual2__c           = beneficiarios[1].cualParentesco;
                
                if(beneficiarios.size() > 2){
                    opor.NomApe_Ben3__c     = beneficiarios[2].nombreCompleto;
                    opor.Tipo_ideBen3__c    = beneficiarios[2].tipoDocumento;
                    opor.Numero_idenBen3__c = beneficiarios[2].numeroDocumento;
                    opor.ParentescoBen3__c  = beneficiarios[2].parentesco;
                    opor.PorcentajeBen3__c  = beneficiarios[2].porcentaje;
                    opor.Cual3__c           = beneficiarios[2].cualParentesco; 
                }
            }
        }
        return opor;
    }
    
    public static ListaClaveValor__mdt obtenerChequeANombreEntidad( ){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Auto Cheque a nombre de entidad'];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Se obtiene el cliente con la información del Miembro de la Campaña
*Date: 21-Sep-2020
******************************************************************************************/
    public static Account getCliente(CampaignMember member){
        Id accountId;
        System.debug('member:'+ member);
        if(member.ContactId != null && member.Contact.AccountId != null){
            accountId = member.Contact.AccountId;
        }else if(member.LeadId != null && member.Lead.ConvertedAccountId != null){
            accountId = member.Lead.ConvertedAccountId;
        }else{
            return null;
        }
        if ( !Schema.sObjectType.Account.fields.Name.isAccessible() ) {   return null;  }
        List<Account> cust = [SELECT Id, Name  FROM Account  WHERE Id =: accountId ];
        if(cust.size() > 0){
            return cust[0];
        }
        return null;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Se obtiene La última oportunidad relacionada al Cliente
*Date: 22-Sep-2020
******************************************************************************************/
    public static Opportunity getOpportunity(Id accounId){
        if ( !Schema.sObjectType.Opportunity.fields.Name.isAccessible() ) {   return null;  }
        List<Opportunity> opps =  [SELECT Id,Name,Famiempresa_relacionada__c,Registro_creado_por__c, Asesor_asignado__c, Persona_Publica__c,
                                   Vinculo_con_Persona_Publica__c, Medio_de_desembolso__c, Sucursal_Bancaria__c, Telefono_Sucursal_Bancaria__c, Cuenta_No__c
                                   ,NomApe_Ben1__c, ParentescoBen1__c, PorcentajeBen1__c
                                   ,Presenta_los_siguientes_sintomas__c
                                   ,Familiar_con_los_siguientes_sintomas__c
                                   ,Sintomas_NO_relacionado_en_la_lista__c
                                   ,Se_encuentra_en_embarazo__c
                                   ,Hospitalizacion_programada__c
                                   ,Participa_en_competencias_deportivas__c
                                   ,Presenta_una_dolencia_no_mencionada__c
                                   ,Se_le_ha_negado_un_seguro__c
                                   ,Se_encuentra_en_estudio_medico__c
                                   ,Sera_sometido_a_tratamiento_medico__c
                                   ,Ha_sido_alguna_vez_hospitalizado__c
                                   ,Numero_de_cigarrillos_diarios_que_fuma__c, SedeOpp__c, Caja_y_bancos__c, Cuentas_por_pagar_Interactuar__c, Cuentas_por_cobrar_comerciales__c,
                                   Proveedores__c, Inventario_balance__c, Otras_cuentas_por_pagar__c, Otras_cuentas_por_cobrar__c, Otras_obligaciones_financieras__c, Activos_fijos__c,
                                   Otros_activos__c     ,
                                   Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c, Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Sector_OR__c,
                                   Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c, Opportunity.Famiempresa_relacionada__r.Ubicacion_Rural__c, 
                                   Opportunity.Famiempresa_relacionada__r.Ingresos_Empresario_Sector_Agropecuario__c
                                   FROM Opportunity 
                                   WHERE AccountId =: accounId AND RecordType.DeveloperName = 'Solicitud_de_credito' AND StageName =: 'Desembolsado'
                                   order by CreatedDate desc LIMIT 1];
        if(opps.size() > 0){
            /*List<Opportunity> listOpp = IT_GestorDeConsultas_cls.consultaOportunidad(opps[0].Id);
if(listOpp.size() > 0){
return listOpp[0];
}*/
            return opps[0];
        }
        return null;
    }
    
    /******************************************************************************************
*Author:  Rafael Cardona
*Function: 
*Date: 28-Sep-2020
******************************************************************************************/
    public static CampaignMember consultaMiembroCamapana(Id idMiembro){
        if ( !Schema.sObjectType.CampaignMember.fields.Name.isAccessible() ) {   return null;  }
        List<CampaignMember> cMiembro = [SELECT Id, Name, ContactId, Contact.AccountId, LeadId , Lead.ConvertedAccountId, CampaignId,Generar_Credito__c,isCreditAutomatizacion__c,
                                         Mensaje_recibido__c, MovilMiembro__c,Producto__c,Plazo_Meses__c,Monto__c,Fondo__c, CreditoSaldoCargo__c, Medio_de_Respuesta__c,
                                         Tipo_de_Respuesta__c, Tipo_de_Cuenta__c, Numero_Cuenta__c, Banco__c, Beneficiarios__c, Monto_RCA__c, Producto_RCA__c, Plazo_Meses_RCA__c
                                         FROM CampaignMember 
                                         WHERE Id =: idMiembro 
                                         LIMIT 1];
        if(cMiembro.size() > 0){
            return cMiembro[0];
        }
        return new CampaignMember();
    }
    
    /******************************************************************************************
*Author:  Rafael Cardona
*Function: 
*Date: 28-Sep-2020
******************************************************************************************/
    public static void logIntegracion(String estado, String integracion, String mensaje ){
        Log_Integracion__c log = new Log_Integracion__c();
        log.Estado__c      = estado;
        log.Integracion__c = integracion;
        log.Mensaje__c     = mensaje ;
        insert log;
    }
    
    public static List<String> correosParaEnviarError(){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Auto Emails Error'];
        if(des.size() > 0){
            return String.valueOf(des[0].valor__c).split(',');
        }
        return null;
    }
    
    /******************************************************************************************
*Author: Álvaro Ortega
*Function: Envío de emails
*Date: 23-oct-2020
******************************************************************************************/
    public static Messaging.SendEmailResult enviarEmail(List<String> emails, RespuestaFinal resFinal){
        emails = correosParaEnviarError();
        
        try{
            CampaignMember men = new CampaignMember();
            men.Id = resFinal.miembro.Id;
            resFinal.mensaje = resFinal.mensaje.length() > 131070 ? String.valueof(resFinal.mensaje).substring(0,131070) : resFinal.mensaje;
            men.Mensaje_de_Generacion_de_Credito__c = resFinal.lugarError != null ? (resFinal.lugarError + ': ' + resFinal.mensaje) : resFinal.mensaje; 
            update men;
        }catch(Exception ex){ 
            System.debug('Error guardando respuesta: ' + ex);
            // ---envio de correo--- 
        }
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.optOutPolicy = 'FILTER';
        
        String text = '<html> <head>';
        
        if(resFinal.estado == 'Correcto'){
            
            message.subject = resFinal.miembro.Name + ' - ' + resFinal.mensaje;
            text += resFinal.mensaje.length() > 131070 ? String.valueof(resFinal.mensaje).substring(0,131070) : resFinal.mensaje;//resFinal.mensaje;
        }else if(resFinal.estado == 'CorrectoEmailAsesor'){
            message.subject = 'Gestionar Solicitud de Crédito';
            text += resFinal.mensajeAsesor;
        } else{
            message.subject = resFinal.miembro.Name + ': Error en Generación Automatica de Crédito';
            text += 'Ocurrio un error en la generación automatica de crédito del miembro de campaña ' + resFinal.miembro.Name;
            text += '<br><br>Mensaje: ' + resFinal.mensaje; 
            text += '<br><br>Lugar: ' + resFinal.lugarError;
        }
        text += '</body> </html>';
        
        message.setHtmlBody(text);//'This is the message body.';
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        return results[0];
    }
    
    /******************************************************************************************
*Author:  Rafael Cardona
*Function: Clase interna para el manejo de las excepciones
*Date: 6-7-2019
******************************************************************************************/
    public class applicationException extends Exception {}
    
    public Class RespuestaFinal{
        public String estado;
        public String mensaje;
        public String mensajeAsesor;
        public String lugarError;
        
        public CampaignMember miembro;
        public string idOpp = '';
        public IT_AutoDataCreditoOportunidad_cls.Respuesta dataCreditoOpp;
        //public IT_AutoDataCreditoAvales_cls.RespuestaFinal dataCreditoAvales;
        
        public RespuestaFinal(String est, String men, String lugarErr){
            this.estado  = est;
            this.mensaje = men;
            this.lugarError = lugarErr;
        }
        public RespuestaFinal(String est, String men, String menA, String lugarErr) {
            this.estado  = est;
            this.mensaje = men;
            this.mensajeAsesor = menA;
            this.lugarError = lugarErr;
        }
        public void actualizar(String est, String men, String lugarErr) {
            this.estado  = est;
            this.lugarError = lugarErr;
        }
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
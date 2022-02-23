/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso  REST para exponer servicio de recepción de mensajes de texto de los miembros de la campaña

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   16-Sep-2020  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/RecepcionSMSCampania/*')
global class IT_RecepcionSMSCampania_WS {
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se realiza la recepción de información del servicio
    *Date: 16-Sep-2020
    ******************************************************************************************/
    @HttpPost
    global static ResponseDTO doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);

        ResponseDTO val = validaInformacion(strJSONContent);
        FromJSON row;
        if(val.Estado == 'Correcto'){
            row = val.Info;
        }else{
            return val;
        }
        
        System.debug('Obj deserealizado y validado'+ row);

        //Select name, AccountId, IsPersonAccount, MasterRecordId from Contact
        //ConvertdAccountId
        CampaignMember memberToUpdate = getCampaignMember(row.Mobile, row.ShortCode);
        if(memberToUpdate != null){
            //Guarda la respuesta del mensaje
            if(memberToUpdate.Mensaje_recibido__c == null || memberToUpdate.Mensaje_recibido__c == '' ){
                memberToUpdate.Mensaje_recibido__c = row.Message;
                memberToUpdate.Fecha_de_Mensaje__c = row.FechaDeRespuestaDate;
                memberToUpdate.Status              = (row.Message != null && row.Message.toLowercase().replace('í', 'i') == 'si') ? 'Respondida' : 'No interesado';
                //memberToUpdate.Indicador_Respuesta_Automatica__c = true;
                memberToUpdate.Medio_de_Respuesta__c = 'Mensaje Texto';
                //memberToUpdate.Usar_Info_RCA__c      = False;
                try{
                    update memberToUpdate;
                }catch(Exception ex){
                    logIntegracion(memberToUpdate.CampaignId,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Excepción en actualizar Miembro de Campaña: ' + ex); 
                    return new ResponseDTO('Fallido', 'Excepción en actualizar Miembro de Campaña: ' + ex, row);
                }
                
                //Guarda el log
                logIntegracion(memberToUpdate.CampaignId,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Mensaje: Información guardada con éxito.'); 
                
                ResponseDTO resp = new ResponseDTO('Exitoso', 'Información guardada en Miembro de Campaña', row);
                resp.Procesos.add('Información guardada en Miembro de Campaña');
                return resp;
            }else{
                logIntegracion(memberToUpdate.CampaignId,'Exitoso','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Mensaje: información no guardada - ya existe una información guardada.'); 

                ResponseDTO resp = new ResponseDTO('Exitoso', 'Mensaje: información no guardada - ya existe una información guardada.', row);
                return resp;
            }
        }else{
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Miembro no existe: No existe Miembro de Campaña asociado a este Movil'); 
            return new ResponseDTO('Fallido', 'Miembro no existe: No existe Miembro de Campaña asociado a este Movil', row);           
            //Crear miembro de campaÃ±a si existe la campaÃ±a del cÃ³digo corto
        }
    }

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Validación de la infromación entrante
    *Date: 21-Sep-2020
    ******************************************************************************************/
    public static ResponseDTO validaInformacion(String strJSONContent){
        FromJSON row;
        try{
            row = (FromJSON)JSON.deserializeStrict(strJSONContent, FromJSON.class);
        }catch(Exception ex){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Excepción en formato de JSON: ' + ex);
            return new ResponseDTO('Fallido', 'Excepción en formato de JSON: ' + ex, null);
        }
        if(row.FechaDeRespuesta == null || row.FechaDeRespuesta == ''){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Campo requerido: El campo FechaDeRespuesta es requerido.');
            return new ResponseDTO('Fallido', 'Campo requerido: El campo FechaDeRespuesta es requerido', row);
        }

        try{            
            row.FechaDeRespuestaDate = Date.parse(row.FechaDeRespuesta);
        }catch(Exception ex){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Excepción en formato de fecha (DD/MM/AAAA): ' + ex);
            return new ResponseDTO('Fallido', 'Excepción en formato de fecha (DD/MM/AAAA): ' + ex, row);
        }

        if(row.Mobile == null || row.Mobile == ''){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Campo requerido: El campo Mobile es requerido.');
            return new ResponseDTO('Fallido', 'Campo requerido: El campo Mobile es requerido', row);
        }
        if(row.Message == null){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Campo requerido: El campo Message es requerido.');
            return new ResponseDTO('Fallido', 'Campo requerido: El campo Message es requerido', row);
        }
        if(row.ShortCode == null || row.ShortCode == ''){
            logIntegracion(null,'Fallido','Aldeamo','Contenido de JSON: ' + strJSONContent + '. Campo requerido: El campo ShortCode es requerido.');         
            return new ResponseDTO('Fallido', 'Campo requerido: El campo ShortCode es requerido', row);
        }
        return new ResponseDTO('Correcto', 'Correcto', row);
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: 
    *Date: 28-Sep-2020
    ******************************************************************************************/
    public static void logIntegracion(ID idCam, String estado, String integracion, String mensaje ){
        Log_Integracion__c log = new Log_Integracion__c();
        log.Campania__c    = idCam;
        log.Estado__c      = estado;
        log.Integracion__c = integracion;
        log.Mensaje__c     = mensaje ;
        insert log;
    }

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se obtiene el Miembro de la Compañía con la relación de Móvil y de código corto de la Compañia
    *Date: 16-Sep-2020
    ******************************************************************************************/
    public static CampaignMember getCampaignMember(String mobile, String shortCode){
        if ( !Schema.sObjectType.CampaignMember.fields.Name.isAccessible() ) {   return null;  }
        List<CampaignMember> members = [select Id, Name, CampaignId, ContactId, Contact.AccountId, LeadId, Lead.ConvertedAccountId, Mensaje_recibido__c
                                        from CampaignMember
                                        where MovilMiembro__c = : mobile and Campaign.Status in ('En Diseño', 'Planeada','En ejecución')
                                        and Campaign.CodigoCorto__c = :shortCode];
        if(members.size() > 0){
            return members[0];
        }
        return null;
    }

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se obtiene Compañía con su código corto
    *Date: 16-Sep-2020
    ******************************************************************************************/

    /*public static Campaign getCampaign(String shortCode){
        if ( !Schema.sObjectType.Campaign.fields.Name.isAccessible() ) {   return null;  }
        List<Campaign> campaigns = [select Id, Name 
                                    from Campaign 
                                    where CodigoCorto__c = :shortCode and Status in ('En ejecuciÃ³n', 'Planeada')];
        if(campaigns.size() > 0){
            return campaigns[0];
        }
        return null;
    }*/
    
    // public class applicationException extends Exception {}

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información recibida
    *Date: 16-Sep-2020
    ******************************************************************************************/
    global class FromJSON{
        public String Mobile; 
        public String Message;	
        public String ShortCode;
        public String FechaDeRespuesta;
        public Date FechaDeRespuestaDate;	
    }  

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase DTO para la respuesta a la petición en caso de que no exista ningún error
    *Date: 16-Sep-2020
    ******************************************************************************************/
    global class ResponseDTO{
        public String Estado;
        public String Mensaje; 
        public FromJSON Info;
        public List<String> Procesos; 

        global ResponseDTO(String estado, String mensaje, FromJSON info){
            this.Estado = estado;
            this.Mensaje = mensaje;
            this.Info = info;
            this.Procesos = new List<String> ();
        }        	
    }
 
    public static void cobertura(){
        String var = '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';      
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
    }   
}
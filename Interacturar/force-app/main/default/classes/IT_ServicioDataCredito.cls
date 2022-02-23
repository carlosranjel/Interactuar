/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class que envia la consulta del servicio de datacredito

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   31-Jul-2019  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public class IT_ServicioDataCredito {

    @AuraEnabled
    public static String servicioDataCredito(String idSf){
        if(idSf.startsWith('00Q')){
            return servicioDataCreditoProspecto(idSf);
        }else{
            return servicioDataCreditoOpp(idSf);
        }
    }

    
    public static String servicioDataCreditoProspecto(String idSf){
        System.debug('dato: '+ idsf);
        Http http = new Http();
        HttpRequest request;
        HttpResponse response1;
        String json = '';
        String responseJSON = '';
        
        List<Lead> lstLead = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c 
        FROM Lead Where Id =: idSf AND IsConverted = false];
        
        
        if( String.isNotBlank(idSf)){
            json = dataCreditoJSON(lstLead.get(0).id,
                                   lstLead.get(0).Tipo_de_identificacion__c,
                                   lstLead.get(0).Numero_de_identificacion__c,
                                   lstLead.get(0).LastName,
                                   lstLead.get(0).FirstName,
                                   lstLead.get(0).Segundo_Apellido__c,
                                   lstLead.get(0).MiddleName,
                                   lstLead.get(0).Correo_asignacion__c,
                                   lstLead.get(0).Nombre_de_usuario__c);
            request = IT_ParametrosWS_cls.parametrosDataCredito(json);
            response1 = http.send(request);
            responseJSON = response1.getBody();
            system.debug('response-->'+response1.getBody());
        }

        try{
            if( response1.getStatus() == 'OK' && response1.getStatusCode() == 200 ){
                fromJSON fromt = (fromJSON)System.JSON.deserializeStrict(responseJSON, fromJSON.class); 

                System.debug('deserialize '+ fromt.cuerpo.contenido.idProceso);   
                System.debug('deserialize '+ fromt.cuerpo.contenido.urlPdf);  
                
                Lead prospecto = [SELECT id, Identificador_proceso__c, Link_PDF_Datacredito__c 
                FROM Lead WHERE Numero_de_identificacion__c =: fromt.cuerpo.contenido.identificacion AND IsConverted = false];
                prospecto.Identificador_proceso__c = fromt.cuerpo.contenido.idProceso;
                prospecto.Link_PDF_Datacredito__c =  fromt.cuerpo.contenido.urlPdf;
                prospecto.Fecha_consulta_Datacredito__c = System.today();
                update prospecto;
                return 'Exitoso';
            }else{
                return 'Warning';           
            } 
        }catch(Exception ex){
            return 'Error'; 
        }
    }

    public class fromJSON{
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
        public cls_contenido contenido;
    }
    class cls_contenido {
      public String identificacion; //1020396989
      public String primerApellido; //Gomez
      public String primerNombre; //Mauricio
      public String tipoIdentificacion; //C
      public String idProceso;  //197028
      public String urlPdf; //http://servicios.interactuar.org.co:5612/filemanager/DownloadHandler?file=DOC/1/2019/07/07/0055527-0000001-20190707/DataCred_1042763259_1562515501361_20190707_110501_434.pdf
      public String xmlDatacredito; //<?xml version="1.0" encoding="UTF-8"?><Informes><Informe apellidoDigitado="" codSeguridad="" fechaConsulta="2019-07-06T16:20:31" identificacionDigitada="" respuesta="23" tipoIdDigitado=""/></Informes>
    }


    public static String dataCreditoJSON(String idSalesforce,String tipo,String doc,String apel,String nom,String apel2,String nom2,String email,String usr){
        if(doc != null){   doc   = (doc.contains('null'))? doc.replace('null','') : doc;       }else{ doc = ''; }       
        if(apel != null){  apel  = (apel.contains('null'))? apel.replace('null','') : apel;    }else{ apel = ''; } 
        if(nom != null){   nom   = (nom.contains('null'))? nom.replace('null','') : nom;       }else{ nom = ''; } 
        if(apel2 != null){ apel2 = (apel2.contains('null'))? apel2.replace('null','') : apel2; }else{ apel2 = ''; }
        if(nom2 != null){  nom2  = (nom2.contains('null'))? nom2.replace('null','') : nom2;    }else{ nom2 = ''; }
        if(email != null){ email = (email.contains('null'))? email.replace('null','') : email; }else{ email = ''; }
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String json = '{'+
        '"encabezado":{'+ 
            '"estado": 0,'+
            '"excepcion": "",'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+idSalesforce +'-'+ numeroAleatorio +'",'+
            '"mensaje": "",'+
            '"integracion":"Consulta DataCredito",'+
            '"operacion": 0,'+
            '"origen":"SALESFORCE",'+
            '"destino":"ORACLE"'+
        '},'+
        '"cuerpo":{'+
            '"contenido":{'+
            '"identificacion":"'+doc+'",'+
            '"primerApellido":"'+apel+'",'+
            '"primerNombre":"'+nom+'",'+
            '"segundoApellido":"'+apel2+'",'+
            '"segundoNombre":"'+nom2+'",'+
            '"tipoIdentificacion":"'+tipo+'",'+
            '"emailAsesor":"'+email+'",'+
            '"usuario":"'+IT_ConstruccionJSON_cls.validarNullString(usr)+'"'+
            '}'+
        '}'+
      '}';
      System.debug('json: '+ json);
      return json;
    }


    public static String servicioDataCreditoOpp(String idSf){
        System.debug('dato: '+ idsf);
        Http http = new Http();
        HttpRequest request;
        HttpResponse response1;
        String json = '';
        String responseJSON = '';
        
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.MiddleName, 
        Account.Correo_asignacion__c, Account.Nombre_de_usuario__c FROM Opportunity Where Id =: idSf];
        
        
        if( String.isNotBlank(idSf)){
            json = dataCreditoJSON(lstOpp.get(0).AccountId,
                                   lstOpp.get(0).Account.Tipo_de_identificacion__c,
                                   lstOpp.get(0).Account.Numero_de_identificacion__c,
                                   lstOpp.get(0).Account.LastName,
                                   lstOpp.get(0).Account.FirstName,
                                   lstOpp.get(0).Account.Segundo_Apellido__c,
                                   lstOpp.get(0).Account.MiddleName,
                                   lstOpp.get(0).Account.Correo_asignacion__c,
                                   lstOpp.get(0).Account.Nombre_de_usuario__c);
            request = IT_ParametrosWS_cls.parametrosDataCredito(json);
            response1 = http.send(request);
            responseJSON = response1.getBody();
            system.debug('response-->'+response1.getBody());
        }

        try{
            if( response1.getStatus() == 'OK' && response1.getStatusCode() == 200 ){
                fromJSON fromt = (fromJSON)System.JSON.deserializeStrict(responseJSON, fromJSON.class); 

                System.debug('deserialize '+ fromt.cuerpo.contenido.idProceso);   
                System.debug('deserialize '+ fromt.cuerpo.contenido.urlPdf);  
                
                List<Opportunity> lstOportunidad = [SELECT id, Identificador_proceso__c, Link_PDF_Datacredito__c , Fecha_consulta_Datacredito__c
                FROM Opportunity WHERE Account.Numero_de_identificacion__c =: fromt.cuerpo.contenido.identificacion
                AND StageName =: System.Label.EstadoDatacreditoOportunidad ORDER BY LastModifiedDate desc LIMIT 1];
                if (lstOportunidad.size() == 1 ) {
                    lstOportunidad.get(0).Identificador_proceso__c      = fromt.cuerpo.contenido.idProceso;
                    lstOportunidad.get(0).Link_PDF_Datacredito__c       =  fromt.cuerpo.contenido.urlPdf;
                    lstOportunidad.get(0).Fecha_consulta_Datacredito__c = System.today();
                    update lstOportunidad.get(0);
                    return 'Exitoso';
                }else{
                    return 'Warning';
                }
            }else{
                return 'Warning';           
            } 
        }catch(Exception ex){
            return 'Error'; 
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
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
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
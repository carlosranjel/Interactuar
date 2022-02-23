/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar parte 2
* @descripcion      Clase para consultar el servicio de IDBPMS 

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   4-DIC-2019   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
global with sharing class IT_idBPMS_ws {

    private static Http         http;
    private static HttpRequest  Request;
    private static HttpResponse Response;
    private static String       JSON_req {get;set;}
    private static String       JSON_res {get;set;}
    public static List<Lead>    lstCandidato;
    public static List<Opportunity> lstOpp;
    public static Boolean       isLead  = false;
    public static Boolean       isOpp   = false;
    public static List<RespuestaServicio> resultsList = new List<RespuestaServicio>();

    public IT_idBPMS_ws() { }

   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Identifica si la logica se invoca desde un prospecto o una oportunidad
    *Date:     5-12-2019
    ************************************************************************************************/
    @InvocableMethod
    public static List<RespuestaServicio> servicioIdBPMS(List<Id> lstidsf){ if(lstidsf.size() == 1){servicioIdBPMS(lstidsf[0]);} return resultsList;
    }
         
    @AuraEnabled
    public static void servicioIdBPMS(String idSf){        
        if(idSf.startsWith('00Q')){ 
            isLead = true; 
            inicioServicioIdBPMSLead(idSf);
        }else{
            isOpp = true;
            inicioServicioIdBPMSopp(idSf);
        }
    }

   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void inicioServicioIdBPMSLead(String idSf){
        lstCandidato  = new  List<Lead>();           
        lstCandidato  = consultaLead(idSf);
        if( lstCandidato.size() == 1 ){ 
            if( lstCandidato[0].RecordType.DeveloperName == 'Persona_natural' ){
                JSON_req  = idBPMSjson(lstCandidato[0].id,                            
                                       lstCandidato[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                                       lstCandidato[0].Tipo_de_identificacion__c,
                                       lstCandidato[0].Numero_de_identificacion__c,
                                       lstCandidato[0].FirstName,
                                       lstCandidato[0].MiddleName,                               
                                       lstCandidato[0].LastName,
                                       lstCandidato[0].Segundo_Apellido__c,
                                       lstCandidato[0].Correo_asignacion__c );
                System.debug('invoca Servicio'+ JSON_req);
                invocaServicio();
            }else{
                JSON_req  = idBPMSjson(lstCandidato[0].id,                            
                                       lstCandidato[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                                       lstCandidato[0].Tipo_de_identificacion__c,
                                       lstCandidato[0].Numero_de_identificacion__c,
                                       lstCandidato[0].Company,
                                       null,                               
                                       lstCandidato[0].Tipo_de_empresa__c,
                                       null,
                                       lstCandidato[0].Correo_asignacion__c );
                System.debug('invoca Servicio'+ JSON_req);
                invocaServicio();
            }
        }
    }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void inicioServicioIdBPMSopp(String idSf){        
        lstOpp = new List<Opportunity>();
        lstOpp = consultaOpp(idSf);
        if( lstOpp.size() == 1 ){
            if( lstOpp[0].Account.RecordType.DeveloperName == 'Persona_natural' ){
                JSON_req  = idBPMSjson(		
                    lstOpp[0].id,                                 
                    lstOpp[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                    lstOpp[0].Account.Tipo_de_identificacion__c,
                    lstOpp[0].Account.Numero_de_identificacion__c,
                    lstOpp[0].Account.FirstName,
                    lstOpp[0].Account.MiddleName,                               
                    lstOpp[0].Account.LastName,
                    lstOpp[0].Account.Segundo_Apellido__c,
                    lstOpp[0].Account.Correo_asignacion__c
                );
                System.debug('invoca Servicio'+ JSON_req);
                invocaServicio();
            }else{
                JSON_req  = idBPMSjson(		
                    lstOpp[0].id,                                 
                    lstOpp[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                    lstOpp[0].Account.Tipo_de_identificacion__c,
                    lstOpp[0].Account.Numero_de_identificacion__c,
                    lstOpp[0].Account.Name,
                    null,                               
                    lstOpp[0].Account.Tipo_de_empresa__c,
                    null,
                    lstOpp[0].Account.Correo_asignacion__c
                );
                System.debug('invoca Servicio'+ JSON_req);
                invocaServicio();
            }
        }
    }

    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Se encarga de la invocacion del servicio web
    *Date:     5-12-2019
    ****************************************************************/
    public static void invocaServicio(){
        http = new Http();System.debug('json_req: '+ JSON_req);
        Request      = IT_ParametrosWS_cls.parametrosIdBPMS(JSON_req);
        System.debug('Request'+ Request);
        Response     = http.send(request);
        JSON_res     = Response.getBody();
        System.debug('JSON_res'+ JSON_res);
        fromJSON respuesta = (fromJSON) System.JSON.deserialize(JSON_res, fromJSON.class);
        if( Response.getStatus() == 'OK' && Response.getStatusCode() == 200 ){            
            System.debug('respuesta: '+ respuesta);
            procesaRespuesta(respuesta);
        }else{
            insertaRespuesta('KO',false,true,false,respuesta.encabezado.excepcion,respuesta.cuerpo.respuesta.idProceso);
        }
    }

    
   /*******************************************************************
    *Author:   Rafael Cardona
    *Function: Actualiza prospecto o oportunidad con el idBPMS
    *Date:     4-12-2019
    *******************************************************************/
    public static void procesaRespuesta(fromJSON respuestaWS){        
        if( respuestaWS != null && (respuestaWS.encabezado.excepcion == '' || respuestaWS.encabezado.excepcion == null) &&  String.isNotBlank(respuestaWS.cuerpo.respuesta.idProceso) ){
            if( isLead && lstCandidato.size() == 1 ){
                lstCandidato[0].Identificador_proceso__c = respuestaWS.cuerpo.respuesta.idProceso;
                update lstCandidato;                
                }else if( isOpp && lstOpp.size() == 1 ){
                lstOpp[0].Identificador_proceso__c = respuestaWS.cuerpo.respuesta.idProceso;
                update lstOpp;
            }
            insertaRespuesta('OK',true,false,true,'',respuestaWS.cuerpo.respuesta.idProceso);
        }else if( respuestaWS != null && ( respuestaWS.encabezado.excepcion != '' || respuestaWS.encabezado.excepcion != null ) ){
            insertaRespuesta('KO',false,false,false,respuestaWS.encabezado.excepcion,respuestaWS.cuerpo.respuesta.idProceso);
        }
    }
    
    public static void insertaRespuesta(String msj, Boolean insertado, Boolean ws, Boolean info, String msjws, String idbpms){        
        RespuestaServicio p = new RespuestaServicio();
        p.mensaje           = msj; 
        p.insertado         = insertado;         
        p.falloEnServicio   = ws;
        P.trajoInfoServicio = info;
        p.mensajeServicio   = msjws;
        p.idBPMS			= idbpms;
        resultsList.add(p);
    }

   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Arma el JSON de la peticion para el servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    private static String idBPMSjson(String idObj,String codOf,String tipo,String docu,String nom1,String nom2,String ape1,String ape2,String mail){
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
    


   /********************************************************************
    *Author:   Rafael Cardona
    *Function: Clase interna para captura de la respuesta del servicio
    *Date:     5-12-2019
    ********************************************************************/
    global class fromJSON{
        public cls_encabezado encabezado;
        public cls_cuerpo cuerpo;
    }
    class cls_encabezado {
        public String estado;
        public String excepcion;
        public String fecha;
        public String identificador;
        public String mensajeEncabezado;
        public String integracion;
        public String operacion;
        public String origen;
        public String destino;
    }
    class cls_cuerpo {
        public cls_respuesta respuesta;
    }
    class cls_respuesta {
        public String error;
        public String mensaje;
        public String idProceso;
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
        public String idBPMS;        
    }

    public static List<Lead> consultaLead( String idSf ){
        return [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c,RecordType.DeveloperName,Company,Tipo_de_empresa__c,
        Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c FROM Lead Where Id =: idSf AND IsConverted = false];
    }
    public static List<Opportunity> consultaOpp( String idSf ){
        return [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Account.RecordType.DeveloperName,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Tipo_de_empresa__c,Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c,
        Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c FROM Opportunity Where Id =: idSf ];
    }
}
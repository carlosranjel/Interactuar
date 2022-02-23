/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar parte 2
* @descripcion      Clase para consultar el servicio de GenerarPDF 

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   9-DIC-2019   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
global with sharing class IT_GenerarPDF_ws {

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

    public IT_GenerarPDF_ws() {}
    
    @InvocableMethod
    public static List<RespuestaServicio> servicioGeneraPDF(List<String> lstidsf){
        if(lstidsf.size() == 1){
            servicioGeneraPDF(lstidsf[0]);
        }
        return resultsList;
    }

    @AuraEnabled
    public static void servicioGeneraPDF(String idSf){        
        if(idSf.startsWith('00Q')){  
            isLead = true;
            inicioServicioGeneraPDFLead(idSf);
        }else if(idSf.startsWith('006')){
            isOpp = true;
            inicioServicioGeneraPDFopp(idSf);
        }else{
            List<String> lstSplit = new List<String>();
            lstSplit = idSf.split(',');
            isCon    = true;
            inicioServicioGeneraPDFCon(lstSplit[0], lstSplit[1]);
        }
    }

   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void inicioServicioGeneraPDFLead(String idSf){
        lstCandidato  = new  List<Lead>();           
        lstCandidato  = consultaLead(idSf);
        if( lstCandidato.size() == 1 ){
            if(lstCandidato[0].RecordType.Name != 'Persona Jurídica'){
                JSON_req  = generarPDFjson(lstCandidato[0].Identificador_proceso__c,
                                           String.valueof(Integer.valueof((Math.random() * 999999))), 
                                           lstCandidato[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, 
                                           lstCandidato[0].Tipo_de_identificacion__c, 
                                           lstCandidato[0].Numero_de_identificacion__c, 
                                           lstCandidato[0].Asesor_asignado__r.Nombre_de_usuario__c);
            }else{
                JSON_req  = generarPDFjson(lstCandidato[0].Identificador_proceso__c,
                                           String.valueof(Integer.valueof((Math.random() * 999999))), 
                                           lstCandidato[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, 
                                           lstCandidato[0].Tipo_de_Identificacion_Contacto__c, 
                                           lstCandidato[0].Numero_de_Identificacion_Contacto__c, 
                                           lstCandidato[0].Asesor_asignado__r.Nombre_de_usuario__c);
            }
            System.debug('Peticion: '+ JSON_req);
            invocaServicio(); 
        }
    }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void inicioServicioGeneraPDFopp(String idSf){        
        lstOpp = new List<Opportunity>();
        lstOpp = consultaOpp(idSf);
        if( lstOpp.size() == 1 ){ 
        JSON_req  = generarPDFjson(lstOpp[0].Identificador_proceso__c,
                                   String.valueOf(Integer.valueof((Math.random() * 999999))), 
                                   lstOpp[0].Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, 
                                   lstOpp[0].Account.Tipo_de_identificacion__c, 
                                   lstOpp[0].Account.Numero_de_identificacion__c, 
                                   lstOpp[0].Asesor_asignado__r.Nombre_de_usuario__c);
         invocaServicio(); 
        }
    }
    
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web idBPMS
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void inicioServicioGeneraPDFCon(String idSf, String idBPMS){        
        lstCon = new List<Contact>();  
        lstCon = consultaCon(idSf);
        List<Opportunity> opTitular = cuentaDeTitular(idBPMS.trim());
        
        if( lstCon.size() == 1 && opTitular.size() == 1 ){ //&& ejecutaConsultaDataCredito( lstCon[0].Fecha_consulta_Datacredito__c
        JSON_req  = generarPDFjson(idBPMS,
                                   String.valueOf(Integer.valueof((Math.random() * 999999))), 
                                   opTitular[0].Account.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, 
                                   lstCon[0].Tipo_de_identificacion__c, 
                                   lstCon[0].Numero_de_identificacion__c, 
                                   opTitular[0].Account.Asesor_asignado__r.Nombre_de_usuario__c);
            if(! Test.isRunningTest() ){invocaServicio(); }
        }
    }

    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Se encarga de la invocacion del servicio web
    *Date:     5-12-2019
    ****************************************************************/
    public static void invocaServicio(){
        http = new Http();
        Request      = IT_ParametrosWS_cls.parametrosGenerarPDF(JSON_req);
        Response     = http.send(request);
        JSON_res     = Response.getBody();
        System.debug('Mensaje respuesta: '+ JSON_res);       
        if( Response.getStatus() == 'OK' && Response.getStatusCode() == 200 ){      
            fromJSON respuesta = (fromJSON) System.JSON.deserialize(JSON_res, fromJSON.class);
            System.debug('respuesta: '+ respuesta);
            procesaRespuesta(respuesta);
        }else{
            insertaRespuesta('KO',false,true,false,'Fallo servicio','');
        }
    }

    /*******************************************************************
    *Author:   Rafael Cardona
    *Function: Actualiza prospecto, oportunidad o aval con el resultado de la consulta.
    *Date:     4-12-2019
    *******************************************************************/
    public static void procesaRespuesta(fromJSON respuestaWS){        
        if( respuestaWS != null && ( respuestaWS.encabezado.excepcion == null || respuestaWS.encabezado.excepcion == '') &&  String.isNotBlank(respuestaWS.cuerpo.url) ){
            if( isLead && lstCandidato.size() == 1){
                lstCandidato[0].Link_PDF_Historico__c = respuestaWS.cuerpo.url;
                update lstCandidato;
            }else if( isOpp && lstOpp.size() == 1 ){
                lstOpp[0].Link_PDF_Historico__c = respuestaWS.cuerpo.url;
                
                update lstOpp;
            }else if( isCon && lstCon.size() == 1 ){
                lstCon.get(0).Link_PDF_Historico__c = respuestaWS.cuerpo.url;
                update lstCon;   
            }
            insertaRespuesta('OK',true,false,true,respuestaWS.cuerpo.mensaje, respuestaWS.cuerpo.mensaje);
        }else if( respuestaWS != null && ( respuestaWS.encabezado.excepcion == null || respuestaWS.encabezado.excepcion == '') &&  String.isBlank(respuestaWS.cuerpo.url) ){
            insertaRespuesta('OK',false,false,false,respuestaWS.cuerpo.mensaje,respuestaWS.cuerpo.url);
        }
        else if( respuestaWS != null && respuestaWS.encabezado.excepcion != '' ){
            insertaRespuesta('KO',false,false,false,respuestaWS.encabezado.excepcion,respuestaWS.cuerpo.url);
        }
    }

    public static void insertaRespuesta(String msj, Boolean insertado, Boolean ws, Boolean info, String msjws, String urlhistorico){        
        RespuestaServicio p = new RespuestaServicio();
        p.mensaje           = msj; 
        p.insertado         = insertado;         
        p.falloEnServicio   = ws;
        P.trajoInfoServicio = info;
        p.mensajeServicio   = msjws;
        p.urlHistorico		= urlhistorico;
        resultsList.add(p);
    }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Arma el JSON de la peticion para el servicio web idBPMS
    *Date:     5-12-2019
    ************************************************************************************************/
    private static String generarPDFjson(String idPro, String noRad, String codOf, String tipoId, String numIdeCli, String nomAse){
        String trimIdPro = idPro.trim();
        String json = '{'+
            '"encabezado": {'+
                '"estado": 0,'+
                '"excepcion": null,'+
                '"fecha": "0001-01-01T00:00:00",'+
                '"identificador": "00000000-0000-0000-0000-000000000000",'+
                '"mensaje": null,'+
                '"integracion": "Generar PDF BPMS",'+
                '"operacion": 0,'+ //Request
                '"origen": "SALESFORCE",'+
                '"destino": "BPMS"'+
            '},'+
            '"cuerpo" : {'+
                '"infoGeneral": {'+
                '"productoId": "",'+
                '"requestId": "1122121212121212121",'+
                '"tipo": "GENERARPDF",'+
                '"creadoPor": "GLORIARA",'+
                '"fecha": "'+System.now()+'",'+
                '"origen": "SALESFORCE"'+
                '},'+
                '"configReporte": {'+
                '"nombreReporte": "RCOHICRCL",'+            
                '"parametros": ['+
                '{'+
                '"clave": "NRORADICADO",'+ 
                '"valor": "",'+  // id objeto que se genere mas un aleatorio de 3 dig '+noRad+'
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "OFICINA",'+
                '"valor": "'+codOf+'",'+ // codigo de la oficina de la asesora asignada "'+codAse+'"
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "PTIPOID",'+
                '"valor": "'+tipoId+'",'+  // tipo de identificacion lead o cliente de opp
                '"destino": "shell"'+
                '},'+
                '{'+
                '"clave": "TIPOID",'+
                '"valor": "'+tipoId+'",'+  // tipo de identificacion lead o cliente de opp 
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "PIDENT",'+
                '"valor": "'+numIdeCli+'",'+
                '"destino": "shell"'+
                '},'+
                '{'+
                '"clave": "NROID",'+
                '"valor": "'+numIdeCli+'",'+ // num identificacion de lead o cliente
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "P_USUARIO",'+
                '"valor": "'+nomAse+'",'+
                '"destino": "shell"'+
                '},'+
                '{'+
                '"clave": "USUARIOSOLICITANTE",'+
                '"valor": "'+nomAse+'",'+  // nombre de usuario de asesor asignado
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "FECHA",'+
                '"valor": "'+System.now()+'",'+  
                '"destino": "BPMS"'+
                '},'+
                '{'+
                '"clave": "IDPROCESO",'+
                '"valor": "'+trimIdPro+'",'+
                '"destino": "BPMS"'+
                '}'+            
                '],'+
                '"data": "xml"'+
            '} } }';
        System.debug('json_request: ' + json);
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
		public String estado;	//0
		public String excepcion;	//
		public String fecha;	//0001-01-01T00:00:00
		public String identificador;	//00000000-0000-0000-0000-000000000000
		public String mensaje;	//
		public String integracion;	//Generar PDF BPMS
		public String operacion;	//0
		public String origen;	//SALESFORCE
		public String destino;	//BPMS
	}
	class cls_cuerpo {
		public String error;	//FALSE
		public String mensaje;	//No se registra mensaje para almacenar o datos para generar Pdf TipoReporte:RCOHICRCL, NroIdentificacion:Cedula de Ciudadania 71603895, Solicitado por:yomairave
		public String url;	//
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
        public String urlHistorico;  
    }
   
    public static List<Lead> consultaLead( String idSf ){
        return [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c, Asesor_asignado__r.Nombre_de_usuario__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c, Link_PDF_Historico__c, Asesor_asignado__r.Codigo_de_Empleado__c, Asesor_asignado__r.Name,
        Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, Numero_de_Identificacion_Contacto__c, Tipo_de_Identificacion_Contacto__c, RecordType.Name
        FROM Lead Where Id =: idSf AND IsConverted = false];
    }
    public static List<Opportunity> consultaOpp( String idSf ){
        return [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Asesor_asignado__r.Nombre_de_usuario__c,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c, Link_PDF_Historico__c, Asesor_asignado__r.Codigo_de_Empleado__c,  Asesor_asignado__r.Name,
        Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c
        FROM Opportunity Where Id =: idSf ];
    }

     public static List<Contact> consultaCon( String idSf ){
        return [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c,LastName,FirstName,Segundo_Apellido__c,
                MiddleName,Account.Correo_asignacion__c, Account.Nombre_de_usuario__c
        FROM Contact WHERE Id =: idsf ORDER BY LastModifiedDate desc LIMIT 1];
    }
    
    public static List<Opportunity> cuentaDeTitular(String idBPMS){
        return [SELECT id, Account.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,Account.Asesor_asignado__r.Nombre_de_usuario__c,
        AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Fecha_consulta_Datacredito__c,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c, Link_PDF_Historico__c, Asesor_asignado__r.Codigo_de_Empleado__c,  Asesor_asignado__r.Name 
        FROM Opportunity WHERE Identificador_proceso__c =: idBPMS];
    }
}
/****************************************************************************************************************
* @Desarrollado por Vass
* @Autor            Alejandro Gómez
* @Projecto         Interactuar Etapa 2
* @Descripcion      Clase para consultar el servicio de PQR.

* Cambios (Versiones)
* ---   -----------   ---------------------------   ------------------------------------------------
* No.   Fecha         Autor                         Descripcion
* ---   -----------   ---------------------------   ------------------------------------------------
* 1.0   04-MAY-2019   Alejandro Gómez (AG)          Creacion Clase.
****************************************************************************************************************/
global with sharing class IT_ServicioConsultaPQR_WS {
    public IT_ServicioConsultaPQR_WS() {
    }
    private static 	Http 					http;
    private static 	HttpRequest 			Request;
    private static 	HttpResponse 			Response;
    private static 	String 					JSON_req 			{get;set;}
    private static 	String 					JSON_res 			{get;set;}
    public 	static 	List<Account>    		lstAccount;
    public static List<VisualWrapper> lstVisualWrapper;
    
    /***********************************************************************************************
    *Author:   Alejandro Gómez
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio consulta PQR
    *Date:     4-12-2019
    ************************************************************************************************/
    @AuraEnabled
    public static String servicioConsultaPQR(String idSf){
        List<VisualWrapper> lstWraper = new List<VisualWrapper>();
        lstAccount  = new  List<Account>();           
        lstAccount  = consultaAccount(idSf);
        if( lstAccount.size() == 1 ){
            JSON_req  = servicioConsultaPQRJSON(lstAccount.get(0).Id, lstAccount.get(0).Tipo_de_identificacion__c, lstAccount.get(0).Numero_de_identificacion__c);            
            lstWraper = invocaServicio();
        }
        System.debug('lista:'+lstWraper);
        return JSON.serialize(lstWraper);
    }
    
    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Se encarga de la invocacion del servicio web
    *Date:     5-12-2019
    ****************************************************************/
    @AuraEnabled
    public static List<VisualWrapper> invocaServicio(){
        List<VisualWrapper> lstWrapper = new List<VisualWrapper>();
        http 			= new Http();
        Request      	= IT_ParametrosWS_cls.parametrosConsultaPQR(JSON_req);
        Response     	= http.send(request);
        JSON_res     	= Response.getBody(); 
		System.debug('JSON_res: '+ JSON_res);   
       	if( Response.getStatus() == 'OK' && Response.getStatusCode() == 200 ){ 
            VisualWrapper lstVisualWrapper = (VisualWrapper) System.JSON.deserialize(JSON_res, VisualWrapper.class);
            System.debug('lstVisualWrapper: '+ lstVisualWrapper);
            lstWrapper.add(lstVisualWrapper);
        }else{
            System.debug('Response.getStatus()' + Response.getStatus());
        }
        return lstWrapper;             
    }    
    
    /********************************************************************
    *Author:   Alejandro Gómez
    *Function: Clase interna para la captura de la respuesta del servicio
    *Date:     20-04-2020
    ********************************************************************/
    global class VisualWrapper {
        public String operacion;
        public cls_respuesta respuesta;
        public cls_pqrs[] pqrs;
    }
    class cls_respuesta {
        public String estado;
        public String mensaje;
       	public String tipoExcepcion;
    } 
    class cls_pqrs {
        public String fecha;
        public String tipo;
        public String descripcion;
        public String estado;
    }

    public static String servicioConsultaPQRJSON(String idSalesforce,String tipoIdentificacion,String numeroIdentificacion){        
        if(numeroIdentificacion != null){numeroIdentificacion = (numeroIdentificacion.contains('null'))? numeroIdentificacion.replace('null','') : numeroIdentificacion;}else{ numeroIdentificacion = '';} 
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String json = '{'+
                '"encabezado":{'+ 
                '"estado": 0,'+
                '"excepcion": "",'+
                '"fecha": "'+(System.now()).addHours(-5)+'",'+
                '"identificador": "'+idSalesforce +'-'+ numeroAleatorio +'",'+
                '"mensaje": "",'+
                '"integracion":"Consulta estado cartera",'+
                '"operacion": 0,'+
                '"origen":"Salesforce",'+
                '"destino":"Oracle"'+
                '},'+
                '"cuerpo": {'+    
                '"tipoIdentificacion": "'+tipoIdentificacion+'",'+
                '"numeroIdentificacion": "'+numeroIdentificacion+'"'+
                '}'+
            '}';
      System.debug('JSON_req: '+ json);
      return json;
    }
        
    public static List<Account> consultaAccount( String idSf ){
        return [ SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c FROM Account Where Id =: idSf ];
    }
}
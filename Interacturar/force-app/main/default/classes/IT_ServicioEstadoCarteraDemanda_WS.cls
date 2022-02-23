/****************************************************************************************************************
* @Desarrollado por Vass
* @Autor            Alejandro Gómez
* @Projecto         Interactuar Etapa 2
* @Descripcion      Clase para consultar el servicio de estado de cartera por demanda.

* Cambios (Versiones)
* ---   -----------   ---------------------------   ------------------------------------------------
* No.   Fecha         Autor                         Descripcion
* ---   -----------   ---------------------------   ------------------------------------------------
* 1.0   20-ABR-2019   Alejandro Gómez (AG)          Creacion Clase.
****************************************************************************************************************/
global with sharing class IT_ServicioEstadoCarteraDemanda_WS {
    public IT_ServicioEstadoCarteraDemanda_WS() {
    }
    
    private static 	Http 					http;
    private static 	HttpRequest 			Request;
    private static 	HttpResponse 			Response;
    private static 	String 					JSON_req 		{get;set;}
    private static 	String 					JSON_res 		{get;set;}
    public 	static 	Boolean       			isAsset 		= false;
    public 	static 	List<RespuestaServicio> resultsList 	= new List<RespuestaServicio>();
    public 	static 	List<Asset>    			lstAsset;
    
    @InvocableMethod
    public static List<RespuestaServicio> respuestaServicio(List<String> lstidsf){
        System.debug(lstidsf);
        if(lstidsf.size() == 1){
            respuestaServicio(lstidsf[0]);
        }
        return resultsList;
    }

    @AuraEnabled
    public static void respuestaServicio(String idSf){        
        if(idSf.startsWith('02i')){  
            isAsset = true;
            servicioActivoDemanda(idSf);
        }
    }
    
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros, invoca servicio, obtiene resultados del servicio web cartera por demanda
    *Date:     4-12-2019
    ************************************************************************************************/
    public static void servicioActivoDemanda(String idSf){
        lstAsset  = new  List<Asset>();           
        lstAsset  = consultaAsset(idSf);
        if( lstAsset.size() == 1 ){
            JSON_req  = carteraDemandaJSON(lstAsset.get(0).Id, lstAsset.get(0).Numero_de_credito__c);            
            invocaServicio();
        }
    }
    
    /***************************************************************
    *Author:   Rafael Cardona
    *Function: Se encarga de la invocacion del servicio web
    *Date:     5-12-2019
    ****************************************************************/
    public static void invocaServicio(){
        http 			= new Http();
        Request      	= IT_ParametrosWS_cls.parametrosActivoDemanda(JSON_req);
        Response     	= http.send(Request);
        JSON_res     	= Response.getBody();  
        
		System.debug('JSON_res: '+ JSON_res);   
        
        if( Response.getStatus() == 'OK' && Response.getStatusCode() == 200 ){  
            fromJSON respuesta = (fromJSON) System.JSON.deserializeStrict(JSON_res, fromJSON.class);
            System.debug('respuesta: '+ respuesta);
            procesaRespuesta(respuesta);
        }else{
            insertaRespuesta('KO',false,true,false,'Servicio de consulta de activo por demanda fuera de servicio, por favor consulte al administrador.');
        }
    }    

    
    /*******************************************************************
    *Author:   Alejandro Gómez
    *Function: Actualiza el activo con las respuesta del servicio
    *Date:     20-04-2020
    *******************************************************************/
    public static void procesaRespuesta(fromJSON respuestaWS){ 
        try{
            if( respuestaWS != null ){
                if( isAsset && lstAsset.size() == 1){
                    String estado = (String.isNotBlank(respuestaWS.respuesta.estado)) 																		? respuestaWS.respuesta.estado 													: null;
                    String mensaje = (String.isNotBlank(respuestaWS.respuesta.mensaje)) 																	? respuestaWS.respuesta.mensaje 												: null;
                    String concatEstadoMensaje = estado + ':::' + mensaje; 
                    
                    lstAsset[0].Avance_en_cuotas__c 				= (respuestaWS.productos.credito.estadoCartera.avanceCuotas != null)  					? respuestaWS.productos.credito.estadoCartera.avanceCuotas 						: null;
                    lstAsset[0].Calificacion__c 					= (String.isNotBlank(respuestaWS.productos.credito.calificacion))  						? respuestaWS.productos.credito.calificacion 									: null;				
                    lstAsset[0].Dias_de_mora__c 					= (respuestaWS.productos.credito.mora.dias != null)            							? respuestaWS.productos.credito.mora.dias 										: null;
                    lstAsset[0].Fecha_de_cancelacion__c 			= (String.isNotBlank(respuestaWS.productos.credito.fechaCancelacion))					? Date.valueOf(respuestaWS.productos.credito.fechaCancelacion) 					: null;
                    lstAsset[0].Fecha_desembolso__c 				= (String.isNotBlank(respuestaWS.productos.credito.fechaDesembolso))					? Date.valueOf(respuestaWS.productos.credito.fechaDesembolso) 					: null;
                    lstAsset[0].Fecha_proximo_pago__c 				= (String.isNotBlank(respuestaWS.productos.credito.estadoCartera.proximoPago.fecha))	? Date.valueOf(respuestaWS.productos.credito.estadoCartera.proximoPago.fecha) 	: null;
                    lstAsset[0].Fecha_ultimo_pago__c 				= (String.isNotBlank(respuestaWS.productos.credito.ultimoPago.fecha))					? Date.valueOf(respuestaWS.productos.credito.ultimoPago.fecha) 					: null;
                    lstAsset[0].Monto_desembolsado__c 				= (respuestaWS.productos.credito.montoDesembolsado != null)            					? respuestaWS.productos.credito.montoDesembolsado 								: null;
                    lstAsset[0].Numero_de_cuotas_restantes__c 		= (respuestaWS.productos.credito.estadoCartera.cuotasRestantes != null)       			? respuestaWS.productos.credito.estadoCartera.cuotasRestantes 					: null;		
                    lstAsset[0].Plazo__c 							= (respuestaWS.productos.credito.plazo != null)											? respuestaWS.productos.credito.plazo											: null;
                    lstAsset[0].Saldo_para_cancelacion_total__c 	= (respuestaWS.productos.credito.estadoCartera.saldoCancelacionTotal != null)   		? respuestaWS.productos.credito.estadoCartera.saldoCancelacionTotal 			: null;
                    lstAsset[0].Status 								= (String.isNotBlank(respuestaWS.productos.credito.estado)) 							? respuestaWS.productos.credito.estado 											: null;
                    lstAsset[0].Valor_en_mora__c 					= (respuestaWS.productos.credito.mora.valor != null)            						? respuestaWS.productos.credito.mora.valor 										: null;
                    lstAsset[0].Valor_proximo_pago__c 				= (respuestaWS.productos.credito.estadoCartera.proximoPago.valor != null)            	? respuestaWS.productos.credito.estadoCartera.proximoPago.valor					: null;
                    lstAsset[0].Valor_ultimo_pago__c 				= (respuestaWS.productos.credito.ultimoPago.valor != null) 								? respuestaWS.productos.credito.ultimoPago.valor 								: null;				
                    lstAsset[0].Proyeccion_fecha__c					= (String.isNotBlank(respuestaWS.productos.credito.mora.proyeccionFecha))				? Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha) 				: null;
                    lstAsset[0].Referencia_de_Pago__c 		  	    = (String.isNotBlank(respuestaWS.productos.credito.referenciaPago))	          	        ? respuestaWS.productos.credito.referenciaPago                               	: null;
                    
                    lstAsset[0].Respuesta_Activo_Demanda__c 		= concatEstadoMensaje;
                    lstAsset[0].Fecha_ultima_consulta_realizada__c 	= (System.now());
                                        
                    try{
                        if(respuestaWS.productos.credito.mora.proyeccionesPago[0].valor <> 0){
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[0].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_1__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(0);
                                lstAsset.get(0).Proyeccion_valor_dia_1__c = respuestaWS.productos.credito.mora.proyeccionesPago[0].valor;
                            }
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[1].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_2__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(1);
                                lstAsset.get(0).Proyeccion_valor_dia_2__c = respuestaWS.productos.credito.mora.proyeccionesPago[1].valor;
                            }
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[2].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_3__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(2);
                                lstAsset.get(0).Proyeccion_valor_dia_3__c = respuestaWS.productos.credito.mora.proyeccionesPago[2].valor;
                            }
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[3].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_4__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(3);
                                lstAsset.get(0).Proyeccion_valor_dia_4__c = respuestaWS.productos.credito.mora.proyeccionesPago[3].valor;
                            }                        
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[4].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_5__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(4);
                                lstAsset.get(0).Proyeccion_valor_dia_5__c = respuestaWS.productos.credito.mora.proyeccionesPago[4].valor;
                            }
                            if(respuestaWS.productos.credito.mora.proyeccionesPago[5].valor != null){
                                lstAsset.get(0).Proyeccion_fecha_dia_6__c = Date.valueOf(respuestaWS.productos.credito.mora.proyeccionFecha).addDays(5);
                                lstAsset.get(0).Proyeccion_valor_dia_6__c = respuestaWS.productos.credito.mora.proyeccionesPago[5].valor;
                            }
                        }
                    }catch(Exception ex){
                        System.debug('Excepción controlada ' + ex);
                    }    
                }
            }
            
            update lstAsset;
            
            insertaRespuesta('OK',true,false,true,'');
        }catch(Exception ex){
            insertaRespuesta('KO',false,false,true,respuestaWS.respuesta.mensaje);
            System.debug('Error: Se genero un fallo al actualizar el registro del activo.');
        }
    }    

    /********************************************************************
    *Author:   Alejandro Gómez
    *Function: Clase interna para la captura de la respuesta del servicio
    *Date:     20-04-2020
    ********************************************************************/
    global class fromJSON{
        public String operacion;
        public cls_respuesta respuesta;
        public cls_productos productos;
    }
    class cls_respuesta {
        public String estado;
        public String mensaje;
       	public String tipoExcepcion;
    }
    class cls_productos {
        public cls_credito credito;
    }
    class cls_credito {
        public String numero;
        public Decimal montoDesembolsado;
        public String estado;
        public String fechaDesembolso;
        public String referenciaPago;
        public Decimal plazo;
        public String fechaCancelacion;
        public String calificacion;
        public cls_ultimoPago ultimoPago;
        public cls_estadoCartera estadoCartera;
        public cls_mora mora;
    }
    class cls_ultimoPago {
        public Decimal valor;
        public String fecha;
    }
    class cls_estadoCartera {
        public Decimal avanceCuotas;
        public Decimal cuotasRestantes;
        public Decimal saldoCancelacionTotal;
        public cls_proximoPago proximoPago;
    }
    class cls_proximoPago {
        public Decimal valor;
        public String fecha;
    }
    
    class cls_mora {
        public Decimal dias;
        public Decimal valor;
        public String proyeccionFecha;
        public cls_proyeccionesPago[] proyeccionesPago;
    }
    class cls_proyeccionesPago {
        public String orden;
        public Decimal valor;
    }

    public static String carteraDemandaJSON(String idSalesforce,String numeroCredito){        
        if(numeroCredito != null){numeroCredito = (numeroCredito.contains('null'))? numeroCredito.replace('null','') : numeroCredito; }else{ numeroCredito = ''; } 
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String json = '{'+
        '"encabezado":{'+ 
            '"estado": 0,'+
            '"excepcion": null,'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+idSalesforce +'-'+ numeroAleatorio +'",'+
            '"mensaje": null,'+
            '"integracion":"Consulta estado cartera",'+
            '"operacion": 0,'+
            '"origen":"Salesforce",'+
            '"destino":"Oracle"'+
        '},'+
        '"cuerpo": {'+    
            '"activo": {'+
            	'"numeroCredito": "'+numeroCredito+'"'+
        	'}'+
        '}'+
      '}';
      System.debug('JSON_req: '+ json);
      return json;
    }

    public static void insertaRespuesta(String msj, Boolean insertado, Boolean ws, Boolean info, String msjws){        
        RespuestaServicio p = new RespuestaServicio();
        p.mensaje           = msj; 
        p.insertado         = insertado;         
        p.falloEnServicio   = ws; 
        P.trajoInfoServicio = info; 
        p.mensajeServicio   = msjws; 
        resultsList.add(p);
    }
    
     global class RespuestaServicio{
        @InvocableVariable
        public String mensaje;
        @InvocableVariable
        public Boolean insertado;         
        @InvocableVariable
        public Boolean falloEnServicio;
        @InvocableVariable
        public Boolean trajoInfoServicio;
        @InvocableVariable
        public String mensajeServicio;  
    }
    
    public static List<Asset> consultaAsset( String idSf ){
        return [ SELECT Id, Numero_de_credito__c FROM Asset Where Id =: idSf ];
    }
}
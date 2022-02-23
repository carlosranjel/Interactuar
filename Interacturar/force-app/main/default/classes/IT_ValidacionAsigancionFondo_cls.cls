/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Axel Landa
* @projecto         Interactuar
* @descripcion      Clase declarada para consumir el servicio de la asignación de fondo
* @Clase Prueba     IT_ValidacionAsigancionFondo_test

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   09-AGO-2021  Axel Landa		      Creación.
**************************************************************************************************************
**/
public class IT_ValidacionAsigancionFondo_cls {
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Consulta asignación de fondo
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public static ResponseDTO validaAsignacionFondo(String cotizacionId,String fondo, Double unitPrice, integer quantity){
        Quote cot = getCotizacion(cotizacionId);
        
        sendJSON jsonAEnviar = new sendJSON();
        /*
        Boolean ;
        Boolean IngresosSectorAgropecuario;*/
        
        jsonAEnviar.encabezado                                           = buildEncabezado();  
        jsonAEnviar.cuerpo.validacionFondo.codigoFondo                   = String.valueOf(getCodigoFondo(fondo));
        jsonAEnviar.cuerpo.validacionFondo.MontoSolicitado               = Integer.valueOf(unitPrice * quantity);
        jsonAEnviar.cuerpo.validacionFondo.CodigoIndustria               = cot.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c;
        jsonAEnviar.cuerpo.validacionFondo.CodigoSector                  = cot.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Sector_OR__c;
        jsonAEnviar.cuerpo.validacionFondo.CodigoActividad               = cot.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c;
        jsonAEnviar.cuerpo.validacionFondo.UbicacionRural                = cot.Opportunity.Famiempresa_relacionada__r.Ubicacion_Rural__c;
        jsonAEnviar.cuerpo.validacionFondo.IngresosSectorAgropecuario    = cot.Opportunity.Famiempresa_relacionada__r.Ingresos_Empresario_Sector_Agropecuario__c;
   
        String jsonAEnviarString = JSON.serialize(jsonAEnviar);
        System.debug('invoca Servicio: ' + jsonAEnviarString);
         Log_Integracion__c log = new Log_Integracion__c();
		 List<Log_Integracion__c> listLog = new List<Log_Integracion__c>();
   		 
        try{   
            
            //////Envío de la petición para la obtención del score
            Http http = new Http();
            System.debug('invoca Servicio: ' + jsonAEnviarString);
            HttpRequest  request = IT_ParametrosWS_cls.parametrosValidacionFondo(jsonAEnviarString);
            HttpResponse response = http.send(request);
            String jSON_res = response.getBody();
            System.debug('JSON_res: '+ jSON_res +'-'+request);
            
            ///////////////////////////////////////////////////////////////Test
        //    String JSON_res = '{"encabezado":{"fecha":"2021-05-24 17:44:23","integracion":"VALIDACION FONDO","origen":"Oracle","destino":"Salesforce","mensaje":{"estado":"ERROR","descripcion":"Consulta fuera de servicio"}},"cuerpo":{"parametros":{"codigoFondo":"000","MontoSolicitado":1000000,"CodigoIndustria":"000","CodigoSector":"000","CodigoActividad":"000","UbicacionRural":true,"IngresosSectorAgropecuario":true},"validacionFondo":{"aplica":"SI","Descripcion":"No tiene registro de una validación de fondo finagro"}}}';
            ///////////////////////////////////////////////////////////////////
            System.debug('JSON_res validacion Fondo : ' + JSON_res);
            ResponseDTO result = (ResponseDTO)JSON.deserializeStrict(jSON_res, ResponseDTO.class);
        	System.debug('respuesta servicio ' + result );

            return result;
        }catch(Exception ex){
            System.debug('Error: ' + ex);
            ResponseDTO result = new ResponseDTO();
            result.encabezado = new Encabezado();
            result.encabezado.mensaje.estado = 'ERROR';
            
            result.encabezado.mensaje.descripcion = 'Error al consumir el servicio de Consulta de Score';
            return result;
        }
        
    }
        public static void logIntegracion(List<Log_Integracion__c> log ){
 
        insert log;
    }
          public static ResponseDTO validaAsignacionFondoGeneracionAutomatica(Opportunity opp,String fondo, Double unitPrice, integer quantity){
         
        
        sendJSON jsonAEnviar = new sendJSON();
        /*
        Boolean ;
        Boolean IngresosSectorAgropecuario;*/
        
        jsonAEnviar.encabezado                                           = buildEncabezado();  
        jsonAEnviar.cuerpo.validacionFondo.codigoFondo                   = fondo;
        jsonAEnviar.cuerpo.validacionFondo.MontoSolicitado               = Integer.valueOf(unitPrice * quantity);
        jsonAEnviar.cuerpo.validacionFondo.CodigoIndustria               = opp.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c;
        jsonAEnviar.cuerpo.validacionFondo.CodigoSector                  = opp.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Sector_OR__c;
        jsonAEnviar.cuerpo.validacionFondo.CodigoActividad               = opp.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c;
        jsonAEnviar.cuerpo.validacionFondo.UbicacionRural                = opp.Famiempresa_relacionada__r.Ubicacion_Rural__c;
        jsonAEnviar.cuerpo.validacionFondo.IngresosSectorAgropecuario    = opp.Famiempresa_relacionada__r.Ingresos_Empresario_Sector_Agropecuario__c;
   
        String jsonAEnviarString = JSON.serialize(jsonAEnviar);
        System.debug('invoca Servicio: ' + jsonAEnviarString);
        
        try{   
            //////Envío de la petición para la obtención del score
            Http http = new Http();
            System.debug('invoca Servicio: ' + jsonAEnviarString);
            HttpRequest  request = IT_ParametrosWS_cls.parametrosValidacionFondo(jsonAEnviarString);
            HttpResponse response = http.send(request);
            String jSON_res = response.getBody();
            System.debug('JSON_res: '+ jSON_res +'-'+request);
            
            ///////////////////////////////////////////////////////////////Test
        //    String JSON_res = '{"encabezado":{"fecha":"2021-05-24 17:44:23","integracion":"VALIDACION FONDO","origen":"Oracle","destino":"Salesforce","mensaje":{"estado":"ERROR","descripcion":"Consulta fuera de servicio"}},"cuerpo":{"parametros":{"codigoFondo":"000","MontoSolicitado":1000000,"CodigoIndustria":"000","CodigoSector":"000","CodigoActividad":"000","UbicacionRural":true,"IngresosSectorAgropecuario":true},"validacionFondo":{"aplica":"SI","Descripcion":"No tiene registro de una validación de fondo finagro"}}}';
            ///////////////////////////////////////////////////////////////////
            System.debug('JSON_res validacion Fondo : ' + JSON_res);
            ResponseDTO result = (ResponseDTO)JSON.deserializeStrict(jSON_res, ResponseDTO.class);
            return result;
        }catch(Exception ex){
            System.debug('Error: ' + ex);
            ResponseDTO result = new ResponseDTO();
            result.encabezado = new Encabezado();
            result.encabezado.mensaje.estado = 'ERROR';
            result.encabezado.mensaje.descripcion = 'Error al consumir el servicio de Consulta de Score';
            return result;
        }
        
    }
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Obten información de la cotización
    *Date: 09-AGO-2021
	******************************************************************************************/
    public static Quote getCotizacion(String cotizacionId){
        return [select Id, Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c, Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Sector_OR__c,
                Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c, Opportunity.Famiempresa_relacionada__r.Ubicacion_Rural__c, 
                Opportunity.Famiempresa_relacionada__r.Ingresos_Empresario_Sector_Agropecuario__c
                from Quote
                where id =:cotizacionId];
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Obten el código del fondo
    *Date: 09-AGO-2021
	******************************************************************************************/
    public static Integer getCodigoFondo(String text){
        if(text == null){
            return null;
        }
        Integer num;
        for(Integer i = 0; i < text.length(); i++){
            try{
                //System.debug(Integer.valueOf(text.substring(i, i + 1)));
                num = Integer.valueOf(text.substring(i, i + 1));
                
                for(Integer j = i + 1; j < text.length(); j++){
                    try{
                        //system.debug(Integer.valueOf(String.valueOf(num) + text.substring(j, j + 1)));
                        num = Integer.valueOf(String.valueOf(num) + text.substring(j, j + 1));
                    }catch(Exception ex){
                        break;
                    }
                }
                break;
            }catch(Exception ex){
            }
        }
        return num;
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function:
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class Encabezado{
        public String fecha; //
        public String integracion; //
        public String origen; //
        public String destino; //
        public Mensaje mensaje = new Mensaje(); 
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Encabezado de respuesta
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public static Encabezado buildEncabezado(){
        Encabezado encabezado = new Encabezado();
        encabezado.fecha         = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        encabezado.mensaje       = null;
        encabezado.integracion   = 'VALIDACION FONDO';
        encabezado.origen        = 'Salesforce';
        encabezado.destino       = 'Oracle';
        
        return encabezado;
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Clase modelo de la información enviada
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class sendJSON{
        public Encabezado encabezado;
        public Cuerpo cuerpo = new Cuerpo();
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function:
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class Cuerpo{
        ValidacionFondo validacionFondo = new ValidacionFondo();
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function:
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class ValidacionFondo{
        String codigoFondo;
        Decimal MontoSolicitado;
        String CodigoIndustria;
        String CodigoSector;
        String CodigoActividad;
        Boolean UbicacionRural;
        Boolean IngresosSectorAgropecuario;
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: Clase modelo de la información recibida
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class ResponseDTO{
        public Encabezado encabezado;
        public CuerpoRespuesta cuerpo = new CuerpoRespuesta();
    }
     /******************************************************************************************
    *Author:  Axel Landa
    *Function:
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class Mensaje{
        public String estado;
        public String descripcion;
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: 
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class CuerpoRespuesta{
        public ValidacionFondo parametros = new ValidacionFondo();
        public Resultado validacionFondo = new Resultado();
    }
    
    /******************************************************************************************
    *Author:  Axel Landa
    *Function: 
    *Date: 09-AGO-2021
    ******************************************************************************************/
    public class Resultado{
        public String aplica; //SI - NO
        public String Descripcion;
    }
    

}
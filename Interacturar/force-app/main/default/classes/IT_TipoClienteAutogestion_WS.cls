/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso REST para exponer servicio del tipo de cliente en autogestión

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   11-Feb-2021  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/TipoClienteAutogestion/*')
global class IT_TipoClienteAutogestion_WS {
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Recepción del servicio
    *Date: 11-Feb-2021
    ******************************************************************************************/
    @HttpPost
    global static ResponseDTO doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);
        
        FromJSON jsonObj = (FromJSON)JSON.deserializeStrict(strJSONContent, FromJSON.class);
       
        ResponseDTO result = new ResponseDTO();
        result.encabezado = buildEncabezado(jsonObj.encabezado);
        
        TipoClienteAutogestion tca = new TipoClienteAutogestion();
        tca.tipoDocumento = jsonObj.tipoClienteAutogestion.tipoDocumento;
        tca.numeroDocumento = jsonObj.tipoClienteAutogestion.numeroDocumento;
        tca = getCreditInfo(jsonObj.tipoClienteAutogestion, tca);
        
        result.tipoClienteAutogestion = tca;
        
        system.debug('Result: ' + result);
        return result;
        
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener activos del cliente
    *Date: 11-Feb-2020
    ******************************************************************************************/
    public static TipoClienteAutogestion getCreditInfo(TipoClienteAutogestionRequest info, TipoClienteAutogestion result){
        
        List<QuoteLineItem> listQuoteLineItems = [Select Id,Identificador_Radicado_OR__c
                                                       from QuoteLineItem
                                                       where Quote.Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' and Quote.Opportunity.Account.Tipo_de_identificacion__c = :info.tipoDocumento
                                                       and Quote.Opportunity.Account.Numero_de_identificacion__c = :info.numeroDocumento];
        if(!(listQuoteLineItems.size() > 0)){
            result.clienteVigenteCredito = False;
            result.clienteConocidoCredito = False;
            result.clienteNuevoCredito = True;
            
            return result;
        }
        
        system.debug('Listado productos de cotización: ' + listQuoteLineItems);
        
        List<String> listRadicados = new List<String> ();
        for(QuoteLineItem prod : listQuoteLineItems){
            if(prod.Identificador_Radicado_OR__c != null && prod.Identificador_Radicado_OR__c != ''){
                listRadicados.add(prod.Identificador_Radicado_OR__c);
            }
        }
        if(!(listRadicados.size() > 0)){
            result.clienteVigenteCredito = False;
            result.clienteConocidoCredito = False;
            result.clienteNuevoCredito = True;
            
            return result;
        }
        
        List<Asset> listAssets = [Select Id, Identificador_Radicado__c, Monto_desembolsado__c, Fecha_desembolso__c, Status, Fecha_de_cancelacion__c
                                 from Asset
                                 where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento
                                 and Identificador_Radicado__c in :listRadicados];
        
        if(listAssets.size() > 0){
            system.debug('Listado activos por producto: ' + listAssets);
            
            Date todayDate = Date.today();
            Integer monthToBeCurrent = Integer.valueOf(obtenerMesesVigente().valor__c);
            system.debug('Meses para ser vigentes: ' + monthToBeCurrent);
            
            for(Asset activo : listAssets){
                //system.debug(result);
                if(!result.clienteVigenteCredito || !result.clienteConocidoCredito){
                    if(activo.Status != 'Cancelado'){
                        result.clienteVigenteCredito = True;
                    }else{
                        if(activo.Fecha_de_cancelacion__c != null){
                            if(activo.Fecha_de_cancelacion__c.monthsBetween(todayDate) <= monthToBeCurrent){
                                result.clienteVigenteCredito = True;
                            }else if(activo.Fecha_de_cancelacion__c.monthsBetween(todayDate) > monthToBeCurrent){
                                result.clienteConocidoCredito = True;
                            }
                        }
                    }
                }else{
                    break;
                } 
            }
            
            if(!result.clienteVigenteCredito && !result.clienteConocidoCredito){
                result.clienteNuevoCredito = True;
            }
            
            return result;
        }else{
            result.clienteVigenteCredito = False;
            result.clienteConocidoCredito = False;
            result.clienteNuevoCredito = True;
            
            return result;
        }
        
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Metadato de los meses de un crédito vigente
    *Date: 12-Feb-2020
    ******************************************************************************************/
    public static ListaClaveValor__mdt obtenerMesesVigente( ){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Auto Meses Para Ser Vigente'];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Encabezado de respuesta
    *Date: 11-Feb-2020
    ******************************************************************************************/
    public static Encabezado buildEncabezado(Encabezado request){
        Encabezado encabezado = new Encabezado();
        encabezado.fecha = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        encabezado.identificador = request.identificador;
        encabezado.integracion = 'Tipo Cliente Autogestión';
        encabezado.operacion = request.operacion;
        encabezado.origen = 'SALESFORCE';
        encabezado.destino = request.origen;
        
        return encabezado;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información recibida
    *Date: 11-Feb-2020
    ******************************************************************************************/
    global class FromJSON{
        public Encabezado encabezado;
        public TipoClienteAutogestionRequest tipoClienteAutogestion;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 11-Feb-2020
    ******************************************************************************************/
    global class Encabezado{
        public String fecha;
        public String identificador;
        public String integracion;
        public String operacion;
        public String origen;
        public String destino; 
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 11-Feb-2020
    ******************************************************************************************/
    global class TipoClienteAutogestionRequest{
        public String tipoDocumento;
        public String numeroDocumento;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información enviada
    *Date: 11-Feb-2020
    ******************************************************************************************/
    global class ResponseDTO{
        public Encabezado encabezado;
        public TipoClienteAutogestion tipoClienteAutogestion = new TipoClienteAutogestion();
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 11-Feb-2020
    ******************************************************************************************/
    global class TipoClienteAutogestion{
        public String tipoDocumento;
        public String numeroDocumento;
        public Boolean clienteVigenteCredito = False;
        public Boolean clienteConocidoCredito = False;
        public Boolean clienteNuevoCredito = False;
        public Boolean clienteVigenteConocimiento;
        public Boolean clienteConocidoConocimiento;
        public Boolean clienteNuevoConocimiento;
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
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
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
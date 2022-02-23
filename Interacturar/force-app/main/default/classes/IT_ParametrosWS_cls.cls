/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase donde se configuran los parametros de los servicios web que se consumen desde SF

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   4-JUL-2019  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public class IT_ParametrosWS_cls {
    
    private static final String TOKEN_GESTOR = 'TokenGestorServicios';
	
    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros del cliente
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosCliente(){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.ClienteWSparam];
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000); 
        System.debug('parametros: '+request);
        return request;
    }

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros del Aval 
    *Date:     12-02-2020
    *******************************************************/
    public static HttpRequest parametrosClienteAval(String JSON_req){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt
                                             WHERE DeveloperName =: Label.ClienteAvalWSparam];
        request.setBody(JSON_req);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000); 
        System.debug('parametros: '+request);
        return request;
    }
    
    /******************************************************
    *Author:   Álvaro Ortega
    *Function: Consulta parametros de invitación a firma de pagaré
    *Date:     12-04-2021
    *******************************************************/
    public static HttpRequest parametrosInvitacionAfirma(String json){
       	String INVITACION_FIRMA = 'OnCreditInvitacionAFirma';
        
        Parametros_Web_Service__mdt paramGestor = parametrosGestorWS(TOKEN_GESTOR);
        String token = getTokenGestorServicios(paramGestor);
        
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(INVITACION_FIRMA);
        request.setBody(json);   
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Ocp-Apim-Subscription-Key', paramGestor.Key__c);
        //https://apimplataformadigital.azure-api.net/services/api/oncredit/dev/v1.0.0/services/api/oncredit/invitacion/pasarelaFirma/v1-0
        //http://esb-dllo.interactuar.org.co:8040/services/api/oncredit/invitacion/pasarelaFirma/v1-0
        request.setTimeout(80000);
        return request;
    } 

    /******************************************************
    *Author:   Álvaro Ortega
    *Function: Consulta parametros del Score
    *Date:     12-04-2021
    *******************************************************/
    public static HttpRequest parametrosScore(String json){
        String CONSULTA_SCORE = 'ConsultaScore';
            
        Parametros_Web_Service__mdt paramGestor = parametrosGestorWS(TOKEN_GESTOR);
        String token = getTokenGestorServicios(paramGestor);
        
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(CONSULTA_SCORE);
        request.setBody(json);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Ocp-Apim-Subscription-Key', paramGestor.Key__c);
        //http://esb-dllo.interactuar.org.co:8040/services/api/r/cliente/modeloScore/v1-0
        //https://apimplataformadigital.azure-api.net/services/api/oncredit/dev/v1.0.0/services/api/r/cliente/modeloScore/v1-0
        request.setTimeout(80000);
        return request;
    }
    
       /******************************************************
    *Author:   Axel Landa
    *Function: Consulta parametros validación de fondo
    *Date:     09-AGO-2021
    *******************************************************/
    public static HttpRequest parametrosValidacionFondo(String json){
        String VALIDACION_FONDO = 'ValidacionFondo';
            
        Parametros_Web_Service__mdt paramGestor = parametrosGestorWS(TOKEN_GESTOR);
        String token = getTokenGestorServicios(paramGestor);
        
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(VALIDACION_FONDO);
        request.setBody(json);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Ocp-Apim-Subscription-Key', paramGestor.Key__c);
        //http://esb-dllo.interactuar.org.co:8040/services/api/r/cliente/modeloScore/v1-0
        //https://apimplataformadigital.azure-api.net/services/api/oncredit/dev/v1.0.0/services/api/r/cliente/modeloScore/v1-0
        request.setTimeout(80000);
        return request;
    }
    
    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros del oportunidad
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosOportunidad(String JSON_req){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.OportunidadWSparam];
        
        Parametros_Web_Service__mdt paramGestor = parametrosGestorWS(TOKEN_GESTOR);
        String token = getTokenGestorServicios(paramGestor);
        
        System.debug('json: '+ JSON_req);                                             
        request.setBody(JSON_req);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);      
        request.setTimeout(120000);                
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Ocp-Apim-Subscription-Key', paramGestor.Key__c);
        //https://apimplataformadigital.azure-api.net/api/talend/qa/v1.0.0/services/api/clientes/crm/serviciosNegocio/oportunidad/v1-0
        //https://apimplataformadigital.azure-api.net/api/talend/dev/v1.0.0/services/api/clientes/crm/serviciosNegocio/v1-0
        System.debug('parametros: '+request);
        return request;
    }
    
    /******************************************************************************************
   	*Author: Álvaro Ortega
   	*Function: Obtiene el token para el gestor de servicios
   	*Date: 08-ABR-2021
	******************************************************************************************/
    public static String getTokenGestorServicios(Parametros_Web_Service__mdt param){
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        
        String json = '{';
        json += '"secret"  : "' + param.Secret_Id__c + '", ';
        json += '"clientId": "' + param.Client_Id__c + '"';
        json += '}';
        System.debug('invoca Servicio'+ json);
        
        request.setBody(json);   
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Ocp-Apim-Subscription-Key', param.Key__c);
        request.setTimeout(80000);
        
        HttpResponse response = http.send(request);
        String jSON_res = response.getBody();
        System.debug('JSON_res token Gestor: '+ jSON_res +'-'+request);
        
        return jSON_res;
    }
    
    private static Parametros_Web_Service__mdt parametrosGestorWS(String depName){
        return [SELECT id,EndPoint__c,Metodo__c, Clave__c, Usuario__c, Key__c, Secret_Id__c, Client_Id__c 
                FROM Parametros_Web_Service__mdt 
                WHERE DeveloperName =: depName];
    }

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros para documentacion BPMS
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosDocumentacionBPMS(){
        System.debug('parametros DOCUMENTACION BPMS');
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.BPMSWSparam];
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);   
        request.setTimeout(80000);                   
        request.setHeader('Content-Type', 'application/json');
        return request;
    }

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros para DataCredito
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosDataCredito(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.DataCreditoWSparam];
        String encoded = EncodingUtil.urlEncode(json, 'UTF-8').replace('+','%20');
    
        request.setTimeout(80000);
        request.setEndpoint(param.EndPoint__c+'?mensaje='+encoded);
        request.setMethod(param.Metodo__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        return request;
    } 

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros para idBPMS
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosIdBPMS(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(Label.IdBpmsWSparam);
        request.setBody(json);   
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000);
        return request;
    } 
    
        /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros para DataCredito nuevo
    *Date:     17-12-2019
    *******************************************************/
    public static HttpRequest parametrosDataCreditoDos(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.DataCreditoWSparam];
        String encoded = EncodingUtil.urlEncode(json, 'UTF-8').replace('+','%20');        
        request.setTimeout(80000);
        request.setEndpoint(param.EndPoint__c+'?mensaje='+encoded);
        request.setMethod(param.Metodo__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        return request;
    }

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros para idBPMS
    *Date:     4-12-2019
    *******************************************************/
    public static HttpRequest parametrosGenerarPDF(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(Label.generarPDFWSparam);
        request.setBody(json);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000);
        return request;
    }

    /******************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros cobranzas 
    *Date:     13-04-2020
    *******************************************************/
    public static HttpRequest parametrosCobranza(String JSON_req){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                                             WHERE DeveloperName =: Label.CobranzaWSparam];
        request.setBody(JSON_req);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000); 
        System.debug('parametros: '+request);
        return request;
    }

    /******************************************************
    *Author:   Alejandro Gómez
    *Function: Consulta parametros para activo por demanda
    *Date:     20-04-2020
    *******************************************************/
    public static HttpRequest parametrosActivoDemanda(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT Id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt WHERE DeveloperName =: Label.ActivoDemandaWSparam];
        request.setBody(json);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000);
        return request;
    }

    /******************************************************
    *Author:   Alejandro Gómez
    *Function: Consulta parametros para PQR
    *Date:     04-05-2020
    *******************************************************/
    public static HttpRequest parametrosConsultaPQR(String json){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = [SELECT Id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt WHERE DeveloperName =: Label.ConsultaPQRWSparam];
        request.setBody(json);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000);
        return request;
    }

    /*************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros de giradores para servicio web
    *Date:     26-06-2020
    **************************************************************/
    public static HttpRequest parametrosGiradores(String JSONreq){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(Label.GiradorWSparam);
        request.setBody(JSONreq);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000); 
        System.debug('parametros: '+request);
        return request;
    }

    /*************************************************************
    *Author:   Rafael Cardona
    *Function: Consulta parametros de pagares para servicio web
    *Date:     6-07-2020
    **************************************************************/
    public static HttpRequest parametrosPagares(String JSONreq){
        HttpRequest request = new HttpRequest();
        Parametros_Web_Service__mdt param = parametrosWS(Label.PagareWSparam);
        request.setBody(JSONreq);
        request.setEndpoint(param.EndPoint__c);
        request.setMethod(param.Metodo__c);               
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(80000); 
        System.debug('parametros: '+request);
        return request;
    }

    private static Parametros_Web_Service__mdt parametrosWS(String depName){
        return [SELECT id,EndPoint__c,Metodo__c FROM Parametros_Web_Service__mdt 
                WHERE DeveloperName =: depName];
    }
}
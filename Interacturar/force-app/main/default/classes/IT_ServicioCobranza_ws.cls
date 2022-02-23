/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class que llama el servicio de notificacion de cobranza

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   13-Abr-2020  Rafael Cardona (RC)           Creacion Clase.
*            1.0   14-Oct-2020  Alejandro Gomez (RC)          Modificacion Clase, origen fechaGestion.
/*
**************************************************************************************************************
**/
public with sharing class IT_ServicioCobranza_ws {
    
    private static Http         http;
    private static HttpRequest  Request;
    private static HttpResponse Response;
    private static String       JSON_req {get;set;}

    public IT_ServicioCobranza_ws() {   }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Metodo de inicio
    *Date: 13-04-2020
    **************************************************************************/
    @InvocableMethod
    public static void servicioNotificacionCobranza(List<ID> idsTarea){        
        system.debug(' idsTarea -->'+idsTarea);        
        consumeServicvioWeb(idsTarea);     
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de consultar la tarea y consumir el servicio
    *Date: 13-4-2020
    **************************************************************************/
    @future (callout=true)
    public static void consumeServicvioWeb(List<ID> idsTarea){
        List<Id> idsActivos    = new List<Id>();
        List<Asset> lstActivos = new List<Asset>();
        http = new Http();
        
        List<Task> lstTareas   = IT_GestorDeConsultas_cls.consultaconsultaTareas(idsTarea);
        if( lstTareas.size() == 1 ){
            idsActivos.add(lstTareas[0].WhatId);
            lstActivos = IT_GestorDeConsultas_cls.consultaconsultaActivos(idsActivos);
        } 
        system.debug('lstTareas: '+ lstTareas);
        
        if( lstTareas.size() == 1  &&  lstActivos.size() == 1 ){
            JSON_req = clientJSON(lstTareas[0] , lstActivos[0]);
            system.debug(' body--->'+JSON_req); 
            Request = IT_ParametrosWS_cls.parametrosCobranza(JSON_req);        
            Response = http.send(Request);
            system.debug('IT_ServicioCliente_cls.response Body:'+Response.getBody()); 
            
            lstTareas[0].Status = 'Terminada';
            if( Response.getStatusCode() == 200 )
                lstTareas[0].Respuesta_Integracion__c = 'OK, Acuerdo de pago enviado exitosamente a Oracle';
            else
                lstTareas[0].Respuesta_Integracion__c = 'KO, Error en el envío del acuerdo de pago a Oracle';            
            
            update lstTareas;
        } 
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se llena la informacion del JSON desde el contacto Aval
    *Date: 3-3-2020
    **************************************************************************/
    public static String clientJSON(Task tarea, Asset activo){     
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        
        System.debug('numeroAleatorio: '+ numeroAleatorio); 
        String body='{'+ 
              '"encabezado": {'+
              '"estado": 0,'+
              '"excepcion": null,'+
              '"fecha": "'+(System.now()).addHours(-5)+'",'+
              '"identificador": "'+tarea.WhatId+'-'+numeroAleatorio+'",'+ 
              '"mensaje": null,'+
              '"integracion": "Notificar Novedades Cobranza",'+
              '"operacion": 0,'+
              '"origen": "SALESFORCE",'+
              '"destino": "ORACLE"'+
              '},'+
              '"cuerpo": {'+              
              '"activo": {'+
              '"codigoActivo": "'+activo.Product2Id+'",'+
              '"numeroCredito": '+IT_ConstruccionJSON_cls.validarNullString_Integer(activo.Numero_de_credito__c)+','+ 
              '"tipoDocumento": "'+activo.Account.Tipo_de_identificacion__c+'",'+ 
              '"numeroDocumento":  "'+activo.Account.Numero_de_identificacion__c+'" '+
              '},'+ // fin activo
              '"producto": {'+
              '"tipoProducto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(activo.Product2.Family)+','+
              '"codigoSalesforce": "",'+
              '"codigoOracle": "" '+
              '},'+ // fin producto
              '"gestionCobranza": {'+
              '"fechaGestion":  "'+(System.now()).addHours(-5)+'",'+
              '"tipoGestion": '+IT_ConstruccionJSON_cls.validarStringReturnNull(tarea.Tipo_de_gestion__c)+','+
              '"tipoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(tarea.Tipo_de_contacto__c)+','+
              '"gestionEfectiva": '+tarea.Gestion_efectiva__c+','+
              '"codigoEmpleado": '+tarea.Asignado_a__r.Codigo_de_Empleado__c+','+ // viene del asesor que hace la gestion
              '"fechaAcuerdo": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(tarea.Fecha_acuerdo_de_pago__c)+'",'+
              '"pagoMinimo": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(tarea.Pago_minimo__c)+','+
              '"fechaSeguimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(tarea.ActivityDate)+'",'+
              '"observacion":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(tarea.Description)+' '+
              '}'+ // fin gestionCobranza              
              '} }';  // fin cuerpo, fin json                             
          return body;
      }
}
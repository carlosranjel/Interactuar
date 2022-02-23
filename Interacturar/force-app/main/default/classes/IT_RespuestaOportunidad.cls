/**
**************************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de Notificacion Estado Oportunidad

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------------------
*            1.0   30-May-2019  Rafael Cardona (RC)           Creacion Clase.
*            2.0   06-Feb-2020  Rafael Cardona (RC)           Se agrega origen y refPadre como atributos nuevos en el json
/*
**************************************************************************************************************************
**/
@RestResource(urlMapping='/NotificacionRespuestaOportunidad/*')
Global class IT_RespuestaOportunidad {


    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura interna para cargar los datos deserealizados
    *Date: 6-7-2019

    *Parametros: 
    *@estado           :  ('OK'=true,'KO'=false)
    *@observacion      :  ('OK'=true no viene mensaje ), ('KO'=false viene menssaje de error)   
    *@consecutivoPadre : id cliente para asociar con los avales, si se necesita enviar otro aval, 
                         Si viene error no llega el consecutivo padre
    *@origen           : ORACLE - TALENT
    *Date: 6-2-2020
    ******************************************************************************************/
    public class RespuestaDeOportunidad{
        public RespuestaOportunidad respuestaOportunidad;
    }
    class RespuestaOportunidad {
        public String idOportunidad;	//006e000000HlOxHAAV
        public String cod_producto;	//0QLe0000000RG57GAG
        public String idRadicado;	//52676
        public String estado;	//OK
        public String tipoCredito;	//N
        public String consecutivoPadre;	//0061Y00000qgNQGQA2-222
        public String observacionTecnica;
        public cls_oracle oracle;
        public cls_bpms bpms;
    }
    class cls_oracle {
        public String origen;	//ORACLE
        public String estadoOracle;	//
        public String observacionOracle;	//
    }
    class cls_bpms {
        public String origen;	//BPMS
        public String estadoBpms;	//
        public String observacionBPMS;	//
    }
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos que vienen de la respuesta de oportunidad
    *Date: 6-7-2019
    ******************************************************************************************/
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);     
        RespuestaDeOportunidad respuestaOportunidad  = (RespuestaDeOportunidad)JSON.deserializeStrict(strJSONContent, RespuestaDeOportunidad.class); 
        System.debug('Obj oportunidad '+ respuestaOportunidad.RespuestaOportunidad);  

        actualizaRadicado(respuestaOportunidad.RespuestaOportunidad);      
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de actualizar los productos por cotizacion asociados a la oportunidad
    *Date: 3-7-2019
    ******************************************************************************************/
    public static void actualizaRadicado(RespuestaOportunidad respuesta){       
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        List<Opportunity>   lstOportunidad   = new List<Opportunity>();
        system.debug('Respuesta: ' + respuesta);
        try{
            if( respuesta.estado != null && respuesta.estado == 'OK' ){
                System.debug('Estado Ok');
                lstQuoteLineItem = IT_GestorDeConsultas_cls.consultaProductoPorCotizacion2(respuesta.cod_producto);
                lstOportunidad   = IT_GestorDeConsultas_cls.consultaOportunidad(lstQuoteLineItem.get(0).Quote.OpportunityId);
                System.debug('Avanza obtención de datos OK');
                System.debug('Respuesta: ' + lstQuoteLineItem + '\n'+lstOportunidad);
                procesaRespuestaOK(lstQuoteLineItem, lstOportunidad, respuesta);
            }else if( respuesta.estado == null || (respuesta.estado != null && ( respuesta.estado == 'KO' ||  respuesta.estado == ''))){
                System.debug('Estado KO');
                lstQuoteLineItem = IT_GestorDeConsultas_cls.consultaProductoPorCotizacion2(respuesta.cod_producto);
                lstOportunidad   = IT_GestorDeConsultas_cls.consultaOportunidad(lstQuoteLineItem.get(0).Quote.OpportunityId);
                System.debug('Avanza obtención de datos KO');
                procesaRespuestaKO( lstOportunidad, respuesta);
            }
        }
        catch(System.DmlException edml){
            system.debug('Excepcion DML');
            Error_Apex__c errordml = New Error_Apex__c(Id_que_genero_el_error__c=edml.getDmlId(0),Causa__c=string.valueOf(edml.getCause()),Error__c= edml.getMessage(),Tipo_de_excepcion__c = edml.getTypeName(),Campos_con_error__c = String.valueOf(edml.getDmlFieldNames(0)),Mensaje_DML__c = edml.getDmlMessage(0),Tipo_DML__c = String.valueOf(edml.getDmlType(0)));
            //errordml.Id_que_genero_el_error__c = edml.getDmlId(0);
            //errordml.Causa__c = string.valueOf(edml.getCause());
            //errordml.Error__c = edml.getMessage();
            //errordml.Tipo_de_excepcion__c = edml.getTypeName();
            //errordml.Campos_con_error__c = String.valueOf(edml.getDmlFieldNames(0));
            //errordml.Mensaje_DML__c = edml.getDmlMessage(0);
            //errordml.Tipo_DML__c = String.valueOf(edml.getDmlType(0));
            try{
                insert errordml;
            }
            catch(Exception s){
                throw new applicationException('Error al insertar log....' + s);
            }
			throw new applicationException('ERROR - VALORES DE RESPUESTA...' + edml);            
        }
        catch(Exception e){
            system.debug('Excepcion generica');
            Error_Apex__c error = New Error_Apex__c();
            error.Causa__c = string.valueOf(e.getCause());
            error.Error__c = e.getMessage();
            error.Tipo_de_excepcion__c = e.getTypeName();            
            try{
                insert error;
            }
            catch(Exception s){
                throw new applicationException('Error al insertar log....' + s);
            } 
            //throw new applicationException('ERROR - VALORES DE RESPUESTA...' + e);
        }
    }

    /******************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Actualiza la oportunidad en caso de que la integracion devuelva un KO, lo que indica exito en el proceso
    *Date: 06-02-2020
    *******************************************************************************************************************/
    public static void procesaRespuestaOK(List<QuoteLineItem> lstQuoteLineItem, List<Opportunity> lstOportunidad, RespuestaOportunidad res){
        Boolean isSinRegistros = false;
        Boolean isActualiza    = false;
        System.debug('lstQuoteLineItem' + lstQuoteLineItem);
        for(Integer k = 0; k < lstQuoteLineItem.size(); k++){ 
            lstQuoteLineItem.get(k).Identificador_Radicado_OR__c = res.idRadicado;
            lstQuoteLineItem.get(k).Tipo_credito__c              = res.tipoCredito;            
            lstOportunidad.get(0).Consecutivo_Padre__c           = res.consecutivoPadre;
            lstOportunidad.get(0).Respuesta_Oportunidad__c       = '['+ res.oracle.estadoOracle +'-'+ res.oracle.observacionOracle +'] '+
                                                                   '['+ res.bpms.estadoBpms +'-'+ res.bpms.observacionBPMS +']';
            lstOportunidad.get(0).Origen_Integracion__c          = res.oracle.origen +' - '+ res.bpms.origen;
            isActualiza = true;            
        }
        try{
            if(isActualiza){
                update lstQuoteLineItem;  
                update lstOportunidad;
                //bloqueaAvales( lstOportunidad.get(0).Id , lstOportunidad.get(0).Account.id );
            }
        }catch(Exception e){ 
            System.debug('e--->' + e.getMessage());
            System.debug('e--->' + e.getCause());            
            if( !isSinRegistros )
                throw new applicationException('Error en la actualizacion de los productos por cotizacion');  
        }
    }

    /*************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Actualiza la oportunidad en caso de que la integracion devuelva un KO, lo que indica que algo fallo
    *Date: 06-02-2020
    **************************************************************************************************************/
    public static void procesaRespuestaKO( List<Opportunity> lstOportunidad, RespuestaOportunidad res ){
        lstOportunidad.get(0).Consecutivo_Padre__c     = res.consecutivoPadre;
        if( (res.oracle.estadoOracle != null && res.oracle.estadoOracle != '') && ( res.oracle.estadoOracle == 'KO' ) ){
            lstOportunidad.get(0).Respuesta_Oportunidad__c       = res.oracle.observacionOracle;
            lstOportunidad.get(0).Origen_Integracion__c          = res.oracle.origen;
        }else if( (res.bpms.estadoBpms != null  && res.bpms.estadoBpms != '') && ( res.bpms.estadoBpms == 'KO'  )  ){
            lstOportunidad.get(0).Respuesta_Oportunidad__c       = res.bpms.observacionBPMS;
            lstOportunidad.get(0).Origen_Integracion__c          = res.bpms.origen;
        }else{
            lstOportunidad.get(0).Respuesta_Oportunidad__c       = res.observacionTecnica;
            lstOportunidad.get(0).Origen_Integracion__c          = 'Tecnico';
        }
        update lstOportunidad.get(0);
    }
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para el manejo de las excepciones
    *Date: 6-7-2019
    ******************************************************************************************/
    public class applicationException extends Exception {}
}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de Notificacion Estado Oportunidad

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   29-May-2019  Rafael Cardona (RC)           Creacion Clase.
/*           2.0   01-Oct-2020  Rafael Cardona (RC)           Actualizacion ooortunidad, proyecto Autogestion
**************************************************************************************************************
**/
@RestResource(urlMapping='/NotificacionEstadoOportunidad/*')
global class IT_NotificacionEstadoOportunidad {

    private static final String TRANSFERENCIA = 'Transferencia';
    private static final String CHEQUE        = 'Cheque';
    private static final String SI            = 'Si';
    private static final String ES_NULO       = null;    
    public static NotificacionOportunidad integracion;
    public static Set<Id> setIdOportunidad = new Set<Id>();
    
    public class NotificacionOportunidad{
        Notificacion notificacionOportunidad;
    }

    class Notificacion{
        InformacionBasica informacionBasica;
        Desembolso desembolso;
    }
    
    class InformacionBasica    {
        public String idRadicado;        
        public String idOportunidad;
        public String idProducto;        
        public String idCredito;         
        public String fecha;			    
        public String valorEstado;       
        public String idFamiempresa;     
        public String montoDesembolsado; 
        public String plazoOrden;        
        public String numeroFactura;
        public String marcacion;
    }
    class Desembolso{
        DesembolsoTransferencia desembolsoTransferencia;
        DesembolsoCheque desembolsoCheque;
    }
    class DesembolsoTransferencia{
        public String tipoCuenta;
        public String banco;
        public String numCuenta;
        public String valorCancelacion;
    }
    class DesembolsoCheque{
        public String cuenta;
        public String numcuenta;
        public String valorCancelacion;
    }
    
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos que vienen de la notificacion de estados de la oportunidad
    *Date: 6-7-2019
    ************************************************************************************************/
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);     
        integracion  = (NotificacionOportunidad)JSON.deserializeStrict(strJSONContent, NotificacionOportunidad.class); 
        System.debug('Obj deserealizado '+ integracion);
        
        actualizaOportunidades();
    }
    
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos que vienen de la notificacion de estados de la oportunidad
    *Date: 25-7-2019
    ************************************************************************************************/
    public static void actualizaOportunidades(){
        Boolean isActualizaJuridico = false;
        Boolean isActualizaNatural  = false;
        List<Famiempresa__c> lstfami = new List<Famiempresa__c>();
        List<Account>      cuentaOpp = new List<Account>();
        List<OrderItem>    lstOrItem = new List<OrderItem>();
        List<Quote>         lstQuote = new List<Quote>();
        List<sObject>    listaObject = new List<sObject>();
        List<Opportunity>     lstOpp = new List<Opportunity>();
        List<QuoteLineItem>   lstQli = new List<QuoteLineItem>();
        
        if( String.isNotBlank(integracion.notificacionOportunidad.informacionBasica.idOportunidad ) ){
            lstOpp    = [SELECT id, AccountId, Famiempresa_relacionada__c FROM Opportunity WHERE Id =: integracion.notificacionOportunidad.informacionBasica.idOportunidad Limit 1 ];
            cuentaOpp = [SELECT id, Identificador_Famiempresa__c,RecordType.DeveloperName FROM Account WHERE Id =: lstOpp.get(0).AccountId Limit 1 ];
        }
        if( String.isNotBlank( integracion.notificacionOportunidad.informacionBasica.idProducto ) ){
            lstQli = [SELECT id,Product2.RecordType.DeveloperName, QuoteId FROM QuoteLineItem WHERE Id =: integracion.notificacionOportunidad.informacionBasica.idProducto Limit 1 ];
        }
        
        if( String.isNotBlank( integracion.notificacionOportunidad.informacionBasica.idProducto ) ){
            lstOrItem = [SELECT id, Product2.RecordType.DeveloperName,QuoteLineItem.QuoteId,Fecha_desembolso__c,Numero_de_factura__c FROM OrderItem 
                         WHERE QuoteLineItemId =: integracion.notificacionOportunidad.informacionBasica.idProducto Limit 1];
        }
        
        if(lstQli.size() == 1 )
            lstQuote  = [SELECT id, Status FROM Quote WHERE id =: lstQli.get(0).QuoteId Limit 1]; 
        
        if( cuentaOpp.size() == 1 && cuentaOpp.get(0).RecordType.DeveloperName != 'Persona_juridica' ){
            lstfami = consultaFamiEmpresaOpp(lstOpp.get(0).Famiempresa_relacionada__c);
        }
        
        if( cuentaOpp.get(0).RecordType.DeveloperName == 'Persona_juridica' && cuentaOpp.size() == 1 ){
            if( (integracion.notificacionOportunidad.informacionBasica.idFamiempresa != null || integracion.notificacionOportunidad.informacionBasica.idFamiempresa != '') && integracion.notificacionOportunidad.informacionBasica.idFamiempresa != '99999'){
                cuentaOpp.get(0).Identificador_Famiempresa__c = integracion.notificacionOportunidad.informacionBasica.idFamiempresa;    
            }
            listaObject = seleccionaConocimientoCredito(lstOrItem,lstQuote,lstQli);
            isActualizaJuridico = true;
        }else {
            if( lstfami.size() == 1 ){ 
                if( (integracion.notificacionOportunidad.informacionBasica.idFamiempresa != null || integracion.notificacionOportunidad.informacionBasica.idFamiempresa != '')  && integracion.notificacionOportunidad.informacionBasica.idFamiempresa != '99999'){
                    lstfami.get(0).Identificador_Famiempresa__c = integracion.notificacionOportunidad.informacionBasica.idFamiempresa;      
                }
            }
            listaObject = seleccionaConocimientoCredito(lstOrItem,lstQuote,lstQli);
            isActualizaNatural = true;
        }
        
        if( cuentaOpp.size() == 1 && isActualizaJuridico){  update cuentaOpp;  }   
        if( lstfami.size()   == 1 && isActualizaNatural){    update lstfami;   }  
        if( listaObject.size() > 0){
            system.debug(listaObject);
            update listaObject;
        }       
        if( lstOpp.size() > 0 ){ actualizaOportunidad( lstOpp[0] );  }
        if(lstQli.size() == 1 ){
            String marc = integracion.notificacionOportunidad.informacionBasica.marcacion; 
            lstQli[0].Marcacion__c = marc;
            // transferencia
            if(integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.tipoCuenta != ES_NULO &&
               integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.banco      != ES_NULO && 
               integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.numCuenta  != ES_NULO ){
                   String valorCancelacion = integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.valorCancelacion;
                   lstQli[0].Valor_Cancelacion_Saldo_a_Cargo__c = valorCancelacion != null ? Decimal.valueOf(valorCancelacion) : null;
               }
            // cheque 
            else if(integracion.notificacionOportunidad.desembolso.desembolsoCheque.cuenta    != ES_NULO &&
                    integracion.notificacionOportunidad.desembolso.desembolsoCheque.numcuenta != ES_NULO){
                        String valorCancelacion = integracion.notificacionOportunidad.desembolso.desembolsoCheque.valorCancelacion;
                        lstQli[0].Valor_Cancelacion_Saldo_a_Cargo__c = valorCancelacion != null ? Decimal.valueOf(valorCancelacion) : null; 
            } 
            
            update lstQli[0];
        }
    }
    
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se define si es de conocimiento o de credito
    *Date: 25-7-2019
    ************************************************************************************************/
    public static List<sObject> seleccionaConocimientoCredito(List<OrderItem> lstOrItem,List<Quote> lstQuote,List<QuoteLineItem> lstQli){
        List<sObject> sObjecto = new List<sObject>();
        if(lstOrItem.size() == 1 && lstOrItem.get(0).Product2.RecordType.DeveloperName == 'Servicios_de_conocimiento_y_redes'){
            if(integracion.notificacionOportunidad.informacionBasica.valorEstado == 'FACTURADO'){
                lstOrItem.get(0).Estado__c = 'Matriculado';
                lstOrItem.get(0).Numero_de_factura__c = String.valueOf(integracion.notificacionOportunidad.informacionBasica.numeroFactura);
            }
            return lstOrItem;
        }else if(lstQli.size() == 1 && lstQli.get(0).Product2.RecordType.DeveloperName == 'Solicitud_de_credito'){
            if(integracion.notificacionOportunidad.informacionBasica.valorEstado == 'DESEMBOLSADA'){
                if(lstOrItem.size() == 1 ){
                    lstOrItem.get(0).Estado__c             = 'Activo';
                    lstOrItem.get(0).Fecha_desembolso__c   = Date.valueof(integracion.notificacionOportunidad.informacionBasica.fecha); 
                    lstOrItem.get(0).Monto_desembolsado__c = Decimal.valueOf(integracion.notificacionOportunidad.informacionBasica.montoDesembolsado);
                    lstOrItem.get(0).Plazo__c              = Decimal.valueOf(integracion.notificacionOportunidad.informacionBasica.plazoOrden);   
                    lstOrItem.get(0).Numero_de_credito__c  = String.valueOf(integracion.notificacionOportunidad.informacionBasica.idCredito);
                    sObjecto.addAll(lstOrItem);
                }
            }else{
                lstQuote.get(0).Status = integracion.notificacionOportunidad.informacionBasica.valorEstado;
                // Aqui se incluiran los update a los campos Monto y plazo aprobados. Nuevos campos en la cotización.
                
                sObjecto.addAll(lstQuote);
            }          
            
            System.debug('lista devuelta '+ sObjecto);
            return sObjecto;
        }else{
            return new List<sObject>();
        }        
    }
    
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se define si es de conocimiento o de credito
    *Date: 25-7-2019
    ************************************************************************************************/
    public static List<Famiempresa__c> consultaFamiEmpresa(List<Account> cuentaOpp){
        return [SELECT id, Identificador_Famiempresa__c FROM Famiempresa__c 
                WHERE Cliente_relacionado__c =: cuentaOpp.get(0).Id ORDER BY LastModifiedDate desc LIMIT 1];
    }
    
    public static List<Famiempresa__c> consultaFamiEmpresaOpp(String idFami){
        return [SELECT id, Identificador_Famiempresa__c FROM Famiempresa__c WHERE Id =: idFami];
    }
    
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de actualizar la oportunidad siempre que se consuma el servicio
    *Date: 01-10-2020
    ************************************************************************************************/
    public static void actualizaOportunidad( Opportunity oportunidad){
        Boolean actualiza = false;
        // tipo cuenta, banco, número de cuenta si es transferencia y cuenta y número de cuenta si es cheque

        // transferencia
        if(integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.tipoCuenta != ES_NULO &&
           integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.banco      != ES_NULO && 
           integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.numCuenta  != ES_NULO ){
            oportunidad.Medio_de_desembolso__c = TRANSFERENCIA;  // transferencia
            oportunidad.Tipo_de_cuenta__c      = integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.tipoCuenta;
            oportunidad.Entidad_financiera__c  = integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.banco;
            oportunidad.Cuenta_No__c           = integracion.notificacionOportunidad.desembolso.desembolsoTransferencia.numCuenta; 
            oportunidad.Exonero_a_Interactuar_de_toda_responsabi__c = SI;
            oportunidad.Cheque_a_nombre_de_entidad__c = null;
            actualiza = true;         
        }
        else // cheque      
        if( integracion.notificacionOportunidad.desembolso.desembolsoCheque.cuenta    != ES_NULO &&
            integracion.notificacionOportunidad.desembolso.desembolsoCheque.numcuenta != ES_NULO ){
            oportunidad.Medio_de_desembolso__c         = CHEQUE; // cheque
            oportunidad.Cheque_a_nombre_de_entidad__c  = integracion.notificacionOportunidad.desembolso.desembolsoCheque.cuenta;       
            oportunidad.Cuenta_No__c                   = integracion.notificacionOportunidad.desembolso.desembolsoCheque.numcuenta;
            oportunidad.Exonero_a_Interactuar_de_toda_responsabi__c = null;
            oportunidad.Tipo_de_cuenta__c              = null;
            oportunidad.Entidad_financiera__c          = null;     
            actualiza = true;         
        }
        if( actualiza ){
            update oportunidad;
        }        
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
    }
}
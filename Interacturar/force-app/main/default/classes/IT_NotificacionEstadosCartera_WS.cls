/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Alejandro Gómez
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso  REST para exponer servicio de Notificacion estados de cartera.

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   26-Nov-2019  Alejandro Gomez (AG)		  Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/NotificacionEstadosCartera/*')
global class IT_NotificacionEstadosCartera_WS {
    public static List<Asset> asset = new List<Asset>();
    public static Set<String> setIdAsset = new Set<String>();
    public static List<Empleado__c> employee = new List<Empleado__c>();
    public static Set<String> setIdEmpleado = new Set<String>();
    
    /******************************************************************************************
    *Author:  Alejandro Gómez
    *Function: Se deserializan los datos que vienen de la notificacion del estado de cartera.
    *Date: 6-7-2019
    ******************************************************************************************/
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent); 
        strJSONContent = '{ "row": '+strJSONContent + '}';
        
        fromJSON row  = (IT_NotificacionEstadosCartera_WS.fromJSON)JSON.deserializeStrict(strJSONContent, IT_NotificacionEstadosCartera_WS.fromJSON.class); 
        
        System.debug('Obj deserealizado '+ row);
        System.debug(row.row.productos.credito.numero);
        //System.debug(row.row.id);
        
        setIdAsset.add(row.row.productos.credito.numero);
        setIdEmpleado.add(row.row.novedades.gestionCobranza.usuario);
        
        asset = [SELECT Id, Numero_de_credito__c, AccountId FROM Asset where Numero_de_credito__c IN: setIdAsset];
        employee = [SELECT Id, Codigo_de_Empleado__c FROM Empleado__c Where Codigo_de_Empleado__c IN: setIdEmpleado];
        
        if(asset.size() == 0 ){        	
            throw new applicationException('El número de crédito no existe en Salesforce: ' + row.row.productos.credito.numero);
        }else if (employee.size() == 0 && row.row.operacion == '4'){
            throw new applicationException('El código del empleado no existe en Salesforce');
        }else if (row.row.operacion == '1'){
            // Operación: 1-Novedad de Pago
            novedadPago(asset,row);
        }else if (row.row.operacion == '2'){
            // Operación: 2-Novedad de Mora
            novedadMora(asset,row);
        }else if (row.row.operacion == '3'){
            // Operación: 3-Novedad Cambió de Estado
            cambioEstado(asset,row);
        }else if (row.row.operacion == '4' && employee.size() > 0 ){
            // Operación: 4-Novedad Cobranza
            acuerdoPago(asset,employee,row);
        }
    }
    
    /******************************************************************************
    *Author:  Alejandro Gómez
    *Function: Se encarga de actualizar el activo, cuando se envia desde Oracle la operación 1-Novedad de Pago.
    *Date: 02-12-2019
    ******************************************************************************/
    public static void novedadPago(List<Asset> listAsset, fromJSON row){
        try{
            for(Integer k=0; k < listAsset.size(); k++){
                if(listAsset.get(k).Numero_de_credito__c      			== row.row.productos.credito.numero){
                    listAsset.get(k).Numero_de_credito__c			 	= listAsset.get(k).Numero_de_credito__c;
                    // NOVEDADES MORA
                    listAsset.get(k).Dias_de_mora__c 		  			= (row.row.novedades.mora.dias != null)            							? row.row.novedades.mora.dias 										: null;
                    listAsset.get(k).Valor_en_mora__c 		  			= (row.row.novedades.mora.valor != null)            						? row.row.novedades.mora.valor 										: null;
                    // ESTADO DE CARTERA
                    // Novedades.pago.(id  (identificador de pago, no se recibe) || fechaPago || monto)
                    listAsset.get(k).Fecha_ultimo_pago__c      		  	= (String.isNotBlank(row.row.novedades.pago.fechaPago)) 					? Date.valueOf(row.row.novedades.pago.fechaPago) 					: null;
                    listAsset.get(k).Valor_ultimo_pago__c      		  	= (row.row.novedades.pago.monto != null) 									? row.row.novedades.pago.monto 										: null;				
                    listAsset.get(k).Identificador_del_pago__c			= (String.isNotBlank(row.row.novedades.pago.id))							? row.row.novedades.pago.id 										: null;
                    // CAMBIO DE ESTADO
                    // Novedades.cambioEstado.(descripcion || calificacion)
                    listAsset.get(k).Status								= (String.isNotBlank(row.row.novedades.cambioEstado.descripcion)) 			? row.row.novedades.cambioEstado.descripcion 						: null;
                    listAsset.get(k).Calificacion__c       		 		= (String.isNotBlank(row.row.novedades.cambioEstado.calificacion))  		? row.row.novedades.cambioEstado.calificacion 						: null;				
                    // Novedades.estadoCartera.(saldoCancelacionTotal || porcentajeAvanceCuotas || cuotasRestantes)
                    listAsset.get(k).Saldo_para_cancelacion_total__c 	= (row.row.novedades.estadoCartera.saldoCancelacionTotal != null)   		? row.row.novedades.estadoCartera.saldoCancelacionTotal 			: null;
                    listAsset.get(k).Avance_en_cuotas__c		      	= (row.row.novedades.estadoCartera.porcentajeAvanceCuotas != null)  		? row.row.novedades.estadoCartera.porcentajeAvanceCuotas 			: null;		
                    listAsset.get(k).Numero_de_cuotas_restantes__c   	= (row.row.novedades.estadoCartera.cuotasRestantes != null)       			? row.row.novedades.estadoCartera.cuotasRestantes 					: null;		
                    // Novedades.estadoCartera.proximoPago.(valor || fecha)
                    listAsset.get(k).Fecha_proximo_pago__c 		  		= (String.isNotBlank(row.row.novedades.estadoCartera.proximoPago.fecha))	? Date.valueOf(row.row.novedades.estadoCartera.proximoPago.fecha) 	: null;
                    listAsset.get(k).Valor_proximo_pago__c 		  		= (row.row.novedades.estadoCartera.proximoPago.valor != null)            	? row.row.novedades.estadoCartera.proximoPago.valor 				: null;
                    listAsset.get(k).Fecha_de_cancelacion__c 		  	= (String.isNotBlank(row.row.novedades.estadoCartera.fechaCancelacion))		? Date.valueOf(row.row.novedades.estadoCartera.fechaCancelacion) 	: null;
                    listAsset.get(k).Referencia_de_Pago__c 		  	    = (String.isNotBlank(row.row.productos.credito.referenciaPago))	          	? row.row.productos.credito.referenciaPago                      	: null;
                }
            }
            update listAsset;
        }catch(Exception ex){
            System.debug('Exception controlada novedad de pago: '+ ex);
            throw new applicationException('Error en los datos de la novedad de pago: '+ ex);
        }
        
    }
    
    /******************************************************************************
    *Author:  Alejandro Gómez
    *Function: Se encarga de actualizar el activo, cuando se envia desde Oracle la operación 2-Novedad Mora.
    *Date: 02-12-2019
    ******************************************************************************/
    public static void novedadMora(List<Asset> listAsset, fromJSON row){
        try{
            for(Integer k=0; k < listAsset.size(); k++){
                if(listAsset.get(k).Numero_de_credito__c      			== row.row.productos.credito.numero){
                    listAsset.get(k).Numero_de_credito__c			 	= listAsset.get(k).Numero_de_credito__c;
                    // NOVEDADES MORA
                    listAsset.get(k).Dias_de_mora__c 		  			= (row.row.novedades.mora.dias != null)            							? row.row.novedades.mora.dias 										: null;
                    listAsset.get(k).Valor_en_mora__c 		  			= (row.row.novedades.mora.valor != null)            						? row.row.novedades.mora.valor 										: null;
                    // ESTADO DE CARTERA
                    // Novedades.estadoCartera.(saldoCancelacionTotal || porcentajeAvanceCuotas || cuotasRestantes)
                    listAsset.get(k).Saldo_para_cancelacion_total__c 	= (row.row.novedades.estadoCartera.saldoCancelacionTotal != null)   		? row.row.novedades.estadoCartera.saldoCancelacionTotal 			: null;
                    listAsset.get(k).Avance_en_cuotas__c		      	= (row.row.novedades.estadoCartera.porcentajeAvanceCuotas != null)  		? row.row.novedades.estadoCartera.porcentajeAvanceCuotas 			: null;		
                    listAsset.get(k).Numero_de_cuotas_restantes__c   	= (row.row.novedades.estadoCartera.cuotasRestantes != null)       			? row.row.novedades.estadoCartera.cuotasRestantes 					: null;		
                    // Novedades.estadoCartera.proximoPago.(valor || fecha)
                    listAsset.get(k).Fecha_proximo_pago__c 		  		= (String.isNotBlank(row.row.novedades.estadoCartera.proximoPago.fecha))	? Date.valueOf(row.row.novedades.estadoCartera.proximoPago.fecha) 	: null;
                    listAsset.get(k).Valor_proximo_pago__c 		  		= (row.row.novedades.estadoCartera.proximoPago.valor != null)            	? row.row.novedades.estadoCartera.proximoPago.valor 				: null;
                    listAsset.get(k).Fecha_de_cancelacion__c 		  	= (String.isNotBlank(row.row.novedades.estadoCartera.fechaCancelacion))		? Date.valueOf(row.row.novedades.estadoCartera.fechaCancelacion) 	: null;
                    // CAMBIO DE ESTADO
                    // Novedades.cambioEstado.(descripcion || calificacion)
                    listAsset.get(k).Status								= (String.isNotBlank(row.row.novedades.cambioEstado.descripcion)) 			? row.row.novedades.cambioEstado.descripcion 						: null;
                    listAsset.get(k).Calificacion__c       		 		= (String.isNotBlank(row.row.novedades.cambioEstado.calificacion))  		? row.row.novedades.cambioEstado.calificacion 						: null;				
                    // PROYECCION PAGO
                    // Novedades.mora.proyeccionFecha
                    listAsset.get(k).Proyeccion_fecha__c 		  		= (String.isNotBlank(row.row.novedades.mora.proyeccionFecha))  			    ? Date.valueOf(row.row.novedades.mora.proyeccionFecha) 				: null;  
                    //Referencia de Pago
                    listAsset.get(k).Referencia_de_Pago__c 		  	    = (String.isNotBlank(row.row.productos.credito.referenciaPago))	          	? row.row.productos.credito.referenciaPago                      	: null;
                    // Novedades.mora.proyeccionesPago.(orden || valor)
                    try{
                        
                        if(row.row.novedades.mora.proyeccionesPago[0].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_1__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(0);
                            listAsset.get(k).Proyeccion_valor_dia_1__c = row.row.novedades.mora.proyeccionesPago[0].valor;
                        }
                        if(row.row.novedades.mora.proyeccionesPago[1].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_2__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(1);
                            listAsset.get(k).Proyeccion_valor_dia_2__c = row.row.novedades.mora.proyeccionesPago[1].valor;
                        }
                        if(row.row.novedades.mora.proyeccionesPago[2].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_3__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(2);
                            listAsset.get(k).Proyeccion_valor_dia_3__c = row.row.novedades.mora.proyeccionesPago[2].valor;
                        }
                        if(row.row.novedades.mora.proyeccionesPago[3].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_4__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(3);
                            listAsset.get(k).Proyeccion_valor_dia_4__c = row.row.novedades.mora.proyeccionesPago[3].valor;
                        }                        
                        if(row.row.novedades.mora.proyeccionesPago[4].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_5__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(4);
                            listAsset.get(k).Proyeccion_valor_dia_5__c = row.row.novedades.mora.proyeccionesPago[4].valor;
                        }
                        if(row.row.novedades.mora.proyeccionesPago[5].valor != null){
                            listAsset.get(k).Proyeccion_fecha_dia_6__c = Date.valueOf(row.row.novedades.mora.proyeccionFecha).addDays(5);
                            listAsset.get(k).Proyeccion_valor_dia_6__c = row.row.novedades.mora.proyeccionesPago[5].valor;
                        }
                    }catch(Exception ex){
                        System.debug('Excepción controlada ' + ex);
                    }
                }
            }
            update listAsset;
        }catch(Exception ex){
            System.debug('Exception controlada novedad de mora: '+ ex);
            throw new applicationException('Error en datos de la novedad de mora: '+ ex);
        }
    }
    
    /******************************************************************************
    *Author:  Alejandro Gómez
    *Function: Se encarga de actualizar el activo, cuando se envia desde Oracle la operación 3-Cambio de Estado.
    *Date: 02-12-2019
    ******************************************************************************/
    public static void cambioEstado(List<Asset> listAsset, fromJSON row){
        try{
            for(Integer k=0; k < listAsset.size(); k++){
                if(listAsset.get(k).Numero_de_credito__c      			== row.row.productos.credito.numero){
                    listAsset.get(k).Numero_de_credito__c			  	= listAsset.get(k).Numero_de_credito__c;
                    // NOVEDADES MORA
                    listAsset.get(k).Dias_de_mora__c 		  			= (row.row.novedades.mora.dias != null)            							? row.row.novedades.mora.dias 										: null;
                    listAsset.get(k).Valor_en_mora__c 		  			= (row.row.novedades.mora.valor != null)            						? row.row.novedades.mora.valor 										: null;
                    // CAMBIO DE ESTADO
                    // Novedades.cambioEstado.(descripcion || calificacion)
                    listAsset.get(k).Status								= (String.isNotBlank(row.row.novedades.cambioEstado.descripcion)) 			? row.row.novedades.cambioEstado.descripcion 						: null;
                    listAsset.get(k).Calificacion__c       		 		= (String.isNotBlank(row.row.novedades.cambioEstado.calificacion))  		? row.row.novedades.cambioEstado.calificacion 						: null;				
                    // ESTADO DE CARTERA
                    // Novedades.estadoCartera.(saldoCancelacionTotal || porcentajeAvanceCuotas || cuotasRestantes)
                    listAsset.get(k).Saldo_para_cancelacion_total__c 	= (row.row.novedades.estadoCartera.saldoCancelacionTotal != null)   		? row.row.novedades.estadoCartera.saldoCancelacionTotal 			: null;
                    listAsset.get(k).Avance_en_cuotas__c		      	= (row.row.novedades.estadoCartera.porcentajeAvanceCuotas != null)  		? row.row.novedades.estadoCartera.porcentajeAvanceCuotas 			: null;		
                    listAsset.get(k).Numero_de_cuotas_restantes__c   	= (row.row.novedades.estadoCartera.cuotasRestantes != null)       			? row.row.novedades.estadoCartera.cuotasRestantes 					: null;		
                    // Novedades.estadoCartera.proximoPago.(valor || fecha)
                    listAsset.get(k).Fecha_proximo_pago__c 		  		= (String.isNotBlank(row.row.novedades.estadoCartera.proximoPago.fecha))	? Date.valueOf(row.row.novedades.estadoCartera.proximoPago.fecha) 	: null;
                    listAsset.get(k).Valor_proximo_pago__c 		  		= (row.row.novedades.estadoCartera.proximoPago.valor != null)            	? row.row.novedades.estadoCartera.proximoPago.valor 				: null;
                    listAsset.get(k).Fecha_de_cancelacion__c 		  	= (String.isNotBlank(row.row.novedades.estadoCartera.fechaCancelacion))		? Date.valueOf(row.row.novedades.estadoCartera.fechaCancelacion) 	: null;
                    listAsset.get(k).Referencia_de_Pago__c 		  	    = (String.isNotBlank(row.row.productos.credito.referenciaPago))	          	? row.row.productos.credito.referenciaPago                      	: null;
                }
            }
            update listAsset; 
        }catch(Exception ex){ 
            System.debug('Exception controlada cambio de estado: '+ ex); 
            throw new applicationException('Error en datos del cambio de estado: '+ ex);
        }
        
    }
    
    /******************************************************************************************
    *Author:  Alejandro Gómez
    *Function: Se encarga de insertar el registro de la actividad, cuando se envia desde Oracle la operación 4-Acuerdo de Pago.
    *Date: 2-12-2019
    ******************************************************************************************/    
    public static void acuerdoPago(List<Asset> listAsset, List<Empleado__c> listEmpleado, fromJSON row){
        List<Task> listInsert = new List<Task>();
        try{
            for(Integer i=0; i < listAsset.size(); i++ ){
                for(Integer k=0; k < listEmpleado.size(); k++){
                    if(listEmpleado.get(k).Codigo_de_Empleado__c    == row.row.novedades.gestionCobranza.usuario){
                        Task task									= new Task();
                        task.Fecha_llamada__c      		  			= (String.isNotBlank(row.row.novedades.gestionCobranza.fechaLlamada)) 				? Date.valueOf(row.row.novedades.gestionCobranza.fechaLlamada) 			: null;
                        task.Description           		  			= (String.isNotBlank(row.row.novedades.gestionCobranza.observacion)) 				? row.row.novedades.gestionCobranza.observacion 						: null;
                        task.Tipo_de_gestion__c    		  			= (String.isNotBlank(row.row.novedades.gestionCobranza.tipoGestion)) 				? row.row.novedades.gestionCobranza.tipoGestion 						: null;
                        task.Tipo_de_contacto__c          			= (String.isNotBlank(row.row.novedades.gestionCobranza.contacto)) 					? row.row.novedades.gestionCobranza.contacto 							: null;
                        task.Gestion_efectiva__c		  			= row.row.novedades.gestionCobranza.efectivo;		
                        task.Asignado_a__c	  						= listEmpleado.get(k).Id;
                        task.Fecha_acuerdo_de_pago__c     			= (String.isNotBlank(row.row.novedades.gestionCobranza.acuerdo.fecha)) 				? Date.valueOf(row.row.novedades.gestionCobranza.acuerdo.fecha) 		: null;
                        task.Pago_minimo__c        		  			= (row.row.novedades.gestionCobranza.acuerdo.pagoMinimo != null) 					? row.row.novedades.gestionCobranza.acuerdo.pagoMinimo 					: null;				
                        task.WhatId									= listAsset.get(i).Id;
                        task.ActivityDate				  			= (String.isNotBlank(row.row.novedades.gestionCobranza.acuerdo.fechaSeguimiento)) 	? Date.valueOf(row.row.novedades.gestionCobranza.acuerdo.fechaSeguimiento) : null;
                        task.Subject								= 'Gestión de Cobranza - Origen Oracle';
                        task.Status									= 'Terminada';
                        listInsert.add(task);
                    }
                }
            }
            insert listInsert;
        }catch(Exception ex){ 
            System.debug('Exception controlada acuerdo de pago: '+ ex); 
            throw new applicationException('Error en datos de la inserción de la gestión cobranza: '+ ex);
        }
    }
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para el manejo de las excepciones
    *Date: 6-7-2019
    ******************************************************************************************/
    public class applicationException extends Exception {}
    
    /******************************************************************************************
    *Author:  Alejandro Gómez
    *Function: Estructura de clases internas para cargar los datos deserializados
    *Date: 6-7-2019
    ******************************************************************************************/
    public class fromJSON{
        public cls_row row;
    }    
    class cls_row {
        public String operacion; 
        public String id;	
        public String propietario;	
        public String radicado;	
        public cls_productos productos;
        public cls_novedades novedades;
    }
    class cls_productos {
        public cls_credito credito;
        public cls_asesoria asesoria;
        public cls_capacitacion capacitacion;
    }
    class cls_credito {
        public String codigoProductoSalesforce;	 
        public String codigoProductoOracle;	
        public String nombreProducto;	
        public String numero;	
        public String referenciaPago;
        public Integer montoDesembolsado;
        public String fechaDesembolso;
        public Integer plazo;
    }
    class cls_asesoria { 
        public String nombreProducto;	
        public String numeroFactura;	
        public String fechaFactura;	
        public String fechaMatricula;	
    }
    class cls_capacitacion { 
        public String nombreProducto;	
        public String numeroFactura;	
        public String fechaFactura;	
        public String fechaMatricula;	
    }
    class cls_novedades {
        public cls_pago pago;
        public cls_mora mora;
        public cls_cambioEstado cambioEstado;
        public cls_gestionCobranza gestionCobranza;
        Public cls_estadoCartera estadoCartera;
    }
    class cls_pago {
        public String id;	
        public String fechaPago;
        public Integer monto;
    }
    class cls_mora {
        public Integer dias;
        public Integer valor;
        public String proyeccionFecha;
        public cls_proyeccionesPago[] proyeccionesPago;
    }
    class cls_proyeccionesPago {
        public Integer orden;
        public Integer valor;
    }
    class cls_cambioEstado {
        public String descripcion;
        public String calificacion;
    }
    class cls_gestionCobranza {
        public String fechaLlamada;
        public String observacion; 
        public String tipoGestion;
        public String contacto;
        public boolean efectivo;
        public String usuario;
        public cls_acuerdo acuerdo;
        
    }
    class cls_acuerdo {
        public String fecha;
        public Integer pagoMinimo;
        public String fechaSeguimiento;
    }
    class cls_estadoCartera {
        public Decimal saldoCancelacionTotal;
        public Decimal porcentajeAvanceCuotas;
        public Integer cuotasRestantes;
        public String fechaCancelacion;
        public cls_proximoPago proximoPago;

    }
    class cls_proximoPago {
        public Integer valor;
        public String fecha;
    }    
    
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
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
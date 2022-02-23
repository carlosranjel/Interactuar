/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de Notificacion estados orden de servicio

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   20-May-2019  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@RestResource(urlMapping='/NotificacionEstadosOrdenServicios/*')
global class IT_NotificacionEstadosOrdenServicio_WS {
        public IT_NotificacionEstadosOrdenServicio_WS(){}

    /*
    public static List<QuoteLineItem> productoxcotizacion = new List<QuoteLineItem>();
	public static Set<Id> setIdProducto = new Set<Id>();
    */
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos que vienen de la notificacion de la orden de servicio
    *Date: 6-7-2019
    ******************************************************************************************/
    /*
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent); 
        strJSONContent = '{ "row": '+strJSONContent + '}';
        fromJSON row  = (IT_NotificacionEstadosOrdenServicio_WS.fromJSON)JSON.deserializeStrict(strJSONContent, IT_NotificacionEstadosOrdenServicio_WS.fromJSON.class); 
        System.debug('Obj deserealizado '+ row);
      	
        // cuando no se cumpla alguna condicion de negocio se debe devolver una exception 
        // con un mensaje bien descriptivo. Este es un ejemplo

		System.debug(row.row.productos.credito.informacionGeneral.codigoProductoSalesforce);
        setIdProducto.add(row.row.productos.credito.informacionGeneral.codigoProductoSalesforce);        
		productoxcotizacion = [SELECT Id, (select id from OrderItems) FROM QuoteLineItem where id IN: setIdProducto];

        if(productoxcotizacion.size() == 0){        	
            throw new applicationException('La orden de servicio no existe en Salesforce');        
        }else{
			actualizaOrdenServicio(productoxcotizacion,row);
        }
        
    }
	*/
	/******************************************************************************
	*Author:  Rafael Cardona
	*Function: Se encarga de actualizar la orden de servicio recibida desde Oracle
	*Date: 3-7-2019
	******************************************************************************/
    /*
    public static void actualizaOrdenServicio(List<QuoteLineItem> listpxc, fromJSON row){
    	List<OrderItem> listaActualizar = new List<OrderItem>();
		try{
    	for(Integer k=0; k < listpxc.size(); k++){
    		if(listpxc.get(k).Id == row.row.productos.credito.informacionGeneral.codigoProductoSalesforce){
	    		OrderItem ordenItem 			= new OrderItem();				
				ordenItem.Estado__c 		    		  = (String.isNotBlank(row.row.estado)) ? row.row.estado : null;
				ordenItem.Valor_proximo_pago__c 		  = (row.row.productos.credito.informacionGeneral.proximoPago.valor != null)            ? row.row.productos.credito.informacionGeneral.proximoPago.valor : null;
				ordenItem.Fecha_proximo_pago__c 		  = (String.isNotBlank(row.row.productos.credito.informacionGeneral.proximoPago.fecha)) ? Date.valueOf(row.row.productos.credito.informacionGeneral.proximoPago.fecha) : null;
				ordenItem.Saldo_para_cancelacion_total__c = (row.row.productos.credito.informacionGeneral.saldoCancelacionTotal != null)        ? row.row.productos.credito.informacionGeneral.saldoCancelacionTotal : null;
				ordenItem.Dias_de_mora__c       		  = (row.row.productos.credito.informacionGeneral.mora.dias != null)                    ? row.row.productos.credito.informacionGeneral.mora.dias : null; 
     			ordenItem.Valor_en_mora__c      		  = (row.row.productos.credito.informacionGeneral.mora.valor != null) 					? row.row.productos.credito.informacionGeneral.mora.valor : null;				
				ordenItem.Fecha_de_cancelacion__c 		  = (String.isNotBlank(row.row.productos.credito.informacionGeneral.fechaCancelacion))  ? Date.valueOf(row.row.productos.credito.informacionGeneral.fechaCancelacion) : null;
      			ordenItem.Calificacion__c       		  = (String.isNotBlank(row.row.productos.credito.informacionGeneral.calificacion))      ? row.row.productos.credito.informacionGeneral.calificacion : null;				
				ordenItem.Fecha_llamada__c      		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.fechaLlamada)) 			? Date.valueOf(row.row.productos.credito.estadoCartera.fechaLlamada) : null;
				ordenItem.Tipo_de_gestion__c    		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.tipoGestion)) 			? row.row.productos.credito.estadoCartera.tipoGestion : null;
				ordenItem.Contacto__c           		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.contacto)) 				? row.row.productos.credito.estadoCartera.contacto : null;
				ordenItem.Efectivo__c           		  = row.row.productos.credito.estadoCartera.efectivo;				
				ordenItem.Usuario__c            		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.usuario)) 				? row.row.productos.credito.estadoCartera.usuario : null;				
				ordenItem.Fecha_acuerdo__c      		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.acuerdo.fecha)) 			? Date.valueOf(row.row.productos.credito.estadoCartera.acuerdo.fecha) : null;
				ordenItem.Dia_acuerdo__c        		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.acuerdo.dia)) 			? row.row.productos.credito.estadoCartera.acuerdo.dia : null;
     			ordenItem.Pago_minimo__c        		  = (row.row.productos.credito.estadoCartera.acuerdo.pagoMinimo != null) 				? row.row.productos.credito.estadoCartera.acuerdo.pagoMinimo : null;				
				ordenItem.Fecha_de_seguimiento__c 		  = (String.isNotBlank(row.row.productos.credito.estadoCartera.acuerdo.fechaSeguimiento)) ? Date.valueOf(row.row.productos.credito.estadoCartera.acuerdo.fechaSeguimiento) : null;
				ordenItem.Avance_en_cuotas__c		      = ( row.row.productos.credito.informacionGeneral.porcentajeAvanceCuotas != null)      ? row.row.productos.credito.informacionGeneral.porcentajeAvanceCuotas : null;		
	    		ordenItem.Numero_de_cuotas_restantes__c   = ( row.row.productos.credito.informacionGeneral.numeroCuotasRestantes != null)       ? row.row.productos.credito.informacionGeneral.numeroCuotasRestantes : null;		
				ordenItem.id        					  = listpxc.get(k).OrderItems.get(0).id;
				listaActualizar.add(ordenItem);
    		}
    	}
		}catch(Exception ex){
			System.debug('Exception controada '+ ex);
			new applicationException('Error en datos '+ ex);
		}
    	update listaActualizar;
    }
    */
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para el manejo de las excepciones
    *Date: 6-7-2019
    ******************************************************************************************/
    //public class applicationException extends Exception {}
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura de clases internas para cargar los datos deserealizados
    *Date: 6-7-2019
    ******************************************************************************************/
    /*
    public class fromJSON{
		public cls_row row;
    }    
	class cls_row {
		public String idConsecutivo;	//Identificador de la Orden de Servicio en Salesforce, 
		public String propietario;	//
		public String radicado;	//Codigo de la Orden de Servicio en Oracle
		public String estado;	//Estado de la orden de servicio en Salesforce (Requiere homologacion)
		public String tipoProducto;	//credito
		public cls_productos productos;
	}
	class cls_productos {
		public cls_credito credito;
		public cls_asesoria asesoria;
		public cls_capacitacion capacitacion;
	}
	class cls_credito {
		public cls_informacionGeneral informacionGeneral;
		public cls_pago pago;
		public cls_estadoCartera estadoCartera;
	}
	class cls_informacionGeneral {
		public String codigoProductoSalesforce;	//  recibo id pxc que yo envio en el json de oportunidad
		public String codigoProductoOracle;	//
		public String nombreProducto;	//
		public String numero;	//
		public Integer montoDesembolsado;	//121300
		public String fechaDesembolso;	//
		public Integer plazo;	//12
		public Integer numeroCuotasRestantes;
		public Double porcentajeAvanceCuotas;	//0.12
		public cls_proximoPago proximoPago;
		public Integer saldoCancelacionTotal;	//90000
		public cls_mora mora;
		public String fechaCancelacion;	//30/06/2019 00:00:00.000
		public String calificacion;	//0.12
	}
	class cls_proximoPago {
		public Integer valor;	//23500
		public String fecha;	//30/06/2019 00:00:00.000
	}
	class cls_mora {
		public Integer dias;	//30
		public Integer valor;	//12500
	}
	class cls_pago {
		public String id;	//Identificador del pago
		public String fechaPago;	//01/08/2019 12:13:00.000
		public Integer monto;	//123145
	}
	class cls_estadoCartera {
		public String fechaLlamada;	//12/06/2019 13:23:01.234
		public String tipoGestion;	//XXXX
		public String contacto;	//NO SE TIENE CLARO QUE CONTIENE
		public boolean efectivo;
		public String usuario;	//
		public cls_acuerdo acuerdo;
	}
	class cls_acuerdo {
		public String fecha;	//15/08/2019 00:00:00.000
		public String dia;	//15/08/2019 00:00:00.000
		public Integer pagoMinimo;	//1234
		public String fechaSeguimiento;	//15/08/2019 00:00:00.000
	}
	class cls_asesoria {
		public String nombreProducto;	//
		public String numeroFactura;	//
		public String fechaFactura;	//01/08/2019 12:13:00.000
		public String fechaMatricula;	//01/08/2019 12:13:00.000
	}
	class cls_capacitacion {
		public String nombreProducto;	//
		public String numeroFactura;	//
		public String fechaFactura;	//01/08/2019 12:13:00.000
		public String fechaMatricula;	//01/08/2019 12:13:00.000
	}
	public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}
    */
}
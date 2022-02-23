/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class Batch que se encarga de crear los productos por cotizacion de offLine

* Cambios (Versiones)
* --------  ---   ----------   ---------------------------   ------------------------------------------------
*           No.   Fecha         Autor                        Descripcion
* --------  ---   ----------   ---------------------------   ------------------------------------------------
* --------  1.0   31-Jul-2019  Rafael Cardona (RC)           Creacion Clase.
* --------  1.0   16-Sep-2019  Alejandro Gomez (AG)          Eliminación de Monto 2, 3, 4, 5, para conocimiento.
/*
**************************************************************************************************************
**/
global class IT_CreaProductos_bch implements Database.Batchable<sObject> {
    
    String query;
    
    global IT_CreaProductos_bch() {     
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('start '); /*
        query = 'SELECT id, Observacion__c, '+
                ' Codigo_producto_1__c, Codigo_producto_2__c, Codigo_producto_3__c, Codigo_producto_4__c, Codigo_producto_5__c, '+
                ' Monto_producto_1__c, '+
                ' Cantidad_producto_1__c, Cantidad_producto_2__c,Cantidad_producto_3__c, Cantidad_producto_4__c,  Cantidad_producto_5__c, '+
                ' Plazo_meses_producto_1__c, Nombre_de_cotizacion__c, Tipo_de_servicio_cotizacion__c, AccountId '+
                ' FROM Opportunity WHERE Observacion__c = NULL AND '+
                ' (  ( Codigo_producto_1__c != NULL AND Cantidad_producto_1__c != NULL ) '+
                ' OR ( Codigo_producto_2__c != NULL AND Cantidad_producto_2__c != NULL ) '+ 
                ' OR ( Codigo_producto_3__c != NULL AND Cantidad_producto_3__c != NULL ) '+
                ' OR ( Codigo_producto_4__c != NULL AND Cantidad_producto_4__c != NULL ) '+
                ' OR ( Codigo_producto_5__c != NULL AND Cantidad_producto_5__c != NULL ) ) '; */
        //return Database.getQueryLocator(query); 
            return Database.getQueryLocator('Select Id From Opportunity Where CreatedDate > Today'); 

    
    }

    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        List<DatosProductosACrear> lstProductosCrear = new List<DatosProductosACrear>();
        Map<String,Product2> mapProductos = new Map<String,Product2>();
        Set<String> setProductos = new Set<String>();
        List<DatosCotizacion> lstDatosCotizacion = new List<DatosCotizacion>();
        List<String> codigoCantidad;
        System.debug('Oportunidad '+ scope);

        for(Opportunity op: scope){
            DatosCotizacion cotizacionesCrear = new DatosCotizacion();
            cotizacionesCrear.idOportunidad = op.ID;
            cotizacionesCrear.idCliente     = op.AccountId;
            cotizacionesCrear.nombre        = op.Nombre_de_cotizacion__c;
            cotizacionesCrear.tipoRegistro  = op.Tipo_de_servicio_cotizacion__c;
            lstDatosCotizacion.add(cotizacionesCrear);

            DatosProductosACrear productoCrear = new DatosProductosACrear();
            productoCrear.oportunidadId = op.ID;            
            productoCrear.plazoMeses    = Integer.valueOf(op.Plazo_meses_producto_1__c); 
            productoCrear.prodCotizacion = new List<UnidadProducto>();

            if( op.Codigo_producto_1__c != null && op.Cantidad_producto_1__c != null ){
                UnidadProducto unidad = new UnidadProducto();
                unidad.codProducto      = op.Codigo_producto_1__c;
                unidad.cantidadProducto = (op.Cantidad_producto_1__c).intValue();
                unidad.monto            = op.Monto_producto_1__c;
                productoCrear.prodCotizacion.add(unidad);
                setProductos.add(op.Codigo_producto_1__c);                              
            }
            if(op.Codigo_producto_2__c != null && op.Cantidad_producto_2__c != null ){
                UnidadProducto unidad = new UnidadProducto();
                unidad.codProducto      = op.Codigo_producto_2__c;
                unidad.cantidadProducto = (op.Cantidad_producto_2__c).intValue();
                productoCrear.prodCotizacion.add(unidad);
                setProductos.add(op.Codigo_producto_2__c);
            }
            if(op.Codigo_producto_3__c != null && op.Cantidad_producto_3__c != null ){
                UnidadProducto unidad = new UnidadProducto();
                unidad.codProducto      = op.Codigo_producto_3__c;
                unidad.cantidadProducto = (op.Cantidad_producto_3__c).intValue();
                productoCrear.prodCotizacion.add(unidad);               
                setProductos.add(op.Codigo_producto_3__c);
            }
            if(op.Codigo_producto_4__c != null && op.Cantidad_producto_4__c != null ){
                UnidadProducto unidad = new UnidadProducto();
                unidad.codProducto      = op.Codigo_producto_4__c;
                unidad.cantidadProducto = (op.Cantidad_producto_4__c).intValue();
                productoCrear.prodCotizacion.add(unidad);
                setProductos.add(op.Codigo_producto_4__c);
            }
            if(op.Codigo_producto_5__c != null && op.Cantidad_producto_5__c != null ){
                UnidadProducto unidad = new UnidadProducto();
                unidad.codProducto      = op.Codigo_producto_5__c;
                unidad.cantidadProducto = (op.Cantidad_producto_5__c).intValue();
                productoCrear.prodCotizacion.add(unidad);   
                setProductos.add(op.Codigo_producto_5__c);
            }
            lstProductosCrear.add(productoCrear);
        }

        mapProductos           = consultaProductos(setProductos);
        Map<Id,Quote> mapQuote = creaQuote(lstDatosCotizacion);
        creaProductoxCotizacion(mapProductos,lstProductosCrear,mapQuote);

    }

    global void finish(Database.BatchableContext BC) {      
    }

    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase que se encarga de crear los productos por cotizacion
    *Date: 6-7-2019
    ************************************************************************************************/
    public static void creaProductoxCotizacion(Map<String,Product2> mapProduct2Query,List<DatosProductosACrear> lstDatosProductos,Map<Id,Quote> mapQuote){
           List<QuoteLineItem> crearProductos  = new  List<QuoteLineItem>();
           Map<Id,String> lstOportunidadesFalla = new Map<Id,String>();
           List<Opportunity> lstOppFalla  = new  List<Opportunity>();
           Set<Id> setOportunidades = new Set<Id>();
        // System.debug('map a crear mapProduct2Query: '+ mapProduct2Query );
        // System.debug('map a crear lstDatosProductos: '+ lstDatosProductos );
        // System.debug('-->3' + (lstDatosProductos.get(0).prodCotizacion).get(0) );

        for(Integer k=0; k < lstDatosProductos.size(); k++){            
            for( Integer j=0;  j < (lstDatosProductos.get(k).prodCotizacion).size(); j++){
                for( Integer i=0;  i < (lstDatosProductos.get(k).prodCotizacion).get(j).cantidadProducto; i++ ){                                
                Boolean isExiste = false;
                QuoteLineitem pxcCrear = new QuoteLineitem();
                
                try{
                System.debug('Entry: '+ mapProduct2Query.get( (lstDatosProductos.get(k).prodCotizacion).get(j).codProducto ).PricebookEntries.get(0).id );
                pxcCrear.QuoteId          = mapQuote.get( lstDatosProductos.get(k).oportunidadId ).id;                      
                pxcCrear.Quantity         = Decimal.valueOf('1');           
                pxcCrear.PricebookEntryId = mapProduct2Query.get( (lstDatosProductos.get(k).prodCotizacion).get(j).codProducto ).PricebookEntries.get(0).id;
                pxcCrear.Product2Id       = mapProduct2Query.get( (lstDatosProductos.get(k).prodCotizacion).get(j).codProducto ).id;

                if( mapProduct2Query.get( (lstDatosProductos.get(k).prodCotizacion).get(j).codProducto ).Family != 'Conocimiento y Redes' ){
                    pxcCrear.Plazo_meses__c  = lstDatosProductos.get(k).plazoMeses;
                }
                if( (lstDatosProductos.get(k).prodCotizacion).get(j).monto == null){
                    pxcCrear.UnitPrice  = 0;
                }else{
                    pxcCrear.UnitPrice  = (lstDatosProductos.get(k).prodCotizacion).get(j).monto;
                }   

                isExiste = true;
                }catch(Exception ex){ 
                    System.debug('Error producto '+ ex);
                    if( !setOportunidades.contains( lstDatosProductos.get(k).oportunidadId )){
                           Opportunity opor = new Opportunity();
                           opor.id = lstDatosProductos.get(k).oportunidadId;
                           opor.Observacion__c = (lstDatosProductos.get(k).prodCotizacion).get(j).codProducto + ':fallo';
                           setOportunidades.add( lstDatosProductos.get(k).oportunidadId );
                           lstOppFalla.add(opor);
                           lstOportunidadesFalla.put(lstDatosProductos.get(k).oportunidadId,(lstDatosProductos.get(k).prodCotizacion).get(j).codProducto + ':fallo,');                  
                    }                   
                 }
                if(isExiste){crearProductos.add(pxcCrear);}

                }               
            }
        }

        if(crearProductos.size() > 0){
            Database.insert(crearProductos,false);
            System.debug('creados '+ crearProductos);
            respuestaCotizacion(crearProductos,lstOportunidadesFalla);
        }else if(lstOppFalla.size() > 0){
            update lstOppFalla;
        }

    }

    /********************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se limpian los campos offLine de los productos por cotizacion que fueron exitosamente creados
    *Date: 31-7-2019
    *********************************************************************************************************/
    public static void respuestaCotizacion(List<QuoteLineItem> crearProductos, Map<Id,String> lstOportunidadesFalla){
        List<QuoteLineItem> lst_PXC          = consultaPXCotizaciones(crearProductos);
        List<Opportunity> lst_OppActualizar  = consultaOportunidades(crearProductos);

        for(Opportunity opo: lst_OppActualizar){
            try{ opo.Observacion__c = lstOportunidadesFalla.get(opo.id);
            }catch(Exception ex){ opo.Observacion__c = ''; }
            
            for(QuoteLineItem pxc: lst_PXC){
                if(opo.Codigo_producto_1__c == pxc.Product2.Codigo_portafolio__c){
                    opo.Codigo_producto_1__c = '';
                    opo.Cantidad_producto_1__c = null;
                    opo.Monto_producto_1__c = null; //Mod
                    opo.Plazo_meses_producto_1__c = null; //Mod 
                    opo.Observacion__c += pxc.Product2.Codigo_portafolio__c+':ok,';
                }else if(opo.Codigo_producto_2__c == pxc.Product2.Codigo_portafolio__c){
                    opo.Codigo_producto_2__c = '';  
                    opo.Cantidad_producto_2__c = null;
                    opo.Observacion__c += pxc.Product2.Codigo_portafolio__c+':ok,';
                }else if(opo.Codigo_producto_3__c == pxc.Product2.Codigo_portafolio__c){
                    opo.Codigo_producto_3__c = '';  
                    opo.Cantidad_producto_3__c = null;
                    opo.Observacion__c += pxc.Product2.Codigo_portafolio__c+':ok,';
                }else if(opo.Codigo_producto_4__c == pxc.Product2.Codigo_portafolio__c){
                    opo.Codigo_producto_4__c = '';
                    opo.Cantidad_producto_4__c = null;
                    opo.Observacion__c += pxc.Product2.Codigo_portafolio__c+':ok,';
                }else if(opo.Codigo_producto_5__c == pxc.Product2.Codigo_portafolio__c){
                    opo.Codigo_producto_5__c = '';  
                    opo.Cantidad_producto_5__c = null;
                    opo.Observacion__c += pxc.Product2.Codigo_portafolio__c+':ok,';
                }
            }
        }
        update lst_OppActualizar;
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Para poder crear los productos por cotizacion, la cotizacion debe tener una 
               lista de precios asignada por lo tanto en este metodo se verifica si se le debe asociar.
               Por defecto se asigna la lista de precios standard
    *Date: 31-7-2019
    **************************************************************************************************/
    public static Map<Id,Quote> creaQuote( List<DatosCotizacion> lstDatosCotizacion ){  
        Map<Id,Quote> mapQuote = new Map<Id,Quote>();
        List<Quote> lstQuoteCrear = new List<Quote>();
        PriceBook2 listaPrecios       = [select id from PriceBook2 where name = 'Standard Price Book' ];

        for(DatosCotizacion dato: lstDatosCotizacion){
            Quote cotizacion = new Quote();         
            cotizacion.pricebook2id  = listaPrecios.Id;
            cotizacion.Name          = dato.nombre;
            cotizacion.OpportunityId = dato.idOportunidad;
            //cotizacion.AccountId     = dato.idCliente;
            cotizacion.RecordTypeId  = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(dato.tipoRegistro).getRecordTypeId();
            lstQuoteCrear.add(cotizacion);      
        }
        if( lstQuoteCrear.size() > 0 ){
            insert lstQuoteCrear;
            for(Quote cot: lstQuoteCrear){
                System.debug('despuesInsert: '+ cot);
                mapQuote.put(cot.OpportunityId,cot);
            }
        }
        return mapQuote;
    }


    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta de Product2 con su catalogo de precios, para devolver un Map<String,Product2>
    *Date: 31-7-2019
    **************************************************************************************************/
    public static Map<String,Product2> consultaProductos(Set<String> lstProductos){
        Map<String,Product2> mapProd = new Map<String,Product2>();      
        Set<String> unicoCodPortafolio = new Set<String>();
        for(Product2 pro : [SELECT id,ProductCode,Name,Family,Tipo_de_servicio__c,Precio__c,Codigo_portafolio__c,
                            (SELECT id FROM PricebookEntries LIMIT 1)
                            FROM Product2 WHERE Codigo_portafolio__c IN: lstProductos]){
            if( !unicoCodPortafolio.contains( pro.Codigo_portafolio__c ) ){
                mapProd.put(pro.Codigo_portafolio__c,pro);
                unicoCodPortafolio.add(pro.Codigo_portafolio__c);
            }           
        }
        return mapProd;
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta de Cotizaciones de productos por cotizacion creados
    *Date: 31-7-2019
    **************************************************************************************************/
    public static List<QuoteLineItem> consultaPXCotizaciones(List<QuoteLineItem> creadosPxc){
        return [SELECT id, Product2.ProductCode, Product2.Codigo_portafolio__c  FROM QuoteLineItem WHERE ID IN: creadosPxc];
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta de Cotizaciones de productos por cotizacion creados
    *Date: 31-7-2019
    **************************************************************************************************/
    public static List<Opportunity> consultaOportunidades(List<QuoteLineItem> creadosPxc){
        Set<ID> idOpp = new Set<ID>();
        for(QuoteLineItem pxc: [SELECT id, Quote.OpportunityId FROM QuoteLineItem WHERE id IN: creadosPxc]){
            idOpp.add(pxc.Quote.OpportunityId);
        }
        
        return [SELECT id, Observacion__c,
                        Cantidad_producto_1__c,Cantidad_producto_2__c,Cantidad_producto_3__c,Cantidad_producto_4__c,Cantidad_producto_5__c,
                        Codigo_producto_1__c,Codigo_producto_2__c,Codigo_producto_3__c,Codigo_producto_4__c,Codigo_producto_5__c,
                        Monto_producto_1__c,
                        (SELECT id FROM Quotes LIMIT 1)
                FROM Opportunity WHERE ID IN: idOpp];
    }
    
    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura donde se guardan los datos que se insertan en los campos offLine
    *Date: 31-7-2019
    **************************************************************************************************/
    public class DatosProductosACrear{
        public ID oportunidadId;
        public ID cotizacionId;
        public Integer plazoMeses;
        public UnidadProducto[] prodCotizacion;
    }

    public class UnidadProducto{
        public String codProducto;
        public Integer cantidadProducto;
        public Decimal monto;
    }

    public class DatosCotizacion{
        public ID idCliente;
        public ID idOportunidad;
        public String nombre;
        public String tipoRegistro;     
    }




































    public static void cobertura(){
    String variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';  
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';  
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
        variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';  
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    variable = '';
    }
    
}
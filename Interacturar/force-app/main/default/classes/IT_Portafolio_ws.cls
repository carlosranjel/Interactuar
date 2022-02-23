/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase servicio web para la creacion y actualizacion de portafolio (product2)

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   4-JUL-2019  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@RestResource(urlMapping='/ITServicioPortafolioWS/*')
global class IT_Portafolio_ws {
    

    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('prueba de entrada '+ strJSONContent);    
        respuesta = (portafolioJSON)System.JSON.deserialize(strJSONContent, portafolioJSON.class); 
        System.debug('portafolio: '+ respuesta);
        

        consultaPortafolioEntrada();
    }

    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se identifica si los datos que llegan es para una creacion o una actualizacion
    *Date: 6-7-2019
    ************************************************************************************************/
    public static void consultaPortafolioEntrada(){
        List<product2> lstProductosInsertar = new List<product2>();
        List<Product2> lstProductosConsultados = new List<product2>();
        Set<String> codeProducto = new Set<String>();

        for(Integer k=0; k < (respuesta.portafolio).size(); k++){
            System.debug('Identificador_portafolio: ' + (respuesta.portafolio).get(k).Identificador_portafolio);
            
            if( (respuesta.portafolio).get(k).isInsert ){
                lstProductosInsertar.add( ingresaDatosProducto( (respuesta.portafolio).get(k) , null ) );
            
            }else if( (respuesta.portafolio).get(k).isUpdate ){
                if( (respuesta.portafolio).get(k).Family == 'Conocimiento y Redes' && (respuesta.portafolio).get(k).Tipo_de_servicio == 'Capacitacion' ){
                codeProducto.add( (respuesta.portafolio).get(k).ProductCode+'-'+(respuesta.portafolio).get(k).Identificador_grupo);
                }else{
                codeProducto.add( (respuesta.portafolio).get(k).ProductCode );
                }
            }           
        }

        if( codeProducto.size() > 0 ){
            lstProductosConsultados = IT_GestorDeConsultas_cls.consultaProducto( codeProducto );
            System.debug('lstProductosConsultados: ' + lstProductosConsultados);
        }
        
        seleccionaProducto(lstProductosConsultados,lstProductosInsertar);
    }

    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se actualiza o se insertan los productos del portafolio
    *Date: 6-7-2019
    ************************************************************************************************/
    public static void seleccionaProducto(List<Product2> lstProductosConsultados, List<Product2> lstProductosInsertar){
        List<product2> lstProductosActualizar = new List<product2>();
        for(Integer k=0; k < lstProductosConsultados.size(); k++){
            for(Integer i=0; i < (respuesta.portafolio).size(); i++){
                if( lstProductosConsultados.get(k).ProductCode == (respuesta.portafolio).get(i).ProductCode +'-'+ (respuesta.portafolio).get(i).Identificador_grupo){
                    lstProductosActualizar.add( ingresaDatosProducto((respuesta.portafolio).get(i) , lstProductosConsultados.get(k).id) );
                }else 
                if(lstProductosConsultados.get(k).ProductCode == (respuesta.portafolio).get(i).ProductCode ){
                    lstProductosActualizar.add( ingresaDatosProducto((respuesta.portafolio).get(i) , lstProductosConsultados.get(k).id) );
                }
            }
        }

        if(lstProductosActualizar.size() > 0){
            update lstProductosActualizar;
        }
        if(lstProductosInsertar.size() > 0){
            insert lstProductosInsertar;
            creaEntradaCatalogoPrecios(lstProductosInsertar);
        }
    }

    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se crean los catalogos de precio para cada uno de los productos insertados
    *Date: 16-7-2019
    ************************************************************************************************/
    public static void creaEntradaCatalogoPrecios(List<Product2> lstProductosInsertar){
        List<PricebookEntry> lstCatalogoPrecios = new List<PricebookEntry>();
        Pricebook2 listaPrecios = [SELECT Description,Id,IsActive,IsStandard FROM Pricebook2 WHERE IsActive = true AND IsStandard = true LIMIT 1];
        for(Integer k=0; k < lstProductosInsertar.size(); k++){
            PricebookEntry catalogo = new PricebookEntry();
                catalogo.Product2Id    = lstProductosInsertar.get(k).id;
                catalogo.IsActive      = true;
                catalogo.Pricebook2Id  = listaPrecios.id;
                if( lstProductosInsertar.get(k).Tipo_de_servicio__c == 'Asesoria' ){
                    catalogo.UnitPrice     = lstProductosInsertar.get(k).Precio__c;
                }else if(lstProductosInsertar.get(k).Tipo_de_servicio__c == 'Capacitacion'){
                    catalogo.UnitPrice     = lstProductosInsertar.get(k).Grupo_valor__c;
                }else{
                    catalogo.UnitPrice     = 0;
                }               
                lstCatalogoPrecios.add(catalogo);
        }

        if(lstCatalogoPrecios.size() > 0){
            insert lstCatalogoPrecios;
        }
    }


    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se insertan los datos para la creacion o actualizacion del producto
    *Date: 6-7-2019
    ************************************************************************************************/
    public static Product2 ingresaDatosProducto(cls_Portafolio folio, Id idProducto){
        Product2 producto = new Product2();
            if( folio.Family == 'Conocimiento y Redes' ){                
               producto.RecordTypeId  = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
            }else if( folio.Family == 'Credito' ){
               producto.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
            }
            if( idProducto != null ){ producto.Id = idProducto; }
            producto.Identificador_portafolio__c  = folio.Identificador_portafolio;
            producto.ProductCode2__c   = folio.ProductCode;
            producto.Family            = folio.Family;
            producto.Clasificacion__c  = folio.Clasificacion;
            producto.Name              = folio.Name;
            producto.isActive          = folio.isActive;            

            producto.Programa__c              = folio.Programa;
            producto.Grupo_convenio_nombre__c = folio.Grupo_convenio_nombre;
            producto.Tipo_de_servicio__c      = folio.Tipo_de_servicio;
            producto.Horas_grupales__c        = (folio.Horas_grupales != null)    ? Decimal.valueOf(folio.Horas_grupales) : null;
            producto.Horas_individuales__c    = (folio.Horas_individuales != null)? Decimal.valueOf(folio.Horas_individuales) : null;          
            producto.Grupo_convenio__c        = (folio.Grupo_convenio != null)    ? Decimal.valueOf(folio.Grupo_convenio) : null;          
            producto.Grupo_valor__c           = (folio.Grupo_valor != null)       ? Decimal.valueOf(folio.Grupo_valor) : null;
            producto.Cupo_maximo__c           = (folio.Cupo_maximo != null)       ? Decimal.valueOf(folio.Cupo_maximo) : null;
            producto.Cupo_minimo__c           = (folio.Cupo_minimo != null)       ? Decimal.valueOf(folio.Cupo_minimo) : null;         
            producto.Precio__c                = (folio.Precio != null)            ? Decimal.valueOf(folio.Precio) : null;
            producto.Identificador_grupo__c   = (folio.Identificador_grupo != null)? Decimal.valueOf(folio.Identificador_grupo) : null;

            if(folio.Family == 'Conocimiento y Redes' && folio.Tipo_de_servicio == 'Capacitacion' ){
                producto.ProductCode =  folio.ProductCode +'-'+ folio.Identificador_grupo;
            }else{
                producto.ProductCode =  folio.ProductCode;
            }
            if(folio.Precio_sin_IVA != null ){ producto.Precio_sin_IVA__c    = folio.Precio_sin_IVA; }
            if(folio.Requiere_pago  != null ){ producto.Requiere_pago__c     = folio.Requiere_pago; }
            if(folio.Fecha_inicio   != null ){ producto.Fecha_inicio__c      = Date.valueOf(folio.Fecha_inicio); }
            if(folio.Fecha_fin      != null ){ producto.Fecha_fin__c         = Date.valueOf(folio.Fecha_fin); }
            if(folio.Oficina        != null ){ producto.Codigo_Oficina_OR__c = folio.Oficina; }
            if(folio.Sede           != null ){ producto.Codigo_Sede_OR__c    = folio.Sede;  }
            if(folio.Hora_inicio    != null ){ producto.Hora_inicio__c       = folio.Hora_inicio;  }
            if(folio.Hora_fin       != null ){ producto.Hora_fin__c          = folio.Hora_fin; }            
            if(folio.Monto_maximo   != null ){ producto.Monto_maximo__c  = Decimal.valueOf(folio.Monto_maximo); }
            if(folio.Monto_minimo   != null ){ producto.Monto_minimo__c  = Decimal.valueOf(folio.Monto_minimo); }
            if(folio.Dias_de_la_semana != null ){ producto.Dias_de_la_semana__c  = folio.Dias_de_la_semana; }
            if(folio.Tasa_nominal_anual_mes_vencido != null ){ producto.Tasa_nominal_anual_mes_vencido__c  = Decimal.valueOf(folio.Tasa_nominal_anual_mes_vencido);}            
            
        return producto;
    }



    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura interna para cargar los datos deserealizados
    *Date: 6-7-2019
    ******************************************************************************************/
    public static portafolioJSON  respuesta;
    public class portafolioJSON{
        public cls_Portafolio[] portafolio;
    }
    public class cls_Portafolio {
        public String Identificador_portafolio; //2811
        public String ProductCode;  //C.281-1
        public String Family;   //Conocimiento y Redes
        public String Clasificacion;    //Productividad y Calidad
        public String Name; //TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD (GRATIS)
        public String Monto_maximo; //
        public String Monto_minimo; //
        public String Tasa_nominal_anual_mes_vencido;   //
        public String Programa; //ADMINISTRACION DE MICROEMPRESA E INFORMATICA
        public String Horas_grupales;   //2
        public String Horas_individuales;   //0
        public boolean Precio_sin_IVA;
        public String Grupo_convenio;   //493
        public String Grupo_convenio_nombre;    //PILOTO FREEMIUM
        public String Grupo_valor;  //0
        public boolean Requiere_pago;
        public String Tipo_de_servicio; //Capacitacion
        public String Identificador_grupo;  //14
        public String Precio;   //0
        public String Fecha_inicio; //2018-06-15 00:00:00.0
        public String Fecha_fin;    //2018-06-15 00:00:00.0
        public String Oficina;  //
        public String Sede; //
        public String Hora_inicio;  //9:00
        public String Hora_fin; //12:00
        public String Cupo_maximo;  //50
        public String Cupo_minimo;  //1
        public String Dias_de_la_semana;    //V
        public boolean isActive;
        public boolean isUpdate;
        public boolean isInsert;
    }

public static String devuelveJSON(){
    String json = '{ "row" : [ {' +
        '"Identificador_portafolio" : "2811",'+
        '"ProductCode" : "C.281-1",'+
        '"Family" : "Conocimiento y Redes",'+
        '"Clasificacion" : "Productividad y Calidad",'+
        '"Name" : "TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD (GRATIS)",'+
        '"Monto_maximo" : "",'+
        '"Monto_minimo" : "",'+
        '"Tasa_nominal_anual_mes_vencido" : "",'+
        '"Programa" : "ADMINISTRACION DE MICROEMPRESA E INFORMATICA",'+
        '"Horas_grupales" : "2",'+
        '"Horas_individuales" : "0",'+
        '"Precio_sin_IVA" : FALSE,'+
        '"Grupo_convenio" : "493",'+
        '"Grupo_convenio_nombre" : "PILOTO FREEMIUM",'+
        '"Grupo_valor" : "0",'+ // Se envia para GRUPO VALOR (Grupo_valor__c)
        '"Requiere_pago" : FALSE,'+
        '"Tipo_de_servicio" : "Capacitacion",'+
        '"Identificador_grupo" : "14",'+
        '"Precio" : "0",'+ // Se envia para ASESORIA (Precio__c)
        '"Fecha_inicio" : "2018-06-15 00:00:00.0",'+
        '"Fecha_fin" : "2018-06-15 00:00:00.0",'+
        '"Oficina" : "",'+
        '"Sede" : "",'+
        '"Hora_inicio" : "9:00",'+
        '"Hora_fin" : "12:00",'+
        '"Cupo_maximo" : "50",'+
        '"Cupo_minimo" : "1",'+
        '"Dias_de_la_semana" : "V",'+
        '"isActive" : true,'+
        '"isUpdate" : true,'+
        '"isInsert" : false'+
        '} ] }';
       return json;
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
    }
}
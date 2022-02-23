@isTest(SeeAllData=true)
public class IT_Portafolio_test {
    public IT_Portafolio_test() {    }


@isTest static void test1(){
    Test.StartTest();        
        // QuoteLineItem qli = [SELECT id	 FROM QuoteLineItem  LIMIT 1];
		// String myJSON = JSONinvoke();

        // RestRequest request = new RestRequest();
        // request.requestUri ='https://interactuar--qzcalidad.my.salesforce.com/services/apexrest/ITServicioPortafolioWS';        
        // request.httpMethod = 'GET';
		// request.requestBody = Blob.valueof(myJSON);		
        // RestContext.request = request;
		// IT_Portafolio_ws.doPost(); // clase que contiene el llamado al servicio
        Test.StopTest();
}

@isTest static void test2(){
    Test.StartTest();
    // List<Product2> lstProducto = new List<Product2>();
    // TestDataFactory factory = new TestDataFactory();
    // Product2 prod = factory.newProducto2();
    // lstProducto.add(prod);
    // IT_Portafolio_ws.creaEntradaCatalogoPrecios(lstProducto);

    Test.StopTest();
}

@isTest static void test3(){
    Test.StartTest();
    IT_Portafolio_ws.cls_Portafolio porta = new IT_Portafolio_ws.cls_Portafolio();
        porta.Identificador_portafolio ='2811';//2811
        porta.ProductCode = 'C.281-1';
        porta.Family ='Conocimiento y Redes';
        porta.Clasificacion ='Productividad y Calidad' ;    //Productividad y Calidad
        porta.Name  ='TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD (GRATIS)'; 
        porta.Monto_maximo = '10'; //
        porta.Monto_minimo = '1'; //
        porta.Tasa_nominal_anual_mes_vencido = '2';   //
        porta.Programa = 'ADMINISTRACION DE MICROEMPRESA E INFORMATICA'; //ADMINISTRACION DE MICROEMPRESA E INFORMATICA
        porta.Horas_grupales = '2';   //2
        porta.Horas_individuales = '1';   //0
        porta.Precio_sin_IVA = false;
        porta.Grupo_convenio = '493';   //493
        porta.Grupo_convenio_nombre = 'PILOTO FREEMIUM';   
        porta.Grupo_valor = '0';  //0
        porta.Requiere_pago = false;
        porta.Tipo_de_servicio = 'Capacitacion';
        porta.Identificador_grupo = '14';  //14
        porta.Precio = '50000';   //0
        porta.Fecha_inicio = null; //2018-06-15 00:00:00.0
        porta.Fecha_fin = null;    //2018-06-15 00:00:00.0
        porta.Oficina = null;  //
        porta.Sede = null; //
        porta.Hora_inicio = null;  //9:00
        porta.Hora_fin = null; //12:00
        porta.Cupo_maximo = '50';  //50
        porta.Cupo_minimo = '1';  //1
        porta.Dias_de_la_semana = 'V';    //V
        porta.isActive = true;
        porta.isUpdate = false;
        porta.isInsert = true;

    IT_Portafolio_ws.ingresaDatosProducto(porta,null);
    IT_Portafolio_ws.devuelveJSON();
    IT_Portafolio_ws.cobertura();
    Test.StopTest();
}

 public static String JSONinvoke(){
       String json = '{ "portafolio" : [ {' +
        '"Identificador_portafolio" : "2811",'+
        '"ProductCode" : "C.281-1",'+
        '"Family" : "Conocimiento y Redes",'+
        '"Clasificacion" : "Productividad y Calidad",'+
        '"Name" : "TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD",'+
        '"Monto_maximo" : "",'+
        '"Monto_minimo" : "",'+
        '"Tasa_nominal_anual_mes_vencido" : "",'+
        '"Programa" : "ADMINISTRACION DE MICROEMPRESA E INFORMATICA",'+
        '"Horas_grupales" : "2",'+
        '"Horas_individuales" : "0",'+
        '"Precio_sin_IVA" : false,'+
        '"Grupo_convenio" : "493",'+
        '"Grupo_convenio_nombre" : "PILOTO FREEMIUM",'+
        '"Grupo_valor" : "0",'+ // Se envia para GRUPO VALOR (Grupo_valor__c)
        '"Requiere_pago" : false,'+
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
}
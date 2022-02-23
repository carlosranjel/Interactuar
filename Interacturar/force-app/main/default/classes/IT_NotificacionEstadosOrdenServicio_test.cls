@isTest(SeeAllData=true)
public class IT_NotificacionEstadosOrdenServicio_test {
    
    @isTest
    static void teste(){
        Test.StartTest();
        IT_NotificacionEstadosOrdenServicio_WS myTest = new IT_NotificacionEstadosOrdenServicio_WS();
        
        Test.StopTest();
    } 
    
    /*
    public IT_NotificacionEstadosOrdenServicio_test() {
    }

    @isTest	static void test1(){
        Test.StartTest();
        IT_NotificacionEstadosOrdenServicio_WS.fromJSON obj = new IT_NotificacionEstadosOrdenServicio_WS.fromJSON();

        List<QuoteLineItem> qli = [SELECT id	 FROM QuoteLineItem  LIMIT 1];
        String myJSON = '';
        // QuoteLineItem qo = new QuoteLineItem();
        // qo.product2id = [SELECT Id FROM Product2 LIMIT 1].id;
        // qo.Quantity  = 0;
        // qo.QuoteId = [SELECT id FROM Quote LIMIT 1].Id;
        // qo.PricebookEntryId = null;     
        // qo.UnitPrice = 5000;
        // insert qo;
        if(qli.size() > 0)
        myJSON =  JSONinvoke(qli.get(0)); 

        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadosOrdenServicios';        
        request.httpMethod = 'GET';
        if(qli.size() > 0)
	request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        if(qli.size() > 0)
	IT_NotificacionEstadosOrdenServicio_WS.doPost(); // clase que contiene el llamado al servicio
        IT_NotificacionEstadosOrdenServicio_WS.cobertura(); 
        Test.StopTest();
    }

    public static String JSONinvoke(QuoteLineItem qli ){
        String json = ' '+
            ' {'+
                 '"idConsecutivo" : "875847",'+
                 '"propietario" : "Tomas",'+
                 '"radicado" : "4356",'+
                 '"estado" : "Matriculado",'+
                 '"tipoProducto" : "tipo",'+
                 '"productos" :  {'+
                       '"credito" : {'+
                            '"informacionGeneral" : {'+
                                    '"codigoProductoSalesforce" : "'+qli.id+'",'+
                                    '"codigoProductoOracle" : "43rerer",'+
                                    '"nombreProducto" : "nombre de producto",'+
                                    '"numero" : "24343",'+
                                    '"montoDesembolsado" : 50,'+
                                    '"fechaDesembolso" : "30/06/2019 00:00:00.000",'+
                                    '"plazo" : 12,'+
                                    '"porcentajeAvanceCuotas" : 0.12,'+
                                    '"proximoPago" : {'+
                                            '"valor" : 20,'+
                                            '"fecha" : "'+System.now().addMonths(5)+'"'+
                                    '},'+
                                    '"saldoCancelacionTotal" : 2,'+
                                    '"mora" : {'+
                                            '"dias" : 20,'+
                                            '"valor" : 30'+
                                    '},'+
                                    '"fechaCancelacion" : "'+System.now().addMonths(5)+'",'+
                                    '"calificacion" : "0.12"'+
                            '},'+
                            '"pago" : {'+
                                    '"id" : "3223",'+
                                    '"fechaPago" : "01/08/2019 12:13:00.000",'+
                                    '"monto" : 14'+
                            '},'+
                            '"estadoCartera" : {'+
                                    '"fechaLlamada" : "'+System.now().addMonths(2)+'",'+
                                    '"tipoGestion" : "x",'+
                                    '"contacto" : "no tiene",'+
                                    '"efectivo" : true,'+
                                    '"usuario" : "usuario",'+
                                    '"acuerdo" : {'+
                                            '"fecha" : "'+System.now().addMonths(5)+'",'+
                                            '"dia" : "LUNES",'+
                                            '"pagoMinimo" : 34,'+
                                            '"fechaSeguimiento" : "'+System.now().addMonths(2)+'"'+
                                    '}'+
                            '}'+
                       '},'+
                       '"asesoria" : {'+
                            '"nombreProducto" : "nom producto asesoria",'+
                            '"numeroFactura" : " 3345",'+
                            '"fechaFactura" : "'+System.now().addMonths(1)+'",'+
                            '"fechaMatricula" : "'+System.now().addMonths(1)+'"'+
                       '},'+
                       '"capacitacion" : {'+
                            '"nombreProducto" : "nom producto capacitacion",'+
                            '"numeroFactura" : "56577",'+
                            '"fechaFactura" : "'+System.now().addMonths(1)+'",'+
                            '"fechaMatricula" : "'+System.now().addMonths(1)+'"'+
                       '} } }';
            return json;
    }
*/
}
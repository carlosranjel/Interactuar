@isTest(seeAllData=true)
global class IT_ServicioEstadoCarteraDemanda_Test {
    global IT_ServicioEstadoCarteraDemanda_Test() {  }

    @isTest static void testServicioEstadoCarteraDemanda(){
        Test.setMock(HttpCalloutMock.class, new IT_ServicioEstadoCarteraDemanda_WS_Test_Mock()); 
        IT_ServicioEstadoCarteraDemanda_WS obj = new IT_ServicioEstadoCarteraDemanda_WS();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Asset assetTest = (Asset)dataFact.createObject('ASSET');         
        List<String> lstValor = new List<String>();
        String valor = assetTest.Id;
        lstValor.add(valor);
        
        Test.startTest();
        IT_ServicioEstadoCarteraDemanda_WS.respuestaServicio(lstValor);
        Test.stopTest();
        
    }

    /***********************************************************************************************
    *Author:   Alejandro Gómez
    *Function: Mock para simular la respuesta del servicio
    *Date:     20-04-2020
    ************************************************************************************************/
    global class IT_ServicioEstadoCarteraDemanda_WS_Test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            '{'+
            '"operacion": "Consulta Estado Cartera",'+
            '"respuesta": {'+
            '"estado": "OK",'+
            '"mensaje": "Consulta Correcta.",'+
            '"tipoExcepcion": 0'+
            '},'+
            '"productos": {'+
            '"credito": {'+
            '"numero": "98989898",'+
            '"montoDesembolsado": 121300,'+
            '"estado": "Activo",'+
            '"fechaDesembolso": "2020-01-07 09:26:58",'+
            '"plazo": 12,'+
            '"fechaCancelacion": "2020-01-07 09:26:58",'+
            '"calificacion": "CREDITO NORMAL",'+
            '"ultimoPago": {'+
            '"valor": 123134234,'+
            '"fecha": "2020-01-07 09:26:58"'+
            '},'+
            '"estadoCartera": {'+
            '"avanceCuotas": 12,'+
            '"cuotasRestantes": 12,'+
            '"saldoCancelacionTotal": 90000,'+
            '"proximoPago": {'+
            '"valor": 123134234,'+
            '"fecha": "2020-01-07 09:26:58"'+
            '}'+
            '},'+
            '"mora": {'+
            '"dias": 30,'+
            '"valor": 12500,'+
            '"proyeccionFecha": "2020-01-07 09:26:58",'+
            '"proyeccionesPago": ['+
            '{'+
            '"orden": 1,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 2,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 3,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 4,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 5,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 6,'+
            '"valor": 12345'+
            '}]}}}}'
                        );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
    }
}
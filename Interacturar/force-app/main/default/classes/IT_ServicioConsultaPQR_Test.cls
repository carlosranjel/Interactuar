@isTest(seeAllData=false)
global class IT_ServicioConsultaPQR_Test {
    global IT_ServicioConsultaPQR_Test() {  }

    @isTest static void testServicioConsultaPQR(){
        Test.setMock(HttpCalloutMock.class, new IT_ServicioConsultaPQR_Test_Mock()); 
        IT_ServicioConsultaPQR_WS obj = new IT_ServicioConsultaPQR_WS();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Account accountTest = (Account)dataFact.createObject('ACCOUNT');         
        //List<String> lstValor = new List<String>();
        String valor = accountTest.Id;
        //lstValor.add(valor);
        Test.startTest();
        IT_ServicioConsultaPQR_WS.servicioConsultaPQR(accountTest.Id);
        Test.stopTest();
    }

    /***********************************************************************************************
    *Author:   Alejandro Gómez
    *Function: Mock para simular la respuesta del servicio
    *Date:     20-04-2020
    ************************************************************************************************/
    global class IT_ServicioConsultaPQR_Test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody( 
            '{'+
            '"operacion": "Consulta PQR",'+
            '"respuesta": {'+
            '"estado": "OK",'+
            '"mensaje": "",'+
            '"tipoExcepcion": 0'+
            '},'+
            '"pqrs": ['+
            '{'+
            '"fecha": "'+(System.now()).addDays(-25)+'",'+
            '"tipo": "Quejas",'+
            '"descripcion": "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!",'+
            '"estado": "Resuelta"'+
            '},'+
            '{'+
            '"fecha": "'+(System.now()).addDays(-20)+'",'+
            '"tipo": "Quejas",'+
            '"descripcion": "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!",'+
            '"estado": "Resuelta"'+
            '},'+
            '{'+
            '"fecha": "'+(System.now()).addDays(-15)+'",'+
            '"tipo": "Quejas",'+
            '"descripcion": "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!",'+
            '"estado": "Resuelta"'+
            '},'+
            '{'+
            '"fecha": "'+(System.now()).addDays(-10)+'",'+
            '"tipo": "Quejas",'+
            '"descripcion": "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!",'+
            '"estado": "Resuelta"'+
            '},'+
            '{'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"tipo": "Quejas",'+
            '"descripcion": "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequuntur est ullam facere commodi necessitatibus inventore excepturi, amet nobis ut, quas blanditiis minus ea nisi pariatur ipsam? Ex facilis quae ad!",'+
            '"estado": "Resuelta"'+
            '}]}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
    }
    }
}
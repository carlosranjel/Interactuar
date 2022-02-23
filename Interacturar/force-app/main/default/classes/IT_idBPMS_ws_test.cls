@isTest(seeAllData=true)
global class IT_idBPMS_ws_test {
    @isTest static void testServicioIdBPMSLead(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_idBPMS_ws_test_Mock()); 
        IT_idBPMS_ws obj = new IT_idBPMS_ws();   
        Lead leadTest = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c FROM Lead Where IsConverted = false 
        order by createddate desc LIMIT 1 ];
        IT_idBPMS_ws.servicioIdBPMS(leadTest.Id);
        List<String> lstValor = new List<String>();
        String var = 'IdBPMS' +','+ leadTest.Id;
        lstValor.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor);
    Test.stopTest();
    }

    @isTest static void testServicioIdBPMSOpp(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_idBPMS_ws_test_Mock());
        IT_idBPMS_ws obj = new IT_idBPMS_ws();
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c FROM Opportunity 
        order by createddate desc LIMIT 1 ];
        IT_idBPMS_ws.servicioIdBPMS(oppTest.Id);
        List<String> lstValor = new List<String>();
        String var = 'IdBPMS' +','+ oppTest.Id;
        lstValor.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor);
        
        ConfirmacionServicios confirmando = new ConfirmacionServicios();
        List<String> lstValor2 = new List<String>();
        String var2 = '' +','+ oppTest.Id;
        lstValor2.add(var2);
        ConfirmacionServicios.validaEjecucion(lstValor2);
    Test.stopTest();
    }

   /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     4-12-2019
    ************************************************************************************************/
    global class IT_idBPMS_ws_test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            
'{'+
  '"encabezado":{'+
    '"estado":"0",'+
    '"excepcion":"",'+
    '"fecha":"2020-02-07T09:26:54",'+
    '"identificador":"00Q1Y00001u1wkxUAA-858",'+
    '"mensaje":"",'+
    '"integracion":"Iniciar Proceso idBPMS",'+
    '"operacion":"1",'+
    '"origen":"SALESFORCE",'+
    '"destino":"BPMS"'+
  '},'+
  '"cuerpo":{'+
    '"respuesta":{'+
      '"error":"FALSE",'+
      '"mensaje":"Nuevo proceso instanciado correctamente",'+
      '"idProceso":"241928"'+
    '}}}'
        
        );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}
}
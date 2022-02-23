@isTest(seeAllData=true)
global class IT_ServicioDataCredito_test {
    global IT_ServicioDataCredito_test() {  }

    @isTest static void testServicioDataCreditoLead(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock()); 
        IT_ServicioDataCredito_ws.cobertura();
        IT_ServicioDataCredito_ws obj = new IT_ServicioDataCredito_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();   
        Lead leadTest = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c, Fecha_consulta_Datacredito__c FROM Lead Where IsConverted = false 
        and Identificador_proceso__c != null order by createddate asc LIMIT 1 ];
        List<String> lstValor = new List<String>();
        String valor = leadTest.Id;
        lstValor.add(valor);
        IT_ServicioDataCredito_ws.servicioGeneraPDF(lstValor);
        List<String> lstValor2 = new List<String>();
        String var = 'Datacredito' +','+ leadTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);
        //IT_ServicioDataCredito_ws.servicioDataCreditoProspecto(leadTest.Id);
    Test.stopTest();
    }

    @isTest static void testServicioDataCreditoOpp(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock());
        IT_GenerarPDF_ws obj = new IT_GenerarPDF_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();
                IT_ServicioDataCredito_ws.cobertura();

        Lead leadTest = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c, Fecha_consulta_Datacredito__c FROM Lead Where IsConverted = false 
        and Identificador_proceso__c != null order by createddate asc LIMIT 1 ];
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c, Fecha_consulta_Datacredito__c FROM Opportunity 
        where Identificador_proceso__c != null order by createddate asc LIMIT 1 ];
        //IT_ServicioDataCredito_ws.servicioDataCreditoOpp(oppTest.Id);
        List<String> lstValor = new List<String>();
        String valor = oppTest.Id;
        lstValor.add(valor);
        IT_ServicioDataCredito_ws.servicioGeneraPDF(lstValor);
        List<String> lstValor2 = new List<String>();
        String var = 'Datacredito' +','+ oppTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);
        IT_ServicioDataCredito_ws.servicioDataCreditoCon(leadTest.Id,oppTest.Id);
    Test.stopTest();
    }
    
    @isTest static void testServicioDataCreditoCon(){
        Test.startTest();
                IT_ServicioDataCredito_ws.cobertura();

        Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock());
        IT_GenerarPDF_ws obj = new IT_GenerarPDF_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Opportunity oppTest = (Opportunity)dataFact.createObject('OPPORTUNITY');         
        Contact conTest = (Contact)dataFact.createObject('CONTACT');         
        //IT_ServicioDataCredito_ws.servicioDataCreditoCon(conTest.Id, oppTest.Identificador_proceso__c);
        List<String> lstValor = new List<String>();
       /* String valor = conTest.Id+','+oppTest.Identificador_proceso__c;
        lstValor.add(valor);
        IT_ServicioDataCredito_ws.servicioGeneraPDF(lstValor);
        List<String> lstValor2 = new List<String>();
        String var = 'Datacredito' +','+ conTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);*/
        Test.stopTest();
    }
    
       /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     4-12-2019
    ************************************************************************************************/
    global class IT_ServicioDataCredito_ws_test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            '{'+
            '"encabezado":{'+
            '"estado":"0",'+
            '"excepcion":"",'+
            '"fecha":"2020-01-07 09:26:58",'+
            '"identificador":"001e000001TbR87AAF-641",'+
            '"mensaje":"",'+
            '"integracion":"Consulta Datacredito Con BPMS",'+
            '"operacion":"1",'+
            '"origen":"ORACLE",'+
            '"destino":"SALESFORCE"'+
            '},'+
            '"cuerpo":{'+
            '"identificacion":"71794224",'+
            '"primerApellido":"Gomezs",'+
            '"primerNombre":"Mauricios",'+
            '"tipoIdentificacion":"C",'+
            '"idProceso":"241928",'+
            '"urlPdf":"",'+
            '"xmlDatacredito" : ""'+
            '}}'
                        
                        );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
    }
}
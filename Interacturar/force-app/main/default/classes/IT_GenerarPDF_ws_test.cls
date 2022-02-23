@isTest(seeAllData=true)
global with sharing class IT_GenerarPDF_ws_test {
    global IT_GenerarPDF_ws_test() {
    }


    @isTest static void testServicioGenerarPDFLead(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_GenerarPDF_ws_test_Mock()); 
        IT_GenerarPDF_ws obj = new IT_GenerarPDF_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();   
        Lead leadTest = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c FROM Lead Where IsConverted = false 
        and Identificador_proceso__c != null order by createddate desc LIMIT 1 ];
        //IT_GenerarPDF_ws.servicioGeneraPDF(leadTest.Id);
        List<String> lstValor = new List<String>();
        String valor = leadTest.Id;
        lstValor.add(valor);
        IT_GenerarPDF_ws.servicioGeneraPDF(lstValor);
        
        List<String> lstValor2 = new List<String>();
        String var = 'Historico' +','+ leadTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);
        IT_GenerarPDF_ws.consultaCon(leadTest.Id);
    Test.stopTest();
    }

    @isTest static void testServicioGenerarPDFOpp(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_GenerarPDF_ws_test_Mock());
        IT_GenerarPDF_ws obj = new IT_GenerarPDF_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();
        Lead leadTest = [SELECT Id, Tipo_de_identificacion__c, Numero_de_identificacion__c, LastName, FirstName, Name, Segundo_Apellido__c,
        MiddleName, Correo_asignacion__c, Nombre_de_usuario__c,Identificador_proceso__c FROM Lead Where IsConverted = false 
        and Identificador_proceso__c != null order by createddate desc LIMIT 1 ];
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c FROM Opportunity where Identificador_proceso__c != null 
        order by createddate desc LIMIT 1 ];
        //IT_GenerarPDF_ws.servicioGeneraPDF(oppTest.Id);
        List<String> lstValor = new List<String>();
        String valor = oppTest.Id;
        lstValor.add(valor);
        IT_GenerarPDF_ws.servicioGeneraPDF(lstValor);
        List<String> lstValor2 = new List<String>();
        String var = 'Historico' +','+ oppTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);
        IT_GenerarPDF_ws.cuentaDeTitular(oppTest.Id);
        IT_GenerarPDF_ws.inicioServicioGeneraPDFCon(leadTest.Id,oppTest.Id);
    Test.stopTest();
    }
    
    @isTest static void testServicioDataCreditoCon(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_GenerarPDF_ws_test_Mock());
        IT_GenerarPDF_ws obj = new IT_GenerarPDF_ws();
        IT_idBPMS_ws objid = new IT_idBPMS_ws();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Opportunity oppTest = (Opportunity)dataFact.createObject('OPPORTUNITY');         
        Contact conTest = (Contact)dataFact.createObject('CONTACT');         
        //IT_ServicioDataCredito_ws.servicioDataCreditoCon(conTest.Id, oppTest.Identificador_proceso__c);
        List<String> lstValor = new List<String>();
        /*String valor = conTest.Id+','+oppTest.Identificador_proceso__c;
        lstValor.add(valor);
        IT_GenerarPDF_ws.servicioGeneraPDF(lstValor);
        
        List<String> lstValor2 = new List<String>();
        String var = 'Historico' +','+ conTest.Id;
        lstValor2.add(var);
        ConfirmacionServicios.validaEjecucion(lstValor2);*/
        Test.stopTest();
    }

       /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     4-12-2019
    ************************************************************************************************/
    global class IT_GenerarPDF_ws_test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        /*response.setBody('{'+
                            '"error": "FALSE",'+
                            '"mensaje": "Documento generado con éxito",'+
                            '"url": "http://BPMS:8080/documento/file.pdf</url>"'+
                            '}');*/
        response.setBody('{'+
                          '"encabezado": {'+
                            '"estado": 0,'+
                            '"excepcion": null,'+
                            '"fecha": "0001-01-01T00:00:00",'+
                            '"identificador": "00000000-0000-0000-0000-000000000000",'+
                            '"mensaje": null,'+
                            '"integracion": "Generar PDF BPMS",'+
                            '"operacion": 0,'+
                            '"origen": "SALESFORCE",'+
                            '"destino": "BPMS"'+
                          '},'+
                          '"cuerpo": {'+
                            '"infoGeneral": {'+
                              '"productoId": "",'+
                              '"requestId": "1122121212121212121",'+
                              '"tipo": "GENERARPDF",'+
                              '"creadoPor": "GLORIARA",'+
                              '"fecha": "2020-02-08 19:14:07",'+
                              '"origen": "SALESFORCE"'+
                            '},'+
                '"configReporte": {'+
                  '"nombreReporte": "RCOHICRCL",'+
                  '"parametros": ['+
                    '{'+
                     '"clave": "NRORADICADO",'+
                      '"valor": "532345",'+
                      '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "OFICINA",'+
                      '"valor": "11",'+
                      '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "PTIPOID",'+
                      '"valor": "Cedula de Ciudadania",'+
                      '"destino": "shell"'+
                    '},'+
                    '{'+
                      '"clave": "TIPOID",'+
                      '"valor": "Cedula de Ciudadania",'+
                     '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "PIDENT",'+
                      '"valor": "71492075",'+
                      '"destino": "shell"'+
                    '},'+
                    '{'+
                      '"clave": "NROID",'+
                      '"valor": "71492075",'+
                      '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "P_USUARIO",'+
                      '"valor": "joseph",'+
                      '"destino": "shell"'+
                    '},'+
                    '{'+
                      '"clave": "USUARIOSOLICITANTE",'+
                      '"valor": "joseph",'+
                      '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "FECHA",'+
                      '"valor": "2020-02-08 19:14:07",'+
                      '"destino": "BPMS"'+
                    '},'+
                    '{'+
                      '"clave": "IDPROCESO",'+
                      '"valor": "241892",'+
                      '"destino": "BPMS"'+
                    '}'+
                  '],'+
                '"data": "xml"'+
    			'}}}');
        response.setStatusCode(200);
        response.setStatus('ok');
        return response;
    }
    }
}
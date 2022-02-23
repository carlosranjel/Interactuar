@isTest(SeeAllData=true)
global class IT_AutoDataCreditoOportunidad_tst {
    @isTest	static void testAll(){
        IT_AutoDataCreditoOportunidad_cls.cobertura();
        List<Quote> cotizaciones = [select Id, OpportunityId
                           from Quote
                           where Opportunity.StageName = 'En Estudio' and Opportunity.Identificador_proceso__c = null
                           limit 10];
        
        List<CampaignMember> mens = [select Id, Name, Producto__c, Monto__c, Plazo_Meses__c, Fondo__c
                             from CampaignMember
                             where Producto__c != null and Monto__c != null and Plazo_Meses__c != null and Fondo__c != null
                             limit 10];
               
        Test.StartTest();
        
        Quote cotizacion = cotizaciones[0];
        CampaignMember men = mens[0]; 
        
        IT_AutoDataCreditoOportunidad_cls nextJob1 = new IT_AutoDataCreditoOportunidad_cls('inicio', cotizacion.OpportunityId, men);
        Test.setMock(HttpCalloutMock.class, new IT_idBPMS_ws_test_Mock()); 
        nextJob1.execute(null);
        
        IT_AutoDataCreditoOportunidad_cls nextJob2 = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionDataCredito', cotizacion.OpportunityId, men);
        Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock()); 
        System.enqueueJob(nextJob2);
        
        IT_AutoDataCreditoOportunidad_cls nextJob3 = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionHistorico', cotizacion.OpportunityId, new IT_AutoDataCreditoOportunidad_cls.Respuesta('',''), men);
        System.enqueueJob(nextJob3);
        
        IT_AutoDataCreditoOportunidad_cls nextJob4 = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionHistorico', cotizacion.OpportunityId, cotizacion.Id, men);
        
        //IT_AutoDataCreditoOportunidad_cls nextJob4 = new IT_AutoDataCreditoOportunidad_cls(null, null, null, );
        
        Test.StopTest();
        
    }
    @isTest	static void testAll2(){
        
        List<Quote> cotizaciones = [select Id, OpportunityId
                           from Quote
                           where Opportunity.StageName = 'En Estudio' and Opportunity.Identificador_proceso__c = null
                           limit 10];
        
        List<CampaignMember> mens = [select Id, Name, Producto__c, Monto__c, Plazo_Meses__c, Fondo__c
                             from CampaignMember
                             where Producto__c != null and Monto__c != null and Plazo_Meses__c != null and Fondo__c != null
                             limit 10];
        
        Quote cotizacion = cotizaciones[0];
        CampaignMember men = mens[0]; 
            
        Test.StartTest();
        
        IT_AutoDataCreditoOportunidad_cls nextJob11 = new IT_AutoDataCreditoOportunidad_cls('inicio', cotizacion.OpportunityId, men);
        Test.setMock(HttpCalloutMock.class, new IT_idBPMS_ws_testError_Mock()); 
        nextJob11.execute(null);
        
        Test.StopTest();
        
    }
    
    @isTest	static void testAll3(){
        
        List<Quote> cotizaciones = [select Id, OpportunityId
                           from Quote
                           where Opportunity.StageName = 'En Estudio' and Opportunity.Identificador_proceso__c = null
                           limit 10];
        
        List<CampaignMember> mens = [select Id, Name, Producto__c, Monto__c, Plazo_Meses__c, Fondo__c
                             from CampaignMember
                             where Producto__c != null and Monto__c != null and Plazo_Meses__c != null and Fondo__c != null
                             limit 10];
            
        Test.StartTest();
        
        Quote cotizacion = cotizaciones[0];
        CampaignMember men = mens[0]; 
        
        IT_AutoDataCreditoOportunidad_cls nextJob1 = new IT_AutoDataCreditoOportunidad_cls('inicio', cotizacion.OpportunityId, men);
        Test.setMock(HttpCalloutMock.class, new IT_idBPMS_ws_test_Mock()); 
        nextJob1.execute(null);
        
        IT_AutoDataCreditoOportunidad_cls nextJob2 = new IT_AutoDataCreditoOportunidad_cls('validaEjecucionDataCredito', cotizacion.OpportunityId, men);
        Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_testError_Mock()); 
        System.enqueueJob(nextJob2);
        
        Test.StopTest();
        
    }
    
    global class IT_idBPMS_ws_testError_Mock implements HttpCalloutMock{   
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
            response.setStatusCode(400);
            response.setStatus('KO');
            return response; 
        }
    }
    
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
    
    global class IT_ServicioDataCredito_ws_testError_Mock implements HttpCalloutMock{   
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
            response.setStatusCode(400);
            response.setStatus('KO');
            return response; 
        }
    }
    
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
@isTest(seeAllData=true)
public class IT_ModeloScore_clsTest {
    
    @isTest static void testAll(){
        it_modeloscore_cls.cobertura();
        List<QuoteLineItem> prodList = [select Id, Product2.ProductCode, Quantity, UnitPrice, Plazo_meses__c, Periodo_Gracias_Meses__c, QuoteId
                                       from QuoteLineItem
                                       where Quote.Account.Estado_civil__pc != null and Score__c = null and Identificador_Radicado_OR__c = null
                                       limit 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_Mock());
        IT_ModeloScore_cls.consultaScore(prodList[0].QuoteId, prodList[0]);
        
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_ErrorMock());
        IT_ModeloScore_cls.consultaScore(prodList[0].QuoteId, prodList[0]);
        
        prodList = [select Id, Product2.ProductCode, Quantity, UnitPrice, Plazo_meses__c, Periodo_Gracias_Meses__c, QuoteId
                                       from QuoteLineItem
                                       where Quote.Account.Estado_civil__pc = null and Score__c = null and Identificador_Radicado_OR__c = null
                                       limit 1];
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_Mock());
        IT_ModeloScore_cls.consultaScore(prodList[0].QuoteId, prodList[0]);
        
        prodList = [select Id, Product2.ProductCode, Quantity, UnitPrice, Plazo_meses__c, Periodo_Gracias_Meses__c, QuoteId
                                       from QuoteLineItem
                                       where Quote.Account.Estado_civil__pc != null and Score__c = null and Identificador_Radicado_OR__c = null and 
                                       Quote.Opportunity.Famiempresa_relacionada__r.Numero_de_empleados__c = null
                                       limit 1];
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_Mock());
        IT_ModeloScore_cls.consultaScore(prodList[0].QuoteId, prodList[0]);
        
        Test.stopTest();
    }
    
    public class IT_ModeloScore_clsTest_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"encabezado":{"integracion":"Consulta Score Masivo","fecha":"2021-04-27 14:55:19","estado":"0","excepcion":"","origen":"SALESFORCE","operacion":"0","mensaje":{"descripcion":"Consulta del score, exitosamente!","estado":"OK"},"destino":"ORACLE","identificador":"0Q0m0000000Mqh8CAC-10795"},"cuerpo":{"descripcion":"PRE-RECHAZADO","score":"675","parametrosRecibidos":{"tipoVivienda":"Propia","periodoGracia":0,"industriaEmpresa":"1","numeroEmpleados":3,"tipoIdentificacion":"Cedula de Ciudadania","numeroIdentificacion":"6497653","codigoAsesor":"1080","estadoCivil":"Soltero","producto":"501","plazoSolicitado":"12","edadDesembolso":"28","experienciaEmpresa":0.4,"oficina":"11","personasACargo":2,"sexo":"Masculino","montoSolicitado":"2000000","numeroRadicado":null,"cabezaFamilia":false},"parametrosComplementarios":{"tipoConsulta":"1"}}}'                           
            );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }
    
    public class IT_ModeloScore_clsTest_ErrorMock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"encabezado":{"integracion":"Consulta Score Masivo","fecha":"2021-04-27 14:55:19","estados":"0","excepcion":"","origen":"SALESFORCE","operacion":"0","mensaje":{"descripcion":"Consulta del score, exitosamente!","estado":"OK"},"destino":"ORACLE","identificador":"0Q0m0000000Mqh8CAC-10795"},"cuerpo":{"descripcion":"PRE-RECHAZADO","score":"675","parametrosRecibidos":{"tipoVivienda":"Propia","periodoGracia":0,"industriaEmpresa":"1","numeroEmpleados":3,"tipoIdentificacion":"Cedula de Ciudadania","numeroIdentificacion":"6497653","codigoAsesor":"1080","estadoCivil":"Soltero","producto":"501","plazoSolicitado":"12","edadDesembolso":"28","experienciaEmpresa":0.4,"oficina":"11","personasACargo":2,"sexo":"Masculino","montoSolicitado":"2000000","numeroRadicado":null,"cabezaFamilia":false},"parametrosComplementarios":{"tipoConsulta":"1"}}}'                           
            );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }

}
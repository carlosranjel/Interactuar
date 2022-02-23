@isTest(SeeAllData=true)
global class IT_AutoConsultaScore_tst {
    @isTest	static void test1(){
        it_autoconsultascore_cls.cobertura();
        List<Opportunity> newOppors = [select Id, Respuesta_Oportunidad__c, AccountId, (select Id from Quotes)
                             from Opportunity
                             where StageName = 'En Estudio' and Identificador_proceso__c != null and RecordType.DeveloperName = 'Solicitud_de_credito'
                             limit 200];
        Opportunity newOpp;
        for(Opportunity opp: newOppors){
            if(opp.Quotes.size() > 0 && opp.Respuesta_Oportunidad__c != null && String.valueOf(opp.Respuesta_Oportunidad__c).contains('OK')){
                newOpp = opp;
                break;
            }
        }
        
        Quote cotizacion = [select Id, (select Id, UnitPrice, Product2.ProductCode, Quantity, Plazo_meses__c, Periodo_Gracias_Meses__c from QuoteLineItems)
                           from Quote
                           where OpportunityId =:newOpp.Id
                           limit 1];
        
        CampaignMember men = [select Id, Name,Tipo_de_Respuesta__c,Medio_de_Respuesta__c
                             from CampaignMember
                             limit 1];
               
        Test.StartTest();
        
        IT_AutoConsultaScore_cls nextJob1 = new IT_AutoConsultaScore_cls(cotizacion.Id, cotizacion.QuoteLineItems[0], men);
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_Mock());
        nextJob1.execute(null);
        
        Test.StopTest();
    }
    
    @isTest	static void test2(){
        List<Opportunity> newOppors = [select Id, Respuesta_Oportunidad__c, AccountId, (select Id from Quotes)
                             from Opportunity
                             where StageName = 'En Estudio' and Identificador_proceso__c != null and RecordType.DeveloperName = 'Solicitud_de_credito'
                             limit 200];
        Opportunity newOpp;
        for(Opportunity opp: newOppors){
            if(opp.Quotes.size() > 0 && opp.Respuesta_Oportunidad__c != null && String.valueOf(opp.Respuesta_Oportunidad__c).contains('OK')){
                newOpp = opp;
                break;
            }
        }
        
        Quote cotizacion = [select Id, (select Id, UnitPrice, Product2.ProductCode, Quantity, Plazo_meses__c, Periodo_Gracias_Meses__c from QuoteLineItems)
                           from Quote
                           where OpportunityId =:newOpp.Id
                           limit 1];
        
        CampaignMember men = [select Id, Name,Tipo_de_Respuesta__c,Medio_de_Respuesta__c
                             from CampaignMember
                             limit 1];
               
        Test.StartTest();
        
        IT_AutoConsultaScore_cls nextJob1 = new IT_AutoConsultaScore_cls(cotizacion.Id, cotizacion.QuoteLineItems[0], men);
        Test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsTest_ErrorMock());
        nextJob1.execute(null);
        
        Test.StopTest();
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
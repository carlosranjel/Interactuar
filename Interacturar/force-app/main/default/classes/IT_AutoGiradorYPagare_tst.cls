@isTest(SeeAllData=true)
global class IT_AutoGiradorYPagare_tst {
    @isTest	static void testAll(){
        List<Opportunity> newOppors = [select Id, Respuesta_Oportunidad__c, (select Id from Quotes)
                             from Opportunity
                             where StageName = 'En Estudio' and Identificador_proceso__c != null
                             order by Name desc
                             limit 200];
        Opportunity newOpp;
        for(Opportunity opp: newOppors){
            if(opp.Quotes != null && opp.Quotes.size() > 0 && opp.Respuesta_Oportunidad__c != null && String.valueOf(opp.Respuesta_Oportunidad__c).contains('OK')){
                newOpp = opp;
                break;
            }
        }
        
        Quote cotizacion = [select Id
                           from Quote
                           where OpportunityId =:newOpp.Id
                           limit 1];

        CampaignMember men = [select Id, Name
                             from CampaignMember
                             limit 1];
               
        Test.StartTest();

        IT_AutoGiradorYPagare_cls nextJob = new IT_AutoGiradorYPagare_cls('Inicio', newOpp.Id, men);
        Test.setMock(HttpCalloutMock.class, new IT_Girador_test_Mock()); 
        nextJob.execute(null);
        
        IT_AutoGiradorYPagare_cls nextJob2 = new IT_AutoGiradorYPagare_cls('Pagaré', newOpp.Id, cotizacion.Id, men);
        //Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock()); 
        System.enqueueJob(nextJob2);
        
        IT_AutoGiradorYPagare_cls nextJob3 = new IT_AutoGiradorYPagare_cls('OnCredit', newOpp.Id, cotizacion.Id, men);
        //Test.setMock(HttpCalloutMock.class, new IT_ServicioDataCredito_ws_test_Mock()); 
        System.enqueueJob(nextJob3);
        
        Opportunity newOppTest1;
        for(Opportunity opp: newOppors){
            if(opp.Quotes == null || opp.Quotes.size() == 0 ){
                newOppTest1 = opp;
                break;
            }
        }
        IT_AutoGiradorYPagare_cls nextJob_1 = new IT_AutoGiradorYPagare_cls('Inicio', newOppTest1.Id, men); 
        Test.setMock(HttpCalloutMock.class, new IT_Girador_test_Mock());
        nextJob_1.execute(null);
        
        newOpp = [select Id, Respuesta_Oportunidad__c, (select Id from Quotes)
                             from Opportunity
                             where StageName = 'Crédito Negado' and Identificador_proceso__c != null
                             order by Name desc
                             limit 1];
        IT_AutoGiradorYPagare_cls nextJob_2 = new IT_AutoGiradorYPagare_cls('Inicio', newOpp.Id, men);
        Test.setMock(HttpCalloutMock.class, new IT_Girador_test_Mock()); 
        nextJob_2.execute(null);
        
        
        Test.StopTest();
        
    }
    public class IT_Girador_test_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(
                    '{'+
                        '"response": {'+
                          '"solicitudCredito": {'+
                            '"radicado": 6546,'+
                            '"oficina": 1102,'+
                            '"idProceso": 258373'+
                          '},'+
                          '"encabezado": {'+
                            '"fecha": "2020-07-15T16:48:04",'+
                            '"usuario": "Rafael Cardona",'+
                            '"operacion": "CREACIONGIRADORES",'+
                            '"origen": "SALESFORCE",'+
                            '"destino": "DECEVAL",'+
                            '"mensaje": {'+
                              '"descripcion": "(SDL.SE.0000): El girador ya existe y se actualizo la informacion",'+
                              '"estado": "OK"'+
                            '}'+
                          '},'+
                          '"CreacionGiradoresCodificados": {'+
                            '"crearGiradorDTO": {'+
                              '"identificacionEmisor": 8909848433,'+
                              '"fkIdClasePersona": 1,'+
                              '"cuentaGirador": 224949,'+
                              '"fkIdTipoDocumento": 1,'+
                              '"nombresNat_Nat": "Paula",'+
                              '"numeroDocumento": 1023877810,'+
                              '"primerApellido_Nat": "Ardila",'+
                              '"mensajeRespuesta": "SDL.SE.0169: El girador ya existe y se actualizo la informacion"'+
                            '} } } }'
                    );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
            }
        }
}
@isTest(SeeAllData=true)
global class IT_AutoSincronizarCotizacion_tst {
    @isTest	static void testAll(){
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
        
        Quote cotizacion = [select Id
                           from Quote
                           where OpportunityId =:newOpp.Id
                           limit 1];
        
        CampaignMember men = [select Id, Name
                             from CampaignMember
                             limit 1];
               
        Test.StartTest();
        
        IT_AutoSincronizarCotizacion_cls nextJob1 = new IT_AutoSincronizarCotizacion_cls(cotizacion.Id, men);
        nextJob1.execute(null);
        
        newOpp.NomApe_Ben1__c = null;
        update newOpp;
        
        IT_AutoSincronizarCotizacion_cls nextJob2 = new IT_AutoSincronizarCotizacion_cls(cotizacion.Id, men);
        nextJob2.execute(null);
        
        
        //Clase sincronizar
        List<Id> lstIdCliente = new List<Id>{ newOpp.AccountId }; 
        List<Account> lstCliente  = IT_GestorDeConsultas_cls.consultaCuenta( lstIdCliente );
        IT_SincronizarCotizacion_ctr.validaCamposClienteJuridico(lstCliente[0]);
        
        IT_SincronizarCotizacion_ctr.detieneSincronizacion(cotizacion.Id);
        
        IT_AutoSincronizarCotizacion_cls.cobertura();
        
        Test.StopTest();
        
    }
}
@isTest(SeeAllData=True)
public class IT_MiembroCampania_test {

    @isTest	static void test1(){
        
        List<Opportunity> opps = [select Id, Name, CampaignId, AccountId, Account.PersonContactId, Account.IsPersonAccount
                                 from Opportunity
                                 where CampaignId != null and Account.IsPersonAccount = True
                                 limit 1];
        CampaignMember men = IT_MiembroCampania.buscaMiembroDeCampana(opps[0]);
        men.Fondo__c = '2';
        
        Test.StartTest();
        
        men = IT_MiembroCampania.buscaMiembroDeCampana(opps[0]);
        IT_MiembroCampania.consultaPorContacto(opps[0]);
        IT_MiembroCampania.oportunidadDeMiembroCampana(opps[0]);
        IT_MiembroCampania.actualizaOportunidad(opps[0], men);

        Test.StopTest();
    }
    
    @isTest	static void test2(){
        
        List<Opportunity> opps = [select Id, Name, CampaignId, AccountId, Account.PersonContactId, Account.IsPersonAccount
                                 from Opportunity
                                 where CampaignId != null and Account.IsPersonAccount = False
                                 limit 1];
        CampaignMember men = IT_MiembroCampania.buscaMiembroDeCampana(opps[0]);
        men.Fondo__c = '2';
        update men;
        
        Test.StartTest();
        
        men = IT_MiembroCampania.buscaMiembroDeCampana(opps[0]);
        IT_MiembroCampania.consultaPorContacto(opps[0]);
        IT_MiembroCampania.oportunidadDeMiembroCampana(opps[0]);
        IT_MiembroCampania.actualizaOportunidad(opps[0], men);

        Test.StopTest();
    }
}
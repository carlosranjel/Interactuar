@isTest(SeeAllData=false)
public class IT_TriggerContact_test {
    
    @isTest	static void testAll(){
        
        TestDataFactory TestDataFactoryT = new TestDataFactory();
        Famiempresa__c fam = TestDataFactoryT.newFamiempresa();

        Account acc = new Account();
        acc = TestDataFactoryT.newAccount();  
        acc.Consecutivo_Padre__c = '4s54a5s45a4s';
        update acc;
        
        Opportunity oport = createOpportunity(acc, fam);

        Test.StartTest();
        IT_ContactHandler_cls.cobertura();
        Contact con1 = new Contact();
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        con1.FirstName = 'Test';
        con1.MiddleName = 'Test';
        con1.LastName = 'test';
        con1.Segundo_Apellido__c = 'Test';
        con1.Genero__c = 'Femenino';
        con1.Oportunidad__c = oport.Id;
        con1.Nombres_Beneficiario__c = 'test';
        con1.Apellidos_Beneficiario__c = 'test';
        insert con1;
                
        con1.Nombres_Beneficiario__c = 'test test';
        update con1;

		delete con1;        
        
        Test.StopTest();
        
    }
    
    public static Opportunity createOpportunity(Account acc, Famiempresa__c fam){
        TestDataFactory TestDataFactoryT = new TestDataFactory();
        Opportunity oport = new Opportunity();
        oport.AccountId = acc.Id;
        oport.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Solicitud de Crédito').getRecordTypeId();
        oport.Name = 'Nombre Oportunidad';
        oport.StageName = 'En Estudio';
        oport.Famiempresa_relacionada__c = fam.Id;
        oport.CloseDate = Date.newInstance(2025,05,15);
        oport.Numero_idenBen1__c = '0123456789';
        oport.NomApe_Ben1__c = 'test';
        oport.ParentescoBen1__c = 'Madre';
        oport.Tipo_ideBen1__c = 'Cedula Ciudadania';
        oport.PorcentajeBen1__c = 100;
        oport.Persona_Publica__c = 'No';
        oport.Vinculo_con_Persona_Publica__c = 'No';
        insert oport;
        return oport;
    }

}
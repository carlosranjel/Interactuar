@isTest(SeeAllData=false)
public class IT_TriggerOpportunity_test {

    @isTest	static void test1(){
            Test.StartTest();

        IT_TriggerOpportunityHandler_cls.cobertura();
        it_triggeropportunityhelper_cls.cobertura();
        TestDataFactory TestDataFactoryT = new TestDataFactory();
        Famiempresa__c fam = TestDataFactoryT.newFamiempresa();

        Account acc = new Account();
        acc = TestDataFactoryT.newAccount();  
        acc.Consecutivo_Padre__c = '4s54a5s45a4s';
        update acc;

    
        
        Opportunity oport = createOpportunity(acc, fam);
        Contact cont3 = createContacts(oport);
        
        
        oport.Respuesta_Oportunidad__c = 'OK';
        update oport;
        

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
        insert oport;
        return oport;
    }

    public static Contact createContacts(Opportunity oport){
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

        Contact con2 = new Contact();
        con2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        con2.FirstName = 'Test';
        con2.MiddleName = 'Test';
        con2.LastName = 'test';
        con2.Segundo_Apellido__c = 'Test';
        con2.Genero__c = 'Femenino';
        con2.Oportunidad__c = oport.Id;
        con2.Nombres_Beneficiario__c = 'test';
        con2.Apellidos_Beneficiario__c = 'test';
        insert con2;

        Contact con3 = new Contact();
        con3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        con3.FirstName = 'Test';
        con3.MiddleName = 'Test';
        con3.LastName = 'test';
        con3.Segundo_Apellido__c = 'Test';
        con3.Oportunidad__c = oport.Id;
        con3.Nombres_Beneficiario__c = 'test';
        con3.Apellidos_Beneficiario__c = 'test';
        con3.Genero__c = 'Femenino';
        insert con3;

        return con3;
    }
}
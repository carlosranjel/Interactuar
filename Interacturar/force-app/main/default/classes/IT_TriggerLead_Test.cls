@isTest(seeAllData=true)
public class IT_TriggerLead_Test {
    @isTest public static void test1(){
        Test.startTest();
        IT_LeadHandler_cls obj = new IT_LeadHandler_cls();
        IT_LeadHandler_cls.cobertura();
        Lead objLead = new Lead(
        FirstName = 'algo',
        LastName = 'algo',
        Email = 'algo@algo.com',
        Movil_empresa__c = '3165698732',
        RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Persona_juridica').getRecordTypeId());
        insert objLead;
        
        objLead.FirstName = 'prueba';
        Update objLead;
        
    }
}
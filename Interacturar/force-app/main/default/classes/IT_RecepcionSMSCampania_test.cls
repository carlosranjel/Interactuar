@isTest(SeeAllData=false)
public class IT_RecepcionSMSCampania_test {

    @isTest	static void test1(){
        TestDataFactory TestDataFactoryT = new TestDataFactory();
        it_recepcionsmscampania_ws.cobertura();
        Campaign camp = new Campaign();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaña con beneficios').getRecordTypeId();
        camp.Status = 'En ejecución';
        camp.Type = 'Credito digital';
        camp.Name = 'test';
        camp.Publico_Objetivo__c = 'test';
        camp.Oficina_Servicio__c = 'Bello';
        camp.Equipo_Comercial_Oficinas_Equipo_Comerci__c = 'Todos';
        camp.Objetivo_de_la_campa_a__c = 'test';
        camp.Capital_impactado__c = 'Todos';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().AddDays(300);
        camp.ExpectedRevenue = 100;
        camp.Meta_en_N_de_creditos__c = 1;
        camp.Meta_en_monto_de_creditos__c = 2;
        camp.Meta_en_monto_de_servicios__c = 1;
        camp.Meta_en_N_de_servicios__c = 1;
        camp.N_de_creditos_desembolsados__c = 1;
        camp.N_de_personas_que_asisten__c = 10;
        camp.Monto_de_creditos_desembolsados__c = 1;
        camp.N_de_servicios_facturados__c = 1;
        camp.ActualCost = 10;
        camp.CodigoCorto__c = '123456789';
        camp.IsActive = true;
        insert camp;
        
        Account acc = new Account();
        acc = TestDataFactoryT.newAccountJuridica();  
        acc.Consecutivo_Padre__c = '4s54a5s45a4s';
        update acc;
        
        Contact con1 = new Contact();
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacto').getRecordTypeId();
        con1.FirstName = 'Test';
        con1.MiddleName = 'Test';
        con1.LastName = 'test';
        con1.Segundo_Apellido__c = 'Test';
        con1.Genero__c = 'Femenino';
        con1.AccountId = acc.Id;
        con1.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        con1.Numero_de_identificacion__c = '0123456789';
        insert con1;
        
        Test.StartTest();

        String myJSON = '{"Mobile": "3000000000", "Message": "No", "ShortCode": "123456789", "FechaDeRespuesta": "02/02/2020"}';
        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar--dev.lightning.force.com/services/apexrest/RecepcionSMSCampania';        
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        IT_RecepcionSMSCampania_WS.doPost();
        
        CampaignMember men = new CampaignMember();
        men.CampaignId = camp.Id;
        men.Status = 'Respondida';
        men.ContactId = con1.Id;
        men.MovilMiembro__c = '3000000000';
        insert men;
        
        myJSON = '{"Mobile": "3000000000", "Message": "No", "ShortCode": "123456789", "FechaDeRespuesta": "02/02/2020"}';
        request = new RestRequest();
        request.requestUri ='https://interactuar--dev.lightning.force.com/services/apexrest/RecepcionSMSCampania';        
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        IT_RecepcionSMSCampania_WS.doPost();
        
        
        myJSON = '{"Mobile": "3000000000", "Message": "No", "ShortCosdsde": "123456789", "FechaDeRespuesta": "02/02/2020"}';
        request = new RestRequest();
        request.requestUri ='https://interactuar--dev.lightning.force.com/services/apexrest/RecepcionSMSCampania';        
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        IT_RecepcionSMSCampania_WS.doPost();
        
        myJSON = '{"Mobile": "3000000000", "Message": "No", "ShortCode": "123456789"}';
        request = new RestRequest();
        request.requestUri ='https://interactuar--dev.lightning.force.com/services/apexrest/RecepcionSMSCampania';        
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        
        IT_RecepcionSMSCampania_WS.doPost();

        Test.StopTest();
    }
}
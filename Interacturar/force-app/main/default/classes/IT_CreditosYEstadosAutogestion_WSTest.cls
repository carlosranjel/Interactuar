@isTest(SeeAllData=True)
public class IT_CreditosYEstadosAutogestion_WSTest {
    @isTest
    static void testAll() {
        Test.startTest();
        IT_CreditosYEstadosAutogestion_WS.cobertura();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreditosYEstadosAutogestion'; //Request URL
        req.httpMethod = 'POST';
        
        List<Account> accs = [select Id, Tipo_de_identificacion__c, Numero_de_identificacion__c
                             from Account
                             where RecordType.developerName = 'Persona_natural' and Tipo_de_identificacion__c = 'Cedula de Ciudadania'
                             limit 3];
        
        //String postData= '{"encabezado":{"fecha":"2021-01-28 15:03:20","identificador":"006m000000CkVnRAAV-11155","integracion":"","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"},"creditosEstadosAutogestion":{"tipoDocumento":"Cedula de ciudadania","numeroDocumento":"15365843"}}';
        String postData = '{"encabezado":{"fecha":"2021-01-28 15:03:20","identificador":"006m000000CkVnRAAV-11155","integracion":"Créditos y estados autogestión","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"},"creditosEstadosAutogestion":{"tipoDocumento":"';
        postData += accs[0].Tipo_de_identificacion__c + '","numeroDocumento":"';
        postData += accs[0].Numero_de_identificacion__c + '"}}';
        String JsonMsg = JSON.serialize(postData);
        req.requestBody = Blob.valueof(postData);   
        
        RestContext.request = req;
        RestContext.response= res;
        
        IT_CreditosYEstadosAutogestion_WS.doPost();
        
        ///////
        List<CampaignMember> members = [Select Id, Contact.Account.Tipo_de_identificacion__c, Contact.Account.Numero_de_identificacion__c
                                        from CampaignMember
                                        where Campaign.Type = 'Credito digital' and ContactId != null and Fecha_de_Mensaje__c != null
                                        and Contact.Account.Tipo_de_identificacion__c != null and Contact.Account.Numero_de_identificacion__c != null
                                        and Producto__r.ProductCode != null
                                        order by Fecha_de_Mensaje__c
                                       limit 1];
        for(Integer i = 0; i < members.size(); i++){
            req = new RestRequest();
            res = new RestResponse();
            req.requestURI = '/services/apexrest/CreditosYEstadosAutogestion'; //Request URL
            req.httpMethod = 'POST';
            
            postData= '{"encabezado":{"fecha":"2021-01-28 15:03:20","identificador":"006m000000CkVnRAAV-11155","integracion":"Créditos y estados autogestión","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"},"creditosEstadosAutogestion":{"tipoDocumento":"' + members[i].Contact.Account.Tipo_de_identificacion__c + '","numeroDocumento":"' + members[i].Contact.Account.Numero_de_identificacion__c +'"}}';
            JsonMsg = JSON.serialize(postData);
            req.requestBody = Blob.valueof(postData);   
            
            RestContext.request = req;
            RestContext.response= res;
            
            IT_CreditosYEstadosAutogestion_WS.doPost();
        }
        
      //  IT_CreditosYEstadosAutogestion_WS.cobertura();
        Test.stopTest();
    }
}
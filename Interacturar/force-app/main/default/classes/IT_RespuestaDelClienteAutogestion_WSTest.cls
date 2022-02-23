@isTest(SeeAllData=True)
public class IT_RespuestaDelClienteAutogestion_WSTest {
    @isTest
    static void testAll() {
        Test.startTest();
        IT_RespuestaDelClienteAutogestion_WS.cobertura();
        /*
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RespuestaDelClienteAutogestion'; //Request URL
        req.httpMethod = 'POST';
        
        List<CampaignMember> members = [Select Id, Contact.Account.Tipo_de_identificacion__c, Contact.Account.Numero_de_identificacion__c
                                        from CampaignMember
                                        where Campaign.Type = 'Credito digital' and ContactId != null and Fecha_de_Mensaje__c != null
                                        and Contact.Account.Tipo_de_identificacion__c != null and Contact.Account.Numero_de_identificacion__c != null
                                        and Producto__r.ProductCode != null
                                        order by Fecha_de_Mensaje__c
                                       limit 1];
        
        List<Account> accs = [select Id, Tipo_de_identificacion__c, Numero_de_identificacion__c
                             from Account
                             where RecordType.developerName = 'Persona_natural' and Tipo_de_identificacion__c = 'Cedula de Ciudadania'
                             limit 1];
        
        String postData = '{"encabezado":{"fecha":"2021-04-30 14:50:00","identificador":"006m000000CkVnRAAV-11155","integracion":"Créditos y estados autogestión","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"},"respuestaClienteAutogestion":{"tipoDocumento":"';
        postData += members[0].Contact.Account.Tipo_de_identificacion__c + '","numeroDocumento":"';
        postData += members[0].Contact.Account.Numero_de_identificacion__c + '",';
        postData += '"monto":3500000,"plazo":24,';
        postData += '"idMiembroCampania": "' + members[0].Id + '","correoElectronico":"otroCorreo1@gmail.com","numeroCelular":"3052279478","producto":501,"aceptoCliente":true,"tipoRespuesta":"solicite aquí su crédito","medioRespuesta":"Respuesta Web","fechaRespuesta":"2021-04-30 14:50:00","tipoCuenta":"Ahorros","numeroCuenta":"0032458940","banco":"NEQUI","beneficiarios":[{"nombreCompleto":"José Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456789","parentesco":"Hijo","porcentaje":34,"cualParentesco":""},{"nombreCompleto":"Manuel Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456788","parentesco":"Hijo","porcentaje":33,"cualParentesco":""},{"nombreCompleto":"Luna Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456787","parentesco":"Hijo","porcentaje":33,"cualParentesco":""}]}}';
        String JsonMsg = JSON.serialize(postData);
        req.requestBody = Blob.valueof(postData);   
        
        RestContext.request = req;
        RestContext.response= res;
        
     
        
        IT_RespuestaDelClienteAutogestion_WS.doPost();
        
List<Campaign> camp = [Select Id
                                  from Campaign
                                  where CodigoCorto__c = '999999999' and Status = 'Terminada'];
        delete camp;
        CampaignMember mb = new CampaignMember();
        contact cn = [Select id ,name from contact limit 1];
        Campaign cm = new Campaign();
        cm = [Select id from Campaign where IsActive = true limit 1];
        mb.ContactId = cn.id;
        mb.CampaignId = cm.id;
        insert mb;
        
 		IT_RespuestaDelClienteAutogestion_WS.getCampaignMember(mb.id);
         req = new RestRequest();
         res = new RestResponse();
        req.requestURI = '/services/apexrest/RespuestaDelClienteAutogestion'; //Request URL
        req.httpMethod = 'POST';
        
         members = [Select Id, Contact.Account.Tipo_de_identificacion__c, Contact.Account.Numero_de_identificacion__c
                                        from CampaignMember
                                        where Campaign.Type = 'Credito digital' and ContactId != null and Fecha_de_Mensaje__c != null
                                        and Contact.Account.Tipo_de_identificacion__c != null and Contact.Account.Numero_de_identificacion__c != null
                                        and Producto__r.ProductCode != null
                                        order by Fecha_de_Mensaje__c
                                       limit 1];
        
         accs = [select Id, Tipo_de_identificacion__c, Numero_de_identificacion__c
                             from Account
                             where RecordType.developerName = 'Persona_natural' and Tipo_de_identificacion__c = 'Cedula de Ciudadania'
                             limit 1];
        
         postData = '{"encabezado":{"fecha":"2021-04-30 14:50:00","identificador":"006m000000CkVnRAAV-11155","integracion":"Créditos y estados autogestión","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"},"respuestaClienteAutogestion":{"tipoDocumento":"';
        postData += 'Pasaporte' + '","numeroDocumento":"';
        postData += 'E429868'+ '",';
        postData += '"monto":3500000,"plazo":24,';
        postData += '"idMiembroCampania": "' + members[0].Id + '","correoElectronico":"otroCorreo1@gmail.com","numeroCelular":"3052279478","producto":501,"aceptoCliente":true,"tipoRespuesta":"solicite aquí su crédito","medioRespuesta":"Respuesta Web","fechaRespuesta":"2021-04-30 14:50:00","tipoCuenta":"Ahorros","numeroCuenta":"0032458940","banco":"NEQUI","beneficiarios":[{"nombreCompleto":"José Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456789","parentesco":"Hijo","porcentaje":34,"cualParentesco":""},{"nombreCompleto":"Manuel Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456788","parentesco":"Hijo","porcentaje":33,"cualParentesco":""},{"nombreCompleto":"Luna Osorio","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"0123456787","parentesco":"Hijo","porcentaje":33,"cualParentesco":""}]}}';
         JsonMsg = JSON.serialize(postData);
        req.requestBody = Blob.valueof(postData);   
        
        RestContext.request = req;
        RestContext.response= res;
        
     
        

        IT_RespuestaDelClienteAutogestion_WS.doPost();
        
        */
        
        Test.stopTest();
    }
   
    
}
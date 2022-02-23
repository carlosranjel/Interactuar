@isTest
public class IT_ParametrosGeneralesAutogestion_WSTest {
    @isTest
    static void testAll() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ParametrosGeneralesAutogestion'; //Request URL
        req.httpMethod = 'POST';
        
        String postData= '{"encabezado":{"fecha":"2021-01-28 15:03:20","identificador":"006m000000CkVnRAAV-11155","integracion":"Parámetros generales Autogestión","operacion":"0","origen":"MICROSITIO CREDITO","destino":"SALESFORCE"}}';
        String JsonMsg = JSON.serialize(postData);
        req.requestBody = Blob.valueof(postData);   
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        IT_ParametrosGeneralesAutogestion_WS.doPost();
        Test.stopTest();
    }
}
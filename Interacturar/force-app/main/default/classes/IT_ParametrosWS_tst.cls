@isTest
global class IT_ParametrosWS_tst {
    @isTest	static void test1(){
               
        Test.StartTest();
        
        Test.setMock(HttpCalloutMock.class, new IT_ModelToken_clsTest_Mock());
        
        IT_ParametrosWS_cls.parametrosCliente();
        IT_ParametrosWS_cls.parametrosClienteAval('');
        IT_ParametrosWS_cls.parametrosInvitacionAfirma('');
        IT_ParametrosWS_cls.parametrosScore('');
        IT_ParametrosWS_cls.parametrosOportunidad('');
        IT_ParametrosWS_cls.parametrosDocumentacionBPMS();
        IT_ParametrosWS_cls.parametrosDataCredito('');
        IT_ParametrosWS_cls.parametrosIdBPMS('');
        IT_ParametrosWS_cls.parametrosDataCreditoDos('');
        IT_ParametrosWS_cls.parametrosGenerarPDF('');
        IT_ParametrosWS_cls.parametrosCobranza('');
        IT_ParametrosWS_cls.parametrosActivoDemanda('');
        IT_ParametrosWS_cls.parametrosGiradores('');
        IT_ParametrosWS_cls.parametrosPagares('');
        
        Test.StopTest();
    }
    
    public class IT_ModelToken_clsTest_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('uyghbfdsuifhaksdnfkjahdsfuial');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }
    
}
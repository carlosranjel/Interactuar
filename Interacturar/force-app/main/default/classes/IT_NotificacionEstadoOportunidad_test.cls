@isTest(SeeAllData=true)
public class IT_NotificacionEstadoOportunidad_test {
    public IT_NotificacionEstadoOportunidad_test() {
    }

    @isTest
	static void teste(){
        Test.StartTest();
		IT_NotificacionEstadoOportunidad.NotificacionOportunidad noit = new IT_NotificacionEstadoOportunidad.NotificacionOportunidad();

        // noit.idRadicado    = '43545';
        // noit.idOportunidad = '6565gf56y57';
        // noit.idProducto    = '545rtrgf656';
        // noit.idCredito     = '5454667uiu';
        // noit.fecha         = '23-07-2019';
        // noit.valorEstado   = '5000';
        // noit.idFamiempresa = '98988776';

		// String myJSON = JSON.serialize(noit);
        List<Opportunity> listaOpp = [SELECT id,Famiempresa_relacionada__c, (select Id from Quotes)
                                      FROM Opportunity 
                                      where StageName = 'Crédito Aprobado'
                                      order by CREATEDDATE asc Limit 200 OFFSET 10];
        
        Opportunity newOpp;
        for(Opportunity opp: listaOpp){
            if(opp.Quotes != null && opp.Quotes.size() > 0){
                newOpp = opp;
                break;
            }
        }
        
        QuoteLineItem prod = [SELECT id,Product2.RecordType.DeveloperName, QuoteId 
                              FROM QuoteLineItem 
                              WHERE QuoteId = :newOpp.Quotes[0].Id];
        
		String myJSON = JSONinvoke(newOpp, prod);

        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadoOportunidad';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_NotificacionEstadoOportunidad.doPost();
        IT_NotificacionEstadoOportunidad.cobertura();

        Test.StopTest();
	} 
        
    public static String JSONinvoke(Opportunity opp, QuoteLineItem prod){
        String json = ''+
        '{'+
        '"NotificacionOportunidad":{'+
            '"InformacionBasica":{'+
                    '"idRadicado": "555",'+
                    '"idOportunidad": "'+opp.id+'",'+
                    '"idProducto": "'+prod.Id+'",'+
                    '"idCredito": "7777",'+
                    '"fecha":  "19/06/2019 12:00:00.000",'+
                    '"valorEstado": "Aprobado",'+
                    '"idFamiempresa": "0986542",'+
                    '"montoDesembolsado": "50.000",'+
                    '"plazoOrden": "12",'+
                    '"numeroFactura" : "16"'+
            '},'+
            '"Desembolso":{'+
                '"DesembolsoTransferencia":{'+
                    '"tipoCuenta": "5555",'+
                    '"banco": "6666",'+
                    '"numCuenta": "77777",'+
                    '"valorCancelacion": "77777"'+
                '},'+
                    '"DesembolsoCheque":{'+
                '"cuenta": "66666",'+
                    '"numcuenta": "77777",'+
                    '"valorCancelacion": "77777"'+
                '}   }  }  }';
        return json;
    }
    
}
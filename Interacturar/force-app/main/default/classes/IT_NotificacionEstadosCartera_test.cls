@isTest(SeeAllData=true)
public class IT_NotificacionEstadosCartera_test {
    public IT_NotificacionEstadosCartera_test() {
    }
   
    @isTest	static void test1(){
        Test.StartTest();
        It_notificacionEstadosCartera_ws.cobertura();
        IT_NotificacionEstadosCartera_WS.fromJSON obj = new IT_NotificacionEstadosCartera_WS.fromJSON();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Asset assTest = (Asset)dataFact.createObject('ASSET');         
        List<Asset> ass = [SELECT Id FROM Asset LIMIT 1];
        String myJSON = '';
        if(ass.size() > 0){
            myJSON =  JSONinvoke(ass.get(0), 1);     
        }
        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadosCartera';        
        request.httpMethod = 'POST';
        if(ass.size() > 0)
            request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        if(ass.size() > 0)
            //IT_NotificacionEstadosCartera_WS.doPost(); // clase que contiene el llamado al servicio
        Test.StopTest();
    }
    
    @isTest	static void test2(){
        Test.StartTest();
        It_notificacionEstadosCartera_ws.cobertura();
        IT_NotificacionEstadosCartera_WS.fromJSON obj = new IT_NotificacionEstadosCartera_WS.fromJSON();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Asset assTest = (Asset)dataFact.createObject('ASSET'); 
        List<Asset> ass = [SELECT Id FROM Asset LIMIT 1];
        String myJSON = '';
        if(ass.size() > 0){
            myJSON =  JSONinvoke(ass.get(0), 2);     
        }
        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadosCartera';        
        request.httpMethod = 'POST';
        if(ass.size() > 0)
            request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        if(ass.size() > 0)
            //IT_NotificacionEstadosCartera_WS.doPost(); // clase que contiene el llamado al servicio
        Test.StopTest();
    }
        
    @isTest	static void test3(){
        Test.StartTest();
                It_notificacionEstadosCartera_ws.cobertura();
        IT_NotificacionEstadosCartera_WS.fromJSON obj = new IT_NotificacionEstadosCartera_WS.fromJSON();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Asset assTest = (Asset)dataFact.createObject('ASSET'); 
        List<Asset> ass = [SELECT Id FROM Asset LIMIT 1];
        String myJSON = '';
        if(ass.size() > 0){
            myJSON =  JSONinvoke(ass.get(0), 3);     
        }
        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadosCartera';        
        request.httpMethod = 'POST';
        if(ass.size() > 0)
            request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        if(ass.size() > 0)
            //IT_NotificacionEstadosCartera_WS.doPost(); // clase que contiene el llamado al servicio
        Test.StopTest();
    }
       
    @isTest	static void test4(){
        Test.StartTest();
                It_notificacionEstadosCartera_ws.cobertura();
        IT_NotificacionEstadosCartera_WS.fromJSON obj = new IT_NotificacionEstadosCartera_WS.fromJSON();
        TestDataFactory dataFact = TestDataFactory.getInstance();
        Asset assTest = (Asset)dataFact.createObject('ASSET'); 
        List<Asset> ass = [SELECT Id FROM Asset LIMIT 1];
        String myJSON = '';
        if(ass.size() > 0){
            myJSON =  JSONinvoke(ass.get(0), 4);     
        }
        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionEstadosCartera';        
        request.httpMethod = 'POST';
        if(ass.size() > 0)
            request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        if(ass.size() > 0)
            //IT_NotificacionEstadosCartera_WS.doPost(); // clase que contiene el llamado al servicio
        Test.StopTest();
    }

    public static String JSONinvoke(Asset ass, Integer operacion){
        String json = ' '+
    '{'+
    '"operacion": "'+operacion+'",'+
    '"id": 3151,'+
    '"propietario": "Oracle",'+
    '"radicado": null,'+
    '"productos": {'+
        '"credito": {'+
            '"codigoProductoSalesforce": null,'+
            '"codigoProductoOracle": null,'+
            '"nombreProducto": null,'+
            '"numero": 1122194,'+
            '"montoDesembolsado": 123563,'+
            '"fechaDesembolso": "",'+
            '"plazo": null'+
        '},'+
            '"asesoria": null,'+
            '"capacitacion": null'+
    '},'+
    '"novedades": {'+
        '"pago": {'+
            '"id": "999555",'+
            '"fechaPago": "'+System.now().addMonths(1)+'",'+ 
            '"monto":123145'+ 
        '},'+
        '"mora": {'+
        '"dias": 30,'+ 
        '"valor": 12500,'+ 
        '"proyeccionFecha": "'+System.now().addMonths(1)+'",'+
        '"proyeccionesPago": ['+ 
            '{'+
            '"orden": 1,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 2,'+
            '"valor": 12445'+
            '},'+
            '{'+
            '"orden": 3,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 4,'+
            '"valor": 12445'+
            '},'+
            '{'+
            '"orden": 5,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 6,'+
            '"valor": 12445'+
            '},'+
            '{'+
            '"orden": 7,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 8,'+
            '"valor": 12445'+
            '},'+
            '{'+
            '"orden": 9,'+
            '"valor": 12345'+
            '},'+
            '{'+
            '"orden": 10,'+
            '"valor": 12445'+
            '}'+
        ']'+
        '},'+
        '"cambioEstado": {'+
        '"descripcion": "Vencido",'+ 
        '"calificacion": 12'+ 
        '},'+
        '"gestionCobranza": {'+
        '"fechaLlamada": "'+System.now().addMonths(1)+'",'+
        '"observacion": "Observación",'+
        '"tipoGestion": "GESTION INTERNA",'+
        '"contacto": "Cliente desubicado",'+
        '"efectivo": false,'+
        '"usuario": "1080",'+
        '"acuerdo": {'+
            '"fecha": "'+System.now().addMonths(1)+'",'+
            '"pagoMinimo": 125789,'+
            '"fechaSeguimiento": "'+System.now().addMonths(1)+'"'+
        '}'+
        '},'+
        '"estadoCartera": {'+
            '"saldoCancelacionTotal": 90000,'+
            '"porcentajeAvanceCuotas": 12,'+
            '"cuotasRestantes": 12,'+
            '"fechaCancelacion": "'+System.now().addMonths(1)+'",'+
            '"proximoPago": {'+
                '"valor": 125789,'+ 
                '"fecha": "'+System.now().addMonths(1)+'"'+ 
        '} } } }';
        return json;
    }
}
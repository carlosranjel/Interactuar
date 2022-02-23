/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test para clase IT_RespuestaCliente

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-ABR-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@isTest(SeeAllData=true)
public  class IT_RespuestaCliente_test {
    public IT_RespuestaCliente_test() {    }

    @isTest	static void test1(){
        Test.StartTest();
        IT_RespuestaCliente.RespuestaCliente obj = new IT_RespuestaCliente.RespuestaCliente();
        IT_RespuestaCliente obj2 = new IT_RespuestaCliente();
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
        
        //Account cuenta = [SELECT id,Numero_de_identificacion__c FROM Account LIMIT 1];
		String myJSON = JSONinvoke( cuentaNuevo );

        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';  
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaCliente.doPost();
        //obj.idFamiEmpresa = '';  
        Test.StopTest();
    }
    
        public static String JSONinvoke(Account cuenta){
        String json = ''+
                '{'+
                '"respuestaCliente":'+
                '{'+
                '"idCliente":"'+cuenta.Numero_de_identificacion__c+'",'+
                '"idFamiEmpresa":"6666666",'+
                '"estado" : "",'+
                '"observacion" : "Ok",'+    
                '"origen" : "test",'+
                '"consecutivoPadre": "AS454DF5F"'+
                '}'+
                '}';
        return json;
    }
    
     @isTest	static void test2(){
        Test.StartTest();
        IT_RespuestaCliente.RespuestaCliente obj = new IT_RespuestaCliente.RespuestaCliente();
        
        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;
         
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
        
        //Account cuenta = [SELECT id,Numero_de_identificacion__c FROM Account LIMIT 1];
		String myJSON = JSONinvoke2( cuentaNuevo );

        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';  
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaCliente.doPost();
        //obj.idFamiEmpresa = '';  
        Test.StopTest();
    }

        public static String JSONinvoke2(Account cuenta){
        String json = ''+
                '{'+
                '"respuestaCliente":'+
                '{'+
                '"idCliente":"1023866955",'+
                '"idFamiEmpresa":"",'+
                '"estado" : "",'+
                '"observacion" : "",'+    
                '"origen" : "",'+
                '"consecutivoPadre": ""'+
                '}'+
                '}';
        return json;
    }
    
     @isTest	static void test3(){
        Test.StartTest();
        IT_RespuestaCliente.RespuestaCliente obj = new IT_RespuestaCliente.RespuestaCliente();
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccountJuridica();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
             
        //Account cuenta = [SELECT id,Numero_de_identificacion__c FROM Account LIMIT 1];
		String myJSON = JSONinvoke3( cuentaNuevo );

        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';  
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaCliente';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaCliente.doPost(); 
        Test.StopTest();
    }
    
        public static String JSONinvoke3(Account cuenta){
        String json = ''+
                '{'+
                '"respuestaCliente":'+
                '{'+
                '"idCliente":"'+cuenta.Numero_de_identificacion__c+'",'+
                '"idFamiEmpresa":"123456789",'+
                '"estado" : "OK",'+
                '"observacion" : "Ok",'+    
                '"origen" : "test",'+
                '"consecutivoPadre": "AS454DF5F"'+
                '}'+
                '}';
        return json;
    }
    }
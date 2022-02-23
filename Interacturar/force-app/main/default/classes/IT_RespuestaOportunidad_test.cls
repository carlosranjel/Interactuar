/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test para clase IT_RespuestaOportunidad

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-ABR-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@isTest(SeeAllData=true)
public class IT_RespuestaOportunidad_test {
    public IT_RespuestaOportunidad_test() {
    }

    @isTest	static void test1(){
        Test.StartTest();           
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
            
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;
            
        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.today();
        insert oportunidadNuevo;
            
        Product2 prod = new TestDataFactory().newProductCredito();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB.Id;
        prieb.UnitPrice    = 5000;
        prieb.IsActive     = true;
        insert prieb;
            
        Pricebook2 pri = new Pricebook2();
        pri.name = 'Test Price Book';
        pri.IsActive = true;
        insert pri;
            
        PricebookEntry prie = new PricebookEntry();
        prie.Product2Id = prod.Id;
        prie.Pricebook2Id = pri.Id;
        prie.UnitPrice = 5000;
        prie.IsActive = true;
        insert prie;
            
        Quote cotizacion = new Quote();
        cotizacion.Status = 'Programada';
        cotizacion.Name = 'Cotizacion Prueba';
        cotizacion.OpportunityId = oportunidadNuevo.Id;
        cotizacion.Pricebook2Id = pri.id;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;      
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;

        String myJSON = JSONinvoke1( oportunidadNuevo, pxc );
        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad'; 
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaOportunidad.doPost();
        IT_RespuestaOportunidad.applicationException appEx = new IT_RespuestaOportunidad.applicationException();
        Test.StopTest();
    }

        public static String JSONinvoke1(Opportunity opp, QuoteLineItem pxc){
        String json = ''+
                '{'+
                '"respuestaOportunidad":'+
                    '{'+
                    '"idOportunidad": "'+opp.id+'",'+
                    '"cod_producto": "'+pxc.Id+'",'+
                    '"idRadicado" : "989877",'+
                    '"estado":"KO",'+
            		'"tipoCredito":"",'+  
                    '"consecutivoPadre":"454689712",'+
                    '"observacionTecnica":"OBSERVACION TECNICA",'+
                     '"oracle":'+
                            '{'+
                    '"origen":"ORACLE",'+
        			'"estadoOracle":"KO",'+
        			'"observacionOracle":"observacion"'+
                            '},'+
                    '"bpms":'+
                            '{'+
                    '"origen":"",'+
        			'"estadoBpms":"",'+
        			'"observacionBPMS":""'+
                            '}'+
                    '}'+
                '}';
        return json;
    }
      
        @isTest	static void test2(){
        Test.StartTest();
        
            
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
            
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;
            
        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.today();
        insert oportunidadNuevo;
            
        Product2 prod = new TestDataFactory().newProductCredito();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB.Id;
        prieb.UnitPrice    = 5000;
        prieb.IsActive     = true;
        insert prieb;
            
        Pricebook2 pri = new Pricebook2();
        pri.name = 'Test Price Book';
        pri.IsActive = true;
        insert pri;
            
        PricebookEntry prie = new PricebookEntry();
        prie.Product2Id = prod.Id;
        prie.Pricebook2Id = pri.Id;
        prie.UnitPrice = 5000;
        prie.IsActive = true;
        insert prie;
            
        Quote cotizacion = new Quote();
        cotizacion.Status = 'Programada';
        cotizacion.Name = 'Cotizacion Prueba';
        cotizacion.OpportunityId = oportunidadNuevo.Id;
        cotizacion.Pricebook2Id = pri.id;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;      
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;

        String myJSON = JSONinvoke2( oportunidadNuevo, pxc );
        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad'; 
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaOportunidad.doPost();
        /*obj.idOportunidad = '';  
        obj.idRadicado = '';  
        obj.estado = '';  
        obj.tipoCredito = '';
        obj.observacion = '';  */
        IT_RespuestaOportunidad.applicationException appEx = new IT_RespuestaOportunidad.applicationException();
        Test.StopTest();
    }

        public static String JSONinvoke2(Opportunity opp, QuoteLineItem pxc){
        String json = ''+
                '{'+
                '"respuestaOportunidad":'+
                    '{'+
                    '"idOportunidad": "'+opp.id+'",'+
                    '"cod_producto": "'+pxc.Id+'",'+
                    '"idRadicado" : "989877",'+
                    '"estado":"",'+
            		'"tipoCredito":"",'+  
                    '"consecutivoPadre":"",'+
                    '"observacionTecnica":"",'+
                     '"oracle":'+
                            '{'+
                    '"origen":"",'+
        			'"estadoOracle":"",'+
        			'"observacionOracle":""'+
                            '},'+
                    '"bpms":'+
                            '{'+
                    '"origen":"",'+
        			'"estadoBpms":"",'+
        			'"observacionBPMS":""'+
                            '}'+
                    '}'+
                '}';
        return json;
    }
    
     @isTest static void test3(){
        Test.StartTest();          
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
            
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;
            
        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.today();
        insert oportunidadNuevo;
            
        Product2 prod = new TestDataFactory().newProductCredito();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB.Id;
        prieb.UnitPrice    = 5000;
        prieb.IsActive     = true;
        insert prieb;
            
        Pricebook2 pri = new Pricebook2();
        pri.name = 'Test Price Book';
        pri.IsActive = true;
        insert pri;
            
        PricebookEntry prie = new PricebookEntry();
        prie.Product2Id = prod.Id;
        prie.Pricebook2Id = pri.Id;
        prie.UnitPrice = 5000;
        prie.IsActive = true;
        insert prie;
            
        Quote cotizacion = new Quote();
        cotizacion.Status = 'Programada';
        cotizacion.Name = 'Cotizacion Prueba';
        cotizacion.OpportunityId = oportunidadNuevo.Id;
        cotizacion.Pricebook2Id = pri.id;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;      
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;

        String myJSON = JSONinvoke3( oportunidadNuevo, pxc );
        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad'; 
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaOportunidad.doPost();
        /*obj.idOportunidad = '';  
        obj.idRadicado = '';  
        obj.estado = '';  
        obj.tipoCredito = '';
        obj.observacion = '';  */
        IT_RespuestaOportunidad.applicationException appEx = new IT_RespuestaOportunidad.applicationException();
        Test.StopTest();
    }

        public static String JSONinvoke3(Opportunity opp, QuoteLineItem pxc){
        String json = ''+
                '{'+
                '"respuestaOportunidad":'+
                    '{'+
                    '"idOportunidad": "'+opp.id+'",'+
                    '"cod_producto": "'+pxc.Id+'",'+
                    '"idRadicado" : "989877",'+
                    '"estado":"OK",'+
            		'"tipoCredito":"test",'+  
                    '"consecutivoPadre":"44548787",'+
                    '"observacionTecnica":"",'+
                     '"oracle":'+
                            '{'+
                    '"origen":"ORACLE",'+
        			'"estadoOracle":"OK",'+
        			'"observacionOracle":"observacion"'+
                            '},'+
                    '"bpms":'+
                            '{'+
                    '"origen":"BPMS",'+
        			'"estadoBpms":"OK",'+
        			'"observacionBPMS":"observacion"'+
                            '}'+
                    '}'+
                '}';
        return json;
    }
    
         @isTest static void test4(){
        Test.StartTest();          
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;
            
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;
            
        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.today();
        insert oportunidadNuevo;
            
        Product2 prod = new TestDataFactory().newProductCredito();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB.Id;
        prieb.UnitPrice    = 5000;
        prieb.IsActive     = true;
        insert prieb;
            
        Pricebook2 pri = new Pricebook2();
        pri.name = 'Test Price Book';
        pri.IsActive = true;
        insert pri;
            
        PricebookEntry prie = new PricebookEntry();
        prie.Product2Id = prod.Id;
        prie.Pricebook2Id = pri.Id;
        prie.UnitPrice = 5000;
        prie.IsActive = true;
        insert prie;
            
        Quote cotizacion = new Quote();
        cotizacion.Status = 'Programada';
        cotizacion.Name = 'Cotizacion Prueba';
        cotizacion.OpportunityId = oportunidadNuevo.Id;
        cotizacion.Pricebook2Id = pri.id;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;      
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;

        String myJSON = JSONinvoke4( oportunidadNuevo, pxc );
        RestRequest request = new RestRequest();
        //request.requestUri ='https://interactuar.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad'; 
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/NotificacionRespuestaOportunidad';
        request.httpMethod = 'GET';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
		IT_RespuestaOportunidad.doPost();
        IT_RespuestaOportunidad.applicationException appEx = new IT_RespuestaOportunidad.applicationException();
        Test.StopTest();
    }

        public static String JSONinvoke4(Opportunity opp, QuoteLineItem pxc){
        String json = ''+
                '{'+
                '"respuestaOportunidad":'+
                    '{'+
                    '"idOportunidad": "'+opp.id+'",'+
                    '"cod_producto": "'+pxc.Id+'",'+
                    '"idRadicado" : "989877",'+
                    '"estado":"OK",'+
            		'"tipoCredito":"",'+  
                    '"consecutivoPadre":"44548787",'+
                    '"observacionTecnica":"",'+
                     '"oracle":'+
                            '{'+
                    '"origen":"",'+
        			'"estadoOracle":"",'+
        			'"observacionOracle":""'+
                            '},'+
                    '"bpms":'+
                            '{'+
                    '"origen":"BPMS",'+
        			'"estadoBpms":"OK",'+
        			'"observacionBPMS":"observacion"'+
                            '}'+
                    '}'+
                '}';
        return json;
    }
}
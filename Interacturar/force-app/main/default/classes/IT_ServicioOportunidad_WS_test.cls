@isTest(seeAllData=true)
global class IT_ServicioOportunidad_WS_test {
    global IT_ServicioOportunidad_WS_test() {   }

    @isTest static void testProcesoSolicitudCredito_1(){
        Test.startTest();
        it_serviciooportunidad_ws.cobertura();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioOportunidad_ws_test_Mock()); 
        IT_ServicioOportunidad_ws obj = new IT_ServicioOportunidad_ws();
        Opportunity Opp = [SELECT id, recordType.developername FROM Opportunity WHERE Identificador_proceso__c != null and 
                           recordType.developername = 'Solicitud_de_credito' LIMIT 1];
        List<String> lstOpp = new List<String>();
        lstOpp.add(Opp.id);
        IT_ServicioOportunidad_ws.servicioOportunidad(lstOpp);
        IT_ServicioOportunidad_ws.sinFamiEmpresa();
        Test.stopTest();
    }
    
    @isTest static void testProcesoConoyRedesAsesorias_2(){

        IT_ServicioOportunidad_ws obj = new IT_ServicioOportunidad_ws();
             it_serviciooportunidad_ws.cobertura();         
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
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
        insert oportunidadNuevo;
            
        Product2 prod = new TestDataFactory().newProductConocimiento();
        
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
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
        insert cotizacion;  
        
        oportunidadNuevo.SyncedQuoteId = cotizacion.Id;
        update oportunidadNuevo;
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Product2Id = prod.id;        
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;  
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioOportunidad_ws_test_Mock()); 
        List<String> lstOpp = new List<String>();
        lstOpp.add(oportunidadNuevo.id);
        IT_ServicioOportunidad_ws.servicioOportunidad(lstOpp);
        Test.stopTest();
    }

    @isTest static void testProcesoConoyRedesAsesorias_3(){
    it_serviciooportunidad_ws.cobertura();
        IT_ServicioOportunidad_ws obj = new IT_ServicioOportunidad_ws();
                  
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
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
        insert oportunidadNuevo;
            
        Product2 prod = new Product2 (
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId(),
                Identificador_portafolio__c='2811',
                ProductCode='C.281-1',
                Family='Conocimiento y Redes',
                Clasificacion__c='Productividad y Calidad',
                Name='TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD (GRATIS)',
                isActive = true,
                Programa__c = 'ADMINISTRACION DE MICROEMPRESA E INFORMATICA',
                Grupo_convenio_nombre__c = 'PILOTO PREMIUM',
                Tipo_de_servicio__c = 'Asesoria',
                Horas_grupales__c =  2,
                Horas_individuales__c = 1,
                Grupo_convenio__c =  493,
                Grupo_valor__c = 1,
                Cupo_maximo__c = 10,
                Cupo_minimo__c = 1,
                Precio__c = 5000,
                Identificador_grupo__c = 14,
                Precio_sin_IVA__c = false,
                Requiere_pago__c = false,
                Fecha_inicio__c = null,
                Fecha_fin__c = null,
                Codigo_Oficina_OR__c = null,
                Codigo_Sede_OR__c = null,
                Hora_inicio__c = null,
                Hora_fin__c = null,
                Monto_maximo__c = 10,
                Monto_minimo__c = 1,
                Dias_de_la_semana__c = 'V',
                Tasa_nominal_anual_mes_vencido__c = 2,
                Oficina__c = null,
                Sede__c = null
            );
            insert prod;
        
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
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
        insert cotizacion;  
        
        oportunidadNuevo.SyncedQuoteId = cotizacion.Id;
        update oportunidadNuevo;
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Product2Id = prod.id;        
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;  
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioOportunidad_ws_test_Mock()); 
        List<String> lstOpp = new List<String>();
        lstOpp.add(oportunidadNuevo.id);
        IT_ServicioOportunidad_ws.servicioOportunidad(lstOpp);
        Test.stopTest();
    }
    
    /*@isTest static void testavales_4(){
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
        insert oportunidadNuevo;
        
        Contact contactoNuevo = new Contact();      
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;
        
        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        aso.RepresentanteLegal__c = False;
        insert aso;
        
        ////
        Test.setMock(HttpCalloutMock.class, new IT_ServicioOportunidad_ws_test_Mock()); 
        IT_ServicioOportunidad_ws obj = new IT_ServicioOportunidad_ws();
        Opportunity Opp = [SELECT id, recordType.developername FROM Opportunity WHERE Identificador_proceso__c != null and 
                           recordType.developername = 'Solicitud_de_credito' LIMIT 1];
        List<String> lstOpp = new List<String>();
        lstOpp.add(Opp.id);
        IT_ServicioOportunidad_ws.servicioOportunidad(lstOpp);
        ///
        
        List<Asociacion_cuenta_contacto__c> lstAsc = new List<Asociacion_cuenta_contacto__c>();
        lstAsc.add(aso);
        //IT_ServicioOportunidad_ws.hom = IT_ServicioOportunidad_ws.getHomologaciones();
        IT_ServicioOportunidad_ws.construyeJSONAvales(lstAsc);
        IT_ServicioOportunidad_ws.sinFamiEmpresa();
    }*/

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     27-02-2020
    ************************************************************************************************/
    global class IT_ServicioOportunidad_ws_test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '{'+
                '"encabezado":{'+
                '"estado":"0",'+
                '"excepcion":"",'+
                '"fecha":"2020-01-07 09:26:58",'+
                '"identificador":"001e000001TbR87AAF-641",'+
                '"mensaje":"",'+
                '"integracion":"Consulta Datacredito Con BPMS",'+
                '"operacion":"1",'+
                '"origen":"ORACLE",'+
                '"destino":"SALESFORCE"'+
                '},'+
                '"cuerpo":{'+
                '"identificacion":"71794224",'+
                '"primerApellido":"Gomezs",'+
                '"primerNombre":"Mauricios",'+
                '"tipoIdentificacion":"C",'+
                '"idProceso":"241928",'+
                '"urlPdf":"",'+
                '"xmlDatacredito" : ""'+
                '}}'                            
                );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
        }
    }
}
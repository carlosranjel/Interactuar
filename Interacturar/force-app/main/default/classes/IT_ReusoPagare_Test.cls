@isTest(seeAllData=false)
public  class IT_ReusoPagare_Test {

    @isTest
    public static void noEncuentraOtraCotizacion(){

        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccountJuridica(); 
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
        oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert oportunidadNuevo;

        Product2 prod = new TestDataFactory().newProductCredito();            
        // Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        Id standardPB = Test.getStandardPricebookId();

        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB;
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
        cotizacion.EstadoIntegracionPagare__c = 'PAGARE-OK';
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;      
            
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;        
        insert pxc;

        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido uno';
        contactoNuevo.firstName = 'Nombre uno';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        Contact contactoDos = new Contact();
        contactoDos.lastName = 'Apellido dos';
        contactoDos.firstName = 'Nombre dos';
        contactoDos.Numero_de_identificacion__c = '1023866950';
        contactoDos.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoDos.Sincronizar_Aval__c = true;
        contactoDos.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoDos.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoDos;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c            = cuentaNuevo.Id;
        aso.Contacto__c           = contactoNuevo.Id;
        aso.Oportunidad__c        = oportunidadNuevo.Id;
        aso.RepresentanteLegal__c = true;
        insert aso;

        Asociacion_cuenta_contacto__c asoDos = new Asociacion_cuenta_contacto__c();
        asoDos.Cliente__c            = cuentaNuevo.Id;
        asoDos.Contacto__c           = contactoDos.Id;
        asoDos.Oportunidad__c        = oportunidadNuevo.Id;
        asoDos.RepresentanteLegal__c = false;
        insert asoDos;

        Test.startTest();
        IT_ReusoPagare.validaReusoPagare( cotizacion , new List<Id>{ oportunidadNuevo.id } );
        Test.stopTest();
    }

    @isTest
    public static void masCotizaciones(){
        Test.startTest();
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccountJuridica(); 
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'Crédito Aprobado';        
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
        oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert oportunidadNuevo;

        Product2 prod = new TestDataFactory().newProductCredito();            
        // Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        Id standardPB = Test.getStandardPricebookId();

        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = prod.Id;
        prieb.Pricebook2Id = standardPB;
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
        cotizacion.idDocumentoPagare__c = '456789';
        cotizacion.EstadoIntegracionPagare__c = 'PAGARE-OK';
        cotizacion.FlagWSOportunidad__c  = true;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion; 
               
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = prod.id;
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;        
        insert pxc;

        oportunidadNuevo.SyncedQuoteId = cotizacion.Id;
        update oportunidadNuevo;

        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido uno';
        contactoNuevo.firstName = 'Nombre uno';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        Contact contactoDos = new Contact();
        contactoDos.lastName = 'Apellido dos';
        contactoDos.firstName = 'Nombre dos';
        contactoDos.Numero_de_identificacion__c = '1023866950';
        contactoDos.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoDos.Sincronizar_Aval__c = true;
        contactoDos.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoDos.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoDos;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c            = cuentaNuevo.Id;
        aso.Contacto__c           = contactoNuevo.Id;
        aso.Oportunidad__c        = oportunidadNuevo.Id;
        aso.RepresentanteLegal__c = true;
        insert aso;

        Asociacion_cuenta_contacto__c asoDos = new Asociacion_cuenta_contacto__c();
        asoDos.Cliente__c            = cuentaNuevo.Id;
        asoDos.Contacto__c           = contactoDos.Id;
        asoDos.Oportunidad__c        = oportunidadNuevo.Id;
        asoDos.RepresentanteLegal__c = false;
        insert asoDos;

        Asset activoAnterior = new Asset();
        activoAnterior.Identificador_Radicado__c = pxc.Identificador_Radicado_OR__c;
        activoAnterior.Fecha_de_cancelacion__c   = Date.newInstance(2019, 01, 01);
        activoAnterior.Name                  = 'Nombre Activo';
        activoAnterior.Numero_de_credito__c  = '565656';
        activoAnterior.Monto_desembolsado__c = 70000;
        activoAnterior.Fecha_desembolso__c   = Date.newInstance(2020, 08, 01);
        activoAnterior.Plazo__c              = 12;
        activoAnterior.AccountId             = cuentaNuevo.Id;
        insert activoAnterior;

        /*****************************************************************************/

        Opportunity oportunidadReuso = new Opportunity();
        oportunidadReuso.AccountId = cuentaNuevo.Id;
        oportunidadReuso.Name = 'Nombre Oportunidad reuso';
        oportunidadReuso.StageName = 'En Estudio';
        oportunidadReuso.CloseDate = Date.newInstance(2025,10,15);
        oportunidadReuso.Respuesta_Oportunidad__c = '';
        oportunidadReuso.Origen_Integracion__c = '';        
        oportunidadReuso.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert oportunidadReuso;

        Quote cotizacionReuso = new Quote();
        cotizacionReuso.Status = 'Programada';
        cotizacionReuso.Name = 'Cotizacion reuso';
        cotizacionReuso.OpportunityId = oportunidadReuso.Id;
        cotizacionReuso.Pricebook2Id = pri.id;
        cotizacionReuso.EstadoIntegracionPagare__c = '';
        cotizacionReuso.FlagWSOportunidad__c  = true;
        cotizacionReuso.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacionReuso;

        QuoteLineItem pxcReuso = new QuoteLineItem();
        pxcReuso.QuoteId = cotizacionReuso.id;
        pxcReuso.Quantity = 5;
        pxcReuso.Plazo_meses__c = 24;
        pxcReuso.Product2Id = prod.id;
        pxcReuso.Identificador_Radicado_OR__c = '53658';
        pxcReuso.PricebookEntryId = prie.Id;
        pxcReuso.UnitPrice = 50000;        
        insert pxcReuso;

        Asociacion_cuenta_contacto__c asoReuso = new Asociacion_cuenta_contacto__c();
        asoReuso.Cliente__c            = cuentaNuevo.Id;
        asoReuso.Contacto__c           = contactoNuevo.Id;
        asoReuso.Oportunidad__c        = oportunidadReuso.Id;
        asoReuso.RepresentanteLegal__c = true;
        insert asoReuso;

        Asociacion_cuenta_contacto__c asoDosReuso = new Asociacion_cuenta_contacto__c();
        asoDosReuso.Cliente__c            = cuentaNuevo.Id;
        asoDosReuso.Contacto__c           = contactoDos.Id;
        asoDosReuso.Oportunidad__c        = oportunidadReuso.Id;
        asoDosReuso.RepresentanteLegal__c = false;
        insert asoDosReuso;

        Quote coti = [select ID, Opportunity.AccountId, Opportunity.Account.Name from Quote where Id =: cotizacionReuso.ID];
        IT_ReusoPagare.validaReusoPagare( coti , new List<ID>{ oportunidadReuso.ID });
        Test.stopTest();
    }
}
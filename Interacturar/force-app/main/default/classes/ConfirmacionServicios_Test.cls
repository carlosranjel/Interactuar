@isTest(seeAllData=true)
public class ConfirmacionServicios_Test {
	
    @isTest static void test_1(){
        Test.startTest();
        ConfirmacionServicios obj = new ConfirmacionServicios();
        
        Lead pros = [select id FROM Lead LIMIT 1];
        Opportunity opp = [select id FROM Opportunity LIMIT 1];  
        Contact con = [select id,EjecutarDataAval__c FROM Contact LIMIT 1];
        String idProspecto = pros.id;
        String idopp = opp.id;
        String idCon = con.id;
        
        ConfirmacionServicios.validaEjecucionIdBPMS(idProspecto);
        ConfirmacionServicios.validaEjecucionIdBPMS(idopp);        
		ConfirmacionServicios.validaEjecucionDataCredito(idProspecto);
        ConfirmacionServicios.validaEjecucionDataCredito(idopp);
        ConfirmacionServicios.validaEjecucionDataCredito(idCon);
        ConfirmacionServicios.validaEjecucionGeneracionPDF(idProspecto);
        ConfirmacionServicios.validaEjecucionGeneracionPDF(idopp);
        ConfirmacionServicios.validaEjecucionGeneracionPDF(idCon);
        ConfirmacionServicios.consultaAsociacionAval(idCon);
        Date fechaantesHoy = Date.newInstance(2020, 03, 01);
        ConfirmacionServicios.ejecutaConsultaDataCredito(fechaantesHoy);
        Date fechaAfterHoy = Date.newInstance(2030, 03, 01);
        ConfirmacionServicios.ejecutaConsultaDataCredito(fechaAfterHoy);
        
        List<String> lstIdbpms1 = new List<String>();
        lstIdbpms1.add('IdBPMS,'+idProspecto);
        ConfirmacionServicios.validaEjecucion(lstIdbpms1);
        
        List<String> lstIdbpms2 = new List<String>();
        lstIdbpms2.add('Datacredito,'+idProspecto);
        ConfirmacionServicios.validaEjecucion(lstIdbpms2);
                
        List<String> lstIdbpms3 = new List<String>();
        lstIdbpms3.add('Historico,'+idProspecto);
        ConfirmacionServicios.validaEjecucion(lstIdbpms3);
        
        List<String> lstIdbpms4 = new List<String>();
        lstIdbpms4.add('else,'+idProspecto);
        ConfirmacionServicios.validaEjecucion(lstIdbpms4);
        Test.stopTest();
    }
    
    @isTest static void test_2(){
        Contact contactoNuevo = new Contact();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
        
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;
        
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        insert aso;
        Test.startTest();
        ConfirmacionServicios.ejecutaDataCreditoOtraOpp(contactoNuevo);
        Test.stopTest();
    }
    
    @isTest static void test_3(){
        Contact contactoNuevo = new Contact();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
        
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;
        
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        insert aso;
        
        Test.startTest();
        List<ID> idsCuenta = new List<ID>();
        idsCuenta.add(cuentaNuevo.id);
        IT_GestorDeConsultas_cls.consultaCuenta(idsCuenta);
        IT_GestorDeConsultas_cls.consultaOportunidad(oportunidadNuevo.id);
        IT_GestorDeConsultas_cls.consultaProductoPorCotizacion(oportunidadNuevo);
        IT_GestorDeConsultas_cls.consultaProductoPorCotizacion2('123');
        Set<String> setId = new Set<String>();
        setId.add('123');
        IT_GestorDeConsultas_cls.consultaProducto(setId);
        IT_GestorDeConsultas_cls.consultaFamiEmpresa(cuentaNuevo.id);
        
        List<ID> idsCon = new List<ID>();
        idsCon.add(contactoNuevo.id);
        IT_GestorDeConsultas_cls.consultaContacto(idsCon);
        IT_GestorDeConsultas_cls.consultaContactos(idsCon);
        
        List<ID> idsOportunidad = new List<ID>();
        idsOportunidad.add(oportunidadNuevo.id);
        IT_GestorDeConsultas_cls.consultaAsociacionAval(idsOportunidad);
		IT_GestorDeConsultas_cls.consultaConsecutivoPadre(idsCon);
        
        Asset act = [SELECT id from asset limit 1];
        List<id> lstActivo = new List<id>();
        lstActivo.add(act.id);
        IT_GestorDeConsultas_cls.consultaconsultaActivos(lstActivo);
        Test.stopTest();
    }
    
     @isTest static void test_4(){
         IT_ParametrosWS_cls.parametrosCliente();
         IT_ParametrosWS_cls.parametrosClienteAval('');
         IT_ParametrosWS_cls.parametrosOportunidad('');
         IT_ParametrosWS_cls.parametrosDocumentacionBPMS();
         IT_ParametrosWS_cls.parametrosDataCredito('');
         IT_ParametrosWS_cls.parametrosIdBPMS('');
         IT_ParametrosWS_cls.parametrosDataCreditoDos('');
         IT_ParametrosWS_cls.parametrosGenerarPDF('');
         IT_ParametrosWS_cls.parametrosCobranza('');
         //IT_ParametrosWS_cls.parametrosActivoDemanda('');
         
     }
    
      @isTest static void test_5(){
        IT_AccountHandler_cls obj1 = new IT_AccountHandler_cls();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
          
        cuentaNuevo = new TestDataFactory().newAccount();  
          cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 3000;
          cuentaNuevo.Cual__c = 'cuales';
          //cuentaNuevo.Otros_ingresos_familiares__c = 3000;
          cuentaNuevo.Ingresos_conyuge__c = 3000;
          cuentaNuevo.Hogar__c = 3000;
          cuentaNuevo.Educacion__c = 3000;
          //cuentaNuevo.Otros_egresos_familiares__c = 3000;
          cuentaNuevo.Alquiler__c = 3000;
          cuentaNuevo.Prestamos__c = 3000;
          update cuentaNuevo;
        Map<Id,Account> mapClienteSeleccionado = new Map<Id,Account>();
        mapClienteSeleccionado.put(cuentaNuevo.id, cuentaNuevo);
          
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        Map<Id,Famiempresa__c> mapfamiNew = new Map<Id,Famiempresa__c>();
        mapfamiNew.put(fami.id, fami);
          
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;          
        Map<Id,Famiempresa__c> mapfamiSeleccionado = new Map<Id,Famiempresa__c>();
        mapfamiSeleccionado.put(fami.id, fami);
        IT_FamiEmpresaHandler_cls.validaCamposModificados(mapfamiSeleccionado,mapfamiNew);
        
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
        oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
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
          
          cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 2000;
          cuentaNuevo.Cual__c = 'cual';
          //cuentaNuevo.Otros_ingresos_familiares__c = 2000;
          cuentaNuevo.Ingresos_conyuge__c = 2000;
          cuentaNuevo.Hogar__c = 2000;
          cuentaNuevo.Educacion__c = 2000;
          //cuentaNuevo.Otros_egresos_familiares__c = 2000;
          cuentaNuevo.Alquiler__c = 2000;
          cuentaNuevo.Prestamos__c = 2000;
        update cuentaNuevo;    

          
       Map<Id,Account> mapClienteNew = new Map<Id,Account>();
       mapClienteNew.put(cuentaNuevo.id, cuentaNuevo);          
       IT_AccountHandler_cls.validaCamposModificados(mapClienteSeleccionado, mapClienteNew);
     }
    
       @isTest static void test_6(){           
        Test.startTest();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
          
        cuentaNuevo = new TestDataFactory().newAccount();  
          cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 3000;
          cuentaNuevo.Cual__c = 'cuales';
          //cuentaNuevo.Otros_ingresos_familiares__c = 3000;
          cuentaNuevo.Ingresos_conyuge__c = 3000;
          cuentaNuevo.Hogar__c = 3000;
          cuentaNuevo.Educacion__c = 3000;
          //cuentaNuevo.Otros_egresos_familiares__c = 3000;
          cuentaNuevo.Alquiler__c = 3000;
          cuentaNuevo.Prestamos__c = 3000;
          update cuentaNuevo;
                 
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();         
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;          
               
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
        oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
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
          
        
        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        List<Account> lstCliente     = new List<Account>{ cuentaNuevo };
        List<Opportunity> lstOpp     = new List<Opportunity>{ oportunidadNuevo };
        List<Id> lstIdOpp            = new List<Id>{ oportunidadNuevo.id };
		IT_SincronizarCotizacion_ctr.validacionParaSincronizar( lstCliente ,  lstOpp, lstIdOpp );
        IT_SincronizarCotizacion_ctr.validaCamposContactoAval(contactoNuevo);
        Test.stopTest();
     }
}
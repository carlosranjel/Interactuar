@isTest(seeAllData=true)
public class IT_ResumenSolicitud_Archivos_Test {
     @isTest static void creaArchivo(){           

        Test.startTest();
         Opportunity oportunidadNuevo = new Opportunity();
          
 
            Integer numeroAleatorioInt1 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
    Integer numeroAleatorioInt2 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
    String numeroAleatorioStr1 = String.valueOf(numeroAleatorioInt1); // 07-03-2020
    String numeroAleatorioStr2 = String.valueOf(numeroAleatorioInt2); // 07-03-2020

         Account cuentaNuevo;    
            cuentaNuevo = new Account (

         Tipo_de_identificacion__c='Cedula de Ciudadania',
                Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
                FirstName='Nombre de cliente',
                LastName='Apellido de cliente',
                Correo_electronico_empresa__c='clientest@clientest.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True,
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
               Personas_a_cargo__pc = 2,
                Autorizacion_uso_de_datos__c = 'Autoriza',
                Medio_de_autorizacion__c = 'Solicitud de vinculacion',
                Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
            );
            insert cuentaNuevo;          

            
         cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 3000;
          cuentaNuevo.Cual__c = 'cuales';
          cuentaNuevo.Otros_ingresos_familiares__c = 3000;
          cuentaNuevo.Ingresos_conyuge__c = 3000;
          cuentaNuevo.Hogar__c = 3000;
          cuentaNuevo.Educacion__c = 3000;
          cuentaNuevo.Otros_egresos_familiares__c = 3000;
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
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.newInstance(2021,02,15);
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
         contactoNuevo.Personas_a_cargo__c = 2;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        List<Account> lstCliente     = new List<Account>{ cuentaNuevo };
        List<Opportunity> lstOpp     = new List<Opportunity>{ oportunidadNuevo };
        List<Id> lstIdOpp            = new List<Id>{ oportunidadNuevo.id };
		IT_SincronizarCotizacion_ctr.validacionParaSincronizar( lstCliente ,  lstOpp, lstIdOpp );
        IT_SincronizarCotizacion_ctr.validaCamposContactoAval(contactoNuevo);
        IT_ResumenSolicitud_Archivo.cargaArchivoProcess(lstIdOpp);
        PageReference vf = new PageReference('/apex/IT_ResumenSolicitud');
        Test.setCurrentPage(vf);
        ApexPages.currentPage().getParameters().put('id',cuentaNuevo.Id);
        ApexPages.currentPage().getParameters().put('idOpp',oportunidadNuevo.id ); 
         
        IT_ResumenSolicitud_ctr itresumen = New IT_ResumenSolicitud_ctr();
        itresumen.getCliente();
         itresumen.getFami();
         itresumen.getOpp();
         itresumen.getqlitem();
         itresumen.getLstAvales();
        Test.stopTest();
     }
}
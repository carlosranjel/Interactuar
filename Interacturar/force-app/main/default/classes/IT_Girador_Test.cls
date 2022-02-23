/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Deceval
* @descripcion      Clase Test IT_Girador_Test

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-JUL-2020   Rafael Cardona (RC)           Creacion Clase Test.
**************************************************************************************************************
**/
@isTest(seeAllData=false)
public with sharing class IT_Girador_Test {

    @isTest static void giradorNaturalTest(){
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
          
        cuentaNuevo = new TestDataFactory().newAccount();  
          cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 3000;
          cuentaNuevo.Cual__c = 'cuales';
          cuentaNuevo.Ingresos_conyuge__c = 3000;
          cuentaNuevo.Hogar__c = 3000;
          cuentaNuevo.Educacion__c = 3000;
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
        oportunidadNuevo.Identificador_proceso__c = '111111';
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.newInstance(2022,05,15);
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

        Asociacion_cuenta_contacto__c asociacionAval = new Asociacion_cuenta_contacto__c();
        asociacionAval.Cliente__c            = cuentaNuevo.id;
        asociacionAval.Contacto__c           = contactoNuevo.id;
        asociacionAval.Oportunidad__c        = oportunidadNuevo.id;
        asociacionAval.RepresentanteLegal__c = false;
        asociacionAval.Name = 'Representante legal';
        insert asociacionAval;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_Girador_test_Mock()); 
        String res1 = IT_Girador_ctr.listadoGiradores(cotizacion.Id);
        // System.assert(res1 != null);
        String res2 = IT_Girador_ctr.integraGirador(cotizacion.Id);
        // System.assert(res2 != null);
        Test.stopTest();
    }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     15-07-2020
    ************************************************************************************************/
    public class IT_Girador_test_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(
                    '{'+
                        '"response": {'+
                          '"solicitudCredito": {'+
                            '"radicado": 6546,'+
                            '"oficina": 1102,'+
                            '"idProceso": 258373'+
                          '},'+
                          '"encabezado": {'+
                            '"fecha": "2020-07-15T16:48:04",'+
                            '"usuario": "Rafael Cardona",'+
                            '"operacion": "CREACIONGIRADORES",'+
                            '"origen": "SALESFORCE",'+
                            '"destino": "DECEVAL",'+
                            '"mensaje": {'+
                              '"descripcion": "(SDL.SE.0000): El girador ya existe y se actualizo la informacion",'+
                              '"estado": "OK"'+
                            '}'+
                          '},'+
                          '"CreacionGiradoresCodificados": {'+
                            '"crearGiradorDTO": {'+
                              '"identificacionEmisor": 8909848433,'+
                              '"fkIdClasePersona": 1,'+
                              '"cuentaGirador": 224949,'+
                              '"fkIdTipoDocumento": 1,'+
                              '"nombresNat_Nat": "Paula",'+
                              '"numeroDocumento": 1023877810,'+
                              '"primerApellido_Nat": "Ardila",'+
                              '"mensajeRespuesta": "SDL.SE.0169: El girador ya existe y se actualizo la informacion"'+
                            '} } } }'
                    );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
            }
        }

        @isTest static void giradorJuridicoTest(){
            Account cuentaNuevo = new Account();
            Opportunity oportunidadNuevo = new Opportunity();

            cuentaNuevo = new TestDataFactory().newAccountJuridica();  
            cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
            update cuentaNuevo;

            oportunidadNuevo.AccountId = cuentaNuevo.Id;
            oportunidadNuevo.Name = 'Nombre Oportunidad';
            oportunidadNuevo.StageName = 'En Estudio';
            oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
            oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
            oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
            oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
            oportunidadNuevo.Identificador_proceso__c = '111111';
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

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IT_Girador_Juridico_test_Mock()); 
            //IT_ServicioGiradores_ws.cobertura();
            //IT_ConstruccionJSON_cls.cobertura();
            String res1 = IT_Girador_ctr.listadoGiradores(cotizacion.Id);
            String res2 = IT_Girador_ctr.integraGirador(cotizacion.Id);
            // System.assert(res1 != null);
            // System.assert(res2 != null);            
            Test.stopTest();

        }

    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     15-07-2020
    ************************************************************************************************/
    public class IT_Girador_Juridico_test_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(
                    '{'+
                        '"response": {'+
                          '"solicitudCredito": {'+
                            '"radicado": 6548,'+
                            '"oficina": 1102,'+
                            '"idProceso": 9396'+
                          '},'+
                          '"encabezado": {'+
                            '"fecha": "2020-07-15T17:02:59",'+
                            '"usuario": "Rafael Cardona",'+
                            '"operacion": "CREACIONGIRADORES",'+
                            '"origen": "SALESFORCE",'+
                            '"destino": "DECEVAL",'+
                            '"mensaje": {'+
                              '"descripcion": "(SDL.SE.0000): El girador ya existe y se actualizo la informacion",'+
                              '"estado": "OK"'+
                            '}'+
                          '},'+
                          '"CreacionGiradoresCodificados": {'+
                            '"crearGiradorDTO": {'+
                              '"listaRepresentantesLegales": {'+
                                '"numIdentificacion": 10235566,'+
                                '"tipoIdentificacion": 2,'+
                                '"idTipoRepresentante": 1'+
                              '},'+
                              '"numeroCelular": 3168998457,'+
                              '"razonSocial_Jur": "juridico",'+
                              '"identificacionEmisor": 8909848433,'+
                              '"fkIdClasePersona": 2,'+
                              '"cuentaGirador": 224948,'+
                              '"fkIdTipoDocumento": 4,'+
                              '"numeroDocumento": 901158411,'+
                              '"correoElectronico": "jurr@gmail.com",'+
                              '"mensajeRespuesta": "SDL.SE.0169: El girador ya existe y se actualizo la informacion"'+
                            '} } } }'
                    );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
            }
        }

        @isTest static void pagareNaturalTest(){
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
          
        cuentaNuevo = new TestDataFactory().newAccount();  
          cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
          cuentaNuevo.Sueldo_Honorario__c = 3000;
          cuentaNuevo.Cual__c = 'cuales';
          //cuentaNuevo.OtroIngresos__c = 3000;
          cuentaNuevo.Ingresos_conyuge__c = 3000;
          cuentaNuevo.Hogar__c = 3000;
          cuentaNuevo.Educacion__c = 3000;
          //cuentaNuevo.Otros_gastos__c = 3000;
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
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.newInstance(2022,05,15);
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

        Asociacion_cuenta_contacto__c asociacionAval = new Asociacion_cuenta_contacto__c();
        asociacionAval.Cliente__c            = cuentaNuevo.id;
        asociacionAval.Contacto__c           = contactoNuevo.id;
        asociacionAval.Oportunidad__c        = oportunidadNuevo.id;
        asociacionAval.RepresentanteLegal__c = false;
        asociacionAval.Name = 'Representante legal';
        insert asociacionAval;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IT_Pagare_Juridico_test_Mock()); 
        IT_Pagare_ctr.creacionPagare(cotizacion.Id);
        Test.stopTest();
    }

        /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     15-07-2020
    ************************************************************************************************/
    public class IT_Pagare_Juridico_test_Mock implements HttpCalloutMock{   
        public HTTPResponse respond(HTTPRequest request) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(
                  '{'+
                    '"response": {'+
                      '"solicitudCredito": {'+
                        '"radicado": 54481,'+
                        '"oficina": 11,'+
                        '"idProceso": 259562'+
                      '},'+
                      '"encabezado": {'+
                        '"fecha": "2020-11-06T23:39:58",'+
                        '"usuario": "Rafael Cardona",'+
                        '"operacion": "PAGAREDECEVAL",'+
                        '"origen": "SALESFORCE",'+
                        '"destino": "DECEVAL",'+
                        '"mensaje": {'+
                          '"descripcion": "(SDL.SE.0000): SDL.SE.0000: Exitoso. - Todos los pagare se crearon exitosamente.",'+
                          '"estado": "OK"'+
                        '}'+
                      '},'+
                      '"CreacionPagaresCodificado": {'+
                        '"documentoPagareServiceDTO": {'+
                          '"creditoReembolsableEn": 2,'+
                          '"otorganteTipoId": 1,'+
                          '"idClaseDefinicionDocumento": 501,'+
                          '"otorganteNumId": 15365843,'+
                          '"tipoPagare": 2,'+
                          '"idDocumentoPagare": 1092457,'+
                          '"nitEmisor": 8909848433,'+
                          '"mensajeRespuesta": "Pagare insertado exitosamente"'+
                        '} } } }' );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
            }
        }
}
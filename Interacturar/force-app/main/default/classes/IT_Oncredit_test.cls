/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Deceval
* @descripcion      Clase Test IT_Oncredit_Test

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-JUL-2020   Rafael Cardona (RC)           Creacion Clase Test.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
global with sharing class IT_Oncredit_test {

    @isTest
    public static void testFirmantes(){
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

        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        
		

        Test.startTest();
        
        Opportunity oppToTest = [select Id, Respuesta_Oportunidad__c, AccountId, (select Id from Quotes)
                             from Opportunity
                             where StageName = 'Crédito Aprobado' and Identificador_proceso__c != null and NomApe_Ben2__c != null
                             limit 1];
        
        Asociacion_cuenta_contacto__c asociacionAval = new Asociacion_cuenta_contacto__c();
        asociacionAval.Cliente__c            = cuentaNuevo.id;
        asociacionAval.Contacto__c           = contactoNuevo.id;
        asociacionAval.Oportunidad__c        = oppToTest.id;
        asociacionAval.RepresentanteLegal__c = false;
        asociacionAval.Name = 'Aval';
        insert asociacionAval;
        
        Asociacion_cuenta_contacto__c asociacionAval2 = new Asociacion_cuenta_contacto__c();
        asociacionAval2.Cliente__c            = cuentaNuevo.id;
        asociacionAval2.Contacto__c           = contactoNuevo.id;
        asociacionAval2.Oportunidad__c        = oppToTest.id;
        asociacionAval2.RepresentanteLegal__c = true;
        asociacionAval2.Name = 'Representante legal';
        insert asociacionAval2;
        
        IT_Oncredit_ctr.firmantes(oppToTest.Id);
        IT_Oncredit_ctr.interfazOnCredit();
        IT_Oncredit_ctr.consultaOportunidad(oppToTest.Id);
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(oppToTest);
        Test.setMock(HttpCalloutMock.class, new IT_OnCedit_ws_test_Mock());
        IT_Oncredit_ctr.firmantesSystematized(opps);
        
        Test.stopTest();
    }
    
    global class IT_OnCedit_ws_test_Mock implements HttpCalloutMock{   
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }
}
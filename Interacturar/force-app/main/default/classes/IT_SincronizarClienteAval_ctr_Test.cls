@isTest(SeeAllData=true)
public with sharing class IT_SincronizarClienteAval_ctr_Test {
    
    @isTest
    static void sincronizaClienteAval_Test(){
        Contact contactoNuevo = new Contact();
        try{
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;
        IT_SincronizarClienteAval_ctr.sincronizaClienteAval(contactoNuevo.Id);
        }catch(Exception e){
            System.debug('Error en la ejecución');
        }
    }

    @isTest
    static void sincronizaClienteAval_Test2(){
        Contact contactoNuevo = new Contact();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
        // try{
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        IT_SincronizarClienteAval_ctr obj = new IT_SincronizarClienteAval_ctr();
        IT_SincronizarClienteAval_ctr.cambiaFalso(contactoNuevo);

        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        insert aso;


        IT_SincronizarClienteAval_ctr.sincronizaClienteAval(contactoNuevo.Id);
        // }catch(Exception e){
        //     System.debug('Error en la ejecución');
        // }
    }

}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test IT_ConvierteAval

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-ABR-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
private with sharing class IT_ConvierteAval_Test {    
    
    @isTest static void convertirAvalEnCliente_Test(){
        Contact contactoNuevo = new Contact();
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
      
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;
        IT_ConvierteAval obj = new IT_ConvierteAval();
        IT_ConvierteAval.convertirAvalEnCliente( contactoNuevo.Id );
    }
    
}
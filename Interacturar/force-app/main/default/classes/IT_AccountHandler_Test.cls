/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase handler del Trigger de Account

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   1-MAY-2020  Rafael Cardona (RC)            Clase que se encarga de la logica del trigger de Account.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
public class IT_AccountHandler_Test {
    @isTest static void test_1(){
        Test.startTest();
        Account cuentaNuevo = new Account();
        
        cuentaNuevo = new TestDataFactory().newAccount();  
        
        
        Famiempresa__c fami = new TestDataFactory().newFamiempresa();
        
        fami.Cliente_relacionado__c = cuentaNuevo.Id;
        fami.Numero_de_empleados__c = 4;
        update fami;     
        Opportunity oportunidadNuevo = new Opportunity();
        
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        oportunidadNuevo.Respuesta_Oportunidad__c = 'OK';
        oportunidadNuevo.Origen_Integracion__c = 'ORACLE';
        oportunidadNuevo.Famiempresa_relacionada__c = fami.Id;
        oportunidadNuevo.Fecha_consulta_Datacredito__c = Date.today();
        oportunidadNuevo.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert oportunidadNuevo;        
        
        cuentaNuevo.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId();
        
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        cuentaNuevo.Sueldo_Honorario__c = 2000;
        cuentaNuevo.Cual__c = 'cual';
        cuentaNuevo.Otros_ingresos_familiares__c = 2000;
        cuentaNuevo.Ingresos_conyuge__c = 2000;
        cuentaNuevo.Hogar__c = 2000;
        cuentaNuevo.Educacion__c = 2000;
        cuentaNuevo.Otros_egresos_familiares__c = 2000;
        cuentaNuevo.Alquiler__c = 2000;
        cuentaNuevo.Prestamos__c = 2000;
        IT_AccountHandler_cls.cobertura();
       // update cuentaNuevo;    
        Test.stopTest();
    }
    
}
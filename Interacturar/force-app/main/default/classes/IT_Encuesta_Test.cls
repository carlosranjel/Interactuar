/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test IT_TriggerEncuesta , IT_EncuestaHandler_cls

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha        Autor                         Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   6-JUN-2020   Rafael Cardona (RC)           Creacion Clase Test.
**************************************************************************************************************
**/
@isTest(seeAllData=false)
public class IT_Encuesta_Test {

    @isTest static void Test_1(){
        Account cuentaNuevo = new Account();
        cuentaNuevo = new TestDataFactory().newAccount();
        
        Opportunity oportunidadNuevo = new Opportunity();
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;
        
        Encuesta__c enc = new Encuesta__c();
        enc.Cliente__c = cuentaNuevo.Id;
        enc.Oportunidad__c = oportunidadNuevo.Id;
        enc.CumpleRequisitosLey__c = 'Si';
        insert enc;
    }
}
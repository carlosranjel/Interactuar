/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Trigger Encuesta

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   2-JUN-2020   Rafael Cardona (RC)           Control que impide la creacion de mas de una
                                                              encuesta por opp
**************************************************************************************************************
**/
trigger IT_TriggerEncuesta on Encuesta__c (
    before insert, before update, before delete,
    after  insert, after  update, after  delete, after undelete) {

        if(Trigger.isbefore){
            if(Trigger.isInsert){ 
                IT_EncuestaHandler_cls.cantidadOportunidades(Trigger.isExecuting,Trigger.newMap,Trigger.old,Trigger.new);                
            }             
        }
}
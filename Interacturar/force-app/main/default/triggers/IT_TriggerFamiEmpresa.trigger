/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Trigger Fami Empresa

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   06-AGO-2019  Rafael Cardona (RC)           Creacion Trigger.
             2.0   1-MAY-2020   Rafael Cardona (RC)           Se agrega control para campos de famiEmpresa cuando se cumplen criterios en opp
**************************************************************************************************************
**/
trigger IT_TriggerFamiEmpresa on Famiempresa__c ( 
 before insert, before update, before delete,
 after  insert, after  update, after  delete, after undelete) {

    if(Trigger.isbefore){
        if(Trigger.isInsert){
            IT_FamiEmpresaHandler_cls.beforeInsert(Trigger.isExecuting,Trigger.newMap,Trigger.new);
        }else
        if(Trigger.isUpdate){   
            IT_FamiEmpresaHandler_cls.bUControlCampos(Trigger.isExecuting,Trigger.newMap,Trigger.old,Trigger.new);
            IT_FamiEmpresaHandler_cls.beforeUpdate(Trigger.isExecuting,Trigger.newMap,Trigger.new); 
        }             
    }else if(Trigger.isAfter){        
        if(Trigger.isInsert){ 
            IT_FamiEmpresaHandler_cls.afterInsert(Trigger.isExecuting,Trigger.newMap,Trigger.new); 
        }else if(Trigger.isUpdate ){ 
            IT_FamiEmpresaHandler_cls.afterUpdate(Trigger.isExecuting,Trigger.newMap,Trigger.new,Trigger.old);            
        }
    } 
}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Trigger Account

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   1-MAY-2020   Rafael Cardona (RC)           Control para campos de Account cuando se cumplen criterios en opp
**************************************************************************************************************
**/
trigger IT_TriggerAccount on Account (
    before insert, before update, before delete,
    after  insert, after  update, after  delete, after undelete) {

        if(Trigger.isbefore){
            if(Trigger.isInsert){                
            }else if(Trigger.isUpdate){   
               IT_AccountHandler_cls.bUControlCampos(Trigger.isExecuting,Trigger.newMap,Trigger.old,Trigger.new);                
            }             
        }else if(Trigger.isAfter){       
            if(Trigger.isInsert){                 
            }else if(Trigger.isUpdate ){       
                IT_AccountHandler_cls.llamaServicioCliente(Trigger.old, Trigger.new);
            }
        }

}
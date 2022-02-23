/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @proyecto         Interactuar
* @descripcion      Trigger de oportunidad
* @test             IT_TriggerOpportunity_test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   24-SEP-2020   Álvaro Ortega (AO)           Desencadenador de oportunidad
**************************************************************************************************************
**/
trigger IT_TriggerOpportunity on Opportunity (after insert, after update) {
    if(Trigger.isAfter){    
        if(Trigger.isInsert){  
            // Después de insertar
            IT_TriggerOpportunityHandler_cls.afterInsert(Trigger.newMap, Trigger.new);
        }else if(Trigger.isUpdate ){
            // Después de actualizar
            IT_TriggerOpportunityHandler_cls.afterUpdate(Trigger.newMap, Trigger.old, Trigger.new);
        }
    }
   if(Trigger.isBefore){
       if(Trigger.isUpdate){
      	IT_TriggerOpportunityHandler_cls.beforeUpdate(Trigger.newMap, Trigger.old);
           
       }

        
    }
}
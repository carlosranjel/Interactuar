/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @proyecto         Interactuar
* @descripcion      Trigger de Contacto
* @test             IT_TriggerContact_test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   13-OCT-2020   Álvaro Ortega (AO)           Desencadenador de contacto
**************************************************************************************************************
**/
trigger IT_TriggerContact on Contact (after insert, before insert, after update, after delete) {
    if(Trigger.isAfter){   
        if(Trigger.isInsert){  
            // Después de insertar
            IT_TriggerContactHandler_cls.afterInsert(Trigger.newMap, Trigger.new);
        }else if(Trigger.isUpdate ){
            // Después de actualizar
            IT_TriggerContactHandler_cls.afterUpdate(Trigger.newMap, Trigger.old, Trigger.new);
        }
        else if(Trigger.IsDelete){
            //Despues de borrar
            IT_TriggerContactHandler_cls.afterDelete(Trigger.old);  
        }
    }else if(Trigger.isBefore){
        if(Trigger.isInsert){  
            // antes de insertar
            IT_TriggerContactHandler_cls.beforeInsert(Trigger.newMap, Trigger.new);
            IT_ContactHandler_cls.cedulasDuplicadas(Trigger.isExecuting,Trigger.newMap,Trigger.old,Trigger.new); 
        }else if(Trigger.IsUpdate){
            IT_ContactHandler_cls.cedulasDuplicadas(Trigger.isExecuting,Trigger.newMap,Trigger.old,Trigger.new); 
        }else if(Trigger.IsDelete){
            //antes de borrar 
        }
    } 
}
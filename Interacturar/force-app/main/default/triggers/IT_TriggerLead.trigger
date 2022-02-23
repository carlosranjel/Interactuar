trigger IT_TriggerLead on Lead (
 before insert, before update, before delete,
 after  insert, after  update, after  delete, after undelete) {
     
     if(Trigger.isbefore){
         if(Trigger.isInsert){
         }else if(Trigger.isUpdate){             
         }else if(Trigger.isDelete){   }     
     }else if(Trigger.isAfter){        
         if(Trigger.isInsert){          
         }else if(Trigger.isUpdate ){
             IT_LeadHandler_cls.asignaTipoRegistroOportunidad(Trigger.isExecuting,Trigger.newMap,Trigger.new);
             IT_LeadHandler_cls.asignaAvalRepEnJuridico(Trigger.new, Trigger.old);
         }
     }                                    
                                    
}
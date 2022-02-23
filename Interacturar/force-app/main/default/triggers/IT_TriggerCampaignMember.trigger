trigger IT_TriggerCampaignMember on CampaignMember (
    before insert, before update, before delete,
    after  insert, after  update, after  delete, after undelete) {

    if(Trigger.isbefore){
        if(Trigger.isInsert){      
            IT_CampaignMemberHandler_cls.verificaMovil(Trigger.newMap,Trigger.new,Trigger.old);           
        }else if(Trigger.isUpdate){  
            //IT_CampaignMemberHandler_cls.verificaMovil(Trigger.newMap,Trigger.new,Trigger.old);                        
        }             
    }else if(Trigger.isAfter){       
        if(Trigger.isInsert){                 
        }else if(Trigger.isUpdate ){                          
        }
    }

}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Axel Landa
* @proyecto         Interactuar
* @descripcion      Trigger de QuoteLineItem
* @test             IT_TriggerQuoteLineItemHandler_Test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   16-MAR-2021   Axel Landa (AL)              Desencadenador de QuotLineItem
**************************************************************************************************************
**/
trigger IT_TriggerQuoteLineItem on QuoteLineItem (after update,before update){
    if(Trigger.isBefore) {
        if(Trigger.isUpdate){  
            system.debug('valida Campo');
            IT_TriggerQuoteLineItemHandler_cls.validaCampo(Trigger.old,Trigger.new);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isUpdate){   
            system.debug('quoteLineItemTrigger');
            IT_TriggerQuoteLineItemHandler_cls.consultaScoreUpdate(Trigger.old,Trigger.new); 
           
        }    
    } 
}
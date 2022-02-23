/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Axel Landa
* @proyecto         Interactuar
* @descripcion      Handler del trigger IT_TriggerQuoteLineItem
* @test             IT_TriggerQuoteLineItemHandler_Test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
1.0   16-MAR-2021   Axel Landa (AL)              Handler del trigger IT_TriggerQuoteLineItem
**************************************************************************************************************
**/
public class IT_TriggerQuoteLineItemHandler_cls {
    public static void validaCampo(List<QuoteLineItem> lstQuoteLineItem,List<QuoteLineItem> lstNewQuoteLineItem){  
        System.debug('lstQuoteLineItem' + lstQuoteLineItem);
        List<ID> listId;
        Opportunity opp;
        Quote quote;
        Campaign campaign;
        quote =  [SELECT Id, Quote.OpportunityId FROM Quote where Id =: lstQuoteLineItem[0].QuoteId];
        opp =  [SELECT Id, CampaignId From Opportunity where Id =: quote.OpportunityId];
        System.debug('opp' + opp);
        try{
            campaign = [Select Id,Type from Campaign   where Id =: opp.CampaignId and Campaign.RecordType.DeveloperName =:'Campana_con_retorno'];   
            system.debug('campaign' + campaign);
            if(campaign.Type == 'Crédito Ágil'){
                if( lstNewQuoteLineItem[0].Plazo_meses__c > lstQuoteLineItem[0].Plazo_meses__c )
                {
                    Trigger.new[0].addError('El valor de plazos meses únicamente puede ser disminuido, ya que se encuentra relacionado con una Campaña de Subtipo Crédito Ágil ');
                }else if(lstNewQuoteLineItem[0].UnitPrice > lstQuoteLineItem[0].UnitPrice ){
                    Trigger.new[0].addError('El valor de Precio únicamente puede ser disminuido, ya que se encuentra relacionado con una Campaña de Subtipo Crédito Ágil.');
                    
                }
            }
        }catch(Exception ex) {
            system.debug('ex' + ex.getMessage());
        }
        
        
        
        
    }
    public static void consultaScoreUpdate (List<QuoteLineItem> lstQuoteLineItem,List<QuoteLineItem> lstNewQuoteLineItem){
        map<String, Quote> mapQuote = new map<String, Quote>();
 
        list<String> listQuote = new list<String>();
        list<String> listOpportunity = new list<String>();
       
        system.debug('lstNewQuoteLineItem[k].Observacion_Score__c' + lstNewQuoteLineItem );
        for (QuoteLineItem itemO:lstQuoteLineItem){
            listQuote.add(itemO.QuoteId);            
        } 
        for(Quote item: [SELECT id, IsSyncing, OpportunityId, Opportunity.Account.Tipo_de_identificacion__c,RecordType.DeveloperName  from Quote where id in :listQuote]){
            mapQuote.put(item.Id,item);
             
        }
        for(Integer k=0; k < lstQuoteLineItem.size(); k++){
   
            
            Quote objQuote = mapQuote.get(lstQuoteLineItem[k].QuoteId);
        
            
            if(objQuote.RecordType.DeveloperName == 'Solicitud_de_credito'){
                System.debug('Es cotizacion solicitud de credito.');
                if (!objQuote.IsSyncing && objQuote.Opportunity.Account.Tipo_de_identificacion__c == 'Nit' && !system.isFuture() && !system.isBatch()){
                    IT_TriggerQuoteLineItemHelper.actualizaJuridico(lstQuoteLineItem[k].Id);
                    
                }else if(!system.isFuture() && !system.isBatch()){
                    system.debug('future');
                    if(!objQuote.IsSyncing){
                        system.debug('antes de validacion observacion score');
                        if( lstQuoteLineItem[k].Observacion_Score__c != null  ){    
                            system.debug('llamando a la consulta score');
                            IT_TriggerQuoteLineItemHelper.consultaServicio(lstQuoteLineItem[k].Id);
                        }else if(lstQuoteLineItem[k].Score__c == null && lstQuoteLineItem[k].Observacion_Score__c == null && lstQuoteLineItem[k].Producto_de_Cotizacion_de_Autogestion__c != True){
                            system.debug('llamando a la consulta score else if');
                            IT_TriggerQuoteLineItemHelper.consultaServicio(lstQuoteLineItem[k].Id);                        
                        } 
                    }else{
                        system.debug('no ira a la consulta score');
                        
                        
                    }
                }else{
                    System.debug('no es system future');
                }
            }
        }
    }
    
}
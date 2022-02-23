public class migracionFondo {
     @future(callout=true)
    public static void migrarCampo(){
        //Map<Id,QuoteLineItem> mapQuote = new Map<Id,QuoteLineItem>([SELECT id, Quote.OpportunityId,Quote.Opportunity.Fondo__c,Fondo__c FROM QuoteLineItem]);
  
        List<QuoteLineItem> qlineItem = new List<QuoteLineItem>([SELECT id, Quote.OpportunityId,Quote.Opportunity.Fondo__c,Fondo__c FROM QuoteLineItem Where Fondo__c = '' limit 10000 ]);             
        //List<QuoteLineItem> qlineItem2 = new List<QuoteLineItem>();
        //qlineItem2.addAll(qlineItem);
        for(Integer k=0; k < qlineItem.size(); k++){ 
             
           
          qlineItem.get(k).Fondo__c = qlineItem.get(k).Quote.Opportunity.Fondo__c;
         
        }
        //system.debug(qlineItem);
        if(!Test.isRunningTest()){
        	database.update(qlineItem);
 		}	
    }
}
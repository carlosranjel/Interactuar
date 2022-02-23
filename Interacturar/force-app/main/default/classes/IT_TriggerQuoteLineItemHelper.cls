/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Axel Landa
* @proyecto         Interactuar
* @descripcion      Helper del trigger IT_TriggerQuoteLineItem
* @test             IT_TriggerQuoteLineItemHandler_Test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   16-MAR-2021   Axel Landa (AL)              Helper del trigger IT_TriggerQuoteLineItem
**************************************************************************************************************
**/
public class IT_TriggerQuoteLineItemHelper {
    
    public static String idQuoteLineItem;
    public static String estadoA;
    public static String scoreA;
    public static String descripcionA;
    
    public class respuesta
    {
        public String estado;
        public String score;
        public String descripcion;
        public String mensajeError;	
    }
    
    
    @future(callout=true)
    public static void actualizaJuridico (String idCotizacion)
    {
		QuoteLineItem listQuoteLineItem = [SELECT Id,PricebookEntryId, Score__c, QuoteId, Plazo_meses__c,Periodo_Gracias_Meses__c,Quantity,UnitPrice,Fondo__c,QuoteLineItem.Product2.ProductCode from QuoteLineItem where Id =: idCotizacion];        	
        listQuoteLineItem.Score__c =  'Persona Juridica';
        listQuoteLineItem.Observacion_Score__c = null;
        listQuoteLineItem.Puntaje_Score__c = -1;
         update listQuoteLineItem;    
   		     
    }
    @future(callout=true)
    public static void consultaServicio(String idCotizacion){
        system.debug('consultaServicio Future');
  		system.debug(idCotizacion);
        QuoteLineItem listQuoteLineItem = [SELECT Id,PricebookEntryId, Score__c, QuoteId, Plazo_meses__c,Periodo_Gracias_Meses__c,Quantity,UnitPrice,Fondo__c,QuoteLineItem.Product2.ProductCode from QuoteLineItem where Id =: idCotizacion];        	
        listQuoteLineItem.Plazo_meses__c = Integer.valueOf(listQuoteLineItem.Plazo_meses__c);
		listQuoteLineItem.Periodo_Gracias_Meses__c = Integer.valueOf(listQuoteLineItem.Periodo_Gracias_Meses__c); 
		listQuoteLineItem.Quantity = Integer.valueOf(listQuoteLineItem.Quantity);
        listQuoteLineItem.UnitPrice = Integer.valueOf(listQuoteLineItem.UnitPrice);
        IT_ModeloScore_cls.ResponseDTO responseDto  =  IT_ModeloScore_cls.consultaScore(listQuoteLineItem.QuoteId,listQuoteLineItem);
        system.debug('responseDto: '+ responseDto);
        respuesta Respuesta = new respuesta();
        
        if(responseDto.encabezado.mensaje.estado != 'ERROR' )
        {
            system.debug('Servicio da OK desde el consumo de servicio desde trigger');
            system.debug('score ' +  responseDto.cuerpo.score);
            system.debug('descripcion ' +  responseDto.cuerpo.descripcion); 
             system.debug('error ' +  responseDto.encabezado.mensaje.descripcion); 
            system.debug('responseDto.cuerpo.score'+ responseDto.cuerpo.score);
            listQuoteLineItem.Score__c = responseDto.cuerpo.descripcion;
           listQuoteLineItem.Observacion_Score__c = null;
            listQuoteLineItem.Puntaje_Score__c = Integer.valueOf(responseDto.cuerpo.score);
            update listQuoteLineItem;            
        }else{
            system.debug('Servicio da error un error en los datos o un error en el consumo desde el trigger');
 
            system.debug('score ' +  responseDto.cuerpo.score);
            system.debug('descripcion ' +  responseDto.cuerpo.descripcion);
           system.debug('mensaje error ' + responseDto.encabezado.mensaje.descripcion);
           listQuoteLineItem.Score__c = null;
            listQuoteLineItem.Observacion_Score__c = responseDto.encabezado.mensaje.descripcion;
            listQuoteLineItem.Puntaje_Score__c = 0;
            update listQuoteLineItem;
        }
    }
    
}
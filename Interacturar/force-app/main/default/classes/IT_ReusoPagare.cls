/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Reuso de pagare

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   3-AGO-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_ReusoPagare {

    
    private static final String OK              = 'OK';
    private static final String ES_NULO         = null;
    private static final String OK_PAGARE       = 'PAGARE-OK';    
    private static final String SI_REUSAR       = 'SI-REUSAR';
    private static final String NO_REUSAR       = 'NO-REUSAR';    
    private static final String REUSAR_PAGARE   = 'REUSAR PAGARE';
    private static final String MENSAJE         = ' - OPORTUNIDAD: ';
    private static final String CREDITOAPROBADO = 'Crédito Aprobado';

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se verifica si se debe reusar el pagare de una oportunidad anterior
    *Date: 27-7-2020
    **************************************************************************************/
    public static String validaReusoPagare(Quote cotizacion , List<ID> lstIDop){
        String reusarPagare;         
        String retorno = NO_REUSAR;
        List<Quote> lstQuote = consultaCotizacionAnterior( cotizacion );
        System.debug('lista quote: '+ lstQuote);
        for(Quote qu: lstQuote){
            if( validacionesActivo( qu ) ){
                retorno = validacionesAvalistas( cotizacion, qu , lstIDop );  // quote completar
                if( SI_REUSAR == retorno ){ break; }
            }else{
                retorno = NO_REUSAR;
            }
        }
        return retorno;                      
      }
  

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Busca la ultima cotizacion creada que sea de la misma cuenta, este sincronizada 
               y el pagare se haya  creado satisfactoriamente 
    *Date: 03-8-2020
    *********************************************************************************************/
    public static List<Quote> consultaCotizacionAnterior( Quote cotizacion ){
        System.debug('cue: '+cotizacion.Opportunity.AccountId + ' ' +cotizacion.Opportunity.Account.NAME);
        if (!Schema.sObjectType.Quote.fields.Name.isAccessible() ) {  return new List<Quote>();  }
        return [SELECT id,EstadoIntegracionPagare__c, IsSyncing, idDocumentoPagare__c, OpportunityId, 
               Opportunity.Respuesta_Oportunidad__c, Opportunity.SyncedQuoteId, Opportunity.StageName,
               (SELECT id, Identificador_Radicado_OR__c FROM QuoteLineItems LIMIT 1)
               FROM Quote WHERE Id !=: cotizacion.Id AND IsSyncing = true
               AND idDocumentoPagare__c !=: ES_NULO AND EstadoIntegracionPagare__c =: OK_PAGARE
               AND AccountId =: cotizacion.Opportunity.AccountId
               order by createdDate desc LIMIT 6]; 
      }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se busca el activo y su fecha de cancelacion 
    *Return:  Si devuelve FALSE significa que no se debe reusar el pagare
    *Date: 03-8-2020
    *********************************************************************************************/
    public static Boolean validacionesActivo( Quote quote ){
        List<Asset> lstAsset;
        if( quote != null ){
            lstAsset = consultaActivoAnterior( quote );
            if( lstAsset.size() > 0){
                return validaFechaPagare( lstAsset[0] );
            }else{
                return false;
            }
        }else{
            return false;
        }
    }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta activo con el radico del producto de la cotizacion
    *Date: 03-8-2020
    *********************************************************************************************/
    public static List<Asset> consultaActivoAnterior( Quote cotizacion ){
        if( (cotizacion.QuoteLineItems).size() > 0 &&  cotizacion.QuoteLineItems[0].Identificador_Radicado_OR__c != ES_NULO ){
            if (!Schema.sObjectType.Asset.fields.Name.isAccessible() ) {  
                return new List<Asset>();  
            }
            return [SELECT id,Identificador_Radicado__c, Fecha_de_cancelacion__c
                    FROM Asset WHERE Identificador_Radicado__c =: cotizacion.QuoteLineItems[0].Identificador_Radicado_OR__c LIMIT 1];
        }else{
            return new List<Asset>();
        }         
      }

    /****************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Fecha actual menos fecha de cancelacion del activo son mas de 2 años, se debe crear un pagare nuevo 
    *Return:  Si devuelve FALSE significa que no se debe reusar el pagare
    *Date: 03-8-2020
    *****************************************************************************************************************/
      public static Boolean validaFechaPagare(Asset vo){   
        if( vo.Fecha_de_cancelacion__c != null ){
            if( masDeDosAnios(vo) ||  mayorMes(vo) ||  igualMes(vo) ){
                return false;
            }else{
                return true;
            }
        }else{ return true;  }
      }

    /****************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Si devuelve TRUE significa que no se debe reusar el pagare 
    *Date: 05-9-2020
    *****************************************************************************************************************/
    public static Boolean masDeDosAnios(Asset vo){
        if( System.today().Year()  - vo.Fecha_de_cancelacion__c.Year()  > 2 ){
            return true;
        }else{   return false;  } 
    }
    /****************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Si devuelve TRUE significa que no se debe reusar el pagare 
    *Date: 05-9-2020
    *****************************************************************************************************************/
    public static Boolean mayorMes(Asset vo){
        if( System.today().Month() - vo.Fecha_de_cancelacion__c.Month() > 0 && System.today().Year() - vo.Fecha_de_cancelacion__c.Year() == 2 ){
            return true;
        }else{  return false;  } 
    }
    /****************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Si devuelve TRUE significa que no se debe reusar el pagare 
    *Date: 05-9-2020
    *****************************************************************************************************************/
    public static Boolean igualMes(Asset vo){
        if( System.today().Day()   - vo.Fecha_de_cancelacion__c.Day()  >= 0 &&
            System.today().Month() - vo.Fecha_de_cancelacion__c.Month() == 0 && 
            System.today().Year()  - vo.Fecha_de_cancelacion__c.Year()  == 2 ){
            return true;
        }else{  return false;  } 
    }

    /****************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se buscan los avalistas de la oportunidad anterior para ser comparados con los actuales
    @Param cotizacion: Cotizacion actual
    @Param quote:   Cotizacion anterior
    @Param lstIDop:    ID oportunidad actual
    *Date: 03-8-2020
    *****************************************************************************************************************/
      public static String validacionesAvalistas( Quote cotizacion , Quote quote, List<ID> lstIDop ){        
        List<Id> idisOpp         = seleccionaOportunidades( quote ); 
        if( idisOpp.size() == 0 ){ return NO_REUSAR; }
        List<Opportunity> lstOpp = consultaOppAnterior( idisOpp );
        Map<String,Asociacion_cuenta_contacto__c> mapAvalistas = identificaAvalesAsociados( lstOpp );
        List<Asociacion_cuenta_contacto__c> lstAscc = IT_GestorDeConsultas_cls.consultaAsociacionAval( lstIDop );
        
        if( comparaAvales( lstAscc, mapAvalistas) == SI_REUSAR ){
            try{
                cotizacion.idDocumentoPagare__c = quote.idDocumentoPagare__c;
                update cotizacion;
                return SI_REUSAR;
            }catch(Exception e){
                return REUSAR_PAGARE + MENSAJE + cotizacion.Opportunity.Name;
            }
        }else{
            return NO_REUSAR;
        }   
      }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Validamos que la oportunidad este sincronizada satisfactoriamente
    *Date: 03-8-2020
    *********************************************************************************************/
    public static List<Id> seleccionaOportunidades( Quote qu ){
        List<Id> lstIdOpp = new List<Id>();
        System.debug('var: '+ qu.Opportunity.SyncedQuoteId);
        System.debug('var: '+ qu.Opportunity.Respuesta_Oportunidad__c);
        System.debug('var: '+ qu.Opportunity.Respuesta_Oportunidad__c.contains(OK));
        if( qu.Opportunity.SyncedQuoteId != ES_NULO && qu.Opportunity.Respuesta_Oportunidad__c != ES_NULO && 
            qu.Opportunity.StageName == CREDITOAPROBADO && qu.Opportunity.Respuesta_Oportunidad__c.contains(OK)){
                lstIdOpp.add(qu.OpportunityId);
        }
        return lstIdOpp;
      }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Traemos la oportunidad y sus asociaciones de avalistas
    *Date: 03-8-2020
    *********************************************************************************************/
    public static List<Opportunity> consultaOppAnterior( List<Id> idisOpp ){
        if ( idisOpp.size() == 0 ||
            !Schema.sObjectType.Opportunity.fields.Name.isAccessible() ||
            !Schema.sObjectType.Asociacion_cuenta_contacto__c.fields.Name.isAccessible() ) {
                 return new List<Opportunity>();  
        }
        return [SELECT id,Respuesta_Oportunidad__c, SyncedQuoteId, 
               (SELECT id,Oportunidad__c, Cliente__c, Contacto__c, RepresentanteLegal__c, Contacto__r.Numero_de_identificacion__c FROM Asociaciones_oportunidad__r)
               FROM Opportunity WHERE Id =: idisOpp];
      }

    /*************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se mapean las asociaciones teniendo como key el numero de documento del contacto
    *Date: 27-7-2020
    **************************************************************************************************************/
    public static Map<String,Asociacion_cuenta_contacto__c> identificaAvalesAsociados( List<Opportunity> opps){
        Map<String,Asociacion_cuenta_contacto__c> mapAvalistas = new Map<String,Asociacion_cuenta_contacto__c>();
        if( opps.size() > 0 && (opps[0].Asociaciones_oportunidad__r).size() > 0 ){
        for ( Asociacion_cuenta_contacto__c ob : opps[0].Asociaciones_oportunidad__r ) {    
            mapAvalistas.put(ob.Contacto__r.Numero_de_identificacion__c,ob);
        }}
        return mapAvalistas;
      }

    /*************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Compara los avales (contact) de oportunidad encontrada, contra los avales de la oportunidad actual
    *@Param     lstAscc : asociacion cuenta contacto de la oportunidad actual
    *@Param mapAvalistas : map de los avales asociados a la anterior oportunidad encontrada en la misma cuenta
    *Date: 27-7-2020
    **************************************************************************************************************/    
    public static String comparaAvales(List<Asociacion_cuenta_contacto__c> lstAscc, Map<String,Asociacion_cuenta_contacto__c> mapAvalistas){
    System.debug(' '+lstAscc.size() + ' - ' + mapAvalistas.size() );    
    String reusarPagare = NO_REUSAR;
    if( lstAscc.size() == 0 && mapAvalistas.size() == 0 ){
        reusarPagare = SI_REUSAR;
    }else
    if( lstAscc.size() ==  mapAvalistas.size() ){
        for (Asociacion_cuenta_contacto__c ob : lstAscc) {
            System.debug('rl: '+ ob);
            System.debug('rl: '+ ob.Contacto__r.Numero_de_identificacion__c);
            System.debug('mrl: '+ mapAvalistas);
            if( mapAvalistas.containsKey( ob.Contacto__r.Numero_de_identificacion__c )  &&
                ob.RepresentanteLegal__c == mapAvalistas.get( ob.Contacto__r.Numero_de_identificacion__c ).RepresentanteLegal__c ){              
                reusarPagare = SI_REUSAR;              
            }else{
                reusarPagare = NO_REUSAR;
                break;
            }
        }
    } 
    System.debug('->'+reusarPagare); 
    return reusarPagare;
    }  
}
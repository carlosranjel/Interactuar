/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   8-9-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_MiembroCampania {

    private static final String ES_NULO = null;
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se busca el miembro de campaña que le pertenezca a la cuenta de la oportunidad
    *Date: 8-9-2020
    ******************************************************************************************/
    public static CampaignMember buscaMiembroDeCampana(Opportunity opp){
        List<CampaignMember> leadMCampana;
        List<CampaignMember> conMCampana;
        leadMCampana = consultaPorLead( opp );
        System.debug('Lead: '+ leadMCampana );
        
        if( leadMCampana.size() == 0 ){
            conMCampana = consultaPorContacto( opp );
            System.debug('Contact: '+ conMCampana );
            if( conMCampana.size() == 0 ){
              CampaignMember miembro = new CampaignMember();
                return miembro;
            }else{
                return conMCampana[0];
            }          
        }else{
            return leadMCampana[0];
        }    
      }
        
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Busca elmiembro de campaña por el lead
    *Date: 8-9-2020
    ******************************************************************************************/
    public static List<CampaignMember> consultaPorLead( Opportunity opp){
        System.debug('could lead: ');
        if ( !Schema.sObjectType.CampaignMember.fields.Name.isAccessible() ) {   return new List<CampaignMember>();  }
        return [SELECT ContactId,Id,LeadId, Lead.isconverted, lead.ConvertedAccountId, lead.recordType.developerName, Contact.IsPersonAccount, CreditoSaldoCargo__c, Fondo__c 
                FROM CampaignMember 
                where lead.ConvertedAccountId =: opp.AccountId AND CampaignId =: opp.CampaignId 
                LIMIT 1];        
    }
    
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Busca elmiembro de campaña por el contacto
    *Date: 8-9-2020
    ******************************************************************************************/
    public static List<CampaignMember> consultaPorContacto( Opportunity opp ){
        if(  opp.Account.IsPersonAccount ){
            System.debug('personal account');
            return [SELECT ContactId,Id,LeadId, Lead.isconverted, lead.ConvertedAccountId, lead.recordType.developerName, 
                    Contact.IsPersonAccount, CreditoSaldoCargo__c, Fondo__c
                    FROM CampaignMember where ContactId =: opp.Account.PersonContactId  AND CampaignId =: opp.CampaignId LIMIT 1];
        }else{
            System.debug(' juridica ');
            if ( !Schema.sObjectType.Contact.fields.Name.isAccessible() ) {   return new List<CampaignMember>();  }
            List<Contact> lstContactos = [SELECT Id FROM Contact WHERE AccountId =: opp.AccountId ];
            
            return [SELECT ContactId,Id,LeadId, Lead.isconverted, lead.ConvertedAccountId, lead.recordType.developerName, 
                    Contact.IsPersonAccount, CreditoSaldoCargo__c, Fondo__c  FROM CampaignMember 
                    WHERE ContactId IN: lstContactos AND CampaignId =: opp.CampaignId LIMIT 1];      
        }
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Actualiza campos en la oportunidad
    *Date: 14-9-2020
    ******************************************************************************************/
    public static void oportunidadDeMiembroCampana( Opportunity opp ){
      List<CampaignMember> leadMCampana;
      List<CampaignMember> conMCampana;
      leadMCampana = consultaPorLead( opp );
      System.debug('Lead: '+ leadMCampana );
      
      if( leadMCampana.size() == 0 ){
          conMCampana = consultaPorContacto( opp );
          System.debug('Contact: '+ conMCampana );
          if( conMCampana.size() > 0 ){
            actualizaOportunidad(opp , conMCampana[0] );
          }          
      }else{
        actualizaOportunidad(opp , leadMCampana[0] );
      }
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Actualiza campos en la oportunidad
    *Date: 14-9-2020
    ******************************************************************************************/
    public static void actualizaOportunidad( Opportunity opp , CampaignMember mc ){
      try{
        if( mc.Fondo__c != ES_NULO ){
          Map<Integer,String> fondoDesembolso = metadataFondoDesembolso( Integer.valueOf(mc.Fondo__c) );
          List<QuoteLineItem> lstQuoteLineItem = IT_GestorDeConsultas_cls.consultaProductoPorCotizacion(opp);
            
          //opp.Fondo__c = (fondoDesembolso.size() > 0 ) ? fondoDesembolso.get( Integer.valueOf(mc.Fondo__c) ) : null;
          opp.CreditoSaldoCargo__c = mc.CreditoSaldoCargo__c;
            
          lstQuoteLineItem[0].Fondo__c = (fondoDesembolso.size() > 0 ) ? fondoDesembolso.get( Integer.valueOf(mc.Fondo__c) ) : null;
            
          if( lstQuoteLineItem[0].Fondo__c != ES_NULO ){
              update opp;
              update lstQuoteLineItem[0];
          }
          System.debug('Actualizo opp ');
        }
      }catch(DmlException ex){
        System.debug('Error en la actualizacion de la oportunidad: '+ ex.getStackTraceString() );
      }
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Metadata type
    *Date: 14-9-2020
    ******************************************************************************************/
    public static Map<Integer,String> metadataFondoDesembolso(Integer cod){
      Map<Integer,String> fondoDesembolso = new Map<Integer,String>();        
      for(FondoDesembolsoCredito__mdt fd: [SELECT MasterLabel,Codigo__c,Nombre__c 
                                           FROM FondoDesembolsoCredito__mdt WHERE Codigo__c =: cod]){
          if( fd.Codigo__c != null && fd.Nombre__c != ES_NULO){
            fondoDesembolso.put(Integer.valueOf(fd.Codigo__c),fd.Nombre__c);
          }
      }
      return fondoDesembolso;
    }
}
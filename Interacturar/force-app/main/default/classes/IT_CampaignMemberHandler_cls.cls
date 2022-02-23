/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Autogestion
* @descripcion      Clase controladora para el trigger de Miembros de campaña

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   12-Sep-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_CampaignMemberHandler_cls {

    static Map<Id,Contact> mapaContactos;
    static Map<Id,Lead> mapaProspectos;
    static Map<String,Id> mapaMCyC = new Map<String,Id>();
    

    /**************************************************************************************************************
   *Author:  Rafael Cardona
   *Function: Valida que los numeros movil de los contactos o prospectos que van asociados a los miembros de campaña
    que se estan insertando no existan en los miembros de campaña existentes, para evitar que hayan varios 
    miembros de campaña con la misma campaña y el mismo numero movil.
   *Date: 12-9-2020
   **************************************************************************************************************/
    public static void verificaMovil(Map<Id,CampaignMember> mapNew, List<CampaignMember> lstNew, List<CampaignMember> lstOld ){
        set<Id> idContacto = new set<Id>();
        set<Id> idLead     = new set<Id>();
        set<ID> idCampana = new set<ID>();

        for (CampaignMember mc : lstNew) {
            idCampana.add(mc.CampaignId);

            if( mc.ContactId != null  ){
                idContacto.add( mc.ContactId );
            }else if( mc.LeadId != null ){
                idLead.add( mc.LeadId );
            }
        }

        if( idContacto.size() > 0){            
            System.debug('--idContacto--'+ idContacto);
            mapaContactos = mapaContactos( idContacto );
        }
        if( idLead.size() > 0 ){
            System.debug('--idLead--'+ idLead);
            mapaProspectos = mapaProspectos( idLead );
        }
        if( idCampana.size() > 0 ){
            System.debug('--idCampana--'+ idCampana);
            mapaCampanias();                     
        }
        controlaAsigna( lstNew, idCampana );
    }

    /**************************************************************************************************************
   *Author:  Rafael Cardona
   *Function: Consulta contactos que se estan asociando al miembro de campaña
   *param idContacto: ids de contactos asociados a los nuevos miembros de campaña
   *Date: 12-9-2020
   **************************************************************************************************************/
    public static Map<Id,Contact> mapaContactos( set<ID> idContacto ){
        return new Map<Id,Contact>([ Select id, Account.Movil_empresa__c
                                     FROM Contact 
                                     WHERE Id IN: idContacto and Account.Movil_empresa__c != null]);
    }

    /**************************************************************************************************************
   *Author:  Rafael Cardona
   *Function: Consulta prospectos que se estan asociando al miembro de campaña
   *param idLead: ids de leads asociados a los nuevos miembros de campaña
   *Date: 12-9-2020
   **************************************************************************************************************/
    public static Map<Id,Lead> mapaProspectos( set<ID> idLead ){
        return new Map<Id,Lead>([ Select id, ConvertedAccount.Movil_empresa__c
                                  FROM Lead 
                                  WHERE Id IN: idLead and ConvertedAccount.Movil_empresa__c != null]);
    }

    /**************************************************************************************************************
   *Author:  Rafael Cardona
   *Function: Consulta miembros de campaña que se estan asociandos a campañas
   *param idCampana: ids de campaña asociados a los nuevos miembros de campaña
   *Date: 12-9-2020
   **************************************************************************************************************/
    public static void mapaCampanias( ){
        for(CampaignMember mc: [ Select id, MovilMiembro__c, CampaignId, ContactId, LeadId
                                FROM CampaignMember
                                WHERE MovilMiembro__c != null and Campaign.Status in ('En ejecución', 'Planeada') and Campaign.Type = 'Credito digital']){
             mapaMCyC.put(mc.MovilMiembro__c,mc.CampaignId);
        }
        System.debug('total mc: '+ mapaMCyC);
    }

    /******************************************************************************
   *Author:  Rafael Cardona
   *Function: Itera sobre los miembros da campaña que se estan insertando
   *Date: 12-9-2020
   ********************************************************************************/
    public static void controlaAsigna( List<CampaignMember> lstNew, set<ID> idCampanas){
        
        Map<Id, Campaign> mapCampanias = new Map<Id, Campaign>([select Id, Type
                                                             from Campaign
                                                             where Id in :idCampanas]);
        
        for (Integer k=0; k < lstNew.size(); k++) {
            if(mapCampanias.containsKey(lstNew[k].CampaignId) && mapCampanias.get(lstNew[k].CampaignId).Type == 'Credito digital'){
                System.debug('--lstNew[k]--'+ lstNew[k]);
                controlaAsignaContacto( lstNew[k], k );                
                controlaAsignaProspecto( lstNew[k], k);
            }
            
        }
    }

    /*******************************************************************************************
   *Author:  Rafael Cardona
   *Function: Valida si el telefono que viene desde el contacto ya existe en un miembro de campaña 
              asociado a la campaña que se esta insertando con el miembro de campaña
    *Variable mapaContactos: Contactos que van asociados a los miembros de campaña que se estan insertando
    *Variable mapaMCyC: Mapa que relaciona el (key)numero movil con la (value)campaña asociada a un mimbro de campaña que ya existe
   *Date: 12-9-2020
   *********************************************************************************************/
    public static void controlaAsignaContacto( CampaignMember cm , Integer k){
        if( cm.ContactId != null &&
            mapaContactos.get(cm.ContactId) != null ){
            if( mapaMCyC.get( mapaContactos.get(cm.ContactId).Account.Movil_empresa__c ) != null ){
                System.debug('--repetido--'+ mapaContactos.get(cm.ContactId).Account.Movil_empresa__c );
                Trigger.new[k].addError('No pueden existir dos Miembros de Campaña con el mismo Móvil en Campañas activas');
            }
            else{
                cm.MovilMiembro__c = mapaContactos.get(cm.ContactId).Account.Movil_empresa__c;
            }                    
        }
    }

    /*******************************************************************************************
   *Author:  Rafael Cardona
   *Function: Valida si el telefono que viene desde el prospecto ya existe en un miembro de campaña 
              asociado a la campaña que se esta insertando con el miembro de campaña
    *Variable mapaProspectos: Prospectos que van asociados a los miembros de campaña que se estan insertando
    *Variable mapaMCyC: Mapa que relaciona el (key)numero movil con la (value)campaña asociada a un mimbro de campaña que ya existe
   *Date: 12-9-2020
   *********************************************************************************************/
    public static void controlaAsignaProspecto( CampaignMember cm , Integer k ){
        if( cm.LeadId != null && 
            mapaProspectos.get(cm.LeadId) != null ){
            if( mapaMCyC.get( mapaProspectos.get(cm.LeadId).ConvertedAccount.Movil_empresa__c ) != null ){
                System.debug('--Trigger.new[k]--'+ Trigger.new[k]);
                Trigger.new[k].addError('No pueden existir dos Miembros de Campaña con el mismo Móvil en Campañas activas');
            }
            else{
                cm.MovilMiembro__c = mapaProspectos.get(cm.LeadId).ConvertedAccount.Movil_empresa__c;
            }                   
        }
    }
}
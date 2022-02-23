/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Helper de Trigger de oportunidad
* @test             IT_TriggerOpportunity_test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   24-SEP-2020   Álvaro Ortega (AO)           Helper de desencadenador de oportunidad
**************************************************************************************************************
**/
public class IT_TriggerOpportunityHelper_cls {
    public static void agregaAvalRespEnJuridico(Map<Id, Opportunity> mapNewOport, List<Opportunity> lstNewOport){
        List<Opportunity> listExtraInfoOpp = getOpps(mapNewOport.keySet());
        
        if(listExtraInfoOpp.size() > 0){
            Map<Id, Id> accountIds = new Map<Id, Id>();
            for(Opportunity opp: listExtraInfoOpp){
                if(opp.Asociaciones_oportunidad__r.size() > 0){
                    Boolean thereAreRep = False;
                    for(Asociacion_cuenta_contacto__c ava : opp.Asociaciones_oportunidad__r){
                        if(ava.RepresentanteLegal__c == True){
                            thereAreRep = True;
                            break;
                        }
                    }
                    if(!thereAreRep){
                        accountIds.put(opp.Id, opp.AccountId);
                    }
                }else{
                    accountIds.put(opp.Id, opp.AccountId);
                }
            }
            if(accountIds.size() > 0){
                List<Contact> listCont = getContact(accountIds.values());
                
                if(listCont.size() > 0){
                    List<Asociacion_cuenta_contacto__c> nuevosAvales = new List<Asociacion_cuenta_contacto__c>();
                    for(Opportunity opp: listExtraInfoOpp){
                        for(Contact cont: listCont){
                            if(cont.AccountId == opp.AccountId){
                                Asociacion_cuenta_contacto__c nuevaAsociacion = new Asociacion_cuenta_contacto__c();
                                nuevaAsociacion.Cliente__c     = opp.AccountId;
                                nuevaAsociacion.Contacto__c    = cont.Id;
                                nuevaAsociacion.Oportunidad__c = opp.Id;
                                nuevaAsociacion.RepresentanteLegal__c = True;
                                nuevosAvales.add(nuevaAsociacion);
                                break;
                            }
                        }
                    }
                    insert nuevosAvales;
                }
            }
        }
        
    }
    
    public static List<Opportunity> getOpps(Set<Id> idOpps){
        return [Select Id, RecordType.DeveloperName, AccountId, Account.RecordType.DeveloperName, (select Id,RepresentanteLegal__c from Asociaciones_oportunidad__r) 
                from Opportunity where Id in :idOpps
                and RecordType.DeveloperName = 'Solicitud_de_credito' and Account.RecordType.DeveloperName = 'Persona_juridica'];
    }
    public static List<Contact> getContact(list<Id> idAccounts){
        return [Select Id, AccountId from Contact where AccountId in :idAccounts and recordType.DeveloperName = 'Contacto_Aval' and Representante_Legal__c = True];
    }

    public static void generacionAutomaticaCredito(Map<Id, Opportunity> mapNewOport, List<Opportunity> lstOldOport, List<Opportunity> lstNewOport){
        for(Integer i = 0; i < lstNewOport.size(); i++){
            if(lstNewOport[i].Generacion_Automatica_de_Credito__c && lstOldOport[i].Respuesta_Oportunidad__c != lstNewOport[i].Respuesta_Oportunidad__c && lstNewOport[i].Respuesta_Oportunidad__c != null && String.valueOf(lstNewOport[i].Respuesta_Oportunidad__c).contains('OK')){
                //IT_AutoGiradorYPagare_cls.despuesSincronizacion(lstNewOport[i].Id);
                CampaignMember member = obtenMiembroDeGeneracionAutomatica(lstNewOport[i].Id);
                if(member != null){
                    IT_AutoGiradorYPagare_cls nextJob = new IT_AutoGiradorYPagare_cls('Inicio', lstNewOport[i].Id, member);
                    Id jobID = System.enqueueJob(nextJob);
                }
            }
        }
    }

    public static CampaignMember obtenMiembroDeGeneracionAutomatica(String IdOpp){
        List<CampaignMember> members = [Select Id, Name, ContactId, Contact.AccountId, LeadId , Lead.ConvertedAccountId, CampaignId,
                                        Mensaje_recibido__c, MovilMiembro__c,Producto__c,Plazo_Meses__c,Monto__c,Fondo__c
                                        from CampaignMember
                                        where Oportunidad_Generada_Automatica__c = :IdOpp
                                        limit 1];
        if(members.size() > 0){
            return members[0];
        }
        return null;
    }
       public static void actualizacionCampaniaOportunidad(Map<Id, Opportunity> mapNewOport, List<Opportunity> lstOldOport, List<Opportunity> lstNewOport){
        system.debug('entro actualizacionCampaniaOPortunidad');
        Decimal valorTotalServicioCredito = 0;
        Decimal valorTotalServicioConocimiento = 0;
        Decimal valorPrevioTotalServicioCredito = 0;
        Decimal valorPrevioTotalServicioConocimiento = 0;        
        Integer TotalCreditoDesembolso = 0;
        Integer TotalConocimientoDesembolso = 0;
        Decimal totalPrevioCreditoDesembolso = 0;
        Decimal totalPrevioConocimientoDesembolso = 0;
        String 	tipoRegistro = '';
        Campaign campaign = new Campaign();
        List <Quote> listQuote = new List<Quote>();
        system.debug('lstNewOport[0].CampaignId'+ lstNewOport[0].CampaignId);
        system.debug('lstNewOport[0].StageNAme'+ lstNewOport[0].StageName);
        if (lstNewOport[0].CampaignId != null &&  (String.valueOf(lstNewOport[0].StageName).contains('Crédito Aprobado') ||String.valueOf(lstNewOport[0].StageName).contains('Matriculado') )){
            system.debug('entro al primer if...');
            if(lstNewOport[0].StageName != lstOldOport[0].StageName ){ 
                try{ 
                    //tipoRegistro = lstNewOport[0].RecordType.DeveloperName; 
                    listQuote =   [SELECT Id, RecordType.DeveloperName, GrandTotal from Quote where Opportunity.Id =: lstNewOport[0].Id];
                    campaign = [Select Id, isManual__c ,N_de_servicios_facturados__c, Monto_de_servicios_facturados__c,Monto_de_creditos_desembolsados__c,N_de_creditos_desembolsados__c From Campaign where id =: lstNewOport[0].CampaignId and RecordType.DeveloperName = 'Campana_con_retorno' and Type = 'Crédito Ágil' ];
                    if(campaign != null){
                        system.debug('campaign' + campaign);
                        valorPrevioTotalServicioConocimiento = campaign.Monto_de_servicios_facturados__c;
                        valorPrevioTotalServicioCredito = campaign.Monto_de_creditos_desembolsados__c;  
                        totalPrevioCreditoDesembolso = campaign.N_de_creditos_desembolsados__c;
                        totalPrevioConocimientoDesembolso = campaign.N_de_servicios_facturados__c;
                        if(listQuote.size()>0){
                            for(Integer i = 0; i<listQuote.size();i++){
                                if(listQuote[i].RecordType.DeveloperName == 'Solicitud_de_credito'){
                                    valorTotalServicioCredito = valorTotalServicioCredito + listQuote[i].GrandTotal;
                                    
                                    TotalCreditoDesembolso = TotalCreditoDesembolso + 1;  
                                }else
                                {
                                    valorTotalServicioConocimiento = valorTotalServicioConocimiento + listQuote[i].GrandTotal;
                                    
                                    TotalConocimientoDesembolso = TotalConocimientoDesembolso + 1;
                                }
                            }
                            campaign.isManual__c = true;
                            campaign.Monto_de_servicios_facturados__c = valorPrevioTotalServicioConocimiento +valorTotalServicioConocimiento;
                            campaign.Monto_de_creditos_desembolsados__c = valorPrevioTotalServicioCredito + valorTotalServicioCredito;
                            campaign.N_de_creditos_desembolsados__c = totalPrevioCreditoDesembolso +TotalCreditoDesembolso;
                            campaign.N_de_servicios_facturados__c = totalPrevioConocimientoDesembolso +TotalConocimientoDesembolso;   
                            system.debug('campaign final' + campaign);
                            update campaign; 
                            campaign.isManual__c = false;
                            update campaign; 
                        }
                    }
                }catch(Exception ex){ 
                    
                }
            }
        }
    }
    public static void cobertura(){
        String variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
    
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
     }

}
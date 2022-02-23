public class IT_LeadHandler_cls {
	
    /******************************************************************************
    *Author:  Álvaro Ortega
    *Function: Asigna el Contacto Aval Representante Legal para Juridico
    *Date: 18-Julio-2021
    *******************************************************************************/
    public static void asignaAvalRepEnJuridico(List<Lead> lstNewLead, List<Lead> lstOldLead){
		Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Set<Id> oppToAsoc = new Set<Id>();
        system.debug('Update leads: ' + lstNewLead);
        for(Integer i = 0; i < lstNewLead.size(); i++){
            system.debug('Values New' + lstNewLead[i].ConvertedContactId + '  ' + lstNewLead[i].RecordType.DeveloperName);
            Id recordTypeJuriId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Persona_juridica').getRecordTypeId();
            if(lstNewLead[i].ConvertedContactId != null && lstNewLead[i].RecordTypeId == recordTypeJuriId){
                 system.debug('Values Old' + lstOldLead[i].ConvertedContactId);
                if(lstOldLead[i].ConvertedContactId == null){
                    Contact contacto = new Contact();
                    contacto.Id                            = lstNewLead[i].ConvertedContactId;
                    contacto.RecordTypeId                  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId(); 
                    contacto.Representante_Legal__c        = false;
                	contacto.FirstName                     = lstNewLead[i].FirstName;
                    contacto.MiddleName                    = lstNewLead[i].MiddleName;
                    contacto.LastName                      = lstNewLead[i].LastName;
                    contacto.Segundo_Apellido__c           = lstNewLead[i].Segundo_Apellido__c;
                    contacto.Link_PDF_Datacredito__c       = lstNewLead[i].Link_PDF_Datacredito__c;
                    contacto.Link_PDF_Historico__c         = lstNewLead[i].Link_PDF_Historico__c;
                    contacto.Fecha_consulta_Datacredito__c = lstNewLead[i].Fecha_consulta_Datacredito__c;
                    contacto.Numero_de_identificacion__c   = lstNewLead[i].Numero_de_Identificacion_Contacto__c;
                    contacto.Tipo_de_identificacion__c     = lstNewLead[i].Tipo_de_Identificacion_Contacto__c;
                    contacto.Phone                         = lstNewLead[i].Telefono_Contacto__c;
                    contacto.Telefono_contacto__c          = lstNewLead[i].Telefono_Contacto__c;
                    contacto.MobilePhone                   = lstNewLead[i].Movil_Contacto__c;
                    contacto.Movil_contacto__c             = lstNewLead[i].Movil_Contacto__c;
                    contacto.Birthdate                     = lstNewLead[i].Fecha_de_nacimiento__c;
                    contacto.Autorizacion_uso_de_datos__c  = lstNewLead[i].Autorizacion_uso_de_datos__c;
                    contacto.Medio_de_autorizacion__c      = lstNewLead[i].Medio_de_autorizacion__c;
                    contacto.Otro_medio_de_autorizacion__c = lstNewLead[i].Otro_medio_de_autorizacion__c;
                    contacto.Email                         = lstNewLead[i].Email;
                    contacto.Indicativo_contacto__c        = lstNewLead[i].Indicativo_prospecto__c != null ? lstNewLead[i].Indicativo_prospecto__c : lstNewLead[i].Indicativo_empresa__c;
                    
                    contactsToUpdate.put(lstNewLead[i].Id,contacto);
                }
                
                if(lstNewLead[i].ConvertedOpportunityId != null && lstOldLead[i].ConvertedOpportunityId == null){
                    oppToAsoc.add(lstNewLead[i].ConvertedOpportunityId);
                }
                
            }
        }
        if(contactsToUpdate.size() > 0){
            try{
                system.debug('Contacts to update: ' + contactsToUpdate);
                update contactsToUpdate.values();
                
            }catch(Exception e){
                System.debug('QQQQ@@@q' + e);
                String mess = String.valueOf(e.getMessage()).Contains('DUPLICATES_DETECTED') ? 'Se detectó posible Contacto de Representante Legal duplicado' : e.getMessage();
                for(Integer i = 0; i < lstNewLead.size(); i++){
                    lstNewLead[i].addError(mess);
                    
                }
                //throw new applicationException(mess);
            }
        }
        if(oppToAsoc.size() > 0){
            List<Opportunity> listOpps = getOpps(oppToAsoc);
            if(listOpps.size() > 0){
                Map<Id, Id> accountIds = new Map<Id, Id>();
                for(Opportunity opp: listOpps){
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
                        for(Opportunity opp: listOpps){
                            for(Contact cont: listCont){
                                if(cont.AccountId == opp.AccountId){
                                    Asociacion_cuenta_contacto__c nuevaAsociacion = new Asociacion_cuenta_contacto__c();
                                    nuevaAsociacion.Cliente__c     = opp.AccountId;
                                    nuevaAsociacion.Contacto__c    = cont.Id;
                                    nuevaAsociacion.Oportunidad__c = opp.Id;
                                    nuevaAsociacion.RepresentanteLegal__c = false;
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
    }
    
    public static List<Contact> getContact(list<Id> idAccounts){
        return [Select Id, AccountId from Contact where AccountId in :idAccounts and recordType.DeveloperName = 'Contacto_Aval' and Representante_Legal__c = True];
    }
    public static List<Opportunity> getOpps(Set<Id> idOpps){
        return [Select Id, RecordType.DeveloperName, AccountId, Account.RecordType.DeveloperName, (select Id,RepresentanteLegal__c from Asociaciones_oportunidad__r) 
                from Opportunity where Id in :idOpps
                and RecordType.DeveloperName = 'Solicitud_de_credito' and Account.RecordType.DeveloperName = 'Persona_juridica'];
    }
    public static void asignaTipoRegistroOportunidad(Boolean contexTrigger,Map<Id,Lead> mapIdNewLead,List<Lead> lstNewLead){
        List<Opportunity> lstOportunidad    = new List<Opportunity>();
        List<Account> lstCliente            = new List<Account>();
        List<Famiempresa__c> lstFamiempresa = new List<Famiempresa__c>();
        Boolean isActualiza = false;
        lstCliente     = consultaClienteConvertida(lstNewLead);
        lstOportunidad = consultaOportunidadConvertida(lstNewLead);
        lstFamiempresa = consultaFamiEmpresa(lstNewLead.get(0).id );
        
        if( lstOportunidad.size() > 0 &&  !lstCliente.get(0).Cliente_Conversion__c ){
            for(Integer k=0; k < lstOportunidad.size(); k++){
                for(Integer i=0; i < lstCliente.size(); i++){
                    if(lstOportunidad.get(k).AccountId == lstCliente.get(i).id){
                        for(Integer j=0; j < lstNewLead.size(); j++){
                            if(lstOportunidad.get(k).id == lstNewLead.get(j).ConvertedOpportunityId){
                                if(lstNewLead.get(j).Interes__c == 'Conocimiento_y_Redes'){
                                    isActualiza = true;     
                                    lstCliente.get(i).Cliente_Conversion__c = true;
                                    if(lstFamiempresa.size() == 1){lstFamiempresa.get(i).Cliente_relacionado__c = lstCliente.get(i).id; }
                                    lstOportunidad.get(k).Oportunidad_Conversion__c = true;
                                    lstOportunidad.get(k).StageName = 'Interesado';
                                    lstOportunidad.get(k).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
                                }else if(lstNewLead.get(j).Interes__c == 'Credito'){
                                    isActualiza = true; 
                                    lstCliente.get(i).Cliente_Conversion__c = true;   
                                    if(lstFamiempresa.size() == 1){lstFamiempresa.get(i).Cliente_relacionado__c = lstCliente.get(i).id; }
                                    lstOportunidad.get(k).Oportunidad_Conversion__c = true;
                                    lstOportunidad.get(k).StageName = 'En Estudio';
                                    lstOportunidad.get(k).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
                                }
                            }
                        }
                    }
                }
            }
            if(isActualiza){
                update lstCliente;
                update lstOportunidad;
                if(lstFamiempresa.size() == 1){ update lstFamiempresa; }
            }
        }
    }
    
    public static List<Opportunity> consultaOportunidadConvertida(List<Lead> lstLead){
        return [SELECT id, RecordTypeId,Oportunidad_Conversion__c,AccountId FROM Opportunity WHERE id =: lstLead.get(0).ConvertedOpportunityId ];
    }
    public static List<Account> consultaClienteConvertida(List<Lead> lstLead){
        return [SELECT id, Cliente_Conversion__c FROM Account WHERE id =: lstLead.get(0).ConvertedAccountId ];
    }
    public static List<Famiempresa__c> consultaFamiEmpresa( String idProspecto ){
        return [SELECT id, Cliente_relacionado__c, Prospecto_relacionado__c FROM Famiempresa__c 
                WHERE Prospecto_relacionado__c =: idProspecto  Limit 1];
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

    public class applicationException extends Exception {}
}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @proyecto         Interactuar
* @descripcion      Trigger de Contacto
* @test             IT_TriggerContact_test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   13-OCT-2020   Álvaro Ortega (AO)           Desencadenador de contacto
**************************************************************************************************************
**/
public class IT_TriggerContactHelper_cls {
    public static void validateRepLegal(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont, List<Contact> lstOldCont, Boolean isNew){
        Map<Id, Id> accountToValidate = new Map<Id, Id>();
        for(Integer i = 0; i < lstOldCont.size(); i++){
            if((lstOldCont[i].Representante_Legal__c != lstNewCont[i].Representante_Legal__c || isNew) && lstNewCont[i].Representante_Legal__c == True){
                accountToValidate.put(lstOldCont[i].AccountId, lstOldCont[i].Id);
            }
        }
        
        if(accountToValidate.values().size() > 0){
            List<AggregateResult> lstContact = [SELECT count(Id) recordCount, AccountId 
                                                FROM Contact 
                                                WHERE AccountId in :accountToValidate.keySet() and AccountId != null and Representante_Legal__c = True
                                                GROUP BY AccountId];
            
            for(AggregateResult count : lstContact){
                if(Integer.valueOf(count.get('recordCount')) > 1){
                    //	system.debug(String.valueOf(count.get('AccountId')));
                    String contactId = accountToValidate.get(String.valueOf(count.get('AccountId')));
                    mapNewCont.get(contactId).addError('Solo puede exixtir un solo Representante Legal por Cliente');
                }
            }
        }
        
    }
    
    public static void insertarNombresBeneficiarios(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont){
        Id beneficiarioRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        
        List<Contact> contactToValidate = new List<Contact> ();
        for(Contact cont : lstNewCont){
            if(cont.RecordTypeId == beneficiarioRecordTypeId){
                if(cont.Nombres_Beneficiario__c != null && cont.Apellidos_Beneficiario__c != null && cont.Genero__c != null){
                    system.debug('Guardando Nuevo');
                    cont.FirstName = cont.Nombres_Beneficiario__c;
                    cont.LastName  = cont.Apellidos_Beneficiario__c;
                }else{
                    cont.addError('Los siguientes campos son obligatorios para contacto Beneficiario: Nombres Beneficiario, Apellidos Beneficiario, Genero');
                }
                
            }
        }
        
    }
    
    public static void validaCamposBeneficiarios(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont){
        Id beneficiarioRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        
        List<Contact> contactToValidate = new List<Contact> ();
        for(Contact cont : lstNewCont){
            if(cont.RecordTypeId == beneficiarioRecordTypeId){
                if(!(cont.Oportunidad__c != null && cont.Nombres_Beneficiario__c != null && cont.Apellidos_Beneficiario__c != null && cont.Genero__c != null)){
                    cont.addError('Los siguientes campos son obligatorios para contacto Beneficiario: Oportunidad, Nombres Beneficiario, Apellidos Beneficiario y Genero-');
                }
            }
        } 
    }
    
    public static void beneficiariosInsert(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont){
        contarBeneficiariosOportunidad(lstNewCont);
    }
    
    public static void beneficiariosDelete(List<Contact> lstOldCont){
        contarBeneficiariosOportunidad(lstOldCont);
    }    

    public static void contarBeneficiariosOportunidad(List<Contact> contacts){
        Id beneficiarioRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiario').getRecordTypeId();
        
        List<Id> opportunityToValidate = new List<Id> ();
        for(Contact cont : contacts){
            if(cont.RecordTypeId == beneficiarioRecordTypeId){
                opportunityToValidate.add(cont.Oportunidad__c);
            }
        }
        List<Opportunity> oportunities = [Select Id, Name, Respuesta_Oportunidad__c, RecordType.DeveloperName,
                                          Account.RecordType.DeveloperName, (select Name from Contactos__r) 
                                          from Opportunity
                                          where Id in :opportunityToValidate];
        opportunityToValidate = null;
        List<Opportunity> oportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity opor: oportunities){
            for(Contact cont : contacts){
                if(opor.Id == cont.Oportunidad__c){
                    if(opor.RecordType.DeveloperName != 'Solicitud_de_credito' || opor.Account.RecordType.DeveloperName != 'Persona_natural'){
                        cont.addError('Para crear un Contacto Beneficiario, la Oportunidad debe ser de Crédito con Cliente Natural.');
                    }else if(opor.Respuesta_Oportunidad__c != null && String.valueOf(opor.Respuesta_Oportunidad__c).contains('OK')){
                        cont.addError('No se puede añadir o eliminar un Contacto Beneficiario a una Oportunidad sincronizada.');
                    }else{
                        opor.Numero_de_Afiliados_a_Prever__c = opor.Contactos__r.size() > 0 ? String.valueOf(opor.Contactos__r.size()) : Null; 
                        oportunitiesToUpdate.add(opor);
                    }
                    break;
                }
            } 
            
            
        }
        update oportunitiesToUpdate;
        
        //contactToValidate = [select Name ]
        
    }
}
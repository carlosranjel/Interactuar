public with sharing class Convert_Lead {
    public Convert_Lead() {}
/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Alejandro Gómez
*  Fecha:               Junio 12 de 2019
*  Decripción:          Metodo para ejecutar la conversion del prospecto (ConvertLead)
*  @version:            1.0
* ===================================================================================================================================
**/
    @InvocableMethod
    public static List<String> convertleadobject(List<String> LstIdsL){
        System.debug('lista: '+ LstIdsL);
        Boolean isDocUnico = false;
        Database.LeadConvert leadConverted = new Database.LeadConvert();
        leadConverted.setLeadId(LstIdsL[0]);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        leadConverted.setConvertedStatus(convertStatus.ApiName);
        //leadConverted.setDoNotCreateOpportunity(false);
       
		Lead candidato = [SELECT id,Tipo_de_identificacion__c,Numero_de_identificacion__c FROM Lead WHERE id =: LstIdsL[0] ];  
        System.debug('candidato: '+ candidato);     
        
        isDocUnico = consultaDocumento(candidato.Numero_de_identificacion__c);
        Database.LeadConvertResult lcr;
        if(isDocUnico){
            lcr = Database.convertLead(leadConverted);
            return new List<String>{lcr.getAccountId()}; }else{ throw new claseException('El número de documento ya existe');
        }           
    } 

    public static Boolean consultaDocumento(String identificacion){
        List<Account> lstCuenta = new List<Account>();
        lstCuenta = [SELECT id, Numero_de_identificacion__c FROM Account WHERE Numero_de_identificacion__c =: identificacion];
        if( lstCuenta.size() == 0 ){
            return true; }else{ return false;
        }
    }
    public class claseException extends Exception{}
}
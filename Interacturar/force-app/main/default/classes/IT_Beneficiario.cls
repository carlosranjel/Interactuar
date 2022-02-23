public with sharing class IT_Beneficiario {

    private static final String TIPO_REGISTRO = 'Beneficiario';
    
    @AuraEnabled
    public static string buscaContactosBeneficiario(String idOportunidad){
        if ( !Schema.sObjectType.Contact.fields.Name.isAccessible() ) {   return JSON.serialize(new List<Contact>());  }
        List<Contact> lstContactos = [SELECT id, Genero__c,Nombres_Beneficiario__c,Apellidos_Beneficiario__c 
                                      FROM Contact 
                                      WHERE Oportunidad__c =:idOportunidad and RecordType.DeveloperName =: TIPO_REGISTRO ];
        return JSON.serialize(lstContactos);
    }
    
    @AuraEnabled
    public static void eliminaBeneficiario(String idContacto){
        Contact con = new Contact();
        con.Id = idContacto;
        
        delete con;
    }
}
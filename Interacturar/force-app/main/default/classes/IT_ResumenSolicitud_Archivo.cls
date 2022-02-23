public with sharing class IT_ResumenSolicitud_Archivo {
    @InvocableMethod
    public static void cargaArchivoProcess(List<String> lstQuote){
        system.debug(lstQuote.get(0));
        
        cargaArchivo(lstQuote.get(0));
    } 
    
    public static void cargaArchivo(string idOportunidad){
        
        Opportunity opp = [Select id, Name,accountId,RecordType.DeveloperName from Opportunity where id  =: idOportunidad];
        
        string pagina,titulo,typeDoc;
        if(opp.RecordType.DeveloperName == 'Solicitud_de_credito'){
            
            system.debug('creara el archivo.');
            pagina = 'IT_ResumenSolicitud';
            titulo = 'Solicitud Archivo ' +opp.Name;
            list<ContentVersion> archivo = [Select id,ContentDocumentId from ContentVersion where Title=:titulo limit 1];
            if(archivo.size()>0){
                delete [Select id,Title,FileType from ContentDocument where id=:archivo[0].ContentDocumentId];
            }
            PageReference ref = new PageReference('/apex/'+pagina+'?id='+opp.AccountId+'&idOpp='+opp.Id);
            
            ContentVersion cont = new ContentVersion();
            cont.Title = titulo;
            cont.PathOnClient = 'file.pdf';
            if(Test.isRunningTest()){
            cont.VersionData = blob.valueOf('Unit.Test');                              
            }else{                
               cont.VersionData = ref.getContentAsPDF(); 
            }
            cont.Origin = 'H';
            insert cont;
                
            Id conDoc = [Select ContentDocumentId from ContentVersion where Id=:cont.Id].ContentDocumentId;
            ContentDocumentLink contentDocResumen = new ContentDocumentLink(ContentDocumentId = conDoc,LinkedEntityId = opp.Id,ShareType = 'I');
            insert contentDocResumen;
        }
        
    } 
}
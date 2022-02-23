/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase servicio web para el envio de documentacion a BPMS

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   16-JUL-2019  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public class IT_ServicioDocumentacionBPMS_cls {

    public static String servicioDocumentacionBPMS(String idOportunidad){        
        List<ContentDistribution> documentosPublicos = new List<ContentDistribution>();
		List<Opportunity> lstOportunidad = new List<Opportunity>();
		List<QuoteLineItem> lstpxc = new List<QuoteLineItem>();

        lstOportunidad = [SELECT id FROM Opportunity WHERE id=: idOportunidad];
		if(lstOportunidad.size() > 0)
        lstpxc = [SELECT id, Tipo_de_producto__c FROM QuoteLineItem 
                             WHERE Quote.OpportunityId =: lstOportunidad.get(0).id AND Tipo_de_producto__c = 'Credito' LIMIT 1];

        if(lstpxc.size() == 1){
            documentosPublicos.addAll(generaContenidoPublicoClasic(lstOportunidad.get(0)));
            documentosPublicos.addAll(generaContenidoPublicoLightning(lstOportunidad.get(0)));
            if(documentosPublicos.size() > 0){
                return 'OK enviar';
            }else{
                return 'Nada para enviar';
            }
        }else{
            return 'No Credito';
        }      
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se hace el filtro para saber si se llama el servicio de documentacion BPMS
    *Date: 16-7-2019
    **************************************************************************************/
    public static String peticionDocumentacionBPMS(String idOpp){
        Opportunity oportunidad   = [SELECT id, Identificador_proceso__c, Codigo_Oficina_OR_Asesor_Asignado__c  FROM Opportunity WHERE id =: idOpp];
        List<QuoteLineItem> lstpxc = [SELECT id, Tipo_de_producto__c,Identificador_Radicado_OR__c FROM QuoteLineItem 
                             WHERE Quote.OpportunityId =: oportunidad.id AND Tipo_de_producto__c = 'Credito' LIMIT 1];

        return procesoServicio(oportunidad,lstpxc.get(0));
    }

    /**********************************************************************
    *Author:  Rafael Cardona
    *Function: Se hace el request al servicio de documentacion BPMS
    *Date: 16-7-2019
    ***********************************************************************/
    public static String procesoServicio(Opportunity opp, QuoteLineItem prodCot){
        List<contentdocumentlink> docLinkEliminar = new List<contentdocumentlink>();
        List<UrlObjeto> lstUrlObjeto = new List<UrlObjeto>();
        Set<String> setNombre = new Set<String>();
        Set<String> setNombreEliminar = new Set<String>();
        Set<Id> setContentDocumentEliminar = new Set<Id>();
        Set<Id> setContentDocument = new Set<Id>();
        Http http = new Http();
        HttpRequest request;
        String json = ''; 
        String mensajeRespuesta = '';
        Boolean resEliminacion = false;
        Boolean resCreacionURL = false;
        Boolean diferenteStatusOk = false;
        
        for(ContentDocumentLink cd: [SELECT contentdocument.id, contentdocument.title, contentdocument.filetype 
                                     FROM contentdocumentlink WHERE linkedentityid =: opp.id]){
            setContentDocument.add(cd.contentdocument.id);
        }
        for(ContentVersion  dato: [SELECT id, Title FROM contentversion WHERE contentdocumentid IN: setContentDocument]){
            setNombre.add(dato.Title);
        }
        for(Attachment invoices : [select id, name, body from attachment WHERE ParentId =: opp.id] ){
            setNombre.add(invoices.name);
        }
        List<ContentDistribution> documentosPublicos = [SELECT ContentDownloadUrl, Id,Name,RelatedRecordId,ContentDocumentId FROM ContentDistribution WHERE Name IN: setNombre];
                
        if( documentosPublicos.size() > 0 ){
            request = IT_ParametrosWS_cls.parametrosDocumentacionBPMS();
            for(Integer k=0; k < documentosPublicos.size(); k++){
                json = documentacionBpmsJSON(documentosPublicos.get(k).ContentDownloadUrl, opp.Identificador_proceso__c, prodCot.Identificador_Radicado_OR__c, opp.Codigo_Oficina_OR_Asesor_Asignado__c,opp);// definir de donde se saca la info
                System.debug(k + '_Json salida: '+ json);                
                request.setBody(json);               
                HttpResponse response = http.send(request);
                system.debug(k + '_response-->'+response.getBody());
                claseJSON claseRespuesta = (claseJSON)System.JSON.deserialize(response.getBody(), claseJSON.class); 
                system.debug('claseRespuesta'+ claseRespuesta );
                
                if(response.getStatus() == 'OK' && response.getStatusCode() == 200 ){
                    UrlObjeto obj = new UrlObjeto();
                    obj.nombre       = documentosPublicos.get(k).Name;
                    obj.urlOrigen    = documentosPublicos.get(k).ContentDownloadUrl;
                    obj.urlRespuesta = claseRespuesta.cuerpo.contenido.url;
                    lstUrlObjeto.add(obj);
                    setNombreEliminar.add(documentosPublicos.get(k).Name);
                    setContentDocumentEliminar.add(documentosPublicos.get(k).ContentDocumentId);
                }else{
                    diferenteStatusOk = true;
                    mensajeRespuesta += ''+ documentosPublicos.get(k).Name +' = fallo Servicio ,';
                }
            }
            resCreacionURL = crearObjetoUrls(lstUrlObjeto,opp.id);
            if(resCreacionURL){resEliminacion = eliminarDocumentos(setNombreEliminar,opp.id,setContentDocumentEliminar,diferenteStatusOk);}
            
            if(resCreacionURL && resEliminacion){
                  if(!diferenteStatusOk){ mensajeRespuesta = 'Ok'; }                                
            }else if(resCreacionURL){                
                if(!resEliminacion){  mensajeRespuesta = 'Fallo eliminacion';  }
                else{                 mensajeRespuesta = 'Ok creacion';        }
            }
        }
        return mensajeRespuesta;
    }
    
    /***********************************************************************************
    *Author:  Rafael Cardona
    *Function: Se inserta el objeto que relaciona la url enviada con la url de respuesta
    *Date: 16-7-2019
    ************************************************************************************/
    public static Boolean crearObjetoUrls(List<UrlObjeto> lstUrlObjeto, String idOpp){
        List<Documento_URL__c> lstDocUrl = new List<Documento_URL__c>();     
        try{
        for(UrlObjeto obj: lstUrlObjeto){
            Documento_URL__c url = new Documento_URL__c();
            url.Nombre_del_Documento__c = obj.nombre;
            url.Documento__c            = idOpp;
            url.URL_Enviada__c          = obj.urlOrigen;
            url.URL_Respuesta__c        = obj.urlRespuesta;
            lstDocUrl.add(url);
        }
        insert lstDocUrl;
            return true;
        }catch(Exception ex){
            return false;
        }
    }
    
    /***********************************************************************************
    *Author:  Rafael Cardona
    *Function: Elimina los documento adjuntos a la oportunidad
    *Date: 16-7-2019
    ************************************************************************************/
    public static Boolean eliminarDocumentos(Set<String> nomEliminar, String idOpp, Set<Id> setContentDocumentEliminar, Boolean eliminaDoc){
        try{
           List<attachment> attEliminar = [select id, name, body from attachment WHERE name IN: nomEliminar AND ParentId =: idOpp];
            if(attEliminar.size() > 0){
                Delete attEliminar;
            }
            if(eliminaDoc){
                List<contentdocumentlink> linkEliminar = [SELECT contentdocument.id, contentdocument.title, contentdocument.filetype 
                    FROM contentdocumentlink WHERE linkedentityid =: idOpp AND contentdocument.id IN: setContentDocumentEliminar];
                if(linkEliminar.size() > 0){  Delete linkEliminar;   } 
            }else{
                List<contentdocumentlink> linkEliminar = [SELECT contentdocument.id, contentdocument.title, contentdocument.filetype 
                    FROM contentdocumentlink WHERE linkedentityid =: idOpp ];
                if(linkEliminar.size() > 0){  Delete linkEliminar;   } 
            }  
            return true;
        }catch(Exception ex){
            return false;
        }
    }
    

    /***********************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase de respuesta
    *Date: 16-7-2019
    ************************************************************************************/
    public class UrlObjeto{
        public String nombre;
        public String urlOrigen;
        public String urlRespuesta;
    }
    
    public class claseJSON{
        public cls_encabezado encabezado;
        public cls_cuerpo cuerpo;
    }
	class cls_encabezado {
		public String estado;	//Exito
		public String excepcion;	//1 - java.lang.NullPointerException:null
		public String fecha;	//2019-07-15T22:29:20
		public String identificador;	//12345
		public String mensaje;	//1 - java.lang.NullPointerException:null
		public String integracion;	//Documentacion bpms
		public String operacion;	//1
		public String origen;	//SALESFORCE
		public String destino;	//BPMS
	}
	class cls_cuerpo {
		public cls_contenido contenido;
	}
	class cls_contenido {
		public String url;	//
	}
    
        
    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de que los documentos adjuntos sean publicos. Para la version lightning
    *Date: 16-7-2019
    *********************************************************************************************/
    public static List<ContentDistribution> generaContenidoPublicoLightning(Opportunity opp){
        List<ContentDistribution> lstContentDistribucion = new List<ContentDistribution>();
        Set<Id> setContentDocument = new Set<Id>();
        Set<String> setNombre = new Set<String>();
        Set<String> nombreExcluidos = new Set<String>();
               
        for(ContentDocumentLink cd: [SELECT contentdocument.id, contentdocument.title, contentdocument.filetype 
                                         FROM contentdocumentlink WHERE linkedentityid =: opp.id]){
            setContentDocument.add(cd.contentdocument.id);
        }                                   

        List<ContentVersion> lstCVersion = [SELECT id, Title FROM contentversion WHERE contentdocumentid IN: setContentDocument];
        for(ContentVersion  dato: lstCVersion){
            setNombre.add(dato.Title);
        }

        List<ContentDistribution> encontrados = [SELECT ContentDownloadUrl, Id,Name,RelatedRecordId FROM ContentDistribution WHERE Name IN: setNombre];
        system.debug('NOMBRES: '+ encontrados);

        system.debug('for: '+ lstCVersion);
        for(ContentDistribution cd: encontrados){
            for(Integer k=0; k < lstCVersion.size(); k++){                
                if( cd.name == lstCVersion.get(k).Title ){
                nombreExcluidos.add(lstCVersion.get(k).Title);
                lstCVersion.remove(k);                    
                k--;
                }
            } 
        }
        system.debug('quedan: '+ lstCVersion);

        if( lstCVersion.size() > 0 ){
            for(ContentVersion contentVer: lstCVersion){
                ContentDistribution cd = new ContentDistribution();
                cd.Name                              = contentVer.Title;
                cd.ContentVersionId                  = contentVer.id;
                cd.PreferencesAllowViewInBrowser     = true;
                cd.PreferencesLinkLatestVersion      = true;
                cd.PreferencesNotifyOnVisit          = false;
                cd.PreferencesPasswordRequired       = false;
                cd.PreferencesAllowOriginalDownload  = true;
                lstContentDistribucion.add(cd);
            }
            insert lstContentDistribucion;
            return [SELECT ContentDownloadUrl, Id,Name,RelatedRecordId FROM ContentDistribution WHERE id IN: lstContentDistribucion OR Name IN: nombreExcluidos]; 
        }else{
            return encontrados;
        }
    }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de que los documentos adjuntos sean publicos. Para la version clasic
    *Date: 16-7-2019
    *********************************************************************************************/
    public static List<ContentDistribution> generaContenidoPublicoClasic(Opportunity opp){
        list<ContentVersion> contents = new list<ContentVersion>();
        list<ContentDistribution> dists = new list<ContentDistribution>();
        Set<String> nombreAtt = new Set<String>();
        Set<String> nombreExcluidos = new Set<String>();

        list<Attachment> invoices = [select id, name, body from attachment WHERE ParentId =: opp.id];
        nombreAtt.addAll(listaAttachmentEncontrados(invoices));

        List<ContentDistribution> encontrados = [SELECT ContentDownloadUrl, Id,Name,RelatedRecordId FROM ContentDistribution WHERE Name IN: nombreAtt];
        system.debug('NOMBRES: '+ encontrados);        

        system.debug('for: '+ invoices);
        for(ContentDistribution cd: encontrados){
            for(Integer k=0; k < invoices.size(); k++){
                if(cd.name == invoices.get(k).name){
                    nombreExcluidos.add(invoices.get(k).name);
                    invoices.remove(k);                    
                    k--;
                }
            } 
        }
        system.debug('quedan: '+ invoices);

        if(invoices.size() > 0){
            for(Attachment inv: invoices){
                ContentVersion cont = new ContentVersion();
                cont.Title = inv.Name;
                cont.PathOnClient =  inv.Name;
                cont.VersionData = inv.Body;
                contents.add(cont);
            }
            insert contents;

            for(ContentVersion cont : contents){
                ContentDistribution cd = new ContentDistribution();
                cd.name = cont.Title;
                cd.ContentVersionId = cont.id;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                dists.add(cd); 
            } 
            insert dists ;   
            System.debug('retorna insertados '+ dists );
            return  [SELECT ContentDownloadUrl, Id,Name,RelatedRecordId FROM ContentDistribution WHERE id IN: dists OR Name IN: nombreExcluidos];        
        }else{
            System.debug('retorna encontrados '+ encontrados );
            return encontrados;
        } 
    }

    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Llena set con  lista de nombres 
    *Date: 16-7-2019
    *********************************************************************************************/
    public static Set<String> listaAttachmentEncontrados(list<Attachment> invoices){
        Boolean isUpdate = false;
        Set<String> nombreAtt = new Set<String>();
         for(Attachment inv: invoices){
             if( (inv.name).length() > 70 ){
                inv.name = (inv.name).subString(0,70); 
                isUpdate = true;
             }         
            nombreAtt.add(inv.name);   
        }
        if(isUpdate){
            update invoices;
            for(Attachment inv: invoices){        
                nombreAtt.add(inv.name);   
            }
            return nombreAtt;
        }else{
            return nombreAtt;
        }
    }


    /********************************************************************************************
    *Author:  Rafael Cardona
    *Function: JSON que se envia 
    *Date: 16-7-2019
    *********************************************************************************************/
    public static String documentacionBpmsJSON(String urlDocumento, String idProceso, String idRadicado, String codOficina, Opportunity opp){
        idProceso  = ( idProceso == null || idProceso == 'null' || String.isBlank(idProceso)  ) ? '' : idProceso;
        idRadicado = ( idRadicado == null || idRadicado == 'null' || String.isBlank(idRadicado)  ) ? '' : idRadicado;
        codOficina = ( codOficina == null || codOficina == 'null' || String.isBlank(codOficina)  ) ? '' : codOficina;
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String json='{'+
        '"encabezado": {'+
            '"estado": 0,'+
            '"excepcion": null,'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+opp.id+'-'+numeroAleatorio+'",'+
            '"mensaje": null,'+
            '"integracion": "Sincronizar Documentación a BPMS",'+
            '"operacion": 0,'+
            '"origen": "SALESFORCE",'+
            '"destino": "BPMS"'+
        '},'+
        '"cuerpo": {'+
            '"contenido": {'+
            '"documentUrl": "'+urlDocumento+'",'+     // este lo generamos nosotros. url...          
            '"idProceso":   "'+idProceso+'",'+ // si idproceso es null o vacio enviar este, se debe sacar de la oportunidad  
            '"idRadicado":  "'+idRadicado+'",'+ // respuesta de la oportunidad cuando es un credito se almacena en la oportunidad , puede estar vacio ya que no se haya dado respuesta oportunidad
            '"idOficina":   "'+codOficina+'",'+ // se saca del codigo oficina asesor asignado de la oportunidad  
            '"idparentFiling": 1,'+ //quemado valor: 1
            '"data": null,'+ // quemado, se envia el dato o null
            '"idDt": "54",'+ // tipologia del documento codigo, string.
            '"physicalLocation": 1,'+ // quemado se envia, valor : 1
            '"idUser": "admin"'+ // por verificar....
            '}'+
        '}'+
        '}';
        return json;
    }

}
public without sharing class IT_Producto_Cotizacion_ctr {
    @AuraEnabled
    public static list<Product2> OtrosProduct2(string idCotizacion) {
        String valuelike= '%'+idCotizacion+'%';        
        Quote quote =[select id, Name, RecordType.DeveloperName from Quote where id=:idCotizacion];         
        list<Product2>listProduct2=[select id,Name,ProductCode,Codigo_portafolio__c, Identificador_portafolio__c, Identificador_grupo__c,Precio__c,Family, Tipo_de_servicio__c,RecordType.DeveloperName
                                    from Product2 where RecordType.DeveloperName =: quote.RecordType.DeveloperName and IsActive = true
                                    and id in (Select Product2Id from PriceBookEntry where isActive = true)
                                    //and (Name Like:valuelike)
                                    order by Name];
        return listProduct2;        
    }
    
    @AuraEnabled
    public static list<Product2> OtrosProduct(string idQuote, string nombre) {
        String valuelike= '%'+nombre+'%';
        system.debug(valuelike);
        system.debug('id' + idQuote);
        system.debug('lo que trae el componente: '+nombre);
        
        Quote quote = [select id, Name, RecordType.DeveloperName,OpportunityId  from Quote where id =: idQuote];
        Opportunity opp = [Select id,RecordType.DeveloperName from Opportunity where id =: quote.OpportunityId];
        system.debug('quote' + quote.OpportunityId);
        system.debug('recordtype' + opp.RecordType.DeveloperName);
        list<Product2>listProduct2=[select id,Name,ProductCode,Codigo_portafolio__c, Identificador_portafolio__c,
                                    Identificador_grupo__c,Precio__c,Family, Tipo_de_servicio__c
                                    from Product2 where RecordType.DeveloperName =: quote.RecordType.DeveloperName and (ProductCode Like:valuelike or Name like :valuelike)
                                    and id in (Select Product2Id from PriceBookEntry where isActive = true)
                                    order by Name];        
        return listProduct2;        
    }
       @AuraEnabled 
    public static String validaFondo(String cotizacionId,String fondo, Double unitPrice ,Integer quantity){
        try{
        IT_ValidacionAsigancionFondo_cls.ResponseDTO response = IT_ValidacionAsigancionFondo_cls.validaAsignacionFondo(cotizacionId, fondo, unitPrice, quantity);
  			system.debug('fondo ' + response);
            if(response.encabezado.mensaje.estado == 'OK'){
                    if(response.cuerpo.validacionFondo.aplica == 'SI'){
                        return 'OK';
                    }else{
                        return  response.cuerpo.validacionFondo.Descripcion;
                     }
                }else{
                    String mensaje = response.cuerpo.validacionFondo.Descripcion;
                    mensaje = mensaje.substringBefore(':');
                    mensaje = mensaje  + ' :'+ '\n';
                    mensaje = mensaje + response.cuerpo.validacionFondo.Descripcion.substringAfter(':'); 
                    return  mensaje;
                }
        }catch(Exception ex){
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static String consultaScore(String cotizacionId,Integer unitPrice,Integer quantity,Integer plazoMeses,Integer periodoGraciaMeses,String productCode)
    {
        QuoteLineItem quoteLineItem = new QuoteLineItem();
        quoteLineItem.UnitPrice = unitPrice;
        quoteLineItem.Quantity = quantity;
        quoteLineItem.Plazo_meses__c = plazoMeses;
        quoteLineItem.Periodo_Gracias_Meses__c = periodoGraciaMeses;
        quoteLineItem.Product2 = new Product2();
        quoteLineItem.Product2.ProductCode = productCode;        
        respuestaServicio response = new respuestaServicio();
         
            IT_ModeloScore_cls.ResponseDTO responseDto  =  IT_ModeloScore_cls.consultaScore(cotizacionId,quoteLineItem);
            if(responseDto.encabezado.mensaje.estado !='ERROR'  )
            {
                response.estado = 'OK';
                response.score = responseDto.cuerpo.score;
                response.descripcion = responseDto.cuerpo.descripcion;
                response.mensajeError = '';
                
            }else{
                response.estado = 'FAIL';
                response.score = '';
                response.descripcion = '';
                response.mensajeError = responseDto.encabezado.mensaje.descripcion;
            }
        system.debug('JSON.Serialize(response)' + JSON.Serialize(response));
        return JSON.Serialize(response);
        
    }
    
    @AuraEnabled
    public static String insertaQuoteLineItem(String idProductoSalesforce, String cotizacionId,Integer unitPrice,Integer quantity,Integer plazoMeses,Integer periodoGraciaMeses, String fondo, Integer score, String scoreDes, String errorCode,String tipoRegistro,String productCode)
    {
        system.debug(idProductoSalesforce);
        system.debug(cotizacionId);
        system.debug(unitPrice);
        system.debug(quantity);
        system.debug(plazoMeses);
        system.debug(fondo);
        system.debug(score);
        system.debug(scoreDes);
        system.debug(errorCode);
        system.debug(tipoRegistro);
        system.debug(productCode);
        string respuesta = 'Producto Creado exitosamente';
        string errores = '';
         
        list<String> listQuote = new list<String>();
        list<String> listOpportunity = new list<String>();
        list<String> listAccount = new list<String>();        
        PriceBook2 listaPrecios   = [select id from PriceBook2 where name = 'Standard Price Book' ];
        Pricebook2 standardPB  = [Select id from pricebook2 where isStandard = true];	
        List<PricebookEntry> lstEntradaLista = [SELECT id 
                                                FROM PricebookEntry 
                                                WHERE  Product2Id =:idProductoSalesforce and Pricebook2Id =: standardPB.Id
                                                limit 1];
        Product2 pro = [SELECT id,ProductCode,Name,Family,Tipo_de_servicio__c,Precio__c,Codigo_portafolio__c,
                        (SELECT id FROM PricebookEntries LIMIT 1)
                        from Product2 where  id=:idProductoSalesforce];
        PricebookEntry entradaLista = new PricebookEntry(); 
        system.debug('size' + lstEntradaLista);
        if( lstEntradaLista.size() == 0 ){
            system.debug('size');
            entradaLista.Pricebook2Id   = standardPB.Id;
            entradaLista.Product2Id     = idProductoSalesforce;
            entradaLista.UnitPrice      = unitPrice;
            entradaLista.IsActive       = true; 
            
            lstEntradaLista.add(entradaLista);
            insert entradaLista;
        }        
        Quote quote = [Select pricebook2id from quote where id =:cotizacionId];
        quote.Pricebook2Id = listaPrecios.id;
        try {
        update quote;
        }catch(Exception ex){
            
            respuesta = ex.getMessage();   
            if(respuesta.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
               List<String> tempErr =  respuesta.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                respuesta = tempErr[1];
            }
           return respuesta; 
        }
        listQuote.add(cotizacionId);
        for(Quote item: [SELECT id, Opportunity.id from Quote where id in :listQuote]){
            
            listOpportunity.add(item.Opportunity.id);
        }
        for(Opportunity item: [SELECT id,Persona_Publica__c, Presenta_una_dolencia_no_mencionada__c,Vinculo_con_Persona_Publica__c,Account.RecordType.DeveloperName,Se_encuentra_en_estudio_medico__c,Sera_sometido_a_tratamiento_medico__c,Ha_sido_alguna_vez_hospitalizado__c,Numero_de_cigarrillos_diarios_que_fuma__c,Participa_en_competencias_deportivas__c,Hospitalizacion_programada__c,Se_le_ha_negado_un_seguro__c, account.id,Presenta_los_siguientes_sintomas__c,Familiar_con_los_siguientes_sintomas__c,Sintomas_NO_relacionado_en_la_lista__c,Se_encuentra_en_embarazo__c from Opportunity where id in :listOpportunity]){
            if(  (unitPrice >Integer.valueOf((obtenerMaxPrecioVenta().Valor__c)) && item.Account.RecordType.DeveloperName == 'Persona_natural' ) ){
                 
            
                if(   String.isBlank(item.Presenta_una_dolencia_no_mencionada__c)|| String.isBlank(item.Presenta_los_siguientes_sintomas__c)   || String.isBlank(item.Familiar_con_los_siguientes_sintomas__c) || String.isBlank(item.Sintomas_NO_relacionado_en_la_lista__c) || String.isBlank(item.Se_encuentra_en_embarazo__c) || String.isBlank(item.Se_encuentra_en_estudio_medico__c) || String.isBlank(item.Sera_sometido_a_tratamiento_medico__c) || String.isBlank(item.Ha_sido_alguna_vez_hospitalizado__c) || String.isBlank(item.Hospitalizacion_programada__c) || String.isBlank(item.Participa_en_competencias_deportivas__c)  ||  String.isBlank(item.Se_le_ha_negado_un_seguro__c) || String.isBlank(item.Persona_Publica__c) || String.isBlank(item.Vinculo_con_Persona_Publica__c)   ){
                     
                    errores = 'Para un monto de más de 70 millones, todos los campos de la sección de Declaración de Asegurabilidad deben estar diligenciados en la Oportunidad.' + '\n';
                }
            }

    
    

            listAccount.add(item.account.id);
        }
     
        QuoteLineItem QLI = new QuoteLineItem();
        QLI.Puntaje_Score__c = score;
        QLI.Score__c = scoreDes;
        QLI.Observacion_Score__c = errorCode;
        for(Account item: [SELECT id, Tipo_de_identificacion__c,Ultima_Modificacion_de_Peso__c ,Nacionalidad__c,Lugar_de_nacimiento__c,Peso_kg__c,Estatura_cm__c from Account where id in :listAccount]){
            //mapAccount.put(item.Id,item);
            if(item.Tipo_de_identificacion__c == 'Nit'){
                QLI.Puntaje_Score__c = -1;
                QLI.Score__c = 'Persona Juridica';
                QLI.Observacion_Score__c = null;
            }    
            // se hace esta asignacion a la variable error, ya que iremos concatenando todos los errores 
            //que deberian de saltar por las reglas de validacion, pero hoy en dia no se pueden obtener todas de un solo
            // al guardar desde un aura component las reglas saltan una a una.
            
            if( item.Tipo_de_identificacion__c != 'Nit'  && unitPrice >Integer.valueOf((obtenerMaxPrecioVenta().Valor__c)) )
            {

                if(item.Ultima_Modificacion_de_Peso__c != System.today())
                {             
                    errores += 'Para un Precio de Venta de mas de 70 millones diligenciar los siguientes campos de la entidad Cliente : El campo Peso (kg)  debe tener fecha de actualización del día de hoy.' + '\n' ;
                }
                if( String.isBlank(item.Nacionalidad__c) || String.isBlank(item.Lugar_de_nacimiento__c) || item.Estatura_cm__c == null ||  item.Peso_kg__c == null)
                {  
                    errores += ' Para un Precio de Venta de mas de 70 millones diligenciar los siguientes campos de la entidad Cliente : Nacionalidad, Lugar de nacimiento, Peso (kg) y Estatura (cm).' + '\n' ;
                }
            }
            System.debug(errores);
             
        }
        if(String.isNotEmpty(errores) ){
            respuesta = errores;
            return respuesta;
        }
        QLI.Product2Id = idProductoSalesforce;
        QLI.QuoteId = cotizacionId;
        QLI.UnitPrice = unitPrice;
        QLI.Quantity = quantity;
        QLI.Plazo_meses__c = plazoMeses;
        QLI.Periodo_Gracias_Meses__c = periodoGraciaMeses;
        QLI.Fondo__c = fondo;
        if(tipoRegistro == 'Solicitud_de_credito')
        {
            QLI.Tipo_de_producto__c = 'Credito';
            
        }else{
            QLI.Tipo_de_producto__c = 'Conocimiento y Redes';           
        }
        system.debug('entrada de : ' +  lstEntradaLista[0].id);
        system.debug('entrada 2 : ' +   pro.PricebookEntries[0].id);
        
        QLI.PricebookEntryId = pro.PricebookEntries[0].id;
        system.debug('respuesta ' + respuesta) ;
        try{
            
            insert QLI;
        }catch(DmlException e){
            String msg = '';
             for (Integer i = 0; i < e.getNumDml(); i++) {
               
                system.debug('a' +  e.getDmlMessage(i) +  '\n' );
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            respuesta = msg;
            System.debug('msg' + msg);
        }
        catch(Exception ex)
        {
            respuesta = ex.getMessage();    
            if(respuesta.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
               List<String> tempErr =  respuesta.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                respuesta = tempErr[1];
            } 
         }
        system.debug('respuesta final ' + respuesta) ;
        return respuesta;      
    }
    @AuraEnabled
    public static String validaTipoCliente(String idCotizacion)
    { 
        String tipoPersona = '';
        map<String, Quote> mapQuote = new map<String, Quote>();
        map<String, Opportunity> mapOpportunity = new map<String, Opportunity>();
        list<String> listQuote = new list<String>();
        list<String> listOpportunity = new list<String>();
        list<String> listAccount = new list<String>();
        listQuote.add(idCotizacion);
        for(Quote item: [SELECT id, Opportunity.id from Quote where id in :listQuote]){
            mapQuote.put(item.Id,item);
            listOpportunity.add(item.Opportunity.id);
        }
        for(Opportunity item: [SELECT id, account.id from Opportunity where id in :listOpportunity]){
            mapOpportunity.put(item.Id,item);
            listAccount.add(item.account.id);
        }       
        for(Account item: [SELECT id, Tipo_de_identificacion__c from Account where id in :listAccount]){
            //mapAccount.put(item.Id,item);
            if(item.Tipo_de_identificacion__c == 'Nit'){
                tipoPersona = 'Juridica';
            } else{
                tipoPersona = 'Natural';
            }   
        }
        return tipoPersona;
    }
    public class respuestaServicio
    {
        public String estado;
        public String score;
        public String descripcion;
        public String mensajeError;
    }
    public static ListaClaveValor__mdt obtenerMaxPrecioVenta( ){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Precio de Venta Decl. Asegurabilidad'];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
}
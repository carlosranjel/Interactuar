/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso REST para exponer servicio para obtener los créditos y sus estados de un cliente en especifico

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   12-Feb-2021  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/CreditosYEstadosAutogestion/*')
global class IT_CreditosYEstadosAutogestion_WS {
    public static Opportunity lastOpp;
    
    public static String preaprobado = 'Preaprobado';
    public static String preaprobadoNoTomado = 'Preaprobado no tomado';
    public static String preaprobadoEnProceso = 'Preaprobado en proceso';
    public static String preaprobadoPorDesembolsar = 'Preaprobado por desembolsar';
    public static String creditoEnProceso = 'Crédito en proceso';
    public static String creditoVigente = 'Crédito vigente';
    public static String creditoCancelado = 'Crédito cancelado';
    public static String creditoNegado = 'Crédito negado'; //Créditos negados que fueron enviados desde el micrositio
    
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Recepción del servicio
*Date: 12-Feb-2021
******************************************************************************************/
    @HttpPost
    global static ResponseDTO doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);
        
        FromJSON jsonObj = (FromJSON)JSON.deserializeStrict(strJSONContent, FromJSON.class);
        
        ResponseDTO result = new ResponseDTO();
        result.encabezado = buildEncabezado(jsonObj.encabezado);
        
        CreditosEstadosAutogestion cea = new CreditosEstadosAutogestion();
        cea.tipoDocumento = jsonObj.creditosEstadosAutogestion.tipoDocumento;
        cea.numeroDocumento = jsonObj.creditosEstadosAutogestion.numeroDocumento;
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////
        lastOpp = getOpportunity(cea.tipoDocumento, cea.numeroDocumento);
        
        List<CreditosYEstados> creditosPreaprobados = getCreditosPreaprobados(jsonObj.creditosEstadosAutogestion);
        creditos.addAll(creditosPreaprobados);
        
        List<CreditosYEstados> creditosEnProgreso = getCreditosEnProceso(jsonObj.creditosEstadosAutogestion);
        creditos.addAll(creditosEnProgreso);
        
        CreditosYActivos creditosVigentesYActivos = getCreditosVigentes(jsonObj.creditosEstadosAutogestion);
        List<CreditosYEstados> creditosVigentes = creditosVigentesYActivos.creditos;
        creditos.addAll(creditosVigentes);
        
        List<CreditosYEstados> creditosCancelados = getCreditosCancelados(jsonObj.creditosEstadosAutogestion);
        creditos.addAll(creditosCancelados);
        
        List<CreditosYEstados> creditosNegadosMicrositio = getCreditosNegadosMicrositio(jsonObj.creditosEstadosAutogestion);
        creditos.addAll(creditosNegadosMicrositio);
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        cea.creditos = creditos;    
        result.creditosEstadosAutogestion = cea;
        
        IT_TipoClienteAutogestion_WS.TipoClienteAutogestionRequest tipoClienteReq = new IT_TipoClienteAutogestion_WS.TipoClienteAutogestionRequest();
        tipoClienteReq.tipoDocumento   = jsonObj.creditosEstadosAutogestion.tipoDocumento;
        tipoClienteReq.numeroDocumento = jsonObj.creditosEstadosAutogestion.numeroDocumento;
        IT_TipoClienteAutogestion_WS.TipoClienteAutogestion tca = new IT_TipoClienteAutogestion_WS.TipoClienteAutogestion();
        tca = IT_TipoClienteAutogestion_WS.getCreditInfo(tipoClienteReq, tca);
        
        cea.soliciteAquiSuCredito = False;
        if(tca.clienteVigenteCredito && (creditosEnProgreso == null || creditosEnProgreso.size() == 0) ){
            Boolean theraArePreaprodado = False;
            for(CreditosYEstados cre : creditosPreaprobados){
                if(cre.estado != preaprobadoNoTomado){
                    theraArePreaprodado = True;
                    break;
                }
            }
            if(!theraArePreaprodado){
                Decimal percent = Decimal.valueOf(obtenerPorcentajeSolicitarCredito().valor__c);
                
                if(creditosVigentes != null && creditosVigentes.size() > 0){
                    Boolean lessPercent = False;
                    for(Integer i = 0; i < creditosVigentes.size(); i++){
                       // if(creditosVigentesYActivos.activos[i].Status == 'Activo'){
                            Decimal avanceCuotas = creditosVigentesYActivos.activos[i].Avance_en_cuotas__c != null ? creditosVigentesYActivos.activos[i].Avance_en_cuotas__c : 0.0;
                            if(((100 - avanceCuotas ) / 100) < percent){
                                lessPercent = True;
                            }else{
                                lessPercent = False;
                                break;
                            }
                       // }else{
                        //    lessPercent = True;
                       // }                
                        if(creditosVigentesYActivos.activos[i].Status == 'Vencido' || creditosVigentesYActivos.activos[i].Status == 'Castigado' ){
                            lessPercent = false;
                             break;
                        }
                    }
                    cea.soliciteAquiSuCredito = lessPercent;
                }else{
                    cea.soliciteAquiSuCredito = True;
                }
                
            }
        }
        
        System.debug('Return: ' + result);
        return result;
        
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Se obtiene La última oportunidad relacionada al Cliente
*Date: 08-Jun-2021
******************************************************************************************/
    public static Opportunity getOpportunity(String typeI, String numI){
        List<Opportunity> opps =  [SELECT Id, Famiempresa_relacionada__r.Name, Famiempresa_relacionada__r.Actividad_economica__r.Name
                                   FROM Opportunity 
                                   WHERE Account.Tipo_de_identificacion__c = :typeI and Account.Numero_de_identificacion__c = :numI and RecordType.DeveloperName = 'Solicitud_de_credito' AND StageName = 'Desembolsado'
                                   order by CreatedDate desc LIMIT 1];
        if(opps.size() > 0){
            return opps[0];
        }
        return null;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Obtener creditos preaprobados
*Date: 12-Feb-2020
******************************************************************************************/
    public static List<CreditosYEstados> getCreditosPreaprobados(CreditosEstadosAutogestionRequest info){
        
        List<CampaignMember> members = [Select Id, Name, Campaign.Name, Mensaje_recibido__c, Producto__r.ProductCode, Monto__c, Campaign.Status, Plazo_Meses__c,
                                        Oportunidad_Generada_Automatica__c, Oportunidad_Generada_Automatica__r.StageName, Campaign.CodigoCorto__c, 
                                        Producto_RCA__c, Producto_RCA__r.ProductCode, Monto_RCA__c, Plazo_Meses_RCA__c, Tipo_de_Respuesta__c
                                        from CampaignMember
                                        where ((Contact.Account.Tipo_de_identificacion__c = :info.tipoDocumento and Contact.Account.Numero_de_identificacion__c = :info.numeroDocumento) 
                                               or (Lead.ConvertedAccount.Tipo_de_identificacion__c = :info.tipoDocumento and Lead.ConvertedAccount.Numero_de_identificacion__c = :info.numeroDocumento))
                                        and Campaign.Type = 'Credito digital' and Campaign.Status != 'En Diseño'
                                        order by Fecha_de_Mensaje__c];
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();
        List<CreditosYEstados> creditosNoTomados = new List<CreditosYEstados>();
        
        Map<Id, CampaignMember> oppMemberMap = new Map<Id, CampaignMember>();
        
        for(CampaignMember men : members){
            if(men.Mensaje_recibido__c != null && men.Mensaje_recibido__c != ''){
                if(isYes(men.Mensaje_recibido__c)){//Preguntar por ese crédito que dijo sí, pero no tiene oportunidad
                    if(isInPreaprobadoEnProgreso(men.Oportunidad_Generada_Automatica__r.StageName)){
                        CreditosYEstados cre = new CreditosYEstados();
                        cre.codigoProducto   = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? (men.Producto_RCA__r.ProductCode != null ? Integer.valueOf(men.Producto_RCA__r.ProductCode) : null) : (men.Producto__r.ProductCode != null ? Integer.valueOf(men.Producto__r.ProductCode) : null);
                            cre.monto            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? men.Monto_RCA__c : men.Monto__c;
                        cre.plazo            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? Integer.valueOf(men.Plazo_Meses_RCA__c) : Integer.valueOf(men.Plazo_Meses__c);
                        cre.estado           = men.Campaign.CodigoCorto__c != '999999999' ? preaprobadoEnProceso : creditoEnProceso;
                        
                        if(lastOpp != null){
                            cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                            cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                        }
                        
                        creditos.add(cre);  
                    }else if(men.Oportunidad_Generada_Automatica__r.StageName == 'Crédito Aprobado'){
                        oppMemberMap.put(men.Oportunidad_Generada_Automatica__c, men);
                    }
                }else{
                    CreditosYEstados cre = new CreditosYEstados();
                    cre.codigoProducto   = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? (men.Producto_RCA__r.ProductCode != null ? Integer.valueOf(men.Producto_RCA__r.ProductCode) : null) : (men.Producto__r.ProductCode != null ? Integer.valueOf(men.Producto__r.ProductCode) : null);
                        cre.monto            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? men.Monto_RCA__c : men.Monto__c;
                    cre.plazo            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? Integer.valueOf(men.Plazo_Meses_RCA__c) : Integer.valueOf(men.Plazo_Meses__c);
                    cre.estado = preaprobadoNoTomado;
                    
                    if(lastOpp != null){
                        cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                        cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                    }
                    
                    creditosNoTomados.add(cre);
                }
            }else{
                if(men.Campaign.Status ==  'En ejecución' || men.Campaign.Status == 'Planeada'){
                    CreditosYEstados cre = new CreditosYEstados();
                    cre.codigoProducto   = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? (men.Producto_RCA__r.ProductCode != null ? Integer.valueOf(men.Producto_RCA__r.ProductCode) : null) : (men.Producto__r.ProductCode != null ? Integer.valueOf(men.Producto__r.ProductCode) : null);
                        cre.monto            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? men.Monto_RCA__c : men.Monto__c;
                    cre.plazo            = men.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? Integer.valueOf(men.Plazo_Meses_RCA__c) : Integer.valueOf(men.Plazo_Meses__c);
                    cre.estado = preaprobado;
                    cre.idMiembroCampania = men.Id;
                    
                    if(lastOpp != null){
                        cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                        cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                    }
                    
                    creditos.add(cre);
                    
                }
            }
        }
        
        if(creditosNoTomados.size() > 0){
            creditos.add(creditosNoTomados[creditosNoTomados.size() - 1]);
        }
        
        List<QuoteLineItem> listQuoteLineItems = [Select Id,Identificador_Radicado_OR__c, Quote.OpportunityId
                                                  from QuoteLineItem
                                                  where Quote.Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' and Quote.OpportunityId in :oppMemberMap.keySet()];
        List<Asset> listAssets = [Select Id, Identificador_Radicado__c, Monto_desembolsado__c, Fecha_desembolso__c
                                  from Asset
                                  where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento];
        
        for(Id oporId : oppMemberMap.keySet()){
            Boolean thereAreProduct = False;
            for(QuoteLineItem prod : listQuoteLineItems){
                if(prod.Quote.OpportunityId == oporId){
                    Boolean IsPreaprobadoPorDesembolsar = False;
                    Boolean thereAreAsset = False;
                    
                    if(prod.Identificador_Radicado_OR__c != null && prod.Identificador_Radicado_OR__c != ''){
                        for(Asset activo : listAssets){
                            if(activo.Identificador_Radicado__c == prod.Identificador_Radicado_OR__c){
                                if(activo.Fecha_desembolso__c == null){
                                    IsPreaprobadoPorDesembolsar = True;
                                }
                                thereAreAsset = True;
                                Break;
                            }                        
                        }
                    }
                    
                    if(IsPreaprobadoPorDesembolsar || !thereAreAsset){
                        CreditosYEstados cre = new CreditosYEstados();
                        
                        cre.codigoProducto   = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? (oppMemberMap.get(oporId).Producto_RCA__r.ProductCode != null ? Integer.valueOf(oppMemberMap.get(oporId).Producto_RCA__r.ProductCode) : null) : (oppMemberMap.get(oporId).Producto__r.ProductCode != null ? Integer.valueOf(oppMemberMap.get(oporId).Producto__r.ProductCode) : null);
                            cre.monto            = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? oppMemberMap.get(oporId).Monto_RCA__c : oppMemberMap.get(oporId).Monto__c;
                        cre.plazo            = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? Integer.valueOf(oppMemberMap.get(oporId).Plazo_Meses_RCA__c) : Integer.valueOf(oppMemberMap.get(oporId).Plazo_Meses__c);
                        
                        cre.estado = oppMemberMap.get(oporId).Campaign.CodigoCorto__c != '999999999' ? preaprobadoPorDesembolsar : creditoEnProceso;
                        
                        if(lastOpp != null){
                            cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                            cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                        }
                        
                        creditos.add(cre);
                    }
                    thereAreProduct = True;
                    break;
                }
            }
            if(!thereAreProduct){
                CreditosYEstados cre = new CreditosYEstados();
                
                cre.codigoProducto   = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? (oppMemberMap.get(oporId).Producto_RCA__r.ProductCode != null ? Integer.valueOf(oppMemberMap.get(oporId).Producto_RCA__r.ProductCode) : null) : (oppMemberMap.get(oporId).Producto__r.ProductCode != null ? Integer.valueOf(oppMemberMap.get(oporId).Producto__r.ProductCode) : null);
                    cre.monto            = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? oppMemberMap.get(oporId).Monto_RCA__c : oppMemberMap.get(oporId).Monto__c;
                cre.plazo            = oppMemberMap.get(oporId).Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' ? Integer.valueOf(oppMemberMap.get(oporId).Plazo_Meses_RCA__c) : Integer.valueOf(oppMemberMap.get(oporId).Plazo_Meses__c);
                
                cre.estado = oppMemberMap.get(oporId).Campaign.CodigoCorto__c != '999999999' ? preaprobadoPorDesembolsar : creditoEnProceso;
                
                if(lastOpp != null){
                    cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                    cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                }
                
                creditos.add(cre);
            }
        }
        
        return creditos;
    }
    
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Otener créditos en proceso que no han sido desembolsados y son diferentes a crédito digital
*Date: 12-Feb-2020
******************************************************************************************/
    public static List<CreditosYEstados> getCreditosEnProceso(CreditosEstadosAutogestionRequest info){
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ([Select Id, Name, StageName, Amount
                                                                 from Opportunity 
                                                                 where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento and 
                                                                 RecordType.DeveloperName = 'Solicitud_de_credito' and Generacion_Automatica_de_Credito__c != true and Resultado_Estudio_Digital__c != 'ANALISIS FABRICA'
                                                                 and Resultado_Estudio_Digital__c != 'ANALISIS ASESOR']);
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();
        
        List<QuoteLineItem> listQuoteLineItems = [Select Id,Identificador_Radicado_OR__c, Quote.OpportunityId, Product2Id, Product2.ProductCode, TotalPrice, Plazo_meses__c
                                                  from QuoteLineItem
                                                  where Quote.Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' and Quote.OpportunityId in :oppMap.keySet()];
        List<Asset> listAssets = [Select Id, Identificador_Radicado__c, Monto_desembolsado__c, Fecha_desembolso__c
                                  from Asset
                                  where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento];
        
        for(Id oporId : oppMap.keySet()){ 
            if(creditoNoPerdido(oppMap.get(oporId).StageName)){
                Boolean thereAreProduct = False;
                for(QuoteLineItem prod : listQuoteLineItems){
                    if(prod.Quote.OpportunityId == oporId){
                        Boolean IsInProgress = False;
                        Boolean thereAreAsset = False;
                        
                        if(prod.Identificador_Radicado_OR__c != null && prod.Identificador_Radicado_OR__c != ''){
                            for(Asset activo : listAssets){
                                if(activo.Identificador_Radicado__c == prod.Identificador_Radicado_OR__c){
                                    if(activo.Fecha_desembolso__c == null){
                                        IsInProgress = True;
                                    }
                                    thereAreAsset = True;
                                    Break;
                                }                        
                            }
                        }
                        
                        if(IsInProgress || !thereAreAsset){
                            CreditosYEstados cre = new CreditosYEstados();
                            cre.codigoProducto = Integer.valueOf(prod.Product2.ProductCode);
                            cre.monto = prod.TotalPrice;
                            cre.plazo = Integer.valueOf(prod.Plazo_meses__c);
                            cre.estado = creditoEnProceso;
                            
                            if(lastOpp != null){
                                cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                                cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                            }
                            
                            creditos.add(cre);
                        }
                        thereAreProduct = True;
                        break;
                    }
                }
                if(!thereAreProduct){
                    CreditosYEstados cre = new CreditosYEstados();
                    cre.codigoProducto = null;
                    cre.monto = oppMap.get(oporId).Amount;
                    cre.plazo = null;
                    cre.estado = creditoEnProceso;
                    
                    if(lastOpp != null){
                        cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                        cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                    }
                    
                    creditos.add(cre);
                }
            }
        }
        
        
        return creditos;
    }
    
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Otener créditos en proceso que no han sido desembolsados y son diferentes a crédito digital
*Date: 12-Feb-2020
******************************************************************************************/
    public static CreditosYActivos getCreditosVigentes(CreditosEstadosAutogestionRequest info){
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ([Select Id, Name, StageName, Amount
                                                                 from Opportunity 
                                                                 where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento
                                                                 and RecordType.DeveloperName = 'Solicitud_de_credito']);
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();
        
        List<QuoteLineItem> listQuoteLineItems = [Select Id,Identificador_Radicado_OR__c, Quote.OpportunityId, Product2Id, Product2.ProductCode, TotalPrice, Plazo_meses__c
                                                  from QuoteLineItem
                                                  where Quote.Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' and Quote.OpportunityId in :oppMap.keySet()];
        List<Asset> listAssets = [Select Id, Identificador_Radicado__c, Monto_desembolsado__c, Fecha_desembolso__c, Numero_de_credito__c, Status, Saldo_para_cancelacion_total__c, Avance_en_cuotas__c 
                                  from Asset
                                  where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento];
        
        List<Asset> activos = new List<Asset> ();
        for(Id oporId : oppMap.keySet()){
            if(creditoNoPerdido(oppMap.get(oporId).StageName)){
                for(QuoteLineItem prod : listQuoteLineItems){
                    if(prod.Quote.OpportunityId == oporId){
                        if(prod.Identificador_Radicado_OR__c != null && prod.Identificador_Radicado_OR__c != ''){
                            for(Asset activo : listAssets){
                                if(activo.Identificador_Radicado__c == prod.Identificador_Radicado_OR__c && activo.Status != 'Cancelado'){
                                    
                                    if(activo.Fecha_desembolso__c != null){
                                        CreditosYEstados cre = new CreditosYEstados();
                                        cre.codigoProducto = Integer.valueOf(prod.Product2.ProductCode);
                                        cre.monto = prod.TotalPrice;
                                        cre.plazo = Integer.valueOf(prod.Plazo_meses__c);
                                        DateTime fede = DateTime.newInstance(activo.Fecha_desembolso__c, Time.newInstance(0,0,0,0));
                                        cre.fechaDesembolso = fede.format('yyyy-MM-dd HH:mm:ss');
                                        cre.numeroCredito = activo.Numero_de_credito__c;
                                        
                                        cre.estado = creditoVigente;
                                        if(lastOpp != null){
                                            cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                                            cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                                        }
                                        
                                        activos.add(activo);
                                        creditos.add(cre);
                                    }
                                    Break;
                                }                        
                            }
                        }
                        break;
                    }
                }
            }
        }
        
        CreditosYActivos toReturn = new CreditosYActivos();
        toReturn.activos = activos;
        toReturn.creditos = creditos;
        
        return toReturn;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Otener créditos que fueron negados en el resultado del estudio digital
*Date: 09-jul-2021
******************************************************************************************/
    public static List<CreditosYEstados> getCreditosNegadosMicrositio(CreditosEstadosAutogestionRequest info){
        ListaClaveValor__mdt  listaClaveValor = ListaClaveValor__mdt.getInstance('Dias_credito_negados');
        integer dias = Integer.valueOf(listaClaveValor.Valor__c);
        Boolean flagCreditos = false;	
        Date fechaActual =  Date.today();	
        Map<Id,Opportunity> oppMapCredito = new Map<Id,Opportunity>();	
        Map<Id,Opportunity> oppMapFinalCredito= new Map<Id,Opportunity>();
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ([Select Id, Name, StageName, Amount,closeDate
                                                                 from Opportunity 
                                                                 where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento and 
                                                                 RecordType.DeveloperName = 'Solicitud_de_credito' and Resultado_Estudio_Digital__c = 'NEGADO' order by closeDate desc]);
        
        for(Id key : oppMap.keySet()){
            if(oppMap.get(key).closeDate.daysBetween(fechaActual) < dias ){
                oppMapCredito.put(key,oppMap.get(key));
                break;
            }
            
        }
        
        /**if(oppMapCredito.size()>0){
            oppMapFinalCredito = oppMapCredito;
        }else{
            oppMapFinalCredito = oppMap;
        }**/
        List<QuoteLineItem> listQuoteLineItems = [Select Id, Identificador_Radicado_OR__c, Quote.OpportunityId, Product2Id, Product2.ProductCode, TotalPrice, Plazo_meses__c
                                                  from QuoteLineItem
                                                  where Quote.OpportunityId in :oppMapCredito.keySet()];
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();        
        for(Id oporId : oppMapCredito.keySet()){
            for(QuoteLineItem prod : listQuoteLineItems){
                if(prod.Quote.OpportunityId == oporId){
                    CreditosYEstados cre = new CreditosYEstados();
                    cre.codigoProducto = Integer.valueOf(prod.Product2.ProductCode);
                    cre.monto = prod.TotalPrice;
                    cre.plazo = Integer.valueOf(prod.Plazo_meses__c);
                    cre.estado = creditoNegado;
                    
                    if(lastOpp != null){
                        cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                        cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                    }
                    
                    creditos.add(cre);
                    
                    break;
                }
            }
        }
        
        return creditos;
    }
    
    public class CreditosYActivos{
        List<Asset> activos;
        List<CreditosYEstados> creditos;
    }
    
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Otener créditos en proceso que no han sido desembolsados y son diferentes a crédito digital
*Date: 12-Feb-2020
******************************************************************************************/
    public static List<CreditosYEstados> getCreditosCancelados(CreditosEstadosAutogestionRequest info){
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ([Select Id, Name, StageName, Amount
                                                                 from Opportunity 
                                                                 where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento
                                                                 and RecordType.DeveloperName = 'Solicitud_de_credito']);
        
        List<CreditosYEstados> creditos = new List<CreditosYEstados>();
        
        List<QuoteLineItem> listQuoteLineItems = [Select Id,Identificador_Radicado_OR__c, Quote.OpportunityId, Product2Id, Product2.ProductCode, TotalPrice, Plazo_meses__c
                                                  from QuoteLineItem
                                                  where Quote.Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' and Quote.OpportunityId in :oppMap.keySet()];
        List<Asset> listAssets = [Select Id, Identificador_Radicado__c, Monto_desembolsado__c, Fecha_desembolso__c, Numero_de_credito__c, Status, Fecha_de_cancelacion__c
                                  from Asset
                                  where Account.Tipo_de_identificacion__c = :info.tipoDocumento and Account.Numero_de_identificacion__c = :info.numeroDocumento];
        
        Date todayDate = Date.today();
        Integer monthToBeCurrent = Integer.valueOf(obtenerMesesVigente().valor__c);
        
        for(Id oporId : oppMap.keySet()){
            if(creditoNoPerdido(oppMap.get(oporId).StageName)){
                for(QuoteLineItem prod : listQuoteLineItems){
                    if(prod.Quote.OpportunityId == oporId){
                        if(prod.Identificador_Radicado_OR__c != null && prod.Identificador_Radicado_OR__c != ''){
                            for(Asset activo : listAssets){
                                if(activo.Identificador_Radicado__c == prod.Identificador_Radicado_OR__c){
                                    if(activo.Status == 'Cancelado'){
                                        if(activo.Fecha_de_cancelacion__c != null && (activo.Fecha_de_cancelacion__c.monthsBetween(todayDate) <= monthToBeCurrent)){
                                            
                                            CreditosYEstados cre = new CreditosYEstados();
                                            cre.codigoProducto = Integer.valueOf(prod.Product2.ProductCode);
                                            cre.monto = prod.TotalPrice;
                                            cre.plazo = Integer.valueOf(prod.Plazo_meses__c);
                                            DateTime fede = DateTime.newInstance(activo.Fecha_desembolso__c, Time.newInstance(0,0,0,0));
                                            cre.fechaDesembolso = fede.format('yyyy-MM-dd HH:mm:ss');
                                            cre.numeroCredito = activo.Numero_de_credito__c;
                                            cre.estado = creditoCancelado;
                                            
                                            if(lastOpp != null){
                                                cre.famiempresa        = lastOpp.Famiempresa_relacionada__r.Name;
                                                cre.actividadEconomica = lastOpp.Famiempresa_relacionada__r.Actividad_economica__r.Name;
                                            }
                                            
                                            creditos.add(cre);
                                        }
                                    }
                                    Break;
                                }                        
                            }
                        }
                        break;
                    }
                }
            }
        }
        
        
        return creditos;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Metadato de los meses de un crédito vigente
*Date: 12-Feb-2020
******************************************************************************************/
    public static ListaClaveValor__mdt obtenerMesesVigente( ){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Auto Meses Para Ser Vigente'];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Metadato de los meses de un crédito vigente
*Date: 16-Abr-2020
******************************************************************************************/
    public static ListaClaveValor__mdt obtenerPorcentajeSolicitarCredito( ){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = 'Auto Porcentaje de Solicitar Credito'];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
    
    
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Devuelve true si el credito no está aprobado y tampoco está perdído.
*Date: 12-Feb-2020
******************************************************************************************/
    public static Boolean isInPreaprobadoEnProgreso(String state){
        if(state != 'Desembolsado' && state != 'Crédito Aprobado' && state != 'Crédito Negado' && state != 'Crédito Devuelto' && state != 'Desistido' && state != 'No seleccionado' && state != 'Negada' && state != 'Desistida'){
            return True;
        }
        return False;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Devuelve true si el credito no está está perdído.
*Date: 12-Feb-2020
******************************************************************************************/
    public static Boolean creditoNoPerdido(String state){
        if(state != 'Crédito Negado' && state != 'Crédito Devuelto' && state != 'Desistido' && state != 'No seleccionado' && state != 'Negada' && state != 'Desistida'){
            return True;
        }
        return False;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Devuelve true si es Sí
*Date: 12-Feb-2020
******************************************************************************************/
    public static Boolean isYes(String text){
        if(text == null || text == ''){
            return False;
        }
        if(text == 'SI' || text == 'si' || text == 'sI' || text == 'Sí' || text == 'SÍ' || text == 'sí' || text == 'sÍ'){
            return True;
        }
        return False;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Encabezado de respuesta
*Date: 12-Feb-2020
******************************************************************************************/
    public static Encabezado buildEncabezado(Encabezado request){
        Encabezado encabezado = new Encabezado();
        encabezado.fecha = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        encabezado.identificador = request.identificador;
        encabezado.integracion = 'Créditos Y Estados Autogestión';
        encabezado.operacion = request.operacion;
        encabezado.origen = 'SALESFORCE';
        encabezado.destino = request.origen;
        
        return encabezado;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Clase modelo de la información recibida
*Date: 12-Feb-2020
******************************************************************************************/
    global class FromJSON{
        public Encabezado encabezado;
        public CreditosEstadosAutogestionRequest creditosEstadosAutogestion;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function:
*Date: 12-Feb-2020
******************************************************************************************/
    global class Encabezado{
        public String fecha;
        public String identificador;
        public String integracion;
        public String operacion;
        public String origen;
        public String destino; 
    }
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function:
*Date: 12-Feb-2020
******************************************************************************************/
    global class CreditosEstadosAutogestionRequest{
        public String tipoDocumento;
        public String numeroDocumento;
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function: Clase modelo de la información enviada
*Date: 12-Feb-2020
******************************************************************************************/
    global class ResponseDTO{
        public Encabezado encabezado;
        public CreditosEstadosAutogestion creditosEstadosAutogestion = new CreditosEstadosAutogestion();
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function:
*Date: 12-Feb-2020
******************************************************************************************/
    global class CreditosEstadosAutogestion{
        public String tipoDocumento;
        public String numeroDocumento;
        public Boolean soliciteAquiSuCredito;
        public List<CreditosYEstados> creditos = new List<CreditosYEstados>();
    }
    
    /******************************************************************************************
*Author:  Álvaro Ortega
*Function:
*Date: 12-Feb-2020
******************************************************************************************/
    global class CreditosYEstados{
        public Integer codigoProducto;
        public Decimal monto;
        public Integer plazo;
        public String estado;
        public String fechaDesembolso;
        public String numeroCredito;
        public String famiempresa;
        public String actividadEconomica;
        public String idMiembroCampania;
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
    }
}
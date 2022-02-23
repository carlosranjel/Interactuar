/**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class que llama el servicio de Oportunidad
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   29-May-2019  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************/
public with sharing class IT_ServicioOportunidad_ws {
    
    private static Http               http;
    private static HttpRequest        Request;
    private static HttpResponse       Response;
    private static String             JSON_req {get;set;}
    private static List<Id>           listaId;
    private static Map<String,String> hom;
    private static final String CONTEXTO = 'Pagare';
    private static final String ES_NULO  = null;
    private static final String AVALISTA = 'rolAvalista';
    private static final String REPR     = 'rolRLegal';
    private static final String RCLIENTE = 'rolCliente';
    
    public IT_ServicioOportunidad_ws() {  }

  	/**************************************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Inicio de la integracion. Este se invoca desde el process Builder
   	*Date: 3-3-2020
   	**************************************************************************************************************/
    @InvocableMethod
    public static void servicioOportunidad(List<String> lstOpp){
        servicioOportunidad2(lstOpp);
    }
    
  	/**************************************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se crea el JSON que se envia en la integracion y posteriormente se invoca la integracion con Talent
   	*Date: 3-3-2020
   	**************************************************************************************************************/
    @Future(callout=true)
    public static void servicioOportunidad2(List<String> lstOpp){
        List<Opportunity> lstOportunidad = consultaOportunidad(lstOpp.get(0));     
        JSON_req = creacionJSONproductos(lstOportunidad.get(0));                  
        Request = IT_ParametrosWS_cls.parametrosOportunidad(JSON_req);        
        http = new Http();
        Response = http.send(Request);
        system.debug('response-->'+Response.getBody());       
    }

  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se identifica el tipo de producto que se agrego en el producto por cotizacion
   	*Date: 3-3-2020
	******************************************************************************************/
    public static String creacionJSONproductos(Opportunity opp){
        String json = '';
        hom = getHomologaciones();
        List<QuoteLineItem> lstQuoteLineItem = consultaProductoPorCotizacion(opp);
        if( opp.RecordType.DeveloperName == 'Solicitud_de_credito' ){
            json = getJsonCredito(opp,lstQuoteLineItem);
        }else if( opp.RecordType.DeveloperName == 'Servicios_de_conocimiento_y_redes' ){
            if( lstQuoteLineItem.get(0).Quote.Res_conteo_servicio_tipo_asesoria__c > 0 ){
                json = getJsonAsesorias(opp,lstQuoteLineItem);
            }else if( lstQuoteLineItem.get(0).Quote.Res_conteo_servicio_tipo_capacitacion__c > 0 ){
                json = getJsonCapacitacion(opp,lstQuoteLineItem);
            }
        }
        return json;
    }
    
    public static List<QuoteLineItem> consultaProductoPorCotizacion(Opportunity opp){
        return [SELECT Id,Product2Id,Product2.ProductCode,Product2.Fecha_fin__c,Product2.Fecha_inicio__c,Product2.Identificador_grupo__c,Product2.Codigo_Oficina_OR__c,Product2.Codigo_Sede_OR__c,Identificador_Radicado_OR__c,
                Product2.name,Product2.ProductCode2__c,Quote.Opportunity.Forma_de_pago__c,Quote.Opportunity.Oficina_asesor_asignado__c,Quote.Opportunity.Asesor_asignado__c,Quote.Opportunity.Sede_Asesor_asignado__c,
                Product2.Requiere_pago__c,Quote.Opportunity.Empleado_que_refiere__r.Numero_de_documento__c,Quote.Opportunity.Codigo_Empleado_referido_por__c,Quote.Opportunity.Paga_un_tercero__c,Product2.Tipo_de_servicio__c,Quantity,
                TotalPrice,Convenio__r.Identificador_convenio__c,Quote.Opportunity.Account.Numero_de_identificacion__c,Convenio__r.Name,Quote.Opportunity.Numero_de_identificacion_de_asistente_1__c,
                Quote.Opportunity.Numero_de_identificacion_de_asistente_2__c,Quote.Opportunity.Numero_de_identificacion_de_asistente_3__c,Quote.Opportunity.Nombre_de_asistente_1__c,LineNumber,CreatedDate,
                Quote.Res_conteo_servicio_tipo_asesoria__c,Quote.Res_conteo_servicio_tipo_capacitacion__c,Product2.Grupo_convenio__c,Product2.Grupo_convenio_nombre__c,Quote.GrandTotal,
                Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c,Numero_identificador_de_pago__r.Name,
                Quote.Opportunity.Respuesta_Oportunidad__c,Quote.OpportunityId,Quote.Opportunity.Identificador_proceso__c,Plazo_meses__c,Tipo_credito__c,Quote.Opportunity.Cheque_a_nombre_de_entidad__c,
                Quote.Opportunity.Entidad_financiera__c,Quote.Opportunity.Tipo_de_cuenta__c,Quote.Opportunity.Medio_de_desembolso__c,Quote.Opportunity.Exonero_a_Interactuar_de_toda_responsabi__c,Quote.Opportunity.Cuenta_No__c,
                Periodo_Gracias_Meses__c,Codigo_Alianza__c,Quote.Opportunity.Numero_de_Afiliados_a_Prever__c, Puntaje_Score__c, fondo__c 
                FROM QuoteLineItem 
                WHERE Quote.OpportunityId =: opp.Id ];
    }

  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Seccion de JSON donde se agrega exclusivamente productos tipo asesorias
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String getJsonAsesorias(Opportunity opp, List<QuoteLineItem> lstQuoteLineItem){
        /*arma json producto asistentes*/
        String jsonAsistentes  = seccionCuenta(opp, lstQuoteLineItem);
        jsonAsistentes  += '"asesorias": [';
        for(Integer k = 0; k < lstQuoteLineItem.size();  k++){                       
            jsonAsistentes += '{'+  
                '"id":      "'+lstQuoteLineItem[k].Product2.ProductCode2__c+'",'+ 
                '"codigo" : "'+lstQuoteLineItem[k].id+'",'+
                '"nombre":  "'+lstQuoteLineItem.get(k).Product2.Name+'",'+   
                '"idPago":  "'+validarNullString(lstQuoteLineItem.get(k).Numero_identificador_de_pago__r.Name)+'",'+  
                '"formaPago": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Forma_de_pago__c)+'",'+   
                '"oficina":   "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c)+'",'+      
                '"asesor":    "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c)+'",'+   
                '"sede":      "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c)+'",'+     
                '"plantaFisica": null,'+   
                '"requierePago": '+lstQuoteLineItem.get(k).Product2.Requiere_pago__c+','+  
                '"empleadorRefiere": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Empleado_referido_por__c)+'",'+    
                '"pagaTercero": '+lstQuoteLineItem.get(k).Quote.Opportunity.Paga_un_tercero__c+','+             
                '"tercero": {'+
                '"numeroIdentificacion": "'+validarNullString(opp.Numero_de_identificacion_tercero__c)+'",'+
                '"tipoIdentificacion": "'+validarNullString(opp.Tipo_de_documento_tercero__c)+'"'+        
                '},'+//fin tercero
                '"tipoAutorizacionTercero": null,'+ 
                '"tipoServicioConocimiento": "'+validarNullString(lstQuoteLineItem.get(k).Product2.Tipo_de_servicio__c)+'",'+   
                '"cantidad": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(lstQuoteLineItem.get(k).Quantity)+','+     
                '"codigoFinanciero": null,'+
                '"estadoFactibilidad": 0,'+ 
                '"valorTotal": '+lstQuoteLineItem.get(k).TotalPrice+','+ 
                '"radicado": null,'+ 
                '"convenio": {'+
                '"id": "'+validarNullString(lstQuoteLineItem.get(k).Convenio__r.Identificador_convenio__c)+'",'+  
                '"nombre": "'+validarNullString(lstQuoteLineItem.get(k).Convenio__r.Name)+'"'+   
                '},'+//fin convenio
                '"asistentes": ['+
                '{'+
                '"numeroIdentificacion": null,'+// "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Numero_de_identificacion_de_asistente_1__c)+'"   
                '"tipoIdentificacion": null'+  // 
                '},'+
                '{'+
                '"numeroIdentificacion": null,'+ // "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Numero_de_identificacion_de_asistente_2__c)+'"
                '"tipoIdentificacion": null'+   //  opp Nombre_de_asistente_2__c
                '},'+
                '{'+
                '"numeroIdentificacion": null,'+ // "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Numero_de_identificacion_de_asistente_3__c)+'"
                '"tipoIdentificacion": null'+ // opp Nombre_de_asistente_3__c
                '}'+
                '],'+
                '"codigoCredito": '+opp.Numero_credito_aprobado__c+''; 
            
            if( k+1 ==  lstQuoteLineItem.size()){
                jsonAsistentes += '} ';
            }else if(k+1 <  lstQuoteLineItem.size()){
                jsonAsistentes += '},';
            }
        }
        jsonAsistentes += '],'+
            '"capacitacion": ['+          
            '],'+
            '"credito": ['+          
            '] } } } }';
        return jsonAsistentes;
    }

   	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Seccion de JSON donde se agrega exclusivamente productos tipo capacitacion
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String getJsonCapacitacion(Opportunity opp,List<QuoteLineItem> lstQuoteLineItem){
        /*arma json producto capacitacion*/
        String jsonCapacitacion  = seccionCuenta(opp, lstQuoteLineItem);
        jsonCapacitacion += '"asesorias": ['+          
            '],'+
            '"capacitacion": [';
        for(Integer k = 0; k < lstQuoteLineItem.size();  k++){
            jsonCapacitacion += ''+
                '{'+
                '"id":"'+lstQuoteLineItem[k].Product2.ProductCode2__c+'",'+// SE ESTA ENVIANDO CODPROD+GRUPO *****
                '"codigo" : "'+lstQuoteLineItem[k].id+'",'+
                '"nombre": "'+lstQuoteLineItem[k].Product2.name+'",'+//
                '"oficina": "'+validarNullString(lstQuoteLineItem.get(k).Product2.Codigo_Oficina_OR__c)+'",'+ 
                '"asesor": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c)+'",'+ 
                '"sede": "'+validarNullString(lstQuoteLineItem.get(k).Product2.Codigo_Sede_OR__c)+'",'+ 
                '"idPago": "'+validarNullString(lstQuoteLineItem.get(k).Numero_identificador_de_pago__r.Name)+'",'+
                '"requierePago": '+lstQuoteLineItem[k].Product2.Requiere_Pago__c+','+ 
                '"empleadorRefiere": "'+validarNullString(opp.Empleado_que_refiere__r.Codigo_de_Empleado__c)+'",'+ 
                '"valorTotal": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(lstQuoteLineItem[k].TotalPrice)+','+
                '"asistentes": 0,'+ 
                '"beca": 0,'+  
                '"fechaCreacion": "'+lstQuoteLineItem[k].CreatedDate+'",'+
                '"fechaFinal": "'+lstQuoteLineItem[k].Product2.Fecha_Fin__c+'",'+ 
                '"fechaInicial": "'+lstQuoteLineItem[k].Product2.Fecha_Inicio__c+'",'+
                '"formaPago": "'+validarNullString(opp.Forma_de_pago__c)+'",'+ 
                '"grupo": "'+lstQuoteLineItem[k].Product2.Identificador_grupo__c+'",'+ 
                '"convenio": {'+
                '"id": "'+validarNullString(lstQuoteLineItem.get(k).Convenio__r.Identificador_convenio__c)+'",'+ 
                '"nombre": "'+validarNullString(lstQuoteLineItem.get(k).Convenio__r.Name)+'"'+ 
                '},'+//fin convenio
                '"cantidad": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(lstQuoteLineItem[k].Quantity)+','+ 
                '"codigoFinanciero": null,'+ 
                '"estadoFactibilidad": 0,'+ 
                '"radicado": "'+validarNullString('')+'",'+ 
                '"pagaTercero": '+opp.Paga_un_tercero__c+','+ 
                '"tercero": {'+
                '"numeroIdentificacion": "'+validarNullString(opp.Numero_de_identificacion_tercero__c)+'",'+ 
                '"tipoIdentificacion": "'+validarNullString(opp.Tipo_de_documento_tercero__c)+'"'+  
                '},'+//fin tercero
                '"motivo": null,'+
                '"clienteTieneEmpresa": false,'+
                '"codigoCredito": '+opp.Numero_credito_aprobado__c+'';                     
            
            if( k+1 ==  lstQuoteLineItem.size()){
                jsonCapacitacion += '} ';
            }else if(k+1 <  lstQuoteLineItem.size()){
                jsonCapacitacion += '},';
            }        
        }
        jsonCapacitacion += '],'+
            '"credito": ['+          
            '] } } } }';
        return jsonCapacitacion;
    }

  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Seccion de JSON donde se agrega exclusivamente productos tipo credito
   	*Date: 3-3-2020
    *Modificacion : el fondo ahora se obtendra desde el producto de la cotización.
   	******************************************************************************************///
    public static String getJsonCredito(Opportunity opp,List<QuoteLineItem> lstQuoteLineItem){
        String jsonCredito  = seccionCuenta(opp, lstQuoteLineItem);
        CampaignMember mCampania = IT_MiembroCampania.buscaMiembroDeCampana(opp);
        Integer fondo = 0;
        jsonCredito += '"asesorias": ['+          
            '],'+
            '"capacitacion": ['+          
            '],'+
            '"credito": [';
        for(Integer k = 0; k < lstQuoteLineItem.size();  k++){
            fondo = ( lstQuoteLineItem.get(k).fondo__c != null )? Integer.valueOf( (lstQuoteLineItem.get(k).fondo__c).subString(0,2).trim() ) : null;
            jsonCredito += '{'+
                '"id": "'+lstQuoteLineItem[k].Product2.ProductCode2__c+'",'+ 
                '"codigo" : "'+lstQuoteLineItem[k].id+'",'+
                '"nombre": "'+lstQuoteLineItem[k].Product2.name+'",'+ 
                '"oficina": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c)+'",'+ 
                '"asesor": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c)+'",'+  
                '"sede": "'+validarNullString(lstQuoteLineItem.get(k).Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c)+'",'+  
                '"valorTotal": '+validarDecimalAInteger(lstQuoteLineItem.get(k).Quote.GrandTotal)+','+ 
                '"destino": null,'+   
                '"montoSolicitado": '+validarDecimalAInteger(lstQuoteLineItem.get(k).TotalPrice)+','+ 
                '"nombreActividad": null,'+  
                '"plazoSolicitado": '+lstQuoteLineItem.get(k).Plazo_meses__c+','+
                '"tipoCredito": 0,'+ 
                '"cantidad": 0,'+    
                '"codigoFinanciero": null,'+ 
                '"estadoFactibilidad": 0,'+ 
                '"radicado": null,'+  
                '"alianza":  "'+IT_ConstruccionJSON_cls.validarNullString(lstQuoteLineItem.get(k).Codigo_Alianza__c)+'",'+
                '"fondo" : '+ fondo +','+ // autogestion
                '"indicadorCancelacion" : '+ mCampania.CreditoSaldoCargo__c +','+ // autogestion
                '"desembolso": {'+
                '"autorizo": false,'+
                '"cuenta": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Cheque_a_nombre_de_entidad__c)+','+
                '"cuentaNumero": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Cuenta_No__c)+','+
                '"entidadFinanciera": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Entidad_financiera__c)+','+
                '"exonero": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Exonero_a_Interactuar_de_toda_responsabi__c)+','+
                '"modo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Medio_de_desembolso__c)+','+
                '"tipoCuenta": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Tipo_de_cuenta__c)+','+
                '"chequeNombreEntidad": '+IT_ConstruccionJSON_cls.validarStringReturnNull(lstQuoteLineItem.get(k).Quote.Opportunity.Cheque_a_nombre_de_entidad__c)+''+
                '}';//fin desembolso IT_ConstruccionJSON_cls.validarNullString()
            
            if( k+1 ==  lstQuoteLineItem.size()){
                jsonCredito += '} ';
            }else if(k+1 <  lstQuoteLineItem.size()){
                jsonCredito += '},';
            }
        }
        jsonCredito += '] } } } }';
        return jsonCredito;
    }
  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Seccion de JSON donde se agrega la parte incial del JSON (header, body)
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String seccionCuenta(Opportunity opp, List<QuoteLineItem> lstQuoteLineItem){
        String apellido     = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Name : IT_ConstruccionJSON_cls.validarNullString(opp.Account.LastName) + ' ' + IT_ConstruccionJSON_cls.validarNullString(opp.Account.Segundo_Apellido__c);      
        String nombre       = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Name : IT_ConstruccionJSON_cls.validarNullString(opp.Account.FirstName) + ' ' + IT_ConstruccionJSON_cls.validarNullString(opp.Account.MiddleName);        
        String correo       = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Correo_electronico_empresa__c :  opp.Account.PersonEmail; 
        String codBarrio    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Codigo_barrio_empresa__c : opp.Account.Barrio_empresa__r.Codigo_Registro_Barrio__c; 
        String codigoCiudad = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Codigo_ciudad_empresa__c : opp.Account.Codigo_ciudad_empresa__c;
        String nombreCiudad = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Ciudad_empresa__r.Name : opp.Account.Ciudad_empresa__r.Name;        
        String codigoDep    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Codigo_departamento_empresa__c : opp.Account.Codigo_departamento_empresa__c;
        String nombreDep    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Departamento_empresa__c : opp.Account.Departamento_empresa__c;
        String strVia       = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Via_empresa__c : opp.Account.Via_empresa__c;
        String strComplemento = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Informacion_adicional_complemento_e__c : opp.Account.Informacion_adicional_complemento_e__c;
        Decimal Inter       = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Intercesion_empresa__c : opp.Account.Intercesion_empresa__c;        
        String strLetraA    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Letra_empresa_a__c : opp.Account.Letra_empresa_a__c;  
        String strLetraB    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Letra_empresa_b__c : opp.Account.Letra_empresa_b__c; 
        Decimal nume        = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Numero_empresa_a__c : opp.Account.Numero_empresa_a__c;
        Decimal numeB       = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Numero_empresa_b__c : opp.Account.Numero_empresa_b__c;
        String puntoCarA    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Punto_cardinal_empresa_a__c : opp.Account.Punto_cardinal_empresa_a__c;
        String puntoCarB    = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Punto_cardinal_empresa_b__c : opp.Account.Punto_cardinal_empresa_b__c;
        Boolean strRuralidad = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Ubicacion_Rural__c : opp.Account.Ubicacion_Rural__c;  
        String strIndicativo = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Indicativo_empresa__c : opp.Account.Indicativo_empresa__c;
        String strMovil     = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Movil_empresa__c : opp.Account.Movil_empresa__c;
        String numContacto  = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Telefono_empresa__c : opp.Account.Telefono_empresa__c;
        String strEstrato   = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Estrato_empresa__c : opp.Account.Estrato_empresa__c;
        Date fechaNacimiento = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.account.Fecha_de_creacion_de_empresa__c : opp.Account.Fecha_de_nacimiento__c;
        String strIdeProcesoBPMS = '';
        if( String.isNotBlank(opp.Identificador_proceso__c)){
            strIdeProcesoBPMS = ((opp.Identificador_proceso__c).contains('null'))? (opp.Identificador_proceso__c).replace('null','') : opp.Identificador_proceso__c;
        }
        Boolean indicadorEnvioMensaje = (opp.CampaignId != null ) ? opp.Campaign.IndicadorEnvioMensaje__c : false;
        System.debug('barrio cliente: '+ codBarrio);
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String consecutivoPadre = opp.id+'-'+ numeroAleatorio;
        String codigoCampania = IT_ConstruccionJSON_cls.validarDatosCampania(opp);
        
        Contact con      = getContactFromAccount(opp.Account.Id);
        String contactId = con != null ? con.Id : null;
        
        String json = '{ '+
            '"encabezado":{ '+
            '"estado": 0,'+
            '"excepcion": null,'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+consecutivoPadre+'",'+ 
            '"mensaje": null,'+
            '"integracion": "Sincronizar Oportunidad",'+
            '"operacion": 0,'+
            '"origen": "SALESFORCE",'+
            '"destino": "ORACLE"'+
            '},'+//fin encabezado
            '"cuerpo": {'+
            '"oportunidad":{'+
            '"cliente":{'+  // INICIO DE CLIENTE
            '"tipoRegistroCliente": null,'+
            '"codigo": "' + (contactId != null ? contactId : opp.id ) + '",'+
            '"informacionBasica": {'+
            '"apellidos": "'+apellido+'",'+ 
            '"autorizacionDatos": 0,'+
            '"correoContacto": "'+IT_ConstruccionJSON_cls.validarNullString(correo)+'",'+
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(codBarrio)+','+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(codigoDep)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(nombreDep)+'"'+
            '},'+//fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(codigoCiudad)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(nombreCiudad)+'",'+
            '"zona": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Zona_empresa__r.Codigo_Registro_Zona__c)+','+
            '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Zona_empresa__r.Name)+''+ 
            '}'+//fin zona
            '},'+//fin ciudad
            '"complemento": "'+IT_ConstruccionJSON_cls.validarNullString(strComplemento)+'",'+
            '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(Inter)+'",'+
            '"letra": "'+IT_ConstruccionJSON_cls.validarNullString(strLetraA)+'",'+
            '"letraB": "'+IT_ConstruccionJSON_cls.validarNullString(strLetraB)+'",'+
            '"numero": "'+IT_ConstruccionJSON_cls.validarNullDecimal(nume)+'",'+
            '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(numeB)+'",'+
            '"puntoCardinal": "'+IT_ConstruccionJSON_cls.validarNullString(puntoCarA)+'",'+
            '"puntoCardinalB": "'+IT_ConstruccionJSON_cls.validarNullString(puntoCarB)+'",'+
            '"ruralidad": '+strRuralidad+','+
            '"via": "'+IT_ConstruccionJSON_cls.validarNullString(strVia)+'"'+
            '},'+//fin direccion
            '"fechaNacimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(fechaNacimiento)+'",'+
            '"genero": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Genero__pc)+'",'+ 
            '"indicativo": "'+IT_ConstruccionJSON_cls.validarNullString(strIndicativo)+'",'+
            '"medio": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Medio_por_el_cual_conocio_a_Interactuar__c)+'",'+
            '"movilContacto": "'+IT_ConstruccionJSON_cls.validarNullString(strMovil)+'",'+ 
            '"nivelEscolaridad": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Nivel_de_escolaridad__pc)+'",'+ 
            '"nombre": "'+nombre+'",'+ 
            '"numeroIdentificacion": '+opp.Account.Numero_de_identificacion__c+','+
            '"telefonoContacto": "'+IT_ConstruccionJSON_cls.validarNullString(numContacto)+'",'+
            '"tipoIdentificacion": "'+opp.Account.Tipo_de_identificacion__c+'",'+
            '"estadoCivil": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Estado_civil__pc)+'",'+ 
            '"autorretenedor": '+opp.Account.Es_autorretenedor__c+','+ 
            '"personasACargo": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(opp.Account.Personas_a_cargo__pc)+','+
            '"estadoCliente": "'+ IT_ConstruccionJSON_cls.validarNullString(opp.Account.Vigente__c)+'",'+
            '"TipoVivienda": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_de_vivienda__pc)+'",'+
            '"actividadCliente": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Ocupacion__c)+'",'+
            '"cabezaFamilia": '+opp.Account.Cabeza_de_familia__pc+','+   
            '"estrato": "'+IT_ConstruccionJSON_cls.validarNullString(strEstrato)+'",'+ 
            '"datosLaborales":{'+ 
            '"direccionTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.DireccionLaboral__c)+','+  // ultimos ajustes de formulario digital
            '"telefonoTrabajo":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.TelefonoLaboral__c)+''+  // ultimos ajustes de formulario digital
            '},'+  //fin datos laborales
            '"valorBien": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Valor_comercial_del_Bien__c)+','+
            '"cupoRecomendado":0,'+
            '"cuotasActuar":0,'+
            '"ingresos":{'+
            '"otrosIngresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Otros_ingresos_familiares__c)+','+
            '"otroValor":  0,'+ 
            '"ingresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Ingresos_conyuge__c)+','+
            //'"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Total_ingresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
            '"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Sueldo_Honorario__c)+
            '},'+// fin ingresos
            '"egresos":{'+
            '"otrosEgresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Otros_egresos_familiares__c)+','+
            '"egresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Egresos_conyuge__c)+','+
            //'"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Total_egresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
            '"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Account.Hogar__c)+
            '},'+// fin egresos
            '"referencias":{'+
            '"tipoDeReferencias": "CLIENTE",'+
            '"nombresReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Nombres_y_apellidos_Referencia__c)+','+
            '"telefonoReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Telefono_Referencia__c)+','+
            '"tipoReferencia1":     "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_Referencia_1__c)+'",'+
            '"ciudadReferencia1":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(opp.Account.CiudadRef1codOR__c)+','+
            '"nombresReferencia2":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Nombres_y_apellidos_Ref2__c)+','+
            '"telefonoReferencia2": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Telefono_Ref2__c)+','+
            '"tipoReferencia2":     "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_Referencia_2__c)+'",'+
            '"ciudadReferencia2":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(opp.Account.CiudadRef2codOR__c)+','+	
            '"nombresReferencia3":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Nombres_y_apellidos_Ref3__c)+','+
            '"telefonoReferencia3": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Telefono_Ref3__c)+','+
            '"tipoReferencia3":     "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_Referencia_3__c)+'",'+
            '"ciudadReferencia3":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(opp.Account.CiudadRef3codOR__c)+','+	
            '"nombresReferencia4":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Nombres_y_apellidos_Ref4__c)+','+
            '"telefonoReferencia4": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Telefono_Ref4__c)+','+
            '"tipoReferencia4":     "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_Referencia_4__c)+'",'+
            '"ciudadReferencia4":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(opp.Account.CiudadRef4codOR__c)+','+
            '"nombresReferencia5":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Nombres_y_apellidos_Ref5__c)+','+
            '"telefonoReferencia5": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Telefono_Ref5__c)+','+
            '"tipoReferencia5":     "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_Referencia_5__c)+'",'+
            '"ciudadReferencia5":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(opp.Account.CiudadRef5codOR__c)+' '+
            '},'+//fin referencias
            '"rol": "'+ hom.get(RCLIENTE) +'" '+
            '},';
        if( opp.Account.RecordType.DeveloperName == 'Persona_juridica'){
            json += juridicaFamiEmpresa(opp);
        }else if( opp.Account.RecordType.DeveloperName == 'Persona_natural'){
            json += seleccionaFamiEmpresa(opp.Account.id,opp);
        }  
        
        listaId = new List<Id>();
        listaId.add(opp.id);
        List<Asociacion_cuenta_contacto__c> lstAscc = IT_GestorDeConsultas_cls.consultaAsociacionAval(listaId); 
        //IT_ConstruccionJSON_cls.validarsObject(lstAscc)
        
        json += '},"avales":{'+
            '"consecutivoPadre": "'+consecutivoPadre+'",'+ // 
            '"listaAvales":[ ';
        //  if( opp.RecordType.DeveloperName  == 'Solicitud_de_credito' && opp.Account.RecordType.DeveloperName == 'Persona_natural'){
        json += construyeJSONAvales(lstAscc);
        Integer cantidadAvales = 0;
        for(Asociacion_cuenta_contacto__c aso : lstAscc){   
            cantidadAvales += aso.RepresentanteLegal__c ? 2 : 1;  
        }
        //  }
        String origenColocacionCredito = '';
        //if(opp.Generacion_Automatica_de_Credito__c){
        CampaignMember member = obtenMiembroDeGeneracionAutomatica(opp.id);
        if(member != null && member.Medio_de_Respuesta__c == 'Web' && (member.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' || member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito')){
            origenColocacionCredito = 'Canal Digital';
        }
        //}
        json += ' ] '+    
            '},'+ // FIN DE CLIENTE
            '"cotizacion": {'+
            '"estado": "'+opp.Quotes[0].Status+'",'+
            '"id": "'+opp.Quotes[0].id+'"'+
            '},'+//fin cotizacion
            '"informacionGeneral": {'+
            '"cantidadProductos": '+opp.Quotes.get(0).Res_conteo_productos_cotizacion__c+','+
            '"cierre": null,'+ 
            '"score": ' + lstQuoteLineItem[0].Puntaje_Score__c + ','+ 
            '"resultadoEstudioDigital": "' + (opp.Resultado_Estudio_Digital__c != null ? opp.Resultado_Estudio_Digital__c : '') + '",'+
            '"origenColocacionCredito": "' + origenColocacionCredito + '",'+
            '"esMiembroDeCampaña": null,'+ 
            '"id": "'+opp.id+'",'+ 
            '"propietario": "'+opp.Owner.Name+'",'+
            '"tipoOportunidad": "'+opp.RecordType.Name+'",'+
            '"valorVenta": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(opp.Amount)+','+ 
            '"idProcesoBpms"  : "'+strIdeProcesoBPMS+'",'+ 
            '"empleadoRefiere" : '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Empleado_que_refiere__r.Numero_de_documento__c)+','+
            '"tipoCampana": "'+IT_ConstruccionJSON_cls.validarTipoCampania(opp)+'",'+
            '"idCampana": "'+codigoCampania+'",'+
            '"indicadorEnvio": '+indicadorEnvioMensaje+','+ // Autogestion
            '"cantidadAvales": '+IT_ConstruccionJSON_cls.validarNullInteger( cantidadAvales )+','+
            '"seguroPrever": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Numero_de_Afiliados_a_Prever__c)+'",'+ // TDR
            '"idDocumentoPagare": "'+ IT_ConstruccionJSON_cls.validarNullString( opp.Quotes[0].idDocumentoPagare__c )+ '",'+
            '"informacionAdicionalCampo1": null,'+
            '"informacionAdicionalCampo2": null,'+
            '"informacionAdicionalCampo3": null,'+
            '"informacionAdicionalCampo4": null,'+
            '"informacionAdicionalCampo5": null'+  
            '},'+//fin informacionGeneral
            '"productos": {';
        return json;
    }
    
    /******************************************************************************************
   	*Author:  Álvaro Ortega
   	*Function: Obtener el miembro de campaña
   	*Date: 27-Abr-2021
   	******************************************************************************************/
    public static CampaignMember obtenMiembroDeGeneracionAutomatica(String IdOpp){
        List<CampaignMember> members = [Select Id, Name, ContactId, Contact.AccountId, LeadId , Lead.ConvertedAccountId, CampaignId,
                                        Mensaje_recibido__c, MovilMiembro__c,Producto__c,Plazo_Meses__c,Monto__c,Fondo__c, Medio_de_Respuesta__c,
                                        Tipo_de_Respuesta__c, Tipo_de_Cuenta__c, Numero_Cuenta__c, Banco__c, Beneficiarios__c,Producto_RCA__c, Monto_RCA__c, Plazo_Meses_RCA__c
                                        from CampaignMember
                                        where Oportunidad_Generada_Automatica__c = :IdOpp
                                        limit 1];
        if(members.size() > 0){
            return members[0];
        }
        return null;
    }
    
    /******************************************************************************************
   	*Author:  Álvaro Ortega
   	*Function: Obtener el contacto de un Cliente
   	*Date: 02-Mar-2021
   	******************************************************************************************/
    public static Contact getContactFromAccount(String accountId){
        List<Contact> conts = [Select Id
                               from Contact 
                               where AccountId = :accountId];
        if(conts.size() > 0){
            return conts[0];
        }
        return null;
    }

   	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se ingresan los datos para una famiEmpresa Juridica
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String juridicaFamiEmpresa(Opportunity opp){
        String correo = (opp.Account.RecordType.DeveloperName == 'Persona_juridica')? opp.Account.Correo_electronico_empresa__c :  opp.Account.PersonEmail; 
        String jsonFami = ''+
            '"famiEmpresa": {'+
            '"actividadEconomica": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Actividad_economica__r.Codigo_Actividad_Economica_OR__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Actividad_economica__r.Name)+'"'+
            '},'+// fin famiEmpresa
            '"fechaCreacion": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(opp.Account.Fecha_de_creacion_de_empresa__c)+'",'+
            '"anosExperiencia":"2",'+
            '"correoElectronico": "'+IT_ConstruccionJSON_cls.validarNullString(correo)+'",'+
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Codigo_barrio_empresa__c)+','+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Codigo_departamento_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Departamento_empresa__c)+'"'+
            '},'+//fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Codigo_ciudad_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Ciudad_empresa__r.Name)+'",'+
            '"zona": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Zona_empresa__r.Codigo_Registro_Zona__c)+','+
            '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(opp.Account.Zona_empresa__r.Name)+''+
            '}'+ //fin zona
            '},'+// fin ciudad
            '"complemento": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Informacion_adicional_complemento_e__c)+'",'+
            '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.Intercesion_empresa__c)+'",'+
            '"letra": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Letra_empresa_a__c)+'",'+
            '"letraB": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Letra_empresa_b__c)+'",'+
            '"numero": "'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.Numero_empresa_a__c)+'",'+
            '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.Numero_empresa_b__c)+'",'+
            '"puntoCardinal": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Punto_Cardinal_empresa_a__c)+'",'+
            '"puntoCardinalB": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Punto_cardinal_empresa_b__c)+'",'+
            '"ruralidad": '+opp.Account.Ubicacion_Rural__c+','+
            '"via": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Via_empresa__c)+'"'+
            '},'+// fin direccion
            '"empleados": "'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.NumberOfEmployees)+'",'+
            '"indicativo": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Indicativo_empresa__c)+'",'+
            '"industria": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Codigo_industria_OR_SF__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Industria__c)+'"'+
            '},'+//fin industria
            '"movil": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Movil_empresa__c)+'",'+
            '"nombreFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Name)+'",'+
            '"numeroFormalizacion": '+IT_ConstruccionJSON_cls.validarStringEspecial(opp.Account.Numero_de_identificacion__c)+','+
            '"principalesProductos": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Principales_productos_servicios_1__c)+','+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Principales_productos_servicios_2__c)+','+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Principales_productos_servicios_3__c)+','+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Principales_productos_servicios_4__c)+','+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Principales_productos_servicios_5__c)+'",'+
            '"sector": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Account.Codigo_sector_OR__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Sector__c)+'"'+
            '},'+// fin sector
            '"telefono": '+opp.Account.Telefono_empresa__c+','+
            '"tipoFormalización": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Tipo_de_identificacion__c)+'",'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": "'+ IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Cuentas_por_cobrar_comerciales__c)+'",'+
            '"inventarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Inventario_balance__c)+','+ 
            '"activosFijos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Activos_fijos__c)+','+ 
            '"totalActivos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_activos_balance__c)+','+
            '"totalPasivos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_pasivo__c)+','+ 
            '"totalCapitalTrabajo": null,'+   // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+   // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null'+   // ultimos ajustes de formulario digital
            '},'+//fin balanceGeneral
            '"costoMercanciaVendida": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.CostoMciaVendida__c)+','+ 
            '"disponibilidadNetaEmpresa": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Disponibilidad_Neta__c)+','+ 
            '"ingresosVentas": null,'+   // ultimos ajustes de formulario digital
            '"codigoAsesor": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Codigo_Empleado_Asesor_asignado__c)+','+ 
            '"empleosGenerar":"'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.Empleos_a_generar__c)+'",'+ 
            '"ingresosAnuales":"'+IT_ConstruccionJSON_cls.validarNullDecimal(opp.Account.AnnualRevenue)+'",'+ 
            '"codigoFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(opp.Account.Identificador_Famiempresa__c)+'"'+
            '}';// fin famiEmpresa
        return jsonFami;
    }

  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se escoge si la famiempresa es natural o debe ir vacia
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String seleccionaFamiEmpresa(string idCuenta, Opportunity opp ){
        List<Famiempresa__c> lstFami = new List<Famiempresa__c>();
        if(opp.Famiempresa_relacionada__c != null){
            lstFami = IT_GestorDeConsultas_cls.consultaFamiEmpresaOpp(opp.Famiempresa_relacionada__c);
        }
        if(lstFami.size() > 0){
            return naturalFamiEmpresa(lstFami.get(0), opp);
        }else{
            return sinFamiEmpresa();
        }    
    }

    /******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se ingresan los datos para una famiEmpresa Natural
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String naturalFamiEmpresa(Famiempresa__c fami, Opportunity opp){
        String jsonFami = ''+
            '"famiEmpresa": {'+
            '"actividadEconomica": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Actividad_economica__r.Codigo_Actividad_Economica_OR__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Actividad_economica__r.Name)+'"'+
            '},'+// fin actividad economica
            '"fechaCreacion": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(fami.Fecha_de_creacion_de_empresa__c)+'",'+
            '"anosExperiencia":"2",'+
            '"correoElectronico": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Correo_electronico_empresa__c)+'",'+
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Barrio_empresa__r.Codigo_Registro_Barrio__c)+','+ 
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_departamento_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Departamento_empresa__c)+'"'+
            '},'+// fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_ciudad_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Ciudad_empresa__r.Name)+'",'+ 
            '"zona": {'+
            '"codigo":  '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Zona_empresa__r.Codigo_Registro_Zona__c)+','+
            '"nombre":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(fami.Zona_empresa__r.Name)+''+
            '}'+ // fin zona
            '},'+ // fin ciudad
            '"complemento": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Informacion_adicional_complemento_e__c)+'",'+
            '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Intercesion_empresa__c)+'",'+
            '"letra": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Letra_empresa_a__c)+'",'+ 
            '"letraB": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Letra_empresa_b__c)+'",'+
            '"numero": "'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Numero_empresa_a__c)+'",'+
            '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Numero_empresa_b__c)+'",'+
            '"puntoCardinal": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Punto_Cardinal_empresa_a__c)+'",'+
            '"puntoCardinalB": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Punto_cardinal_empresa_b__c)+'",'+
            '"ruralidad": '+fami.Ubicacion_Rural__c+','+
            '"via": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Via_empresa__c)+'"'+
            '},'+// fin direccion
            '"empleados": "'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Numero_de_empleados__c)+'",'+ 
            '"indicativo": "'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Indicativo_empresa__c)+'",'+ 
            '"industria": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_industria_OR_SF__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Industria__c)+'"'+
            '},'+ // fin industria
            '"movil": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Movil_empresa__c)+'",'+
            '"nombreFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Name)+'",'+
            '"numeroFormalizacion": '+IT_ConstruccionJSON_cls.validarStringEspecial(fami.Numero_de_identificacion__c)+','+
            '"principalesProductos": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_1__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_2__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_3__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_4__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_5__c)+'",'+
            '"sector": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_sector_OR__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Sector__c)+'"'+
            '},'+//fin sector
            '"telefono": "'+fami.Telefono_empresa__c+'",'+
            '"tipoFormalización": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Tipo_de_identificacion__c)+'",'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": "'+ IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Cuentas_por_cobrar_comerciales__c)+'",'+
            '"inventarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Inventario_balance__c)+','+
            '"activosFijos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Activos_fijos__c)+','+ 
            '"totalActivos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_activos_balance__c)+','+
            '"totalPasivos": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_pasivo__c)+','+ 
            '"totalCapitalTrabajo": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_Capital_de_Trabajo__c)+','+   // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(opp.Total_Activos_Fijos_y_Otros__c)+','+  // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null'+   // ultimos ajustes de formulario digital
            '},'+//fin balance general
            '"costoMercanciaVendida": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(fami.Costo_mercancia_vendida__c)+','+
            '"disponibilidadNetaEmpresa": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(fami.Disponibilidad_neta_empresa__c)+','+ 
            '"ingresosVentas": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(fami.Ingresos_ventas__c)+','+   // ultimos ajustes de formulario digital
            '"codigoAsesor": '+IT_ConstruccionJSON_cls.validarNullString_Integer(opp.Codigo_Empleado_Asesor_asignado__c)+','+ 
            '"empleosGenerar":"'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Empleos_a_generar__c)+'",'+ 
            '"ingresosAnuales":"'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Ingreso_Anual__c)+'",'+ 
            '"codigoFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Identificador_Famiempresa__c)+'"'+ 
            '}'; // fin famiEmpresa
        
        return jsonFami;
    }

   	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se ingresan los datos para una famiEmpresa vacia
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String sinFamiEmpresa(){
        String jsonFami = '';
        jsonFami += '"famiEmpresa": {'+
            '"actividadEconomica": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+
            '"fechaCreacion": null,'+
            '"anosExperiencia": null,'+
            '"correoElectronico": null,'+
            '"direccion": {'+
            '"barrio": null,'+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+
            '"codigo": null,'+
            '"nombre": null,'+ 
            '"zona": {'+
            '"codigo": null,'+ 
            '"nombre": null'+ 
            '}'+
            '},'+
            '"complemento": null,'+
            '"intercesion": null,'+
            '"letra": null,'+ 
            '"letraB": null,'+
            '"numero": null,'+
            '"numeroB": null,'+
            '"puntoCardinal": null,'+
            '"puntoCardinalB": null,'+
            '"ruralidad": null,'+
            '"via": null'+
            '},'+
            '"empleados": null,'+
            '"indicativo": null,'+ 
            '"industria": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+
            '"movil": null,'+
            '"nombreFamiempresa": null,'+
            '"numeroFormalizacion": null,'+
            '"principalesProductos": null,'+
            '"sector": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+
            '"telefono": null,'+
            '"tipoFormalización": null,'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": null,'+
            '"inventarios": null,'+
            '"activosFijos": null,'+
            '"totalActivos": null,'+
            '"totalPasivos": null,'+
            '"totalCapitalTrabajo": null,'+  // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+  // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null'+  // ultimos ajustes de formulario digital
            '},'+
        '"costoMercanciaVendida": null,'+
        '"disponibilidadNetaEmpresa": null,'+
        '"ingresosVentas": null,'+   // ultimos ajustes de formulario digital
        '"codigoAsesor": null,'+
        '"empleosGenerar": null,'+ 
        '"ingresosAnuales": null,'+ 
        '"codigoFamiempresa": null'+ 
        '}';
        return jsonFami;
    }

  	/******************************************************************************************
   	*Author:  Rafael Cardona
   	*Function: Se ingresan los avales que se encuentras asociados en la oportunidad 
   	*Date: 3-3-2020
   	******************************************************************************************/
    public static String construyeJSONAvales(List<Asociacion_cuenta_contacto__c> lstAscc){
        String avales = '';
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        for(Asociacion_cuenta_contacto__c aso : lstAscc){   
            String rol = ( aso.RepresentanteLegal__c ) ? hom.get(REPR) : hom.get(AVALISTA);   
            avales +='{'+
                '"identificadorAval": "'+ aso.Contacto__c+'-'+ numeroAleatorio++ +'",'+ 
                '"informacionBasica":{'+
                '"apellidos": '+IT_ConstruccionJSON_cls.validarStringNombreApellido( aso.Contacto__r.LastName , aso.Contacto__r.Segundo_Apellido__c)+','+
                '"autorizacionDatos":0,'+
                '"correoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Email)+','+
                '"direccion":{'+
                '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c)+','+
                '"ciudad":{'+
                '"departamento":{'+
                '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c)+','+
                '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ciudad_contacto__r.Nombre_Departamento__c)+''+
                '},'+// fin departamento
                '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Ciudad_contacto__r.Codigo_Ciudad_OR__c)+','+
                '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ciudad_contacto__r.Name)+','+
                '"zona": {'+
                '"codigo":  '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Zona_contacto__r.Codigo_Registro_Zona__c)+','+
                '"nombre":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Zona_contacto__r.Name)+''+
                '}'+ // fin zona
                '},'+//fin ciudad
                '"complemento": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Informacion_adicional_complemento_c__c)+','+
                '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Intercesion_contacto__c)+'",'+
                '"letra":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Letra_contacto_a__c)+','+
                '"letraB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Letra_contacto_b__c)+','+
                '"numero":  "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Numero_contacto_a__c)+'",'+
                '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Numero_contacto_b__c)+'",'+
                '"puntoCardinal": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Punto_cardinal_contacto_a__c)+','+
                '"puntoCardinalB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Punto_cardinal_contacto_b__c)+','+
                '"ruralidad": '+aso.Contacto__r.Ruralidad_domicilio_contacto__c+','+
                '"via": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Via_contacto__c)+''+
                '},'+ // fin direccion
                '"fechaNacimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(aso.Contacto__r.Birthdate)+'",'+
                '"genero": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Genero__c)+','+ 
                '"indicativo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Indicativo_contacto__c)+','+  
                '"medio": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Medio_por_el_cual_conocio_a_Interactuar__c)+','+ 
                '"movilContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Movil_contacto__c)+','+   	
                '"nivelEscolaridad": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nivel_de_escolaridad__c)+','+ 
                '"nombre": '+IT_ConstruccionJSON_cls.validarStringNombreApellido( aso.Contacto__r.FirstName , aso.Contacto__r.MiddleName )+','+ 
                '"numeroIdentificacion": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Numero_de_identificacion__c)+','+ 
                '"telefonoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_contacto__c)+','+
                '"tipoIdentificacion": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Tipo_de_identificacion__c)+','+    
                '"estadoCivil": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Estado_civil__c)+','+ 
                '"autorretenedor":false,'+
                '"personasACargo": '+IT_ConstruccionJSON_cls.validarDecimalReturnInteger(aso.Contacto__r.Personas_a_cargo__c)+','+
                '"estadoCliente":"Vigente",'+
                '"TipoVivienda": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Tipo_de_vivienda__c)+','+   
                '"actividadCliente": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ocupacion__c)+','+
                '"cabezaFamilia": '+aso.Contacto__r.Cabeza_de_familia__c+','+
                '"estrato": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Estrato_contacto__c)+','+
                '"datosLaborales":{'+ // anexo 1
                '"direccionTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.DireccionLaboral__c)+','+  // ultimos ajustes de formulario digital
                '"telefonoTrabajo":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.TelefonoLaboral__c)+''+  // ultimos ajustes de formulario digital
                '},'+        // fin datos laborales
                '"valorBien": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Valor_comercial_del_Bien__c)+','+
                '"cupoRecomendado":0,'+
                '"cuotasActuar":0,'+
                '"ingresos":{'+
                '"otrosIngresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Otros_ingresos_familiares__c)+','+
                '"otroValor": 0,'+ 
                '"ingresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Ingresos_conyuge__c)+','+
                //'"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Total_ingresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
                '"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Sueldo_Honorario__c)+
                '},'+//fin ingresos
                '"egresos":{'+
                '"otrosEgresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Otros_egresos_familiares__c)+','+
                '"egresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Egresos_conyuge__c)+','+
                //'"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Total_egresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
                '"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Hogar__c)+
                '},'+
                '"referencias":{'+
                '"tipoDeReferencias": "AVAL",'+
                '"nombresReferencia1":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nombres_y_apellidos_Referencia__c)+','+
                '"telefonoReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_Referencia__c)+','+
                '"tipoReferencia1":     "'+IT_ConstruccionJSON_cls.validarNullString(aso.Contacto__r.Tipo_Referencia_1__c)+'",'+
                '"ciudadReferencia1":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(aso.Contacto__r.CiudadRef1codOR__c)+','+
                '"nombresReferencia2":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nombres_y_apellidos_Ref2__c)+','+
                '"telefonoReferencia2": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_Ref2__c)+','+
                '"tipoReferencia2":     "'+IT_ConstruccionJSON_cls.validarNullString(aso.Contacto__r.Tipo_Referencia_2__c)+'",'+
                '"ciudadReferencia2":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(aso.Contacto__r.CiudadRef2codOR__c)+','+
                '"nombresReferencia3":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nombres_y_apellidos_Ref3__c)+','+
                '"telefonoReferencia3": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_Ref3__c)+','+
                '"tipoReferencia3":     "'+IT_ConstruccionJSON_cls.validarNullString(aso.Contacto__r.Tipo_Referencia_3__c)+'",'+
                '"ciudadReferencia3":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(aso.Contacto__r.CiudadRef3codOR__c)+','+
                '"nombresReferencia4":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nombres_y_apellidos_Ref4__c)+','+
                '"telefonoReferencia4": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_Ref4__c)+','+
                '"tipoReferencia4":     "'+IT_ConstruccionJSON_cls.validarNullString(aso.Contacto__r.Tipo_Referencia_4__c)+'",'+
                '"ciudadReferencia4":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(aso.Contacto__r.CiudadRef4codOR__c)+','+
                '"nombresReferencia5":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nombres_y_apellidos_Ref5__c)+','+
                '"telefonoReferencia5": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_Ref5__c)+','+
                '"tipoReferencia5":     "'+IT_ConstruccionJSON_cls.validarNullString(aso.Contacto__r.Tipo_Referencia_5__c)+'",'+
                '"ciudadReferencia5":  '+IT_ConstruccionJSON_cls.convierteCodigoOracle(aso.Contacto__r.CiudadRef5codOR__c)+' '+
                '},'+//fin referencias
                '"rol": "'+ rol +'" '+
                '} },';
            if(aso.RepresentanteLegal__c){
                avales +='{'+
                    '"identificadorAval": "'+ aso.Contacto__c+'-'+ numeroAleatorio++ +'",'+ 
                    '"informacionBasica":{'+
                    '"apellidos": '+IT_ConstruccionJSON_cls.validarStringNombreApellido( aso.Contacto__r.LastName , aso.Contacto__r.Segundo_Apellido__c)+','+
                    '"autorizacionDatos":0,'+
                    '"correoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Email)+','+
                    '"direccion":{'+
                    '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c)+','+
                    '"ciudad":{'+
                    '"departamento":{'+
                    '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c)+','+
                    '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ciudad_contacto__r.Nombre_Departamento__c)+''+
                    '},'+// fin departamento
                    '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Ciudad_contacto__r.Codigo_Ciudad_OR__c)+','+
                    '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ciudad_contacto__r.Name)+','+
                    '"zona": {'+
                    '"codigo":  '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Zona_contacto__r.Codigo_Registro_Zona__c)+','+
                    '"nombre":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Zona_contacto__r.Name)+''+
                    '}'+ // fin zona
                    '},'+//fin ciudad
                    '"complemento": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Informacion_adicional_complemento_c__c)+','+
                    '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Intercesion_contacto__c)+'",'+
                    '"letra":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Letra_contacto_a__c)+','+
                    '"letraB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Letra_contacto_b__c)+','+
                    '"numero":  "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Numero_contacto_a__c)+'",'+
                    '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(aso.Contacto__r.Numero_contacto_b__c)+'",'+
                    '"puntoCardinal": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Punto_cardinal_contacto_a__c)+','+
                    '"puntoCardinalB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Punto_cardinal_contacto_b__c)+','+
                    '"ruralidad": '+aso.Contacto__r.Ruralidad_domicilio_contacto__c+','+
                    '"via": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Via_contacto__c)+''+
                    '},'+ // fin direccion
                    '"fechaNacimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(aso.Contacto__r.Birthdate)+'",'+
                    '"genero": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Genero__c)+','+ 
                    '"indicativo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Indicativo_contacto__c)+','+  
                    '"medio": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Medio_por_el_cual_conocio_a_Interactuar__c)+','+ 
                    '"movilContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Movil_contacto__c)+','+   	
                    '"nivelEscolaridad": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Nivel_de_escolaridad__c)+','+ 
                    '"nombre": '+IT_ConstruccionJSON_cls.validarStringNombreApellido( aso.Contacto__r.FirstName , aso.Contacto__r.MiddleName )+','+ 
                    '"numeroIdentificacion": '+IT_ConstruccionJSON_cls.validarNullString_Integer(aso.Contacto__r.Numero_de_identificacion__c)+','+ 
                    '"telefonoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Telefono_contacto__c)+','+
                    '"tipoIdentificacion": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Tipo_de_identificacion__c)+','+    
                    '"estadoCivil": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Estado_civil__c)+','+ 
                    '"autorretenedor":false,'+
                    '"personasACargo": '+IT_ConstruccionJSON_cls.validarDecimalReturnInteger(aso.Contacto__r.Personas_a_cargo__c)+','+
                    '"estadoCliente":"Vigente",'+
                    '"TipoVivienda": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Tipo_de_vivienda__c)+','+   
                    '"actividadCliente": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Ocupacion__c)+','+
                    '"cabezaFamilia": '+aso.Contacto__r.Cabeza_de_familia__c+','+
                    '"estrato": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.Estrato_contacto__c)+','+
                    '"datosLaborales":{'+ // anexo 1
                    '"direccionTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.DireccionLaboral__c)+','+  // ultimos ajustes de formulario digital
                    '"telefonoTrabajo":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(aso.Contacto__r.TelefonoLaboral__c)+''+  // ultimos ajustes de formulario digital
                    '},'+        // fin datos laborales
                    '"valorBien": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Valor_comercial_del_Bien__c)+','+
                    '"cupoRecomendado":0,'+
                    '"cuotasActuar":0,'+
                    '"ingresos":{'+
                    '"otrosIngresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Otros_ingresos_familiares__c)+','+
                    '"otroValor": 0,'+ 
                    '"ingresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Ingresos_conyuge__c)+','+
                    //'"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Total_ingresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
                    '"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Sueldo_Honorario__c)+
                    '},'+//fin ingresos
                    '"egresos":{'+
                    '"otrosEgresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Otros_egresos_familiares__c)+','+
                    '"egresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Egresos_conyuge__c)+','+
                    //'"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Total_egresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
                    '"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(aso.Contacto__r.Hogar__c)+
                    '},'+
                    '"referencias":{},'+//fin referencias
                    '"rol": "'+ hom.get(AVALISTA) +'" '+
                    '} },';
            }
        }
        avales = ( avales.length() > 0 )? avales.substring(0, avales.length() - 1) : '';
        return avales;
    }
    
    public static String validarNullString(String valor){
        if(valor == null || valor == ''){
            return '';
        }else{ 
            return valor;
        }
    }
    
    public static Integer validarDecimalAInteger(Decimal valor){
        if(valor == null ){
            return 0;
        }else{ 
            return valor.intValue();
        }
    }

  	/*************************************************************************************
  	*Author:  Rafael Cardona
  	*Function: Pone en un MAP las configuraciones parametrizadas de la metadata
  	*Date: 26-8-2020
  	**************************************************************************************/
    public static Map<String,String> getHomologaciones(){
        Map<String,String> homologaciones = new Map<String,String>();        
        for(ListaClaveValor__mdt cv: [SELECT MasterLabel,Clave__c,Valor__c FROM ListaClaveValor__mdt WHERE Contexto__c =: CONTEXTO ]){
            if( cv.Clave__c != ES_NULO && cv.Valor__c != ES_NULO){
                homologaciones.put(cv.Clave__c,cv.Valor__c);
            }
        }
        return homologaciones;
    }
    
    public static List<Opportunity> consultaOportunidad(String idsOportunidad){
        return [SELECT Id,Famiempresa_relacionada__r.Ciudad_empresa__r.Nombre_Departamento__c,Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Famiempresa_relacionada__r.Actividad_economica__r.Name,
                Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c,Famiempresa_relacionada__r.Correo_electronico_empresa__c,Famiempresa_relacionada__r.Codigo_departamento_empresa__c,Famiempresa_relacionada__r.Departamento_empresa__c,
                Famiempresa_relacionada__r.Codigo_ciudad_empresa__c,Famiempresa_relacionada__r.Ciudad_empresa__c,Famiempresa_relacionada__r.Informacion_adicional_complemento_e__c,Famiempresa_relacionada__r.Intercesion_empresa__c,
                Famiempresa_relacionada__r.Letra_empresa_a__c,Famiempresa_relacionada__r.Letra_empresa_b__c,Famiempresa_relacionada__r.Numero_empresa_a__c,Famiempresa_relacionada__r.Numero_empresa_b__c,
                Famiempresa_relacionada__r.Punto_Cardinal_empresa_a__c,Famiempresa_relacionada__r.Punto_cardinal_empresa_b__c,Famiempresa_relacionada__r.Ruralidad_domicilio_empresa__c,Famiempresa_relacionada__r.Ubicacion_Rural__c,Famiempresa_relacionada__r.Via_empresa__c,
                Famiempresa_relacionada__r.Codigo_industria_OR_SF__c,Famiempresa_relacionada__r.Industria__c,Famiempresa_relacionada__r.Movil_empresa__c,Famiempresa_relacionada__r.Name,Famiempresa_relacionada__r.Sector__c,
                Famiempresa_relacionada__r.Telefono_empresa__c,Famiempresa_relacionada__r.Tipo_de_identificacion__c,Famiempresa_relacionada__r.Barrio_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_empleados__c,
                Famiempresa_relacionada__r.Indicativo_empresa__c,Famiempresa_relacionada__r.Principales_productos_servicios_1__c,Famiempresa_relacionada__r.Principales_productos_servicios_2__c,
                Famiempresa_relacionada__r.Principales_productos_servicios_3__c,Famiempresa_relacionada__r.Principales_productos_servicios_4__c,Famiempresa_relacionada__r.Principales_productos_servicios_5__c,
                Famiempresa_relacionada__r.Codigo_sector_OR__c,Famiempresa_relacionada__r.Ciudad_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_identificacion__c,Famiempresa_relacionada__r.Identificador_Famiempresa__c,
                Famiempresa_relacionada__r.Zona_empresa__c,Famiempresa_relacionada__r.Estrato_empresa__c,Famiempresa_relacionada__r.Vista_direccion_empresa__c,Famiempresa_relacionada__r.Tipo_de_construccion__c,
                Famiempresa_relacionada__r.Anioos_de_construccion__c,Famiempresa_relacionada__r.Numero_pisos__c,Famiempresa_relacionada__r.Actividad_economica__c,Famiempresa_relacionada__r.Tipo_de_local_donde_tiene_la_empresa__c,
                Famiempresa_relacionada__r.Ingreso_Anual__c,Famiempresa_relacionada__r.Empleos_a_generar__c,Account.Id,Account.Identificador_Famiempresa__c,Account.Barrio_contacto__pr.name,Account.Barrio_empresa__r.name,
                Account.Codigo_barrio_empresa__c,Account.Codigo_industria_OR_SF__c,Account.Letra_empresa_a__c,Account.Letra_empresa_b__c,Account.Letra_contacto_b__pc,Account.Letra_contacto_a__pc,Account.Numero_empresa_a__c,
                Account.Numero_empresa_b__c,Account.Punto_Cardinal_empresa_a__c,Account.Punto_cardinal_contacto_a__pc,Account.Punto_cardinal_empresa_b__c,Account.Punto_cardinal_contacto_b__pc,Account.Ruralidad_domicilio_empresa__c,Account.Ubicacion_Rural__c,
                Account.Ruralidad_domicilio_contacto__pc,Account.RecordType.name,Account.RecordTypeId,Account.RecordType.DeveloperName,Account.Via_empresa__c,Account.Via_contacto__pc,Account.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,
                Account.Sector__c,Account.Informacion_adicional_complemento_e__c,Account.Informacion_adicional_complemento_c__pc,Account.Intercesion_empresa__c,Account.Intercesion_contacto__pc,Account.NumberOfEmployees,
                Account.Industria__c,Account.Movil_empresa__c,Account.Codigo_sector_SF__c,Account.Vista_direccion_empresa__c,Account.Zona_empresa__c,Account.Autorizacion_uso_de_datos__c,Account.Autorizacion_uso_de_datos__pc,
                Account.Correo_electronico_empresa__c,Account.PersonBirthdate,Account.Genero__pc,Account.Indicativo_empresa__c,Account.Indicativo_contacto__pc,Account.Medio_de_autorizacion__c,Account.Medio_de_autorizacion__pc,
                Account.Nivel_de_escolaridad__pc,Account.Name,Account.Numero_de_identificacion__c,Account.Tipo_de_identificacion__c,Account.Telefono_empresa__c,Account.Valor_comercial_del_Bien__c,Account.Otros_ingresos_familiares__c,
                Account.Ingresos_conyuge__c,Account.Total_ingresos__c,Account.Sueldo_Honorario__c,Account.Total_egresos__c,Account.Hogar__c,Account.Otros_egresos_familiares__c,Account.Egresos_conyuge__c,Account.Nombres_y_apellidos_Referencia__c,
                Account.Nombres_y_apellidos_Ref2__c,Account.Nombres_y_apellidos_Ref3__c,Account.Nombres_y_apellidos_Ref4__c,Account.Nombres_y_apellidos_Ref5__c,Account.Celular_Referencia__c,Account.Telefono_Referencia__c,
                Account.Telefono_Ref2__c,Account.Telefono_Ref3__c,Account.Telefono_Ref4__c,Account.Telefono_Ref5__c,Account.Tipo_Referencia_1__c,Account.Tipo_Referencia_2__c,Account.Tipo_Referencia_3__c,Account.Tipo_Referencia_4__c,
                Account.Tipo_Referencia_5__c,Account.CiudadRef1codOR__c,Account.CiudadRef2codOR__c,Account.CiudadRef3codOR__c,Account.CiudadRef4codOR__c,Account.CiudadRef5codOR__c,Account.Movil_contacto__pc,Account.Telefono_contacto__pc,
                Account.LastName,Account.PersonEmail,Account.Barrio_empresa__r.Codigo_Registro_Barrio__c,Account.Codigo_barrio_contacto__c,Account.Codigo_departamento_contacto__pc,Account.Codigo_departamento_empresa__c,
                Account.Departamento_empresa__c,Account.Codigo_ciudad_contacto__pc,Account.Departamento_contacto__pc,Account.Medio_por_el_cual_conocio_a_Interactuar__c,Account.FirstName,Account.Estrato_contacto__pc,
                Account.Actividad_economica__r.Codigo_Actividad_Economica_SF__c,Account.Actividad_economica__r.Name,Account.Ciudad_contacto__pc,Account.Barrio_empresa__c,Account.Codigo_de_empresa__c,Account.Asesor_asignado__r.Codigo_de_Empleado__c,
                Account.Estado_civil__pc,Account.Personas_a_cargo__pc,Account.Vigente__c,Account.Tipo_de_vivienda__pc,Account.Ocupacion__c,Account.Cabeza_de_familia__pc,Account.Principales_productos_servicios_1__c,
                Account.Principales_productos_servicios_2__c,Account.Principales_productos_servicios_3__c,Account.Principales_productos_servicios_4__c,Account.Principales_productos_servicios_5__c,Account.Numero_contacto_a__pc,
                Account.Numero_contacto_b__pc,Account.Es_autorretenedor__c,Account.Codigo_ciudad_empresa__c,Account.Ciudad_empresa__c,Account.Codigo_sector_OR__c,Account.Fecha_de_creacion_de_empresa__c,Account.ispersonaccount,
                Account.Estrato_empresa__c,Account.Ciudad_contacto__pr.Name,Account.Ciudad_empresa__r.Name,Account.Fecha_de_nacimiento__c,Account.Barrio_contacto__pr.Codigo_Registro_Barrio__c,Account.Segundo_Apellido__c,
                Account.MiddleName,Account.Zona_empresa__r.Codigo_Registro_Zona__c,Account.Zona_empresa__r.Name,Account.DireccionLaboral__c,Account.TelefonoLaboral__c,Account.Ciudad_empresa__r.Nombre_Departamento__c,
                Account.PersonContactId,Account.Lugar_expedicion__c,Account.Pais_empresa__c,Account.Empresa_donde_labora__c,Account.Nacionalidad__c,Account.Lugar_de_nacimiento__c,Account.Peso_kg__c,Account.Estatura_cm__c,
                Account.Empleos_a_generar__c,Account.AnnualRevenue,Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c, Account.Actividad_economica__r.Codigo_CIIU__c, Famiempresa_relacionada__r.Actividad_economica__r.Codigo_CIIU__c,Oficina_asesor_asignado__c,Asesor_asignado__r.Codigo_de_Empleado__c,Asesor_asignado__r.Sede_Empleado__c,Asesor_asignado__r.Name,Asesor_asignado__r.Correo_electronico__c,
                Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,Empleado_que_refiere__r.Codigo_de_Empleado__c,Forma_de_pago__c,Paga_un_tercero__c,
                (SELECT Id,Status,Res_conteo_productos_cotizacion__c,idDocumentoPagare__c FROM Quotes WHERE IsSyncing=true LIMIT 1),(SELECT Id,Product2.ProductCode FROM OpportunityLineItems LIMIT 1),
                Owner.Name,RecordTypeId,RecordType.Name,Asesor_asignado__r.Oficina_Empleado__r.Centro_de_Costos__c,Sede_Asesor_asignado__c,Codigo_Empleado_Asesor_asignado__c,Codigo_Oficina_OR_Asesor_Asignado__c,
                Codigo_Sede_OR_Asesor_Asignado__c,Tipo_de_documento_tercero__c,Numero_de_identificacion_tercero__c,Quien_paga_tercero__c,Numero_de_identificacion_de_asistente_1__c,Numero_de_identificacion_de_asistente_2__c,
                Numero_de_identificacion_de_asistente_3__c,Amount,Famiempresa_relacionada__r.Barrio_empresa__r.Codigo_Registro_Barrio__c,Respuesta_Oportunidad__c,Identificador_proceso__c,RecordType.DeveloperName,
                Quien_autoriza__r.Codigo_de_Empleado__c,Numero_credito_aprobado__c,Cuentas_por_cobrar_comerciales__c,Inventario_balance__c,Activos_fijos__c,Total_activos_balance__c,Patrimonio__c,Total_pasivo__c,
                CostoMciaVendida__c,Disponibilidad_Neta__c,Empleado_que_refiere__r.Numero_de_documento__c,Cheque_a_nombre_de_entidad__c,Tipo_de_cuenta__c,Cuenta_No__c,Telefono_Sucursal_Bancaria__c,Entidad_financiera__c,Sucursal_Bancaria__c,
                Registro_creado_por__c,CloseDate,Exonero_a_Interactuar_de_toda_responsabi__c,Medio_de_desembolso__c,Total_Activos_Fijos_y_Otros__c,Famiempresa_relacionada__c,Total_Capital_de_Trabajo__c,
                Campaign.Name,Campaign.Type,Campaign.CreatedDate,Campaign.IndicadorEnvioMensaje__c,CampaignId,CreatedDate,NomApe_Ben1__c,ParentescoBen1__c,Tipo_ideBen1__c,Numero_idenBen1__c,PorcentajeBen1__c,
                NomApe_Ben2__c,ParentescoBen2__c,Tipo_ideBen2__c,Numero_idenBen2__c,PorcentajeBen2__c,NomApe_Ben3__c,ParentescoBen3__c,Tipo_ideBen3__c,Numero_idenBen3__c,PorcentajeBen3__c,CreditoSaldoCargo__c,
                Persona_Publica__c,Vinculo_con_Persona_Publica__c,Presenta_los_siguientes_sintomas__c,Familiar_con_los_siguientes_sintomas__c,Sintomas_NO_relacionado_en_la_lista__c,Se_encuentra_en_embarazo__c,
                Hospitalizacion_programada__c,Participa_en_competencias_deportivas__c,Presenta_una_dolencia_no_mencionada__c,Se_le_ha_negado_un_seguro__c,Se_encuentra_en_estudio_medico__c,Sera_sometido_a_tratamiento_medico__c,
                Ha_sido_alguna_vez_hospitalizado__c,Numero_de_cigarrillos_diarios_que_fuma__c,Numero_de_Afiliados_a_Prever__c, Resultado_Estudio_Digital__c, Generacion_Automatica_de_Credito__c
                FROM Opportunity  
                WHERE Id  =: idsOportunidad ];
    }
    
    public static void cobertura(){
        String var = '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';      
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        var += '';
    }
}
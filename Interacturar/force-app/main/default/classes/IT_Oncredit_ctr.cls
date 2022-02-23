/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Oncredit
* @descripcion      Clase para el proceso de Oncredit

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   24-JUL-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_Oncredit_ctr {

    private static final String URL_STRING   = '/';
    private static final String INICIALIZADO = '';
    private static final String ERROR        = 'ERROR';
    private static final String JURIDICO     = 'Persona_juridica';
    private static final String CONTEXTO     = 'Pagare';
    private static final String AVALISTA     = 'rolAvalista';
    private static final String REPR         = 'rolRLegal';
    private static final String RCLIENTE     = 'rolCliente';
    private static final String ES_NULO      = null;
    private static Parametros_Web_Service__mdt param;
    private static final String INVITACION_FIRMA = 'OnCreditInvitacionAFirma';
    private static final String ONCREDIT_PROFILE   = 'profile';
    private static final String ONCREDIT_DASHBOARD = 'dashboard';
    private static final String ONCREDIT_SYSTEMATIZED = 'systematized';

    @AuraEnabled
    public static string firmantes(String idOportunidad){
        List<Asociacion_cuenta_contacto__c> lstAscc = new List<Asociacion_cuenta_contacto__c>();        
        List<Id> listaId = new List<Id>{ idOportunidad };
        List<Opportunity>   lstOpps = IT_GestorDeConsultas_cls.consultaOportunidad( idOportunidad );
        List<QuoteLineItem> lstPxc  = IT_GestorDeConsultas_cls.consultaProductoPorCotizacion( lstOpps[0] );
        lstAscc         = IT_GestorDeConsultas_cls.consultaAsociacionAval(listaId);
        param = parametrosWS(Label.OncreditURLparam);
        String route = ONCREDIT_PROFILE;
        String jsonRpta = jsonOncredit( lstAscc, lstOpps[0] , lstPxc[0], route);
        System.debug( 'JsonRpta: '+ jsonRpta );
        return generaURL( jsonRpta );
    }

    @InvocableMethod
    public static void firmantesSystematized(List<Opportunity> listOpor){
        System.debug('LLamado a firma pagaré: ' + listOpor);
        String idOportunidad = listOpor[0].Id;
        System.debug('Oportunidad Id: ' + idOportunidad);
        
        List<Asociacion_cuenta_contacto__c> lstAscc = new List<Asociacion_cuenta_contacto__c>();        
        List<Id> listaId = new List<Id>{ idOportunidad };
        List<Opportunity>   lstOpps = IT_GestorDeConsultas_cls.consultaOportunidad( idOportunidad );
        List<QuoteLineItem> lstPxc  = IT_GestorDeConsultas_cls.consultaProductoPorCotizacion( lstOpps[0] );
        lstAscc         = IT_GestorDeConsultas_cls.consultaAsociacionAval(listaId);
        param = parametrosWS(INVITACION_FIRMA);
        String route = ONCREDIT_SYSTEMATIZED;
        String jsonRpta = jsonOncredit( lstAscc, lstOpps[0] , lstPxc[0], route);
        System.debug( 'JsonRpta: '+ jsonRpta );
        
        
        //////Envío de la petición a la invitación de la firma de pagaré
        String finalJson = '{';
        finalJson += '"encabezado": {';
        finalJson += '"estado": "0",';
        finalJson += '"excepcion": "",';
        finalJson += '"fecha": "' + DateTime.now().format('yyyy-MM-dd HH:mm:ss') + '",';
        finalJson += '"identificador": "' + lstOpps[0].Id + '-123456",';
        finalJson += '"mensaje": "",';
        finalJson += '"integracion": "Invitación Firma Pagaré",';
        finalJson += '"operacion": "0",';
        finalJson += '"origen": "SALESFORCE",';
        finalJson += '"destino": "OnCredit"';
        finalJson += '},';
        finalJson += '"cuerpo":';
        finalJson += jsonRpta;
        finalJson += '}';

        callOutInvitaFirma(finalJson);
        ///////////////////////////////////////////////////////////////
    }
    
    /******************************************************
    *Author:   Álvaro Ortega
    *Function: Futuro de invitación a firma de pagaré
    *Date:     02-Mar-2021
    *******************************************************/
    @future(callout=true)
    public static void callOutInvitaFirma(String jsonRpta){
        Http http = new Http();
        String jSON_req  = jsonRpta;
        System.debug('Envío de la petición a la invitación de la firma de pagaré');
        System.debug('invoca Servicio'+ jSON_req);
        //HttpRequest  request = parametrosInvitacionAfirma(jSON_req);
        HttpRequest  request = IT_ParametrosWS_cls.parametrosInvitacionAfirma(jSON_req);
        HttpResponse response = http.send(request);
        String jSON_res = response.getBody();
        System.debug('JSON_res'+ jSON_res +'-'+request);
    }

    private static String generaURL(String cuerpoJson ){
        ResponseURL res;
        try{            
            String url = INICIALIZADO;
            url = param.EndPoint__c;
            // url += URL_STRING;    
            url += EncodingUtil.base64Encode( Blob.valueOf(cuerpoJson) );
            res = new ResponseURL(true,url);
            System.debug(url);
            return JSON.serialize(res);
        }catch(Exception e){
            res = new ResponseURL(false, ERROR);
            return JSON.serialize(res);
        }
    }
            //cot.Opportunity.Asesor_asignado__r.Sede_Empleado__r.Codigo_Sede_OR__c;
    public static String jsonOncredit( List<Asociacion_cuenta_contacto__c> lstAscc , Opportunity opp , QuoteLineItem pxc, String route){
        String json = ''+
        '{'+
            '"user":     "'+param.Usuario__c+'",'+
            '"password": "'+param.Clave__c+'",'+
            '"route":    "'+route+'",'+
            '"additional_data": [';
             json += jsonLista( lstAscc, opp );
             json += '],';
             json += '"additional_data_cliente":{';
             json += jsonCliente( opp );
             json += '},'+
                     '"additional_data_solicitud":{'+
                     '"fecha_solicitud": "'+opp.CreatedDate+'",'+// fecha de creacion o otra fecha ?
                     '"codigo_producto": "'+pxc.Product2.ProductCode+'",'+
                     '"numero_radicado": "'+pxc.Identificador_Radicado_OR__c+'",'+
                     '"oficina":         "'+opp.Oficina_asesor_asignado__c+'",'+
                     '"oficina_codigo":  "'+opp.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c+'",'+
                     '"nombre_asesor":   "'+opp.Asesor_asignado__r.Name+'",'+
                     '"correo_asesor":   "'+opp.Asesor_asignado__r.Correo_electronico__c+'",'+ 
                     '"plazoMeses"   :   "'+pxc.Plazo_meses__c+'",'+
                     '"precioTotal"  :   "'+pxc.TotalPrice+'",'+
                     '"periodoGracia" :  "'+pxc.Periodo_Gracias_Meses__c +'"'+
                     '},';
            json += '"additional_declaracion_asegurabilidad":{';
            json += jsonDeaclaracionAsegurabilidad( opp );
            json += '}';

            json += '}';

        return json;
    }

    public static String jsonLista( List<Asociacion_cuenta_contacto__c> lstAscc , Opportunity opp ){
        String json = '';
        Map<String,String> hom = getHomologaciones();  
        for(Asociacion_cuenta_contacto__c acc: lstAscc){
            String rol = ( acc.RepresentanteLegal__c ) ? hom.get(REPR) : hom.get(AVALISTA);
            json += '{'+
                    '"customer_document":          "'+ acc.Contacto__r.Numero_de_identificacion__c+'",'+
                    '"customer_document_type":     "'+ acc.Contacto__r.Tipo_de_identificacion__c +'",'+
                    '"customer_role":              "'+ rol +'",'+ 
                    '"customer_name":              "'+ acc.Contacto__r.FirstName +' '+ IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.MiddleName) +'",'+
                    '"customer_primer_apellido":   "'+ acc.Contacto__r.LastName +'",'+
                    '"customer_segundo_apellido":  "'+ acc.Contacto__r.Segundo_Apellido__c +'",'+
                    '"customer_sexo":              "'+ acc.Contacto__r.Genero__c +'",'+
                    '"customer_lugar_expedicion":  "'+ acc.Contacto__r.Lugar_expedicion__c +'",'+
                    '"customer_fecha_nacimiento":  "'+ acc.Contacto__r.Birthdate +'",'+
                    '"customer_pais_nacimiento":   "'+ acc.Contacto__r.Pais_contacto__c +'",'+
                    '"customer_dir_residencia":    "'+ acc.Contacto__r.Vista_direccion_contacto__c +'",'+
                    '"customer_departamento":      "'+ acc.Contacto__r.Departamento_contacto__c +'",'+
                    '"customer_municipio":         "'+ acc.Contacto__r.Ciudad_contacto__r.Name +'",'+
                    '"customer_barrio_vereda":     "'+ acc.Contacto__r.Barrio_contacto__r.Name +'",'+
                    '"customer_tel_residencia":    "'+ acc.Contacto__r.Telefono_contacto__c +'",'+
                    '"customer_celular":           "'+ acc.Contacto__r.Movil_contacto__c +'",'+
                    '"customer_correo":            "'+ acc.Contacto__r.Email +'",'+
                    '"customer_empresa_labora":    "'+ acc.Contacto__r.Empresa_donde_labora__c +'",'+
                    '"customer_dir_empresa_labora": "'+ acc.Contacto__r.DireccionLaboral__c +'",'+
                    '"customer_tel_empresa_labora": "'+ acc.Contacto__r.TelefonoLaboral__c +'",'+
                    '"customer_Nacionalidad":       "'+ acc.Cliente__r.Nacionalidad__c +'",'+
                    '"customer_LugarNacimiento":    "'+ acc.Cliente__r.Lugar_de_nacimiento__c +'",'+
                    '"customer_peso":               "'+ acc.Cliente__r.Peso_kg__c +'",'+
                    '"customer_estatura":           "'+ acc.Cliente__r.Estatura_cm__c +'",'+
                    '"customer_estadoCivil":        "'+ acc.Cliente__r.Estado_civil__pc +'"'+
                    '},';
            if(acc.RepresentanteLegal__c){
                json += '{'+
                    '"customer_document":          "'+ acc.Contacto__r.Numero_de_identificacion__c+'",'+
                    '"customer_document_type":     "'+ acc.Contacto__r.Tipo_de_identificacion__c +'",'+
                    '"customer_role":              "'+ hom.get(AVALISTA) +'",'+ 
                    '"customer_name":              "'+ acc.Contacto__r.FirstName +' '+ IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.MiddleName) +'",'+
                    '"customer_primer_apellido":   "'+ acc.Contacto__r.LastName +'",'+
                    '"customer_segundo_apellido":  "'+ acc.Contacto__r.Segundo_Apellido__c +'",'+
                    '"customer_sexo":              "'+ acc.Contacto__r.Genero__c +'",'+
                    '"customer_lugar_expedicion":  "'+ acc.Contacto__r.Lugar_expedicion__c +'",'+
                    '"customer_fecha_nacimiento":  "'+ acc.Contacto__r.Birthdate +'",'+
                    '"customer_pais_nacimiento":   "'+ acc.Contacto__r.Pais_contacto__c +'",'+
                    '"customer_dir_residencia":    "'+ acc.Contacto__r.Vista_direccion_contacto__c +'",'+
                    '"customer_departamento":      "'+ acc.Contacto__r.Departamento_contacto__c +'",'+
                    '"customer_municipio":         "'+ acc.Contacto__r.Ciudad_contacto__r.Name +'",'+
                    '"customer_barrio_vereda":     "'+ acc.Contacto__r.Barrio_contacto__r.Name +'",'+
                    '"customer_tel_residencia":    "'+ acc.Contacto__r.Telefono_contacto__c +'",'+
                    '"customer_celular":           "'+ acc.Contacto__r.Movil_contacto__c +'",'+
                    '"customer_correo":            "'+ acc.Contacto__r.Email +'",'+
                    '"customer_empresa_labora":    "'+ acc.Contacto__r.Empresa_donde_labora__c +'",'+
                    '"customer_dir_empresa_labora": "'+ acc.Contacto__r.DireccionLaboral__c +'",'+
                    '"customer_tel_empresa_labora": "'+ acc.Contacto__r.TelefonoLaboral__c +'",'+
                    '"customer_Nacionalidad":       "'+ acc.Cliente__r.Nacionalidad__c +'",'+
                    '"customer_LugarNacimiento":    "'+ acc.Cliente__r.Lugar_de_nacimiento__c +'",'+
                    '"customer_peso":               "'+ acc.Cliente__r.Peso_kg__c +'",'+
                    '"customer_estatura":           "'+ acc.Cliente__r.Estatura_cm__c +'",'+
                    '"customer_estadoCivil":        "'+ acc.Cliente__r.Estado_civil__pc +'"'+
                    '},';
            }
        }
        if( opp.Account.RecordType.DeveloperName != JURIDICO ){            
            json += jsonListaCliente( opp.Account , hom );
        }
        json = ( json.length() > 0 )? json.substring(0, json.length() - 1) : '';
        return json;
    }

    public static String jsonListaCliente(Account cNatural,Map<String,String> hom){
        String json = '';
        json += '{'+
        '"customer_document":          "'+ cNatural.Numero_de_identificacion__c+'",'+
        '"customer_document_type":     "'+ cNatural.Tipo_de_identificacion__c +'",'+
        '"customer_role":              "'+ hom.get(RCLIENTE) +'",'+ 
        '"customer_name":              "'+ cNatural.FirstName +' '+ IT_ConstruccionJSON_cls.validarNullString(cNatural.MiddleName) +'",'+
        '"customer_primer_apellido":   "'+ cNatural.LastName +'",'+
        '"customer_segundo_apellido":  "'+ cNatural.Segundo_Apellido__c +'",'+
        '"customer_sexo":              "'+ cNatural.Genero__pc +'",'+
        '"customer_lugar_expedicion":  "'+ cNatural.Lugar_expedicion__c +'",'+
        '"customer_fecha_nacimiento":  "'+ cNatural.Fecha_de_nacimiento__c +'",'+
        '"customer_pais_nacimiento":   "'+ cNatural.Pais_empresa__c +'",'+
        '"customer_dir_residencia":    "'+ cNatural.Vista_direccion_empresa__c +'",'+
        '"customer_departamento":      "'+ cNatural.Departamento_empresa__c +'",'+
        '"customer_municipio":         "'+ cNatural.Ciudad_empresa__r.Name +'",'+
        '"customer_barrio_vereda":     "'+ cNatural.Barrio_empresa__r.Name +'",'+
        '"customer_tel_residencia":    "'+ cNatural.Telefono_empresa__c +'",'+
        '"customer_celular":           "'+ cNatural.Movil_empresa__c +'",'+
        '"customer_correo":            "'+ cNatural.PersonEmail +'",'+
        '"customer_empresa_labora":    "'+ cNatural.Empresa_donde_labora__c +'",'+
        '"customer_dir_empresa_labora": "'+ cNatural.DireccionLaboral__c +'",'+
        '"customer_tel_empresa_labora": "'+ cNatural.TelefonoLaboral__c +'",'+
        '"customer_Nacionalidad":       "'+ cNatural.Nacionalidad__c +'",'+
        '"customer_LugarNacimiento":    "'+ cNatural.Lugar_de_nacimiento__c +'",'+
        '"customer_peso":               "'+ cNatural.Peso_kg__c +'",'+
        '"customer_estatura":           "'+ cNatural.Estatura_cm__c +'", '+
        '"customer_estadoCivil":        "'+ cNatural.Estado_civil__pc +'"'+
        '},';
        return json;
    }

    public static String jsonCliente(  Opportunity opp ){
        String json = '';        
        if( opp.Account.RecordType.DeveloperName == JURIDICO ){
            json += '"cliente_nit":          "'+opp.Account.Numero_de_identificacion__c+'",'+      // solo si es juridico
                    '"cliente_razonSocial":  "'+opp.Account.Name+'",'+                         // solo si es juridico
                    '"cliente_ciudad":       "'+opp.Account.Ciudad_empresa__r.Name+'",'+            // solo si es juridico
               		'"cliente_Ciudad_CodigoDane":   "'+opp.Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c+'",'+            // solo si es juridico
                	'"cliente_ActividadEconomica_CodigoCIIU":   "'+opp.Account.Actividad_economica__r.Codigo_CIIU__c+'",'+            // solo si es juridico
                    '"cliente_departamento": "'+opp.Account.Ciudad_empresa__r.Nombre_Departamento__c+'",'+  // solo si es juridico
                    '"cliente_barrio":       "'+opp.Account.Barrio_empresa__r.Name+'",'+  // solo si es juridico
                    '"cliente_direccion":    "'+opp.Account.Vista_direccion_empresa__c+'",'+  // solo si es juridico
                    '"cliente_telefono":     "'+opp.Account.Movil_empresa__c          +'",'+ // solo si es juridico 
                    '"cliente_correoElectronico":     "'+opp.Account.Correo_electronico_empresa__c+'" ';  // solo si es juridico
        }else {
            json += '"fami_nombre":    "'+opp.Famiempresa_relacionada__r.Name+'",'+      // solo si es natural
                    '"fami_tel":       "'+opp.Famiempresa_relacionada__r.Telefono_empresa__c+'",'+        // solo si es natural
                    '"fami_dir":       "'+opp.Famiempresa_relacionada__r.Vista_direccion_empresa__c+'",'+         // solo si es natural
                    '"fami_barrio":    "'+opp.Famiempresa_relacionada__r.Barrio_empresa__r.Name+'",'+       // solo si es natural
                    '"fami_municipio": "'+opp.Famiempresa_relacionada__r.Ciudad_empresa__r.Name+'",'+ // solo si es natural
                    '"fami_NoPisos":           "'+opp.Famiempresa_relacionada__r.Numero_pisos__c+'",'+ // solo si es natural
                    '"fami_tipoConstruccion":  "'+opp.Famiempresa_relacionada__r.Tipo_de_construccion__c+'",'+ // solo si es natural
                    '"fami_AniosConstruccion": "'+opp.Famiempresa_relacionada__r.Anioos_de_construccion__c+'",'+ // solo si es natural
                    '"fami_ActividadEconomica":  "'+opp.Famiempresa_relacionada__r.Actividad_economica__r.Name+'",'+ // solo si es natural
                    '"fami_TipoLocal": "'+(opp.Famiempresa_relacionada__r.Tipo_de_local_donde_tiene_la_empresa__c == 'Otro' ? 'Propio' : opp.Famiempresa_relacionada__r.Tipo_de_local_donde_tiene_la_empresa__c)+'",'+ // solo si es natural
                    '"cliente_TotalIngresos": "'+opp.Account.Total_ingresos__c+'",'+ // solo si es natural
                    '"cliente_TotalEgresos":  "'+opp.Account.Total_egresos__c+'",'+ // solo si es natural
                	'"cliente_Ciudad_CodigoDane":  "'+opp.Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c+'",'+ // solo si es natural
                	'"cliente_ActividadEconomica_CodigoCIIU":  "'+opp.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_CIIU__c+'",'+ // solo si es natural
                    '"opp_TotalActivosBalance": "'+opp.Total_activos_balance__c+'",'+ // solo si es natural
                    '"opp_Patrimonio":  "'+opp.Patrimonio__c+'",'+ // solo si es natural
                    '"additional_data_beneficiario": [';
            json += jsonPoliza( opp );
            json +=  '],';

            json += '"additional_data_beneficiario_prever": [';
            json += jsonContactosPrever( opp );
            json +=  ']';
        }        
        return json;
    }
    
    public static String jsonPoliza(  Opportunity opp ){
        String json = '';
        if( opp.NomApe_Ben1__c != ES_NULO  ){  // && opp.Numero_idenBen1__c != ES_NULO
            json = '{'+       
                    '"Poliza_nombre_apellidos":    "'+opp.NomApe_Ben1__c+'",'+       // solo si es natural
                    '"Poliza_parentesco":          "'+opp.ParentescoBen1__c+'",'+    // solo si es natural
                    //'"Poliza_tipo_Identificacion": "'+opp.Tipo_ideBen1__c+'",'+      // solo si es natural
                    '"Poliza_documento":           "'+opp.Numero_idenBen1__c+'",'+   // solo si es natural
                    //'"Poliza_cliente_barrio":      "",'+                             // NO EXISTE
                    '"Poliza_porcentaje":          "'+opp.PorcentajeBen1__c+'" '+    // solo si es natural  
                    '}';
        }
        if( opp.NomApe_Ben2__c != ES_NULO  ){ // && opp.Numero_idenBen2__c != ES_NULO
            json += ',{'+
                    '"Poliza_nombre_apellidos":    "'+opp.NomApe_Ben2__c+'",'+       // solo si es natural
                    '"Poliza_parentesco":          "'+opp.ParentescoBen2__c+'",'+    // solo si es natural
                   // '"Poliza_tipo_Identificacion": "'+opp.Tipo_ideBen2__c+'",'+      // solo si es natural
                    '"Poliza_documento":           "'+opp.Numero_idenBen2__c+'",'+   // solo si es natural
                   // '"Poliza_cliente_barrio":      "",'+                             // NO EXISTE
                    '"Poliza_porcentaje":          "'+opp.PorcentajeBen2__c+'" '+    // solo si es natural 
                    '}';
        }
        if( opp.NomApe_Ben3__c != ES_NULO  ){  // && opp.Numero_idenBen3__c != ES_NULO
            json += ',{'+
                    '"Poliza_nombre_apellidos":    "'+opp.NomApe_Ben3__c+'",'+       // solo si es natural
                    '"Poliza_parentesco":          "'+opp.ParentescoBen3__c+'",'+    // solo si es natural
                    //'"Poliza_tipo_Identificacion": "'+opp.Tipo_ideBen3__c+'",'+      // solo si es natural
                    '"Poliza_documento":           "'+opp.Numero_idenBen3__c+'",'+   // solo si es natural
                    //'"Poliza_cliente_barrio":      "",'+                             // NO EXISTE
                    '"Poliza_porcentaje":          "'+opp.PorcentajeBen3__c+'" '+    // solo si es natural
                    '}';
        }
        return json;
    }

    public static String jsonContactosPrever(  Opportunity opp ){
        List<Contact> conts = getContactos(opp.Id).Contactos__r;
        String json = '';
        for(Integer i = 0; i < conts.size(); i++){
            String aux = '{';
            aux += '"nombres_Beneficiario": "' + conts[i].Nombres_Beneficiario__c     + '",' +
                   '"apellidos_Beneficiario": "' + conts[i].Apellidos_Beneficiario__c + '",' +
                   '"genero": "' + conts[i].Genero__c +'" ' +
                   '}';
            aux += i < (conts.size() -1) ? ',' : ''; 

            json += aux;
        }
        return json;
    }
    
    public static Opportunity getContactos(Id oportId){
        return [select Id, Name, Numero_de_Afiliados_a_Prever__c,
                    (select Name, Id, FirstName, MiddleName, LastName, Segundo_Apellido__c, Genero__c, RecordType.Name, Nombres_Beneficiario__c, Apellidos_Beneficiario__c
                    from Contactos__r 
                    where RecordType.DeveloperName = 'Beneficiario'
                    Order by CreatedDate)
                from Opportunity
                where id = :oportId and RecordType.DeveloperName = 'Solicitud_de_credito' limit 1];
    }

    public static String jsonDeaclaracionAsegurabilidad(  Opportunity opp ){

        String json = '';
        json = '"persona_publica":        "' + opp.Persona_Publica__c + '",' +
               '"vinculo_publica":        "' + opp.Vinculo_con_Persona_Publica__c + '",' +
               '"padecido_sintoma":       "' + opp.Presenta_los_siguientes_sintomas__c  + '",' +
               '"sintoma_familiar":       "' + opp.Familiar_con_los_siguientes_sintomas__c  + '",' +
               '"sintoma_noListada":      "' + opp.Sintomas_NO_relacionado_en_la_lista__c  + '",' +
               '"enEmbarazo":             "' + opp.Se_encuentra_en_embarazo__c  + '",' +
               '"programadaPractica":     "' + opp.Hospitalizacion_programada__c + '",' +
               '"competenciaDeportiva":   "' + opp.Participa_en_competencias_deportivas__c  + '",' +
               '"dolenciaNoPreguntada":   "' + opp.Presenta_una_dolencia_no_mencionada__c  + '",' +
               '"seguroDeVida":           "' + opp.Se_le_ha_negado_un_seguro__c  + '",' +
               '"estudioMedico":          "' + opp.Se_encuentra_en_estudio_medico__c  + '",' +
               '"intervencionQuirurgica": "' + opp.Sera_sometido_a_tratamiento_medico__c  + '",' +
               '"hospitalizadoOperado":   "' + opp.Ha_sido_alguna_vez_hospitalizado__c  + '",' +
               '"cigarrillosDiarios":     "' + opp.Numero_de_cigarrillos_diarios_que_fuma__c  + '"';
        
        return json;
    }

    @AuraEnabled
    public static string interfazOnCredit(){
        param = parametrosWS(Label.OncreditURLparam);
        String jsonRpta = jsonInterfazOncredit();
        System.debug( jsonRpta );
        return generaURL( jsonRpta );
    }

    public static String jsonInterfazOncredit(){
        String json = ''+
        '{'+
            '"user":     "'+param.Usuario__c+'",'+
            '"password": "'+param.Clave__c+'",'+
            '"route":    "'+ONCREDIT_DASHBOARD+'",'+
            '"additional_data": ['+
            '{'+
                '"customer_document": "",'+
                '"customer_document_type": "",'+
                '"customer_role": "",'+
                '"customer_name": "" '+
            '}'+
            ']'+
          '}';
          return json;
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Pone en un MAP las configuraciones parametrizadas de la metadata
    *Date: 06-8-2020
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

    private static Parametros_Web_Service__mdt parametrosWS(String depName){
        return [SELECT id,EndPoint__c,Metodo__c, Clave__c, Usuario__c FROM Parametros_Web_Service__mdt 
                WHERE DeveloperName =: depName];
    }
    
    /*************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener información básica de la oportunidad
    *Date: 18-12-2020
    **************************************************************************************/
    @AuraEnabled
    public static Opportunity consultaOportunidad(String idOportunidad){
        return [Select Id, Name, NomApe_Ben1__c
               from Opportunity
               where Id = :idOportunidad];
        
    }

    public class ResponseURL{
        Boolean proceso;
        String  url;
        public ResponseURL(Boolean bo, String url){
            this.proceso = bo;
            this.url     = url;
        }
    }
}
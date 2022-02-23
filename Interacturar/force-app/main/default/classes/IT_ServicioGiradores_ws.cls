/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase tipo servicio web REST para el proceso de Giradores

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   26-JUN-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing Class IT_ServicioGiradores_ws {

    private static Http         http;
    private static HttpRequest  request;
    private static HttpResponse response;
    private static String       jSONreq;
    private static final String TIPO_CLIENTE = 'Cliente';
    private static final String TIPO_AVAL    = 'Aval';
    private static final String EMISOR       = 'Emisor';
    private static final String TIPO_REP     = 'Principal';
    private static final String GIRADORES    = 'GIRADORES';
    private static final String OK           = 'OK';
    private static final String CLIENTE_J    = 'Cliente J';
    private static final String CLIENTE_N    = 'Cliente N';
    private static final String ERROR        = 'ERROR';
    private static final String TRY_CATCH    = 'TRY CATCH';
    private static final String JURIDICO     = 'Persona_juridica';
    private static final String NATURAL      = 'Persona_natural';
    private static final String MSG_ADMIN    = 'Comuniquese con su administrador';
    private static final Integer CODE        =  200;
    public static List<RespuestaGirador> lstGiradores = new List<RespuestaGirador>();
    public static RespuestaGlobal resGlobal;
    

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Entrada para enviar persona natural
    *Date: 26-6-2020
    **************************************************************************/
    public static String ejecutaPersonaNatural( Quote cot, Asociacion_cuenta_contacto__c acc , Map<String,String> hom, String tipo ){
      http = new Http();    
      jSONreq = jsonGiradoresPN(cot,  acc , hom, tipo);      
      system.debug(' body--->'+jSONreq); 
      request = IT_ParametrosWS_cls.parametrosGiradores(jSONreq);        
      response = http.send(request);
      system.debug('IT_CrearActualizarGiradores_ws Body:'+response.getBody()); 
      try {
        if( response.getStatus() == OK && response.getStatusCode() == CODE ){
          RespuestaGiradorPN resGirador = (RespuestaGiradorPN)JSON.deserialize(response.getBody(), RespuestaGiradorPN.class);
          return resultadoIntegracionPNA(cot , resGirador, tipo);
          }else{
            RespuestaGiradorPN resGirador = (RespuestaGiradorPN)JSON.deserialize(response.getBody(), RespuestaGiradorPN.class);
            system.debug('Error en el servidor: ' + response);
            return resultadoIntegracionErrorPNA(cot, acc , resGirador, tipo);
              
          }
      } catch (Exception e) {
          system.debug('Exception: ' + e);
        return resultadoIntegracionErrorPNA(cot, acc , new RespuestaGiradorPN(), TRY_CATCH + ' '+ tipo);
      }
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Gestiona la respuesta del servicio para los naturales/avales
    *Date: 09-7-2020
    **************************************************************************/
    public static String resultadoIntegracionPNA( Quote cot, RespuestaGiradorPN resGirador, String tipo){
      RespuestaGirador girador = new RespuestaGirador(
        resGirador.response.encabezado.mensaje.estado,
        resGirador.response.encabezado.mensaje.descripcion,
        resGirador.response.CreacionGiradoresCodificados.crearGiradorDTO.nombresNat_Nat,
        CLIENTE_N,true
        );
      lstGiradores.add(girador);
      System.debug( lstGiradores.size() );

      try{ 
        if( tipo == TIPO_CLIENTE){          
          actualizaciones(cot);
          return JSON.serialize(resGlobal);
        }else{
          return JSON.serialize( new RespuestaGlobal(ERROR, new List<RespuestaGirador>{ new RespuestaGirador('','','','',true) }) );
        }
        }catch(Exception e){
         System.debug('ERROR: '+e.getStackTraceString());
         return JSON.serialize( new RespuestaGlobal(ERROR, new List<RespuestaGirador>{ new RespuestaGirador('','','','',false) }) );
      }
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Entrada para enviar persona juridica
    *Date: 26-6-2020
    **************************************************************************/
    public static String ejecutaPersonaJuridica(Quote cot , List<Asociacion_cuenta_contacto__c> lstAvales, Map<String,String> hom){
        http = new Http();        
        jSONreq = jsonGiradoresPJ(cot, lstAvales, hom);
        system.debug(' body--->'+jSONreq); 
        request = IT_ParametrosWS_cls.parametrosGiradores(jSONreq);       
        response = http.send(request);
        system.debug('IT_CrearActualizarGiradores_ws Body:'+response.getBody()); 
        try{
            if( response.getStatus() == OK && response.getStatusCode() == CODE ){
                RespuestaGiradorPJ resGirador = (RespuestaGiradorPJ)JSON.deserializeStrict(response.getBody(), RespuestaGiradorPJ.class);
                system.debug('Prueba1---> ' + resGirador.response.encabezado.mensaje.estado);
                return resultadoIntegracionPJ(resGirador , cot);
            }else {
                RespuestaGiradorPJ resGirador = (RespuestaGiradorPJ)JSON.deserializeStrict(response.getBody(), RespuestaGiradorPJ.class);
                system.debug('Prueba1.2---> ' + resGirador.response.encabezado.mensaje.estado);
                return resultadoIntegracionErrorPJ(cot , resGirador, TRY_CATCH);
            }
        }catch(Exception e){
            system.debug('Prueba1.3---> Try Catch' + e);
            return resultadoIntegracionErrorPJ(cot , new RespuestaGiradorPJ(), TRY_CATCH);
        }
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Gestiona la respuesta del servicio para el cliente juridico
    *Date: 09-7-2020
    **************************************************************************/
    public static String resultadoIntegracionPJ(RespuestaGiradorPJ resGirador, Quote cot){
        system.debug('Prueba2---> ' + resGirador.response.encabezado.mensaje.estado);
        RespuestaGirador girador = new RespuestaGirador(
            resGirador.response.encabezado.mensaje.estado,
            resGirador.response.encabezado.mensaje.descripcion,
            resGirador.response.CreacionGiradoresCodificados.crearGiradorDTO.razonSocial_Jur,
            CLIENTE_J,true);
        lstGiradores.add(girador);
        System.debug( lstGiradores.size() );
        
        try{  
            actualizaciones(cot);                
            return JSON.serialize(resGlobal);
        }catch(Exception e){
            System.debug('ERROR: '+e.getStackTraceString());
            return JSON.serialize( new RespuestaGlobal(ERROR, new List<RespuestaGirador>{ new RespuestaGirador('','','','',false) }) );
        }
    }

    /*****************************************************************************
    *Author:  Rafael Cardona
    *Function: Setea los campos que se van a actualizar y realiza la actulizacion
    *Date: 09-7-2020
    ******************************************************************************/
    public static void actualizaciones(Quote cot){
      String sedeOportunidad = cot.Opportunity.Asesor_asignado__r.Sede_Empleado__r.Codigo_Sede_OR__c;
      String mensaje = GIRADORES+'-'+OK;      
      cot.EstadoIntegracionGirador__c = GIRADORES+'-'+OK;
      cot.RespuestaCrearActualizarGiradores__c = '';
      for(RespuestaGirador gi: lstGiradores){          
        cot.RespuestaCrearActualizarGiradores__c += 'NOMBRE: '+gi.nomGirador+'\n'+'ESTADO: '+gi.estado +'\n'+'MENSAJE: '+gi.descripcion+'\n'+
                                                    +'________________________________\n';
        if( gi.estado == ERROR ){   
          cot.EstadoIntegracionGirador__c = GIRADORES+'-'+ERROR;
          mensaje = GIRADORES+'-'+ERROR;
        }
      }      
      resGlobal = new RespuestaGlobal(mensaje,lstGiradores);
      if( sedeOportunidad != null && mensaje == GIRADORES+'-'+OK){  
        Opportunity op = consultaOportunidad( cot.OpportunityId );
        op.SedeOpp__c = sedeOportunidad;   
        update op;
      }  
      update cot;
    }


    /*************************************************************************
    *Author:   Rafael Cardona
    *Function: Crea json para persona natural (cliente natural o avales)
    *Date:     2-7-2020
    **************************************************************************/
    public static String jsonGiradoresPN(Quote cotiza, Asociacion_cuenta_contacto__c scc , Map<String,String> hom, String tipo){
      Quote cot = cotiza;
      Asociacion_cuenta_contacto__c acc = scc;

      String idProceso = ( tipo == TIPO_CLIENTE) ? cot.Opportunity.Identificador_proceso__c : acc.Oportunidad__r.Identificador_proceso__c;
      String oficina   = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c);
      String radicado  = cot.QuoteLineItems[0].Identificador_Radicado_OR__c;
      String emisor    = hom.get(EMISOR);
      String cPersona  = hom.get(NATURAL);
      String tDoc      = ( tipo == TIPO_CLIENTE) ? hom.get(cot.Opportunity.Account.Tipo_de_identificacion__c) : hom.get(acc.Contacto__r.Tipo_de_identificacion__c);
      String nDoc      = ( tipo == TIPO_CLIENTE) ? cot.Opportunity.Account.Numero_de_identificacion__c : acc.Contacto__r.Numero_de_identificacion__c;
      String nCel      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Movil_empresa__c)    : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Movil_contacto__c);
      String email     = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.PersonEmail)         : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Email);
      String noms      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNombreApellido(IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.firstName) , IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.MiddleName)) : 
                                                   IT_ConstruccionJSON_cls.validarNombreApellido(IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.FirstName)  ,        IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.MiddleName));
      String fApe      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.lastName)            : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.LastName);
      String lApe      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Segundo_Apellido__c) : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Segundo_Apellido__c);
      
      String cTel      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Movil_empresa__c)                       : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Movil_contacto__c);
      String cDir      = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Vista_direccion_empresa__c)             : IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Vista_direccion_contacto__c);
      String cCiud     = ( tipo == TIPO_CLIENTE) ? IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c): IT_ConstruccionJSON_cls.validarNullString(acc.Contacto__r.Ciudad_contacto__r.Codigo_DANE_Ciudad__c);

        String json = ''+
        '{'+
            '"encabezado": {'+
              '"operacion": "CREACIONGIRADORES",'+
              '"origen": "SALESFORCE",'+
              '"destino": "DECEVAL",'+
              '"fecha": "'+(System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss')+'",'+
              '"usuario": "'+UserInfo.getName()+'"'+
            '},'+
            '"solicitudCredito": {'+
              '"idProceso": "'+idProceso+'",'+// identificador de proceso bpms +
              '"oficina":   "'+oficina+'",'+  // Oficina  + asesor asignado
              '"radicado":  "'+radicado+'"'+ // Radicado Asociado a la Solicitud de Credito* +
            '},'+
            '"CreacionGiradoresCodificados": {'+
              '"crearGiradorDTO": {'+
                '"identificacionEmisor": "'+emisor+'",'+//  +
                '"fkIdClasePersona":    "'+cPersona+'",'+     // natural o juridico +
                '"fkIdTipoDocumento":   "'+tDoc+'",'+   // doc cliente o aval +
                '"numeroDocumento":     "'+nDoc+'",'+  // doc cliente o aval +
        		'"telefono1PersonaGrupo_PGP":     "'+cTel+'",'+  // doc cliente o aval +
        		'"direccion1PersonaGrupo_PGP":     "'+cDir+'",'+  // doc cliente o aval +
        		'"fkIdCiudadDomicilio_Nat":     "'+((cCiud != null && String.valueOf(cCiud).length() == 4) ? ('0' + String.valueOf(cCiud)) : (String.valueOf(cCiud)) )+'",';  // doc cliente o aval +
                json += agregaNumeroCelular(nCel);
                json += agregaCorreo(email);
                json += ''+
                '"nombresNat_Nat":      "'+noms+'",';      // nombres completo girador +
                json += agregaSegundoApellido( fApe, lApe);
                json += '}'+
          '}'+
          '}';
          return json;
    }

    public static String agregaNumeroCelular( String nCel ){
      String json = '';
      if( nCel != ''){  json += '"numeroCelular" : "'+nCel+'",'; }// +   
      return json;                    
    }
    public static String agregaCorreo( String email ){
      String json = '';
      if( email != ''){ json +=  '"correoElectronico":   "'+email+'",'; } // email cliente o aval +  
      return json;                    
    }
    public static String agregaSegundoApellido(String fApe, String lApe){
      String json = '';
      if( lApe != ''){
        json += '"primerApellido_Nat":  "'+fApe+'",'+   // 1er apellido girador +
                '"segundoApellido_Nat": "'+lApe+'" ';   // 2do apellido girador +
      }else{
        json += '"primerApellido_Nat":  "'+fApe+'" ';   // 1er apellido girador +
      }
      return json;                    
    }

    /********************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura de clases para el manejo de la respuesta del servicio de cliente Natural y Avales
    *Date: 2-7-2020
    *********************************************************************************************************/
    public class RespuestaGiradorPN{
      public Pn_response response;
    }
      class Pn_response {
        public Pn_solicitudCredito solicitudCredito;
        public Pn_encabezado encabezado;
        public Pn_CreacionGiradoresCodificados CreacionGiradoresCodificados;
      }
      Class Pn_solicitudCredito {
        public Integer radicado;	//5454
        public Integer oficina;	//32
        public Integer idProceso;	//2323
      }
      Class Pn_encabezado {
        public String fecha;	//2020-03-09T13:20:09
        public String usuario;	//PEDROGG
        public String operacion;	//CREACIONGIRADORES
        public String origen;	//SALESFORCE
        public String destino;	//DECEVAL
        public Pn_mensaje mensaje;
      }
      Class Pn_mensaje {
        public String descripcion;	//(SDL.SE.0098): Se presentaron errores al crear el(los) girador(es). Número de giradores fallidos:1
        public String estado;	//ERROR
      }
      Class Pn_CreacionGiradoresCodificados {
        public Pn_crearGiradorDTO crearGiradorDTO;
      }
      Class Pn_crearGiradorDTO {
        public String segundoApellido_Nat;	//BONILLA
        public Integer fkIdClasePersona;	//1        
        public Integer fkIdTipoDocumento;	//1
        public String identificacionEmisor;	//22
        public String numeroCelular;        
        public Integer cuentaGirador;	//0        
        public String nombresNat_Nat;	//CARLOS ED
        public String numeroDocumento;	//1181818181
        public String correoElectronico;	//prueba@mail.com
        public String primerApellido_Nat;	//GRANADOS
        public String mensajeRespuesta;	//SDL.DA.0440 - SDL.DA.0440 - No existe el emisor enviado
        public String telefono1PersonaGrupo_PGP; //798654
        public String direccion1PersonaGrupo_PGP; //Carrera 17 #5
        public String fkIdCiudadDomicilio_Nat; //5005
      }

    
    /*************************************************************************
    *Author:   Rafael Cardona
    *Function: Crea json para persona juridica (cliente juridico)
    *Date:     2-7-2020
    **************************************************************************/
      public static String jsonGiradoresPJ(Quote cot, List<Asociacion_cuenta_contacto__c> lstAvales , Map<String,String> hom){
        
        String idProceso = cot.Opportunity.Identificador_proceso__c;
        String oficina   = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c);
        String radicado  = cot.QuoteLineItems[0].Identificador_Radicado_OR__c;
        String emisor    = hom.get(EMISOR);
        String cPersona  = hom.get(JURIDICO);
        String tDoc      = hom.get(cot.Opportunity.Account.Tipo_de_identificacion__c);
        String nDoc      = cot.Opportunity.Account.Numero_de_identificacion__c + String.valueOf(IT_Girador_ctr.generarDigitoNit(cot.Opportunity.Account.Numero_de_identificacion__c));
        String nCel      = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Movil_empresa__c);
        String email     = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Correo_electronico_empresa__c);
        String nom       = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Name);
          
        String cTel      = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Movil_empresa__c);
      	String cDir      = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Vista_direccion_empresa__c);
      	String cCiud     = IT_ConstruccionJSON_cls.validarNullString(cot.Opportunity.Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c);
       
        String json = ''+
        '{'+
          '"encabezado": {'+
            '"operacion": "CREACIONGIRADORES",'+
            '"origen":    "SALESFORCE",'+
            '"destino":   "DECEVAL",'+
            '"fecha":     "'+(System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss')+'",'+ 
            '"usuario":   "'+UserInfo.getName()+'"'+
          '},'+
          '"solicitudCredito": {'+
            '"idProceso":   "'+idProceso+'",'+  // id opp
            '"oficina":     "'+oficina+'",'+ // Oficina asociada a la solicitud de Crédito
            '"radicado":    "'+radicado+'"'+  // Radicado Asociado a la Solicitud de Credito
          '},'+
          '"CreacionGiradoresCodificados": {'+
            '"crearGiradorDTO": {'+
              '"identificacionEmisor": "'+emisor+'",'+    // doc de quien envia +
              '"fkIdClasePersona":     "'+cPersona+'",'+         // natural o juridico + 
              '"fkIdTipoDocumento":    "'+tDoc+'",'+        // doc cliente o aval +
              '"numeroDocumento":      "'+nDoc+'",'+  // doc cliente o aval +
          	  '"telefono1PersonaGrupo_PGP":     "'+cTel+'",'+  // doc cliente o aval +
        	  '"direccion1PersonaGrupo_PGP":     "'+cDir+'",'+  // doc cliente o aval +
        	  '"fkIdCiudad_Jur":     "'+((cCiud != null && String.valueOf(cCiud).length() == 4) ? ('0' + String.valueOf(cCiud)) : (String.valueOf(cCiud)) )+'",';  // doc cliente o aval +
              json += agregaCorreo(email); //'"correoElectronico":    "'+email+'",'+   // email cliente o aval +
              json += '"listaRepresentantesLegales": [';
              json += listaRepresentantesLegales(lstAvales, cot, hom);
              json += '],';              
              json += agregaNumeroCelular(nCel); //'"numeroCelular": "'+nCel+'",'+   // número de celular de contacto de la persona. +              
              json += '"razonSocial_Jur": "'+nom+'" '+ //  Indica la razón social de la persona Jurídica +
            '}  }   } ';
        return json;
      }

    public static String listaRepresentantesLegales(List<Asociacion_cuenta_contacto__c> lstRp, Quote cot, Map<String,String> hom){
        String avales = '';
        for(Asociacion_cuenta_contacto__c acc: lstRp){
          if( acc.RepresentanteLegal__c ){
            avales +='{'+
                     '"idTipoRepresentante": "'+hom.get(TIPO_REP)+'",'+  //  Indica el tipo de representante del representante legal + 
                     '"numIdentificacion":   "'+acc.Contacto__r.Numero_de_identificacion__c+'",'+ // Indica el número de identificación del representante legal + 
                     '"tipoIdentificacion":  "'+hom.get(acc.Contacto__r.Tipo_de_identificacion__c)+'" '+ // Indica el tipo de identificación del representante legal. +
                     '},';           
        }}
        avales = ( avales.length() > 0 )? avales.substring(0, avales.length() - 1) : '';
        return avales;
      }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura de clases para el manejo de la respuesta del servicio de cliente Juridico
    *Date: 2-7-2020
    **************************************************************************************************/
      public Class RespuestaGiradorPJ{
        public Pj_response response;
      }
        Class Pj_response {
          public Pj_solicitudCredito solicitudCredito;
          public Pj_encabezado encabezado;
          public Pj_CreacionGiradoresCodificados CreacionGiradoresCodificados;
        }
        Class Pj_solicitudCredito {
          public Integer radicado;	//5454
          public Integer oficina;	//32
          public Integer idProceso;	//2323
        }
        Class Pj_encabezado {
          public String fecha;	//2020-03-09T13:20:09
          public String usuario;	//PEDROGG
          public String operacion;	//CREACIONGIRADORES
          public String origen;	//SALESFORCE
          public String destino;	//DECEVAL
          public Pj_mensaje mensaje;
        }
        Class Pj_mensaje {
          public String descripcion;	//(SDL.SE.0098): Se presentaron errores al crear el(los) girador(es). Número de giradores fallidos:1
          public String estado;	//ERROR
        }
        Class Pj_CreacionGiradoresCodificados {
          public Pj_crearGiradorDTO crearGiradorDTO;
        }
        Class Pj_crearGiradorDTO {
          public Integer fkIdTipoDocumento;	//1
          public String numeroDocumento;	//1181818181          
          public String numeroCelular;	//3196369610
          public String razonSocial_Jur;	//Pruebas Deceval B2B
          public Integer fkIdClasePersona;	//1
          public String correoElectronico;	//prueba@mail.com
          public String identificacionEmisor;	//22
          public Integer cuentaGirador;	//0
          public String mensajeRespuesta;	//SDL.DA.0440 - SDL.DA.0440 - No existe el emisor enviado
          //public String fkIdCiudadDomicilio_Nat; //05510
          public String fkIdCiudad_Jur; //05510
          public String direccion1PersonaGrupo_PGP; //Calle 23 #5
          public String telefono1PersonaGrupo_PGP; //785632
          public Pj_listaRepresentantesLegales listaRepresentantesLegales;          
        }
        Class Pj_listaRepresentantesLegales {
          public String numIdentificacion;	//80094108
          public Integer tipoIdentificacion;	//1          
          public Integer idTipoRepresentante;	//1
        }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Manejo en caso de exception y diferente de OK 200 en la integracion de cliente natural
    *Date: 02-7-2020
    **************************************************************************************************/
    public static String resultadoIntegracionErrorPNA( Quote cot, Asociacion_cuenta_contacto__c acc, RespuestaGiradorPN errGirador, String tipo){
      if( tipo.contains( TRY_CATCH ) ){
        RespuestaGirador girador = new RespuestaGirador(ERROR,MSG_ADMIN,acc.Contacto__r.Name,CLIENTE_N,false);
        lstGiradores.add(girador);
        if( tipo.contains( TIPO_CLIENTE ) ){   actualizaciones(cot);   }
        return JSON.serialize(resGlobal);
      }
      RespuestaGirador girador = new RespuestaGirador(errGirador.response.encabezado.mensaje.estado, errGirador.response.encabezado.mensaje.descripcion,
                                            errGirador.response.CreacionGiradoresCodificados.crearGiradorDTO.nombresNat_Nat,CLIENTE_N,true);
      lstGiradores.add(girador);
      if( tipo.contains( TIPO_CLIENTE ) ){     actualizaciones(cot);   }
      return JSON.serialize(resGlobal);        
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Manejo en caso de exception y diferente de OK 200 en la integracion de cliente juridico
    *Date: 02-7-2020
    **************************************************************************************************/
    public static String resultadoIntegracionErrorPJ(  Quote cot, RespuestaGiradorPJ errGirador, String tipo){
      if( tipo == TRY_CATCH ){
        RespuestaGirador girador = new RespuestaGirador(ERROR,MSG_ADMIN,cot.Opportunity.Account.Name,CLIENTE_J,false);
        lstGiradores.add(girador);
        actualizaciones(cot);                
        return JSON.serialize(resGlobal);
      }
      RespuestaGirador girador = new RespuestaGirador(errGirador.response.encabezado.mensaje.estado, errGirador.response.encabezado.mensaje.descripcion,
                                            errGirador.response.CreacionGiradoresCodificados.crearGiradorDTO.razonSocial_Jur,CLIENTE_N,true);
      lstGiradores.add(girador);
      actualizaciones(cot); 
      System.debug( lstGiradores.size() );
      return JSON.serialize(resGlobal);        
    }

    /*********************************
    *Author:  Rafael Cardona 
    *Function: Consulta de cotizacion
    *Date: 02-7-2020
    **********************************/
    public static Opportunity consultaOportunidad(String idOportunidad){
      return [SELECT ID,SedeOpp__c FROM Opportunity WHERE ID =: idOportunidad];
  }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para entregarsela al componente Aura que maneja la interfaz de usuario
    *Date: 02-7-2020
    **************************************************************************************************/
    public Class RespuestaGlobal{
      private String mensajeGlobal;
      private List<RespuestaGirador> lista;
      private RespuestaGlobal(String res, List<RespuestaGirador> lst){
        this.mensajeGlobal = res;
        this.lista         = lst;
      }
    }
    public Class RespuestaGirador{
      private String  estado;
      private String  descripcion;
      private String  nomGirador;
      private String  tipoGirador;
      private Boolean proceso;

      private RespuestaGirador(String estado, String des, String nom, String ti,Boolean proceso){
          this.estado      = estado;
          this.descripcion = des;
          this.nomGirador  = nom;
          this.tipoGirador = ti;
          this.proceso     = proceso;
      }
  }
}
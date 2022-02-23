/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase controladora del componente aura IT_Girador

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   26-JUN-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_Girador_ctr {

    private static final String JURIDICO     = 'Persona_juridica';
    private static final String NATURAL      = 'Persona_natural';
    private static final String TIPO_CLIENTE = 'Cliente';
    private static final String TIPO_AVAL    = 'Aval';
    private static final String CONTEXTO     = 'Giradores';
    private static final String SI_REPRESENTANTE = 'SI';
    private static final String NO_REPRESENTANTE = 'NO';
    private static final String ES_NULO          = null;
    private static final String OK              = 'OK';
    private static final String ETAPA_BLOQUEADA = 'EB';
    private static final String SINC_OPP        = 'SincOpp';
    private static final String RADICADO        = 'Radicado';
    private static final String NOMB_BENEFI     = 'NombreBeneficiario';
    private static List<Asociacion_cuenta_contacto__c> lstAscc;

    static{
        lstAscc = new List<Asociacion_cuenta_contacto__c>();
    }

    /*********************************************************************************
    *Author:  Rafael Cardona
    *Function: Funcion responsable de listar los Giradores a enviar en la integracion
    *Date: 02-7-2020
    **********************************************************************************/
    @AuraEnabled
    public static String listadoGiradores(String idCotizacion){        
        Quote cotizacion = consultaCotizacion(idCotizacion);
        String val = validaciones( cotizacion );
        if( OK != val ){
            List<Girador> lstGirador = new List<Girador>{ new Girador(false,val) };
            return JSON.serialize(lstGirador);
        }
        List<Id> listaId = new List<Id>{ cotizacion.OpportunityId }; 
        List<Girador> lstGirador = obtieneGiradores( listaId , cotizacion);

        return JSON.serialize(lstGirador);
    }

    /***********************************************************************************
    *Author:  Rafael Cardona
    *Function: Controla que la oportunidad este en una etapa valida para la integracion
    *Date: 02-7-2020
    *************************************************************************************/
    public static String validaciones(Quote cotizacion){
        String  avanzar = OK;
        Map<String,String> homo = getHomologaciones();
        List<String> etapas     = homo.get(ETAPA_BLOQUEADA).split(',');
        for (String var : etapas) {
            if( (cotizacion.Opportunity.StageName).contains( var )){
                avanzar = ETAPA_BLOQUEADA;
            }
        }
        if( cotizacion.Opportunity.Respuesta_Oportunidad__c == ES_NULO ||
            (cotizacion.Opportunity.Respuesta_Oportunidad__c!=ES_NULO && !(cotizacion.Opportunity.Respuesta_Oportunidad__c).contains(OK))
        ){
            return SINC_OPP;
        }else if( cotizacion.QuoteLineItems[0].Identificador_Radicado_OR__c == ES_NULO ){
            return RADICADO;
        }else{
            return avanzar;
        } 
    }

    /**************************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Organiza los Giradores insertandolos en una estructura facil de manipular en la interfaz de usuario
    *Date: 02-7-2020
    ***************************************************************************************************************/
    public static List<Girador> obtieneGiradores( List<Id> listaId , Quote cot){
        List<Girador> lstGirador = new List<Girador>();
        lstAscc = consultaAsociacionAval(listaId);
        lstGirador.add( obtieneGiradorCliente( cot ));
        String nomCompleto = '';
        for(Integer k=0; k < lstAscc.size(); k++){
            nomCompleto = agregaApellido( lstAscc[k] );
            Girador gi = new Girador(
            nomCompleto,
            lstAscc[k].Contacto__r.Numero_de_identificacion__c,
            TIPO_AVAL,
            ( lstAscc[k].RepresentanteLegal__c ) ? SI_REPRESENTANTE : NO_REPRESENTANTE
            );
            lstGirador.add(gi);
        }        
        return lstGirador;
    }
    /*********************************************************************
    *Author:  Rafael Cardona
    *Function: Organiza el Girador cliente insertandolo en la estructura
    *Date: 02-7-2020
    *********************************************************************/
    public static Girador obtieneGiradorCliente(Quote cot){
        String nombreCompleto = agregaApellido( cot.Opportunity.Account.Name, cot.Opportunity.Account.Segundo_Apellido__c, 
                                               cot.Opportunity.Account.RecordType.DeveloperName );
        Girador gi = new Girador(
            nombreCompleto,
            cot.Opportunity.Account.Numero_de_identificacion__c,
            TIPO_CLIENTE,
            NO_REPRESENTANTE
            );
        return gi;
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Funcion responsable del envio de la integracion crear actualizar giradores
    *Date: 02-7-2020
    **************************************************************************************/
    @AuraEnabled
    public static String integraGirador( String idCotizacion ){
        String respuesta = '';
        Quote cotizacion = consultaCotizacion(idCotizacion);
        Map<String,String> homologaciones = getHomologaciones();
        List<Id> listaId = new List<Id>{ cotizacion.OpportunityId };
        lstAscc = consultaAsociacionAval(listaId);

        if( cotizacion.Opportunity.Account.RecordType.DeveloperName == JURIDICO ){
            enviaGiradorNaturalAvales( cotizacion  , homologaciones );
            respuesta = enviaGiradorJuridicoCliente( cotizacion  , homologaciones );
        }else if( cotizacion.Opportunity.Account.RecordType.DeveloperName == NATURAL ){
            enviaGiradorNaturalAvales( cotizacion  , homologaciones );
            respuesta = enviaGiradorNaturalCliente( cotizacion , homologaciones );            
        }
        System.debug('integrador: '+respuesta);
        return respuesta;
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Ejecuta la integracion para el cliente natural
    *Date: 02-7-2020
    **************************************************************************************/
    public static String enviaGiradorNaturalCliente( Quote cotizacion , Map<String,String> hom){
        return IT_ServicioGiradores_ws.ejecutaPersonaNatural( cotizacion, new Asociacion_cuenta_contacto__c(), hom, TIPO_CLIENTE );
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Ejecuta la integracion para los avales
    *Date: 02-7-2020
    **************************************************************************************/
    public static void enviaGiradorNaturalAvales( Quote cotizacion , Map<String,String> hom ){
        for(Asociacion_cuenta_contacto__c acc: lstAscc){
            IT_ServicioGiradores_ws.ejecutaPersonaNatural(cotizacion, acc, hom, TIPO_AVAL);
        }
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Ejecuta la integracion para el cliente juridico
    *Date: 02-7-2020
    **************************************************************************************/
    public static String enviaGiradorJuridicoCliente( Quote cotizacion , Map<String,String> hom ){
        return IT_ServicioGiradores_ws.ejecutaPersonaJuridica(cotizacion , lstAscc, hom );
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Pone en un MAP las configuraciones parametrizadas de la metadata
    *Date: 02-7-2020
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

    /*********************************
    *Author:  Rafael Cardona
    *Function: Consulta de cotizacion
    *Date: 02-7-2020
    **********************************/
    public static Quote consultaCotizacion(String idCotizacion){
        return [SELECT id,Iniciar_sincronizacion__c,Detener_sincronizacion__c, Opportunity.RecordType.DeveloperName,
        Status, Opportunity.Identificador_proceso__c, OpportunityId ,  Opportunity.AccountId, 
        Opportunity.Account.RecordType.DeveloperName , Opportunity.Respuesta_Oportunidad__c,
        Opportunity.Account.Numero_de_identificacion__c,
        Opportunity.Account.Tipo_de_identificacion__c, Opportunity.Account.Movil_empresa__c,
        Opportunity.Account.PersonEmail, Opportunity.Account.firstName, Opportunity.Account.lastName,
        Opportunity.StageName,Opportunity.Account.Segundo_Apellido__c,Opportunity.Account.MiddleName,
        Opportunity.Account.Name,RespuestaCrearActualizarGiradores__c,EstadoIntegracionGirador__c,
        ResIntegreacionPagare__c,EstadoIntegracionPagare__c,
        Opportunity.Asesor_asignado__r.Sede_Empleado__r.Codigo_Sede_OR__c,
        Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
        Opportunity.Account.Correo_electronico_empresa__c,
        Opportunity.Account.Telefono_empresa__c,
        Opportunity.Account.Vista_direccion_empresa__c,
        Opportunity.Account.Ciudad_empresa__c,
        Opportunity.Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c,
        Opportunity.NomApe_Ben1__c,
        (SELECT Identificador_Radicado_OR__c  FROM QuoteLineItems )
        FROM Quote WHERE id =: idCotizacion];
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para entregarsela al componente Aura que maneja la interfaz de usuario
    *Date: 02-7-2020
    **************************************************************************************************/
    public Class Girador{
        private String nombre;
        private String documento;
        private String tipo;
        private String representanteLegal;
        private Boolean proceso;
        private String mensaje;

        private Girador(String nom, String doc, String tip,String rep){
            this.nombre             = nom;
            this.documento          = doc;
            this.tipo               = tip;
            this.representanteLegal = rep;
        }
        private Girador(Boolean proceso, String mensaje){
            this.proceso  = proceso;
            this.mensaje  = mensaje;
        }
    }

    public static Integer generarDigitoNit(String nit){
        String nnit = '890984843';
        string miTemp = '';
        Integer miChequeo = 0;
        Integer residuo = 0;
        Integer[] numeroFijo = new Integer[15];
        numeroFijo[0] = 3;
        numeroFijo[1] = 7;
        numeroFijo[2] = 13;
        numeroFijo[3] = 17;
        numeroFijo[4] = 19;
        numeroFijo[5] = 23;
        numeroFijo[6] = 29;
        numeroFijo[7] = 37;
        numeroFijo[8] = 41;
        numeroFijo[9] = 43;
        numeroFijo[10] = 47;
        numeroFijo[11] = 53;
        numeroFijo[12] = 59;
        numeroFijo[13] = 67;
        numeroFijo[14] = 71;
        
        for( Integer k = 0; k < nit.length(); k++ ){
            miTemp = nit.subString(k , k + 1);
            miChequeo = miChequeo + ( Integer.valueof(miTemp)  * numeroFijo[ (nit.length() - 1) - k ] );
        }        
        residuo = math.mod(miChequeo,11);
        System.debug('resultado= '+ residuo);
        if( residuo > 1 ){
            System.debug('resultado* '+ (11 - residuo));
            return 11 - residuo;
        }else{
            System.debug('resultado^ '+ residuo);
            return residuo;
        }
    }

    public static String agregaApellido( Asociacion_cuenta_contacto__c aso ){
        if( aso.Contacto__r.Segundo_Apellido__c != null ){
            return aso.Contacto__r.Name +' '+ aso.Contacto__r.Segundo_Apellido__c; 
        }else{
            return aso.Contacto__r.Name;
        }
    }

    public static String agregaApellido( String nombre, String segundoApellido, String tipoRegistro){
        if(tipoRegistro == 'Persona_juridica'){
            return nombre;
        }else{
            if( segundoApellido != null ){
                return nombre +' '+ segundoApellido;
            }else{
                return nombre;
            }            
        }        
    }
    
    public static List<Asociacion_cuenta_contacto__c> consultaAsociacionAval(List<Id> idsOportunidad){
        return [SELECT Id,Name,Cliente__c,Cliente__r.Consecutivo_Padre__c,Contacto__c,Oportunidad__c,Contacto__r.LastName,Contacto__r.Email,Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c,
                Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c,Contacto__r.Ciudad_contacto__r.Nombre_Departamento__c,Contacto__r.Ciudad_contacto__r.Codigo_Ciudad_OR__c,Contacto__r.Ciudad_contacto__r.Name,
                Contacto__r.Informacion_adicional_complemento_c__c,Contacto__r.Intercesion_contacto__c,Contacto__r.Letra_contacto_a__c,Contacto__r.Letra_contacto_b__c,Contacto__r.Numero_contacto_a__c,
                Contacto__r.Numero_contacto_b__c,Contacto__r.Punto_cardinal_contacto_a__c,Contacto__r.Punto_cardinal_contacto_b__c,Contacto__r.Ruralidad_domicilio_contacto__c,Contacto__r.Empresa_donde_labora__c,
                Contacto__r.Via_contacto__c,Contacto__r.Birthdate,Contacto__r.Genero__c,Contacto__r.Indicativo_contacto__c,Contacto__r.Medio_por_el_cual_conocio_a_Interactuar__c,Contacto__r.Movil_contacto__c,
                Contacto__r.Nivel_de_escolaridad__c,Contacto__r.Name,Contacto__r.Numero_de_identificacion__c,Contacto__r.Telefono_contacto__c,Contacto__r.Tipo_de_identificacion__c,Contacto__r.Estado_civil__c,
                Contacto__r.Personas_a_cargo__c,Contacto__r.Tipo_de_vivienda__c,Contacto__r.Cabeza_de_familia__c,Contacto__r.Estrato_contacto__c,Contacto__r.Valor_comercial_del_Bien__c,
                Contacto__r.Ingresos_conyuge__c,Contacto__r.Pais_contacto__c,Contacto__r.Total_ingresos__c,Contacto__r.Sueldo_Honorario__c,
                Contacto__r.Total_egresos__c,Contacto__r.Hogar__c,Contacto__r.FirstName,Contacto__r.Zona_contacto__r.Codigo_Registro_Zona__c,Contacto__r.Zona_contacto__r.Name,Contacto__r.Phone,
                Contacto__r.DireccionLaboral__c,Contacto__r.TelefonoLaboral__c,Contacto__r.Ocupacion__c,Contacto__r.Nombres_y_apellidos_Referencia__c,Contacto__r.Nombres_y_apellidos_Ref2__c,Contacto__r.Nombres_y_apellidos_Ref3__c,
                Contacto__r.Nombres_y_apellidos_Ref4__c,Contacto__r.Nombres_y_apellidos_Ref5__c,Contacto__r.Telefono_Referencia__c,Contacto__r.Telefono_Ref2__c,Contacto__r.Telefono_Ref3__c,Contacto__r.Telefono_Ref4__c,
                Contacto__r.Telefono_Ref5__c,Contacto__r.Tipo_Referencia_1__c,Contacto__r.Tipo_Referencia_2__c,Contacto__r.Tipo_Referencia_3__c,Contacto__r.Tipo_Referencia_4__c,Contacto__r.Tipo_Referencia_5__c,
                Contacto__r.CiudadRef1codOR__c,Contacto__r.CiudadRef2codOR__c,Contacto__r.CiudadRef3codOR__c,Contacto__r.CiudadRef4codOR__c,Contacto__r.CiudadRef5codOR__c,RepresentanteLegal__c,Contacto__r.Lugar_expedicion__c,
                Cliente__r.Name,Cliente__r.Numero_de_identificacion__c,Oportunidad__r.Identificador_proceso__c,Contacto__r.Segundo_Apellido__c,Contacto__r.MiddleName,Cliente__r.RecordType.DeveloperName,
                Oportunidad__r.RecordType.DeveloperName,Contacto__r.Vista_direccion_contacto__c,Contacto__r.Departamento_contacto__c,Contacto__r.Ciudad_contacto__r.Codigo_DANE_Ciudad__c,Contacto__r.Barrio_contacto__r.Name,Cliente__r.Tipo_de_identificacion__c,Cliente__r.LastName,
                Cliente__r.Segundo_Apellido__c,Cliente__r.Genero__pc,Cliente__r.Lugar_expedicion__c,Cliente__r.Fecha_de_nacimiento__c,Cliente__r.Pais_empresa__c,Cliente__r.Vista_direccion_empresa__c,
                Cliente__r.Departamento_empresa__c,Cliente__r.Barrio_empresa__r.Name,Cliente__r.Telefono_empresa__c,Cliente__r.Movil_empresa__c,Cliente__r.PersonEmail,Cliente__r.Empresa_donde_labora__c,
                Cliente__r.DireccionLaboral__c,Cliente__r.TelefonoLaboral__c,Cliente__r.FirstName,Cliente__r.MiddleName,Cliente__r.Ciudad_empresa__r.Name,Cliente__r.Nacionalidad__c,Cliente__r.Lugar_de_nacimiento__c,
                Cliente__r.Peso_kg__c,Cliente__r.Estatura_cm__c,Cliente__r.Estado_civil__pc,Cliente__r.AnnualRevenue
                FROM Asociacion_cuenta_contacto__c 
                WHERE Oportunidad__c =: idsOportunidad.get(0)];
    }
}
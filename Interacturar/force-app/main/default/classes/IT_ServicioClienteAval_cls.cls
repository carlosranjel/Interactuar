/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar parte 2
* @descripcion      Clase para consultar el servicio de cliente contacto 

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   11-FEB-2020   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public with sharing class IT_ServicioClienteAval_cls {
    
    private static Http               http;
    private static HttpRequest        Request;
    private static HttpResponse       Response;
    private static String             JSON_req {get;set;}
    private static List<ID>           lstIdis;
    private static Map<String,String> hom;
    private static final String       AVALISTA = 'rolAvalista';
    private static final String       REPR     = 'rolRLegal';
    private static final String       CONTEXTO = 'Pagare';
    private static final String       ES_NULO  = null;
    
    public IT_ServicioClienteAval_cls() { }      

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Metodo de inicio
    *Date: 3-3-2020
    **************************************************************************/
    @InvocableMethod
    public static void idContactoAval(List<ID> idsContacto){        
        system.debug(' idsContacto Aval-->'+idsContacto);        
        consumeServicvioWeb(idsContacto);     
    }
    
    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de consultar el contacto y consumir el servicio
    *Date: 3-3-2020
    **************************************************************************/
    @future (callout=true)
    public static void consumeServicvioWeb(List<ID> idsContacto){
        http = new Http();
        hom = getHomologaciones();
        List<Contact> lstContactos = IT_GestorDeConsultas_cls.consultaContacto(idsContacto);
        system.debug('lstContactos: '+ lstContactos);
        
        if( lstContactos.size() == 1  &&  lstContactos.get(0).controlSincronizacion__c ){
            JSON_req = clientJSON(lstContactos.get(0));
            system.debug(' body--->'+JSON_req); 
            Request = IT_ParametrosWS_cls.parametrosClienteAval(JSON_req);        
            Response = http.send(Request);
            system.debug('IT_ServicioCliente_cls.response Body:'+Response.getBody()); 
            if( lstContactos.get(0).controlSincronizacion__c ){
                lstContactos.get(0).controlSincronizacion__c = false;
                update lstContactos;
            }
        } 
    }

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se llena la informacion del JSON desde el contacto Aval
    *Date: 3-3-2020
    **************************************************************************/
    public static String clientJSON(Contact contacto){     
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        lstIdis = new List<ID>();
        lstIdis.add(contacto.id);
        List<Asociacion_cuenta_contacto__c> lstAscc = IT_GestorDeConsultas_cls.consultaConsecutivoPadre(lstIdis);
        String rol = ( lstAscc[0].RepresentanteLegal__c ) ? hom.get(REPR) : hom.get(AVALISTA);
        System.debug('numeroAleatorio: '+ numeroAleatorio); 
        String body='{'+ 
            '"encabezado": {'+
            '"estado": 0,'+
            '"excepcion": "exception",'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+contacto.id+'-'+numeroAleatorio+'",'+ 
            '"mensaje": "mensaje",'+
            '"integracion": "Sincronizar Cliente Aval",'+
            '"operacion": 0,'+
            '"origen": "SALESFORCE",'+
            '"destino": "ORACLE"'+
            '},'+
            '"cuerpo": {'+
            '"tipoRegistroCliente": 0,'+ 
            '"codigo": "'+contacto.id+'",'+
            '"consecutivoPadre":   '+IT_ConstruccionJSON_cls.validarsObject(lstAscc) +','+
            '"informacionBasica": {'+
            '"apellidos": '+IT_ConstruccionJSON_cls.validarStringNombreApellido( contacto.LastName, contacto.Segundo_Apellido__c )+','+
            '"autorizacionDatos":0,'+ 
            '"correoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Email)+','+ 
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(contacto.Barrio_contacto__r.Codigo_Registro_Barrio__c)+','+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(contacto.Codigo_departamento_contacto__c)+','+
            '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Departamento_contacto__c)+' '+
            '},'+ // fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(contacto.Codigo_ciudad_contacto__c)+','+ 
            '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Ciudad_contacto__r.Name)+','+
            '"zona": {'+
            '"codigo":  '+IT_ConstruccionJSON_cls.validarNullString_Integer(contacto.Zona_contacto__r.Codigo_Registro_Zona__c)+','+
            '"nombre":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Zona_contacto__r.Name)+''+  // 
            '}'+  // fin zona
            '},'+ // fin ciudad
            '"complemento": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Informacion_adicional_complemento_c__c)+','+ 
            '"intercesion": '+IT_ConstruccionJSON_cls.validarDecimalReturnNull(contacto.Intercesion_contacto__c)+','+ 
            '"letra": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Letra_contacto_a__c)+','+
            '"letraB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Letra_contacto_b__c)+','+
            '"numero": '+IT_ConstruccionJSON_cls.validarDecimalReturnNull(contacto.Numero_contacto_a__c)+','+  
            '"numeroB": '+IT_ConstruccionJSON_cls.validarDecimalReturnNull(contacto.Numero_contacto_b__c)+','+ 
            '"puntoCardinal": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Punto_cardinal_contacto_a__c)+','+
            '"puntoCardinalB": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Punto_cardinal_contacto_b__c)+','+
            '"ruralidad": '+contacto.Ruralidad_domicilio_contacto__c+','+
            '"via": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Via_contacto__c)+
            '},'+  // fin direccion
            '"fechaNacimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(contacto.Birthdate)+'",'+
            '"genero": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Genero__c)+','+
            '"indicativo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(contacto.Indicativo_contacto__c)+','+
            '"medio": "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Medio_por_el_cual_conocio_a_Interactuar__c)+'",'+
            '"movilContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Movil_contacto__c)+','+ 
            '"nivelEscolaridad": "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Nivel_de_escolaridad__c)+'",'+
            '"nombre":  '+IT_ConstruccionJSON_cls.validarStringNombreApellido( contacto.FirstName , contacto.Middlename )+','+
            '"numeroIdentificacion": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Numero_de_identificacion__c)+','+ 
            '"telefonoContacto": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_contacto__c)+','+
            '"tipoIdentificacion": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Tipo_de_identificacion__c)+','+
            '"estadoCivil": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Estado_civil__c)+','+  
            '"autorretenedor":false,'+ 
            '"personasACargo": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(contacto.Personas_a_cargo__c)+','+    
            '"estadoCliente": "Vigente",'+  
            '"TipoVivienda": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Tipo_de_vivienda__c)+','+   
            '"actividadCliente": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Ocupacion__c)+','+  
            '"cabezaFamilia":'+contacto.Cabeza_de_familia__c+','+    
            '"estrato": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Estrato_contacto__c)+','+
            '"datosLaborales":{'+
            '"direccionTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.DireccionLaboral__c)+','+
            '"telefonoTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.TelefonoLaboral__c)+' '+
            '},'+  // fin datosLaborales
            '"valorBien": '+IT_ConstruccionJSON_cls.validarDecimalReNullDecimal(contacto.Valor_comercial_del_Bien__c)+','+
            '"cupoRecomendado":0,'+
            '"cuotasActuar":0,'+
            '"ingresos":{'+
            '"otrosIngresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Otros_ingresos_familiares__c)+','+
            '"otroValor":  0,'+ 
            '"ingresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Ingresos_conyuge__c)+','+
            '"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Sueldo_Honorario__c)+
            '},'+ // fin ingresos
            '"egresos":{'+
            '"otrosEgresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Otros_egresos_familiares__c)+','+
            '"egresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Egresos_conyuge__c)+','+
            '"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(contacto.Hogar__c)+
            '},'+  // fin egresos
            '"referencias":{'+
            '"tipoDeReferencias": "AVAL",'+
            '"nombresReferencia1":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Nombres_y_apellidos_Referencia__c)+','+
            '"telefonoReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_Referencia__c)+','+
            '"tipoReferencia1":     "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Tipo_Referencia_1__c)+'",'+
            '"ciudadReferencia1":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(contacto.CiudadRef1codOR__c)+','+
            '"nombresReferencia2":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Nombres_y_apellidos_Ref2__c)+','+
            '"telefonoReferencia2": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_Ref2__c)+','+
            '"tipoReferencia2":     "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Tipo_Referencia_2__c)+'",'+
            '"ciudadReferencia2":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(contacto.CiudadRef2codOR__c)+','+
            '"nombresReferencia3":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Nombres_y_apellidos_Ref3__c)+','+
            '"telefonoReferencia3": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_Ref3__c)+','+
            '"tipoReferencia3":     "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Tipo_Referencia_3__c)+'",'+
            '"ciudadReferencia3":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(contacto.CiudadRef3codOR__c)+','+
            '"nombresReferencia4":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Nombres_y_apellidos_Ref4__c)+','+
            '"telefonoReferencia4": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_Ref4__c)+','+
            '"tipoReferencia4":     "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Tipo_Referencia_4__c)+'",'+
            '"ciudadReferencia4":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(contacto.CiudadRef4codOR__c)+','+
            '"nombresReferencia5":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Nombres_y_apellidos_Ref5__c)+','+
            '"telefonoReferencia5": '+IT_ConstruccionJSON_cls.validarStringReturnNull(contacto.Telefono_Ref5__c)+','+
            '"tipoReferencia5":     "'+IT_ConstruccionJSON_cls.validarNullString(contacto.Tipo_Referencia_5__c)+'",'+
            '"ciudadReferencia5":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(contacto.CiudadRef5codOR__c)+' '+
            '},'+  // fin referencias
            '"rol": "'+rol+'" '+
            '},'+  // fin informacion basica
            '"famiEmpresa": {'+ // inicio famiEmpresa y va vacio para el aval
            '"actividadEconomica": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+  // fin actividad academica
            '"fechaCreacion": null,'+
            '"anosExperiencia": null,'+//rr_cb
            '"correoElectronico": null,'+
            '"direccion": {'+
            '"barrio": null,'+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+  // fin departamento
            '"codigo": null,'+
            '"nombre": null,'+
            '"zona": {'+
            '"codigo": 0,'+ 
            '"nombre": null'+ 
            '}'+ // fin zona
            '},'+ // fin ciudad
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
            '},'+ // fin direccion
            '"empleados": null,'+
            '"indicativo": null,'+ 
            '"industria": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+ // fin industria
            '"movil": null,'+
            '"nombreFamiempresa": null,'+
            '"numeroFormalizacion": null,'+
            '"principalesProductos": null,'+
            '"sector": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+ // fin sector
            '"telefono": null,'+
            '"tipoFormalizacion": null,'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": null,'+
            '"inventarios": null,'+
            '"activosFijos": null,'+
            '"totalActivos": null,'+
            '"totalPasivos": null,'+
            '"totalCapitalTrabajo": null,'+   // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+   // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null'+   // ultimos ajustes de formulario digital
            '},'+// fin balanceGeneral
            '"costoMercanciaVendida": null,'+
            '"disponibilidadNetaEmpresa": null,'+
            '"ingresosVentas": null,'+   // ultimos ajustes de formulario digital
            '"codigoAsesor": null,'+
            '"empleosGenerar": null,'+ // Se ingresa el valor sin asignacion por el reuso de la integracion del cliente
            '"ingresosAnuales": null,'+ // Se ingresa el valor sin asignacion por el reuso de la integracion del cliente
            '"codigoFamiempresa": null'+ 
            '} } }';  // fin informacionBasica , fin cuerpo, fin json                             
        return body;
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
}
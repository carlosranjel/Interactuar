/**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class que llama el servicio de cliente
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   10-AGO-2019  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************/
public with sharing class IT_ServicioCliente_cls {
    private static Http         http;
    private static HttpRequest  Request;
    private static HttpResponse Response;
    private static String       JSON_req {get;set;}
    private static Map<String,String> hom;
    private static final String       RCLIENTE = 'rolCliente';
    private static final String       CONTEXTO = 'Pagare';
    private static final String       ES_NULO  = null;
    
    public IT_ServicioCliente_cls() {  }
    
    /*******************************************************************************
    *Author:  Rafael Cardona
    *Function: Entrada para cuando se consume desde un flow
    *Date: 3-3-2020
    ********************************************************************************/
    @InvocableMethod
    public static void obtenerESB(List<ID> idsCuenta){        
        system.debug(' idsCuenta-->'+idsCuenta);       
        IF(!System.isFuture()){
            System.debug('no Es future');
            enviarInformacionTalent(idsCuenta);     

        }else{
            System.debug(' es future');
            
        }
    }
    
    
   /*************************************************************************
   *Author:  Rafael Cardona
   *Function: Consulta la cuenta y hace la integracion con Talent
   *Date: 3-3-2020
   **************************************************************************/
    @future (callout=true)
    public static void enviarInformacionTalent(List<ID> idsCuenta){
                system.debug(' idsCuenta-->'+idsCuenta);        

        http = new Http();        
        List<Account> lstCuentas = IT_GestorDeConsultas_cls.consultaCuenta(idsCuenta);
        hom = getHomologaciones();
        system.debug('IT_ServicioCliente_cls'+ lstCuentas);
        
        if(lstCuentas.size() > 0){
            JSON_req = clientJSON(lstCuentas.get(0));
            system.debug(' body--->'+ JSON_req); 
        }
        Request = IT_ParametrosWS_cls.parametrosCliente();
        Request.setBody(JSON_req);
        Response = http.send(Request);
        system.debug('IT_ServicioCliente_cls.response Body:'+Response.getBody());        
    }
    
    
    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se llenan los datos en el json, menos los de la famiEmpresa
    *Date: 3-3-2020
   **************************************************************************/
    public static String clientJSON(Account cuenta){      
        String apellido        = (cuenta.RecordType.DeveloperName == 'Persona_juridica')? cuenta.Name : IT_ConstruccionJSON_cls.validarNullString(cuenta.LastName) + ' ' + IT_ConstruccionJSON_cls.validarNullString(cuenta.Segundo_Apellido__c);      
        String nombre          = (cuenta.RecordType.DeveloperName == 'Persona_juridica')? cuenta.Name : IT_ConstruccionJSON_cls.validarNullString(cuenta.FirstName) + ' ' + IT_ConstruccionJSON_cls.validarNullString(cuenta.MiddleName);        
        Date fechaNacimiento   = (cuenta.RecordType.DeveloperName == 'Persona_juridica')? cuenta.Fecha_de_creacion_de_empresa__c : cuenta.Fecha_de_nacimiento__c;
        Integer numeroAleatorio = Integer.valueof((Math.random() * 999));
        String correo          = (cuenta.RecordType.DeveloperName == 'Persona_juridica')? cuenta.Correo_electronico_empresa__c :  cuenta.PersonEmail; 
        
        System.debug('numeroAleatorio: '+ numeroAleatorio); 
        String body='{'+ 
            '"encabezado": {'+
            '"estado": 0,'+
            '"excepcion": "exception",'+
            '"fecha": "'+(System.now()).addHours(-5)+'",'+
            '"identificador": "'+cuenta.id+'-'+numeroAleatorio+'",'+ 
            '"mensaje": "mensaje",'+
            '"integracion": "Sincronizar Cliente",'+
            '"operacion": 0,'+
            '"origen": " SALESFORCE",'+
            '"destino": " ORACLE"'+
            '},'+  // fin encabezado
            '"cuerpo": {'+
            '"tipoRegistroCliente": 0,'+ 
            '"codigo": "'+cuenta.id+'",'+
            '"consecutivoPadre": null,'+ // NUEVO, solo en caso de que se envie un aval
            '"informacionBasica": {'+
            '"apellidos": "'+IT_ConstruccionJSON_cls.validarNullString(apellido)+'",'+
            '"autorizacionDatos":0,'+ 
            '"correoContacto": "'+IT_ConstruccionJSON_cls.validarNullString(correo)+'",'+
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_barrio_empresa__c)+','+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_departamento_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Departamento_empresa__c)+'"'+
            '},'+ // fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_ciudad_empresa__c)+','+ 
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Ciudad_empresa__r.Name)+'",'+
            '"zona": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Zona_empresa__r.Codigo_Registro_Zona__c)+','+ 
            '"nombre": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Zona_empresa__r.Name)+' '+ 
            '}'+  // fin zona
            '},'+  // fin ciudad
            '"complemento": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Informacion_adicional_complemento_e__c)+'",'+
            '"intercesion": "'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Intercesion_empresa__c)+'",'+ 
            '"letra": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Letra_empresa_a__c)+'",'+
            '"letraB": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Letra_empresa_b__c)+'",'+
            '"numero": "'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Numero_empresa_a__c)+'",'+  
            '"numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Numero_empresa_b__c)+'",'+ 
            '"puntoCardinal": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Punto_Cardinal_empresa_a__c)+'",'+
            '"puntoCardinalB": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Punto_cardinal_empresa_b__c)+'",'+
            '"ruralidad": '+cuenta.Ubicacion_Rural__c+','+
            '"via": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Via_empresa__c)+'"'+
            '},'+  // fin direccion
            '"fechaNacimiento": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(fechaNacimiento)+'",'+ 
            '"genero": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Genero__pc)+'",'+
            '"indicativo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Indicativo_empresa__c)+','+
            '"medio": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Medio_por_el_cual_conocio_a_Interactuar__c)+'",'+
            '"movilContacto": '+cuenta.Movil_empresa__c+','+ 
            '"nivelEscolaridad": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Nivel_de_escolaridad__pc)+'",'+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(nombre)+'",'+
            '"numeroIdentificacion": '+IT_ConstruccionJSON_cls.validarNullString(cuenta.Numero_de_identificacion__c)+','+ 
            '"telefonoContacto": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Telefono_empresa__c)+','+ 
            '"tipoIdentificacion": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_de_identificacion__c)+'",'+
            '"estadoCivil": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Estado_civil__pc)+'",'+  
            '"autorretenedor": '+cuenta.Es_autorretenedor__c+','+  
            '"personasACargo": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(cuenta.Personas_a_cargo__pc)+','+    
            '"estadoCliente": "'+ IT_ConstruccionJSON_cls.validarNullString(cuenta.Vigente__c)+'",'+ 
            '"TipoVivienda": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_de_vivienda__pc)+'",'+   
            '"actividadCliente": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Ocupacion__c)+'",'+  
            '"cabezaFamilia": '+cuenta.Cabeza_de_familia__pc+','+    
            '"estrato": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Estrato_empresa__c)+'",'+
            '"datosLaborales":{'+
            '"direccionTrabajo": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.DireccionLaboral__c)+','+
            '"telefonoTrabajo":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.TelefonoLaboral__c)+' '+
            '},'+ // fin datosLaborales
            '"valorBien": null,'+
            '"cupoRecomendado":0,'+
            '"cuotasActuar":0,'+
            '"ingresos":{'+
            '"otrosIngresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Otros_ingresos_familiares__c)+','+
            '"otroValor": 0,'+ 
            '"ingresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Ingresos_conyuge__c)+','+
            '"sueldoHonorarios": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Total_ingresos__c)+ // Se modifica Origen de Sueldo_Honorario__c a Total_ingresos__c. 19-02-2021
            '},'+  // fin ingresos
            '"egresos":{'+
            '"otrosEgresosFamiliares": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Otros_egresos_familiares__c)+','+
            '"egresosConyuge": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Egresos_conyuge__c)+','+
            '"egresosHogar": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(cuenta.Total_egresos__c)+
            '},'+  // fin egresos
            '"referencias":{'+
            '"tipoDeReferencias": "CLIENTE",'+
            '"nombresReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Nombres_y_apellidos_Referencia__c)+','+
            '"telefonoReferencia1": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Telefono_Referencia__c)+','+
            '"tipoReferencia1":     "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_Referencia_1__c)+'",'+
            '"ciudadReferencia1":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(cuenta.CiudadRef1codOR__c)+','+
            '"nombresReferencia2":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Nombres_y_apellidos_Ref2__c)+','+
            '"telefonoReferencia2": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Telefono_Ref2__c)+','+
            '"tipoReferencia2":     "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_Referencia_2__c)+'",'+
            '"ciudadReferencia2":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(cuenta.CiudadRef2codOR__c)+','+
            '"nombresReferencia3":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Nombres_y_apellidos_Ref3__c)+','+
            '"telefonoReferencia3": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Telefono_Ref3__c)+','+
            '"tipoReferencia3":     "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_Referencia_3__c)+'",'+
            '"ciudadReferencia3":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(cuenta.CiudadRef3codOR__c)+','+
            '"nombresReferencia4":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Nombres_y_apellidos_Ref4__c)+','+
            '"telefonoReferencia4": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Telefono_Ref4__c)+','+
            '"tipoReferencia4":     "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_Referencia_4__c)+'",'+
            '"ciudadReferencia4":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(cuenta.CiudadRef4codOR__c)+','+
            '"nombresReferencia5":  '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Nombres_y_apellidos_Ref5__c)+','+
            '"telefonoReferencia5": '+IT_ConstruccionJSON_cls.validarStringReturnNull(cuenta.Telefono_Ref5__c)+','+
            '"tipoReferencia5":     "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_Referencia_5__c)+'",'+
            '"ciudadReferencia5":   '+IT_ConstruccionJSON_cls.convierteCodigoOracle(cuenta.CiudadRef5codOR__c)+' '+
            '},'+ // fin referencias
            '"rol": "'+ hom.get(RCLIENTE) +'" '+
            '},'; // fin informacionBasica
        
        if( cuenta.RecordType.DeveloperName == 'Persona_juridica'){
            body += juridicaFamiEmpresa(cuenta);
        }else if( cuenta.RecordType.DeveloperName == 'Persona_natural'){
            body += seleccionaFamiEmpresa(cuenta.id);
        }        
        
        body += ' } }';  // fin cuerpo , fin json                              
        return body;
    }


    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Se llenan los datos en el json, para la famiEmpresa juridica
    *Date: 3-3-2020
   **************************************************************************/
    public static String juridicaFamiEmpresa(Account cuenta){
        String jsonFami = '';
        jsonFami +=  '"famiEmpresa":{'+          
            '"actividadEconomica":{'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Actividad_economica__r.Codigo_Actividad_Economica_OR__c)+','+ 
            '"nombre":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Actividad_economica__r.Name)+'"'+ 
            '},'+  // fin actividadEconomica
            '"fechaCreacion": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(cuenta.Fecha_de_creacion_de_empresa__c)+'",'+
            '"correoElectronico":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Correo_electronico_empresa__c)+'",'+ 
            '"direccion":{'+ 
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_barrio_empresa__c)+','+   
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_departamento_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Departamento_empresa__c)+'"'+  
            '},'+  // fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_ciudad_empresa__c)+','+ // 1 
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Ciudad_empresa__r.Name)+'",'+
            '"zona": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Zona_empresa__r.Codigo_Registro_Zona__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Zona_empresa__r.Name)+'"'+
            '}'+ // fin zona
            '},'+ // fin ciudad
            ' "complemento":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Informacion_adicional_complemento_e__c)+'",'+ 
            ' "intercesion":"'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Intercesion_empresa__c)+'",'+ 
            ' "letra":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Letra_empresa_a__c)+'",'+ 
            ' "letraB":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Letra_empresa_b__c)+'",'+ 
            ' "numero": "'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Numero_empresa_a__c)+'",'+ 
            ' "numeroB": "'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Numero_empresa_b__c)+'",'+ 
            ' "puntoCardinal":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Punto_Cardinal_empresa_a__c)+'",'+ 
            ' "puntoCardinalB":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Punto_cardinal_empresa_b__c)+'",'+
            ' "ruralidad":'+cuenta.Ubicacion_Rural__c+','+    
            ' "via": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Via_empresa__c)+'"'+
            '},'+  // fin direccion
            ' "empleados": '+IT_ConstruccionJSON_cls.validarNullInteger(cuenta.NumberOfEmployees)+','+ 
            ' "indicativo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Indicativo_empresa__c)+','+ 
            ' "industria":{'+ 
            ' "codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_industria_OR_SF__c)+','+ 
            ' "nombre": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Industria__c)+'"'+ 
            '},'+  // fin industria
            ' "movil": '+IT_ConstruccionJSON_cls.validarStringEspecial(cuenta.Movil_empresa__c)+','+ 
            ' "nombreFamiempresa":"'+cuenta.name+'",'+ 
            ' "numeroFormalizacion":'+IT_ConstruccionJSON_cls.validarStringEspecial(cuenta.Numero_de_identificacion__c)+','+ 
            ' "principalesProductos":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Principales_productos_servicios_1__c)+'",'+
            ' "sector":{'+ 
            ' "codigo":'+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Codigo_sector_OR__c)+','+ 
            ' "nombre":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Sector__c)+'"'+ 
            '},'+  // fin sector
            ' "telefono": '+cuenta.Telefono_empresa__c+','+   // Este campo permitira imputar 7 o 10 caracteres el cambio se genera a partir de validacion.          
            ' "tipoFormalización":"'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Tipo_de_identificacion__c)+'",'+ 
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": null,'+
            '"inventarios": null,'+
            '"activosFijos": null,'+
            '"totalActivos": null,'+
            '"totalPasivos": null,'+
            '"totalCapitalTrabajo": null,'+   // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+   // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null '+   // ultimos ajustes de formulario digital
            '},'+  // fin balanceGeneral
            '"costoMercanciaVendida": null,'+
            '"disponibilidadNetaEmpresa": null,'+
            '"ingresosVentas": null,'+   // ultimos ajustes de formulario digital
            '"codigoAsesor": '+IT_ConstruccionJSON_cls.validarNullString_Integer(cuenta.Asesor_asignado__r.Codigo_de_Empleado__c)+','+ 
            '"empleosGenerar":"'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.Empleos_a_generar__c)+'",'+ 
            '"ingresosAnuales":"'+IT_ConstruccionJSON_cls.validarNullDecimal(cuenta.AnnualRevenue)+'",'+ 
            '"codigoFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(cuenta.Identificador_Famiempresa__c)+'"'+  
            '} ';
        return jsonFami;
    }

    /*******************************************************************************
    *Author:  Rafael Cardona
    *Function: Si un cliente natural puede que tenga o no una famiEmpresa asociada
    *Date: 3-3-2020
    ********************************************************************************/
    public static String seleccionaFamiEmpresa(string idCuenta){
        List<Famiempresa__c> lstFami = IT_GestorDeConsultas_cls.consultaFamiEmpresa(idCuenta);
        if(lstFami.size() > 0){
            return naturalFamiEmpresa(lstFami.get(0));
        }else{
            return sinFamiEmpresa();
        }    
    }

    /******************************************************************************
    *Author:  Rafael Cardona
    *Function: Se llenan los datos en el json, menos los de la famiEmpresa natural
    *Date: 3-3-2020
   ********************************************************************************/
    public static String naturalFamiEmpresa(Famiempresa__c fami){
        String jsonFami = '';
        jsonFami += '"famiEmpresa": {'+
            '"actividadEconomica": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Actividad_economica__r.Codigo_Actividad_Economica_OR__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Actividad_economica__r.Name)+'"'+
            '},'+ // fin actividadEconomica
            '"fechaCreacion": "'+IT_ConstruccionJSON_cls.validarFechaNacimiento(fami.Fecha_de_creacion_de_empresa__c)+'",'+
            '"anosExperiencia":"2",'+
            '"correoElectronico": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Correo_electronico_empresa__c)+'",'+
            '"direccion": {'+
            '"barrio": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Barrio_empresa__r.Codigo_Registro_Barrio__c)+','+ 
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_departamento_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Departamento_empresa__c)+'"'+
            '},'+  // fin departamento
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_ciudad_empresa__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Ciudad_empresa__r.Name)+'",'+ 
            '"zona": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Zona_empresa__r.Codigo_Registro_Zona__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Zona_empresa__r.Name)+'"'+
            '}'+  // fin zona
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
            '},'+ // fin direccion
            '"empleados": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(fami.Numero_de_empleados__c)+','+ 
            '"indicativo": '+IT_ConstruccionJSON_cls.validarDecimal_Decimal(fami.Indicativo_empresa__c)+','+ 
            '"industria": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_industria_OR_SF__c)+','+
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Industria__c)+'"'+
            '},'+  // fin industria
            '"movil": '+IT_ConstruccionJSON_cls.validarStringEspecial(fami.Movil_empresa__c)+','+
            '"nombreFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Name)+'",'+
            '"numeroFormalizacion": '+fami.Numero_de_identificacion__c+','+
            '"principalesProductos": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_1__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_2__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_3__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_4__c)+','+IT_ConstruccionJSON_cls.validarNullString(fami.Principales_productos_servicios_5__c)+'",'+
            '"sector": {'+
            '"codigo": '+IT_ConstruccionJSON_cls.validarNullString_Integer(fami.Codigo_sector_OR__c)+','+ 
            '"nombre": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Sector__c)+'"'+
            '},'+  // fin sector
            '"telefono": '+fami.Telefono_empresa__c+','+  // Este campo permitira imputar 7 o 10 caracteres el cambio se genera a partir de validacion.
            '"tipoFormalización": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Tipo_de_identificacion__c)+'",'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": null,'+
            '"inventarios": null,'+
            '"activosFijos": null,'+
            '"totalActivos": null,'+
            '"totalPasivos": null,'+
            '"totalCapitalTrabajo": null,'+    // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+  // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null '+   // ultimos ajustes de formulario digital
            '},'+  // fin balanceGeneral
            '"costoMercanciaVendida": '+IT_ConstruccionJSON_cls.validarDecimalReturnInteger(fami.Costo_mercancia_vendida__c)+','+
            '"disponibilidadNetaEmpresa": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(fami.Disponibilidad_neta_empresa__c)+','+
            '"ingresosVentas": '+IT_ConstruccionJSON_cls.validarDecimalReturnDecimal(fami.Ingresos_ventas__c)+','+   // ultimos ajustes de formulario digital
            '"codigoAsesor": null,'+ 
            '"empleosGenerar":"'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Empleos_a_generar__c)+'",'+ 
            '"ingresosAnuales":"'+IT_ConstruccionJSON_cls.validarNullDecimal(fami.Ingreso_Anual__c)+'",'+ 
            '"codigoFamiempresa": "'+IT_ConstruccionJSON_cls.validarNullString(fami.Identificador_Famiempresa__c)+'"'+
            '}';
        return jsonFami;
    }

    /******************************************************************************
    *Author:  Rafael Cardona
    *Function: Json de famiEmpresa cuando se debe enviar datos en nulos
    *Date: 3-3-2020
   ********************************************************************************/
    public static String sinFamiEmpresa(){
        String jsonFami = '';
        jsonFami += '"famiEmpresa": {'+
            '"actividadEconomica": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+ // fin actividadEconomica
            '"fechaCreacion": null,'+
            '"correoElectronico": null,'+
            '"direccion": {'+
            '"barrio": null,'+
            '"ciudad": {'+
            '"departamento": {'+
            '"codigo": null,'+
            '"nombre": null'+
            '},'+ // fin departamento
            '"codigo": null,'+
            '"nombre": null,'+ 
            '"zona": {'+
            '"codigo": 0,'+ 
            '"nombre": null'+ 
            '}'+  // fin zona
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
            '},'+  // fin sector
            '"telefono": null,'+
            '"tipoFormalización": null,'+
            '"balanceGeneral":{'+
            '"cuentasPorCobrarComerciales": null,'+
            '"inventarios": null,'+
            '"activosFijos": null,'+
            '"totalActivos": null,'+
            '"totalPasivos": null,'+
            '"totalCapitalTrabajo": null,'+   // ultimos ajustes de formulario digital
            '"totalActivosFijosYOtros": null,'+   // ultimos ajustes de formulario digital
            '"totalServiciosConocimiento": null'+   // ultimos ajustes de formulario digital
            '},'+ // fin balance general
            '"costoMercanciaVendida": null,'+
            '"disponibilidadNetaEmpresa": null,'+
            '"ingresosVentas": null,'+   // ultimos ajustes de formulario digital
            '"codigoAsesor": null,'+
            '"empleosGenerar":null,'+ 
            '"ingresosAnuales":null,'+ 
            '"codigoFamiempresa": null'+ 
            '}';
        return jsonFami;
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
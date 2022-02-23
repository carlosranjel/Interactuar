/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Alejandro Gómez
*  Fecha:               Junio 12 de 2019
*  Decripción:          Clase de prueba TestDatafactory para la creacion de datos
*  @version:            1.0
* ===================================================================================================================================
**/

@isTest
public class TestDataFactory {
    private static TestDataFactory instance = null;
    public Lead objLead;
    public Account objAccount;
    public Account objAccountJuridica;
    public User objUser;
    public Poblacion__c objPoblacion;
    public Zona__c objZona;
    public Barrio__c objBarrio;
    public Empleado__c objEmpleado;
    public Oficina__c objOficina;
    public Asociacion_barrio_empleado__c objAsociacionBarrioEmpleado;
    public Famiempresa__c objFamiempresa;
    public Actividad_economica__c objActividadEconomica;
    public Asset objAsset;
    public Product2 objProductConocimiento;
    public Product2 objProductCredito;
    Integer numeroAleatorioInt1 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
    Integer numeroAleatorioInt2 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
    String numeroAleatorioStr1 = String.valueOf(numeroAleatorioInt1); // 07-03-2020
    String numeroAleatorioStr2 = String.valueOf(numeroAleatorioInt2); // 07-03-2020

    // inicia la instancia de la clase
    public static TestDataFactory getInstance(){
        if(instance == null) { 
            instance = new TestDataFactory();  
        }
        return instance;
    }
    
    public List<sObject> createListObject(List<String> objListName){
        List<sObject> objs = new List<sObject>();
        for(String objName : objListName ){
            objs.add(createObject(objName));
        }
        return objs;        
    }
    
    public sObject createObject(String objName){
        if(objName.toUpperCase().equals('LEAD')) return (sObject) newLead();
        else if(objName.toUpperCase().equals('USER')) return (sObject) newUser();
        else if(objName.toUpperCase().equals('POBLACION__C')) return (sObject) newPoblacion();
        else if(objName.toUpperCase().equals('ZONA__C')) return (sObject) newZona();
        else if(objName.toUpperCase().equals('BARRIO__C')) return (sObject) newBarrio();
        else if(objName.toUpperCase().equals('EMPLEADO__C')) return (sObject) newEmpleado();
        else if(objName.toUpperCase().equals('OFICINA__C')) return (sObject) newOficina();
        else if(objName.toUpperCase().equals('ASOCIACION_BARRIO_EMPLEADO__C')) return (sObject) newAsociacionBarrioEmpleado();
        else if(objName.toUpperCase().equals('ACCOUNT')) return (sObject) newAccount();
        else if(objName.toUpperCase().equals('ACCOUNT')) return (sObject) newAccountJuridica();
        else if(objName.toUpperCase().equals('FAMIEMPRESA__C')) return (sObject) newFamiempresa();
        else if(objName.toUpperCase().equals('ACTIVIDAD_ECONOMICA__C')) return (sObject) newActividadEconomica();
        else if(objName.toUpperCase().equals('ASSET')) return (sObject) newAsset();
        else if(objName.toUpperCase().equals('PRODUCT2')) return (sObject) newProductConocimiento();
        else if(objName.toUpperCase().equals('PRODUCT2')) return (sObject) newProductCredito(); 
        
        return null;    
    }
    
    public Asset newAsset(){
        if( objAsset == null ){
            objAsset = new Asset(
                Name = 'Activo de prueba',
                RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId(),
                Numero_de_credito__c = '98989898',
                Monto_desembolsado__c = 9898898,
                Fecha_desembolso__c	= (System.Today()).addDays(-5),
                Plazo__c = 12,
                Quantity = 1,
                Product2Id = newProductCredito().Id,
                AccountId = newAccount().Id,
                Identificador_Radicado__c = '7878787',
                Calificacion__c = 'CREDITO NORMAL',
                Status = 'Activo'
            );
            insert objAsset;
        }
        return objAsset;
    }
    
    public Actividad_economica__c newActividadEconomica(){
        if( objActividadEconomica == null ){
            objActividadEconomica = new Actividad_economica__c(
                Name = 'Cría de ganado porcino2', 
                Codigo_Industria_OR_SF__c='4',
                Industria__c='Agropecuario',
                Codigo_Sector_OR__c='12',
                Codigo_Sector_SF__c='40012',
                Sector__c='Productores pecuarios',
                Codigo_Actividad_Economica_OR__c='2',
                Codigo_Actividad_Economica_SF__c='400120099'
            );
            insert objActividadEconomica;
        }
        return objActividadEconomica;
    }
    
    
    public Famiempresa__c newFamiempresa(){
        if( objFamiempresa == null ){
            objFamiempresa = new Famiempresa__c(
                Name = 'Famiempresa Test',
                Fecha_de_creacion_de_empresa__c = System.Today(),
                Actividad_economica__c=newActividadEconomica().Id,
                Numero_de_identificacion__c=numeroAleatorioStr1, // 07-03-2020
                Movil_empresa__c='3165698732',
                Ciudad_empresa__c=newPoblacion().Id,
                Zona_empresa__c=newZona().Id,
                Barrio_empresa__c=newBarrio().Id,
                Prospecto_relacionado__c=newLead().Id,
                Numero_de_empleados__c = 4
            );
            insert objFamiempresa;
        }
        return objFamiempresa;
    }
    
    public Asociacion_barrio_empleado__c newAsociacionBarrioEmpleado(){
        if( objAsociacionBarrioEmpleado == null ){
            objAsociacionBarrioEmpleado = new Asociacion_barrio_empleado__c(
                Empleado__c=newEmpleado().Id,
                Barrio__c=newBarrio().Id
            );
            insert objAsociacionBarrioEmpleado;
        }
        return objAsociacionBarrioEmpleado;
    }
    
    public Oficina__c newOficina(){
        if( objOficina == null ){
            objOficina = new oficina__c(
                Name = 'Oficina de prueba',
                Codigo_Oficina_OR__c = 'X9',
                Vigente__c = true
            );
            insert objOficina;
        }
        return objOficina;
    }
    
    public Empleado__c newEmpleado(){
        if( objEmpleado == null ){
            objEmpleado = new Empleado__c(
                Name='Nombre de empleado',
                Correo_electronico__c='mgom@mgom.com',
                Codigo_de_Empleado__c='12345',
                Oficina_Empleado__c=newOficina().Id,
                Ciudad__c=newPoblacion().Id
            );
            insert objEmpleado;
        }
        return objEmpleado;
    }
    
    public Poblacion__c newPoblacion(){
        if( objPoblacion == null ){
            objPoblacion = new Poblacion__c(
                Name='Abejorral',
                Vigente__c=true
            );
            insert objPoblacion;
        }
        return objPoblacion;
    }
    
    public Zona__c newZona(){
        if( objZona == null ){
            objZona = new Zona__c(
                Name='Zona25',
                Vigente__c=true,
                Ciudad__c=newPoblacion().Id
            );
            insert objZona;
        }
        return objZona;
    }
    
    public Barrio__c newBarrio(){
        if( objBarrio == null ){
            objBarrio = new Barrio__c(
                Name='Penjamo',
                Zona__c=newZona().Id,
                Vigente__c=true
            );
            insert objBarrio;
        }
        return objBarrio;
    }
    
    public User newUser(){
        if( objUser == null ){
            objUser = new User(
                Alias=String.valueOf(Date.today()).remove(' ').remove(':').remove('-'),
                Email='tigo.test@vass.com',
                LastName='Gomez',
                FirstName='Alejandro', 
                CommunityNickname=String.valueOf(DateTime.now().getTime()).remove(' ').remove(':'),
                Username = String.valueOf(DateTime.now().getTime()).remove(' ').remove(':')+ '@tigo.com.test',
                Phone='3165698732',
                TimeZoneSidKey='America/Bogota',
                LocaleSidKey='es_CO',
                EmailEncodingKey='ISO-8859-1',
                LanguageLocaleKey='es',
                ProfileId=UserInfo.getProfileId()
            );
            insert objUser;
        }
        return objUser; 
    }
    
    public Lead newLead(){        
        if( objLead == null){
            objLead = new Lead (
                Status='Asignado',
                Tipo_de_identificacion__c='Cedula de Ciudadania',
                Numero_de_identificacion__c=numeroAleatorioStr1,  // 07-03-2020
                FirstName='Nombre de prospecto',
                LastName='Apellido de prospecto',
                Email='mgomezre2006@fmail.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True, // 07-03-2020
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural', // 07-03-2020
                Ciudad_empresa__c=newPoblacion().Id, // 07-03-2020
                Zona_empresa__c=newZona().Id, // 07-03-2020
                Barrio_empresa__c=newBarrio().Id, // 07-03-2020
                Autorizacion_uso_de_datos__c = 'Autoriza',
                Medio_de_autorizacion__c = 'Solicitud de vinculacion',
                Interes__c='Capacitación',
                Movil_empresa__c = '3165698732',
                Estrato_empresa__c='Dos',
                Tiene_empresa__c = true,
                Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
                Correo_electronico_asesor_asignado__c='mgmg@mgmgmg.com',
                OwnerId = newUser().Id,
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
            );
            insert objLead;
        }
        return objLead;
    }
    
    public Account newAccount(){        
        if( objAccount == null){
            objAccount = new Account (
                Tipo_de_identificacion__c='Cedula de Ciudadania',
                Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
                FirstName='Nombre de cliente',
                LastName='Apellido de cliente',
                Correo_electronico_empresa__c='clientest@clientest.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True,
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
                Asesor_asignado__c = newEmpleado().Id,
                Ciudad_empresa__c=newPoblacion().Id,
                Zona_empresa__c=newZona().Id,
                Barrio_empresa__c=newBarrio().Id,
                Autorizacion_uso_de_datos__c = 'Autoriza',
                Medio_de_autorizacion__c = 'Solicitud de vinculacion',
                Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
                OwnerId = newUser().Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
            );
            insert objAccount;
        }
        return objAccount;
    }  
    
    public Account newAccountJuridica(){        
        if( objAccountJuridica == null){
            objAccountJuridica = new Account (
                Tipo_de_identificacion__c='Nit',
                Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
                Name='Nombre del cliente',
                Correo_electronico_empresa__c='clientest@clientest.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True,
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
                Asesor_asignado__c = newEmpleado().Id,
                Ciudad_empresa__c=newPoblacion().Id,
                Zona_empresa__c=newZona().Id,
                Barrio_empresa__c=newBarrio().Id,
                Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
                OwnerId = newUser().Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_juridica').getRecordTypeId()
            );
            insert objAccountJuridica;
        }
        return objAccountJuridica;
    } 
    
    public Product2 newProductConocimiento(){       
        if( objProductConocimiento == null){            
            objProductConocimiento = new Product2 (
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId(),
                Identificador_portafolio__c='2811',
                ProductCode='C.281-1',
                Family='Conocimiento y Redes',
                Clasificacion__c='Productividad y Calidad',
                Name='TALLERES EMPRESARIALES  PRODUCTIVIDAD Y CALIDAD (GRATIS)',
                isActive = true,
                Programa__c = 'ADMINISTRACION DE MICROEMPRESA E INFORMATICA',
                Grupo_convenio_nombre__c = 'PILOTO PREMIUM',
                Tipo_de_servicio__c = 'Capacitacion',
                Horas_grupales__c =  2,
                Horas_individuales__c = 1,
                Grupo_convenio__c =  493,
                Grupo_valor__c = 1,
                Cupo_maximo__c = 10,
                Cupo_minimo__c = 1,
                Precio__c = 5000,
                Identificador_grupo__c = 14,
                Precio_sin_IVA__c = false,
                Requiere_pago__c = false,
                Fecha_inicio__c = null,
                Fecha_fin__c = null,
                Codigo_Oficina_OR__c = null,
                Codigo_Sede_OR__c = null,
                Hora_inicio__c = null,
                Hora_fin__c = null,
                Monto_maximo__c = 10,
                Monto_minimo__c = 1,
                Dias_de_la_semana__c = 'V',
                Tasa_nominal_anual_mes_vencido__c = 2,
                Oficina__c = null,
                Sede__c = null
            );
            insert objProductConocimiento;
        }
        return objProductConocimiento;
    } 
    
    public Product2 newProductCredito(){       
        if( objProductCredito == null){            
            objProductCredito = new Product2 (
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId(),
                Identificador_portafolio__c='1109',
                ProductCode='501',
                Family='Crédito',
                Clasificacion__c='',
                Name='COMERCIAL',
                isActive = true,
                Programa__c = '',
                Grupo_convenio_nombre__c = '',
                Tipo_de_servicio__c = '',
                Horas_grupales__c =  null,
                Horas_individuales__c = null,
                Grupo_convenio__c =  null,
                Grupo_valor__c = null,
                Cupo_maximo__c = null,
                Cupo_minimo__c = null,
                Precio__c = null,
                Identificador_grupo__c = null,
                Precio_sin_IVA__c = false,
                Requiere_pago__c = false,
                Fecha_inicio__c = null,
                Fecha_fin__c = null,
                Codigo_Oficina_OR__c = null,
                Codigo_Sede_OR__c = null,
                Hora_inicio__c = null,
                Hora_fin__c = null,
                Dias_de_la_semana__c = '',
                Tasa_nominal_anual_mes_vencido__c = 2,
                Oficina__c = null,
                Sede__c = null,
                Monto_minimo__c = 99999999,
                Monto_maximo__c = 1000000
            );
            insert objProductCredito;
        }
        return objProductCredito;
    } 
}
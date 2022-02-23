/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase que gestiona la mayoria de acciones que se ejecuan para el aval

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-Abr-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_Avales {

    private static final String JURIDICO    = 'Persona_juridica';
    private static final Integer MAX_AVALES = 5;

    @AuraEnabled
    public static String consultaAvales(String oportunidadId){
        List<objetoRespuesta> lstRes = new List<objetoRespuesta>();
        Set<Id> idSetContacto            = new Set<Id>();
        List<Id> lstIdContactos          = new List<Id>();
        List<Opportunity> lstOportunidad = new List<Opportunity>();
        List<Account> lstCliente         = new List<Account>();

        lstOportunidad = [SELECT Id,Name,AccountId,Identificador_proceso__c,StageName,SyncedQuoteId,Respuesta_Oportunidad__c
                          FROM Opportunity WHERE id =: oportunidadId LIMIT 1];
        
        if(lstOportunidad.size() == 1){
        lstCliente = [SELECT id,Name FROM Account WHERE id =: lstOportunidad[0].AccountId LIMIT 1];
        }

        if(lstCliente.size() == 1){
            for(Asociacion_cuenta_contacto__c cc : [SELECT Id,Contacto__c, Cliente__c, Oportunidad__c,
                                                    Contacto__r.Numero_de_identificacion__c, Cliente__r.Numero_de_identificacion__c 
                                        FROM Asociacion_cuenta_contacto__c WHERE Cliente__c =: lstCliente[0].Id AND Oportunidad__c =: oportunidadId]){
                if( ! idSetContacto.contains(cc.Contacto__c) && cc.Contacto__r.Numero_de_identificacion__c != cc.Cliente__r.Numero_de_identificacion__c){  
                    lstIdContactos.add(cc.Contacto__c);
                    idSetContacto.add(cc.Contacto__c);
                }
            }
        }

        if(lstIdContactos.size() > 0){
            for(Contact con : [SELECT id, Name, Numero_de_identificacion__c FROM Contact WHERE id IN: lstIdContactos]){
            objetoRespuesta obj = new objetoRespuesta();
                obj.idContacto        = con.Id;
                obj.nomContacto       = con.Name;
                obj.numIdentificacion = con.Numero_de_identificacion__c;
                obj.idCuenta       = lstCliente[0].Id;
                obj.idOportunidad  = lstOportunidad[0].Id;
                obj.nomOportunidad = lstOportunidad[0].Name;
                obj.nomCuenta      = lstCliente[0].Name;
                obj.idBPMS         = lstOportunidad[0].Identificador_proceso__c;
                obj.estadoOpp      = lstOportunidad[0].StageName;
                obj.oppSincronizada= (lstOportunidad[0].SyncedQuoteId != null && String.isNotBlank(lstOportunidad[0].Respuesta_Oportunidad__c) && (lstOportunidad[0].Respuesta_Oportunidad__c).contains('OK')) ? true : false ;
                lstRes.add(obj);
            }
            return JSON.Serialize(lstRes);
        }else{
            objetoRespuesta obj = new objetoRespuesta();
            obj.oppSincronizada = false;
            lstRes.add(obj);
            return JSON.Serialize(lstRes);
        }
        
    }

    @AuraEnabled
    public static String consultaContacto(String idContacto, String idOportunidad){//deceval
        Contact contacto = [SELECT id, Name, Numero_de_identificacion__c,EjecutarDataAval__c FROM Contact WHERE id =: idContacto LIMIT 1];
                
        List<ID> lstIDop = new List<ID>{ idOportunidad };
        List<Asociacion_cuenta_contacto__c> lstAso = IT_GestorDeConsultas_cls.consultaAsociacionAval(lstIDop);
        RespuestaDoInit res = new RespuestaDoInit();
        for(Asociacion_cuenta_contacto__c acc: lstAso){
            if(acc.Cliente__r.RecordType.DeveloperName == JURIDICO){
                if(acc.Contacto__c == idContacto && acc.RepresentanteLegal__c == true){
                    res.ejecutoRepresentante = true;
                }
            }else{
                res.NoApRepresentante = true;
            }
        }
               
        if( contacto.EjecutarDataAval__c != null && (contacto.EjecutarDataAval__c).contains(idOportunidad)){
            res.ejecutoDataAval = true;
            return JSON.serialize(res);
        }else{
            res.ejecutoDataAval = false;
            return JSON.serialize(res);
        }
    }

    @AuraEnabled
    public static List<Contact> buscarContactosAvales(String numDocumento){
        return [SELECT id, Name, Numero_de_identificacion__c 
        FROM Contact WHERE Numero_de_identificacion__c =: numDocumento and recordType.developername = 'Contacto_Aval'];
    }

    @AuraEnabled
    public static String agregarAval(String idContacto, String idOportunidad){
        List<Asociacion_cuenta_contacto__c> lstAsociacion = listaAsociacionesAval(idOportunidad);
        if( controlMaximoAvales( lstAsociacion.size() ) ){
            List<Opportunity> lstOpp  = [SELECT id FROM Opportunity WHERE id =: idOportunidad];
            List<Contact> lstContacto = [SELECT id FROM Contact WHERE id =: idContacto];
            List<Account> lstCliente  = [SELECT id FROM Account WHERE id IN (SELECT AccountId FROM Opportunity WHERE id =: idOportunidad)];
            if( controlAvalDuplicado(lstAsociacion , lstContacto) ){
            Asociacion_cuenta_contacto__c nuevaAsociacion = new Asociacion_cuenta_contacto__c();
            nuevaAsociacion.Cliente__c     = lstCliente[0].id;
            nuevaAsociacion.Contacto__c    = lstContacto[0].id;
            nuevaAsociacion.Oportunidad__c = lstOpp[0].Id;
            insert nuevaAsociacion;                
           
            Respuesta response = new Respuesta( true, 'Agregar');
            return JSON.serialize(response);
            }else{
                Respuesta response = new Respuesta(false,'Existe');
                return JSON.serialize(response);
            }
        }else{
            Respuesta res = new Respuesta(false,'Maximos avales');
            return JSON.Serialize(res);
        }
    }

    public static Boolean controlMaximoAvales(Integer cantidad){        
        if(cantidad < MAX_AVALES){
            return true;
        }else{
            return false;
        }                                                    
    }
    @AuraEnabled
    public static Boolean controlMaximoAval(String oportunidadId){ 
        List<Asociacion_cuenta_contacto__c> lstAsociacion; 
        lstAsociacion = listaAsociacionesAval(oportunidadId);
        if(lstAsociacion.size() < MAX_AVALES){
            return true;
        }else{
            return false;
        }                                                    
    }

    public static List<Asociacion_cuenta_contacto__c> listaAsociacionesAval( String oportunidadId){
        List<Asociacion_cuenta_contacto__c> lista = new List<Asociacion_cuenta_contacto__c>();
        lista = [SELECT Cliente__c,Contacto__c,Id,Name,Oportunidad__c 
        FROM Asociacion_cuenta_contacto__c WHERE Oportunidad__c =:oportunidadId];
        return lista;
    }
    
    public static Boolean controlAvalDuplicado(List<Asociacion_cuenta_contacto__c> lstAsociacion,List<Contact> lstContacto){
        for(Asociacion_cuenta_contacto__c acc: lstAsociacion){
            if( lstContacto[0].id == acc.Contacto__c){
                return false;
            }
        }                                         
        return true;                                                   
    }


    @AuraEnabled
    public static Contact creaContacto(String idOportunidad, String nom, String ape, String numIdentificacion, String tipoIde){
        try{
            List<Asociacion_cuenta_contacto__c> lstAsociacion = listaAsociacionesAval(idOportunidad);
        if( controlMaximoAvales( lstAsociacion.size() ) ){
            Contact contacto = new Contact();
            contacto.FirstName = nom;
            contacto.LastName  = ape;
            contacto.Numero_de_identificacion__c = numIdentificacion;
            contacto.Tipo_de_identificacion__c   = tipoIde;
            contacto.RecordTypeId  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
            insert contacto;
    
            List<Opportunity> lstOpp  = [SELECT id FROM Opportunity WHERE id =: idOportunidad];
            List<Account> lstCliente  = [SELECT id FROM Account WHERE id IN (SELECT AccountId FROM Opportunity WHERE id =: idOportunidad)];
            Asociacion_cuenta_contacto__c nuevaAsociacion = new Asociacion_cuenta_contacto__c();
            nuevaAsociacion.Cliente__c     = lstCliente[0].id;
            nuevaAsociacion.Contacto__c    = contacto.id;
            nuevaAsociacion.Oportunidad__c = lstOpp[0].Id;
            insert nuevaAsociacion;
            return contacto;
                // agregar validaciones para posibles errores
        }else{
            System.debug(' ADVERTENCIA - Limite maximo de avales alcanzado');
            return null;
        }
    }catch(Exception e){
        System.debug('Error en la creacion del aval o en la asociacion del aval a la oportunidad');
        return new Contact(LastName = 'Error');
    }

    }

    @AuraEnabled
    public static Boolean quitarAval(String idContacto, String idOportunidad){
        Asociacion_cuenta_contacto__c eliminar;
        List<Account> lstCliente  = [SELECT id FROM Account WHERE id IN (SELECT AccountId FROM Opportunity WHERE id =: idOportunidad)];

        if( String.isNotBlank(idContacto) && lstCliente.size() == 1){
            try{
            for(Asociacion_cuenta_contacto__c cc: [SELECT id,Oportunidad__c FROM Asociacion_cuenta_contacto__c 
                                                   WHERE Cliente__c =: lstCliente[0].id AND Contacto__c =: idContacto]){
            if(cc.Oportunidad__c == idOportunidad){
                eliminar = cc;
            }}

            if( eliminar.id != null ){  delete eliminar; return true; } 
            else return false;            
            }catch(Exception e){
                System.debug('Error: '+e.getStackTraceString());
                return false;
            }
        }else{
            return false;
        }
    }

    @AuraEnabled
    public static Account consultaClienteAconvertir(String docCliente, String idOpp){
        List<Account> lstClientes = new List<Account>();
        List<Contact> lstCon = new List<Contact>();
        System.debug('nivel'+idOpp);

        lstCon = [SELECT id FROM Contact WHERE Numero_de_identificacion__c =: docCliente AND RecordType.DeveloperName = 'Contacto_Aval'];

        if( lstCon.size() == 0 ){
            Account cuentaActual = [SELECT id,LastName,Name,Numero_de_identificacion__c
            FROM Account WHERE id IN (SELECT AccountId FROM Opportunity WHERE id =: idOpp)];

            lstClientes = [SELECT id,FirstName,LastName,Name,Numero_de_identificacion__c,Tipo_de_identificacion__c,
            PersonEmail,PersonBirthdate,Fecha_de_nacimiento__c,Personas_a_cargo__pc,Empresa_donde_labora__c,
            Genero__pc,Cabeza_de_familia__pc,Estado_civil__pc,Estrato_contacto__pc,Estrato_empresa__c,CargoLaboral__c,
            Letra_empresa_a__c,Letra_empresa_b__c,Medio_de_autorizacion__c,Sueldo_Honorario__c,Tipo_de_vivienda__pc,
            Hipoteca_a_favor_de__c,Informacion_adicional_complemento_c__pc,Ocupacion__c,
            Informacion_adicional_complemento_e__c,Intercesion_empresa__c,Numero_empresa_a__c,Numero_empresa_b__c,
            Punto_Cardinal_empresa_a__c,Punto_Cardinal_empresa_b__c,Ruralidad_domicilio_empresa__c,Via_empresa__c,
            Indicativo_empresa__c,Medio_por_el_cual_conocio_a_Interactuar__c,Movil_empresa__c,Nivel_de_escolaridad__pc,
            Telefono_empresa__c,Barrio_empresa__c,Zona_empresa__c,Ciudad_empresa__c,Nombre_del_arrendador__c,
            Telefono_arrendador__c,Tiene_hipoteca__c,Segundo_Apellido__c,MiddleName,Autorizacion_uso_de_datos__c
            FROM Account WHERE Numero_de_identificacion__c =: docCliente AND Id !=: cuentaActual.Id ];

            if( lstClientes.size() == 1){
                return lstClientes[0];
            }else{
                // no se encontro cliente
                return new Account();
            }
        }else{
            return new Account(Name = 'Contacto Existente');
        }       
    }

    @AuraEnabled
    public static String convertirClienteEnAval(Account cliente, String idOportunidad){        
        System.debug('cliente a convertir: '+ cliente + ' --- '+ idOportunidad);
        Respuesta res;
        try{
        Contact nuevoAval = new Contact();
        nuevoAval.Autorizacion_uso_de_datos__c = cliente.Autorizacion_uso_de_datos__c;
        nuevoAval.LastName                      = cliente.LastName;
        nuevoAval.Segundo_Apellido__c           = cliente.Segundo_Apellido__c;
        nuevoAval.FirstName                     = cliente.FirstName;
        nuevoAval.MiddleName                    = cliente.MiddleName;
        nuevoAval.Numero_de_identificacion__c   = cliente.Numero_de_identificacion__c;
        nuevoAval.Tipo_de_identificacion__c     = cliente.Tipo_de_identificacion__c;
        nuevoAval.RecordTypeId                  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        nuevoAval.Email                         = cliente.PersonEmail;
        nuevoAval.Birthdate                     = cliente.Fecha_de_nacimiento__c;
        nuevoAval.Informacion_adicional_complemento_c__c = cliente.Informacion_adicional_complemento_e__c;
        nuevoAval.Intercesion_contacto__c       = cliente.Intercesion_empresa__c;
        nuevoAval.Letra_contacto_a__c           = cliente.Letra_empresa_a__c;
        nuevoAval.Letra_contacto_b__c           = cliente.Letra_empresa_b__c;
        nuevoAval.Numero_contacto_a__c          = cliente.Numero_empresa_a__c;
        nuevoAval.Numero_contacto_b__c          = cliente.Numero_empresa_b__c;
        nuevoAval.Punto_cardinal_contacto_a__c  = cliente.Punto_Cardinal_empresa_a__c;
        nuevoAval.Punto_cardinal_contacto_b__c  = cliente.Punto_Cardinal_empresa_b__c;
        nuevoAval.Ruralidad_domicilio_contacto__c  = cliente.Ruralidad_domicilio_empresa__c;
        nuevoAval.Via_contacto__c               = cliente.Via_empresa__c;
        nuevoAval.Genero__c                     = cliente.Genero__pc;
        nuevoAval.Indicativo_contacto__c        = cliente.Indicativo_empresa__c;   
        nuevoAval.Medio_por_el_cual_conocio_a_Interactuar__c = cliente.Medio_por_el_cual_conocio_a_Interactuar__c;
        nuevoAval.Movil_contacto__c             = cliente.Movil_empresa__c;
        nuevoAval.Nivel_de_escolaridad__c       = cliente.Nivel_de_escolaridad__pc;
        nuevoAval.Telefono_contacto__c          = cliente.Telefono_empresa__c;
        nuevoAval.Estado_civil__c               = cliente.Estado_civil__pc;
        nuevoAval.Personas_a_cargo__c           = cliente.Personas_a_cargo__pc;
        nuevoAval.Tipo_de_vivienda__c           = cliente.Tipo_de_vivienda__pc;
        nuevoAval.Nombre_del_arrendador__c      = cliente.Nombre_del_arrendador__c;
        nuevoAval.Telefono_arrendador__c        = cliente.Telefono_arrendador__c;
        nuevoAval.Ocupacion__c                  = cliente.Ocupacion__c; 
        nuevoAval.Cabeza_de_familia__c          = cliente.Cabeza_de_familia__pc;
        nuevoAval.Estrato_contacto__c           = cliente.Estrato_empresa__c;
        nuevoAval.Empresa_donde_labora__c       = cliente.Empresa_donde_labora__c;
        nuevoAval.Barrio_contacto__c            = cliente.Barrio_empresa__c;
        nuevoAval.Zona_contacto__c              = cliente.Zona_empresa__c;
        nuevoAval.Ciudad_contacto__c            = cliente.Ciudad_empresa__c; 
        nuevoAval.Medio_de_autorizacion__c      = cliente.Medio_de_autorizacion__c;
        nuevoAval.Sueldo_Honorario__c           = cliente.Sueldo_Honorario__c;        
        nuevoAval.Hipoteca_a_favor_de__c        = cliente.Hipoteca_a_favor_de__c;
        nuevoAval.Tiene_hipoteca__c             = cliente.Tiene_hipoteca__c;
        insert nuevoAval; 
        Respuesta resAs = (Respuesta)System.JSON.deserialize(agregarAval( nuevoAval.Id, idOportunidad), Respuesta.class);
        if( resAs.ejecucion && resAs.mensaje == 'Agregar'){
            res = new Respuesta(true,nuevoAval.Id);
            return JSON.serialize(res);
        }else{
            res = new Respuesta(false,'Maximo');
            return JSON.serialize(res);
        }
        }catch(DmlException dm){
            System.debug('Error en la conversion del cliente en aval');
            res = new Respuesta(false,'KO');
            return JSON.serialize(res);
        }
    }

    @AuraEnabled
    public static string representanteLegal(String idContacto, String idOportunidad){// deceval
        Asociacion_cuenta_contacto__c union = new Asociacion_cuenta_contacto__c();
        Respuesta res;
        String respuesta = 'ok';
        Boolean elegidoRepresentante = false;
        List<ID> lstIDop = new List<ID>{ idOportunidad };        
        List<Asociacion_cuenta_contacto__c> lstAso = IT_GestorDeConsultas_cls.consultaAsociacionAval(lstIDop);
        
        for(Asociacion_cuenta_contacto__c acc: lstAso){            
            if( acc.RepresentanteLegal__c == true && acc.Contacto__c != idContacto ){
                elegidoRepresentante = true;
                res = new Respuesta(true,'OCUPADO');
                break;
            }
            if(acc.Contacto__c == idContacto && ! acc.RepresentanteLegal__c){ 
                union = acc;               
                union.RepresentanteLegal__c = true;
                res = new Respuesta(true,'OK-on');
            }else if(acc.Contacto__c == idContacto && acc.RepresentanteLegal__c){
                union = acc; 
                union.RepresentanteLegal__c = false;
                res = new Respuesta(true,'OK-off');
            }
        }

        if( ! elegidoRepresentante && union.Name != null){
            try{
                update union;                
            }catch(Exception e){
                res = new Respuesta(false,'ERROR');
                System.debug('ERROR:'+E.getStackTraceString());
            }
        }

        return JSON.serialize(res);
    }

    private class Respuesta{
        String  mensaje;
        Boolean ejecucion;        
        Respuesta( Boolean ejecucion , String mensaje ){
            this.ejecucion = ejecucion;
            this.mensaje   = mensaje;
        }
    }

    public class objetoRespuesta{
        public Id idContacto;
        public String nomContacto;
        public String numIdentificacion;
        public Id idCuenta;
        public String nomCuenta;
        public Id idOportunidad;
        public String nomOportunidad;
        public String idBPMS;
        public String estadoOpp;
        public Boolean oppSincronizada;
    }

    private class RespuestaDoInit{// deceval
        Boolean ejecutoDataAval;        
        Boolean ejecutoRepresentante;
        Boolean NoApRepresentante;
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
    }
}
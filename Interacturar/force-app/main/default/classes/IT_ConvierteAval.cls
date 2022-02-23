/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase donde se mapean los campos del aval para convertir en cliente

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-ABR-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public with sharing class IT_ConvierteAval {
    public IT_ConvierteAval() {    }

    @AuraEnabled
    public static string convertirAvalEnCliente(String idAval){
        System.debug('aval a convertir '+ idAval);
        ID[] ids = new ID[]{idAval};
        List<Contact> lstContacto = IT_GestorDeConsultas_cls.consultaContacto(ids);
        System.debug('aval a -convertir- '+ lstContacto);        
        return insertaCliente(lstContacto[0]);
    }

    public static String insertaCliente(Contact aval){
        Respuesta res;
        try{
        Account cliente = new Account();
        cliente.LastName                        = aval.LastName;
        cliente.FirstName                       = aval.FirstName;        
        cliente.Numero_de_identificacion__c     = aval.Numero_de_identificacion__c;
        cliente.Tipo_de_identificacion__c       = aval.Tipo_de_identificacion__c;
        cliente.RecordTypeId                    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId();
        cliente.PersonEmail                     = aval.Email;
        cliente.Fecha_de_nacimiento__c          = aval.Birthdate;
        cliente.PersonBirthdate                 = aval.Birthdate;        
        cliente.Personas_a_cargo__pc            = aval.Personas_a_cargo__c;        
        cliente.Empresa_donde_labora__c         = aval.Empresa_donde_labora__c;        
        cliente.Estado_civil__pc                = aval.Estado_civil__c;        
        cliente.Ocupacion__c                    = aval.Ocupacion__c;        
        cliente.Genero__pc                      = aval.Genero__c;        
        cliente.Cabeza_de_familia__pc           = aval.Cabeza_de_familia__c;
        cliente.Barrio_empresa__c               = aval.Barrio_contacto__c;
        cliente.Zona_empresa__c                 = aval.Zona_contacto__c;
        cliente.Ciudad_empresa__c               = aval.Ciudad_contacto__c;
        cliente.Via_empresa__c                  = aval.Via_contacto__c;        
        cliente.Estrato_empresa__c              = aval.Estrato_contacto__c;
        cliente.Indicativo_empresa__c           = aval.Indicativo_contacto__c;
        cliente.Intercesion_empresa__c          = aval.Intercesion_contacto__c;
        cliente.Letra_empresa_a__c              = aval.Letra_contacto_a__c;
        cliente.Letra_empresa_b__c              = aval.Letra_contacto_b__c;        
        cliente.Movil_empresa__c                = aval.Movil_contacto__c;
        cliente.Numero_empresa_a__c             = aval.Numero_contacto_a__c;
        cliente.Numero_empresa_b__c             = aval.Numero_contacto_b__c;
        cliente.Punto_Cardinal_empresa_a__c     = aval.Punto_cardinal_contacto_a__c;
        cliente.Punto_Cardinal_empresa_b__c     = aval.Punto_cardinal_contacto_b__c;
        cliente.Telefono_empresa__c             = aval.Telefono_contacto__c;
        cliente.Medio_de_autorizacion__c        = aval.Medio_de_autorizacion__c;        
        cliente.Sueldo_Honorario__c             = aval.Sueldo_Honorario__c;        
        cliente.Tipo_de_vivienda__pc            = aval.Tipo_de_vivienda__c;        
        cliente.Hipoteca_a_favor_de__c          = aval.Hipoteca_a_favor_de__c;
        cliente.Ruralidad_domicilio_empresa__c  = aval.Ruralidad_domicilio_contacto__c;
        cliente.Informacion_adicional_complemento_e__c = aval.Informacion_adicional_complemento_c__c;
        insert cliente;
        res = new Respuesta(true,'OK',cliente.Id);
        return JSON.serialize(res);
        }catch(Exception e){
            System.debug('Error en creacion de cliente: '+ e.getStackTraceString());
            res = new Respuesta(true, e.getStackTraceString(), '');
            return JSON.serialize(res);
        }
    }

    private class Respuesta{
        String idCliente;
        String  mensaje;
        Boolean ejecucion;        
        Respuesta( Boolean ejecucion , String mensaje ,String idCliente){
            this.ejecucion = ejecucion;
            this.mensaje   = mensaje;
            this.idCliente = idCliente;
        }
    }
}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase controladora para el componente aura de cobranza

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-Abr-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_Cobranza_ctr {
    public IT_Cobranza_ctr() {    }

    private static Map<String,List<CustomSelectOptions>> mapPickList;
    private static List<CustomSelectOptions> lstEstado;
    private static List<CustomSelectOptions> lstPrioridad;
    private static List<CustomSelectOptions> lstTipoDeGestion;
    private static List<CustomSelectOptions> lstTipoDeContacto;
    private static List<CustomSelectOptions> lstAsunto;

    @AuraEnabled
    public static Map<String,List<CustomSelectOptions>> getAllPickList(){
        mapPickList = new Map<String,List<CustomSelectOptions>>();
        lstEstado         = getPickList('Task','Status');
        lstPrioridad      = getPickList('Task','Priority');
        lstTipoDeGestion  = getPickList('Task','Tipo_de_gestion__c');
        lstTipoDeContacto = getPickList('Task','Tipo_de_contacto__c');
        lstAsunto         = getPickList('Task','Subject');

        mapPickList.put('estado',lstEstado);
        mapPickList.put('prioridad',lstPrioridad);
        mapPickList.put('tGestion',lstTipoDeGestion);
        mapPickList.put('tContacto',lstTipoDeContacto);
        mapPickList.put('asunto',lstAsunto);
        return mapPickList;
    }

    public static List<CustomSelectOptions> getPickList(String objectName, String fieldName){
        List<CustomSelectOptions> pickListValuesList = new List<CustomSelectOptions>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
        System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
        pickListValuesList.add(new CustomSelectOptions(pickListVal.getLabel(),pickListVal.getValue()));
        } 
        return pickListValuesList;
    }

    @AuraEnabled
    public static string gestionDeCobranza(Empleado__c empleado,String idActivo,String estado,String prioridad,String tgestion,String tcontacto,
           String asunto,Boolean cgestionado,Date fVencimiento,Date fAcuerdo,Decimal pago,String descripcion){
    try{
        Asset activo = [select id,Account.Asesor_asignado__c,Account.Asesor_asignado__r.Codigo_de_Empleado__c,Status from Asset where id =: idActivo];
        if(activo.Status != 'Vencido'){
            Respuesta response = new Respuesta(null,'EtapaIncorrecta',false);
            return JSON.serialize(response);
        }
        System.debug(empleado);
        Task tarea = new Task();
        tarea.recordTypeId             = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Gestion_de_Cobranza').getRecordTypeId();
        tarea.WhatId                   = activo.id;
        tarea.Asignado_a__c            = empleado.Id;
        tarea.OwnerId                  = userInfo.getUserId();
        tarea.Status                   = estado;
        tarea.Priority                 = prioridad;        
        tarea.Tipo_de_gestion__c       = tgestion;
        tarea.Tipo_de_contacto__c      = tcontacto;
        tarea.Subject                  = asunto;
        tarea.Gestion_efectiva__c      = cgestionado;
        tarea.ActivityDate             = fVencimiento;
        tarea.Fecha_acuerdo_de_pago__c = fAcuerdo;
        tarea.Pago_minimo__c           = pago;  
        descripcion = descripcion.replace('<p>','');
        descripcion = descripcion.replace('</p>','');
        tarea.Description              = descripcion.trim();        
        insert tarea;
        Respuesta response = new Respuesta(tarea,'Se inserto Exitosamente',true);
        return JSON.serialize(response);
    }catch(Exception e){
        System.debug('Fallo en el proceso:'+e.getStackTraceString());
        Respuesta response = new Respuesta(null,'Fallo en el proceso',false);
        return JSON.serialize(response);
    }        
    }

    public class CustomSelectOptions{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}    
        public CustomSelectOptions(String lab, String val) {
            this.label = lab;
            this.value = val;
        }
    }

    public class Respuesta{
        public Task tarea {get;set;}
        public String mensaje {get;set;}
        public Boolean proceso {get;set;}
        public Respuesta(Task tarea, String men, Boolean pro){
            this.tarea   = tarea;
            this.mensaje = men;
            this.proceso = pro;
        }
    }
    public class RespuestaListado{
        public String mensaje {get;set;}
        public Boolean proceso {get;set;}
        public List<Task> lstTareas {get;set;}
        public RespuestaListado(List<Task> lstTareas, String men, Boolean pro){
            this.lstTareas = lstTareas;
            this.mensaje   = men;
            this.proceso   = pro;
        }
    }

    @AuraEnabled
    public static List <sObject> lookupEmpleado(String searchKeyWord, String ObjectName){
        List < sObject > returnList = new List < sObject > ();
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';     
        String sQuery =  'SELECT id, Name FROM ' +ObjectName + ' WHERE Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static String buscaGestionesCobranza(String idActivo){
        List<Task> lstTareas = [SELECT CreatedDate,CreatedBy.Name,Description,Fecha_acuerdo_de_pago__c,Fecha_llamada__c,
                                       Gestion_efectiva__c,Id,Status,WhatId, Subject,Fecha_Creacion__c 
                                       FROM Task WHERE WhatId =: idActivo ORDER BY CreatedDate DESC];
        if(lstTareas.size() > 0){
            RespuestaListado response = new RespuestaListado(lstTareas,'Listado de tareas',true);
            return JSON.serialize(response);
        }else{
            RespuestaListado response = new RespuestaListado(null,'Ninguna',false);
            return JSON.serialize(response);
        }        
    }

    // @AuraEnabled
    // public static Empleado__c asesorCuenta(String idActivo){
    //     Empleado__c empleado;
    //     Asset activo = [select id,Account.Asesor_asignado__c from Asset where id =: idActivo];
    //     if( activo.Account.Asesor_asignado__c != null ){
    //         empleado = [SELECT id FROM Empleado__c WHERE id =: activo.Account.Asesor_asignado__c LIMIT 1];
    //         return empleado;
    //     }else{
    //         return null;
    //     }
    // }
}
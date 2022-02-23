/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class que controla la actualizacion del contacto aval para que se ejecute el builder que 
                    llama el servicio web que actualiza el contacto aval

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   13-Abr-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_SincronizarClienteAval_ctr {
    public IT_SincronizarClienteAval_ctr() {
    }

    @AuraEnabled
    public static String sincronizaClienteAval(String idContacto){                
        Respuesta res;
        Contact contacto = [SELECT id, Sincronizar_Aval__c FROM Contact WHERE Id =: idContacto];
        String sincronizado = sincronizadoPreviamente(contacto);
        try{
            if( sincronizado == 'No sincronizado'){
                res = new Respuesta('FaltaSincronizar',false);
                return JSON.serialize(res);
            }else{
                cambiaFalso(contacto);
                System.debug('Se modifica a falso para que siempre se envie: '+ contacto.Sincronizar_Aval__c);       
                contacto.Sincronizar_Aval__c = true;
                contacto.controlSincronizacion__c = true;
                if(!Test.isRunningTest()){update contacto;}
                res = new Respuesta('Se actualizo correctamente',true);    
                return JSON.serialize(res);
            }
        }catch(Exception e){
            res = new Respuesta('Error',false);
            return JSON.serialize(res);
        }
    }

    public static String sincronizadoPreviamente(Contact contacto){
        List<ID> lstIdis = new List<ID>();
        lstIdis.add(contacto.id);
        List<Asociacion_cuenta_contacto__c> lstAscc = IT_GestorDeConsultas_cls.consultaConsecutivoPadre(lstIdis);
        if( lstAscc.size() > 0){
            return (lstAscc[0].Cliente__r.Consecutivo_Padre__c!=null && lstAscc[0].Cliente__r.Consecutivo_Padre__c!='') ? '"'+lstAscc[0].Cliente__r.Consecutivo_Padre__c+'"' : 'No sincronizado';
          }else{
            return 'No sincronizado';
          }
    }

    public static void cambiaFalso(Contact contacto){
        if( contacto.Sincronizar_Aval__c ){
            contacto.Sincronizar_Aval__c      = false;
            contacto.controlSincronizacion__c = false;
            update contacto;
        }
    }

    public class Respuesta{
        public String mensaje;
        public Boolean actualizo;  
        Respuesta(String men, Boolean act){
            this.mensaje = men;
            this.actualizo = act;
        }      
    }
}
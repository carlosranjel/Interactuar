/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase handler del Trigger de Encuesta

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   2-JUN-2020  Rafael Cardona (RC)            Clase para la logica del trigger de Encuesta.
**************************************************************************************************************
**/
public with sharing class IT_EncuestaHandler_cls {
	
	/*************************************************************************************************
	*Author:  Rafael Cardona
	*Function: Evita que se agregue mas de una encuesta a la oportunidad
	*Date: 2-06-2020
	**************************************************************************************************/
    public static void cantidadOportunidades(Boolean cTrigger,Map<Id,Encuesta__c> mapNewEncuesta,List<Encuesta__c> lstOldEncuesta,List<Encuesta__c> lstNewEncuesta){
        Map<Integer,ID> idOpp = new Map<Integer,ID>();
        Map<ID,Opportunity> mapOpp;
        
        for(Integer i=0; i < lstNewEncuesta.size(); i++){
            if( lstNewEncuesta[i].Oportunidad__c != null ){
                idOpp.put(i,lstNewEncuesta[i].Oportunidad__c);
            }            
        }
        if( idOpp.size() > 0 ){
            mapOpp = new  Map<ID,Opportunity>([Select id,(select id from Encuestas__r) from Opportunity WHERE id IN: idOpp.values()]);            
            for(Integer valor: idOpp.keySet()){
                if( mapOpp.get( idOpp.get(valor) ).Encuestas__r.size() >= 1 ){
                    Trigger.new[valor].addError(' Esta oportunidad ya tiene mas de una encuesta asociada ');
                }
            }
        } 
    }
}
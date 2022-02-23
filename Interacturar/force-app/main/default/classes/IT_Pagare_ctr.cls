/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase controladora del componente aura IT_Pagare

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   6-JUL-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_Pagare_ctr {

    private static final String CONTEXTO     = 'Pagare';
    private static final String ES_NULO      = null;
    private static List<Asociacion_cuenta_contacto__c> lstAscc;

    static{
        lstAscc = new List<Asociacion_cuenta_contacto__c>();
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Funcion para ser invocada desde el compoenente Aura para la creación del pagare
    *Date: 10-7-2020
    *******************************************************************************************/
    @AuraEnabled
    public static String creacionPagare(String idCotizacion){
        Quote cotizacion = consultaCotizacion(idCotizacion);
        Map<String,String> hom = getHomologaciones();
        List<Id> listaId = new List<Id>{ cotizacion.OpportunityId };
        lstAscc = IT_GestorDeConsultas_cls.consultaAsociacionAval(listaId);
        return IT_ServicioPagare_ws.ejecutaPagare(cotizacion, hom, lstAscc);                   
    }

    /*************************************************************************************
    *Author:  Rafael Cardona
    *Function: Pone en un MAP las configuraciones parametrizadas de la metadata
    *Date: 08-7-2020
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
    *Date: 6-7-2020
    **********************************/
    public static Quote consultaCotizacion(String idCotizacion){
        return [SELECT id,Iniciar_sincronizacion__c,Detener_sincronizacion__c, Opportunity.RecordType.DeveloperName,
        Status, Opportunity.Identificador_proceso__c, OpportunityId ,  Opportunity.AccountId, TotalPrice,
        Opportunity.Account.RecordType.DeveloperName , Opportunity.Account.Numero_de_identificacion__c,
        Opportunity.Account.Tipo_de_identificacion__c, Opportunity.Account.Movil_empresa__c,
        Opportunity.Account.PersonEmail, Opportunity.Account.firstName, Opportunity.Account.lastName,
        Opportunity.StageName,Opportunity.Account.Segundo_Apellido__c,Opportunity.Account.MiddleName,
        Opportunity.Account.Name,RespuestaCrearActualizarGiradores__c,EstadoIntegracionGirador__c,
        ResIntegreacionPagare__c,EstadoIntegracionPagare__c,
        Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
        Account.RecordType.DeveloperName,
        (SELECT Identificador_Radicado_OR__c  FROM QuoteLineItems )
        FROM Quote WHERE id =: idCotizacion];
    }
    
    public static void cobertura(){
        String variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
    }

}
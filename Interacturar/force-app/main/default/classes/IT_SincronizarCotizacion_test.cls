@isTest
public class IT_SincronizarCotizacion_test {
	@isTest(seeAllData=true)
    static void IT_SincronizarCotizacion_ctr(){
        test.starttest();
        IT_SincronizarCotizacion_ctr obj = new IT_SincronizarCotizacion_ctr();
        Quote cotizacionC = [SELECT id,OpportunityId,Opportunity.RecordType.DeveloperName, Status
                             FROM Quote WHERE Status = 'PROGRAMADA' and Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' 
                             and Opportunity.Account.RecordType.DeveloperName = 'Persona_natural' and IsSyncing = true
                             LIMIT 1];
        
        //List<Account> cliente = [select id, RecordType.DeveloperName from Account where id =: cotizacionC.Opportunity.Account.Id];
        Quote cotizacion = IT_SincronizarCotizacion_ctr.consultaCotizacion(cotizacionC.Id);
        List<Id> lstIdCliente = new List<Id>{ cotizacion.Opportunity.AccountId }; 
        List<Account> lstCliente     = IT_GestorDeConsultas_cls.consultaCuenta( lstIdCliente ); 
        List<Id> lstIdOpp     = new List<Id>{ cotizacion.OpportunityId };
        List<Opportunity> lstOpp     = IT_GestorDeConsultas_cls.consultaOportunidad( cotizacion.OpportunityId );
        List<Famiempresa__c> lstFami = IT_GestorDeConsultas_cls.consultaFamiEmpresaOpp( lstOpp[0].Famiempresa_relacionada__r.Id );
        IT_SincronizarCotizacion_ctr.validaCreditoBPMS(cotizacion.Id);
        IT_SincronizarCotizacion_ctr.validacionParaSincronizar(lstCliente, lstOpp, lstIdOpp);
        IT_SincronizarCotizacion_ctr.sincronizaOportunidad(cotizacion.id);
        IT_SincronizarCotizacion_ctr.detieneSincronizacion(cotizacion.id);
        IT_SincronizarCotizacion_ctr.validaCamposProductoCotizacion(cotizacion.Id);
        IT_SincronizarCotizacion_ctr.validaRepresentanteLegal(cotizacion,lstIdOpp);
        IT_SincronizarCotizacion_ctr.validaCamposFamiEmpresa(lstFami[0]);
        
        Quote cotizacionJ = [SELECT id,Opportunity.RecordType.DeveloperName, Status FROM Quote WHERE Status = 'PROGRAMADA' 
                            and Opportunity.RecordType.DeveloperName = 'Solicitud_de_credito' 
                            and Opportunity.Account.RecordType.DeveloperName = 'Persona_juridica' and IsSyncing = true
                             LIMIT 1];
        
        //List<Account> cliente = [select id, RecordType.DeveloperName from Account where id =: cotizacionC.Opportunity.Account.Id];
        Quote cotizacionJuridico = IT_SincronizarCotizacion_ctr.consultaCotizacion(cotizacionJ.Id);
        List<Id> lstIdClienteJ = new List<Id>{ cotizacionJuridico.Opportunity.AccountId }; 
        List<Account> lstClienteJ     = IT_GestorDeConsultas_cls.consultaCuenta( lstIdClienteJ ); 
        List<Id> lstIdOppJ     = new List<Id>{ cotizacionJuridico.OpportunityId };
        List<Opportunity> lstOppJ     = IT_GestorDeConsultas_cls.consultaOportunidad( cotizacionJuridico.OpportunityId );
        IT_SincronizarCotizacion_ctr.validaCreditoBPMS(cotizacionJuridico.Id);
        IT_SincronizarCotizacion_ctr.validacionParaSincronizar(lstClienteJ, lstOppJ, lstIdOppJ);
        IT_SincronizarCotizacion_ctr.sincronizaOportunidad(cotizacionJuridico.id);
        IT_SincronizarCotizacion_ctr.detieneSincronizacion(cotizacionJuridico.id);
        IT_SincronizarCotizacion_ctr.validaCamposProductoCotizacion(cotizacionJuridico.Id);
        IT_SincronizarCotizacion_ctr.validaRepresentanteLegal(cotizacionJuridico,lstIdOpp);
        
        
        
        Quote cotizacion2 = [SELECT id,Opportunity.RecordType.DeveloperName, Status, 
                             Iniciar_sincronizacion__c,Detener_sincronizacion__c,Opportunity.Identificador_proceso__c,OpportunityId,Opportunity.AccountId, 
                             Res_conteo_productos_cotizacion__c,Opportunity.Account.RecordType.DeveloperName,GrandTotal,
                             TotalPrice,Opportunity.Total_Capital_de_Trabajo__c,Opportunity.Total_Activos_Fijos_y_Otros__c,
                             Opportunity.Total_Servicios_de_Conocimiento__c
                             FROM Quote WHERE //Status = 'APROBADA' and
                             Opportunity.RecordType.DeveloperName = 'Servicios_de_conocimiento_y_redes' and IsSyncing = true
                             LIMIT 1];
        IT_SincronizarCotizacion_ctr.validacionesEjecucion(cotizacion2);
        
        test.stopTest();
    }
}
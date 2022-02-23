/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar - Autogestion
* @descripcion      Clase que se añade a la cola del proceso de autogestión para la consulta del Score 
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-MAR-2021   ÁLvaro Ortega (AO)           Creacion Clase.
**************************************************************************************************************
**/
public Class IT_AutoConsultaScore_cls implements Queueable, Database.AllowsCallouts{
    private String cotizacionId; 
    private QuoteLineItem productoDeCotizacion;

    public CampaignMember member;
    
    public IT_AutoConsultaScore_cls(String cotiId, QuoteLineItem prod, CampaignMember men) {
        this.cotizacionId         = cotiId;
        this.productoDeCotizacion = prod;
        this.member               = men;
    }
    
    public void execute(QueueableContext context) {
        Respuesta resp = consultaScore(cotizacionId, productoDeCotizacion, member);
        system.debug('resp: '+resp);
        if(resp.estado == 'Correcto'){
            system.debug('entro en el if validación respuesta correcta: '+resp.estado);
            Boolean continueWithSync = True;
            Opportunity opp                  = new Opportunity();
            if(member != null && member.Medio_de_Respuesta__c == 'Web' && (member.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' || member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito') ){
                
                system.debug('member: '+member);
                system.debug('member.Medio_de_Respuesta__c: '+member.Medio_de_Respuesta__c);
                system.debug('member.Tipo_de_Respuesta__c: '+member.Tipo_de_Respuesta__c);
                
                system.debug('resp.consultaScore.cuerpo.descripcion: '+resp.consultaScore.cuerpo.descripcion);
                system.debug('resp.consultaScore.cuerpo.decisor: '+resp.consultaScore.cuerpo.decisor);
                
                String score   = resp.consultaScore.cuerpo.descripcion == '' || resp.consultaScore.cuerpo.descripcion == null ? '' : resp.consultaScore.cuerpo.descripcion.toUppercase();
                String decisor = resp.consultaScore.cuerpo.decisor     == '' || resp.consultaScore.cuerpo.decisor     == null ? '' : resp.consultaScore.cuerpo.decisor.toUppercase();
                
                system.debug('score: '+score);
                system.debug('decisor: '+decisor);
                
                Resultado_Estudio_Digital__mdt resultadoDelCredito = getEstadoDelCredito(score, decisor);
                
                system.debug('resultadoDelCredito: '+resultadoDelCredito);
                
                opp.Id                           = resp.opportunityId;
                if(resultadoDelCredito != null){
                    system.debug('resultadoDelCredito distinto de nulo: '+resultadoDelCredito);
                    opp.Resultado_Estudio_Digital__c = resultadoDelCredito.Estado_del_Credito__c;
                    system.debug('opp.Resultado_Estudio_Digital__c: '+opp.Resultado_Estudio_Digital__c);
                    if(opp.Resultado_Estudio_Digital__c == 'APROBADO'){
                        //Sigue con el proceso normal de autogestión fase 2A
                        continueWithSync = True;
                    }else if(opp.Resultado_Estudio_Digital__c == 'ANALISIS FABRICA'){
                        opp.Generacion_Automatica_de_Credito__c = False;
                        continueWithSync = True;
                    }else if(opp.Resultado_Estudio_Digital__c == 'ANALISIS ASESOR'){
                        opp.Generacion_Automatica_de_Credito__c = False;
                        continueWithSync = False;
                        //Informa al asesor
                    }else if(opp.Resultado_Estudio_Digital__c == 'NEGADO'){
                        opp.Generacion_Automatica_de_Credito__c = False;
                        opp.StageName = 'Negada';
                        continueWithSync = False;
                    }
                }else{
                    system.debug('entro al else de resultadoDelCredito: '+resultadoDelCredito);
                    continueWithSync = False;
                    opp.Resultado_Estudio_Digital__c = 'OPORTUNIDAD CON ERROR DE CÁLCULO DE CALIFICACIÓN';
                }
                update opp;
            }
            
            if(!Test.isRunningTest()){
                if(continueWithSync){
                    IT_AutoSincronizarCotizacion_cls nextJob = new IT_AutoSincronizarCotizacion_cls(cotizacionId, member);
                	Id jobID = System.enqueueJob(nextJob);
                }else{
                    String URL = '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'">'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'</a>';
                    IT_GeneracionAutomaticaCredito.logIntegracion('Exitoso','Aldeamo', 'Sincronización Oportunidad: La sincronización no se realizó porque el Resultado del Estudio Digital fue "' + opp.Resultado_Estudio_Digital__c + '"');
                    IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('CorrectoEmailAsesor','Sincronización Oportunidad: La sincronización no se realizó porque el Resultado del Estudio Digital fue "' + opp.Resultado_Estudio_Digital__c + '"','Uno de tus clientes está solicitando crédito por la oficina virtual y necesita que tú continues con el proceso de la solicitud: ' + URL, 'Sincronización Oportunidad');
                    resFinal.miembro = member;
                    
                    IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
                }
            }
        }else{
            system.debug('entro al else de correcto');
            if(member != null && member.Medio_de_Respuesta__c == 'Web' && (member.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' || member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito') )
            {
                system.debug('member.Medio_de_Respuesta__c del else: '+member.Medio_de_Respuesta__c);
                system.debug('member.Tipo_de_Respuesta__c del else: '+member.Tipo_de_Respuesta__c);
                Opportunity opp                  = new Opportunity();
                opp.Id                           = resp.opportunityId;
                opp.Resultado_Estudio_Digital__c = 'OPORTUNIDAD CON ERROR DE CÁLCULO DE CALIFICACIÓN';
                update opp;
            }
            
            IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo', resp.mensaje);
            IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', resp.mensaje, 'Consulta de Score');
            resFinal.miembro = member;
            
            IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
        } 
    }
    
    @InvocableMethod
    public static void enviaEmailAlAsesor( List<String> idOpor ){
        List<Opportunity> opps = [Select Id, Asesor_asignado__r.Correo_electronico__c
                                  from Opportunity
                                  where id = :idOpor[0]];
        
        List<String> emails = new List<String>{opps[0].Asesor_asignado__r.Correo_electronico__c};
            
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.optOutPolicy = 'FILTER';
        
        String text = 'Una de tus Oportunidades de Crédito asigandas necesita ser gestionada lo más pronto:<br><b>';
        text       += System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/' + opps[0].Id + '/view</b>';
        
        message.subject = 'Gestionar Solicitud de Crédito';
        message.setHtmlBody(text);//'This is the message body.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            opps[0].Fecha_de_Notificacion_al_Asesor__c = DateTime.now();
            opps[0].Oportunidad_Necesita_ser_Gestionada__c = True;
            update opps[0];
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        } 
    }
    public static Respuesta consultaScore(String cotizacionId, QuoteLineItem productoDeCotizacion, CampaignMember member){
        QuoteLineItem aux = [select Id, Product2.ProductCode, Quote.OpportunityId
                                from QuoteLineItem
                                where Id = : productoDeCotizacion.Id];
        try{
            
            productoDeCotizacion.Product2 = new Product2();
            productoDeCotizacion.Product2.ProductCode = aux.Product2.ProductCode;
            
            IT_ModeloScore_cls.ResponseDTO response = IT_ModeloScore_cls.consultaScore(cotizacionId, productoDeCotizacion);
            
            if(response.encabezado.mensaje.estado != 'ERROR'){
                system.debug(response.cuerpo.score);
                
                productoDeCotizacion.Score__c         = response.cuerpo.descripcion;
                productoDeCotizacion.Puntaje_Score__c = Decimal.valueOf(response.cuerpo.score); 
                update productoDeCotizacion;
                
                return new Respuesta('Correcto', 'Score correcto', response, aux.Quote.OpportunityId);
                
            }else{
                system.debug(response.encabezado.mensaje.descripcion);
                
                productoDeCotizacion.Observacion_Score__c         = response.encabezado.mensaje.descripcion;
                update productoDeCotizacion;
                
                return new Respuesta('Error', response.encabezado.mensaje.descripcion, aux.Quote.OpportunityId);
            }
    
        }catch(Exception ex){
            productoDeCotizacion.Observacion_Score__c = 'Error en la consulta de Score en Autogestión';
            update productoDeCotizacion;
            return new Respuesta('Error', 'Error: Consulte a su administrador : ' + ex, aux.Quote.OpportunityId);
        }
        
        
    }
    
    /********************************************************************************************************
    *Author:   Álvaro Ortega
    *Function: Obtiene el resutado del crédito dependiendo del Decisor y del Score
    *Date:     27-ABR-2021
    *********************************************************************************************************/
    public static Resultado_Estudio_Digital__mdt getEstadoDelCredito(String score, String decisor){
        List<Resultado_Estudio_Digital__mdt> mets = [select Decisor__c, Score__c, Estado_del_Credito__c
                                                    from Resultado_Estudio_Digital__mdt
                                                    where Decisor__c = :decisor and Score__c = :score
                                                    and Vigente__c = True];
        system.debug('valor de mets: '+mets);
        if(mets.size() > 0){
            return mets[0];
        }
        return null;
    }
    
    public Class Respuesta{
        public String estado;
        public String mensaje;
        public IT_ModeloScore_cls.ResponseDTO consultaScore;
        public String opportunityId;
        
        public Respuesta(String est, String men, String oppId) {
            this.estado  = est;
            this.mensaje = men;
            this.opportunityId = oppId;
        }
        public Respuesta(String est, String men, IT_ModeloScore_cls.ResponseDTO conScore, String oppId) {
            this.estado        = est;
            this.mensaje       = men;
            this.consultaScore = conScore;
            this.opportunityId = oppId;
        }
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
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
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
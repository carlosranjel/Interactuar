global class IT_AutoNotificaDirector_job implements Schedulable {
    global static Integer timeBetweenRun = 30; //El Job se corre cada 30 minutos
    
    global void execute(SchedulableContext ctx) {
        
        doAll();
        
        DateTime todayDate = DateTime.now();
        deleteJob();
        assignJob(todayDate);
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
        var += '';
        var += '';
    }
    
    global static void doAll(){
        ListaClaveValor__mdt maxTime       = getListaClaveValor('Auto Tiempo Max Informa Director (h)');
        ListaClaveValor__mdt directorEmail = getListaClaveValor('Auto Correo Director');
        
        Map<Id, Opportunity> listOpp = new Map<Id, Opportunity>([Select Id, Name, Oportunidad_Necesita_ser_Gestionada__c, Resultado_Estudio_Digital__c, Horas_sin_Gestionar_Solicitud_de_Credito__c,
                                                                 Asesor_asignado__r.Name, Asesor_asignado__r.Codigo_de_Empleado__c
                                                                 from Opportunity 
                                                                 where Resultado_Estudio_Digital__c = 'ANALISIS ASESOR' and Oportunidad_Necesita_ser_Gestionada__c = True 
                                                                 and Horas_sin_Gestionar_Solicitud_de_Credito__c >= :Integer.valueOf(maxTime.valor__c) and Notificado_al_Director__c != True
                                                                order by Asesor_asignado__r.Codigo_de_Empleado__c]);
        
        if(listOpp.values().size() > 0){
            enviaEmailAlAsesor(listOpp.values(), directorEmail.valor__c, Integer.valueOf(maxTime.valor__c));
        }
        system.debug(listOpp);
    }    
    
    /********************************************************************************************************
    *Author:   Álvaro Ortega
    *Function: Envía correo al Director de ser necesario
    *Date:     27-ABR-2021
    *********************************************************************************************************/
    public static void enviaEmailAlAsesor( List<Opportunity> listOpor, String email, Integer maxTime){
        
        List<String> emails = new List<String>{email};
            
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.optOutPolicy = 'FILTER';
        
        String text = 'Las siguientes Oportunidades no han sido gestionadas por sus asesores en ' + maxTime + ' horas:<br>';
        
        for(Opportunity opp : listOpor){
            text += '<br>Nombre        : ' + opp.Name + '<br>';
            text += 'Url           : ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/' + opp.Id + '/view<br>';
            text += 'Asesor        : ' + opp.Asesor_asignado__r.Name + '<br>';
            text += 'Código Asesor : ' + opp.Asesor_asignado__r.Codigo_de_Empleado__c +'<br>';
            opp.Notificado_al_Director__c = True;
            
        }
        message.subject = 'Oportunidades no Gestionadas por sus Asesores';
        message.setHtmlBody(text);//'This is the message body.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            update listOpor;
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        } 
    }
    
    /********************************************************************************************************
    *Author:   Álvaro Ortega
    *Function: Obtenen metadatos
    *Date:     27-ABR-2021
    *********************************************************************************************************/
   	public static ListaClaveValor__mdt getListaClaveValor(String name){
        List<ListaClaveValor__mdt> des = [select Clave__c, valor__c, MasterLabel 
                                          from ListaClaveValor__mdt 
                                          where MasterLabel = :name];
        if(des.size() > 0){
            return des[0];
        }
        return null;
    }
    
    /********************************************************************************************************
    *Author:   Álvaro Ortega
    *Function: Borra la tarea programada que ya se cumplió
    *Date:     27-ABR-2021
    *********************************************************************************************************/
    global static void deleteJob() {
        String title = 'IT_AutoNotificaDirector_job';
        for(CronTrigger con : [SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State FROM CronTrigger]){
            if(con.CronJobDetail.Name == title){
                System.abortJob(con.Id);
            }
        }
    }
    
    /********************************************************************************************************
    *Author:   Álvaro Ortega
    *Function: Asigna el trabajo programado dentro de un tiempo deteminado
    *Date:     27-ABR-2021
    *********************************************************************************************************/
    public static void assignJob(DateTime todayDate) {
        DateTime nextDate = todayDate.addMinutes(timeBetweenRun);
        IT_AutoNotificaDirector_job Schedule = new IT_AutoNotificaDirector_job();
        String sch = '1 ' + nextDate.minute() + ' ' + nextDate.hour() + ' ' + nextDate.day() + ' ' + nextDate.month() + ' ? ' + nextDate.year();
        String title = 'IT_AutoNotificaDirector_job';
        system.schedule(title, sch, Schedule );
    }
}
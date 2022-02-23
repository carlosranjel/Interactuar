global with sharing class ConfirmacionServicios {
    
    global ConfirmacionServicios() {
    }    	
    global static RespuestaConfirmacion       resConfirmacion;
    global static List<RespuestaConfirmacion> lstResConfirmacion;
     
    @InvocableMethod
    global static List<RespuestaConfirmacion> validaEjecucion(List<String> confirmacion ){
        resConfirmacion    = new RespuestaConfirmacion();
        lstResConfirmacion = new List<RespuestaConfirmacion>();
        List<String> lstRespuesta = new List<String>();
        lstRespuesta = confirmacion[0].split(',');
        System.debug('muestra '+lstRespuesta[0] + ' - ' + lstRespuesta[1]);
       
        if( lstRespuesta[0] == 'IdBPMS'){           
            resConfirmacion.respuesta = validaEjecucionIdBPMS(lstRespuesta[1].trim());            
            lstResConfirmacion.add(resConfirmacion);
            return lstResConfirmacion;
        }else if( lstRespuesta[0] == 'Datacredito'){
            resConfirmacion.respuesta = validaEjecucionDataCredito(lstRespuesta[1].trim());            
            lstResConfirmacion.add(resConfirmacion);
            return lstResConfirmacion;
        }else if( lstRespuesta[0] == 'Historico'){
            resConfirmacion.respuesta = validaEjecucionGeneracionPDF(lstRespuesta[1].trim());            
            lstResConfirmacion.add(resConfirmacion);
            return lstResConfirmacion;
        }else{
            resConfirmacion.respuesta = 'KO';            
            lstResConfirmacion.add(resConfirmacion);
            return lstResConfirmacion;
        } 
    }    
    
    global static String validaEjecucionIdBPMS( String idObj ){
        // valida exista id procesoBMS
        if( idObj.startsWith('00Q') ){
        	List<Lead> lstPros = consultaLead(idObj);
            if( lstPros.size() == 1 && lstPros[0].Identificador_proceso__c == null)
                return 'OK';
            else
                return 'KO';
        }else{
            List<Opportunity> lstOpp = consultaOpp(idObj);
            if( lstOpp.size() == 1 && lstOpp[0].Identificador_proceso__c == null)
                return 'OK';
            else
                return 'KO';
        }
    }
    
  
    global static String validaEjecucionDataCredito( String idObj ){
        // VALIDA fecha de consulta mayor a 30 dias
        // url_datacredito exista
        if( idObj.startsWith('00Q') ){
            List<Lead> lstPros = consultaLead(idObj);
            if( lstPros.size() == 1 && lstPros[0].Fecha_consulta_Datacredito__c == null ){
                 return 'OK';
            }else if( lstPros.size() == 1 && lstPros[0].Fecha_consulta_Datacredito__c != null ){
                if( ejecutaConsultaDataCredito(lstPros[0].Fecha_consulta_Datacredito__c) ){
                    return 'Ok';
                }else{
                    return 'KO';
                }            
            }else{
                return 'KO';
            }                   
        }else if( idObj.startsWith('006')){
            List<Opportunity> lstOpp = consultaOpp(idObj);
            if( lstOpp.size() == 1 && lstOpp[0].Fecha_consulta_Datacredito__c == null ){
                 return 'OK';
            }else if( lstOpp.size() == 1 && lstOpp[0].Fecha_consulta_Datacredito__c != null ){
                if( ejecutaConsultaDataCredito(lstOpp[0].Fecha_consulta_Datacredito__c) ){
                    return 'Ok';
                }else{
                    return 'KO';
                }            
            }else{
                return 'KO';
            }  
        }else{
            // ajuste para contacto
            List<Contact> lstCon = consultaCon(idObj);
            if( lstCon.size() == 1 && lstCon[0].Fecha_consulta_Datacredito__c == null ){
                 return 'OK';
            }else if( lstCon.size() == 1 && lstCon[0].Fecha_consulta_Datacredito__c != null ){
                if( ejecutaDataCreditoOtraOpp( lstCon[0] ) ){ // otra opp
                    return 'Ok';
                }else{
                    return 'KO';
                }            
            }else{
                return 'KO';
            }
        }
    }
    

    global static String validaEjecucionGeneracionPDF( String idObj ){
        // url historico si esta vacia ejecuta   
        
        if( idObj.startsWith('00Q') ){
            List<Lead> lstPros = consultaLead(idObj);
            if( lstPros.size() > 0 && lstPros[0].Link_PDF_Historico__c == null )
                return 'OK';
            else
                return 'KO';                 
        }else if( idObj.startsWith('006') ){
            List<Opportunity> lstOpp = consultaOpp(idObj);
            if( lstOpp.size() == 1 && lstOpp[0].Link_PDF_Historico__c == null)
                return 'OK';
            else
                return 'KO';
        }else{
            // ajuste para contacto
            List<Contact> lstCon = consultaCon(idObj);
            if( lstCon.size() == 1 && lstCon[0].Link_PDF_Historico__c == null)
                return 'OK';
            else if(lstCon.size() == 1 && lstCon[0].Link_PDF_Historico__c != null && ejecutaDataCreditoOtraOpp( lstCon[0] )  )// otra opp
                return 'OK';
            else
                return 'KO';
        }             
    }
    
    global class RespuestaConfirmacion{
        @InvocableVariable
        public String respuesta;
    }
    
    public static List<Lead> consultaLead( String idObj ){
        return [SELECT id, Identificador_proceso__c, Fecha_consulta_Datacredito__c,Link_PDF_Datacredito__c,
                              Link_PDF_Historico__c FROM Lead WHERE id =: idObj];
    }
    
    public static List<Opportunity> consultaOpp( String idObj ){
        return [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Fecha_consulta_Datacredito__c,
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c,Link_PDF_Datacredito__c, Link_PDF_Historico__c FROM Opportunity WHERE id =: idObj];
    }
    
    public static List<Contact> consultaCon( String idObj ){
        return [SELECT Id,Fecha_consulta_Datacredito__c,Link_PDF_Datacredito__c, Link_PDF_Historico__c, EjecutarDataAval__c FROM Contact WHERE id =: idObj];
    }

    public static List<Asociacion_cuenta_contacto__c> consultaAsociacionAval(String idContacto){
        return [SELECT id, Cliente__c, Cliente__r.Consecutivo_Padre__c, Contacto__c,Oportunidad__c,
        Contacto__r.LastName, Contacto__r.Email,Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c,
        Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c, Oportunidad__r.Id
         FROM Asociacion_cuenta_contacto__c WHERE Contacto__c =: idContacto];
      }
    
    public static Boolean ejecutaConsultaDataCredito(Date fechaValidar){
        Date fechaDataCredito;
        System.debug('fecha: '+ fechaValidar);
        if( fechaValidar != null ){
            fechaDataCredito = (fechaValidar).addDays(31);
            System.debug('fecha: '+ fechaDataCredito );
            if( fechaDataCredito < System.now() ){
                System.debug('1: ' );
                return true;
            }else{
                System.debug('2: ' );
                return false;
            }
        }else{
            System.debug('3: ' );
            return true;
        }        
    }

    public static Boolean ejecutaDataCreditoOtraOpp( Contact contacto ){ // otra opp
        Boolean ejecutarDataCredito = false;
        for(Asociacion_cuenta_contacto__c aso: consultaAsociacionAval( contacto.Id ) ){
            if( String.isNotBlank(contacto.EjecutarDataAval__c) && !(contacto.EjecutarDataAval__c).contains(aso.Oportunidad__r.Id) ){
                ejecutarDataCredito = true;
            }
        }
        return ejecutarDataCredito;
    }
}
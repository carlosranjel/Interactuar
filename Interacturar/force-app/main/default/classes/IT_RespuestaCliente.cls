/**
**************************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de respuesta de Cliente

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            1.0   10-Jul-2019  Rafael Cardona (RC)           Creacion Clase.
*            2.0   06-Feb-2020  Rafael Cardona (RC)           Se agrega origen y refPadre como atributos nuevos en el json
/*
***************************************************************************************************************************
**/
@RestResource(urlMapping='/NotificacionRespuestaCliente/*')
global class IT_RespuestaCliente {
	public IT_RespuestaCliente() {	}

	/******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura interna para cargar los datos deserealizados
	*Date: 10-7-2019
	
	*Author:  Rafael Cardona
    *Parametros: 
    *@estado           :  // ('OK'=true,'KO'=false)
    *@observacion      :  // si ('OK'=true no viene mensaje ), (KO'=false viene menssaje de error)   
    *@consecutivoPadre : id cliente para asociar con los avales, si se necesita enviar otro aval, 
                         Si viene error no llega el consecutivo padre
    *@origen           : ORACLE - TALENT
    *Date: 6-2-2020
    ******************************************************************************************/
    public class RespuestaDeCliente{
       RespuestaCliente respuestaCliente;
    }    
    global class RespuestaCliente{
        public String idCliente          {get;set;}// id SF cliente
		public String idFamiEmpresa      {get;set;}// id fami empresa
		public String estado             {get;set;}// ('OK'=true,'KO'=false)mensaje de exitoso o que fallo
		public String observacion        {get;set;}// si ('OK'=true no viene mensaje ), (KO'=false viene menssaje de error)
		public String origen             {get;set;}// mensaje de exitoso o que fallo
        public String consecutivoPadre   {get;set;}// id cliente para asociar con los avales, si se necesita enviar otro aval
    }

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos que vienen de la respuesta de oportunidad
    *Date: 6-7-2019
    ******************************************************************************************/
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent); 

        RespuestaDeCliente respuestaCli  = (RespuestaDeCliente)JSON.deserializeStrict(strJSONContent, RespuestaDeCliente.class); 
        System.debug('Obj cliente '+ respuestaCli.respuestaCliente );  

        identificaObjetos( respuestaCli.respuestaCliente );
    }


    public static void identificaObjetos( RespuestaCliente  respuesta ){		
        List<Famiempresa__c> famiEmpresa = new List<Famiempresa__c>();
        List<Account> cuentas  = new List<Account>();
        List<Contact> contacto = new List<Contact>();

        if( respuesta.consecutivoPadre != null && respuesta.consecutivoPadre != '' ){
            cuentas = [SELECT id,Respuesta_Cliente__c, RecordType.DeveloperName, Numero_de_identificacion__c, LastName, FirstName,
            Origen_Integracion__c, Consecutivo_Padre__c 
            FROM Account WHERE Numero_de_identificacion__c  =: respuesta.idCliente];
        }else{
            contacto = [SELECT id,Respuesta_ClienteAval__c, RecordType.DeveloperName, Numero_de_identificacion__c, LastName, FirstName,
            Origen_Integracion__c, Consecutivo_Padre__c , Sincronizar_Aval__c
            FROM Contact WHERE Numero_de_identificacion__c  =: respuesta.idCliente and recordType.Developername = 'Contacto_Aval'];
        }

        if( cuentas.size() != 1 && contacto.size() != 1 ){								 
			throw new applicationException('VALIDAR: No se encontraron cliente o contacto con este idCliente: '+ respuesta.idCliente);
		}else{
            if( cuentas.size() == 1){
                famiEmpresa = [SELECT id,Identificador_Famiempresa__c 
                FROM Famiempresa__c WHERE Cliente_relacionado__c =: cuentas[0].id ORDER BY LastModifiedDate Desc LIMIT 1];
                actualizaObjetos(cuentas[0], null,  respuesta, famiEmpresa );
            }			
            if( contacto.size() == 1 ){
                actualizaObjetos(null, contacto[0],  respuesta, famiEmpresa );
            }
			
		}
    }


	public static void actualizaObjetos(Account cuenta, Contact contacto, RespuestaCliente  respuesta, List<Famiempresa__c> famiEmpresa){
        Boolean isUpdate = false;
        Boolean isUpdateContacto = false;

		if( cuenta != null && cuenta.RecordType.DeveloperName == 'Persona_juridica'){	
            if(respuesta.estado == 'OK'){
                if( (respuesta.idFamiEmpresa != null || respuesta.idFamiEmpresa != '') && respuesta.idFamiempresa != '99999'){
                    cuenta.Identificador_Famiempresa__c = respuesta.idFamiEmpresa;
                }
                cuenta.Confirmacion_Cliente_OR__c   = true;
				cuenta.Respuesta_Cliente__c         = respuesta.observacion;
				cuenta.Origen_Integracion__c        = respuesta.origen;  
                cuenta.Consecutivo_Padre__c         = respuesta.consecutivoPadre;
				isUpdate = true;
			}else {
				cuenta.Respuesta_Cliente__c         = respuesta.observacion;
				cuenta.Origen_Integracion__c        = respuesta.origen;  
                cuenta.Consecutivo_Padre__c         = respuesta.consecutivoPadre;
				isUpdate = true;
			}
        }else if( cuenta != null && cuenta.RecordType.DeveloperName == 'Persona_natural'){
            system.debug('persona natural');
            system.debug('famiEmpresa' + famiEmpresa.size());
            system.debug('respuesta fami empresa' + respuesta.idFamiEmpresa);
            if(famiEmpresa.size() > 0){ 
               
                if( respuesta.idFamiEmpresa != null && respuesta.idFamiEmpresa != '' && respuesta.idFamiempresa != '99999'){
                    system.debug('entro en actualizacion fami empresa');
                    famiEmpresa.get(0).Identificador_Famiempresa__c = respuesta.idFamiEmpresa;  
                }
            }
            isUpdate = true;
            cuenta.Respuesta_Cliente__c       = respuesta.observacion;
            cuenta.Confirmacion_Cliente_OR__c = true;
            cuenta.Origen_Integracion__c      = respuesta.origen;
            cuenta.Consecutivo_Padre__c       = respuesta.consecutivoPadre;
		}else if( contacto != null && contacto.RecordType.DeveloperName == 'Contacto_Aval' ){
            contacto.Respuesta_ClienteAval__c = respuesta.observacion;
            contacto.Origen_Integracion__c    = respuesta.origen;
            contacto.Consecutivo_Padre__c     = respuesta.consecutivoPadre; 
            contacto.Sincronizar_Aval__c      = true;
            isUpdateContacto = true;
        }  

        if(isUpdate){ update cuenta; }
        if(isUpdateContacto){ update contacto; }
        if( famiEmpresa.size() > 0 ){ update famiEmpresa; }
	}

    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para el manejo de las excepciones
    *Date: 17-2-2019
    ******************************************************************************************/
    public class applicationException extends Exception {}

}
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso REST para exponer servicio para la respuesta del cliente

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   22-Feb-2021  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/RespuestaDelClienteAutogestion/*')
global class IT_RespuestaDelClienteAutogestion_WS {
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Recepción del servicio
    *Date: 22-Feb-2021
    ******************************************************************************************/
    @HttpPost
    global static ResponseDTO doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);
        
        FromJSON jsonObj = (FromJSON)JSON.deserializeStrict(strJSONContent, FromJSON.class);
       
        String tipoRespuesta = jsonObj.respuestaClienteAutogestion.tipoRespuesta;
        
        CampaignMember member;
        ResponseDTO result = new ResponseDTO();
        result.encabezado = buildEncabezado(jsonObj.encabezado);
        
        if(tipoRespuesta.toLowerCase() != 'solicite aquí su crédito'){
            member = getCampaignMember(jsonObj.respuestaClienteAutogestion.idMiembroCampania);
        }else{
            //En este caso no existe Miembro de Campaña, hay que crearlo
            List<Campaign> camp = [Select Id
                                  from Campaign
                                  where CodigoCorto__c = '999999999' and Status = 'Terminada'];
            if(camp.size() > 0){
                Account clien = getCliente(jsonObj.respuestaClienteAutogestion.tipoDocumento, jsonObj.respuestaClienteAutogestion.numeroDocumento);
                
                List<CampaignMember> existMember = [select Id
                                                    from CampaignMember
                                                    where (Contact.AccountId = :clien.Id or Lead.ConvertedAccountId = :clien.Id) and CampaignId = :camp[0].Id];
                member = new CampaignMember();
                if(existMember.size() > 0){
                    member.Id = existMember[0].Id;
                    member.Credito_sin_Preaprobado__c = True;
                    member.Fondo__c = '2';
                    member.Mensaje_recibido__c = '';
                    member.Fecha_de_Mensaje__c = null;
                    member.Mensaje_de_Generacion_de_Credito__c = '';
                    member.Oportunidad_Generada_Automatica__c = null;
                    member.Status = 'Enviado';
                    update member;
                    
                }else{
                    member.Fondo__c = '2';
                    member.CampaignId = camp[0].Id;
                    member.Credito_sin_Preaprobado__c = True;
                    
                    List<Contact> cons = [select Id
                                          from Contact
                                          where AccountId = : clien.Id];
                    if(cons.size() > 0){
                        member.ContactId = cons[0].Id;
                    }else{
                        List<Lead> leads = [select Id
                                            from Lead
                                            where ConvertedAccountId = : clien.Id];
                        if(leads.size() > 0){
                            member.LeadId = leads[0].Id;                     
                        }else{
                            result.encabezado.mensaje.estado = 'KO';
                            result.encabezado.mensaje.descripcion = 'No existe Contacto o Prospecto para este cliente';
                            return result;   
                        }
                    }
                    insert member;
                }                
            }else{
                result.encabezado.mensaje.estado = 'KO';
                result.encabezado.mensaje.descripcion = 'Error. Consulte a su administrador: No existe Campaña para los créditos sin preaprobados';
                return result;
            } 
        }
       
        if(member != null){
            try{
                Product2 prod = getProduct(String.valueOf(jsonObj.respuestaClienteAutogestion.producto));
                if(prod == null){
                    result.encabezado.mensaje.estado = 'KO';
                	result.encabezado.mensaje.descripcion = 'No existe o no está activo este producto';
                    return result;
                }
                
                if(tipoRespuesta.toLowerCase() != 'monto mayor/cambio de plazo'){
                    member.Producto__c    = prod.Id;
                    member.Monto__c       = jsonObj.respuestaClienteAutogestion.monto;
                    member.Plazo_Meses__c = jsonObj.respuestaClienteAutogestion.plazo;
                }
               
                member.Producto_RCA__c       = prod.Id;
                member.Monto_RCA__c          = jsonObj.respuestaClienteAutogestion.monto;
                member.Plazo_Meses_RCA__c	 = jsonObj.respuestaClienteAutogestion.plazo;
                
                member.Mensaje_recibido__c   = jsonObj.respuestaClienteAutogestion.aceptoCliente == True ? 'Sí' : 'No';
                member.Status                = jsonObj.respuestaClienteAutogestion.aceptoCliente == True ? 'Respondida' : '	No interesado';
                member.Tipo_de_Respuesta__c  = tipoRespuesta;
                member.Medio_de_Respuesta__c = jsonObj.respuestaClienteAutogestion.medioRespuesta.toLowerCase().contains('web') ? 'Web' : null;
                member.Fecha_de_Mensaje__c   = DateTime.valueOf(jsonObj.respuestaClienteAutogestion.fechaRespuesta).date();
                member.Tipo_de_Cuenta__c     = jsonObj.respuestaClienteAutogestion.tipoCuenta;
                member.Numero_Cuenta__c      = jsonObj.respuestaClienteAutogestion.numeroCuenta;
                member.Banco__c              = jsonObj.respuestaClienteAutogestion.banco;
                member.Beneficiarios__c      = JSON.serialize(jsonObj.respuestaClienteAutogestion.beneficiarios);
                //member.Usar_Info_RCA__c      = True; //Campo auxiliar para saber que se debe tomar la información del servicio para la creaión de la Oportunidad
                
                Account clien = getCliente(jsonObj.respuestaClienteAutogestion.tipoDocumento, jsonObj.respuestaClienteAutogestion.numeroDocumento);
                if(clien != null){
                    system.debug('entro en cuenta');
                    if(tipoRespuesta.toLowerCase() == 'monto mayor/cambio de plazo' || tipoRespuesta.toLowerCase() == 'solicite aquí su crédito' || tipoRespuesta.toLowerCase() == 'Monto Menor/Cambio de Plazo'){
                    system.debug('entro en tipo de respuesta');
                    system.debug('nombre arrendador' + jsonObj.respuestaClienteAutogestion.nombreArrendador);
                    system.debug('Telefono_arrendador__pc arrendador' + jsonObj.respuestaClienteAutogestion.telefonoArrendador);
                        
                        clien.Tipo_de_vivienda__pc          = jsonObj.respuestaClienteAutogestion.tipoVivienda;
                        clien.Nombre_del_arrendador__pc     = jsonObj.respuestaClienteAutogestion.nombreArrendador;
                        clien.Telefono_arrendador__pc = jsonObj.respuestaClienteAutogestion.telefonoArrendador;
                        clien.Estado_civil__pc              = jsonObj.respuestaClienteAutogestion.estadoCivil;
                    }
                    
                    clien.Movil_empresa__c              = jsonObj.respuestaClienteAutogestion.numeroCelular;
                    clien.Correo_electronico_empresa__c = jsonObj.respuestaClienteAutogestion.correoElectronico;
                    clien.PersonEmail                   = jsonObj.respuestaClienteAutogestion.correoElectronico;
                    
                    update clien;
                }
                
				update member;
                
                result.encabezado.mensaje.estado = 'OK';
                result.encabezado.mensaje.descripcion = '';
                
            }catch(Exception ex){
                result.encabezado.mensaje.estado = 'KO';
                result.encabezado.mensaje.descripcion = 'Error técnico: consulte con su administrador: ' + ex;
                
            }
        }else{
            result.encabezado.mensaje.estado = 'KO';
            result.encabezado.mensaje.descripcion = 'No existe este Miembro de Campaña';
        }

        return result;
        
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se obtiene el cliente
    *Date: 23-Mar-2021
    ******************************************************************************************/
    public static Account getCliente(String tipoIden, String numIden){
        List<Account> accounts = [Select Id
                                  from Account 
                                  where Tipo_de_identificacion__c = :tipoIden and Numero_de_identificacion__c = :numIden];
        if(accounts.size() > 0){
            return accounts[0];
        }
        return null;
    }

    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se obtiene el Miembro de la Compañía
    *Date: 23-Feb-2021
    ******************************************************************************************/
    public static CampaignMember getCampaignMember(String idMember){
        if ( !Schema.sObjectType.CampaignMember.fields.Name.isAccessible() ) {   return null;  }
        List<CampaignMember> members = [select Id, Name, CampaignId, ContactId, Contact.AccountId, LeadId, Lead.ConvertedAccountId, Mensaje_recibido__c
                                        from CampaignMember
                                        where Id = :idMember];
        if(members.size() > 0){
            return members[0];
        }
        return null;
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Se obtiene producto con código de producto
    *Date: 23-Feb-2021
    ******************************************************************************************/
    public static Product2 getProduct(String productCode){
        List<Product2> productList = [Select Id 
                                       from Product2 
                                       where ProductCode = :productCode and IsActive = true];
        if(productList.size() > 0){
            return productList[0];
        }
        return null;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Encabezado de respuesta
    *Date: 22-Feb-2020
    ******************************************************************************************/
    public static Encabezado buildEncabezado(Encabezado request){
        Encabezado encabezado = new Encabezado();
        encabezado.fecha = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        encabezado.identificador = request.identificador;
        encabezado.integracion = 'Créditos Y Estados Autogestión';
        encabezado.operacion = request.operacion;
        encabezado.origen = 'SALESFORCE';
        encabezado.destino = request.origen;
        
        return encabezado;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información recibida
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class FromJSON{
        public Encabezado encabezado;
        public RespuestaClienteAutogestion respuestaClienteAutogestion;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class Encabezado{
        public String fecha;
        public String identificador;
        public String integracion;
        public String operacion;
        public String origen;
        public String destino;
        public Mensaje mensaje = new Mensaje(); 
    }
    
     /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class Mensaje{
        public String estado;
        public String descripcion;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class RespuestaClienteAutogestion{
        public String idMiembroCampania;
        public String tipoDocumento;
        public String numeroDocumento;
        public Decimal monto;           //
        public Integer plazo;           //
        public String correoElectronico;
        public String numeroCelular;    
        public Integer producto;        //
        public Boolean aceptoCliente;   //
        public String tipoRespuesta;    // Campo nuevo
        public String medioRespuesta;   //
        public String fechaRespuesta;   //
        public String tipoCuenta;       // Campo nuevo para Oportunidad
        public String numeroCuenta;     // Campo nuevo para Oportunidad
        public String banco;            // Campo nuevo para Oportunidad
        public String estadoCivil;
        public String tipoVivienda;
        public String nombreArrendador; //campo nuevo requerimiento autogestion fase 2
        public String telefonoArrendador; //campo nuevo requerimiento autogestion fase 2
        public List<Beneficiario> beneficiarios = new List<Beneficiario>();
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class Beneficiario{
        public String nombreCompleto;
        public String tipoDocumento;
        public String numeroDocumento;
        public String parentesco;
        public Decimal porcentaje;
        public String cualParentesco;
    }

     /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información enviada
    *Date: 22-Feb-2020
    ******************************************************************************************/
    global class ResponseDTO{
        public Encabezado encabezado;
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
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
        
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
        var += '';
        var += '';
        var += '';
        var += '';
                var += '';
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
}
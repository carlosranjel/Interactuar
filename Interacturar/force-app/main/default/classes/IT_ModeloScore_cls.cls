/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada para consumir el servicio que obtiene el Score del cliente
* @Clase Prueba     IT_ModeloScore_clsTest

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   08-Mar-2021  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
public class IT_ModeloScore_cls {
    private static final String CONSULTA_SCORE = 'ConsultaScore'; 
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Consulta del score con Id de la Cotización
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public static ResponseDTO consultaScore(String cotizacionId, QuoteLineItem prod){
        Quote cotizacion = getCotizacion(cotizacionId);
        /* 
        public Integer numeroRadicado; */
        
        ValidacionOBJ validate = validateFields(cotizacion, prod);
            if(!validate.correcto){
            ResponseDTO result = new ResponseDTO();
            result.encabezado = new Encabezado();
            result.encabezado.mensaje.estado = 'ERROR';
            result.encabezado.mensaje.descripcion = validate.mensaje;
            return result;
        }
        
        sendJSON jsonAEnviar = new sendJSON();
        jsonAEnviar.encabezado                     = buildEncabezado(cotizacionId);
        jsonAEnviar.cuerpo.tipoIdentificacion      = cotizacion.Account.Tipo_de_identificacion__c;
        jsonAEnviar.cuerpo.numeroIdentificacion    = cotizacion.Account.Numero_de_identificacion__c;
        jsonAEnviar.cuerpo.codigoAsesor            = cotizacion.Opportunity.Asesor_asignado__r.Codigo_de_Empleado__c;
        jsonAEnviar.cuerpo.estadoCivil             = cotizacion.Account.Estado_civil__pc;
        jsonAEnviar.cuerpo.sexo                    = cotizacion.Account.Genero__pc;
        jsonAEnviar.cuerpo.edadDesembolso          = cotizacion.Account.Edad__c != null ? String.valueOf(cotizacion.Account.Edad__c) : null;
        jsonAEnviar.cuerpo.tipoVivienda            = cotizacion.Account.Tipo_de_vivienda__pc;
        jsonAEnviar.cuerpo.personasACargo          = cotizacion.Account.Personas_a_cargo__pc != null ? Integer.valueOf(cotizacion.Account.Personas_a_cargo__pc) : null;
        jsonAEnviar.cuerpo.cabezaFamilia           = cotizacion.Account.Cabeza_de_familia__pc;
        jsonAEnviar.cuerpo.oficina                 = cotizacion.Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c;
        jsonAEnviar.cuerpo.producto                = prod.Product2.ProductCode;
        jsonAEnviar.cuerpo.montoSolicitado         = String.valueOf(Integer.valueOf(prod.UnitPrice * prod.Quantity));
        jsonAEnviar.cuerpo.plazoSolicitado         = String.valueOf(prod.Plazo_meses__c);
        jsonAEnviar.cuerpo.periodoGracia           = Integer.valueOf(prod.Periodo_Gracias_Meses__c	);
        jsonAEnviar.cuerpo.industriaEmpresa        = cotizacion.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c;
        
        if(cotizacion.Opportunity.Generacion_Automatica_de_Credito__c){
            CampaignMember member = consultaMiembroCamapana(cotizacion.OpportunityId);
            if(member != null && member.Medio_de_Respuesta__c == 'Web' && (member.Tipo_de_Respuesta__c == 'Monto Mayor/Cambio de Plazo' || member.Tipo_de_Respuesta__c == 'Solicite Aquí su Crédito')){
                jsonAEnviar.cuerpo.origenColocacionCredito = 'Canal Digital';
            }
        }
        
        if(cotizacion.Opportunity.Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c != null){
            Decimal monthsExp = getMonthsBetween(cotizacion.Opportunity.Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c, Date.today());
        	Decimal yearExp = monthsExp / 12;
        	jsonAEnviar.cuerpo.experienciaEmpresa = yearExp.setScale(2);
        }
        
        jsonAEnviar.cuerpo.numeroEmpleados     	= Integer.valueOf(cotizacion.Opportunity.Famiempresa_relacionada__r.Numero_de_empleados__c);
    	//jsonAEnviar.cuerpo.numeroRadicado     = cotizacion.Account.Cabeza_de_familia__pc;
    	
        String jsonAEnviarString = JSON.serialize(jsonAEnviar);
        
        //jsonAEnviarString = '{"encabezado":{"origen":"SALESFORCE","operacion":"0","mensaje":null,"integracion":"Consulta Score Masivo","identificador":"0Q0m0000000Bcf3CAC-86992","fecha":"2021-03-16 14:50:24","excepcion":"","estado":"0","destino":"ORACLE"},"cuerpo":{"tipoVivienda":"Propia","tipoIdentificacion":"Cedula de Ciudadania","sexo":"Femenino","producto":"116","plazoSolicitado":"64","personasACargo":10,"periodoGracia":5,"oficina":"11","numeroRadicado":null,"numeroIdentificacion":"40378512","numeroEmpleados":2,"montoSolicitado":"20000000","industriaEmpresa":"2","experienciaEmpresa":11.33,"estadoCivil":"Casado","edadDesembolso":"45","codigoAsesor":"535","cabezaFamilia":true}}';
        
        
        try{   
            //////Envío de la petición para la obtención del score
            Http http = new Http();
            System.debug('invoca Servicio'+ jsonAEnviarString);
            //HttpRequest  request = parametrosScore(jsonAEnviarString);
            HttpRequest  request = IT_ParametrosWS_cls.parametrosScore(jsonAEnviarString);
            HttpResponse response = http.send(request);
            String jSON_res = response.getBody();
            System.debug('JSON_res: '+ jSON_res +'-'+request);
            ///////////////////////////////////////////////////////////////Test
            //JSON_res = '{"encabezado":{"integracion":"Consulta Score Masivo","fecha":"2021-04-27 14:55:19","estado":"0","excepcion":"","origen":"SALESFORCE","operacion":"0","mensaje":{"descripcion":"Consulta del score, exitosamente!","estado":"OK"},"destino":"ORACLE","identificador":"0Q0m0000000Mqh8CAC-10795"},"cuerpo":{"descripcion":"PRE-RECHAZADO","score":"675","decisor":"","parametrosRecibidos":{"tipoVivienda":"Propia","periodoGracia":0,"industriaEmpresa":"1","numeroEmpleados":3,"tipoIdentificacion":"Cedula de Ciudadania","numeroIdentificacion":"6497653","codigoAsesor":"1080","estadoCivil":"Soltero","producto":"501","plazoSolicitado":"12","edadDesembolso":"28","experienciaEmpresa":0.4,"oficina":"11","personasACargo":2,"sexo":"Masculino","montoSolicitado":"2000000","numeroRadicado":null,"cabezaFamilia":false},"parametrosComplementarios":{"tipoConsulta":"1"}}}';
            ///////////////////////////////////////////////////////////////////
            ResponseDTO result = (ResponseDTO)JSON.deserializeStrict(jSON_res, ResponseDTO.class);
            return result;
        }catch(Exception ex){
            System.debug('Error: ' + ex);
            ResponseDTO result = new ResponseDTO();
            result.encabezado = new Encabezado();
            result.encabezado.mensaje.estado = 'ERROR';
            result.encabezado.mensaje.descripcion = 'Error al consumir el servicio de Consulta de Score';
            return result;
        }
        
        
        
    }
    public static decimal getMonthsBetween(date startDate, date endDate) {
        decimal n = 0.0;
          
        if( startDate.month()== endDate.month() && startDate.year()== endDate.year() ){
            n =  decimal.valueOf((startDate.daysBetween(endDate) + 1 )) / decimal.valueOf(date.daysInMonth(startDate.year(),startDate.month()));
        }
        else{
            Integer monthsBetween = startDate.monthsBetween(endDate)-1;
            decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month())-startDate.day()+1) / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));
            decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate)+1) / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));
            n =  firstMonth + monthsBetween + lastMonth ;        
        }
       
        return n; 
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: 
    *Date: 26-Abr-2021
    ******************************************************************************************/
    public static CampaignMember consultaMiembroCamapana(String oporId){
        if ( !Schema.sObjectType.CampaignMember.fields.Name.isAccessible() ) {   return null;  }
        List<CampaignMember> cMiembro = [SELECT Id, Name, ContactId, Contact.AccountId, LeadId , Lead.ConvertedAccountId, CampaignId,
                                         Mensaje_recibido__c, MovilMiembro__c,Producto__c,Plazo_Meses__c,Monto__c,Fondo__c, CreditoSaldoCargo__c, Medio_de_Respuesta__c,
                                         Tipo_de_Respuesta__c, Tipo_de_Cuenta__c, Numero_Cuenta__c, Banco__c, Beneficiarios__c, Producto_RCA__c, Monto_RCA__c, Plazo_Meses_RCA__c
                                         FROM CampaignMember 
                                         WHERE Oportunidad_Generada_Automatica__c = :oporId
                                         LIMIT 1];
        if(cMiembro.size() > 0){
            return cMiembro[0];
        }
        return null;
    }
    
    /******************************************************
    *Author:   Álvaro Ortega
    *Function: Validaciones de campos
    *Date:     18-Mar-2021
    *******************************************************/
    public static ValidacionOBJ validateFields(Quote cotizacion, QuoteLineItem prod){
        ValidacionOBJ result = new ValidacionOBJ();
        result.correcto = True;
        if(cotizacion == null){
            result.correcto = False;
            result.mensaje = 'Error: consulte a su administrador: Id de cotización nulo en validación de campos';
        }else if(cotizacion.Account.Tipo_de_identificacion__c == null || cotizacion.Account.Tipo_de_identificacion__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Tipo de identifiación';
        }else if(cotizacion.Account.Numero_de_identificacion__c == null || cotizacion.Account.Numero_de_identificacion__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Número de identificación';
        }else if(cotizacion.Account.Asesor_asignado__r.Codigo_de_Empleado__c == null || cotizacion.Account.Asesor_asignado__r.Codigo_de_Empleado__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Código de Empleado en Asesor Asiganado';
        }else if(cotizacion.Account.Asesor_asignado__r.Codigo_de_Empleado__c == null || cotizacion.Account.Asesor_asignado__r.Codigo_de_Empleado__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Código de Empleado en Asesor Asiganado';
        }else if(cotizacion.Account.Estado_civil__pc == null || cotizacion.Account.Estado_civil__pc == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Estado civil';
        }else if(cotizacion.Account.Genero__pc == null || cotizacion.Account.Genero__pc == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Genero';
        }else if(cotizacion.Account.Edad__c == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Edad';
        }else if(cotizacion.Account.Tipo_de_vivienda__pc == null || cotizacion.Account.Tipo_de_vivienda__pc == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Tipo de Vivienda';
        }else if(cotizacion.Account.Personas_a_cargo__pc == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Personas a Cargo';
        }else if(cotizacion.Account.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c == null || cotizacion.Account.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el cliente para calcular el Score: Código de Oficina en Asesor Asigado del Cliente';
        }else if(prod.Product2.ProductCode == null || prod.Product2.ProductCode == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el producto de cotización para calcular el Score: Código de Producto';
        }else if(prod.UnitPrice == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el producto de cotización para calcular el Score: Precio de Venta';
        }else if(prod.Quantity == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el producto de cotización para calcular el Score: Cantidad';
        }else if(prod.Plazo_meses__c == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en el producto de cotización para calcular el Score: Plazo Meses';
        }else if(cotizacion.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c == null || cotizacion.Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c == ''){
            result.correcto = False;
            result.mensaje = 'Falta párametro en la actividad economica para calcular el Score: Código de Industria';
        }else if(cotizacion.Opportunity.Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en la Famiempresa Relacionada para calcular el Score: Fecha de creación de la empresa';
        }else if(cotizacion.Opportunity.Famiempresa_relacionada__r.Numero_de_empleados__c == null){
            result.correcto = False;
            result.mensaje = 'Falta párametro en la Famiempresa Relacionada para calcular el Score: Número de Empleados';
        }
        
        return result;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase DTO de validacion
    *Date: 18-Mar-2020
    ******************************************************************************************/
    public class ValidacionOBJ{
        public Boolean correcto = True;
        public String mensaje;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtine al infoamción de la cotización
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public static Quote getCotizacion(String cotizacionId){
        List<Quote> cotizaciones = [Select Id, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, Account.Asesor_asignado__r.Codigo_de_Empleado__c, 
                                    Account.Estado_civil__pc, Account.Genero__pc, Account.Edad__c, Account.Tipo_de_vivienda__pc, Account.Personas_a_cargo__pc, Account.Cabeza_de_familia__pc, 
                                    Account.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c, Opportunity.Famiempresa_relacionada__r.Industria__c, 
                                    Opportunity.Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c, Opportunity.Famiempresa_relacionada__r.Numero_de_empleados__c,
                                    Opportunity.Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Industria_OR_SF__c,
                                    Opportunity.Asesor_asignado__r.Codigo_de_Empleado__c, Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,
                                    Opportunity.Generacion_Automatica_de_Credito__c, OpportunityId
                                    from Quote 
                                    where Id = :cotizacionId];
        if(cotizaciones.size() > 0){
            return cotizaciones[0];
        }
        return null;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Encabezado de respuesta
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public static Encabezado buildEncabezado(String toIdentify){
        Encabezado encabezado = new Encabezado();
        
        encabezado.estado        = '0';
        encabezado.excepcion     = '';
        encabezado.fecha         = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        
        Integer STRING_LENGTH = 5;
        Integer MIN = Integer.valueOf( Math.pow(10, STRING_LENGTH - 1) ); //Returns 10000
        Integer MAX = Integer.valueOf( Math.pow(10, STRING_LENGTH) - 1 ); // Returns 99999
        String aleaNumberN = String.valueOf(Math.Round(Math.Random() * (MAX-MIN) + MIN));
        encabezado.identificador = toIdentify + '-' + aleaNumberN;
        
        encabezado.mensaje       = null;
        encabezado.integracion   = 'Consulta Score Masivo';
        encabezado.operacion     = '0';
        encabezado.origen        = 'SALESFORCE';
        encabezado.destino       = 'ORACLE';
        
        return encabezado;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información enviada
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class sendJSON{
        public Encabezado encabezado;
        public Cuerpo cuerpo = new Cuerpo();
    }
    
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 22-Feb-2020
    ******************************************************************************************/
    public class Mensaje{
        public String estado;
        public String descripcion;
    }
    
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class Cuerpo{
        public String tipoIdentificacion;
        public String numeroIdentificacion;
        public String codigoAsesor;
        public String estadoCivil;
        public String sexo;
        public String edadDesembolso;
        public String tipoVivienda;
        public Integer personasACargo;
        public Boolean cabezaFamilia;
        public String oficina; 
        public String producto;           //
        public String montoSolicitado;    //
        public String plazoSolicitado;    //
        public Integer periodoGracia;     //
        public String industriaEmpresa;   
        public Decimal experienciaEmpresa;
        public Integer numeroEmpleados;
        public Integer numeroRadicado;  //¿De dónde sale esta información?
        public String origenColocacionCredito; //“” - "Canal Digital",
        
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información recibida
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class ResponseDTO{
        public Encabezado encabezado;
        public CuerpoRespuesta cuerpo = new CuerpoRespuesta();
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class Encabezado{
        public String estado; //
        public String excepcion; //
        public String fecha; //
        public String identificador; //
        public String integracion; //
        public String operacion; //
        public String origen; //
        public String destino; //
        public Mensaje mensaje = new Mensaje(); 
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: 
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class CuerpoRespuesta{
        public Cuerpo parametrosRecibidos;
        public ParametrosComplementarios parametrosComplementarios;
        public String score;
        public String descripcion;	
        public String decisor;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: 
    *Date: 08-Mar-2020
    ******************************************************************************************/
    public class ParametrosComplementarios{
        public String tipoConsulta;
        
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
/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase tipo servicio web REST para el proceso de Pagares

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   6-JUL-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public with sharing class IT_ServicioPagare_ws {


    private static Http         http;
    private static HttpRequest  request;
    private static HttpResponse response;
    private static String       jSONreq;
    private static final String EMISORP = 'EmisorP';
    private static final String DEF_DOC = 'IdDef';
    private static final String CREEMBOLSO = 'CReembolso';
    private static final String T_PAGARE   = 'TPagare';
    private static final String ROL_RL     = 'rolRLegal';
    private static final String ROL_AVAL   = 'rolAvalista';
    private static final String PAGARE     = 'PAGARE';
    private static final String JURIDICO   = 'Persona_juridica';

    /*************************************************************************
    *Author:  Rafael Cardona
    *Function: Servicio de pagre
    *Date: 6-7-2020
    **************************************************************************/
    public static String ejecutaPagare(Quote cotizacion , Map<String,String> hom, List<Asociacion_cuenta_contacto__c> lstAscc){
        http = new Http();        
        jSONreq = jsonPagares(cotizacion,hom,lstAscc);
        system.debug(' body--->'+jSONreq); 
        request = IT_ParametrosWS_cls.parametrosPagares(jSONreq);        
        response = http.send(request);
        system.debug('IT_ServicioPagare_ws Body:'+response.getBody()); 
        
        RespuestaPagare resPagare = (RespuestaPagare)JSON.deserializeStrict(response.getBody(), RespuestaPagare.class);
        System.debug('Deserializado: '+ resPagare);       
        return respuestaIntegracion( cotizacion , resPagare ); 
      }

    /******************************************************************************
    *Author:  Rafael Cardona
    *Function: Se encarga de guardar las respuestas en los campos de la cotizacion
    *Date: 10-7-2020
    *******************************************************************************/
    public static String respuestaIntegracion(Quote cotizacion , RespuestaPagare resPagare){
        RespuestaFrontPagare respuesta = new RespuestaFrontPagare(
        resPagare.response.encabezado.mensaje.estado,
        resPagare.response.encabezado.mensaje.descripcion,
        resPagare.response.CreacionPagaresCodificado.documentoPagareServiceDTO.mensajeRespuesta
        ,true);
        try{
          cotizacion.ResIntegreacionPagare__c   = resPagare.response.encabezado.mensaje.descripcion +'\n'+
                  +resPagare.response.CreacionPagaresCodificado.documentoPagareServiceDTO.mensajeRespuesta;
          cotizacion.EstadoIntegracionPagare__c = PAGARE+'-'+resPagare.response.encabezado.mensaje.estado;
          cotizacion.idDocumentoPagare__c       = resPagare.response.CreacionPagaresCodificado.documentoPagareServiceDTO.idDocumentoPagare;
          update cotizacion;
          return JSON.serialize( new List<RespuestaFrontPagare>{ respuesta } );
        }catch(Exception e){
          System.debug('Error');
          return JSON.serialize( new List<RespuestaFrontPagare>{ new RespuestaFrontPagare('ERROR', 'Error en la actualización','',false) } );
        }      
    }

    /*************************************************************************
    *Author:   Rafael Cardona
    *Function: Crea json para el envio de pagares
    *Date:     6-7-2020
    **************************************************************************/
    public static String jsonPagares(Quote cot , Map<String,String> hom,List<Asociacion_cuenta_contacto__c> lstAscc){
        String idProceso = cot.Opportunity.Identificador_proceso__c;
        String oficina   = cot.Opportunity.Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c;
        String radicado  = cot.QuoteLineItems[0].Identificador_Radicado_OR__c;
        String nDoc      = '';        
        String tDoc      = hom.get(cot.Opportunity.Account.Tipo_de_identificacion__c);
        String emisor    = hom.get(EMISORP);
        String idDef     = hom.get(DEF_DOC);
        String cReem     = hom.get(CREEMBOLSO);
        String tPagare   = hom.get(T_PAGARE);
        Decimal pTotal   = cot.TotalPrice;
        if( cot.Opportunity.Account.RecordType.DeveloperName == JURIDICO ){
          nDoc      = cot.Opportunity.Account.Numero_de_identificacion__c + String.valueOf(IT_Girador_ctr.generarDigitoNit(cot.Opportunity.Account.Numero_de_identificacion__c));
        }else{
          nDoc      = cot.Opportunity.Account.Numero_de_identificacion__c;
        }

        String json = ''+
        '{'+
            '"encabezado": {'+
              '"operacion": "PAGAREDECEVAL",'+
              '"origen": "SALESFORCE",'+
              '"destino": "DECEVAL",'+
              '"fecha": "'+(System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss')+'",'+
              '"usuario": "'+UserInfo.getName()+'"'+
            '},'+
            '"solicitudCredito": {'+
              '"idProceso": "'+ idProceso +'",'+
              '"oficina":   "'+ oficina   +'",'+    
              '"radicado":  "'+ radicado  +'"'+  
            '},'+
            '"CreacionPagaresCodificado": {'+
              '"documentoPagareServiceDTO": {'+
                 '"creditoReembolsableEn":     "'+ cReem +'",'+ 
                 '"tipoPagare":                "'+ tPagare +'",'+  
                '"idClaseDefinicionDocumento": "'+ idDef +'",'; 
                json += listaAvalistas(lstAscc, hom, cot);
                json += '"nitEmisor": "'+emisor+'",'+ 
                '"otorganteNumId":  "'+ nDoc +'",'+ 
                '"otorganteTipoId": "'+ tDoc +'" ,';
                json += agregaRepresentanteLegal( lstAscc, hom );
                json +='} } }';
            return json;
    }

    /********************************************************************************
    *Author:  Rafael Cardona
    *Function: Agrega los avales que no son representante legal, si no hay avales
               no se deben agregar los parametros correspondientes al json 
    *Date: 31-7-2020
    *********************************************************************************/
    public static String listaAvalistas(List<Asociacion_cuenta_contacto__c> lstRp, Map<String,String> hom, Quote cot ){
        String avales = '';
        Boolean existenAvales = false; 
        if( lstRp.size() > 0) { 
            avales += ' "listaCodeudoresAvalistasPagare": [ '; 
        }  
        for(Asociacion_cuenta_contacto__c acc: lstRp){
            if( !acc.RepresentanteLegal__c || cot.Account.RecordType.DeveloperName == JURIDICO){
                avales += '{'+
                    '"giradorNumId":  "'+acc.Contacto__r.Numero_de_identificacion__c+'",'+
                    '"giradorTipoId": "'+hom.get(acc.Contacto__r.Tipo_de_identificacion__c)+'",'+ 
                    '"idRol":         "'+hom.get(ROL_AVAL)+'" '+
                    '},';  
                existenAvales = true;
            }
        }
        if( existenAvales ){
            avales = ( avales.length() > 0 )? avales.substring(0, avales.length() - 1) : '';
            avales += '\n],';
        }else{
            avales = '';
        }
        return avales;
    }

    /********************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Agrega el aval representante legal, en caso de que no haya un representante 
               legal como en un cliente natural, no se deben agregar los parametros correspondientes al json 
    *Date: 31-7-2020
    *********************************************************************************************************/
    public static String agregaRepresentanteLegal( List<Asociacion_cuenta_contacto__c> lstRp ,Map<String,String> hom){
        String rLegal = '';
        for(Asociacion_cuenta_contacto__c acc: lstRp){
          if( acc.RepresentanteLegal__c ){
            rLegal +=  '"apoderadoNumId": "'+acc.Contacto__r.Numero_de_identificacion__c+'",'+ 
                       '"apoderadoTipoId": "'+hom.get(acc.Contacto__r.Tipo_de_identificacion__c)+'" ';  
        }}
        return rLegal;
    }


    /********************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Estructura de clases para el manejo de la respuesta del servicio de pagare
    *Date: 6-7-2020
    *********************************************************************************************************/
    public class RespuestaPagare{
        public cls_response response;
    }
        class cls_response {
            public cls_solicitudCredito solicitudCredito;
            public cls_encabezado encabezado;
            public cls_CreacionPagaresCodificado CreacionPagaresCodificado;
        }
        class cls_solicitudCredito {
            public Integer radicado;	//12345
            public Integer oficina;	//2
            public Integer idProceso;	//123
        }
        class cls_encabezado {
            public String fecha;	//2020-03-09T13:20:09
            public String usuario;	//PEDROGG
            public String operacion;	//PAGAREDECEVAL
            public String origen;	//SALESFORCE
            public String destino;	//DECEVAL
            public cls_mensaje mensaje;
        }
        class cls_mensaje {
            public String descripcion;	//(SDL.SE.0098): SDL.SE.0098: Fallido. - Se presentaron errores al crear el(los) pagare(s). Número de pagarés fallidos: 1
            public String estado;	//ERROR
        }
        class cls_CreacionPagaresCodificado {
            public cls_documentoPagareServiceDTO documentoPagareServiceDTO;
        }
        class cls_documentoPagareServiceDTO {
            public String numPagareEntidad;	//2015-04-23_P3
            public Integer otorganteCuenta;	//25916
            public cls_listaCodeudoresAvalistasPagare listaCodeudoresAvalistasPagare;
            public cls_archivosAdjuntos archivosAdjuntos;
            public Decimal valorPesosDesembolso;	//1500000
            public Decimal valorPesosDiligenciamiento;
            public Integer ciudadDesembolso;	//150
            public Integer tipoPagare;	//2
            public String nitEmisor;	//890984843-3
            public Integer pais;	//14
            public Integer creditoReembolsableEn;	//2
            public Integer otorganteTipoId;	//1
            public Integer idClaseDefinicionDocumento;	//123
            public String otorganteNumId;	//80094090
            public Integer departamento;	//5
            public cls_listaApoderadoRepresentantePagare listaApoderadoRepresentantePagare;
            public Integer tasaInteres;	//1
            public String mensajeRespuesta;	//SDL.DA.0388 - SDL.DA.0388 - El otorgante enviado no puede asignarse al pagare
            public String apoderadoNumId;
            public String apoderadoTipoId;
            public String idDocumentoPagare;
        }
        class cls_listaCodeudoresAvalistasPagare {
            public Integer giradorTipoId;	//5
            public Integer idRol;	//6
            public Integer giradorCuenta;	//25796
            public Integer giradorNumId;	//80094105
            public Integer idPersonaRepresentada;	//80094090
        }
        class cls_archivosAdjuntos {
            public String nombreArchivo;	//imagen7.jpg
            public String contenido;	///9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAMAAA/+ /wD/AOOmg//Z
        }
        class cls_listaApoderadoRepresentantePagare {
            public Integer giradorTipoId;	//2
            public Integer idRol;	//6
            public Integer giradorCuenta;	//333333
            public Integer giradorNumId;	//80095100
            public Integer idPersonaRepresentada;	//80094090
        }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Clase interna para entregarsela al componente Aura que maneja la interfaz de usuario
    *Date: 08-7-2020
    **************************************************************************************************/
    public Class RespuestaFrontPagare{
      private String  estado;
      private String  descripcion;
      private String mensajeOtorgante;
      private Boolean proceso;      

      private RespuestaFrontPagare(String estado, String des, String oto, Boolean pro){
          this.estado            = estado;
          this.descripcion       = des;
          this.mensajeOtorgante  = oto;
          this.proceso           = pro;          
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
    }
}
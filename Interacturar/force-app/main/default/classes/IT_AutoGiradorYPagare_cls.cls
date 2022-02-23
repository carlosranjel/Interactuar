public with sharing class IT_AutoGiradorYPagare_cls implements Queueable, Database.AllowsCallouts {
    private String oportunidadId;
    private String cotizacionId;

    private CampaignMember member;

    private String proceso;

    public IT_AutoGiradorYPagare_cls(String proc, String IdOpp, CampaignMember men){
        this.proceso = proc;
        this.oportunidadId = IdOpp;
        this.member = men;
    }

    public IT_AutoGiradorYPagare_cls(String proc, String IdOpp, String IdCoti, CampaignMember men){
        this.proceso = proc;
        this.cotizacionId = IdCoti;
        this.oportunidadId = IdOpp;
        this.member = men;
    }

    public void execute(QueueableContext context) {
        if(proceso == 'Inicio'){
            Quote coti = obtenerCotizacion(oportunidadId);
            if(coti != null){
                cotizacionId = coti.Id;
                Respuesta rGirador = crearActualizarGirador(cotizacionId);
                if(rGirador.estado == 'Correcto'){
                    if(!Test.isRunningTest()){
                        IT_AutoGiradorYPagare_cls nextJob = new IT_AutoGiradorYPagare_cls('Pagaré', oportunidadId, cotizacionId, member);
                        Id jobID = System.enqueueJob(nextJob);
                    }

                }else{
                    IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Crear Actualizar Girador: ' + rGirador.mensaje);
                    IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', rGirador.mensaje, 'Crear Actualizar Girador');
                    resFinal.miembro = member;

                    IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
                }
            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Crear Actualizar Girador: No se encontró una Cotización asociada a la Oportunidad Creada');
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', 'No se encontró una Cotización asociada a la Oportunidad Creada', 'Crear Actualizar Girador');
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);

            }
        }else if(proceso == 'Pagaré'){
            Respuesta rPagare = crearPagare(cotizacionId);
            if(rPagare.estado == 'Correcto'){
                if(!Test.isRunningTest()){
                    IT_AutoGiradorYPagare_cls nextJob = new IT_AutoGiradorYPagare_cls('OnCredit', oportunidadId, cotizacionId, member);
                    Id jobID = System.enqueueJob(nextJob);
                }

            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Crear Pagaré: ' + rPagare.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', rPagare.mensaje, 'Crear Pagaré');
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
            }
        }else if(proceso == 'OnCredit'){
            Respuesta rOnCredit = onCredit(oportunidadId);
            if(rOnCredit.estado == 'Correcto'){
                IT_GeneracionAutomaticaCredito.logIntegracion('Exitoso','Aldeamo','Enviado a OnCredit con éxito: ' + rOnCredit.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Correcto', 'Enviado a OnCredit con éxito: ' + rOnCredit.mensaje, 'OnCredit');
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);

            }else{
                IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','OnCredit: ' + rOnCredit.mensaje);
                IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', rOnCredit.mensaje, 'OnCredit');
                resFinal.miembro = member;

                IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
            }
        }
    }

    public Respuesta crearActualizarGirador(String idCotizacion) {
        String stringGiradores;
        List<Girador> giradores;
        try{   
            stringGiradores = IT_Girador_ctr.listadoGiradores(idCotizacion);
            giradores = (List<Girador>)JSON.deserialize(stringGiradores, List<Girador>.class );
        }catch(Exception ex){
            //return new Respuesta('', '');
            return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
        }

        if( giradores[0].nombre != null){
            //Todo bien
            String stringRespuesta;
            RespuestaGlobal respuesta;
            try{   
                stringRespuesta = IT_Girador_ctr.integraGirador(idCotizacion);
                respuesta = (RespuestaGlobal)JSON.deserialize(stringRespuesta, RespuestaGlobal.class);
            }catch(Exception ex){
                return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
            }
            
            if(respuesta.mensajeGlobal == 'GIRADORES-ERROR' ){return new Respuesta('Error', 'INCONSISTENCIA: Revise los mensajes de respuesta');
            }else if(respuesta.mensajeGlobal == 'ERROR'){return new Respuesta('Error', 'ERROR: Por favor consulte a su administrador');
            }else if(respuesta.mensajeGlobal == 'GIRADORES-OK' ){return new Respuesta('Correcto', 'GIRADORES ENVIADOS: Giradores enviados exitosamente');
            }else{return new Respuesta('Error', 'ERROR: Por favor consulte a su administrador');
            }
        }else if(!giradores[0].proceso && giradores[0].mensaje == 'SincOpp' ){return new Respuesta('Error', 'SINCRONIZACION OPORTUNIDAD: Verifique la sincronizacion en Oportunidad');
        }else if(!giradores[0].proceso && giradores[0].mensaje == 'Radicado' ){return new Respuesta('Error', 'RADICADO: Verifique el radicado en el producto de cotización');
        }else if(!giradores[0].proceso && giradores[0].mensaje == 'EB' ){return new Respuesta('Error', 'ETAPA BLOQUEADA DE LA OPORTUNIDAD: No es posible enviar giradores en la etapa actual de la oportunidad');
        }else{return new Respuesta('Error', 'ERROR: Por favor comuniquese con su administrador');
        }
    }

    public Respuesta crearPagare(String idCotizacion) {
        String stringPagare;
        List<RespuestaFrontPagare> listaPagare;
        try{
            Quote cotiz = consultaCotizacion(idCotizacion);
            if(cotiz.idDocumentoPagare__c != null){return new Respuesta('Correcto', 'Ya existe Pagaré para esta Cotización');
            }else{
                stringPagare = IT_Pagare_ctr.creacionPagare(idCotizacion);
                listaPagare = (List<RespuestaFrontPagare>)JSON.deserialize(stringPagare, List<RespuestaFrontPagare>.class );
            }
        }catch(Exception ex){
            return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
        }
        if(listaPagare[0].estado != null && listaPagare[0].estado != 'ERROR' && listaPagare[0].estado != 'REUSAR' ){return new Respuesta('Correcto', listaPagare[0].estado + ': Ejecutado exitosamente');
        }else if(listaPagare[0].estado != null && listaPagare[0].estado == 'ERROR' && listaPagare[0].estado != 'REUSAR' ){return new Respuesta('Error', listaPagare[0].estado + ': Revise los mensajes de error');
        }else if(listaPagare[0].estado != null && listaPagare[0].estado == 'REUSAR' && listaPagare[0].estado != 'ERROR' ){return new Respuesta('Error', 'REUSAR PAGARE: No se permite ejecutar servicio de pagare');
        }else{return new Respuesta('Error', 'ERROR: Por favor comuniquese con su administrador');
        }
    }
    
    public static Quote consultaCotizacion(String idCotizacion){
        return [SELECT Id, idDocumentoPagare__c,
        (SELECT Identificador_Radicado_OR__c  FROM QuoteLineItems )
        FROM Quote WHERE id =: idCotizacion];
    }

    public Respuesta onCredit(String idOportunidad) {
        String stringOncredit;
        ResponseURL resp;
        try{ 
            System.debug(idOportunidad);
            stringOncredit = IT_Oncredit_ctr.firmantes(idOportunidad);
            resp = (ResponseURL)JSON.deserialize(stringOncredit, ResponseURL.class );
        }catch(Exception ex){
            return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
        }
        if(resp.proceso){return new Respuesta('Correcto', 'Url Construida', resp.url);
        }else{return new Respuesta('Error', 'La Url no fue construida');
        }
    }

    public Quote obtenerCotizacion(String idOportunidad){
        List<Quote> cotis =[select Id 
                            from Quote
                            where OpportunityId = :idOportunidad
                            order by CreatedDate desc
                            limit 1];
        
        if(cotis.size() > 0){ return cotis[0]; }
        else{return null; }
                    
    }

    public class ResponseURL{
        Boolean proceso;
        String  url;
        /*public ResponseURL(Boolean bo, String url){
            this.proceso = bo;
            this.url     = url;
        }*/
    }

    public Class Girador{
        private String nombre;
        private String documento;
        private String tipo;
        private String representanteLegal;
        private Boolean proceso; 
        private String mensaje;

        /*private Girador(String nom, String doc, String tip,String rep){
            this.nombre             = nom;
            this.documento          = doc;
            this.tipo               = tip;
            this.representanteLegal = rep;
        }
        private Girador(Boolean proceso, String mensaje){
            this.proceso  = proceso;
            this.mensaje  = mensaje;
        }*/
    }

    public Class RespuestaGlobal{
      private String mensajeGlobal;
      private List<RespuestaGirador> lista;
      /*private RespuestaGlobal(String res, List<RespuestaGirador> lst){
        this.mensajeGlobal = res;
        this.lista         = lst;
      }*/
    }

    public Class RespuestaGirador{
      private String  estado;
      private String  descripcion;
      private String  nomGirador;
      private String  tipoGirador;
      private Boolean proceso;

      /*private RespuestaGirador(String estado, String des, String nom, String ti,Boolean proceso){
          this.estado      = estado;
          this.descripcion = des;
          this.nomGirador  = nom;
          this.tipoGirador = ti;
          this.proceso     = proceso;
      }*/
    }

    public Class RespuestaFrontPagare{
      private String  estado;
      private String  descripcion;
      private String mensajeOtorgante;
      private Boolean proceso;      

      /*private RespuestaFrontPagare(String estado, String des, String oto, Boolean pro){
          this.estado            = estado;
          this.descripcion       = des;
          this.mensajeOtorgante  = oto;
          this.proceso           = pro;          
      }*/
    }

    public Class Respuesta{
        public String estado;
        public String mensaje;
        public String url;
        public String lugarError;

        public Respuesta(String est, String men){
            this.estado  = est;
            this.mensaje = men;
        }

        public Respuesta(String est, String men, String ur){
            this.estado  = est;
            this.mensaje = men;
            this.url = ur;
        }
    }
}
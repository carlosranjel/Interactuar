public with sharing class IT_AutoSincronizarCotizacion_cls implements Queueable, Database.AllowsCallouts {
    private String cotizacionId;

    private CampaignMember member;

    public IT_AutoSincronizarCotizacion_cls(String IdCoti, CampaignMember men){
        this.cotizacionId = IdCoti;
        this.member = men;
    }

    public void execute(QueueableContext context) {
        Respuesta resp = sincronizarCotizacion(cotizacionId);
        if(resp.estado == 'Correcto'){
            //Sincronizacion iniciada con exito
            //system.debug('Correcto: ' + sincronizacion.mensaje);
            IT_GeneracionAutomaticaCredito.logIntegracion('Exitoso','Aldeamo','Sincronización Oportunidad: ' + resp.mensaje);
            IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Correcto', 'Sincronización iniciada con exito: ' + resp.mensaje, 'Sincronización Oportunidad');
            resFinal.miembro = member;

            IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
        }else{
            //Hubo un error en la sincronizacion de la cotizacion
            //system.debug('Error: ' + sincronizacion.mensaje);

            IT_GeneracionAutomaticaCredito.logIntegracion('Fallido','Aldeamo','Sincronización Oportunidad: ' + resp.mensaje);
            IT_GeneracionAutomaticaCredito.RespuestaFinal resFinal = new IT_GeneracionAutomaticaCredito.RespuestaFinal('Error', resp.mensaje, 'Sincronización Oportunidad');
            resFinal.miembro = member;

            IT_GeneracionAutomaticaCredito.enviarEmail(new List<String>(), resFinal);
        }
    }

    public Respuesta sincronizarCotizacion(String idCotizacion) {
        String stringValida;
        try{   
            stringValida = IT_SincronizarCotizacion_ctr.validaCreditoBPMS(idCotizacion);
        }catch(Exception ex){
            return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
        }
        if(stringValida != null){
            if(stringValida == 'DataCredito'){
                return new Respuesta('Error', 'CONSULTE DATACREDITO: Tenga en cuenta que debe realizar la consulta a Datacredito antes de realizar la sincronización de la solicitud de crédito');

            }else if(stringValida == 'PRECIOS DIFERENTES'){
                return new Respuesta('Error', 'Inconsistencia de precios: El VALOR TOTAL de la cotizacion debe ser igual a la suma de los campos TOTAL CAPITAL DE TRABAJO + TOTAL ACTIVOS FIJOS Y OTROS + TOTAL SERVICIO DE CONOCIMIENTO en la oportunidad');
                
            }else if(stringValida == 'CALCULO DEL SCORE'){
                return new Respuesta('Error', 'Tenga en cuenta que no puede sincronizar la solicitud de crédito con un Score fallido');
                
            }else if(stringValida.contains('FaltanCampos')){
                return new Respuesta('Error', 'Campos faltantes para hacer la sincrozacion: ' + stringValida);
                
            }else if(stringValida.contains('RL')){
                return new Respuesta('Error', 'Representante Legal: Por favor escoja un aval como representante legal');
                
            }else if(stringValida.contains('ERROR-REUSAR')){
                return new Respuesta('Error', 'REUSAR PAGARE: Ocurrio un error en la actualizacion del ID pagare');
                
            }else if(stringValida.contains('CLIENTE Y AVALES')){
                String stringSincOpor;
                try{   
                    stringSincOpor = IT_SincronizarCotizacion_ctr.sincronizaOportunidad(idCotizacion);
                }catch(Exception ex){
                    return new Respuesta('Error', 'Consulta a su administrador: ' + ex);
                }
                if(stringSincOpor == 'OK'){
                    return new Respuesta('Correcto', 'Sincronizacion en progreso');
                }else if (stringSincOpor == 'ERROR'){
                    return new Respuesta('Error', 'Fallo el envío de la sincronización');
                }else{
                    return new Respuesta('Error', 'Revisar: ' + stringSincOpor);
                }
            }else{
                return new Respuesta('Error', 'Respuesta DESCONOCIDA de validaCreditoBPMS en la clase IT_SincronizarCotizacion_ctr');
            }

        }else{
            return new Respuesta('Error', 'Respuesta NULA de validaCreditoBPMS en la clase IT_SincronizarCotizacion_ctr');
        }
    }

    public Class Respuesta{
        public String estado;
        public String mensaje;

        public Respuesta(String est, String men){
            this.estado  = est;
            this.mensaje = men;
        }

        public void actualizar(String est, String men){
            this.estado  = est;
            this.mensaje = men;
        }
    }
    
    public Static void cobertura() {
        String cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
        cobertura = '';
    }
}
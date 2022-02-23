/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class de validaciones para la sincronizacion

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   30-MAR-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
public class IT_SincronizarCotizacion_ctr {



    private static final String SOLICITUD_CREDITO = 'Solicitud_de_credito';
    private static final String PERSONA_NATURAL   = 'Persona_natural';
    private static final String PERSONA_JURIDICA  = 'Persona_juridica';
    private static final String OK                = 'OK';
    private static final String TEL_MOVIL         = 'CLIENTE Y AVALES';
    private static final String REPRESENTANTE_LEGAL = 'RL';
    private static final String REUSAR_PAGARE     = 'REUSAR PAGARE';

        /*********************************************************
    *Author:  Rafael Cardona
    *Function: Se valida que se haya hecho la consulta a BPMS
    *Date: 30-3-2020
    **********************************************************/
    @AuraEnabled
    public static String validaCreditoBPMS(String idCotizacion){
        System.debug('llega cotizacion: '+ idCotizacion);
        Quote cotizacion = consultaCotizacion(idCotizacion);
        List<Id> lstIdCliente = new List<Id>{ cotizacion.Opportunity.AccountId };  
        List<Id> lstIdOpp     = new List<Id>{ cotizacion.OpportunityId };
        List<Account> lstCliente     = IT_GestorDeConsultas_cls.consultaCuenta( lstIdCliente );        
        List<Opportunity> lstOpp     = IT_GestorDeConsultas_cls.consultaOportunidad( lstIdOpp[0] );

        //DECEVAL solitado
        if(cotizacion.OpportunityId != null && cotizacion.Opportunity.RecordType.DeveloperName == SOLICITUD_CREDITO && String.isBlank(cotizacion.Opportunity.Identificador_proceso__c)){
            return 'DataCredito';
        }

        // aplica solo para formulario digital
        if(cotizacion.Opportunity.RecordType.DeveloperName == 'Solicitud_de_credito'){
            if(cotizacion.Opportunity.Account.RecordType.DeveloperName == PERSONA_NATURAL){
                if( ! validaPrecioTotal(cotizacion) ){ 
                    return 'PRECIOS DIFERENTES'; 
                }
                if( ! validaCalculoDelScore(idCotizacion) ){ 
                    return 'CALCULO DEL SCORE'; 
                }
                String validaCampos = validacionParaSincronizar( lstCliente , lstOpp, lstIdOpp);  
                if(validaCampos != ''){
                    return 'FaltanCampos: \n'+validaCampos;
                }
                validaCampos = validaCamposProductoCotizacion(idCotizacion);
                if(validaCampos != '')
                {
                   return 'FaltanCampos: \n'+validaCampos;
                }
            }else if(cotizacion.Opportunity.Account.RecordType.DeveloperName == PERSONA_JURIDICA){
                String validaCampos = validacionParaSincronizar( lstCliente , lstOpp, lstIdOpp);  
                if(validaCampos != ''){
                    return 'FaltanCampos: \n'+validaCampos;
                }
                validaCampos = validaCamposProductoCotizacion(idCotizacion);
                if(validaCampos != '')
                {
                   return 'FaltanCampos: \n'+validaCampos; 
                }
            }
        }

        // String resEncuesta = IT_EncuestaHandler_cls.validacionPreviaSincronizacion( cotizacion );
        // if( resEncuesta != '' ){
        //    return 'Encuesta: \n'+resEncuesta;
        // }

        //DECEVAL solitado
        if( REPRESENTANTE_LEGAL == validaRepresentanteLegal(cotizacion , lstIdOpp)){  
            return REPRESENTANTE_LEGAL;   
        }
        // REUSO PAGARE solitado
        String validaReuso = IT_ReusoPagare.validaReusoPagare(cotizacion, lstIdOpp);
        if( validaReuso.contains( REUSAR_PAGARE ) ){
            return validaReuso;
        }
        // AUTOGESTION 
        IT_MiembroCampania.oportunidadDeMiembroCampana(lstOpp[0]);
        //DECEVAL solitado
        return TEL_MOVIL;   // siempre debe devolver este mensaje para que recuerde los campos que debe verificar   
    }
    
    public static Boolean validaCalculoDelScore(String idCotizacion){
        QuoteLineItem quoteLineItem  = [Select fondo__c, Score__c
                                        from QuoteLineItem 
                                        where QuoteId =: idCotizacion];
        if(quoteLineItem.Score__c == null || quoteLineItem.Score__c == ''){
            return false;
        }
        return true;
    }

    public static Boolean validaPrecioTotal(Quote cotizacion){
        Integer valorCotizacion = 0;
        Integer sumaCamposOpp   = 0;
        Integer totalAFijoOtro  = 0;
        Integer totalCapital    = 0;        
        Integer totalCmiento    = 0;

        if( cotizacion.Opportunity.Total_Capital_de_Trabajo__c != null ){            
            totalCapital   = (Integer)cotizacion.Opportunity.Total_Capital_de_Trabajo__c;
        }        
        if( cotizacion.Opportunity.Total_Activos_Fijos_y_Otros__c != null ){
            totalAFijoOtro = (Integer)cotizacion.Opportunity.Total_Activos_Fijos_y_Otros__c;
        }
        if( cotizacion.Opportunity.Total_Servicios_de_Conocimiento__c != null ){
            totalCmiento = (Integer)cotizacion.Opportunity.Total_Servicios_de_Conocimiento__c;
        }
        valorCotizacion = (Integer)cotizacion.GrandTotal;
        sumaCamposOpp   = totalCapital + totalAFijoOtro + totalCmiento;

        if( valorCotizacion == sumaCamposOpp  )
            return true;
        else
            return false;
    }
    
	public static String validaCamposProductoCotizacion(String idCotizacion){
        System.debug('validaCamposProductoCotizacion cot: '+ idCotizacion);
        QuoteLineItem quoteLineItem  = [Select fondo__c, Score__c
                                        from QuoteLineItem 
                                        where QuoteId =: idCotizacion];
  		String llenar = 'Producto['; 
        llenar += ( quoteLineItem.Fondo__c != null && quoteLineItem.Fondo__c != '' ) ? '' :' - Fondo' ;
        //llenar += ( quoteLineItem.Score__c != null && quoteLineItem.Score__c != '' ) ? '' :' - Score' ;

        if( llenar == 'Producto[' )  llenar = '';
        else   llenar += '], \n';

        return llenar;
    }
    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se validan campos obligatorios antes de la sincronizacion. 
    *          Para los objetos [ Cliente Natural - Oportunidad de credito - Avales - famiEmpresa ]
    *Date: 30-3-2020
    ************************************************************************************************/
    public static String validacionParaSincronizar( List<Account> lstCliente , List<Opportunity> lstOpp , List<Id> lstIdOpp ){
        String faltantes = '';        
        // List<Id> lstIdCliente = new List<Id>();  
        // List<Id> lstIdOpp     = new List<Id>();      
        // lstIdCliente.add( idCuenta );
        // lstIdOpp.add( idOportunidad );
        // List<Account> lstCliente     = IT_GestorDeConsultas_cls.consultaCuenta( lstIdCliente );        
        // List<Opportunity> lstOpp     = IT_GestorDeConsultas_cls.consultaOportunidad( idOportunidad );

        if ( lstCliente[0].RecordType.DeveloperName == 'Persona_natural' && lstOpp[0].RecordType.DeveloperName == 'Solicitud_de_credito' ) {
    
            List<Famiempresa__c> lstFami = IT_GestorDeConsultas_cls.consultaFamiEmpresaOpp( lstOpp[0].Famiempresa_relacionada__r.Id );     
            List<Contact> lstcon         = consultaContactos( lstIdOpp );
    
            faltantes += validaCamposClienteNatural( lstCliente[0] );
            faltantes += validaCamposOportunidadCredito( lstOpp[0] );
            
            if(lstOpp[0].Famiempresa_relacionada__r.Numero_de_identificacion__c	!= '99999'){
            	faltantes += validaCamposFamiEmpresa( lstFami[0] );
            }

            for( Contact con: lstcon){
                faltantes += validaCamposContactoAval( con );
            }
        }else if( lstCliente[0].RecordType.DeveloperName == 'Persona_juridica' && lstOpp[0].RecordType.DeveloperName == 'Solicitud_de_credito'){
            List<Contact> lstcon   = consultaContactos( lstIdOpp );        
            faltantes += validaCamposClienteJuridico( lstCliente[0] );
            faltantes += validaCamposOportunidadCredito( lstOpp[0] );            
            for( Contact con: lstcon){
                faltantes += validaCamposContactoAval( con );
            }
        }
        return faltantes;
    }

    /****************************************************************************************
    *Author:   Rafael Cardona
    *Function: Valida que se seleccione al menos un representante legal cuando la cuenta 
               es juridica y la oportunidad es de credito
    *Date:     26-06-2020
    *****************************************************************************************/
    public static String validaRepresentanteLegal(Quote cotizacion,  List<Id> lstIdOpp ){
        Integer cantidad = 0;
        if( cotizacion.Opportunity.RecordType.DeveloperName == 'Solicitud_de_credito' && cotizacion.Opportunity.Account.RecordType.DeveloperName == 'Persona_juridica'){ 
            List<Asociacion_cuenta_contacto__c> lstAso = IT_GestorDeConsultas_cls.consultaAsociacionAval(lstIdOpp);        
            for(Integer k=0; k < lstAso.size(); k++){
            if( lstAso[k].RepresentanteLegal__c == true){
                cantidad += 1;
            }
            }
        }else{
            cantidad = -1;
        }
        if( cantidad == 1 || cantidad == -1 ){
            return OK;
        }else{
            return REPRESENTANTE_LEGAL;
        }        
    }

    /****************************************************
    *Author:  Rafael Cardona
    *Function: Se activa check para la sincronizacion.
    *          Se llama desde componente Aura
    *Date: 30-3-2020
    ****************************************************/
    @AuraEnabled
    public static String sincronizaOportunidad(String idCotizacion){
        Quote cotizacion = consultaCotizacion(idCotizacion);        
        try{
            String valido = validacionesEjecucion(cotizacion);              
               if(valido == 'OK'){
                    cotizacion.Iniciar_sincronizacion__c = true;
                    cotizacion.Detener_sincronizacion__c = false;
                    update cotizacion;
                    System.debug('RETORNO OK ');
                    return 'OK';
               }else if( valido == 'PRECIOS DIFERENTES' ){
                    return valido;
               }else{
                    return valido;
               }           
            }catch(Exception ex){
                System.debug('Error en el proceso: '+ ex);
               return 'ERROR';
            }
    }

    /****************************************************
    *Author:  Rafael Cardona
    *Function: Se validan condiciones para ejecucion
    *Date: 30-3-2020
    ****************************************************/
    public static String validacionesEjecucion(Quote cotizacion){
        System.debug('cotizacion.Res_conteo_productos_cotizacion__c' + cotizacion.Res_conteo_productos_cotizacion__c);        
   
        if( cotizacion.Res_conteo_productos_cotizacion__c > 0  ){
            if(cotizacion.Opportunity.RecordType.DeveloperName == 'Solicitud_de_credito' ){                
                if( cotizacion.Status == 'PROGRAMADA' )
                    return 'OK';
                else
                    return System.Label.Sincroniza_Credito;                 
            }else if( cotizacion.Opportunity.RecordType.DeveloperName == 'Servicios_de_conocimiento_y_redes' ){                
                if( cotizacion.Status == 'APROBADA' || cotizacion.Status == 'Aprobado' )
                    return 'OK';
                else
                    return System.Label.Sincroniza_Conocimiento;                
            }else{
                return 'SIN TIPO REGISTRO';
            }            
        }else{
            return System.Label.Cotizacion_Sin_Producto;
        }
    }



    /****************************************************
    *Author:  Rafael Cardona
    *Function: Desincroniza la oportnidad
    *Date: 30-3-2020
    ****************************************************/
    @AuraEnabled
    public static string detieneSincronizacion(String idCotizacion){
        Quote cotizacion = consultaCotizacion(idCotizacion);        
        Try{
            cotizacion.Iniciar_sincronizacion__c = false;
            cotizacion.Detener_sincronizacion__c = true;
            update cotizacion;
            return 'OK';         
        }catch(Exception ex){
            System.debug('Error en el proceso: '+ ex);
            return 'ERROR';
        }
    }

    public static Quote consultaCotizacion(String idCotizacion){
 
        return [SELECT id,Iniciar_sincronizacion__c,Detener_sincronizacion__c, Opportunity.RecordType.DeveloperName,
        Status, Opportunity.Identificador_proceso__c, OpportunityId ,  Opportunity.AccountId, Res_conteo_productos_cotizacion__c,
        Opportunity.Account.RecordType.DeveloperName, GrandTotal,TotalPrice, Opportunity.Total_Capital_de_Trabajo__c,
        Opportunity.Total_Activos_Fijos_y_Otros__c, Opportunity.Total_Servicios_de_Conocimiento__c, idDocumentoPagare__c,
        Opportunity.Name, Opportunity.Account.Name
        FROM Quote WHERE id =: idCotizacion];
    }

    /***********************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta los avales por medio del objeto asociacion cuenta contacto
    *Date: 30-3-2020
    ************************************************************************************************/
    public static List<Contact> consultaContactos( List<Id> lstIdOpp ){
        String llenar = '';
        List<Id> lstAvales   = new List<Id>();
        List<Contact> lstcon = new List<Contact>();

        for(Asociacion_cuenta_contacto__c cc: IT_GestorDeConsultas_cls.consultaAsociacionAval( lstIdOpp )){
            lstAvales.add(cc.Contacto__c);
        }
        if( lstAvales.size() > 0 )
        lstcon  = IT_GestorDeConsultas_cls.consultaContactos( lstAvales );
        return lstcon;
    }

    /*********************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos obligatorios del cliente antes de sincronizar
    *Date: 30-3-2020
    **********************************************************************/
    public static String  validaCamposClienteNatural(Account cc){        

        String  detalle = 'Cliente[';
                detalle += (cc.Autorizacion_uso_de_datos__c != null && cc.Autorizacion_uso_de_datos__c != '') ? '':'Autorización uso de datos' ;
                detalle += (cc.Tipo_de_identificacion__c    != null && cc.Tipo_de_identificacion__c    != '') ? '' :' - Tipo de identificación' ;
                detalle += (cc.Medio_de_autorizacion__c     != null && cc.Medio_de_autorizacion__c     != '') ? '' :' - Medio de autorización' ;
                detalle += (cc.Numero_de_identificacion__c  != null && cc.Numero_de_identificacion__c  != '') ? '' :' - Número de identificación' ;
                detalle += (cc.Fecha_de_nacimiento__c       != null                                         ) ? '' :' - Fecha de nacimiento' ;
                detalle += (cc.Nivel_de_escolaridad__pc     != null && cc.Nivel_de_escolaridad__pc     != '') ? '' :' - Nivel de escolaridad' ;
                detalle += (cc.Genero__pc                   != null && cc.Genero__pc                   != '') ? '' :' - Genero' ;
                detalle += (cc.Ocupacion__c                 != null && cc.Ocupacion__c                 != '') ? '' :' - Ocupación' ;
                detalle += (cc.Tipo_de_vivienda__pc         != null && cc.Tipo_de_vivienda__pc         != '') ? '' :' - Tipo de vivienda' ;
                detalle += (cc.Estado_civil__pc             != null && cc.Estado_civil__pc             != '') ? '' :' - Estado civil' ;
                detalle += (cc.Estrato_empresa__c           != null && cc.Estrato_empresa__c           != '') ? '' :' - Estrato' ;
                detalle += (cc.Ciudad_empresa__c            != null                                         ) ? '' :' - Ciudad' ;
                detalle += (cc.Zona_empresa__c              != null                                         ) ? '' :' - Zona' ;
                detalle += (cc.Barrio_empresa__c            != null                                         ) ? '' :' - Barrio' ;
                detalle += (cc.Medio_por_el_cual_conocio_a_Interactuar__c != null && cc.Medio_por_el_cual_conocio_a_Interactuar__c != '') ? '' :' - Medio por el cuál conoció a Interactuar';
                detalle += (cc.Vigente__c                   != null && cc.Vigente__c                   != '') ? '' :' - Vigente' ;                
                detalle += (cc.AccountSource                != null && cc.AccountSource                != '') ? '' :' - Origen de cliente';
                detalle += (cc.Registro_creado_por__c       != null                                         ) ? '' :' - Registro creado por' ;

                if( cc.Ruralidad_domicilio_empresa__c ){
                detalle += (cc.Informacion_adicional_complemento_e__c != null && cc.Informacion_adicional_complemento_e__c != '') ? '': ' - Información adicional - complemento';
                }else{
                detalle += (cc.Via_empresa__c               != null && cc.Via_empresa__c               != '') ? '' :' - Vía' ;
                detalle += (cc.Intercesion_empresa__c       != null                                         ) ? '' :' - Intersección' ;
                detalle += (cc.Numero_empresa_a__c          != null                                         ) ? '' :' - Número' ;
                detalle += (cc.Numero_empresa_b__c          != null                                         ) ? '' :' - Número' ;
                }
                if( detalle == 'Cliente[' )  detalle = '';
                else   detalle += '], \n';                
        return detalle;
    }

     /******************************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos obligatorios del cliente juridico antes de sincronizar
    *Date: 12-06-2020
    ********************************************************************************/
    public static String  validaCamposClienteJuridico(Account cc){
        String  detalle = 'Cliente[';                
                detalle += (cc.Tipo_de_identificacion__c    != null && cc.Tipo_de_identificacion__c    != '') ? '' :' - Tipo de identificación' ;
                detalle += (cc.Numero_de_identificacion__c  != null && cc.Numero_de_identificacion__c  != '') ? '' :' - Número de identificación' ;
                detalle += (cc.Estrato_empresa__c           != null && cc.Estrato_empresa__c           != '') ? '' :' - Estrato' ;
                detalle += (cc.Ciudad_empresa__c            != null                                         ) ? '' :' - Ciudad' ;
                detalle += (cc.Zona_empresa__c              != null                                         ) ? '' :' - Zona' ;
                detalle += (cc.Barrio_empresa__c            != null                                         ) ? '' :' - Barrio' ;
                detalle += (cc.Medio_por_el_cual_conocio_a_Interactuar__c != null && cc.Medio_por_el_cual_conocio_a_Interactuar__c != '') ? '' :' - Medio por el cuál conoció a Interactuar';
                detalle += (cc.Vigente__c                   != null && cc.Vigente__c                   != '') ? '' :' - Vigente' ;                
                detalle += (cc.AccountSource                != null && cc.AccountSource                != '') ? '' :' - Origen de cliente';
                detalle += (cc.Registro_creado_por__c       != null                                         ) ? '' :' - Registro creado por' ;

                if( cc.Ruralidad_domicilio_empresa__c ){
                detalle += (cc.Informacion_adicional_complemento_e__c != null && cc.Informacion_adicional_complemento_e__c != '') ? '': ' - Información adicional - complemento';
                }else{
                detalle += (cc.Via_empresa__c               != null && cc.Via_empresa__c               != '') ? '' :' - Vía' ;
                detalle += (cc.Intercesion_empresa__c       != null                                         ) ? '' :' - Intersección' ;
                detalle += (cc.Numero_empresa_a__c          != null                                         ) ? '' :' - Número' ;
                detalle += (cc.Numero_empresa_b__c          != null                                         ) ? '' :' - Número' ;
                }
                if( detalle == 'Cliente[' )  detalle = '';
                else   detalle += '], \n';                
        return detalle;
    }

    /*********************************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos obligatorios de Oportunidad credito antes de sincronizar
    *Date: 30-3-2020
    **********************************************************************************/
    public static String  validaCamposOportunidadCredito(Opportunity op){        
        String  llenar = 'Oportunidad[';
        llenar += (op.Asesor_asignado__c          != null                                     ) ? '' :'Asesor asignado' ;
        llenar += (op.Registro_creado_por__c      != null                                     ) ? '' :' - Registro creado por' ;
        llenar += (op.CloseDate                   != null                                     ) ? '' :' - Fecha de cierre' ;
        llenar += (op.Medio_de_desembolso__c      != null && op.Medio_de_desembolso__c   != '') ? '' :' - Medio de desembolso' ;
  
        if( op.Account.RecordType.DeveloperName == 'Persona_natural'){
            llenar += (op.Famiempresa_relacionada__c  != null                                     ) ? '' :' - Famiempresa relacionada' ;
            llenar += (op.NomApe_Ben1__c              != null                                     ) ? '' :' - Nombre Beneficiario 1' ;
            llenar += (op.ParentescoBen1__c           != null                                     ) ? '' :' - Parentezco Beneficiario 1' ;
            llenar += (op.PorcentajeBen1__c           != null                                     ) ? '' :' - Porcentaje Beneficiario 1' ;
        }
        if( op.Medio_de_desembolso__c != null && op.Medio_de_desembolso__c  != '' && op.Medio_de_desembolso__c  == 'Transferencia'){
            llenar += (op.Entidad_financiera__c         != null && op.Entidad_financiera__c  != '') ? '' :' - Entidad Financiera' ; 
            llenar += (op.Tipo_de_cuenta__c             != null && op.Tipo_de_cuenta__c      != '') ? '' :' - Tipo de cuenta' ;            
            llenar += (op.Cuenta_No__c                  != null && op.Cuenta_No__c           != '') ? '' :' - Cuenta No' ;
            llenar += (op.Exonero_a_Interactuar_de_toda_responsabi__c != null && op.Exonero_a_Interactuar_de_toda_responsabi__c != '') ? '' :' - Exonero a Interactuar de toda responsabi' ;
        }else if( op.Medio_de_desembolso__c != null && op.Medio_de_desembolso__c  != '' && op.Medio_de_desembolso__c  == 'Cheque'){
            llenar += (op.Cheque_a_nombre_de_entidad__c != null && op.Cheque_a_nombre_de_entidad__c  != '') ? '' :' - Cheque a nombre de entidad' ;
        }
        if( llenar == 'Oportunidad[' )  llenar = '';
        else   llenar += '], \n';
        return llenar;
    }

    /***********************************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos obligatorios del contacto Aval credito antes de sincronizar
    *Date: 30-3-2020
    ************************************************************************************/
    public static String  validaCamposContactoAval(Contact cn){ 
        String  llenar  = 'Aval -'+cn.Name+'[';
                llenar += (cn.Tipo_de_identificacion__c    != null && cn.Tipo_de_identificacion__c    != '') ? '' :' - Tipo de identificación' ;
                llenar += (cn.firstname                    != null && cn.firstname                    != '') ? '' :' - Primer Nombre' ;
                llenar += (cn.Numero_de_identificacion__c  != null && cn.Numero_de_identificacion__c  != '') ? '' :' - Número de identificación' ;
                llenar += (cn.Genero__c                    != null && cn.Genero__c                    != '') ? '' :' - Genero' ;
                llenar += (cn.Nivel_de_escolaridad__c      != null && cn.Nivel_de_escolaridad__c      != '') ? '' :' - Nivel de escolaridad' ;                
                llenar += (cn.Estado_civil__c              != null && cn.Estado_civil__c             != '') ? '' :' - Estado civil' ;
                llenar += (cn.Tipo_de_vivienda__c          != null && cn.Tipo_de_vivienda__c         != '') ? '' :' - Tipo de vivienda' ;
                llenar += (cn.Ocupacion__c                 != null && cn.Ocupacion__c                != '') ? '' :' - Ocupación' ;
                llenar += (cn.Estrato_contacto__c          != null && cn.Estrato_contacto__c         != '') ? '' :' - Estrato *' ; 
                llenar += (cn.Ciudad_contacto__c           != null                                        ) ? '' :' - Ciudad *' ; 
                llenar += (cn.Barrio_contacto__c           != null                                        ) ? '' :' - Barrio *' ; 
                llenar += (cn.Medio_por_el_cual_conocio_a_Interactuar__c != null && cn.Medio_por_el_cual_conocio_a_Interactuar__c != '') ? '' :' - Medio por el cuál conoció a Interactuar';              
               
                if( cn.Ruralidad_domicilio_contacto__c ){
                llenar += (cn.Informacion_adicional_complemento_c__c != null && cn.Informacion_adicional_complemento_c__c != '') ? '': ' - Información adicional - complemento *';
                }else{
                llenar += (cn.Via_contacto__c               != null && cn.Via_contacto__c               != '') ? '' :' - Vía *' ;
                //llenar += (cn.Letra_contacto_a__c           != null && cn.Letra_contacto_a__c           != '') ? '' :' - Letra *' ;
                //llenar += (cn.Letra_contacto_b__c           != null && cn.Letra_contacto_b__c           != '') ? '' :' - Letra *' ;
                llenar += (cn.Intercesion_contacto__c       != null                                          ) ? '' :' - Intersección *' ;
                // llenar += (cn.Punto_cardinal_contacto_a__c  != null && cn.Punto_cardinal_contacto_a__c  != '') ? '' :' - Punto cardinal *' ;
                // llenar += (cn.Punto_cardinal_contacto_b__c  != null && cn.Punto_cardinal_contacto_b__c  != '') ? '' :' - Punto cardinal *' ;
                llenar += (cn.Numero_contacto_a__c          != null                                          ) ? '' :' - Número *' ;
                llenar += (cn.Numero_contacto_b__c          != null                                          ) ? '' :' - Número *' ;
                }
                if( llenar == 'Aval -'+cn.Name+'[' )  llenar = '';
                else   llenar += '], \n';
        return llenar;
    }

    /**************************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos obligatorios de famiEmpresa antes de sincronizar
    *Date: 30-3-2020
    ***************************************************************************/
    public static String  validaCamposFamiEmpresa(Famiempresa__c fa){    
        String  llenar = 'FamiEmpresa[';
                llenar += (fa.Tipo_de_identificacion__c        != null && fa.Tipo_de_identificacion__c     != '') ? '' :' - Tipo de identificacion' ;
                llenar += (fa.Fecha_de_creacion_de_empresa__c  != null                                          ) ? '' :' - Fecha de cierre' ;
                llenar += (fa.Numero_de_identificacion__c      != null && fa.Numero_de_identificacion__c   != '') ? '' :' - Número de identificación' ;
                llenar += (fa.Actividad_economica__c           != null                                          ) ? '' :' - Actividad económica' ;        
                llenar += (fa.Ciudad_empresa__c                != null                                          ) ? '' :' - Ciudad' ;       
                llenar += (fa.Zona_empresa__c                  != null                                          ) ? '' :' - Zona' ;
                llenar += (fa.Barrio_empresa__c                != null                                          ) ? '' :' - Barrio' ;
                if( llenar == 'FamiEmpresa[' )  llenar = '';
                else   llenar += '], \n';
        return llenar;
    }
        /****************************************************
    *Author:  Gerardo Alvarado
    *Function: Se valida que la famiempresa y el cliente estén vigentes.
    *          Se llama desde componente Aura
    *Date: 02-12-2021
    ****************************************************/
    @AuraEnabled
    public static Boolean validaVigencia(String idCotizacion){
        Opportunity oportunidad = new Opportunity();
        Quote cotizacion = new Quote();
        
        cotizacion = [SELECT Id,OpportunityId FROM Quote WHERE Id =: idCotizacion LIMIT 1];
        oportunidad = [SELECT Id,Famiempresa_relacionada__r.Vigente__c,Account.vigente__c, Account.RecordType.DeveloperName, RecordType.DeveloperName FROM Opportunity Where Id =: cotizacion.OpportunityId LIMIT 1];
        
        if(oportunidad.Account.RecordType.DeveloperName == 'Persona_juridica'){
            if(oportunidad.Account.Vigente__c == 'Vigente'){
                return true;
            }
            else{
                return false;
            }
        }else if (oportunidad.Account.RecordType.DeveloperName == 'Persona_natural') {
            if(oportunidad.RecordType.DeveloperName == 'Solicitud_de_credito'){
                if(oportunidad.Famiempresa_relacionada__r.Vigente__c && oportunidad.Account.Vigente__c == 'Vigente'){
                    return true;
                }
                else{
                    return false;
                }
            }
            if(oportunidad.RecordType.DeveloperName == 'Servicios_de_conocimiento_y_redes'){
                if(oportunidad.Account.Vigente__c == 'Vigente'){
                    return true;
                }
                else{
                    return false;
                }                
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
}
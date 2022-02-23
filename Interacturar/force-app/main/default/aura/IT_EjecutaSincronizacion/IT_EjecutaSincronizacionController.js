({
    /*******************************************************************************************************
     *@Author: Rafael Cardona
     *@Function: Valida si la cuenta es de credito para identificar si hace falta la consulta de datacredito
    *******************************************************************************************************/
    validaCredito : function ( component, event, helper ){  
        var action = component.get("c.validaCreditoBPMS");
        var idOpp = component.get("v.recordId");
        console.log('id opp: '+ idOpp);
        action.setParams({
            idCotizacion : idOpp
        });

        component.set("v.Spinner", true);
        
        action.setCallback(this,function(respuesta){            
        if(respuesta.getState() === 'SUCCESS'){
        var resControlador = respuesta.getReturnValue();
        component.set("v.Spinner", false);
        console.log(resControlador);
        
                if( resControlador == 'DataCredito'){
                    var msg = "Tenga en cuenta que debe realizar la consulta "+
                              "a Datacredito antes de realizar la sincronización de la solicitud de crédito. ";
                    helper.helperMensaje("CONSULTE DATACREDITO", msg ,"warning");
                    $A.get("e.force:closeQuickAction").fire();
                }
                // COMENTAREAR CUANDO SE HABILITE DECEVAL
                // else if(resControlador == 'NoAplica'){
                //     console.log('noo applica');
                //     var ejecutaSincro = component.get('c.ejecutarSincronizacion');
                //     $A.enqueueAction(ejecutaSincro);
                //     $A.get("e.force:closeQuickAction").fire();
                //} // COMENTAREAR CUANDO SE HABILITE DECEVAL

                else if( resControlador == 'PRECIOS DIFERENTES' ){
                    helper.helperMensaje("Inconsistencia de precios","El VALOR TOTAL de la cotización debe ser igual a la suma de los campos\n"+
                    " TOTAL CAPITAL DE TRABAJO + TOTAL ACTIVOS FIJOS Y OTROS + TOTAL SERVICIO DE CONOCIMIENTO en la oportunidad","Error");
                    $A.get("e.force:closeQuickAction").fire();
                }else if( resControlador == 'CALCULO DEL SCORE' ){
                    helper.helperMensaje("Cálculo del Score","Tenga en cuenta que no puede sincronizar la solicitud de crédito con un Score fallido","Error");
                    $A.get("e.force:closeQuickAction").fire();
                }else if( resControlador == 'PRECIOS DIFERENTES' ){
                    helper.helperMensaje("Inconsistencia de precios","El VALOR TOTAL de la cotización debe ser igual a la suma de los campos\n"+
                    " TOTAL CAPITAL DE TRABAJO + TOTAL ACTIVOS FIJOS Y OTROS + TOTAL SERVICIO DE CONOCIMIENTO en la oportunidad","Error");
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if( resControlador.includes('FaltanCampos')){
                    component.set("v.lstCamposFaltantes",resControlador);
                    component.set("v.faltanCampos",true);
                }
                else if( resControlador.includes('Encuesta')){
                    helper.helperMensaje("ENCUESTA","Verifique que todas las preguntas esten diligenciadas: \n"+resControlador,"Warning");
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if( resControlador.includes('RL')){
                    helper.helperMensaje("Representante Legal","Por favor escoja un aval como representante legal","Warning");
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if( resControlador.includes('ERROR-REUSAR')){
                    helper.helperMensaje("REUSAR PAGARE","Ocurrio un error en la actualizacion del ID pagare","Error");
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if( resControlador.includes('CLIENTE Y AVALES')){// debe ser el último else-if en la cadena
                    component.set("v.lstMovilActualizar",resControlador);
                    component.set("v.actualizaMovil",true);
                }               
            }else{
                helper.helperMensaje(
                    "Fallo el proceso!",
                    "Fallo ejecucion de iniciar sincronizacion",
                    "Error"
                );  
                component.set("v.Spinner", false);  
                $A.get("e.force:closeQuickAction").fire();            
            }       
                
        });         
        $A.enqueueAction(action); 
    }
    ,
    /*************************************************************************
     *@Author: Rafael Cardona
     *@Function: Ejecuta proceso de sincronizacion desde la cotizacion
    **************************************************************************/
   ejecutarSincronizacion : function(component, event, helper) {
    console.log('entro ejecutarSincronizacion');
    var action = component.get("c.sincronizaOportunidad");
    var idCot = component.get("v.recordId");
    action.setParams({ 
        idCotizacion : idCot
    });
    component.set("v.Spinner", true);
    // console.log('antes');   
    
    // COMENTAREAR CUANDO SE HABILITE DECEVAL
    // helper.helperMensaje("Ejecutando...","Sincronizacion en proceso...","WARNING");
    // COMENTAREAR CUANDO SE HABILITE DECEVAL

    action.setCallback(this,function( response ) {
        component.set("v.actualizaMovil",false); //DECEVAL solitado
        var state = response.getState();  
        if ( state === "SUCCESS") {        
            var resControlador = response.getReturnValue();
            component.set("v.Spinner", false);
            if (resControlador == 'OK') {                    
                helper.helperMensaje("Ejecutando...","Sincronizacion en proceso...","Success");    
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();               
            }
            else if( resControlador == 'ERROR' ){
                helper.helperMensaje("Fallo","Fallo en el envio de la sincronizacion","Error");
            }
            else{
                helper.helperMensaje("-- Por favor Revisar --",resControlador,"Warning"); 
            }    
      } else {
          helper.helperMensaje(
              "Fallo en el proceso!","Fallo ejecucion de iniciar sincronizacion","Error");  
          component.set("v.Spinner", false);        
      }
    });
     $A.enqueueAction(action);    
  }
  ,
  closeModel : function(component, helper, event){
    component.set("v.faltanCampos",false);
    component.set("v.actualizaMovil",false); // DECEVAL solitado
  },
    validarVigencia : function(component, helper, event){
        var action = component.get("c.validaVigencia");
        var idQuote = component.get("v.recordId"); 
        action.setParams({ 
        	idCotizacion : idQuote
    	});
        action.setCallback(this,function( response ) {
        var state = response.getState();  
        if ( state === "SUCCESS") {        
            var vigente = response.getReturnValue();
            console.log(vigente);
            if (vigente == true) {                    
                component.set("v.vigente",true);
            }
            else{
                component.set("v.vigente",false);
            }    
      	}
    });
     $A.enqueueAction(action);  
    }
})
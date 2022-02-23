({
    detenerSincronizacion : function(component, event, helper) {
        console.log(" Validacion de datos : " + event.getSource().get("v.label"));    
        var action = component.get("c.detieneSincronizacion");
        action.setParams({
            idCotizacion: component.get("v.recordId")
        });

        component.set("v.Spinner", true);
        action.setCallback(this, function(respuesta) {
          if (respuesta.getState() === "SUCCESS") {
                var resControlador = respuesta.getReturnValue();
                console.log(resControlador);                
                if (resControlador == 'OK') {                    
                        helper.helperMensaje(
                            "Ejecutando...",
                            "Proceso detenido",
                            "Success"
                        );     
                        $A.get('e.force:refreshView').fire();              
                }else if( resControlador == 'ERROR' ){
                    helper.helperMensaje(
                        "Atención",
                        "Fallo ejecucion para detener sincronizacion",
                        "Warning"
                    );
                }
            }    
           else {
              helper.helperMensaje(
                  "Fallo en el proceso!",
                  "Fallo ejecucion de detener sincronizacion",
                  "Error"
              );        
          }
          component.set("v.Spinner", false);
          $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
      }
})
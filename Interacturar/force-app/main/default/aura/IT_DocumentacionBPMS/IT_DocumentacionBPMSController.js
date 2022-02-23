({
  ejecutarDocumentacion: function(component, event, helper) {
    console.log(" Validacion de datos : " + event.getSource().get("v.label"));

    var action = component.get("c.componenteDocumentacionBPMS");
    action.setParams({
      oportunidadId: component.get("v.recordId")
    });
    component.set("v.Spinner", true);
    action.setCallback(this, function(respuesta) {
      if (respuesta.getState() === "SUCCESS") {
        var resControlador = JSON.parse(respuesta.getReturnValue());
        console.log(" respuesta : " + resControlador);
        console.log(resControlador);
        component.set("v.Spinner", false);
        if (resControlador.exitoso) {
            console.log(" 1 : " + resControlador.exitoso);
            if(resControlador.respuesta == 'OK enviar'){
                helper.helperMensaje(
                    "Proceso en ejecucion...",
                    "Enviando documentacion a BPMS",
                    "Success"
                );
            }else{
                console.log(" 2 : " + resControlador.exitoso);
                helper.helperMensaje(
                    "Proceso exitoso",
                    "No se encontraron documentos para enviar a BPMS",
                    "Warning"
                );
            }

          var ServicioDocBPMS = component.get("c.ejecutarServicio");
          $A.enqueueAction(ServicioDocBPMS);
        }else{
            if( !resControlador.exitoso ){
                helper.helperMensaje(
                    "Oportunidad no permitida",
                    "El producto de la oportunidad debe ser de tipo credito",
                    "Warning"
                ); 
                $A.get("e.force:closeQuickAction").fire();
          }else{
              helper.helperMensaje(
                  "Revisar proceso",
                  "Por favor consultar con asesoria tecnica",
                  "Warning"
              ); 
              $A.get("e.force:closeQuickAction").fire();
          }
        }

      } else {
          helper.helperMensaje(
              "Exception controlada!",
              "Fallo ejecucion, Servicio documentacion BPMS",
              "Error"
          );          
      }
    });
    $A.enqueueAction(action);
  },

  ejecutarServicio: function(component, event, helper) {
    var action = component.get("c.componenteServicioBPMS");
    action.setParams({
      oportunidadId: component.get("v.recordId")
    });

    action.setCallback(this, function(respuesta) {
      if (respuesta.getState() === "SUCCESS") {
        var resControlador = JSON.parse(respuesta.getReturnValue());
        console.log(" respuesta : " + resControlador);
        console.log(resControlador);

        if (resControlador.exitoso) {
            if( resControlador.respuesta == 'Ok' ){
                helper.helperMensaje(
                    "Proceso exitoso",
                    "Se envio documentacion a BPMS y se eliminaron documentos en SF",
                    "Success"
                );
                $A.get("e.force:closeQuickAction").fire();
            }else if( resControlador.respuesta == 'Fallo eliminacion' ){
                helper.helperMensaje(
                    "Proceso inconsistente",
                    "Se envio documentacion a BPMS pero Fallo eliminacion documentos en SF",
                    "Warning"
                );
                $A.get("e.force:closeQuickAction").fire();
            }else if( resControlador.respuesta == 'Ok creacion' ){
                helper.helperMensaje(
                    "Proceso inconsistente",
                    "Se envio documentacion a BPMS",
                    "Warning"
                );
                $A.get("e.force:closeQuickAction").fire();
            }else{
               helper.helperMensaje(
                    "Proceso inconsistente",
                     resControlador.respuesta,
                    "Warning"
                );
                $A.get("e.force:closeQuickAction").fire();
            }

        } else {
          helper.helperMensaje(
            "No se ejecuto servicio",
            "Revisar archivos a enviar",
            "Warning"
          );
            $A.get("e.force:closeQuickAction").fire();
        }
      } else {
        helper.helperMensaje(
          "Exception controlada!",
          "Fallo ejecucion, Servicio documentacion BPMS",
          "Error"
        );
          $A.get("e.force:closeQuickAction").fire();
      }
    });
    $A.enqueueAction(action);
  }
});
({
    ejecutarDatacredito : function(cmp, event, helper) {
        
        var action = cmp.get("c.servicioDataCredito");
        action.setParams({ 
            idSf: cmp.get("v.recordId")
        });
        
        cmp.set("v.Spinner", true);
        action.setCallback(this, function(respuesta) {
            var strRespuesta = respuesta.getReturnValue();
            cmp.set("v.Spinner", false);
            if (respuesta.getState() === "SUCCESS") {
	              if(strRespuesta == 'Exitoso'){  
                    helper.helperMensaje(
                        "Consulta exitosa, verifique los datos",
                        "Ejecucion exitosa del servicio DataCredito",
                        "Success"
                    );
                   $A.get("e.force:closeQuickAction").fire();
                }else if(strRespuesta == 'Warning'){ 
                    helper.helperMensaje(
                        "Fallo en el servicio",
                        "Se presento un error en el servicio, consulte al administrador",
                        "Warning"
                    );   
                    $A.get("e.force:closeQuickAction").fire();
                }else if(strRespuesta == 'Error'){ 
                    helper.helperMensaje(
                        "Por favor actualice el registro antes de consultar datacredito",
                        "Se presento un error en la ejecucion del Proceso, consulte al administrador",
                        "Error"
                    );
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else if (respuesta.getState() === "INCOMPLETE") { 
                 helper.helperMensaje(
                    "Proceso en prueba",
                    "El servidor podría estar inactivo o el cliente podría estar desconectado",
                    "Success"
                );
                $A.get("e.force:closeQuickAction").fire();
            }else if (respuesta.getState() === "ERROR") { 
                    var errors = response.getError();
                    if (respuesta.getError()) {              
                             helper.helperMensaje(
                                "Mensaje de error",
                                "Por favor consulte su consultor salesforce",
                                "Error"
                            ); 
                        $A.get("e.force:closeQuickAction").fire();
                    } else {
                             helper.helperMensaje(
                                "Mensaje de error",
                                "Por favor consulte su consultor salesforce",
                                "Error"
                            );
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
        });
        $A.enqueueAction(action);        
    }
})
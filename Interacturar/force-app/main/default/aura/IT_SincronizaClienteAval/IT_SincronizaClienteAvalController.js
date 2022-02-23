({
    sincronizaAval : function(component, event, helper) {
        var idContacto = component.get("v.recordId");
        component.set("v.Spinner",true);
        var action = component.get("c.sincronizaClienteAval");
        action.setParams({
            idContacto : idContacto
        });

        action.setCallback(this, function(response){
            component.set("v.Spinner",false);
            var state = response.getState();
            console.log("entro");
            console.log(state);
            if (state === "SUCCESS") {
                var respuesta = JSON.parse(response.getReturnValue());                
                if(respuesta.actualizo){                    
                    helper.helperMensaje('Sincronización Aval','El aval se sincronizo satisfactoriamente','SUCCESS');
                    console.log("actualizo correctamente");
                }else if( ! respuesta.actualizo  && respuesta.mensaje == 'FaltaSincronizar'){
                    helper.helperMensaje('Aval no existe en Oracle','Por favor Asocie el aval a una oportunidad y sincronicela satisfactoriamente','WARNING');
                    console.log("El aval No esta sincronizado");
                }else if( ! respuesta.actualizo  && respuesta.mensaje == 'Error'){
                    helper.helperMensaje('Sincronización Aval','En la actualización del Aval ocurrio algún error','ERROR');
                    console.log("ocurrio un -error-");
                }else{
                    helper.helperMensaje('Sincronización Aval','En la actualización del Aval ocurrio algún error','ERROR');
                    console.log("ocurrio un -ERROR-");
                }
                $A.get('e.force:refreshView').fire();
            }
        });

        $A.enqueueAction(action);
    }
})
({
    EliminarDataAval : function(component, event, helper) {
        component.set("v.Cliente",null);
    }
    ,
    goToAccount : function(component, event, helper){
        var cliente = component.get("v.Cliente");
        var accountEvent = $A.get("e.force:navigateToSObject");
        accountEvent.setParams({
            "recordId" : cliente.Id
        });
        accountEvent.fire();
    }
    ,
    resaltaCliente : function(component, event, helper) {
        console.log('activo onmouseover');
        component.set("v.resaltarCliente",true);
    }
    ,
    noResaltaCliente : function(component, event, helper) {
        console.log('activo onmouse-out');
        component.set("v.resaltarCliente",false);
    },
    convertirClienteAval : function(component, event, helper){
        console.log('Inicia proceso de conversion del cliente en aval');
        var clienteSeleccionado = component.get("v.Cliente");
        var idOportunidad       = component.get("v.idOportunidad");

        var action = component.get("c.convertirClienteEnAval");
        action.setParams({
            cliente : clienteSeleccionado,
            idOportunidad : idOportunidad
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resConversion = JSON.parse(response.getReturnValue());
                if( resConversion.ejecucion && resConversion.mensaje != 'Maximo' ){
                    console.log("Conversion exitosa");                    
                    // resConversion.mensaje trae el id del contacto aval creado
                    var EventoAvalCliente  = component.getEvent("EventoAvalClienteAsociado");
                    EventoAvalCliente.setParams({ "contactoAvalAsociado": resConversion.mensaje });
                    EventoAvalCliente.fire();
                    helper.helperMensaje("Aval creado","El Aval se vinculo satisfactoriamente","Success");
                }else if( ! resConversion.ejecucion && resConversion.mensaje == 'Maximo'){
                    console.log("fallo en la asociacion");
                    helper.helperMensaje("Limite de Avales","Cupo máximo de Avales alcanzado","Warning");
                }else if( ! resConversion.ejecucion && resConversion.mensaje == 'KO'){
                    helper.helperMensaje("Inconsistencia","Por favor comuniquese con su adminisrtrador","Error");
                    console.log("fallo en la conversion");
                }
            }
        });
        $A.enqueueAction(action);
    }
})
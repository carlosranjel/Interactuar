({
    agregarAvalaOportunidad : function(component, event, helper) {
        var contacto = component.get("v.Contacto");
        var idOpp = component.get("v.idOpotunidad");
        console.log(contacto);
        console.log(idOpp);
        var action = component.get("c.agregarAval");
        action.setParams({
            idContacto    : contacto.Id,
            idOportunidad : idOpp
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var respuestaJson = JSON.parse(response.getReturnValue());
                console.log(respuestaJson);
                console.log("ejecuta event");
                if( respuestaJson.ejecucion && respuestaJson.mensaje == "Agregar"){
                    var EventAvalAgregado  = component.getEvent("EventoAvalAgregado");
                    EventAvalAgregado.setParams({ "contactoAgregado": contacto });
                    EventAvalAgregado.fire();
                }else if( ! respuestaJson.ejecucion && respuestaJson.mensaje == "Maximos avales"){
                    helper.helperMensaje("Limite de Avales","Cupo máximo de Avales alcanzado","Warning");
                    var EventAvalAgregado  = component.getEvent("EventoAvalAgregado");
                    EventAvalAgregado.setParams({ "contactoAgregado": null });
                    EventAvalAgregado.fire();
                }else if( ! respuestaJson.ejecucion && respuestaJson.mensaje == "Existe"){
                    helper.helperMensaje("Actualice pagina","El Aval ya fue agregado","Warning");
                    var EventAvalAgregado  = component.getEvent("EventoAvalAgregado");
                    EventAvalAgregado.setParams({ "contactoAgregado": null });
                    EventAvalAgregado.fire();
                }
            }
            // si falla el proceso se debe lanzar mensaje
        });
        $A.enqueueAction(action);
    }
})
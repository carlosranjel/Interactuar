({
    convertirAval : function(component, event, helper) {
        var idAval = component.get("v.recordId");
        component.set("v.Spinner",true);
        var action = component.get("c.convertirAvalEnCliente");
        action.setParams({
            idAval : idAval
        });

        action.setCallback(this, function(response){
            component.set("v.Spinner",false);
            var state = response.getState();
            console.log(state);
             if (state === "SUCCESS") {
                var respuesta = JSON.parse(response.getReturnValue()); 
                var urlLightning = helper.generaUrl(respuesta.idCliente,'Account');  
                console.log(urlLightning);                            
                 if( respuesta.ejecucion && respuesta.mensaje == 'OK' ){
                   helper.helperMensajeOk('Conversion Aval','El aval se convirtio a cliente satisfactoriamente','SUCCESS',urlLightning);
                 }else{
                    console.log(respuesta.mensaje);
                    helper.helperMensajeErr('Conversion Aval','Error en la conversion','ERROR');
                 }
            }
        });
        $A.enqueueAction(action);
    }
})
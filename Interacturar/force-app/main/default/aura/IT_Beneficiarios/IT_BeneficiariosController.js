({
    doInit : function(component, event, helper) {
        let registro = component.get("v.recordId");

        let action = component.get("c.buscaContactosBeneficiario");
        action.setParams({
            idOportunidad : registro
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var respuesta = JSON.parse(response.getReturnValue());
                console.log(respuesta);
                if( respuesta ){
                    component.set("v.listaContactos", respuesta);
                }else{
                    console.log("vacio");
                }
            }
        });

        $A.enqueueAction(action);
    },
    updateInfo : function(component, event, helper) {
        component.set("v.listaContactos", undefined);
        let registro = component.get("v.recordId");

        let action = component.get("c.buscaContactosBeneficiario");
        action.setParams({
            idOportunidad : registro
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var respuesta = JSON.parse(response.getReturnValue());
                console.log(respuesta);
                if( respuesta ){
                    component.set("v.listaContactos", respuesta);
                }else{
                    console.log("vacio");
                }
            }
        });

        $A.enqueueAction(action);
    }
})
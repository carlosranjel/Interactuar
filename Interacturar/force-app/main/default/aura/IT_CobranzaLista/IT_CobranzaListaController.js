({
    doInit : function(component, event, helper) {

        var idActivo = component.get("v.idActivo");
        var action = component.get("c.buscaGestionesCobranza");

        action.setParams({
            idActivo : idActivo
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if( state === "SUCCESS" ){
            var respuesta = JSON.parse(response.getReturnValue());
            console.log(respuesta.lstTareas);
            component.set("v.lstTareas",respuesta.lstTareas);    
            }else{
                helper.helperMensaje('Inconsistencia',' Comuniquese con su administrador','Error');
            }
        });
        $A.enqueueAction(action);
    }
    
})
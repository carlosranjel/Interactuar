({
    doInit : function(component, event, helper) {
        var idContacto    = component.get("v.idContacto")
        var idOportunidad = component.get("v.idOportunidad");
        var action     = component.get("c.consultaContacto");
        action.setParams({
            idContacto    : idContacto,
            idOportunidad : idOportunidad
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var res = JSON.parse(response.getReturnValue());
                console.log(res);
                if( res.ejecutoDataAval ){
                    component.set("v.selected", res);
                }
                if( res.ejecutoRepresentante ){
                    component.set("v.representante","slds-m-left_xx-small slds-button_success");
                }
                if( res.NoApRepresentante ){
                    component.set("v.noAplicaRepr",true);
                }
            }
        });

        $A.enqueueAction(action);

        var estructura    = component.get("v.Estructura");
        var idContacto    = component.get("v.idContacto");
        
        console.log(estructura);
        console.log(idContacto);
        console.log(idOportunidad);
    }
    ,
    clickEnAval : function(component, event, helper){
        console.log("Selecciona boton aval");   
    }
    ,
    EjecutarDataCreditoAval : function(component, event, helper){
        var estructura    = component.get("v.Estructura");
        var idOpp  = component.get("v.idOportunidad");
        var idbpms = estructura.idBPMS;
        var idCon  = component.get("v.idContacto");

        if( idbpms ){
        console.log("ejecutar aval");
        component.set("v.selected",true);
        var inputVariables = [
            {
                name : "idOportunidad",
                type : "String",
                value : idOpp
            },
            {
                name : "idBPMS",
                type : "String",
                value : idbpms
            },
            {
                name : "idContacto",
                type : "String",
                value : idCon
            }
        ];
        var flow = component.find("flowData");
        flow.startFlow("Consulta_Datacredito_Historico",inputVariables);
        }else{
        helper.helperMensaje("Por favor Revisar","Verifique que el valor del identificador proceso (BPMS) para la oportunidad del titular se haya generado.","Warning");
        }
    }
    ,
    EliminarDataAval : function(component, event, helper){
        var idContacto = component.get("v.idContacto");
        var idOpp      = component.get("v.idOportunidad");
        console.log(idContacto);
        console.log(idOpp);
        var action = component.get("c.quitarAval");
        action.setParams({
            idContacto    : idContacto,
            idOportunidad : idOpp
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var expelido = response.getReturnValue();
                console.log(expelido);
                console.log("expelido");
                if( expelido ){
                    var EventoAvalExpelido  = component.getEvent("EventoAvalExpelido");
                    EventoAvalExpelido.setParams({ "idContactoExpelido": idContacto });
                    EventoAvalExpelido.fire();
                    helper.helperMensaje('Exitoso','El Aval se desvinculo de la oportunidad','Success');
                }else{
                    helper.helperMensaje('Inconsistencia','Por favor consulte a su administrador','Warning');
                }
            }else{
                helper.helperMensaje('Error','Por favor consulte a su administrador','Error');
            }
            // si falla el proceso se debe lanzar mensaje
        });
        $A.enqueueAction(action);
    }
    ,
    goToAval : function(component, event, helper) {
        var idAval = component.get("v.idContacto");
        var avalEvent = $A.get("e.force:navigateToSObject");
        avalEvent.setParams({
            "recordId" : idAval
        });
        avalEvent.fire();
    }
    ,
    resaltaAval : function(component, event, helper) {
        console.log('activo onmouseover');
        component.set("v.resaltarAval",true);
    }
    ,
    noResaltaAval : function(component, event, helper) {
        console.log('activo onmouse-out');
        component.set("v.resaltarAval",false);
    }
    ,
    RepresentanteLegal : function( component, event, helper ){
        console.log("representante");
        var idContacto = component.get("v.idContacto");
        var idOpp      = component.get("v.idOportunidad");
        console.log(idContacto);
        console.log(idOpp);
        var action = component.get("c.representanteLegal");
        action.setParams({
            idContacto    : idContacto,
            idOportunidad : idOpp
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("respuesta:");
            console.log(state);
            if (state === "SUCCESS") {
                let res = JSON.parse(response.getReturnValue());
                if( res.ejecucion ){
                    if( res.mensaje == 'OCUPADO'){
                        helper.helperMensaje('Exitoso','Solo se permite un representante legal por oportunidad','Warning');
                    }else if( res.mensaje == 'OK-on' ){
                        component.set("v.representante","slds-m-left_xx-small slds-button_success");
                        helper.helperMensaje('Exitoso','Representante Legal','Success');
                    }else if( res.mensaje == 'OK-off' ){
                        component.set("v.representante","slds-m-left_xx-small");
                        helper.helperMensaje('Advertencia','Escoge otro representante legal','Success');
                    }                    
                }else{
                    helper.helperMensaje('ERROR','Por favor comuniquese con su administrador','Error');
                }                
            }
        });
         $A.enqueueAction(action);
    }
})
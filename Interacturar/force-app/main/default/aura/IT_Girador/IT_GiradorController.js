({
    listaGiradores : function( component, event, helper ){
        let idCot = component.get("v.recordId");

        let action = component.get("c.listadoGiradores");

        action.setParams({
            idCotizacion : idCot
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if (state === "SUCCESS") {                
                let giradoresLista = JSON.parse(response.getReturnValue());
                if( giradoresLista[0].nombre != null){
                    console.log(giradoresLista);
                    component.set("v.giradoresEncontrados",giradoresLista);
                    component.set("v.muestraLista",true);
                }else if( ! giradoresLista[0].proceso && giradoresLista[0].mensaje == 'EB' ){
                    helper.helperMensaje("ETAPA BLOQUEADA DE LA OPORTUNIDAD","No es posible enviar giradores en la etapa actual de la oportunidad","Warning");
                }else if( ! giradoresLista[0].proceso && giradoresLista[0].mensaje == 'SincOpp' ){
                    helper.helperMensaje("SINCRONIZACION OPORTUNIDAD","Verifique la sincronizacion en Oportunidad","Warning");
                }else if( ! giradoresLista[0].proceso && giradoresLista[0].mensaje == 'Radicado' ){
                    helper.helperMensaje("RADICADO","Verifique el radicado en el producto de cotización","Warning");
                }               
            }
        });
        $A.enqueueAction(action);
    }
    ,
    crearActualizarGiradores : function(component, event, helper) {
        let idCot = component.get("v.recordId");
        component.set("v.muestraLista",false);
        component.set("v.Spinner",true);
        let action = component.get("c.integraGirador");

        action.setParams({
            idCotizacion : idCot
        });

        action.setCallback(this,function(response){
            component.set("v.Spinner",false);
            let state = response.getState();
            if (state === "SUCCESS") {
                var resControl = JSON.parse(response.getReturnValue());
                console.log(resControl);                
                if( resControl.mensajeGlobal == 'GIRADORES-OK' ){
                    helper.helperMensaje("GIRADORES ENVIADOS","Giradores enviados exitosamente","Success");
                }else if( resControl.mensajeGlobal == 'GIRADORES-ERROR' ){
                    helper.helperMensaje("INCONSISTENCIA","Revise los mensajes de respuesta","Warning");
                }else if( resControl.mensajeGlobal == 'ERROR'){
                    helper.helperMensaje("ERROR","Por favor consulte a su administrador","Error");
                }
                $A.get('e.force:refreshView').fire();
            }
        });

        $A.enqueueAction(action);
    }
    ,
    closeModel : function(component, helper, event){
        component.set("v.muestraLista",false);
      }
})
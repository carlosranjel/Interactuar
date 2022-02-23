({
    crearPagare : function( component, event, helper ){
        let idCot = component.get("v.recordId");
        console.log('entro');
        component.set("v.Spinner", true);

        var action = component.get("c.creacionPagare");
        action.setParams({
            idCotizacion : idCot
        });
        action.setCallback(this,function(response){
            component.set("v.Spinner", false);
            let resp = response.getState();
            if( resp === 'SUCCESS' ){
                let lista = JSON.parse(response.getReturnValue());
                console.log(lista);
                if( lista[0].estado && lista[0].estado != 'ERROR'  && lista[0].estado != 'REUSAR' ){
                    helper.helperMensaje(lista[0].estado, 'Ejecutado exitosamente' ,"Success");
                }else if( lista[0].estado && lista[0].estado == 'ERROR' && lista[0].estado != 'REUSAR' ){
                    helper.helperMensaje(lista[0].estado, 'Revise los mensajes de error' ,"Warning");
                }else if( lista[0].estado && lista[0].estado == 'REUSAR' && lista[0].estado != 'ERROR' ){
                    helper.helperMensaje('REUSAR PAGARE', 'No se permite ejecutar servicio de pagare' ,"Warning");
                }else{
                    helper.helperMensaje('ERROR', 'Por favor comuniquese con su administrador' ,"Error");
                }
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        }
})
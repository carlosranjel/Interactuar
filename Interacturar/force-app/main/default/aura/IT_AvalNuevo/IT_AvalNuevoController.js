({
    guardarContacto : function(component, event, helper){
        var FirstName = component.get("v.FirstName");
        var LastName = component.get("v.LastName");
        var NumeroIdentificacion = component.get("v.NumeroIdentificacion");
        var TipoIdentificacion   = component.get("v.TipoIdentificacion");

        var idOportunidad  = component.get("v.idOportunidad");
        var okCampos = true;
        if ( FirstName == null || FirstName == '' ) {
            helper.helperMensaje('Requerido','Diligencie el campo: Primer nombre.','WARNING');
            okCampos = false;
        } else if( LastName == null || LastName == '' ){
            helper.helperMensaje('Requerido','Diligencie el campo: Primer apellido.','WARNING');
            okCampos = false;
        } else if( NumeroIdentificacion == null || NumeroIdentificacion == '' ){
            helper.helperMensaje('Requerido','Diligencie el campo: Número de identificación.','WARNING');
            okCampos = false;
        }else if( TipoIdentificacion == null || TipoIdentificacion == '' ){
            helper.helperMensaje('Requerido','Diligencie el campo: Tipo de identificación.','WARNING');
            okCampos = false;
        }
        
        console.log("guardar contacto");
        console.log(FirstName);
        console.log(idOportunidad);
        if( okCampos ){
            var ejecutar = component.get('c.ejecutar');
            $A.enqueueAction(ejecutar);
        }
    },

    ejecutar : function(component, event, helper){
        var FirstName = component.get("v.FirstName");
        var LastName = component.get("v.LastName");
        var NumeroIdentificacion = component.get("v.NumeroIdentificacion");
        var tipoIdentificacion  = component.get("v.TipoIdentificacion");
        var idOportunidad  = component.get("v.idOportunidad");

        var action = component.get("c.creaContacto");
        action.setParams({
            idOportunidad : idOportunidad,
            nom : FirstName,
            ape : LastName,
            numIdentificacion : NumeroIdentificacion,
            tipoIde : tipoIdentificacion
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var creadoContacto = response.getReturnValue();
                if( creadoContacto != null){
                    if( creadoContacto.LastName == 'Error' ){
                        helper.helperMensaje('Error','Este número de documento ya existe para otro aval','ERROR');
                    }else{
                        console.log(creadoContacto);
                        console.log("creado event")
                        var EventoAvalCreado  = component.getEvent("EventoAvalCreado");
                        EventoAvalCreado.setParams({ "contactoCreado": creadoContacto });
                        EventoAvalCreado.fire();
                    }                    
                }else{
                    helper.helperMensaje('Inconsistencia','Por favor consulte su administrador','WARNING');
                }
            }
            //crear las validaciones para cuando el resultado es diferente de success
        });
        $A.enqueueAction(action);
    }
})
({
    consultaPQR : function( component, event, helper ) {
        var idCuenta = component.get( "v.recordId" );
        var action = component.get( "c.servicioConsultaPQR" );
        action.setParams( {
            idSf : idCuenta
        } );
        component.set( "v.spinner", true );
        action.setCallback(this,function( response ){
            var state = response.getState();
            //console.log( "INICIO..." );
            if ( state === "SUCCESS" ) {
                //console.log( "IF SUCCESS" );
                //console.log( 'Status: ' + state );
                var lstRespuesta = JSON.parse( response.getReturnValue() );
                //console.log( lstRespuesta );
                //console.log( lstRespuesta[0].respuesta.estado );
                component.set( "v.spinner", false );
                if( lstRespuesta[0].respuesta.estado == 'OK' ){
                    if(lstRespuesta[0].respuesta.mensaje == 'Consulta realizada correctamente.'){
                        //console.log( 'IF OK Consulta realizada correctamente.' );
                        //console.log( lstRespuesta );
                        component.set( "v.isOpen",true );
                        component.set( "v.notComment",true );
                        component.set( "v.lstObjects",lstRespuesta[0].pqrs );
                    }else{
                        //console.log('IF OK ... OTRO');
                        //console.log( lstRespuesta[0].respuesta.mensaje );
                        component.set( "v.isOpen",true );
                        component.set( "v.isComment",true );
                        component.set( "v.inComment",lstRespuesta[0].respuesta.mensaje );
                    }
                }else{
                    //console.log( 'KO - Fallo conexión Talend - Oracle.' );
                    helper.helperMensaje(
                        "Excepción controlada.",
                        "Fallo ejecucion, el servicio de consulta PQRS no se encuentra disponible, consulte al administrador.",
                        "Error"
                    );
                    $A.get( "e.force:closeQuickAction" ).fire();
                }
            }else{
                //console.log( 'KO - Fallo conexión Salesforce - Talend.' );
                helper.helperMensaje(
                    "Excepción controlada.",
                    "Fallo ejecucion, el servicio de consulta PQRS no se encuentra disponible, consulte al administrador.",
                    "Error"
                );
                $A.get( "e.force:closeQuickAction" ).fire();
            }
        });
        $A.enqueueAction( action );
    },
    closeModel : function( component, event, helper ){        
        component.set( "v.isOpen",false );
    }
})
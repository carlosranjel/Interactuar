({
    doInit : function(component, event, helper) {
        var registroId = component.get("v.recordId");
        console.log(registroId);

        var action = component.get("c.consultaAvales");
        action.setParams({
            oportunidadId  : registroId
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("entro doInit");
            console.log(state);
            if (state === "SUCCESS") {
                var lista = JSON.parse(response.getReturnValue())
                console.log(lista); 
                if( lista.length > 0 && lista[0].idContacto != null && lista[0].idContacto != '' ){
                    component.set("v.lstEstructura", lista);
                }else if( lista.length > 0 && lista[0].idContacto == null || lista[0].idContacto == '' ){
                    component.set("v.lstEstructura", null);
                }                               
                if( lista.length > 0 && lista[0].oppSincronizada ){
                    console.log( lista[0].oppSincronizada );
                    component.set("v.OppSincronizada",true);
                }else if( lista.length > 0 && ! lista[0].oppSincronizada ){ // lista == null || lista.length == 0 
                    console.log( lista[0].oppSincronizada );
                    component.set("v.OppSincronizada",false);
                }                
            }
        });

        $A.enqueueAction(action);
    }
    ,
    buscaConEnter : function(component, event, helper){
        var noAsociado = true;
        var isEnterKey = event.keyCode === 13;
        var bDocumento = component.find('enter-search').get('v.value');
        var action = component.get("c.buscarContactosAvales");
        var listaEstructura = component.get("v.lstEstructura");

        for(var key in listaEstructura){
           if( listaEstructura[key].numIdentificacion == bDocumento ){
                console.log( listaEstructura[key].numIdentificacion );
                console.log(bDocumento);
                component.set("v.PreviamenteAgregado",true);
                noAsociado = false;
                break;
           }          
        }

        if (isEnterKey && noAsociado) {
            // verificar que se numerico la entrada, de lo contrario mostrar mensaje
            // verificar tamaño de entrada
            // despues de pasar validaciones anteriores hacer la consulta
            component.set('v.estaBuscando', true);
           console.log(bDocumento);

           action.setParams({
              numDocumento : bDocumento
           });
           action.setCallback(this,function(response){
            component.set('v.estaBuscando', false);
            var state = response.getState();
            console.log("busqueda de avales");
            console.log(state);
            if (state === "SUCCESS") {
                var avalesEncontrados = response.getReturnValue();
                console.log(avalesEncontrados);
                component.set("v.avalesEncontrados", avalesEncontrados);
                // si el resultado de la consulta es vacio devolver mensaje
            }
            // si no se encuentra el aval se debe mandar mensaje en el front
           });

           $A.enqueueAction(action);
        }
    }
    ,
    capturaEventoAvalAgregado : function(component, event, helper){
        var nomEvento   = event.getParam("contactoAgregado");
        console.log(nomEvento);        
        if( nomEvento != null){ 
            var conAgregado  = nomEvento.Name;           
            console.log("capturaEventoAvalAgregado");
            console.log(conAgregado);
            component.set("v.avalesEncontrados", null);
            var actualizaListaAvales = component.get("c.doInit");
            $A.enqueueAction(actualizaListaAvales);
        }else{
            component.set("v.avalesEncontrados", null);
        }

    }
    ,
    nuevoAval : function (component, event, helper){
        var idOpp = component.get("v.recordId");
        var action = component.get("c.controlMaximoAval");
        action.setParams({
            oportunidadId : idOpp
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if( state === 'SUCCESS'){
                var resMax = response.getReturnValue();
                if( resMax ){
                    component.set("v.nuevoAval",true);
                    component.set("v.escondeBotonNuevo",false);
                }else{
                    helper.helperMensaje("Limite de Avales","Cupo máximo de Avales alcanzado","Warning");
                }
            }
        });
        $A.enqueueAction(action);
    }
    ,    
    capturaEventoAvalCreado : function(component, event, helper){
        var conEvento   = event.getParam("contactoCreado");
        console.log(conEvento);
        var nombreContacto  = conEvento.Name;
        console.log("capturaEventoAvalCreado");
        console.log(nombreContacto);
        component.set("v.escondeBotonNuevo",true);
        component.set("v.nuevoAval",false);
        var actualizaListaAvales = component.get("c.doInit");
        $A.enqueueAction(actualizaListaAvales);
    }
    ,    
    capturaEventoAvalExpelido : function(component, event, helper){
        var idContacto   = event.getParam("idContactoExpelido");
        console.log(idContacto);        
        console.log("capturaEventoAvalExpelido");
        var actualizaListaAvales = component.get("c.doInit");
        $A.enqueueAction(actualizaListaAvales);
    }
    ,
    EventoAvalClienteAsociado : function(component, event, helper){
        console.log('entra evento - EventoAvalClienteAsociado');
        component.set("v.clienteEncontrado",null);
        var idAvalConvertido   = event.getParam("contactoAvalAsociado");
        console.log(idAvalConvertido);        
        console.log("EventoAvalClienteAsociado");
        var actualizaListaAvales = component.get("c.doInit");
        $A.enqueueAction(actualizaListaAvales);
    }
    ,
    limpiarPill : function(component, event, helper){
        component.set("v.PreviamenteAgregado",false);
        component.set("v.ClienteNoEncontrado",false);
        component.set("v.clienteEncontrado",null);
    }
    ,
    buscaClienteConEnter : function( component, event, helper ) {        
        var isEnterKey = event.keyCode === 13;
        var docCliente = component.find('enter-search-client').get('v.value');
        

        if( isEnterKey ){
            var action = component.get("c.consultaClienteAconvertir");
            var registroId = component.get("v.recordId");
            component.set('v.estaBuscandoCliente', true);
            console.log(docCliente);

            action.setParams({
                docCliente : docCliente,
                idOpp : registroId
            });

            action.setCallback(this,function(response){
            component.set('v.estaBuscandoCliente', false);
            var state = response.getState();
            console.log("busqueda de clientes para convertir en avales");
            console.log(state);
            if (state === "SUCCESS") {
                var clienteEncontrado = response.getReturnValue();
                console.log(clienteEncontrado);
                if( clienteEncontrado.Numero_de_identificacion__c != null ){
                    component.set("v.clienteEncontrado", clienteEncontrado);
                    console.log('cliente asignado');
                }else if( clienteEncontrado.Name == 'Contacto Existente' ){
                    helper.helperMensaje('Alerta!!!','Este Cliente ya existe como Aval','Warning');
                }else{
                    console.log('NUMERO DE DOCUMENTO DE CLIENTE NO ASIGNADO');
                    //helper.helperMensaje("Advertencia","El cliente no se encontro","Warning");
                    component.set("v.ClienteNoEncontrado",true);
                }
            
                }
            });

            $A.enqueueAction(action);
        }
    }
})
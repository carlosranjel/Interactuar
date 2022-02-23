({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAllPickList");
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);      
            if ( state === "SUCCESS") {
                component.set("v.mapPickList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }   
    ,
    Guardar : function(component, event, helper){
        var cObligatorio = '';
        console.log('guardar');
        var empleado     = component.get("v.empleadoSeleccionado");
        var idActivo     = component.get("v.idActivo");
        var estado       = component.get("v.estadoSeleccionado");
        var prioridad    = component.get("v.prioridadSeleccionado");
        var tgestion     = component.get("v.gestionSeleccionado");
        var tcontacto    = component.get("v.contactoSeleccionado");
        var asunto       = component.get("v.asuntoSeleccionado");
        var cgestionado  = component.get("v.gestionCheckSeleccionado");
        var fVencimiento = component.get("v.fechaVSeleccionado");
        var fAcuerdo     = component.get("v.fechaASeleccionado");
        var pago         = component.get("v.pagoSeleccionado");
        var descripcion  = component.get("v.descripcionSeleccionado");        
        
        cObligatorio = helper.validaCampos(empleado,tgestion,tcontacto,asunto,fVencimiento,fAcuerdo,pago,descripcion);
        
        if( cObligatorio == '' ){
        var action = component.get("c.gestionDeCobranza");
        action.setParams({
            empleado     : empleado,
            idActivo     : idActivo,
            estado       : estado,
            prioridad    : prioridad,
            tgestion     : tgestion,
            tcontacto    : tcontacto,
            asunto       : asunto,
            cgestionado  : cgestionado,
            fVencimiento : fVencimiento,
            fAcuerdo     : fAcuerdo,
            pago         : pago,
            descripcion  : descripcion
        });
        action.setCallback(this,function(response){
            console.log('5');
            var state = response.getState();
            console.log(state);
            if( state === "SUCCESS" ){
            var respuesta = JSON.parse(response.getReturnValue());
            if( respuesta.proceso && respuesta.tarea != null){
                helper.helperMensaje('Gestión de Cobranza creada','La Gestión de cobranza ha sido creada','Success');
                $A.get('e.force:refreshView').fire();
            }else if(respuesta.proceso == 'EtapaIncorrecta'){
                helper.helperMensaje('Etapa de Activo','La etapa del activo debe ser Vencido','Warning');
            }else{
                helper.helperMensaje('Gestión de Cobranza','Inconsistencia! Por favor consulte a su administrador','Warning');
            }
            }else{
                helper.helperMensaje('Error en proceso','Por favor consulte a su administrador','Error');
            }
        });
        $A.enqueueAction(action);
        }else{
            helper.helperMensaje('Campos obligatorios',cObligatorio,'Warning');
        }
    }
    ,
    insertaDatoCheck : function(component, event, helper){
        var cgestionado  = component.get("v.gestionCheckSeleccionado");
        console.log( cgestionado );
        if(  ! cgestionado ){        
        console.log( 'paso a true' );
        component.set("v.gestionCheckSeleccionado", true);
        }else{
        console.log( 'paso a false' );
        component.set("v.gestionCheckSeleccionado", false);
        }
    }
    ,
    // Recibe el empleado que viene en el evento.   
    handleComponentEvent : function(component, event, helper) {
     
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log( 'handleComponentEvent' );
        console.log( selectedAccountGetFromEvent.Name );
        component.set("v.empleadoSeleccionado" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
    
        var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    }
    ,
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    }
    ,
    // limpia el empleado seleccionado 
    clear :function(component,event,heplper){
    console.log('clear');
    var pillTarget = component.find("lookup-pill");
    var lookUpTarget = component.find("lookupField"); 

    $A.util.addClass(pillTarget, 'slds-hide');
    $A.util.removeClass(pillTarget, 'slds-show');

    $A.util.addClass(lookUpTarget, 'slds-show');
    $A.util.removeClass(lookUpTarget, 'slds-hide');

    component.set("v.SearchKeyWord",null);
    component.set("v.listOfSearchRecords", null );
    component.set("v.empleadoSeleccionado", {} );   
    }
    ,
    onfocus : function(component,event,helper){
        console.log('onfocus');
        $A.util.addClass(component.find("mySpinner"), "slds-show");
         var forOpen = component.find("searchRes");
             $A.util.addClass(forOpen, 'slds-is-open');
             $A.util.removeClass(forOpen, 'slds-is-close');
         // Get Default 5 Records order by createdDate DESC  
          var getInputkeyWord = '';
          helper.searchHelper(component,event,getInputkeyWord);
     }
     ,
     keyPressController : function(component, event, helper) {         
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if( getInputkeyWord.length > 0 ){
              var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
             helper.searchHelper(component,event,getInputkeyWord);
         }
         else{  
              component.set("v.listOfSearchRecords", null ); 
              var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
           }
     }
})
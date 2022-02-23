({
    doInit : function( component, event, helper ){
        let idsObject = component.get("v.recordId");
        console.log('viene');
        console.log(idsObject);
        if( idsObject.startsWith('006') ){
            component.set("v.quickAction",true);
            let validaOpor = component.get("c.validaOportunidad");
            $A.enqueueAction(validaOpor);
        }else{
            component.set("v.globalAction",true);
            let continuarInterfaz = component.get("c.interfaz");
            $A.enqueueAction(continuarInterfaz);
        }
    },
    
    validaOportunidad : function( component, event, helper ){
        let registroOpp = component.get("v.recordId");

        let action = component.get("c.consultaOportunidad");

        action.setParams({
            idOportunidad : registroOpp
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if (state === "SUCCESS") {                
                let oportunidad = response.getReturnValue();
                //alert(oportunidad.NomApe_Ben1__c);
                if(oportunidad.NomApe_Ben1__c == '.'){
                    helper.helperMensaje("NOMBRE BENEFICIARIO","Actualice la información del Beneficiario 1 en la Oportunidad","Warning");
                }else{
                    let paraFirmar = component.get("c.firman");
            		$A.enqueueAction(paraFirmar);
                }            
            }
        });
        $A.enqueueAction(action);
    },
    firman : function(component, event, helper) {
        let registroOpp = component.get("v.recordId");
        console.log(registroOpp);
        let action = component.get("c.firmantes");
        action.setParams({
            idOportunidad : registroOpp
        });
        component.set("v.Spinner",true);
        action.setCallback(this,function(response){
            component.set("v.Spinner",false);
            console.log('call resp');
            let state = response.getState();
            if (state === "SUCCESS") {                
                let rpta = JSON.parse(response.getReturnValue());
                console.log(rpta);
                if( rpta.proceso ){
                    component.set("v.urlOncredit", rpta.url);
                    component.set("v.urlConstruida",true);
                }else{
                    component.set("v.urlConstruida",false);
                }                
            }
        });

        $A.enqueueAction(action);
    }
    ,
    interfaz : function( component, event, helper ){
        let action = component.get("c.interfazOnCredit");
        console.log('entrada');
        action.setCallback(this,function(response){
            let state = response.getState();
            if (state === "SUCCESS") {                
                let rpta = JSON.parse(response.getReturnValue());
                console.log(rpta); 
                if( rpta.proceso ){
                    component.set("v.urlOncredit", rpta.url);
                    component.set("v.urlConstruida",true);
                }else{
                    component.set("v.urlConstruida",false);
                }               
            }
        });
        $A.enqueueAction(action);
    }
    ,
    cerrarVenta : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})
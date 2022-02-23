({
    SearchProducts: function(component,inputsearch, idQuote) {
        component.set("v.showSpinnersearch", true); 
        var action = component.get('c.OtrosProduct');
        action.setParams({
            "idQuote" : idQuote,
            "nombre" : inputsearch
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                if(storeResponse.length>0){                       
                    component.set("v.Otrosprods", storeResponse);
                    component.set("v.showSpinnersearch", false); 
                }else{
                    component.set("v.showSpinnersearch", false);  
                }         
            }    
        });
        $A.enqueueAction(action);  
    },
    
    mensaje : function(component, mensaje,tipo) {
        var tipotoast=tipo;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            duration: "550",
            type:tipotoast,
            message: mensaje
           
        });
        toastEvent.fire();
    },
    cancelDialog : function(component,ev, helper) {
        
        var payload = component.get("v.recordId");                        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": payload,
            "slideDevName": "Detail"
        });
        navEvt.fire();     }
    ,
    saveQuote: function(component, event, helper){
        console.log("cmp.getElements(): ", component.getElements());
        var cotizacionId= component.get("v.recordId");
        var idProductoSalesforce = component.find("idProductoSalesforce").get("v.class");
        console.log(idProductoSalesforce);
        var unitPrice = component.find("UnitPrice").get("v.value");
        var quantity = component.find("Quantity").get("v.value");
        var plazoMeses = component.find("Plazo_meses__c").get("v.value");
        var periodoGraciaMeses = component.get("v.periodoGracia"); 
        var fondo = component.find("Fondo__c").get("v.value");
        var score = component.get("v.Score");
        var scoreDes = component.get("v.ScoreDescripcion");
        var errorCode = component.get("v.ErrorScore");
        
        var tipoRegistro = component.get("v.tipoRegistro");
        var productCode = component.find("productCode").get("v.value");   
         var storeResponse;
        var action = component.get('c.insertaQuoteLineItem');
        var tipoMensaje = 'success';
        var mensaje = 'Producto Creado exitosamente';
		 
    
        console.log(idProductoSalesforce);
        console.log(unitPrice);
        console.log(quantity);
        console.log(plazoMeses);
        console.log(periodoGraciaMeses);
        console.log(fondo);
        console.log(score);
        console.log(scoreDes);
        console.log("errorcode " +errorCode);        
        console.log(productCode);
        console.log(tipoRegistro); 
        if((quantity <=0||quantity == null)){
		      helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Cantidad','Warning');            
        }else if((unitPrice <=0||unitPrice ==null)){
             helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Precio','Warning');          
        }else if(plazoMeses <= 0||plazoMeses ==null){
             helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Plazo Meses','Warning');   
        }else if(fondo == null){
             helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Fondo','Warning');
        }else{
            if(component.get("v.scoreConsultado") == true)
            { 
                component.set("v.showSpinner", true);
                action.setParams({
                    "idProductoSalesforce" :idProductoSalesforce, 
                    "cotizacionId" : cotizacionId,
                    "unitPrice" : unitPrice,
                    "quantity" : Math.trunc(quantity),
                    "plazoMeses" : plazoMeses,
                    "periodoGraciaMeses" : periodoGraciaMeses,
                    "fondo" : fondo,
                    "score" : score,
                    "scoreDes" : scoreDes,
                    "errorCode" : errorCode,
                    "tipoRegistro" :tipoRegistro,
                    "productCode":productCode
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                         storeResponse = response.getReturnValue();
                        console.log(state);
                        console.log("store Response"+ storeResponse);
                        if(storeResponse !== "Producto Creado exitosamente"){
                            mensaje = storeResponse;
                            tipoMensaje = 'error';
                        }
                        $A.get("e.force:refreshView").fire(); 
                    }else{
					    var errors = response.getError();
                        tipoMensaje = 'error';
                        mensaje = 'Hubo un Error al crear el producto';
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                         errors[0].message);
                                mensaje = errors[0].message;
                            }
                        } else {
                            console.log("Unknown error");
                        }                        
                        console.log("error en consumo insert");
 
                    }
                    console.log(mensaje);
                    console.log(tipoMensaje);
                    if(mensaje !== "Producto Creado exitosamente"){
                        
                        component.set("v.btnFormBack", false);
                        component.set("v.btnFormNext", false);
                        component.set("v.btnFormSave", false);
                        component.set("v.btnFormCancel", false);
                        component.set("v.editarCampos",false);
                        component.set("v.showSpinner", false);
                        component.set("v.showSpinner", false);
                        component.set("v.showform", false);
                        component.set("v.showformModificarPrd", false);
                        component.set("v.erroresSF", true); 
                        component.set("v.ErrorSF", mensaje);
                        
                        
                    }else{
                        component.set("v.showSpinner", false);
                        helper.mensaje(component,mensaje ,tipoMensaje);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                   
                });
 			  $A.enqueueAction(action); 
            } 
        }
        
    },
       verificaScore : function(component,event,helper){
        
        var selectedItem = event.currentTarget;
        
        var unitPrice, quantity, plazoMeses, periodoGraciaMeses, productCode, fondo;
        var cotizacionId= component.get("v.recordId");
        var mensaje; 
        var mensaje2;
        quantity = component.get("v.Quantity") ;
        unitPrice = component.get("v.UnitPrice") ;
        plazoMeses = component.get("v.plazo") ;
        periodoGraciaMeses = component.get("v.periodoGracia");
        productCode = component.find("productCode").get("v.value");   
        fondo = component.find("Fondo__c").get("v.value");            
        console.log(quantity);
        console.log(unitPrice);
        console.log(plazoMeses);
        console.log(periodoGraciaMeses);
        console.log(productCode);
        console.log(fondo);   
        console.log("antes de score");
        console.log(component.get("v.scoreConsultado"));
        
        if(component.get("v.tipoRegistro") === "Servicios_de_conocimientos_y_redes")
        {
            component.set("v.scoreConsultado",true);
            helper.saveQuote(component,event,helper);
        }else if(component.get("v.scoreConsultado")==false)
        { 
           if((quantity <=0||quantity == null)){
    
               helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Cantidad','Warning');            
            }else if((unitPrice <=0||unitPrice ==null)){
                 helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Precio','Warning');          
            }else if(plazoMeses <= 0||plazoMeses ==null){
                 helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Plazo Meses','Warning');   
            }else if(fondo == null || fondo ===""){
                 helper.mensaje(component,'Para guardar  el registro, favor diligenciar el campo Fondo','Warning');
            }else
            {
                component.set("v.showSpinner", true);   
                
                var action = component.get("c.consultaScore");
                action.setParams({
                    cotizacionId:cotizacionId,
                    unitPrice: unitPrice,
                    quantity:quantity,
                    plazoMeses:plazoMeses,
                    periodoGraciaMeses:periodoGraciaMeses,
                    productCode:productCode
                });
                
                action.setCallback(this,function(response){
                    var state = response.getState();
                    console.log(state);
                    if(state === "SUCCESS")
                    {
                        
                        var resControlador = JSON.parse(response.getReturnValue());
                        if(resControlador.estado === "OK")
                        {
                            mensaje = 'El resultado del Score es '  + resControlador.descripcion;
                            mensaje2 = '¿Desea modificar el producto antes de Guardar?';
                            component.set("v.mensajeScore2",mensaje2);                           component.set("v.Score",resControlador.score);
                            component.set("v.ScoreDescripcion",resControlador.descripcion);
                            component.set("v.ErrorScore",null);
                            component.set("v.showSpinner", false);  
                            component.set("v.editarCampos",true);
                            component.set("v.consultaScore",false); 
                            component.set("v.mensajeScore",mensaje);
                        }else
                        {
                            mensaje = resControlador.mensajeError;
                            mensaje2 = '¿Desea modificar el producto antes de Guardar?';
                            component.set("v.mensajeScore2",mensaje2);                            
                            component.set("v.Score",0);
                            component.set("v.ScoreDescripcion",null);
                            component.set("v.ErrorScore",resControlador.mensajeError);
                            component.set("v.showSpinner", false);  
                            component.set("v.editarCampos",true);
                            component.set("v.consultaScore",false); 
                            component.set("v.mensajeScore",mensaje);
                        }
                        
                    }
                    else{
                        component.set("v.showSpinner", false); 
                        component.set("v.editarCampos",true);
                        mensaje =  'No fue Posible calcular el Score por indisponibilidad del servicio en R';
                        mensaje2 = '¿Desea modificar el producto antes de Guardar?';
                        component.set("v.mensajeScore2",mensaje2);
                        component.set("v.mensajeScore",mensaje);
                        component.set("v.consultaScore",false); 
                        
                        component.set("v.Score",0);
                        component.set("v.ScoreDescripcion",null);
                        component.set("v.ErrorScore",'No fue Posible calcular el Score por indisponibilidad del servicio en R');
                    }
                    
                });
                $A.enqueueAction(action);
                component.set("v.scoreConsultado",true);
            }
        }else{
            component.set("v.editarCampos",false);
            helper.saveQuote(component,event,helper);
        }
    }
    
})
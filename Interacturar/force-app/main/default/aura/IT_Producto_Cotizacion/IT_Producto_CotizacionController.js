({
    Refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        //$A.get("e.force:closeQuickAction").fire();
    },
    showToolTip : function(component, event, helper) {
        component.set("v.tooltip" , true);
        
    },
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
    OnChangePeriodoGracias : function(component,event,helper)
    {
        let newValue =  event.getSource().get("v.value") ; 
        component.set('v.periodoGracia',newValue);
        console.log(newValue);
    },
    OnChangeFondo : function(component,event,helper)
    {
        let newValue =  event.getSource().get("v.value") ; 
        component.set('v.fondo',newValue);
        console.log(newValue);
    },
    plazo : function(component,event,helper)
    {
        let newValue =  event.getSource().get("v.value") ; 
        component.set('v.plazo',newValue);
        console.log(newValue);
    },
    UnitPrice : function(component,event,helper)
    {
        let newValue =  event.getSource().get("v.value") ; 
        component.set('v.UnitPrice',newValue);
        console.log(newValue);
    },
    Quantity : function(component,event,helper)
    {
        let newValue =  event.getSource().get("v.value") ; 
        component.set('v.Quantity',newValue);
        console.log(newValue);
    },    
    doInit : function(component, event, helper) {    
        var idCotizacion= component.get("v.recordId");
        console.log(idCotizacion);
        component.set('v.showSpinner', true);   
        component.set('v.columns', [
            { label: 'Nombre del Producto', fieldName: 'Name', type: 'text', initialWidth: 450},
            { label: 'Código de Producto', fieldName: 'ProductCode', type: 'text'},
            { label: 'Código Portafolio', fieldName: 'Codigo_portafolio__c', type: 'text'},
            { label: 'Identificador Portafolio', fieldName: 'Identificador_portafolio__c', type: 'text'},
             
           
            { label: 'Familia de Productos', fieldName: 'Family', type: 'text'} 
        ]);
        var action = component.get('c.OtrosProduct2');
        action.setParams({"idCotizacion" : idCotizacion });    
        action.setCallback(this, function(response) {
            try {     
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var storeResponse = response.getReturnValue();
                    console.log(storeResponse);
                    if(storeResponse.length>0){
                        for(var key in storeResponse)
                        {
                            for(var key2 in storeResponse[key])
                            {  
                                if (storeResponse[key][key2].hasOwnProperty('DeveloperName')) { 
                                    component.set('v.tipoRegistro',storeResponse[key][key2].DeveloperName);
                                }
                            }
                        }
                        component.set('v.Otrosprods', response.getReturnValue());
                        //component.set("v.Otrosprods", storeResponse);
                        $A.get('e.force:refreshView').fire();
                    }
                    else{
                        console.log('mensaje');
                       // helper.mensaje(component,'Los Contactos no estan disponible.');      
                    }   
                }   
                component.set("v.showSpinner", false);
            }
            catch (e) {  
                component.set("v.showSpinner", false);   
            }      
        });
        $A.enqueueAction(action); 
        var action2 = component.get('c.validaTipoCliente');
        action2.setParams({"idCotizacion" : idCotizacion });
        action2.setCallback(this, function(response2) {
            var state2 = response2.getState();      
            if (state2 === "SUCCESS") { 
                var storeResponse2 = response2.getReturnValue();
                component.set("v.tipoPersona",storeResponse2);
                console.log('es persona j' +component.get('v.tipoPersona'));  
                if (storeResponse2 ==="Juridica")
                {
                    component.set("v.scoreConsultado",true);
                    
                    console.log(component.get("v.scoreConsultado"));
                    component.set("v.Score",-1);
                    component.set("v.ScoreDescripcion",null);
                    component.set("v.ErrorScore","Persona Juridica");
                }
            }
        });
        $A.enqueueAction(action2);        
    },
    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log(selectedRows);
        cmp.set('v.selectedRowsCount', selectedRows.length);
        var arrSelect = [];
        var arrayProductos= [];
        let num = 0
        for(var key in selectedRows)
        {  num = num + 1;
         arrayProductos.push({'num':num,'Id':selectedRows[key].Id,'nombre':selectedRows[key].Name,'codeProduct':selectedRows[key].ProductCode,'cantidad':''});
         
         arrSelect.push({'num':num,'Id':selectedRows[key].Id,'nombre':selectedRows[key].Name,'codeProduct':selectedRows[key].ProductCode});
        }
        cmp.set("v.productosArray",arrayProductos);
        cmp.set("v.cantidadProductos",num);
        cmp.set("v.columnsSelected",arrSelect);
        console.log('aaa');
        console.log(arrSelect);
    },
    searchproducts: function(component, event, helper){   
        var idQuote = component.get("v.recordId");
         
        var validity = component.find("searchinp").get("v.validity");
        var inputsearch = component.find("searchinp").get("v.value");
        console.log(validity.valid); 
        console.log(component.find("searchinp").get("v.value"));
        if(validity.valid==true){
            helper.SearchProducts(component,inputsearch,idQuote);
        }
        else{
            component.set("v.showSpinnersearch", false); 
        }
    },
    validar: function(component,event,helper){
        
        component.set('v.unitPriceBoolean',false);
        
    }
    , 
        verificaFondo : function(component,event,helper){
        var cotizacionId = component.get("v.recordId");
        var unitPrice,quantity,fondo;
        quantity = component.get("v.Quantity");
        unitPrice = component.get("v.UnitPrice");
        fondo = component.find("Fondo__c").get("v.value");
                    	console.log('es tipo juridca' + component.get("v.tipoPersona"));    
        if(component.get("v.tipoRegistro") === "Servicios_de_conocimientos_y_redes" || component.get("v.tipoPersona") === "Juridica")
        {    

              helper.verificaScore(component,event,helper);   
        
        }else{
			if((quantity <=0||quantity == null) || (unitPrice <=0||unitPrice ==null)  || fondo == null  )
            {
                helper.mensaje(component,'Para consultar el fondo, favor llene  los campos fondo,cantidad, precio.','warning');
            }else{
                component.set("v.showSpinner", true);   
                var action = component.get("c.validaFondo");
                var storeResponse;
                action.setParams({
                    cotizacionId:cotizacionId,
                    fondo:fondo,
                    unitPrice: unitPrice,
                    quantity:quantity,                    
                }
                );
                action.setCallback(this,function(response){
				var state = response.getState();
                    if(state == "SUCCESS"){
                    storeResponse = response.getReturnValue();     
                    component.set("v.showSpinner", false);      
                        if(storeResponse === 'OK'){
                            console.log('verifica score');
                            
                            helper.verificaScore(component,event,helper);
                           console.log('fin verifica score');
                            //component.set("v.ventanaConsultaFondo",true);
                        }else{
                            component.set("v.ventanaConsultaFondo",true);
							component.set("v.mensajeErrorConsultaFondo",storeResponse);	                            
                        }    
                    }                    
                });
                $A.enqueueAction(action);
            }                                   
        }
    },
 
    
    OtrosProds: function (component, event, helper) {
        component.set("v.showSpinner", true);   
        var nombre='';
        var action = component.get('c.OtrosProduct2');
        action.setParams({
            "nombre" : nombre
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                if(storeResponse.length>0){                       
                    component.set("v.Otrosprods", storeResponse);
                    $A.get('e.force:refreshView').fire();
                    //this.Refresh(component, event, helper);
                }else{
                  //  helper.mensaje(component,'Ningún Contacto Seleccionado');  
                    //component.set("v.refresh",true);
                }        
            }    
            component.set("v.showSpinner", false);  
        });
        $A.enqueueAction(action);  
    },
    closeQuickAction: function(cmp, ev, helper) {
       $A.get("e.force:closeQuickAction").fire(); 
        
    },
    closeModel : function(component, helper, event){
         component.set("v.scoreConsultado",false);
        component.set("v.editarCampos",false); 
    },
    
    siguiente: function(cmp, ev, helper) {
        cmp.set("v.showform", false); 
        cmp.set("v.showformModificarPrd", true);    
        cmp.set("v.btnFormBack", true);   
        cmp.set("v.btnFormSave", true);   
        cmp.set("v.btnFormNext", false);   
        
       
        
    },
    atras: function(cmp, ev, helper) {
        cmp.set("v.showform", true);  
        cmp.set("v.showformModificarPrd", false);   
        cmp.set("v.btnFormBack", false);   
        cmp.set("v.btnFormSave", false);  
        cmp.set("v.btnFormNext", true);  
         
    },
    closeErrors : function(component,helper,event){
        $A.get("e.force:closeQuickAction").fire();
    },
    closeModelFondo : function(component, helper, event){
        component.set("v.ventanaConsultaFondo",false); 
    },
    guardarProducto : function(component,event,helper){
       helper.verificaScore(component,event,helper);   
      //helper.saveQuote(component,event,helper);
    }
    
})
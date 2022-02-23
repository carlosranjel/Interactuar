({
    seleccionaEmpleado : function(component, event, helper){      
        // get the selected record from list  
          var empleado = component.get("v.empleado");
        // call the event   
          var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute. 
        console.log('selecciona empleado') ;
        console.log(empleado.Name) ;
             compEvent.setParams({"recordByEvent" : empleado });  
        // fire the event  
             compEvent.fire();
        }
})
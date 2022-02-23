({
    resaltaTarea : function(component, event, helper) {
        console.log('activo onmouseover');
        component.set("v.resaltaTarea",true);
    }
    ,
    noResaltaTarea : function(component, event, helper) {
        console.log('activo onmouse-out');
        component.set("v.resaltaTarea",false);
    }
    ,
    goToTarea : function(component, event, helper) {
        var idTarea = component.get("v.tarea.Id");
        var tareaEvent = $A.get("e.force:navigateToSObject");
        tareaEvent.setParams({
            "recordId" : idTarea
        });
        tareaEvent.fire();
    }
    ,
    resaltaBt : function(component, event, helper) {
        console.log('activo onmouseover');
        component.set("v.variante",'Neutral');
    }
    ,
    noResaltaBt : function(component, event, helper) {
        console.log('activo onmouse-out');
        component.set("v.variante",'base');
    }
 
})
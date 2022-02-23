({
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
        
    }, 
    deletingBeneficiario : function(component) {
        let contacto = component.get("v.contacto");

        let action = component.get("c.eliminaBeneficiario");
        action.setParams({
            idContacto: contacto.Id,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('Correcto', 'El Beneficiario fue eliminado', 'success');
            }else{
               this.showToast('Error', 'El Beneficiario no pudo ser eliminado', 'error');
            }
        });

        $A.enqueueAction(action);
        
    }, 
})
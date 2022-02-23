({
    onLoad : function(component, event, helper) {
        component.set("v.cargando", false);

    },
    onError : function(component, event, helper) {
        component.set("v.cargando", false);
        helper.showToast('Error', 'Información de Beneficiario no guardada', 'error');

    },
    onSuccess : function(component, event, helper) {
        component.set("v.cargando", false);
        helper.showToast('Beneficiario Guardado', 'Información guardada', 'success');

    },
    onSubmit : function(component, event, helper) {
        component.set("v.cargando", true);

    },
    deleteBeneficiario : function(component, event, helper) {
        component.set("v.cargando", true);
        helper.deletingBeneficiario(component);
    }
})
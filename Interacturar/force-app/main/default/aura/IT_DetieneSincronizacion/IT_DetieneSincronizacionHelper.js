({
	helperMensaje : function(titulo, mensaje, tipo, parametro) {
        var resultadoToastMensaje = $A.get("e.force:showToast");
        resultadoToastMensaje.setParams({
            "title"   : titulo,
            "message" : mensaje,
            "type"    : tipo
        });
        resultadoToastMensaje.fire();
	}
})
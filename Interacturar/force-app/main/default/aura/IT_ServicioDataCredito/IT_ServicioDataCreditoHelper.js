({
  helperMensaje: function(titulo, mensaje, tipo) {
    var resultadoToastMensaje = $A.get("e.force:showToast");
    resultadoToastMensaje.setParams({
      title: titulo,
      message: mensaje,
      type: tipo
    });
    resultadoToastMensaje.fire();
  }
})
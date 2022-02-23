({
	helperMensaje : function(titulo, mensaje, tipo) {
        var resultadoToastMensaje = $A.get("e.force:showToast");
        resultadoToastMensaje.setParams({
            "title"   : titulo,
            "message" : mensaje,
            "type"    : tipo
        });
        resultadoToastMensaje.fire();
    }
    ,
    searchHelper : function(component,event,getInputkeyWord) {        
      var action = component.get("c.lookupEmpleado");
      action.setParams({
      'searchKeyWord': getInputkeyWord,
      'ObjectName' : component.get("v.objectAPIName")
      });

      action.setCallback(this, function(response) {
        $A.util.removeClass(component.find("mySpinner"), "slds-show");
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          if (storeResponse.length == 0) {
          component.set("v.Message", 'No encuentro registros');
          } else {
          component.set("v.Message", '');
          }
          
          component.set("v.listOfSearchRecords", storeResponse);
        }   
      });  
      $A.enqueueAction(action);      
      }
      ,
      validaCampos : function(empleado,tgestion,tcontacto,asunto,fVencimiento,fAcuerdo,pago,descripcion){
        var cObligatorio = '';
        if( empleado == null)
            cObligatorio += 'Asesor asignado - ';        
        if( tgestion == null)
          cObligatorio += 'Tipo de Gestión - ';
        if( tcontacto == null)
          cObligatorio += 'Tipo de Contacto - ';
        if( asunto == null)
          cObligatorio += 'Asunto - ';
        if( fVencimiento == null)
          cObligatorio += 'Fecha de vencimiento - ';
        if( fAcuerdo == null)
          cObligatorio += 'Fecha de acuerdo de pago - ';
        if( pago == null)
          cObligatorio += 'Pago minimo - ';
        if( descripcion == null)
          cObligatorio += 'Comentarios ';        
        return cObligatorio;
      }
})
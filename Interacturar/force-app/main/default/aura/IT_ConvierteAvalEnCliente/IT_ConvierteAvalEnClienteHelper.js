({
	helperMensajeOk : function(titulo, mensaje, tipo, urlCliente) {
        var resultadoToastMensaje = $A.get("e.force:showToast");
        resultadoToastMensaje.setParams({
            "title"   : titulo,
            "message" : mensaje,
            "type"    : tipo,
            messageTemplate: mensaje+'. Encuentra lo {1}!',
            messageTemplateData: ['Cliente', {
                url: urlCliente,
                label: ' AQUI ',
                }
            ],
            duration : '4000'
        });
        resultadoToastMensaje.fire();
    },
    helperMensajeErr : function(titulo, mensaje, tipo) {
        var resultadoToastMensaje = $A.get("e.force:showToast");
        resultadoToastMensaje.setParams({
            "title"   : titulo,
            "message" : mensaje,
            "type"    : tipo,
            duration : '4000'
        });
        resultadoToastMensaje.fire();
    }
    ,
    generaUrl : function(idsObject,nomsObject){
        console.log( idsObject+' - '+nomsObject );
        let urlink = window.location.protocol+'//'+window.location.host ;
        urlink = urlink.replace(".lightning.force.com",".my.salesforce.com");
        urlink = urlink+'/lightning/r/'+nomsObject+'/'+idsObject+'/view';
        console.log('urlink');
        console.log(urlink);
        return urlink;
    }
})
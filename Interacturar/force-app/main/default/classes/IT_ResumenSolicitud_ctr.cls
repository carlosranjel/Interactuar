public with sharing class IT_ResumenSolicitud_ctr {

    private List<ID> idisCliente = new List<ID>();
    private List<ID> idisOpp     = new List<ID>();
    private final transient Account        cliente;
    private final transient Famiempresa__c fami;
    private final transient Opportunity    opp;
    private final transient Quote          quo;
    private final transient QuoteLineItem  qlitem;
    private final transient List<Asociacion_cuenta_contacto__c> lstAvales;

    public IT_ResumenSolicitud_ctr() {
        idisCliente.add( ApexPages.currentPage().getParameters().get('id') );
        idisOpp.add( ApexPages.currentPage().getParameters().get('idOpp') );
        system.debug('id'+idisCliente);
        system.debug('opp'+idisOpp);
        cliente   = (IT_GestorDeConsultas_cls.consultaCuenta( idisCliente ))[0]; 
        opp = (IT_GestorDeConsultas_cls.consultaOportunidadPdf( idisOpp ))[0]; 
        qlitem = (IT_GestorDeConsultas_cls.consultaProductoPorCotizacionPdf( idisOpp ))[0];
        system.debug('cliente' + cliente);
        system.debug('Oportunidad' + opp);
        try{
            lstAvales =  IT_GestorDeConsultas_cls.consultaAsociacionAval( idisOpp );
        }catch(exception ex){}
        system.debug('avales' + lstAvales);
        system.debug('cliente' + cliente.Id);
        try{
            fami      = (IT_GestorDeConsultas_cls.consultaFamiEmpresa( cliente.Id ))[0];       
        }catch(exception ex){}
    }

    public Account getCliente(){
        return cliente;
    }

    public Famiempresa__c getFami(){
        return fami;
    }
    
    public Opportunity getOpp(){
        return Opp;
    }
	
    public QuoteLineItem getqlitem(){
        return qlitem;
    }
    public List<Asociacion_cuenta_contacto__c> getLstAvales(){
        return lstAvales;
    }
}
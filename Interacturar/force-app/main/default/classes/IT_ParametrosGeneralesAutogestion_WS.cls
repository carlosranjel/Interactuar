/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @projecto         Interactuar
* @descripcion      Clase declarada como recurso REST para exponer servicio obtención de parámetros generales

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* --------   1.0   08-Feb-2021  Álvaro Ortega (AO)		      Creación.
**************************************************************************************************************
**/
@RestResource(urlMapping='/ParametrosGeneralesAutogestion/*')
global class IT_ParametrosGeneralesAutogestion_WS {
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Recepción del servicio
    *Date: 08-Feb-2021
    ******************************************************************************************/
    @HttpPost
    global static ResponseDTO doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        System.debug('Recibir Body: ' + strJSONContent);
        
        FromJSON jsonObj = (FromJSON)JSON.deserializeStrict(strJSONContent, FromJSON.class);
        
        ResponseDTO result = new ResponseDTO();
        result.encabezado = buildEncabezado(jsonObj.encabezado);
        
        result.parametrosGeneralesAutogestion.listas.add(getTipoDocuemento());
        result.parametrosGeneralesAutogestion.listas.add(getTipoDocuementoBeneficiario());
        result.parametrosGeneralesAutogestion.listas.add(getTipoCuenta());
        result.parametrosGeneralesAutogestion.listas.add(getParentesco());
        result.parametrosGeneralesAutogestion.listas.add(getEntidadFinanciera());
        result.parametrosGeneralesAutogestion.listas.add(getEstadoCivil());
        result.parametrosGeneralesAutogestion.listas.add(getTipoDeVivienda());
        result.parametrosGeneralesAutogestion.listas.addAll(getProdutosDigitales());
        
        return result;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener id de Productos digitales 
    *Date: 14-Abr-2021
    ******************************************************************************************/
    public static List<ListaParametro> getProdutosDigitales(){
        ListaParametro proDigi = new ListaParametro();
        proDigi.tipoLista = 'Productos digitales';
        proDigi.aplicacionPropietaria = 'SALESFORCE';
        
        ListaParametro proDigiAlt = new ListaParametro();
        proDigiAlt.tipoLista = 'Productos digitales alternos';
        proDigiAlt.aplicacionPropietaria = 'SALESFORCE';
        
        List<Product2> products = [Select Id, Name, ProductCode, IsActive, Aplica_para_Credito_Digital__c, Aplica_para_Credito_Digital_Alterno__c
                                   from Product2 
                                   where (Aplica_para_Credito_Digital__c = True or Aplica_para_Credito_Digital_Alterno__c = True) and IsActive = True];
        
        for( Product2 pro : products){
            ValorParametro val = new ValorParametro();
            val.nombre     = pro.Name;
            val.etiqueta   = pro.Name;
            val.idProducto = pro.ProductCode;
            
            if(pro.Aplica_para_Credito_Digital__c == True){
                proDigi.valores.add(val);
            }
            if(pro.Aplica_para_Credito_Digital_Alterno__c == True){
                proDigiAlt.valores.add(val);
            }
            
        }
        List<ListaParametro> resu = new List<ListaParametro>();
        resu.add(proDigi);
        resu.add(proDigiAlt);
        
        return resu;
        
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Tipo de Vivienda de la entidad Cliente
    *Date: 14-Abr-2021
    ******************************************************************************************/
    public static ListaParametro getTipoDeVivienda(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Tipo de vivienda';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Account.Tipo_de_vivienda__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Estado Civil de la entidad Cliente
    *Date: 14-Abr-2021
    ******************************************************************************************/
    public static ListaParametro getEstadoCivil(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Estado civil del cliente';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Account.Estado_civil__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Tipo de Documento
    *Date: 08-Feb-2021
    ******************************************************************************************/
    public static ListaParametro getTipoDocuemento(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Tipo de documento';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Account.Tipo_de_identificacion__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Tipo de Cuenta
    *Date: 08-Feb-2021
    ******************************************************************************************/
    public static ListaParametro getTipoCuenta(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Tipo de cuenta';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Opportunity.Tipo_de_cuenta__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Tipo de Documento para beneficiario
    *Date: 08-Feb-2021
    ******************************************************************************************/
    public static ListaParametro getTipoDocuementoBeneficiario(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Tipo de documento beneficiario';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Opportunity.Tipo_ideBen1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Parentesco
    *Date: 08-Feb-2021
    ******************************************************************************************/
    public static ListaParametro getParentesco(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Parentesco';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Opportunity.ParentescoBen1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            para.valores.add(val);
        }     
        return para;
    }
    
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Obtener lista de valores de Entidad financiera
    *Date: 08-Feb-2021
    ******************************************************************************************/
    public static ListaParametro getEntidadFinanciera(){
        ListaParametro para = new ListaParametro();
        para.tipoLista = 'Entidad financiera';
        para.aplicacionPropietaria = 'SALESFORCE';
        
        Schema.DescribeFieldResult fieldResult = Opportunity.Entidad_financiera__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        Map<String, Decimal> topes = getTopesBancos();
        for( Schema.PicklistEntry pickListVal : ple){
            ValorParametro val = new ValorParametro();
            val.nombre = pickListVal.getValue();
            val.etiqueta = pickListVal.getLabel();
            val.tope = topes.containsKey(val.etiqueta) ? topes.get(val.etiqueta) : null;
            
            para.valores.add(val);
        }     
        return para;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Metadato de los topes de los bancos
    *Date: 12-Feb-2020
    ******************************************************************************************/
    public static Map<String, Decimal> getTopesBancos(){
        List<Tope_Desembolso_por_Banco__mdt> topes = [select Id, Entidad_financiera__c, Tope__c
                                                      from Tope_Desembolso_por_Banco__mdt];
        
        Map<String, Decimal> topesBanco = new Map<String, Decimal>();
        for(Tope_Desembolso_por_Banco__mdt tope : topes){
            topesBanco.put(tope.Entidad_financiera__c, tope.Tope__c);
        }
        return topesBanco;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Encabezado de respuesta
    *Date: 08-Feb-2020
    ******************************************************************************************/
    public static Encabezado buildEncabezado(Encabezado request){
        Encabezado encabezado = new Encabezado();
        encabezado.fecha = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        encabezado.identificador = request.identificador;
        encabezado.integracion = 'Parámetros generales Autogestión';
        encabezado.operacion = request.operacion;
        encabezado.origen = 'SALESFORCE';
        encabezado.destino = request.origen;
        
        return encabezado;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información recibida
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class FromJSON{
        public Encabezado encabezado;
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class Encabezado{
        public String fecha;
        public String identificador;
        public String integracion;
        public String operacion;
        public String origen;
        public String destino; 
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function: Clase modelo de la información enviada
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class ResponseDTO{
        public Encabezado encabezado;
        public ParametrosGeneralesAutogestion parametrosGeneralesAutogestion = new ParametrosGeneralesAutogestion();
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class ParametrosGeneralesAutogestion{
        public List<ListaParametro> listas = new List<ListaParametro>();
    }
    
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class ListaParametro{
        public String tipoLista;
        public List<ValorParametro> valores = new List<ValorParametro>();
        public String aplicacionPropietaria;
    }
    /******************************************************************************************
    *Author:  Álvaro Ortega
    *Function:
    *Date: 08-Feb-2020
    ******************************************************************************************/
    global class ValorParametro{
        public String nombre;
        public Decimal tope;
        public String etiqueta;
        public String idProducto;
    }

}
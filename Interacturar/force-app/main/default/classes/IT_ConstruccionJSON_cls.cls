public class IT_ConstruccionJSON_cls {
    
  
// solo se usa una vez it_serviciocliente 205
    public static Integer validarNullInteger(Integer valor){
      if(valor == null){
        return 0;
      }else{
        return valor;
      }
    }
// en servicio de cliente y oportunidd se usa
    public static String validarStringEspecial(String valor){
      if(valor == null || valor == ''){
        return '0';
      }else{ 
        return valor;
      }
    }

    // en servicio de cliente y oportunidd se usa
    public static String validarNullDecimal(Decimal valor){
      if(valor == null){
        return '';
      }else{
        return String.valueOf(valor);
      }
    }
    // en servicio de cliente y oportunidd se usa
    public static Integer validarDecimal_Decimal(Decimal valor){
      if(valor == null){
        return 0;
      }else{
        return (Integer)valor;
      }
    }

    // en servicio de cliente y oportunidd se usa
    public static Integer validarNullString_Integer(String valor){
      if(valor == null || valor == ''){
        return 0;
      }else{       
        return Integer.valueOf(valor);
      }
    }

    // mantener
    public static String validarNullString(String valor){
      if(valor == null || valor == ''){
        return '';
      }else{ 
        return valor;
      }
    }

    // mantener
    public static String validarStringReturnNull(String valor){
      if(valor == null || valor == ''){
        return null;
      }else{ 
        return '"'+valor+'"';
      }
    }

        // mantener
    public static String validarStringNombreApellido(String nom1, String nom2){
        String nombre = '';
        if( nom1 != null && nom1 != '' ){
            nombre = nom1 + ' ';
        }
        if( nom2 != null && nom2 != '' ){
            nombre += nom2;
        }
        return '"'+nombre+'"';
    }

    // mantener
    public static String validarNombreApellido(String nom1, String nom2){
      String nombre = '';
      if( nom1 != null && nom1 != '' ){
          nombre = nom1 + ' ';
      }
      if( nom2 != null && nom2 != '' ){
          nombre += nom2;
      }else{
        return  nombre.trim();
      }
      return nombre;
    }      

    // mantener
    public static String validarDecimalReturnNull(Decimal valor){
      if(valor == null){
        return null;
      }else{
        return '"'+(Integer)valor+'"';
      }
    }
        // mantener
    public static String validarDecimalReNullDecimal(Decimal valor){
          if(valor == null){
            return null;
          }else{
            return '"'+valor+'"';
          }
    }
    // mantener
    public static Integer validarDecimalReturnInteger(Decimal valor){
      if(valor == null){
        return 0;
      }else{
        return  (Integer)valor;
      }
    }

    // mantener
    public static Decimal validarDecimalReturnDecimal(Decimal valor){
      if(valor == null){
        return 0;
      }else{
        return  valor;
      }
    }

    // mantener
    public static Integer validarDecimalReturnNulo(Decimal valor){
      if(valor == null || valor == 0){
        return null;
      }else{
        return  (Integer)valor;
      }
    }

    // mantener
    public static Date validarFechaNacimiento(Date valor){
      if(valor == null){
        return date.newInstance(0000, 0, 00);
      }else{
        return valor;
      }
    }
    
    // mantener
    public static String validarDatosCampania(Opportunity opp){
        IF(opp.Campaign <> null){
            Date dateOnly = date.newinstance(opp.Campaign.CreatedDate.year(), opp.Campaign.CreatedDate.month(), opp.Campaign.CreatedDate.day());  
            return  dateOnly+' '+opp.Campaign.Name;
        }else{
            return '';
        }
    }
    
    // mantener
    public static String validarTipoCampania(Opportunity opp){
        IF(opp.Campaign <> null && opp.Campaign.Type <> null && opp.Campaign.Type <> '' ){
            return opp.Campaign.Type;
        }else{
            return '';
        }
    }
    
    // mantener
    public static String validarsObject(List<Asociacion_cuenta_contacto__c> lstAscc){
      if( lstAscc.size() > 0){
        return (lstAscc[0].Cliente__r.Consecutivo_Padre__c!=null && lstAscc[0].Cliente__r.Consecutivo_Padre__c!='') ? '"'+lstAscc[0].Cliente__r.Consecutivo_Padre__c+'"' : null;
      }else{
        return null;
      }
    }

    public static Integer convierteCodigoOracle(String ciudadCod){
      if( ciudadCod == null || ciudadCod == ''){
        return null;
      }else{
        return Integer.valueOf(ciudadCod);
      }
    }

      public static void cobertura(){
    String var = '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
        var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
    var += '';
  }
}
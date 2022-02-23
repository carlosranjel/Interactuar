@isTest
public class IT_Principal_test {
    public IT_Principal_test() {    }

    @isTest static void triggerFamiEmpresa(){
        Test.startTest();
        /**  INICIO  proceso insert  Empresa_en_domicilio__c == true y con cliente relacionado*/
        IT_FamiEmpresaHandler_cls famiHandler = new IT_FamiEmpresaHandler_cls();
        Actividad_economica__c ae = new Actividad_economica__c();
        //ae.Industria__c = 'Manufactura';
        ae.Codigo_Sector_OR__c = '1';
        ae.Codigo_Sector_SF__c = '1000';
        ae.Sector__c  = 'software y arquitectura de vestir';
        ae.Codigo_Actividad_Economica_OR__c = '13';
        ae.Codigo_Actividad_Economica_SF__c = '100000000';
        ae.Codigo_CIIU__c = 'C13100000000';
        insert ae;
        
        TestDataFactory tf = TestDataFactory.getInstance();
        
        Asociacion_barrio_empleado__c matriz = new Asociacion_barrio_empleado__c();
        matriz.Empleado__c  = tf.newEmpleado().id;
        matriz.Ciudad__c = tf.newPoblacion().Id;
        matriz.Barrio__c = tf.newBarrio().id;
        insert matriz;
        
        Account fami_cuenta = tf.newAccount();
        fami_cuenta.Tiene_empresa__c = true;
        update fami_cuenta;
        
        Famiempresa__c fami = new Famiempresa__c();
        fami.name = 'Fami prueba';
        fami.Actividad_economica__c = ae.id;
        fami.Ciudad_empresa__c  = tf.newPoblacion().id;
        fami.Zona_empresa__c    = tf.newZona().id;
        fami.Barrio_empresa__c  = tf.newBarrio().id;
        fami.Fecha_de_creacion_de_empresa__c  = Date.newInstance(2019,08,21);
        fami.Telefono_empresa__c  = '9556874';
        fami.Numero_de_empleados__c  = 2;
        fami.Empresa_en_domicilio__c = true;
        fami.Cliente_relacionado__c  = fami_cuenta.id;
        insert fami;
        
        fami.Numero_de_empleados__c  = 3;
        update fami;
        /**  FIN  proceso insert  Empresa_en_domicilio__c == true y con cliente relacionado*/
        
        /**  iNICIO  proceso insert  Empresa_en_domicilio__c == true y con PROSPECTO relacionado*/
        Lead lead_cuenta = tf.newLead();
        lead_cuenta.Tiene_empresa__c = true;
        update lead_cuenta;
        
        Famiempresa__c fami2 = new Famiempresa__c();
        fami2.name = 'Fami prueba';
        fami2.Actividad_economica__c   = ae.id;
        fami2.Ciudad_empresa__c        = tf.newPoblacion().id;
        fami2.Zona_empresa__c          = tf.newZona().id;
        fami2.Barrio_empresa__c        = tf.newBarrio().id;
        fami2.Fecha_de_creacion_de_empresa__c  = Date.newInstance(2019,08,21);
        fami2.Telefono_empresa__c      = '9556874';
        fami2.Numero_de_empleados__c   = 2;
        fami2.Empresa_en_domicilio__c  = true;
        fami2.Prospecto_relacionado__c = lead_cuenta.id;
        insert fami2;
        /**  FIN  proceso insert  Empresa_en_domicilio__c == true y con PROSPECTO relacionado*/
        
        /**  INICIO  proceso insert  Empresa_en_domicilio__c == FALSO y con CLIENTE relacionado*/
        Famiempresa__c fami3 = new Famiempresa__c();
        fami3.name = 'Fami prueba';
        fami3.Actividad_economica__c = ae.id;
        fami3.Ciudad_empresa__c  = tf.newPoblacion().id;
        fami3.Zona_empresa__c     = tf.newZona().id;
        fami3.Barrio_empresa__c  = tf.newBarrio().id;
        fami3.Fecha_de_creacion_de_empresa__c  = Date.newInstance(2019,08,21);
        fami3.Telefono_empresa__c  = '9556874';
        fami3.Numero_de_empleados__c  = 2;
        fami3.Empresa_en_domicilio__c = false;
        fami3.Cliente_relacionado__c  = fami_cuenta.id;
        insert fami3;
        
        fami3.Cliente_relacionado__c  = null;
        fami3.Prospecto_relacionado__c = lead_cuenta.id;
        update fami3; 
        /**  INICIO  proceso insert  Empresa_en_domicilio__c == FALSO y con CLIENTE relacionado*/
        
        Test.stopTest();
    }
    
}
@isTest(seeAllData=true)
public class IT_GestorDeConsultas_cls_Test {
    @isTest static void gestorConsultas(){
        Contact contactoNuevo = new Contact();
        
        Opportunity oportunidadNuevo = new Opportunity();
        Integer numeroAleatorioInt1 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        Integer numeroAleatorioInt2 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        String numeroAleatorioStr1 = String.valueOf(numeroAleatorioInt1); // 07-03-2020
        String numeroAleatorioStr2 = String.valueOf(numeroAleatorioInt2); // 07-03-2020
        
        Account cuentaNuevo;    
        cuentaNuevo = new Account (
            Tipo_de_identificacion__c='Cedula de Ciudadania',
            Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
            FirstName='Nombre de cliente',
            LastName='Apellido de cliente',
            Correo_electronico_empresa__c='clientest@clientest.com',
            Telefono_empresa__c='4806539',
            Indicativo_empresa__c = '731',
            Ruralidad_domicilio_empresa__c = True,
            Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
            Personas_a_cargo__pc = 2,
            Autorizacion_uso_de_datos__c = 'Autoriza',
            Medio_de_autorizacion__c = 'Solicitud de vinculacion',
            Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
        );
        insert cuentaNuevo;          
        
        
        
        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;
        
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.Personas_a_cargo__c = 3;    
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;
        
        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        insert aso;
        
        Test.startTest();
        List<ID> idsCuenta = new List<ID>();
        List<ID> idsOpp = new List<ID>();
        idsCuenta.add(cuentaNuevo.id);
        idsOpp.add(oportunidadNuevo.id);
        IT_GestorDeConsultas_cls.consultaCuenta(idsCuenta);
        IT_GestorDeConsultas_cls.consultaOportunidad(oportunidadNuevo.id);
        IT_GestorDeConsultas_cls.consultaOportunidadPdf(idsOpp);
        IT_GestorDeConsultas_cls.consultaProductoPorCotizacion(oportunidadNuevo);
        IT_GestorDeConsultas_cls.consultaProductoPorCotizacion2('123');
        IT_GestorDeConsultas_cls.consultaProductoPorCotizacionPdf(idsOpp);
        IT_GestorDeConsultas_cls.consultaAsociacionAvales(idsOpp);
        Set<String> setId = new Set<String>();
        setId.add('123');
        IT_GestorDeConsultas_cls.consultaProducto(setId);
        IT_GestorDeConsultas_cls.consultaFamiEmpresa(cuentaNuevo.id);
        IT_GestorDeConsultas_cls.consultaFamiEmpresaOpp(cuentaNuevo.id);    
        
        List<ID> idsCon = new List<ID>();
        idsCon.add(contactoNuevo.id);
        IT_GestorDeConsultas_cls.consultaContacto(idsCon);
        IT_GestorDeConsultas_cls.consultaContactos(idsCon);
        
        List<ID> idsOportunidad = new List<ID>();
        idsOportunidad.add(oportunidadNuevo.id);
        IT_GestorDeConsultas_cls.consultaAsociacionAval(idsOportunidad);
        IT_GestorDeConsultas_cls.consultaConsecutivoPadre(idsCon);
        
        Asset act = [SELECT id from asset limit 1];
        List<id> lstActivo = new List<id>();
        lstActivo.add(act.id);
        IT_GestorDeConsultas_cls.consultaconsultaActivos(lstActivo);
        Test.stopTest();
    }
    
    
}
@isTest(seeAllData=true)
global class IT_ServicioCliente_test {
    global IT_ServicioCliente_test() {    }

    
    @isTest static void testClienteSolicitudCredito(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IT_ServicioCliente_test_Mock()); 

            TestDataFactory tf = TestDataFactory.getInstance();
            Account cuenta = tf.newAccount();
            Zona__c zona =  [SELECT id, Codigo_Registro_Zona__c FROM Zona__c WHERE id =: cuenta.Zona_empresa__c limit 1];
            zona.Codigo_Registro_Zona__c = '15';
            update zona;
            System.debug('actualiza Zona: '+ zona);
            cuenta.Zona_empresa__c  = zona.id;
            System.debug('actualiza cuenta: '+ cuenta.Zona_empresa__r.Codigo_Registro_Zona__c);
            List<ID> lstIDcuenta = new List<ID>();
            lstIDcuenta.add(cuenta.id);
            IT_ServicioCliente_cls.obtenerESB(lstIDcuenta);

        Test.stopTest();
    }

        @isTest static void testClienteSolicitudConocimiento(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IT_ServicioCliente_test_Mock()); 

            TestDataFactory tf = TestDataFactory.getInstance();
            Account cuenta = [SELECT id FROM Account WHERE RecordType.DeveloperName = 'Persona_juridica' LIMIT 1];
            List<ID> lstIDcuenta = new List<ID>();
            lstIDcuenta.add(cuenta.id);
            IT_ServicioCliente_cls.obtenerESB(lstIDcuenta);

        Test.stopTest();
    }
    
    @isTest static void testClienteFamiEmpresa(){
        Test.startTest();
			TestDataFactory tf = TestDataFactory.getInstance();
            //Famiempresa__c fami = tf.newFamiempresa();            
            Famiempresa__c fami = [SELECT Actividad_economica__c,
            Actividad_economica__r.Codigo_Actividad_Economica_OR__c,
            Actividad_economica__r.Name,
            Barrio_empresa__r.Codigo_Registro_Barrio__c,Ingresos_ventas__c,
            Ciudad_empresa__c,Costo_mercancia_vendida__c,Disponibilidad_neta_empresa__c,
            Cliente_relacionado__c,Codigo_CIIU__c,Codigo_departamento_empresa__c,
            Codigo_industria_OR_SF__c,Codigo_sector_OR__c,Fecha_de_creacion_de_empresa__c,Id,
            Identificador_Famiempresa__c,Informacion_adicional_complemento_e__c,
            Intercesion_empresa__c,Name,Numero_de_empleados__c,Numero_de_identificacion__c,
            Sector__c,Tipo_de_identificacion__c,Vigente__c,Correo_electronico_empresa__c,
            Departamento_empresa__c,Codigo_ciudad_empresa__c,Ciudad_empresa__r.Name,
            Letra_empresa_a__c,Letra_empresa_b__c,Numero_empresa_a__c,Numero_empresa_b__c,
            Punto_Cardinal_empresa_a__c,Punto_cardinal_empresa_b__c,Ruralidad_domicilio_empresa__c,
            Via_empresa__c,Indicativo_empresa__c,Industria__c,Movil_empresa__c,
            Principales_productos_servicios_1__c,Principales_productos_servicios_2__c,
            Principales_productos_servicios_3__c,Principales_productos_servicios_4__c,
            Principales_productos_servicios_5__c,Telefono_empresa__c,Empleos_a_generar__c,Ingreso_Anual__c,
            Zona_empresa__r.Codigo_Registro_Zona__c,Zona_empresa__r.Name,ubicacion_rural__c
            FROM Famiempresa__c WHERE Numero_de_empleados__c > 0 LIMIT 1];
            IT_ServicioCliente_cls.naturalFamiEmpresa(fami);
        Test.stopTest();
    }


    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     27-02-2020
    ************************************************************************************************/
    global class IT_ServicioCliente_test_Mock implements HttpCalloutMock{   
    global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '{'+
                '"encabezado":{'+
                '"estado":"0",'+
                '"excepcion":"",'+
                '"fecha":"2020-01-07 09:26:58",'+
                '"identificador":"001e000001TbR87AAF-641",'+
                '"mensaje":"",'+
                '"integracion":"Consulta Datacredito Con BPMS",'+
                '"operacion":"1",'+
                '"origen":"ORACLE",'+
                '"destino":"SALESFORCE"'+
                '},'+
                '"cuerpo":{'+
                '"identificacion":"71794224",'+
                '"primerApellido":"Gomezs",'+
                '"primerNombre":"Mauricios",'+
                '"tipoIdentificacion":"C",'+
                '"idProceso":"241928",'+
                '"urlPdf":"",'+
                '"xmlDatacredito" : ""'+
                '}}'                            
                );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
        }
    }
}
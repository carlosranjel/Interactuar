@isTest(SeeAllData=false)
global class IT_GeneracionAutomaticaCredito_tst {
    
    @isTest	static void testAll(){
        TestDataFactory TestDataFactoryT = new TestDataFactory();
        IT_GeneracionAutomaticaCredito.cobertura();
        Campaign camp = new Campaign();
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaña con beneficios').getRecordTypeId();
        camp.Type = 'Credito digital';
        camp.Name = 'test';
        camp.Publico_Objetivo__c = 'test';
        camp.Oficina_Servicio__c = 'Bello';
        camp.Equipo_Comercial_Oficinas_Equipo_Comerci__c = 'Todos';
        camp.Objetivo_de_la_campa_a__c = 'test';
        camp.Capital_impactado__c = 'Todos';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().AddDays(300);
        camp.ExpectedRevenue = 100;
        camp.Meta_en_N_de_creditos__c = 1;
        camp.Meta_en_monto_de_creditos__c = 2;
        camp.Meta_en_monto_de_servicios__c = 1;
        camp.Meta_en_N_de_servicios__c = 1;
        camp.N_de_creditos_desembolsados__c = 1;
        camp.N_de_personas_que_asisten__c = 10;
        camp.Monto_de_creditos_desembolsados__c = 1;
        camp.N_de_servicios_facturados__c = 1;
        camp.ActualCost = 10;
        camp.CodigoCorto__c = '123456789';
        camp.IsActive = true;
        insert camp;
        
        Account acc = new Account();
        acc = TestDataFactoryT.newAccount();  
        acc.Consecutivo_Padre__c = '4s54a5s45a4s';
        update acc;
        
        Account acc1 = new Account();
        acc1 = TestDataFactoryT.newAccountJuridica();  
        acc1.Consecutivo_Padre__c = '4s54a5s45a4s';
        update acc1;
        
        Contact con1 = new Contact();
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacto').getRecordTypeId();
        con1.FirstName = 'Test';
        con1.MiddleName = 'Test';
        con1.LastName = 'test';
        con1.Segundo_Apellido__c = 'Test';
        con1.Genero__c = 'Femenino';
        con1.AccountId = acc1.Id;
        con1.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        con1.Numero_de_identificacion__c = '0123456789';
        insert con1;
        
        TestDataFactory td = TestDataFactory.getInstance();
        Lead pros = new Lead(
            Status='Asignado',
            Tipo_de_identificacion__c='Cedula de Ciudadania',
            Numero_de_identificacion__c= '0123456789',  // 07-03-2020
            Movil_empresa__c = '0123456789',
            FirstName='Nombre de prospecto',
            LastName='Apellido de prospecto',
            Email='mgomezre2006@fmail.com',
            Telefono_empresa__c='4806539',
            Indicativo_empresa__c = '731',
            Ruralidad_domicilio_empresa__c = True, // 07-03-2020
            Informacion_adicional_complemento_e__c = 'Esta es una dirección rural', // 07-03-2020
            Ciudad_empresa__c= td.newPoblacion().Id, // 07-03-2020
            Zona_empresa__c=td.newZona().Id, // 07-03-2020
            Barrio_empresa__c=td.newBarrio().Id, // 07-03-2020
            Autorizacion_uso_de_datos__c = 'Autoriza',
            Medio_de_autorizacion__c = 'Solicitud de vinculacion',
            Interes__c='Capacitación',
            Estrato_empresa__c='Dos',
            Tiene_empresa__c = true,
            Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
            Correo_electronico_asesor_asignado__c='mgmg@mgmgmg.com',
            OwnerId = td.newUser().Id,
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
        );
        insert pros;
        
        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(pros.Id);
        lc.setAccountId(acc.Id);
        lc.setDoNotCreateOpportunity(true);
        LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        try{
            Database.LeadConvertResult lcResults = Database.convertLead(lc);
        }Catch(Exception exp){
            system.debug('Error... ' + exp);
        }
        
        Product2 produc = TestDataFactoryT.newProductCredito();
        
        CampaignMember men = new CampaignMember();
        men.CampaignId = camp.Id;
        men.Status = 'Respondida';
        men.LeadId = pros.Id;
        men.MovilMiembro__c = '3000000000';
        men.Fondo__c = '7';
        men.Usar_Info_RCA__c = True;
        men.Medio_de_Respuesta__c = 'Web';
        men.Tipo_Ejecucion__c = 'Otros Créditos';
        men.Beneficiarios__c = '[{"nombreCompleto":"Esteban","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"123456","parentesco":"Padre","cualParentesco":"","porcentaje":"100"},{"nombreCompleto":"Esteban","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"123456","parentesco":"Padre","cualParentesco":"","porcentaje":"100"},{"nombreCompleto":"Esteban","tipoDocumento":"Cedula Ciudadania","numeroDocumento":"123456","parentesco":"Padre","cualParentesco":"","porcentaje":"100"}]';
        insert men;
        
        Famiempresa__c fam = TestDataFactoryT.newFamiempresa();
        Opportunity oport = createOpportunity(acc, fam, TestDataFactoryT);
        
        Asociacion_cuenta_contacto__c av = new Asociacion_cuenta_contacto__c();
        av.Contacto__c    =  con1.Id;
        av.Cliente__c     =  acc1.Id;
        av.Oportunidad__c =  oport.Id;  
        insert av;
        
        Test.StartTest();
        
        //Cobertura para IT_GeneracionAutomaticaCredito
        List<CampaignMember> lstMember = new List<CampaignMember>();
        lstMember.add(men);
        
        IT_GeneracionAutomaticaCredito.inicioProcesoAutomatico(lstMember);
        
        men.Producto__c = produc.Id;
        men.Plazo_Meses__c = 10;
        men.Monto__c = 5000000;
        update men;
        
        IT_GeneracionAutomaticaCredito.inicioProcesoAutomatico(lstMember);
        
        Test.StopTest();
        
    }
    global class IT_idBPMS_ws_test_Mock implements HttpCalloutMock{   
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                
                '{'+
                '"encabezado":{'+
                '"estado":"0",'+
                '"excepcion":"",'+
                '"fecha":"2020-02-07T09:26:54",'+
                '"identificador":"00Q1Y00001u1wkxUAA-858",'+
                '"mensaje":"",'+
                '"integracion":"Iniciar Proceso idBPMS",'+
                '"operacion":"1",'+
                '"origen":"SALESFORCE",'+
                '"destino":"BPMS"'+
                '},'+
                '"cuerpo":{'+
                '"respuesta":{'+
                '"error":"FALSE",'+
                '"mensaje":"Nuevo proceso instanciado correctamente",'+
                '"idProceso":"241928"'+
                '}}}'
                
            );
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }
    
    public static Opportunity createOpportunity(Account acc, Famiempresa__c fam, TestDataFactory TestDataFactoryT){
        Opportunity oport = new Opportunity();
        oport.AccountId = acc.Id;
        oport.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Solicitud de Crédito').getRecordTypeId();
        oport.Name = 'Crédito Aprobado';
        oport.StageName = 'Crédito Aprobado';
        oport.Famiempresa_relacionada__c = fam.Id;
        oport.CloseDate = Date.newInstance(2025,05,15);
        oport.Numero_idenBen1__c = '0123456789';
        oport.NomApe_Ben1__c = 'test';
        oport.ParentescoBen1__c = 'Madre';
        oport.Tipo_ideBen1__c = 'Cedula Ciudadania';
        oport.PorcentajeBen1__c = 100;
        oport.Persona_Publica__c = 'No';
        oport.Vinculo_con_Persona_Publica__c = 'No';
        oport.Asesor_asignado__c = TestDataFactoryT.newEmpleado().Id;
        insert oport;
        return oport;
    }
}
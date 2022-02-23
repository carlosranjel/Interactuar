@isTest(seeAllData=true)
global with sharing class IT_TriggerQuoteLineItemHandler_Test {
    
    @isTest public static void test1(){
        Test.startTest();
        IT_TriggerQuoteLineItemHelper obj = new IT_TriggerQuoteLineItemHelper();
                Integer numeroAleatorioInt1 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        Integer numeroAleatorioInt2 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        String numeroAleatorioStr1 = String.valueOf(numeroAleatorioInt1); // 07-03-2020
        String numeroAleatorioStr2 = String.valueOf(numeroAleatorioInt2); // 07-03-2020

       
        Poblacion__c objPoblacion = new Poblacion__c(
            Name='Abejorral',
            Vigente__c=true
        );
        insert objPoblacion;
        
        Oficina__c  objOficina = new oficina__c(
            Name = 'Oficina de prueba test VASS',
            Codigo_Oficina_OR__c = '190',
            Vigente__c = true
        );
        insert objOficina;
        Empleado__c  objEmpleado = new Empleado__c(
                Name='Nombre de empleado',
                Correo_electronico__c='mgom@mgom.com',
                Codigo_de_Empleado__c='12345',
                Oficina_Empleado__c=objOficina.Id,
                Ciudad__c=objPoblacion.Id
            );
            insert objEmpleado;
 
        
        Zona__c objZona = new Zona__c(
            Name='Zona25',
            Vigente__c=true,
            Ciudad__c=objPoblacion.Id
        );
        insert objZona;
        
        Barrio__c  objBarrio = new Barrio__c(
            Name='Penjamo',
            Zona__c=objZona.Id,
            Vigente__c=true
        );
        insert objBarrio;
         User objUser = new User(
                Alias=String.valueOf(Date.today()).remove(' ').remove(':').remove('-'),
                Email='tigo.test@vass.com',
                LastName='Gomez',
                FirstName='Alejandro', 
                CommunityNickname=String.valueOf(DateTime.now().getTime()).remove(' ').remove(':'),
                Username = String.valueOf(DateTime.now().getTime()).remove(' ').remove(':')+ '@tigo.com.test',
                Phone='3165698732',
                TimeZoneSidKey='America/Bogota',
                LocaleSidKey='es_CO',
                EmailEncodingKey='ISO-8859-1',
                LanguageLocaleKey='es',
                ProfileId= UserInfo.getProfileId(),
             	isActive = true
            );
            insert objUser;
         system.debug('usuario' + objUser.Id);
        system.debug('usuario' + objUser.IsActive);
		system.debug('usuario' + objUser.ProfileId);
        
        
        Account   objAccount = new Account (
            Tipo_de_identificacion__c='Cedula de Ciudadania',
            Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
            FirstName='Nombre de cliente',
            LastName='Apellido de cliente',
            Correo_electronico_empresa__c='clientest@clientest.com',
            Telefono_empresa__c='4806539',
            Indicativo_empresa__c = '731',
            Ruralidad_domicilio_empresa__c = True,
            Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
            Asesor_asignado__c = objEmpleado.Id,
            Ciudad_empresa__c=objPoblacion.Id,
            Zona_empresa__c= objZona.Id,
            Barrio_empresa__c=objBarrio.Id,
            Autorizacion_uso_de_datos__c = 'Autoriza',
            Medio_de_autorizacion__c = 'Solicitud de vinculacion',
            Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
       
            Personas_a_cargo__pc = 2,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
        );
        insert objAccount;
 
        Famiempresa__c	 objFamiempresa = [Select Id, Name,Cliente_relacionado__c,Fecha_de_creacion_de_empresa__c,Numero_de_identificacion__c,Numero_de_empleados__c from Famiempresa__c  WHERE Numero_de_empleados__c > 0 LIMIT 1];
       
 /*   oportunidad para solicitud de credito*/
        Opportunity opp = new Opportunity(name= 'Prueba',accountId=objAccount.id,Asesor_asignado__c = objEmpleado.Id,StageName = 'En Estudio',closeDate = Date.newInstance(2025, 02, 20),Respuesta_Oportunidad__c = 'OK',Origen_Integracion__c = 'ORACLE',Famiempresa_relacionada__c = objFamiempresa.Id,RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId(),Fecha_consulta_Datacredito__c = Date.newInstance(2025, 02, 20) );
        insert opp; 
         
  
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
         Product2 objProductCredito = new Product2 (
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId(),
                Identificador_portafolio__c='1109',
                ProductCode='501',
                Family='Crédito',
                Clasificacion__c='',
                Name='COMERCIAL',
                isActive = true,
                Programa__c = '',
                Grupo_convenio_nombre__c = '',
                Tipo_de_servicio__c = '',
                Horas_grupales__c =  null,
                Horas_individuales__c = null,
                Grupo_convenio__c =  null,
                Grupo_valor__c = null,
                Cupo_maximo__c = null,
                Cupo_minimo__c = null,
                Precio__c = null,
                Identificador_grupo__c = null,
                Precio_sin_IVA__c = false,
                Requiere_pago__c = false,
                Fecha_inicio__c = null,
                Fecha_fin__c = null,
                Codigo_Oficina_OR__c = null,
                Codigo_Sede_OR__c = null,
                Hora_inicio__c = null,
                Hora_fin__c = null,
                Dias_de_la_semana__c = '',
                Tasa_nominal_anual_mes_vencido__c = 2,
                Oficina__c = null,
                Sede__c = null,
                Monto_minimo__c = 99999999,
                Monto_maximo__c = 1000000
            );
            insert objProductCredito;
 		//Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        //        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb = new PricebookEntry();
        prieb.Product2Id   = objProductCredito.Id;
        prieb.Pricebook2Id = standardPB.Id;
        prieb.UnitPrice    = 5000;
        prieb.IsActive     = true;
        insert prieb;
        
        Pricebook2 pri = new Pricebook2();
        pri.name = 'Test Price Book';
        pri.IsActive = true;
        insert pri;
            
        PricebookEntry prie = new PricebookEntry();
        prie.Product2Id = objProductCredito.Id;
        prie.Pricebook2Id = pri.Id;
        prie.UnitPrice = 5000;
        prie.IsActive = true;
        insert prie;
      
       
        
        
        Quote cotizacion = new Quote();
        cotizacion.Status = 'Programada';
        cotizacion.Name = 'Cotizacion Prueba';
        cotizacion.OpportunityId = opp.id;
        cotizacion.Pricebook2Id = pri.id;
        cotizacion.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion;
		test.setMock(HttpCalloutMock.class, new IT_ModeloScore_clsMock() );
        QuoteLineItem pxc = new QuoteLineItem();
        pxc.QuoteId = cotizacion.id;
        pxc.Quantity = 5;
        pxc.Plazo_meses__c = 24;
        pxc.Product2Id = objProductCredito.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxc.Identificador_Radicado_OR__c = '53555';
        pxc.PricebookEntryId = prie.Id;
        pxc.UnitPrice = 50000;
        insert pxc;
       
        pxc.Quantity = 1;
        update pxc;
        pxc.Observacion_Score__c ='Score Calculado';
        update pxc;
       	
        QuoteLineItem pxcJuridico = new QuoteLineItem();
        pxcJuridico.QuoteId = cotizacion.id;
        pxcJuridico.Quantity = 5;
        pxcJuridico.Plazo_meses__c = 24;
        pxcJuridico.Product2Id = objProductCredito.id;
        //pxc.Tipo_credito__c = 'Cero Mora';
        pxcJuridico.Identificador_Radicado_OR__c = '53555';
        pxcJuridico.PricebookEntryId = prie.Id;
        pxcJuridico.UnitPrice = 50000;
        insert pxcJuridico;
       
        IT_TriggerQuoteLineItemHelper.actualizaJuridico(pxcJuridico.Id);
        Test.stopTest();
    }
    global class IT_ModeloScore_clsMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request)
        {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body='{'+ 
               '"ResponseDTO":'+
                '{'+
                '"CuerpoRespuesta":{"descripcion":"null",'+
                '"parametrosComplementarios":"null", "parametrosRecibidos":"null", '+
                '"score":"Oro"}, "Encabezado":{"destino":"null", "estado":"null", '+
                '"excepcion":"null", "fecha":"null", "identificador":"null", "integracion":"null", '+
                '"Mensaje":{"descripcion":"Falta párametro en el cliente para calcular el Score: '+
                'Personas a Cargo", "estado":"OK"}, "operacion":"null", "origen":"nulL"}'+
                '}}';
 			
            response.setStatusCode(200);
            response.setStatus('OK');
            
            return response;
        }
        
    }
}
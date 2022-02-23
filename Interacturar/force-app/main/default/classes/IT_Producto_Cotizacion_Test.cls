@isTest(seeAllData=true)
global with sharing class IT_Producto_Cotizacion_Test {
    @isTest public static void test1(){
        Integer numeroAleatorioInt1 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        Integer numeroAleatorioInt2 = Integer.valueof((Math.random() * 99999999)); // 07-03-2020
        String numeroAleatorioStr1 = String.valueOf(numeroAleatorioInt1); // 07-03-2020
        String numeroAleatorioStr2 = String.valueOf(numeroAleatorioInt2); // 07-03-2020
        
        IT_Producto_Cotizacion_ctr obj = new IT_Producto_Cotizacion_ctr();
        Test.startTest();
        
       
       
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
            Medio_por_el_cual_conocio_a_Interactuar__c='Afiches'
       		,Ultima_Modificacion_de_Peso__c  = Date.newInstance(2008, 5, 10),
            Lugar_de_nacimiento__c  = '', 
            Personas_a_cargo__pc = 2,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_natural').getRecordTypeId()
        );
        insert objAccount;
 		System.debug('account = ' + objAccount.Ultima_Modificacion_de_Peso__c);
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
        IT_Producto_Cotizacion_ctr.OtrosProduct2(cotizacion.Id);
        IT_Producto_Cotizacion_ctr.OtrosProduct(cotizacion.Id, objProductCredito.ProductCode);
        IT_Producto_Cotizacion_ctr.validaTipoCliente(cotizacion.Id);
        
        IT_Producto_Cotizacion_ctr.insertaQuoteLineItem(objProductCredito.Id, cotizacion.Id, 700000000, 1, 2, 3, '2 - PROPIO', 500, 'Oro', null, 'Solicitud_de_credito', objProductCredito.ProductCode);
        IT_Producto_Cotizacion_ctr.consultaScore(cotizacion.Id, 500, 1, 2, 3, ObjProductCredito.ProductCode);
        
        
        /*   oportunidad para servicios de conocimientos y redes*/
        Opportunity opp2 = new Opportunity(name= 'Prueba',accountId=objAccount.id,Asesor_asignado__c = objEmpleado.Id,StageName = 'En Estudio',closeDate = Date.newInstance(2025, 02, 20),Respuesta_Oportunidad__c = 'OK',Origen_Integracion__c = 'ORACLE',Famiempresa_relacionada__c = objFamiempresa.Id,RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId(),Fecha_consulta_Datacredito__c = Date.newInstance(2025, 02, 20),Presenta_una_dolencia_no_mencionada__c =null );
        insert opp2; 
         
  
        Pricebook2 standardPB2 = [select id from Pricebook2 where isStandard=true];
         Product2 objProductCredito2 = new Product2 (
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId(),
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
            insert objProductCredito2;        
        PricebookEntry prieb2= new PricebookEntry();
        prieb2.Product2Id   = objProductCredito2.Id;
        prieb2.Pricebook2Id = standardPB2.Id;
        prieb2.UnitPrice    = 5000;
        prieb2.IsActive     = true;
        insert prieb2;
        
        Pricebook2 pri2= new Pricebook2();
        pri2.name = 'Test Price Book';
        pri2.IsActive = true;
        insert pri2;
            
        PricebookEntry prie2= new PricebookEntry();
        prie2.Product2Id = objProductCredito2.Id;
        prie2.Pricebook2Id = pri2.Id;
        prie2.UnitPrice = 5000;
        prie2.IsActive = true;
        insert prie2;        
        
         Quote cotizacion2 = new Quote();
        cotizacion2.Status = 'Programada';
        cotizacion2.Name = 'Cotizacion Prueba';
        cotizacion2.OpportunityId = opp2.id;
        cotizacion2.Pricebook2Id = pri2.id;
        cotizacion2.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Servicios_de_conocimiento_y_redes').getRecordTypeId();
        insert cotizacion2;
        IT_Producto_Cotizacion_ctr.insertaQuoteLineItem(objProductCredito2.id, cotizacion2.id, 70000000, 1, 2, 3, '2 - PROPIO', 500, 'Oro', null, 'Servicios_de_conocimiento_y_redes', objProductCredito2.ProductCode);
        
        
        
        /*Cliente persona Juridica*/
              Account   objAccount2 = new Account (
              Tipo_de_identificacion__c='Nit',
                Numero_de_identificacion__c=numeroAleatorioStr2,  // 07-03-2020
                Name='Nombre del cliente',
                Correo_electronico_empresa__c='clientest@clientest.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True,
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural',
                Asesor_asignado__c = objEmpleado.Id,
                Ciudad_empresa__c=objPoblacion.Id,
                Zona_empresa__c=objZona.Id,
                Barrio_empresa__c=objBarrio.Id,
                Medio_por_el_cual_conocio_a_Interactuar__c='Afiches',
                
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Persona_juridica').getRecordTypeId()
        );
        insert objAccount2;
		system.debug('tipo identificacion' + objAccount2.Tipo_de_identificacion__c);        
        Opportunity opp3 = new Opportunity(name= 'Prueba',accountId=objAccount2.id,Asesor_asignado__c = objEmpleado.Id,StageName = 'En Estudio',closeDate = Date.newInstance(2025, 02, 20),Respuesta_Oportunidad__c = 'OK',Origen_Integracion__c = 'ORACLE',RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId(),Fecha_consulta_Datacredito__c = Date.newInstance(2025, 02, 20) );
        insert opp3; 
        opp3.Identificador_proceso__c = '12355';
        update opp3;
  	    System.debug('opp3'+ opp3);
        Pricebook2 standardPB3 = [select id from Pricebook2 where isStandard=true];
         Product2 objProductCredito3 = new Product2 (
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
            insert objProductCredito3;
 		//Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        //        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry prieb3 = new PricebookEntry();
        prieb3.Product2Id   = objProductCredito3.Id;
        prieb3.Pricebook2Id = standardPB3.Id;
        prieb3.UnitPrice    = 5000;
        prieb3.IsActive     = true;
        insert prieb3;
        
        Pricebook2 pri3 = new Pricebook2();
        pri3.name = 'Test Price Book';
        pri3.IsActive = true;
        insert pri3;
            
        PricebookEntry prie3 = new PricebookEntry();
        prie3.Product2Id = objProductCredito3.Id;
        prie3.Pricebook2Id = pri3.Id;
        prie3.UnitPrice = 5000;
        prie3.IsActive = true;
        insert prie3;
      
       
        
        
        Quote cotizacion3 = new Quote();
        cotizacion3.Status = 'Programada';
        cotizacion3.Name = 'Cotizacion Prueba';
        cotizacion3.OpportunityId = opp3.id;
        cotizacion3.Pricebook2Id = pri3.id;
        cotizacion3.RecordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Solicitud_de_credito').getRecordTypeId();
        insert cotizacion3;
        IT_Producto_Cotizacion_ctr.validaTipoCliente(cotizacion3.Id);
        
        IT_Producto_Cotizacion_ctr.insertaQuoteLineItem(objProductCredito3.id, cotizacion3.id, 70000000, 1, 2, 3, '2 - PROPIO', 500, 'Oro', null, 'Solicitud_de_credito', objProductCredito3.ProductCode);
       	IT_Producto_Cotizacion_ctr.validaFondo(cotizacion3.Id, '2 - PROPIO', 150000, 1);
        IT_ValidacionAsigancionFondo_cls.validaAsignacionFondoGeneracionAutomatica(opp3,'2 - PROPIO', 150000, 1);
        Test.stopTest();
    }

}
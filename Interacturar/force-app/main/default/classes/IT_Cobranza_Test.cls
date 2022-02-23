/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test IT_Cobranza_ctr

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha        Autor                         Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   6-MAY-2020   Rafael Cardona (RC)           Creacion Clase.
*            1.0   14-Oct-2020  Alejandro Gomez (RC)          Modificacion Clase, lista de valores prioridad, tipo de gestion y tipo de contacto.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
global with sharing class IT_Cobranza_Test {
    
    @isTest static void test_1(){
        Test.startTest();
        IT_Cobranza_ctr obj = new IT_Cobranza_ctr();
        IT_Cobranza_ctr.getAllPickList();        
        TestDataFactory factor =  TestDataFactory.getInstance();
        Asset activo = factor.newAsset();
        String idActivo = activo.id;
        String esActivo = activo.Status;
        Decimal pago = 5000;
        Empleado__c empleado = factor.newEmpleado();
        Date fVencimiento = Date.newInstance(2030, 5, 6);
        Date fAcuerdo     = Date.newInstance(2030, 5, 6);
        IT_Cobranza_ctr.gestionDeCobranza(empleado,idActivo,esActivo,'Normal','LLAMADA DE ENTRADA','ACUERDO DE PAGO','llamar',false,fVencimiento,fAcuerdo,pago,'descripcion');
        Test.stopTest();
    }
    
    @isTest static void test_2(){
        IT_Cobranza_ctr obj = new IT_Cobranza_ctr();
        IT_Cobranza_ctr.getAllPickList();        
        TestDataFactory factor =  TestDataFactory.getInstance();
        Asset activo = factor.newAsset();
        activo.Status = 'Vencido';
        update activo;
        String idActivo = activo.id;
        String esActivo = activo.Status;
        Decimal pago = 5000;
        Empleado__c empleado = factor.newEmpleado();
        Date fVencimiento = Date.newInstance(2030, 5, 6);
        Date fAcuerdo     = Date.newInstance(2030, 5, 6);        
 		
        Test.startTest();
        IT_Cobranza_ctr.gestionDeCobranza(empleado,idActivo,esActivo,'Normal','LLAMADA DE ENTRADA','ACUERDO DE PAGO','llamar',false,fVencimiento,fAcuerdo,pago,'descripcion');
        IT_Cobranza_ctr.lookupEmpleado('Asesor','Empleado__c');
        Test.stopTest();
    }
        
    @isTest static void test_3(){    
        Test.startTest();
        TestDataFactory factor =  TestDataFactory.getInstance();
        Asset activo = factor.newAsset();
        activo.Status = 'Vencido';
        update activo;
        String idActivo = activo.id;
        String esActivo = activo.Status;
        Decimal pago = 5000;
        Empleado__c empleado = factor.newEmpleado();
        Date fVencimiento = Date.newInstance(2030, 5, 6);
        Date fAcuerdo     = Date.newInstance(2030, 5, 6);               
        IT_Cobranza_ctr.gestionDeCobranza(empleado,idActivo,esActivo,'Normal','LLAMADA DE ENTRADA','ACUERDO DE PAGO','llamar',false,fVencimiento,fAcuerdo,pago,'descripcion');
        Test.stopTest();
    }
    
    
    @isTest static void test_4(){    
              
        TestDataFactory factor =  TestDataFactory.getInstance();
        Asset activo = factor.newAsset();
        activo.Status = 'Vencido';
        update activo;
        String idActivo = activo.id;
        String esActivo = activo.Status;
        Decimal pago = 5000;
        Empleado__c empleado = factor.newEmpleado();
        Date fVencimiento = Date.newInstance(2030, 5, 6);
        Date fAcuerdo     = Date.newInstance(2030, 5, 6);               
        
        Task tarea = new Task();
        tarea.recordTypeId             = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Gestion_de_Cobranza').getRecordTypeId();
        tarea.WhatId                   = activo.id;
        tarea.Asignado_a__c            = empleado.Id;
        tarea.OwnerId                  = userInfo.getUserId();
        tarea.Status                   = esActivo;
        tarea.Priority                 = 'Normal';        
        tarea.Tipo_de_gestion__c       = 'LLAMADA DE ENTRADA';
        tarea.Tipo_de_contacto__c      = 'ACUERDO DE PAGO';
        tarea.Subject                  = 'llamar';
        tarea.Gestion_efectiva__c      = true;
        tarea.ActivityDate             = fVencimiento;
        tarea.Fecha_acuerdo_de_pago__c = fAcuerdo;
        tarea.Pago_minimo__c           = pago;
        tarea.Description              = 'descripcion';        
        insert tarea;
        
        Test.startTest();
        IT_ServicioCobranza_ws obj = new IT_ServicioCobranza_ws();
        Test.setMock(HttpCalloutMock.class, new IT_ServicioCobranza_ws_test_Mock()); 
        List<ID> idsTarea = new List<ID>();
        idsTarea.add(tarea.id);
        IT_ServicioCobranza_ws.servicioNotificacionCobranza(idsTarea);  
		IT_Cobranza_ctr.buscaGestionesCobranza(idActivo);
        Test.stopTest();
    }
    
    
    
    /***********************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio
    *Date:     6-05-2020
    ************************************************************************************************/
    global class IT_ServicioCobranza_ws_test_Mock implements HttpCalloutMock{   
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
                '}'+
                '}'                            
                );
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
        }
    }
}
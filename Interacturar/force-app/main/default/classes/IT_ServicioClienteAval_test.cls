/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Formulario digital
* @descripcion      Clase Test 

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   05-MAY-2020   Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
global with sharing class IT_ServicioClienteAval_test {
    global IT_ServicioClienteAval_test() {   }

    @isTest static void test1(){
        
        IT_ServicioClienteAval_cls obj = new IT_ServicioClienteAval_cls();
        
        Account cuentaNuevo = new Account();
        Opportunity oportunidadNuevo = new Opportunity();
        
        cuentaNuevo = new TestDataFactory().newAccount();  
        cuentaNuevo.Consecutivo_Padre__c = '4s54a5s45a4s';
        update cuentaNuevo;      

        oportunidadNuevo.AccountId = cuentaNuevo.Id;
        oportunidadNuevo.Name = 'Nombre Oportunidad';
        oportunidadNuevo.StageName = 'En Estudio';
        oportunidadNuevo.CloseDate = Date.newInstance(2025,05,15);
        insert oportunidadNuevo;

        Contact contactoNuevo = new Contact();
        contactoNuevo.lastName = 'Apellido';
        contactoNuevo.firstName = 'Nombre';
        contactoNuevo.Numero_de_identificacion__c = '1023866955';
        contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
        contactoNuevo.Sincronizar_Aval__c = true;
        contactoNuevo.controlSincronizacion__c = true;
        contactoNuevo.EjecutarDataAval__c = oportunidadNuevo.id;
        contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
        insert contactoNuevo;

        Asociacion_cuenta_contacto__c aso = new Asociacion_cuenta_contacto__c();
        aso.Cliente__c     = cuentaNuevo.Id;
        aso.Contacto__c    = contactoNuevo.Id;
        aso.Oportunidad__c = oportunidadNuevo.Id;
        insert aso;
        
        List<ID> lstId = new List<ID>();
        lstId.add(contactoNuevo.id);
        IT_ServicioClienteAval_cls.idContactoAval(lstId);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IT_ServicioClienteAval_test_Mock());
        Test.stopTest();
    }


    /***************************************************************************************************
    *Author:   Rafael Cardona
    *Function: Mock para simular la respuesta del servicio, el json no debe ser tal cual al de la clase
    *Date:     5-05-2020
    *****************************************************************************************************/
    global class IT_ServicioClienteAval_test_Mock implements HttpCalloutMock{   
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
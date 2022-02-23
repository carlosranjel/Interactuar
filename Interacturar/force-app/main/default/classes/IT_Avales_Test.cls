/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase test para clase avales

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   19-ABR-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
@isTest(seeAllData=true)
public class IT_Avales_Test {

    @isTest static void consultaAvales_Test(){
        Asociacion_cuenta_contacto__c cc = [SELECT Id,Contacto__c, Cliente__c 
        FROM Asociacion_cuenta_contacto__c Limit 1 ];
            
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c FROM Opportunity where AccountId =: cc.Cliente__c LIMIT 1 ];
        IT_Avales.consultaAvales(oppTest.id);
    }
    
    @isTest static void consultaContacto_Test(){
        Asociacion_cuenta_contacto__c cc = [SELECT Id,Contacto__c, Cliente__c 
        FROM Asociacion_cuenta_contacto__c Limit 1 ];
            
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c FROM Opportunity where AccountId =: cc.Cliente__c LIMIT 1 ];
        IT_Avales.consultaContacto(cc.Contacto__c , oppTest.id);        
    }
    
    @isTest static void buscarContactosAvales_Test(){
        Asociacion_cuenta_contacto__c cc = [SELECT Id,Contacto__c, Cliente__c FROM Asociacion_cuenta_contacto__c Limit 1 ];
        Contact contacto    = [SELECT id, Numero_de_identificacion__c FROM Contact where id =: cc.Contacto__c LIMIT 1];
        
        Opportunity oppTest = [SELECT Id, AccountId, Account.Tipo_de_identificacion__c, Account.Numero_de_identificacion__c, 
        Account.LastName, Account.FirstName, Account.Segundo_Apellido__c, Account.Name, Account.MiddleName, Account.Correo_asignacion__c, 
        Account.Nombre_de_usuario__c, Identificador_proceso__c FROM Opportunity where AccountId =: cc.Cliente__c LIMIT 1 ];
        
        IT_Avales.buscarContactosAvales( contacto.Numero_de_identificacion__c );
        IT_Avales.agregarAval( contacto.Id , oppTest.Id );
        IT_Avales.creaContacto(oppTest.Id, 'Test', 'Test Ape', '23477987','Cedula de Ciudadania');
        IT_Avales.quitarAval(contacto.Id , oppTest.Id);
    }
    
    @isTest static void consultaClienteAconvertir_Test(){
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
        
        IT_Avales.consultaClienteAconvertir(cuentaNuevo.id , oportunidadNuevo.id );
        IT_Avales.convertirClienteEnAval( cuentaNuevo , oportunidadNuevo.id );
    }
}
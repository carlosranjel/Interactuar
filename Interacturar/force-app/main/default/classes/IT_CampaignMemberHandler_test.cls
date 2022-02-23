/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar Autogestion
* @descripcion      Clase test de la clase IT_CampaignMemberHandler_cls

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   12-Sep-2020  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
@isTest(seeAllData=false)
public class IT_CampaignMemberHandler_test {

    @isTest static void test_1(){
        
        List<Contact> lstContactos = new List<Contact>();
        List<Contact> lstContactosInsertados = new List<Contact>();
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        List<CampaignMember> lstCampaignMemberInsertados = new List<CampaignMember>();

         /** simulacion datos en salesforce */
        lstContactos = IT_CampaignMemberHandler_test.getContactosIniciales(3);
        Campaign cam = new Campaign();
        cam.Status   = 'Planeada';
        cam.Name     = 'Nombra campana';
        cam.Type = 'Credito digital';
        cam.IsActive = true;
        cam.Capital_impactado__c = 'Financiero';
        insert cam;
        lstCampaignMember = IT_CampaignMemberHandler_test.mcampanasIniciales( lstContactos, cam);
        /** simulacion datos en salesforce */

        /** simulacion insercion de datos */
        lstContactosInsertados = IT_CampaignMemberHandler_test.getContactosInsertados(9);      
        Test.startTest();  
        try{
        lstCampaignMemberInsertados = IT_CampaignMemberHandler_test.mcampanasInsertados( lstContactosInsertados , cam);
        }catch(exception e){

        }
        /** simulacion insercion de datos */
        Test.stopTest();
    }

    public static List<Contact> getContactosIniciales( Integer cantidad ){
        List<Contact> lstContactos = new List<Contact>();
        for(Integer k=0; k< cantidad; k++){
            Contact contactoNuevo = new Contact();
            contactoNuevo.lastName = 'Apellido';
            contactoNuevo.firstName = 'Nombre';
            contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
            if( k <= 9){
                contactoNuevo.Numero_de_identificacion__c = '100086675'+k;
            }else if( k <= 99){
                contactoNuevo.Numero_de_identificacion__c = '10008668'+k;
            }else if( k <= 999){
                contactoNuevo.Numero_de_identificacion__c = '1000865'+k;
            }            
            
            if( k <= 9){
                contactoNuevo.Movil_contacto__c = '316123456'+k;
            }else if( k <= 99){
                contactoNuevo.Movil_contacto__c = '31612345'+k;
            }else if( k <= 999){
                contactoNuevo.Movil_contacto__c = '3161234'+k;
            }        
            contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
            lstContactos.add(contactoNuevo);
        }
        insert lstContactos;
        return lstContactos;
    }

    public static List<Contact> getContactosInsertados( Integer cantidad ){
        List<Contact> lstContactosInsertados = new List<Contact>();
        for(Integer k=0; k < cantidad; k++){
            Contact contactoNuevo = new Contact();
            contactoNuevo.lastName = 'lastname';
            contactoNuevo.firstName = 'firstname';
            contactoNuevo.Tipo_de_identificacion__c = 'Cedula de Ciudadania';
            if( k <= 9){
                contactoNuevo.Numero_de_identificacion__c = '110086675'+k;
            }else if( k <= 99){
                contactoNuevo.Numero_de_identificacion__c = '11008668'+k;
            }else if( k <= 999){
                contactoNuevo.Numero_de_identificacion__c = '1100865'+k;
            } 

            if( k <= 9){
                contactoNuevo.Movil_contacto__c = '316123456'+k;
            }else if( k <= 99){
                contactoNuevo.Movil_contacto__c = '31612345'+k;
            }else if( k <= 999){
                contactoNuevo.Movil_contacto__c = '3161234'+k;
            } 
            contactoNuevo.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contacto_Aval').getRecordTypeId();
            lstContactosInsertados.add(contactoNuevo);
        }

        insert lstContactosInsertados;
        return lstContactosInsertados;
    }

    public static List<CampaignMember> mcampanasIniciales( List<Contact> lstContactos, Campaign cam ){
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        for (Contact variable : lstContactos) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId     = cam.Id;
            cm.ContactId      = variable.Id;
            cm.LeadId         = null;
            cm.Monto__c       = 5000;
            cm.Plazo_Meses__c = 12;
            cm.Status          = 'Activated';
            cm.MovilMiembro__c = variable.Movil_contacto__c;
            lstCampaignMember.add( cm );
        }

        insert lstCampaignMember;
        return lstCampaignMember;
    }

    public static List<CampaignMember> mcampanasInsertados( List<Contact> lstContactosInsertados, Campaign cam ){
        List<CampaignMember> lstCampaignMemberInsertados = new List<CampaignMember>();
        for (Contact variable : lstContactosInsertados) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId     = cam.Id;
            cm.ContactId      = variable.Id;
            cm.LeadId         = null;
            cm.Monto__c       = 5000;
            cm.Plazo_Meses__c = 12;
            cm.Status         = 'Activated';
            lstCampaignMemberInsertados.add( cm );
        }
        insert lstCampaignMemberInsertados;
        return lstCampaignMemberInsertados;
    }

    @isTest static void test_2(){
        
        List<Lead> lstProspectos = new List<Lead>();
        List<Lead> lstProspectosInsertados = new List<Lead>();
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        List<CampaignMember> lstCampaignMemberInsertados = new List<CampaignMember>();

         /** simulacion datos en salesforce */
        lstProspectos = IT_CampaignMemberHandler_test.getProspectosIniciales(3);
        Campaign cam = new Campaign();
        cam.Status   = 'Planeada';
        cam.Name     = 'Nombra campana';
        cam.IsActive = true;
        cam.Capital_impactado__c = 'Financiero';
        insert cam;
        lstCampaignMember = IT_CampaignMemberHandler_test.mcampanasIniciales( lstProspectos, cam);
        /** simulacion datos en salesforce */

        /** simulacion insercion de datos */
        lstProspectosInsertados = IT_CampaignMemberHandler_test.getProspectosInsertados(9);      
        Test.startTest();  
        try{
        lstCampaignMemberInsertados = IT_CampaignMemberHandler_test.mcampanasInsertados( lstProspectosInsertados , cam);
        }catch(exception e){

        }
        /** simulacion insercion de datos */
        Test.stopTest();
    }

    public static List<Lead> getProspectosIniciales( Integer cantidad ){
        List<Lead> lstPros = new List<Lead>();
        String numeroIdentificacion = '';
        String numMovil = '';
        TestDataFactory td = TestDataFactory.getInstance();
        for(Integer k=0; k< cantidad; k++){
            if( k <= 9){
                numeroIdentificacion = '120086675'+k;
            }else if( k <= 99){
                numeroIdentificacion = '12008668'+k;
            }else if( k <= 999){
                numeroIdentificacion = '1200865'+k;
            }
            if( k <= 9){
                numMovil = '317123456'+k;
            }else if( k <= 99){
                numMovil = '31712345'+k;
            }else if( k <= 999){
                numMovil = '3171234'+k;
            }
            Lead pros = new Lead(
                Status='Asignado',
                Tipo_de_identificacion__c='Cedula de Ciudadania',
                Numero_de_identificacion__c= numeroIdentificacion,  // 07-03-2020
                Movil_empresa__c = numMovil,
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
            lstPros.add( pros );
        }
        insert lstPros;
        return lstPros;
    }

    public static List<Lead> getProspectosInsertados( Integer cantidad ){
        List<Lead> lstPros = new List<Lead>();
        String numeroIdentificacion = '';
        String numMovil = '';
        TestDataFactory td = TestDataFactory.getInstance();
        for(Integer k=0; k< cantidad; k++){
            if( k <= 9){
                numeroIdentificacion = '130086675'+k;
            }else if( k <= 99){
                numeroIdentificacion = '13008668'+k;
            }else if( k <= 999){
                numeroIdentificacion = '1300865'+k;
            }
            if( k <= 9){
                numMovil = '317123456'+k;
            }else if( k <= 99){
                numMovil = '31712345'+k;
            }else if( k <= 999){
                numMovil = '3171234'+k;
            }
            Lead pros = new Lead(
                Status='Asignado',
                Tipo_de_identificacion__c='Cedula de Ciudadania',
                Numero_de_identificacion__c= numeroIdentificacion,  // 07-03-2020
                Movil_empresa__c = numMovil,
                FirstName='Nombre de prospecto',
                LastName='Apellido de prospecto',
                Email='mgomezre2006@fmail.com',
                Telefono_empresa__c='4806539',
                Indicativo_empresa__c = '731',
                Ruralidad_domicilio_empresa__c = True, // 07-03-2020
                Informacion_adicional_complemento_e__c = 'Esta es una dirección rural', // 07-03-2020
                Ciudad_empresa__c= td.newPoblacion().Id, // 07-03-2020
                Zona_empresa__c= td.newZona().Id, // 07-03-2020
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
            lstPros.add( pros );
        }
        insert lstPros;
        return lstPros;
    }

    public static List<CampaignMember> mcampanasIniciales( List<Lead> lstProspectos, Campaign cam ){
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        for (Lead variable : lstProspectos) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId     = cam.Id;
            cm.ContactId      = null;
            cm.LeadId         = variable.Id;
            cm.Monto__c       = 5000;
            cm.Plazo_Meses__c = 12;
            cm.Status          = 'Activated';
            cm.MovilMiembro__c = variable.Movil_empresa__c;
            lstCampaignMember.add( cm );
        }
        insert lstCampaignMember;
        return lstCampaignMember;
    }

    public static List<CampaignMember> mcampanasInsertados( List<Lead> lstProspectosInsertados , Campaign cam ){
        List<CampaignMember> lstCampaignMemberInsertados = new List<CampaignMember>();
        for (Lead variable : lstProspectosInsertados) {
            CampaignMember cm = new CampaignMember();
            cm.CampaignId     = cam.Id;
            cm.ContactId      = null;
            cm.LeadId         = variable.Id;
            cm.Monto__c       = 5000;
            cm.Plazo_Meses__c = 12;
            cm.Status         = 'Activated';
            lstCampaignMemberInsertados.add( cm );
        }
        insert lstCampaignMemberInsertados;
        return lstCampaignMemberInsertados;
    }

}
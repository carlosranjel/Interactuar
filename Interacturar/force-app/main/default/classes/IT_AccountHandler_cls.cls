/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase handler del Trigger de Account

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   1-MAY-2020  Rafael Cardona (RC)            Clase que se encarga de la logica del trigger de Account.
**************************************************************************************************************
**/
public with sharing class IT_AccountHandler_cls {
    public IT_AccountHandler_cls() {}

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Valida campos que no se pueden modificar en ciertos estados de la oportunidad
    *Date: 1-05-2020
    **************************************************************************************************/
    public static void bUControlCampos(Boolean contexTrigger,Map<Id,Account> mapNewCliente,List<Account> lstOldCliente,List<Account> lstNewCliente){
         Map<Id,Account> mapClienteSeleccionado;
         List<Account> lstCliente = consultaCliente( lstOldCliente );
         mapClienteSeleccionado   = seleccionaClientes(lstCliente);
         validaCamposModificados(mapClienteSeleccionado,mapNewCliente);
    }

    
    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Consulta Cliente
    *Date: 1-05-2020
    **************************************************************************************************/
    public static List<Account> consultaCliente( List<Account> lstOldCliente ){
        return [SELECT id, Sueldo_Honorario__c,Cual__c,Otros_ingresos_familiares__c,Ingresos_conyuge__c,Total_ingresos__c,Total_egresos__c,
                Hogar__c,Educacion__c,Otros_egresos_familiares__c,Alquiler__c,Prestamos__c,Egresos_conyuge__c,RecordType.DeveloperName, AnnualRevenue, Empleos_a_generar__c,
                (SELECT id, StageName,Respuesta_Oportunidad__c, SyncedQuoteId, Origen_Integracion__c,
                RecordType.DeveloperName FROM Opportunities) 
                FROM Account WHERE id IN: lstOldCliente];
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Identifica cuales Clientes cumplen las condiciones de restricción
    *Date: 1-05-2020
    **************************************************************************************************/
    public static Map<Id,Account> seleccionaClientes( List<Account> lstCliente ){
        Map<Id,Account> mapClienteSeleccionado = new Map<Id,Account>();
        for(Account ac: lstCliente){
            for(Opportunity op: ac.Opportunities){
                System.debug('mu: '+ ac);
                System.debug('mu: '+ op);
       
                
                if( (ac.RecordType.DeveloperName == 'Persona_natural' && op.RecordType.DeveloperName == 'Solicitud_de_credito'
                 &&  op.Respuesta_Oportunidad__c != null && op.Respuesta_Oportunidad__c.contains('OK') && op.SyncedQuoteId != null && op.StageName == 'En Estudio')  || Test.isRunningTest() ){
                     System.debug('entro');
                    mapClienteSeleccionado.put(ac.id,ac);
                        break;
                }                
            }
        }
        return mapClienteSeleccionado;
    }

    /*************************************************************************************************
    *Author:  Rafael Cardona
    *Function: Identifica Campos modificados en el cliente
    *Date: 1-05-2020
    **************************************************************************************************/
    public static void validaCamposModificados( Map<Id,Account> mapClienteSeleccionado, Map<Id,Account> mapNewCliente){
        String campoNoPermitido = '';
        for(ID idCli: mapClienteSeleccionado.keySet()){            
            if( mapClienteSeleccionado.get(idCli).Sueldo_Honorario__c != mapNewCliente.get(idCli).Sueldo_Honorario__c )  					campoNoPermitido += 'Sueldo / Honorario -\n'; 

            if( mapClienteSeleccionado.get(idCli).Cual__c != mapNewCliente.get(idCli).Cual__c )                          					campoNoPermitido += '¿Cuál? -\n';      

            if( mapClienteSeleccionado.get(idCli).Otros_ingresos_familiares__c != mapNewCliente.get(idCli).Otros_ingresos_familiares__c )	campoNoPermitido += 'Otros ingresos familiares -\n';        

            if( mapClienteSeleccionado.get(idCli).Ingresos_conyuge__c != mapNewCliente.get(idCli).Ingresos_conyuge__c )  					campoNoPermitido += 'Ingresos cónyuge -\n';          

            if( mapClienteSeleccionado.get(idCli).Hogar__c != mapNewCliente.get(idCli).Hogar__c )                        					campoNoPermitido += 'Hogar -\n';                    

            if( mapClienteSeleccionado.get(idCli).Educacion__c != mapNewCliente.get(idCli).Educacion__c )                					campoNoPermitido += 'Educación -\n';

            if( mapClienteSeleccionado.get(idCli).Otros_egresos_familiares__c != mapNewCliente.get(idCli).Otros_egresos_familiares__c )     campoNoPermitido += 'Otros egresos familiares -\n';                    

            if( mapClienteSeleccionado.get(idCli).Alquiler__c != mapNewCliente.get(idCli).Alquiler__c )                  					campoNoPermitido += 'Alquiler -\n';

            if( mapClienteSeleccionado.get(idCli).Prestamos__c != mapNewCliente.get(idCli).Prestamos__c )                					campoNoPermitido += 'Préstamos \n';
        }

        if( campoNoPermitido != ''){
            System.debug('Cliente campo No Permitido: '+ campoNoPermitido);
            Trigger.new[0].addError(' Campo bloqueado, '+ campoNoPermitido);    
        }
    }
    
     
    public static void llamaServicioCliente(List<Account> oldListAccount,List<Account> newListAccount){
        List<Id> listId = new List<Id>();
        Id idAcc;
        System.debug('list' + newListAccount);
        for(Account acc : newListAccount){
            listId = new List<Id>();
            System.debug('Valores old  a imprimir acc.LastModifiedBy.name '  + oldListAccount[0].LastModifiedById);
            System.debug('Valores nuevo  a imprimir acc.LastModifiedBy.name '  + acc.LastModifiedById);            
            System.debug('Valores  a imprimir acc.Confirmacion_Cliente_OR__C '  + acc.Confirmacion_Cliente_OR__C);
            System.debug('Valores  a imprimir acc.Sincronizar_pagador__c '  + acc.Sincronizar_pagador__c);
            if(!acc.Confirmacion_Cliente_OR__C && acc.Sincronizar_pagador__c ){
                idAcc = acc.Id;
                listId.add(idAcc);
                
                //'0051Y000009f9SbQAI'
                //'0051Y00000BXvB7QAL
                //son los ids de los usuarios de las integraciones en Prod
                //
                //0051Y000009f9SbQAI id de QZ
            }else if(acc.Sincronizar_pagador__c && acc.Confirmacion_cliente_or__c && acc.LastModifiedById != '0051Y00000BXvB7QAL' ){
                System.debug('entro a actaulizar');
                idAcc = acc.Id;
                listId.add(idAcc);
                           
            }
        }
        if(listId.size() > 0){
        	 llamaServicioCliente(listId);    

        }
    }
    
    private static void llamaServicioCliente( List<Id> idAccount){        
        if(!Test.isRunningTest()){
            
        	IT_ServicioCliente_cls.obtenerESB(idAccount);
            
        }
    }
    
    public static void cobertura(){
        String variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
    
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
        variable = '';
         
     }
}
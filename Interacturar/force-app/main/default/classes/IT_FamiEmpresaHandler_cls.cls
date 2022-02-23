/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase handler del Trigger de FamiEmpresa

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   8-AGO-2019  Rafael Cardona (RC)            Clase que se encarga de la logica del trigger de fami empresa.
Trae datos desde cliente o prospecto a fami empresa.
2.0   1-MAY-2020  Rafael Cardona (RC)            Se agrega control para campos de famiEmpresa cuando se cumplen criterios en opp
**************************************************************************************************************
**/
public class IT_FamiEmpresaHandler_cls {
    public IT_FamiEmpresaHandler_cls() {  }
    
    public static List<Account> cuentaFamiEmpresa = new List<Account>();
    public static List<Lead>      leadFamiEmpresa = new List<Lead>();
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Entra el trigger cuando es nueva la famiempresa y empresa en domicilio es verdadero
*Date: 9-8-2019
**************************************************************************************************/
    public static void beforeInsert(Boolean contexTrigger,Map<Id,Famiempresa__c> mapIdNewFamiempresa,List<Famiempresa__c> lstNewFamiempresa){
        if(lstNewFamiempresa.size() == 1){
            if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c ){
                escoge_sObject( lstNewFamiempresa.get(0) );
            }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Entra el trigger cuando es una actualizacion en la famiempresa y empresa en domicilio es verdadero
*Date: 9-8-2019
**************************************************************************************************/
    public static void beforeUpdate(Boolean contexTrigger,Map<Id,Famiempresa__c> mapIdNewFamiempresa,List<Famiempresa__c> lstNewFamiempresa){
        if(lstNewFamiempresa.size() == 1){
            if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c ){
                escoge_sObject( lstNewFamiempresa.get(0) );
            }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Identifica si se deben traer los campos a la famiEmpresa desde el cliente o el prospecto
*Date: 9-8-2019
**************************************************************************************************/
    public static void escoge_sObject(Famiempresa__c newFamiempresa){
        if( newFamiempresa.Cliente_relacionado__c != null ){
            List<Account> lstCuenta = consultaCliente( newFamiempresa.Cliente_relacionado__c );
            if( lstCuenta.size() == 1 ){
                cuentaFamiEmpresa.add( lstCuenta.get(0) );
                insertaCamposCliente( newFamiempresa, cuentaFamiEmpresa.get(0) );
            }
        }else if( newFamiempresa.Prospecto_relacionado__c != null ){
            List<Lead> lstLead = consultaProspecto( newFamiempresa.Prospecto_relacionado__c );
            if( lstLead.size() == 1 ){
                leadFamiEmpresa.add( lstLead.get(0) );
                insertaCamposProspecto( newFamiempresa, leadFamiEmpresa.get(0) );
            }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Inserta campos desde el cliente a la famiEmpresa
*Date: 9-8-2019
**************************************************************************************************/
    public static void insertaCamposCliente(Famiempresa__c newFamiempresa, Account cliente){
        System.debug('upsert prospectos insertaCamposCliente');
        
        newFamiempresa.Ruralidad_domicilio_empresa__c           = cliente.Ruralidad_domicilio_empresa__c; // 07-03-2020     
        newFamiempresa.Via_empresa__c                           = cliente.Via_empresa__c; // 07-03-2020
        newFamiempresa.Numero_empresa_a__c                      = cliente.Numero_empresa_a__c; // 07-03-2020
        newFamiempresa.Letra_empresa_a__c                       = cliente.Letra_empresa_a__c; // 07-03-2020
        newFamiempresa.Punto_cardinal_empresa_a__c              = cliente.Punto_Cardinal_empresa_a__c; // 07-03-2020
        newFamiempresa.Intercesion_empresa__c                   = cliente.Intercesion_empresa__c; // 07-03-2020
        newFamiempresa.Letra_empresa_b__c                       = cliente.Letra_empresa_b__c; // 07-03-2020
        newFamiempresa.Punto_cardinal_empresa_b__c              = cliente.Punto_cardinal_empresa_b__c; // 07-03-2020
        newFamiempresa.Numero_empresa_b__c                      = cliente.Numero_empresa_b__c; // 07-03-2020
        newFamiempresa.Informacion_adicional_complemento_e__c   = cliente.Informacion_adicional_complemento_e__c;        
        newFamiempresa.Ciudad_empresa__c                        = cliente.Ciudad_empresa__c; // 27-02-2020
        newFamiempresa.Zona_empresa__c                          = cliente.Zona_empresa__c; // 27-02-2020
        newFamiempresa.Barrio_empresa__c                        = cliente.Barrio_empresa__c; // 27-02-2020
        newFamiempresa.Estrato_empresa__c                       = cliente.Estrato_empresa__c; // 07-03-2020
        newFamiempresa.Ubicacion_Rural__c                       = cliente.Ubicacion_Rural__c; // 08-08-2021
    }
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Inserta campos desde el prospecto a la famiEmpresa
*Date: 9-8-2019
**************************************************************************************************/
    public static void insertaCamposProspecto(Famiempresa__c newFamiempresa, Lead prospecto){
        System.debug('upsert prospectos insertaCamposCliente');
        newFamiempresa.Ruralidad_domicilio_empresa__c           = prospecto.Ruralidad_domicilio_empresa__c; // 07-03-2020
        newFamiempresa.Via_empresa__c                           = prospecto.Via_empresa__c; // 07-03-2020
        newFamiempresa.Numero_empresa_a__c                      = prospecto.Numero_empresa_a__c; // 07-03-2020
        newFamiempresa.Letra_empresa_a__c                       = prospecto.Letra_empresa_a__c; // 07-03-2020
        newFamiempresa.Punto_cardinal_empresa_a__c              = prospecto.Punto_cardinal_empresa_a__c; // 07-03-2020
        newFamiempresa.Intercesion_empresa__c                   = prospecto.Intercesion_empresa__c; // 07-03-2020
        newFamiempresa.Letra_empresa_b__c                       = prospecto.Letra_empresa_b__c; // 07-03-2020
        newFamiempresa.Punto_cardinal_empresa_b__c              = prospecto.Punto_cardinal_empresa_b__c; // 07-03-2020
        newFamiempresa.Numero_empresa_b__c                      = prospecto.Numero_empresa_b__c; // 07-03-2020
        newFamiempresa.Informacion_adicional_complemento_e__c   = prospecto.Informacion_adicional_complemento_e__c; // 07-03-2020
        newFamiempresa.Ciudad_empresa__c                        = prospecto.Ciudad_empresa__c; // 07-03-2020
        newFamiempresa.Zona_empresa__c                          = prospecto.Zona_empresa__c; // 07-03-2020
        newFamiempresa.Barrio_empresa__c                        = prospecto.Barrio_empresa__c; // 07-03-2020
        newFamiempresa.Estrato_empresa__c                       = prospecto.Estrato_empresa__c; // 07-03-2020
        newFamiempresa.Ubicacion_Rural__c                       = prospecto.Ubicacion_Rural__c;
        
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Entra el trigger cuando se inserta la famiempresa
Si empresa en domicilio es falso se asigna buscando desde la ciudad y barrio de la famiEmpresa
Si empresa en domicilio es true se asigna buscando la ciudad y barrio del cliente o prospecto
dandole prioridad al cliente
*Date: 9-8-2019
**************************************************************************************************/
    public static void afterInsert(Boolean contexTrigger,Map<Id,Famiempresa__c> mapIdNewFamiempresa,List<Famiempresa__c> lstNewFamiempresa){
        System.debug('after insert: '+ mapIdNewFamiempresa + ' -- '+ lstNewFamiempresa);
        if(lstNewFamiempresa.size() == 1){
            if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c == false ){
                selecciona_sObject( lstNewFamiempresa.get(0) );
            }else 
                if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c == true ){
                    selecciona_sObject_2( lstNewFamiempresa.get(0) );
                }
        }
    }
    /********************************************************************************************************
*Author:  Rafael Cardona
*Function: Entra el trigger cuando se actualiza la famiempresa (Cuando se actualiza el valor Barrio).
Si empresa en domicilio es falso se asigna buscando desde la ciudad y barrio de la famiEmpresa
Si empresa en domicilio es true se asigna buscando la ciudad y barrio del cliente o prospecto
dandole prioridad al cliente
*Date: 9-8-2019
*********************************************************************************************************/
    public static void afterUpdate(Boolean contexTrigger,Map<Id,Famiempresa__c> mapIdNewFamiempresa,List<Famiempresa__c> lstNewFamiempresa,List<Famiempresa__c> lstOldFamiempresa){
        if(lstNewFamiempresa.size() == 1){
            if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c == false && lstNewFamiempresa.get(0).Barrio_empresa__c != lstOldFamiempresa.get(0).Barrio_empresa__c)
            {
                selecciona_sObject( lstNewFamiempresa.get(0) ); // 27-02-2020 
                
            }else if( lstNewFamiempresa.get(0).Empresa_en_domicilio__c == true && lstNewFamiempresa.get(0).Barrio_empresa__c != lstOldFamiempresa.get(0).Barrio_empresa__c){
                selecciona_sObject_2( lstNewFamiempresa.get(0) ); // 27-02-2020
            }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Se le da prioridad al cliente de la famiEmpresa, de lo contrario se escoge el prospecto
*Date: 9-8-2019
**************************************************************************************************/
    public static void selecciona_sObject_2(Famiempresa__c newFamiempresa){
        List<Empleado__c> lstEmpleado = new List<Empleado__c>();
        if( newFamiempresa.Cliente_relacionado__c != null ){
            List<Account> lstCuenta = consultaCliente( newFamiempresa.Cliente_relacionado__c );
            if( lstCuenta.size() == 1 )
                lstEmpleado =  encuentraAsesor(lstCuenta.get(0).Ciudad_empresa__c,lstCuenta.get(0).Barrio_empresa__c ); // 27-02-2020
            if( lstCuenta.size() == 1 && lstEmpleado.size() == 1 ){
                lstCuenta.get(0).Asesor_asignado__c = lstEmpleado[0].id;
                lstCuenta.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionCorrecta;
                update lstCuenta;
                crearTareaCliente( lstCuenta.get(0),lstEmpleado[0] );  }else if( lstCuenta.size() == 1 ){ lstCuenta.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionFallida; update lstCuenta;
                                                                                                        }        
        }else if( newFamiempresa.Prospecto_relacionado__c != null ){
            List<Lead> lstLead = consultaProspecto( newFamiempresa.Prospecto_relacionado__c );
            if( lstLead.size() == 1 )
                lstEmpleado =  encuentraAsesor(lstLead.get(0).Ciudad_empresa__c,lstLead.get(0).Barrio_empresa__c );
            if( lstLead.size() == 1 && lstEmpleado.size() == 1 ){ 
                lstLead.get(0).Asesor_asignado__c = lstEmpleado[0].id; 
                lstLead.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionCorrecta; 
                update lstLead; 
                crearTareaProspecto( lstLead.get(0),lstEmpleado[0] ); }else if( lstLead.size() == 1 ){ lstLead.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionFallida; update lstLead;
                                                                                                     }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Se le da prioridad al cliente de la famiEmpresa, de lo contrario se escoge el prospecto
*Date: 9-8-2019
**************************************************************************************************/
    public static void selecciona_sObject(Famiempresa__c newFamiempresa){
        List<Empleado__c> lstEmpleado = new List<Empleado__c>();
        if( newFamiempresa.Ciudad_empresa__c != null && newFamiempresa.Barrio_empresa__c != null )
            lstEmpleado =  encuentraAsesor(newFamiempresa.Ciudad_empresa__c,newFamiempresa.Barrio_empresa__c );
        if( newFamiempresa.Cliente_relacionado__c != null ){
            List<Account> lstCuenta = consultaCliente( newFamiempresa.Cliente_relacionado__c );
            if( lstCuenta.size() == 1 && lstEmpleado.size() == 1 ){
                lstCuenta.get(0).Asesor_asignado__c = lstEmpleado[0].id;
                lstCuenta.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionCorrecta;
                update lstCuenta;
                crearTareaCliente( lstCuenta.get(0),lstEmpleado[0] ); 
            }else if( lstCuenta.size() == 1 ){
                lstCuenta.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionFallida; update lstCuenta;
            } 
        }else if( newFamiempresa.Prospecto_relacionado__c != null ){ 
            List<Lead> lstLead = consultaProspecto( newFamiempresa.Prospecto_relacionado__c );  
            if( lstLead.size() == 1 && lstEmpleado.size() == 1 ){
                lstLead.get(0).Asesor_asignado__c = lstEmpleado[0].id;
                lstLead.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionCorrecta;
                update lstLead;
                crearTareaProspecto( lstLead.get(0),lstEmpleado[0] );
            }else if( lstLead.size() == 1 ){ 
                lstLead.get(0).Respuesta_Asignacion__c = Label.TareaAsignacionFallida; update lstLead;
            }
        }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Por medio de la ciudad y barrio se busca la matriz de asignacion en la cual podemos 
encontrar relacionado el empleado (asesor asignado)
Si no encuentra matriz o empleado se devuelve lista vacia
*Date: 9-8-2019
**************************************************************************************************/
    public static List<Empleado__c> encuentraAsesor(id ciudadEmpresa, id barrioEmpresa){
        List<Asociacion_barrio_empleado__c> lstMatrizAsignacion = consultaMatrizAsignacion( ciudadEmpresa,barrioEmpresa );
        System.debug('consultaMatrizAsignacion: '+ lstMatrizAsignacion);
        if(lstMatrizAsignacion.size() == 1 && lstMatrizAsignacion[0].Empleado__c != null ){
            List<Empleado__c> empleado = consultaEmpleadoAsignado( lstMatrizAsignacion[0].Empleado__c );
            System.debug('Empleado: '+ empleado);
            return empleado; }else{ return new List<Empleado__c>();
                                  }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Creación de tarea prospecto.
*Date: 5-9-2019
**************************************************************************************************/        
    public static void crearTareaProspecto(Lead prospecto, Empleado__c empleado){Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asignacion_de_Registro').getRecordTypeId();try{ Task tarea = new Task(); tarea.ActivityDate = System.today().addDays(3); tarea.Asignado_a__c = prospecto.Asesor_asignado__c;tarea.Correo_asesor_asignado__c = empleado.Correo_electronico__c;tarea.Nombre_completo__c = prospecto.Name;tarea.Numero_de_identificacion__c = prospecto.Numero_de_identificacion__c;tarea.OwnerId = prospecto.OwnerId;tarea.Priority = Label.TareaPrioridadAlta;tarea.Status = Label.TareaEstadoEnProgreso;tarea.Subject = Label.TareaAsuntoNuevaAsignacionProspecto;tarea.UrlBaseAsignado__c = prospecto.UrlBase__c + '' + prospecto.Id;tarea.WhoId = prospecto.Id;tarea.RecordTypeId = recordTypeId;insert tarea; }catch(Exception ex){
        System.debug('Error Creacion Tarea Prospecto: '+ ex.getStackTraceString());
    }
                                                                                }
    
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Creación de tarea cliente.
*Date: 5-9-2019
**************************************************************************************************/        
    public static void crearTareaCliente(Account cliente, Empleado__c empleado){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asignacion_de_Registro').getRecordTypeId();
        try{
            Task tarea = new Task();
            tarea.ActivityDate                = System.today().addDays(3);
            tarea.Asignado_a__c               = cliente.Asesor_asignado__c;
            tarea.Correo_asesor_asignado__c   = empleado.Correo_electronico__c;
            tarea.Nombre_completo__c          = (cliente.RecordType.DeveloperName == 'Persona_juridica')? cliente.Name : cliente.FirstName + ' ' + cliente.LastName;
            tarea.Numero_de_identificacion__c = cliente.Numero_de_identificacion__c;
            tarea.OwnerId                     = cliente.OwnerId;
            tarea.Priority                    = Label.TareaPrioridadAlta;
            tarea.Status                      = Label.TareaEstadoEnProgreso;
            tarea.Subject                     = Label.TareaAsuntoNuevaAsignacionCliente;
            tarea.UrlBaseAsignado__c          = cliente.UrlBase__c;
            tarea.WhatId                      = cliente.Id;
            tarea.RecordTypeId                = recordTypeId;
            insert tarea; }catch(Exception ex){
                System.debug('Error Creacion Tarea cliente: '+ ex.getStackTraceString());
            }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Consulta cliente tipo persona natural/juridica y tiene empresa en verdadero
*Date: 9-8-2019
**************************************************************************************************/
    public static List<Account> consultaCliente(String idCliente){
        return [SELECT id,RecordType.DeveloperName,Ruralidad_domicilio_contacto__pc,Ruralidad_domicilio_empresa__c,Via_contacto__pc,Via_empresa__c,Numero_contacto_a__pc,Numero_empresa_a__c,
                Letra_contacto_a__pc,Letra_empresa_a__c,Punto_cardinal_contacto_a__pc,Punto_Cardinal_empresa_a__c,Intercesion_contacto__pc,Intercesion_empresa__c,Letra_contacto_b__pc,Letra_empresa_b__c,
                Punto_cardinal_contacto_b__pc,Punto_cardinal_empresa_b__c,Numero_contacto_b__pc,Numero_empresa_b__c,Informacion_adicional_complemento_c__pc,Informacion_adicional_complemento_e__c,OwnerId, UrlBase__c,
                Ciudad_empresa__c,Zona_empresa__c,Barrio_empresa__c,Estrato_contacto__pc,Estrato_empresa__c,Asesor_asignado__c,Numero_de_identificacion__c,FirstName,LastName, Ubicacion_Rural__c
                FROM Account WHERE id =: idCliente AND RecordType.DeveloperName = 'Persona_natural' 
                AND Tiene_empresa__c = true LIMIT 1];
    }// 27-02-2020
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Consulta prospecto tipo persona natural y tiene empresa en verdadero
*Date: 9-8-2019
**************************************************************************************************/
    public static List<Lead> consultaProspecto(String idProspecto){
        return [SELECT id,Ubicacion_Rural__c,RecordType.DeveloperName,Ruralidad_domicilio_prospecto__c,Ruralidad_domicilio_empresa__c,Via_prospecto__c,Via_empresa__c,Numero_prospecto_a__c,Numero_empresa_a__c,
                Letra_prospecto_a__c,Letra_empresa_a__c,Punto_cardinal_prospecto_a__c,Punto_cardinal_empresa_a__c,Intercesion_prospecto__c,Intercesion_empresa__c,Letra_prospecto_b__c,Letra_empresa_b__c,
                Punto_cardinal_prospecto_b__c,Punto_cardinal_empresa_b__c,Numero_prospecto_b__c,Numero_empresa_b__c,Informacion_adicional_complemento_p__c,Informacion_adicional_complemento_e__c,OwnerId, UrlBase__c,
                Ciudad_prospecto__c,Ciudad_empresa__c,Zona_prospecto__c,Zona_empresa__c,Barrio_prospecto__c,Barrio_empresa__c,Estrato_prospecto__c,Estrato_empresa__c,Asesor_asignado__c, Name, Numero_de_identificacion__c 
                FROM Lead WHERE id =: idProspecto AND RecordType.DeveloperName = 'Persona_natural' 
                AND Tiene_empresa__c = true LIMIT 1];
    }
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Consulta matriz de asignacion (Asociacion_barrio_empleado__c)
*Date: 9-8-2019
**************************************************************************************************/
    public static List<Asociacion_barrio_empleado__c> consultaMatrizAsignacion( id ciudadEmpresa, id barrioEmpresa ){
        return [SELECT id,Empleado__c, Id_Ciudad_Barrio_Relacionado__c, Id_barrio__c FROM Asociacion_barrio_empleado__c 
                WHERE Id_Ciudad_Barrio_Relacionado__c =: ciudadEmpresa AND Id_barrio__c =: barrioEmpresa ORDER BY LastModifiedDate DESC LIMIT 1];
    }
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Consulta empleado asignado (Empleado__c)
*Date: 9-8-2019
**************************************************************************************************/
    public static List<Empleado__c> consultaEmpleadoAsignado( id idEmpleado ){
        return [SELECT id,Correo_electronico__c  FROM Empleado__c WHERE Id =: idEmpleado LIMIT 1];
    } 
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Consulta la famiEmpresa
*Date: 1-05-2020
**************************************************************************************************/
    public static List<Famiempresa__c> consultaFamiEmpresa( List<Famiempresa__c> lstOldFamiempresa ){
        return [SELECT id, Ingreso_Anual__c,Ingresos_ventas__c,Gastos_de_administracion_y_ventas__c,Salario_s_due_o_s_empresa__c,
                Cuota_s_interactuar__c,Otros_egresos__c,Costo_mercancia_vendida__c,Gastos_laborales__c,Cuota_s_otras_obligaciones__c,
                Otros_ingresos__c,Cuota_credito_cancelar__c,Numero_de_empleados__c,
                Cliente_relacionado__r.RecordType.DeveloperName,
                (SELECT id, StageName,Respuesta_Oportunidad__c, SyncedQuoteId, Origen_Integracion__c,
                 RecordType.DeveloperName FROM Oportunidades__r) 
                FROM Famiempresa__c WHERE id IN: lstOldFamiempresa];
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Identifica cuales famiEmpresas cumplen las condiciones de restricción
*Date: 1-05-2020
**************************************************************************************************/
    public static Map<Id,Famiempresa__c> seleccionaFamiEmpresas( List<Famiempresa__c> lstFami ){
        Map<Id,Famiempresa__c> mapFamiSeleccionada = new Map<Id,Famiempresa__c>();
        for(Famiempresa__c fa: lstFami){
            for(Opportunity op: fa.Oportunidades__r){ if( fa.Cliente_relacionado__r.RecordType.DeveloperName == 'Persona_natural' && op.RecordType.DeveloperName == 'Solicitud_de_credito' && op.Respuesta_Oportunidad__c != null && op.Respuesta_Oportunidad__c.contains('OK') && op.SyncedQuoteId != null  && op.StageName == 'En Estudio' ){ mapFamiSeleccionada.put(fa.id,fa); break;
                                                                                                                                                                                                                                                                                                                                              }                
                                                    }
        }
        return mapFamiSeleccionada;
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Identifica Campos modificados
*Date: 1-05-2020
**************************************************************************************************/
    public static void validaCamposModificados( Map<Id,Famiempresa__c> mapFamiSeleccionada, Map<Id,Famiempresa__c> mapNewFamiempresa){
        String campoNoPermitido = '';
        for(ID Idfa: mapFamiSeleccionada.keySet()){if( mapFamiSeleccionada.get(Idfa).Ingreso_Anual__c != mapNewFamiempresa.get(Idfa).Ingreso_Anual__c )     campoNoPermitido += 'Ingreso Anual -\n'; if( mapFamiSeleccionada.get(Idfa).Ingresos_ventas__c != mapNewFamiempresa.get(Idfa).Ingresos_ventas__c )  campoNoPermitido += 'Ingresos ventas -\n'; if( mapFamiSeleccionada.get(Idfa).Gastos_de_administracion_y_ventas__c != mapNewFamiempresa.get(Idfa).Gastos_de_administracion_y_ventas__c )   campoNoPermitido += 'Gastos de administración y ventas -\n';      if( mapFamiSeleccionada.get(Idfa).Salario_s_due_o_s_empresa__c != mapNewFamiempresa.get(Idfa).Salario_s_due_o_s_empresa__c )   campoNoPermitido += 'Salario(s) dueño(s) empresa -\n';        if( mapFamiSeleccionada.get(Idfa).Cuota_s_interactuar__c != mapNewFamiempresa.get(Idfa).Cuota_s_interactuar__c )   campoNoPermitido += 'Cuota(s) interactuar -\n';          if( mapFamiSeleccionada.get(Idfa).Otros_egresos__c != mapNewFamiempresa.get(Idfa).Otros_egresos__c )    campoNoPermitido += 'Otros egresos -\n';                    if( mapFamiSeleccionada.get(Idfa).Costo_mercancia_vendida__c != mapNewFamiempresa.get(Idfa).Costo_mercancia_vendida__c )   campoNoPermitido += 'Costo mercancía vendida -\n';if( mapFamiSeleccionada.get(Idfa).Gastos_laborales__c != mapNewFamiempresa.get(Idfa).Gastos_laborales__c )    campoNoPermitido += 'Gastos laborales -\n'; if( mapFamiSeleccionada.get(Idfa).Cuota_s_otras_obligaciones__c != mapNewFamiempresa.get(Idfa).Cuota_s_otras_obligaciones__c )  campoNoPermitido += 'Cuota(s) otras obligaciones -\n'; if( mapFamiSeleccionada.get(Idfa).Otros_ingresos__c != mapNewFamiempresa.get(Idfa).Otros_ingresos__c )     campoNoPermitido += 'Otros ingresos -\n'; if( mapFamiSeleccionada.get(Idfa).Cuota_credito_cancelar__c != mapNewFamiempresa.get(Idfa).Cuota_credito_cancelar__c )   campoNoPermitido += 'Cuota de crédito a cancelar';
                                                  }
        if( campoNoPermitido != ''){            Trigger.new[0].addError('Campo bloqueado: '+ campoNoPermitido);    
                                    System.debug('Famis campoNoPermitido: '+ campoNoPermitido);
                                   }
    }
    
    /*************************************************************************************************
*Author:  Rafael Cardona
*Function: Valida campos que no se pueden modificar en ciertos estados de la oportunidad
*Date: 1-05-2020
**************************************************************************************************/
    public static void bUControlCampos(Boolean contexTrigger,Map<Id,Famiempresa__c> mapNewFamiempresa,List<Famiempresa__c> lstOldFamiempresa,List<Famiempresa__c> lstNewFamiempresa){
        Map<Id,Famiempresa__c> mapFamiSeleccionada;
        List<Famiempresa__c> lstFami = consultaFamiEmpresa( lstOldFamiempresa );
        mapFamiSeleccionada          = seleccionaFamiEmpresas(lstFami);
        validaCamposModificados(mapFamiSeleccionada,mapNewFamiempresa);
    }
}
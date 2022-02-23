/**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase que abarca las consultas mas grandes del sistema

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-Abr-2020  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************/
public without sharing class IT_GestorDeConsultas_cls {
    public static List<Account> consultaCuenta(List<Id> idsCuenta){
        return [SELECT Id,Barrio_contacto__pr.name,Barrio_empresa__r.name,Codigo_barrio_empresa__c,Codigo_industria_OR_SF__c,Letra_empresa_a__c,Letra_empresa_b__c,Letra_contacto_b__pc,Letra_contacto_a__pc,Numero_empresa_a__c,Total_ingresos__c,
                Numero_empresa_b__c,Punto_Cardinal_empresa_a__c,Punto_cardinal_contacto_a__pc,Punto_cardinal_empresa_b__c,Punto_cardinal_contacto_b__pc,Ruralidad_domicilio_empresa__c,Ruralidad_domicilio_contacto__pc,Sueldo_Honorario__c,
                RecordType.name,RecordTypeId,Via_empresa__c,Via_contacto__pc,Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Sector__c,Informacion_adicional_complemento_e__c,Informacion_adicional_complemento_c__pc,Total_egresos__c,
                Intercesion_empresa__c,Intercesion_contacto__pc,NumberOfEmployees,Industria__c,Movil_empresa__c,Codigo_sector_SF__c,Zona_empresa__r.Codigo_Registro_Zona__c,Zona_empresa__r.Name,Autorizacion_uso_de_datos__c,
                Autorizacion_uso_de_datos__pc,Correo_electronico_empresa__c,PersonBirthdate,Genero__pc,Indicativo_empresa__c,Indicativo_contacto__pc,Medio_de_autorizacion__c,Medio_de_autorizacion__pc,Nivel_de_escolaridad__pc,
                Name,Numero_de_identificacion__c,Tipo_de_identificacion__c,Telefono_empresa__c,Movil_contacto__pc,Telefono_contacto__pc,LastName,PersonEmail,Barrio_empresa__r.Codigo_Registro_Barrio__c,Otros_ingresos_familiares__c,
                Codigo_barrio_contacto__c,Codigo_departamento_contacto__pc,Codigo_departamento_empresa__c,Departamento_empresa__c,Codigo_ciudad_contacto__pc,Departamento_contacto__pc,Medio_por_el_cual_conocio_a_Interactuar__c,
                FirstName,Estrato_contacto__pc,Actividad_economica__r.Codigo_Actividad_Economica_SF__c,Actividad_economica__r.Name,Barrio_empresa__c,Codigo_de_empresa__c,Asesor_asignado__r.Codigo_de_Empleado__c,Ingresos_conyuge__c,
                Estado_civil__pc,Personas_a_cargo__pc,Vigente__c,Tipo_de_vivienda__pc,Ocupacion__c,Cabeza_de_familia__pc,Principales_productos_servicios_1__c,Principales_productos_servicios_2__c,Empleos_a_generar__c,Otros_egresos_familiares__c,
                Principales_productos_servicios_3__c,Principales_productos_servicios_4__c,Principales_productos_servicios_5__c,Numero_contacto_a__pc,Numero_contacto_b__pc,Es_autorretenedor__c,Codigo_ciudad_empresa__c,Egresos_conyuge__c,
                Ciudad_empresa__c,Codigo_sector_OR__c,Fecha_de_creacion_de_empresa__c,ispersonaccount,Ciudad_contacto__pr.Name,RecordType.DeveloperName,Ciudad_empresa__r.Name,Estrato_empresa__c,Fecha_de_nacimiento__c,Hogar__c,
                Identificador_Famiempresa__c,Segundo_Apellido__c,MiddleName,Zona_empresa__c,AccountSource,Registro_creado_por__c,DireccionLaboral__c,TelefonoLaboral__c,Nombres_y_apellidos_Referencia__c,AnnualRevenue,
                Nombres_y_apellidos_Ref2__c,Nombres_y_apellidos_Ref3__c,Nombres_y_apellidos_Ref4__c,Nombres_y_apellidos_Ref5__c,Telefono_Referencia__c,Telefono_Ref2__c,Telefono_Ref3__c,Telefono_Ref4__c,Telefono_Ref5__c,
                Tipo_Referencia_1__c,Tipo_Referencia_2__c,Tipo_Referencia_3__c,Tipo_Referencia_4__c,Tipo_Referencia_5__c,CiudadRef1codOR__c,CiudadRef2codOR__c,CiudadRef3codOR__c,CiudadRef4codOR__c,CiudadRef5codOR__c,Vista_direccion_empresa__c,Empresa_donde_labora__c,
                CargoLaboral__c,Nombres_Completo_Conyuge__c,Numero_de_identificaci_n_conyuge__c,Ocupacion_Conyuge__c,Alquiler__c,Educacion__c,Prestamos__c,Ingreso_disponible_total__c,Ubicacion_Rural__c
                
                FROM Account  
                WHERE Id  =: idsCuenta.get(0) ];
    }
    
    public static List<Opportunity> consultaOportunidad(String idsOportunidad){
        return [SELECT Id,Famiempresa_relacionada__r.Ciudad_empresa__r.Nombre_Departamento__c,Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Famiempresa_relacionada__r.Actividad_economica__r.Name,
                Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c,Famiempresa_relacionada__r.Correo_electronico_empresa__c,Famiempresa_relacionada__r.Codigo_departamento_empresa__c,Famiempresa_relacionada__r.Departamento_empresa__c,
                Famiempresa_relacionada__r.Codigo_ciudad_empresa__c,Famiempresa_relacionada__r.Ciudad_empresa__c,Famiempresa_relacionada__r.Informacion_adicional_complemento_e__c,Famiempresa_relacionada__r.Intercesion_empresa__c,
                Famiempresa_relacionada__r.Letra_empresa_a__c,Famiempresa_relacionada__r.Letra_empresa_b__c,Famiempresa_relacionada__r.Numero_empresa_a__c,Famiempresa_relacionada__r.Numero_empresa_b__c,
                Famiempresa_relacionada__r.Punto_Cardinal_empresa_a__c,Famiempresa_relacionada__r.Punto_cardinal_empresa_b__c,Famiempresa_relacionada__r.Ruralidad_domicilio_empresa__c,Famiempresa_relacionada__r.Via_empresa__c,
                Famiempresa_relacionada__r.Codigo_industria_OR_SF__c,Famiempresa_relacionada__r.Industria__c,Famiempresa_relacionada__r.Movil_empresa__c,Famiempresa_relacionada__r.Name,Famiempresa_relacionada__r.Sector__c,
                Famiempresa_relacionada__r.Telefono_empresa__c,Famiempresa_relacionada__r.Tipo_de_identificacion__c,Famiempresa_relacionada__r.Barrio_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_empleados__c,
                Famiempresa_relacionada__r.Indicativo_empresa__c,Famiempresa_relacionada__r.Principales_productos_servicios_1__c,Famiempresa_relacionada__r.Principales_productos_servicios_2__c,
                Famiempresa_relacionada__r.Principales_productos_servicios_3__c,Famiempresa_relacionada__r.Principales_productos_servicios_4__c,Famiempresa_relacionada__r.Principales_productos_servicios_5__c,
                Famiempresa_relacionada__r.Codigo_sector_OR__c,Famiempresa_relacionada__r.Ciudad_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_identificacion__c,Famiempresa_relacionada__r.Identificador_Famiempresa__c,
                Famiempresa_relacionada__r.Zona_empresa__c,Famiempresa_relacionada__r.Estrato_empresa__c,Famiempresa_relacionada__r.Vista_direccion_empresa__c,Famiempresa_relacionada__r.Tipo_de_construccion__c,
                Famiempresa_relacionada__r.Anioos_de_construccion__c,Famiempresa_relacionada__r.Numero_pisos__c,Famiempresa_relacionada__r.Actividad_economica__c,Famiempresa_relacionada__r.Tipo_de_local_donde_tiene_la_empresa__c,
                Famiempresa_relacionada__r.Ingreso_Anual__c,Famiempresa_relacionada__r.Empleos_a_generar__c,Account.Id,Account.Identificador_Famiempresa__c,Account.Barrio_contacto__pr.name,Account.Barrio_empresa__r.name,
                Account.Codigo_barrio_empresa__c,Account.Codigo_industria_OR_SF__c,Account.Letra_empresa_a__c,Account.Letra_empresa_b__c,Account.Letra_contacto_b__pc,Account.Letra_contacto_a__pc,Account.Numero_empresa_a__c,
                Account.Numero_empresa_b__c,Account.Punto_Cardinal_empresa_a__c,Account.Punto_cardinal_contacto_a__pc,Account.Punto_cardinal_empresa_b__c,Account.Punto_cardinal_contacto_b__pc,Account.Ruralidad_domicilio_empresa__c,
                Account.Ruralidad_domicilio_contacto__pc,Account.RecordType.name,Account.RecordTypeId,Account.RecordType.DeveloperName,Account.Via_empresa__c,Account.Via_contacto__pc,Account.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,
                Account.Sector__c,Account.Informacion_adicional_complemento_e__c,Account.Informacion_adicional_complemento_c__pc,Account.Intercesion_empresa__c,Account.Intercesion_contacto__pc,Account.NumberOfEmployees,
                Account.Industria__c,Account.Movil_empresa__c,Account.Codigo_sector_SF__c,Account.Vista_direccion_empresa__c,Account.Zona_empresa__c,Account.Autorizacion_uso_de_datos__c,Account.Autorizacion_uso_de_datos__pc,
                Account.Correo_electronico_empresa__c,Account.PersonBirthdate,Account.Genero__pc,Account.Indicativo_empresa__c,Account.Indicativo_contacto__pc,Account.Medio_de_autorizacion__c,Account.Medio_de_autorizacion__pc,
                Account.Nivel_de_escolaridad__pc,Account.Name,Account.Numero_de_identificacion__c,Account.Tipo_de_identificacion__c,Account.Telefono_empresa__c,Account.Valor_comercial_del_Bien__c,Account.Otros_ingresos_familiares__c,
                Account.Ingresos_conyuge__c,Account.Total_ingresos__c,Account.Sueldo_Honorario__c,Account.Total_egresos__c,Account.Hogar__c,Account.Otros_egresos_familiares__c,Account.Egresos_conyuge__c,Account.Nombres_y_apellidos_Referencia__c,
                Account.Nombres_y_apellidos_Ref2__c,Account.Nombres_y_apellidos_Ref3__c,Account.Nombres_y_apellidos_Ref4__c,Account.Nombres_y_apellidos_Ref5__c,Account.Celular_Referencia__c,Account.Telefono_Referencia__c,
                Account.Telefono_Ref2__c,Account.Telefono_Ref3__c,Account.Telefono_Ref4__c,Account.Telefono_Ref5__c,Account.Tipo_Referencia_1__c,Account.Tipo_Referencia_2__c,Account.Tipo_Referencia_3__c,Account.Tipo_Referencia_4__c,
                Account.Tipo_Referencia_5__c,Account.CiudadRef1codOR__c,Account.CiudadRef2codOR__c,Account.CiudadRef3codOR__c,Account.CiudadRef4codOR__c,Account.CiudadRef5codOR__c,Account.Movil_contacto__pc,Account.Telefono_contacto__pc,
                Account.LastName,Account.PersonEmail,Account.Barrio_empresa__r.Codigo_Registro_Barrio__c,Account.Codigo_barrio_contacto__c,Account.Codigo_departamento_contacto__pc,Account.Codigo_departamento_empresa__c,
                Account.Departamento_empresa__c,Account.Codigo_ciudad_contacto__pc,Account.Departamento_contacto__pc,Account.Medio_por_el_cual_conocio_a_Interactuar__c,Account.FirstName,Account.Estrato_contacto__pc,
                Account.Actividad_economica__r.Codigo_Actividad_Economica_SF__c,Account.Actividad_economica__r.Name,Account.Ciudad_contacto__pc,Account.Barrio_empresa__c,Account.Codigo_de_empresa__c,Account.Asesor_asignado__r.Codigo_de_Empleado__c,
                Account.Estado_civil__pc,Account.Personas_a_cargo__pc,Account.Vigente__c,Account.Tipo_de_vivienda__pc,Account.Ocupacion__c,Account.Cabeza_de_familia__pc,Account.Principales_productos_servicios_1__c,
                Account.Principales_productos_servicios_2__c,Account.Principales_productos_servicios_3__c,Account.Principales_productos_servicios_4__c,Account.Principales_productos_servicios_5__c,Account.Numero_contacto_a__pc,
                Account.Numero_contacto_b__pc,Account.Es_autorretenedor__c,Account.Codigo_ciudad_empresa__c,Account.Ciudad_empresa__c,Account.Codigo_sector_OR__c,Account.Fecha_de_creacion_de_empresa__c,Account.ispersonaccount,
                Account.Estrato_empresa__c,Account.Ciudad_contacto__pr.Name,Account.Ciudad_empresa__r.Name,Account.Fecha_de_nacimiento__c,Account.Barrio_contacto__pr.Codigo_Registro_Barrio__c,Account.Segundo_Apellido__c,
                Account.MiddleName,Account.Zona_empresa__r.Codigo_Registro_Zona__c,Account.Zona_empresa__r.Name,Account.DireccionLaboral__c,Account.TelefonoLaboral__c,Account.Ciudad_empresa__r.Nombre_Departamento__c,
                Account.PersonContactId,Account.Lugar_expedicion__c,Account.Pais_empresa__c,Account.Empresa_donde_labora__c,Account.Nacionalidad__c,Account.Lugar_de_nacimiento__c,Account.Peso_kg__c,Account.Estatura_cm__c,
                Account.Empleos_a_generar__c,Account.AnnualRevenue,Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c, Account.Actividad_economica__r.Codigo_CIIU__c, Famiempresa_relacionada__r.Actividad_economica__r.Codigo_CIIU__c,Oficina_asesor_asignado__c,Asesor_asignado__r.Codigo_de_Empleado__c,Asesor_asignado__r.Sede_Empleado__c,Asesor_asignado__r.Name,Asesor_asignado__r.Correo_electronico__c,
                Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,Empleado_que_refiere__r.Codigo_de_Empleado__c,Forma_de_pago__c,Paga_un_tercero__c,
                (SELECT Id,Status,Res_conteo_productos_cotizacion__c,idDocumentoPagare__c FROM Quotes WHERE IsSyncing=true LIMIT 1),(SELECT Id,Product2.ProductCode FROM OpportunityLineItems LIMIT 1),
                Owner.Name,RecordTypeId,RecordType.Name,Asesor_asignado__r.Oficina_Empleado__r.Centro_de_Costos__c,Sede_Asesor_asignado__c,Codigo_Empleado_Asesor_asignado__c,Codigo_Oficina_OR_Asesor_Asignado__c,
                Codigo_Sede_OR_Asesor_Asignado__c,Tipo_de_documento_tercero__c,Numero_de_identificacion_tercero__c,Quien_paga_tercero__c,Numero_de_identificacion_de_asistente_1__c,Numero_de_identificacion_de_asistente_2__c,
                Numero_de_identificacion_de_asistente_3__c,Amount,Famiempresa_relacionada__r.Barrio_empresa__r.Codigo_Registro_Barrio__c,Respuesta_Oportunidad__c,Identificador_proceso__c,RecordType.DeveloperName,
                Quien_autoriza__r.Codigo_de_Empleado__c,Numero_credito_aprobado__c,Cuentas_por_cobrar_comerciales__c,Inventario_balance__c,Activos_fijos__c,Total_activos_balance__c,Patrimonio__c,Total_pasivo__c,
                CostoMciaVendida__c,Disponibilidad_Neta__c,Empleado_que_refiere__r.Numero_de_documento__c,Cheque_a_nombre_de_entidad__c,Tipo_de_cuenta__c,Cuenta_No__c,Telefono_Sucursal_Bancaria__c,Entidad_financiera__c,Sucursal_Bancaria__c,
                Registro_creado_por__c,CloseDate,Exonero_a_Interactuar_de_toda_responsabi__c,Medio_de_desembolso__c,Total_Activos_Fijos_y_Otros__c,Famiempresa_relacionada__c,Total_Capital_de_Trabajo__c,
                Campaign.Name,Campaign.Type,Campaign.CreatedDate,Campaign.IndicadorEnvioMensaje__c,CampaignId,CreatedDate,NomApe_Ben1__c,ParentescoBen1__c,Tipo_ideBen1__c,Numero_idenBen1__c,PorcentajeBen1__c,
                NomApe_Ben2__c,ParentescoBen2__c,Tipo_ideBen2__c,Numero_idenBen2__c,PorcentajeBen2__c,NomApe_Ben3__c,ParentescoBen3__c,Tipo_ideBen3__c,Numero_idenBen3__c,PorcentajeBen3__c,CreditoSaldoCargo__c,Fondo__c,
                Persona_Publica__c,Vinculo_con_Persona_Publica__c,Presenta_los_siguientes_sintomas__c,Familiar_con_los_siguientes_sintomas__c,Sintomas_NO_relacionado_en_la_lista__c,Se_encuentra_en_embarazo__c,
                Hospitalizacion_programada__c,Participa_en_competencias_deportivas__c,Presenta_una_dolencia_no_mencionada__c,Se_le_ha_negado_un_seguro__c,Se_encuentra_en_estudio_medico__c,Sera_sometido_a_tratamiento_medico__c,
                Ha_sido_alguna_vez_hospitalizado__c,Numero_de_cigarrillos_diarios_que_fuma__c,Numero_de_Afiliados_a_Prever__c
                FROM Opportunity  
                WHERE Id  =: idsOportunidad ];
    }
       public static List<Opportunity> consultaOportunidadPdf(List<Id> idsOportunidad){
        return [SELECT Id,Famiempresa_relacionada__r.Ciudad_empresa__r.Nombre_Departamento__c,Famiempresa_relacionada__r.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Famiempresa_relacionada__r.Actividad_economica__r.Name,
                Famiempresa_relacionada__r.Fecha_de_creacion_de_empresa__c,Famiempresa_relacionada__r.Correo_electronico_empresa__c,Famiempresa_relacionada__r.Codigo_departamento_empresa__c,Famiempresa_relacionada__r.Departamento_empresa__c,
                Famiempresa_relacionada__r.Codigo_ciudad_empresa__c,Famiempresa_relacionada__r.Ciudad_empresa__c,Famiempresa_relacionada__r.Informacion_adicional_complemento_e__c,Famiempresa_relacionada__r.Intercesion_empresa__c,
                Famiempresa_relacionada__r.Letra_empresa_a__c,Famiempresa_relacionada__r.Letra_empresa_b__c,Famiempresa_relacionada__r.Numero_empresa_a__c,Famiempresa_relacionada__r.Numero_empresa_b__c,
                Famiempresa_relacionada__r.Punto_Cardinal_empresa_a__c,Famiempresa_relacionada__r.Punto_cardinal_empresa_b__c,Famiempresa_relacionada__r.Ruralidad_domicilio_empresa__c,Famiempresa_relacionada__r.Via_empresa__c,
                Famiempresa_relacionada__r.Codigo_industria_OR_SF__c,Famiempresa_relacionada__r.Industria__c,Famiempresa_relacionada__r.Movil_empresa__c,Famiempresa_relacionada__r.Name,Famiempresa_relacionada__r.Sector__c,
                Famiempresa_relacionada__r.Telefono_empresa__c,Famiempresa_relacionada__r.Tipo_de_identificacion__c,Famiempresa_relacionada__r.Barrio_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_empleados__c,
                Famiempresa_relacionada__r.Indicativo_empresa__c,Famiempresa_relacionada__r.Principales_productos_servicios_1__c,Famiempresa_relacionada__r.Principales_productos_servicios_2__c,
                Famiempresa_relacionada__r.Principales_productos_servicios_3__c,Famiempresa_relacionada__r.Principales_productos_servicios_4__c,Famiempresa_relacionada__r.Principales_productos_servicios_5__c,
                Famiempresa_relacionada__r.Codigo_sector_OR__c,Famiempresa_relacionada__r.Ciudad_empresa__r.Name,Famiempresa_relacionada__r.Numero_de_identificacion__c,Famiempresa_relacionada__r.Identificador_Famiempresa__c,
                Famiempresa_relacionada__r.Zona_empresa__c,Famiempresa_relacionada__r.Estrato_empresa__c,Famiempresa_relacionada__r.Vista_direccion_empresa__c,Famiempresa_relacionada__r.Tipo_de_construccion__c,
                Famiempresa_relacionada__r.Anioos_de_construccion__c,Famiempresa_relacionada__r.Numero_pisos__c,Famiempresa_relacionada__r.Actividad_economica__c,Famiempresa_relacionada__r.Tipo_de_local_donde_tiene_la_empresa__c,
                Famiempresa_relacionada__r.Ingreso_Anual__c,Famiempresa_relacionada__r.Empleos_a_generar__c,Account.Id,Account.Identificador_Famiempresa__c,Account.Barrio_contacto__pr.name,Account.Barrio_empresa__r.name,
                Account.Codigo_barrio_empresa__c,Account.Codigo_industria_OR_SF__c,Account.Letra_empresa_a__c,Account.Letra_empresa_b__c,Account.Letra_contacto_b__pc,Account.Letra_contacto_a__pc,Account.Numero_empresa_a__c,
                Account.Numero_empresa_b__c,Account.Punto_Cardinal_empresa_a__c,Account.Punto_cardinal_contacto_a__pc,Account.Punto_cardinal_empresa_b__c,Account.Punto_cardinal_contacto_b__pc,Account.Ruralidad_domicilio_empresa__c,
                Account.Ruralidad_domicilio_contacto__pc,Account.RecordType.name,Account.RecordTypeId,Account.RecordType.DeveloperName,Account.Via_empresa__c,Account.Via_contacto__pc,Account.Actividad_economica__r.Codigo_Actividad_Economica_OR__c,
                Account.Sector__c,Account.Informacion_adicional_complemento_e__c,Account.Informacion_adicional_complemento_c__pc,Account.Intercesion_empresa__c,Account.Intercesion_contacto__pc,Account.NumberOfEmployees,
                Account.Industria__c,Account.Movil_empresa__c,Account.Codigo_sector_SF__c,Account.Vista_direccion_empresa__c,Account.Zona_empresa__c,Account.Autorizacion_uso_de_datos__c,Account.Autorizacion_uso_de_datos__pc,
                Account.Correo_electronico_empresa__c,Account.PersonBirthdate,Account.Genero__pc,Account.Indicativo_empresa__c,Account.Indicativo_contacto__pc,Account.Medio_de_autorizacion__c,Account.Medio_de_autorizacion__pc,
                Account.Nivel_de_escolaridad__pc,Account.Name,Account.Numero_de_identificacion__c,Account.Tipo_de_identificacion__c,Account.Telefono_empresa__c,Account.Valor_comercial_del_Bien__c,Account.Otros_ingresos_familiares__c,
                Account.Ingresos_conyuge__c,Account.Total_ingresos__c,Account.Sueldo_Honorario__c,Account.Total_egresos__c,Account.Hogar__c,Account.Otros_egresos_familiares__c,Account.Egresos_conyuge__c,Account.Nombres_y_apellidos_Referencia__c,
                Account.Nombres_y_apellidos_Ref2__c,Account.Nombres_y_apellidos_Ref3__c,Account.Nombres_y_apellidos_Ref4__c,Account.Nombres_y_apellidos_Ref5__c,Account.Celular_Referencia__c,Account.Telefono_Referencia__c,
                Account.Telefono_Ref2__c,Account.Telefono_Ref3__c,Account.Telefono_Ref4__c,Account.Telefono_Ref5__c,Account.Tipo_Referencia_1__c,Account.Tipo_Referencia_2__c,Account.Tipo_Referencia_3__c,Account.Tipo_Referencia_4__c,
                Account.Tipo_Referencia_5__c,Account.CiudadRef1codOR__c,Account.CiudadRef2codOR__c,Account.CiudadRef3codOR__c,Account.CiudadRef4codOR__c,Account.CiudadRef5codOR__c,Account.Movil_contacto__pc,Account.Telefono_contacto__pc,
                Account.LastName,Account.PersonEmail,Account.Barrio_empresa__r.Codigo_Registro_Barrio__c,Account.Codigo_barrio_contacto__c,Account.Codigo_departamento_contacto__pc,Account.Codigo_departamento_empresa__c,
                Account.Departamento_empresa__c,Account.Codigo_ciudad_contacto__pc,Account.Departamento_contacto__pc,Account.Medio_por_el_cual_conocio_a_Interactuar__c,Account.FirstName,Account.Estrato_contacto__pc,
                Account.Actividad_economica__r.Codigo_Actividad_Economica_SF__c,Account.Actividad_economica__r.Name,Account.Ciudad_contacto__pc,Account.Barrio_empresa__c,Account.Codigo_de_empresa__c,Account.Asesor_asignado__r.Codigo_de_Empleado__c,
                Account.Estado_civil__pc,Account.Personas_a_cargo__pc,Account.Vigente__c,Account.Tipo_de_vivienda__pc,Account.Ocupacion__c,Account.Cabeza_de_familia__pc,Account.Principales_productos_servicios_1__c,
                Account.Principales_productos_servicios_2__c,Account.Principales_productos_servicios_3__c,Account.Principales_productos_servicios_4__c,Account.Principales_productos_servicios_5__c,Account.Numero_contacto_a__pc,
                Account.Numero_contacto_b__pc,Account.Es_autorretenedor__c,Account.Codigo_ciudad_empresa__c,Account.Ciudad_empresa__c,Account.Codigo_sector_OR__c,Account.Fecha_de_creacion_de_empresa__c,Account.ispersonaccount,
                Account.Estrato_empresa__c,Account.Ciudad_contacto__pr.Name,Account.Ciudad_empresa__r.Name,Account.Fecha_de_nacimiento__c,Account.Barrio_contacto__pr.Codigo_Registro_Barrio__c,Account.Segundo_Apellido__c,
                Account.MiddleName,Account.Zona_empresa__r.Codigo_Registro_Zona__c,Account.Zona_empresa__r.Name,Account.DireccionLaboral__c,Account.TelefonoLaboral__c,Account.Ciudad_empresa__r.Nombre_Departamento__c,
                Account.PersonContactId,Account.Lugar_expedicion__c,Account.Pais_empresa__c,Account.Empresa_donde_labora__c,Account.Nacionalidad__c,Account.Lugar_de_nacimiento__c,Account.Peso_kg__c,Account.Estatura_cm__c,
                Account.Empleos_a_generar__c,Account.AnnualRevenue,Account.Ciudad_empresa__r.Codigo_DANE_Ciudad__c, Account.Actividad_economica__r.Codigo_CIIU__c, Famiempresa_relacionada__r.Actividad_economica__r.Codigo_CIIU__c,Oficina_asesor_asignado__c,Asesor_asignado__r.Codigo_de_Empleado__c,Asesor_asignado__r.Sede_Empleado__c,Asesor_asignado__r.Name,Asesor_asignado__r.Correo_electronico__c,
                Asesor_asignado__r.Oficina_Empleado__r.Codigo_Oficina_OR__c,Empleado_que_refiere__r.Codigo_de_Empleado__c,Forma_de_pago__c,Paga_un_tercero__c,
                (SELECT Id,Status,Res_conteo_productos_cotizacion__c,idDocumentoPagare__c FROM Quotes WHERE IsSyncing=true LIMIT 1),(SELECT Id,Product2.ProductCode FROM OpportunityLineItems LIMIT 1),
                Owner.Name,RecordTypeId,RecordType.Name,Asesor_asignado__r.Oficina_Empleado__r.Centro_de_Costos__c,Sede_Asesor_asignado__c,Codigo_Empleado_Asesor_asignado__c,Codigo_Oficina_OR_Asesor_Asignado__c,
                Codigo_Sede_OR_Asesor_Asignado__c,Tipo_de_documento_tercero__c,Numero_de_identificacion_tercero__c,Quien_paga_tercero__c,Numero_de_identificacion_de_asistente_1__c,Numero_de_identificacion_de_asistente_2__c,
                Numero_de_identificacion_de_asistente_3__c,Amount,Famiempresa_relacionada__r.Barrio_empresa__r.Codigo_Registro_Barrio__c,Respuesta_Oportunidad__c,Identificador_proceso__c,RecordType.DeveloperName,
                Quien_autoriza__r.Codigo_de_Empleado__c,Numero_credito_aprobado__c,Cuentas_por_cobrar_comerciales__c,Inventario_balance__c,Activos_fijos__c,Total_activos_balance__c,Patrimonio__c,Total_pasivo__c,
                CostoMciaVendida__c,Disponibilidad_Neta__c,Empleado_que_refiere__r.Numero_de_documento__c,Cheque_a_nombre_de_entidad__c,Tipo_de_cuenta__c,Cuenta_No__c,Telefono_Sucursal_Bancaria__c,Entidad_financiera__c,Sucursal_Bancaria__c,
                Registro_creado_por__c,CloseDate,Exonero_a_Interactuar_de_toda_responsabi__c,Medio_de_desembolso__c,Total_Activos_Fijos_y_Otros__c,Famiempresa_relacionada__c,Total_Capital_de_Trabajo__c,
                Campaign.Name,Campaign.Type,Campaign.CreatedDate,Campaign.IndicadorEnvioMensaje__c,CampaignId,CreatedDate,NomApe_Ben1__c,ParentescoBen1__c,Tipo_ideBen1__c,Numero_idenBen1__c,PorcentajeBen1__c,
                NomApe_Ben2__c,ParentescoBen2__c,Tipo_ideBen2__c,Numero_idenBen2__c,PorcentajeBen2__c,NomApe_Ben3__c,ParentescoBen3__c,Tipo_ideBen3__c,Numero_idenBen3__c,PorcentajeBen3__c,CreditoSaldoCargo__c,Fondo__c,
                Persona_Publica__c,Vinculo_con_Persona_Publica__c,Presenta_los_siguientes_sintomas__c,Familiar_con_los_siguientes_sintomas__c,Sintomas_NO_relacionado_en_la_lista__c,Se_encuentra_en_embarazo__c,
                Hospitalizacion_programada__c,Participa_en_competencias_deportivas__c,Presenta_una_dolencia_no_mencionada__c,Se_le_ha_negado_un_seguro__c,Se_encuentra_en_estudio_medico__c,Sera_sometido_a_tratamiento_medico__c,
                Ha_sido_alguna_vez_hospitalizado__c,Numero_de_cigarrillos_diarios_que_fuma__c,Numero_de_Afiliados_a_Prever__c, Numero_de_credito_a_cancelar_1__c, Numero_de_credito_a_cancelar_2__c, Numero_de_credito_a_cancelar_3__c,
                Cliente_con_visita__c, Inventario__c, Maquinaria_y_equipo__c, Capacitacion__c, Pago_a_proveedores__c, Vehiculo__c, Creacion_de_empresas__c, Pago_a_terceros__c, Vivienda__c, Asesorias__c, Financiar_cuentas_por_cobrar__c,
                Local__c, Servicios_CCA__c, Otro_Capital__c, Terreno__c, Otros_empresarialConocimiento__c, Otros_activos__c, Cuales__c, Cual_empresarialConocimeinto__c, Caja_y_bancos__c, Cuentas_por_pagar_Interactuar__c, Otras_obligaciones_financieras__c,
                Proveedores__c, Otras_cuentas_por_cobrar__c, Otras_cuentas_por_pagar__c, Total_pasivo_mas_patrimonio__c, Dias_de_Cartera__c, Dias_de_Inventarios__c, Ciclo_Operacional__c, Porcentaje_de_Endeudamiento__c, Margen_Bruto__c, Margen_Neto__c,
                Cancelar_credito_Interactuar__c, Otros__c
                FROM Opportunity  
                WHERE Id  =: idsOportunidad.get(0) ];
    }

    public static List<QuoteLineItem> consultaProductoPorCotizacion(Opportunity opp){
        return [SELECT Id,Product2Id,Product2.ProductCode,Product2.Fecha_fin__c,Product2.Fecha_inicio__c,Product2.Identificador_grupo__c,Product2.Codigo_Oficina_OR__c,Product2.Codigo_Sede_OR__c,Identificador_Radicado_OR__c,
                Product2.name,Product2.ProductCode2__c,Quote.Opportunity.Forma_de_pago__c,Quote.Opportunity.Oficina_asesor_asignado__c,Quote.Opportunity.Asesor_asignado__c,Quote.Opportunity.Sede_Asesor_asignado__c,
                Product2.Requiere_pago__c,Quote.Opportunity.Empleado_que_refiere__r.Numero_de_documento__c,Quote.Opportunity.Codigo_Empleado_referido_por__c,Quote.Opportunity.Paga_un_tercero__c,Product2.Tipo_de_servicio__c,Quantity,
                TotalPrice,Convenio__r.Identificador_convenio__c,Quote.Opportunity.Account.Numero_de_identificacion__c,Convenio__r.Name,Quote.Opportunity.Numero_de_identificacion_de_asistente_1__c,
                Quote.Opportunity.Numero_de_identificacion_de_asistente_2__c,Quote.Opportunity.Numero_de_identificacion_de_asistente_3__c,Quote.Opportunity.Nombre_de_asistente_1__c,LineNumber,CreatedDate,
                Quote.Res_conteo_servicio_tipo_asesoria__c,Quote.Res_conteo_servicio_tipo_capacitacion__c,Product2.Grupo_convenio__c,Product2.Grupo_convenio_nombre__c,Quote.GrandTotal,
                Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c,Numero_identificador_de_pago__r.Name,
                Quote.Opportunity.Respuesta_Oportunidad__c,Quote.OpportunityId,Quote.Opportunity.Identificador_proceso__c,Plazo_meses__c,Tipo_credito__c,Quote.Opportunity.Cheque_a_nombre_de_entidad__c,
                Quote.Opportunity.Entidad_financiera__c,Quote.Opportunity.Tipo_de_cuenta__c,Quote.Opportunity.Medio_de_desembolso__c,Quote.Opportunity.Exonero_a_Interactuar_de_toda_responsabi__c,Quote.Opportunity.Cuenta_No__c,
                Periodo_Gracias_Meses__c,Codigo_Alianza__c,Quote.Opportunity.Numero_de_Afiliados_a_Prever__c, Puntaje_Score__c, fondo__c 
                FROM QuoteLineItem 
                WHERE Quote.OpportunityId =: opp.Id ];
    }
    	public static List<QuoteLineItem> consultaProductoPorCotizacionPdf(List<Id> idsOportunidad){
        return [SELECT Id,Product2Id,Product2.ProductCode,Product2.Fecha_fin__c,Product2.Fecha_inicio__c,Product2.Identificador_grupo__c,Product2.Codigo_Oficina_OR__c,Product2.Codigo_Sede_OR__c,Identificador_Radicado_OR__c,
                Product2.name,Product2.ProductCode2__c,Quote.Opportunity.Forma_de_pago__c,Quote.Opportunity.Oficina_asesor_asignado__c,Quote.Opportunity.Asesor_asignado__c,Quote.Opportunity.Sede_Asesor_asignado__c,
                Product2.Requiere_pago__c,Quote.Opportunity.Empleado_que_refiere__r.Numero_de_documento__c,Quote.Opportunity.Codigo_Empleado_referido_por__c,Quote.Opportunity.Paga_un_tercero__c,Product2.Tipo_de_servicio__c,Quantity,
                TotalPrice,Convenio__r.Identificador_convenio__c,Quote.Opportunity.Account.Numero_de_identificacion__c,Convenio__r.Name,Quote.Opportunity.Numero_de_identificacion_de_asistente_1__c,
                Quote.Opportunity.Numero_de_identificacion_de_asistente_2__c,Quote.Opportunity.Numero_de_identificacion_de_asistente_3__c,Quote.Opportunity.Nombre_de_asistente_1__c,LineNumber,CreatedDate,
                Quote.Res_conteo_servicio_tipo_asesoria__c,Quote.Res_conteo_servicio_tipo_capacitacion__c,Product2.Grupo_convenio__c,Product2.Grupo_convenio_nombre__c,Quote.GrandTotal,
                Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c,Numero_identificador_de_pago__r.Name,
                Quote.Opportunity.Respuesta_Oportunidad__c,Quote.OpportunityId,Quote.Opportunity.Identificador_proceso__c,Plazo_meses__c,Tipo_credito__c,Quote.Opportunity.Cheque_a_nombre_de_entidad__c,
                Quote.Opportunity.Entidad_financiera__c,Quote.Opportunity.Tipo_de_cuenta__c,Quote.Opportunity.Medio_de_desembolso__c,Quote.Opportunity.Exonero_a_Interactuar_de_toda_responsabi__c,Quote.Opportunity.Cuenta_No__c,
                Periodo_Gracias_Meses__c,Codigo_Alianza__c,Quote.Opportunity.Numero_de_Afiliados_a_Prever__c
                FROM QuoteLineItem 
                WHERE Quote.OpportunityId =: idsOportunidad.get(0) ];
    }    
    public static List<QuoteLineItem> consultaProductoPorCotizacion2(String idPxc){
        return [SELECT Id,Product2Id,Product2.ProductCode,Product2.Fecha_fin__c,Product2.Fecha_inicio__c,Product2.Identificador_grupo__c,Product2.Codigo_Oficina_OR__c,Product2.Codigo_Sede_OR__c,
                Product2.name,Product2.ProductCode2__c,Quote.Opportunity.Forma_de_pago__c,Quote.Opportunity.Oficina_asesor_asignado__c,Quote.Opportunity.Asesor_asignado__c,Quote.Opportunity.Sede_Asesor_asignado__c,
                Product2.Requiere_pago__c,Quote.Opportunity.Empleado_que_refiere__r.Numero_de_documento__c,Quote.Opportunity.Codigo_Empleado_referido_por__c,Identificador_Radicado_OR__c,Quote.Opportunity.Paga_un_tercero__c,
                Product2.Tipo_de_servicio__c,Quantity,TotalPrice,Convenio__r.Identificador_convenio__c,Quote.Opportunity.Account.Numero_de_identificacion__c,Convenio__r.Name,
                Quote.Opportunity.Numero_de_identificacion_de_asistente_1__c,Quote.Opportunity.Numero_de_identificacion_de_asistente_2__c,Quote.Opportunity.Numero_de_identificacion_de_asistente_3__c,
                Quote.Opportunity.Nombre_de_asistente_1__c,LineNumber,CreatedDate,Quote.Res_conteo_servicio_tipo_asesoria__c,Quote.Res_conteo_servicio_tipo_capacitacion__c,Product2.Grupo_convenio__c,
                Product2.Grupo_convenio_nombre__c,Quote.GrandTotal,Quote.Opportunity.Codigo_Oficina_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Sede_OR_Asesor_Asignado__c,Quote.Opportunity.Codigo_Empleado_Asesor_asignado__c,
                Numero_identificador_de_pago__r.Name,Quote.Opportunity.Respuesta_Oportunidad__c,Quote.OpportunityId,Quote.Opportunity.Identificador_proceso__c,Plazo_meses__c,Tipo_credito__c,
                Quote.Opportunity.Cheque_a_nombre_de_entidad__c,Quote.Opportunity.Entidad_financiera__c,Quote.Opportunity.Tipo_de_cuenta__c,Quote.Opportunity.Medio_de_desembolso__c,
                Quote.Opportunity.Exonero_a_Interactuar_de_toda_responsabi__c,Quote.Opportunity.Cuenta_No__c,Periodo_Gracias_Meses__c,Codigo_Alianza__c,Quote.Opportunity.Numero_de_Afiliados_a_Prever__c
                FROM QuoteLineItem 
                WHERE Id =: idPxc ];
    }
    
    public static List<Product2> consultaProducto( Set<String> codigos ){
        return [SELECT Id,ProductCode FROM Product2 WHERE ProductCode IN: codigos];
    }
    
    public static List<Famiempresa__c> consultaFamiEmpresa(String idCuenta){
        return [SELECT Id,Cliente_relacionado__c,Identificador_Famiempresa__c,Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Actividad_economica__r.Name,Fecha_de_creacion_de_empresa__c,Correo_electronico_empresa__c,
                Codigo_departamento_empresa__c,Departamento_empresa__c,Codigo_ciudad_empresa__c,Ciudad_empresa__c,Informacion_adicional_complemento_e__c,Intercesion_empresa__c,Letra_empresa_a__c,Letra_empresa_b__c,
                Numero_empresa_a__c,Numero_empresa_b__c,Punto_Cardinal_empresa_a__c,Punto_cardinal_empresa_b__c,Ruralidad_domicilio_empresa__c,Via_empresa__c,Codigo_industria_OR_SF__c,Industria__c,Movil_empresa__c,
                Name,Sector__c,Telefono_empresa__c,Tipo_de_identificacion__c,Barrio_empresa__r.Name,Numero_de_empleados__c,Indicativo_empresa__c,Principales_productos_servicios_1__c,Principales_productos_servicios_2__c,
                Principales_productos_servicios_3__c,Principales_productos_servicios_4__c,Principales_productos_servicios_5__c,Codigo_sector_OR__c,Ciudad_empresa__r.Name,Barrio_empresa__r.Codigo_Registro_Barrio__c,
                Numero_de_identificacion__c,Zona_empresa__r.Codigo_Registro_Zona__c,Zona_empresa__r.Name,Actividad_economica__c,Zona_empresa__c,Barrio_empresa__c,Ingresos_ventas__c,Costo_mercancia_vendida__c,
                Otros_ingresos__c,Disponibilidad_neta_empresa__c,Ingreso_Anual__c,Empleos_a_generar__c,Vista_direccion_empresa__c,Anios_de_experiencia__c,
                Utilidad_bruta__c,Gastos_de_administracion_y_ventas__c,Gastos_laborales__c,Salario_s_due_o_s_empresa__c,Utilidad_operacional__c,Cuota_s_interactuar__c,
                Cuota_s_otras_obligaciones__c,Otros_egresos__c, Cuota_credito_cancelar__c,Ubicacion_Rural__c
                FROM Famiempresa__c 
                WHERE Cliente_relacionado__c =: idCuenta order by LastModifiedDate desc LIMIT 1];
    }
    
    public static List<Famiempresa__c> consultaFamiEmpresaOpp(String idFami){
        return [SELECT Id,Cliente_relacionado__c,Identificador_Famiempresa__c,Actividad_economica__r.Codigo_Actividad_Economica_OR__c,Actividad_economica__r.Name,Fecha_de_creacion_de_empresa__c,Correo_electronico_empresa__c,
                Codigo_departamento_empresa__c,Departamento_empresa__c,Codigo_ciudad_empresa__c,Ciudad_empresa__c,Informacion_adicional_complemento_e__c,Intercesion_empresa__c,Letra_empresa_a__c,Letra_empresa_b__c,
                Numero_empresa_a__c,Numero_empresa_b__c,Punto_Cardinal_empresa_a__c,Punto_cardinal_empresa_b__c,Ruralidad_domicilio_empresa__c,Via_empresa__c,Codigo_industria_OR_SF__c,Industria__c,Movil_empresa__c,
                Name,Sector__c,Telefono_empresa__c,Tipo_de_identificacion__c,Barrio_empresa__r.Name,Numero_de_empleados__c,Indicativo_empresa__c,Principales_productos_servicios_1__c,Principales_productos_servicios_2__c,
                Principales_productos_servicios_3__c,Principales_productos_servicios_4__c,Principales_productos_servicios_5__c,Codigo_sector_OR__c,Ciudad_empresa__r.Name,Barrio_empresa__r.Codigo_Registro_Barrio__c,
                Numero_de_identificacion__c,Zona_empresa__r.Codigo_Registro_Zona__c,Zona_empresa__r.Name,Actividad_economica__c,Zona_empresa__c,Barrio_empresa__c,Ingresos_ventas__c,Costo_mercancia_vendida__c,
                Ingreso_Anual__c,Empleos_a_generar__c,Otros_ingresos__c,Disponibilidad_neta_empresa__c,Ubicacion_Rural__c
                FROM Famiempresa__c 
                WHERE Id =: idFami];
    }
    
    public static List<Contact> consultaContacto(List<Id> idsContacto){
        return [SELECT Id,FirstName,Segundo_Apellido__c,MiddleName,lastName,Email,Barrio_contacto__r.Name,Barrio_contacto__r.Codigo_Registro_Barrio__c,Codigo_departamento_contacto__c,Departamento_contacto__c,
                Codigo_ciudad_contacto__c,Ciudad_contacto__r.Name,controlSincronizacion__c,Informacion_adicional_complemento_c__c,Intercesion_contacto__c,Letra_contacto_a__c,Letra_contacto_b__c,Numero_contacto_a__c,
                Numero_contacto_b__c,Punto_cardinal_contacto_a__c,Punto_cardinal_contacto_b__c,Ruralidad_domicilio_contacto__c,Via_contacto__c,Birthdate,Genero__c,Indicativo_contacto__c,Medio_de_autorizacion__c,
                Movil_contacto__c,Nivel_de_escolaridad__c,Name,Numero_de_identificacion__c,Telefono_contacto__c,Tipo_de_identificacion__c,Estado_civil__c,Personas_a_cargo__c,Tipo_de_vivienda__c,Cabeza_de_familia__c,
                Estrato_contacto__c,Valor_comercial_del_Bien__c,Otros_ingresos_familiares__c,Ingresos_conyuge__c,Total_ingresos__c,Sueldo_Honorario__c,Otros_egresos_familiares__c,Egresos_conyuge__c,Total_egresos__c,
                Hogar__c,Consecutivo_Padre__c,Nombres_y_apellidos_Referencia__c,Celular_Referencia__c,Telefono_Referencia__c,Nombres_y_apellidos_Ref2__c,Telefono_Ref2__c,Nombres_y_apellidos_Ref3__c,Telefono_Ref3__c,
                Nombres_y_apellidos_Ref4__c,Telefono_Ref4__c,Nombres_y_apellidos_Ref5__c,Telefono_Ref5__c,Tipo_Referencia_1__c,Tipo_Referencia_2__c,Tipo_Referencia_3__c,Tipo_Referencia_4__c,Tipo_Referencia_5__c,
                CiudadRef1codOR__c,CiudadRef2codOR__c,CiudadRef3codOR__c,CiudadRef4codOR__c,CiudadRef5codOR__c,Zona_contacto__r.Codigo_Registro_Zona__c,Zona_contacto__r.Name,Empresa_donde_labora__c,Ocupacion__c,
                Barrio_contacto__c,Zona_contacto__c,Ciudad_contacto__c,Hipoteca_a_favor_de__c,Medio_por_el_cual_conocio_a_Interactuar__c,DireccionLaboral__c,TelefonoLaboral__c
                FROM Contact 
                WHERE Id =: idsContacto.get(0)];
    }
    
    public static List<Contact> consultaContactos(List<Id> listaContactos){
        return [SELECT Id,FirstName,Segundo_Apellido__c,MiddleName,lastName,Email,Barrio_contacto__r.Name,Barrio_contacto__r.Codigo_Registro_Barrio__c,Codigo_departamento_contacto__c,Departamento_contacto__c,
                Codigo_ciudad_contacto__c,Ciudad_contacto__r.Name,controlSincronizacion__c,Informacion_adicional_complemento_c__c,Intercesion_contacto__c,Letra_contacto_a__c,Letra_contacto_b__c,Numero_contacto_a__c,
                Numero_contacto_b__c,Punto_cardinal_contacto_a__c,Punto_cardinal_contacto_b__c,Ruralidad_domicilio_contacto__c,Via_contacto__c,Birthdate,Genero__c,Indicativo_contacto__c,Medio_de_autorizacion__c,
                Movil_contacto__c,Nivel_de_escolaridad__c,Name,Numero_de_identificacion__c,Telefono_contacto__c,Tipo_de_identificacion__c,Estado_civil__c,Personas_a_cargo__c,Tipo_de_vivienda__c,Cabeza_de_familia__c,
                Estrato_contacto__c,Valor_comercial_del_Bien__c,Otros_ingresos_familiares__c,Ingresos_conyuge__c,Total_ingresos__c,Sueldo_Honorario__c,Otros_egresos_familiares__c,Egresos_conyuge__c,Total_egresos__c,
                Hogar__c,Consecutivo_Padre__c,Nombres_y_apellidos_Referencia__c,Celular_Referencia__c,Telefono_Referencia__c,Nombres_y_apellidos_Ref2__c,Telefono_Ref2__c,Nombres_y_apellidos_Ref3__c,Telefono_Ref3__c,
                Nombres_y_apellidos_Ref4__c,Telefono_Ref4__c,Nombres_y_apellidos_Ref5__c,Telefono_Ref5__c,Tipo_Referencia_1__c,Tipo_Referencia_2__c,Tipo_Referencia_3__c,Tipo_Referencia_4__c,Tipo_Referencia_5__c,
                CiudadRef1codOR__c,CiudadRef2codOR__c,CiudadRef3codOR__c,CiudadRef4codOR__c,CiudadRef5codOR__c,Zona_contacto__r.Codigo_Registro_Zona__c,Zona_contacto__r.Name,Empresa_donde_labora__c,Ocupacion__c,
                Barrio_contacto__c,Zona_contacto__c,Ciudad_contacto__c,Hipoteca_a_favor_de__c,Medio_por_el_cual_conocio_a_Interactuar__c,DireccionLaboral__c,TelefonoLaboral__c
                FROM Contact 
                WHERE Id =: listaContactos];
    }
    
    public static List<Asociacion_cuenta_contacto__c> consultaAsociacionAval(List<Id> idsOportunidad){
        return [SELECT Id,Name,Cliente__c,Cliente__r.Consecutivo_Padre__c,Contacto__c,Oportunidad__c,Contacto__r.LastName,Contacto__r.Email,Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c,
                Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c,Contacto__r.Ciudad_contacto__r.Nombre_Departamento__c,Contacto__r.Ciudad_contacto__r.Codigo_Ciudad_OR__c,Contacto__r.Ciudad_contacto__r.Name,
                Contacto__r.Informacion_adicional_complemento_c__c,Contacto__r.Intercesion_contacto__c,Contacto__r.Letra_contacto_a__c,Contacto__r.Letra_contacto_b__c,Contacto__r.Numero_contacto_a__c,
                Contacto__r.Numero_contacto_b__c,Contacto__r.Punto_cardinal_contacto_a__c,Contacto__r.Punto_cardinal_contacto_b__c,Contacto__r.Ruralidad_domicilio_contacto__c,Contacto__r.Empresa_donde_labora__c,
                Contacto__r.Via_contacto__c,Contacto__r.Birthdate,Contacto__r.Genero__c,Contacto__r.Indicativo_contacto__c,Contacto__r.Medio_por_el_cual_conocio_a_Interactuar__c,Contacto__r.Movil_contacto__c,
                Contacto__r.Nivel_de_escolaridad__c,Contacto__r.Name,Contacto__r.Numero_de_identificacion__c,Contacto__r.Telefono_contacto__c,Contacto__r.Tipo_de_identificacion__c,Contacto__r.Estado_civil__c,
                Contacto__r.Personas_a_cargo__c,Contacto__r.Tipo_de_vivienda__c,Contacto__r.Cabeza_de_familia__c,Contacto__r.Estrato_contacto__c,Contacto__r.Valor_comercial_del_Bien__c,Contacto__r.Otros_ingresos_familiares__c,
                Contacto__r.Ingresos_conyuge__c,Contacto__r.Pais_contacto__c,Contacto__r.Total_ingresos__c,Contacto__r.Sueldo_Honorario__c,Contacto__r.Otros_egresos_familiares__c,Contacto__r.Egresos_conyuge__c,
                Contacto__r.Total_egresos__c,Contacto__r.Hogar__c,Contacto__r.FirstName,Contacto__r.Zona_contacto__r.Codigo_Registro_Zona__c,Contacto__r.Zona_contacto__r.Name,Contacto__r.Phone,
                Contacto__r.DireccionLaboral__c,Contacto__r.TelefonoLaboral__c,Contacto__r.Ocupacion__c,Contacto__r.Nombres_y_apellidos_Referencia__c,Contacto__r.Nombres_y_apellidos_Ref2__c,Contacto__r.Nombres_y_apellidos_Ref3__c,
                Contacto__r.Nombres_y_apellidos_Ref4__c,Contacto__r.Nombres_y_apellidos_Ref5__c,Contacto__r.Telefono_Referencia__c,Contacto__r.Telefono_Ref2__c,Contacto__r.Telefono_Ref3__c,Contacto__r.Telefono_Ref4__c,
                Contacto__r.Telefono_Ref5__c,Contacto__r.Tipo_Referencia_1__c,Contacto__r.Tipo_Referencia_2__c,Contacto__r.Tipo_Referencia_3__c,Contacto__r.Tipo_Referencia_4__c,Contacto__r.Tipo_Referencia_5__c,
                Contacto__r.CiudadRef1codOR__c,Contacto__r.CiudadRef2codOR__c,Contacto__r.CiudadRef3codOR__c,Contacto__r.CiudadRef4codOR__c,Contacto__r.CiudadRef5codOR__c,RepresentanteLegal__c,Contacto__r.Lugar_expedicion__c,
                Cliente__r.Name,Cliente__r.Numero_de_identificacion__c,Oportunidad__r.Identificador_proceso__c,Contacto__r.Segundo_Apellido__c,Contacto__r.MiddleName,Cliente__r.RecordType.DeveloperName,
                Oportunidad__r.RecordType.DeveloperName,Contacto__r.Vista_direccion_contacto__c,Contacto__r.Departamento_contacto__c,/*Contacto__r.Ciudad_empresa__c,*/
                /*Contacto__r.Ciudad_empresa__r.Codigo_DANE_Ciudad__c,*/Contacto__r.Ciudad_contacto__r.Codigo_DANE_Ciudad__c,Contacto__r.Barrio_contacto__r.Name,Cliente__r.Tipo_de_identificacion__c,Cliente__r.LastName,
                Cliente__r.Segundo_Apellido__c,Cliente__r.Genero__pc,Cliente__r.Lugar_expedicion__c,Cliente__r.Fecha_de_nacimiento__c,Cliente__r.Pais_empresa__c,Cliente__r.Vista_direccion_empresa__c,
                Cliente__r.Departamento_empresa__c,Cliente__r.Barrio_empresa__r.Name,Cliente__r.Telefono_empresa__c,Cliente__r.Movil_empresa__c,Cliente__r.PersonEmail,Cliente__r.Empresa_donde_labora__c,
                Cliente__r.DireccionLaboral__c,Cliente__r.TelefonoLaboral__c,Cliente__r.FirstName,Cliente__r.MiddleName,Cliente__r.Ciudad_empresa__r.Name,Cliente__r.Nacionalidad__c,Cliente__r.Lugar_de_nacimiento__c,
                Cliente__r.Peso_kg__c,Cliente__r.Estatura_cm__c,Cliente__r.Estado_civil__pc,Cliente__r.AnnualRevenue,Cliente__r.Empleos_a_generar__c,Cliente__r.Total_egresos__c, Cliente__r.Total_ingresos__c,
                Contacto__r.Cargo_laboral__c,Contacto__r.Nombres_Completo_Conyuge__c,Contacto__r.Numero_de_identificaci_n_conyuge__c,Contacto__r.Ocupacion_Conyuge__c,
                Contacto__r.Alquiler__c,Contacto__r.Educacion__c,Contacto__r.Prestamos__c,Contacto__r.Ingreso_disponible_total__c
                FROM Asociacion_cuenta_contacto__c 
                WHERE Oportunidad__c =: idsOportunidad.get(0)];
    }
    
    public static List<Asociacion_cuenta_contacto__c> consultaAsociacionAvales(List<Id> idsOportunidad){
        return [SELECT Id,Name,Cliente__c,Cliente__r.Consecutivo_Padre__c,Contacto__c,Oportunidad__c,Contacto__r.LastName,Contacto__r.Email,Contacto__r.Barrio_contacto__r.Codigo_Registro_Barrio__c,
                Contacto__r.Ciudad_contacto__r.Codigo_Departamento_OR__c,Contacto__r.Ciudad_contacto__r.Nombre_Departamento__c,Contacto__r.Ciudad_contacto__r.Codigo_Ciudad_OR__c,Contacto__r.Ciudad_contacto__r.Name,
                Contacto__r.Informacion_adicional_complemento_c__c,Contacto__r.Intercesion_contacto__c,Contacto__r.Letra_contacto_a__c,Contacto__r.Letra_contacto_b__c,Contacto__r.Numero_contacto_a__c,
                Contacto__r.Numero_contacto_b__c,Contacto__r.Punto_cardinal_contacto_a__c,Contacto__r.Punto_cardinal_contacto_b__c,Contacto__r.Ruralidad_domicilio_contacto__c,
                Contacto__r.Via_contacto__c,Contacto__r.Birthdate,Contacto__r.Genero__c,Contacto__r.Indicativo_contacto__c,Contacto__r.Medio_por_el_cual_conocio_a_Interactuar__c,Contacto__r.Movil_contacto__c,
                Contacto__r.Nivel_de_escolaridad__c,Contacto__r.Name,Contacto__r.Numero_de_identificacion__c,Contacto__r.Telefono_contacto__c,Contacto__r.Tipo_de_identificacion__c,
                Contacto__r.Estado_civil__c,Contacto__r.Personas_a_cargo__c,Contacto__r.Tipo_de_vivienda__c,Contacto__r.Cabeza_de_familia__c,Contacto__r.Estrato_contacto__c,Contacto__r.Valor_comercial_del_Bien__c,
                Contacto__r.Otros_ingresos_familiares__c,Contacto__r.Ingresos_conyuge__c,Contacto__r.Total_ingresos__c,Contacto__r.Sueldo_Honorario__c,Contacto__r.Otros_egresos_familiares__c,Contacto__r.Egresos_conyuge__c,
                Contacto__r.Total_egresos__c,Contacto__r.Hogar__c,Contacto__r.FirstName,Contacto__r.Zona_contacto__r.Codigo_Registro_Zona__c,Contacto__r.Zona_contacto__r.Name,Contacto__r.DireccionLaboral__c,
                Contacto__r.TelefonoLaboral__c,Contacto__r.Ocupacion__c,Contacto__r.Nombres_y_apellidos_Referencia__c,Contacto__r.Nombres_y_apellidos_Ref2__c,Contacto__r.Nombres_y_apellidos_Ref3__c,
                Contacto__r.Nombres_y_apellidos_Ref4__c,Contacto__r.Nombres_y_apellidos_Ref5__c,Contacto__r.Telefono_Referencia__c,Contacto__r.Telefono_Ref2__c,Contacto__r.Telefono_Ref3__c,Contacto__r.Telefono_Ref4__c,
                Contacto__r.Telefono_Ref5__c,Contacto__r.Tipo_Referencia_1__c,Contacto__r.Tipo_Referencia_2__c,Contacto__r.Tipo_Referencia_3__c,Contacto__r.Tipo_Referencia_4__c,Contacto__r.Tipo_Referencia_5__c,
                Contacto__r.CiudadRef1codOR__c,Contacto__r.CiudadRef2codOR__c,Contacto__r.CiudadRef3codOR__c,Contacto__r.CiudadRef4codOR__c,Contacto__r.CiudadRef5codOR__c,RepresentanteLegal__c,Cliente__r.Name,
                Cliente__r.Numero_de_identificacion__c,Oportunidad__r.Identificador_proceso__c,Contacto__r.Segundo_Apellido__c,Contacto__r.MiddleName,Cliente__r.RecordType.DeveloperName,
                Oportunidad__r.RecordType.DeveloperName,Contacto__r.Pais_contacto__c,Contacto__r.Vista_direccion_contacto__c,Contacto__r.Departamento_contacto__c,Contacto__r.Barrio_contacto__r.Name,
                Contacto__r.Empresa_donde_labora__c,Cliente__r.Tipo_de_identificacion__c,Cliente__r.LastName,Cliente__r.Segundo_Apellido__c,Cliente__r.Genero__pc,Cliente__r.Lugar_expedicion__c,Cliente__r.Fecha_de_nacimiento__c,
                Cliente__r.Pais_empresa__c,Cliente__r.Vista_direccion_empresa__c,Cliente__r.Departamento_empresa__c,Cliente__r.Barrio_empresa__r.Name,Cliente__r.Telefono_empresa__c,Cliente__r.Movil_empresa__c,
                Cliente__r.PersonEmail,Cliente__r.Empresa_donde_labora__c,Cliente__r.DireccionLaboral__c,Cliente__r.TelefonoLaboral__c,Cliente__r.Nacionalidad__c,Cliente__r.Lugar_de_nacimiento__c,Cliente__r.Peso_kg__c,
                Cliente__r.Estatura_cm__c,Cliente__r.AnnualRevenue,Cliente__r.Empleos_a_generar__c,Cliente__r.Total_egresos__c, Cliente__r.Total_ingresos__c
                FROM Asociacion_cuenta_contacto__c 
                WHERE Oportunidad__c =: idsOportunidad ];
    }
    
    public static List<Asociacion_cuenta_contacto__c> consultaConsecutivoPadre(List<Id> idsContacto){
        return [SELECT Id,Contacto__c,Cliente__c,Cliente__r.Consecutivo_Padre__c,RepresentanteLegal__c 
                FROM Asociacion_cuenta_contacto__c 
                WHERE Contacto__c =: idsContacto.get(0)];
    }
    
    public static List<Task> consultaconsultaTareas(List<Id> idsTareas){
        return [SELECT Id,WhatId,CreatedDate,Fecha_acuerdo_de_pago__c,Tipo_de_gestion__c,Tipo_de_contacto__c,Gestion_efectiva__c,Pago_minimo__c,ActivityDate,Description,Asignado_a__r.Codigo_de_Empleado__c
                FROM Task 
                WHERE Id IN: idsTareas];
    }
    
    public static List<Asset> consultaconsultaActivos(List<Id> idsActivos){
        return [SELECT Id,Product2Id,Product2.Family,Identificador_Radicado__c,AccountId,Account.Tipo_de_identificacion__c,Numero_de_credito__c,Account.Numero_de_identificacion__c
                FROM Asset 
                WHERE Id IN: idsActivos];
    }
}
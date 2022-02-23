/**
**************************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de sincronizacion barrios

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            1.0   10-Jun-2019  Rafael Cardona (RC)           Creacion servicio sincronizacion barrios
/*
***************************************************************************************************************************
**/
@RestResource(urlMapping='/SincronizacionBarrios/*')
global with sharing class IT_SincronizacionBarrios {
    public static List<Barrio__c> barrio = new List<Barrio__c>();
    public static Set<String> setIdBarrio = new Set<String>();
    /******************************************************************************************
    *Author:  Rafael Cardona
    *Function: Se deserealizan los datos
    *Date: 10-6-2020
    ******************************************************************************************/
    @HttpPost
    global static String doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String strJSONContent = request.requestBody != null ? request.requestBody.toString().trim() : '';
        SincronizacionBarrios deserealizado  = (SincronizacionBarrios)JSON.deserializeStrict(strJSONContent, SincronizacionBarrios.class); 
        System.debug('deserealizado::' + deserealizado);
        recibeDatos(deserealizado);
        return 'OK';
    }
    /*********************************************************************
    *Author:  Rafael Cardona
    *Function: Administra datos
    *Date: 10-6-2020
    *********************************************************************/
    public static void recibeDatos( SincronizacionBarrios deserealizado ){
        Set<String> barrios = new Set<String>();
        Set<String> zonas   = new Set<String>();
        List<String> trip  = new List<String>();
        List<String> dup   = new List<String>();
        Map<String,Localizaciones> tripleta = new Map<String,Localizaciones>();
        Map<String,Localizaciones>    dupla = new Map<String,Localizaciones>();
        
        for(Localizaciones bar: deserealizado.localizaciones){ 
            trip.add(bar.tripletaCodigosORA);
            tripleta.put(bar.tripletaCodigosORA,bar);
            dup.add(bar.codigoCiudadORA+'-'+bar.codigoZonaORA);
            dupla.put(bar.codigoCiudadORA+'-'+bar.codigoZonaORA,bar);
        }
        
        creacionZonasBarrios( deserealizado, tripleta , dupla , trip, dup);
    }  
    /*********************************************************************
    *Author:  Rafael Cardona
    *Function: Administra datos
    *Date: 10-6-2020
	*********************************************************************/
    public static void creacionZonasBarrios(SincronizacionBarrios deserealizado, Map<String,Localizaciones> tripleta, Map<String,Localizaciones> dupla,List<String> trip, List<String> dup){                                  
        creacionZonas( dupla, dup );
        creacionBarrios( tripleta, trip );
    }

    public static  void creacionZonas( Map<String,Localizaciones> dupla, List<String> dup ){
        Set<String> zonasExistentes = new Set<String>();
        Map<String,Id> zonaRetorno = new Map<String,Id>();
        List<Zona__c> zonasCrear = new List<Zona__c>();
        for( Zona__c var:  [SELECT id,Dupla_Codigo_OR__c  FROM Zona__c WHERE Dupla_Codigo_OR__c =: dup ] ){
            zonasExistentes.add(var.Dupla_Codigo_OR__c);
        }
        for( String viene: dup){
            if( !zonasExistentes.contains(viene) ){ Zona__c zon = new Zona__c(); zon.Ciudad__c = dupla.get(viene).codigoCiudadSF; zon.Name = dupla.get(viene).nombreZona; zon.Codigo_Registro_Zona__c = dupla.get(viene).codigoZonaORA;                 zon.Vigente__c              = true;                 zonasCrear.add(zon);
            }
        }
        if( zonasCrear.size() > 0 ){             insert zonasCrear;
        }
    }

    public static  void creacionBarrios( Map<String,Localizaciones> tripleta, List<String> trip ){
        Set<String> barriosExistentes   = new Set<String>();
        List<Barrio__c> barriosCrear    = new List<Barrio__c>();
        List<String> zonasSf            = new List<String>();
        Map<String,Id> zonaSFexistentes = new Map<String,Id>();
        
        for( Barrio__c var:  [SELECT Id, Tripleta_Codigo_OR__c FROM Barrio__c WHERE  Tripleta_Codigo_OR__c =: trip ] ){             barriosExistentes.add(var.Tripleta_Codigo_OR__c);
        }
        for( String viene: trip){
            if( !barriosExistentes.contains(viene) ){
                System.debug('viene: '+ viene);
                zonasSf.add(tripleta.get(viene).codigoCiudadORA+'-'+tripleta.get(viene).codigoZonaORA);
            }
        }
        for( Zona__c var:  [SELECT Id, Dupla_Codigo_OR__c  FROM Zona__c WHERE Dupla_Codigo_OR__c =: zonasSf ] ){
            zonaSFexistentes.put(var.Dupla_Codigo_OR__c,var.Id);
        }
        for( String viene: trip){
            if( !barriosExistentes.contains(viene) ){
                Barrio__c bar = new Barrio__c();
                bar.Zona__c                     = zonaSFexistentes.get( tripleta.get(viene).codigoCiudadORA +'-'+tripleta.get(viene).codigoZonaORA );
                bar.Name                        = tripleta.get(viene).nombreBarrio;
                bar.Codigo_Registro_Barrio__c   = tripleta.get(viene).codigoBarrioORA;
                bar.Vigente__c                  = true;
                barriosCrear.add(bar);
            }
        }
        if( barriosCrear.size() > 0 ){
            insert barriosCrear;
        }
        actualizaBarrios( tripleta, trip );
    }
    
    public static void actualizaBarrios( Map<String,Localizaciones> tripleta, List<String> trip ){
        Map<String, Id> barriosExistentes   = new Map<String,Id>();
        
        for( Barrio__c var:  [SELECT Id, Tripleta_Codigo_OR__c FROM Barrio__c WHERE  Tripleta_Codigo_OR__c =: trip ] ){             barriosExistentes.put(var.Tripleta_Codigo_OR__c,var.Id);
        }
        
        List<Barrio__c> lstBarriosActualizar = new List<Barrio__c>();
        try{
            for(String viene: trip){
                Barrio__c ba = new Barrio__c();
                ba.Id        					= barriosExistentes.get(tripleta.get(viene).tripletaCodigosORA);
                ba.Name                      	= tripleta.get(viene).nombreBarrio;
                ba.Codigo_Registro_Barrio__c 	= tripleta.get(viene).codigoBarrioORA;
                ba.Vigente__c   				= true;
                lstBarriosActualizar.add(ba);
                System.debug('lstBarriosActualizar' + lstBarriosActualizar);
            }
            if( lstBarriosActualizar.size() > 0){
                update lstBarriosActualizar;
            }
        }catch(DmlException e){
            System.debug('Error en la actualizacion del registro: '+ e.getStackTraceString());
        }
    }    

    public class SincronizacionBarrios{
        public Encabezado encabezado;
        public List<Localizaciones> localizaciones = new List<Localizaciones>(); }   public class Encabezado{         public String integracion  {get;set;}         public String fecha        {get;set;}         public String origen       {get;set;}         public String destino      {get;set;}
    } 
    public class Localizaciones{         public String codigoBarrioSF      	{get;set;}         public String codigoBarrioORA      	{get;set;}         public String nombreBarrio        	{get;set;}         public String codigoZonaSF  	    {get;set;}         public String codigoZonaORA			{get;set;}         public String nombreZona			{get;set;}         public String codigoCiudadSF		{get;set;}         public String codigoCiudadORA		{get;set;}         public String nombreCiudad			{get;set;}         public String tripletaCodigosORA	{get;set;}         public String accion              	{get;set;}
    }
}
/**
**************************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class declared as REST resource para exponer servicio de respuesta de Cliente

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   -------------------------------------------------------------
*            1.0   10-Jul-2019  Rafael Cardona (RC)           Creacion Clase.
/*
***************************************************************************************************************************
**/
@isTest(SeeAllData=true)
public with sharing class IT_SincronizacionBarrios_Test {

    @isTest	static void test1(){
        Test.StartTest();
        List<Barrio__c> lstBarrios = new List<Barrio__c>();
        List<Zona__c> lstZonas = new List<Zona__c>();
        
        // ### Ciudad #1
        Poblacion__c ciudadBogota = new Poblacion__c();
        ciudadBogota.Nombre_Pais__c = 'Colombia';
        ciudadBogota.Nombre_Departamento__c = 'Bogota';
        ciudadBogota.Name = 'Bogota';
        ciudadBogota.Vigente__c = true;
        ciudadBogota.Codigo_ISO__c = '10';
        ciudadBogota.Codigo_DANE_Ciudad__c = '20';
        ciudadBogota.Codigo_DANE_Departamento__c = '30';
        ciudadBogota.Codigo_Ciudad_OR__c = '01';
        ciudadBogota.Codigo_DANE_Ciudad__c = '1001';
        insert ciudadBogota;

        // ### Zona # 1
        Zona__c zonaSanIsidro = new Zona__c();
        zonaSanIsidro.Name = 'Zona Bogotá';
        zonaSanIsidro.Vigente__c = true;
        zonaSanIsidro.Ciudad__c = ciudadBogota.Id;
        zonaSanIsidro.Codigo_Registro_Zona__c = 'X1';
        insert zonaSanIsidro;
        
        // ### Barrio # 1
        Barrio__c barrioSerafina = new Barrio__c();
        barrioSerafina.Zona__c = zonaSanIsidro.Id;
        barrioSerafina.Vigente__c = true;
        barrioSerafina.Name  = 'Barrio Bogotá';
        barrioSerafina.Codigo_Registro_Barrio__c = 'X11';
        insert barrioSerafina;
        
		// ### Solicitud WEB Service
        IT_SincronizacionBarrios obj2 = new IT_SincronizacionBarrios();
        
		String myJSON = jSONinvoke(ciudadBogota, zonaSanIsidro, barrioSerafina);

        RestRequest request = new RestRequest();
        request.requestUri ='https://interactuar--qzcalidad.lightning.force.com/services/apexrest/SincronizacionBarrios';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);		
        RestContext.request = request;
        IT_SincronizacionBarrios.doPost(); 
        IT_SincronizacionBarrios.SincronizacionBarrios wraper1 = new IT_SincronizacionBarrios.SincronizacionBarrios(); 
        wraper1.encabezado = new IT_SincronizacionBarrios.Encabezado();

        Test.StopTest();
    }
    
        public static String jSONinvoke(Poblacion__c ciudadBogota, Zona__c zonaSanIsidro, Barrio__c barrioSerafina){
        String json = 
        '{'+
            '"encabezado": '+
                '{'+
                '"integracion": "Sincronizar Barrios",'+
                '"fecha": "2020-06-20 09:18:28",'+
                '"origen": "ORACLE",'+
                '"destino": "SALESFORCE"'+
                '},'+
            '"localizaciones":['+
                '{'+
                '"codigoBarrioSF": "",'+
                '"codigoBarrioORA": "11",'+
                '"nombreBarrio": "Barrio Bogota X",'+
                '"codigoZonaSF" : "'+zonaSanIsidro.Id+'", '+
                '"codigoZonaORA": "1",'+
                '"nombreZona": "Zona Bogotá",'+
                '"codigoCiudadSF": "'+ciudadBogota.Id+'",'+
                '"codigoCiudadORA": "100",'+
                '"nombreCiudad": "Bogotá",'+
                '"tripletaCodigosORA": "100-X1-X11",'+
                '"accion": "2"'+           
            '}]}';
        return json;
    }
}
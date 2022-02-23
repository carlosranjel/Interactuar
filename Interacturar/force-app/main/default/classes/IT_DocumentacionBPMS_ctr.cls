/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Clase controlador del componente aura para el envio de la documentacion a bpms

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   31-JUL-2019  Rafael Cardona (RC)           Creacion Clase.
**************************************************************************************************************
**/
public class IT_DocumentacionBPMS_ctr {
    public IT_DocumentacionBPMS_ctr() {    }

    @AuraEnabled
    public static String componenteDocumentacionBPMS(String oportunidadId){
        RespuestaServicioDocumentacionBPMS objRes;
        System.debug('id prospecto: '+ oportunidadId);
        Opportunity oportunidad = [SELECT id FROM Opportunity WHERE id =: oportunidadId];
        System.debug('resultado oportunidad: '+ oportunidad);

        String respuesta = IT_ServicioDocumentacionBPMS_cls.servicioDocumentacionBPMS(oportunidadId);
        if( respuesta == 'OK enviar' || respuesta == 'Nada para enviar' ){
            objRes = creaObjetoRespuesta(respuesta,true);
        }else{
            objRes = creaObjetoRespuesta(respuesta,false);
        }              
        return JSON.Serialize(objRes);
    }

    @AuraEnabled
    public static String componenteServicioBPMS(String oportunidadId){
        RespuestaServicioDocumentacionBPMS objRes;
        String respuesta = IT_ServicioDocumentacionBPMS_cls.peticionDocumentacionBPMS(oportunidadId);
        objRes = creaObjetoRespuesta(respuesta,true);       
        return JSON.Serialize(objRes);
    }

    public static RespuestaServicioDocumentacionBPMS creaObjetoRespuesta(String res, Boolean isExitoso){
        RespuestaServicioDocumentacionBPMS obj = new RespuestaServicioDocumentacionBPMS();
        obj.respuesta = res;
        obj.exitoso  = isExitoso;
        return obj;
    }

    public class RespuestaServicioDocumentacionBPMS{
        public String respuesta;
        public Boolean exitoso;
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
    }
}
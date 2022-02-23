/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Álvaro Ortega
* @proyecto         Interactuar
* @descripcion      Trigger de Contacto
* @test             IT_TriggerContact_test
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
             1.0   13-OCT-2020   Álvaro Ortega (AO)           Desencadenador de contacto
**************************************************************************************************************
**/
public class IT_TriggerContactHandler_cls {
    
    public static void afterInsert(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont){
        IT_TriggerContactHelper_cls.beneficiariosInsert(mapNewCont, lstNewCont);
        IT_TriggerContactHelper_cls.validateRepLegal(mapNewCont, lstNewCont, lstNewCont, True);
        
    }
    public static void beforeInsert(Map<Id, Contact> mapNewCont, List<Contact> lstNewCont){
        IT_TriggerContactHelper_cls.insertarNombresBeneficiarios(mapNewCont, lstNewCont);
        
    }
    public static void afterUpdate(Map<Id, Contact> mapNewCont, List<Contact> lstOldCont, List<Contact> lstNewCont){
        //IT_TriggerContactHelper_cls.insertarNombresBeneficiarios(mapNewCont, lstNewCont);
        IT_TriggerContactHelper_cls.validaCamposBeneficiarios(mapNewCont, lstNewCont);
        IT_TriggerContactHelper_cls.validateRepLegal(mapNewCont, lstNewCont, lstOldCont, False);
        
    }
    public static void afterDelete(List<Contact> lstOldCont){
        IT_TriggerContactHelper_cls.beneficiariosDelete(lstOldCont);
    }

}
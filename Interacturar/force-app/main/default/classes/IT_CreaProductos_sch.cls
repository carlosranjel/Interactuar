/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Rafael Cardona
* @projecto         Interactuar
* @descripcion      Class scheduable para programar la tarea que crea los productos x cotizacion off line

* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   31-Jul-2019  Rafael Cardona (RC)           Creacion Clase.
/*
**************************************************************************************************************
**/
global class IT_CreaProductos_sch implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		IT_CreaProductos_bch b = new IT_CreaProductos_bch();
		database.executebatch(b);
	}
}
/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Alejandro Gómez
*  Fecha:               Junio 12 de 2019
*  Decripción:          Clase de test de la clase Convert_Lead
*  @version:            1.0
* ===================================================================================================================================
**/

@isTest(seeAllData=true)
private class Convert_Lead_test
{
    @isTest(seeAllData=false)
    static void itShould()
    {
        Test.startTest();
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        Convert_Lead conLead = new Convert_Lead();
        Convert_Lead.convertleadobject(new list<string>{dataFactory.newLead().id});
        Test.stopTest();
    }
}
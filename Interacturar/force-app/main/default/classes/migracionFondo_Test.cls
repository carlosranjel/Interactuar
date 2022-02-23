@isTest(seeAllData=true)
public class migracionFondo_Test {
 @isTest static void test_1()
 {
     Test.startTest();
     migracionFondo.migrarCampo();
     Test.stopTest();
 }
}
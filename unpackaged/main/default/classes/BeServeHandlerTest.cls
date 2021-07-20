/**
 * Created by fabiankramer on 12.07.21.
 */

@IsTest
public with sharing class BeServeHandlerTest {

    @IsTest
    public static void testInformationRequest(){
        BeServe__c customSetting = new BeServe__c();
        customSetting.Name = 'name';
        customSetting.endPoint__c = 'http://google.de';
        customSetting.Kid__c = '12345';
        customSetting.IdString__c = '123456789012';
        insert customSetting;

        Account a1 =  new Account(
                Name = 'Dummy Account - Case 999',
                CL_AccountIDInSF2__c = '0011r00002EdYJ0AAN',
                CL_Firmenstatus__c = 'Debitor Kunde',
                CL_CS1InBearbeitung__c = true,
                CL_CS2InBearbeitung__c = false,
                CL_ZurBearbeitungGesperrt__c = false,
                beServe__BIPID__c = '12346',
                ShippingPostalCode = '12345',
                BillingPostalCode = '12345',
                BillingCountry = 'Deutschland',
                LKM_EmailZentrale__c = 'fabian.kramer@fk-sd.de',
                Phone = '+491754101967',
                RecordTypeId = '0121r000000xCyCAAU',
                CL_GeplAuftragsvolumenVG1__c = 999999,
                CL_DrucksteuerungSMVBelegeVG1__c = 'ohne Gültigkeit',
                CL_VertriebsgesellschaftVG1__c = 'DSM Decaux GmbH',
                CL_ZahlungskonditionenVG1__c = '14 Tage ab Re.dat. 2% Skto., 45 Tage ohne Abzug'
        );
        insert a1;

        Test.startTest();
        List<BeServeHandler.FlowInputs> fiList = new List<BeServeHandler.FlowInputs>();
        BeServeHandler.FlowInputs fi = new BeServeHandler.FlowInputs ();
        fi.recordId = [SELECT Id FROM Account WHERE Name = 'Dummy Account - Case 999' LIMIT 1][0]?.Id;
        fi.queryTyp = 'information';
        fiList.add(fi);
        System.debug(BeServeHandler.getInformation(fiList));
        Test.stopTest();
    }

}
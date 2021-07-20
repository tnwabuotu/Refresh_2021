/**
 * Created by fabiankramer on 12.07.21.
 */

public with sharing class BeServeHandler {

    public class FlowInputs {
        @InvocableVariable
        public String recordId;
        @InvocableVariable
        public String queryTyp;
    }

    public class FlowOutputs {
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String bipid;
        @InvocableVariable
        public String crf;
        @InvocableVariable
        public String zcrf;
        @InvocableVariable
        public String firmenName_zeile1;
        @InvocableVariable
        public String firmenName_zeile2;
        @InvocableVariable
        public String firmenName_zeile3;
        @InvocableVariable
        public String firmenName_gesamt;
        @InvocableVariable
        public String strasse_gesamt;
        @InvocableVariable
        public String strasse;
        @InvocableVariable
        public String hausNr;
        @InvocableVariable
        public String hausNrZus;
        @InvocableVariable
        public String lkz;
        @InvocableVariable
        public String plz;
        @InvocableVariable
        public String ort;
        @InvocableVariable
        public String umsatzSteuer_id;
        @InvocableVariable
        public String steuerNummer;
        @InvocableVariable
        public String status_id;
        @InvocableVariable
        public String status_id_name;
        @InvocableVariable
        public String telefon_vorwahl;
        @InvocableVariable
        public String telefon_rufnummer;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String url;
        @InvocableVariable
        public String gruendungs_datum;
    }

    @InvocableMethod(Label='BeServe - Information Request' Description='BeServe - Information Request' Category='Interface')
    public static List<FlowOutputs> getInformation(List<FlowInputs> fiList) {
        List<FlowOutputs> foList = new List<FlowOutputs>();
        String bipidId = [SELECT beServe__BIPID__c FROM Account WHERE Id =:fiList[0].recordId LIMIT 1][0]?.beServe__BIPID__c;
        HttpResponse response = informationRequest(bipidId, fiList[0]?.queryTyp);
        if (response.getStatus() == 'OK') {
            foList.add(parseResponse(response.getBody()));
        }
        return foList;
    }

    public static HttpResponse informationRequest(String bipidId, String queryTyp) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        BeServe__c customSetting = BeServe__c.getValues('name');
        String kid = customSetting?.Kid__c;
        String idString = customSetting?.IdString__c;
        request.setEndpoint(customSetting.endPoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml; charset=character encoding');
        request.setBody(generateBody(bipidId, queryTyp, kid, idString));
        if (!Test.isRunningTest()) {
            return http.send(request);
        } else {
            return setMock();
        }

    }

    public static String generateBody(String bipidId, String queryTyp, String kid, String idString) {
        String returnString = null;
        if (queryTyp == 'information' && bipidId != null && kid != null && idString != null) {
            returnString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="https://xbeserve.bedirect.de/soap/3">\n' +
                    '   <soapenv:Header/>\n' +
                    '   <soapenv:Body>\n' +
                    '      <ns:information>\n' +
                    '         <KID>' + kid + '</KID>\n' +
                    '         <IDSTRING>' + idString + '</IDSTRING>\n' +
                    '         <BIPID>' + bipidId + '</BIPID>\n' +
                    '      </ns:information>\n' +
                    '   </soapenv:Body>\n' +
                    '</soapenv:Envelope>';
        }
        return returnString;
    }

    public static FlowOutputs parseResponse(String response) {
        System.debug(response);
        FlowOutputs fo = new FlowOutputs();
        fo.status = response?.substringBetween('<STATUS>', '</STATUS>');
        if (fo.status == 'FOUND') {
            fo.bipid = response?.substringBetween('<BIPID>', '</BIPID>');
            fo.crf = response?.substringBetween('<CRF>', '</CRF>');
            fo.zcrf = response?.substringBetween('<ZCRF>', '</ZCRF>');
            fo.firmenName_zeile1 = response?.substringBetween('<FIRMENNAMENSZEILE1>', '</FIRMENNAMENSZEILE1>');
            fo.firmenName_zeile2 = response?.substringBetween('<FIRMENNAMENSZEILE2>', '</FIRMENNAMENSZEILE2>');
            fo.firmenName_zeile3 = response?.substringBetween('<FIRMENNAMENSZEILE3>', '</FIRMENNAMENSZEILE3>');
            fo.firmenName_gesamt = response?.substringBetween('<FIRMENNAME_GESAMT>', '</FIRMENNAME_GESAMT>');
            fo.strasse_gesamt = response?.substringBetween('<STRASSE_GESAMT>', '</STRASSE_GESAMT>');
            fo.strasse = response?.substringBetween('<STRASSE>', '</STRASSE>');
            fo.hausNr = response?.substringBetween('<HAUSNR>', '</HAUSNR>');
            fo.hausNrZus = response?.substringBetween('<HAUSNRZUS>', '</HAUSNRZUS>');
            fo.lkz = response?.substringBetween('<LKZ>', '</LKZ>');
            fo.plz = response?.substringBetween('<PLZ>', '</PLZ>');
            fo.ort = response?.substringBetween('<ORT>', '</ORT>');
            fo.status_id = response?.substringBetween('<STATUS_ID>', '</STATUS_ID>');
            fo.status_id_name = response?.substringBetween('<STATUS_ID_TEXT>', '</STATUS_ID_TEXT>');
            fo.telefon_vorwahl = response?.substringBetween('<TELEFON_VORWAHL>', '</TELEFON_VORWAHL>');
            fo.telefon_rufnummer = response?.substringBetween('<TELEFON_RUFNUMMER>', '</TELEFON_RUFNUMMER>');
            fo.email = response?.substringBetween('<EMAIL>', '</EMAIL>');
            fo.url = response?.substringBetween('<URL>', '</URL>');
            String gruendungsDatum = response?.substringBetween('<GRUENDUNGSDATUM>', '</GRUENDUNGSDATUM>');
            if (gruendungsDatum != null && gruendungsDatum != '' && gruendungsDatum != ' ') {
                fo.gruendungs_datum = gruendungsDatum?.substring(0, 4) + '-' + gruendungsDatum?.substring(5, 6) + '-' + gruendungsDatum?.substring(7, 8);
            }
            fo.steuerNummer = response?.substringBetween('<STEUERNUMMER>', '</STEUERNUMMER>');
            fo.umsatzSteuer_id = response?.substringBetween('<UMSATZSTEUER_ID>', '</UMSATZSTEUER_ID>');
        }
        return fo;
    }

    private static HttpResponse setMock() {
        HttpResponse response =  new HttpResponse();
        response.setStatus('OK');
        response.setBody('<?xml version="1.0" encoding="UTF-8"?>\n' +
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="https://xbeservetest.bedirect.de/soap/3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<SOAP-ENV:Body>' +
                '<ns1:informationResponse><return>' +
                '<STATUS>FOUND</STATUS>' +
                '<ANFRAGEID>001</ANFRAGEID>' +
                '<BIPID>123456</BIPID>' +
                '<CRF>123456</CRF>' +
                '<ZCRF></ZCRF>' +
                '<FIRMENNAMENSZEILE1>Test Company</FIRMENNAMENSZEILE1>' +
                '<FIRMENNAMENSZEILE2></FIRMENNAMENSZEILE2>' +
                '<FIRMENNAMENSZEILE3></FIRMENNAMENSZEILE3>' +
                '<FIRMENNAME_GESAMT>STest Company</FIRMENNAME_GESAMT>' +
                '<STRASSE_GESAMT>Test Straße 3</STRASSE_GESAMT>' +
                '<STRASSE>Test Straße </STRASSE>' +
                '<HAUSNR>3</HAUSNR>' +
                '<HAUSNRZUS></HAUSNRZUS>' +
                '<LKZ>DE</LKZ>'+
                '<<GRUENDUNGSDATUM>20210101</GRUENDUNGSDATUM>'
        );
        return response;
    }
}
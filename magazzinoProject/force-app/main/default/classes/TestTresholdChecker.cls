@isTest
public  class TestTresholdChecker {
    @TestSetup
    static void makeData(){
        List<Schema.Location> locations = new List<Schema.Location>();
        locations.add(new Schema.Location(Name = 'Magazzino Roma',locationType = 'Roma'));
        locations.add(new Schema.Location(Name = 'Magazzino Napoli',locationType = 'Napoli'));
        insert locations;
        SubType__c subT = new SubType__c(Name = 'mouse');
        insert subT;
        List<Item__c> items = new List<Item__c>();
        for(Schema.Location sc : locations){
            items.add(new Item__c(Name = 'Logitech5401',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subT.id));
            items.add(new Item__c(Name = 'RazerNew',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Razer',SubType__c = subT.id));
        }
        insert items;

    }

    @isTest
    static void testData(){
        list<Item__c> newList = [SELECT Name FROM Item__c];
        test.startTest();
        tresholdChecker.tresholdChecker(newList);
        test.stopTest();

    }


}
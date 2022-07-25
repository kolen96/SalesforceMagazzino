@isTest
public  class TestCountHandler {

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
            items.add(new Item__c(Name = 'Logitech5401',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subT.id,Count__c = 5));
            items.add(new Item__c(Name = 'RazerNew',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Razer',SubType__c = subT.id,Count__c = 15));
        }
        insert items;
        
    }

    @isTest
    static void testData(){
        List<Schema.Location> locations = [SELECT Name,locationType FROM Location];
        List<SubType__C> subTs = [SELECT Name FROM SubType__c];
        List<Item__c> items = [SELECT Name,Count__c,ThresholdLimit__c,Location__c FROM Item__c];
        List<Item__c> newItems = new List<Item__c>();
        for(Schema.Location sc : locations){
            if(sc.locationType == 'Roma'){
                items.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
                items.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
            }else{
                items.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
            }
        }

        test.startTest();

        CountHandler.checkItem(items);

        test.stopTest();



    }
   
}
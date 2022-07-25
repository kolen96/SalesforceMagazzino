@isTest
public  class TestTriggerItem {

    
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
            items.add(new Item__c(Name = 'Logitech5405',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subT.id));
            items.add(new Item__c(Name = 'RazerNew',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Razer',SubType__c = subT.id));
        }
        insert items;
       
        
    }

    @isTest
    static void testData(){
        List<Schema.Location> locations = [SELECT Name,locationType FROM Location];
        List<SubType__C> subTs = [SELECT Name FROM SubType__c];
        // List<Item__c> items = [SELECT Name,Count__c,ThresholdLimit__c,Location__c FROM Item__c];
        List<Item__c> newItems = new List<Item__c>();
        for(Schema.Location sc : locations){
            if(sc.locationType == 'Roma'){
                newItems.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
                newItems.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
            }else{
                newItems.add(new Item__c(Name = 'LEGION5',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subTs.get(0).id,Count__c = 5));
                newItems.add(new Item__c(Name = 'RazerNew',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Razer',SubType__c = subTs.get(0).id,Count__c = 5));
            }
        }

        test.startTest();

        Database.SaveResult[] srl = Database.insert(newItems,false);

        test.stopTest();

        Integer contatoriSuccessi = 0;
        integer contatoriSbagliati = 0;
        Boolean expectedExceptionThrown;

        
        for(Database.SaveResult sr :srl){
           
            if(sr.isSuccess()){
                contatoriSuccessi = contatoriSuccessi + 1;
                
            }
             else {
                
                contatoriSbagliati = contatoriSbagliati + 1;
                for(Database.Error er : sr.getErrors()){
                    expectedExceptionThrown = er.getMessage().contains('Oggetto presente già nel database, si prega di aggiornarne la quantità') ? true : false;
                }
            }
        }

        system.assertEquals(2, contatoriSbagliati);
        system.assertEquals(2, contatoriSuccessi);
        system.assertEquals(expectedExceptionThrown, true);


    }
   
}
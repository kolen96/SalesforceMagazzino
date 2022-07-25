@isTest
public class TestLowTresholdAlert {
  
    @TestSetup
    static void makeItem(){

        List<Schema.Location> locations = new List<Schema.Location>();
        locations.add(new Schema.Location(Name = 'Magazzino Roma',locationType = 'Roma'));
        locations.add(new Schema.Location(Name = 'Magazzino Napoli',locationType = 'Napoli'));
        insert locations;
        SubType__c subT = new SubType__c(Name = 'mouse');
        insert subT;

        List<Item__c> items = new List<Item__c>();
        for(Schema.Location sc : locations){
            if(sc.locationType == 'Roma'){
                items.add(new Item__c(Name = 'Logitech5401',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subT.id,Count__c = 5));
                items.add(new Item__c(Name = 'RazerNew',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Razer',SubType__c = subT.id,Count__c = 15));
            }else{
                items.add(new Item__c(Name = 'Logitech5401',Location__c = sc.id,ThresholdLimit__c = 10,Brand__c = 'Logitech',SubType__c = subT.id,Count__c = 5));
            }

        }
        insert items;

        UserRole ur = new UserRole(Name = 'Locations Manager');
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.runAs(usr){
            insert ur;
        }

        

        Profile p = [SELECT id FROM Profile WHERE Name = 'System Administrator'];
        List<User> us = new List<User>();

        us.add(new User (
                    firstName = 'Kolen',
                    lastName = 'Lleshi',
                    Profileid = p.id,
                    username = 'kolen96@email.com',
                    email = 'kolen96@email.com',
                    UserRoleId = ur.id,
                    City = 'Roma',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'Europe/Rome',
                    Alias = 'Klleshi'));

         us.add(new User (
                        firstName = 'Valerio',
                        lastName = 'Esposito',
                        Profileid = p.id,
                        username = 'valerio99@email.com',
                        email = 'valerio99@email.com',
                        UserRoleId = ur.id,
                        City = 'Napoli',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'Europe/Rome',
                        Alias = 'Vespo'));
               
        System.runAs(usr){
            insert us;
        }          

    }


    @isTest
    static void testData(){
        List<Item__c> newList = [SELECT Name,Location__r.LocationType FROM Item__c];
        Map<String,List<Item__c>> mapItem = new Map<String,List<item__C>>();

        for(Item__c item : newList){
            if(!mapItem.containsKey(item.Location__r.locationType)){
                List<Item__c> itemi = new List<Item__c>();
                itemi.add(item);
                mapItem.put(item.Location__r.locationType,itemi);
            }else{
                mapItem.get(item.Location__r.locationType).add(item);
            }
        }
        test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'nessuna email inviata');
        lowTresholdAlert.sendlowTresholdAlert(mapItem);
        System.assertEquals(3, Limits.getEmailInvocations(), 'le email sono state inviate');

    }
   


}
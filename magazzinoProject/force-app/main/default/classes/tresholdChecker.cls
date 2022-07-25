public with sharing class tresholdChecker {
  

    public static void tresholdChecker(list<item__c> newList ) {
        List<Item__c> items = [SELECT Name,Location__r.locationType, Location__r.name
                                FROM Item__c 
                                WHERE id =: newList 
                                AND (ThresholdStatus__c = :'RUNNING OUT' 
                                        OR ThresholdStatus__c = :'OUT OF STOCK') ];//get all items with threshold status running out or out of stock
        

        Map<String,List<Item__c>> mapItem = new Map<String,List<item__C>>();

        for (Item__c item : items) {

            if (!mapItem.containsKey(item.Location__r.locationType)) {//if the key does not exist, create it
                List<Item__c> itemi = new List<Item__c>();
                itemi.add(item);
                mapItem.put(item.Location__r.locationType,itemi);

            } else {                                                  //if the key exists, add the item to the list
                mapItem.get(item.Location__r.locationType).add(item);
            }
        }
        lowTresholdAlert.sendlowTresholdAlert(mapItem);//send the alert

        // System.debug(mapItem);
    }
}
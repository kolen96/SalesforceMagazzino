@RestResource(urlmapping = '/Items/*')
global with sharing class getItems {

    @HttpGet
    global static List<Item__c> retriveAllItems(){
        list<Item__c> listaItems = new List<Item__C>();
        listaItems = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, isActive__c, Category__c, Count__c, Item_Description__c, Location__r.Name, Location__r.LocationType, ThresholdLimit__c, Brand__c, SubType__r.Name, productId__c 
                      FROM Item__c ];
        return listaItems;
    } 

    @HttpPost
    global static Boolean eliminaItem(String productId, String localita, String venduto){
        list<Item__c> listaItems = new List<Item__C>();
        Decimal strToDec = decimal.valueOf(venduto);

        Item__c itemVenduto = [SELECT id, count__c, productId__c, Location__r.Name 
                               FROM Item__c 
                               WHERE productId__c =: productId 
                               AND Location__r.Name =: localita LIMIT 1];

        itemVenduto.count__c = itemVenduto.count__c - strToDec;
        listaItems.add(itemVenduto);
        
        Database.SaveResult[] srList = Database.update(listaItems, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated item. Item ID: ' + sr.getId());
                return true;
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Item fields that affected this error: ' + err.getFields());
                    return false;
                }
            }
        }
        return srList[0].isSuccess();
    }
}
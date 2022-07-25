public with sharing class homePageMagazzinoApex {
    @AuraEnabled
    public static boolean userRole(Id userId) {
        if([SELECT Userrole.name FROM User WHERE id = :userId LIMIT 1].Userrole.name == 'Lead Manager') {
            return true;
        } else {
            return false;
        }
    }
    @AuraEnabled
    public static  void updateCount(Id idItem, Integer n){
        Item__c item = [SELECT count__c FROM item__c WHERE id = :idItem LIMIT 1];
        item.count__c += n;
        Database.update(item,false);
    }
    @AuraEnabled
    public static list<Item__c> retriveItem(String strItemName, Id userId, String status, Integer offsetPage ) {

        Integer limitPage = 20;
        User Utonto = [SELECT city, Userrole.name FROM User WHERE id = :userId LIMIT 1]; 
        String outStock = '';
        String runningOut = '';
        String inStock = '';

        if (status.contains('1')) {
           outStock = 'OUT OF STOCK';
        }
        if (status.contains('2')) {
            runningOut = 'RUNNING OUT';
        }
        if (status.contains('3')){
            inStock = 'IN STOCK';
        }

        strItemName = '%' + strItemName + '%';
    
        list<Item__c> lstItem = new list<Item__c>();
        if(Utonto.Userrole.name == 'Lead Manager'){
                lstItem = [SELECT Name, Count__c, Category__c, SubType__r.Name,ThresholdLimit__c,Location__r.LocationType 
                                            FROM Item__c 
                                            WHERE Name LIKE :strItemName
                                            AND (ThresholdStatus__c = :outStock OR ThresholdStatus__c = :runningOut OR ThresholdStatus__c = :inStock) 
                                            LIMIT :limitPage 
                                            OFFSET :offsetPage];
        } else {
                lstItem = [SELECT Name, Count__c, Category__c, SubType__r.Name,ThresholdLimit__c,Location__r.LocationType 
                                            FROM Item__c 
                                            WHERE Name LIKE :strItemName 
                                            AND Location__r.LocationType = :Utonto.City
                                            AND (ThresholdStatus__c = :outStock OR ThresholdStatus__c = :runningOut OR ThresholdStatus__c = :inStock) 
                                            LIMIT :limitPage 
                                            OFFSET :offsetPage];
        }

        /*if( lstItem.isEmpty() && !(strItemName == '%%')) {
            throw new AuraHandledException('No Record Found..');
        }*/
        return lstItem; 
    }
}
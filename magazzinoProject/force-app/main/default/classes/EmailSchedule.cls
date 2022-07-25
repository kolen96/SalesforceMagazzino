Global class EmailSchedule implements Schedulable {
   
    Global void execute(SchedulableContext sc){
        List<Item__C> items = [SELECT Name,ThresholdLimit__c,Location__c,Count__c FROM Item__c ];
       tresholdChecker.tresholdChecker(items);

    }
    
}
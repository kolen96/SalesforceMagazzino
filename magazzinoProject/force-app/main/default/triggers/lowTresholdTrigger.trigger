trigger lowTresholdTrigger on item__c (after update) {
    tresholdChecker.tresholdChecker(trigger.new);

}
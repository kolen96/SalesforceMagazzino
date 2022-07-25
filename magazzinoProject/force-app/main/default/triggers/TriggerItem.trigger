trigger TriggerItem on Item__c (after insert,after update) {


    if(trigger.isAfter && trigger.isUpdate){
        System.debug('sono partito in after update');
        ItemCreateInfoHandler.makeInfo(trigger.oldMap,trigger.new);

    }

    switch on Trigger.operationType {
        when AFTER_INSERT{
            TriggerItemHandler.createRefreshRecordPlatformEvents(Trigger.new);
        }when AFTER_UPDATE{
            
            TriggerItemHandler.createRefreshRecordPlatformEvents(Trigger.new);
        }
    }

}
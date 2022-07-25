public with sharing class TriggerItemHandler {
    public static void createRefreshRecordPlatformEvents(List<Item__C> newItemList){
        
        List<Refresh_Item_Event__e> refreshRecordEventList = new List<Refresh_Item_Event__e>();
        Refresh_Item_Event__e refreshEventObj = new Refresh_Item_Event__e();
        
        if(newItemList == null || newItemList.isEmpty())
            return;
                     
        for (Item__c item : newItemList) {
            refreshEventObj = new Refresh_Item_Event__e();
            refreshEventObj.Record_Id__c = item.Id;
            refreshEventObj.User_Id__c = UserInfo.getUserId();
            
            refreshRecordEventList.add(refreshEventObj);
        }
        
        try{
            if(refreshRecordEventList <> null && !refreshRecordEventList.isEmpty())
                EventBus.publish(refreshRecordEventList);
        }catch(Exception e){
            System.debug('Exception during publishing of refresh platform events-->'+e.getMessage());
        }
    }
}
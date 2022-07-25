public class ItemCreateInfoHandler {
  

    public static void makeInfo(map<id,Item__c> oldMap,List<Item__C> newList){

        List<Item_Info__c> listaInfo = new List<Item_Info__c>();

        Map<id,User> userMap = new Map<id,User>();

        for(User u : [SELECT Name FROM User]){
            userMap.put(u.id, u);
        }

        for(Item__c i : newList){
            Item__c oldItem = oldMap.get(i.id);
            
            if(i.Count__c < oldItem.Count__c){
                Decimal CountDifference = oldItem.Count__c - i.Count__c;
                String name = userMap.get(i.LastModifiedByid).name; 
                listaInfo.add( new Item_Info__c(CountDelta__c =  CountDifference,LastTake__c = DateTime.now(),UserName__c = name, Item__c = i.id));
            }
        }
        system.debug('lista ITEM IINFO: ' + listainfo);
        insert listaInfo;

    }

}

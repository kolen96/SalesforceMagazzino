public class CountHandler {
    public static void checkItem(list<Item__C> li ) {
        list<Item__C> present =[select count__C,name,location__c from Item__C];
        for (item__C presente:present ) {
            for(integer i=0;i<li.size();i++){
                if(presente.name==li[i].name && presente.location__c == li[i].location__C){
                    
                    li[i].adderror('Oggetto presente già nel database, si prega di aggiornarne la quantità');
                    }
            }          
        }
        
        for(integer i = 0;i<li.size();i++){
            for(integer j = i+1;j<li.size();j++){
                if(li[i].name==li[j].name && li[i].location__c == li[j].location__C){
                    li[i].adderror('Oggetto presente già nel database, si prega di aggiornarne la quantità');
                }
            }
        }
        
    }
}
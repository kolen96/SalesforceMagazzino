trigger insertItemTrigger on item__C (before insert) {
    
          CountHandler.checkItem(trigger.new); 
   

}
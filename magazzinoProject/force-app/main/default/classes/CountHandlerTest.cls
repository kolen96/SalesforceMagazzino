@istest
public with sharing class CountHandlerTest {
@TestSetup
static void makeData(){
    list<item__C> inserimenti = new list<item__C>();
    list<schema.location>magazzini=new list<schema.location>();
    magazzini.add(new schema.location(name='Magazzino Napoli',locationtype='Napoli'));
    magazzini.add(new schema.location(name='Magazzino Roma',locationtype='Roma'));
insert magazzini;
 subtype__C mouse=new subtype__C(name='Mouse');
 insert mouse;
    item__C item1 = new item__C(name='LEGION 5',category__C='Periferiche Pc',isactive__C=true,location__c= magazzini[0].id,thresholdlimit__C=10,brand__C='Logitech',subtype__C=mouse.id,count__C=10);
    inserimenti.add(item1);
    insert inserimenti;   
}
@istest
public static void testdata() {
    list<schema.location>magazzini=[select id,name,locationtype from location];
    list<item__C> inserimenti=new list<item__C>();
    subtype__C mouse=[select  name from subtype__C];
    inserimenti.add(new item__C(name='LEGION 5',category__C='Periferiche Pc',isactive__C=true,location__c= magazzini[0].id,thresholdlimit__C=10,brand__C='Logitech',subtype__C=mouse.id,count__C=10));
    inserimenti.add(new item__C(name='LEGION 4',category__C='Periferiche Pc',isactive__C=true,location__c= magazzini[0].id,thresholdlimit__C=10,brand__C='Logitech',subtype__C=mouse.id,count__C=10));
    test.starttest();
   
   database.insert(inserimenti,false);
    test.stoptest();
    item__C control = [select count__c from item__C where name='LEGION 5'];
    list<item__C> totlistitem= [select id from item__C];
    system.assertEquals(2,totlistitem.size());
    
}
}
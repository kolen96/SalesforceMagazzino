public with sharing class ItemUtilities {
    public static list<item__C> ItemUtilities(integer i) {
       list<item__C> listaitem=new list<item__c>();
        for(integer k=0;k<i;k++){
            Integer randomNumber = Integer.valueof((Math.random() * 20));
            Integer randomCount = Integer.valueof((Math.random() * 20));
            item__C item = new item__C(brand__c='Lenovo',name='test'+k,category__C='Computer',location__C='1317Q000000UaIjQAK',count__c=randomCount,ThresholdLimit__c=randomNumber,SubType__C='a017Q00000ocbu1QAA');
            listaitem.add(item);
        }
         return listaitem;
    }
}
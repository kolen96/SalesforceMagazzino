public with sharing class lowTresholdAlert {

    public static void sendlowTresholdAlert(map<string,list<item__c>> mappa ) {
        // system.debug('Start method');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        // list<String>luoghi=new list<String>();
        // for(string luogo:mappa.keyset()){
        //     luoghi.add(luogo);
        // }
          
        list<User> managers= [SELECT Id, Name, Email, UserRole.Name , user.city 
                                FROM User
                                WHERE UserRole.Name LIKE '%Manager%'];
        // System.debug('Mappa ' + mappa);
        // System.debug('Managers ' + managers);
        list<item__c> allItems = new list<item__c>();                                
        for(list<item__c> li: mappa.values() ){
            allItems.addAll(li);
        }

        for(User manager : managers){
            // system.debug(manager.UserRole.Name);
            // system.debug('For');
            list<item__c> lstItems = new list<item__c>();
            String city;
            switch on manager.UserRole.Name{
                
                when 'Locations Manager'{
                    // system.debug('Location');
                    lstItems = mappa.get(manager.city);
                    // city = manager.city;

                    mails.add(sendMail(manager, lstItems));
                }

                when 'Lead Manager'{
                    // system.debug('Lead');
                    mails.add(sendMail(manager, allItems));
                }
    
            }
        }

        Messaging.sendEmail(mails);
        
    }

    public static Messaging.SingleEmailMessage sendMail(User manager, list<item__c> item){
        
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();

        list<string>listamail = new list<string>();
        listamail.add(manager.email);
        mail.setToAddresses(listamail);
        mail.setSenderDisplayName('Magazzino');
        mail.setSubject('Attenzione prodotto in esaurimento - ' + manager.UserRole.Name);
        
        String body = 'Gentile ' + manager.Name + ',\n' + 'Mancano i seguenti prodotti: \n';

        if(manager.UserRole.Name == 'Lead Manager'){
            // system.debug('Lead');
            for(Item__c it: item){
                //system.debug(it.location__r.Name);
                body += it.id + ' | ' + it.Name + ' (' + it.Location__r.Name + '),\n ';
            }

        } else {
            
            // system.debug('Location');

            for(Item__c it: item){
                
                body += it.id + ' | ' + it.Name +',\n ';
            }

            body += 'nel magazzino ' + manager.city;
        }

        mail.setHtmlBody(body);

        // system.debug('Corpo:' + body);
        return mail;

    }
}
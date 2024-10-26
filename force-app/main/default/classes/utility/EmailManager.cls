public with sharing class EmailManager {
    @AuraEnabled(cacheable=true)
    public static void sendMassEmail(List<Id> contactIds) {
        List<Contact> contactsToSendEmail = getContacts(contactIds);
        if (contactsToSendEmail == null || contactsToSendEmail.isEmpty()) {
            throw new AuraHandledException('Please choose the contacts you want to send the email to.');
        }

        Boolean contactsHaveInvalidEmails = false;
        String invalidEmailsErrorMessage = 'Cannot send the emails. The problem is:\n';
        for (Contact contact : contactsToSendEmail) {
            if (contact.Email == null || contact.Email == '') {
                contactsHaveInvalidEmails = true;
                invalidEmailsErrorMessage += 
                    'This Contact: {contact.Id} {contact.FirstName} {contact.LastName} has invalid email: {contact.Email}\n';
            }
        }
        if (contactsHaveInvalidEmails) {
            throw new AuraHandledException(invalidEmailsErrorMessage);
        }

        EmailTemplate et = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name='General Mass Email'];
        if (et == null) {
            throw new AuraHandledException('Email template not found.');
        }

        Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
        massEmail.setTargetObjectIds(contactIds);
        massEmail.setTemplateId(et.Id);

        try {
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { massEmail });
            System.debug('Email has been sent');
        } catch (Exception e) {
            System.debug('Email hasnt been sent');
            throw new AuraHandledException('Cannot send the mass email, the error is: ' + e.getMessage());
        }
    }

    private static List<Contact> getContacts(List<Id> contactIds) {
        return [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :contactIds];
    }
}
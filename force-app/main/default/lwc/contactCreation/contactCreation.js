import { LightningElement, track, api } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findDuplicateContacts from '@salesforce/apex/ContactService.findDuplicateContacts';

export default class ContactCreation extends LightningElement {
    @api recordId;
    @track contacts = [{
        id: 1,
        FirstName: '',
        LastName: '',
        Birthdate: '',
        Email: '',
        LeadSource: ''
    }];

    handleAddContactRow() {
        console.log("recordId(accountId): ", this.recordId);
        const newContact = {
            id: this.contacts.length + 1,
            FirstName: '',
            LastName: '',
            Birthdate: '',
            Email: '',
            LeadSource: ''
        };

        this.contacts = [...this.contacts, newContact];
    }

    handleInputChange(event) {
        const contactId = event.target.dataset.id;
        const fieldName = event.target.dataset.field;
        const inputValue = event.target.value;

        this.contacts = this.contacts.map(contact => {
            if (String(contact.id) === contactId) {
                return {...contact, [fieldName]: inputValue};
            }
            return contact;
        });

        console.log('contacts:', JSON.stringify(this.contacts));
    }

    handleCreateContacts() {
        findDuplicateContacts({contactsToCheck: this.contacts})            
            .then((existingContacts) => {
                if (existingContacts.length > 0) {
                    console.log('existingContacts', JSON.stringify(existingContacts));

                    const duplicateEmails = existingContacts.map(contact => contact.Email);
                    console.log('duplicateEmails', JSON.stringify(duplicateEmails)  );

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Found duplicate Contacts',
                            message: `The following Contacts with these emails already exist: ${duplicateEmails.join(', ')}`,
                            variant: 'error'
                        })
                    );
                    return;
                }

                const promises = this.contacts.map(contact => {
                    const fields = {
                        FirstName: contact.FirstName,
                        LastName: contact.LastName,
                        Birthdate: contact.Birthdate,
                        Email: contact.Email,
                        LeadSource: contact.LeadSource,
                        AccountId: this.recordId
                    };
            
                    const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };
                    console.log('recordInput', JSON.stringify(recordInput));
            
                    return createRecord(recordInput);
                });
    
                Promise.all(promises)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Contacts created successfully!',
                                variant: 'success'
                            })
                        );
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating Contacts',
                                message: 'Cannot create contacts. Error: ' + error.message,
                                variant: 'error'
                            })
                        );
                    })
            })
    }

    handleDeleteContactRow(event) {
        const contactIdToDelete = event.target.dataset.id;
        this.contacts = this.contacts.filter((contact) => String(contact.id) !== contactIdToDelete);
    }
}
import { LightningElement, track } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactCreation extends LightningElement {
    @track contacts = [];

    handleAddContactRow() {
        const newContact = {
            id: this.contacts.length + 1,
            firstName: '',
            lastName: '',
            dateOfBirth: '',
            email: '',
            leadSource: ''
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
        const promises = this.contacts.map(contact => {
            const fields = {
                FirstName: contact.firstName,
                LastName: contact.lastName,
                Birthdate: contact.dateOfBirth,
                Email: contact.email,
                LeadSource: contact.leadSource
            };
    
            const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };
    
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
    }

    handleDeleteContactRow(event) {
        const contactIdToDelete = event.target.dataset.id;
        this.contacts = this.contacts.filter((contact) => String(contact.id) !== contactIdToDelete);
    }
}
import { LightningElement, track, api, wire } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findDuplicateContacts from '@salesforce/apex/ContactService.findDuplicateContacts';
import getContactsForAccount from '@salesforce/apex/ContactService.getContactsForAccount';

export default class ContactCreation extends LightningElement {
    @api recordId;
    contacts = [];

    @wire(getContactsForAccount, {
        accountId: '$recordId'
    })
    loadRelatedContacts({ error, data }) {
        console.log('Wire response - recordId:', this.recordId, 'data:', data, 'error:', error);

        if (data) {
            if (data.length > 0) {
                this.contacts = data.map(contact => (
                    {...contact, isExisting: true}
                ));
                console.log('Contacts loaded successfully:', data);
            } else {
                this.contacts = [];
                console.log("No contacts found.");
            }
        } else if (error) {
            this.contacts = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while loading contacts: ' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleAddContactRow() {
        console.log("recordId(accountId): ", this.recordId);
        const newContact = {
            id: this.contacts.length + 1,
            FirstName: '',
            LastName: '',
            Birthdate: '',
            Email: '',
            LeadSource: '',
            isExisting: false,
            isChild: false,
            MotherFirstName: '',
            MotherLastName: '',
            MotherEmail: '',
            FatherFirstName: '',
            FatherLastName: '',
            FatherEmail: '',
        };

        this.contacts = [...this.contacts, newContact];
    }

    handleInputChange(event) {
        const contactId = event.target.dataset.id;
        const fieldName = event.target.dataset.field;
        const inputValue = event.target.value;

        this.contacts = this.contacts.map(contact => {
            if (String(contact.id) === contactId) {
                if (fieldName === 'Birthdate') {
                    contact.isChild = this.calculateIsChild(inputValue);
                }
                if (contact.isChild) {
                    if (fieldName === "MotherFirstName") {
                        contact.MotherFirstName = inputValue;
                    }
                }
                return {...contact, [fieldName]: inputValue};
            }
            return contact;
        });

        // console.log('contacts:', JSON.stringify(this.contacts));
    }

    handleCreateContacts() {
        const contactsToCreate = this.contacts.filter(contact => !contact.isExisting);

        findDuplicateContacts({contactsToCheck: contactsToCreate})            
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

                const promises = contactsToCreate.map(contact => {
                    if (!contact.isChild) {
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
                    } else {
                        const motherFields = {
                            FirstName: contact.MotherFirstName,
                            LastName: contact.MotherLastName,
                            Email: contact.MotherEmail,
                            AccountId: this.recordId
                        }
                        const fatherFields = {
                            FirstName: contact.FatherFirstName,
                            LastName: contact.FatherLastName,
                            Email: contact.FatherEmail,
                            AccountId: this.recordId
                        }

                        const motherRecordInput = { apiName: CONTACT_OBJECT.objectApiName, fields: motherFields };
                        const fatherRecordInput = { apiName: CONTACT_OBJECT.objectApiName, fields: fatherFields };

                        console.log('motherRecordInput', JSON.stringify(motherRecordInput));

                        const createMotherPromise = createRecord(motherRecordInput);
                        const createFatherPromise = createRecord(fatherRecordInput);

                        return Promise.all([createMotherPromise, createFatherPromise])
                            .then(([motherData, fatherData]) => {
                                if (motherData && fatherData) {
                                    const childFields = {
                                        FirstName: contact.FirstName,
                                        LastName: contact.LastName,
                                        Birthdate: contact.Birthdate,
                                        Email: motherData.fields.Email.value,
                                        LeadSource: contact.LeadSource,
                                        AccountId: this.recordId,
                                        Mother__c: motherData.id,
                                        Father__c: fatherData.id 
                                    };
                                    const childRecordInput = { apiName: CONTACT_OBJECT.objectApiName, fields: childFields };
    
                                    console.log('childRecordInput', JSON.stringify(childRecordInput));
    
                                    return createRecord(childRecordInput)
                                        .then((childData) => {
                                            console.log('Child contact created:', JSON.stringify(childData));
                                        })
                                        .catch(error => {
                                            this.dispatchEvent(
                                                new ShowToastEvent({
                                                    title: "Error creating Child Contacts",
                                                    message: 'Cannot create child contacts. Error: ' + error.body.message,
                                                    variant: 'error'
                                                })
                                            );
                                        })
                                }
                            
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Error creating Parents' Contacts",
                                        message: 'Cannot create parents contacts. Error: ' + error.body.message,
                                        variant: 'error'
                                    })
                                );
                            })
                    }
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
                                message: 'Cannot create contacts. Error: ' + error.body.message,
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

    calculateIsChild(birthdate) {
        if (!birthdate) {
            return false;
        }

        const today = new Date();
        const birthDate = new Date(birthdate);
        let age = today.getFullYear() - birthDate.getFullYear();
        if (today.getMonth() < birthDate.getMonth() || 
            (today.getMonth() === birthDate.getMonth() && today.getDate() < birthDate.getDate())) {
                age--;
        }

        return age < 18;
    }

    get hasNonExistingContacts() {
        return this.contacts.some(contact => !contact.isExisting);
    }

    get contactsLengthIsMaximum() {
        return this.contacts.length === 5;
    }
}
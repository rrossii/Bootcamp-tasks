import { LightningElement, api, wire, track } from 'lwc';
import getFilteredContacts from '@salesforce/apex/ContactFilterController.getFilteredContacts';
import getTypePicklistValues from '@salesforce/apex/ContactFilterController.getTypePicklistValues';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import sendMassEmail from '@salesforce/apex/EmailManager.sendMassEmail';


export default class ContactTableInformation_LWC extends LightningElement {
    @api recordId;
    dateFrom = null;
    dateTo = null;
    type = '';
    showTable = false;
    @track contacts = [];
    @track selectedContacts = [];
    availableTypes = [];
    error;
    columns = [
        { label: 'First Name', fieldName: 'FirstName', type: 'text', editable: 'true' },
        { label: 'Last Name', fieldName: 'LastName', type: 'text', editable: 'true' },
        { label: 'Email', fieldName: 'Email', type: 'email', editable: 'true' },
        { label: 'Phone', fieldName: 'Phone', type: 'email' },
        { label: 'Date of Joining', fieldName: 'Date_of_joining_the_company__c', type: 'date', editable: 'true' }
    ];

    handleInputChange(event) {
        const inputLabel = event.target.label;
        if (inputLabel === 'From:') {
            this.dateFrom = event.target.value;
        } else if (inputLabel === 'To:') {
            this.dateTo = event.target.value;
        } else if (inputLabel === 'Type:') {
            this.type = event.target.value;
        }

        console.log("From handleInputChange() function");
        console.log('From:', this.dateFrom);
        console.log('To:', this.dateTo);
        console.log('Type:', this.type);
        console.log('recordId:', this.recordId);
    }

    @wire(getTypePicklistValues)
    availableTypes({ error, data }) {
        console.log('data in availableTypes wire function:', data)
        if (data && data.length > 0) {
            this.availableTypes = [
                { label: 'Choose One', value: '' },

                ...data.map(type => ({
                    label: type,
                    value: type
                }))
            ];
            console.log("Got type picklist successfully");
        } else if (data && data.length === 0) {
            this.availableTypes = [];

            console.log("Got no type picklist.")
        } else if (error) {
            this.error = error;
            this.availableTypes = [];

            console.error("Can't get type picklist: ", error);
        }
    }

    @wire(getFilteredContacts, { 
        accountId: '$recordId', 
        dateFrom: '$dateFrom', 
        dateTo: '$dateTo', 
        type: '$type'  
    })
    wiredContacts({ error, data }) {
        console.log('data in wire function:', data)
        console.log('recordId:', this.recordId);

        this.showTable = false;
        if (this.recordId) {
            if (data && data.length > 0) {
                this.contacts = data;
                this.error = undefined;
    
                console.log("Got contacts successfully");
            } else if (data && data.length === 0) {
                this.contacts = [];

                console.log("Got no contacts.")
            } else if (error) {
                this.error = error;
                this.contacts = [];
    
                console.error("Can't get filtered contacts: ", error);
            }
        } else {
            console.error("recordId is undefined");
        }
    }

    handleRunButtonClick() {
        this.showTable = true;
    }

    handleSaveContacts(event) {
        const updatedFields = event.detail.draftValues;
        console.log("updatedFields: ", event.detail.draftValues)

        const inputs = updatedFields.map(contactDraft => {
            console.log("updatedcontactDraft:", contactDraft)
            const fields = Object.assign({}, contactDraft);
            fields[ID_FIELD.fieldApiName] = contactDraft.Id;

            return { fields };
        });
        console.log('inputs: ', inputs)
        
        const promises = inputs.map(contactInput => updateRecord(contactInput));
        Promise.all(promises)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contacts Updated Successfully!',
                        variant: 'success'
                    })
                );
                console.log("All contacts updated successfully");

                return refreshApex(this.contacts);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Contacts',
                        message: 'Cannot update the Contacts: ' + error.message,
                        variant: 'error'
                    })
                );
                console.error("Error updating contacts: ", error);
            })
    }

    handleContactSelection(event) {
        this.selectedContacts = event.detail.selectedRows; 
        console.log("selectedContacts", JSON.stringify(this.selectedContacts))

    }

    handleEmailSending() {
        const contactIds = this.selectedContacts.map(contact => contact.Id);
        console.log("contactIds", JSON.stringify(contactIds));

        sendMassEmail({contactIds}) 
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Sent emails to selected Contacts Successfully!',
                        variant: 'success'
                    })
                );
                console.log("All contacts updated successfully");
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error sending emails to Contacts',
                        message: 'Cannot send the emails to selected Contacts: ' + error.body.message,
                        variant: 'error'
                    })
                );
            })
    }
}
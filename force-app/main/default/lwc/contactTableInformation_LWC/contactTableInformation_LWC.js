import { LightningElement, api, wire, track } from 'lwc';
import getFilteredContacts from '@salesforce/apex/ContactFilterController.getFilteredContacts';
import getTypePicklistValues from '@salesforce/apex/ContactFilterController.getTypePicklistValues';

export default class ContactTableInformation_LWC extends LightningElement {
    @api recordId;
    dateFrom = null;
    dateTo = null;
    type = '';
    showTable = false;
    @track contacts = [];
    availableTypes = [];
    error;
    columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Phone', fieldName: 'Phone', type: 'email' },
        { label: 'Date of Joining', fieldName: 'Date_of_joining_the_company__c', type: 'date' }
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
}
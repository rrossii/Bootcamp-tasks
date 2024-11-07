import { LightningElement } from 'lwc';

export default class ContactCreation extends LightningElement {
    contactRows = [];
    handleAddContactRow() {
        const newContact = {
            id: this.contactRows.length + 1,
            firstName: '',
            lastName: '',
            dateOfBirth: '',
            email: '',
            leadSource: ''
        };

        this.contactRows = [...this.contactRows, newContact];
    }

}
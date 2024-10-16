({
    init : function(component) {    
        // set record ID from URL
        var params = new URLSearchParams(window.location.search);
        var recordId = params.get('c__recordId');
        component.set("v.recordId", recordId);
        console.log("Record ID after setting: " + recordId);

        component.set("v.columns", [
            {label:"First Name", fieldName:"FirstName", type:"text"},
            {label:"Last Name", fieldName:"LastName", type:"text"},
            {label:"Phone", fieldName:"Phone", type:"phone"},
            {label:"Email", fieldName:"Email", type:"email"},
            {label:"Birthday", fieldName:"Birthdate", type:"date"},
            {label:"Date of Joining", fieldName:"Date_of_joining_the_company__c", type:"date"}
        ]);

        var action = component.get("c.getTypePicklistValues");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.types", response.getReturnValue());
                console.log("Got type values successfully");
            } else {
                console.error("Can't get picklist values from Type__c: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    getContacts : function(component) {
        var inputAccountId = component.get("v.recordId");
        var inputDateFrom = component.get("v.dateFrom");
        var inputDateTo = component.get("v.dateTo");
        var inputType = component.get("v.type");

        var action = component.get("c.getFilteredContacts");
        action.setParams({
            accountId: inputAccountId,
            dateFrom: inputDateFrom,
            dateTo: inputDateTo,
            type: inputType
        })
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.contacts", response.getReturnValue());

                // logs
                console.log("Got contacts successfully");
                console.log(response.getReturnValue());
                console.log("From: ", inputDateFrom, "To: ", inputDateTo);
            } else {
                console.error("Can't get filtered contacts: ", response.getError());
            }
        })

        $A.enqueueAction(action);
    },

    printContacts: function(component) {
        var dateFrom = component.get("v.dateFrom");
        var dateTo = component.get("v.dateTo");
        var type = component.get("v.type");
        var accountId = component.get("v.recordId");

        dateFrom = dateFrom ? dateFrom : '';
        dateTo = dateTo ? dateTo : '';

        console.log("From:", dateFrom);
        console.log("to:", dateTo);
        console.log("type:", type);
        console.log("accountId:", accountId);

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/ContactsTable?dateFrom=" + dateFrom + "&dateTo=" + dateTo + "&type=" + type + "&recordId=" + accountId
        });

        urlEvent.fire();
    },

    refresh : function() {
        $A.get('e.force:refreshView').fire();
    }
})

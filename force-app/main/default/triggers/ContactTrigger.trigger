trigger ContactTrigger on Contact (before insert) {
    new ContactTriggerHandler().run();
}
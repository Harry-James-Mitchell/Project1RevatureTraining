trigger TransactionTrigger on Transaction__c (before insert, after delete, after insert, before update, after update) {
 /*   if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){
        TransactionHelper.updateAllTransactions();
    } else if(trigger.isDelete && trigger.isAfter){
        TransactionHelper.updateAllTransactions();
    } */
    if(trigger.isAfter && !TransactionHelper.alreadyExecuted){
        TransactionHelper.updateAllTransactions();
    }
}
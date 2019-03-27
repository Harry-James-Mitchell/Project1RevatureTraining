trigger TransactionTrigger on Transaction__c (before insert, after delete, after insert, before update, after update) {

    if(trigger.isAfter && !TransactionHelper.alreadyExecuted){
        TransactionHelper.updateAllTransactions();
        TransactionHelper.updateBudgets();
    }
}
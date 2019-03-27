trigger BudgetTrigger on Budget__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
            BudgetHelper.setRemainingBudgetForNewBudgets(trigger.new);
        }
}
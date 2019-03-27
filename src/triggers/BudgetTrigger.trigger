trigger BudgetTrigger on Budget__c (before insert) {
    if(trigger.isBefore && trigger.isInsert){
            BudgetHelper.setRemainingBudgetForNewBudgets(trigger.new);
        }
}
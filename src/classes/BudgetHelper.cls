public class BudgetHelper {
    
    //This method sets the value of read only field Remaining Budget to the value of initial budget
    public static void setRemainingBudgetForNewBudgets(List<Budget__c> newBudgets){
        List<Budget__c> updatedBudgets = new List<Budget__c>();
        for(Budget__c newBudget : newBudgets){
        	if(newBudget.BudgetInitial__c != null){
        		newBudget.Budget_Remaining__c = newBudget.BudgetInitial__c;
        		updatedBudgets.add(newBudget);
        	}
        }
        update updatedBudgets;
    }

}
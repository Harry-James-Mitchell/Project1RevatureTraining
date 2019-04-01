public class TransactionHelper {
    
    //This boolean checks if the transaction trigger has already executed
    public static Boolean alreadyExecuted = false;

    /*
     * This method will update all of the transaction objects to keep track of the 
     * remaining budget when the transaction was made
     * 
     * for each loop explatation
     * Step 1: find the inital budget this transaction was apart of
     * Step 2: find all transactions in the same month and before this transaction
     * Step 3: compute what the remaining budget was at the time
     * Step 4: update the field
     */
    public static void updateAllTransactions(){
        List<Transaction__c> allTransactions = [SELECT Id, DateOfTransaction__c, Budget__c, cost__c, deposit__c FROM Transaction__c];
        List<Transaction__c> updatedTransactions = new List<Transaction__c>(); //this list will be inserted into the database
        //retrieving all budgets relevant to the incoming transactions
        List<Id> budgetIds = new List<Id>();
        for(Transaction__c T : allTransactions){
            budgetIds.add(T.Budget__c);
        }
        List<Budget__c> Budgets = [SELECT Id, BudgetInitial__c, EndDate__c FROM Budget__c WHERE Id IN :budgetIds];
        
        for(Transaction__c currentTransaction: allTransactions){
            //Step 1
            Decimal remainingBudget = 0.00;
            Boolean hasBudget = false;
            for(Budget__c B : Budgets){
                if(B.Id == currentTransaction.Budget__c){
                    remainingBudget = B.BudgetInitial__c;
                    if(currentTransaction.Cost__c != null){
                        remainingBudget -= currentTransaction.Cost__c;
                    } else {
                        remainingBudget += currentTransaction.Deposit__c;
                    }
                    hasBudget = true;
                    break;
                }
            }
            //if this transaction isn't part of budget, skip to the next transaction
            if(!hasBudget){continue;}
            //Step 2
            for(Transaction__c T : allTransactions){
                if((currentTransaction.DateOfTransaction__c.month() == T.DateOfTransaction__c.month()) && 
                (currentTransaction.DateOfTransaction__c > T.DateOfTransaction__c) && 
                (currentTransaction.Budget__c == T.Budget__c)){
                    //Step 3
                    if(T.Cost__c != null){
                        remainingBudget -= T.Cost__c;
                    } else {
                        remainingBudget += T.Deposit__c;
                    }
                }
            }
            //Step 4
            
            currentTransaction.Current_Budget_Remaining__c = remainingBudget;
            UpdatedTransactions.add(currentTransaction);
        }
        alreadyExecuted = true;
        update UpdatedTransactions;
    }
    
    //This method sets the value of read only field Remaining Budget based on the transaction associated with it
    public static void updateBudgets(List<Transaction__c> newTransactions){
        //retrive the ids of the budgets associated with each transaction
        set<Id> BudgetIds = new set<Id>();
        for(Transaction__c newTransaction : newTransactions){
            BudgetIds.add(newTransaction.Budget__c);
        }
        //use the list of ids to retrieve all of the needed budgets
        List<Budget__c> relevantBudgets = [SELECT Id, BudgetInitial__c, Budget_Remaining__c FROM Budget__c WHERE Id IN :BudgetIds];
        List<Budget__c> updatedBudgets = new List<Budget__c>();
        
        /*
        * for each transaction:
        * step 1: determine how the transaction changes the budget
        * step 2: determine which budget the transaction is associated with
        * step 3: update the budget's Budget Remaining field
        */
        for(Transaction__c newTransaction : newTransactions ){
            //step 1
            Decimal change = 0.00;
            if(newTransaction.Cost__c != null){
                change = -1 * newTransaction.Cost__c;
            } else {
                change = newTransaction.Deposit__c;
            }
            //step 2
            for(Budget__c currentBudget : relevantBudgets){
                if(currentBudget.Id == newTransaction.Budget__c){
                    //step 3
                    currentBudget.Budget_Remaining__c += change;
                    updatedBudgets.add(currentBudget);
                    break;
                }
            }
        }
        update updatedBudgets;
    }
}
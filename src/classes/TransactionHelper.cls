public class TransactionHelper {
    
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
    public static void updateRemainingBudget(List<Transaction__c> newTransactions){
        List<Transaction__c> allTransactions = [SELECT Id, DateOfTransaction__c, Budget__c, cost__c, deposit__c FROM Transaction__c];
        List<Transaction__c> newUpdatedTransactions = new List<Transaction__c>(); //this list will be inserted into the database
        //retrieving all budgets relevant to the incoming transactions
        List<Id> budgetIds = new List<Id>();
        for(Transaction__c newTransaction : newTransactions){
            budgetIds.add(newTransaction.Budget__c);
        }
        List<Budget__c> Budgets = [SELECT Id, BudgetInitial__c, EndDate__c FROM Budget__c WHERE Id IN :budgetIds];
        
        //You made this all transactions for testing - change it back if you need to
        for(Transaction__c newTransaction: newTransactions){
            //Step 1
            Decimal remainingBudget;
            for(Budget__c B : Budgets){
                if(B.Id == newTransaction.Budget__c){
                    remainingBudget = B.BudgetInitial__c;
                    if(newTransaction.Cost__c != null){
                        remainingBudget -= newTransaction.Cost__c;
                    } else {
                        remainingBudget += newTransaction.Deposit__c;
                    }
                    
                    break;
                }
            }           
            //Step 2
            for(Transaction__c T : allTransactions){
                if((newTransaction.DateOfTransaction__c.month() == T.DateOfTransaction__c.month()) && 
                (newTransaction.DateOfTransaction__c > T.DateOfTransaction__c) && 
                (newTransaction.Budget__c == T.Budget__c)){
                    //Step 3
                    if(T.Cost__c != null){
                        remainingBudget -= T.Cost__c;
                    } else {
                        remainingBudget += T.Deposit__c;
                    }
                }
            }
            //Step 4
            newTransaction.Current_Budget_Remaining__c = remainingBudget;
            newUpdatedTransactions.add(newTransaction);
        }
    }
    
    /*
     * This method will be called after a Transaction is deleted to update the remaining balance field on all other transactions
     */
    public static void updateTransactionAfterDeletion(List<Transaction__c> deletedTransactions){
        List<Id> budgetIds = new List<Id>();
        for(Transaction__c T : deletedTransactions){
            budgetIds.add(T.Budget__c);
        }
       // List<Budget__c> relevantBudgets = [SELECT Id, ]
    }
    
    public static void updateAllTransactions(){
        List<Transaction__c> allTransactions = [SELECT Id, DateOfTransaction__c, Budget__c, cost__c, deposit__c FROM Transaction__c];
        List<Transaction__c> updatedTransactions = new List<Transaction__c>(); //this list will be inserted into the database
        //retrieving all budgets relevant to the incoming transactions
        List<Id> budgetIds = new List<Id>();
        for(Transaction__c T : allTransactions){
            budgetIds.add(T.Budget__c);
        }
        List<Budget__c> Budgets = [SELECT Id, BudgetInitial__c, EndDate__c FROM Budget__c WHERE Id IN :budgetIds];
        
        //You made this all transactions for testing - change it back if you need to
        for(Transaction__c currentTransaction: allTransactions){
            //Step 1
            Decimal remainingBudget;
            for(Budget__c B : Budgets){
                if(B.Id == currentTransaction.Budget__c){
                    remainingBudget = B.BudgetInitial__c;
                    if(currentTransaction.Cost__c != null){
                        remainingBudget -= currentTransaction.Cost__c;
                    } else {
                        remainingBudget += currentTransaction.Deposit__c;
                    }
                    break;
                }
            }           
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
}
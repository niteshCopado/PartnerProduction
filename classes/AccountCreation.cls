public class AccountCreation {
    public static void newAccountRecords() {
        try{
        List<Account> accList= new List<Account>();
        for( Integer i=0 ; i<20 ; i++ ) {
            Account acc=new Account();
            acc.Name = 'PaiCopa'+i+'Rajath';
            acc.Fax = '123paicopa';
            acc.Website='https://trailhead.salesforce.com';
            accList.add(acc);
            // comment to test cli work
            //one more comment
        }
        if(accList.size() > 0) {
            insert  accList;
        }
    }
    catch(Exception ex){
        system.debug('Exception_Line_No--->'+ex.getLineNumber());
        system.debug('Exception_Message--->'+ex.getMessage());
    }
    }
}
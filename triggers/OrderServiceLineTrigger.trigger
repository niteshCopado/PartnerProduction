trigger OrderServiceLineTrigger on kugo2p__SalesOrderServiceLine__c (before update) {
    for(kugo2p__SalesOrderServiceLine__c orderService : trigger.new){
        if(orderService.kugo2p__LineDiscountPercent__c >= 100){
            orderService.kugo2p__LineDiscountPercent__c = null;
        }
    }
    

}
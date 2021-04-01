// common method used in 3 controller methods.
//
// 1). paymentMethodCompController
// 2). newCCPaymentMethodCompController
// 3). newACHPaymentMethodCompController
//

window._setPaymentMethod = (function () {

    //main method to set payment method against account and invoices.

    return function(cmp, paymentMethod, payNowBtn) {

        var comps = cmp.get('v.comps');
        var invoiceList = cmp.get("v.invoiceList");
        var listOfInvoiceLines = cmp.get("v.listOfInvoiceLines");


        if (invoiceList.length > 0) {
            var transactionParameter = [];
            invoiceList.forEach(function (inv) {
                var invoiceLines = listOfInvoiceLines.filter(function (line) {
                    return line.blng__Invoice__c === inv.Id
                });

                var param;

                if (inv.partial) {

                    var amountVal = 0;


                    invoiceLines.forEach(function (val) {
                        val.blng__Balance__c = val.amount;
                        amountVal += parseFloat(val.amount);
                    });

                    if (amountVal <= 0)
                    {
                        return ;
                    }

                    var finalLines = invoiceLines.filter(function (value) {
                        return value.amount > 0;
                    });

                    param = {
                        invoice: inv,
                        listOfInvoiceLine: finalLines,
                        isSelected: true,
                        amount: amountVal,
                        paymentMethod: paymentMethod
                    };

                }
                else {
                    param = {
                        invoice: inv,
                        isSelected: true,
                        amount: inv.blng__Balance__c,
                        paymentMethod: paymentMethod
                    };
                }
                transactionParameter.push(param);
            });

            if (comps.context !== 'invoice') {
                postAccountInvoices(cmp, transactionParameter, payNowBtn);
                return;
            } else {
                postInvoice(cmp, transactionParameter, payNowBtn);
                return;
            }

        } else {
            var param = [{
                accountInstance: {'sobjectType': 'Account', 'Id': cmp.get('v.recordId')},
                amount: comps.paymentTotalInput,
                paymentMethod: paymentMethod
            }];

            postAccountAmount(cmp, param, payNowBtn);
            return;
        }
    }

    //Post method for account invoice Payment - helper method
    function postAccountInvoices(component, transactionParameter, payNowBtn) {

        var processVirtualTerminalAction = component.get("c.processVirtualTerminalTransaction");
        processVirtualTerminalAction.setParams({transactionParameterToProcess: JSON.stringify(transactionParameter)});
        processVirtualTerminalAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue()[0];
            if (component.isValid() && state === "SUCCESS") {

                if (result.isSuccess) {
                    var comps = component.get("v.comps");
                    comps.paymentHome = false;
                    comps.paymentMethod = false;
                    comps.paymentChoice = false;
                    comps.paymentConfirm = true;
                    component.set("v.comps", comps);
                } else {
                    component.set('v.toastConfig', {'isActive': true, context: 'error', message: result.message});
                    if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                        payNowBtn.set('v.disabled', false);
                    }
                }

            } else if (state === "INCOMPLETE") {
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: 'Process incomplete'});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: errors[0].message});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            }
        });

        $A.enqueueAction(processVirtualTerminalAction);
    }

    //Post method for Account amount payment  - helper method

    function postAccountAmount(component, transactionParameter, payNowBtn) {
        var processTransaction = component.get("c.processAccountTransaction");
        processTransaction.setParams({transactionParameterToProcess: JSON.stringify(transactionParameter)});
        processTransaction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue()[0];

            if (component.isValid() && state === "SUCCESS") {

                if (result.isSuccess) {
                    var comps = component.get("v.comps");
                    comps.paymentHome = false;
                    comps.paymentChoice = false;
                    comps.paymentMethod = false;
                    comps.paymentConfirm = true;
                    comps.invoiceList = false;
                    comps.enterAmount = false;
                    comps.paymentTotalInput = 0;
                    component.set("v.comps", comps);
                } else {
                    component.set('v.toastConfig', {'isActive': true, context: 'error', message: result.message});
                    if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                        payNowBtn.set('v.disabled', false);
                    }
                }
            } else if (state === "INCOMPLETE") {
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: 'Process incomplete'});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: errors[0].message});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            }
        });

        $A.enqueueAction(processTransaction);
    }

    //Post method for Invoice payment - helper method
    function postInvoice(component, transactionParameter, payNowBtn) {
        var payInvoice = component.get("c.processVirtualTerminalTransaction");

        payInvoice.setParams({transactionParameterToProcess: JSON.stringify(transactionParameter)});
        payInvoice.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue()[0];
            if (component.isValid() && state === "SUCCESS") {

                if (result.isSuccess) {
                    var comps = component.get("v.comps");
                    comps.paymentHome = false;
                    comps.paymentChoice = false;
                    comps.paymentMethod = false;
                    comps.paymentConfirm = true;
                    comps.invoiceList = false;
                    comps.enterAmount = false;
                    comps.paymentTotalInput = 0;
                    component.set("v.comps", comps);
                } else {
                    component.set('v.toastConfig', {'isActive': true, context: 'error', message: result.message});
                    if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                        payNowBtn.set('v.disabled', false);
                    }
                }

            } else if (state === "INCOMPLETE") {
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: 'Process incomplete'});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set('v.toastConfig', {'isActive': true, context: 'error', message: errors[0].message});
                if (typeof payNowBtn !== "undefined" && !$A.util.isUndefinedOrNull(payNowBtn)) {
                    payNowBtn.set('v.disabled', false);
                }
            }
        });
        $A.enqueueAction(payInvoice);
    }
}());
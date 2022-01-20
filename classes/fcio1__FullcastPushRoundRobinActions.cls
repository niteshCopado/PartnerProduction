/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FullcastPushRoundRobinActions {
    global FullcastPushRoundRobinActions() {

    }
    @InvocableMethod(label='Push RR Exception' description='Round robin exception')
    global static void pushRoundRobinList(List<fcio1.FullcastPushRoundRobinActions.RoutingQueueParams> params) {

    }
global class RoutingQueueParams {
    @InvocableVariable(label='Tag' required=false)
    global String inputVal1;
    @InvocableVariable(label='Skill' required=false)
    global String inputVal2;
    @InvocableVariable(label='UserId/ParticipantId' required=false)
    global String inputVal3;
    @InvocableVariable(label='Tag Operator' required=false)
    global String inputVal4;
    @InvocableVariable(label='Sync/ASync' required=false)
    global String inputVal5;
    @InvocableVariable(label='LIFO/FIFO' required=false)
    global String inputVal6;
    @InvocableVariable(label='Skip/Redo' required=false)
    global String inputVal7;
    @InvocableVariable( required=false)
    global String inputVal8;
    @InvocableVariable( required=true)
    global Id recordId;
    global RoutingQueueParams() {

    }
}
}

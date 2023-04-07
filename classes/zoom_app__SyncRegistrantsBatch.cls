/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SyncRegistrantsBatch implements Database.AllowsCallouts, Database.Batchable<String>, Database.Stateful {
    global Boolean isError;
    global String next_page_token;
    global String status;
    global Set<String> zoomRegEmailSet;
    global SyncRegistrantsBatch() {

    }
    global SyncRegistrantsBatch(List<String> webinarIds) {

    }
    global SyncRegistrantsBatch(List<String> webinarIds, String next_page_token, String status, Set<String> zoomRegEmailSet) {

    }
    global SyncRegistrantsBatch(List<String> webinarIds, String next_page_token, String status, Set<String> zoomRegEmailSet, Boolean isError) {

    }
    global void execute(Database.BatchableContext BC, List<String> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global System.Iterable start(Database.BatchableContext BC) {
        return null;
    }
}

let definition = 
                {"GlobalKey__c":"Claim Story LWC/Vlocity/2/1580726061137","dataSource":{"type":null},"enableLwc":true,"filter":{"['objAPIName']":"vlocity_cmt__InsuranceClaim__c"},"sessionVars":[{"name":"iconName","val":"standard:partner_fund_claim"}],"states":[{"blankStateCheck":false,"collapse":true,"conditions":{"group":[{"field":"$scope.data.status","operator":"===","type":"system","value":"'active'"},{"field":"['onGoing']","logicalOperator":"&&","operator":"==","type":"custom","value":"true"}]},"definedActions":{"actions":[]},"disableAddCondition":false,"fields":[{"collapse":true,"editing":false,"fieldType":"standard","label":"Claim Number","name":"['subtitle']","type":"string"},{"collapse":true,"editing":false,"fieldType":"standard","label":"Loss Type","name":"['highlight']","type":"string"}],"filter":"$scope.data.status === 'active' && $scope.obj['onGoing'] == true","flyout":{"lwc":{"DeveloperName":"storyEditStateFlyout","Id":"0Rb5Y000000gD1OCAI","MasterLabel":"storyEditStateFlyout","name":"storyEditStateFlyout"}},"flyoutAttributes":[{"name":"parent","val":"$scope.obj"}],"lwc":{"DeveloperName":"storyOngoingState","Id":"0Rb5Y000000gD1PCAY","MasterLabel":"storyOngoingState","name":"storyOngoingState"},"name":"Claim Ongoing","sObjectType":"vlocity_cmt__InsuranceClaim__c","templateUrl":"story-card"},{"blankStateCheck":false,"collapse":true,"conditions":{"group":[{"field":"$scope.data.status","operator":"===","type":"system","value":"'active'"},{"field":"['onGoing']","logicalOperator":"&&","operator":"==","type":"custom","value":"false"}]},"definedActions":{"actions":[]},"disableAddCondition":false,"fields":[{"collapse":true,"editing":false,"fieldType":"standard","label":"Claim Number","name":"['subtitle']","type":"string"},{"collapse":true,"editing":false,"fieldType":"standard","label":"Loss Type","name":"['highlight']","type":"string"}],"filter":"$scope.data.status === 'active' && $scope.obj['onGoing'] == false","flyout":{"lwc":{"DeveloperName":"storyEditStateFlyout","Id":"0Rb5Y000000gD1OCAI","MasterLabel":"storyEditStateFlyout","name":"storyEditStateFlyout"}},"flyoutAttributes":[{"name":"parent","val":"$scope.obj"}],"lwc":{"DeveloperName":"storyNormalState","Id":"0Rb5Y000000gD1QCAI","MasterLabel":"storyNormalState","name":"storyNormalState"},"name":"Claim","sObjectType":"vlocity_cmt__InsuranceClaim__c","templateUrl":"story-card"}],"title":"Claims"}; 
            export default definition
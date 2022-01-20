import { LightningElement, track, wire } from 'lwc';
import getCaseDetail from '@salesforce/apex/ProjectConfigurationController.getCaseDetail';

export default class CaseDetail extends LightningElement {
    @track caseId;
    @track caseNo;
    @track dataNonTA = [];
    @track dataTA = [];
    @track errorMsg = '';
    @track isLoading = false;
    @track hasData = false;

    // Constructor method to get Case Id from url
    constructor(){
		super();
        let cid = new URL(window.location.href).searchParams.get('cid');
        this.caseId = cid;
    }

    // Wired method to get case deatils
    @wire(getCaseDetail, {recId : '$caseId'})
    getCaseData(value) {
        console.log(value);
        this.isLoading = true;
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {
            var data1 = JSON.parse(data.allOthersFieldsMap);
            var data2 = JSON.parse(data.textAreaFieldsMap);
            this.caseNo = data1['Case Number'];
            for(var key in data1){
                this.dataNonTA.push({value:data1[key], key:key});
            }
            for(var key in data2){
                this.dataTA.push({value:data2[key], key:key});
            }

            this.errorMsg = '';
            this.isLoading = false;
            this.hasData = true;
        }
        else if (data && data.isError) {
            this.errorMsg = 'There is an error while fetching data.';
            this.data = null;
            this.isLoading = false;
            this.hasData = false;
         }
        else if (error) {
            this.errorMsg = 'There is an error while fetching data.';
            this.data = null;
            this.isLoading = false;
            this.hasData = false;
        }
    };
}
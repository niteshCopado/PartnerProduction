import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import tableauJSAPI from '@salesforce/resourceUrl/TableauJSAPI';
import { reduceErrors } from './errorUtils.js';

import templateMain from './tableauViz.html';
import templateError from './tableauVizError.html';

export default class TableauViz extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api vizUrl;
    @api showTabs;
    @api showToolbar;
    @api filterOnRecordId;
    @api height;
    @api tabAdvancedFilter;
    @api sfAdvancedFilter;

    viz;
    advancedFilterValue;
    errorMessage;
    isLibLoaded = false;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$sfAdvancedFilter'
    })
    getRecord({ error, data }) {
        if (data) {
            this.advancedFilterValue = getFieldValue(
                data,
                this.sfAdvancedFilter
            );
            if (this.advancedFilterValue === undefined) {
                this.errorMessage = `Failed to retrieve value for field ${this.sfAdvancedFilter}`;
            } else {
                this.renderViz();
            }
        } else if (error) {
            this.errorMessage = `Failed to retrieve record data: ${reduceErrors(
                error
            )}`;
        }
    }

    async connectedCallback() {
        await loadScript(this, tableauJSAPI);
        this.isLibLoaded = true;
        this.renderViz();
    }

    renderedCallback() {
        this.renderViz();
    }

    renderViz() {
        // Halt rendering if inputs are invalid or if there's an error
        if (!this.validateInputs() || this.errorMessage) {
            return;
        }

        // Halt rendering if lib is not loaded
        if (!this.isLibLoaded) {
            return;
        }

        // Halt rendering if advanced filter value is not yet loaded
        if (this.sfAdvancedFilter && this.advancedFilterValue === undefined) {
            return;
        }

        const containerDiv = this.template.querySelector(
            'div.tabVizPlaceholder'
        );

        // Configure viz URL
        const vizToLoad = new URL(this.vizUrl);
        this.setVizDimensions(vizToLoad, containerDiv);
        this.setVizFilters(vizToLoad);
        TableauViz.checkForMobileApp(vizToLoad, window.navigator.userAgent);
        const vizURLString = vizToLoad.toString();

        // Set viz Options
        const options = {
            hideTabs: !this.showTabs,
            hideToolbar: !this.showToolbar,
            height: `${this.height}px`,
            width: '100%'
        };

        // eslint-disable-next-line no-undef
        this.viz = new tableau.Viz(containerDiv, vizURLString, options);
    }

    render() {
        if (this.errorMessage) {
            return templateError;
        }
        return templateMain;
    }

    validateInputs() {
        // Validate viz url
        try {
            const u = new URL(this.vizUrl);
            if (u.protocol !== 'https:') {
                throw Error(
                    'Invalid URL. Make sure the link to the Tableau view is using HTTPS.'
                );
            }

            if (u.toString().replace(u.origin, '').startsWith('/#/')) {
                throw Error(
                    "Invalid URL. Enter the link for a Tableau view. Click Copy Link to copy the URL from the Share View dialog box in Tableau. The link for the Tableau view must not include a '#' after the name of the server."
                );
            }
        } catch (error) {
            this.errorMessage = error.message ? error.message : 'Invalid URL';
            return false;
        }

        // Advanced filter checks
        if (
            (this.sfAdvancedFilter && !this.tabAdvancedFilter) ||
            (!this.sfAdvancedFilter && this.tabAdvancedFilter)
        ) {
            this.errorMessage =
                'Advanced filtering requires that you select both Tableau and Salesforce fields. The fields should represent corresponding data, for example, user or account identifiers.';
            return false;
        }

        return true;
    }

    // Height is set by the user
    // Width is based on the containerDiv to which the viz is added
    // The ':size' parameter is added to the url to communicate this
    setVizDimensions(vizToLoad, containerDiv) {
        containerDiv.style.height = `${this.height}px`;
        const vizWidth = containerDiv.offsetWidth;
        vizToLoad.searchParams.append(':size', `${vizWidth},${this.height}`);
    }

    setVizFilters(vizToLoad) {
        // In context filtering
        if (this.filterOnRecordId === true && this.objectApiName) {
            const filterNameTab = `${this.objectApiName} ID`;
            vizToLoad.searchParams.append(filterNameTab, this.recordId);
        }

        // Additional Filtering
        if (this.tabAdvancedFilter && this.advancedFilterValue) {
            vizToLoad.searchParams.append(
                this.tabAdvancedFilter,
                this.advancedFilterValue
            );
        }
    }

    static checkForMobileApp(vizToLoad, userAgent) {
        const mobileRegex = /SalesforceMobileSDK/g;
        if (!mobileRegex.test(userAgent)) {
            return;
        }

        const deviceIdRegex = /uid_([\w|-]+)/g;
        const deviceNameRegex = /(iPhone|Android|iPad)/g;

        const deviceIdMatches = deviceIdRegex.exec(userAgent);
        const deviceId =
            deviceIdMatches == null
                ? TableauViz.generateRandomDeviceId()
                : deviceIdMatches[1];
        const deviceNameMatches = deviceNameRegex.exec(userAgent);
        const deviceName =
            deviceNameMatches == null
                ? 'SFMobileApp'
                : `SFMobileApp_${deviceNameMatches[1]}`;

        vizToLoad.searchParams.append(':use_rt', 'y');
        vizToLoad.searchParams.append(':client_id', 'TableauVizLWC');
        vizToLoad.searchParams.append(':device_id', deviceId);
        vizToLoad.searchParams.append(':device_name', deviceName);
    }

    /* ***********************
     * This function just needs to generate a random id so that if the user-agent for this mobile device
     * doesn't contain a uid_ field, we can have a random id that is not likely to collide if the same user logs
     * in to SF Mobile from a different mobile device that also doesn't have a uid_ field.
     * ***********************/
    static generateRandomDeviceId() {
        function getRandomSymbol(symbol) {
            var array;

            if (symbol === 'y') {
                array = ['8', '9', 'a', 'b'];
                return array[Math.floor(Math.random() * array.length)];
            }

            array = new Uint8Array(1);
            window.crypto.getRandomValues(array);
            return (array[0] % 16).toString(16);
        }

        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
            /[xy]/g,
            getRandomSymbol
        );
    }
}
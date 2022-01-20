import { LightningElement } from 'lwc';

import LightningDatatable from 'lightning/datatable';
import projectConfigurationProfileImageTableControl from './projectConfigurationProfileImageTableControl.html';

export default class CustomLightningDatatable extends LightningDatatable  {
    // custom type of Profile Image for lightning datatable
    static customTypes = {
        profileImage: {
            template: projectConfigurationProfileImageTableControl,
            typeAttributes: ['url', 'name']
        }
    };
}
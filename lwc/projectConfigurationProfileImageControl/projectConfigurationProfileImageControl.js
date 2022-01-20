import { LightningElement, api } from 'lwc';

export default class ProjectConfigurationProfileImageControl extends LightningElement {
    @api url;
    @api altText;
    @api name;
}
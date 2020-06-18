/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
/**
 * @description
 *
 * @class
 * @noinstancector
 * @example
*/
/* global*/

(function (window) {

    'use strict';
    var //Private Methods
        getUpdateWidgetData, addWebServiceData, resetForm,
        //Public Methods
        showCreateForm,
        //Life cycle methods
        //Event handlers
        onTemplateContentChange, onTemplateContentClear, validateForm, closeForm, onTemplateReady,
        onServerError, createStatusChanged,
        //Constants,

    	TYPE, STATE;
    TYPE = {
        SimulationProcess: 'Simulation',
        SimulationActivity: 'Simulation Activity',
        SimulationAttributeGroup: 'Simulation Attribute Group',
        Document: 'DOCUMENTS',
        SimulationTemplateView: 'Simulation Template View'
    };

    STATE = {
        ready: 'is-ready',
        creating: 'is-creating',
        closing: 'is-closing',
        enable: 'is-enable'
    };

    //When any selection on content fields change
    onTemplateContentChange = function(e){
        e.stopPropagation();
        if (this.$.templateContent.value.objectType ===  TYPE.SimulationProcess ||
            this.$.templateContent.value.objectType ===  'Simulation Process' ||
            this.$.templateContent.value.objectTypeValue ===  'Simulation')
        {
            this.$.templateView.removeAttribute('disabled');
            this.$.helpText.classList.remove('display');
        } else {
            this.$.templateView.setAttribute('disabled', true);
            this.$.templateView.selectedIndex = 1;
            this.$.helpText.classList.add('display');
        }
    };

    //When content items are cleared
    onTemplateContentClear = function(e){
        e.stopPropagation();
        this.$.templateView.removeAttribute('disabled');
        this.$.helpText.classList.remove('display');
        this.$.templateView.selectedIndex = 0;
    };

    //Create object for dataelements to create Template
    addWebServiceData = function(dataElements, name, value){
        if (!this.JS.isEmpty(value)){
            dataElements[name] = {
                value: [
                    {
                        value: value
                    }
                ]
            };
        }
    };

    //Returns final post data to be send to Create Template Web Service
    getUpdateWidgetData = function(){
        var postData = {
            datarecords: {
                datagroups: [
                    {
                        updateAction: 'CREATE',
                        dataelements: {}
                    }
                ],
                name: 'SMA_Template'
            },
            name: 'SMA_Template'
        };

        var dataElements = {};
        //Don't add a field if it is null as its a create form not a update form
        addWebServiceData.call(this, dataElements, 'title', this.$.title.value);
        addWebServiceData.call(this, dataElements, 'description', this.$.description.value);
        addWebServiceData.call(this, dataElements, 'sourceId', this.$.templateContent.value.objectId);
        addWebServiceData.call(this, dataElements, 'templateView', this.$.templateView.value);
        addWebServiceData.call(this, dataElements, 'simulationKind', this.$.simulationKind.value);
        if (!this.JS.isEmpty(this.$.attributeGroup.value)) {
        	addWebServiceData.call(this, dataElements, 'attributeGroupId', this.$.attributeGroup.value.objectId);
        }

        if (!this.JS.isEmpty(this.$.instructionDoc.value)) {
        	addWebServiceData.call(this, dataElements, 'instructionDocId', this.$.instructionDoc.value.objectId);
        }

        if (this.policyList){
            addWebServiceData.call(this, dataElements, 'policy', this.$$('#policy').value);
        }

        postData.datarecords.datagroups[0].dataelements = dataElements;
        return 'updateWidget='+JSON.stringify(postData);
    };

    //On Clicking create template button in form. Validates form data and calls the web service
    validateForm = function(){
        var titlePattern = new RegExp("^((?!#)(?!,)(?!\\|)(?!\\[)(?!\\$)(?!\\])(?!@)(?!%)(?!:)(?!')(?!\")(?!\\\\)(?!\\*)(?!\\?)(?!<)(?!>).)*$");
        var errMsg = '';
        if (this.JS.isEmpty(this.$.title.value)){
            errMsg = 'Title cannot be Empty';
        }

        if (errMsg === '' && !titlePattern.test(this.$.title.value)){
            errMsg = 'Title contains forbidden characters like  " # $ @ % * , ? \\ < > [ ] | :';
        }

        if (errMsg === '' && this.JS.isEmpty(this.$.templateContent.value)){
            errMsg = 'Template Content cannot be empty.';
        }

        if (errMsg === '' && this.$.templateContent.value.objectType === TYPE.SimulationActivity && this.$.templateView.selectedIndex === 0){
            errMsg = 'Cannot create Custom View Template for Simulation Activity';
        }

        if (errMsg === ''){
            var createOptions = {
                uri: this.$.dashboard.getMcsUri() + '/resources/e6w/service/SMA_Template',
                verb: 'POST',
                data: getUpdateWidgetData.call(this),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            };
            this.createStatus = STATE.creating;
            this.$.create_template.sendRequest(createOptions); // jshint ignore:line
        } else {
            this.$.notification.logMessage({
                type: 'warning',
                text: errMsg,
                autoRemove: true
            });
        }
    };

    //Public function to show it in UI
    showCreateForm = function(obj){
        //if simulation object is passed use it to initialize Template Content Field
        this.createStatus = STATE.ready;

        if (! this.JS.isEmpty(obj)){
            this.$.templateContent.setObject(obj);
        }
        this.$.modalcontainer.show();
    };

    //Event handler to close the create form
    closeForm = function(){
        this.createStatus = STATE.closing;
        this.fire('close', {});
    };

    //On Successful creation of template
    onTemplateReady = function(event){
        event.stopPropagation();
        var response = JSON.parse(event.detail.response);
        if (response.hasOwnProperty('success') && String(response.success).toLowerCase() === 'true'){
            //parse response to get all data and fire create event
            var successData = {};
            successData.templateId = response.datarecords.datagroups[0].physicalId;
            successData.templateView = response.datarecords.datagroups[0].dataelements.templateView.value[0].value;
            successData.simulationKind = response.datarecords.datagroups[0].dataelements.simulationKind.value[0].value;
            successData.templateTitle = response.datarecords.datagroups[0].dataelements.title.value[0].value;

            var allChildren = response.datarecords.datagroups[0].children;
            var templateViewId, simulationId, contentType;
            allChildren.forEach(function (record) {
                if (record.busType === TYPE.SimulationTemplateView) {
                    templateViewId = record.objectId;
                }
                if (record.busType === TYPE.SimulationProcess){
                    simulationId = record.objectId;
                    contentType = record.busType;
                }
                if (record.busType === TYPE.SimulationActivity){
                    simulationId = record.objectId;
                    contentType = record.busType;
                }
            });
            successData.templateViewId = templateViewId;
            successData.simulationId = simulationId;
            successData.contentType = contentType;
            successData.simulationTitle = this.$.templateContent.value.displayName;
            this.createStatus = STATE.closing;
            this.fire('create', successData);
        } else {
            // its a failure
            onServerError.call(this, event);
        }
    };

    //Handle Template creation failed call
    onServerError = function(event){
        event.stopPropagation();
        this.createStatus = STATE.enable;
        var errorMsg = 'Error: Unable to Create Template.';
        if (event.detail.response){
            var error = JSON.parse(event.detail.response);
            if (error && error.datarecords
          && error.datarecords.datagroups[0]
          && error.datarecords.datagroups[0].updateMessage) {
                errorMsg = error.datarecords.datagroups[0].updateMessage;
            } else {
                errorMsg = error.error ;
            }
        }
        this.$.notification.logMessage({
            type: 'error',
            text: errorMsg
        });

    };

    resetForm = function(){
        this.$.title.value = undefined;
        this.$.description.value = null;
        this.$.simulationKind.selectedIndex = 0;
        this.$.templateContent.resetObject();
        this.$.attributeGroup.resetObject();
        this.$.instructionDoc.resetObject();
        this.$.templateView.removeAttribute('disabled');
        this.$.helpText.classList.remove('display');
        this.$.templateView.selectedIndex = 0;
        this.isFormDisabled = false;
        //Issue with textArea. If we set null & skip this line, it resets textArea only once.
        //The description remains unchanged from second time onwards. Hence this solution.
        this.$.description.value = '';
        this.$.description.textArea && this.$.description.textArea.enable();
    };
    //Wheneever create status is changed handle the Ui status
    createStatusChanged = function(){
        if (this.createStatus === STATE.enable){
            this.DOM(this.$.loadmsg).removeClass('loadmsg-visible');
            this.$.okButton.removeAttribute('disabled');
            this.$.dismissButton.removeAttribute('disabled');
            this.isFormDisabled = false;
            this.$.description.textArea && this.$.description.textArea.enable();
        }
        else if (this.createStatus === STATE.creating){
            this.DOM(this.$.loadmsg).addClass('loadmsg-visible');
            this.$.okButton.setAttribute('disabled', true);
            this.$.dismissButton.setAttribute('disabled', true);
            this.$.description.textArea && this.$.description.textArea.disable();
            this.isFormDisabled = true;
        }
        else if (this.createStatus === STATE.closing){
            this.DOM(this.$.loadmsg).removeClass('loadmsg-visible');
            this.$.okButton.removeAttribute('disabled');
            this.$.dismissButton.removeAttribute('disabled');
            resetForm.call(this);
	      this.$.modalcontainer.hide();
        }
    };

    window.Polymer(/** @lends element:xs-create-template# */{  // jshint ignore:line
        is: 'xs-create-template',
        behaviors: [window.DS.SMAProcSP.SPBase],
        properties: {
            createStatus:{
                type: String,
                value: 'is-ready',
                notify: true,
                observer: 'createStatusChanged'
            },
            policyList:{
                type: Array,
                value: null,
                notify: true
            }
        },


        attached: function() {
            this.$.templateContent.searchString = '(flattenedtaxonomies:"types/Simulation" OR flattenedtaxonomies:"types/Simulation Activity") AND (NOT policy:"Simulation Template Content")';
        },

        showCreateForm : showCreateForm,
        createStatusChanged: createStatusChanged,
        onTemplateContentChange:onTemplateContentChange,
        onTemplateContentClear:onTemplateContentClear,
        validateForm:validateForm,
        closeForm:closeForm,
        onTemplateReady:onTemplateReady,
        onServerError:onServerError,
        /*on reference to IR-633595-3DEXPERIENCER2019x, listeing to onError when user tries to acess
		sp-search in transient mode and giving proper msg.
		*/
        spError: function(event) {
            this.$.notification.logMessage({
                type: 'warning',
                text: 'The search cannot be started in Transient mode context.',
                autoRemove: true

            });
        }
    });
}(this));

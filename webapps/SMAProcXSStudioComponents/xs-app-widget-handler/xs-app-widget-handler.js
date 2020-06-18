/*--
[xs-app-widget-handler JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 27 Apr 2016 19:50:21 GMT
Assigned to:
Description:	TODO: Description
--*/
/**
	@module xs-app-widget-handler

	@example
		TODO: Provide example on how to use this element
*/
/* global widget, SPBase*/
(function (window) {
	'use strict';
	require(['UWA/Core', 'DS/UIKIT/SuperModal', 'DS/UIKIT/Mask', 'DS/UIKIT/Alert'],
		function(UWA, SuperModal, Mask, Alert) {

			/*jslint nomen: true*/
			var loadXSDesigner, onMandDataReady, loadOneClickPage, refresh, maskWidget, unmaskWidget, clearWidgetBody, openTemplate,
				//private members
				_savedCollabSpace, openSavedTemplate, loadPolicyInfo,
				//Life cycle methods
				ready, attached,
				//Event handlers
				onLoad, onRefresh, onNewObjectClick, onTemplateCreate,
				onDrop, onGetExperienceSuccess, onGetExperienceError, onEdit, endEdit, onCreateFormClose,
				closeTemplate, initWidgetHandler, onTemplateDataSuccess,
				//variables
				templateTitle, titleChangedAlready,
				//Constants
				PLM_TYPE;

			//Different PLM types used in here
			PLM_TYPE = {
				SimulationTemplate: 'Simulation Template',
				Simulation: 'Simulation',
				SimulationProcess: 'Simulation Process',
				SimulationActivity: 'Simulation Activity',
				SimulationAttributeGroup: 'Simulation Attribute Group',
				SimulationTemplateView: 'Simulation Template View'
			};

			ready = function () {
				//Remove if not required
			};

			onLoad = function(){
				var templateData = widget.getValue('templateData');
				if (templateData){
					openSavedTemplate.call(this.getElement('xs-app-widget-handler'), templateData.templateOid);
				} else {
					initWidgetHandler.call(this.getElement('xs-app-widget-handler'));
				}
			};

			initWidgetHandler = function(){
				this.initWidgetHandler();
			};

			openSavedTemplate = function(templateId){
				this.$.templateWS.uri = this.$.uwawidget.mcsuri + '/resources/e6w/service/SMA_TemplateRelation?objectId=' + templateId;
				this.$.templateWS.getData();
			};
			/*
     * Initiatilize Alert and Modal components
     */
			attached = function () {
	  		this.modal = new SuperModal({ renderTo: widget.body });
	  		this.alert = new Alert({ visible: true, renderTo: this.$.alertmsg });
				//add read only where accessed info to widget
				if (this.$.dashboard){
					this.$.dashboard.addReadOnlyWAPreference();
				}
				//Load Existing Template
				this.$.uwawidget.droptype = ['Simulation Template'];
				this.$.uwawidget.init(this);
				require(['DS/PlatformAPI/PlatformAPI'], function (PlatformAPI) {
				    this.platformAPIListener = PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh', function(modifiedData) {
				    var templateId = modifiedData.data && modifiedData.data.authored.modified[0];
				    this.$.SMAtemplateWS.uri = this.$.uwawidget.mcsuri + '/resources/e6w/service/SMA_Template?objectId='+templateId;
				      this.$.SMAtemplateWS.getData();
				    }.bind(this));
				}.bind(this));
			};

			onTemplateDataSuccess = function (event) {
				var templateData =  event.detail.response && event.detail.response.datarecords.datagroups[0].dataelements;
				var templateTitle = templateData && templateData.title.value[0].value;
				this.xsDesigner.templatetitle = templateTitle;
				widget.setTitle(templateTitle);
				var initialTemplateData = widget.getValue('templateData');
 				widget.setValue('templateData', {
					templateOid : initialTemplateData.templateOid,
					templateViewId : initialTemplateData.templateViewId,
					simulationKind : initialTemplateData.simulationKind, //Drop event does not provide simulationKind
					simulationId : initialTemplateData.simulationId,
					contentType : initialTemplateData.contentType, //Simulation or Simulation Activity
					templateTitle : templateTitle
				});
			};
			/*
     * Refresh XS- Designer
     */
			refresh = function(){
				if (this.xsDesigner && this.xsDesigner.isAttached){
					this.xsDesigner.refreshData();
				} else if (this.xsOneClick){
					this.xsOneClick.refreshData();
				}
				this.loadPolicyInfo();
			};

			// function to listen to drop event on widget. It can be either process or activity or Template
			onDrop = function(event, newDropZone){
    	        event.preventDefault();
				event.stopPropagation();
				if (newDropZone.objectData.templateContent){
					this.$.notification.logMessage({
						type: 'error',
						text: 'Cannot create Custom View Template for Simulation Content',
						autoRemove: false
					});
					if (!(this.xsDesigner && this.xsDesigner.isAttached) && !(this.xsOneClick && this.xsOneClick.isAttached)){
						this.$.uwawidget.revertToDrop();
					}
				} else {
					if (this.xsDesigner && this.xsDesigner.isAttached && this.xsDesigner.hasPendingUpdates()){
						var that = this;
						this.modal.confirm('All changes will be lost. Do you want to drop object ?', 'Unsaved Changes', function (result) {
							if (result){
								that.openTemplate(newDropZone);
							}
							else {
								newDropZone.objectData = that.dropZone.objectData;
							}
						});
					}
					else {
						this.openTemplate(newDropZone);
					}
				}
			};

			/*
     * Open Template in Process Studio
     */
			openTemplate = function(newDropZone){
				this.dropZone = newDropZone;
				var objectData = this.dropZone.objectData;
				var objectType = objectData.objectTypeValue ? objectData.objectTypeValue : objectData.objectType;
				if (objectType === PLM_TYPE.SimulationTemplate){
					this.$.templateWS.uri = this.$.uwawidget.mcsuri + '/resources/e6w/service/SMA_TemplateRelation?objectId=' + objectData.objectId;
					this.$.templateWS.getData();
				} else if (this.$.uwawidget.enableadd && (objectType === PLM_TYPE.Simulation || objectData.objectType === PLM_TYPE.SimulationProcess)){
					this.$.xsCreateTemplate.showCreateForm(objectData);
				} else if (this.$.uwawidget.enableadd && (objectType === PLM_TYPE.SimulationActivity)){
					this.$.xsCreateTemplate.showCreateForm(objectData);
				}

			};

			loadPolicyInfo = function(){
				this.$.fetchMandData.uri = this.$.dashboard.getMcsUri() + '/resources/e6w/service/SMA_TypeMetaData?type=Simulation Template';
				this.$.fetchMandData.getData();
				var templateData = widget.getValue('templateData');
				if (!titleChangedAlready || templateData === undefined){
					// widget.setTitle(' ');
					titleChangedAlready=false;
				} else {
					widget.setTitle(templateData.templateTitle);
				}
			};

			onMandDataReady = function(event){
				// add an array for this add array only if size of policy list is greater than one
				event.preventDefault();
				event.stopPropagation();
				var response = event.detail.response;
				if (response.hasOwnProperty('success') && String(response.success).toLowerCase() === 'true'){
					//parse response to get all data and fire create event
					var dataElem = response.datarecords.datagroups[0].dataelements;
					var policyResponse = dataElem.policy.value;
					var hasCreateAccess = dataElem.hasCreateAccess && (dataElem.hasCreateAccess.value[0].value === 'true');

					if (hasCreateAccess){
						this.$.uwawidget.enableadd = true;
						this.$.uwawidget.droptype = ['Simulation Template', 'Simulation', 'Simulation Process', 'Simulation Activity'];
						//Custom search is added to avoid showing internal objects for a simulation object which have only "Exists" state.
						this.$.uwawidget.customsearch = '(flattenedtaxonomies:"types/Simulation Template" OR flattenedtaxonomies:"types/Simulation" OR flattenedtaxonomies:"types/Simulation Process" OR flattenedtaxonomies:"types/Simulation Activity") AND (NOT policy:"Simulation Template Content")';
						this.$.uwawidget.dropNoteText = 'Simulation Template, Process, Activity';
					} else {
						this.$.uwawidget.enableadd = false;
						this.$.uwawidget.droptype =  ['Simulation Template'];
						this.$.uwawidget.dropNoteText = 'Simulation Template';
					}

					var policyArray = [];
					for (var i = 0; i < policyResponse.length; i++) {
						policyArray.push({
							value: policyResponse[i].value,
							label: policyResponse[i].value
						});
					}
					if (policyResponse.length > 1){
						this.$.xsCreateTemplate.policyList = policyArray;

					} else if (policyResponse.length === 1){
						if (policyResponse[0].value !== 'Simulation Template'){
							this.$.xsCreateTemplate.policyList = policyArray;
						}
					}

					if (!(this.xsDesigner && this.xsDesigner.isAttached) && !(this.xsOneClick && this.xsOneClick.isAttached)){
						this.$.uwawidget.revertToDrop();
					}

				}
				else {
					// console.log('Simulation Exprience Form Inint web service failed');
				}
			};


			/*
     * Event Handler when New Object button is clicked in dashboard
     */
			onNewObjectClick = function(){
				this.$.xsCreateTemplate.showCreateForm();
			};

			onTemplateCreate = function(e){
				e.stopPropagation();
				var templateObject = e.detail;
				if (!this.JS.isEmpty(templateObject.templateViewId)) {
					this.loadXSDesigner({
						templateOid : templateObject.templateId,
						templateViewId : templateObject.templateViewId,
						simulationKind : templateObject.simulationKind, //Drop event does not provide simulationKind
						simulationId : templateObject.simulationId,
						contentType : templateObject.contentType, //Simulation or Simulation Activity
						templateTitle : templateObject.templateTitle,
						simulationTitle : templateObject.simulationTitle
					});
				} else {

					this.loadOneClickPage({
						templateOid : templateObject.templateId,
						templateViewId : templateObject.templateViewId,
						simulationKind : templateObject.simulationKind, //Drop event does not provide simulationKind
						simulationId : templateObject.simulationId,
						contentType : templateObject.contentType, //Simulation or Simulation Activity
						templateTitle : templateObject.templateTitle,
						simulationTitle : templateObject.simulationTitle
					});
					//  this.alert.add({
					//      className: 'warning',
					//      message: 'View/Edit of One-click Experience is not yet supported on Dashboard. Use 3DSpace for that.'
					//  });
					//  this.clearWidgetBody();
				}
			};

			/*
    * Event to handle close button call of Create New Template Form
    */
			onCreateFormClose = function(e){
				e.stopPropagation();
				if (!(this.xsDesigner && this.xsDesigner.isAttached)){
					this.$.uwawidget.revertToDrop();
				}
			};

			/*
    * Event to handle Refresh call from widget menu
    */
			onRefresh = function () {
				if (_savedCollabSpace){
					return;
				}
				if (this.xsDesigner && this.xsDesigner.isAttached){
					if (this.xsDesigner.$.processbrowser){
						this.xsDesigner.$.processbrowser.onDismiss();
					}
					if (this.xsDesigner.hasPendingUpdates()){
						var that = this;
						this.modal.confirm('All changes will be lost. Do you want to refresh ?', 'Unsaved Changes', function (result) {
							if (result){
								that.refresh();
							}
						});
					} else {
						this.refresh();
					}
				} else if (this.xsOneClick){
					this.refresh();
				}
			};

			/*
     * Save existing collab space before preference edit
     */
			onEdit = function(){
				_savedCollabSpace = this.$.dashboard.getSecurityContext();
				//To hide dialog in case user has processbrowser window open
				if (this.xsDesigner && this.xsDesigner.$.processbrowser){
					this.xsDesigner.$.processbrowser.onDismiss();
				}
			};
			/*
     * If Changes are not saved then give Warning message to user that changes might be lost
     */
			endEdit = function(){
				// prevent default
				if (_savedCollabSpace !== this.$.dashboard.getSecurityContext()){
					//Check if collabspace is changed if no then reset it to previous prefrence
					if (this.xsDesigner && this.xsDesigner.isAttached){
						if (this.xsDesigner.hasPendingUpdates()){
							var that = this;
							this.modal.confirm('All changes will be lost. Do you want to Change CollabSpace ?', 'Unsaved Changes', function (result) {
								if (result){
									that.refresh();
									_savedCollabSpace = undefined;
									widget.setTitle(templateTitle);
									titleChangedAlready=true;
								} else {
									widget.setValue('collabspaces', _savedCollabSpace);
									_savedCollabSpace = undefined;
								}
							});
						} else {
							this.refresh();
						}
					} else {
						this.refresh();
					}
				}

			};

			/*
     * Event Handler to Template info. Allow Custom Templates if user has XS license or
     * else allow on-click if Composer license is present
     */
			onGetExperienceSuccess = function(e){
    	e.preventDefault();
				e.stopPropagation();
    	var response = e.currentTarget.data;
    	var simulationId, templateViewId, contentType, simulationTitle;
		  if (UWA.owns(response, 'success') && response.success){
			  response.datarecords.datagroups.forEach(function (record) {
						if (record.busType === PLM_TYPE.SimulationTemplateView) {
							templateViewId = record.physicalId;
						}
						if (record.busType === PLM_TYPE.Simulation){
							simulationId = record.physicalId;
							contentType = record.busType;
							simulationTitle = record.dataelements.title.value[0].value;
						}
						if (record.busType === PLM_TYPE.SimulationActivity){
							simulationId = record.physicalId;
							contentType = record.busType;
							simulationTitle = record.dataelements.title.value[0].value;
						}
					});

					templateTitle = '';
					if (this.dropZone){
						templateTitle = this.dropZone.objectData.displayName;
					} else {
						templateTitle = widget.getValue('templateData') ? widget.getValue('templateData').templateTitle : '';
					}

					if (UWA.is(templateViewId)) {
    					var simulationRecord = response.datarecords.datagroups.filter(function(record){
							if (record.busType === 'Simulation'){
								return true;
							}
							return false;
						});
						this.loadXSDesigner({
							templateOid : response.objectId,
							templateViewId : templateViewId,
							simulationKind : '', //Drop event does not provide simulationKind
							simulationId : simulationId,
							contentType : contentType,
							templateTitle : templateTitle,
							simulationTitle: simulationTitle
						});
					} else {
						this.loadOneClickPage({
							templateOid : response.objectId,
							templateViewId : templateViewId,
							simulationKind : '', //Drop event does not provide simulationKind
							simulationId : simulationId,
							contentType : contentType,
							templateTitle : templateTitle,
							simulationTitle: simulationTitle

						});
						// this.alert.add({
       			 //      className: 'warning',
        		  //     message: 'View/Edit of One-click Experience is not yet supported on Dashboard. Use 3DSpace for that.'
    		      // });
    		      // this.clearWidgetBody();
		      }
				} else {
  		  this.alert.add({
  			     className: 'error',
  			     message: 'Unable to fetch Template data. Please contact your system administrator.'
  		  });
  		  this.clearWidgetBody();
				}
			};

			/*
    * When fetching template info fails
    */
			onGetExperienceError = function(){
    	this.alert.add({
			 className: 'error',
			 message: 'Unable to fetch Template data. Please contact your system administrator.'
		  });
		  this.clearWidgetBody();
			};

			/*
     * Load XS designer in Process Studio
     */
			loadXSDesigner = function(templateData){

				widget.setValue('templateData', templateData);
		  this.$.uwawidget.removeDropNotes();
		  if (this.xsDesigner && this.xsDesigner.isAttached){
					this.xsDesigner.parentNode.removeChild(this.xsDesigner);
		  }

				if (this.xsOneClick && this.xsOneClick.isAttached){
					this.xsOneClick.parentNode.removeChild(this.xsOneClick);
				}
				this.xsDesigner = null;
				this.xsOneClick = null;
		  this.xsDesigner = UWA.createElement('xs-designer');
				this.xsDesigner.inDashBoard = true;
		  this.xsDesigner.templateid = templateData.templateOid;
		  this.xsDesigner.templatetitle = templateData.templateTitle;
		  this.xsDesigner.simid = templateData.simulationId;
		  this.xsDesigner.viewid = templateData.templateViewId;
		  this.xsDesigner.simtitle = templateData.simulationTitle;
				this.listen(this.xsDesigner, 'closeTemplate', 'closeTemplate');

				if (this.JS.isEmpty(this.dropZone)){
					this.dropZone = this.$.uwawidget.$$('#dropzone');
				}
		  this.dropZone.injectContent(this.xsDesigner);
		  this.xsDesigner.addEventListener('xs-designer-loaded', this.initWidgetHandler.bind(this));
		  this.unmaskWidget();
				widget.setTitle(templateData.templateTitle);
				titleChangedAlready=true;
			};

			/*
     * Load XS designer in Process Studio
     */
			loadOneClickPage = function(templateData){

				widget.setValue('templateData', templateData);
				this.$.uwawidget.removeDropNotes();

				if (this.xsDesigner && this.xsDesigner.isAttached){
					this.xsDesigner.parentNode.removeChild(this.xsDesigner);
		  }

				if (this.xsOneClick && this.xsOneClick.isAttached){
					this.xsOneClick.parentNode.removeChild(this.xsOneClick);
				}
				this.xsDesigner = null;
				this.xsOneClick = null;

				this.xsOneClick = UWA.createElement('xs-one-click');
				this.xsOneClick.openOneClick(templateData.templateOid, templateData.templateTitle, templateData.simulationId, templateData.simulationTitle, templateData.contentType);
				this.listen(this.xsOneClick, 'closeTemplate', 'closeTemplate');
				if (this.JS.isEmpty(this.dropZone)){
					this.dropZone = this.$.uwawidget.$$('#dropzone');
				}
				this.dropZone.injectContent(this.xsOneClick);
				this.initWidgetHandler();
				this.unmaskWidget();
				//To show title of template in widget templateTitle
				widget.setTitle(templateData.templateTitle);
				titleChangedAlready=true;
			};

			/*
    * Custom function to clear widget body and intialize it to basic
    */
			clearWidgetBody = function clearWidgetBody() {
				this.unmaskWidget();
				if (this.xsDesigner && this.xsDesigner.isAttached){
					this.xsDesigner.remove();
				}
				if (this.xsOneClick){
					this.xsOneClick.remove();
				}
				widget.setValue('templateData', undefined);
				this.initWidgetHandler();
				this.$.uwawidget.revertToDrop();
				//clear the title of the widget
				widget.setTitle(' ');
				titleChangedAlready=false;
			};


			closeTemplate = function(){
				if (this.xsDesigner && this.xsDesigner.isAttached){
					if (this.xsDesigner.hasPendingUpdates()){
						this.modal.confirm('All changes will be lost. Do you want to Close ?', 'Unsaved Changes', (function (result) { // jshint ignore:line
							if (result){
								clearWidgetBody.call(this);
							}
						}).bind(this)); // jshint ignore:line
					} else {
						clearWidgetBody.call(this);
					}
				} else if (this.xsOneClick) {
					clearWidgetBody.call(this);
				}
			};

			//Mask the widget
			maskWidget = function(){
	     Mask.mask(UWA.constructor(widget.body));
			};

			//Unmask the widget
			unmaskWidget = function(){
				Mask.unmask(UWA.constructor(widget.body));
			};

			window.DS.SMAProcXSStudioComponents = window.DS.SMAProcXSStudioComponents || {};
			window.DS.SMAProcXSStudioComponents.XSAppWidget = window.Polymer({ // jshint ignore:line
				is: 'xs-app-widget-handler',
				properties: {
					state: {
						type: String,
						notify: true,
						value: 'is-loading'
					}
				},
				ready: function () {
					return ready.apply(this, arguments);
				},
				attached: function(){
        	return attached.apply(this, arguments);
				},
				onLoad: function(){
        	return onLoad.apply(this, arguments);
				},

				initWidgetHandler: function(){
					this.state = 'is-init';
					this.fire('xs-app-widget-handler-loaded');
				},

				onRefresh: function () {
					var event = window.event;
					if (event !== undefined){
						var eventData = JSON.parse(event.data);
						if (eventData.payload.data.args[0] === 'onRefresh'){
							return onRefresh.apply(this.getElement('xs-app-widget-handler'), arguments);
						}
					} else { //Unable to get event object in Firefox, this will cause onRefresh to be called even in case of prefrence change
						return onRefresh.apply(this.getElement('xs-app-widget-handler'), arguments);
					}
					return undefined;
				},
				closeTemplate: function(){
					return closeTemplate.apply(this);
				},
				onDrop: function () {
					return onDrop.apply(this, arguments);
				},
				openTemplate: function(){
					return openTemplate.apply(this, arguments);
				},
				onNewObjectClick: function () {
					return onNewObjectClick.apply(this, arguments);
				},
				onTemplateCreate: function () {
					return onTemplateCreate.apply(this, arguments);
				},
				onCreateFormClose: function () {
					return onCreateFormClose.apply(this, arguments);
				},
				onEdit: function(){
					return onEdit.apply(this.getElement('xs-app-widget-handler'), arguments);
				},
				endEdit: function () {
					return endEdit.apply(this.getElement('xs-app-widget-handler'), arguments);
				},
				onResize: function () {
					// return onResize.apply(this, arguments);
				},
				onGetExperienceSuccess: function(){
        	return onGetExperienceSuccess.apply(this, arguments);
				},
				onTemplateDataSuccess: function () {
					return onTemplateDataSuccess.apply(this, arguments);
				},
				onGetExperienceError: function(){
        	return onGetExperienceError.apply(this, arguments);
				},
				loadXSDesigner: function(){
        	return loadXSDesigner.apply(this, arguments);
				},
				loadOneClickPage: function(){
					return loadOneClickPage.apply(this, arguments);
				},
				clearWidgetBody: function(){
          	return clearWidgetBody.apply(this, arguments);
				},
				maskWidget: function(){
					return maskWidget.apply(this, arguments);
				},
				unmaskWidget: function(){
					return unmaskWidget.apply(this, arguments);
				},
				refresh: function(){
					return refresh.apply(this, arguments);
				},
				onMandDataReady: function(){
					return onMandDataReady.apply(this, arguments);
				},
				loadPolicyInfo: function(){
					return loadPolicyInfo.apply(this, arguments);
				},
				behaviors: [SPBase]
			});
		});
}(this));

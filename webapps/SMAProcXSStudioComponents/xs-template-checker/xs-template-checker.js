/*--------------------------------------------------------------------
[xs-template-checker JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 27 May 2016 09:40:03 GMT
Assigned to:	zb8
Description:	Checks the template type and provides method to open the process PS widget
---------------------------------------------------------------------*/
/*
Example:
<xs-template-checker id="templateCheck" is-template-type = "{{templateType}}" obj-id = "{{objId}}">
</xs-template-checker>

 */

/* globals require*/
(function (window) {
	'use strict';

	// ---declaring globals---
	var TEMPLATE_INFO_URL, EVENT, MODE, openInNewWindow, toQueryString, check, TYPE;

	openInNewWindow = window.DS.SMAProcSP.SPBase.WIN.openInWindow;
	toQueryString = window.DS.SMAProcSP.SPBase.JS.toQueryString;

	TEMPLATE_INFO_URL = '/resources/e6w/service/SMA_TemplateRelation?objectId=';

	EVENT = {
		WEB_SERVICE_ERROR: 'error'
	};

	MODE = {
		MY_SIMULATION: 'My Simulation',
		PERFORMANCE_STUDY: 'Performance Study'
	};
	// Constants
	TYPE = {
		templateView: 'Simulation Template View',
		activity: 'Simulation Activity',
		template: 'Simulation Template'
	};

	window.Polymer({
		is: 'xs-template-checker',
		properties: {
			templateId: {
				notify: true,
				observer: 'templateIdChanged'
			},
			mode: {
				value: MODE.MY_SIMULATION
			}
		},

		// ---private methods---
		templateIdChanged: function () {
			if (this.templateId && this.templateId !== '') {
				this.getTemplateInfo(this.templateId, this.onTemplateInfoFetch.bind(this), this.onTemplateInfoError.bind(this));
			}
		},

		/*
		 * searches for the PLM Object type: Simulation Templates
		 */
		searchTemplates: function () {
			// importing sp-search
			// to allow selecting the same template again
			this.templateId = undefined;
			if (this.$.dashboard.isInDashboard()) {
				this.$.spSearch.search('(flattenedtaxonomies:"types/Simulation Template") AND [ds6w:status]:"Simulation Template.Released"');
			} else {
				this.$.spSearch.searchIn3DSpace(undefined, 'TYPE=type_SimulationTemplate:CURRENT=policy_SimulationTemplate.state_Released');
			}
		},

		/*
		 * operating after the search is completed.
		 */
		onSearchResult: function (event) {
			var selectedObjects;
			event.preventDefault();
        	event.stopPropagation();
			selectedObjects = event.detail.getSelectedObjects();
			if (selectedObjects && selectedObjects[0]) {
				this.templateTitle = selectedObjects[0].displayName;
				this.templateId = selectedObjects[0].objectId;
			} else {
				this.$.notify.logMessage({
					text: 'No Data Selected. Please select some data',
					type: 'warning',
					autoRemove: true
				});
			}
		},

		/**
		 * Get info about given Template id
		 * @param  {String} templateid Simulation Template id for which information is to be fetched
		 * @param  {Function} success Success callback function
		 * @param  {Function} error Error callback function
		 */
		getTemplateInfo: function (templateid, success, error) {
			this.$.templateInfo.uri = this.$.dashboard.getMcsUri() + TEMPLATE_INFO_URL + templateid;
			// Add error event listener
			this.$.templateInfo.addEventListener(EVENT.WEB_SERVICE_ERROR, function onTemplateDataError(event) {
				this.$.templateInfo.removeEventListener(EVENT.WEB_SERVICE_ERROR, onTemplateDataError);
				error(event);
			}.bind(this));
			// Get Data
			this.$.templateInfo.getData(success);
		},

		/*
		 * Checks whether the template is one-click or custom using templateview relationship
         * one-click: show JSP
         * custom: show the PS transient widget containing XS instantiator
		 */
		onTemplateInfoFetch: function (event) {
			var response, psWidgetOptions;
			response = event.response.datarecords.datagroups;
			psWidgetOptions = {
				templateData: {
					objectId: this.templateId,
					displayName: this.templateTitle,
					objectType: 'Simulation Template'
				},
				mode: 'create',
				operation: 'fromExprience',
				collabspaces: this.$.dashboard.getSecurityContext()
			};
			if (this.$.dashboard.isInDashboard()){
				psWidgetOptions.x3dPlatformId = window.widget.getValue('x3dPlatformId');
			}
			if (this.isActivityTemplate(response)) { // If Activity Template
				this.$.notify.logMessage({
					text: 'Inappropriate template type selected. Please select the Simulation Template of a Simulation Process',
					type: 'error',
					autoRemove: true
				});
			} else if (this.isCustomTemplate(response)) {
				this.initiateCustomTemplateInstantiation(psWidgetOptions);
			} else { // If this is one click
				this.initiateOneClickTemplateInstantiation(psWidgetOptions);
			}
		},

		/*
		 * Error when the web-services fails
		 */
		onTemplateInfoError: function () {
			this.$.notify.logMessage({
				text: 'Error in checking the Template tpye. Please contact your Administrator',
				type: 'error',
				autoRemove: true
			});
		},

		/**
		 * Is this activity tempalte or not
		 * @param  {Array} templateInfo Response array from Template info web service
		 * @return {Boolean} true/false
		 */
		isActivityTemplate: function (templateInfo) {
			return this._haskeyInResponse(templateInfo, TYPE.activity);
		},

		/**
		 * Is this Custom tempalte or not
		 * @param  {Array} templateInfo Response array from Template info web service
		 * @return {Boolean} true/false
		 */
		isCustomTemplate: function (templateInfo) {
			return this._haskeyInResponse(templateInfo, TYPE.templateView);
		},

		/**
		 * Is given key available in template info response or not
		 * @param  {Array} templateInfo Response array from Template info web service
		 * @param  {String} key type of object to search for
		 * @return {Boolean} true/false
		 */
		_haskeyInResponse: function (templateInfo, key) {
			var i = 0;
			for (i = 0; i < templateInfo.length; i += 1) {
				if (templateInfo[i].busType === key) {
					return true;
				}
			}
			return false;
		},

		/**
		 * Open Custom template instantiation page, in dashboard a widget is opened
		 * in case of 3dspace new window is opened
		 * @param {Object} data Template Data
		 */
		initiateCustomTemplateInstantiation: function(data) {
			var url;
			if (this.$.dashboard.isInDashboard()) {
				this.showTransientWidget('SIMDISB_AP', 'Performance Study', data);
			} else {
				url = '../../SMAProcXSUI/xs-app-instantiator/xs-app-instantiator.html?' + toQueryString({
					templateId: data.templateData.objectId,
					templateTitle: data.templateData.displayName
				});
				openInNewWindow(url);
			}
		},

		/**
		 * Open the one-click Instantiation jsp
		 * check = allows to message event listener to listen to postMessage for the correct template * fromdashboard = flag consumed by the JSP to make it compatible for 3DDashboard
		 * @param {Object} data Template Data
		 */
		initiateOneClickTemplateInstantiation: function (data) {
			var url;
			var date = new Date().getTime();
			if (this.$.dashboard.isInDashboard()) {
				window.top.addEventListener('message', this.receiveMessage.bind(this), false);
			}
			check = data.templateData.objectId + date;
			url = this.querySelector('#dashboard').getAuthenticatedJspUri('/common/emxTableEdit.jsp?' + toQueryString({
				objectId: data.templateData.objectId,
				table: 'SMATemplate_Instantiate',
				selection: 'none',
				program: 'jpo.simulation.Template:getOptions',
				postProcessURL: '../simulationcentral/smaInstantiateTemplateProcess.jsp',
				disableSorting: 'true',
				headerRepeat: '0',
				objectBased: 'false',
				pagination: '0',
				massUpdate: 'false',
				suiteKey: 'SimulationCentral',
				cancelProcessJPO: 'jpo.simulation.Template:cancelInstantiate',
				parentOID: data.templateData.objectId,
				header: 'Template.Instantiate.PageHeading',
				mode: 'Instantiate',
				optionType: 'viewableFields',
				check: check,
				findMxLink: 'false',
				HelpMarker: '',
				fromdashboard: this.$.dashboard.isInDashboard() ? 'true' : 'false'
			}));
			openInNewWindow(url);
		},

		/*
		* Open one click template instantiation JSP with apply button from Performance Study widget.
		* method get called when template is dragged n dropped on PS widget.
		*/
		initiateNewOneClickTemplateInstantiationFromPS : function(data){
			var url;
			var date = new Date().getTime();
			if (this.$.dashboard.isInDashboard()) {
				window.top.addEventListener('message', this.receiveMessage.bind(this), false);
			}
			check = data.templateData.objectId + date;
			url = this.querySelector('#dashboard').getAuthenticatedJspUri('/common/emxTableEdit.jsp?' + toQueryString({
				objectId: data.templateData.objectId,
				table: 'SMATemplate_Instantiate',
				selection: 'none',
				program: 'jpo.simulation.Template:getOptions',
				postProcessURL: '../simulationcentral/smaInstantiateTemplateProcess.jsp',
				disableSorting: 'true',
				headerRepeat: '0',
				objectBased: 'false',
				pagination: '0',
				massUpdate: 'false',
				suiteKey: 'SimulationCentral',
				cancelProcess: 'true',
				cancelProcessURL: '../simulationcentral/smaClose.jsp',
				parentOID: data.templateData.objectId,
				header: 'Template.Instantiate.PageHeading',
				mode: 'Instantiate',
				optionType: 'viewableFields',
				check: check,
				findMxLink: 'false',
				stopOOTBRefresh : 'false',
				HelpMarker: '',
				fromdashboard: this.$.dashboard.isInDashboard() ? 'true' : 'false',
				fromWidget:  this.$.dashboard.isInDashboard() ? 'true' : 'false',
				showApply: window.widget && window.widget.options.title === 'Performance Study' ? 'true' : 'false'
			}));
			this.fire('setdefaultlayout');
			openInNewWindow(url);
		},
		/*
		* Handles the callback from the instantiation JSP with the instantiated process details
		*/
		receiveMessage: function (event) {
			// only listen to event if the object is created and check matches
			if (event.data.id && check === event.data.check) {
				event.preventDefault();
				event.stopPropagation();
				// clear the objId  so that same object can be instantiated again.
				this.templateId = '';
				this.openProcessInPS(event.data.id);
			}
		},

		showTransientWidget: function (appId, title, data) {
			require(['DS/TransientWidget/TransientWidget'], function (Transient) {
				Transient.showWidget(appId, title, data);
			});
		},

		/*
		 * Open the process in transient PS Widget
		 */
		openProcessInPS: function (procID) {
			var processData, psWidgetOptions;
			processData = {
				objectId: procID,
				id: procID,
				objectType: 'Simulation'
			};

        	// setting the widget options
			psWidgetOptions = {
				procID: procID,
				mode: 'viewondrop',
				collabspaces: this.$.dashboard.getSecurityContext(),
				processData: processData
			};
			if (this.$.dashboard.isInDashboard()){
				psWidgetOptions.x3dPlatformId = window.widget.getValue('x3dPlatformId');
			}
			if (window.widget && window.widget.options.title === 'My Simulations'){
				this.showTransientWidget('SIMDISB_AP', 'Performance Study', psWidgetOptions);
			} else if(window.widget && window.widget.options.title === 'Performance Study') {
				if (this.$.dashboard.isInDashboard()) {
					this.fire('instantiated', { objectId: psWidgetOptions.procID, id: psWidgetOptions.procID, objectType: 'Simulation Process' });
				}
			}
		}
	});
}(this));

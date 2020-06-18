/*--------------------------------------------------------------------
[xs-instantiator JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:03 GMT
Assigned to:	d6u
Description:	TODO: Description
---------------------------------------------------------------------*/
/**
	@module SMAProcXS
        TODO: Update module based on web module this component is part of

	@example
		TODO: Provide example on how to use this element
*/
/* global Polymer, SPBase*/
(function (window) {
	'use strict';

	var displayInfoDialog, getAbsoluteUri, handlePendingRequests, MCS_URL, refreshParentFrame, redirectToPerformanceStudy, _sendRequest,
		// Event handlers
		// Constants
		// Enums
		PLAY, STATE;
	STATE = {
		loading: 'is-loading',
		ready: 'is-ready',
		updating: 'is-updating',
		deleting: 'is-deleting',
		visible: 'is-visible'
	};
	PLAY = {
		YES: 'is-playing',
		NO: 'is-notplaying'
	};

	/**
     * Private method that checks for any unsaved data changes and flushes any pending requests
     * @returns {String} - Alert information telling the user the changes are being saved before navigating away
     */
	handlePendingRequests = function () {
		// if there are pending updates, flush them
		if (this.$.playWS.hasPendingUpdates()) {
			this.$.playWS.flushAll();
			return 'Your changes are still being saved(this should only take a moment longer).\n\n' + 'If you leave now, your recent changes may be lost.';
		}
	};
	// Private methods
	/**
     * Private method to display dialog with the provided information
     * @param {String} heading - Dialog heading
     * @param {String} message - Detailed message
     */
	displayInfoDialog = function (heading, message) {
		this.$.infoDialog.heading = heading;
		Polymer.dom(this.$.infoDialogText).textContent = message;
		this.$.infoDialog.show();
	};

	/**
     * Private method to redirect to Performance study application with the simulation id provided
     * @param {String} objectId - Simulation id
     */
	redirectToPerformanceStudy = function (objectId) {
		var PS_PATH, url, appFrameWindow, spDashboard = this.$.dashboard;
		if (spDashboard.isInDashboard()) {
			this.fire('instantiated', { objectId: objectId, id: objectId, objectType: 'Simulation Process' });
		} else {
			PS_PATH = '/simulationcentral/smaHomeUtil.jsp?objectAction=EntryInPerformanceStudy&objectId=';
			url = MCS_URL + PS_PATH + objectId;
			appFrameWindow = window.emxUICore.findFrame(window.opener.getTopWindow(), 'content');
			appFrameWindow.open(url, '_self');
			window.close();
		}
	};

	refreshParentFrame = function (objectId) {
		var appFrameWindow, spDashboard = this.$.dashboard;
		if (spDashboard.isInDashboard()) {
			this.fire('instantiated', { objectId: objectId, id: objectId, objectType: 'Simulation Process' });
		} else {
			appFrameWindow = window.emxUICore.findFrame(window.opener.getTopWindow(), 'detailsDisplay');
			appFrameWindow.location.href = appFrameWindow.location.href;
			window.close();
		}
	};

	getAbsoluteUri = function (spWebservice) {
		return spWebservice.parseUri(spWebservice.uri).prefix + '/' + spWebservice.uri;
	};

	/**
     * Private method to send XHR request with the specified verb
     * @param {Object}  spWebservice - sp-webservice-instance with its uri and payload(if any) already set
     * @param {String} verb  - Method name 'PUT','POST','DELETE' etc.
     */
	_sendRequest = function (spWebservice, verb) {
		var absoluteURI;
		spWebservice.verb = verb;
		absoluteURI = spWebservice.parseUri(spWebservice.uri).prefix + '/' + spWebservice.uri;
		spWebservice.sendRequest({
			uri: absoluteURI,
			verb: verb
		});
	};
	// Prototype
	window.XSInstantiator = Polymer({ // jshint ignore:line
		is: 'xs-instantiator',
		properties: {
			loadstatus: {
				value: function () {
					return STATE.loading;
				}
			},
			playstatus: {
				type: String,
				value: ''
			},
			templateData: {
				notify: true,
				observer: 'templateDataChanged'
			},
			proceedPlayOnLoad: {
				type: Boolean,
				value: false
			}
		},
		// Life cycle methods
		ready: function () {
			MCS_URL = this.$.dashboard.getMcsUri();
			//Fix for IR-681768-3DEXPERIENCER2019x : Unable to instantiate custom-view template from 3DSpace on Chrome
			//check if we are running ODTs. If yes, do not modify history state
			if (!window.jasmine){
				//IR-702354-3DEXPERIENCER2019x :  Unable to instantiate a "custom view" template when server name in web address is not "3DSpace".
				//This change is done to avoid any hardcode. Now the path will get generated dynamically based on server url.
                var splitString = MCS_URL.split('/');
                var xsAppInstantiatorURL = '/'+splitString[splitString.length -1] +'/webapps/SMAProcXSUI/xs-app-instantiator/xs-app-instantiator.html';               
                //need to set this history state to get xs-instantiator.html file without any issues.
				history.pushState({}, '', xsAppInstantiatorURL);
				this.async(function(){
					//need to do this to avoid running into  IR-652536-3DEXPERIENCER2017x:-XS- Error occurs if user tries to change the referenced document while instantiating custom view template                    
                    history.pushState({}, '', '../../xs-app-instantiator.html');
				}, 400);
			}
		},
		play: function () {
			_sendRequest.call(this, this.$.playWS, 'POST');
		},
		/**
         * Event listener indicates player is ready once it receives ready event from canvas
         * @param {on-canvasready} event - Canvas triggers this event once it completed binding the Template view definition
         */
		onCanvasReady: function () {
			this.loadstatus = STATE.ready;
		},
		/**
         * Template id change listener.This calls the Play web service for the changed template id
         */
		templateDataChanged: function () {
			// Invoke Play web service
			this.hidePlayer();
			this.loadstatus = STATE.loading;
			this.$.templateChecker.getTemplateInfo(this.templateData.objectId, function onSuccess(event) {
				var response;
				response = event.response.datarecords.datagroups;
				if (this.$.templateChecker.isActivityTemplate(response)) { // If Activity Template
					this.clearPrefrencesfromPS('Activity Template instantiation is not supported.');
				} else if (this.$.templateChecker.isCustomTemplate(response)) {
					this.showPlayer();
					this.templateTitle = this.templateData.displayName;
					this.templateid = this.templateData.objectId;
					this.play();
				} else { // If this is one click
					// Show one - click Template instantiation JSP.
					var data = {};
					data  = event.response;
					data.templateData =  {};
					data.templateData.objectId = event.response.objectId;
					if(this.getParent){
						var spDrop = this.getParent('sp-drop');
						spDrop.revertToDrop();
					}
					this.$.templateChecker.initiateNewOneClickTemplateInstantiationFromPS(data);
					//this.clearPrefrencesfromPS('One Click Templates are not supported by Drop on Performance Study widget. Use My Simulation widget');
				}
			}.bind(this), function onError() {
				this.clearPrefrencesfromPS('Something went wrong. Please contact your Administrator.');
			}.bind(this));
		},

		clearPrefrencesfromPS: function (errorMsg) {
			this.hidePlayer();
			this.errorMsg = errorMsg;
			this.proceedPlayOnLoad = false;
			this.fire('closeWidget', {});
			this.$.errorMsg.show();
		},

		resetUI: function () {
			this.onDeleteSimulation();
		},

		showPlayer: function () {
			this.$.topNav.classList.remove('no-display');
			this.$.player.classList.remove('no-display');
		},

		hidePlayer: function () {
			this.$.topNav.classList.add('no-display');
			this.$.player.classList.add('no-display');
		},

		onPostRequest: function (event) {
			var httpRequest = event.detail;
			httpRequest.verb = 'POST';
		},
		/**
         * Event listener for 'Play' web service response.
         * @param {response} event - Response event
         */
		onPlayResponse: function (event) {
        	try {
	            var response;
	            response = JSON.parse(event.detail.response);

				if (event.detail.status !== 200) {
					return;
				}

				//why we do not try to get Template state before instantiation dialog window : we are not going to block template instantiation for obsolete template.
				//we are just gonna show warning message, hence even if we get the data along with Play webservice response, we are fine.
				//if user tries to Instatantiate Obsolete template, We should warn user about the same.
				if (response && response.infoMsg && response.infoMsg.contains('Template is in Obsolete State.')) {
					this.$.notification.logMessage({
						type: 'warning',
						text: 'Template is in Obsolete State.',
						autoRemove: true
					});
				}

				// If the response doesnt have any error message
				if (!response.hasOwnProperty('errorMsg')) {
    	            Polymer.Base.set('$.playWS.data', response, this);
    	            this.loadstatus = STATE.ready;

    	            // If it's a newly created Transient process, proceed to displaying view
    	            if (this.proceedPlayOnLoad) {
    	            	this.playstatus = PLAY.YES;
    	            } else {
    	            	this.playstatus = response.createdNew ? PLAY.YES : PLAY.NO;
    	            }

    	            if (this.playstatus === PLAY.YES && this.$.dashboard.isInDashboard()) {
    	              this.fire('proceedPlayOnLoad');
    	            }
				} else {
					// Show play error
					this._notifyPlayError(response.errorMsg);
				}
        	} catch (ex) {
        		if (console && console.warn) {
        			console.warn('Server did not respond well while trying to Play experience', ex);
        		}
        	}
		},
		_notifyPlayError: function (message) {
			this.$.notification.logMessage({
				type: 'error',
				text: message
			});
			this.loadstatus = STATE.ready;
			// Stop the spinner
			this.$.playerUpdatepanel.done();
		},
		/**
         * Event listener for 'Play' web service in case of error.
         * @param {response} event - Error event
        */
		onPlayError: function (event) {
			var message = event.detail.xhr ? event.detail.xhr.response : event.detail.response;
			this._notifyPlayError(message);
		},
		/**
         * Show the current Transient process
         * @param {click} event - User's button click event requesting continue Play
         */
		onProceedPlay: function () {
			// tempCreateStatus = false;
        	this.playstatus = PLAY.YES;
			if (this.$.dashboard.isInDashboard()) {
				this.fire('proceedPlayOnLoad');
			}
		},

		/**
         * Delete current Transient process and create a new one
         * @param {click} event - User's button click event requesting to restart Play
         */
		onRestartPlay: function () {
			var deleteSimWS;
			// tempCreateStatus = true;
			this.loadstatus = STATE.updating;
			deleteSimWS = this.$.deleteSimWS1;
			// Delete the existing Transient simulation and get a new one once deletion is successful.
			deleteSimWS.sendRequest({
				uri: (function () {
					return getAbsoluteUri.apply(this, arguments);
				})(deleteSimWS),
				verb: 'DELETE'
			});
		},
		/**
         * Event handler to respond to the cancel action by user
         * @param {click} event - Triggered when 'Click' from the Top bar is clicked
         */
		onCancelAttempt: function () {
			this.$.warningDialog.show();
		},
		/**
         * Event handler to delete the instantiated process(transient) and cancel
         * @param {click} event - Triggered when user confirms to proceed with Cancel
         */
		onCancelInstantiation: function () {
			this.loadstatus = STATE.updating;
			// Delete the simulation created on Play
			_sendRequest.call(this, this.$.deleteSimWS, 'DELETE');
			// Hide the confirm dialog
			this.hideWarningDialog();
		},
		/**
         * Event handler to complete the instantiation process
         * @param {click} event - Triggered when user chooses to complete instantiation
         */
		onTriggerInstantiation: function () {
			var canvas;
			// Get the canvas
			canvas = this.$.player.getCanvas();
			// If there are errors
			if (canvas.hasMandErrors()) {
				// Show the summary
				canvas.showSummary();
			} else if (this.$.playWS.hasPendingUpdates()) {
				this.$.playWS.flushAll();
				displayInfoDialog.call(this, 'Please wait', 'We are still saving changes to the process.Please try to instantiate again in a moment.');
				// Show the warning dailog
			} else if (canvas.hasErrors()) {
				this.unlisten(this.$.proceedDiscard, 'click', 'closeWindow');
				this.listen(this.$.proceedDiscard, 'click', 'instantiateTemplate');
				this.$.discardChangesDialog.show();
			} else {
				this.instantiateTemplate();
			}
		},

		/*
        *Instatantiate the templare
        */
		instantiateTemplate: function () {
			this.$.discardChangesDialog.hide();
			// Proceed with instantiation
			Polymer.Base.set('$.triggerInstantiation.disabled', true, this);
			this.loadstatus = STATE.updating;
			_sendRequest.call(this, this.$.instantiateWS, 'POST');
		},
		/**
         * Event listener when Instantiation is successful
         * @param {response} event - Triggered by sp-webservice when response is available
         */
		onInstantiationSuccess: function (event) {
			try {
				var response;
				// Display a success notification
				response = JSON.parse(event.detail.response);

				if (event.detail.status !== 200) {
					return;
				}

				// If the response doesnt have any error message
				if (!response.hasOwnProperty('errorMsg')) {
					Polymer.Base.set('$.instantiateWS.data', response, this);
					this.loadstatus = STATE.ready;
					this.$.notification.logMessage({
						type: 'success',
						text: 'Instantiated successfully',
						autoRemove: true
					});
					// If parentOID is present - will happen only when template is getting instantiated from other than My Simulation
					if (this._isParentOidPresent(this.templateData)) {
						refreshParentFrame.call(this, response.physicalid);
					} else {
						redirectToPerformanceStudy.call(this, response.physicalid);
					}
				} else {
					Polymer.dom(this.$.triggerInstantiation).removeAttribute('disabled');
					this._notifyPlayError(response.errorMsg);
				}
			} catch (e) {

			}
		},
		/**
         * Event listener when Instantiation failed
         * @param {response} event - Triggered by sp-webservice when there is error
         */
		onInstantiationError: function (event) {
			// Enable Instantiate again for the user to be able to retry and show an error notification
			Polymer.dom(this.$.triggerInstantiation).removeAttribute('disabled');
			this.loadstatus = STATE.ready;
			this.$.notification.logMessage({
				type: 'error',
				text: 'Instantiation failed.' + event.detail.response
			});
		},
		/**
         * Delete simulation response handler
         * This checks if the Simulation was deleted successfully
         * If successful-Redirect to landing page
         * If not - Notify the user and remain in XS
        */
		onDeleteSimulation: function () {
			// If successful, close the Instantiate pop-up
			this.loadstatus = STATE.ready;
			if (this.$.dashboard.isInDashboard()) {
				this.fire('closeWidget', { closeWindow: true });
			} else {
				window.getTopWindow().close();
			}
			var spDrop = this.getParent('sp-drop');
			spDrop.revertToDrop();
		},
		// TODO If not successful, remain in the page and display the error in cancel.
		// This should be rare because it's the same user deleting it!
		onDeleteSimError: function (event) {
			this.$.notification.logMessage({
				type: 'error',
				text: event.detail.xhr.response
			});
			this.loadstatus = STATE.ready;
		},
		/**
         * Retain the current Transient Simulation and close the Instantiate window
         */
		onSaveForLater: function () {
			var canvas = this.$.player.getCanvas();
			// If there are errors
			if (canvas.hasMandErrors()) {
				// Show the summary
				canvas.showSummary();
			} else if (this.$.playWS.hasPendingUpdates()) {
				this.$.playWS.flushAll();
				displayInfoDialog.call(this, 'Please wait', 'We are still saving changes to the process.');
				// Show the warning dailog
			} else if (canvas.hasErrors()) {
				// Show the warning dailog
				this.unlisten(this.$.proceedDiscard, 'click', 'instantiateTemplate');
				this.listen(this.$.proceedDiscard, 'click', 'closeWindow');
				this.$.discardChangesDialog.show();
			} else {
				this.$.notification.logMessage({
					type: 'success',
					text: 'Saved successfully'
				});
				this.closeWindow();
			}
		},

		/**
         * Close the Instantiation page.
         */
		closeWindow: function () {
			this.$.discardChangesDialog.hide();
			if (this.$.dashboard.isInDashboard()) {
				this.fire('closeWidget', { closeWindow: true });
			} else {
				window.setTimeout(function () {
					window.getTopWindow().close();
				}, 2000);
			}
		},

		/**
         * Hide the warning dialog.
         */
		hideDiscardDialog: function () {
			this.$.discardChangesDialog.hide();
			this.$.notification.logMessage({
				type: 'warning',
				text: 'Unsaved Changes. Please correct the errors.'
			});
		},

		/**
         * Hide the warning dialog.
         */
		hideWarningDialog: function () {
			this.$.warningDialog.hide();
		},
		/**
         * Hide the common information dialog.
         */
		hideInfoDialog: function () {
			this.$.infoDialog.hide();
		},
		behaviors: [SPBase],
		_computeUri: function (templateid) {
			return 'templates/' + templateid + '/play';
		},
		_computeUri2: function (transientsim) {
			return 'simulations/' + transientsim.id;
		},
		_computeUri3: function (transientsim, templateData) {
			if (this._isParentOidPresent(templateData)) {
				return 'templates/' + transientsim.id + '/play/instantiate?parentOID=' + templateData.parentOID;
			}
			return 'templates/' + transientsim.id + '/play/instantiate';
		},
		_computeClass: function (playstatus) {
			return playstatus + ' actions ' + playstatus;
		},
		_computeDisabled: function (loadstatus, playerupdating) {
			return playerupdating || loadstatus === 'is-updating';
		},
		_computeDisabled2: function (loadstatus) {
			return loadstatus === 'is-updating';
		},
		_computeClass2: function (loadstatus, playstatus) {
			return loadstatus + ' ' + playstatus + ' optional-begin-screen ' + loadstatus + ' ' + playstatus;
		},
		_computeDisabled3: function (loadstatus) {
			return loadstatus === 'is-updating';
		},
		_computeClass3: function (playstatus) {
			return playstatus + ' space-before-maincontent ' + playstatus;
		},
		_computeClass4: function (playstatus) {
			return 'player-overlay ' + playstatus;
		},
		_computeClass5: function (playstatus) {
			return playstatus + 'player ' + playstatus;
		},
		_isParentOidPresent: function (templateData) {
			if (templateData.parentOID !== undefined && templateData.parentOID !== null && templateData.parentOID.length > 0) {
				return true;
			}
			return false;
		}
	});
}(this));

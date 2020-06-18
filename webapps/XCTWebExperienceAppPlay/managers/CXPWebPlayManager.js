/**
 * @exports DS/XCTWebExperienceAppPlay/managers/CXPWebPlayManager
 */

define('DS/XCTWebExperienceAppPlay/managers/CXPWebPlayManager',
[
	'UWA/Core',
	'UWA/Class/Events',
	'DS/StuCore/StuContext',
	'DS/WebApplicationBase/W3AAManager',
	'DS/EPTaskPlayer/EPTaskPlayerDefine',
	'DS/StuRenderEngine/StuRenderManagerNA',
	'DS/EPEventServices/EPEventServices',

	'DS/StuCameras/StuNavigationNA', // require for reticule definition. Not used in this closure.
	'DS/StuTriggerZones/StuTriggerZoneManagerNA', // require for play triggerZone. Not use in this
	'DS/StuCID/StuUIActorNA', // require for play UIActors. Not use in this
    'DS/StuCore/StuEnvServicesNA'
],
function (UWA, Events, STU, W3AAManager, EPTaskPlayer, RenderManager, EventServices) {
	'use strict';

	/**
	* @name DS/XCTWebExperienceAppPlay/managers/CXPWebPlayManager
	* @category Manager
	*
	* @description
	* Manage Play/Pause/Stop of the runloop. 
	*
	* @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
	*/

	var CXPWebPlayManager = UWA.Class.extend(W3AAManager, Events,
	/** @lends DS/XCTWebExperienceAppPlay/managers/CXPWebPlayManager.prototype **/
	{

		initialize: function () {
			this._playing = false;
			this._pause = false;
			this._protoSpecs = [];
		},

		unInitialize: function () {
			this._playing = false;
			this._pause = false;
			this._protoSpecs = [];
		},

		getUpdatePriority: function () {
			return 0;
		},

		update: function (iOptions) {
			if (this._playing) {
				// compute elapsted time 
				var now = Date.now();
				var elapsedTime = now - this._startDate;
				var context = { deltaTime: iOptions.deltaTime, elapsedTime: elapsedTime };
				// execute task manager 
				EPTaskPlayer.execute(context);
			}
		},

		/** 
		 * Add a dictionary linking specs with a STU implementation.
		 * @public
		 * @param  {JSON} iData.
		**/
		AddProtobuildSpec: function (iData) {
			this._protoSpecs.push(iData);
		},

		/** 
		 * Get The stu object associated with a component. this method is async.
		 * @public
		 * @param  {Component} iComponent.
		 * @return {UWA.Promise}
		**/
		GetProtobuildFromComponent: function (iComponent) {
		    var type = iComponent.GetType();
			var protoFile = undefined;

			for (var i = 0; i < this._protoSpecs.length; ++i) {
			    if (this._protoSpecs[i].hasOwnProperty(type)) {
			        protoFile = this._protoSpecs[i][type];
			        break;
			    }
			}

			var self = this;
			return new UWA.Promise(function (iSuccess, iFail) {
				if (protoFile) {
					require([protoFile], function () {
						var closureArgs = arguments;
						var stuObject = new closureArgs[0];
						iSuccess(stuObject);
					});
				} else {
				    self._experienceBase.getManager('CAT3DXNotificationsManager').addNotification({
				        level: 'warning',
				        message: 'Warning : ' + type + ' not (longer) supported'
				    }, 5000);
				    iFail();
				}
			});
		},

		/** 
		* Start the experience : project the experience in "play mode" and start the DS/EPTaskPlayer
		* the start mechanism initialize and activate the subactors, starting scenario and starting act.
		* @public
		* @param  {StuExperience} experience - The experience instance to start.
		*/
		play: function (iExperience) {
			if (!iExperience.IsKindOf('CXPExperience_Spec')) {
			    return UWA.Promise.reject(new Error());
			}

			// start the event listener to fw events to EP
			var self = this;
			// resume from pause
			if (this._pause) {
				this._pause = false;
				this._playing = true;
				self._experienceBase.getManager('CXPWebEventListenerManager').start();
				EPTaskPlayer.resume();
				return UWA.Promise.resolve();
			}

			// init RenderManager
			this._viewer = this._experienceBase.getManager('CAT3DXVisuManager').getViewer();

			STU.RenderManager.getInstance().setViewer(this._viewer);
			STU.RenderManager.getInstance().setViewpoint(this._viewer.currentViewpoint);
			STU.initContext();

			return this._getStuObject(iExperience).done(function (stuExperience) {
			    // set variables as volatile
			    iExperience.QueryInterface('CATI3DXVolatileEO').setVolatile();
				self._experienceBase.getManager('CXPWebEventListenerManager').start();
				// initialize the experience 
				stuExperience.initialize();
				self._startDate = Date.now();
				self._playing = true;
				// activate the exeprience
				stuExperience.activate();
				// start the task player 
				EPTaskPlayer.start();				
				self._setPlayCursor();
				return UWA.Promise.resolve();
			});
		},

		/** 
		* Pause execution of EPTaskPlayer
		* @public
		* @param  {StuExperience} experience - The experience to pause.
		*/
		pause: function (/*iExperience*/) {
			//Stop run loop
			this._playing = false;
			this._pause = true;
			// stop the event listener 
			this._experienceBase.getManager('CXPWebEventListenerManager').stop();
			EPTaskPlayer.pause();
			return UWA.Promise.resolve();
			// pause the runloop
		},

		/** 
		* Stop execution of EPTaskPlayer
		* @public
		* @param  {StuExperience} experience - The experience to stop.
		*/
		stop: function (iExperience) {
			if (this._pause) {
				this._pause = false;
			}
			var self = this;

			//Stop run loop
			this._playing = false;
			// stop the event listener 
			this._experienceBase.getManager('CXPWebEventListenerManager').stop();
			// stop the task player 
			EPTaskPlayer.stop();

			return this._getStuObject(iExperience).done(function (stuExperience) {
				// deactivate experience 
				stuExperience.deactivate();
				STU.disposeContext();
				// reset positions

				iExperience.QueryInterface('StuIPrototypeBuild').Free();
				iExperience.QueryInterface('CATI3DXVolatileEO').restorePersistent();
				self._restoreAuthoringCursor();
			});
		},

		_getStuObject: function (iObject) {
			// build the STU view of the experience if necessary 
			if (!UWA.is(iObject)) {
				console.error('Error getStuObject() : parameter not defined !');
				return undefined;
			}
			return iObject.QueryInterface('StuIPrototypeBuild').Get();
		},


		_setPlayCursor: function () {
			this.onClickableEnterEvent = function () {
				this._viewer.canvas.style.cursor = 'pointer';
			};

			this.onClickableExitEvent = function () {
				this._viewer.canvas.style.cursor = 'default';
			};

			var clickableEnterEvent = EventServices.getEventByType('ClickableEnterEvent');
			EventServices.addObjectListener(clickableEnterEvent, this, 'onClickableEnterEvent');

			var clickableExitEvent = EventServices.getEventByType('ClickableExitEvent');
			EventServices.addObjectListener(clickableExitEvent, this, 'onClickableExitEvent');
			this._viewer.canvas.style.cursor = 'default';
		},

		_restoreAuthoringCursor: function () {
			var clickableEnterEvent = EventServices.getEventByType('ClickableEnterEvent');
			EventServices.removeObjectListener(clickableEnterEvent, this, 'onClickableEnterEvent');

			var clickableExitEvent = EventServices.getEventByType('ClickableExitEvent');
			EventServices.removeObjectListener(clickableExitEvent, this, 'onClickableExitEvent');

			this._viewer.canvas.style.cursor = 'auto';
		},

		GetType: function () {
			return 'CXPWebPlayManager';
		}

	});

	return CXPWebPlayManager;
});

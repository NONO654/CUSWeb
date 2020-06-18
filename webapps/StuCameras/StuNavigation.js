define('DS/StuCameras/StuNavigation', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/EPEventServices/EPEvent', 'DS/StuModel/StuBehavior', 'DS/EPEventServices/EPEventServices',
    'DS/EPTaskPlayer/EPTask', 'MathematicsES/MathsDef', 'DS/StuCameras/StuInputManager', 'DS/StuMath/StuMath', 'DS/EPInputs/EPKeyboard'],
    function (STU, EP, Event, Behavior, EventServices, Task, DSMath) {
	'use strict';

	/**
	* NAVIGATION HANDLER TASK
	* @class 
	* @private
	*/
	var NavigationTask = function(cameraHandler) {
		Task.call(this);
		this.cameraHandler = cameraHandler;
	};

	NavigationTask.prototype = new Task();
	NavigationTask.constructor = NavigationTask;

	/**
	 * Method called each frame by the task manager
	 *
	 * @method
	 * @private
	 * @param  iExeCtx Execution context
	 */
	NavigationTask.prototype.onExecute = function(iExeCtx) {

		if (this.cameraHandler === undefined || this.cameraHandler === null) {
			return this;
		}
		var cameraHandler = this.cameraHandler;

		var actor = cameraHandler.getActor();
		if (actor === undefined || actor === null) {
			return this;
		}

		cameraHandler._renderMngr = STU.RenderManager.getInstance();
		if (cameraHandler._renderMngr === undefined || cameraHandler._renderMngr === null) {
			return this;
		}

		// If this actor is not the current camera registered in the Render Manager
		// then we are not updating the viewpoint and we do not want to handle
		// user interaction
		if (cameraHandler._renderMngr.getCurrentCamera() !== actor) {
			//remove of the reticule if any 
			if (!!cameraHandler._reticuleWidget) {
				cameraHandler._reticuleWidget.Dispose();
				cameraHandler._reticuleWidget = null;
			}
			return this;
		}

		cameraHandler._camera = cameraHandler.getActor();
		if (cameraHandler._camera === undefined || cameraHandler._camera === null) {
			return this;
		}

		if (cameraHandler._inputManager === undefined || cameraHandler._inputManager === null) {
			return this;
		}

		if (cameraHandler.navigateOnClick === true) {
			if (cameraHandler._inputManager.buttonsState[8] === false) {
				cameraHandler._isMousePressed = false;
			} else {
				//if the mouse wasn't pressed the previous frame 
				if (!cameraHandler._isMousePressed && cameraHandler.followMouse === true) {

					if (cameraHandler._inputManager.mouseAxis === 2) {
						cameraHandler._lastMousePosition.x = cameraHandler._inputManager.axis2.x;
						cameraHandler._lastMousePosition.y = cameraHandler._inputManager.axis2.y;
					} else {
						cameraHandler._lastMousePosition.x = cameraHandler._inputManager.axis1.x;
						cameraHandler._lastMousePosition.y = cameraHandler._inputManager.axis1.y;
					}
				}
				cameraHandler._isMousePressed = true;
			}
		}

		// Time will be handle in seconds 
		cameraHandler._deltaTime = iExeCtx.getDeltaTime() / 1000;

		cameraHandler._isCursorInNeutralZone = false;

		cameraHandler.update();
	};


	/**
	 * Describe a camera navigation
	 *
	 * @exports Navigation
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends {STU.Behavior}
	 * @memberOf STU
	 * @alias STU.Navigation
     */
	var Navigation = function() {

		Behavior.call(this);
		this.name = 'Navigation';

		this.associatedTask;

		//////////////////////////////////////////////////////////////////////////
		// Properties that should NOT be visible in UI
		//////////////////////////////////////////////////////////////////////////


		/**
		 * Keyboard and mouse manager
		 *
		 * @member
		 * @private
		 * @type {STU.InputManager}
		 */
		this._inputManager = null;

		/**
		 * Radius of the neutral zone
		 *
		 * @member
		 * @private
		 * @type {Number}
		 */
		this._neutralZoneRadius = 55;

		/**
		 * Widget handeling the reticule behaviour
		 *
		 * @member
		 * @private
		 * @type {stu__ReticuleWidget}
		 */
		this._reticuleWidget = null;

		/**
		 * Flag indicating if the cursor is in the neutral zone of the reticule widget
		 *
		 * @member
		 * @private
		 * @type {boolean}
		 */
		this._isCursorInNeutralZone = false;

		/**
		 * Mouse coordinates of previous frame
		 *
		 * @member
		 * @private
		 * @type {DSMath.Point}
		 */
		this._lastMousePosition = new DSMath.Point();

		/**
		 * Flag indicating if the mouse is beeing pressed
		 *
		 * @member
		 * @private
		 * @type {boolean}
		 */
		this._isMousePressed = false;

		/**
		 * Position of the center of the reticule widget relatively to the center of the window
		 *
		 * @member
		 * @private
		 * @type {Array.<number>}
		 */
		this._reticulePosition = {
			'x': 0,
			'y': 0
		};

		/**
		 * Camera instance
		 *
		 * @member
		 * @private
		 * @type {STU.Camera}
		 */
		this._camera = null;

		/**
		 * Render manager instance
		 *
		 * @member
		 * @private
		 * @type {STU.RenderManager}
		 */
		this._renderMngr = null;

		/**
		 * Time elpased since last frame in seconds
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
		this._deltaTime = 0;


		///
		/////////      General
		///

		/**
		 * Show or hide the reticle
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.showReticule = true;

		///
		/////////      Controls
		///

		/**
		 * Move the view only when the left mouse button is pressed
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.navigateOnClick = true;

		/**
		 * Use the mouse displacement to move the view instead of using the mouse position
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.followMouse = false;


		///
		/////////      Advanced
		///

		/**
		 * Set the speed of Yaw displacement (horizontal speed, rotation on Up axis) in degree / seconds
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.horizontalRotationSensitivity = 100.0;

		/**
		 * Set the speed of Pitch displacement (vertical speed, rotation on Right axis) in degree / seconds
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.verticalRotationSensitivity = 50.0;

	};

	Navigation.prototype = new Behavior();
	Navigation.prototype.constructor = Navigation;
	Navigation.prototype.protoId = 'ED0414E7-007F-4FE8-9A46-9E55481F4BD6';

	Navigation.prototype.pureRuntimeAttributes = [
		'_camera', '_deltaTime', '_inputManager',
		'_isCursorInNeutralZone', '_isMousePressed', '_lastMousePosition',
		'_neutralZoneRadius', '_renderMngr', '_reticulePosition',
		'_reticuleWidget'
	].concat(Behavior.prototype.pureRuntimeAttributes);

	/**
	 * Process executed when STU.Navigation is activating
	 *
	 * @method
	 * @private
	 */
	Navigation.prototype.onActivate = function() {
		Behavior.prototype.onActivate.call(this);

		// Init of the keyboard and the mouse manager 
		this._inputManager = new STU.InputManager();

		if (this._inputManager === undefined || this._inputManager === null) {
			return this;
		}
		this._inputManager.initialize();
		this._inputManager.activate();
		this._inputManager.useMouse = true;

		this._camera = this.getActor();

		this.associatedTask = new NavigationTask(this);
		EP.TaskPlayer.addTask(this.associatedTask);
		if (EP.TaskPlayer.isPlaying())
			{this.associatedTask.start();}
	};

	/**
	 * Process executed when STU.Navigation is deactivating
	 *
	 * @method
	 * @private
	 */
	Navigation.prototype.onDeactivate = function() {
		EP.TaskPlayer.removeTask(this.associatedTask);
		delete this.associatedTask;

		if (this._inputManager !== undefined && this._inputManager !== null) {
			this._inputManager.deactivate();
			this._inputManager.dispose();
			this._inputManager = null;
		}

		if (this._reticuleWidget !== undefined && this._reticuleWidget !== null) {
			this._reticuleWidget.Dispose();
			this._reticuleWidget = null;
		}

		Behavior.prototype.onDeactivate.call(this);
	};

	/**
	 * Handle the behaviour of the reticule widget
	 *
	 * @method
	 * @private
	 */
	Navigation.prototype.handleReticule = function() {

		if (this.showReticule === true) {
			var inputManager = this._inputManager;
			if (inputManager === undefined || inputManager === null) {
				return this;
			}

			//get the axis used for mouse input
			var imAxis;
			if (inputManager.mouseAxis === 1)
				{imAxis = inputManager.axis1;}
			else
				{imAxis = inputManager.axis2;}

			// Mouse move only && mouse down only
			if (this.followMouse === true && this.navigateOnClick === true) {

				//Widget creation 
				if (this._isMousePressed === true && (this._reticuleWidget === undefined || this._reticuleWidget === null)) {
					this._reticulePosition = {
						'x': imAxis.x,
						'y': imAxis.y
					};

					this._reticuleWidget = this.buildReticule(); // jshint ignore:line
					this._reticuleWidget.BuildWidget(this._neutralZoneRadius, -this._reticulePosition.x, (inputManager.mouseInvertY ? -1 : 1) * this._reticulePosition.y);
				}

				//Widget behaviour 
				if (this._reticuleWidget !== undefined && this._reticuleWidget !== null) {
					// Hiding
					if (this._isMousePressed === false) {
						this._reticuleWidget.Dispose();
						this._reticuleWidget = null;
					} else { // Rotation
						//Is the mouse cursor in the neural zone ?
						var viewerSize = STU.RenderManager.getInstance().getViewerSize();
						var xpx = (viewerSize.x * 0.5) * (imAxis.x - this._reticulePosition.x);
						var ypx = (viewerSize.y * 0.5) * (imAxis.y - this._reticulePosition.y);
						var norm = xpx * xpx + ypx * ypx;

						if (norm <= Math.pow(this._neutralZoneRadius, 2)) {
							this._reticuleWidget.ShowArrow(false);
							this._reticuleWidget.SetOpacity(0.1);
						} else {
							var opacityLevel = Math.max(0.1, Math.sqrt(Math.pow(imAxis.x - this._reticulePosition.x, 2) + Math.pow(
								inputManager.axis1.y - this._reticulePosition.y, 2)));
							var rotationAngle = STU.Math.RadToDegree * Math.atan2((inputManager.mouseInvertY ? 1 : -1) * (imAxis.y -
								this._reticulePosition.y), -(imAxis.x - this._reticulePosition.x));

							this._reticuleWidget.ShowArrow(true);
							this._reticuleWidget.SetOpacity(opacityLevel);
							this._reticuleWidget.SetRotationInDegree(rotationAngle);
						}
					}
				}
			} else {
				//Widget creation 
				if (this._reticuleWidget === undefined || this._reticuleWidget === null) {
				    this._reticuleWidget = this.buildReticule();; // jshint ignore:line
					this._reticuleWidget.BuildWidget(this._neutralZoneRadius, 0, 0);
				}

				//Is the mouse cursor in the neural zone ?
				var viewerSize = STU.RenderManager.getInstance().getViewerSize();
				var xpx = (viewerSize.x * 0.5) * imAxis.x;
				var ypx = (viewerSize.y * 0.5) * imAxis.y;
				var norm = xpx * xpx + ypx * ypx;

				//-> yes : circle shape and no rotation
				if (norm <= this._neutralZoneRadius * this._neutralZoneRadius) {
					if (this.followMouse === false)
						{this._isCursorInNeutralZone = true;}
					this._reticuleWidget.ShowArrow(false);
					this._reticuleWidget.SetOpacity(0.1);
				} else { // not in neutral zone
					var opacityLevel = Math.max(0.1, Math.sqrt(Math.pow(imAxis.x, 2) + Math.pow(imAxis.y, 2)));
					var rotationAngle = STU.Math.RadToDegree * Math.atan2((this._inputManager.mouseInvertY ? 1 : -1) * imAxis.y, -
						imAxis.x);

					this._reticuleWidget.ShowArrow(true);
					this._reticuleWidget.SetOpacity(opacityLevel);
					this._reticuleWidget.SetRotationInDegree(rotationAngle);
				}
			}
		}
		// reticule is deactivated but not hidden
		else if (this.showReticule === false && !(this._reticuleWidget === undefined || this._reticuleWidget === null)) {
			this._reticuleWidget.Dispose();
			this._reticuleWidget = null;
		}
	};



	// Navigation events 

    /**
	 * This event is thrown when the navigation has reached the point that was targeted.
	 *
	 * @exports NavHasReachedEvent
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends EP.Event
	 * @memberOf STU
	 * @alias STU.NavHasReachedEvent
     */
	var NavHasReachedEvent = function(iPoint, iNav) {
		Event.call(this);

		/**
		 * Point that has been reached by the navigation.
		 *
		 * @public
		 * @type {STU.PointActor}
		 */
		this.targetPoint = iPoint !== undefined ? iPoint : null;

		/**
		 * The navigation that reached the point.
		 * @public
		 * @type {STU.Navigation}
		 */
		this.navigation = iNav !== undefined ? iNav : null;

	};


	NavHasReachedEvent.prototype = new Event();
	NavHasReachedEvent.prototype.constructor = NavHasReachedEvent;
	NavHasReachedEvent.prototype.type = 'NavHasReachedEvent';

	// Expose in STU namespace.
	STU.NavHasReachedEvent = NavHasReachedEvent;
	EventServices.registerEvent(NavHasReachedEvent);

	/**
	 * This event is thrown when the navigation has reached the end of the given path.
	 *
	 * @exports NavHasCompletedEvent
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends EP.Event
	 * @memberOf STU
	 * @alias STU.NavHasCompletedEvent
     */
	var NavHasCompletedEvent = function(iPath, iNav) {
		Event.call(this);

		/**
		 * Path that has been completed by the navigation.
		 *
		 * @type {STU.PathActor}
		 * @public
		 * @default null
		 */
		this.targetPath = iPath !== undefined ? iPath : null;

		/**
		 * The navigation that reached the end of the path.
		 * @type {STU.Navigation}
		 * @public
		 */
		this.navigation = iNav !== undefined ? iNav : null;

	};

	NavHasCompletedEvent.prototype = new Event();
	NavHasCompletedEvent.prototype.constructor = NavHasCompletedEvent;
	NavHasCompletedEvent.prototype.type = 'NavHasCompletedEvent';

	// Expose in STU namespace.
	STU.NavHasCompletedEvent = NavHasCompletedEvent;
	EventServices.registerEvent(NavHasCompletedEvent);


	/**
	 * Easing of quadratic in / out function
	 *
	 * @method
	 * @private
	 * @param  {number} t current time
	 * @param  {number} b beginning value
	 * @param  {number} c change in value
	 * @param  {number} d duration
	 * @return {number}   easing amount
	 */
	Navigation.prototype.easeInOutQuad = function(t, b, c, d) {
		if ((t /= d / 2) < 1) {return c / 2 * t * t + b;}
		return -c / 2 * ((--t) * (t - 2) - 1) + b;
	};

	/**
	 * Easing of quadratic out function
	 *
	 * @method
	 * @private
	 * @param  {number} t current time
	 * @param  {number} b beginning value
	 * @param  {number} c change in value
	 * @param  {number} d duration
	 * @return {number}   easing amount
	 */
	Navigation.prototype.easeOutQuad = function(t, b, c, d) {
		return -c * (t /= d) * (t - 2) + b;
	};

	/**
	 * Quintic easing in/out - acceleration until halfway, then deceleration
	 *
	 * @method
	 * @private
	 * @param  {number} t current time
	 * @param  {number} b beginning value
	 * @param  {number} c change in value
	 * @param  {number} d duration
	 * @return {number}   easing amount
	 */
	Navigation.prototype.easeInOutQuint = function(t, b, c, d) {
		t /= d / 2;
		if (t < 1) {return c / 2 * t * t * t * t * t + b;}
		t -= 2;
		return c / 2 * (t * t * t * t * t + 2) + b;
	};
	/**
	 * Cubic easing out - decelerating to zero velocity
	 *
	 * @method
	 * @private
	 * @param  {number} t current time
	 * @param  {number} b beginning value
	 * @param  {number} c change in value
	 * @param  {number} d duration
	 * @return {number}   easing amount
	 */
	Navigation.prototype.easeOutCubic = function(t, b, c, d) {
		t /= d;
		t--;
		return c * (t * t * t + 1) + b;
	};


	// Expose in STU namespace.
	STU.Navigation = Navigation;

	return Navigation;
});

define('StuCameras/StuNavigation', ['DS/StuCameras/StuNavigation'], function (Navigation) {
    'use strict';

    return Navigation;
});

/* global define */
define('DS/StuMiscContent/StuPlaneController',
	['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent', 'MathematicsES/MathsDef',
        'DS/EPInputs/EPKeyboard', 'DS/EPInputs/EPKeyboardPressEvent', 'DS/EPInputs/EPKeyboardReleaseEvent'],
	function (STU, EP, Behavior, Task, EventServices, Event, DSMath) {
	    'use strict';

	     var PlaneControllerTask = function (iComp) {
	        Task.call(this);
	        this.comp = iComp;
	    };

	    PlaneControllerTask.prototype = new Task();
	    PlaneControllerTask.prototype.constructor = PlaneControllerTask;

	    /**
		 * Method called each frame by the task manager
		 *
		 * @method
		 * @private
		 * @param  iExContext Execution context
		 */
	    PlaneControllerTask.prototype.onExecute = function (iExContext) {
	        if ('executeOneFrame' in this.comp) {
	            this.comp.executeOneFrame(iExContext);
	        }
	    };

	    //###################################################################################################
	    //                                              EVENTS                                              #
	    //###################################################################################################

	    //=====================================    Has Reached     ========================================

	    /**
		 * This event is thrown when the Plane has reached his target
		 *
		 * @param {STU.Actor} iPath  The target that has been reached by the actor
		 * @param {STU.Actor} iActor The STU.Actor that has reached the target
		 *
		 * @class 
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
	    var PlaneHasReachedEvent = function (iPath, iActor) {
	        Event.call(this);

	        /**
			 * The target that has been reached by the actor
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
	        this.path = iPath !== undefined ? iPath : null;

	        /**
			 * The STU.Actor that has reached the target
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
	        this.actor = iActor !== undefined ? iActor : null;
	    };

	    PlaneHasReachedEvent.prototype = new Event();
	    PlaneHasReachedEvent.prototype.constructor = PlaneHasReachedEvent;
	    PlaneHasReachedEvent.prototype.type = 'PlaneHasReachedEvent';

	    // Expose in STU namespace.
	    STU.PlaneHasReachedEvent = PlaneHasReachedEvent;
	    EP.EventServices.registerEvent(PlaneHasReachedEvent);

	    //=====================================    Has completed     ========================================

	    /**
		 * This event is thrown when the Plane has reached the end of a path
		 *
		 * @param {STU.Actor} iPath  The path that the STU.Actor had followed
		 * @param {STU.Actor} iActor The STU.Actor that has reached the end of the path
		 *
		 * @class 
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
	    var PlaneHasCompletedEvent = function (iPath, iActor) {
	        Event.call(this);

	        /**
			 * The path that the STU.Actor had followed
			 *
			 
			 * @type {STU.PathActor}
			 * @default
			 * @public
			 */
	        this.path = iPath !== undefined ? iPath : null;

	        /**
			 * The STU.Actor that has reached the end of the path
			 *
			 * @type {STU.Actor}
			 * @default
			 * @public
			 */
	        this.actor = iActor !== undefined ? iActor : null;
	    };

	    PlaneHasCompletedEvent.prototype = new Event();
	    PlaneHasCompletedEvent.prototype.constructor = PlaneHasCompletedEvent;
	    PlaneHasCompletedEvent.prototype.type = 'PlaneHasCompletedEvent';

	    // Expose in STU namespace.
	    STU.PlaneHasCompletedEvent = PlaneHasCompletedEvent;
	    EP.EventServices.registerEvent(PlaneHasCompletedEvent);

	    //=====================================    Has Took off     ========================================

	    /**
		 * This event is thrown when the Plane has took off from any runway or position
		 *
		 * @class 
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
	    var PlaneHasTookOffEvent = function () {
	        Event.call(this);
	    };

	    PlaneHasTookOffEvent.prototype = new Event();
	    PlaneHasTookOffEvent.prototype.constructor = PlaneHasTookOffEvent;
	    PlaneHasTookOffEvent.prototype.type = 'PlaneHasTookOffEvent';

	    // Expose in STU namespace.
	    STU.PlaneHasTookOffEvent = PlaneHasTookOffEvent;
	    EP.EventServices.registerEvent(PlaneHasTookOffEvent);

	    //=====================================    Has Land     ========================================

	    /**
		 * This event is thrown when the Plane has land on any runway
		 *
		 * @class 
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
	    var PlaneHasLandEvent = function () {
	        Event.call(this);
	    };

	    PlaneHasLandEvent.prototype = new Event();
	    PlaneHasLandEvent.prototype.constructor = PlaneHasLandEvent;
	    PlaneHasLandEvent.prototype.type = 'PlaneHasLandEvent';

	    // Expose in STU namespace.
	    STU.PlaneHasLandEvent = PlaneHasLandEvent;
	    EP.EventServices.registerEvent(PlaneHasLandEvent);

	    //###################################################################################################
	    //                                              CONSTRUCTOR                                         #
	    //###################################################################################################

	    /**
         * Describe a Plane controller behavior
         *
         * @exports PlaneController
         * @class 
         * @constructor
         * @noinstancector
         * @public
         * @extends {STU.Behavior}
         * @memberOf STU
         * @alias STU.PlaneController
         */
	    var PlaneController = function () {
	        Behavior.call(this);
	        this.name = 'PlaneController';
	        this.associatedTask;

	        // Public

	        /**
			* The maximum speed (m/s)
			 * @type {Number}
			* @public
			 */
	        this.maximumSpeed = 277.778;

	        /**
			 * The acceleration (m.s-2)
			 * @type {Number}
			* @public
			*/
	        this.acceleration = 20;

	        /**
			 * The flight altitude (m)
			 * @type {Number}
			 * @public
			 */
	        this.flightAltitude = 190;


	        /**
			 * The angular speed (deg/s)
			 * @type {Number}
			 * @public
			 */
	        this.angularSpeed = 0.5;


	        /**
            * The movement smoothness coefficient
            * @type {Number}
			 * @public
            */
	        this.smoothness = 1.0;

	        /**
            * The inertia factor applied on the plane
            * @type {Number}
			 * @public
            */
	        this.inertiaFactor = 1.0;

	        /**
            * Permit to automatically found the direction vector according to the plane's shape
            * @type {Boolean}
			 * @public
            */
	        this.computeDirectionAxis = true;

	        /**
            * The plane's direction axis
            * @type {Number}
			 * @public
            */
	        this.directionAxis = 0;

	        /**
            * Permit to control the plane using the gamepad's input
            * @type {Boolean}
			 * @public
            */
	        this.useGamepad = false;

	        /**
            * The mapped key to go up
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.moveUp = EP.Keyboard.EKey.eUp;

	        /**
            * The mapped key to go down
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.moveDown = EP.Keyboard.EKey.eDown;

	        /**
            * The mapped key to rotate on the right using the roll axis
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.rollRight = EP.Keyboard.EKey.ePageDown;

	        /**
            * The mapped key to rotate on the left using the roll axis
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.rollLeft = EP.Keyboard.EKey.ePageUp;

	        /**
            * The mapped key to turn to the left
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.turnLeft = EP.Keyboard.EKey.eLeft;

	        /**
            * The mapped key to turn to the right
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.turnRight = EP.Keyboard.EKey.eRight;

	        /**
            * The mapped key to increase the plane's speed
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.accelerate = EP.Keyboard.EKey.eSpace;

	        /**
            * The mapped key to increase the plane's speed
            * @type {EP.Keyboard.EKey}
            * @public
            */
	        this.decelerate = EP.Keyboard.EKey.eShift;

	        // Private

	        /**
			 * The driving runway defined for the "Drives On" capacity.
			 * @private
			 * @type {Object}
			 */
	        this._drivingRunway = null;

	        /**
			 * The defined path defined for the "Flies Along" capacity.
			 * @private
			 * @type {Object}
			 */
	        this._flyingPathTarget = null;


	        /**
			 * The time needed to reach the acceleration value
			 * @private
			 * @type {Number}
			 */
	        this._timeNeededToReachMaxAcceleration = 10; //10 sec

	        /**
			 * The current acceleration duration
			 * @private
			 * @type {Number}
			 */
	        this._currentAccelerationTime = 0.0;

	        /**
			 * The current acceleration value
			 * @private
			 * @type {Number}
			 */
	        this._currentAcceleration = 0.0;

	        /**
			 * The time needed to reach a null acceleration from its maximum value
			 * @private
			 * @type {Number}
			 */
	        this._timeNeededToReachMaxDecceleration = 10; //10 sec

	        /**
			 * The current deceleration duration
			 * @private
			 * @type {Number}
			 */
	        this._currentDeccelerationTime = 0.0;

	        /**
			 * The current deceleration value
			 * @private
			 * @type {Number}
			 */
	        this._currentDecceleration = 0.0;

	        /**
			 * The current speed
			 * @private
			 * @type {Number}
			 */
	        this._currentSpeed = 0;

	        /**
			 * 
			 * @private
			 * @type {Number}
			 */
	        this._applyPosition = null;

	        /**
			 * 
			 * @private
			 * @type {Number}
			 */
	        this._takeOffState = 0;

	        /**
			 * Air density
			 * @private
			 * @type {Number}
			 */
	        //this._airDensity = 1.2; // 1.1 --> 1.4

	        /**
			 * Plane's velocity
			 * @private
			 * @type {DSMath.Vector3D}
			 */
	        this._velocity = new DSMath.Vector3D();


	        /**
			 * Local destination used for serveral part of the GoTo function
			 * @private
			 * @type {DSMath.Vector3D}
			 */
	        this._localDestination = new DSMath.Vector3D();


	        /**
			 * Anticipated landing point C is a plane's destination at which the plane reorientate to the runaway
			 * @private
			 * @type {DSMath.Vector3D}
			 */
	        this._anticipatedLandingPointC = new DSMath.Vector3D(); // Before reorientation


	        /**
			 * Anticipated landing point B is a plane's destination at which the plane is well oriented and start to loose altitude in order to land.
			 * @private
			 * @type {DSMath.Vector3D}
			 */
	        this._anticipatedLandingPointB = new DSMath.Vector3D(); // After reorientation


	        /**
			 * Landing runaway direction
			 * @private
			 * @type {DSMath.Vector3D}
			 */
	        this._landingDirection = new DSMath.Vector3D();

	        /**
			 * Power used (0 to 1, 1 means maximum speed)
			 * @private
			 * @type {Number}
			 */
	        this._power = 0.0; // Percentage 0->1


	        /**
			 * Takeoff speed
			 * @private
			 * @type {Number}
			 */
	        this._takeoffSpeed = 0.0;

	        /**
			 * Special ratio depending of the plane's aspect
			 * @private
			 * @type {Number}
			 */
	        //this._aspectRatio = 0.0;

	        /**
			 * Current plane's yaw
			 * @private
			 * @type {Number}
			 */
	        this._yaw = 0.0;

	        /**
			 * Current plane's pitch
			 * @private
			 * @type {Number}
			 */
	        this._pitch = 0.0;

	        /**
			 * Current plane's roll
			 * @private
			 * @type {Number}
			 */
	        this._roll = 0.0;

	        /**
			 * The angle between plane's front direction and destination
			 * @private
			 * @type {Number}
			 */
	        this._angleToDestination = 0.0;

	        /**
			 * The angle sign between plane's front direction and destination
			 * @private
			 * @type {Number}
			 */
	        this._angleSignToDestination = 0.0;

	        /**
			 * Angle reference for plane's rotation
			 * @private
			 * @type {Number}
			 */
	        this._startRotatingAngle = 0.0;

	        /**
			 * Distance reference for plane's rotation
			 * @private
			 * @type {Number}
			 */
	        this._startRotatingDistance = 0.0;

	        /**
			 * Height reference for takeoff
			 * @private
			 * @type {Number}
			 */
	        this._takeOffStartHeight = 0.0;

	        /**
			 * Time reference for actions in GoTo function
			 * @private
			 * @type {Number}
			 */
	        this._actionCurrentTime = 0.0;

	        /**
			 * Total action time reference
			 * @private
			 * @type {Number}
			 */
	        this._actionTotalTime = 0.0;

	        /**
			 * Current distance in the FollowPath function
			 * @private
			 * @type {Number}
			 */
	        this._currentDistanceFollowPath = 0.0;

	        /**
			 * Current landing height
			 * @private
			 * @type {Number}
			 */
	        this._landingHeight = 0.0;

	        /**
			 * Current landing distance to the runaway
			 * @private
			 * @type {Number}
			 */
	        this._landingDistance = 0.0;

	        /**
			 * Start landing altitude reference
			 * @private
			 * @type {Number}
			 */
	        this._startLandingAltitude = 0.0;

	        /**
			 * Start landing distance reference
			 * @private
			 * @type {Number}
			 */
	        this._startLandingDistance = 0.0;

	        /**
			 * Landing anticipation distance reference
			 * @private
			 * @type {Number}
			 */
	        this._anticipatedDistance = 0.0;

	        /**
			 * GoTo state ( 0 --> 6)
			 * @private
			 * @type {Number}
			 */
	        this._goToState = 0;

	        /**
			 * Path total length
			 * @private
			 * @type {Number}
			 */
	        this._pathLength = 0;

	        /**
			 * KeyPressed Objet to handle triggers
			 * @private
			 * @type {Object}
			 */
	        this._keyPressed = {};
	        this._keyPressed.accelerate = false;
	        this._keyPressed.decelerate = false;
	        this._keyPressed.turnLeft = false;
	        this._keyPressed.turnRight = false;
	        this._keyPressed.moveUp = false;
	        this._keyPressed.moveDown = false;
	        this._keyPressed.rollRight = false;
	        this._keyPressed.rollLeft = false;

	        /**
			 * GamepadBtnPressed Objet to handle triggers
			 * @private
			 * @type {Object}
			 */
	        this._gamepadBtnPressed = {};
	        this._gamepadBtnPressed.accelerate = false;
	        this._gamepadBtnPressed.decelerate = false;
	        this._gamepadBtnPressed.turnLeft = false;
	        this._gamepadBtnPressed.turnRight = false;
	        this._gamepadBtnPressed.moveUp = false;
	        this._gamepadBtnPressed.moveDown = false;
	        this._gamepadBtnPressed.rollRight = false;
	        this._gamepadBtnPressed.rollLeft = false;

	        /**
			 * The plane's initial matrix
			 * @private
			 * @type {DSMath.Matrix3x3}
			 */
	        this._initialMatrix = null;

	        /**
			 * Reorientating matrix after front axis detection
			 * @private
			 * @type {DSMath.Matrix3x3}
			 */
	        this._reorientationMatrix = null;

	        /**
			 * GoTo, or Follow Path target
			 * @private
			 * @type {Object}
			 */
	        this._target = null;

	        /**
			 * True if the plane is landed
			 * @private
			 * @type {Boolean}
			 */
	        this._isLanded = true;

	        /**
			 * True if the plane is using Follow Path function
			 * @private
			 * @type {Boolean}
			 */
	        this._isFollowingPath = false;

	        /**
			 * True if the plane is using GoTo function
			 * @private
			 * @type {Boolean}
			 */
	        this._isGoToState = false;

	        /**
			 * True if the plane is at the takeoff state
			 * @private
			 * @type {Boolean}
			 */
	        this._isTakeOffState = false;

	        /**
			 * True if the plane is at the cruising altitude
			 * @private
			 * @type {Boolean}
			 */
	        this._isCruisingState = false;

	        /**
			 * Store previous transform, used for the stabilisator
			 * @private
			 * @type {DSMath.Transformation}
			 */
	        this._oldTransform = null;

	        /**
			 * Keyboard event listener
			 * @private
			 * @type {Object}
			 */
	        this._keyboardPressCb = null;

	        /**
			 * Plane's Scale
			 * @private
			 * @type {Number}
			 */
	        this._scale = 1;

	        /**
			 * Array storing the previous position for stabilisation
			 * @private
			 * @type {Array}
			 */
	        this._queueStabilisator = [];


	        /**
			 * Altitude offset applied the flight altitude
			 * @private
			 * @type {Array}
			 */
	        this._altitudeOffset = 0;

	        /**
			 * The computed length use to define the plane orientation
			 * @private
			 * @type {Number}
			 */
	        this._length = 0;

	        /**
			 * The computed width use to define the plane orientation
			 * @private
			 * @type {Number}
			 */
	        this._width = 0;

	        /**
			 * the vector from the origin of the actor to its center
			 * @private
			 * @type {Number}
			 */
	        this._worldPositionOffset = null;

	        /**
			 * the vector from the origin of the actor to the center of it's supposed wheels
			 * @private
			 * @type {Number}
			 */
	        this._worldLowPositionOffset = null;

	        this._drivingEndPhase = false;

	        this._globeLocation = null;
	    };


	    PlaneController.prototype = new Behavior();
	    PlaneController.prototype.constructor = PlaneController;
	    PlaneController.prototype.pureRuntimeAttributes = ['_keyboardPressCb'].concat(Behavior.prototype.pureRuntimeAttributes);

		/**
         * An enumeration of supported axes</br>
         *
         * @enum {number}
         * @private         
         */
		PlaneController.EAxis = {
			/** @private */
			eX0: 0,
			/** @private */
			eX1: 1,
			/** @private */
			eY0: 2,
			/** @private */
			eY1: 3,
			/** @private */
			eZ0: 4,
			/** @private */
	        eZ1: 5
	    };

	    //###################################################################################################
	    //                                         STANDARDS METHODS                                        #
	    //###################################################################################################

	    /**
		 * Process executed when STU.PlaneController is activating
		 *
		 * @method
		 * @private
		 */
	    PlaneController.prototype.onActivate = function () {
	        Behavior.prototype.onActivate.call(this);
	        this.associatedTask = new PlaneControllerTask(this);
	        EP.TaskPlayer.addTask(this.associatedTask);

	        this._keyboardPressCb = STU.makeListener(this, 'keyboardPress');
	        EventServices.addListener(EP.KeyboardPressEvent, this._keyboardPressCb);

	        this._keyboardReleaseCb = STU.makeListener(this, 'keyboardRelease');
	        EventServices.addListener(EP.KeyboardReleaseEvent, this._keyboardReleaseCb);

	        if (this.useGamepad) {
	            this.gamepadCB = STU.makeListener(this, 'onGamepadEvent');
	            EP.EventServices.addListener(EP.GamepadEvent, this.gamepadCB);
	        }

	        // Special inits
	        this._altitudeOffset = this.actor.getPosition().z;
	        this._flightAltitude = this.flightAltitude + this._altitudeOffset;
	        this._plane = this.getActor();
	        this._globeLocation = this._plane.getLocation();
	        this.computeInitialValues();
	        this._initialMatrix = this._plane.getTransform().matrix.clone();
	        this._reorientationMatrix = new DSMath.Matrix3x3();
	        this.setOrientationMatrix();
	        this._scale = this._plane.getScale();
	        this._initialRotationInverse = this._initialMatrix.clone().multiplyScalar(1 / this._scale);
	        this._initialRotationInverse = this._initialRotationInverse.getInverse();
	    };

	    /**
		 * Process executed when STU.PlaneController is deactivating
		 * @method
		 * @private
		 */
	    PlaneController.prototype.onDeactivate = function () {
	        EventServices.removeListener(EP.KeyboardEvent, this._keyboardPressCb);
	        delete this._keyboardPressCb;

	        EventServices.removeListener(EP.KeyboardEvent, this._keyboardReleaseCb);
	        delete this._keyboardReleaseCb;

	        if (this.useGamepad && this.gamepadCB != null && this.gamepadCB != undefined) {
	            EventServices.removeListener(EP.GamepadEvent, this.gamepadCB);
	            delete this.gamepadCB;
	        }

	        // EP.EventServices.removeListener(EP.GamepadEvent, this.gamepadCB);
	        // delete this.gamepadCB;

	        EP.TaskPlayer.removeTask(this.associatedTask);
	        delete this.associatedTask;

	        Behavior.prototype.onDeactivate.call(this);
	    };

	    /**
		 * Executed at each frame
		 * @method
		 * @private
		 */
	    PlaneController.prototype.executeOneFrame = function (iDelta) {
	        if (this._oldTransform !== null) {
	            this._plane.setTransform(this._oldTransform);
	        }

	        if (this._isTakingOffState) {
	            this.updateTakeOff(iDelta);
	            //this.updateTakeOffManaged(iDelta);
	        }
	        else if (this._isFlyingToState) {
	            this.updateFliesTo(iDelta);
	        }
	        else if (this._isFlyingAlongState) {
	            this.updateFliesAlong(iDelta);
	        }
	        else if (this._isLandingOnState) {
	            this.updateLandsOn(iDelta);
	        }
	        else if (this._isDrivingOnState) {
	            this.updateDrivesOn(iDelta);
	        }
	        else {
	            this.updateManualControl(iDelta);
	        }

	        this.adaptVelocity(iDelta, false);
	        this.computeVelocity();
	        this.updateTransform(iDelta);
	        this.updateAverageTransform();

	        var t = this._plane.getTransform().clone();

	        var initialOffsetClone = this._initialPositionOffset.clone();
	        initialOffsetClone.applyMatrix3x3(this._initialRotationInverse);

	        var initialLowOffsetClone = this._initialLowPositionOffset.clone();
	        initialLowOffsetClone.applyMatrix3x3(this._initialRotationInverse);

	        this._worldPositionOffset = this.vectorLocalToWorldReferential(initialOffsetClone, t);
	        this._worldLowPositionOffset = this.vectorLocalToWorldReferential(initialLowOffsetClone, t);


	        //[DEBUG]
	        /*var localTransfo = new DSMath.Transformation();
	        localTransfo.vector = DSMath.Vector3D.add(t.vector, this._worldPositionOffset);
	        var iColor = new STU.Color(0, 100, 255);
	        var render = STU.RenderManager.getInstance();
	        render._createSphere({ radius: 2000, position: localTransfo, color: iColor, alpha: 255, lifetime: 0 });

	        localTransfo.vector = DSMath.Vector3D.add(t.vector, this._worldLowPositionOffset);
	        iColor = new STU.Color(0, 250, 100);
	        render._createSphere({ radius: 2000, position: localTransfo, color: iColor, alpha: 255, lifetime: 0 });*/
	    };


	    //###################################################################################################
	    //                                      PLANE'S DIMENSIONS                                          #
	    //###################################################################################################

	    /**
		 * Compute the plane's matrix according to the defined direction axis.
		 * @method
		 * @private
		 */
	    PlaneController.prototype.setOrientationMatrix = function () {
	        var rotVector = new DSMath.Vector3D(0, 0, 1);
	        var angle = 0;
	        var angleX = 0;
	        var angleY = 0;
	        if (this.directionAxis === PlaneController.EAxis.eX0) {//if (this.frontVector === 'x') {
	            angle = 0;
	            angleX = 0;
	            angleY = 0;
	        }
	        if (this.directionAxis === PlaneController.EAxis.eX1) {//if (this.frontVector == '-x') {
	            angle = Math.PI;
	            angleX = Math.PI;
	            angleY = Math.PI;
	        }
	        if (this.directionAxis === PlaneController.EAxis.eY1) {//if (this.frontVector === '-y') {
	            angle = -Math.PI / 2;
	            angleX = 0;
	            angleY = 0;
	        }
	        if (this.directionAxis === PlaneController.EAxis.eY0) {//if (this.frontVector === 'y') {
	            angle = Math.PI / 2;
	            angleX = Math.PI;
	        }

	        //var m0 = new DSMath.Matrix3x3();
	        //m0.makeRotation(DSMath.Vector3D.zVect, angle);
	        //m0.makeRotationFromEuler([angle, angleX, angleY]);

	        /*this._reorientationMatrix.setFirstColumn(m0.getFirstColumn());
			this._reorientationMatrix.setSecondColumn(m0.getSecondColumn());
			this._reorientationMatrix.setThirdColumn(m0.getThirdColumn());*/

	        this._reorientationMatrix.makeRotation(rotVector, angle);//this._reorientationMatrix.setRotation(rotVector, angle);
	        this.setLocalAxis();
	    };

	    /**
		 * Compute the plane's matrix according to the defined direction axis.
		 * @method
		 * @private
		 */
	    PlaneController.prototype.setLocalAxis = function () {
	        var XVector = this._plane.getTransform().matrix.getFirstColumn().normalize();
	        var YVector = this._plane.getTransform().matrix.getSecondColumn().normalize();
	        var ZVector = this._plane.getTransform().matrix.getThirdColumn().normalize();
	        switch (this.directionAxis) {
	            case PlaneController.EAxis.eX0:
	                this._localFront = XVector;// on suppose +X comme front axis
	                this._localRight = YVector;// on suppose +Y comme right axis
	                this._localUp = ZVector;// on suppose +Z comme up axis
	                break;
	            case PlaneController.EAxis.eX1:
	                this._localFront = XVector.negate();// on suppose -X comme front axis
	                this._localRight = YVector;// on suppose +Y comme right axis
	                this._localUp = ZVector;// on suppose +Z comme up axis
	                break;
	            case PlaneController.EAxis.eY0:
	                this._localFront = YVector;// on suppose +Y comme front axis
	                this._localRight = XVector;// on suppose +X comme right axis
	                this._localUp = ZVector;// on suppose +Z comme up axis
	                break;
	            case PlaneController.EAxis.eY1:
	                this._localFront = YVector.negate();// on suppose -Y comme front axis
	                this._localRight = XVector;// on suppose +X comme right axis
	                this._localUp = ZVector;// on suppose +Z comme up axis
	                break;
	            default:
	                this._localFront = YVector;// on suppose +Y comme front axis
	                this._localRight = XVector;// on suppose +X comme right axis
	                this._localUp = ZVector;// on suppose +Z comme up axis
	                break;
	        }
	    };

	    /**
		 * Init function to computes required values
		 * @method
		 * @private
		 */
	    PlaneController.prototype.computeInitialValues = function () {
	        this._velocity.set(0, 0, 0);
	        this._takeoffSpeed = this.maximumSpeed * 0.33;

	        //storage unit of angular velocity is: turn per min.
	        //this.angularSpeed = 2 * Math.PI / 60 * this.angularSpeed; 

	        if (this.angularSpeed < 0) {
	            this.angularSpeed = this.angularSpeed * -1;
	            console.log("[Plane Controller]: The angular speed should be positive.");
	        }

	        if (this.inertiaFactor < 0) {
	            this.inertiaFactor = 1;
	            console.log("[Plane Controller]: The angular speed should not be negative.");
	        }
	        else if (this.inertiaFactor === 0) {
	            this.inertiaFactor = 1;
	        }

	        //[DEBUG]
	        /*
	        console.log('[Plane Controller] Maximum Speed: ' + this.maximumSpeed + ' m/s');
	        console.log('[Plane Controller] Angular Speed: ' + this.angularSpeed + ' rad/s');
	        console.log('[Plane Controller] Takeoff speed computed: ' + this._takeoffSpeed + ' m/s');
	        console.log('[Plane Controller] Flight Altitude: ' + this.flightAltitude + ' mm');
	        console.log('[Plane Controller] Flight Altitude (Relative): ' + (this._altitudeOffset + this.flightAltitude) + ' mm');
	        */

	        this.findLowestPoint();

	        if (this.computeDirectionAxis) {
	            this.checkDimension();
	        }
	    };

	    /**
		 * Analyse the plane's dimensions
		 * @method
		 * @private
		 */
	    PlaneController.prototype.checkDimension = function () {
	        //var testPosition = this._plane.getTransform().vector.clone();
	        var planeTransformRef = this._plane.getTransform().clone();
	        planeTransformRef.vector = DSMath.Vector3D.add(planeTransformRef.vector, this._positionOffset);

	        var isClickable = this._plane.clickable;
	        this._plane.clickable = true;

	        var rayOrigin = planeTransformRef.vector.clone();
	        //rayOrigin.z += 10000000; // 10 km
	        rayOrigin.z += 5000;// 5m

	        this._saveLen1 = planeTransformRef.vector.clone();
	        this._saveLen2 = planeTransformRef.vector.clone();
	        this._saveWid1 = planeTransformRef.vector.clone();
	        this._saveWid2 = planeTransformRef.vector.clone();

	        var length = this.checkLenX(rayOrigin, 1000);
	        var width = this.checkLenY(rayOrigin, 1000);
	        var value1, value2;

	        if (length > width) {
	            this._length = length;
	            this._width = width;
	            value1 = this.checkLenY(this._saveLen1, 100);
	            value2 = this.checkLenY(this._saveLen2, 100);

	            if (value1 > value2) {
	                this.directionAxis = PlaneController.EAxis.eX1; //this.frontVector = '-x';
	            } else {
	                this.directionAxis = PlaneController.EAxis.eX0; //this.frontVector = 'x';
	            }
	        } else {
	            this._length = width;
	            this._width = length;
	            value1 = this.checkLenX(this._saveWid1, 100);
	            value2 = this.checkLenX(this._saveWid2, 100);
	            if (value1 > value2) {
	                this.directionAxis = PlaneController.EAxis.eY1; //this.frontVector = '-y';
	            } else {
	                this.directionAxis = PlaneController.EAxis.eY0; //this.frontVector = 'y';
	            }
	        }

	        //[DEBUG]
	        // console.log("["+this.actor.name+"] length: " + length);
	        // console.log("["+this.actor.name+"] width: " + width);
	        // console.log("["+this.actor.name+"] Direction Axis: " + this.directionAxis);
	        // console.log("=====================================");

	        this._plane.clickable = isClickable;
	    };

	    /**
		 * check the lenght of the plane in the X axis
		 * @param {DSMath.Vector3D} vector - The ray's origin
		 * @param {number} increment - the increment distance
		 * @method
		 * @private
		 */
	    PlaneController.prototype.checkLenX = function (vector, increment) {
	        var length = 0;
	        var isHit = true;
	        var testRay = vector.clone();

	        var XVector = this._plane.getTransform().matrix.getFirstColumn().clone();

	        XVector.normalize();
	        XVector.multiplyScalar(increment * 10);

	        while (length < 1000 && isHit) { //Raycast + move on X Axis until we don't detect the plane
	            testRay.add(XVector);
	            length += 10 * increment / 1000; // Length express in meter
	            isHit = this.isZRaycastCollide(testRay);
	        }

	        XVector.multiplyScalar(0.1);

	        while (length > 0 && !isHit) { //Raycast + move on -X Axis until we detect the plane
	            testRay.sub(XVector);
	            length -= 1 * increment / 1000; // Length express in meter
	            isHit = this.isZRaycastCollide(testRay);
	            if (isHit) {
	                this._saveLen1 = testRay.clone(); // Save the first extremity 
	                this._saveLen1.sub(XVector.multiplyScalar(2)); // sub the increment twice in oder to don't miss the plane
	            }
	        }
	        testRay = vector.clone();	// Restart from the middle
	        XVector.multiplyScalar(10);

	        while (length < 1000 && isHit) {
	            testRay.sub(XVector);
	            length += 10 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	        }

	        XVector.multiplyScalar(0.1);

	        while (length > 0 && !isHit) {
	            testRay.add(XVector);
	            length -= 1 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	            if (isHit) {
	                this._saveLen2 = testRay.clone();	// Save the second extremity 
	                this._saveLen2.add(XVector.multiplyScalar(2));	// add the increment twice in oder to don't miss the plane
	            }
	        }

	        return length;
	    };

	    /**
		 * check the lenght of the plane in the Y axis
		 * @param {DSMath.Vector3D} vector - The ray's origin
		 * @param {number} increment - the increment distance
		 * @method
		 * @private
		 */
	    PlaneController.prototype.checkLenY = function (vector, increment) {
	        var length = 0;
	        var isHit = true;
	        var testRay = vector.clone();

	        var YVector = this._plane.getTransform().matrix.getSecondColumn().clone();
	        YVector.normalize();
	        YVector.multiplyScalar(increment * 10);

	        // Test Length
	        while (length < 1000 && isHit) {
	            testRay.add(YVector);
	            length += 10 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	        }
	        YVector.multiplyScalar(0.1);
	        while (length > 0 && !isHit) {

	            testRay.sub(YVector);
	            length -= 1 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	            if (isHit) {
	                this._saveWid1 = testRay.clone();
	                this._saveWid2.sub(YVector.multiplyScalar(2));
	            }
	        }

	        testRay = vector.clone();
	        YVector.multiplyScalar(10);
	        while (length < 1000 && isHit) {
	            testRay.sub(YVector);
	            length += 10 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	        }
	        YVector.multiplyScalar(0.1);
	        while (length > 0 && !isHit) {
	            testRay.add(YVector);
	            length -= 1 * increment / 1000;
	            isHit = this.isZRaycastCollide(testRay);
	            if (isHit) {
	                this._saveWid2 = testRay.clone();
	                this._saveWid2.add(YVector.multiplyScalar(2));
	            }
	        }
	        return length;
	    };

	    /**
		 * Do a raycast and test if it's collide
		 * @param {DSMath.Vector3D} vector - The ray's origin
		 * @method
		 * @private
		 */
	    PlaneController.prototype.isZRaycastCollide = function (vector) {
	        var ray = new STU.Ray();
	        ray.origin = vector.clone();
	        ray.direction.x = 0;
	        ray.direction.y = 0;
	        ray.direction.z = -1;
	        ray.length = 50000;
	        var renderManager = STU.RenderManager.getInstance();
	        //var intersectArray = renderManager._pickFromRay(ray);
	        var myLocation = this._globeLocation; // myLocation != null ==> we are in globe context
	        var intersectArray = renderManager._pickFromRay(ray, true, false, myLocation); // the case where myLocation is null is handle in the picking function
	        if (intersectArray.length > 0) {
	            for (var i = 0; i < intersectArray.length; i++) {
	                if (intersectArray[i].actor !== null && intersectArray[i].actor !== undefined) {
	                    if (intersectArray[i].actor === this._plane) {
	                        return true;
	                    }
	                }
	            }
	            //return true;
	            return false;
	        } else {
	            return false;
	        }
	    };

	    /**
         * Check for the lowest point of the plane
         * @method
         * @private
         */
	    PlaneController.prototype.findLowestPoint = function () {
	        var iLocalTransformation = this.actor.getTransform().clone();
	        var MyParams = { excludeChildren: 0, orientation: iLocalTransformation };
	        var iBBox = this.actor.getOrientedBoundingBox(MyParams);

	        /*var interPoint = iBBox.high.clone();
	        interPoint.x = iBBox.low.x;
	        interPoint.y = iBBox.low.y;
	        var ZDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;
	        interPoint.x = iBBox.high.x;
	        interPoint.z = iBBox.low.z;
	        var XDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;
	        interPoint.x = iBBox.low.x;
	        interPoint.y = iBBox.high.y;
	        var YDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;*/

	        //Calculate the center of the plane
	        var center = new DSMath.Vector3D(); // Coord dans le repere local du cube
	        center.x = (iBBox.high.x + iBBox.low.x) * 0.5;
	        center.y = (iBBox.high.y + iBBox.low.y) * 0.5;
	        center.z = (iBBox.high.z + iBBox.low.z) * 0.5;

	        //Calculate the lowest position of the plane
	        var lowPos = center.clone();
	        lowPos.z = iBBox.low.z;

	        //Express in world Position
	        center.add(iLocalTransformation.vector);
	        lowPos.add(iLocalTransformation.vector);

	        //Calculate the translation Origin -> Center
	        var centerOffset = DSMath.Vector3D.sub(center, iLocalTransformation.vector);
	        centerOffset = centerOffset.applyTransformation(iLocalTransformation);
	        var c = DSMath.Vector3D.add(centerOffset, iLocalTransformation.vector);
	        center = c.clone();
	        //center.z = center.z - (ZDimension * 0.5);

	        this._applyPosition = center;
	        this._positionOffset = centerOffset;

	        //Calculate the translation Origin -> LowPosition
	        var lowPositionOffset = DSMath.Vector3D.sub(lowPos, iLocalTransformation.vector);
	        lowPositionOffset = lowPositionOffset.applyTransformation(iLocalTransformation);
	        this._lowPositionOffset = lowPositionOffset;

	        this._initialLowPositionOffset = lowPositionOffset.clone();
	        this._initialPositionOffset = centerOffset.clone();


	        //[DEBUG]
	        /*var localTransfo = new DSMath.Transformation();
	        localTransfo.vector = DSMath.Vector3D.add(this.actor.getPosition(), this._initialPositionOffset);
	        var iColor = new STU.Color(0, 100, 255);
	        var render = STU.RenderManager.getInstance();
	        render._createSphere({ radius: 2000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	        localTransfo.vector = DSMath.Vector3D.add(this.actor.getPosition(), this._initialLowPositionOffset);
	        iColor = new STU.Color(0, 250, 100);
	        render._createSphere({ radius: 2000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });*/
	    };

	    /**
         * Set the plane position according to its lowest point
		 * @method
		 * @private
		 */
	    PlaneController.prototype.setPlanePosition = function (iPosition) {
	        var goodArgsType = true;
	        if (iPosition === null || iPosition === undefined || !goodArgsType) {
	            //console.warn("[Plane Controller]: wrong type of parameter inquired");
	        }
	        else {
	            var modifiedPos = DSMath.Vector3D.sub(iPosition, this._lowPositionOffset);
	            this._plane.setPosition(modifiedPos);
	            this._oldTransform = this._plane.getTransform().clone();
	        }
	    };

	    //###################################################################################################
	    //                                              MOVEMENTS                                           #
	    //###################################################################################################

	    /**
		 * Update to speed Up
		 * @method
		 * @private
		 */
	    PlaneController.prototype.speedUpFunc = function (iDelta) {
	        this.accelerateFunc(iDelta);
	        this._power = this._currentSpeed / this.maximumSpeed;
	    };

	    /**
		 * Update to speed Down
		 * @method
		 * @private
		 */
	    PlaneController.prototype.speedDownFunc = function (iDelta) {
	        this.decelerateFunc(iDelta);
	        this._power = this._currentSpeed / this.maximumSpeed;
	    };

	    /**
		 * Update to move up
		 * @method
		 * @private
		 */
	    PlaneController.prototype.moveUpFunc = function (iDelta, iCoeff) {
	        //var toAdd = this._power * 0.2 * this.maneuverability * iDelta.deltaTime / 1000 * argm * (1 + this._pitch / (0.25 * this.maneuverability));
	        if (iCoeff === null || iCoeff === undefined) {
	            iCoeff = 1;
	        }
	        var toAdd = iCoeff * this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._pitch += toAdd;

	        if (this._pitch > 1) {
	            this._pitch = 1;
	        }
	    };

	    /**
		 * Update to move down
		 * @method
		 * @private
		 */
	    PlaneController.prototype.moveDownFunc = function (iDelta, iCoeff) {
	        if (iCoeff === null || iCoeff === undefined) {
	            iCoeff = 1;
	        }
	        var toAdd = iCoeff * this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._pitch -= toAdd;

	        if (this._pitch < -1) {
	            this._pitch = -1;
	        }
	    };

	    /**
		 * Update to turn right
		 * @method
		 * @private
		 */
	    PlaneController.prototype.turnRightFunc = function (iDelta, iForceUpdate) {
	        var toAdd = this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._yaw -= toAdd;

	        if (!iForceUpdate && this._yaw < -1) {
	            this._yaw = -1;
	        }
	    };

	    /**
		 * Update to to turn left
		 * @method
		 * @private
		 */
	    PlaneController.prototype.turnLeftFunc = function (iDelta, iForceUpdate) {
	        var toAdd = this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._yaw += toAdd;

	        if (!iForceUpdate && this._yaw > 1) {
	            this._yaw = 1;
	        }
	    };

	    /**
		 * Update to turn right
		 * @method
		 * @private
		 */
	    PlaneController.prototype.rollRightFunc = function (iDelta) {
	        var toAdd = this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._roll += toAdd;
	    };

	    /**
		 * Update to to turn left
		 * @method
		 * @private
		 */
	    PlaneController.prototype.rollLeftFunc = function (iDelta) {
	        var toAdd = this._power * this.angularSpeed * iDelta.deltaTime * 0.001;

	        if (toAdd < 0) {
	            return;
	        }

	        this._roll -= toAdd;
	    };

	    /**
		 * Increase the plane's speed
		 * @method
		 * @private
		 */
	    PlaneController.prototype.accelerateFunc = function (iDelta) {
	        this._currentAccelerationTime += iDelta.deltaTime * 0.001;
	        if (this._currentAccelerationTime > this._timeNeededToReachMaxAcceleration) {
	            this._currentAccelerationTime = this._timeNeededToReachMaxAcceleration;
	        }

	        this._currentAcceleration = this.easeInOutQuad(this._currentAccelerationTime, 0, this.acceleration, this._timeNeededToReachMaxAcceleration);
	        this._currentSpeed += this._currentAcceleration * iDelta.deltaTime * 0.001 * (1 / this.inertiaFactor);

	        if (this._currentSpeed > this.maximumSpeed) {
	            this._currentSpeed = this.maximumSpeed;
	        }

	        /*var keyboard = EP.Devices.getKeyboard();
	        if (keyboard.isKeyPressed(EP.Keyboard.EKey.eA)) {
	            console.log("CurrentSpeed:" + this._currentSpeed);
	        }*/
	    };

	    /**
		 * Decrease the plane's speed
		 * @method
		 * @private
		 */
	    PlaneController.prototype.decelerateFunc = function (iDelta) {
	        if (this._currentAccelerationTime >= 0) {
	            this._currentAccelerationTime -= iDelta.deltaTime * 0.001;
	            if (this._currentAccelerationTime < 0) {
	                this._currentAccelerationTime = 0;
	            }
	            this._currentAcceleration = this.easeInOutQuad(this._currentAccelerationTime, 0, this.acceleration, this._timeNeededToReachMaxAcceleration);
	            //this._currentSpeed -= this._currentAcceleration * iDelta.deltaTime * 0.001;
	            this._currentSpeed -= (this.acceleration - this._currentAcceleration) * iDelta.deltaTime * 0.001 * (1 / this.inertiaFactor);
	        }
	        /*else {
				this._currentSpeed -= (this.acceleration - this._currentAcceleration) * iDelta.deltaTime * 0.001;
			}*/


	        //this._currentSpeed += this._currentAcceleration * iDelta.deltaTime * 0.001;

	        if (this._currentSpeed < 0) {
	            this._currentSpeed = 0;
	        }

	        if (this._currentSpeed > this.maximumSpeed) {
	            this._currentSpeed = this.maximumSpeed;
	        }

	        /*var keyboard = EP.Devices.getKeyboard();
	        if (keyboard.isKeyPressed(EP.Keyboard.EKey.eA)) {
	            console.log("CurrentSpeed: " + this._currentSpeed + "\nCurrentAcceleration: " + this._currentAcceleration);
	        }*/
	    };

	    /**
		 * Compute the velocity vector based on the current speed
		 * @method
		 * @private
		 */
	    PlaneController.prototype.computeVelocity = function () {
	        this.setLocalAxis();
	        /*var planeMatrix = this._plane.getTransform().matrix.clone();
		    planeMatrix.multiply(this._reorientationMatrix);
		    this._velocity.set(planeMatrix.coef[0], planeMatrix.coef[3], planeMatrix.coef[6]);
		    this._velocity.normalize();
		    this._velocity.multiplyVector(this._currentSpeed);*/
	        this._velocity = DSMath.Vector3D.multiplyScalar(this._localFront, this._currentSpeed);
	    };

	    //###################################################################################################
	    //                                          DRIVERS/SENSORS                                         #
	    //###################################################################################################

	    /**
		 * Make the plane fly to the target defined in argument
		 * @param {STU.Actor3D} iTarget - The new target
		 * @method
		 * @public
		 */
	    PlaneController.prototype.fliesTo = function (iTarget) {
	        var goodArgsType = (iTarget instanceof STU.Actor3D);
	        if (iTarget === null || iTarget === undefined || !goodArgsType) {
	            console.error("[Plane Controller]: Target undefined or non-handled type");
	            return;
	        }
	        this._isFlyingToState = true;
	        this._target = iTarget;

	        this._actionTotalTime = 0.0;
	        this._actionCurrentTime = 0.0;

	        if (this._isLanded) {
	            this._takesOffThenFliesToState = true;
	            // this.flightAltitude = iTarget.getPosition().z;
	            var targetAltitude = iTarget.getPosition().z;
	            if (targetAltitude > this.actor.getPosition().z) {
	                this._flightAltitude = iTarget.getPosition().z;
	                this._flyingToState = 0;
	            }
	            else {
	                this._flightAltitude = this._altitudeOffset + (this.flightAltitude * 0.5);
	                this._flyingToState = -3;
	            }

	            this.takesOff();
	            console.log('[Plane Controller] Take off before Going to: ' + this._target.getName());
	        }
	        else {
	            console.log('[Plane Controller] Going to: ' + this._target.getName());
	            //this._flyingToState = 0;
	            var targetAltitude = iTarget.getPosition().z;
	            if (targetAltitude >= this.actor.getPosition().z) {
	                this._flightAltitude = iTarget.getPosition().z;
	                this._flyingToState = 0;
	            }
	            else {
	                this._flightAltitude = this._altitudeOffset + (this.flightAltitude * 0.5);
	                this._flyingToState = -3;
	            }
	        }
	    };

	    /**
		 * Test if the plane is using the FliesTo function to go a specific target
		 * @param {STU.Actor3D} iTarget - The specified target
		 * @method
		 * @public
		 * @return {Boolean}
		 */
	    PlaneController.prototype.isFlyingTo = function (iTarget) {
	        if (iTarget === this._target) {
	            return this._isFlyingToState;
	        }
	        return false;
	    };

	    /**
         * Make the plane following a specific path defined in argument
		 * @param {STU.PathActor} iPath - The specified path
		 * @method
		 * @public
		 */
	    PlaneController.prototype.fliesAlong = function (iPath) {
	        var goodArgsType = (iPath instanceof STU.PathActor);
	        if (iPath === null || iPath === undefined || !goodArgsType) {
	            console.error("[Plane Controller]: Target undefined or non-handled type");
	            return;
	        }
	        this._flyingPathTarget = iPath;
	        this._isFlyingAlongState = true;

	        this._actionTotalTime = 0.0;
	        this._actionCurrentTime = 0.0;

	        this._currentDistanceFollowPath = 0.0;
	        this._pathLength = this._flyingPathTarget.getLength();

	        //var distanceToTheBeginningOfThePath = DSMath.Vector3D.sub(this._plane.getPosition(), this._flyingPathTarget.getValue(0));

	        if (this._isLanded) {
	            console.log('[Plane Controller] Take off before Going to : ' + this._flyingPathTarget.getName());
	            this._takesOffThenFliesAlongState = true;

	            if (iPath.getValue(0, this._globeLocation).z > this.actor.getPosition().z) {
	                this._flightAltitude = iPath.getValue(0, this._globeLocation).z;
	            }
	            else {
	                this._flightAltitude = this._altitudeOffset + (this.flightAltitude * 0.5);
	            }
	            //this._flightAltitude = iPath.getValue(0).z;
	            this.takesOff();
	        }
	            /*else if(distanceToTheBeginningOfThePath > 1000){
                    this._FliesToPathThenFliesAlongState = true;
                    console.log('Going to :' + this._flyingPathTarget.getName());
                    //this.fliesToOriented();
                }*/
	        else {
	            console.log('[Plane Controller] Going to: ' + this._flyingPathTarget.getName());

	            /*var targetAltitude = this._flyingPathTarget.getPosition().z;
	            if(targetAltitude > this.actor.getPosition().z){
	            	this._flightAltitude = this._flyingPathTarget.getPosition().z;
	            	this._flyingAlongState = 0;
	            }
	            else{
	            	this._flightAltitude = this._altitudeOffset + (this.flightAltitude * 0.5);
	            	this._flyingAlongState = -3;
	            }*/

	            this._flyingAlongState = -3;

	            var startPoint = this._flyingPathTarget.getValue(0, this._globeLocation);
	            var lastPoint = this._flyingPathTarget.getValue(0.01, this._globeLocation);

	            var direction = DSMath.Vector3D.sub(lastPoint, startPoint);

	            this._landingDirection = direction;
	            //this._landingDirection.z = 0;
	            this._landingDirection.normalize();

	            this._flyingPathTargetDirection = direction;
	            this._flyingPathTargetDirection.normalize();

	            this._anticipatedLandingPointB = this._landingDirection.clone();
	            this._anticipatedLandingPointC = this._landingDirection.clone();

	            this._anticipatedDistance = 4 * this.maximumSpeed * 1000 * 0.5 + 3 * this.flightAltitude; // 4sec at 50% speed +  3 * cruising altitude
	            this._anticipatedLandingPointB.multiplyScalar(-this._anticipatedDistance);
	            this._anticipatedLandingPointB.add(startPoint);
	            this._anticipatedLandingPointC.multiplyScalar(-1.5 * this._anticipatedDistance);
	            this._anticipatedLandingPointC.add(startPoint);

	            //this.checkTargetedPoints();

	            //[DEBUG]
	            /*var localTransfo = new DSMath.Transformation();
	            localTransfo.vector = startPoint;
	            var iColor = new STU.Color(255, 0, 0);
	            var render = STU.RenderManager.getInstance();
	            render._createSphere({ radius: 25000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	            //Create Debug Sphere
	            localTransfo.vector = this._anticipatedLandingPointB;
	            iColor = new STU.Color(128, 128, 0);
	            render._createSphere({ radius: 25000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	            localTransfo.vector = this._anticipatedLandingPointC;
	            iColor = new STU.Color(0, 255, 0);
	            render._createSphere({ radius: 25000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });*/

	            // this.analysePathUserScale(this._flyingPathTarget);*/

	        }
	    };

	    /**
		 * Test if the plane is following a specific path using the FliesAlong function
		 * @param {STU.PathActor} iPath - The specified path
		 * @method
		 * @public
		 * @return {Boolean}
		 */
	    PlaneController.prototype.isFlyingAlong = function (iPath) {
	        if (iPath === this._flyingPathTarget) {
	            return this._isFlyingAlongState;
	        }
	        return false;
	    };

	    /**
		 * Make the plane following a specific path defined in argument
		 * @param {STU.PathActor} iPath - The specified path
		 * @method
		 * @public
		 */
	    PlaneController.prototype.drivesOn = function (iPath) {
	        var goodArgsType = (iPath instanceof STU.PathActor);
	        if (iPath === null || iPath === undefined || !goodArgsType) {
	            console.warn("[Plane Controller]: wrong type of parameter inquired");
	            return;
	        }

	        this._drivingRunway = iPath;
	        this._isDrivingOnState = true;
	        this._drivingOnState = 0;
	        this._actionTotalTime = 0.0;
	        this._actionCurrentTime = 0.0;

	        this._currentDistanceFollowPath = 0.0;
	        this._pathLength = this._drivingRunway.getLength();

	        console.log("[Plane Controller] Drives on: " + this._drivingRunway.getName());


	        var startPoint = this._drivingRunway.getValue(0, this._globeLocation);
	        var lastPoint = this._drivingRunway.getValue(0.01, this._globeLocation);
	        var direction = DSMath.Vector3D.sub(lastPoint, startPoint);

	        this.setPlanePosition(startPoint);
	        this.updateAngleToDestination(direction);

	        if (this._angleSignToDestination > 0) {
	            this._yaw += this._angleToDestination;
	        }
	        else {
	            this._yaw -= this._angleToDestination;
	        }

	        this._queueStabilisator = [];

	        //[DEBUG]
	        //this.analysePathUserScale(this._drivingRunway);
	    };

	    /**
		 * Test if the plane is following a specific path using the DriveOn function
		 * @param {STU.PathActor} iPath - The specified path
		 * @method
		 * @public
		 * @return {Boolean}
		 */
	    PlaneController.prototype.isDrivingOn = function (iPath) {
	        if (iPath === this._drivingRunway) {
	            return this._isDrivingOnState;
	        }
	        return false;
	    };

	    /**
		 * Make the plane taking off from a specific path defined in argument
		 * @param {STU.PathActor} iPath - The path to take off from
		 * @method
		 * @public
		 */
	    PlaneController.prototype.takesOff = function (iPath) {
	        var startsStraightForward = false;
	        var goodArgsType = (iPath instanceof STU.PathActor);
	        if (iPath === null || iPath === undefined || !goodArgsType) {
	            console.warn("[Plane Controller]: No runway path defined for take off");
	            startsStraightForward = true;
	        }
	        if (!this._isLanded) {
	            console.warn("[Plane Controller]: Can only Take Off if the plane is landed");
	            return;
	        }

	        this._isTakingOffState = true;
	        this._takeOffState = 0;
	        this._actionTotalTime = 0.0;
	        this._actionCurrentTime = 0.0;
	        //this._flightAltitude = this.flightAltitude;
	        this._flightAltitude = this.flightAltitude + this._altitudeOffset;

	        var startPoint;
	        var lastPoint;
	        var direction;

	        if (startsStraightForward) {
	            startPoint = this._plane.getPosition().clone();
	            direction = new DSMath.Vector3D();
	            var planeMatrix = this._plane.getTransform().matrix.clone();
	            planeMatrix.multiply(this._reorientationMatrix);
	            direction.set(planeMatrix.coef[0], planeMatrix.coef[3], planeMatrix.coef[6]);
	            direction.normalize();

	            var offset = direction.clone().multiplyScalar(10);
	            lastPoint = DSMath.Vector3D.add(startPoint.clone(), offset);

	            this._takeOffState = 4;
	        }
	        else {
	            this._takeOffRunway = iPath;
	            this._currentDistanceFollowPath = 0.0;
	            this._pathLength = this._takeOffRunway.getLength();

	            console.log("[Plane Controller] Takes Off From: " + this._takeOffRunway.getName());

	            startPoint = this._takeOffRunway.getValue(0, this._globeLocation).clone();
	            lastPoint = this._takeOffRunway.getValue(0.01, this._globeLocation);
	            direction = DSMath.Vector3D.sub(lastPoint, startPoint);

	            //this.analysePathUserScale(this._takeOffRunway);
	        }

	        this._takeOffStartHeight = startPoint.z;

	        this.setPlanePosition(startPoint);
	        this.updateAngleToDestination(direction);

	        if (this._angleSignToDestination > 0) {
	            this._yaw += this._angleToDestination;
	        }
	        else {
	            this._yaw -= this._angleToDestination;
	        }

	        this._queueStabilisator = [];
	    };

	    /**
		 * Make the plane lands on a specific path defined in argument
		 * @param {STU.PathActor} iPath - The path to land on
		 * @method
		 * @public
		 */
	    PlaneController.prototype.landsOn = function (iPath) {
	        var goodArgsType = (iPath instanceof STU.PathActor);
	        if (iPath === null && iPath === undefined && !goodArgsType) {
	            console.warn("[Plane Controller]: wrong type of parameter inquired");
	        }
	        this._landingRunway = iPath;
	        this._isLandingOnState = true;

	        this._actionTotalTime = 0.0;
	        this._actionCurrentTime = 0.0;


	        if (this._isLanded) {
	            console.log('[Plane Controller] Take off before Going to :' + this._landingRunway.getName());
	            this._takesOffThenLandsOnState = true;
	            this.takesOff();
	        }
	        else {
	            console.log('[Plane Controller] Going to: ' + this._landingRunway.getName());
	            this._landingOnState = 0;

	            var startPoint = this._landingRunway.getValue(0, this._globeLocation);
	            var lastPoint = this._landingRunway.getValue(0.01, this._globeLocation);

	            var direction = DSMath.Vector3D.sub(lastPoint, startPoint);

	            this._landingDirection = direction;
	            this._landingDirection.z = 0;
	            this._landingDirection.normalize();

	            this._anticipatedLandingPointB = this._landingDirection.clone();
	            this._anticipatedLandingPointC = this._landingDirection.clone();

	            this._anticipatedDistance = 4 * this.maximumSpeed * 1000 * 0.5 + 3 * this.flightAltitude; // 4sec at 50% speed +  3 * cruising altitude
	            this._anticipatedLandingPointB.multiplyScalar(-this._anticipatedDistance);
	            this._anticipatedLandingPointB.add(startPoint);
	            this._anticipatedLandingPointC.multiplyScalar(-1.5 * this._anticipatedDistance);
	            this._anticipatedLandingPointC.add(startPoint);

	            //this.checkTargetedPoints();

	            //this._queueStabilisator = [];
	            //console.log("_anticipatedDistance:"+this._anticipatedDistance);
	            //console.log(this._anticipatedLandingPointB);

	            //Create Debug Sphere // DEBUG
	            /*var localTransfo = new ThreeDS.Mathematics.Transformation();
	            localTransfo.vector = startPoint;
	            var iColor = new STU.Color(255, 0, 0);
	            var render = STU.RenderManager.getInstance();
	            //render._createSphere({ radius: 50000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	            //Create Debug Sphere
	            localTransfo.vector = this._anticipatedLandingPointB;
	            iColor = new STU.Color(128, 128, 0);
	            render._createSphere({ radius: 50000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	            localTransfo.vector = this._anticipatedLandingPointC;
	            iColor = new STU.Color(0, 255, 0);
	            render._createSphere({ radius: 50000, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });

	            this.analysePathUserScale(this._landingRunway);*/
	        }
	    };

	    /**
		 * Return true if the plane is flying
		 * @method
		 * @public
		 * @return {Boolean}
		 */
	    PlaneController.prototype.isFlying = function () {
	        return !this._isLanded;
	    };

	    /**
		 * Return true if the plane is landed
		 * @method
		 * @public
		 * @return {Boolean}
		 */
	    PlaneController.prototype.isLanded = function () {
	        return this._isLanded;
	    };

	    //###################################################################################################
	    //                                  CAPACITIE'S UPDATE FUNCTIONS                                    #
	    //###################################################################################################

	    /**
         * Update function for the "Flies To" Capacity
		 * @method
		 * @private
         * @param {Object} iDelta - Object containing the delta time between each frames
         */
	    PlaneController.prototype.updateFliesTo = function (iDelta) {
	        var vector = this._plane.getTransform().vector.clone();
	        //in case where the target is lower than the plane's initial position
	        if (this._flyingToState === -3) {
	            var futurePositionOffset = this._velocity.clone().multiplyScalar(2500); // 1 seconds later to anticipate the speed increase and raise approximatively the cruising altitude
	            var futurPosition = this._plane.getPosition().clone().add(futurePositionOffset);

	            //Trying to reach the same altitude of the target
	            if (this._target.getPosition().z > this._plane.getPosition().z) {
	                //target higher
	                if (this._pitch < 0.20) {
	                    this.moveUpFunc(iDelta);
	                }
	                if (futurPosition.z > this._target.getPosition().z) {
	                    this._flyingToState = -2;
	                    this._savedPitch = this._pitch;
	                    this._actionTotalTime = 5000.0;
	                    this._actionCurrentTime = 0.0;
	                }
	            }
	            else if (this._target.getPosition().z < this.actor.getPosition().z) {
	                //target lower
	                if (this._pitch > -0.20) {
	                    this.moveDownFunc(iDelta);
	                }
	                if (futurPosition.z < this._target.getPosition().z) {
	                    this._flyingToState = -2;
	                    this._savedPitch = this._pitch;
	                    this._actionTotalTime = 5000.0;
	                    this._actionCurrentTime = 0.0;
	                }
	            }
	        }
	        else if (this._flyingToState === -2) {
	            //Ending take off
	            this._actionCurrentTime += iDelta.deltaTime;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                this._actionCurrentTime = this._actionTotalTime;
	            }

	            this._pitch = this.easeInOutQuad(this._actionCurrentTime, this._savedPitch, -this._savedPitch, this._actionTotalTime);

	            if (this._pitch > -0.001 && this._pitch < 0.001) {
	                this._pitch = 0.0;
	                this._flyingToState = -1;
	                this._actionTotalTime = 0.0;
	                this._actionCurrentTime = 0.0;
	                this._localDestination = null;
	            }
	        }
	        else if (this._flyingToState === -1) {
	            this._flyingToState = 0;
	        }




	        if (this._flyingToState === 0) {
	            // Aiming anticipatedLandingPointC
	            var direction;
	            if (this._localDestination !== null) {
	                direction = this._localDestination.clone();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	            } else {
	                direction = this._target.getPosition();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	            }

	            if (this._actionTotalTime === 0.0) {
	                //this._actionTotalTime = 3000 + (this._angleToDestination + 1) / (this.maneuverability + 1) * 14000;
	                //console.log(((this._angleToDestination + 1) / this.angularSpeed) * 1000);
	                //this._actionTotalTime = 10000 + (this._angleToDestination + 1) / this.angularSpeed;
	                this._actionTotalTime = ((this._angleToDestination + 1) / this.angularSpeed) * 1000;
	                this._startRotatingAngle = this._angleToDestination;
	            }

	            this._actionCurrentTime += iDelta.deltaTime;
	            var angleModifier = 0;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                angleModifier = this.easeInOutQuad(this._actionTotalTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            } else {
	                angleModifier = this.easeInOutQuad(this._actionCurrentTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            }

	            if (this._angleSignToDestination > 0 && this._angleToDestination !== 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            if (this._angleSignToDestination < 0 && this._angleToDestination !== 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            // Roll update
	            if (this._actionCurrentTime < this._actionTotalTime / 5 && Math.abs(this._roll) < 0.3) {
	                //(this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta, 0.3) : this.rotateRight(iDelta, 0.3);
	                (this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta) : this.rollRightFunc(iDelta);
	            }
	            if (this._actionTotalTime - this._actionCurrentTime < 2000) {
	                this._roll -= this._roll * iDelta.deltaTime / 1500;
	            }

	            //var distance = DSMath.Vector3D.sub(this._plane.getPosition(), this._target.getPosition()).norm();
	            var distance = this.DistanceToPosition2D(this._target.getPosition());
	            //console.log(distance);
	            if (distance < 10000) { // distance inferieur a 10m

	                var evt = new PlaneHasReachedEvent(this._target, this._plane);
	                this._plane.dispatchEvent(evt);
	                console.log('[Plane Controller] Plane has reached its target (Event sent).');

	                this.dispatchEvent(new STU.ServiceStoppedEvent("fliesTo", this));

	                this._isFlyingToState = false;

	                this._localDestination = null;
	            }
	        }
	    };

	    /**
         * Update function for the "Flies Along" Capacity
		 * @method
		 * @private
         * @param {Object} iDelta - Object containing the delta time between each frames
         */
	    PlaneController.prototype.updateFliesAlong = function (iDelta) {
	        //step 1: going to the beginning off the path with the good orientation
	        //this.angularSpeed = 0.2;
	        var vector = this._plane.getTransform().vector.clone();
	        if (this._flyingAlongState === -3) {
	            //console.log("The plan will take the same altitude than the destination...");
	            var heightTolerance = 5000; //we authorize a 5 meter height difference

	            if (this._power < 0.75) {
	                this.speedUpFunc(iDelta);
	            }

	            var futurePositionOffset = this._velocity.clone().multiplyScalar(2500); // 2.5 seconds later to anticipate the speed increase and raise approximatively the cruising altitude
	            var futurPosition = this._plane.getPosition().clone().add(futurePositionOffset);
	            if (futurPosition.z > this._flyingPathTarget.getValue(0, this._globeLocation).z + heightTolerance) {
	                this.moveDownFunc(iDelta, 0.25);
	            }
	            else if (futurPosition.z < this._flyingPathTarget.getValue(0, this._globeLocation).z - heightTolerance) {
	                this.moveUpFunc(iDelta, 0.25);
	            }
	            else {
	                this._flyingAlongState = -2;
	                this._savedPitch = this._pitch;
	                this._actionTotalTime = 5000.0;
	                this._actionCurrentTime = 0.0;
	                //console.log('');
	            }
	        }
	        else if (this._flyingAlongState === -2) {
	            //Stage 2: Height Stabilisation
	            this._actionCurrentTime += iDelta.deltaTime;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                this._actionCurrentTime = this._actionTotalTime;
	            }

	            this._pitch = this.easeInOutQuad(this._actionCurrentTime, this._savedPitch, -this._savedPitch, this._actionTotalTime);

	            if (Math.abs(this._pitch) < 0.001) {
	                this._pitch = 0.0;
	                this._flyingAlongState = -1;
	                this._actionTotalTime = 0.0;
	                this._actionCurrentTime = 0.0;
	                this._localDestination = null;
	                //this.checkTargetedPoints();
	            }
	        }
	        else if (this._flyingAlongState === -1) {
	            //wait until we're far enought
	            var dist = this.DistanceToPosition2D(this._anticipatedLandingPointC.clone());
	            if (dist > 1.5 * this._anticipatedDistance) {
	                this._flyingAlongState = 0;
	            }
	            //this._flyingAlongState = 0;
	        }
	            //
	        else if (this._flyingAlongState === 0) {
	            // Aiming anticipatedLandingPointC
	            var direction;
	            if (this._localDestination !== null && this._localDestination !== undefined) {
	                direction = this._localDestination.clone();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	            } else {
	                direction = this._anticipatedLandingPointC.clone();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	                //console.log(this._anticipatedLandingPointC.clone());
	            }

	            if (this._actionTotalTime === 0.0) {
	                //console.log(this.angularSpeed);
	                this._actionTotalTime = ((this._angleToDestination + 1) / this.angularSpeed) * 1000;
	                this._startRotatingAngle = this._angleToDestination;
	            }

	            this._actionCurrentTime += iDelta.deltaTime;
	            var angleModifier = 0;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                //angleModifier = this._startRotatingAngle;
	                angleModifier = this.easeInOutQuad(this._actionTotalTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            } else {
	                angleModifier = this.easeInOutQuad(this._actionCurrentTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            }

	            if (this._angleSignToDestination > 0 && this._angleToDestination !== 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            if (this._angleSignToDestination < 0 && this._angleToDestination !== 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }

	            // Roll update
	            if (this._actionCurrentTime < this._actionTotalTime / 5 && Math.abs(this._roll) < 0.3) {
	                (this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta) : this.rollRightFunc(iDelta);
	            }
	            if (this._actionTotalTime - this._actionCurrentTime < 2000) {
	                this._roll -= this._roll * iDelta.deltaTime / 1500;
	            }

	            var dist = this.DistanceToPosition2D(this._anticipatedLandingPointC.clone());

	            if (this._actionCurrentTime > this._actionTotalTime) {
	                var dist = 0;
	                if (this._localDestination !== null) {
	                    dist = this.DistanceToPosition2D(this._localDestination);
	                }
	                else {
	                    dist = this.DistanceToPosition2D(this._anticipatedLandingPointC.clone());
	                }
	                if (dist < 1.5 * this._anticipatedDistance) {
	                    this._actionCurrentTime = 0;
	                    this._actionTotalTime = 0;
	                    this._startRotatingDistance = 0.0;
	                    this._flyingAlongState = 1;
	                }
	                if (dist < 2 * this._anticipatedDistance) {
	                    if (this._power > 0.5) {
	                        this.speedDownFunc(iDelta);
	                    }
	                }
	            }
	        }
	        else if (this._flyingAlongState === 1) {
	            // Aiming anticipatedLandingPointB
	            if (this._power > 0.5) {
	                this.speedDownFunc(iDelta);
	            }
	            var direction = this._anticipatedLandingPointB.clone();
	            direction.sub(vector);
	            this.updateAngleToDestination(direction);
	            var distToBC = this.pointToLineDistance2D(vector, this._anticipatedLandingPointC, this._anticipatedLandingPointB);
	            if (this._startRotatingDistance === 0.0) {
	                this._startRotatingAngle = this._angleToDestination;
	                this._startRotatingDistance = distToBC;
	            }
	            var angleModifier = 0;
	            angleModifier = this.easeInOutQuad(this._startRotatingDistance - distToBC, 0, this._startRotatingAngle, this._startRotatingDistance);
	            if (this._angleSignToDestination > 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier * 0.4;
	            }
	            if (this._angleSignToDestination < 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier * 0.4;
	            } // Roll update
	            if (distToBC > this._startRotatingDistance * 4 / 5 && Math.abs(this._roll) < 0.3) {
	                (this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta) : this.rollRightFunc(iDelta);
	            }
	            var distToB = this.DistanceToPosition2D(this._anticipatedLandingPointB);

	            if (this._velocity.norm() * (5000) > distToB) {
	                this._flyingAlongState = 2;
	                this._startRotatingDistance = distToBC;
	                this._startRotatingAngle = 0.0;
	                this._actionCurrentTime = 0.0;
	                //console.log('[Plane Controller] Anticipation Point B: OK --> Going to the beginning of the path');
	            }
	        }
	        else if (this._flyingAlongState === 2) {
	            // End of the reorientation of the plane to the landing runaway
	            this._planeProjectionBC = this._anticipatedLandingPointB.clone();
	            var projection = this._landingDirection.clone();
	            projection.z = 0;
	            projection.normalize();

	            var distToBC = this.pointToLineDistance2D(vector, this._anticipatedLandingPointC, this._anticipatedLandingPointB);
	            var distToB = this.DistanceToPosition2D(this._anticipatedLandingPointB);
	            var distToC = this.DistanceToPosition2D(this._anticipatedLandingPointC);
	            if (distToC * distToC > (this._anticipatedDistance * this._anticipatedDistance / 4 + distToB * distToB)) {
	                projection.multiplyScalar(Math.sqrt(distToB * distToB - distToBC * distToBC));
	            } else {
	                projection.multiplyScalar(-Math.sqrt(distToB * distToB - distToBC * distToBC));
	            }
	            this._planeProjectionBC.add(projection);
	            this.updateAngleToDestination(this._landingDirection);

	            var distToPathStart = this.DistanceToPosition2D(this._planeProjectionBC);

	            if (this._startRotatingAngle === 0) {
	                //console.log("8000 + 6000 / 3 = "+ (8000 + 6000 / 3));
	                //console.log("distToPathStart / this._currentSpeed = "+ (distToPathStart / this._currentSpeed));
	                //this._actionTotalTime = 8000 + 6000 / 2;
	                this._actionTotalTime = /*(distToPathStart / this._currentSpeed) +*/ (((this._angleToDestination + 1) / this.angularSpeed) * 1000);
	                //this._actionTotalTime = 8000 + 6000 / 3;
	                //console.log("Action Total Time: " + this._actionTotalTime);
	                this._startRotatingAngle = this._angleToDestination;
	                this._startRotatingDistance = this.DistanceToPosition2D(this._planeProjectionBC);
	            }

	            this._actionCurrentTime += iDelta.deltaTime;

	            if (this._actionTotalTime < this._actionCurrentTime) {
	                this._flyingAlongState = 3;
	                this._localDestination = this._flyingPathTarget.getValue(0, this._globeLocation);
	                this._actionCurrentTime = this._actionTotalTime;

	                /*****/
	                //this._actionCurrentTime = 0.0;
	                //this._actionTotalTime = 0.0;
	                /*****/

	                this._landingHeight = 0;
	                this.adaptVelocity(iDelta, true);
	                //console.log('[Plane Controller] Almost to the beginning of the path');
	            }
	            var angleModifier = this.easeInOutQuad(this._actionCurrentTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            if (this._angleSignToDestination > 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            if (this._angleSignToDestination < 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            var positionModifier = this.easeOutQuad(this._actionCurrentTime, 0, this._startRotatingDistance, this._actionTotalTime);
	            positionModifier = this._startRotatingDistance - this.DistanceToPosition2D(this._planeProjectionBC) - positionModifier;
	            var planeToProj = this._planeProjectionBC.clone();
	            planeToProj.sub(vector);
	            planeToProj.z = 0;
	            planeToProj.normalize();
	            planeToProj.multiplyScalar(-positionModifier);
	            vector.add(planeToProj);
	            this._plane.setPosition(vector);
	            vector = this._plane.getTransform().vector.clone();
	            if (this._actionCurrentTime + 3000 > this._actionTotalTime) {
	                this._roll -= this._roll * iDelta.deltaTime / 4000;
	            }
	        }
	        else if (this._flyingAlongState === 3) {
	            this._roll -= this._roll * iDelta.deltaTime / 1000;
	            //var dist = this.DistanceToPosition2D(this._flyingPathTarget.getValue(0));
	            var dist = this.DistanceToPosition(this._flyingPathTarget.getValue(0, this._globeLocation));

	            if (this._actionCurrentTime === this._actionTotalTime) {
	                this._actionCurrentTime = 0.0;
	                this._actionTotalTime = dist / this._currentSpeed;
	                this._actionTotalTime -= 2000;
	                //this._positionTst = vector.clone();
	                //console.log("Total time: " + this._actionTotalTime);
	            }

	            this._actionCurrentTime += iDelta.deltaTime;

	            if (this._actionCurrentTime > this._actionTotalTime) {
	                if (this._positionTst === null || this._positionTst === undefined) {
	                    this._positionTst = vector.clone();
	                }
	                if (dist < 50) {//if(dist < 1000){
	                    //console.log('Start of the path: OK --> Start to fly along the path');
	                    console.log('[Plane Controller] Start flying along ' + this._flyingPathTarget.getName());
	                    this._flyingAlongState = 4;
	                }
	                else {
	                    //this._currentSpeed = 0;
	                    var t = (this._actionCurrentTime - this._actionTotalTime) / 2000;
	                    t = t > 1 ? 1 : t;
	                    var newPosition = DSMath.Vector3D.lerp(this._positionTst, this._flyingPathTarget.getValue(0, this._globeLocation), t);
	                    this._plane.setPosition(newPosition);

	                    if (t === 1) {
	                        this._flyingAlongState = 4;
	                    }

	                }
	            }
	        }
	            //step 2: follow the path
	        else if (this._flyingAlongState === 4) {
	            var smoothness = 6;
	            var maneuverability = 3;
	            var followPath = true;

	            if (this._currentDistanceFollowPath < this._pathLength) {
	                this._currentDistanceFollowPath += this._currentSpeed * 1000 * iDelta.deltaTime * 0.001;
	            }
	            if (this._currentDistanceFollowPath > this._pathLength) {
	                this._currentDistanceFollowPath = this._pathLength;
	                /*var evt = new PlaneHasCompletedEvent(this._flyingPathTarget, this._plane);
	            this._plane.dispatchEvent(evt);
	                console.log('Plane has completed following path');*/
	                //this._isFlyingAlongState = false;
	                followPath = false;
	                this._flyingAlongState = 5;
	            }

	            var nextPosition = this._flyingPathTarget.getValue(this._currentDistanceFollowPath / this._pathLength, this._globeLocation);

	            var nextPositionVarTst;
	            if (followPath) {
	                var offset = this._currentDistanceFollowPath + this._currentSpeed * 50;
	                if (offset > this._pathLength) {
	                    offset = this._pathLength;
	                }
	                nextPositionVarTst = this._flyingPathTarget.getValue(offset / this._pathLength, this._globeLocation);
	            }
	            //console.log("Next position:"+ nextPosition);

	            var nextTargetedDistance = this._currentDistanceFollowPath + this._currentSpeed * 1000 * 2;
	            if (nextTargetedDistance > this._pathLength) {
	                nextTargetedDistance = this._pathLength;
	            }

	            var nextTargetedPosition = this._flyingPathTarget.getValue(nextTargetedDistance / this._pathLength, this._globeLocation);
	            //console.log("Next Targeted position:"+ nextTargetedPosition);

	            var vector = this._plane.getTransform().vector.clone();
	            /*if (this._currentDistanceFollowPath === this._pathLength) {
	                this._isFlyingAlongState = false;
	            }*/

	            if (!followPath) {
	                var nextPositionDirection = this._localFront;
	            }
	            else {
	                var nextPositionDirection = nextPositionVarTst.clone();
	                nextPositionDirection.sub(vector);
	                nextPositionDirection.normalize();
	            }

	            //Create Debug Sphere
	            /*var localTransfo = new ThreeDS.Mathematics.Transformation();
	            localTransfo.vector = nextPosition;
	            var iColor = new STU.Color(255, 100, 0);
	            var render = STU.RenderManager.getInstance();
	            render._createSphere({ radius: 4000, position: localTransfo, color: iColor, alpha: 255, lifetime: 1 });*/

	            //vector = this._plane.getPosition();
	            /*nextPositionDirection.subVectorFromVector(vector);
	            nextPositionDirection.normalize();*/
	            this.updateAngleToDestination(nextPositionDirection);

	            var offset = this._currentDistanceFollowPath + this._currentSpeed * 50;
	            if (offset < this._pathLength) {
	                if (this._angleSignToDestination > 0) {
	                    this._yaw += this._angleToDestination / smoothness;
	                }
	                else {
	                    this._yaw -= this._angleToDestination / smoothness;
	                }
	            }

	            //this._pitch = this.getPitchDiff(nextPositionDirection, this._angleToDestination);

	            this._plane.setPosition(nextPosition);

	            var nextPositionDirection = nextTargetedPosition.clone();
	            nextPositionDirection.sub(vector);
	            nextPositionDirection.normalize();
	            this.updateAngleToDestination(nextPositionDirection);

	            if (!followPath) {
	                nextPositionDirection = this._localFront;
	            }

	            //console.log(this._angleToDestination);

	            var maxAngle = 0.05;
	            var currentAngle = (this._angleToDestination > maxAngle) ? maxAngle : this._angleToDestination;
	            var minRoll = 0;
	            var maxRoll = 0.50;

	            var desiredRoll = this.lerp(minRoll, maxRoll, currentAngle / maxAngle);
	            var deltaCoeff = this.lerp(0.25, 2, currentAngle / maxAngle);

	            if (this._angleSignToDestination > 0) {
	                desiredRoll *= -1;
	            }

	            if (followPath) {
	                if (desiredRoll > this._roll + 0.01) {
	                    this._roll += this.angularSpeed * deltaCoeff * iDelta.deltaTime * 0.001;
	                    //this._roll += this._angleToDestination * 0.5;
	                }
	                else if (desiredRoll < this._roll - 0.01) {
	                    this._roll -= this.angularSpeed * deltaCoeff * iDelta.deltaTime * 0.001;
	                    //this._roll -= this._angleToDestination * 0.5;
	                }
	            }
	        }
	            //step 3: send the event and go straight forward
	        else if (this._flyingAlongState === 5) {
	            if (this._roll > 0) {
	                this._roll -= this.angularSpeed * iDelta.deltaTime * 0.001;
	            }
	            else {
	                this._roll += this.angularSpeed * iDelta.deltaTime * 0.001;
	            }

	            if (this._roll > -0.01 && this._roll < 0.01) {
	                this._isFlyingAlongState = false;
	                this._localDestination = null;

	                var evt = new PlaneHasCompletedEvent(this._flyingPathTarget, this._plane);
	                this._plane.dispatchEvent(evt);
	                console.log('[Plane Controller] Plane has completed path (Event Sent)');

	                this.dispatchEvent(new STU.ServiceStoppedEvent("fliesAlong", this));
	            }
	        }
	    };

	    /**
         * Update function for the "Drive On" Capacity
		 * @method
		 * @private
         * @param {Object} iDelta - Object containing the delta time between each frames
         */
	    PlaneController.prototype.updateDrivesOn = function (iDelta) {
	        if (this._actionCurrentTime === 0.0) {
	            this._speed = this._currentSpeed;
	        }

	        var distanceInFiveSec = this._currentDistanceFollowPath + this._currentSpeed * 1000 * 5;
	        if (distanceInFiveSec > this._pathLength) {
	            if (this._power > 0) {
	                this._actionCurrentTime += iDelta.deltaTime;
	                this._actionCurrentTime = this._actionCurrentTime > 5000 ? 5000 : this._actionCurrentTime;
	                this._currentSpeed = this.lerp(this._speed, 0, this._actionCurrentTime / 5000);

	                if (this._currentSpeed < 2) {
	                    this._currentSpeed = 0;
	                    this._currentAcceleration = 0;
	                    this._currentAccelerationTime = 0;
	                    this._isDrivingOnState = false;

	                    var evt = new PlaneHasCompletedEvent(this._drivingRunway, this._plane);
	                    this._plane.dispatchEvent(evt);
	                    console.log('[Plane Controller] Plane has completed path (Event Sent)');

	                    this.dispatchEvent(new STU.ServiceStoppedEvent("drivesOn", this));
	                }
	            }
	        }
	        else {
	            if (this._power < 0.3) {
	                this.speedUpFunc(iDelta);
	            }
	        }

	        //step 2: follow the path
	        if (this._drivingOnState === 0) {
	            var smoothness = 6;
	            var followPath = true;

	            if (this._currentDistanceFollowPath < this._pathLength) {
	                this._currentDistanceFollowPath += this._currentSpeed * 1000 * iDelta.deltaTime * 0.001;
	            }
	            if (this._currentDistanceFollowPath >= this._pathLength) {
	                this._currentDistanceFollowPath = this._pathLength;
	                followPath = false;
	            }

	            var nextPosition = this._drivingRunway.getValue(this._currentDistanceFollowPath / this._pathLength, this._globeLocation);
	            nextPosition = DSMath.Vector3D.sub(nextPosition, this._worldLowPositionOffset);

	            var nextPositionVarTst;
	            if (followPath) {
	                var offset = 1000 + this._currentDistanceFollowPath + this._currentSpeed * 500;
	                if (offset > this._pathLength) {
	                    offset = this._pathLength;
	                }
	                nextPositionVarTst = this._drivingRunway.getValue(offset / this._pathLength, this._globeLocation);
	                nextPositionVarTst = DSMath.Vector3D.sub(nextPositionVarTst, this._worldLowPositionOffset);
	            }

	            var nextTargetedDistance = this._currentDistanceFollowPath + this._currentSpeed * 1000 * 2;
	            if (nextTargetedDistance > this._pathLength) {
	                nextTargetedDistance = this._pathLength;
	            }

	            var nextTargetedPosition = this._drivingRunway.getValue(nextTargetedDistance / this._pathLength, this._globeLocation);
	            nextTargetedPosition = DSMath.Vector3D.sub(nextTargetedPosition, this._worldLowPositionOffset);

	            if (nextTargetedDistance < this._pathLength) {
	                var u = (this._length / this._pathLength);
	                var tst = this._drivingRunway.getValue(this._currentDistanceFollowPath / this._pathLength, this._globeLocation);
	                var tst2 = this._drivingRunway.getValue((this._currentDistanceFollowPath + u) / this._pathLength, this._globeLocation);
	                var dir = DSMath.Vector3D.sub(tst2, tst);
	                this.updateAngleToDestination(dir);

	                var p = this._power / 0.25;
	                var d = this._currentDistanceFollowPath / (this._pathLength * 0.05);
	                if (d > 1) {
	                    d = 1;
	                }
	                if (this._angleSignToDestination > 0) {
	                    this._yaw += (this._angleToDestination * d * p) / smoothness;
	                }
	                else {
	                    this._yaw -= (this._angleToDestination * d * p) / smoothness;
	                }
	            }

	            this._plane.setPosition(nextPosition);
	        }
	    };

	    /**
         * Update function for the "Take Off" Capacity
		 * @method
         * @private
         * @param {Object} iDelta - Object containing the delta time between each frames
         */
	    PlaneController.prototype.updateTakeOff = function (iDelta) {
	        //analyse next position
	        var smoothness = 6;
	        //var maneuverability = 3;
	        var followPath = true;
	        if (this._takeOffState === 0) {
	            //var conf = this.vectorLocalToWorldReferential(this._positionOffset, this._plane.getTransform().clone());
	            //console.log(this._pathLength);
	            if (this._currentDistanceFollowPath < 0.05 * this._pathLength) {
	                this.speedUpFunc(iDelta);
	                //console.log(this._currentSpeed);
	            }

	            if (this._currentDistanceFollowPath < this._pathLength) {
	                this._currentDistanceFollowPath += this._currentSpeed * 1000 * iDelta.deltaTime * 0.001;
	            }
	            if (this._currentDistanceFollowPath > this._pathLength) {
	                this._currentDistanceFollowPath = this._pathLength;
	                followPath = false;
	            }

	            var nextPosition = this._takeOffRunway.getValue(this._currentDistanceFollowPath / this._pathLength, this._globeLocation);
	            nextPosition = DSMath.Vector3D.sub(nextPosition, this._worldLowPositionOffset);

	            var nextTargetedDistance = this._currentDistanceFollowPath + this._currentSpeed * 1000 * 5;
	            if (nextTargetedDistance > this._pathLength) {
	                nextTargetedDistance = this._pathLength;
	                // il faut forcer le decollage car on est en fin de piste
	                this._takeOffState = 1;
	            }
	            var nextTargetedPosition = this._takeOffRunway.getValue(nextTargetedDistance / this._pathLength, this._globeLocation);
	            nextTargetedPosition = DSMath.Vector3D.sub(nextTargetedPosition, this._worldLowPositionOffset);

	            var direction = DSMath.Vector3D.sub(nextTargetedPosition, this._plane.getPosition().clone());
	            direction.normalize();
	            this.updateAngleToDestination(direction);

	            if (this._angleToDestination < 0.05) {
	                this.speedUpFunc(iDelta);
	                var readyToLeaveGround = (this._currentSpeed > this._takeoffSpeed);
	                if (readyToLeaveGround) {
	                    this._takeOffState = 1;
	                }
	            }

	            nextTargetedDistance = 1000 + this._currentDistanceFollowPath + this._currentSpeed * 50;
	            if (nextTargetedDistance < this._pathLength) {
	                nextTargetedPosition = this._takeOffRunway.getValue(nextTargetedDistance / this._pathLength, this._globeLocation);
	                nextTargetedPosition = DSMath.Vector3D.sub(nextTargetedPosition, this._worldLowPositionOffset);
	                direction = DSMath.Vector3D.sub(nextTargetedPosition, this._plane.getPosition().clone());
	                direction.normalize();
	                this.updateAngleToDestination(direction);
	                if (this._angleSignToDestination > 0) {
	                    this._yaw += (this._angleToDestination * this._power) / smoothness;
	                }
	                else {
	                    this._yaw -= (this._angleToDestination * this._power) / smoothness;
	                }
	            }
	            /*var nextPositionVarTst;
	            if (followPath) {
	                var offset = this._currentDistanceFollowPath + this._currentSpeed * 50;
	                if (offset > this._pathLength) {
	                    offset = this._pathLength;
	                }
	                nextPositionVarTst = this._takeOffRunway.getValue(offset / this._pathLength);
	                nextPositionVarTst = DSMath.Vector3D.sub(nextPositionVarTst, conf);
	            }*/

	            //nextPosition = DSMath.Vector3D.sub(nextPosition, conf);
	            this._plane.setPosition(nextPosition);
	        }
	        else if (this._takeOffState === 1) {
	            if (this._power < 1) {
	                this.speedUpFunc(iDelta);
	            }
	            if (this._pitch < 0.20) {
	                this.moveUpFunc(iDelta);
	            }

	            var futurePositionOffset = this._velocity.clone().multiplyScalar(2500); // 5 seconds later to anticipate the speed increase and raise approximatively the cruising altitude
	            var futurPosition = this._plane.getPosition().clone().add(futurePositionOffset);

	            //Create Debug Sphere [DEBUG]
	            /*var localTransfo = new DSMath.Transformation();
	            localTransfo.vector = futurPosition;
	            var iColor = new STU.Color(0, 255, 0);
				var render = STU.RenderManager.getInstance();
	            render._createSphere({ radius: 4000, position: localTransfo, color: iColor, alpha: 255, lifetime: 1 });*/

	            if (futurPosition.z > this._flightAltitude) {
	                this._takeOffState = 2;
	                this._savedPitch = this._pitch;
	                this._actionTotalTime = 5000.0;
	                this._actionCurrentTime = 0.0;
	            }
	        }
	        else if (this._takeOffState === 2) {
	            //Ending take off
	            this._actionCurrentTime += iDelta.deltaTime;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                this._actionCurrentTime = this._actionTotalTime;
	            }

	            this._pitch = this.easeInOutQuad(this._actionCurrentTime, this._savedPitch, -this._savedPitch, this._actionTotalTime);

	            if (this._pitch < 0.001) {
	                this._pitch = 0.0;
	                this._takeOffState = 3;
	                this._actionTotalTime = 0.0;
	                this._actionCurrentTime = 0.0;
	                this._localDestination = null;
	            }
	        }
	        else if (this._takeOffState === 3) {
	            var evt = new PlaneHasTookOffEvent();
	            this._plane.dispatchEvent(evt);
	            console.log('[Plane Controller] Plane has took off (Event Sent)');
	            this.dispatchEvent(new STU.ServiceStoppedEvent("takesOff", this));

	            this._isTakingOffState = false;
	            this._isLanded = false;

	            if (this._takesOffThenFliesToState) {
	                this.fliesTo(this._target);
	            }
	            else if (this._takesOffThenFliesAlongState) {
	                this.fliesAlong(this._flyingPathTarget);
	            }
	            else if (this._takesOffThenLandsOnState) {
	                this.landsOn(this._landingRunway);
	            }
	        }

	            //Take Off straitght forward
	        else if (this._takeOffState === 4) {
	            //Start accelerate until reach takeoff speed
	            if (this._power < 1) {
	                this.speedUpFunc(iDelta);
	            }
	            var readyToLeaveGround = (this._currentSpeed > this._takeoffSpeed);
	            if (readyToLeaveGround && this._pitch < 0.20) {
	                this.moveUpFunc(iDelta);
	            }
	            var isleavingGround = (this._pitch < 0.20 && this._pitch > 0);

	            var futurePositionOffset = this._velocity.clone().multiplyScalar(2500); // 2.5 seconds later to anticipate the speed increase and raise approximatively the cruising altitude
	            var futurPosition = this._plane.getPosition().clone().add(futurePositionOffset);
	            if (futurPosition.z > this._flightAltitude) {
	                this._takeOffState = 5;
	                this._savedPitch = this._pitch;
	                this._actionTotalTime = 5000.0;
	                this._actionCurrentTime = 0.0;
	            }
	        }
	        else if (this._takeOffState === 5) {
	            //Ending take off
	            this._actionCurrentTime += iDelta.deltaTime;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                this._actionCurrentTime = this._actionTotalTime;
	            }

	            this._pitch = this.easeInOutQuad(this._actionCurrentTime, this._savedPitch, -this._savedPitch, this._actionTotalTime);

	            if (this._pitch < 0.001) {
	                this._pitch = 0.0;
	                this._takeOffState = 6;
	                this._actionTotalTime = 0.0;
	                this._actionCurrentTime = 0.0;
	                this._localDestination = null;
	                //this.checkTargetedPoints();
	                //console.log('TakeOffState 2');
	            }
	        }
	        else if (this._takeOffState === 6) {
	            var evt = new PlaneHasTookOffEvent();
	            this._plane.dispatchEvent(evt);
	            console.log('[Plane Controller] Plane has taken off (Event Sent)');

	            this.dispatchEvent(new STU.ServiceStoppedEvent("takesOff", this));

	            this._isTakingOffState = false;
	            this._isLanded = false;

	            if (this._takesOffThenFliesToState) {
	                this.fliesTo(this._target);
	            }
	            else if (this._takesOffThenFliesAlongState) {
	                this.fliesAlong(this._flyingPathTarget);
	            }
	            else if (this._takesOffThenLandsOnState) {
	                this.landsOn(this._landingRunway);
	            }
	        }
	    };

	    /**
         * Update function for the "Land On" Capacity
         * @method
         * @private
         * @param {Object} iDelta - Object containing the delta time between each frames
         */
	    PlaneController.prototype.updateLandsOn = function (iDelta) {
	        var vector = this._plane.getTransform().vector.clone();

	        if (this._landingOnState === 0) {
	            // Aiming anticipatedLandingPointC
	            var direction;
	            if (this._localDestination !== null) {
	                direction = this._localDestination.clone();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	            } else {
	                direction = this._anticipatedLandingPointC.clone();
	                direction.sub(vector);
	                this.updateAngleToDestination(direction);
	            }

	            if (this._actionTotalTime === 0.0) {
	                this._actionTotalTime = ((this._angleToDestination + 1) / this.angularSpeed) * 1000;
	                this._startRotatingAngle = this._angleToDestination;
	            }

	            this._actionCurrentTime += iDelta.deltaTime;
	            var angleModifier = 0;
	            if (this._actionCurrentTime > this._actionTotalTime) {
	                angleModifier = this.easeInOutQuad(this._actionTotalTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            } else {
	                angleModifier = this.easeInOutQuad(this._actionCurrentTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            }

	            if (this._angleSignToDestination > 0 && this._angleToDestination !== 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            if (this._angleSignToDestination < 0 && this._angleToDestination !== 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }

	            // Roll update
	            if (this._actionCurrentTime < this._actionTotalTime / 5 && Math.abs(this._roll) < 0.3) {
	                //(this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta, 0.3) : this.rotateRight(iDelta, 0.3);
	                (this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta) : this.rollRightFunc(iDelta);
	            }
	            if (this._actionTotalTime - this._actionCurrentTime < 2000) {
	                this._roll -= this._roll * iDelta.deltaTime / 1500;
	            }

	            if (this._actionCurrentTime > this._actionTotalTime) {
	                var dist = 0;
	                if (this._localDestination !== null) {
	                    dist = this.DistanceToPosition2D(this._localDestination);
	                }
	                else {
	                    dist = this.DistanceToPosition2D(this._anticipatedLandingPointC.clone());
	                }
	                if (dist < 1.5 * this._anticipatedDistance) {
	                    this._actionCurrentTime = 0;
	                    this._actionTotalTime = 0;
	                    this._startRotatingDistance = 0.0;

	                    this._landingOnState = 1;
	                    //console.log('[Plane Controller] Anticipation Point C: OK --> Going to B');
	                }
	                if (dist < 2 * this._anticipatedDistance) {
	                    if (this._power > 0.5) {
	                        this.speedDownFunc(iDelta);
	                    }
	                }
	            }
	        }
	        else if (this._landingOnState === 1) {
	            // Aiming anticipatedLandingPointB
	            if (this._power > 0.5) {
	                this.speedDownFunc(iDelta);
	            }
	            var direction = this._anticipatedLandingPointB.clone();
	            direction.sub(vector);
	            this.updateAngleToDestination(direction);
	            var distToBC = this.pointToLineDistance2D(vector, this._anticipatedLandingPointC, this._anticipatedLandingPointB);
	            if (this._startRotatingDistance === 0.0) {
	                this._startRotatingAngle = this._angleToDestination;
	                this._startRotatingDistance = distToBC;
	            }
	            var angleModifier = 0;
	            angleModifier = this.easeInOutQuad(this._startRotatingDistance - distToBC, 0, this._startRotatingAngle, this._startRotatingDistance);
	            if (this._angleSignToDestination > 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier * 0.4;
	            }
	            if (this._angleSignToDestination < 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier * 0.4;
	            } // Roll update
	            if (distToBC > this._startRotatingDistance * 4 / 5 && Math.abs(this._roll) < 0.3) {
	                (this._angleSignToDestination > 0) ? this.rollLeftFunc(iDelta) : this.rollRightFunc(iDelta);
	            }
	            var distToB = this.DistanceToPosition2D(this._anticipatedLandingPointB);

	            if (this._velocity.norm() * (5000) > distToB) {
	                this._landingOnState = 2;
	                this._startRotatingDistance = distToBC;
	                this._startRotatingAngle = 0.0;
	                this._actionCurrentTime = 0.0;
	                //console.log('[Plane Controller] Anticipation Point B: OK --> Going to the beginning of the path');
	            }
	        }
	        else if (this._landingOnState === 2) {
	            // End of the reorientation of the plane to the landing runaway
	            this._planeProjectionBC = this._anticipatedLandingPointB.clone();
	            var projection = this._landingDirection.clone();
	            projection.z = 0;
	            projection.normalize();

	            var distToBC = this.pointToLineDistance2D(vector, this._anticipatedLandingPointC, this._anticipatedLandingPointB);
	            var distToB = this.DistanceToPosition2D(this._anticipatedLandingPointB);
	            var distToC = this.DistanceToPosition2D(this._anticipatedLandingPointC);
	            if (distToC * distToC > (this._anticipatedDistance * this._anticipatedDistance / 4 + distToB * distToB)) {
	                projection.multiplyScalar(Math.sqrt(distToB * distToB - distToBC * distToBC));
	            } else {
	                projection.multiplyScalar(-Math.sqrt(distToB * distToB - distToBC * distToBC));
	            }
	            this._planeProjectionBC.add(projection);
	            this.updateAngleToDestination(this._landingDirection);

	            var distToPathStart = this.DistanceToPosition2D(this._planeProjectionBC);

	            if (this._startRotatingAngle === 0) {
	                //console.log("8000 + 6000 / 3 = "+ (8000 + 6000 / 3));
	                //console.log("distToPathStart / this._currentSpeed = "+ (distToPathStart / this._currentSpeed));
	                //this._actionTotalTime = 8000 + 6000 / 2;
	                this._actionTotalTime = /*(distToPathStart / this._currentSpeed) +*/ (((this._angleToDestination + 1) / this.angularSpeed) * 1000);
	                //this._actionTotalTime = 8000 + 6000 / 3;
	                //console.log("Action Total Time: " + this._actionTotalTime);
	                this._startRotatingAngle = this._angleToDestination;
	                this._startRotatingDistance = this.DistanceToPosition2D(this._planeProjectionBC);
	            }

	            this._actionCurrentTime += iDelta.deltaTime;

	            if (this._actionTotalTime < this._actionCurrentTime) {
	                this._landingOnState = 3;
	                this._localDestination = this._landingRunway.getValue(0, this._globeLocation);
	                this._actionCurrentTime = this._actionTotalTime;

	                /*****/
	                //this._actionCurrentTime = 0.0;
	                //this._actionTotalTime = 0.0;
	                /*****/

	                this._landingHeight = 0;
	                this.adaptVelocity(iDelta, true);
	                //console.log('[Plane Controller] Almost to the beginning of the path');
	            }
	            var angleModifier = this.easeInOutQuad(this._actionCurrentTime, 0, this._startRotatingAngle, this._actionTotalTime);
	            if (this._angleSignToDestination > 0) {
	                this._yaw -= this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            if (this._angleSignToDestination < 0) {
	                this._yaw += this._startRotatingAngle - this._angleToDestination - angleModifier;
	            }
	            var positionModifier = this.easeOutQuad(this._actionCurrentTime, 0, this._startRotatingDistance, this._actionTotalTime);
	            positionModifier = this._startRotatingDistance - this.DistanceToPosition2D(this._planeProjectionBC) - positionModifier;
	            var planeToProj = this._planeProjectionBC.clone();
	            planeToProj.sub(vector);
	            planeToProj.z = 0;
	            planeToProj.normalize();
	            planeToProj.multiplyScalar(-positionModifier);
	            vector.add(planeToProj);
	            this._plane.setPosition(vector);
	            vector = this._plane.getTransform().vector.clone();
	            if (this._actionCurrentTime + 3000 > this._actionTotalTime) {
	                this._roll -= this._roll * iDelta.deltaTime / 4000;
	            }
	        }
	        else if (this._landingOnState === 3) {
	            // Landing procedure
	            this._roll -= this._roll * iDelta.deltaTime / 1000;
	            if (this._power > 0.25) {
	                this.speedDownFunc(iDelta);
	            }
	            if (this._landingHeight === 0) {
	                this._landingHeight = vector.z - this._localDestination.z;
	                this._startLandingAltitude = vector.z;
	                this._startLandingDistance = this.DistanceToPosition2D(this._localDestination);
	            }
	            var heightModifier = this.easeInOutQuad(this.DistanceToPosition2D(this._localDestination), 0, this._landingHeight - 5000, this._startLandingDistance);

	            if (this._pitch > -0.2 && this._landingHeight * 4 / 5 < heightModifier) {
	                this.moveDownFunc(iDelta);
	            }
	            var newPosition = vector.clone();
	            newPosition.z = this._localDestination.z + heightModifier + 5000;
	            this._plane.setPosition(newPosition);
	            if (heightModifier < this._landingHeight / 5) {
	                this._pitch -= this._pitch * iDelta.deltaTime / 2000;
	            }
	            if (heightModifier < 5000) {
	                this._landingOnState = 4;
	                this._actionTotalTime = 0;
	                this._velocity.z = 0;
	                //console.debug('GoToState 4');
	            }
	        }

	        else if (this._landingOnState === 4) {
	            // Just before hitting the ground to the end
	            this._velocity.z = 0;

	            //var tst = this._plane.getPosition().clone();
	            //var conf = this.vectorLocalToWorldReferential(this._positionOffset, this._plane.getTransform().clone());
	            //var vectorLowPos = DSMath.Vector3D.add(vector.clone(), conf);
	            var vectorLowPos = DSMath.Vector3D.add(vector.clone(), this._worldLowPositionOffset);

	            if (this._power > 0.15) {//if (this._power > 0.15) {
	                this.speedDownFunc(iDelta);
	            }
	            if (this._actionTotalTime === 0) {
	                this._actionTotalTime = 8000;
	                this._actionCurrentTime = 0;
	                this._landingHeight = 0;
	            }
	            this._actionCurrentTime += iDelta.deltaTime;
	            if (this._actionCurrentTime < 3000 && this._pitch < 0.14) {
	                this.moveUpFunc(iDelta);
	            }
	            if (this._actionCurrentTime > 2000 && this._landingHeight === 0) {
	                this._startLandingAltitude = vector.z;//vectorLowPos.z;//vector.z
	                this._landingHeight = vectorLowPos.z - this._localDestination.z;//vector.z - this._localDestination.z;
	            }
	            if (this._landingHeight !== 0) {
	                var heightModifier = 0;
	                if (this._actionCurrentTime < this._actionTotalTime) {
	                    heightModifier = this.easeInOutQuad(this._actionCurrentTime - 2000, 0, this._landingHeight, this._actionTotalTime - 2000);
	                } else {
	                    heightModifier = this.easeInOutQuad(this._actionTotalTime - 2000, 0, this._landingHeight, this._actionTotalTime - 2000);
	                }
	                vector.z = this._startLandingAltitude - heightModifier;
	                this._plane.setPosition(vector);
	                vector = this._plane.getTransform().vector.clone();
	            }
	            if (this._actionCurrentTime > this._actionTotalTime && this._pitch !== 0) {
	                this._pitch -= 0.05 * iDelta.deltaTime / 1000;
	            }
	            if (this._pitch < 0 && this._actionCurrentTime > this._actionTotalTime) {
	                this._pitch = 0;
	            }//ASO4
	            if (this._actionCurrentTime > this._actionTotalTime + 2000) {
	                var inertiaToRemove = this._velocity.clone();
	                inertiaToRemove.multiplyScalar(iDelta.deltaTime / 8000);
	                this._velocity.sub(inertiaToRemove);
	            }
	            if (this._actionCurrentTime > this._actionTotalTime + 7000) {
	                var inertiaToRemove = this._velocity.clone();
	                inertiaToRemove.multiplyScalar(iDelta.deltaTime / 3000);
	                this._velocity.sub(inertiaToRemove);
	            }
	            if (this._actionCurrentTime > this._actionTotalTime + 10000) { // 14000
	                this._landingOnState = 5;
	                //console.log("GoToState 5");
	            }
	        }

	        else if (this._landingOnState === 5) {
	            if (this._power > 0.0) {
	                this.speedDownFunc(iDelta);
	            }

	            if (this._power < 0.01) {
	                this._isLandingOnState = false;
	                this._landingOnState = 0;
	                this._power = 0;
	                this._currentSpeed = 0;
	                this._isLanded = true;
	                this._localDestination = null;
	                //this._velocity.subVectorFromVector(this._velocity);
	                var evt = new PlaneHasLandEvent();
	                this._plane.dispatchEvent(evt);
	                console.log('[Plane Controller] Plane has Land (Event sent).');

	                this.dispatchEvent(new STU.ServiceStoppedEvent("landsOn", this));
	            }
	        }
	    };

	    //###################################################################################################
	    //                                          MATRIX COMPUTING                                        #
	    //###################################################################################################

	    /**
		 * Update the transform of the plane
		 * @method
		 * @private
		 */
	    PlaneController.prototype.updateTransform = function (iDelta) {
	        if (isNaN(this._pitch)) {
	            this._pitch = 0.0;
	        }
	        if (isNaN(this._yaw)) {
	            this._yaw = 0.0;
	        }
	        if (isNaN(this._roll)) {
	            this._roll = 0.0;
	        }

	        if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
	            console.error('Velocity bad value in updateTransfom');
	            this._velocity.set(0.0, 0.0, 0.0);
	            return;
	        }

	        // update position
	        var position = this._plane.getTransform().vector.clone();
	        var movement = this._velocity.clone();
	        movement.multiplyScalar(iDelta.deltaTime);
	        position.add(movement);
	        this._plane.setPosition(position);

	        // update yaw
	        var rotMatrix = new DSMath.Matrix3x3();
	        var rotZ = new DSMath.Vector3D(0.0, 0.0, 1.0);
	        rotMatrix.makeRotation(rotZ, this._yaw);//rotMatrix.setRotation(rotZ, this._yaw);

	        // update pitch/yaw/roll
	        if (this._pitch > Math.PI) {
	            this._pitch -= 2 * Math.PI;
	        } else if (this._pitch < -Math.PI) {
	            this._pitch += 2 * Math.PI;
	        }

	        var orientedTransform = new DSMath.Transformation();
	        orientedTransform.matrix = this._initialMatrix.clone();
	        orientedTransform.matrix.multiply(this._reorientationMatrix);
	        orientedTransform.matrix = orientedTransform.matrix.multiply(rotMatrix);

	        var newTransform = new DSMath.Transformation();
	        newTransform.matrix = this._initialMatrix.clone();
	        newTransform.matrix = newTransform.matrix.multiply(rotMatrix);
	        newTransform.vector = position;

	        var rotX = new DSMath.Vector3D(1.0, 0.0, 0.0);
	        var rotXWorld = this.vectorLocalToWorldReferential(rotX, orientedTransform);
	        var rotY = new DSMath.Vector3D(0.0, 1.0, 0.0);
	        var rotYWorld = this.vectorLocalToWorldReferential(rotY, orientedTransform);

	        rotXWorld.normalize();
	        rotXWorld.multiplyScalar(this._roll);
	        rotYWorld.normalize();
	        rotYWorld.multiplyScalar(-this._pitch);

	        this._plane.setTransform(newTransform);
	        this._plane.rotate(rotXWorld);
	        this._plane.rotate(rotYWorld);

	        /*var rotation = new DSMath.Vector3D(this._roll,this._pitch, this._yaw);
		    this._plane.rotate(rotation);*/

	        // [DEBUG]
	        /*var conf = this.vectorLocalToWorldReferential(this._positionOffset, this._plane.getTransform().clone());
	        //Create Debug Sphere
	        var localTransfo = new DSMath.Transformation();
	        localTransfo.vector = DSMath.Vector3D.add(this._plane.getPosition(), conf);
	        var iColor = new STU.Color(255, 0, 0);
	        var render = STU.RenderManager.getInstance();
	        render._createSphere({ radius: 3000, position: localTransfo, color: iColor, alpha: 255, lifetime: 1 });*/
	    };

	    /**
		 * Update the average transform computation
		 * @method
		 * @private
		 */
	    PlaneController.prototype.updateAverageTransform = function () {
	        var t = this._plane.getTransform().clone();
	        t.matrix.multiplyScalar(1 / this._scale);
	        this._oldTransform = t;
	        this._queueStabilisator.push(this._oldTransform);
	        if (this._queueStabilisator.length > this.smoothness + 1) {
	            this._queueStabilisator.shift();
	        }
	        var averageTransform = this.getAverageTransform();
	        averageTransform.matrix.multiplyScalar(this._scale);
	        this._plane.setTransform(averageTransform);
	        //this._plane.setScale(this._scale);
	    };

	    /**
		 * Get the average transform
		 * @method
		 * @private
		 */
	    PlaneController.prototype.getAverageTransform = function () {
	        var averageTransform = new DSMath.Transformation();
	        var averageQuaternion = new DSMath.Quaternion();
	        //averageTransform.vector.set(0, 0, 0);
	        //averageTransform.matrix.setFromArray([0, 0, 0, 0, 0, 0, 0, 0, 0]);
	        for (var i = 0; i < this._queueStabilisator.length; i++) {
	            averageTransform.vector.add(this._queueStabilisator[i].vector);
	            var quat = new DSMath.Quaternion();
	            this._queueStabilisator[i].matrix.getQuaternion(quat);//quat.rotMatrixToQuaternion(this._queueStabilisator[i].matrix);
	            averageQuaternion = DSMath.Quaternion.slerp(averageQuaternion, quat, (1 / (1 + i)));
	        }
	        averageQuaternion.getMatrix(averageTransform.matrix);//averageTransform.matrix = averageQuaternion.quaternionToRotMatrix();
	        averageTransform.vector.multiplyScalar(1 / this._queueStabilisator.length);
	        //averageTransform.vector.multiplyVector(0.5);
	        return averageTransform;
	    };

	    //###################################################################################################
	    //                                          KEYBOARD EVENTS                                         #
	    //###################################################################################################

	    /**
		 * Function used when the keyboard is pressed
		 * @method
		 * @private
		 */
	    PlaneController.prototype.keyboardPress = function (argm) {
	        var key = argm.getKey();

	        if (key === this.accelerate) {
	            this._keyPressed.accelerate = true;
	        }
	        if (key === this.decelerate) {
	            this._keyPressed.decelerate = true;
	        }
	        if (key === this.moveUp) {
	            this._keyPressed.moveUp = true;
	        }
	        if (key === this.moveDown) {
	            this._keyPressed.moveDown = true;
	        }
	        if (key === this.turnLeft) { //eQ
	            this._keyPressed.turnLeft = true;
	        }
	        if (key === this.turnRight) { //eD
	            this._keyPressed.turnRight = true;
	        }
	        if (key === this.rollRight) {
	            this._keyPressed.rollRight = true;
	        }
	        if (key === this.rollLeft) {
	            this._keyPressed.rollLeft = true;
	        }
	    };

	    /**
		 * Function used when the keyboard is release
		 * @method
		 * @private
		 */
	    PlaneController.prototype.keyboardRelease = function (argm) {
	        var key = argm.getKey();
	        if (key === this.accelerate) {
	            this._keyPressed.accelerate = false;
	        }
	        if (key === this.decelerate) {
	            this._keyPressed.decelerate = false;
	        }
	        if (key === this.moveUp) {
	            this._keyPressed.moveUp = false;
	        }
	        if (key === this.moveDown) {
	            this._keyPressed.moveDown = false;
	        }
	        if (key === this.turnLeft) { //eQ
	            this._keyPressed.turnLeft = false;
	        }
	        if (key === this.turnRight) { //eD
	            this._keyPressed.turnRight = false;
	        }
	        if (key === this.rollRight) {
	            this._keyPressed.rollRight = false;
	        }
	        if (key === this.rollLeft) {
	            this._keyPressed.rollLeft = false;
	        }
	    };

	    /**
         * Update the keyboard controller
         * @method
         * @private
         */
	    PlaneController.prototype.updateManualControl = function (iDelta) {

	        //Keyboard
	        if (this._keyPressed.accelerate) {
	            this.speedUpFunc(iDelta);
	        }
	        if (this._keyPressed.decelerate) {
	            this.speedDownFunc(iDelta);
	        }

	        if (this._keyPressed.moveUp) {
	            this.moveUpFunc(iDelta);
	        }
	        if (this._keyPressed.moveDown) {
	            this.moveDownFunc(iDelta);
	        }

	        if (this._keyPressed.turnLeft) {
	            this.turnLeftFunc(iDelta, true);
	        }
	        if (this._keyPressed.turnRight) {
	            this.turnRightFunc(iDelta, true);
	        }

	        if (this._keyPressed.rollLeft) {
	            this.rollLeftFunc(iDelta);
	        }
	        if (this._keyPressed.rollRight) {
	            this.rollRightFunc(iDelta);
	        }

	        //Gamepad
	        if (this._gamepadBtnPressed.accelerate > 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.accelerate;
	            this.speedUpFunc(iDelta);
	        }
	        if (this._gamepadBtnPressed.decelerate > 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.decelerate;
	            //this.speedDownFunc(deltaClone);
	            this.speedDownFunc(iDelta);
	        }
	        if (this._gamepadBtnPressed.moveUp > 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.moveUp;
	            this.moveUpFunc(iDelta);
	        }
	        if (this._gamepadBtnPressed.moveDown < 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.moveDown * -1;
	            this.moveDownFunc(iDelta);
	        }
	        if (this._gamepadBtnPressed.turnLeft < 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.turnLeft * -1;
	            this.turnLeftFunc(iDelta, true);
	        }
	        if (this._gamepadBtnPressed.turnRight > 0) {
	            //var deltaClone = iDelta;
	            //deltaClone.deltaTime *= this._gamepadBtnPressed.turnRight;
	            this.turnRightFunc(iDelta, true);
	        }
	        if (this._gamepadBtnPressed.rollLeft) {
	            this.rollLeftFunc(iDelta);
	        }
	        if (this._gamepadBtnPressed.rollRight) {
	            this.rollRightFunc(iDelta);
	        }
	    };

	    PlaneController.prototype.onGamepadEvent = function (iGamepadEvent) {
	        //console.log(iGamepadEvent);
	        var isPressed = 0;
	        var axis = 0;

	        if (iGamepadEvent.constructor === EP.GamepadPressEvent) {
	            isPressed = 1;
	        } else if (iGamepadEvent.constructor === EP.GamepadReleaseEvent) {
	            isPressed = 0;
	        } else if (iGamepadEvent.constructor === EP.GamepadAxisEvent) {
	            axis = 1;
	        } else {
	            return;
	        }

	        if (isPressed != -1) {
	            switch (iGamepadEvent.button) {
	                case EP.Gamepad.EButton.eRB:
	                    this._gamepadBtnPressed.rollRight = isPressed;
	                    break;
	                case EP.Gamepad.EButton.eLB:
	                    this._gamepadBtnPressed.rollLeft = isPressed;
	                    break;
	            }
	        }

	        if (axis) {
	            switch (iGamepadEvent.getAxis()) {
	                case EP.Gamepad.EAxis.eLT:
	                    this._gamepadBtnPressed.accelerate = iGamepadEvent.getAxisValue();
	                    break;
	                case EP.Gamepad.EAxis.eRT:
	                    this._gamepadBtnPressed.decelerate = iGamepadEvent.getAxisValue();
	                    break;
	                case EP.Gamepad.EAxis.eRSX:
	                    var axisValue = iGamepadEvent.getAxisValue();
	                    this._gamepadBtnPressed.turnRight = (axisValue > 0) ? axisValue : 0;
	                    this._gamepadBtnPressed.turnLeft = (axisValue < 0) ? axisValue : 0;
	                    break;
	                case EP.Gamepad.EAxis.eLSY:
	                    var axisValue = iGamepadEvent.getAxisValue();
	                    this._gamepadBtnPressed.moveUp = (axisValue > 0) ? axisValue : 0;
	                    this._gamepadBtnPressed.moveDown = (axisValue < 0) ? axisValue : 0;
	                    break;
	            }
	        }
	    };

	    //###################################################################################################
	    //                                          		UTILS                                         	#
	    //###################################################################################################

	    /**
		 * Transform a vector from the local referential, to the world referential
		 * @method
		 * @private
		 */
	    PlaneController.prototype.vectorLocalToWorldReferential = function (iVec, iTransfo) {
	        if (!(iVec instanceof DSMath.Vector3D)) {
	            throw new TypeError('iVec argument is not a DSMath.Vector3D');
	        }
	        var translationVector = new DSMath.Vector3D(iVec.x, iVec.y, iVec.z);

	        if (iTransfo !== undefined && iTransfo !== null) {
	            var refMatrix = iTransfo.matrix;
	            var refMatrixCoef = refMatrix.getArray();
	            var scale = Math.sqrt(refMatrixCoef[0] * refMatrixCoef[0] + refMatrixCoef[3] * refMatrixCoef[3] + refMatrixCoef[6] * refMatrixCoef[6]);

	            if (scale !== 1.0 && scale !== 0.0) {
	                for (var i = 0; i < refMatrixCoef.length; i++) {
	                    refMatrixCoef[i] /= scale;
	                }
	                refMatrix.setFromArray(refMatrixCoef);
	            }
	            translationVector = translationVector.applyMatrix3x3(refMatrix);
	        }
	        return translationVector;
	    };

	    /**
		 * Update the value of this._angleToDestination with the angle between the plane's front and the destination
		 * @method
		 * @private
		 */
	    PlaneController.prototype.updateAngleToDestination = function (destination) {
	        // Getting the direction vector of the plane
	        var planeMatrix = this._initialMatrix.clone();
	        planeMatrix.multiply(this._reorientationMatrix);
	        var rotZ = new DSMath.Vector3D(0.0, 0.0, 1.0);

	        var rotMatrix = new DSMath.Matrix3x3();
	        rotMatrix.makeRotation(rotZ, this._yaw);
	        planeMatrix.multiply(rotMatrix);

	        var planeDirection = planeMatrix.getFirstColumn();
	        planeDirection.normalize();
	        // the scalar product to compute the angle
	        var dest = destination.clone();
	        dest.z = 0;
	        dest.normalize();
	        var dot = planeDirection.dot(dest);

	        if (dot >= 1) {
	            this._angleToDestination = 0.0;
	        } else if (dot <= -1) {
	            this._angleToDestination = Math.PI;
	        } else {
	            this._angleToDestination = Math.acos(dot);
	        }
	        this._angleSignToDestination = planeDirection.x * dest.y - planeDirection.y * dest.x;
	    };

	    /**
		 * Compute the distance from a point to a line in 2D
		 * @method
		 * @private
		 */
	    PlaneController.prototype.pointToLineDistance2D = function (a, b, c) {
	        var top = Math.abs((c.x - b.x) * (b.y - a.y) - (b.x - a.x) * (c.y - b.y));
	        var bot = Math.sqrt((c.x - b.x) * (c.x - b.x) + (c.y - b.y) * (c.y - b.y));
	        return top / bot;
	    };

	    /**
		 * Compute the distance from a point to an other position in 3D
		 * @method
		 * @private
		 */
	    PlaneController.prototype.DistanceToPosition = function (position) {
	        var vectDiff = position.clone();
	        vectDiff.sub(this._plane.getTransform().vector);
	        return vectDiff.norm();
	    };

	    /**
		 * Compute the distance from a point to an other position in 2D
		 * @method
		 * @private
		 */
	    PlaneController.prototype.DistanceToPosition2D = function (position) {
	        //var vectDiff = position.clone();
	        //vectDiff.subVectorFromVector(this._plane.getTransform().vector);
	        //vectDiff.z = 0;
	        var vectDiff = DSMath.Vector3D.sub(position, this._plane.getPosition());
	        vectDiff.z = 0;
	        return vectDiff.norm();
	    };

	    /**
		 * Easing function
		 * @method
		 * @private
		 */
	    PlaneController.prototype.easeInOutQuad = function (t, b, c, d) {
	        if (d === 0.0) {
	            console.debug('Divide 0 easeInOutQuad');
	            return 0;
	        } else {
	            t /= d / 2;
	            if (t < 1) {
	                return c / 2 * t * t + b;
	            }
	            t--;
	            return -c / 2 * (t * (t - 2) - 1) + b;
	        }
	    };

	    /**
		 * Easing function, it's return the computed value
		 * @method
		 * @private
		 * @param {Number} t - current time
		 * @param {Number} b - beginning value
		 * @param {Number} c - change in value
		 * @param {Number} d - duration
		 */
	    PlaneController.prototype.easeOutQuad = function (t, b, c, d) {
	        if (d === 0.0) {
	            console.debug('Divide 0 easeOutQuad');
	            return 0;
	        }
	        t /= d;
	        return -c * t * (t - 2) + b;
	    };

	    /**
		 * Adapt the velocity of the plane
		 * @method
		 * @private
		 */
	    PlaneController.prototype.adaptVelocity = function (iDelta, forceAdapt) {
	        // Update velocity is used to have a nice following velocity when the plane change its direction
	        var velocity = this._velocity.clone();
	        var veloNorm = velocity.norm();
	        var forwardVector = new DSMath.Vector3D();
	        var planeMatrix = this._plane.getTransform().matrix.clone();
	        planeMatrix.multiply(this._reorientationMatrix);
	        forwardVector.set(planeMatrix.coef[0], planeMatrix.coef[3], planeMatrix.coef[6]);
	        forwardVector.normalize();
	        if (forceAdapt !== undefined && forceAdapt === true) {
	            this._velocity = forwardVector.multiplyScalar(veloNorm);
	        }
	        if (Math.abs(this._pitch) < 0.26) {
	            //forwardVector.multiplyVector(veloNorm * (iDelta.deltaTime / 1000) * this.maneuverability);
	            forwardVector.multiplyScalar(veloNorm * (iDelta.deltaTime / 1000) * (1 / this.inertiaFactor));
	        } else {
	            //forwardVector.multiplyScalar(veloNorm * (iDelta.deltaTime / 6000) * this.maneuverability);
	            forwardVector.multiplyScalar(veloNorm * (iDelta.deltaTime / 6000) * (1 / this.inertiaFactor));
	        }
	        velocity.add(forwardVector);
	        if (velocity.norm() !== 0.0) {
	            velocity.normalize();
	            velocity.multiplyScalar(veloNorm);
	            this._velocity = velocity;
	        }
	    };

	    /**
		 * Check if the angle between the plane and the landing runaway is too low. If it is, compute a new local destination
		 * @method
		 * @private
		 */
	    PlaneController.prototype.checkTargetedPoints = function () {
	        var B = this._anticipatedLandingPointB.clone();
	        var C = this._anticipatedLandingPointC.clone();
	        var vector = this._plane.getTransform().vector.clone();
	        var BC = Math.sqrt((B.x - C.x) * (B.x - C.x) + (B.y - C.y) * (B.y - C.y));
	        var d = this.DistanceToPosition2D(C);
	        var b = this.DistanceToPosition2D(B);
	        B.sub(vector);
	        C.sub(vector);
	        B.z = 0;
	        C.z = 0;
	        B.normalize();
	        C.normalize();
	        var dot = C.dot(B);
	        var sign = C.x * B.y - C.y * B.x;
	        var cosTheta = (d - dot * b) / BC;
	        var theta = 0;
	        if (cosTheta >= 1) {
	            theta = 0.0;
	        } else if (cosTheta <= -1) {
	            theta = Math.PI;
	        } else {
	            theta = Math.acos(cosTheta);
	        }
	        if (theta < Math.PI / 2) {
	            // We need to set a new localDestination
	            var z = new DSMath.Vector3D(0, 0, 1);
	            //z.set(0, 0, 1);
	            var orthogonalToLanding = DSMath.Vector3D.cross(this._landingDirection, z);
	            orthogonalToLanding.z = 0;
	            orthogonalToLanding.normalize();
	            if (sign < 0) {
	                orthogonalToLanding.multiplyScalar(4 * BC);
	            } else {
	                orthogonalToLanding.multiplyScalar(-4 * BC);
	            }
	            var bcVec = this._anticipatedLandingPointB.clone();
	            bcVec.sub(this._anticipatedLandingPointC);
	            bcVec.multiplyScalar(-1);
	            this._localDestination = this._anticipatedLandingPointC.clone();
	            this._localDestination.add(bcVec);
	            this._localDestination.add(orthogonalToLanding);
	        }
	    };

	    /**
		 * Compute de pitch difference between the plane and the vector
		 * @method
		 * @private
		 */
	    PlaneController.prototype.getPitchDiff = function (vec) {
	        var planeMatrix = this._initialMatrix.clone();
	        planeMatrix.multiply(this._reorientationMatrix);
	        var rotZ = new DSMath.Vector3D(0.0, 0.0, 1.0);
	        var rotMatrix = new DSMath.Matrix3x3();
	        //rotZ.setCoord(0.0, 0.0, 1.0);
	        var yaw = this._yaw;
	        if (this._angleSignToDestination > 0) {
	            yaw += this._angleToDestination * 3 / 4;
	        } else {
	            yaw -= this._angleToDestination * 3 / 4;
	        }
	        rotMatrix.makeRotation(rotZ, yaw);//rotMatrix.setRotation(rotZ, yaw);
	        planeMatrix.multiply(rotMatrix);
	        var planeDirection = planeMatrix.getFirstColumn();
	        planeDirection.normalize();

	        var vec2 = vec.clone();
	        vec2.normalize();

	        var dot = planeDirection.dot(vec2);
	        var angle = 0;
	        if (dot > 0.9999) {
	            angle = 0.0;
	        } else if (dot < -0.9999) {
	            angle = Math.PI;
	        } else {
	            angle = Math.acos(dot);
	        }
	        var angleSign = vec2.z - planeDirection.z;
	        if (angleSign < 0) {
	            angle *= -1;
	        }
	        return angle;
	    };

	    /**
		 * Showing sphere primitive along the path {For debug purpose} 
		 * @method
		 * @private
		 */
	    PlaneController.prototype.analysePathUserScale = function (iPath) {
	        // this._targets = new Array();
	        //this._pathLength = this._flyingPathTarget.getLength();

	        var sCoeff = 0.025;
	        sCoeff = sCoeff > 1 ? 1 : sCoeff;
	        sCoeff = sCoeff < 0 ? 0 : sCoeff;

	        //var divisionMin = Math.round(this._pathLength * 0.05);
	        var divisionMin = 20;
	        var divisionMax = this._pathLength / 1000;

	        var division = (1 - sCoeff) * divisionMin + sCoeff * divisionMax;
	        division = Math.round(division);

	        /*console.log("pathLength: " + this._pathLength);
            console.log("divisionMin: " + divisionMin);
            console.log("divisionMax: " + divisionMax);
            console.log("division: " + division);
            console.log("NB: " + (this._pathLength/division));*/
	        //var pathStep = pathLength / division;

	        for (var i = 0; i <= division; i++) {
	            var pos = iPath.getValue(i / division, this._globeLocation);
	            if (true) {
	                //this.drawSphere(pos, 0.3 * 1000 * this._scale, 5, -1);
	                //Create Debug Sphere
	                var localTransfo = new DSMath.Transformation();
	                localTransfo.vector = pos;
	                var iColor = new STU.Color(0, 25, 255);
	                var render = STU.RenderManager.getInstance();
	                render._createSphere({ radius: 2500, position: localTransfo, color: iColor, alpha: 255, lifetime: -1 });
	            }
	            //this._targets.push(pos);

	            /*if (i == 0) {
                    this._currentTarget = pos.clone();
                }
                else if (i == division) {
                    this._endTarget = pos.clone();
                }*/
	        }
	    };

	    /**
		 * linear interpolation function 
		 * @method
		 * @private
		 */
	    PlaneController.prototype.lerp = function (v0, v1, t) {
	        return (1 - t) * v0 + t * v1;
	    };

	    STU.PlaneController = PlaneController;
	    return PlaneController;

	});

define('StuMiscContent/StuPlaneController', ['DS/StuMiscContent/StuPlaneController'], function (PlaneController) {
    'use strict';

    return PlaneController;
});

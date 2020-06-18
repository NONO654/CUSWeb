/* global define */
define('DS/StuMiscContent/StuHelicopterController', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices',
		'DS/EPEventServices/EPEvent', 'MathematicsES/MathsDef', 'DS/EPInputs/EPKeyboard', 'DS/EPInputs/EPKeyboardPressEvent', 'DS/EPInputs/EPKeyboardReleaseEvent'
	],
	function(STU, EP, Behavior, Task, EventServices, Event, DSMath) {
		'use strict';


		var HelicopterControllerTask = function(iComp) {
			Task.call(this);
			this.comp = iComp;
		};

		HelicopterControllerTask.prototype = new Task();
		HelicopterControllerTask.prototype.constructor = HelicopterControllerTask;


		/**
		 * Method called each frame by the task manager
		 *
		 * @method
		 * @private
		 * @param  iExContext Execution context
		 */
		HelicopterControllerTask.prototype.onExecute = function(iExContext) {
			if ('executeOneFrame' in this.comp) {
				this.comp.executeOneFrame(iExContext);
			}
		};

		/**
		 * This event is thrown when the helicopter has reached his target
		 *
		 * @param {STU.Actor} iTarget The target that has been reached by the actor
		 * @param {STU.Actor} iActor  The STU.Actor that has reached the target
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
		var HelicopterHasReachedEvent = function(iTarget, iActor) {
			Event.call(this);

			/**
			 * The target that has been reached by the actor
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
			this.targetActor = iTarget !== undefined ? iTarget : null;

			/**
			 * The STU.Actor that has reached the target
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
			this.actor = iActor !== undefined ? iActor : null;
		};

		HelicopterHasReachedEvent.prototype = new Event();
		HelicopterHasReachedEvent.prototype.constructor = HelicopterHasReachedEvent;
		HelicopterHasReachedEvent.prototype.type = 'HelicopterHasReachedEvent';

		// Expose in STU namespace.
		STU.HelicopterHasReachedEvent = HelicopterHasReachedEvent;
		EP.EventServices.registerEvent(HelicopterHasReachedEvent);

		/**
		 * his event is thrown when the helicopter has reached the end of a path
		 *
		 * @param {STU.PathActor} iTarget The path that the STU.Actor had followed
		 * @param {STU.Actor} iActor  The STU.Actor that has reached the end of the path
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
		var HelicopterHasCompletedEvent = function(iPath, iActor) {
			Event.call(this);

			/**
			 * The path that the STU.Actor had followed
			 *
			 * @type {STU.PathActor}
			 * @public
			 * @default
			 */
			this.path = iPath !== undefined ? iPath : null;

			/**
			 * The STU.Actor that has reached the end of the path
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
			this.actor = iActor !== undefined ? iActor : null;
		};

		HelicopterHasCompletedEvent.prototype = new Event();
		HelicopterHasCompletedEvent.prototype.constructor = HelicopterHasCompletedEvent;
		HelicopterHasCompletedEvent.prototype.type = 'HelicopterHasCompletedEvent';

		// Expose in STU namespace.
		STU.HelicopterHasCompletedEvent = HelicopterHasCompletedEvent;
		EP.EventServices.registerEvent(HelicopterHasCompletedEvent);


		/**
		 * Describe a helicopter controller behavior
		 *
		 * @exports HelicopterController
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
		 * @alias STU.HelicopterController
		 */
		var HelicopterController = function() {
			Behavior.call(this);
			this.name = 'HelicopterController';
			this.associatedTask;



			// Public

			/**
			 * The Maximum speed reached by the helicopter
			 * @public
			 * @type {Number}
			 */
			this.maximumSpeed = 60;

			/**
			 * The acceleration of the helicopter (m/s²)
			 * @public
			 * @type {Number}
			 */
			this.acceleration = 5;

			/**
			 * The rotating acceleration of the helicopter
			 * @public
			 * @type {Number}
			 */
			this.angularSpeed = 1;

			/**
			 * The inertia of the helicopter (0 means no inertia)
			 * @public
			 * @type {Number}
			 */
			this.inertiaFactor = 1;

			/**
			 * Distance between the helicopter and the local target when following path (meters)
			 * @public
			 * @type {Number}
			 */
			this.followingTrackDistance = 10000;

			/**
			 * Distance to the destination where the helicopter will start going down (GoTo function)
			 * @public
			 * @type {Number}
			 */
			this.landingDistance = 20000;

			/**
			 * The cruising altitude used for the GoTo function
			 * @public
			 * @type {Number}
			 */
			this.flightAltitude = 20000;

			/**
			 * Distance used for the GoTo function to check is there is an obstacle in front of the helicopter
			 * @public
			 * @type {Number}
			 */
			this.obstacleDetectionDistance = 60000;

			/**
			 * Distance before each check of the avoidance system
			 * @public
			 * @type {Number}
			 */
			this.obstacleDetectionFrequency = 5000;

			/**
			 * Distance to the floor at which the helicopter will automatically land if it's going down
			 * @public
			 * @type {Number}
			 */
			this.automaticLandingHeight = 5000;

			/**
			 * Add noise to the helicopter
			 * @public
			 * @type {Boolean}
			 */
			this.enableTurbulence = true;

			/** 
			 * The main rotor of the helicopter
			 * @public
			 * @type {Object}
			 */
			this.mainRotor = null;

			/**
			 * The tail rotor of the helicopter
			 * @public
			 * @type {Object}
			 */
			this.tailRotor = null;

			/**
			 * If is enable, the boat will be controlled by a gamepad
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.useGamePad = false;

			/**
			 * Mapped key for moving forward
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.moveForward = EP.Keyboard.EKey.eUp;

			/**
			 * Mapped key for moving backward
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.moveBackward = EP.Keyboard.EKey.eDown;

			/**
			 * Mapped key to gain altitude
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.goUp = EP.Keyboard.EKey.eSpace;

			/**
			 * Mapped key to lose altitude
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.goDown = EP.Keyboard.EKey.eShift;

			/**
			 * Mapped key for turning to the left
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.turnLeft = EP.Keyboard.EKey.eLeft;

			/**
			 * Mapped key for turning to the right
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.turnRight = EP.Keyboard.EKey.eRight;

			/**
			 * Mapped key for moving laterally to the left
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.moveLeft = EP.Keyboard.EKey.eNumpad4;

			/**
			 * Mapped key for moving laterally to the right
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.moveRight = EP.Keyboard.EKey.eNumpad6;

			/**
			 * Mapped key to start/stop the engine
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
			this.engine = EP.Keyboard.EKey.eX;

			// Private
			/**
			 * Keyboard listener for press and release
			 * @private
			 * @type {Object}
			 */
			this._keyboardPressCb = null;

			/**
			 *  Rotation speed of the main rotor and the tail's rotor
			 * @private
			 * @type {Number}
			 */
			this._rotorRotationSpeed = 0.0;

			/**
			 * The current yaw of the helicopter
			 * @private
			 * @type {Number}
			 */
			this._yaw = 0.0;

			/**
			 * The  yaw variation
			 * @private
			 * @type {Number}
			 */
			this._yawSpeed = 0.0;

			/**
			 * The current pitch of the helicopter
			 * @private
			 * @type {Number}
			 */
			this._pitch = 0.0;

			/**
			 * The  pitch variation
			 * @private
			 * @type {Number}
			 */
			this._pitchSpeed = 0.0;

			/**
			 * The current roll of the helicopter
			 * @private
			 * @type {Number}
			 */
			this._roll = 0.0;

			/**
			 * The  roll variation
			 * @private
			 * @type {Number}
			 */
			this._rollSpeed = 0.0;

			/**
			 * Distance from the helicopter to the ground when it starts to land
			 * @private
			 * @type {Number}
			 */
			this._landingHeight = 0.0;

			/**
			 * Current time of a specific action
			 * @private
			 * @type {Number}
			 */
			this._currentActionTime = 0.0;

			/**
			 * Duration of a specific action
			 * @private
			 * @type {Number}
			 */
			this._totalActionTime = 0.0;

			/**
			 * Duration of the rotating procedure
			 * @private
			 * @type {Number}
			 */
			this._totalRotatingTime = 0.0;

			/**
			 * The path length of the followed path
			 * @private
			 * @type {Number}
			 */
			this._pathLength = 0.0;

			/**
			 * Current position tracking in the path
			 * @private
			 * @type {Number}
			 */
			this._currentFollowPathDist = 0.0;

			/**
			 *  Current time during the FollowPath procedure
			 * @private
			 * @type {Number}
			 */
			this._currentFollowPathTime = 0.0;

			/**
			 * The current state of the landing procedure
			 * @private
			 * @type {Number}
			 */
			this._landingState = 0.0;

			/**
			 * The z position of the helicopter when it starts to land
			 * @private
			 * @type {Number}
			 */
			this._startLandingHeight = 0.0;

			/**
			 * The forward velocity of the helicopter when it starts to land
			 * @private
			 * @type {Number}
			 */
			this._startLandingVelocity = 0.0;

			/**
			 * Distance detected when the helicopter starts to land
			 * @private
			 * @type {Number}
			 */
			this._startLandingDst = 0.0;

			/**
			 * The angle of the helicopter to the destination when it starts to land
			 * @private
			 * @type {Number}
			 */
			this._startLandingAngle = 0.0;

			/**
			 *  The z position of the helicopter when it starts to take-off
			 * @private
			 * @type {Number}
			 */
			this._startTakeoffHeight = 0.0;

			/**
			 * The height computed that the helicopter will try to reach during the takeoff procedure
			 * @private
			 * @type {Number}
			 */
			this._takeoffHeightDiff = 0.0;

			/**
			 * Current state of the Goto procedure
			 * @private
			 * @type {Number}
			 */
			this._goToState = 0.0;

			/**
			 * Angle between the helicopter and the direction to the destination. Used for the yaw tracking
			 * @private
			 * @type {Number}
			 */
			this._angleToDestination = 0.0;

			/**
			 * The sign of the angle. If < 0  the destination is on the right, and if > 0 on the left.
			 * @private
			 * @type {Number}
			 */
			this._angleSignToDestination = 0.0;

			/**
			 * The seed for the seededrandom generator
			 * @private
			 * @type {Number}
			 */
			this._seed = 1;

			/**
			 * The current velocity of the helicopter
			 * @private
			 * @type {DSMath.Vector3D}
			 */
			this._velocity = new DSMath.Vector3D();

			/**
			 * The current destination tracked by the helicopter during the Goto and FollowPath procedure.
			 * @private
			 * @type {DSMath.Vector3D}
			 */
			this._destination = new DSMath.Vector3D();

			/**
			 * The computed axis of the tail's rotor used for the rotation
			 * @private
			 * @type {DSMath.Vector3D}
			 */
			this._tailRotorAxis = new DSMath.Vector3D();

			/**
			 * If the target is oriented, the helicopter will try to set his front vector as the target's one : _targetOrientation
			 * @private
			 * @type {DSMath.Vector3D}
			 */
			this._targetOrientation = new DSMath.Vector3D();

			/**
			 * Local destination used to avoid collisions
			 * @private
			 * @type {DSMath.Vector3D}
			 */
			this._localTarget = new DSMath.Vector3D();

			/**
			 * True if the helicopter is starting his engines
			 * @private
			 * @type {Boolean}
			 */
			this._isStartEngineState = false;

			/**
			 * True if the helicopter is landing
			 * @private
			 * @type {Boolean}
			 */
			this._isLandingState = false;

			/**
			 * True is the helicopter tries to track the destination
			 * @private
			 * @type {Boolean}
			 */
			this._isYawTrackingState = false;

			/**
			 * True if the helicopter is in the Goto procedure
			 * @private
			 * @type {Boolean}
			 */
			this._isGoToState = false;

			/**
			 * True if the helicopter is in the FollowingPath procedure
			 * @private
			 * @type {Boolean}
			 */
			this._isFollowPathState = false;

			/**
			 *  True if the helicopter is taking  off during a procedure
			 * @private
			 * @type {Boolean}
			 */
			this._isTakeoffState = false;

			/**
			 *  True if the helicopter uses the CruisingAltitudeState. Moving forward and avoiding collision by surrounding them.
			 * @private
			 * @type {Boolean}
			 */
			this._isCruisingAltitudeState = false;

			/**
			 *  True if the helicopter is doing a vertical tracking to the destination
			 * @private
			 * @type {Boolean}
			 */
			this._isHeightTrackingState = false;

			/**
			 * True if the destination of the Goto procedure is oriented ( not a Point )
			 * @private
			 * @type {Boolean}
			 */
			this._isTargetOriented = false;

			/**
			 * True if the helicopter is landed.
			 * @private
			 * @type {Boolean}
			 */
			this._isLanded = true;


			/**
			 * True if the velocity linked to the axis is modified with a moveX() x,y,z : axis
			 * @private
			 * @type {Object}
			 */
			this._axisModified = {};

			/**
			 * True if the velocity linked to the axis x is modified with a moveX()
			 * @private
			 * @type {Boolean}
			 */
			this._axisModified.x = false;

			/**
			 * True if the velocity linked to the axis y is modified with a moveX()
			 * @private
			 * @type {Boolean}
			 */
			this._axisModified.y = false;

			/**
			 * True if the velocity linked to the axis z is modified with a moveX()
			 * @private
			 * @type {Boolean}
			 */
			this._axisModified.z = false;

			/**
			 * Key pressed/released handler
			 * @private
			 * @type {Object}
			 */
			this._keyPressed = {};

			/**
			 * True if the 'front' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.front = false;

			/**
			 * True if the 'back' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.back = false;

			/**
			 * True if the 'left' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.left = false;

			/**
			 * True if the 'right' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.right = false;

			/**
			 * True if the 'up' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.up = false;

			/**
			 * True if the 'down' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.down = false;

			/**
			 * True if the 'moveRight' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.moveRight = false;

			/**
			 * True if the 'moveLeft' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.moveLeft = false;

			/**
			 * True if the 'engine' key is pressed
			 * @private
			 * @type {Boolean}
			 */
			this._keyPressed.engine = false;

			/**
			 * Save of the Cruising Altitude
			 * @private
			 * @type {Number}
			 */
			this._flightAltitudeSave = 0.0;

			/**
			 * The helicopter Actor3D
			 * @private
			 * @type {Number}
			 */
			this._helicopter = null;

			/**
			 *  The scale of the helicopter
			 * @private
			 * @type {Number}
			 */
			this._helicopterScale = 0.0;

			/**
			 * The initial matrix of the helicopter
			 * @private
			 * @type {Number}
			 */
			this._initialMatrix = null;


			/**
			 * The matrix used to realign the helicopter matrix with the world matrix
			 * @private
			 * @type {Number}
			 */
			this._realignMatrix = null;

			/**
			 * The scene actor in case where we are in globe context
			 * @private
			 * @type {Number}
			 */
			this._globeLocation = null;

			/**
			 * Variable tst pour ODT (TO DELETE)
			 * @private
			 * @type {Number}
			 **/
			/*this._tmpDist = 0;*/
			this._odtTstDist = 0;
			this._odtGotoState = 0;
			this._odtHelicoVector = null;
		};

		HelicopterController.prototype = new Behavior();
		HelicopterController.prototype.constructor = HelicopterController;
		HelicopterController.prototype.pureRuntimeAttributes = ['_keyboardPressCb'].concat(Behavior.prototype.pureRuntimeAttributes);

		/**
		 * Process executed when STU.HelicopterController is activating
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.onActivate = function() {
			Behavior.prototype.onActivate.call(this);
			this.associatedTask = new HelicopterControllerTask(this);
			EP.TaskPlayer.addTask(this.associatedTask);

			this._keyboardPressCb = STU.makeListener(this, 'keyboardPress');
			EventServices.addListener(EP.KeyboardPressEvent, this._keyboardPressCb);

			this._keyboardReleaseCb = STU.makeListener(this, 'keyboardRelease');
			EventServices.addListener(EP.KeyboardReleaseEvent, this._keyboardReleaseCb);
			//console.log(this.flightAltitude);
			// Value Check
			if (this.inertiaFactor === 0) {
				console.log('[Helicopter Controller] Warning : inertiaFactor is set to 0');
			}
			if (this.maximumSpeed === 0) {
				console.log('[Helicopter Controller] Warning : speed is set to 0');
			}
			if (this.inertiaFactor === undefined) {
				console.log('[Helicopter Controller]: inertiaFactor is not defined. Please update the properties.');
			}
			if (this.tailRotor === null || this.tailRotor === undefined) {
				console.warn('[Helicopter Controller] : Tail Rotor is not defined.');
				this.tailRotor = undefined;
			}
			if (this.mainRotor === null || this.mainRotor === undefined) {
				console.warn('[Helicopter Controller] : Main Rotor is not defined.');
				this.mainRotor = undefined;
			}
			if (this.acceleration === undefined) {
				console.log('[Helicopter Controller] acceleration is not defined. Please update the properties.');
			}
			if (this.landingDistance === undefined) {
				console.log('[Helicopter Controller] landingDistance is not defined. Please update the properties.');
			}
			if (this.maximumSpeed === undefined) {
				console.log('[Helicopter Controller] speed is not defined. Please update the properties.');
			}
			if (this.flightAltitude === undefined) {
				console.log('[Helicopter Controller] flightAltitude is not defined. Please update the properties.');
			}
			if (this.followingTrackDistance === undefined) {
				console.log('[Helicopter Controller] followingTrackDistance is not defined. Please update the properties.');
			}
			if (this.automaticLandingHeight === undefined) {
				console.log('[Helicopter Controller] automaticLandingHeight is not defined. Please update the properties.');
			}
			if (this.angularSpeed === undefined) {
				console.log('[Helicopter Controller] angularSpeed is not defined. Please update the properties.');
			}
			console.debug('HelicoController onStart done. Everything look fine.');
			//console.log("Speed: " + this.maximumSpeed);
			// this.gamepadCB = STU.makeListener(this, 'onGamepadEvent');
			// EP.EventServices.addListener(EP.GamepadEvent, this.gamepadCB);

			/*if (this.mainRotor !== undefined && this.mainRotor !== null && this.tailRotor !== undefined && this.tailRotor !== null) {
			    
			}*/
			/*if(!this.tailRotor){
			    console.wanr('[Helicopter Controller] : Tail Rotor is not defined.');
			    this.tailRotor = undefined;
			}*/
			if (this.mainRotor !== undefined && this.tailRotor !== undefined) {
				if (this.mainRotor === this.tailRotor) {
					console.error('Main Rotor and Tail Rotor is the same object.');
					this.mainRotor = undefined;
					this.tailRotor = undefined;
				}
			}

			this._flightAltitudeSave = this.flightAltitude;
			this._helicopter = this.getActor();
			this._globeLocation = this._helicopter.getLocation();
			this._helicopterScale = this._helicopter.getScale();
			this._initialMatrix = this._helicopter.getTransform().matrix.clone();
			this._realignMatrix = this._helicopter.getTransform().matrix.clone();
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				this.computeHelicopterAxis();
			}

		};


		/**
		 * Process executed when STU.HelicopterController is deactivating
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.onDeactivate = function() {
			EventServices.removeListener(EP.KeyboardEvent, this._keyboardPressCb);
			delete this._keyboardPressCb;

			EventServices.removeListener(EP.KeyboardEvent, this._keyboardReleaseCb);
			delete this._keyboardReleaseCb;

			// EP.EventServices.removeListener(EP.GamepadEvent, this.gamepadCB);
			// delete this.gamepadCB;

			EP.TaskPlayer.removeTask(this.associatedTask);
			delete this.associatedTask;

			Behavior.prototype.onDeactivate.call(this);
		};
		//=============================================================================//
		//=============================================================================//

		/**
		 * Return True if the helicopter is currently going to the specified target.
		 * @param  {STU.Actor3D} iTarget  The specified target
		 * @method
		 * @public
		 * @return {Boolean}
		 */
		HelicopterController.prototype.isFlyingTo = function(actor) {
			if (actor === this._target) {
				return this._isGoToState;
			}
			return false;
		};

		/**
		 * Return True if the helicopter is currently following the specified path
		 * @param  {STU.PathActor} iTarget  The specified path
		 * @method
		 * @public
		 * @return {Boolean}
		 */
		HelicopterController.prototype.isFlyingAlong = function(path) {
			if (path === this._target) {
				return this._isFollowPathState;
			}
			return false;
		};

		/**
		 * Returns true if the helicopter is currently landed
		 * @method
		 * @public
		 * @return {Boolean}
		 */
		HelicopterController.prototype.isLanded = function() {
			return this._isLanded;
		};

		/**
		 * Returns true if the helicopter is flying
		 * @method
		 * @public
		 * @return {Boolean}
		 */
		HelicopterController.prototype.isFlying = function() {
			return !this._isLanded;
		};


		/**
		 * Convert a vector from a local referential to the world's one using the transformation object
		 * @param  {DSMath.Vector3D} iVec  the 3d Vector to convert
		 * @param  {DSMath.Transformation} iTransfo :  transformation which handle the local referential's matrix.
		 * @return {DSMath.Vector3D}  The 3d Vector in the world's referential
		 * @method
		 * @private
		 */
		HelicopterController.prototype.vectorLocalToWorldReferential = function(iVec, iTransfo) {
			if (!(iVec instanceof DSMath.Vector3D)) {
				throw new TypeError('iVec argument is not a DSMath.Vector3D');
			}
			var translationVector = new DSMath.Vector3D();
			translationVector.set(iVec.x, iVec.y, iVec.z);

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
				translationVector = translationVector.applyMatrix3x3(refMatrix); //ThreeDS.Mathematics.multiplyMatrixByVector(refMatrix, translationVector);
			}
			return translationVector;
		};

		/**
		 *  Easing function in/out
		 * @param  {Number} t current time
		 * @param  {Number} b beginning value
		 * @param  {Number} c change in value
		 * @param  {Number} d duration
		 * @return {Number} the computed value
		 * @method
		 * @private
		 */
		HelicopterController.prototype.easeInOutQuad = function(t, b, c, d) {
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
		 *  Easing function out
		 * @param  {Number} t current time
		 * @param  {Number} b beginning value
		 * @param  {Number} c change in value
		 * @param  {Number} d duration
		 * @return {Number} the computed value
		 * @method
		 * @private
		 */
		HelicopterController.prototype.easeOutQuad = function(t, b, c, d) {
			if (d === 0.0) {
				console.debug('Divide 0 easeOutQuad');
				return 0;
			}
			t /= d;
			return -c * t * (t - 2) + b;
		};


		/**
		 *   Use : computeHelicopterAxis is used to know where is the front of the helicopter and
		 *   the axis of the tail rotor
		 *
		 *   Prerequired :
		 *   -  The origin of the principal rotor need to be set on his rotating axis, and  his rotating
		 *   axis  set like the world.z axis, z pointing upward.
		 *   -  The origin of the tail rotor need to be set on his rotating axis, and  at least one axis
		 *   set as a rotating axis
		 *
		 *   Method : By doing a scalar product of the position of the origin of the main rotor with
		 *   every vector of the tail rotor's transformation matrix we are able to know at least one
		 *   vector not null in the plane (world.z, oneVector). With oneVector perpendicular to the
		 *   tail's rotor axis.
		 *   This this plane, we are able to compute the tail's rotor axis doing a cross product and
		 *   as the front of the helicopter is perpendicular to the tail's rotor axis, and the world.z,
		 *   we can compute it again doing a Vector3D cross product.
		 *   Then, we have enough information to compute the this._initialMatrix.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.computeHelicopterAxis = function() {
			var mainRotorCenter = this.mainRotor.getTransform().vector.clone();
			var tailRotorCenter = this.tailRotor.getTransform().vector.clone();
			var tailRotorMatrix = this.tailRotor.getTransform().matrix.clone();
			var tailRotorX = tailRotorMatrix.getFirstColumn();
			var tailRotorY = tailRotorMatrix.getSecondColumn();
			var tailRotorZ = tailRotorMatrix.getThirdColumn();
			var diffHelitailRotor = mainRotorCenter.sub(tailRotorCenter);
			var scalarX = tailRotorX.dot(diffHelitailRotor);
			var scalarY = tailRotorY.dot(diffHelitailRotor);
			var scalarZ = tailRotorZ.dot(diffHelitailRotor);
			var maxScalar = Math.max(Math.abs(scalarX), Math.abs(scalarY), Math.abs(scalarZ));
			var frontAxis = new DSMath.Vector3D();
			if (maxScalar === Math.abs(scalarX)) {
				this._tailRotorAxis = DSMath.Vector3D.cross(diffHelitailRotor, tailRotorX);
			} else if (maxScalar === Math.abs(scalarY)) {
				this._tailRotorAxis = DSMath.Vector3D.cross(diffHelitailRotor, tailRotorY);
			} else if (maxScalar === Math.abs(scalarZ)) {
				this._tailRotorAxis = DSMath.Vector3D.cross(diffHelitailRotor, tailRotorZ);
			}
			this._tailRotorAxis.normalize();
			var zAxis = new DSMath.Vector3D(0, 0, 1);
			//zAxis.set(0, 0, 1);
			frontAxis = DSMath.Vector3D.cross(this._tailRotorAxis, zAxis);
			var scalarSign = diffHelitailRotor.dot(frontAxis);
			frontAxis.normalize();
			if (scalarSign > 0) {
				frontAxis.multiplyScalar(-1);
			}
			this._tailRotorAxis = DSMath.Vector3D.cross(frontAxis, zAxis);
			this._tailRotorAxis.normalize();
			var coefs = [
				this._tailRotorAxis.x * this._helicopterScale, frontAxis.x * this._helicopterScale, 0,
				this._tailRotorAxis.y * this._helicopterScale, frontAxis.y * this._helicopterScale, 0,
				0, 0, this._helicopterScale
			];
			this._realignMatrix.setFromArray(coefs);
			if (Math.abs(tailRotorX.dot(this._tailRotorAxis)) > 0.9) {
				this._tailRotorAxis.set(tailRotorX.dot(this._tailRotorAxis) / Math.abs(tailRotorX.dot(this._tailRotorAxis)), 0, 0);
			} else if (Math.abs(tailRotorY.dot(this._tailRotorAxis)) > 0.9) {
				this._tailRotorAxis.set(0, tailRotorY.dot(this._tailRotorAxis) / Math.abs(tailRotorY.dot(this._tailRotorAxis)), 0);
			} else if (Math.abs(tailRotorZ.dot(this._tailRotorAxis)) > 0.9) {
				this._tailRotorAxis.set(0, 0, tailRotorZ.dot(this._tailRotorAxis) / Math.abs(tailRotorZ.dot(this._tailRotorAxis)));
			}

		};


		/**
		 *   Use : Compute the time required to travel a distance from 0 velocity with
		 *   the easeInOutQuad. It is used in the takeoff of the helicopter.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.computeEaseInOutQuadTimeRequired = function(distance) {
			if (distance < 0.0) {
				return 4 * Math.sqrt(-distance / (this.acceleration * 1000));
			}
			return 4 * Math.sqrt(distance / (this.acceleration * 1000));
		};

		/**
		 *   Use : computeNextPathDestination is used in the followpath part to return
		 *   a new local destination for the helicopter to track on.
		 *
		 *   Method : The method take care of the current velocity to predict at least one second
		 *   further than the current position ( *1000 ), if it's under the followingTrackDistance it
		 *   will iterate again until it's over followingTrackDistance or 5 second.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.computeNextPathDestination = function(Path) {
			var second = 0.0;
			var newDestination = Path.getValue(this._currentFollowPathDist / this._pathLength, this._globeLocation);
			do {
				second++;
				this._currentFollowPathDist += (1 + Math.abs(this._velocity.y)) * 1000;
				if (this._currentFollowPathDist > this._pathLength) {
					this._currentFollowPathDist = this._pathLength;
				}
				newDestination = Path.getValue(this._currentFollowPathDist / this._pathLength, this._globeLocation);
			}
			while (this.DistanceToPosition(newDestination) < this.followingTrackDistance && second < 5);
			return newDestination.clone();
		};

		/**
		 *   Use : compute the distance of the helicopter to the vector3D.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.DistanceToPosition = function(position) {
			var vectDiff = position.clone();
			vectDiff.sub(this._helicopter.getTransform().vector);
			return vectDiff.norm();
		};

		/**
		 *   Use : Take the control of the helicopter, and manage it to go to a certain destination.
		 *   1-   If it is used on a point, the helicopter will simply go to the point.
		 *   2-   If it is used on a Actor3D, it will take care of the Actor3D orientation to orientate the
		 *   helicopter before landing
		 *   3-   If it is used on a point which is not close to the ground, it will not have a landing state.
		 * @param  {STU.Actor3D}  iTarget The defined target the helicopter will fly to.
		 * @method
		 * @public
		 */
		//HelicopterController.prototype.goTo = function (actor) {
		HelicopterController.prototype.fliesTo = function(actor) {
			if (actor !== this._target) {
				this._target = actor;
				this._isFollowPathState = false; // Override followPath order
				this.flightAltitude = this._flightAltitudeSave;
				this._goToState = 0;
				console.debug('GOTO :' + actor.getName());
				this._destination = actor.getTransform().vector;
				this._isGoToState = true;
				this._isTakeoffState = false;
				this._isLandingState = false;
				this._isCruisingAltitudeState = false;
				this._isYawTrackingState = false;
				this._isTargetOriented = false; // default
				this.step2currentTime = 0.0;
				this._localTarget = null;
				if (this._target instanceof STU.Actor3D) {
					this._isTargetOriented = true;
					this._targetOrientation.set(this._target.getTransform().matrix.coef[1], this._target.getTransform().matrix.coef[4], 0);
					this._targetOrientation.normalize();
				}
				if (this._target instanceof STU.PointActor) {
					this._isTargetOriented = false;
				}
				this._landingHeight = 0.0;
				this._totalActionTime = 0.0;
			}
		};

		/**
		 * Use : Take the control of the helicopter, and manage it though a path created by the user.
		 * @param  {STU.PathActor} iPath The defined path that the helicopter will follow.
		 * @method
		 * @public
		 */
		//HelicopterController.prototype.followPath = function (actor) {
		HelicopterController.prototype.fliesAlong = function(actor) {
			this._target = actor;
			this._isGoToState = false; // Override a goTo order
			console.debug('FollowPath :' + actor.getName());
			this._destination = this._target.getValue(0, this._globeLocation);
			this._isFollowPathState = true;
			this._isTakeoffState = false;
			this._isLandingState = false;
			this._isCruisingAltitudeState = false;
			this._isYawTrackingState = false;
			this._currentFollowPathDist = 0.0;
			this._totalActionTime = 0.0;
			this._landingHeight = 0.0;
			this._currentFollowPathTime = 0.0;
			this._pathLength = this._target.getLength();
			this._totalFollowPathTime = this._pathLength / (this.acceleration);
		};

		/**
		 *   Use : isCloseToLand return false if the target vector is at least 1 meter above the ground
		 *   else, return true. (ray.lenght = 1000 means 1 meter)
		 * @method
		 * @private
		 */
		HelicopterController.prototype.isCloseToLand = function(iVector) {


			var iRef = this._globeLocation;

			//Vector is express in world context (scene if globe)
			//Pick work in global world context
			var posWorld = new DSMath.Point(iVector.x, iVector.y, iVector.z);
			var rayDirection = new DSMath.Vector3D(0, 0, -1);
			var rayLength = 1000;

			if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {

				var transformScene = iRef.getTransform();
				var transformSceneWorld = iRef.getTransform("World");
				var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

				posWorld.applyTransformation(transfoScene2World);
				rayDirection.applyTransformation(transfoScene2World);
				//rayLength *= transformSceneWorld.matrix.getScale();
			}

			var ray = new STU.Ray();
			ray.origin = posWorld; //DSMath.Vector3D.add(posWorld, new DSMath.Vector3D(-10,0,0));
			ray.direction = rayDirection;

			ray.length = rayLength;
			var renderManager = STU.RenderManager.getInstance();
			var intersectArray = renderManager._pickFromRay(ray, true, true);
			if (intersectArray.length > 0) {
				return true;
			} else {
				return false;
			}
		};

		/**
		 *   Use : Theses 3 next functions are RayCasting tools to be able to simplify the code a little
		 * @method
		 * @private
		 */
		// Return true if the ray hit something
		HelicopterController.prototype.isRayCastCollide = function(origin, direction, length) {
			//origin --> Local
			//direction --> Local
			var helicoClickable = this._helicopter.clickable;
			var mainRotorClickable = false;
			var tailRotorClickable = false;
			if (helicoClickable) {
				this._helicopter.setClickable(false);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				mainRotorClickable = this.mainRotor.clickable;
				tailRotorClickable = this.tailRotor.clickable;
				if (mainRotorClickable) {
					this.mainRotor.setClickable(false);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(false);
				}
			}

			var iRef = this._globeLocation;
			var originWorld = new DSMath.Point(origin.x, origin.y, origin.z);
			var rayDirection = direction.clone();
			var rayLength = length;

			if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
				var transformScene = iRef.getTransform();
				var transformSceneWorld = iRef.getTransform("World");
				var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

				originWorld.applyTransformation(transfoScene2World);
				rayDirection.applyTransformation(transfoScene2World);
				//rayLength *= transformSceneWorld.matrix.getScale();
			}

			var ray = new STU.Ray();
			ray.origin = originWorld;
			ray.direction = rayDirection;
			ray.length = rayLength;
			var renderManager = STU.RenderManager.getInstance();
			var intersectArray = renderManager._pickFromRay(ray, true, true);

			if (helicoClickable) {
				this._helicopter.setClickable(true);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				if (mainRotorClickable) {
					this.mainRotor.setClickable(true);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(true);
				}
			}
			if (intersectArray.length > 0) {
				return true;
			} else {
				return false;
			}
		};

		// Return true the this._destination is visible from the point "origin"
		HelicopterController.prototype.isDestinationVisible = function(origin) {
			var helicoClickable = this._helicopter.clickable;
			var mainRotorClickable = false;
			var tailRotorClickable = false;
			if (helicoClickable) {
				this._helicopter.setClickable(false);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				mainRotorClickable = this.mainRotor.clickable;
				tailRotorClickable = this.tailRotor.clickable;
				if (mainRotorClickable) {
					this.mainRotor.setClickable(false);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(false);
				}
			}
			var dest = this._destination.clone();
			var direction = dest.sub(origin);
			var length = direction.norm();
			direction.normalize;

			var iRef = this._globeLocation;
			var originWorld = new DSMath.Point(origin.x, origin.y, origin.z);
			var rayDirection = direction.clone();
			var rayLength = length;

			if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
				var transformScene = iRef.getTransform();
				var transformSceneWorld = iRef.getTransform("World");
				var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

				originWorld.applyTransformation(transfoScene2World);
				rayDirection.applyTransformation(transfoScene2World);
				//rayLength *= transformSceneWorld.matrix.getScale();
			}

			var ray = new STU.Ray();
			ray.origin = originWorld;
			ray.direction = rayDirection;
			ray.length = rayLength;
			var renderManager = STU.RenderManager.getInstance();
			var intersectArray = renderManager._pickFromRay(ray, true, true);
			if (helicoClickable) {
				this._helicopter.setClickable(true);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				if (mainRotorClickable) {
					this.mainRotor.setClickable(true);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(true);
				}
			}
			if (intersectArray.length > 0) {
				return false;
			} else {
				return true;
			}
		};

		// Return the distance to the closest point hit by the RayCast. If there is no point hit, return null
		HelicopterController.prototype.closestDstRayCollision = function(origin, direction, length) {
			var ray = new STU.Ray();
			var helicoClickable = this._helicopter.clickable;
			var mainRotorClickable = false;
			var tailRotorClickable = false;
			if (helicoClickable) {
				this._helicopter.setClickable(false);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				mainRotorClickable = this.mainRotor.clickable;
				tailRotorClickable = this.tailRotor.clickable;
				if (mainRotorClickable) {
					this.mainRotor.setClickable(false);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(false);
				}
			}

			var iRef = this._globeLocation;
			var originWorld = new DSMath.Point(origin.x, origin.y, origin.z);
			var rayDirection = direction.clone();
			var rayLength = length;

			if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
				var transformScene = iRef.getTransform();
				var transformSceneWorld = iRef.getTransform("World");
				var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

				originWorld.applyTransformation(transfoScene2World);
				rayDirection.applyTransformation(transfoScene2World);
				//rayLength *= transformSceneWorld.matrix.getScale();
			}

			ray.origin = originWorld;
			ray.direction = direction;
			ray.length = rayLength;
			var renderManager = STU.RenderManager.getInstance();
			var intersectArray = renderManager._pickFromRay(ray, true, true);
			if (helicoClickable) {
				this._helicopter.setClickable(true);
			}
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				if (mainRotorClickable) {
					this.mainRotor.setClickable(true);
				}
				if (tailRotorClickable) {
					this.tailRotor.setClickable(true);
				}
			}
			if (intersectArray.length > 0) {
				var point = intersectArray[0].getPoint();
				if (iRef !== null && iRef !== undefined) {
					//Point exprime dans le repere scene
					var invTransfoScene = iRef.getTransform("World").getInverse();
					point.applyTransformation(invTransfoScene);
				}
				var x = point.x - origin.x;
				var y = point.y - origin.y;
				var z = point.z - origin.z;
				var dstvec = Math.sqrt(x * x + y * y + z * z);
				//console.log(dstvec);
				return dstvec;
			} else {
				return null;
			}
		};

		/**
		 *   Use : computeNextLocalDestination is used on the stationary state ( while GOTO).  It computes
		 *   a new local destination for the helicopter to track. It is used to avoid to crash on mountains or
		 *   buildings and go over the top of it.
		 *
		 *   Method  : First, it does some raycasting  to know if there are some objects clickable in the direction
		 *   of the helicopter (obstacleDetectionDistance). If there are, it finds a height where there are no collisions
		 *    and then adapts it. If there are no colisions at all, it try to decrease the target height.
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.computeNextLocalDestination = function() {
			var incrementalHeight = 10000;
			var vector = this._helicopter.getTransform().vector;
			var dest = this._destination.clone();
			var stationaryDirection = new DSMath.Vector3D();
			var origin = vector.clone();
			var x = dest.x - vector.x;
			var y = dest.y - vector.y;
			// Special if the target in on the air
			if (this._goToState === 3) {
				var z = dest.z - vector.z;
				stationaryDirection.set(x, y, z);
				var len = stationaryDirection.norm();
				stationaryDirection.normalize();
				if (!this.isRayCastCollide(origin, stationaryDirection, len)) {
					return dest;
				}
			}
			stationaryDirection.set(x, y, 0);
			stationaryDirection.normalize();
			// Use a logarithm increase to avoid too long computing (buildings...)
			while (this.isRayCastCollide(origin, stationaryDirection, this.obstacleDetectionDistance)) {
				origin.z += incrementalHeight *= 10;
			}

			stationaryDirection.multiplyScalar(this.obstacleDetectionDistance);
			origin = origin.add(stationaryDirection);
			// origin is now a little bit further than the helicopter

			var iRef = this._globeLocation;
			var originWorld = new DSMath.Point(origin.x, origin.y, origin.z);
			var rayDirection = new DSMath.Vector3D(0, 0, -1);
			var rayLength = this.flightAltitude;

			if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
				var transformScene = iRef.getTransform();
				var transformSceneWorld = iRef.getTransform("World");
				var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

				originWorld.applyTransformation(transfoScene2World);
				rayDirection.applyTransformation(transfoScene2World);
				//rayLength *= transformSceneWorld.matrix.getScale();
			}

			var ray = new STU.Ray();
			ray.origin = originWorld;
			ray.direction = rayDirection;
			ray.length = rayLength;

			var renderManager = STU.RenderManager.getInstance();
			var intersectArray = renderManager._pickFromRay(ray, true, true);
			if (intersectArray.length > 0) {
				var intersectedPoint = intersectArray[0].getPoint();
				if (iRef !== null && iRef !== undefined) {
					//Point exprime dans le repere scene
					var invTransfoScene = iRef.getTransform("World").getInverse();
					intersectedPoint.applyTransformation(invTransfoScene);
				}
				if (origin.z - intersectedPoint.z < this.flightAltitude) {
					origin.z += this.flightAltitude - (origin.z - intersectedPoint.z);
				}
			} else if (origin.z <= vector.z) {
				var originZ = origin.z;
				origin.z -= this.flightAltitude;
				var dir = origin.clone();
				dir.sub(vector);
				var len = dir.norm();
				dir.normalize();
				// Check if we can still see the local target ( no collision)
				if (this.isRayCastCollide(vector, dir, len)) {
					origin.z = originZ;
				}
				if (origin.z < dest.z + this.flightAltitude) {
					origin.z = dest.z + this.flightAltitude;
				}
			}
			// Check if the helicopter is not going in the ground
			var dir = new DSMath.Vector3D(0, 0, -1);
			//dir.setCoord(0, 0, -1);
			var height = this.closestDstRayCollision(vector, dir, this.flightAltitude);
			if (height !== null) {
				origin.z += this.flightAltitude - height;
			}
			return origin;
		};

		/**
		 *   Use : updateGoToState is called every frame when isGoToState is on. It is used to managed the
		 *   different parts during the goto.
		 *   State 0: Starting the engine (this._isStartEngineState false when the rotor speed is fast enought)
		 *   State 1: Combine : takeoff, yawtracking and stationnaryLevelUpdate ( going forward ).
		 *   State 2: Used when the target is close to the land. Start the LandingProcedure when the distance
		 *       to the target is lower than landingDistance
		 *   State 3: Used when the target is not close to the ground. Also include a regulation algorithm to
		 *       track the target
		 *   State 4: End of the gotostate. Setting off variables
		 * @method
		 * @private
		 *
		 */
		HelicopterController.prototype.updateGoToState = function(iDelta) {
			this._odtGotoState = this._goToState;
			var dest = this._destination.clone();
			var vector = this._helicopter.getTransform().vector.clone();
			this._odtHelicoVector = vector.clone();
			var x = vector.x - dest.x;
			var y = vector.y - dest.y;
			var dst = Math.sqrt(x * x + y * y);
			if (this._goToState === 0) {
				// console.log("State 0 : Starting Engine...");
				this.startEngine();
				this._goToState = 1;
			} else if (this._goToState === 1 && !this._isLanded) {
				this.yawTrack();
				this.startCruisingAltitude();
				// Check if there is any object on the stationnary level of the helicopter
				var stationaryDirection = new DSMath.Vector3D();
				var origin = new DSMath.Vector3D();
				var x = dest.x - vector.x;
				var y = dest.y - vector.y;
				stationaryDirection.set(x, y, 0);
				origin.set(vector.x, vector.y, vector.z + this.flightAltitude);
				var additionalHeight = 0.0;

				// Test to know if the object is in the air, or on the ground
				if (this.isCloseToLand(dest)) {
					this.takeOff(additionalHeight);
					this._goToState = 2;
				} else {
					this._goToState = 3;
					console.debug('Target is not close to land');
				}
			} else if (this._goToState === 2 && !this._isTakeoffState) {
				this._odtTstDist = dst;
				if (dst < this.landingDistance) {
					// console.log("State 2 : Landing procedure");
					this._goToState = 4;
					this._isCruisingAltitudeState = false;
					this.land();
				}
			} else if (this._goToState === 3 && !this._isTakeoffState) {
				if (!this._isHeightTrackingState) {
					this.heightTrack();
				}
				if (dst < this.landingDistance) {
					if (this.step2currentTime === undefined || this.step2currentTime === 0.0 || this.step2dist === undefined) {
						this.step2dist = vector.clone();
						if (this._velocity.y > -1) {
							this._velocity.y = -1;
						}
						this.step2timeRequired = 3 / 2 * dst / -this._velocity.y + 3000;
						this.step2pitch = this._pitch;
						this.step2currentTime = 0.0;
						this._velocity.y = 0;
						this._isCruisingAltitudeState = false;
					}
					this.step2currentTime += iDelta.deltaTime;
					if (this.step2currentTime > this.step2timeRequired) {
						this._goToState = 4;
						this.step2currentTime = this.step2timeRequired;
						this._isYawTrackingState = false;
					}
					var position = this.step2dist.clone();
					position.x = this.step2dist.x + this.easeOutQuad(this.step2currentTime, 0, dest.x - this.step2dist.x, this.step2timeRequired);
					position.y = this.step2dist.y + this.easeOutQuad(this.step2currentTime, 0, dest.y - this.step2dist.y, this.step2timeRequired);
					position.z = vector.z;
					this._pitch = this.step2pitch - this.easeOutQuad(this.step2currentTime, 0, this.step2pitch, this.step2timeRequired);
					this._helicopter.setPosition(position);
				}
			} else if (this._goToState === 4 && !this._isLandingState && (Math.abs(vector.z - dest.z) < 3000)) {
				var evt = new HelicopterHasReachedEvent(this._target, this._helicopter);
				this._helicopter.dispatchEvent(evt);
				console.debug('HelicopterHasReachedEvent sent.');
				this.dispatchEvent(new STU.ServiceStoppedEvent("fliesTo", this));
				this._isGoToState = false;
				this.step2currentTime = 0.0;
				this._isYawTrackingState = false;
				this._isHeightTrackingState = false;
				this._velocity.y = 0;
				this.flightAltitude = this._flightAltitudeSave;
			}

		};

		/**
		 *   Use : It is used during the FollowPathState to set up the right values at the right time
		 *   It activate the trakers and update the local destination when needed
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateFollowPath = function(iDelta) {

			if (this._currentFollowPathDist === 0.0) // Not started yet
			{
				if (this._isLanded && !this._isStartEngineState) {
					// console.log("Going to the path");
					this.startEngine();
				}
				if (!this._isYawTrackingState && !this._isLanded) {
					if (!this.isDestinationVisible(this._helicopter.getTransform().vector.clone())) {
						this.takeOff();
					}
					this.yawTrack();
					this.heightTrack();
					this.startCruisingAltitude();
				} else {
					var distance = this.DistanceToPosition(this._destination);
					if (distance < (this.followingTrackDistance * 2 /** 2000*/ + 5000)) {
						this._currentFollowPathDist += 1;
					}
				}
			} else {
				this._currentFollowPathTime += iDelta.deltaTime;
				if (this._currentFollowPathTime > this._totalFollowPathTime) {
					this._currentFollowPathTime = this._totalFollowPathTime;
				}
				var distance = this.DistanceToPosition(this._destination);
				if (distance < this.followingTrackDistance || ((this._currentFollowPathDist / this._pathLength) < (this._currentFollowPathTime / this._totalFollowPathTime))) {
					this._destination = this.computeNextPathDestination(this._target);
				}
			}
			if (this._currentFollowPathDist === this._pathLength) {
				// console.log("End following");
				var evt = new HelicopterHasCompletedEvent(this._target, this._helicopter);
				this._helicopter.dispatchEvent(evt);
				this.dispatchEvent(new STU.ServiceStoppedEvent("fliesAlong", this));
				this._isFollowPathState = false;
				this._isYawTrackingState = false;
				this._isCruisingAltitudeState = false;
				this._isHeightTrackingState = false;
			}
		};

		/**
		 *   Use : Update the takeoff procedure.
		 *
		 *   Method: Before starting, cast a RayCast to know where the helicopter is ( may be not landed)
		 *   In order to make a smooth movement, we compute the time required to make the takeoff
		 *   and set a easeinoutquad by modifing the position directly. It may be a better idea to control
		 *   the velocity, but it is harder to control.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateTakeoffState = function(iDelta) {
			if (this._totalActionTime === 0.0) { // First time in the takeoff procedure
				this._currentActionTime = 0.0;
				this._startTakeoffHeight = this._helicopter.getTransform().vector.z;
				this._takeoffHeightDiff = this._destination.z - this._helicopter.getTransform().vector.z;
				// If the destination is at a lower height than the current position
				// we cast a ray to avoid going up if we are higher than the cruisingAltitude
				if (this._takeoffHeightDiff < 0) {

					var iRef = this._globeLocation;
					var vectorPosition = this._helicopter.getTransform().vector;
					var originWorld = new DSMath.Point(vectorPosition.x, vectorPosition.y, vectorPosition.z);
					var rayDirection = new DSMath.Vector3D(0, 0, -1);
					var rayLength = this.flightAltitude;

					if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
						var transformScene = iRef.getTransform();
						var transformSceneWorld = iRef.getTransform("World");
						var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

						originWorld.applyTransformation(transfoScene2World);
						rayDirection.applyTransformation(transfoScene2World);
						//rayLength *= transformSceneWorld.matrix.getScale();
					}

					var ray = new STU.Ray();
					ray.origin = originWorld;
					ray.direction = rayDirection;
					ray.length = rayLength;

					var renderManager = STU.RenderManager.getInstance();
					var intersectArray = renderManager._pickFromRay(ray, true, true);
					if (intersectArray.length > 0) {
						var intersectedPoint = intersectArray[0].getPoint();
						if (iRef !== null && iRef !== undefined) {
							//Point exprime dans le repere scene
							var invTransfoScene = iRef.getTransform("World").getInverse();
							intersectedPoint.applyTransformation(invTransfoScene);
						}
						this._takeoffHeightDiff = intersectedPoint.z - this._helicopter.getTransform().vector.z;
					}
				}
				// Compute the time required to do the takeoff
				//if (-this._takeoffHeightDiff < this.flightAltitude) {
				if (-this._takeoffHeightDiff < (this.flightAltitude / 1000)) { //solution temporaire pour respecter l'ODT... oublie de la conversion des unité... 
					this._totalActionTime = this.computeEaseInOutQuadTimeRequired(this.flightAltitude + this._takeoffHeightDiff) * 1000;
				} else if (this.isCloseToLand(this._helicopter.getTransform().vector)) {
					this._totalActionTime = this.computeEaseInOutQuadTimeRequired(this.flightAltitude) * 1000;
				} else {
					this._totalActionTime = 0;
				}
			}
			//Set the new position to the helicopter
			this._currentActionTime += iDelta.deltaTime;
			if (this._currentActionTime > this._totalActionTime) {
				this._currentActionTime = this._totalActionTime;
			}
			var position = this._helicopter.getTransform().vector.clone();
			var modif = 0.0;
			if (this._totalActionTime !== 0.0) {
				modif = this.easeInOutQuad(this._currentActionTime, 0, this.flightAltitude + this._takeoffHeightDiff, this._totalActionTime);
			}
			position.z = this._startTakeoffHeight + modif;
			this._helicopter.setPosition(position);
			if (this._currentActionTime === this._totalActionTime) {
				// Takeoff is finished
				this._totalActionTime = 0.0;
				this._currentActionTime = 0.0;
				this._isTakeoffState = false;
				this._startTakeoffHeight = 0.0;
				this._takeoffHeightDiff = 0.0;
				this._velocity.z = 0;
				// console.log("End Takeoff");
			}
		};

		/**
		 *   Use : Update the stationary level. Used to go forward and to avoid collisions by going
		 *   over the top of objects
		 *
		 *   Method : Go forward depending on the angle to the destination ( going faster when
		 *   the target is forward). Use of computeNextLocalDestination function to avoid collisions.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateCruisingAltitude = function(iDelta) {
			if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
				console.error('Velocity bad value in updateCruisingAltitude');
				return;
			}
			var vector = this._helicopter.getTransform().vector.clone();
			var localDestination = new DSMath.Vector3D();
		    // (ASO4) [IR-641273] We also need obstacle detection during the take off state
		    //if (!this._goToState || this._isTakeoffState) { 
			if (!this._goToState) {
				localDestination = this._destination.clone();
			} else if (this._localTarget !== null) {
				localDestination = this._localTarget.clone();
				var localDirection = new DSMath.Vector3D();
				var x = localDestination.x - vector.x;
				var y = localDestination.y - vector.y;
				var dst = Math.sqrt(x * x + y * y);
				localDirection.set(x, y, 0);
				localDirection.normalize();
				if (dst < this.obstacleDetectionDistance - this.obstacleDetectionFrequency) {
					this._localTarget = this.computeNextLocalDestination();
				}
				var frontMargin = this.closestDstRayCollision(vector, localDirection, this.obstacleDetectionDistance);
				var x = this._destination.x - vector.x;
				var y = this._destination.y - vector.y;
				var globaldst = Math.sqrt(x * x + y * y);
				if (frontMargin !== null && frontMargin < globaldst) {
					this._velocity.y -= this._velocity.y * (iDelta.deltaTime / 200) * (this.obstacleDetectionDistance - frontMargin) *
						(this.obstacleDetectionDistance - frontMargin) / (this.obstacleDetectionDistance) / (this.obstacleDetectionDistance);

					if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
						console.error('Velocity bad value in updateCruisingAltitude 2');
						return;
					}
				}


			} else {
				this._localTarget = this.computeNextLocalDestination();
				this.heightTrack();
			}

			var x = localDestination.x - vector.x;
			var y = localDestination.y - vector.y;
			var dst = Math.sqrt(x * x + y * y);

		    // Slow the helicopter when he can not reach his target height 
		    // (ASO4) [IR-641273] We also need a speed adaptation according to the obstacle detection during the take off state
			if(!this._isGoToState || this._isTakeoffState){
			    if (Math.abs(this._velocity.y * 2000) > dst && Math.abs(this._velocity.z * 2000 + 200) < Math.abs(localDestination.z - this._helicopter.getTransform().vector.z)) {
			        this._velocity.y -= this._velocity.y * this.inertiaFactor * (iDelta.deltaTime / 500);
			    }
			}

			if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
				console.error('Velocity bad value in updateCruisingAltitude 2');
				return;
			}

			var velocityFactor = 1.0;
			var distance = this.DistanceToPosition(localDestination);
			// Compute if in 5 sec the helicopter will approximately reach the destination
			if (distance < 5000 * -this._velocity.y && this._velocity.y !== 0.0) {
				velocityFactor = distance / (5000 * -this._velocity.y);
			}
			if (this._isTakeoffState) {
				velocityFactor *= 0.4;
			}
			if (!this._isLandingState) { // Moving forward is hold differently when it is on the landing state
				if (this._angleToDestination < Math.PI / 2) {
					this.moveForwardFunc(velocityFactor * (Math.PI / 2 - this._angleToDestination) / (Math.PI / 2));
				}
			}

		};

		/**
		 *   Use : Update the yaw tracking. It track the 3d point : this._destination.
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateYawTracking = function(iDelta) {

			var trackingDirection = new DSMath.Vector3D();
			trackingDirection.x = this._destination.x - this._helicopter.getTransform().vector.x;
			trackingDirection.y = this._destination.y - this._helicopter.getTransform().vector.y;
			trackingDirection.z = 0;
			trackingDirection.normalize();
			this.updateAngleToDestination(trackingDirection);
			var multiplier = 1;
			// The multiplier allow the followpath to have a better result if it's >1
			if (this._isFollowPathState) {
				multiplier = 2;
			} // if this._angleSignToDestination < 0 , target is on the right. if this._angleSignToDestination > 0, target is on the left
			if (this._angleSignToDestination > 0) {
				this.rotateLeft(multiplier * this._angleToDestination / Math.PI);
			}
			if (this._angleSignToDestination < 0) {
				this.rotateRight(multiplier * this._angleToDestination / Math.PI);
			}
			if (this._angleToDestination < 1) {
				this._yawSpeed -= this._yawSpeed * this.inertiaFactor * (iDelta.deltaTime / 700);
			}
		};

		/**
		 *   Use : Update the landing procedure. It is separated in several cases and parts.
		 *   It need enough speed before activing it, or the landing will be very long.
		 * @method
		 * @private
		 *
		 */
		HelicopterController.prototype.updateLandingProcedure = function(iDelta) {
			var vector = this._helicopter.getTransform().vector;
			if (this._landingHeight === 0.0) {
				// First time in this state : Compute the right values required
				this.step2currentTime = 0.0;
				this._isYawTrackingState = false; // use of a own tracking
				this._isCruisingAltitudeState = false;
				this._isHeightTrackingState = false;
				this._currentActionTime = 0.0;
				this._landingHeight = vector.z - this._destination.z;
				this._startLandingHeight = vector.z;
				var x = vector.x - this._destination.x;
				var y = vector.y - this._destination.y;
				var dst = Math.sqrt(x * x + y * y);
				this._startLandingDst = dst;
				this._startLandingVelocity = this._velocity.clone();
				this._startLandingAngle = this._angleToDestination;
				this._totalRotatingTime = (this._startLandingAngle / this.angularSpeed + 3) * 1000;
				this._totalActionTime = this.computeEaseInOutQuadTimeRequired(this._landingHeight) * 1000 + this._totalRotatingTime + 3000;
				this._landingState = 1;
				this.landingPitch = this._pitch;
			}
			this._currentActionTime += iDelta.deltaTime;
			// Advanced yaw tracking
			if (this._landingState === 1) {
				var trackingDirection = new DSMath.Vector3D();
				trackingDirection.x = this._destination.x - vector.x;
				trackingDirection.y = this._destination.y - vector.y;
				trackingDirection.z = 0;
				trackingDirection.normalize();
				this.updateAngleToDestination(trackingDirection);
				if (this._currentActionTime > this._totalRotatingTime) {
					this._currentActionTime = this._totalRotatingTime;
					this._landingState = 2;
				}
				var angleModifier = this.easeInOutQuad(this._currentActionTime, 0, this._startLandingAngle, this._totalRotatingTime);
				if (this._angleSignToDestination > 0) {
					this._yaw -= this._startLandingAngle - this._angleToDestination - angleModifier;
				}
				if (this._angleSignToDestination < 0) {
					this._yaw += this._startLandingAngle - this._angleToDestination - angleModifier;
				}
			}
			var x = vector.x - this._destination.x;
			var y = vector.y - this._destination.y;
			var dst = Math.sqrt(x * x + y * y);

			//this._tmpDist = dst;

			// Height
			if (this._currentActionTime + (this._startLandingDst - dst) / 2 <= this._totalActionTime + this._startLandingDst / 2) {
				var heightModifier = this.easeInOutQuad(this._currentActionTime + (this._startLandingDst - dst) / 2, 0, this._landingHeight, this._totalActionTime + this._startLandingDst / 2);
				this._pitch = this.landingPitch - this.easeInOutQuad(this._currentActionTime + (this._startLandingDst - dst) / 2, 0, this.landingPitch, this._totalActionTime + this._startLandingDst / 2);
				var position = vector.clone();
				position.z = this._startLandingHeight - heightModifier;
				this._helicopter.setPosition(position);
				vector = position;
			}
			// Compute the distance to the destination for velocity.y
			if (dst < 10000 && this._isTargetOriented && this._landingState < 3) {
				this._landingState = 3;
			}
			if (dst > this._startLandingDst) {
				this._velocity.y = this._startLandingVelocity.y;
				if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
					console.error('Velocity bad value in updateLanding');
					return;
				}
			} else if (dst !== 0) {
				if (this.step2currentTime === undefined || this.step2currentTime === 0.0 || this.step2dist === undefined) {
					this.step2dist = vector.clone();
					if (this._velocity.y > -2) {
						this._velocity.y = -2;
					}
					this.step2timeRequired = 3 / 2 * dst / -this._velocity.y + 1000;
					this.step2currentTime = 0.0;
					this._velocity.y = 0;
				}
				this.step2currentTime += iDelta.deltaTime;
				if (this.step2currentTime > this.step2timeRequired) {
					this.step2currentTime = this.step2timeRequired;
				}
				var position = this.step2dist.clone();
				position.x = this.step2dist.x + this.easeOutQuad(this.step2currentTime, 0, this._destination.x - this.step2dist.x, this.step2timeRequired);
				position.y = this.step2dist.y + this.easeOutQuad(this.step2currentTime, 0, this._destination.y - this.step2dist.y, this.step2timeRequired);
				position.z = vector.z;
				this._helicopter.setPosition(position);
				vector = position.clone();
			} else if (dst === 0.0 && (this._currentActionTime > this._totalActionTime) && !this._isTargetOriented) {
				this._isLandingState = false;
				this._landingHeight = 0.0;
				this._startLandingHeight = 0.0;
				this._startLandingVelocity.z = 0.0;
				this._totalActionTime = 0.0;
				this._currentActionTime = 0.0;
				this._totalRotatingTime = 0.0;
				this.step2currentTime = 0.0;
				this._isLanded = true;

			}
			if (this._landingState === 3) {
				// Target is oriented, we need to reorientate the helicopter
				this._landingState = 4;
				this.step3rotatingTime = this._currentActionTime - 1;
				this.updateAngleToDestination(this._targetOrientation);
				this._startLandingAngle = this._angleToDestination;
				this._totalRotatingTime = this._currentActionTime + (this._startLandingAngle / this.angularSpeed + 4) * 1000;
			}
			//Reorientating state of the helicopter
			if (this._landingState === 4) {
				this.updateAngleToDestination(this._targetOrientation);
				if (this._currentActionTime > this._totalRotatingTime) {
					this._currentActionTime = this._totalRotatingTime;
					this._isTargetOriented = false;
					this._landingState = 5;
				}

				var angleModifier = this.easeInOutQuad(this._currentActionTime - this.step3rotatingTime, 0, this._startLandingAngle, this._totalRotatingTime - this.step3rotatingTime);
				if (this._angleSignToDestination > 0) {
					this._yaw -= this._startLandingAngle - this._angleToDestination - angleModifier;
				}
				if (this._angleSignToDestination < 0) {
					this._yaw += this._startLandingAngle - this._angleToDestination - angleModifier;
				}
			}

		};



		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateAutoLandingProcedure = function() {
			// When the helicopter is going down, and not going forward quickly, try to land
			if (Math.abs(this._velocity.y) < this.maximumSpeed / 10 && this._velocity.z < 0 && this._landingHeight === 0.0) {
				// Avoid ray collision with the helicopter
				var helicoClickable = this._helicopter.clickable;
				var mainRotorClickable = false;
				var tailRotorClickable = false;
				if (helicoClickable) {
					this._helicopter.setClickable(false);
				}
				if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
					mainRotorClickable = this.mainRotor.clickable;
					tailRotorClickable = this.tailRotor.clickable;
					if (mainRotorClickable) {
						this.mainRotor.setClickable(false);
					}
					if (tailRotorClickable) {
						this.tailRotor.setClickable(false);
					}
				}

				var iRef = this._globeLocation;
				var vectorPosition = this._helicopter.getTransform().vector;
				var originWorld = new DSMath.Point(vectorPosition.x, vectorPosition.y, vectorPosition.z + 1000);
				var rayDirection = new DSMath.Vector3D(0, 0, -1);
				var rayLength = this.automaticLandingHeight + 1000 * -this._velocity.z;

				if (iRef !== null && iRef !== undefined && iRef instanceof STU.Location) {
					var transformScene = iRef.getTransform();
					var transformSceneWorld = iRef.getTransform("World");
					var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());

					originWorld.applyTransformation(transfoScene2World);
					rayDirection.applyTransformation(transfoScene2World);
					//rayLength *= transformSceneWorld.matrix.getScale();
				}

				var ray = new STU.Ray();
				var vector = this._helicopter.getTransform().vector;
				ray.origin = originWorld;
				ray.direction = rayDirection;
				ray.length = rayLength;

				var renderManager = STU.RenderManager.getInstance();
				var intersectArray = renderManager._pickFromRay(ray, true, true);
				if (intersectArray.length > 0) {
					var i = 0;
					for (i = 0; i < intersectArray.length; i++) {
						var intersectedPoint = intersectArray[i].getPoint();
						if (iRef !== null && iRef !== undefined) {
							//Point exprime dans le repere scene
							var invTransfoScene = iRef.getTransform("World").getInverse();
							intersectedPoint.applyTransformation(invTransfoScene);
						}
						if (intersectedPoint.z <= vector.z + 50) {
							this._startLandingHeight = vector.z;
							this._landingHeight = this._startLandingHeight - intersectedPoint.z;
							this._startLandingVelocity = this._velocity.clone();
							//if (this._landingHeight > 200)
							//  console.log("AutoLanding Activated...");
						}
					}
				}
				// Restore clickable if it was set to true
				if (helicoClickable) {
					this._helicopter.setClickable(true);
				}
				if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
					if (mainRotorClickable) {
						this.mainRotor.setClickable(true);
					}
					if (tailRotorClickable) {
						this.tailRotor.setClickable(true);
					}
				}
			}
			// The helicopter is landed and try to go through the floor. Cancel this move.
			if (this._landingHeight < 200 && this._landingHeight !== 0.0) {
				this._velocity.z = 0;
				this._landingHeight = 0.0;
				this._startLandingHeight = 0.0;
				this._startLandingVelocity.z = 0.0;
			}
			// Auto landing detected, slowing down procedure
			else if (this._landingHeight !== 0.0) {
				var height = this._helicopter.getTransform().vector.z - (this._startLandingHeight - this._landingHeight);
				if (height >= 0) {
					var velocityModifier = this.easeInOutQuad(this._landingHeight - height, 0, this._startLandingVelocity.z, this._landingHeight);
					this._velocity.z = this._startLandingVelocity.z - velocityModifier * 0.9 - (this.maximumSpeed / 30);
				} else {
					height = 0;
					var position = this._helicopter.getTransform().vector;
					position.z = this._startLandingHeight - this._landingHeight;
					this._helicopter.setPosition(position);
					this._velocity.z = 0;
					this._isLanded = true;
					// console.log("Landed.");
					this._landingHeight = 0.0;
					this._startLandingHeight = 0.0;
					this._startLandingVelocity.z = 0.0;
				}
			}
		};



		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateHeightTracking = function(iDelta) {
			var destination = this._destination.clone();
			var vector = this._helicopter.getTransform().vector.clone();
			var x = vector.x - this._destination.x;
			var y = vector.y - this._destination.y;
			var dst = Math.sqrt(x * x + y * y);
			if (this._localTarget !== null && this._isGoToState && dst > this.landingDistance) {
				destination = this._localTarget;
				if (this._goToState === 3 && this._localTarget.z < this._destination.z) {
					destination.z = this._destination.z;
				}
				// When the target is not close to the land, we want the helicopter to track the z position if there are no obstables
			}
			var heightVar = destination.z - vector.z;
			// console.log((destination.z - vector.z) + " +   "+  (this._localTarget.z - vector.z));
			//  If close to the destination, start to slow down
			if (Math.abs(this._velocity.z * 1000) > Math.abs(heightVar)) {
				this._velocity.z -= this._velocity.z * this.inertiaFactor * (iDelta.deltaTime / 1000);
			}
			if (Math.abs(heightVar) < 200) {
				this._velocity.z -= this._velocity.z * this.inertiaFactor * (iDelta.deltaTime / 500);
			}
			if (heightVar > 1000) {
				heightVar = 1000;
			}
			if (heightVar < -1000) {
				heightVar = -1000;
			}
			this.moveUp(heightVar / 1000);
		};



		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateKeyboardFlightController = function() {
			// This is the Keyboard impact on the helicopter
			// Control up / down 
			if (this._keyPressed.down) {
				this.moveDown();
			}
			if (this._keyPressed.up) {
				this.moveUp();
			}
			// Go forward / backward 
			if (this._keyPressed.front) {
				this.moveForwardFunc();
			}
			if (this._keyPressed.back) {
				this.moveBackwardFunc();
			}
			// Move Right / Move Left 
			if (this._keyPressed.moveRight) {
				this.moveRightFunc();
			}
			if (this._keyPressed.moveLeft) {
				this.moveLeftFunc();
			}
			// Rotate left / right 
			if (this._keyPressed.left) {
				this.rotateLeft();
			}
			if (this._keyPressed.right) {
				this.rotateRight();
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateGamepadFlightController = function() {
			// This is the GamePad impact on the helicopter
			var gamePad = EP.Devices.getGamepad();
			if (gamePad === undefined || gamePad === null) {
				return;
			}

			var axis = gamePad.axisValues;
			if (axis[0] < -0.20) {
				this.rotateLeft((-axis[0] - 0.20) * 2);
			}
			if (axis[0] > 0.20) {
				this.rotateRight((axis[0] - 0.20) * 2);
			}
			if (axis[1] > 0.20) {
				this.moveBackwardFunc(axis[1]);
			}
			if (axis[1] < -0.20) {
				this.moveForwardFunc(-axis[1]);
			}
			if (axis[4] > 0.20) {
				this.moveDown(axis[4]);
			}
			if (axis[5] > 0.20) {
				this.moveUp(axis[5]);
			}
			if (gamePad.isButtonPressed(EP.Gamepad.EButton.e5)) {
				this.moveLeftFunc();
			}
			if (gamePad.isButtonPressed(EP.Gamepad.EButton.e6)) {
				this.moveRightFunc();
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateTransform = function(iDelta) {
			if (isNaN(this._pitch) || isNaN(this._pitchSpeed)) {
				this._yaw = 0.0;
				this._yawSpeed = 0.0;
			}
			if (isNaN(this._yaw) || isNaN(this._yawSpeed)) {
				this._roll = 0.0;
				this._rollSpeed = 0.0;
			}
			if (isNaN(this._roll) || isNaN(this._rollSpeed)) {
				this._pitch = 0.0;
				this._pitchSpeed = 0.0;
			}
			// update all angles
			this._yaw += this._yawSpeed;
			this._pitch += this._pitchSpeed;
			this._roll += this._rollSpeed;
			// apply inertia
			if (isNaN(this._velocity.x) || isNaN(this._velocity.y) || isNaN(this._velocity.z)) {
				console.error('Velocity bad value in updateTransfom');
				this._velocity.set(0.0, 0.0, 0.0);
				return;
			}
			this.applyinertia(iDelta);
			// Update the new position and angle
			var position = new DSMath.Vector3D();
			var vector = this._helicopter.getTransform().vector;
			position.set(vector.x, vector.y, vector.z);
			var newTransform = new DSMath.Transformation();
			var rotMatrix = new DSMath.Matrix3x3();
			var rotZ = new DSMath.Vector3D(0, 0, 1);
			//rotZ.set(0.0, 0.0, 1.0);
			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				newTransform.matrix = this._realignMatrix.clone();
			} else {
				newTransform.matrix = this._initialMatrix.clone();
			}

			rotMatrix.makeRotation(rotZ, this._yaw);
			newTransform.matrix = newTransform.matrix.multiply(rotMatrix);
			// When the yaw is correct, we can easily set the translate movement without having
			// the influance of the Roll and the Pitch
			var movement = this._velocity.clone();
			movement.multiplyScalar(iDelta.deltaTime);
			position.add(this.vectorLocalToWorldReferential(movement, newTransform));
			if (isNaN(position.x) || isNaN(position.y) || isNaN(position.z)) {
				console.error('Position bad value in updateTransform');
				return;
			}
			var saveTest = newTransform.clone();

			newTransform.matrix = this._initialMatrix.clone();
			newTransform.vector = position;
			rotMatrix.makeRotation(rotZ, this._yaw);
			newTransform.matrix = newTransform.matrix.multiply(rotMatrix);

			var rotX = new DSMath.Vector3D(1.0, 0.0, 0.0);

			var rotXHeli = this.vectorLocalToWorldReferential(rotX, saveTest);
			var rotY = new DSMath.Vector3D(0.0, 1.0, 0.0);

			var rotYHeli = this.vectorLocalToWorldReferential(rotY, saveTest);

			rotXHeli.normalize();
			rotXHeli.multiplyScalar(this._pitch);
			rotYHeli.normalize();
			rotYHeli.multiplyScalar(this._roll);

			this._helicopter.setTransform(newTransform);
			this._helicopter.rotate(rotXHeli);
			this._helicopter.rotate(rotYHeli);
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateAngleToDestination = function(destination) {
			// Getting the direction vector of the helicopter
			var helicopterTransform = new DSMath.Transformation();
			helicopterTransform.matrix = this._realignMatrix.clone();
			var rotZ = new DSMath.Vector3D();
			var rotMatrix = new DSMath.Matrix3x3();
			rotZ.set(0.0, 0.0, 1.0);
			rotMatrix.makeRotation(rotZ, this._yaw);
			helicopterTransform.matrix = helicopterTransform.matrix.multiply(rotMatrix);
			var helicoDirection = new DSMath.Vector3D();
			helicoDirection.set(-helicopterTransform.matrix.coef[1], -helicopterTransform.matrix.coef[4], 0);
			helicoDirection.normalize();

			// the scalar product to compute the angle
			var dot = helicoDirection.dot(destination);

			if (dot > 0.9999) {
				this._angleToDestination = 0.0;
			} else if (dot < -0.9999) {
				this._angleToDestination = Math.PI;
			} else {
				this._angleToDestination = Math.acos(dot);
			}
			this._angleSignToDestination = helicoDirection.x * destination.y - helicoDirection.y * destination.x;

		};


		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.applyinertia = function(iDelta) {
			this._currentActionTime += iDelta.deltaTime;
			//// inertia of the helicopter ////
			if (this._axisModified.y === false) {
				this._velocity.y -= this._velocity.y * this.inertiaFactor * (iDelta.deltaTime / 1000);
				this._pitch -= this._pitch * this.inertiaFactor * (iDelta.deltaTime / 800);
			}
			if (this._axisModified.x === false) {
				this._velocity.x -= this._velocity.x * this.inertiaFactor * (iDelta.deltaTime / 1000);
				this._roll -= this._roll * this.inertiaFactor * (iDelta.deltaTime / 800);
			}
			if (this._axisModified.z === false) {
				this._velocity.z -= this._velocity.z * this.inertiaFactor * (iDelta.deltaTime / 1000);
			}
			if (Math.abs(this._roll) > 0.3 && Math.abs(this._rollSpeed) < 0.001) {
				if (this._axisModified.x === true) {
					this._roll -= this._roll * this.inertiaFactor * (iDelta.deltaTime / 4000);
				} else {
					this._roll -= this._roll * this.inertiaFactor * (iDelta.deltaTime / 1000);
				}
			}

			if (Math.abs(this._pitch) > 0.30 && Math.abs(this._pitchSpeed) < 0.001) {
				if (this._axisModified.y === true) {
					this._pitch -= this._pitch * this.inertiaFactor * (iDelta.deltaTime / 4000);
				} else {
					this._pitch -= this._pitch * this.inertiaFactor * (iDelta.deltaTime / 1000);
				}
			}

			this._yawSpeed -= this._yawSpeed * this.inertiaFactor * (iDelta.deltaTime / 600);
			this._pitchSpeed -= this._pitchSpeed * this.inertiaFactor * (iDelta.deltaTime / 700);
			this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (iDelta.deltaTime / 700);

			this._axisModified.x = false;
			this._axisModified.y = false;
			this._axisModified.z = false;
		};

		/**
		 * Keyboard press handler function
		 * @method
		 * @private
		 */
		HelicopterController.prototype.keyboardPress = function(argm) {
			var key = argm.getKey();
			//console.log(key);
			if (key === this.moveForward /*EP.Keyboard.EKey.eZ*/ ) {
				this._keyPressed.front = true;
			}
			if (key === this.moveRight /*EP.Keyboard.EKey.eE*/ ) {
				this._keyPressed.moveRight = true;
			}
			if (key === this.moveLeft /*EP.Keyboard.EKey.eA*/ ) {
				this._keyPressed.moveLeft = true;
			}
			if (key === this.moveBackward /*EP.Keyboard.EKey.eS*/ ) {
				this._keyPressed.back = true;
			}
			if (key === this.turnLeft /*EP.Keyboard.EKey.eQ*/ ) {
				this._keyPressed.left = true;
			}
			if (key === this.turnRight /*EP.Keyboard.EKey.eD*/ ) {
				this._keyPressed.right = true;
			}
			if (key === this.goUp /*EP.Keyboard.EKey.eSpace*/ ) {
				this._keyPressed.up = true;
			}
			if (key === this.goDown /*EP.Keyboard.EKey.eShift*/ ) {
				this._keyPressed.down = true;
			}
		};

		/**
		 * Keyboard release handler function
		 * @method
		 * @private
		 */
		HelicopterController.prototype.keyboardRelease = function(argm) {
			var key = argm.getKey();
			if (key === this.moveForward /*EP.Keyboard.EKey.eZ*/ ) {
				this._keyPressed.front = false;
			}
			if (key === this.moveRight /*EP.Keyboard.EKey.eE*/ ) {
				this._keyPressed.moveRight = false;
			}
			if (key === this.moveLeft /*EP.Keyboard.EKey.eA*/ ) {
				this._keyPressed.moveLeft = false;
			}
			if (key === this.moveBackward /*EP.Keyboard.EKey.eS*/ ) {
				this._keyPressed.back = false;
			}
			if (key === this.turnLeft /*EP.Keyboard.EKey.eQ*/ ) {
				this._keyPressed.left = false;
			}
			if (key === this.turnRight /*EP.Keyboard.EKey.eD*/ ) {
				this._keyPressed.right = false;
			}
			if (key === this.goUp /*EP.Keyboard.EKey.eSpace*/ ) {
				this._keyPressed.up = false;
			}
			if (key === this.goDown /*EP.Keyboard.EKey.eShift*/ ) {
				this._keyPressed.down = false;
			}
			if (key === this.engine) {
				if (this.isEngineStarted() === false) {
					this.startEngine();
				} else {
					this.stopEngine();
				}
			}
		};

		/**
		 * Random number generator with seed
		 * @method
		 * @private
		 */
		HelicopterController.prototype.seededRandom = function(max, min) {
			this._seed = (this._seed + 1) % 233280;
			max = max || 1;
			min = min || 0;
			this._seed = (this._seed * 9301 + 49297) % 233280;
			var rnd = this._seed / 233280;
			return min + rnd * (max - min);
		};


		/**
		 * Generate some noise on the helicopter to make it more realistic
		 * @method
		 * @private
		 */
		HelicopterController.prototype.updateNoiseOnHelicopter = function() {
			if (Math.abs(this._pitch) > 0.05 || Math.abs(this._roll) > 0.05) {
				return;
			}
			var noiseFactor = 20;
			var noiseImpact = 0.15;
			var randValue = Math.floor(this.seededRandom(noiseFactor + 8, 1));
			switch (randValue) {
				case 1:
					this.moveForwardFunc(noiseImpact);
					break;
				case 2:
					this.moveBackwardFunc(noiseImpact);
					break;
				case 3:
					this.rotateLeft(noiseImpact);
					break;
				case 4:
					this.rotateRight(noiseImpact);
					break;
				case 5:
					this.moveLeftFunc(noiseImpact);
					break;
				case 6:
					this.moveRightFunc(noiseImpact);
					break;
				case 7:
					this.moveUp(noiseImpact);
					break;
			}
		};


		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.land = function() {
			this._isLandingState = true;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.takeOff = function() {
			this._isTakeoffState = true;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.yawTrack = function() {
			this._isYawTrackingState = true;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.startCruisingAltitude = function() {
			this._isCruisingAltitudeState = true;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.heightTrack = function() {
			this._isHeightTrackingState = true;
		};

		/**
		 * Permit to start the rotors animation
		 * @method
		 * @public
		 */
		HelicopterController.prototype.startEngine = function() {
			this._isStartEngineState = true;
		};

		/**
		 * Permit to stop the rotors animation
		 * @method
		 * @public
		 */
		HelicopterController.prototype.stopEngine = function() {
			this._isStartEngineState = false;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.isEngineStarted = function() {
			return this._isStartEngineState;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.startToFly = function() {
			this._isLanded = false;
		};


		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.optionalCoefCheck = function(optionalCoef) {
			if (typeof(optionalCoef) === 'undefined') {
				return 1;
			}
			return optionalCoef;
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveForwardFunc = function(optionalCoef) {
			this._axisModified.y = true;
			if (this._velocity.y > -this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				if (this._velocity.y > 0) {
					optionalCoef *= 2;
				}
				this._velocity.y -= this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.y < -this.maximumSpeed) // To remove jaggedness effect
				{
					this._velocity.y = -this.maximumSpeed;
				}
			}
			if (this._pitch > 0.25) {
				this._pitchSpeed -= this._pitchSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
				if (this._pitchSpeed < 0.0 && this._velocity.y < 0) {
					this._pitchSpeed = 0.0;
				}
			} else if (this._pitch < 0.15) {
				this._pitchSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
			} else if (this._pitch > 0.15 && this._pitch < 0.25) {
				this._pitchSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
				this._pitchSpeed -= this._pitchSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveBackwardFunc = function(optionalCoef) {
			this._axisModified.y = true;
			if (this._velocity.z < this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				if (this._velocity.y < 0) {
					optionalCoef *= 2;
				}
				this._velocity.y += this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.y > this.maximumSpeed) // To remove jaggedness effect
				{
					this._velocity.y = this.maximumSpeed;
				}
			}
			if (this._pitch < -0.25) {
				this._pitchSpeed -= this._pitchSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
				if (this._pitchSpeed > 0.0 && this._velocity.y > 0) {
					this._pitchSpeed = 0.0;
				}
			} else if (this._pitch > -0.15) {
				this._pitchSpeed -= this._iDelta.deltaTime * optionalCoef / 50000;
			} else if (this._pitch < -0.15 && this._pitch > -0.25) {
				this._pitchSpeed -= this._iDelta.deltaTime * optionalCoef / 80000;
				this._pitchSpeed += this._pitchSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveUp = function(optionalCoef) {
			this._axisModified.z = true;
			if (this._velocity.z < this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				this._velocity.z += this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.z > this.maximumSpeed) // To remove jaggedness effect
				{
					this._velocity.z = this.maximumSpeed;
				}
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveDown = function(optionalCoef) {
			this._axisModified.z = true;
			if (this._velocity.z > -this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				this._velocity.z -= this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.z < -this.maximumSpeed) // To remove jaggedness effect
				{
					this._velocity.z = -this.maximumSpeed;
				}
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveLeftFunc = function(optionalCoef) {
			this._axisModified.x = true;
			if (this._velocity.x < this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				this._velocity.x += this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.x > this.maximumSpeed) // To remove jaggedness effect
				{
					this._velocity.x = this.maximumSpeed;
				}
			}
			if (this._roll > 0.25) {
				this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
				if (this._rollSpeed < 0.0 && this._velocity.x > 0) {
					this._rollSpeed = 0.0;
				}
			} else if (this._roll < 0.15) {
				this._rollSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
			} else if (this._roll > 0.15 && this._roll < 0.25) {
				this._rollSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
				this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.moveRightFunc = function(optionalCoef) {
			this._axisModified.x = true;
			if (this._velocity.x > -this.maximumSpeed) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				this._velocity.x -= this.acceleration * optionalCoef * this._iDelta.deltaTime / 1000;
				if (this._velocity.x < -this.maximumSpeed) {
					this._velocity.x = -this.maximumSpeed;
				}
			}
			if (this._roll < -0.25) {
				this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
				if (this._rollSpeed > 0.0 && this._velocity.x < 0) {
					this._rollSpeed = 0.0;
				}
			} else if (this._roll > -0.15) {
				this._rollSpeed -= this._iDelta.deltaTime * optionalCoef / 50000;
			} else if (this._roll < -0.15 && this._roll > -0.25) {
				this._rollSpeed -= this._iDelta.deltaTime * optionalCoef / 80000;
				this._rollSpeed += this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.rotateLeft = function(optionalCoef) {
			if (this._yawSpeed < 0.07) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				if (this._yawSpeed < 0) {
					optionalCoef *= 2;
				}
				this._yawSpeed += this.angularSpeed * optionalCoef * this._iDelta.deltaTime / 10000;
				if (Math.abs(this._velocity.y) > this.maximumSpeed / 10) {
					if (this._roll > 0.25) {
						this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
						if (this._rollSpeed < 0.0 && this._velocity.x < 0) {
							this._rollSpeed = 0.0;
						}
					} else if (this._roll < 0.15) {
						this._rollSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
					} else if (this._roll > 0.15 && this._roll < 0.25) {
						this._rollSpeed += this._iDelta.deltaTime * optionalCoef / 50000;
						this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
					}
				}

			}
		};

		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.rotateRight = function(optionalCoef) {
			if (this._yawSpeed > -0.07) {
				optionalCoef = this.optionalCoefCheck(optionalCoef);
				if (this._yawSpeed > 0) {
					optionalCoef *= 2;
				}
				this._yawSpeed -= this.angularSpeed * optionalCoef * this._iDelta.deltaTime / 10000;
				if (Math.abs(this._velocity.y) > this.maximumSpeed / 10) {
					if (this._roll < -0.25) {
						this._rollSpeed -= this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
						if (this._rollSpeed > 0.0 && this._velocity.x > 0) {
							this._rollSpeed = 0.0;
						}
					} else if (this._roll > -0.15) {
						this._rollSpeed -= this._iDelta.deltaTime * optionalCoef / 50000;
					} else if (this._roll < -0.15 && this._roll > -0.25) {
						this._rollSpeed -= this._iDelta.deltaTime * optionalCoef / 80000;
						this._rollSpeed += this._rollSpeed * this.inertiaFactor * (this._iDelta.deltaTime / 1000);
					}
				}
			}
		};


		/**
		 *
		 * @method
		 * @private
		 */
		HelicopterController.prototype.executeOneFrame = function(iDelta) {
			this._iDelta = iDelta;

			if (this._isGoToState) {
				this.updateGoToState(iDelta);
			}
			if (this._isFollowPathState) {
				this.updateFollowPath(iDelta);

			} // tailRotor and mainRotor Rotation

			if (this.tailRotor === undefined && this.mainRotor === undefined && this._isLanded && !this._isStartEngineState) {
				this.startEngine();
			}

			if (this._isLanded) {
				var gamePad = EP.Devices.getGamepad();
				var axisLT = 0.0;
				var axisRT = 0.0;
				if (gamePad !== undefined && gamePad !== null) {
					axisLT = gamePad.getAxisValue(EP.Gamepad.EAxis.eLT);
					axisRT = gamePad.getAxisValue(EP.Gamepad.EAxis.eRT);
				}

				if (axisRT > 0.5 || this._keyPressed.up) {
					this.startEngine();
					if (this._rotorRotationSpeed >= 0.4) {
						this.startToFly();
						this._rotorRotationSpeed = 0.4;
					}
				}
				if (axisLT > 0.5 || this._keyPressed.down) {
					this.stopEngine();
				}
				if (this._rotorRotationSpeed !== 0.0 && !this._isStartEngineState) {
					this._rotorRotationSpeed -= iDelta.deltaTime / 40000;
				}
				if (this._rotorRotationSpeed < 0.0) {
					this._rotorRotationSpeed = 0.0;
				}
			}

			if (this._isStartEngineState && this._isLanded) {
				this._rotorRotationSpeed += iDelta.deltaTime / 10000;
				if (this._rotorRotationSpeed >= 0.40) {
					this._rotorRotationSpeed = 0.4;
					if (this._isGoToState || this._isFollowPathState) {
						this.startToFly();
					}
				}
			}

			if (this.tailRotor !== undefined && this.mainRotor !== undefined) {
				var rotmainRotor = new DSMath.Vector3D();
				rotmainRotor.z = this._rotorRotationSpeed;
				var rottailRotor = this._tailRotorAxis.clone();
				rottailRotor.multiplyScalar(this._rotorRotationSpeed);
				this.mainRotor.rotate(rotmainRotor, this.mainRotor);
				this.tailRotor.rotate(rottailRotor, this.tailRotor);
			}

			if (!this._isLanded) {
				this.updateKeyboardFlightController();

				this.updateGamepadFlightController();
			}

			if (this._isTakeoffState) {
				this.updateTakeoffState(iDelta);
			}
			if (this._isYawTrackingState) {
				this.updateYawTracking(iDelta);
			}
			if (this._isHeightTrackingState) {
				this.updateHeightTracking(iDelta);
			}
			if (this._isCruisingAltitudeState) {
				this.updateCruisingAltitude(iDelta);
			}
			if (!this._isLanded && !this._isFollowPathState && !this._isGoToState) {
				this.updateAutoLandingProcedure();
			}
			if (!this._isLanded && this.enableTurbulence && !this._isFollowPathState && !this._isGoToState) {
				this.updateNoiseOnHelicopter();
			}
			if (this._isLandingState) {
				this.updateLandingProcedure(iDelta);
			}
			// UPDATE THE HELICOPTER POSITION// 
			this.updateTransform(iDelta);
		};

		
		// Expose in STU namespace.
		STU.HelicopterController = HelicopterController;
		return HelicopterController;		
	});

define('StuMiscContent/StuHelicopterController', ['DS/StuMiscContent/StuHelicopterController'], function(HelicopterController) {
	'use strict';

	return HelicopterController;
});

define('DS/StuCameras/StuLookAroundNavigation', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuCameras/StuNavigation', 'MathematicsES/MathsDef'], function(STU, EP, Navigation, DSMath) {
	'use strict';

	/**
	 * Describe an orbital camera navigation.
	 *
	 * @exports LookAroundNavigation
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends {STU.Navigation}
	 * @memberOf STU
	 * @alias STU.LookAroundNavigation
	 */
	var LookAroundNavigation = function() {

		Navigation.call(this);
		this.name = 'LookAroundNavigation';

		//////////////////////////////////////////////////////////////////////////
		// Properties that should NOT be visible in UI
		//////////////////////////////////////////////////////////////////////////

		this._startPitch = 0;
		this._startYaw = 0;
		this._currentPitch = 0;
		this._currentYaw = 0;

		/**
		 *  True if the navigation is currently doing a lookAt transition
		 *
		 * @private
		 * @type {Boolean}
		 */
		this._isLookingAt = false;

		/**
		 *  Quaternion holding the camera rotation when starting a lookAt transition
		 *
		 * @private
		 * @type {DSMath.Quaternion}
		 */
		this._lookAtStartQuat = null;

		/**
		 *  Target actor to look at
		 *
		 * @private
		 * @type {STU.Actor3D}
		 */
		this._lookAtTarget = null;

		/**
		 * Duration of the lookAt transition in seconds.
		 * Note that the default value will be overridden using this formula :
		 * 450 / (this.horizontalRotationSensitivity + this.verticalRotationSensitivity);
		 *
		 * @private
		 * @type {Number}
		 */
		this._timeToLookAt = 1.5;

		/*
		 */
		this._smoothnessQueue = [];

		//////////////////////////////////////////////////////////////////////////
		// Properties that should be visible in UI
		//////////////////////////////////////////////////////////////////////////
		/**
		 * Enable or disable navigation with mouse
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.useMouse = true;

		/**
		 * Enable or disable navigation with keyboard
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.useKeyboard = false;

		/**
		 * Enable or disable navigation with gamepad
		 *
		 * @member
		 * @public
		 * @type {boolean}
		 */
		this.useGamepad = false;

		/**
		 * Mapped key for moving left
		 *
		 * @member
		 * @instance
		 * @name moveLeft
		 * @public
		 * @type {EP.Keyboard.EKey}
		 * @default {EP.Keyboard.EKey.eLeft}
		 * @memberOf STU.LookAroundNavigation
		 */
		this._moveLeft = EP.Keyboard.EKey.eLeft;
		Object.defineProperty(this, 'moveLeft', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._moveLeft;
			},
			set: function(value) {
				this._moveLeft = value;
				if (this._inputManager !== undefined && this._inputManager !== null) {
					this._inputManager.keyLeft = this._moveLeft;
				}
			}
		});

		/**
		 * Mapped key for moving right
		 *
		 * @member
		 * @instance
		 * @name moveRight
		 * @public
		 * @type {EP.Keyboard.EKey}
		 * @default {EP.Keyboard.EKey.eRight}
		 * @memberOf STU.LookAroundNavigation
		 */
		this._moveRight = EP.Keyboard.EKey.eRight;
		Object.defineProperty(this, 'moveRight', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._moveRight;
			},
			set: function(value) {
				this._moveRight = value;
				if (this._inputManager !== undefined && this._inputManager !== null) {
					this._inputManager.keyRight = this._moveRight;
				}
			}
		});

		/**
		 * Mapped key for moving up
		 *
		 * @member
		 * @instance
		 * @name moveUp
		 * @public
		 * @type {EP.Keyboard.EKey}
		 * @default {EP.Keyboard.EKey.eUp}
		 * @memberOf STU.LookAroundNavigation
		 */
		this._moveUp = EP.Keyboard.EKey.eUp;
		Object.defineProperty(this, 'moveUp', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._moveUp;
			},
			set: function(value) {
				this._moveUp = value;
				if (this._inputManager !== undefined && this._inputManager !== null) {
					this._inputManager.keyUp = this._moveUp;
				}
			}
		});

		/**
		 * Mapped key for moving down
		 *
		 * @member
		 * @instance
		 * @name moveDown
		 * @public
		 * @type {EP.Keyboard.EKey}
		 * @default {EP.Keyboard.EKey.eDown}
		 * @memberOf STU.LookAroundNavigation
		 */
		this._moveDown = EP.Keyboard.EKey.eDown;
		Object.defineProperty(this, 'moveDown', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._moveDown;
			},
			set: function(value) {
				this._moveDown = value;
				if (this._inputManager !== undefined && this._inputManager !== null) {
					this._inputManager.keyDown = this._moveDown;
				}
			}
		});

		/**
		 * Set the speed of Yaw displacement (horizontal speed, rotation on Up axis) in degree / seconds
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.horizontalRotationSensitivity = 200.0;

		/**
		 * Set the speed of Pitch displacement (vertical speed, rotation on Right axis) in degree / seconds
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.verticalRotationSensitivity = 100.0;

		/**
		 * Switch the X axis controls
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.invertXAxis = false;

		/**
		 * Switch the Y axis controls
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this.invertYAxis = false;

		/**
		 * Rotation smoothness coefficient
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
		this._rotationSmoothness = 100;
		Object.defineProperty(this, 'rotationSmoothness', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._rotationSmoothness;
			},
			set: function(value) {
				if (value <= 0) {
					console.warn('[Third Person Navigation] \"Rotation smoothness\" Should be greater than 0');
					this._rotationSmoothness = 1;
				} else {
					this._rotationSmoothness = value;
				}
			}
		});

		/**
		 * The angle offset to the bottom (relative to the initial Pitch)
		 *
		 * @member
		 * @public
		 * @type {Number}
		 */
		this._lowerPitchLimit = 1.92;
		Object.defineProperty(this, 'lowerPitchLimit', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._lowerPitchLimit;
			},
			set: function(value) {
				if (value < 0 || value > Math.PI / 2) {
					console.warn('[Third Person Navigation] \"Lower Pitch Limit\" Should be between 0 and PI/2 radian (90 degree)');
					this._lowerPitchLimit = value < 0 ? 0 : Math.PI / 2;
				} else {
					this._lowerPitchLimit = value;
				}
			}
		});

		/**
		 * The angle offset to the top (relative to the initial Pitch)
		 *
		 * @member
		 * @public
		 * @type {Number}
		 */
		this._upperPitchLimit = 1.22;
		Object.defineProperty(this, 'upperPitchLimit', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._upperPitchLimit;
			},
			set: function(value) {
				if (value < 0 || value > Math.PI / 2) {
					console.warn('[Third Person Navigation] \"Upper Pitch Limit\" Should be between 0 and PI/2 radian (90 degree)');
					this._upperPitchLimit = value < 0 ? 0 : Math.PI / 2;
				} else {
					this._upperPitchLimit = value;
				}
			}
		});

		/**
		 * The angle offset to the right (relative to the initial Yaw)
		 *
		 * @member
		 * @public
		 * @type {Number}
		 */
		this._rightYawLimit = 3.14159;
		Object.defineProperty(this, 'rightYawLimit', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._rightYawLimit;
			},
			set: function(value) {
				if (value < 0 || value > 2 * Math.PI) {
					console.warn('[Third Person Navigation] \"Right Yaw Limit\" Should be between 0 and 2*PI radian (360 degree)');
					this._rightYawLimit = value < 0 ? 0 : 2 * Math.PI;
				} else {
					this._rightYawLimit = value;
				}
			}
		});

		/**
		 * The angle offset to the left (relative to the initial Yaw)
		 *
		 * @member
		 * @public
		 * @type {Number}
		 */
		this._leftYawLimit = 3.14159;
		Object.defineProperty(this, 'leftYawLimit', {
			enumerable: true,
			configurable: true,
			get: function() {
				return this._leftYawLimit;
			},
			set: function(value) {
				if (value < 0 || value > 2 * Math.PI) {
					console.warn('[Third Person Navigation] \"Left Yaw Limit\" Should be between 0 and 2*PI radian (360 degree)');
					this._leftYawLimit = value < 0 ? 0 : 2 * Math.PI;
				} else {
					this._leftYawLimit = value;
				}
			}
		});

	};

	LookAroundNavigation.prototype = new Navigation();
	LookAroundNavigation.prototype.constructor = LookAroundNavigation;

	/**
	 * Process executed when STU.LookAroundNavigation is activating.
	 *
	 * @method
	 * @private
	 */
	LookAroundNavigation.prototype.onActivate = function() {
		Navigation.prototype.onActivate.call(this);

		//Registering key bindings
		this._inputManager.useMouse = this.useMouse;
		this._inputManager.useKeyboard = this.useKeyboard;
		this._inputManager.mouseAxis = 2;
		this._inputManager.mouseInvertY = false;
		this._inputManager.keyLeft = this.moveLeft;
		this._inputManager.keyRight = this.moveRight;
		this._inputManager.keyUp = this.moveUp;
		this._inputManager.keyDown = this.moveDown;
		//this._inputManager.keyTrigger1 = this.turbo; //turbo key

		/*var cameraQuat = this.actor.getTransform().matrix.getQuaternion();
		for(var i=0; i<this.rotationSmoothness; i++){
		    this._smoothnessQueue.push(cameraQuat);
		}*/

		for (var i = 0; i < this._rotationSmoothness; i++) {
			//var q0 = DSMath.Quaternion.makeRotation(DSMath.Vector3D.zVect, 0);
			this._smoothnessQueue.push(new DSMath.Quaternion());
		}
	};

	/**
	 * Process executed when STU.LookAroundNavigation is deactivating.
	 *
	 * @method
	 * @private
	 */
	LookAroundNavigation.prototype.onDeactivate = function() {
		Navigation.prototype.onDeactivate.call(this);
	};

	/**
	 * Update
	 *
	 * @private
	 */
	LookAroundNavigation.prototype.update = function() {
		var forwardVec, rightVec, ZAxisVec, camToTargetVec;
		var needToUpdateCamera = false;

		var lookAtPositionVec = new DSMath.Vector3D();

		var myLocation = this._camera.getLocation();
		if (myLocation === null || myLocation === undefined) {
			myLocation = "World";
		}

		var oldCameraPositionVec = this._camera.getPosition(myLocation);
		var cameraPositionVec = oldCameraPositionVec.clone();
		//var oldCameraPositionPt = new DSMath.Point(oldCameraPositionVec.x, oldCameraPositionVec.y, oldCameraPositionVec.z);

		forwardVec = this._camera.getForward(myLocation);
		this.handleReticule();
		ZAxisVec = new DSMath.Vector3D(0, 0, 1);
		rightVec = this._camera.getRight(myLocation);

		if (this._isLookingAt === true) {
			this.handleLookAt();
		} else {
			// ORIENTATION.       
			// x and y movement during this frame
			var deltaX = 0;
			var deltaY = 0;
			if (this.useMouse) {
				if ((this.navigateOnClick === false && this._isCursorInNeutralZone === false) ||
					(this.navigateOnClick === true && this._isMousePressed === true)) {
					deltaX = this.followMouse === true ? (this._inputManager.axis2.x - this._lastMousePosition.x) / this._deltaTime : this._inputManager.axis2.x;
					deltaY = this.followMouse === true ? (this._inputManager.axis2.y - this._lastMousePosition.y) / this._deltaTime : this._inputManager.axis2.y;
					this._lastMousePosition.x = this._inputManager.axis2.x;
					this._lastMousePosition.y = this._inputManager.axis2.y;
				}
			}
			if (this.useKeyboard) {
				if (this._inputManager.axis1.x !== 0) {
					deltaX = this._inputManager.axis1.x * -1;
				}
				if (this._inputManager.axis1.y !== 0) {
					deltaY = this._inputManager.axis1.y * -1;
				}
			}
			if (this.useGamepad) {
				var gp = EP.Devices.getGamepad();
				if (gp === undefined || gp === null) {
					return;
				}

				if (gp.getAxisValue(EP.Gamepad.EAxis.eLSX) !== 0) {
					deltaX = gp.getAxisValue(EP.Gamepad.EAxis.eLSX) * -1;
				}
				if (gp.getAxisValue(EP.Gamepad.EAxis.eLSY) !== 0) {
					deltaY = gp.getAxisValue(EP.Gamepad.EAxis.eLSY) * -1;
				}
			}

			deltaX = this.invertXAxis ? (deltaX * -1) : deltaX;
			deltaY = this.invertYAxis ? (deltaY * -1) : deltaY;

			camToTargetVec = new DSMath.Vector3D();

			var rightQuat = new DSMath.Quaternion();
			rightQuat.makeRotation(rightVec, -deltaY * STU.Math.DegreeToRad * this.verticalRotationSensitivity * this._deltaTime);

			var rotDataPitch = rightQuat.getRotationData();
			this._currentPitch += this._sign(deltaY) * rotDataPitch.angle;

			if (this.lowerPitchLimit !== Math.PI || this.upperPitchLimit !== Math.PI) {
				if (this._currentPitch < -1 * this.upperPitchLimit || this._currentPitch > this.lowerPitchLimit) {
					rightQuat.makeRotation(rightVec, 0);
					this._currentPitch -= this._sign(deltaY) * rotDataPitch.angle;
				}
			}

			var zAxisQuat = new DSMath.Quaternion();
			zAxisQuat.makeRotation(ZAxisVec, deltaX * STU.Math.DegreeToRad * this.horizontalRotationSensitivity * this._deltaTime);

			var rotDataYaw = zAxisQuat.getRotationData();
			this._currentYaw += this._sign(deltaX) * rotDataYaw.angle;
			if (this.leftYawLimit !== 2 * Math.PI || this.rightYawLimit !== 2 * Math.PI) {
				if (this._currentYaw < -1 * this.rightYawLimit || this._currentYaw > this.leftYawLimit) {
					zAxisQuat.makeRotation(ZAxisVec, 0);
					this._currentYaw -= this._sign(deltaX) * rotDataYaw.angle;
				}
			}

			var composedRotQuat = DSMath.Quaternion.multiply(rightQuat, zAxisQuat);

			/////////////////////////////=======================================================================================/////////////////////////////////
			this._smoothnessQueue.push(composedRotQuat);
			//this._smoothnessQueue.shift();

			//Global variable which holds the amount of rotations which
			//need to be averaged.
			var addAmount = 0; // this._smoothnessQueue.length + 1;

			//Global variable which represents the additive quaternion
			var addedRotation = this._smoothnessQueue.shift(); //new DSMath.Quaternion(); //Quaternion.identity;

			//The averaged rotational value
			var averageRotation;

			//Loop through all the rotational values.
			for (var i = 0; i < this._smoothnessQueue.length; i++) {

				//Amount of separate rotational values so far
				addAmount++;

				addedRotation = DSMath.Quaternion.slerp(this._smoothnessQueue[i], addedRotation, addAmount / this._smoothnessQueue.length);
				averageRotation = addedRotation.clone();
				averageRotation.normalize();
			}
			/////////////////////////////=======================================================================================/////////////////////////////////

			var forwardPoint = new DSMath.Point();
			forwardPoint.set(forwardVec.x, forwardVec.y, forwardVec.z);
			var camToTargetPoint = forwardPoint.applyQuaternion(averageRotation); //var camToTargetPoint = composedRotQuat.rotate(forwardPoint);

			camToTargetVec.set(camToTargetPoint.x, camToTargetPoint.y, camToTargetPoint.z);

			////////////////////////////////////////////////////////////////////////////////////

			//avoid rotation glitches
			if (Math.abs(camToTargetVec.z) > 0.999) {
				forwardPoint.set(forwardVec.x, forwardVec.y, forwardVec.z);
				camToTargetPoint = forwardPoint.applyQuaternion(zAxisQuat); //var camToTargetPoint = zAxisQuat.rotate(forwardPoint);
				camToTargetVec.set(camToTargetPoint.x, camToTargetPoint.y, camToTargetPoint.z);
			}

			needToUpdateCamera = true;

			if (needToUpdateCamera === true) {
				lookAtPositionVec.set(cameraPositionVec.x + camToTargetVec.x, cameraPositionVec.y + camToTargetVec.y, cameraPositionVec.z + camToTargetVec.z);
				this._camera.lookAt(lookAtPositionVec);
			}
		}
		return this;
	};

    /**
	 * Replace Math.sign for IE 
	 * 
	 * @private
	 */
	LookAroundNavigation.prototype._sign = function (iNumber) {
	    if (iNumber === 0) {
	        return 0;
	    } else if (iNumber > 0) {
	        return 1;
	    } else if (iNumber < 0) {
	        return -1;
	    }
	};

	/**
	 * Makes the navigation look at a given actor with a smooth transition.
	 *
	 * @public
	 * @param  {STU.Actor3D} iActor 3DActor to look at
	 */
	LookAroundNavigation.prototype.lookAt = function(iActor) {
		// - XE8 - 
		//    This one is exactly the same as FirstPersonNavigation.lookAt, for now I leave them split but they could be merged one day.
		// 
		if (!(iActor instanceof STU.Actor3D)) {
			console.error('LookAroundNavigation.lookAt can only look at an STU.Actor3D');

		} else {
			this._isLookingAt = true;
			this._lookAtTarget = iActor;
			this._lookAtElapsedTime = 0; // 0
			this._timeToLookAt = 450 / (this.horizontalRotationSensitivity + this.verticalRotationSensitivity);

			var myLocation = this._camera.getLocation();
			if (myLocation === null || myLocation === undefined) {
				myLocation = "World";
			}

			var camTransfo = this._camera.getTransform(myLocation);
			this._lookAtStartQuat = new DSMath.Quaternion();
			camTransfo.matrix.getQuaternion(this._lookAtStartQuat);
		}
	};

	/**
	 * Performs the lookAt transition. 
	 * 
	 * @private
	 */
	LookAroundNavigation.prototype.handleLookAt = function() {
		// - XE8 - 
		//    This one is exactly the same as FirstPersonNavigation.handleLookAt, for now I leave them split but they could be merged one day.
		// 
		if (this._isLookingAt === false) {
			return;
		}

		this._lookAtElapsedTime += this._deltaTime;
		var lerpAmount = this._lookAtElapsedTime / this._timeToLookAt;

		var myLocation = this._camera.getLocation();
		if (myLocation === null || myLocation === undefined) {
			myLocation = "World";
		}

		if (lerpAmount >= 1) {
			this._camera.lookAt(this._lookAtTarget);
			this._isLookingAt = false;
		} else {
			var camTransform = this._camera.getTransform(myLocation);

			var dir = DSMath.Vector3D.sub(this._lookAtTarget.getPosition(myLocation), camTransform.vector);
			dir.normalize();

			//Cameras are looking to -x
			dir.negate();

			// projecting the new sight direction on the ground to get a right direction parallel to the ground
			var dirOnGround = dir.clone();
			dirOnGround.z = 0;
			dirOnGround.normalize();

			var right = DSMath.Vector3D.cross(DSMath.Vector3D.zVect, dirOnGround);
			right.normalize();

			// computing the up direction as usual
			var up = DSMath.Vector3D.cross(dir, right);
			up.normalize();

			var mTargetLook = new DSMath.Matrix3x3();
			mTargetLook.setFromArray([
				dir.x, right.x, up.x,
				dir.y, right.y, up.y,
				dir.z, right.z, up.z
			]);

			var endQuat = new DSMath.Quaternion();
			mTargetLook.getQuaternion(endQuat);
			var intermediateQuat = DSMath.Quaternion.slerp(this._lookAtStartQuat, endQuat, lerpAmount);
			camTransform.matrix = intermediateQuat.getMatrix();
			this._camera.setTransform(camTransform, myLocation);
		}
	};

	// Expose in STU namespace.
	STU.LookAroundNavigation = LookAroundNavigation;

	return LookAroundNavigation;
});

define('StuCameras/StuLookAroundNavigation', ['DS/StuCameras/StuLookAroundNavigation'], function(LookAroundNavigation) {
	'use strict';

	return LookAroundNavigation;
});

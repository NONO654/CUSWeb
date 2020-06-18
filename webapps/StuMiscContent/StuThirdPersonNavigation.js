define('DS/StuMiscContent/StuThirdPersonNavigation', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent', 'MathematicsES/MathsDef',
		'DS/StuCore/StuEnvServices', 'DS/EPInputs/EPKeyboard', 'DS/EPInputs/EPMousePressEvent', 'DS/EPInputs/EPMouseWheelEvent', 'DS/EPInputs/EPMouseReleaseEvent',
		'DS/EPInputs/EPMouseMoveEvent', 'DS/EPInputs/EPMouse'
	],
	function (STU, EP, Behavior, Task, EventServices, Event, DSMath, StuEnvServices) {
		'use strict';

		var ThirdPersonNavigationTask = function(iComp) {
			Task.call(this);
			this.comp = iComp;
		};

		ThirdPersonNavigationTask.prototype = new Task();
		ThirdPersonNavigationTask.prototype.constructor = ThirdPersonNavigationTask;

		/**
		 * Method called each frame by the task manager
		 *
		 * @method
		 * @private
		 * @param  iExContext Execution context
		 */
		ThirdPersonNavigationTask.prototype.onExecute = function(iExContext) {
			if ('executeOneFrame' in this.comp) {
				this.comp.executeOneFrame(iExContext);
			}
		};

		/**
		 * The third person navigation behavior offer the possibility to get an external view focused on a specific target by making a camera actor follow another actor
		 *
		 * @exports ThirdPersonNavigation
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
		 * @alias STU.ThirdPersonNavigation
		 */
		var ThirdPersonNavigation = function() {
			Behavior.call(this);
			this.name = 'ThirdPersonNavigation';
			this.associatedTask;

			this._resetCameraTransform = false;

			//public
			/**
			 * The target of the camera
			 *
			 * @name target
			 * @member
			 * @public
			 * @type {STU.Actor3D}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._target = null;
			Object.defineProperty(this, 'target', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._target;
				},
				set: function(value) {
					var goodArgsType = (value instanceof STU.Actor3D);
					if (goodArgsType) {
						if (this._target !== null) { //to anticipate first init
							//[IR-459937] To avoid dezoom when changing target
							this._resetCameraTransform = true;
							this._queueStabilisator.splice(0, this._queueStabilisator.length);
						}
						this._target = value;
					} else {
						console.warn('[TrafficManager] : Target should be defined by a STU.Actor3D !');
					}
				}
			});

			/**
			 * Position offset according to the origin of the target
			 *
			 * @member
			 * @public
			 * @type {DSMath.Vector3D}
			 */
			this.offset = new DSMath.Vector3D();


			/**
			 * A reference to the front axis of the target
			 *
			 * @member
			 * @public
			 * @type {STU.ThirdPersonNavigation.eAxis}
			 */
			this.targetDirectionAxis = null;

			/**
			 * The distance between the camera and its target
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.keepAtDistance = 10000;

			/**
			 * The maximum distance between the camera and its target
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.maximumDistance = 12000;

			/**
			 * Enable gamepad interaction
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.useGamepad = true;

			/**
			 * Enable mouse interaction
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.useMouse = true;

			/**
			 * Enable the possibility to zoom on target
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.zoom = true;

			/**
			 * Camera speed coefficient when making a rotation around the horizontal axis of the target.
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.horizontalRotationSensitivity = 2;

			/**
			 * Camera speed coefficient when making a rotation around the vertical axis of the target.
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.verticalRotationSensitivity = 2;

			/**
			 * Zoom speed coefficient.
			 *
			 * @name zoomSensitivity
			 * @member
			 * @public
			 * @type {Number}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._zoomSensitivity = 2;
			Object.defineProperty(this, 'zoomSensitivity', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._zoomSensitivity;
				},
				set: function(value) {
					if (value <= 0) {
						console.warn('[Third Person Navigation] \"Zoom Sensitivity\" should be greater than 0');
						this._zoomSensitivity = 1;
					} else {
						this._zoomSensitivity = value;
					}
				}
			});

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
			 * Define the condition to reset the position of the camera
			 *
			 * @member
			 * @public
			 * @type {STU.ThirdPersonNavigation.eResetMode}
			 */
			this.resetMode = 2;

			/**
			 * The position of teh camera will be reset after the delay defined by this parameter  
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.resetTimer = 2;

			/**
			 * The position of the camera will be reset after pressing the keyboard�s key defined by this parameter   
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.resetKey = 0;

			/**
			 * Avoid collision with other object
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.avoidCollisions = false;

			/**
			 * Interpolation coefficient acting on the orientation and position of the camera through time
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.stabilizationFactor = 25; // doesnt care of keepdistancetolerance

			/**
			 * Smoothness coefficient of the camera rotation 
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.rotationSmoothness = 5; // 0 = No smoothness

			/**
			 * Smoothness coefficient of the camera translation 
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.translationSmoothness = 0;

			/**
			 * Camera initial orientation on its side axis
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.pitchAngle = 0.35;

			/**
			 * Camera initial orientation on its up axis
			 *
			 * @member
			 * @public
			 * @type {Number}
			 */
			this.yawAngle = 0;

			/**
			 * The angle offset to the bottom (relative to the initial Pitch)
			 *
			 * @name lowerPitchLimit
			 * @member
			 * @public
			 * @type {Number}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._lowerPitchLimit = 1.92;
			Object.defineProperty(this, 'lowerPitchLimit', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._lowerPitchLimit;
				},
				set: function(value) {
					if (value < 0 || value > Math.PI) {
						console.warn('[Third Person Navigation] \"Lower Pitch Limit\" Should be between 0 and PI radian');
						this._lowerPitchLimit = value < 0 ? 0 : Math.PI;
					} else {
						this._lowerPitchLimit = value;
					}
				}
			});

			/**
			 * The angle offset to the top (relative to the initial Pitch)
			 *
			 * @name upperPitchLimit
			 * @member
			 * @public
			 * @type {Number}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._upperPitchLimit = 1.22;
			Object.defineProperty(this, 'upperPitchLimit', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._upperPitchLimit;
				},
				set: function(value) {
					if (value < 0 || value > Math.PI) {
						console.warn('[Third Person Navigation] \"Upper Pitch Limit\" Should be between 0 and PI radian');
						this._upperPitchLimit = value < 0 ? 0 : Math.PI;
					} else {
						this._upperPitchLimit = value;
					}
				}
			});

			/**
			 * The angle offset to the right (relative to the initial Yaw)
			 *
			 * @name rightYawLimit
			 * @member
			 * @public
			 * @type {Number}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._rightYawLimit = 3.14159;
			Object.defineProperty(this, 'rightYawLimit', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._rightYawLimit;
				},
				set: function(value) {
					if (value < 0 || value > Math.PI) {
						console.warn('[Third Person Navigation] \"Right Yaw Limit\" Should be between 0 and PI radian');
						this._rightYawLimit = value < 0 ? 0 : Math.PI;
					} else {
						this._rightYawLimit = value;
					}
				}
			});

			/**
			 * The angle offset to the left (relative to the initial Yaw)
			 *
			 * @name leftYawLimit
			 * @member
			 * @public
			 * @type {Number}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._leftYawLimit = 3.14159;
			Object.defineProperty(this, 'leftYawLimit', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._leftYawLimit;
				},
				set: function(value) {
					if (value < 0 || value > Math.PI) {
						console.warn('[Third Person Navigation] \"Left Yaw Limit\" Should be between 0 and PI radian');
						this._leftYawLimit = value < 0 ? 0 : Math.PI;
					} else {
						this._leftYawLimit = value;
					}
				}
			});

			/**
			 * Lock the camera rotation on its up axis
			 *
			 * @name lockYaw
			 * @member
			 * @public
			 * @type {Boolean}
			 * @memberOf STU.ThirdPersonNavigation
			 */
			this._lockYaw = false;
			Object.defineProperty(this, 'lockYaw', {
				enumerable: true,
				configurable: true,
				get: function() {
					return this._lockYaw;
				},
				set: function(value) {
					var goodArgsType = (value !== null && value !== undefined);
					if (goodArgsType) {
						this._lockYaw = value;
						if (this._lockYaw === true) {
							//[IR-460004] Stop yaw update when lock yaw parameter is set to true
							this._lockYawVectorReference = this._targetForwardVector.clone();
							var frontVector = this._camera.getTransform().matrix.getFirstColumn();
							frontVector.multiplyScalar(-1);

							if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
								this._yawAngle = this.getAngleBetweenVectorsInXZ(frontVector, this._targetForwardVector);
							} else {
								this._yawAngle = this.getAngleBetweenVectorsInXY(frontVector, this._targetForwardVector);
							}
						}
					}
				}
			});

			/**
			 * Lock the camera rotation on its side axis
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.lockPitch = false;

			this.targetForward = 'x';
			this.keepAtDistanceTolerance = 1000;
			this.smartCam = true;
			this.smartCamTimer = 2; // in seconds
			//this.controlSensitivity = 2; // 0 -> 10


			//private
			this._zoom = 1;
			this._keepAtDistanceTolerance = 0;
			this._keepAtDistanceZoom = 0;
			this._pitchAngle = 0;
			this._yawAngle = 0;
			this._smartCamLocalTimer = 0;
			this._targetOldTransform = null;
			this._targetTransform = null;
			this._targetForwardVector = null;
			this._distanceDiff = 0;
			this._isLeftClickPressed = false;
			this._queueStabilisator = [];
			this._lockYawVectorReference = null;
			this._isCurrentCamera = true;
			this._keyboardMouseWheel = null;
			this._keyboardMousePress = null;
			this._keyboardMouseRelease = null;
			this._keyboardMouseMove = null;
			this._targetTransformOffset = null;

			this._targetTransformWithoutOffset = null;
			this._oldTargetTransformWithoutOffset = null;

			this._settedOffset = new DSMath.Vector3D();
			this._offsetTimer = 0;
			this._isSettingOffset = false;

			this._collisionDetected = false;

		};


		ThirdPersonNavigation.prototype = new Behavior();
		ThirdPersonNavigation.prototype.constructor = ThirdPersonNavigation;
		//ThirdPersonNavigation.prototype.pureRuntimeAttributes = ['_zoom'].concat(Behavior.prototype.pureRuntimeAttributes);

		/**
		 * An enumeration of all the supported direction axis.<br/>
		 * It allows to refer in the code to a specific key.
		 *
		 * @enum {number}
		 * @public
		 */
		ThirdPersonNavigation.eAxis = {
			eXPositive: 0,
			eXNegative: 1,
			eYPositive: 2,
			eYNegative: 3,
			eZPositive: 4,
			eZNegative: 5,
		};

		/**
		 * An enumeration of all the event to reset the camera position.<br/>
		 * It allows to refer in the code to a specific key.
		 *
		 * @enum {number}
		 * @public
		 */
		ThirdPersonNavigation.eResetMode = {
			eNoActivation: 0,
			eOnTimer: 1,
			eOnKeyPress: 2,
		};


		//###################################################################################################
		//                                              BASICS                                           	#
		//###################################################################################################

		/**
		 * Process executed when STU.ThirdPersonNavigation is activating
		 *
		 * @method
		 * @private
		 */
		ThirdPersonNavigation.prototype.onActivate = function() {
			Behavior.prototype.onActivate.call(this);
			this.associatedTask = new ThirdPersonNavigationTask(this);
			EP.TaskPlayer.addTask(this.associatedTask);

			var myEnvServices = new StuEnvServices();
			this._betaVersion = myEnvServices.CATGetEnv("CXP_TPN_BETA");

			this._keyboardMouseWheel = STU.makeListener(this, 'listenerMouseWheel');
			EventServices.addListener(EP.MouseWheelEvent, this._keyboardMouseWheel);
			this._keyboardMousePress = STU.makeListener(this, 'listenerMousePress');
			EventServices.addListener(EP.MousePressEvent, this._keyboardMousePress);
			this._keyboardMouseRelease = STU.makeListener(this, 'listenerMouseRelease');
			EventServices.addListener(EP.MouseReleaseEvent, this._keyboardMouseRelease);
			this._keyboardMouseMove = STU.makeListener(this, 'listenerMouseMove');
			EventServices.addListener(EP.MouseMoveEvent, this._keyboardMouseMove);

			/*
            console.log("target: " + this.target);
            console.log("targetDirectionAxis: " + this.targetDirectionAxis);
            console.log("offset: " + this.offset);
            console.log("keepAtDistance: " + this.keepAtDistance);
            console.log("maximumDistance: " + this.maximumDistance);
            console.log("useGamepad: " + this.useGamepad);
            console.log("useMouse: " + this.useMouse);
            console.log("zoom: " + this.zoom);
            console.log("horizontalRotationSensitivity: " + this.horizontalRotationSensitivity);
            console.log("verticalRotationSensitivity: " + this.verticalRotationSensitivity);
            console.log("resetMode: " + this.resetMode);
            console.log("resetTimer: " + this.resetTimer);
            console.log("stabilisation Factor: " + this.stabilizationFactor);
            console.log("translationSmoothness: " + this.translationSmoothness);
            console.log("rotationSmoothness: " + this.rotationSmoothness);
            console.log("pitchAngle: " + this.pitchAngle + " \t (" + this.degToRad(this.pitchAngle) + " rad)");
            console.log("yawAngle: " + this.yawAngle + " \t (" + this.degToRad(this.yawAngle)+" rad)");
	        console.log("lockYaw: "+this.lockYaw);
	        console.log("lockPitch: "+this.lockPitch);
            */

			this.checkParameters();

			this._settedOffset = this.offset.clone();

			//this.pitchAngle = this.degToRad(this.pitchAngle);
			//this.yawAngle = this.degToRad(this.yawAngle);

			// Special inits
			if (this.target !== undefined && this.target !== null) {
				//console.log('[Third Person Navigation] Camera target is not defined!');
				this._targetTransformOffset = this.target.getTransform().clone();
				this._targetTransformOffset.vector.add(this._settedOffset);

				this._targetTransformWithoutOffset = this.target.getTransform().clone();
				this._oldTargetTransformWithoutOffset = this.target.getTransform().clone();
				this.computeInitialPosition();

				var bs = this.target.getBoundingSphere();
				this._minDistance = bs.radius;

				//this._minDistance = this.keepAtDistance * 0.3; // 0.3 ==> minimum zoom value
			}
		};

		/**
		 * Process executed when STU.ThirdPersonNavigation is deactivating
		 *
		 * @method
		 * @private
		 */
		ThirdPersonNavigation.prototype.onDeactivate = function() {
			EP.TaskPlayer.removeTask(this.associatedTask);
			delete this.associatedTask;

			EventServices.removeListener(EP.MouseWheelEvent, this._keyboardMouseWheel);
			delete this._keyboardMouseWheel;
			EventServices.removeListener(EP.MousePressEvent, this._keyboardMousePress);
			delete this._keyboardMousePress;
			EventServices.removeListener(EP.MouseReleaseEvent, this._keyboardMouseRelease);
			delete this._keyboardMouseRelease;
			EventServices.removeListener(EP.MouseMoveEvent, this._keyboardMouseMove);
			delete this._keyboardMouseMove;

			Behavior.prototype.onDeactivate.call(this);
		};

		/**
		 * Process executed each frame
		 *
		 * @method
		 * @private
		 */
		ThirdPersonNavigation.prototype.executeOneFrame = function(iDelta) {
			if (this.target === undefined || this.target === null) {
				return;
			}

			/*################################################################
            ##                                                              ##
            ##                      UPDATE PARAMETERS                       ##
            ##                                                              ##
            ##################################################################*/
			this.checkParameters();

			this._targetTransformOffset = this.target.getTransform().clone();
			this._targetTransformOffset.vector.add(this._settedOffset);

			this._oldTargetTransformWithoutOffset = this._targetTransformWithoutOffset.clone();
			this._targetTransformWithoutOffset = this.target.getTransform().clone();

			// Is current camera check
			if (this._isCurrentCamera) {
				this._isCurrentCamera = this._camera.isCurrent();
			} else {
				this._isCurrentCamera = this._camera.isCurrent();
				if (this._isCurrentCamera) {
					this._yawAngle = this.yawAngle;
					this._pitchAngle = this.pitchAngle;
					this.updateOrientation(true);
				}
				return;
			}

			this._deltaTime = iDelta.deltaTime;
			this._keepAtDistanceZoom = this.keepAtDistance * this._zoom;

			if (this.useGamepad) {
				this.updateGamepadController();
			}
			//if(this.resetMode !== ThirdPersonNavigation.eResetMode.eNoActivation)
			if (this.resetMode !== ThirdPersonNavigation.eResetMode.eNoActivation && !this._isLeftClickPressed) {
				this.updateSmartCam();
			}
			if (this.avoidCollisions) {
				this.updateAvoidCollision();
			}
			this.manageOffset();
			this.updateTargetPostion();
			this.updateTargetForwardVector();
			this.updateRotation();
			this.updateOrientation();

			//this.updateFollowingDistance();
			if (this.avoidCollisions === false) {
				this.updateFollowingDistance();
			} else if (this.avoidCollisions && this._collisionDetected === false) {
				this.updateFollowingDistance();
			}
		};

		//###################################################################################################
		//                                              MOVEMENTS                                           #
		//###################################################################################################

		/**
		 * Methods checking that all the parameters inquired are correct
		 *
		 * @method
		 * @private
		 */
		ThirdPersonNavigation.prototype.checkParameters = function() {
			// Special inits
			if (this.target === undefined || this.target === null) {
				console.error('[Third Person Navigation] Camera target is not defined!');
			}
			if (this.targetDirectionAxis > 5 || this.targetDirectionAxis < 0) {
				console.error('[Third Person Navigation] unknown axis');
				this.targetDirectionAxis = ThirdPersonNavigation.eAxis.eXPositive;
			}
			if (this.keepAtDistance <= 0) {
				console.warn('[Third Person Navigation] The camera should be keep to a distance greater to 0 from the target !');
				this.keepAtDistance = 0.1;
			}
			if (this.keepAtDistance <= this.maximumDistance) {
				this._keepAtDistanceTolerance = this.maximumDistance - this.keepAtDistance;
			} else {
				console.warn("[Third Person Navigation] \"Maximum Distance\" should be greater or equals to \"Keep at Distance\"");
				this.maximumDistance = this.keepAtDistance;
				this._keepAtDistanceTolerance = 0;
			}
			if (this.horizontalRotationSensitivity < 0) {
				console.warn("[Third Person Navigation] \"Horizontal Rotation Sensitivity\" should be greater to 0");
				this.horizontalRotationSensitivity = 0;
			}
			if (this.verticalRotationSensitivity < 0) {
				console.warn("[Third Person Navigation] \"Vertical Rotation Sensitivity\" should be greater to 0");
				this.verticalRotationSensitivity = 0;
			}
			if (this.resetMode < 0 || this.resetMode > 2) {
				console.error('[Third Person Navigation] unknown \"Reset Mode\"');
				this.resetMode = ThirdPersonNavigation.eResetMode.eNoActivation;
			}
			if (this.resetTimer < 0) {
				console.error('[Third Person Navigation] \"Reset Timer\" Should be greater than 0');
				this.resetTimer = 1;
			}
			if (this.translationSmoothness < 0) {
				console.error('[Third Person Navigation] \"Translation Smoothness\" Should be greater or eqauls to 0');
				this.translationSmoothness = 0;
			}
			if (this.rotationSmoothness < 0) {
				console.error('[Third Person Navigation] \"Rotation Smoothness\" Should be greater or equals to 0');
				this.rotationSmoothness = 0;
			}
		};

		ThirdPersonNavigation.prototype.computeInitialPosition = function() {
			var newTransform = new DSMath.Transformation();
			this._yawAngle = this.yawAngle;
			this._pitchAngle = this.pitchAngle;
			this._camera = this.getActor();

			// Translate
			this._targetTransform = this._targetTransformOffset;
			this._targetOldTransform = this._targetTransformOffset;
			//this._targetForwardVector = this.target.getTransform().matrix.getFirstColumn();
			var newCameraPosition = this._targetTransformOffset.vector.clone();
			switch (this.targetDirectionAxis) {
				case ThirdPersonNavigation.eAxis.eXPositive:
					this._targetForwardVector = this.target.getTransform().matrix.getFirstColumn();
					newCameraPosition.x -= this.keepAtDistance;
					//console.log("X");
					break;
				case ThirdPersonNavigation.eAxis.eXNegative:
					this._targetForwardVector = this.target.getTransform().matrix.getFirstColumn();
					this._targetForwardVector.negate();
					newCameraPosition.x += this.keepAtDistance;
					//console.log("-X");
					break;
				case ThirdPersonNavigation.eAxis.eYPositive:
					this._targetForwardVector = this.target.getTransform().matrix.getSecondColumn();
					newCameraPosition.y -= this.keepAtDistance;
					//console.log("Y");
					break;
				case ThirdPersonNavigation.eAxis.eYNegative:
					this._targetForwardVector = this.target.getTransform().matrix.getSecondColumn();
					this._targetForwardVector.negate();
					newCameraPosition.y += this.keepAtDistance;
					//console.log("-Y");
					break;
				case ThirdPersonNavigation.eAxis.eZPositive:
					this._targetForwardVector = this.target.getTransform().matrix.getThirdColumn();
					newCameraPosition.z -= this.keepAtDistance;
					//console.log("Z");
					break;
				case ThirdPersonNavigation.eAxis.eZNegative:
					this._targetForwardVector = this.target.getTransform().matrix.getThirdColumn();
					this._targetForwardVector.negate();
					newCameraPosition.z += this.keepAtDistance;
					//console.log("-Z");
					break;

			}

			//newCameraPosition.x -= this.keepAtDistance;
			newTransform.vector = newCameraPosition;

			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				// Orientate 
				var worldY = new DSMath.Vector3D(0, 1, 0);
				var cameraForward = newCameraPosition.clone();
				cameraForward.sub(this._targetTransformOffset.vector.clone());
				//cameraForward = DSMath.Vector3D.sub(this._targetTransform.vector.clone().add(this.offset), newCameraPosition);
				cameraForward.normalize();
				var vectorX = DSMath.Vector3D.cross(worldY, cameraForward);
				vectorX.normalize();
				newTransform.matrix.setFromArray([cameraForward.x, worldY.x, -vectorX.x,
					cameraForward.y, worldY.y, -vectorX.y,
					cameraForward.z, worldY.z, -vectorX.z
				]);
			} else {
				// Orientate 
				var worldZ = new DSMath.Vector3D(0, 0, 1);
				var cameraForward = newCameraPosition.clone();
				cameraForward.sub(this._targetTransformOffset.vector.clone());
				cameraForward.normalize();
				var vectorY = DSMath.Vector3D.cross(worldZ, cameraForward);
				vectorY.normalize();
				newTransform.matrix.setFromArray([cameraForward.x, vectorY.x, worldZ.x,
					cameraForward.y, vectorY.y, worldZ.y,
					cameraForward.z, vectorY.z, worldZ.z
				]);
			}

			// Apply to the camera
			this._camera.setTransform(newTransform);

			// Set up the first frame
			this._deltaTime = 1;
			this._keepAtDistanceZoom = this.keepAtDistance * this._zoom;
			this.updateTargetPostion();
			this.updateTargetForwardVector();
			if (this.lockYaw) {
				this._lockYawVectorReference = this._targetForwardVector.clone();
			}
			this.updateRotation(true, true);
			this.updateOrientation();
			this.updateFollowingDistance();
		};

		ThirdPersonNavigation.prototype.updateTargetPostion = function() {
			this._targetOldTransform = this._targetTransform.clone();
			this._queueStabilisator.push(this._targetTransformOffset);
			if (this._queueStabilisator.length > this.stabilizationFactor + 1) {
				this._queueStabilisator.shift();
			}
			this._targetTransform = this.getAverageTransform();
			var keepAtDistanceVector = this._targetTransform.vector.clone();
			keepAtDistanceVector.sub(this._targetOldTransform.vector.clone());
			if (keepAtDistanceVector.norm() === 0) {
				return;
			}

			//[IR-459937] To avoid dezoom when changing target
			if (this._resetCameraTransform) {
				this._distanceDiff = 0;
			} else {
				var d = DSMath.Vector3D.sub(this._oldTargetTransformWithoutOffset.vector, this._targetTransformWithoutOffset.vector).norm();
				if (d > 0) {
					this._distanceDiff = keepAtDistanceVector.norm();
				}
			}

			this._camera.translate(keepAtDistanceVector);
			// keepAtDistanceVector.normalize();
			// var distance = this.DistanceToPosition(this._targetTransform.vector);
			// var factor = (distance - this.keepAtDistance) / ( 1 + this.translationSmoothness);
			// keepAtDistanceVector.multiplyScalar(factor);
		};

		ThirdPersonNavigation.prototype.getAverageTransform = function() {
			var averageTransform = new DSMath.Transformation();
			averageTransform.vector.set(0, 0, 0);
			averageTransform.matrix.setFromArray([0, 0, 0, 0, 0, 0, 0, 0, 0]);
			for (var i = 0; i < this._queueStabilisator.length; i++) {
				averageTransform.vector.add(this._queueStabilisator[i].vector);
				averageTransform.matrix.add(this._queueStabilisator[i].matrix);
			}
			averageTransform.vector.multiplyScalar(1 / this._queueStabilisator.length);
			averageTransform.matrix.multiplyScalar(1 / this._queueStabilisator.length);

			return averageTransform;
		};

		ThirdPersonNavigation.prototype.DistanceToPosition = function(position) {
			var vectDiff = position.clone();
			vectDiff.sub(this.getActor().getPosition());
			return vectDiff.norm();
		};

		ThirdPersonNavigation.prototype.updateTargetForwardVector = function() {

			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eXPositive) {
				this._targetForwardVector = this._targetTransform.matrix.getFirstColumn();
			} else if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eXNegative) {
				this._targetForwardVector = this._targetTransform.matrix.getFirstColumn();
				this._targetForwardVector.multiplyScalar(-1);
			} else if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eYPositive) {
				this._targetForwardVector = this._targetTransform.matrix.getSecondColumn();
			} else if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eYNegative) {
				this._targetForwardVector = this._targetTransform.matrix.getSecondColumn();
				this._targetForwardVector.multiplyScalar(-1);
			} else if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				this._targetForwardVector = this._targetTransform.matrix.getThirdColumn();
			} else if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative) {
				this._targetForwardVector = this._targetTransform.matrix.getThirdColumn();
				this._targetForwardVector.multiplyScalar(-1);
			}
			//TODO: -/+Z AXis
		};

		//###################################################################################################
		//                                              MATH UTILS                                          #
		//###################################################################################################

		ThirdPersonNavigation.prototype.getAngleBetweenVectorsInXY = function(vector1, vector2) {
			var vec1 = vector1.clone();
			vec1.z = 0;
			vec1.normalize();
			var vec2 = vector2.clone();
			vec2.z = 0;
			vec2.normalize();
			var dot = vec1.dot(vec2);
			var angle = 0;
			if (dot >= 1) {
				angle = 0.0;
			} else if (dot <= -1) {
				angle = Math.PI;
			} else {
				angle = Math.acos(dot);
			}
			var sign = vec1.x * vec2.y - vec1.y * vec2.x;
			if (sign < 0) {
				return -angle;
			}
			return angle;
		};

		ThirdPersonNavigation.prototype.getAngleBetweenVectorsInXZ = function(vector1, vector2) {
			var vec1 = vector1.clone();
			vec1.y = 0;
			vec1.normalize();
			var vec2 = vector2.clone();
			vec2.y = 0;
			vec2.normalize();
			var dot = vec1.dot(vec2);
			var angle = 0;
			if (dot >= 1) {
				angle = 0.0;
			} else if (dot <= -1) {
				angle = 0;
			} else {
				angle = Math.acos(dot);
			}
			//var sign = vec1.x * vec2.z - vec1.z* vec2.x;
			var sign = vec1.z * vec2.x - vec1.x * vec2.z;
			if (sign < 0) {
				return -angle;
			}
			return angle;
		};

		ThirdPersonNavigation.prototype.getAngleBetweenVectors = function(vector1, vector2) {
			var vec1 = vector1.clone();
			vec1.normalize();
			var vec2 = vector2.clone();
			vec2.normalize();
			var dot = vec1.dot(vec2);
			var angle = 0;
			if (dot >= 1) {
				angle = 0.0;
			} else if (dot <= -1) {
				angle = Math.PI;
			} else {
				angle = Math.acos(dot);
			}
			return angle;
		};

		//###################################################################################################
		//                                              LISTENERS                                           #
		//###################################################################################################

		/*ThirdPersonNavigation.prototype.listenerMouseWheelOLD = function (iMouseWheelEvent) {
		    if (this.zoom && this._isCurrentCamera) {
		        var minimumZoomRatio = 0.3;//(this._minDistance + (this._camera.nearClip)) / this.keepAtDistance; // 0.3;
		        var maximumZoomRatio = 10;
		        this._zoom += iMouseWheelEvent.getWheelDeltaValue() * this._zoomSensitivity * -1 / 20;
		        if (this._zoom > maximumZoomRatio) {
		            this._zoom = maximumZoomRatio;
		        }
		        if (this._zoom < minimumZoomRatio) {
		            this._zoom = minimumZoomRatio;
		        }
		        this._smartCamLocalTimer = 0;
		    }
		};*/

		ThirdPersonNavigation.prototype.listenerMouseWheel = function(iMouseWheelEvent) {
			if (this.zoom && this._isCurrentCamera) {
				var minimumZoomRatio = 0.3; //(this._minDistance + (this._camera.nearClip)) / this.keepAtDistance; // 0.3;
				var maximumZoomRatio = 10;

				// Zoom coefficient increrase in function of our distance to the target 
				var keepAtDistanceZoom = this.keepAtDistance * this._zoom;
				var coeff = keepAtDistanceZoom / this.keepAtDistance;

				var mouseStep = iMouseWheelEvent.getWheelDeltaValue() * this._zoomSensitivity * -1 / 20;
				coeff = (this._betaVersion === 1) ? coeff : 1;
				this._zoom += mouseStep * coeff;
				//console.log((this._minDistance + (this._camera.nearClip)) / this.keepAtDistance);

				//this._zoom += iMouseWheelEvent.getWheelDeltaValue() * this._zoomSensitivity * -1 / 20;
				if (this._zoom > maximumZoomRatio) {
					this._zoom = maximumZoomRatio;
				}
				if (this._zoom < minimumZoomRatio) {
					this._zoom = minimumZoomRatio;
				}
				this._smartCamLocalTimer = 0;
			}
		};

		ThirdPersonNavigation.prototype.listenerMousePress = function(iMousePressEvent) {
			if (iMousePressEvent.getButton() === EP.Mouse.EButton.eLeft && this._isCurrentCamera) {
				this._isLeftClickPressed = true;
			}
			if (iMousePressEvent.getButton() === EP.Mouse.EButton.eMiddle && this._isCurrentCamera) {
				//this._yawAngle = this.yawAngle;
				//this._pitchAngle = this.pitchAngle;
				//	this.updateRotation(true);
				this.reset();
			}
		};

		ThirdPersonNavigation.prototype.listenerMouseRelease = function(iMousePressEvent) {
			if (iMousePressEvent.getButton() === EP.Mouse.EButton.eLeft && this._isCurrentCamera) {
				this._isLeftClickPressed = false;
			}
		};

		/*ThirdPersonNavigation.prototype.listenerMouseMove = function (iMouseMoveEvent) {
		    if (this._isLeftClickPressed && this.useMouse && this._isCurrentCamera) {
		        var delta = iMouseMoveEvent.getDeltaPosition();
		        if (this.lockPitch === false) {
		            this._pitchAngle += delta.y / (100 + 1000 / (this.verticalRotationSensitivity + 1));
		        }
		        if (this.lockYaw === false) {
		            this._yawAngle += delta.x / (100 + 1000 / (this.horizontalRotationSensitivity + 1));
		        }
		        if (this._pitchAngle > (Math.PI / 2) - 0.125) {
		            this._pitchAngle = (Math.PI / 2) - 0.125;
		        }
		        if (this._pitchAngle < -Math.PI / 2) {
		            this._pitchAngle = -Math.PI / 2;
		        }
		        this._smartCamLocalTimer = 0;
		    }
		};*/

		ThirdPersonNavigation.prototype.listenerMouseMove = function(iMouseMoveEvent) {
			if (this._isLeftClickPressed && this.useMouse && this._isCurrentCamera) {
				var delta = iMouseMoveEvent.getDeltaPosition();

				if (this.invertYAxis) {
					delta.y *= -1;
				}
				if (this.invertXAxis) {
					delta.x *= -1;
				}
				if (this.lockPitch === false) {
					this._pitchAngle += delta.y / (100 + 1000 / (this.verticalRotationSensitivity + 1));
				}
				if (this.lockYaw === false) {
					this._yawAngle += delta.x / (100 + 1000 / (this.horizontalRotationSensitivity + 1));
				}

				if (this._pitchAngle > this.pitchAngle + this._upperPitchLimit) {
					this._pitchAngle = this.pitchAngle + this._upperPitchLimit;
				} else if (this._pitchAngle < this.pitchAngle - this._lowerPitchLimit) {
					this._pitchAngle = this.pitchAngle - this._lowerPitchLimit;
				}

				var roundedValueRightYawLimit = Math.round(this._rightYawLimit * 10000);
				roundedValueRightYawLimit *= 0.0001;
				var roundedValueLeftYawLimit = Math.round(this._leftYawLimit * 10000);
				roundedValueLeftYawLimit *= 0.0001;
				var roundedValuePI = Math.round(Math.PI * 10000);
				roundedValuePI *= 0.0001;

				if (roundedValueRightYawLimit < roundedValuePI || roundedValueLeftYawLimit < roundedValuePI) {
					if (this._yawAngle > this.yawAngle + this._rightYawLimit) {
						this._yawAngle = this.yawAngle + this._rightYawLimit;
					} else if (this._yawAngle < this.yawAngle - this._leftYawLimit) {
						this._yawAngle = this.yawAngle - this._leftYawLimit;
					}
				}

				this._smartCamLocalTimer = 0;
			}
		};

		//###################################################################################################
		//                                          UPDATE FUNCTIONS                                        #
		//###################################################################################################

		ThirdPersonNavigation.prototype.updateGamepadController = function() {
			// This is the GamePad impact on the camera
			var gamePad = EP.Devices.getGamepad();
			if (gamePad === undefined || gamePad === null) {
				return;
			}

			var axis = gamePad.axisValues;
			var invertX = this.invertXAxis ? -1 : 1;
			var invertY = this.invertYAxis ? -1 : 1;
			if (axis[2] > 0.15) {
				this._yawAngle += invertX * (axis[2] - 0.15) * this._deltaTime / (100 + 1000 / (this.horizontalRotationSensitivity + 1));
			}
			if (axis[2] < -0.15) {
				this._yawAngle += invertX * (axis[2] + 0.15) * this._deltaTime / (100 + 1000 / (this.horizontalRotationSensitivity + 1));
			}
			if (axis[3] > 0.15) {
				this._pitchAngle += invertY * (axis[3] - 0.15) * this._deltaTime / (100 + 1000 / (this.verticalRotationSensitivity + 1));
			}
			if (axis[3] < -0.15) {
				this._pitchAngle += invertY * (axis[3] + 0.15) * this._deltaTime / (100 + 1000 / (this.verticalRotationSensitivity + 1));
			}
			if (Math.abs(axis[2]) > 0.15 || Math.abs(axis[3]) > 0.15) {
				this._smartCamLocalTimer = 0;
			}

			if (this._pitchAngle > (Math.PI / 2) - 0.125) {
				this._pitchAngle = (Math.PI / 2) - 0.125;
			}
			if (this._pitchAngle < -Math.PI / 2) {
				this._pitchAngle = -Math.PI / 2;
			}

			if (this._pitchAngle > this.pitchAngle + this._upperPitchLimit) {
				this._pitchAngle = this.pitchAngle + this._upperPitchLimit;
			} else if (this._pitchAngle < this.pitchAngle - this._lowerPitchLimit) {
				this._pitchAngle = this.pitchAngle - this._lowerPitchLimit;
			}

			var roundedValueRightYawLimit = Math.round(this._rightYawLimit * 10000);
			roundedValueRightYawLimit *= 0.0001;
			var roundedValueLeftYawLimit = Math.round(this._leftYawLimit * 10000);
			roundedValueLeftYawLimit *= 0.0001;
			var roundedValuePI = Math.round(Math.PI * 10000);
			roundedValuePI *= 0.0001;

			if (roundedValueRightYawLimit < roundedValuePI || roundedValueLeftYawLimit < roundedValuePI) {
				if (this._yawAngle > this.yawAngle + this._rightYawLimit) {
					this._yawAngle = this.yawAngle + this._rightYawLimit;
				} else if (this._yawAngle < this.yawAngle - this._leftYawLimit) {
					this._yawAngle = this.yawAngle - this._leftYawLimit;
				}
			}

			var gamepad = EP.Devices.getGamepad();
			var gamepadAxisValue = gamepad.getAxisValue(EP.Gamepad.EAxis.eRT);
			var zoomIn = gamepadAxisValue > 0 ? 1 : 0;
			gamepadAxisValue = gamepad.getAxisValue(EP.Gamepad.EAxis.eLT);
			var zoomOut = gamepadAxisValue > 0 ? -1 : 0;

			if (zoomIn !== 0 || zoomOut !== 0) {
				if (this.zoom && this._isCurrentCamera) {
					this._zoom += (zoomOut + zoomIn) * -1 / 20;
					if (this._zoom > 10) {
						this._zoom = 10;
					}
					if (this._zoom < 0.3) {
						this._zoom = 0.3;
					}
					this._smartCamLocalTimer = 0;
				}
			}
		};

		ThirdPersonNavigation.prototype.updateSmartCam = function() {

			if (Math.round(this._yawAngle * 1000) !== Math.round(this.yawAngle * 1000) || Math.round(this._pitchAngle * 1000) !== Math.round(this.pitchAngle * 1000)) {

				if (this.resetMode === ThirdPersonNavigation.eResetMode.eOnTimer) {
					this._smartCamLocalTimer += this._deltaTime;
				} else if (this.resetMode === ThirdPersonNavigation.eResetMode.eOnKeyPress) {
					if (this._smartCamLocalTimer === 0) {
						this._resetKeyPress = false;
					}
					if (this._resetKeyPress === true) {
						this._smartCamLocalTimer += this._deltaTime;
					}
					var keyboard = EP.Devices.getKeyboard();
					if (keyboard.isKeyPressed(this.resetKey)) {
						this._smartCamLocalTimer = this.resetTimer * 1000;
						this._resetKeyPress = true;
					}
				}

				//this._smartCamLocalTimer += this._deltaTime;
				//this._camToInitPos = false;

				if (this._smartCamLocalTimer > this.resetTimer * 1000) {
					var delta = (this._smartCamLocalTimer - this.resetTimer * 1000) / this._smartCamLocalTimer * this._deltaTime / (100 + 1000 / (this.verticalRotationSensitivity + 1));
					this._yawAngle -= (this._yawAngle - this.yawAngle) * delta;
					this._pitchAngle -= (this._pitchAngle - this.pitchAngle) * delta;
					this._zoom = 1;
				}
			} else {

				this._smartCamLocalTimer = 0;
				//this._camToInitPos = true;
				this._resetKeyPress = false;
			}
		};

		ThirdPersonNavigation.prototype.updateAvoidCollision = function() {
			var point = this.getPointWithoutCollisions();
			if (point !== null) {
				var vector = new DSMath.Vector3D();
				vector.x = point.x;
				vector.y = point.y;
				vector.z = point.z;
				this._camera.setPosition(vector);
				this._collisionDetected = true;
			} else {
				this._collisionDetected = false;
			}
		};

		ThirdPersonNavigation.prototype.updateRotation = function(forceUpdate, iInit) {
			var init = (iInit === null || iInit === undefined) ? false : iInit;
			var yaw = 0;
			var frontVector;
			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				frontVector = this._camera.getTransform().matrix.getFirstColumn();
				frontVector.multiplyScalar(-1);
				if (this.lockYaw) {
					yaw = this.getAngleBetweenVectorsInXZ(frontVector, this._lockYawVectorReference);
				} else {
					yaw = this.getAngleBetweenVectorsInXZ(frontVector, this._targetForwardVector);
				}
			} else {
				frontVector = this._camera.getTransform().matrix.getFirstColumn();
				frontVector.multiplyScalar(-1);
				if (this.lockYaw) {
					yaw = this.getAngleBetweenVectorsInXY(frontVector, this._lockYawVectorReference);
				} else {
					yaw = this.getAngleBetweenVectorsInXY(frontVector, this._targetForwardVector);
				}
			}

			//console.log("Yaw: "+yaw);
			var worldZ = new DSMath.Vector3D(0, 0, 1);
			var worldY = new DSMath.Vector3D(0, 1, 0);

			//console.log(yaw);
			if (this._yawAngle < -Math.PI && yaw > 0) {
				this._yawAngle += 2 * Math.PI;
			}
			if (this._yawAngle > Math.PI && yaw < 0) {
				this._yawAngle -= 2 * Math.PI;
			}

			yaw -= this._yawAngle;

			var timeCoef = this._deltaTime / (1 + this.rotationSmoothness * 100);
			if (timeCoef > 1) {
				timeCoef = 1;
			}
			if (forceUpdate === true) {
				timeCoef = 1;
			}

			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				if (this.lockYaw === false || init === true) {
					this._camera.rotateAround(this._targetTransform.vector.clone(), worldY, yaw * timeCoef);
				}
			} else {
				//console.log(this.lockYaw);
				if (this.lockYaw === false || init === true) {
					this._camera.rotateAround(this._targetTransform.vector.clone(), worldZ, yaw * timeCoef);
				}
			}


			yaw += this._yawAngle;

			var quat = new DSMath.Quaternion();
			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				quat.makeRotation(worldY, yaw);
			} else {
				quat.makeRotation(worldZ, yaw);
			}

			var idealPoint = frontVector.applyQuaternion(quat);
			var idealVector = new DSMath.Vector3D();
			idealVector.set(idealPoint.x, idealPoint.y, idealPoint.z);
			var targetForward = this._targetForwardVector.clone();

			var pitch = this.getAngleBetweenVectors(idealVector, targetForward);

			var frontVector = this._camera.getTransform().matrix.getFirstColumn();
			frontVector.multiplyScalar(-1);
			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				frontVector.y = 0;
			} else {
				frontVector.z = 0;
			}
			frontVector.normalize();

			var vectorY;
			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				vectorY = DSMath.Vector3D.cross(frontVector, worldY);
			} else {
				vectorY = DSMath.Vector3D.cross(frontVector, worldZ);
			}

			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				if (idealVector.y > targetForward.y) {
					pitch = -pitch;
				}
			} else {
				if (idealVector.z > targetForward.z) {
					pitch = -pitch;
				}
			}
			pitch -= this._pitchAngle;

			if (this.lockPitch === false || init === true) {
				this._camera.rotateAround(this._targetTransform.vector.clone(), vectorY, pitch * timeCoef);
			}
		};

		ThirdPersonNavigation.prototype.updateOrientation = function() {
			var frontVector = this._camera.getTransform().matrix.getFirstColumn();
			var newTransform = this._camera.getTransform();

			if (this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZNegative || this.targetDirectionAxis === ThirdPersonNavigation.eAxis.eZPositive) {
				var frontWithoutZ = frontVector.clone();
				frontWithoutZ.multiplyScalar(-1);
				frontWithoutZ.y = 0;
				frontWithoutZ.normalize();

				var worldZ = new DSMath.Vector3D(0, 1, 0);
				var vectorY = DSMath.Vector3D.cross(frontWithoutZ, worldZ);
				var vectorZ = DSMath.Vector3D.cross(frontVector, vectorY);

				//console.log(vectorY);

				newTransform.matrix.setFromArray([frontVector.x, vectorY.x, vectorZ.x,
					frontVector.y, vectorY.y, vectorZ.y,
					frontVector.z, vectorY.z, vectorZ.z
				]);
			} else {
				var frontWithoutZ = frontVector.clone();
				frontWithoutZ.multiplyScalar(-1);
				frontWithoutZ.z = 0;
				frontWithoutZ.normalize();

				var worldZ = new DSMath.Vector3D(0, 0, 1);
				var vectorY = DSMath.Vector3D.cross(frontWithoutZ, worldZ);
				var vectorZ = DSMath.Vector3D.cross(frontVector, vectorY);

				newTransform.matrix.setFromArray([frontVector.x, vectorY.x, vectorZ.x,
					frontVector.y, vectorY.y, vectorZ.y,
					frontVector.z, vectorY.z, vectorZ.z
				]);
			}


			/*var worldZ = new DSMath.Vector3D(0, 0, 1);
			var worldY = new DSMath.Vector3D(0, 1, 0);

			var vectorY = DSMath.Vector3D.cross(frontWithoutZ, worldZ);
			var vectorZ = DSMath.Vector3D.cross(frontVector, vectorY);*/

			//var newTransform = this._camera.getTransform();

			this._camera.setTransform(newTransform);
		};

		ThirdPersonNavigation.prototype.updateFollowingDistance = function() {
			var currentDistanceToObject = this.DistanceToPosition(this._targetTransform.vector.clone());
			//var currentDistanceToObject = this.DistanceToPosition(this.target.getPosition().clone());

			var postDistanceToObject = currentDistanceToObject + this._distanceDiff;
			var relativeDistance = postDistanceToObject - this._keepAtDistanceZoom;
			var timeCoef = this._deltaTime / (1 + this.translationSmoothness * 1000);
			if (timeCoef > 1) {
				timeCoef = 1;
			}
			postDistanceToObject -= relativeDistance * timeCoef;
			if (postDistanceToObject > this._keepAtDistanceZoom + this._keepAtDistanceTolerance) {
				postDistanceToObject -= (postDistanceToObject - (this._keepAtDistanceZoom + this._keepAtDistanceTolerance)) * timeCoef;
			}
			//var distance = postDistanceToObject - currentDistanceToObject;

			var distance;
			//[IR-459937] To avoid dezoom when changing target
			if (this._resetCameraTransform) {
				distance = -relativeDistance;
				this._resetCameraTransform = false;
			} else {
				distance = postDistanceToObject - currentDistanceToObject;
			}

			var frontVector = this._camera.getTransform().matrix.getFirstColumn();
			frontVector.normalize();
			frontVector.multiplyScalar(distance);
			this._camera.translate(frontVector);
			//console.log('DIST: ' + currentDistanceToObject + '  Distance next: ' + distance + ' and ' + postDistanceToObject);
		};

		ThirdPersonNavigation.prototype.getPointWithoutCollisions = function() {
			//var theoricalRadius = 350; //Supposed radius of the camera
			var cameraOffset = this._camera.nearClip;

			var clickable = this.target.clickable;
			if (clickable) {
				this.target.setClickable(false);
			}

			var dest = this._camera.getPosition();
			var origin = this._targetTransform.vector.clone();
			var direction = dest.sub(origin);

			var length = direction.norm();
			direction.normalize();
			var ray = new STU.Ray();
			ray.origin.x = origin.x;
			ray.origin.y = origin.y;
			ray.origin.z = origin.z;
			ray.direction.x = direction.x;
			ray.direction.y = direction.y;
			ray.direction.z = direction.z;
			ray.length = length + (cameraOffset * 2);

			var renderManager = STU.RenderManager.getInstance();
			//var intersectArray = renderManager._pickFromRay(ray);

			var intersectArray, sceneTransform;
			//intersectArray = renderManager._pickFromRay(ray);
			var myLocation = this.actor.getLocation();
			if (myLocation === null || myLocation === undefined) { //Here we are in a globe environnement
				intersectArray = renderManager._pickFromRay(ray);
			} else {
				intersectArray = renderManager._pickFromRay(ray, true, false, myLocation);
			}

			if (clickable) {
				this.target.setClickable(true);
			}

			if (intersectArray.length > 0) {
				var hitPoint = intersectArray[intersectArray.length - 1].getPoint();
				//var normal = intersectArray[intersectArray.length - 1].getNormal();
				var vectorPos = new DSMath.Vector3D(hitPoint.x, hitPoint.y, hitPoint.z);
				vectorPos.sub(direction.clone().multiplyScalar(cameraOffset));
				var point = new DSMath.Point(vectorPos.x, vectorPos.y, vectorPos.z);
				return point;

			} else {
				return null;
			}
		};

		ThirdPersonNavigation.prototype.degToRad = function(iDeg) {
			return iDeg * (Math.PI / 180);
		};

		ThirdPersonNavigation.prototype.manageOffset = function() {
			var offsetEasingDuration = 3;
			if (!this._settedOffset.isEqual(this.offset, 5)) {
				this._offsetTimer += this._deltaTime * 0.001;
				if (this._offsetTimer > offsetEasingDuration) {
					this._offsetTimer = offsetEasingDuration;
				}
				this._settedOffset = DSMath.Vector3D.lerp(this._settedOffset, this.offset, this._offsetTimer / offsetEasingDuration);
				this._isSettingOffset = true;
			} else {
				this._offsetTimer = 0;
				this._settedOffset = this.offset.clone();
				this._isSettingOffset = false;
			}
		};

		/**
		 * Reset the camera to it's initial Yaw and pitch orientation
		 *
		 * @method
		 * @public
		 */
		ThirdPersonNavigation.prototype.reset = function() {
			this._yawAngle = this.yawAngle;
			this._pitchAngle = this.pitchAngle;
		};

		STU.ThirdPersonNavigation = ThirdPersonNavigation;
		return ThirdPersonNavigation;

	});

define('StuMiscContent/StuThirdPersonNavigation', ['DS/StuMiscContent/StuThirdPersonNavigation'], function (ThirdPersonNavigation) {
	'use strict';

	return ThirdPersonNavigation;
});

define('DS/StuMiscContent/StuBoatController',
    ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent',
        'MathematicsES/MathsDef', 'DS/EPInputs/EPKeyboard', 'DS/EPInputs/EPDevices'],
    function (STU, EP, Behavior, Task, EventServices, Event, DSMath) {
        'use strict';

        var BoatControllerTask = function (iComp) {
            Task.call(this);
            this.comp = iComp;
        };

        BoatControllerTask.prototype = new Task();
        BoatControllerTask.prototype.constructor = BoatControllerTask;

        /**
         * This event is thrown when the boat has reached the end of a path
         *
         * @class 
         * @constructor
         * @noinstancector
         * @public
         * @extends EP.Event
         * @memberof STU
         */
        var BoatHasCompletedEvent = function (iPath, iActor) {
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

        BoatHasCompletedEvent.prototype = new Event();
        BoatHasCompletedEvent.prototype.constructor = BoatHasCompletedEvent;
        BoatHasCompletedEvent.prototype.type = 'BoatHasCompletedEvent';

        // Expose in STU namespace.
        STU.BoatHasCompletedEvent = BoatHasCompletedEvent;
        EP.EventServices.registerEvent(BoatHasCompletedEvent);

        /**
         * This event is thrown when a actor has reached a target
         *
         * @class 
         * @constructor
         * @noinstancector
         * @public
         * @extends EP.Event
         * @memberof STU
         */
        var BoatHasReachedEvent = function (iTarget, iActor) {
            Event.call(this);

            /**
             * The target that has been reached by the actor
             * 
             * @type {STU.Actor}
             * @default
             * @public
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

        BoatHasReachedEvent.prototype = new Event();
        BoatHasReachedEvent.prototype.constructor = BoatHasReachedEvent;
        BoatHasReachedEvent.prototype.type = 'BoatHasReachedEvent';

        // Expose in STU namespace
        STU.BoatHasReachedEvent = BoatHasReachedEvent;
        EventServices.registerEvent(BoatHasReachedEvent);

        /**
         * Method called each frame by the task manager
         *
         * @method
         * @private
         * @param  iExContext Execution context
         */
        BoatControllerTask.prototype.onExecute = function (iExContext) {
            if ('executeOneFrame' in this.comp) {
                this.comp.executeOneFrame(iExContext);
            }
        };

        BoatControllerTask.prototype.onStart = function () {
            if ('initializeDevices' in this.comp) {
                this.comp.initializeDevices();
            }
        };

        /**
         * Behavior that permit to an actor to act simulate a boat.
         *
         * @exports BoatController
         * @class 
         * @constructor
         * @noinstancector
         * @public
         * @extends {STU.Behavior}
         * @memberOf STU
         * @alias STU.BoatController
         */
        var BoatController = function () {
            Behavior.call(this);
            this.name = 'BoatController';
            this.associatedTask;

            //public

            /**
             * The boat's maximum speed (km/h)
             * @member
             * @public
             * @type {Number}
             */
            this.maximumSpeed = 25;
            this._maximumSpeed = 25;
            Object.defineProperty(this, 'maximumSpeed', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._maximumSpeed;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value > 0) {
                            this._maximumSpeed = value;
                            this._speed = value * 1000;
                        } else {
                            console.error("Maximum Speed value should be greater to 0");
                        }
                    }
                }
            });

            /**
             * The vertical distance between the waterline and the bottom of the hull (m)
             * @member
             * @public
             * @type {Number}
             */
            this.draft = 500; //500mm
            this._draft = 500;
            this._draftInMeter = 0.5;
            Object.defineProperty(this, 'draft', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._draftInMeter;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value > 0) {
                            this._draftInMeter = value;
                        } else {
                            console.error("Draft value should be greater to 0");
                        }
                    }
                }
            });

            /**
             * The inertia coefficient applied on the boat's movements
             * @member
             * @public
             * @type {Number}
             */
            this.inertiaFactor = 1.0;
            this._inertiaFactor = 1.0;
            Object.defineProperty(this, 'inertiaFactor', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._inertiaFactor;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value > 0) {
                            this._inertiaFactor = value;
                        } else {
                            console.error("Inertia Factor value should be greater to 0");
                        }
                    }
                }
            });

            /**
             * If set to true the boat's front vector will be computed automatically according to its dimensions
             *
             * @member
             * @public
             * @type {Boolean}
             */
            this.computeDirectionAxis = true;

            /**
             * Correspond to the vector that will be used as the boat's front vector 
             *
             * @member
             * @public
             * @type {STU.BoatController.eAxis}
             */
            this.directionAxis = 0;

            /**
             * If True the buoyancy of the boat will be compute according to the draft parameter, if false the buoyancy will be compute in function of the boat's mass and its volume 
             *
             * @member
             * @private
             * @type {Boolean}
             */
            this.useDraft = true; //TO DELETE

            /**
             * If True, the behavior will simulate the pitching of the boat on the water. 
             * If false, the behavior will incline the boat according to the ground orientation.
             *
             * @member
             * @public
             * @type {Boolean}
             */
            this.simulateWaves = false;

            /**
             * The boat's mass (kg)
             *
             * @member
             * @private
             * @type {Number}
             */
            this.mass = 1000; //TO DELETE

            /**
             * The time needed to the boat for reaching its maxSpeed from 0 (s)
             *
             * @member
             * @public
             * @type {Number}
             */
            this.acceleration = 5;
            this._acceleration = 5;
            Object.defineProperty(this, 'acceleration', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._acceleration;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value > 0) {
                            this._acceleration = value;
                        } else {
                            console.error("Acceleration value should be greater to 0");
                        }
                    }
                }
            });

            /**
             * The time needed to the boat for reaching a null speed from its maxSpeed (s)
             *
             * @member
             * @private
             * @type {Number}
             */
            this.deceleration = 5; //TO DELETE

            /**
             * The boat's maximum angular speed (rad/s)
             *
             * @member
             * @public
             * @type {Number}
             */
            this.angularSpeed = 0.3;
            this._angularSpeed = 0.3;
            Object.defineProperty(this, 'angularSpeed', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._angularSpeed;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value > 0) {
                            this._angularSpeed = value;
                            //stockage unit : turn/min
                            //this._angularSpeed = (Math.abs(value) * 2 * Math.PI) / 60;
                        } else {
                            console.error("Angular Speed value should be greater to 0");
                        }
                    }
                }
            });



            /**
             * The time needed to the boat for reaching its maximum angular speed from 0 (s)
             *
             * @member
             * @private
             * @type {Number}
             */
            this.angularAcceleration = 3; //TO DELETE

            /**
             * The time needed to the boat for reaching a null angular speed from its its maximum angular speed (s)
             *
             * @member
             * @private
             * @type {Number}
             */
            this.angularDeceleration = 3; //TO DELETE

            /**
             * The value which will determine how the boat will stick to the curve despite of it's parameters
             *
             * @member
             * @public
             * @type {Number}
             */
            this.stickCoefficient = 0;
            this._stickCoefficient = 0;
            Object.defineProperty(this, 'stickCoefficient', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._stickCoefficient;
                },
                set: function (value) {
                    if (value !== undefined && value !== null) {
                        if (value >= 0 && value <= 1) {
                            this._stickCoefficient = value;
                            //stockage unit : turn/min
                            //this._angularSpeed = (Math.abs(value) * 2 * Math.PI) / 60;
                        } else {
                            console.error("Stick Coefficient value should be between 0 and 1");
                        }
                    }
                }
            });

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
             * Mapped key for turning left
             *
             * @member
             * @public
             * @type {EP.Keyboard.EKey}
             */
            this.turnLeft = EP.Keyboard.EKey.eLeft;

            /**
             * Mapped key for turning right
             *
             * @member
             * @public
             * @type {EP.Keyboard.EKey}
             */
            this.turnRight = EP.Keyboard.EKey.eRight;

            //###########################################################
            //                                                         ##
            //                          PRIVATE                        ##
            //                      global Settings                    ##
            //                                                         ##
            //###########################################################

            /**
             * Temp variables, for debug purpose 
             *
             * @member
             * @private
             * @type {Boolean}
             */
            this._useGlobeSystem = false;

            /**
             * Temp variables, for debug purpose 
             *
             * @member
             * @private
             * @type {Boolean}
             */
            this._enableVisualDebug = false;

            /*
            * The boat actor 
            * @type {STU.Actor3D}
            */
            this._actor = null;

            /*
            * The gravity vector 
            * @type {DSMath.Vector3D}
            */
            this._gravity = null;

            /*
            * The boat mass 
            * @type {Number}
            */
            this._mass = 1000; //TO DELETE

            /*
            * Water density value (kg/m3)
            * @type {Number}
            */
            this._water_mass = 1000; //1000 kg/m3

            /*
            * Boat's hull material density value (kg/m3)
            * @type {Number}
            */
            this._raw_mass = 2.7; //2700 kg/m3

            //actor's properties
            this._bbox = 0;
            this._width = 0;
            this._length = 0;
            this._height = 0;
            this._volume = 0;
            this._center = null;
            this._centerOffset = null;
            this._actorTransform = null;
            this._actorPosition = null;
            this._xExtremity = null;
            this._yExtremity = null;
            this._zExtremity = null;

            //referencial
            this._worldFront = null;
            this._worldRight = null;
            this._worldUp = null;
            this._localUp = null;
            this._localFront = null;
            this._localRight = null;
            this._scale = null;
            this._frontVector = null;

            //input
            this._keyboard = null;
            this._gamepad = null;

            //Raycast
            this._lastFrontIntersection = null;
            this._lastBackIntersection = null;
            this._lastRightIntersection = null;
            this._lastLeftIntersection = null;

            //speed Management
            this._speedDirection = null;
            this._currentSpeed = 0;
            this._speed = 0; //km/h

            this._currentSpeedBack = 0;
            this._currentSpeedFront = 0;
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
            this._timeNeededToReachMaxDecceleration = 5; //5 sec

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
             * ratio currentSpeed / maximumSpeed
             * @private
             * @type {Number}
             */
            this._power = 0;

            /**
             * Value representing the maximum angle of the boat's inclinaison when a wave comes from the front
             * Expressed in radian
             * @private
             * @type {Number}
             */
            this._frontWaveRotationFactor = 0.010;

            /**
             * Value representing the maximum angle of the boat's inclinaison when a wave comes from the side
             * Expressed in radian
             * @private
             * @type {Number}
             */
            this._sideWaveRotationFactor = 0.005;

            /**
             * Speed of the wave simulation
             * @private
             * @type {Number}
             */
            this._waveSpeedCoefficient = 1;

            //Rotation management
            this._currentAngularAcceleration = 0;
            this._currentAngularInertia = 0;
            this._angularSpeed = 2.86478898; //tr/min
            this._isAccelerating = false;

            this._inertiaStartValue = 0;
            this._accelerationOrientation = 1;
            this._inertieOrientation = 1;

            this._oldAxisValue = null;
            this._tAcceleration = 0;

            //Water Management
            this._previous_water_info = null;
            this._isWaterVariationTooImportant = false;

            //Capacities variables 
            this._isOnGoToState = false;
            this._isOnFollowPathState = false;

            //Goto Capacity
            this._target = null;
            this._targetReached = false;

            //FollowPath capacity
            this._pathLength = null;
            this._currentDistanceFollowPath = 0;
            this._targets = null;
            this._currentTarget = null;
            this._endTarget = null;
            this._currentTargetIndex = 0;
            this._targetedPath = null;
            this._pathCompleted = false;

            this._currentTimeWaveOrientationSimulation = 0;
            this._currentTimeWaveHeightSimulation = 0;

            this._elapsedFrame = 0; // Because the first frame is longer and cause several issue, we use this variable to skip the first frame.
            this._gravityAccel = null;

            //Debug
            this._debug = true;
            this._scaleSystem = 1; //0: option user relative    1: Globe Relative
            this._globeLocation = null;
        };

        BoatController.prototype = new Behavior();
        BoatController.prototype.constructor = BoatController;
        //BoatController.prototype.pureRuntimeAttributes = ['_zoom'].concat(Behavior.prototype.pureRuntimeAttributes);

        /**
         * An enumeration of all the supported direction axis.<br/>
         * It allows to refer in the code to a specific key.
         *
         * @enum {number}
         * @public
         */
        BoatController.eAxis = {
            eXPositive: 0,
            eXNegative: 1,
            eYPositive: 2,
            eYNegative: 3,
            eZPositive: 4,
            eZNegative: 5,
        };

        /**
         * Process executed when STU.BoatController is activating
         *
         * @method
         * @private
         */
        BoatController.prototype.onActivate = function () {
            Behavior.prototype.onActivate.call(this);
            this.associatedTask = new BoatControllerTask(this);
            EP.TaskPlayer.addTask(this.associatedTask);

            //this._keyboard = EP.Devices.getKeyboard();
            //this._gamepad = EP.Devices.getGamepad();
            this._actor = this.getActor();
            this._actorTransform = this._actor.getTransform();
            this._globeLocation = this._actor.getLocation();

            this._gravity = new DSMath.Vector3D();
            //this._gravity.set(0, 0, -9.81);
            this._gravity.set(0, 0, -9.81 * 1000);

            this._gravityAccel = new DSMath.Vector3D(0, 0, 0);

            this._worldUp = new DSMath.Vector3D(0, 0, 1);
            this._worldFront = new DSMath.Vector3D(0, 1, 0);
            this._worldRight = new DSMath.Vector3D(1, 0, 0);

            this._localRight = this._actorTransform.matrix.getFirstColumn().normalize();
            this._localFront = this._actorTransform.matrix.getSecondColumn().normalize();
            this._localUp = this._actorTransform.matrix.getThirdColumn().normalize();

            this._scale = this._actor.getScale();
            //this._mass = this.mass * 0.1;

            //this._speed = this.maximumSpeed * this._scale * 277.777778; // km/h to mm/s;
            this._speed = this.maximumSpeed * 1000 * this._scale; // m/s to mm/s;
            this._speedDirection = new DSMath.Vector3D(0, 0, 0);

            //acceleration stockee en m.s-2 --> Need mm.s-2
            //var accel = this._acceleration * 1000;

            this._draftInMeter = this.draft * 0.001;

            /*if (this._debug) {
                console.log("maximumSpeed: " + this._speed + "mm/s");
                console.log("acceleration: " + accel + "mm/s.-2");
            }*/

            //stockage unit : turn/min
            //this._angularSpeed = (Math.abs(this.angularSpeed) * 2 * Math.PI) / 60; // this.angularSpeed;

            this._debug = this._enableVisualDebug;
            this._scaleSystem = this._useGlobeSystem ? 1 : 0;

            this.computeSize();
        };

        /**
         * Process executed when STU.BoatController is deactivating
         *
         * @method
         * @private
         */
        BoatController.prototype.onDeactivate = function () {
            EP.TaskPlayer.removeTask(this.associatedTask);
            delete this.associatedTask;

            Behavior.prototype.onDeactivate.call(this);
        };

        /**
         * Update method called each frames
         *
         * @method
         * @private
         * @param   {Number} iElapsedTime Time elapsed since last frame
         */
        BoatController.prototype.executeOneFrame = function (iDelta) {
            if (!this._firstFrameSkiped) {
                this._firstFrameSkiped = true;
                return;
            }

            var keyboard = EP.Devices.getKeyboard();
            if (keyboard.isKeyPressed(EP.Keyboard.EKey.eA) && this._debug) {
                console.log("CurrentSpeed:" + this._currentSpeed);
                console.log("Ratio:" + this._power);
            }
            //=================== ( Settings ) =====================//
            var deltaTime = iDelta.deltaTime * 0.001;
            this._actorTransform = this._actor.getTransform();
            this._actorPosition = this._actor.getPosition();
            this.computeDirectionVectors();

            var appliedForce = new DSMath.Vector3D(0, 0, 0);
            //=================== ( Settings ) =====================//

            //================== ( Water Info ) ====================//

            if (!this.simulateWaves) {
                var waterInfo = this.detectWater();
                /*if (this._previous_water_info !== null && this._previous_water_info !== undefined) {
                    if (waterInfo === null) {
                        waterInfo = this._previous_water_info;
                    }
                }

                if (waterInfo !== null) {
                    if (this._previous_water_info === undefined || this._previous_water_info === null) {
                        this._previous_water_info = waterInfo;
                    }
                    this._isWaterVariationTooImportant = Math.abs(waterInfo.waterHeight.z - this._previous_water_info.waterHeight.z) > 0.5;
                    if (!this._isWaterVariationTooImportant) {
                        this._previous_water_info = waterInfo;
                    }
                    else {
                        //console.warn("Avoiding high water variation");
                        waterInfo = this._previous_water_info;
                    }
                }*/

                var waveInfo = null;
                if (waterInfo !== null && waterInfo !== undefined) {
                    waveInfo = this.isOnWater(waterInfo.waterHeight);
                    if (waveInfo !== null && waterInfo !== undefined) {
                        if (!this.simulateWaves && waveInfo.isOnWater) {
                            this.computeMatrix(waterInfo.sideDirection, waterInfo.frontDirection, waterInfo.upDirection);
                        }

                        var currentGravity = this.computeBuoyancy(deltaTime, waveInfo);
                        appliedForce.add(currentGravity);

                        if (!waveInfo.isOnWater) {
                            this._gravityAccel.add(this._gravity);
                            this._gravityAccel.multiplyScalar(deltaTime);
                            appliedForce.add(this._gravityAccel);
                        }
                        else {
                            this._gravityAccel = new DSMath.Vector3D(0, 0, 0);
                        }
                    }
                }
            }

            if (this.simulateWaves) {
                this.updateSimulateWaveOrientation(deltaTime);
            }

            //Keyboard/Gamepad Control
            if (!this._isOnSailsToState && !this._isOnFollowTrajectoryState) {
                var currentSpeedDirection;
                if (waterInfo !== null && waterInfo !== undefined) {
                    currentSpeedDirection = this.computeVitesse(deltaTime, waveInfo.isOnWater);
                }
                else {
                    currentSpeedDirection = this.computeVitesse(deltaTime, true);
                }
                currentSpeedDirection.multiplyScalar(deltaTime);
                appliedForce.add(currentSpeedDirection);
                this.computeRotation(deltaTime);
            }
            else {
                if (this._isOnSailsToState) {
                    this.updateSailsTo(this._target.getPosition(), deltaTime);
                }
                else if (this._isOnFollowTrajectoryState) {
                    this.updateFollowTrajectory(this._targetedPath, deltaTime);
                }
            }

            this._actor.translate(appliedForce);
        };

        /*
         * Called after build
         */
        BoatController.prototype.initializeDevices = function () {
            this._keyboard = EP.Devices.getKeyboard();
            this._gamepad = EP.Devices.getGamepad();
        };

        //*******************************{ SPEED MANAGEMENT }****************************//

        /**
         * Manage the boat's speed according to the keyboard or gamepad input
         * @method
         * @private
         */
        BoatController.prototype.computeVitesse = function (iDeltaTime, iIsOnWater) {
            var axisValue;
            this._speedDirection = this._localFront;
            //Keyboard/Gamepad Control
            if (!this._isOnGoToState & !this._isOnFollowPathState) {
                if (this.useGamePad) {
                    axisValue = this._gamepad.getAxisValue(EP.Gamepad.EAxis.eLSY);
                }
                else {
                    //Pas d'input manette 
                    axisValue = this._keyboard.isKeyPressed(this.moveForward) ? 1 : this._keyboard.isKeyPressed(this.moveBackward) ? -1 : 0;
                }
            }
            else {
                if (this._isOnGoToState) {
                    var distance = DSMath.Vector3D.sub(this._actorPosition, this._target.getPosition());
                    var minDistance = this._acceleration * this._speed * 0.5 * (this._currentSpeed / this._speed);
                    var distanceTolerance = 5;

                    distanceTolerance *= 1000;
                    axisValue = (distance.norm() > minDistance + 5000) ? 1 : 0;
                }
                else {

                }
            }
            return this.speedComputation(iDeltaTime, axisValue, iIsOnWater);
        };

        /**
         * Manage the boat's speed
         * @method
         * @private
         */
        BoatController.prototype.speedComputation = function (iDeltaTime, iAxisValue, iIsOnWater) {
            var speed = 0;
            if (iIsOnWater) {
                if (iAxisValue > 0) {
                    speed = this.accelerate(iDeltaTime, iAxisValue);
                }
                else if (iAxisValue < 0) {
                    speed = this.accelerate(iDeltaTime, iAxisValue);
                }
                else {
                    speed = this.decelerate(iDeltaTime, true, true, 1.23); //frottement pris en compte
                }
            }
            else {
                speed = this.decelerate(iDeltaTime, true, true, 1); //frottement negligeable
            }

            this._power = speed / this._speed;
            var speedVector = this._localFront.clone().normalize();
            speedVector.multiplyScalar(speed);//speedVector.multiplyScalar(this._currentSpeed);
            return speedVector;
        };

        /**
         * Increase the boat's speed
         * @method
         * @private
         */
        BoatController.prototype.accelerate = function (iDeltaTime, iAxisValue, iCoeff) {
            if (iCoeff === null || iCoeff === undefined) {
                iCoeff = 1;
            }
            //acceleration stockee en m.s-2 --> Need mm.s-2
            var accel = this._acceleration * 1000;
            if (iAxisValue > 0) {
                this._currentSpeedFront += (accel * iDeltaTime * (1 / this._inertiaFactor)) * iCoeff;
                if (this._currentSpeedFront > this._speed) {
                    this._currentSpeedFront = this._speed;
                }
                //this._currentSpeedFront -= (this._acceleration * iDeltaTime * (1 / this._inertiaFactor)) * iCoeff;
                this.decelerate(iDeltaTime, false, true, 2.0);
            }
            else if (iAxisValue < 0) {
                this._currentSpeedBack += (accel * iDeltaTime * (1 / this._inertiaFactor)) * iCoeff;
                if (this._currentSpeedBack > this._speed) {
                    this._currentSpeedBack = this._speed;
                }

                this.decelerate(iDeltaTime, true, false, 2.0);
            }

            var resultSpeed = this._currentSpeedFront - this._currentSpeedBack;
            this._currentSpeed = resultSpeed;

            this._power = this._currentSpeed / this._speed;

            return resultSpeed;
        };

        /**
         * Decrease the boat's speed
         * @method
         * @private
         */
        BoatController.prototype.decelerate = function (iDeltaTime, iFront, iBack, iCoeff) {
            if (iCoeff === null || iCoeff === undefined) {
                iCoeff = 1;
            }
            //acceleration stockee en m.s-2 --> Need mm.s-2
            var accel = this._acceleration * 1000;
            if (iFront) {
                this._currentSpeedFront -= (accel * iDeltaTime * (1 / this._inertiaFactor)) * iCoeff;
                if (this._currentSpeedFront < 0) {
                    this._currentSpeedFront = 0;
                }
            }

            if (iBack) {
                this._currentSpeedBack -= (accel * iDeltaTime * (1 / this._inertiaFactor)) * iCoeff;
                if (this._currentSpeedBack < 0) {
                    this._currentSpeedBack = 0;
                }
            }
            //this._currentSpeed -= this._acceleration * iDeltaTime * (1 / this._inertiaFactor);
            var resultSpeed = this._currentSpeedFront - this._currentSpeedBack;
            this._currentSpeed = resultSpeed;

            this._power = this._currentSpeed / this._speed;

            return resultSpeed;
        };

        //*******************************{ ROTATION MANAGEMENT }****************************//

        BoatController.prototype.computeRotation = function (iDeltaTime) {
            var frontOffset = DSMath.Vector3D.multiplyScalar(this._localFront, this._width * 0.5);
            var rotationPivotPosition = DSMath.Vector3D.add(this._actorPosition, frontOffset.multiplyScalar(0.75));

            var axisValue = 0;
            if (this.useGamePad) {
                axisValue = this._gamepad.getAxisValue(EP.Gamepad.EAxis.eRSX) * -1;
                if (axisValue > 0.05) { axisValue = 1; }
                else if (axisValue < -0.05) { axisValue = -1; }
            }
            else {
                axisValue = (this._keyboard.isKeyPressed(this.turnLeft)) ? 1 : (this._keyboard.isKeyPressed(this.turnRight)) ? -1 : 0;
            }

            //var axisValue = gamepad.getAxisValue(EP.Gamepad.EAxis.eRSX);
            //  if(axisValue == 0)//PAs d'input manette dtectÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©
            //    axisValue = (keyboard.isKeyPressed(EP.Keyboard.EKey.eLeft)) ? 1 : (keyboard.isKeyPressed(EP.Keyboard.EKey.eRight)) ? -1 : 0;

            var timeToMax = this.angularAcceleration;
            var timeToMin = this.angularDeceleration;
            var maxAngular = this._angularSpeed;
            //var actorPosition = actor.getPosition();
            //var upVector = actor.getTransform().matrix.getThirdColumn().normalize();

            var finalRotation = 0;

            if (axisValue !== 0) {
                if (this._oldAxisValue === undefined) {
                    this._oldAxisValue = axisValue;
                }
                this._isAccelerating = (axisValue === this._oldAxisValue) ? true : false;
                if (this._isAccelerating) {
                    if (timeToMax > 0) {
                        this._tAcceleration += iDeltaTime / this._inertiaFactor;
                        this._tAcceleration = this._tAcceleration > timeToMax ? timeToMax : this._tAcceleration;
                        this._currentAngularAcceleration = this.easeInQuad(this._tAcceleration, 0, maxAngular, timeToMax) * axisValue;
                    }
                    else {
                        this._currentAngularAcceleration = maxAngular;
                    }
                    this._oldAxisValue = axisValue;
                }
                else {
                    this._tAcceleration -= (iDeltaTime * 2) / this._inertiaFactor;
                    this._tAcceleration = this._tAcceleration < 0 ? 0 : this._tAcceleration;

                    if (this._oldAxisValue !== undefined) {
                        this._currentAngularAcceleration = this.easeInQuad(this._tAcceleration, 0, maxAngular, timeToMax) * this._oldAxisValue;
                    }
                    if (this._currentAngularAcceleration === 0) {
                        this._oldAxisValue = axisValue;
                    }
                }
            }
            else {
                this._tAcceleration -= iDeltaTime * (timeToMax / timeToMin) * (1 / this._inertiaFactor);
                this._tAcceleration = this._tAcceleration < 0 ? 0 : this._tAcceleration;
                if (this._oldAxisValue !== undefined) {
                    this._currentAngularAcceleration = this.easeInQuad(this._tAcceleration, 0, maxAngular, timeToMax) * this._oldAxisValue;
                }
            }

            finalRotation = this._currentAngularAcceleration + this._currentAngularInertia;

            this.rotateAround(this._actor, rotationPivotPosition, this._localUp, finalRotation * iDeltaTime);

            var transfoRotation = this.pointRotateAround(this._centerOffset, this._actor.getPosition().clone(), this._localUp, finalRotation * iDeltaTime);
            this._centerOffset = this._centerOffset.applyTransformation(transfoRotation);
        };

        //*******************************{ WATER DETECTION }****************************//

        /**
         * Detect if there is a ground in front, back, left and right of the boat
         * @method
         * @private
         */
        BoatController.prototype.detectWater = function () {
            var upOffset = DSMath.Vector3D.multiplyScalar(this._worldUp, 500);
            var frontOffset = DSMath.Vector3D.multiplyScalar(this._localFront, this._length * 0.3);
            var rightOffset = DSMath.Vector3D.multiplyScalar(this._localRight, this._width * 0.3);
            var leftOffset = DSMath.Vector3D.multiplyScalar(this._localRight, this._width * -0.3);

            var initPosition = DSMath.Vector3D.add(this._actorTransform.vector, this._centerOffset);

            var frontRayPosition = DSMath.Vector3D.add(initPosition, frontOffset);
            frontRayPosition.add(upOffset);

            //this.drawSphere(frontRayPosition, 0.4, 5);
            var rightRayPosition = DSMath.Vector3D.add(initPosition, rightOffset);
            rightRayPosition.add(upOffset);
            rightRayPosition.add(frontOffset.clone().negate());
            //this.drawSphere(rightRayPosition, 0.4, 5);
            var leftRayPosition = DSMath.Vector3D.add(initPosition, leftOffset);
            leftRayPosition.add(upOffset);
            leftRayPosition.add(frontOffset.clone().negate());
            //this.drawSphere(leftRayPosition, 0.4, 5);

            var clickableState = this._actor.clickable;
            this._actor.clickable = false; //To exclude the object from the raycast
            var intersectFront = this.getFirstDownIntersectPoint(frontRayPosition);
            var intersectRight = this.getFirstDownIntersectPoint(rightRayPosition);
            var intersectLeft = this.getFirstDownIntersectPoint(leftRayPosition);
            this._actor.clickable = clickableState;

            if (this._debug) {
                if (intersectFront.point !== null) { this.drawSphere(frontRayPosition, 0.5 * 1000 * this._scale); }
                if (intersectRight.point !== null) { this.drawSphere(rightRayPosition, 0.5 * 1000 * this._scale, 2); }
                if (intersectLeft.point !== null) { this.drawSphere(leftRayPosition, 0.5 * 1000 * this._scale, 2); }
            }

            var waterInfo = this.getWaterInformation(intersectFront, intersectRight, intersectLeft);
            return waterInfo;
        };

        BoatController.prototype.getWaterInformation = function (iFrontIntersection, iRightIntersection, iLeftIntersection) {
            var ptFront, ptRight, ptLeft;
            var newPtFront = new DSMath.Vector3D();
            var newPtRight = new DSMath.Vector3D();
            var newPtLeft = new DSMath.Vector3D();
            var vecOrientFront, vecOrientSide, vecOrientUp;
            var movementSmoothness = 0.25;
            //var nbCollision = 3;
            var water_height = new DSMath.Vector3D();

            // ================================== RIGHT ==================================//
            if (iRightIntersection !== 0) {
                ptRight = this.pointToVector(iRightIntersection.point);
                newPtRight = (this._lastRightIntersection !== undefined && this._lastRightIntersection !== null) ? this._lastRightIntersection.lerp(ptRight, movementSmoothness / 4) : ptRight;
                newPtRight.set(ptRight.x, ptRight.y, newPtRight.z);
                this._lastRightIntersection = newPtRight.clone();
            }
            // ================================== RIGHT ==================================//

            // ==================================  LEFT ==================================//
            if (iLeftIntersection !== 0) {
                ptLeft = this.pointToVector(iLeftIntersection.point);
                newPtLeft = (this._lastLeftIntersection !== undefined && this._lastLeftIntersection !== null) ? this._lastLeftIntersection.lerp(ptLeft, movementSmoothness / 4) : ptLeft;
                newPtLeft.set(ptLeft.x, ptLeft.y, newPtLeft.z);
                this._lastLeftIntersection = newPtLeft.clone();
            }
            // ==================================  LEFT ==================================//

            // if(newPtLeft !== null && newPtLeft !== undefined && newPtRight !== null && newPtRight !== undefined){
            //     var middlePoint = DSMath.Vector3D.add(newPtLeft, newPtRight);
            //     middlePoint.multiplyScalar(0.5);
            // }
            // var middlePoint = DSMath.Vector3D.add(newPtLeft, newPtRight);
            // middlePoint.multiplyScalar(0.5);
            //this.drawSphere(middlePoint, 1 * 1000 * this._scale, 4);

            // ================================== FRONT ==================================//
            if (iFrontIntersection !== 0) {
                ptFront = this.pointToVector(iFrontIntersection.point);
                newPtFront = (this._lastFrontIntersection !== undefined && this._lastFrontIntersection !== null) ? this._lastFrontIntersection.lerp(ptFront, movementSmoothness) : ptFront;
                newPtFront.set(ptFront.x, ptFront.y, newPtFront.z);
                this._lastFrontIntersection = newPtFront.clone();
            }
            // ================================== FRONT ==================================//

            /*// ================================== BACK  ==================================//
            if (iBackIntersection !== 0) {
                ptBack = this.pointToVector(iBackIntersection.point);
                newPtBack = (this._lastBackIntersection !== undefined && this._lastBackIntersection !== null) ? this._lastBackIntersection.lerp(ptBack, movementSmoothness) : ptBack;
                newPtBack.set(ptBack.x, ptBack.y, newPtBack.z);
                this._lastBackIntersection = newPtBack;
            }

            if (newPtBack !== null) { water_height.add(newPtBack); }
            // =================================== BACK ==================================//*/

            //Quick fix : To Remove
            newPtFront = iFrontIntersection.point;
            newPtRight = iRightIntersection.point;
            newPtLeft = iLeftIntersection.point;


            if (this._debug) {
                if (iFrontIntersection !== 0) { this.drawSphere(newPtFront, 0.5 * 1000, 4); }
                //if (iBackIntersection !== 0) { this.drawSphere(iBackIntersection.point, 0.5 * 1000, 4); }
                if (iRightIntersection !== 0) { this.drawSphere(newPtRight, 0.5 * 1000, 4); }
                if (iLeftIntersection !== 0) { this.drawSphere(newPtLeft, 0.5 * 1000, 4); }
            }

            var waterDetected = (newPtLeft !== null && newPtLeft !== undefined && newPtRight !== null && newPtRight !== undefined && newPtFront !== null && newPtFront !== undefined) ? true : false;

            var resultinfo;
            if (waterDetected) {

                water_height.add(newPtFront);
                water_height.add(newPtLeft);
                water_height.add(newPtRight);
                water_height.multiplyScalar(1 / 3);
                //water_height.multiplyScalar(1 / nbCollision);

                var backPoint = DSMath.Point.add(newPtLeft, newPtRight);
                backPoint.multiplyScalar(0.5);
                if (this._debug) {
                    this.drawSphere(backPoint, 0.7 * 1000, 3);
                    this.drawSphere(water_height, 1000);
                }

                var vFront = this._localFront.clone();
                vecOrientFront = newPtFront.clone().sub(backPoint);
                vecOrientFront = vFront.lerp(vecOrientFront, 1 / (this._length + this._width));
                vecOrientFront.normalize();

                var vRight = this._localRight.clone();
                vecOrientSide = newPtRight.clone().sub(newPtLeft);
                vecOrientSide = vRight.lerp(vecOrientSide, 1 / ((this._length + this._width) * 2)); //vecOrientSide = vRight.lerp(vecOrientSide, 0.0009);
                vecOrientSide.normalize();

                vecOrientUp = DSMath.Vector3D.cross(vecOrientSide, vecOrientFront);
                vecOrientUp.normalize();

                resultinfo = {
                    allRaycastOK: waterDetected,
                    waterHeight: water_height,
                    frontDirection: vecOrientFront,
                    sideDirection: vecOrientSide,
                    upDirection: vecOrientUp
                };
            }
            else {
                resultinfo = null;
            }

            return resultinfo;
        };

        BoatController.prototype.isOnWater = function (iWaterSurfacePosition) {
            //we divide the boat in 3 part: Front, back, middle
            //we set the lowest point of these 3 part. If the lowest point of the boat is lower than picking point we consider the part under water.
            //The delta between the lowest point and the intersection point will permit to approximate (a lot) the percentage of boat under water.

            var volumePercent = 0;
            var volumePercentFront = 0;
            var volumePercentBack = 0;
            var draft = 0;
            var draftFront = 0;
            var draftBack = 0;

            var upOffset = DSMath.Vector3D.multiplyScalar(this._worldUp, -this._height * 0.45);
            var frontOffset = DSMath.Vector3D.multiplyScalar(this._localFront, this._length * 0.35);
            var initPosition = DSMath.Vector3D.add(this._actorTransform.vector, this._centerOffset);

            // Define 3 lowest position of the boat: Front, Middle, Back
            // =============================
            var boatLowPosFront = DSMath.Vector3D.add(initPosition, frontOffset);
            boatLowPosFront.add(upOffset);

            var boatLowPosBack = DSMath.Vector3D.sub(initPosition, frontOffset);
            boatLowPosBack.add(upOffset);

            var boatLowPos = initPosition.clone();
            boatLowPos.add(upOffset);

            // Define 3 picking origin: Front, Middle, Back
            // =============================
            var pickingPosFront = boatLowPosFront.clone();
            var pickingPosMiddle = boatLowPos.clone();
            var pickingPosBack = boatLowPosBack.clone();

            var ZOffset = DSMath.Vector3D.multiplyScalar(this._worldUp, this._height);
            pickingPosFront.add(ZOffset);
            pickingPosMiddle.add(ZOffset);
            pickingPosBack.add(ZOffset);

            // Launch picking
            // =============================
            var clickableState = this._actor.clickable;
            this._actor.clickable = false; //To exclude the object from the raycast
            var intersectFront = this.getFirstDownIntersectPoint(pickingPosFront);
            var intersectMiddle = this.getFirstDownIntersectPoint(pickingPosMiddle);
            var intersectBack = this.getFirstDownIntersectPoint(pickingPosBack);
            this._actor.clickable = clickableState;

            if (this._debug) {
                if (intersectFront != 0)
                    this.drawSphere(intersectFront.point, 500, 3);
                if (intersectMiddle != 0)
                    this.drawSphere(intersectMiddle.point, 500, 3);
                if (intersectBack != 0)
                    this.drawSphere(intersectBack.point, 500, 3);
                //---
                this.drawSphere(boatLowPosFront, 500, 5);
                this.drawSphere(boatLowPos, 500, 5);
                this.drawSphere(boatLowPosBack, 500, 5);
                //---
                if (intersectMiddle != 0)
                    (boatLowPos.z < intersectMiddle.point.z) ? this.drawSphere(pickingPosMiddle, 1000, 1) : this.drawSphere(pickingPosMiddle, 1000, 0);
                if (intersectFront != 0)
                    (boatLowPosFront.z < intersectFront.point.z) ? this.drawSphere(pickingPosFront, 1000, 1) : this.drawSphere(pickingPosFront, 1000, 0);
                if (intersectBack != 0)
                    (boatLowPosBack.z < intersectBack.point.z) ? this.drawSphere(pickingPosBack, 1000, 1) : this.drawSphere(pickingPosBack, 1000, 0);
            }

            var onWater;
            if (intersectMiddle != 0 && intersectFront != 0 && intersectBack != 0) {
                onWater = (boatLowPos.z < intersectMiddle.point.z) || (boatLowPosFront.z < intersectFront.point.z) || (boatLowPosBack.z < intersectBack.point.z);
            }
            else {
                onWater = (boatLowPos.z < iWaterSurfacePosition.z);
            }
            //var onWater = (boatLowPos.z < intersectMiddle.point.z) || (boatLowPosFront.z < intersectFront.point.z) || (boatLowPosBack.z < intersectBack.point.z);
            if (onWater) {
                draft = iWaterSurfacePosition.z - boatLowPos.z;
                if (intersectMiddle != 0) {
                    volumePercent = (intersectMiddle.point.z - boatLowPos.z) / (this.draft * 1000);
                }
                else {
                    volumePercent = 1;
                }

                if (intersectFront != 0) {
                    draftFront = intersectFront.point.z - boatLowPosFront.z;
                    volumePercentFront = (intersectFront.point.z - boatLowPosFront.z) / (this.draft * 1000);
                }
                else {
                    volumePercentFront = 1;
                    draftFront = draft;
                }

                if (intersectBack != 0) {
                    draftBack = intersectBack.point.z - boatLowPosBack.z;
                    volumePercentBack = (intersectBack.point.z - boatLowPosBack.z) / (this.draft * 1000);
                }
                else {
                    volumePercentFront = 1;
                    draftBack = draft;
                }

                volumePercent += volumePercentFront + volumePercentBack;
                volumePercent = volumePercent / 3;

                draft += draftFront + draftBack;
                draft = draft / 3;
            }

            var info = {
                isOnWater: onWater,
                draft: draft,
                volumePercent: volumePercent
            };
            return info;
        };

        BoatController.prototype.computeBuoyancy = function (iDeltaTime, iWaveInfo) {
            var a;

            var coefficient = 0;
            if (this.draft * 1000 > this._height) {
                coefficient = 0;
            }
            else if (this.draft * 1000 <= 0) {
                coefficient = 0;
            }
            else {
                if (this.simulateWaves) {
                    var slowCoefficient = 2;
                    this._currentTimeWaveHeightSimulation += iDeltaTime;
                    this._currentTimeWaveHeightSimulation = this._currentTimeWaveHeightSimulation % ((2 * slowCoefficient) * Math.PI);

                    iWaveInfo.draft += this.draft * 1000 * 0.15 * Math.sin(this._currentTimeWaveHeightSimulation / slowCoefficient);

                    coefficient = (iWaveInfo.draft / (this.draft * 1000));
                }
                else {
                    //coefficient = (iWaveInfo.draft / (this.draft * 1000)); // draft express in meter
                    coefficient = iWaveInfo.volumePercent;
                }
            }
            /*if (coefficient > 1.5) {
                coefficient = 1.5;
            }
            if (coefficient >= 1 && iWaveInfo.volumePercent < 0.05) {
                coefficient = 1;
            }*/

            var archimede = DSMath.Vector3D.multiplyScalar(this._gravity, coefficient);

            if (this._oldArchimede !== undefined && this._oldArchimede !== null) {
                archimede = DSMath.Vector3D.lerp(this._oldArchimede, archimede, 0.1);
            }

            this._oldArchimede = archimede;

            a = DSMath.Vector3D.sub(this._gravity, archimede);
            a.multiplyScalar(iDeltaTime);

            return a;
        };

        //********************************{ ORIENTATION }******************************//
        /**
         * Identifiate the differents local axis according to the front vector
         * @method
         * @private
         */
        BoatController.prototype.computeDirectionVectors = function () {
            //var actorTransform = actor.getTransform();
            var XVector = this._actorTransform.matrix.getFirstColumn().normalize().clone();
            var YVector = this._actorTransform.matrix.getSecondColumn().normalize().clone();
            var ZVector = this._actorTransform.matrix.getThirdColumn().normalize().clone();

            switch (this._frontVector) {
                case "x":
                    this._localFront = XVector;// on suppose +X comme front axis
                    this._localRight = YVector.negate();// on suppose +Y comme right axis
                    this._localUp = ZVector;// on suppose +Z comme up axis
                    break;
                case "-x":
                    this._localFront = XVector.negate();// on suppose -X comme front axis
                    this._localRight = YVector;// on suppose +Y comme right axis
                    this._localUp = ZVector;// on suppose +Z comme up axis
                    break;
                case "y":
                    this._localFront = YVector;// on suppose +Y comme front axis
                    this._localRight = XVector;// on suppose +X comme right axis
                    this._localUp = ZVector;// on suppose +Z comme up axis
                    break;
                case "-y":
                    this._localFront = YVector.negate();// on suppose -Y comme front axis
                    this._localRight = XVector.negate();// on suppose +X comme right axis
                    this._localUp = ZVector;// on suppose +Z comme up axis
                    break;
                case "z":
                    this._localFront = ZVector;// on suppose +Z comme front axis
                    this._localRight = XVector.negate();// on suppose -X comme right axis
                    this._localUp = YVector;// on suppose +Y comme up axis
                    break;
                case "-z":
                    this._localFront = ZVector.negate();// on suppose -Y comme front axis
                    this._localRight = XVector;// on suppose +X comme right axis
                    this._localUp = YVector.negate();// on suppose +Z comme up axis
                    break;
                default:
                    this._localFront = YVector;// on suppose +Y comme front axis
                    this._localRight = XVector;// on suppose +X comme right axis
                    this._localUp = ZVector;// on suppose +Z comme up axis
                    break;
            }
        };

        /**
         * Compute the local axis of the actor
         * @method
         * @private
         */
        BoatController.prototype.computeMatrix = function (iXDirection, iYDirection, iZDirection) {
            var rotCenter = this._actorTransform.vector.clone().add(this._centerOffset);
            this.alignWithTheGround(this.actor, this._localUp, iZDirection, rotCenter);
        };

        /**
         * essaye de rendre colinéaire iGroundZ et iUpActorVector
         * @method
         * @private
         */
        BoatController.prototype.alignWithTheGround = function (iActor, iUpActorVector, iGroundZ, iCenterAvgPosScene) {
            if (iUpActorVector === undefined || iUpActorVector === null) {
                console.error('iUpActorVector == null');
                return;
            }
            if (iGroundZ === undefined || iGroundZ === null) {
                console.error('iGroundZ == null');
                return;
            }

            var orth = DSMath.Vector3D.cross(iGroundZ, iUpActorVector);
            var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
            // collinear test 
            if (orth.squareNorm() > Tol) {
                orth.normalize();
                var dot = iGroundZ.dot(iUpActorVector);
                var angle = -Math.acos(dot);

                this.rotateAround(iActor, iCenterAvgPosScene, orth, angle);

                var transfoRotation = this.pointRotateAround(this._centerOffset, this._actor.getPosition().clone(), orth, angle);
                this._centerOffset = this._centerOffset.applyTransformation(transfoRotation);
            }
        };

        /**
         * Function used to simulate the incidence of waves on the boat
         * @method
         * @private
         */
        BoatController.prototype.updateSimulateWaveOrientation = function (iDeltaTime) {
            var boatCenter = DSMath.Vector3D.add(this._actorTransform.vector, this._centerOffset);

            this._currentTimeWaveOrientationSimulation += (iDeltaTime);
            this._currentTimeWaveOrientationSimulation = this._currentTimeWaveOrientationSimulation % ((2 * this._waveSpeedCoefficient) * Math.PI);

            var frontRotation = this._frontWaveRotationFactor /** (1 - (this._currentSpeed / this._speed))*/;
            var sideRotation = this._sideWaveRotationFactor * (1 - (this._currentSpeed / this._speed));

            var frontValue = Math.cos(this._currentTimeWaveOrientationSimulation * this._waveSpeedCoefficient) * frontRotation;
            this.rotateAround(this._actor, boatCenter, this._localRight.clone().negate(), frontValue * iDeltaTime);

            var sideValue = Math.cos((this._currentTimeWaveOrientationSimulation * this._waveSpeedCoefficient) + 1) * sideRotation;
            this.rotateAround(this._actor, boatCenter, this._localFront, sideValue * iDeltaTime);
        };

        //********************************{ DIMENSIONS }******************************//
        /**
         * This function will automaticaly compute the boat's dimension 
         * @method
         * @private
         */
        BoatController.prototype.computeSize = function () {

            var iLocalTransformation = this._actorTransform.clone();
            var MyParams = { excludeChildren: 1, orientation: iLocalTransformation };
            var iBBox = this.actor.getOrientedBoundingBox(MyParams);

            var interPoint = iBBox.high.clone();
            interPoint.x = iBBox.low.x;
            interPoint.y = iBBox.low.y;
            var ZDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;
            interPoint.x = iBBox.high.x;
            interPoint.z = iBBox.low.z;
            var XDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;
            interPoint.x = iBBox.low.x;
            interPoint.y = iBBox.high.y;
            var YDimension = Math.round(iBBox.low.distanceTo(interPoint) * 10) / 10;

            XDimension *= this._scale;
            YDimension *= this._scale;
            ZDimension *= this._scale;

            if (this.computeDirectionAxis) {
                this._frontVector = (XDimension > YDimension) ? "x" : "y";
                this._length = (XDimension > YDimension) ? XDimension : YDimension;
                this._width = (XDimension > YDimension) ? YDimension : XDimension;
                this._height = ZDimension;
            }
            else {
                switch (this.directionAxis) {
                    case 0: //X
                        this._frontVector = "x";
                        this._length = XDimension;
                        this._width = YDimension;
                        break;
                    case 1: //-X
                        this._frontVector = "-x";
                        this._length = XDimension;
                        this._width = YDimension;
                        break;
                    case 2: //Y
                        this._frontVector = "y";
                        this._length = YDimension;
                        this._width = XDimension;
                        break;
                    case 3: //-Y
                        this._frontVector = "-y";
                        this._length = YDimension;
                        this._width = XDimension;
                        break;
                    case 4: //Z
                        this._frontVector = "z";
                        this._length = YDimension;
                        this._width = XDimension;
                        break;
                    case 5: //-Z
                        this._frontVector = "-z";
                        this._length = YDimension;
                        this._width = XDimension;
                        break;
                }
                this._height = ZDimension;
            }

            if (this._debug) {
                if (!this.computeDirectionAxis) {
                    console.log("Front Vector: " + this._frontVector);
                }
                console.log("Length: " + this._length);
                console.log("Width: " + this._width);
            }


            var center = new DSMath.Vector3D(); // Coord dans le repere local du cube
            center.x = (iBBox.high.x + iBBox.low.x) * 0.5;
            center.y = (iBBox.high.y + iBBox.low.y) * 0.5;
            center.z = (iBBox.high.z + iBBox.low.z) * 0.5;

            center.add(this.actor.getPosition());

            //if (this._debug) {
            //    this.drawSphere(center, 1000 * this._scale, 1, -1);
            //}

            var centerOffset = DSMath.Vector3D.sub(center, this.actor.getPosition());

            //faire une rotation sur cet offset
            centerOffset = centerOffset.applyTransformation(iLocalTransformation);
            //if (this._debug) {
            //    this.drawLine(this.actor.getPosition(), 450, centerOffset.norm(), centerOffset.clone().normalize(), 2, -1);
            //}

            var c = DSMath.Vector3D.add(centerOffset, this.actor.getPosition());

            if (this._debug) {
                //var col = new STU.Color(0, 255, 0);
                //this._createSphere(c, 1000, col, -1);
                this.drawSphere(center, 1000, 1, -1);
            }

            center = c.clone();

            this._center = center;
            this._centerOffset = centerOffset;

            if (this.computeDirectionAxis) {
                this.checkDimensions(center, XDimension, YDimension, ZDimension);
            }
        };

        BoatController.prototype.checkDimensions = function (iCenter, iXDimension, iYDimension, iZDimension) {

            var rayOrigin = iCenter.clone();
            var upOffset = new DSMath.Vector3D();
            var frontOffset = new DSMath.Vector3D();
            var sideOffset = new DSMath.Vector3D();
            var length, width;
            var airFront = 0;
            var airBack = 0;

            if (iXDimension > iYDimension) {
                frontOffset = this.actor.getTransform().matrix.getFirstColumn().normalize();
                sideOffset = this.actor.getTransform().matrix.getSecondColumn().normalize();
                length = iXDimension;
                width = iYDimension;
            }
            else {
                frontOffset = this.actor.getTransform().matrix.getSecondColumn().normalize();
                sideOffset = this.actor.getTransform().matrix.getFirstColumn().normalize();
                length = iYDimension;
                width = iXDimension;
            }

            //_frontVector = frontOffset.clone();

            //Dans le cas present on considere Z comme Up vector
            var upOffset = this.actor.getTransform().matrix.getThirdColumn().normalize();
            upOffset.multiplyScalar(iZDimension * 0.5);

            //On se place tres haut
            rayOrigin.add(upOffset);

            if (this._debug) {
                this.drawSphere(rayOrigin, 1000, 0, -1); //this._createSphere(rayOrigin, 1000, null, -1);
            }

            //On commence par l'avant
            frontOffset.multiplyScalar(length * 0.225);
            rayOrigin.add(frontOffset);

            //On lance le rayon
            var hit = this.hitActor(rayOrigin, upOffset.clone().normalize().negate(), iZDimension * 3);
            if (hit) {
                var lengthDone = 0;
                var lengthIncrement = length * 0.125; // divisé par 8
                var lengthPosition = rayOrigin.clone();
                var lengthOffset = frontOffset.clone().normalize().multiplyScalar(lengthIncrement);
                do {
                    hit = this.hitActor(lengthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);
                    //this._createSphere(lengthPosition, 1000, null, -1);

                    if (this._debug) {
                        var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                        this.drawSphere(lengthPosition, 750, tmpCol, -1);//this._createSphere(lengthPosition, 750, tmpCol, -1);
                    }

                    if (hit) {
                        var widthOffset = sideOffset.clone();
                        var widthPosition = lengthPosition.clone();
                        var widthIncrement = width * 0.125; // divisé par 8

                        widthOffset.multiplyScalar(widthIncrement);
                        //a droite
                        var width1 = 0;
                        var widthDone = 0;
                        do {
                            widthPosition.add(widthOffset);
                            hit = this.hitActor(widthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);

                            if (this._debug) {
                                var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                                this.drawSphere(widthPosition, 500, tmpCol, -1);//this._createSphere(widthPosition, 500, tmpCol, -1);
                            }

                            if (hit) { width1 += widthIncrement; }
                            widthDone += widthIncrement;

                        } while (widthDone < width * 0.5);

                        widthPosition = lengthPosition.clone();
                        widthDone = 0;
                        var width2 = 0;

                        do {
                            widthPosition.sub(widthOffset);
                            hit = this.hitActor(widthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);

                            if (this._debug) {
                                var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;     
                                this.drawSphere(widthPosition, 500, tmpCol, -1);//this._createSphere(widthPosition, 500, tmpCol, -1);
                            }

                            if (hit) { width2 += widthIncrement; }
                            widthDone += widthIncrement;

                        } while (widthDone < width * 0.5);

                        airFront += width1 + width2;
                    }

                    lengthPosition.add(lengthOffset);
                    lengthDone += lengthIncrement;
                    //console.log("Je bosse");
                }
                while (lengthDone <= length * 0.25);
            }
            else {
                if (this._debug) {
                    //var col = new STU.Color(255, 128, 0);
                    this.drawSphere(rayOrigin, 1000, 0, -1);//this._createSphere(rayOrigin, 1000, col, -1);
                }
            }

            //On fini avec l'arriere
            rayOrigin.sub(frontOffset.clone().multiplyScalar(1.97));

            var hit = this.hitActor(rayOrigin, upOffset.clone().normalize().negate(), iZDimension * 3);
            if (hit) {
                var lengthDone = 0;
                var lengthIncrement = length * 0.125; // divisé par 8
                var lengthPosition = rayOrigin.clone();
                var lengthOffset = frontOffset.clone().normalize().multiplyScalar(lengthIncrement);
                do {
                    hit = this.hitActor(lengthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);
                    //this._createSphere(lengthPosition, 1000, null, -1);

                    if (this._debug) {
                        var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                        this.drawSphere(lengthPosition, 750, tmpCol, -1);//this._createSphere(lengthPosition, 750, tmpCol, -1);
                    }

                    if (hit) {
                        var widthOffset = sideOffset.clone();
                        var widthPosition = lengthPosition.clone();
                        var widthIncrement = width * 0.125; // divisé par 8

                        widthOffset.multiplyScalar(widthIncrement);
                        //a droite
                        var width1 = 0;
                        var widthDone = 0;
                        do {
                            widthPosition.add(widthOffset);
                            hit = this.hitActor(widthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);

                            if (this._debug) {
                                var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                                this.drawSphere(widthPosition, 500, tmpCol, -1);//this._createSphere(widthPosition, 500, tmpCol, -1);
                            }

                            if (hit) { width1 += widthIncrement; }
                            widthDone += widthIncrement;

                        } while (widthDone < width * 0.5);

                        widthPosition = lengthPosition.clone();
                        widthDone = 0;
                        var width2 = 0;

                        do {
                            widthPosition.sub(widthOffset);
                            hit = this.hitActor(widthPosition, upOffset.clone().normalize().negate(), iZDimension * 3);

                            if (this._debug) {
                                var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                                this.drawSphere(widthPosition, 500, tmpCol, -1);//this._createSphere(widthPosition, 500, tmpCol, -1);
                            }

                            if (hit) { width2 += widthIncrement; }
                            widthDone += widthIncrement;

                        } while (widthDone < width * 0.5);

                        //var total = width1 + width2; 
                        airBack += width1 + width2;
                    }

                    lengthPosition.sub(lengthOffset);
                    lengthDone += lengthIncrement;
                }
                while (lengthDone <= length * 0.25);

                //if (this._debug) { console.log("Air Positive Front: " + airFront); }
                //if (this._debug) { console.log("Air Negative Front: " + airBack); }

                if (airFront < airBack) {
                    //if (this._debug) { console.log("Front vector positif"); }
                }
                else {
                    //_frontVector.negate();
                    this._frontVector = "-" + this._frontVector;
                    //if (this._debug) { console.log("Front vector negatif"); }
                }
                if (this._debug) {
                    console.log("Front Vector: " + this._frontVector);
                }
            }
            else {
                //var col = new STU.Color(255, 128, 0);
                //this._createSphere(rayOrigin, 1000, col, -1);
                if (this._debug) {
                    var tmpCol = hit ? 1 : 0;//var tmpCol = hit ? new STU.Color(0, 255, 0) : null;
                    this.drawSphere(rayOrigin, 1000, tmpCol, -1);//this._createSphere(widthPosition, 500, tmpCol, -1);
                }
            }
        };

        BoatController.prototype.hitActor = function (iPosition, iDirection, iLength, iActor) {
            if (iActor === null || iActor === undefined) {
                iActor = this.actor;
            }
            var renderManager = STU.RenderManager.getInstance();
            var rayVect = new STU.Ray();
            rayVect.origin.x = iPosition.x;
            rayVect.origin.y = iPosition.y;
            rayVect.origin.z = iPosition.z;
            rayVect.direction.x = iDirection.x;
            rayVect.direction.y = iDirection.y;
            rayVect.direction.z = iDirection.z;
            rayVect.length = iLength;
            var intersectArray = renderManager._pickFromRay(rayVect, false, false, this._globeLocation);
            if (intersectArray.length > 0) {
                for (var i = 0; i < intersectArray.length; i++) {
                    if (intersectArray[i].actor !== null && intersectArray[i].actor !== undefined) {
                        if (intersectArray[i].actor === iActor) {
                            return true;
                        }
                    }
                }
                return false;
            } else {
                return false;
            }
        };

        //********************************{ Go To }********************************//
        /**
         * The SailsTo function is a complex capacity which take control of the boat to go to a specific destination
         * @param  {STU.Actor3D} iTarget The new target the boat will sails to
         * @method
         * @public
         */
        BoatController.prototype.sailsTo = function (iDestination) {
            if (iDestination === undefined || iDestination === null) {
                console.warn("Target is not define");
                this._isOnSailsToState = false;
            }
            else {
                this._target = iDestination;
                this._targetReached = false;
                this._isOnSailsToState = true;
                this._distanceEvaluationDone = false;
                this._decelerateTillEnd = false;
            }
        };

        /**
         * Update function for the "SailsTo" capacity
         * @method
         * @private
         */
        BoatController.prototype.updateSailsTo = function (iDestination, iDeltaTime) {
            if (iDestination !== undefined || iDestination !== null) {
                this._targetPosition = this.projectTargetOnTheGround(iDestination);
                if (this._debug) {
                    this.drawSphere(this._targetPosition, 1500, 3, 1);
                }

                var targetDirection = this.direction2D(iDestination);

                var distance = this.distance2D(iDestination);

                var dotValue = targetDirection.dot(this._localFront);
                var angle = Math.acos(dotValue);
                var orientation = targetDirection.dot(this._localRight);

                var speed = this._currentSpeed;

                if (this._distanceEvaluationDone === false) {
                    var rotationTimeNeeded = (angle / (this._angularSpeed * 0.8)); //facteur 0.8 pour anticiper la phase d'acceleration de la rotation

                    var travelSpeed = this._speed * 0.2; //20% of the maximum speed
                    var travelingTimeNeeded = distance / travelSpeed;

                    //console.log("Rotation Time: "+rotationTimeNeeded +" sec");
                    //console.log("TravelingTime Time: "+travelingTimeNeeded +" sec");

                    if (rotationTimeNeeded > travelingTimeNeeded) {
                        speed = this.accelerate(iDeltaTime, 1);
                    }
                    else {
                        this._distanceEvaluationDone = true;
                        /*if (this._debug) {
                            console.log("Je suis a bonne distance pour effecuer ma manoeuvre");
                        }*/
                    }
                }
                else {
                    var fiveSecOffset = this._localFront.clone().multiplyScalar(this._currentSpeed);
                    fiveSecOffset.multiplyScalar(5);
                    var positionInFiveSec = DSMath.Vector3D.add(this._actorPosition, fiveSecOffset);
                    if (this._debug) {
                        this.drawSphere(positionInFiveSec, 2000, 5, 1);
                    }

                    var traveledDistanceInFiveSec = DSMath.Vector3D.sub(positionInFiveSec, this._actorPosition).norm();

                    if (this._decelerateTillEnd === false) {
                        if (distance > traveledDistanceInFiveSec) {
                            if (this._power < 0.8) {
                                speed = this.accelerate(iDeltaTime, 1);
                            }
                        }
                        else {
                            if (distance > (traveledDistanceInFiveSec * (4 / 5)) + (this._length * 0.1)) {
                                if (this._power > 0.7) {
                                    speed = this.decelerate(iDeltaTime, true, false, 1);
                                }
                            }
                            else if (distance > (traveledDistanceInFiveSec * (3 / 5)) + (this._length * 0.1)) {
                                if (this._power > 0.5) {
                                    speed = this.decelerate(iDeltaTime, true, false, 1);
                                }
                            }
                            else if (distance > (traveledDistanceInFiveSec * (2 / 5)) + (this._length * 0.1)) {
                                if (this._power > 0.25) {
                                    speed = this.decelerate(iDeltaTime, true, false, 1);
                                }
                            }
                            else if (distance > (traveledDistanceInFiveSec * (1 / 5)) + (this._length * 0.1)) {
                                if (this._power > 0.1) {
                                    speed = this.decelerate(iDeltaTime, true, false, 1);
                                }
                            }
                            else if (distance < (traveledDistanceInFiveSec * (1 / 5)) + (this._length * 0.1)) {
                                this._decelerateTillEnd = true;
                            }
                        }

                        //Rotation

                        //acceleration stockée en m.s-2 --> Need mm.s-2
                        var accel = this._acceleration * 1000;
                        var minDistance = accel * this._speed * 0.5 * (this._currentSpeed / this._speed);
                        var distanceTolerance = 5;

                        var axisValue = 1 - dotValue;
                        axisValue = orientation < 0 ? 1 : -1; //Inversed
                        /*if(this._frontVector === "-x" || this._frontVector === "-y" || this._frontVector === "-z" ){
                            axisValue *= -1;
                        }*/

                        var degree = this.radToDeg(Math.acos(dotValue));

                        //axisValue = orientation < 0 ? -1 : 1;

                        var minDistanceRotation = (this._acceleration * this._speed * 0.5) + distanceTolerance;
                        var minDegree = 20;

                        if (degree < minDegree) {
                            axisValue = axisValue * (degree / minDegree);

                            if (distance < minDistanceRotation) {
                                axisValue = axisValue * (degree / minDegree) * (distance / minDistanceRotation);
                            }
                        }
                        if (!this._targetReached) {
                            this.computeAutoRotation(axisValue, iDeltaTime);
                        }
                    }
                    else {
                        if (this._power > 0) {
                            speed = this.decelerate(iDeltaTime, true, false, 1);
                        }
                        else if (this._power === 0) {
                            if (this._debug) {
                                console.log("Target reached");
                            }
                            var evt = new BoatHasReachedEvent(this._target, this._actor);
                            this._actor.dispatchEvent(evt);
                            this._targetReached = true;
                            this._isOnSailsToState = false;
                        }
                    }

                }

                var speedVector = this._localFront.clone().normalize();
                speedVector.multiplyScalar(speed);//speedVector.multiplyScalar(this._currentSpeed);
                speedVector.multiplyScalar(iDeltaTime);
                this._actor.translate(speedVector);

            }
        };

        /**
         * Project the target on the water
         * @method
         * @private
         */
        BoatController.prototype.projectTargetOnTheGround = function (iDestination) {
            var clickableTargetVar;
            var clickableActorVar = this.actor.clickable;

            if (this._target !== undefined && this._target !== null) {
                clickableTargetVar = this._target.clickable;
                this._target.clickable = false;
            }
            else {
                console.error("[BoatController]: Target Undefined");
            }

            this.actor.clickable = false;
            var upOffset = DSMath.Vector3D.multiplyScalar(DSMath.Vector3D.zVect, 1000); //1m en haut
            var rayPosition = DSMath.Vector3D.add(iDestination, upOffset);

            /*var ray = new STU.Ray();
            ray.origin = rayPosition.clone();
            ray.direction = DSMath.Vector3D.zVect.clone().negate(); //[0,0,-1]
            ray.length = 50000;

            var renderManager = STU.RenderManager.getInstance();
            var intersectArray = renderManager._pickFromRay(ray, true, true);*/

            //ASO4: While we don't know how to know if there is a globe instancied we pick only on geometry
            var rm = STU.RenderManager.getInstance();
            var pickingParams = {
                position: rayPosition,
                reference: this._globeLocation,
                pickGeometry: true,
                pickTerrain: true,
                pickWater: true
            };
            var intersection = rm._pickGroundFromPosition(pickingParams);

            /*if (intersectArray.length > 0) {
                var vect = new DSMath.Vector3D(intersectArray[0].point.x, intersectArray[0].point.y, intersectArray[0].point.z);
                return vect;
            }*/
            if (intersection !== null && intersection !== undefined) {
                var point = intersection.point;
                var vect = new DSMath.Vector3D(point.x, point.y, point.z);
                return vect;
            }
            else {
                //console.error("Target should be near to the ground...");
                var actorPos = this.actor.getPosition();
                var vect = new DSMath.Vector3D(iDestination.x, iDestination.y, actorPos.z);
                return vect;
            }

            if (this._target !== undefined && this._target !== null) {
                this._target.clickable = clickableTargetVar;
            }
            else {
                console.error("[BoatController]: Target Undefined");
            }
            this.actor.clickable = clickableActorVar;
        };

        BoatController.prototype.computeAutoRotation = function (iAxisValue, iDeltaTime) {
            var frontOffset = DSMath.Vector3D.multiplyScalar(this._localFront, this._width * 0.5);
            //var axisValue = (keyboard.isKeyPressed(EP.Keyboard.EKey.eLeft)) ? 1 : (keyboard.isKeyPressed(EP.Keyboard.EKey.eRight)) ? -1 : 0;

            if (iAxisValue !== 0) {
                var roundAxis = (iAxisValue < 0) ? -1 : 1;

                this._isAccelerating = (roundAxis === this._accelerationOrientation) ? true : false;
                if (this._isAccelerating) {
                    if (this.angularAcceleration > 0) {
                        var t = this._currentAngularAcceleration / (this._angularSpeed * Math.abs(iAxisValue)) * this.angularAcceleration;
                        t = Math.min(t + iDeltaTime, this.angularAcceleration);
                        this._currentAngularAcceleration = this._angularSpeed * Math.abs(iAxisValue) / this.angularAcceleration * t;
                    }
                    else {
                        this._currentAngularAcceleration = this._angularSpeed * Math.abs(iAxisValue);
                    }
                    this._inertiaStartValue = this._currentAngularAcceleration + this._currentAngularInertia;
                }
                else {
                    this._currentAngularInertia = this._inertiaStartValue;
                    this._inertieOrientation = this._accelerationOrientation;
                    this._currentAngularAcceleration = 0;
                }
                this._accelerationOrientation = roundAxis;
                //isAccelerating = true;
            }
            else {
                if (this._isAccelerating) {
                    if (this._currentAngularInertia === 0) {
                        this._currentAngularInertia = this._inertiaStartValue;
                        this._inertieOrientation = this._accelerationOrientation;
                    }
                    this._currentAngularAcceleration = 0;
                    this._isAccelerating = false;
                }
            }

            var t = this._currentAngularInertia / this._angularSpeed * (this.angularDeceleration);
            if (t > 0) {
                t = Math.max(t - iDeltaTime, 0);
            }
            else if (t < 0) {
                t = Math.min(t + iDeltaTime, 0);
            }
            else {
                t = 0;
            }
            this._currentAngularInertia = this._angularSpeed / (this.angularDeceleration) * t;

            var accel = this._currentAngularAcceleration * this._accelerationOrientation;
            var iner = this._currentAngularInertia * this._inertieOrientation;
            var rotationPivotPosition = DSMath.Vector3D.add(this._actorPosition, frontOffset.multiplyScalar(0.75));

            this.rotateAround(this._actor, rotationPivotPosition, this._localUp, (accel + iner) * iDeltaTime);

            var transfoRotation = this.pointRotateAround(this._centerOffset, this._actor.getPosition().clone(), this._localUp, (accel + iner) * iDeltaTime);
            this._centerOffset = this._centerOffset.applyTransformation(transfoRotation);//this._centerOffset = transfoRotation.applyToVector(this._centerOffset);
        };

        /**
         * Returns true when the boat is currently going to the given actor.
         *
         * @public
         * @param  {STU.Actor3D}  iActor The specified target.
         * @return {Boolean}
         */
        BoatController.prototype.isSailingTo = function (iTarget) {
            return this._isOnSailsToState && iTarget !== undefined && iTarget !== null && iTarget === this._target;
        };

        //********************************{ Follow Path }********************************//

        /**
         * Use : Take the control of the boat, and manage it through a pathActor created by the user.
         * @param  {STU.PathActor} iPath The defined path that the boat will follow
         * @method
         * @public
         */
        BoatController.prototype.followTrajectory = function (iPath) {
            if (iPath === undefined || iPath === null) {
                console.warn("Path is not define");
                this._isOnFollowPathState = false;
            }
            else {
                this._currentDistanceFollowPath = 0;
                this._pathLength = 0;

                this._isOnFollowTrajectoryState = true;
                this._targetedPath = iPath;
                this._pathCompleted = false;
                //this._pathLength = this._targetedPath.getLength();
                this._currentTargetIndex = 0;
                this.computeTrajectory();

                this.PlaceOnTheBeginningOfThePath(this._targetedPath);
                this._currentSpeed = this._speed;
            }
        };

        BoatController.prototype.updateFollowTrajectory = function (iPath, iDeltaTime) {

            if (iPath !== undefined || iPath !== null) {

                var boatCenter = DSMath.Vector3D.add(this._actorPosition.clone(), this._centerOffset);

                //Estimate the distance traveled on the path
                var pathLength = this._targetedPath.getLength();
                var div = pathLength / this._targets.length;
                var pathDone = this._currentTargetIndex * div;
                var distanceToThePathEnd = pathLength - pathDone;

                //Distance to the next target
                //var targetDirection = DSMath.Vector3D.sub(this._currentTarget, this._actorPosition);
                //var distance = targetDirection.norm();
                //targetDirection.normalize();
                var distance = this.distance2D(this._currentTarget);
                var targetDirection = this.direction2D(this._currentTarget);

                //Angle between front vector and direction to the target
                var angle, axisValue;
                if (this._localFront.isEqual(targetDirection, 0.001)) {
                    angle = 0;
                    axisValue = 1;
                }
                else {
                    var dotValue = targetDirection.dot(this._localFront);
                    angle = Math.acos(dotValue);
                    var orientation = targetDirection.dot(this._localRight);
                    axisValue = 1 - angle;
                    axisValue = orientation < 0 ? 1 : -1; //Inversed
                }

                /*if(this._frontVector === "-x" || this._frontVector === "-y" || this._frontVector === "-z" ){
                    axisValue *= -1;
                }*/

                //Estimate the distance traveled in 1s
                var oneSecOffset = this._localFront.clone().multiplyScalar(this._currentSpeed);
                var positionInOneSec = DSMath.Vector3D.add(boatCenter, oneSecOffset);
                var traveledDistanceInOneSec = DSMath.Vector3D.sub(positionInOneSec, boatCenter).norm();
                traveledDistanceInOneSec = ((1 - this._stickCoefficient) * traveledDistanceInOneSec) + ((this._stickCoefficient) * 0);
                if (this._globeLocation !== null && this._globeLocation !== undefined) {
                    var scale = this._globeLocation.getTransform("World").matrix.getScale();
                    traveledDistanceInOneSec *= scale;
                }
                if (this._debug) {
                    this.drawSphere(positionInOneSec, 2000, 5, 1);
                }
                var distanceToThePathEnd = pathLength - pathDone;


                //Going to the next target position on the path
                if (traveledDistanceInOneSec + (this._length * 0.5) > distance) {
                    if (this._currentTarget === this._endTarget) {
                        pathDone += div;
                    }
                    this.goToNextTarget();
                }
                // else{
                //     console.log(traveledDistanceInOneSec);
                // }


                //Manage speed in fonction of the position on the path
                var speed = this._currentSpeed;

                if (pathDone < pathLength - 1) {
                    if (pathDone > (pathLength) * 0.75) {
                        if (traveledDistanceInOneSec * 2 > distanceToThePathEnd) {
                            speed = this.decelerate(iDeltaTime, true, false, 1);
                            //console.log(distanceToThePathEnd);
                        }
                    }
                    else {
                        speed = this.accelerate(iDeltaTime, 1);
                    }
                }
                else {
                    var evt = new BoatHasCompletedEvent(this._targetedPath, this._actor);
                    this._actor.dispatchEvent(evt);
                    this._pathCompleted = true;
                    this._isOnFollowTrajectoryState = false;
                    console.log("Path Completed");
                    this.dispatchEvent(new STU.ServiceStoppedEvent("followTrajectory", this));
                    return;
                }

                //translate
                var speedVector = this._localFront.clone().normalize();
                speedVector.multiplyScalar(speed);
                speedVector.multiplyScalar(iDeltaTime);
                this._actor.translate(speedVector);

                //var rotationTimeNeeded = angle / this._angularSpeed;
                //var travelingTimeNeeded = distance / this._speed;
                //var time = ((1-this._stickCoefficient) * rotationTimeNeeded) + ((this._stickCoefficient) * 0);


                // compute rotation 
                var tmpAngle = angle;
                if (tmpAngle > this._angularSpeed / this._inertiaFactor) {
                    tmpAngle = this._angularSpeed / this._inertiaFactor;
                }
                tmpAngle *= iDeltaTime * axisValue;
                var coeff = ((1 - this._stickCoefficient) * iDeltaTime) + ((this._stickCoefficient) * 0.25);
                var followPathAngularSpeed = ((1 - this._stickCoefficient) * tmpAngle) + ((this._stickCoefficient) * angle * axisValue * coeff);

                //rotate the boat
                //var rotationPivotPosition = this._actorPosition.clone();
                this.rotateAround(this._actor, boatCenter, this._localUp, followPathAngularSpeed);

                //Apply the rotation on the centeroffset
                var transfoRotation = this.pointRotateAround(this._centerOffset, this._actor.getPosition().clone(), this._localUp, followPathAngularSpeed);
                this._centerOffset = this._centerOffset.applyTransformation(transfoRotation);

                if (this._debug) {
                    this.drawSphere(this._currentTarget, 2 * 1000 * this._scale, 4, 1);
                }
            }
        };

        BoatController.prototype.getAngleBetweenVectors = function (vector1, vector2) {
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

        BoatController.prototype.PlaceOnTheBeginningOfThePath = function (iPath) {
            /*var transform = iPath.getTransform().clone();
            transform.matrix.multiplyScalar(this._scale);
            //transform.matrix = matrix;
            //transform.vector = actorPosition;
            this._actor.setTransform(transform);*/

            //var offset = this._localFront.clone().multiplyScalar(500000);


            //var start = iPath.getValue(0);
            //var end = iPath.getValue(0.01);

            var start = this._targets[0];
            var end = this._targets[1];

            var direction = DSMath.Vector3D.sub(end, start);
            direction.normalize();
            //console.log(this._localFront);
            var dotValue = direction.dot(this._localFront);
            var angle = Math.acos(dotValue);
            var orientation = direction.dot(this._localRight);
            orientation = orientation < 0 ? 1 : -1; //Inversed

            var boatCenter = DSMath.Vector3D.add(this._actorPosition.clone(), this._centerOffset);
            this.actor.rotateAround(boatCenter, this._localUp, angle * orientation);

            var transfoRotation = this.pointRotateAround(this._centerOffset, this._actor.getPosition().clone(), this._localUp, angle * orientation);
            this._centerOffset = this._centerOffset.applyTransformation(transfoRotation);

            var offset = this._centerOffset.clone();
            offset.z = 0;
            start.sub(offset);
            //start.add(new DSMath.Vector3D(0, 0, this._height *0.5));
            this.actor.setPosition(start);
        };

        BoatController.prototype.computeTrajectory = function () {
            this._targets = [];//new Array();
            this._pathLength = this._targetedPath.getLength();

            var timeToCompletePath = this._pathLength / this._speed;



            if (this._globeLocation !== null && this._globeLocation !== undefined) {
                var s = this._globeLocation.getTransform("World").matrix.getScale();
                timeToCompletePath = this._pathLength / (this._speed * s);
            }

            var div = Math.round(timeToCompletePath);

            var sCoeff = this._stickCoefficient;
            sCoeff = this._stickCoefficient > 1 ? 1 : this._stickCoefficient;
            sCoeff = this._stickCoefficient < 0 ? 0 : this._stickCoefficient;

            //console.log(sCoeff);
            //var coef = sCoeff - 2;
            //coef = Math.abs(coef);

            var divisionMin = div;
            var divisionMax = div * 10;

            var division = (1 - sCoeff) * divisionMin + sCoeff * divisionMax;
            division = Math.round(division);


            for (var i = 0; i <= division; i++) {
                var pos = this._targetedPath.getValue(i / division, this._globeLocation);

                var v = DSMath.Vector3D.zVect.clone();
                if (this._globeLocation !== null && this._globeLocation !== undefined) {
                    v = this._globeLocation.getTransform("World").matrix.getThirdColumn();
                    v.normalize();
                }

                pos.add(v.clone().multiplyScalar(this._height));
                var hit = this.getFirstDownIntersectPoint(pos);
                if (hit !== 0 && hit !== null && hit !== undefined) {
                    pos.setFromPoint(hit.point);
                }

                if (this._debug) {
                    this.drawSphere(pos, 1000 * this._scale, 5, -1);
                }
                this._targets.push(pos);

                if (i === 1) {
                    this._currentTarget = pos.clone();
                }
                else if (i === division) {
                    this._endTarget = pos;
                }
            }


            /*var sCoeff = this._stickCoefficient;
            sCoeff = this._stickCoefficient > 1 ? 1 : this._stickCoefficient;
            sCoeff = this._stickCoefficient < 0 ? 0 : this._stickCoefficient;

            //var divisionMin = Math.round(this._pathLength * 0.05);
            var divisionMin = 20;
            var divisionMax = this._pathLength / 2000;

            var division = (1 - sCoeff) * divisionMin + sCoeff * divisionMax;
            division = Math.round(division);

            console.log("pathLength: " + this._pathLength);
            console.log("divisionMin: " + divisionMin);
            console.log("divisionMax: " + divisionMax);
            console.log("division: " + division);
            console.log("NB: " + (this._pathLength / division));
            //var pathStep = pathLength / division;

            for (var i = 0; i <= division; i++) {
                var pos = this._targetedPath.getValue(i / division);
                if (this._debug) {
                    this.drawSphere(pos, 0.3 * 1000 * this._scale, 5, -1);
                }
                this._targets.push(pos);

                if (i === 0) {
                    this._currentTarget = pos.clone();
                }
                else if (i === division) {
                    this._endTarget = pos.clone();
                }
            }*/
        };

        BoatController.prototype.goToNextTarget = function () {
            this._currentTargetIndex++;
            if (this._currentTargetIndex > this._targets.length - 1) {
                this._currentTargetIndex = this._targets.length - 1;
            }
            this._currentTarget = this._targets[this._currentTargetIndex];
        };

        /**
         * Returns true when the boat is currently following a given path.
         *
         * @public
         * @param  {STU.PathActor}  iPath
         * @return {Boolean}
         */
        BoatController.prototype.isFollowing = function (iPath) {
            return this._isOnFollowTrajectoryState && iPath !== undefined && iPath !== null && iPath === this._targetedPath;
        };

        //********************************{ UTILS }********************************//

        /**
         * Project the target at the same height of the boat
         * @method
         * @private
         */
        BoatController.prototype.distance2D = function (iDestination) {
            var pos = DSMath.Vector3D.add(this._actorPosition, this._centerOffset);
            var targetDirection = DSMath.Vector3D.sub(iDestination, pos);
            targetDirection.z = 0;
            //var newPos = DSMath.Vector3D.add(this._actorPosition, targetDirection);
            return targetDirection.norm();
        };

        /**
         * Return the direction to the target at the same height of the boat
         * @method
         * @private
         */
        BoatController.prototype.direction2D = function (iDestination) {
            var pos = DSMath.Vector3D.add(this._actorPosition, this._centerOffset);
            var targetDirection = DSMath.Vector3D.sub(iDestination, pos);
            targetDirection.z = 0;
            targetDirection.normalize();
            return targetDirection;
        };

        /**
         * Do a raycast and test if it's collide according to an origin and a ray direction 
         * @method
         * @private
         */
        /*BoatController.prototype.getFirstIntersectPoint = function (iPosition, iDirection) {
            var renderManager = STU.RenderManager.getInstance();
            var rayVect = new STU.Ray();
            rayVect.origin = new DSMath.Point(iPosition.x, iPosition.y, iPosition.z);
            rayVect.direction = iDirection;
            rayVect.length = 100000000;//150;
            var intersectArray = renderManager._pickFromRay(rayVect, true, true);
            if (intersectArray.length > 0) {
                return intersectArray[0];
            } else {
                return 0;
            }
        };*/

        BoatController.prototype.getFirstDownIntersectPoint = function (iPosition) {
            var renderManager = STU.RenderManager.getInstance();
            var location = this.actor.getLocation();
            var params = {
                position: iPosition,
                reference: location,
                pickGeometry: true,
                pickTerrain: true,
                pickWater: true
            };
            var intersection = renderManager._pickGroundFromPosition(params);
            if (intersection === null || intersection === undefined) {
                intersection = 0
            }
            return intersection;
        };

        //********************************{ MATH }********************************//
        /**
         * Casting a Point into a Vector3D
         * @method
         * @private
         */
        BoatController.prototype.pointToVector = function (point) {
            var vector = new DSMath.Vector3D();
            vector.set(point.x, point.y, point.z);
            return vector;
        };

        /**
         * Return the value in degree of a radian 
         * @method
         * @private
         */
        BoatController.prototype.radToDeg = function (iRad) {
            return (180 * iRad) / Math.PI;
        };

        /**
         * Rotate an Actor3D around an axis
         * @method
         * @private
         */
        BoatController.prototype.rotateAround = function (iActor, iOrigin, iVector, iAngle) {
            var actorCenterToOrigin = new DSMath.Vector3D();

            var quat = new DSMath.Quaternion();
            quat.makeRotation(iVector, iAngle);

            var actorTransform = iActor.getTransform();
            actorCenterToOrigin = DSMath.Vector3D.sub(actorTransform.vector.clone(), iOrigin);

            var rotTransform = actorTransform.clone();
            rotTransform.matrix = DSMath.Matrix3x3.multiply(quat.getMatrix(), actorTransform.matrix);

            var newPosCenter = actorCenterToOrigin.applyQuaternion(quat);//var newPosCenter = quat.rotate(actorCenterToOrigin);
            var finalactorPos = iOrigin.clone();
            finalactorPos.set(finalactorPos.x + newPosCenter.x, finalactorPos.y + newPosCenter.y, finalactorPos.z + newPosCenter.z);

            rotTransform.vector = finalactorPos;
            iActor.setTransform(rotTransform);
        };

        /**
         * Rotate a Point around an axis
         * @method
         * @private
         */
        BoatController.prototype.pointRotateAround = function (iPosition, iOrigin, iVector, iAngle) {
            var actorCenterToOrigin = new DSMath.Vector3D();

            var quat = new DSMath.Quaternion();
            quat.makeRotation(iVector, iAngle);
            /*quat.setRotationData({
                angle: iAngle,
                vector: iVector
            });*/

            var actorTransform = new DSMath.Transformation();//iActor.getTransform();
            actorTransform.vector = iPosition;
            actorCenterToOrigin = DSMath.Vector3D.sub(actorTransform.vector.clone(), iOrigin);

            var rotTransform = new DSMath.Transformation();//actorTransform.clone();
            var mat33 = new DSMath.Matrix3x3();
            rotTransform.matrix = DSMath.Matrix3x3.multiply(quat.getMatrix(), mat33);

            var newPosCenter = actorCenterToOrigin.applyQuaternion(quat);//var newPosCenter = quat.rotate(actorCenterToOrigin);
            var finalactorPos = iOrigin.clone();
            finalactorPos.set(finalactorPos.x + newPosCenter.x, finalactorPos.y + newPosCenter.y, finalactorPos.z + newPosCenter.z);

            rotTransform.vector = finalactorPos;
            return rotTransform;
            //iActor.setTransform(rotTransform);
        };

        //t: current time, b: startValue, c: change in value, d: duration
        BoatController.prototype.easeInQuad = function (t, b, c, d) {
            t /= d;
            return c * t * t + b;
        };

        //********************************{ DEBUG }********************************//
        /**
         * Draw a primitive sphere (for debug purpose)
         * @method
         * @private
         */
        BoatController.prototype.drawSphere = function (iPosition, iSize, iIndexColor, iLifeTime) {
            var position = new DSMath.Point(iPosition.x, iPosition.y, iPosition.z);
            /*if (this._globeLocation !== null && this._globeLocation !== undefined) {
                var transformScene = this._globeLocation.getTransform();
                var transformSceneWorld = this._globeLocation.getTransform("World");
                var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());
                position.applyTransformation(transfoScene2World);
                iSize *= transformSceneWorld.matrix.getScale();
            }*/

            var localTransfo = new DSMath.Transformation();
            var iColor = new STU.Color(255, 0, 0);
            var render = STU.RenderManager.getInstance();
            localTransfo.vector = position;
            var lifeTime = 1;
            if (iLifeTime !== null && iLifeTime !== undefined) {
                lifeTime = iLifeTime;
            }
            switch (iIndexColor) {
                case 0: iColor.setPixelValue(255, 0, 0);
                    break;
                case 1: iColor.setPixelValue(0, 255, 0);
                    break;
                case 2: iColor.setPixelValue(0, 0, 255);
                    break;
                case 3: iColor.setPixelValue(255, 255, 0);
                    break;
                case 4: iColor.setPixelValue(0, 255, 255);
                    break;
                case 5: iColor.setPixelValue(255, 0, 255);
                    break;
                case 6: iColor.setPixelValue(255, 175, 50);
                    break;
            }
            //render._createSphere(iSize, localTransfo, iColor, 255, lifeTime);
            render._createSphere({ radius: iSize, position: localTransfo, color: iColor, alpha: 255, lifetime: lifeTime });
        };

        STU.BoatController = BoatController;
        return BoatController;

    });

define('StuMiscContent/StuBoatController', ['DS/StuMiscContent/StuBoatController'], function (BoatController) {
    'use strict';

    return BoatController;
});

define('DS/StuCameras/StuFirstPersonNavigation', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuCameras/StuNavigation', 'MathematicsES/MathsDef', 'DS/StuRenderEngine/StuRenderManager'],
    function (STU, EP, Navigation, DSMath) {
    'use strict';

    /**
     * Describe a first person navigation.
     *
     * @exports FirstPersonNavigation
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.Navigation}
     * @memberOf STU
     * @alias STU.FirstPersonNavigation
     */
    var FirstPersonNavigation = function() {

        Navigation.call(this);
        this.name = 'FirstPersonNavigation';

        //////////////////////////////////////////////////////////////////////////
        // Properties that should NOT be visible in UI
        //////////////////////////////////////////////////////////////////////////        

        /**
         * Current crouch offset
         *
         * @private
         * @type {number}
         */
        this._crouchOffset = 0;

        /**
         * Current jump offset
         *
         * @private
         * @type {number}
         */
        this._jumpOffset = 0;


        /**
         * Flag set to true when then there is something (object or ground) under the camera
         *
         * @private
         * @type {boolean}
         */
        this._fristTimeOnTheground = false;

        /**
         * Current ground level
         *
         * @private
         * @type {number}
         */
        this._groundLevel = 0;

        /**
         * Temporary variable used for the jump animation
         *
         * @private
         * @type {number}
         */
        this._jumpAmount = 0;

        /**
         * This ratio will be multiplied with standHeight to get the maximum distance between
         * the camera and walls
         *
         * @private
         * @type {number}
         */
        this._cameraSizeRatio = 0.2;

        /**
         * Unitary Z world vector
         *
         * @private
         * @type {DSMath.Vector3D}
         */
        this._zWorld = new DSMath.Vector3D();
        this._zWorld.set(0, 0, 1);



        /**
         * True when the navigation is doing a goingTo transition
         *
         * @private
         * @type {Boolean}
         */
        this._isGoingTo = false;

        /**
         * Point to go to
         *
         * @private
         * @type {DSMath.Vector3D}
         */
        this._targetCoordinateToGoTo = null;

         /**
         * Point to go to
         *
         * @private
         * @type {STU.PointActor}
         */
        this._targetPointToGoTo = null;


        /**
         * Number of seconds since a goTo transition was started
         *
         * @private
         * @type {Number}
         */
        this._elapsedTimeGoTo = 0.0;

        /**
         * Time to perform to goTo transition.
         * Note that the default value will be overridden using this formula :
         * 450 / (this.horizontalRotationSensitivity + this.verticalRotationSensitivity);
         *
         * @private
         * @type {Number}
         */
        this._timeToGoTo = 1.5;

        /**
         *  True if the camera is currently following a path
         *
         * @private
         * @type {Boolean}
         */
        this._isFollowing = false;

        /**
         *  Target point to go to.
         *
         * @private
         * @type {STU.PointActor}
         */
        this._targetVirtualPointToGoTo = null;

        /**
         *  Path to follow
         *
         * @private
         * @type {STU.PathActor}
         */
        this._followedPath = null;

        /**
         * Length of the path done (in millimeters)
         *
         * @private
         * @type {Number}
         */
        this._followedPathDone = 0.0;

        /**
         *  Length of the path (in millimeters)
         *
         * @private
         * @type {Number}
         */
        this._followedPathLength = 0.0;

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


        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////

        ///
        /////////      General
        ///


        /**
         * Set the walk speed (in mm/s)
         *
         * @public
         * @default
         * @type {number}
         */
        this.walkSpeed = 2000.0;

        /**
         * Set the run speed (in unit/second)
         *
         * @public
         * @default
         * @type {number}
         */
        this.runSpeed = 3000.0;

        /**
         * Set the crouch speed (int unit/second)
         *
         * @public
         * @default
         * @type {number}
         */
        this.crouchSpeed = 1000.0;

        ///
        /////////      Controls
        ///


        /**
         *  Mapped key for moving left
         *
         * @member
         * @instance
         * @name moveLeft
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eLeft}
         * @memberOf STU.FirstPersonNavigation
         */
        this._moveLeft = EP.Keyboard.EKey.eLeft;
        Object.defineProperty(this, 'moveLeft', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._moveLeft;
            },
            set: function(iValue) {
                this._moveLeft = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyLeft = this._moveLeft;
                }
            }
        });

        /**
         *  Mapped key for moving right
         *
         * @member
         * @instance
         * @name moveRight
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eRight}
         * @memberOf STU.FirstPersonNavigation
         */
        this._moveRight = EP.Keyboard.EKey.eRight;
        Object.defineProperty(this, 'moveRight', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._moveRight;
            },
            set: function(iValue) {
                this._moveRight = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyRight = this._moveRight;
                }
            }
        });

        /**
         * Mapped key for moving forward
         *
         * @member
         * @instance
         * @name moveForward
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eUp}
         * @memberOf STU.FirstPersonNavigation
         */
        this._moveForward = EP.Keyboard.EKey.eUp;
        Object.defineProperty(this, 'moveForward', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._moveForward;
            },
            set: function(iValue) {
                this._moveForward = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyUp = this._moveForward;
                }
            }
        });

        /**
         * Mapped key for moving backward
         *
         * @member
         * @instance
         * @name moveBackward
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eDown}
         * @memberOf STU.FirstPersonNavigation
         */
        this._moveBackward = EP.Keyboard.EKey.eDown;
        Object.defineProperty(this, 'moveBackward', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._moveBackward;
            },
            set: function(iValue) {
                this._moveBackward = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyDown = this._moveBackward;
                }
            }
        });

        /**
         * Set the key enabling the jump mode
         *
         * @member
         * @instance
         * @name jump
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eEnter}
         * @memberOf STU.FirstPersonNavigation
         */
        this._jump = EP.Keyboard.EKey.eEnter;
        Object.defineProperty(this, 'jump', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._jump;
            },
            set: function(iValue) {
                this._jump = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyTrigger1 = this._jump;
                }
            }
        });

        /**
         * Set the key enabling the crouch mode
         *
         * @member
         * @instance
         * @name crouch
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eControl}
         * @memberOf STU.FirstPersonNavigation
         */
        this._crouch = EP.Keyboard.EKey.eControl;
        Object.defineProperty(this, 'crouch', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._crouch;
            },
            set: function(iValue) {
                this._crouch = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyTrigger2 = this._crouch;
                }
            }
        });

        /**
         * Set the key enabling the run mode
         *
         * @member
         * @instance
         * @name run
         * @public
         * @type {EP.Keyboard.EKey}
         * @default {EP.Keyboard.EKey.eShift}
         * @memberOf STU.FirstPersonNavigation
         */
        this._run = EP.Keyboard.EKey.eShift;
        Object.defineProperty(this, 'run', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._run;
            },
            set: function(iValue) {
                this._run = iValue;
                if (this._inputManager !== undefined && this._inputManager !== null) {
                    this._inputManager.keyTrigger3 = this._run;
                }
            }
        });


        ///
        /////////      Advanced
        ///


        /**
         * Set the height from the floor to the head (camera position), when standing (in millimeters)
         *
         * @member
         * @instance
         * @name standHeight
         * @public
         * @type {number}
         * @default {1800.0}
         * @memberOf STU.FirstPersonNavigation
         */
        this._standHeight = 1800.0;
        Object.defineProperty(this, 'standHeight', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._standHeight;
            },
            set: function(iValue) {
                this._standHeight = Math.max(iValue, 0);
                this.updateGroundPosition();

            }
        });

        /**
         * Set the height from the floor to the head (camera position), when crouching (in millimeters)<br/>
         * Note that crouch height cannot be higher than stand height
         *
         * @member
         * @instance
         * @name crouchHeight
         * @public
         * @type {number}
         * @default {1200.0}
         * @memberOf STU.FirstPersonNavigation
         */
        this._crouchHeight = 1200.0;
        Object.defineProperty(this, 'crouchHeight', {
            enumerable: true,
            configurable: true,
            get: function() {
                return this._crouchHeight;
            },
            set: function(iValue) {
                this._crouchHeight = Math.min(Math.max(iValue, 0), this._standHeight);
            }
        });

        /**
         * Set the duration from standing position to crouch position (in seconds)
         *
         * @public
         * @default
         * @type {number}
         */
        this.crouchDuration = 0.25;

        /**
         * Set the time spent with feet off the ground (in seconds)
         *
         * @public
         * @default
         * @type {number}
         */
        this.jumpDuration = 0.3;

        /**
         * Set the maximum height delta between the current ground level and the targeted ground level (in millimeters)
         *
         * @public
         * @default
         * @type {number}
         */
        this.maximumStepHeight = 400.0;

        /**
         * Prevent the camera from falling
         *
         * @public
         * @default
         * @type {boolean}
         */
        this.avoidFalls = false;

        /**
         * Enable or disable navigation with gamepad
         *
         * @member
         * @public
         * @type {boolean}
         */
        this.useGamepad = true;

    };

    FirstPersonNavigation.prototype = new Navigation();
    FirstPersonNavigation.prototype.constructor = FirstPersonNavigation;
    FirstPersonNavigation.prototype.protoId = 'C4A77260-1A82-493C-AF52-FA4C8D386F68';
    FirstPersonNavigation.prototype.pureRuntimeAttributes = [
        '_camera', '_cameraSizeRatio', '_crouch', '_crouchHeight',
        '_crouchOffset', '_deltaTime', '_elapsedTimeGoTo', '_followedPath',
        '_followedPathDone', '_followedPathLength', '_fristTimeOnTheground', '_groundLevel',
        '_inputManager', '_isCursorInNeutralZone', '_isFollowing', '_isGoingTo',
        '_isLookingAt', '_isMousePressed', '_jump', '_jumpAmount',
        '_jumpOffset', '_lastMousePosition', '_lookAtElapsedTime', '_lookAtStartQuat',
        '_lookAtTarget', '_moveBackward', '_moveForward', '_moveLeft',
        '_moveRight', '_renderMngr', '_run', '_standHeight',
        '_targetPointToGoTo', '_targetCoordinateToGoTo', '_targetVirtualPointToGoTo', '_timeToGoTo',
        '_timeToLookAt', '_zWorld'
    ].concat(Navigation.prototype.pureRuntimeAttributes);

    /**
     * Process executed when STU.FreeNavigation is activating
     *
     * @private
     */
    FirstPersonNavigation.prototype.onActivate = function() {
        Navigation.prototype.onActivate.call(this);

        //Registering keybindings
        this._inputManager.useMouse = true;
        this._inputManager.useKeyboard = true;
        this._inputManager.useGamepad = this.useGamepad;
        this._inputManager.mouseAxis = 2;
        this._inputManager.mouseInvertY = false;

        this._inputManager.keyLeft = this.moveLeft;
        this._inputManager.keyRight = this.moveRight;
        this._inputManager.keyUp = this.moveForward;
        this._inputManager.keyDown = this.moveBackward;
        this._inputManager.keyTrigger1 = this.jump; // jump key
        this._inputManager.keyTrigger2 = this.crouch; // crouch key
        this._inputManager.keyTrigger3 = this.run; // run key

        //Compute the starting ground level
        this._renderMngr = STU.RenderManager.getInstance();
        this.updateGroundPosition();

    };

    /**
     * Process executed when STU.FreeNavigation is deactivating
     *
     * @private
     */
    FirstPersonNavigation.prototype.onDeactivate = function() {
        Navigation.prototype.onDeactivate.call(this);
    };

    /**
     * Compute the ground position according to the stand height
     *
     * @private
     */
    FirstPersonNavigation.prototype.updateGroundPosition = function() {
        var camera = this._camera;
        if (camera !== undefined && camera !== null) {
            var cameraPosition = camera.getPosition();

            //Launch of an vertical ray to detect the ground
            var rayVect = new STU.Ray();

            rayVect.origin.x = cameraPosition.x;
            rayVect.origin.y = cameraPosition.y;
            rayVect.origin.z = cameraPosition.z;

            rayVect.direction.x = 0;
            rayVect.direction.y = 0;
            rayVect.direction.z = -1;

            rayVect.setLength(this._standHeight);

            //var intersectArray = this._renderMngr._pickFromRay(rayVect);
            var intersectArray;
            var myLocation = camera.getLocation();
            if (myLocation === null || myLocation === undefined) {
                intersectArray = this._renderMngr._pickFromRay(rayVect);
            }
            else {
                intersectArray = this._renderMngr._pickFromRay(rayVect, true, false, myLocation);
            }

            // if there is an object in front of camera
            if (intersectArray.length > 0) {
                this._groundLevel = intersectArray[0].getPoint().z;
                cameraPosition.z = this._groundLevel + this._standHeight;
                camera.setPosition(cameraPosition);
            } else {
                this._groundLevel = cameraPosition.z - this._standHeight;
            }
        }
    };

    /**
     * Handle the jumping behavior
     *
     * @private
     */
    FirstPersonNavigation.prototype.handleJumping = function() {
        var jumpBtnPressed;

        jumpBtnPressed = this._inputManager.buttonsState[STU.eInputTrigger.eTrigger1];

        if (this._jumpOffset > 0 || jumpBtnPressed === true) {
            this._jumpAmount += this._deltaTime;
            this._jumpOffset = Math.max(0, this.easeOutQuad(this._jumpAmount, 0, 1, this.jumpDuration));

        } else {
            this._jumpAmount = 0;
        }
    };

    /**
     * Handle the crouching behavior
     *
     * @private
     */
    FirstPersonNavigation.prototype.handleCrouching = function() {
        var crouchBtnPressed = this._inputManager.buttonsState[STU.eInputTrigger.eTrigger2];
        var crouchAmount = 1.0 / this.crouchDuration * this._deltaTime;

        // Crouch down.
        if (crouchBtnPressed) {
            this._crouchOffset = Math.max(0, Math.min(1, this._crouchOffset + crouchAmount));
        }

        // Crouching up.
        else if (!crouchBtnPressed) {
            this._crouchOffset = Math.min(1, Math.max(0, this._crouchOffset - crouchAmount));
        }
    };

    /**
     * Handle collision detection between objects and the camera
     *
     * @private
     */
    FirstPersonNavigation.prototype.handleCollision = function (motionVector, nextCamPosition, currentHeight) {
        var currentCamPos = this._camera.getPosition();

        var motionIsNotNull = true;
        if (motionVector.x === 0 && motionVector.y === 0 && motionVector.x === 0)
        { motionIsNotNull = false; }

        var intersectArray = [];

        if (motionIsNotNull === true) {
            {
                // Prevent the naviagtion to be stucked in objects
                var verticalRay = new STU.Ray();

                verticalRay.origin.x = nextCamPosition.x;
                verticalRay.origin.y = nextCamPosition.y;
                verticalRay.origin.z = nextCamPosition.z;

                verticalRay.direction.x = 0;
                verticalRay.direction.y = 0;
                verticalRay.direction.z = -1;

                verticalRay.setLength(currentHeight);

                //intersectArray = this._renderMngr._pickFromRay(verticalRay);
                var intersectArray;
                var myLocation = this._camera.getLocation();
                if (myLocation === null || myLocation === undefined) {
                    intersectArray = this._renderMngr._pickFromRay(verticalRay);
                }
                else {
                    intersectArray = this._renderMngr._pickFromRay(verticalRay, true, false, myLocation);
                }

                if (intersectArray.length > 0) { // the camera is suck into something
                    var impactPoint = intersectArray[0].getPoint();
                    nextCamPosition.z = impactPoint.z + currentHeight;
                }
            }

            {
                //Launch of an horizontal ray to detect obstacles in front of the camera
                var rayHoriz = new STU.Ray();

                rayHoriz.origin.x = currentCamPos.x;
                rayHoriz.origin.y = currentCamPos.y;
                rayHoriz.origin.z = currentCamPos.z - currentHeight + this.maximumStepHeight;

                var v = new DSMath.Vector3D();
                var o = rayHoriz.origin;
                v.set(o.x, o.y, o.z);

                rayHoriz.direction.x = motionVector.x;
                rayHoriz.direction.y = motionVector.y;
                rayHoriz.direction.z = 0;

                rayHoriz.setLength(Math.max(motionVector.norm(), this._standHeight * this._cameraSizeRatio));
                //intersectArray = this._renderMngr._pickFromRay(rayHoriz);
                var intersectArray;
                var myLocation = this._camera.getLocation();
                if (myLocation === null || myLocation === undefined) {
                    intersectArray = this._renderMngr._pickFromRay(rayHoriz);
                }
                else {
                    intersectArray = this._renderMngr._pickFromRay(rayHoriz, true, false, myLocation);
                }
            }
        }

        // if there is an object in front of camera
        if (motionIsNotNull && intersectArray.length > 0) {
            //object slider
            var n = intersectArray[0].getNormal();
            var w = DSMath.Vector3D.cross(n, this._zWorld);
            var wDot = w.dot(motionVector);

            motionVector.set(w.x, w.y, w.z);
            motionVector.multiplyScalar(wDot);


            //are we close to an angle ?
            var rayAngle = new STU.Ray();
            rayAngle.origin = this._camera.getPosition();
            rayAngle.origin.z = currentCamPos.z - currentHeight + this.maximumStepHeight;
            rayAngle.direction = motionVector;
            rayAngle.setLength(motionVector.norm() + this._standHeight * this._cameraSizeRatio);

            var intersectArray;
            var myLocation = this._camera.getLocation();
            if (myLocation === null || myLocation === undefined) {
                intersectArray = this._renderMngr._pickFromRay(rayAngle);
            }
            else {
                intersectArray = this._renderMngr._pickFromRay(rayAngle, true, false, myLocation);
            }

            if (intersectArray.length > 0) {
                motionVector.set(0, 0, 0);
            }

            // if (this._renderMngr._pickFromRay(rayAngle).length > 0) {
            //     motionVector.set(0, 0, 0);
            // }

            nextCamPosition.set(currentCamPos.x, currentCamPos.y, currentCamPos.z);
            nextCamPosition.add(motionVector);

        } else { // Launch of a vertical ray along the body
            var nbOfTries = 2;
            do {
                var rayVertical = new STU.Ray();

                var motionVectNormalized = motionVector.clone();

                if (motionIsNotNull) {
                    motionVectNormalized.normalize();
                    motionVectNormalized.multiplyScalar(this._standHeight * this._cameraSizeRatio);
                }

                rayVertical.origin.x = currentCamPos.x + motionVectNormalized.x;
                rayVertical.origin.y = currentCamPos.y + motionVectNormalized.y;
                rayVertical.origin.z = currentCamPos.z + motionVectNormalized.z;

                rayVertical.direction.z = -1;
                rayVertical.setLength(this._standHeight * 1000);

                //var objBelowCam = this._renderMngr._pickFromRay(rayVertical);

                var objBelowCam;
                var myLocation = this._camera.getLocation();
                if (myLocation === null || myLocation === undefined) {
                    objBelowCam = this._renderMngr._pickFromRay(rayVertical);
                }
                else {
                    objBelowCam = this._renderMngr._pickFromRay(rayVertical, true, false, myLocation);
                }

                if (objBelowCam.length > 0) {
                    var camToObj = new DSMath.Vector3D();
                    camToObj.set(0, 0, nextCamPosition.z - objBelowCam[0].point.z);
                    var camToObjNorm = camToObj.norm();

                    if (this._jumpOffset > 0)
                    { this._fristTimeOnTheground = false; }

                    if (camToObjNorm > (currentHeight - this.maximumStepHeight) && camToObjNorm < currentHeight) {
                        nextCamPosition.z = objBelowCam[0].point.z + currentHeight + 3;
                        this._fristTimeOnTheground = true;
                        nbOfTries = 0;
                    }
                    else if (this.avoidFalls === true && camToObjNorm >= (currentHeight + this.maximumStepHeight) && this._jumpOffset === 0 && this._fristTimeOnTheground === true && motionIsNotNull) {

                        var rayStep = new STU.Ray();

                        rayStep.origin.x = rayVertical.origin.x;
                        rayStep.origin.y = rayVertical.origin.y;
                        rayStep.origin.z = nextCamPosition.z - currentHeight - this._standHeight * 0.01;

                        rayStep.direction.set(-motionVector.x, -motionVector.y, 0);

                        rayStep.setLength(this._standHeight * 0.2);

                        //var edge = this._renderMngr._pickFromRay(rayStep);
                        var edge;
                        var myLocation = this._camera.getLocation();
                        if (myLocation === null || myLocation === undefined) {
                            edge = this._renderMngr._pickFromRay(rayStep);
                        }
                        else {
                            edge = this._renderMngr._pickFromRay(rayStep, true, false, myLocation);
                        }

                        if (edge.length > 0) {

                            var n = edge[0].getNormal();
                            var motionDir = DSMath.Vector3D.cross(n, this._zWorld);
                            var motionDot = motionVector.dot(motionDir);

                            motionDir.multiplyScalar(motionDot);
                            motionVector.set(motionDir.x, motionDir.y, motionDir.z);

                            nextCamPosition.set(currentCamPos.x, currentCamPos.y, currentCamPos.z);
                            nextCamPosition.add(motionVector);
                        }
                    } else if (camToObjNorm > (currentHeight + 10000 * this._deltaTime) && this._jumpOffset === 0) {
                        nextCamPosition.z -= 10000 * this._deltaTime;
                        nbOfTries = 0;
                    }
                }
                nbOfTries = nbOfTries - 1;
            } while (nbOfTries > 0);
        }
    };

    /**
     * Makes to navigation go to a given point with a smooth transition.
     *
     * @public
     * @param  {STU.PointActor} iPoint Point to go to
     */
    FirstPersonNavigation.prototype.goTo = function(iPoint) {
        if (!(iPoint instanceof STU.PointActor)) {
            console.error('goTo can only go to a STU.PointActor');

        } else if (this._isFollowing === true) {
            console.warn('There is already a followPath transition going on. This call to FirstPersonNavigation.goTo will be ignored.');

        } else { // everything is OK => start goTo transition
            this._targetPointToGoTo = iPoint;
            this._targetCoordinateToGoTo = iPoint.getCoordinate();
            this._targetVirtualPointToGoTo = iPoint;
            this._isGoingTo = true;
            this._elapsedTimeGoTo = 0;
            this._timeToGoTo = 450 / (this.horizontalRotationSensitivity + this.verticalRotationSensitivity);
            // note that 450 / (100 + 200) = 1.5 so the transition will take 1.5s with default RotationSensitivity values
        }
    };

    /**
     * Performs the go to transition.
     *
     * @private
     * @param  {Number} iSpeed magnitude of the step
     * @param  {DSMath.Vector3D} oMotionVector  motion vector to modify
     * @param  {DSMath.Vector3D} iCurrentCamPos Current position of the camera
     */
    FirstPersonNavigation.prototype.handleGoTo = function(iSpeed, oMotionVector, iCurrentCamPos) {
        if (this._isGoingTo !== true) {return;}

        var dir = DSMath.Vector3D.sub(this._targetCoordinateToGoTo, iCurrentCamPos);
        dir.z = 0; // move only in X/Y plane

        var d2 = dir.squareNorm();

        if (d2 <= iSpeed*iSpeed) { // target reached
            oMotionVector.x = 0;
            oMotionVector.y = 0;
            oMotionVector.z = 0;

            this._isGoingTo = false;

            var evt = new STU.NavHasReachedEvent(this._targetVirtualPointToGoTo, this);
            this._camera.dispatchEvent(evt);
            this.dispatchEvent(new STU.ServiceStoppedEvent("goTo",this));
        } else {
            dir.normalize();

            oMotionVector.x = dir.x;
            oMotionVector.y = dir.y;
            oMotionVector.z = 0;
        }
    };

    /**
     * Makes the navigation look at a given actor with a smooth transition.
     *
     * @public
     * @param  {STU.Actor3D} iActor 3DActor to look at
     */
    FirstPersonNavigation.prototype.lookAt = function(iActor) {
        if (!(iActor instanceof STU.Actor3D)) {
            console.error('FirstPersonNavigation.lookAt can only look at an STU.Actor3D');

        } else {
            this._isLookingAt = true;
            this._lookAtTarget = iActor;
            this._lookAtElapsedTime = 0; // 0
            this._timeToLookAt = 450 / (this.horizontalRotationSensitivity + this.verticalRotationSensitivity);

            var camTransfo = this._camera.getTransform();
            this._lookAtStartQuat = new DSMath.Quaternion();
            camTransfo.matrix.getQuaternion(this._lookAtStartQuat);//this._lookAtStartQuat.rotMatrixToQuaternion(camTransfo.matrix); 
        }
    };

    /**
     * Performs the lookAt transition.
     *
     * @private
     */
    FirstPersonNavigation.prototype.handleLookAt = function() {
        if (this._isLookingAt === false) {return;}

        this._lookAtElapsedTime += this._deltaTime;
        var lerpAmount = this._lookAtElapsedTime / this._timeToLookAt;

        if (lerpAmount >= 1) {
            this._camera.lookAt(this._lookAtTarget.getPosition());
            this._isLookingAt = false;
        } else {
            var camTransform = this._camera.getTransform();

            var dir = DSMath.Vector3D.sub(this._lookAtTarget.getPosition(), camTransform.vector);
            dir.normalize();

            //Cameras are looking to -x
            dir.negate();

            // projecting the new sight direction on the ground to get a right direction parallel to the ground
            var dirOnGround = dir.clone();
            dirOnGround.z = 0;
            dirOnGround.normalize();

            // computing the right direction using the ground-projected sight direction
            /*var right = ThreeDS.Mathematics.cross({
                x: 0,
                y: 0,
                z: 1
            }, dirOnGround);*/
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
            mTargetLook.getQuaternion(endQuat);//endQuat.rotMatrixToQuaternion(mTargetLook);

            var intermediateQuat = DSMath.Quaternion.slerp(this._lookAtStartQuat, endQuat, lerpAmount);
            camTransform.matrix = intermediateQuat.getMatrix();//camTransform.matrix = intermediateQuat.quaternionToRotMatrix();

            this._camera.setTransform(camTransform);
        }
    };

    /**
     * Make the navigation follow a path.
     *
     * @public
     * @param  {STU.PathActor} iPath Path to follow
     */
    FirstPersonNavigation.prototype.followPath = function(iPath) {
        if (!(iPath instanceof STU.PathActor)) {
            console.error('FirstPersonNavigation.followPath can only follow a STU.PathActor');

        } else if (this._isGoingTo === true) {
            console.warn('There is already a goto transition going on. Follow path and goto are incompatible. This call to FirstPersonNavigation.followPath will be ignored.');

        } else {
            this._isFollowing = true;
            this._followedPath = iPath;
            this._followedPathLength = iPath.getLength();


            var initialStep = this.runSpeed * this._deltaTime;
            var pathAmount = initialStep / this._followedPathLength;
            console.log(this._followedPathLength);

            this._FPNextCheckPoint = iPath.getValue(pathAmount);
            this._followedPathDone = pathAmount;

            this._jumpOffset = 0;
            this._crouchOffset = 0;

            var pathStart = iPath.getValue(0);

            //Ray launch below path start to position the camera on the ground 
            {
                //Launch of an vertical ray to detect the ground
                var rayVect = new STU.Ray();

                rayVect.origin.x = pathStart.x;
                rayVect.origin.y = pathStart.y;
                rayVect.origin.z = pathStart.z;

                rayVect.direction.x = 0;
                rayVect.direction.y = 0;
                rayVect.direction.z = -1;

                rayVect.setLength(this._standHeight);

                var intersectArray = this._renderMngr._pickFromRay(rayVect);
                // if there is an object in front of camera
                if (intersectArray.length > 0) {
                    this._groundLevel = intersectArray[0].getPoint().z;

                } else {
                    this._groundLevel = this._camera.getPosition().z - this._standHeight;
                }

                var camStartPos = pathStart;
                camStartPos.z = this._standHeight + this._groundLevel;

                this._camera.setPosition(camStartPos); //start point
            }
        }
    };

    /**
     * Performs the path following.
     *
     * @private
     * @param  {DSMath.Vector3D} ioMotionVector     Motion vector to determine  the step length
     * @param  {DSMath.Vector3D} ioNextCamPosition Camera position
     */
    FirstPersonNavigation.prototype.handleFollowPath = function(ioMotionVector, iCurrentCamPos) {
        if (this._isFollowing === false) {return;}

        var camToTarget = DSMath.Vector3D.sub(this._FPNextCheckPoint, iCurrentCamPos);


        // Cam will follow the path regardless of z value
        camToTarget.z = 0;
        ioMotionVector.z = 0;

        var camToTargetLength = camToTarget.norm();
        var stepLength = ioMotionVector.norm();

        if (this._followedPathDone === 1) { // end of  the path
            this._isFollowing = false;

            //dispatch event 
            var evt = new STU.NavHasCompletedEvent(this._followedPath, this);
            this._camera.dispatchEvent(evt);
            this.dispatchEvent(new STU.ServiceStoppedEvent("followPath",this));

        } else if (camToTargetLength <= stepLength) { // cam is close enough from checkPoint, we define another one 
            var pathAmount = Math.min(stepLength / this._followedPathLength + this._followedPathDone, 1);

            this._followedPathDone = pathAmount;
            this._FPNextCheckPoint = this._followedPath.getValue(pathAmount);

            camToTarget = DSMath.Vector3D.sub(this._FPNextCheckPoint, iCurrentCamPos);
            camToTarget.z = 0;
            camToTargetLength = camToTarget.norm();
        }

        var scale = stepLength / camToTargetLength; // 0 div protection
        if (!isFinite(scale) || isNaN(scale)) {
            scale = 0;
        }

        ioMotionVector.x = camToTarget.x * scale;
        ioMotionVector.y = camToTarget.y * scale;

        // ioMotionVector.x = camToTarget.x;
        // ioMotionVector.y = camToTarget.y;
        // ioMotionVector.norm();

        // ioMotionVector.multiplyVector(stepLength);

    };


    /**
     * Returns true when the navigation is currently going to the given point.
     *
     * @public
     * @param  {STU.PointActor}  iPoint
     * @return {Boolean}
     */
    FirstPersonNavigation.prototype.isGoingTo = function(iPoint) {
        return this._isGoingTo && iPoint === this._targetPointToGoTo;
    };

    /**
     * Returns true when the navigation is currently following a given path.
     *
     * @public
     * @param  {STU.PathActor}  iPath
     * @return {Boolean}
     */
    FirstPersonNavigation.prototype.isFollowing = function(iPath) {
        return this._isFollowing && iPath === this._followedPath;
    };

    /**
     * Update method called each frames
     *
     * @method
     * @private
     */
    FirstPersonNavigation.prototype.update = function() {
        var forward = this._camera.getForward();
        var right = this._camera.getRight();

        var forwardZ0 = this._camera.getForward();
        forwardZ0.z = 0;
        forwardZ0.normalize();

        this.handleReticule();
        var nextCamPosition = null;

        // follow path takes care of webcam position
        var motionVector;
        var currentCamPos = this._camera.getPosition();


        // GoTo transition overrides direction keys
        if (this._isGoingTo === false) {
            if (this._isFollowing === true) {
                motionVector = new DSMath.Vector3D();
                motionVector.x = 1; // dummy vector to collect speed 

            } else {
                var axisX = this._inputManager.axis1.x;
                var axisY = this._inputManager.axis1.y;

                if (this.useGamepad) {
                    axisX += this._inputManager.axis3.x;
                    axisY += this._inputManager.axis3.y;
                }

                motionVector = DSMath.Vector3D.multiplyScalar(right, axisX);
                motionVector.add(DSMath.Vector3D.multiplyScalar(forwardZ0, axisY));

                if (motionVector.squareNorm() > 0) {
                    motionVector.normalize();
                }

            }
        }

        // Running is not possible once crouched.
        var speed;
        if (this._inputManager.buttonsState[STU.eInputTrigger.eTrigger3] && this._crouchOffset === 0) {
            speed = this.runSpeed;
        } else if (this._inputManager.buttonsState[STU.eInputTrigger.eTrigger2]) {
            speed = this.crouchSpeed;
        } else {
            speed = this.walkSpeed;
        }

        speed *= this._deltaTime;
        if (this._isGoingTo === true) {
            motionVector = new DSMath.Vector3D();
            this.handleGoTo(speed, motionVector, currentCamPos);
        }
        motionVector.multiplyScalar(speed);

        if (this._isFollowing === true) {
            this.handleFollowPath(motionVector, currentCamPos);
        }

        nextCamPosition = currentCamPos;
        nextCamPosition.add(motionVector);

        var currentHeight;
        if (this._crouchOffset > 0) { // we are crouched
            currentHeight = this._standHeight - this._crouchOffset * (this._standHeight - this.crouchHeight);
        } else { // we are standing or jumping
            currentHeight = this._standHeight + this._jumpOffset * this.crouchHeight;
        }

        this.handleCollision(motionVector, nextCamPosition, currentHeight);

        //no jumping and no crouching
        if (this._jumpOffset === 0 && this._crouchOffset === 0) {
            this._groundLevel = nextCamPosition.z - this._standHeight;
        }

        //crouching
        if (this._jumpOffset === 0) {
            //Update Crouch values
            this.handleCrouching();
            nextCamPosition.z = this._groundLevel + this._standHeight - this._crouchOffset * (this._standHeight - this.crouchHeight);
        }

        //jumping
        if (this._crouchOffset === 0) {
            //Update jump values
            this.handleJumping();
            nextCamPosition.z = this._groundLevel + this._standHeight + this._jumpOffset * this.crouchHeight;
        }



        this._camera.setPosition(nextCamPosition);


        //
        //Handle cam rotation
        //
        if (this._isLookingAt === true) {
            this.handleLookAt();
        } else {
            var deltaX = 0;
            var deltaY = 0;

            if ((this.navigateOnClick === false && this._isCursorInNeutralZone === false) ||
                (this.navigateOnClick === true && this._isMousePressed === true)) {

                // x and y movement during this frame
                var deltaX = this.followMouse === true ? (this._inputManager.axis2.x - this._lastMousePosition.x) / this._deltaTime : this._inputManager.axis2.x;
                var deltaY = this.followMouse === true ? (this._inputManager.axis2.y - this._lastMousePosition.y) / this._deltaTime : this._inputManager.axis2.y;

                this._lastMousePosition.x = this._inputManager.axis2.x;
                this._lastMousePosition.y = this._inputManager.axis2.y;
            }

            //manage gamepad inputs
            if (this.useGamepad === true) {
                var gamepadXAxis = this._inputManager.axis4.x * -1;
                var gamepadYAxis = this._inputManager.axis4.y * -1;

                deltaX += gamepadXAxis;
                deltaY += gamepadYAxis;
            }

            var camToTarget = new DSMath.Vector3D();

            var rightQuat = new DSMath.Quaternion();
            rightQuat.makeRotation(right, -deltaY * STU.Math.DegreeToRad * this.verticalRotationSensitivity * this._deltaTime);
            /*rightQuat.setRotationData({
                angle: -deltaY * STU.Math.DegreeToRad * this.verticalRotationSensitivity * this._deltaTime,
                vector: right
            });*/

            var zAxisQuat = new DSMath.Quaternion();
            zAxisQuat.makeRotation(this._zWorld, deltaX * STU.Math.DegreeToRad * this.horizontalRotationSensitivity * this._deltaTime);
            /*zAxisQuat.setRotationData({
                angle: deltaX * STU.Math.DegreeToRad * this.horizontalRotationSensitivity * this._deltaTime,
                vector: this._zWorld
            });*/

            var composedRotQuat = DSMath.Quaternion.multiply(rightQuat, zAxisQuat);

            var forwardPoint = new DSMath.Point();
            forwardPoint.set(forward.x, forward.y, forward.z);
            var camToTargetPoint = forwardPoint.applyQuaternion(composedRotQuat);//var camToTargetPoint = composedRotQuat.rotate(forwardPoint);
            camToTarget.set(camToTargetPoint.x, camToTargetPoint.y, camToTargetPoint.z);

            //avoid rotation glitches
            if (Math.abs(camToTarget.z) > 0.999) {

                forwardPoint.set(forward.x, forward.y, forward.z);
                camToTargetPoint = forwardPoint.applyQuaternion(zAxisQuat);//camToTargetPoint = zAxisQuat.rotate(forwardPoint);
                camToTarget.set(camToTargetPoint.x, camToTargetPoint.y, camToTargetPoint.z);
            }
            var lookAtPosition = new DSMath.Vector3D();
            lookAtPosition.set(nextCamPosition.x + camToTarget.x, nextCamPosition.y + camToTarget.y, nextCamPosition.z + camToTarget.z);
            this._camera.lookAt(lookAtPosition);
            //}
        }

        return this;
    };

    // Expose in STU namespace.
    STU.FirstPersonNavigation = FirstPersonNavigation;

    return FirstPersonNavigation;
});

define('StuCameras/StuFirstPersonNavigation', ['DS/StuCameras/StuFirstPersonNavigation'], function (FirstPersonNavigation) {
    'use strict';

    return FirstPersonNavigation;
});

define('DS/StuMiscContent/StuMotion',
    ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPEventServices/EPEvent', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPTaskPlayer/EPTaskPlayer', 'MathematicsES/MathsDef'],
    function (STU, Behavior, Event, Task, EventServices, TaskPlayer, DSMath) {
        'use strict';

		/**
		 * MOTION HANDLER TASK.
		 * @private
		 */
        var MotionTask = function (motionHandler) {
            Task.call(this);
            this.motionHandler = motionHandler;
        };

        MotionTask.prototype = new Task();
        MotionTask.constructor = MotionTask;

	    /**
		 * Method called each frame by the task manager
		 *
		 * @method
		 * @private
		 * @param  iExeCtx Execution context
		 */
        MotionTask.prototype.onExecute = function (iExeCtx) {

            if (this.motionHandler === undefined || this.motionHandler === null) {
                return this;
            }
            var motionHandler = this.motionHandler;

            motionHandler.update(iExeCtx.getDeltaTime() / 1000);
        };

	    /**
		 * This event is thrown when a actor has reached a target
		 *
		 *
		 * @exports MotionHasReachedEvent
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 * @alias STU.MotionHasReachedEvent
		 */
        var MotionHasReachedEvent = function (iTarget, iActor) {
            Event.call(this);

	        /**
			 * The target that has been reached by the actor
			 * @public
			 * @type {STU.Actor}
			 */
            this.targetActor = iTarget !== undefined ? iTarget : null;

	        /**
			 * The STU.Actor that has reached the target
			 * @public
			 * @type {STU.Actor}
			 */
            this.actor = iActor !== undefined ? iActor : null;
        };

        MotionHasReachedEvent.prototype = new Event();
        MotionHasReachedEvent.prototype.constructor = MotionHasReachedEvent;
        MotionHasReachedEvent.prototype.type = 'MotionHasReachedEvent';

        // Expose in STU namespace
        STU.MotionHasReachedEvent = MotionHasReachedEvent;
        EventServices.registerEvent(MotionHasReachedEvent);

	    /**
		 * This event is thrown when an actor begins to move towards a target
		 *
		 * @exports MotionIsGoingToEvent
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 * @alias STU.MotionIsGoingToEvent
		 *
		 */
        var MotionIsGoingToEvent = function (iTarget, iActor) {
            Event.call(this);

	        /**
			 * The target that will be reached by the actor
			 * @public
			 * @type {STU.Actor}
			 */
            this.targetActor = iTarget !== undefined ? iTarget : null;

	        /**
			 * The actor that will reached the target
			 * @public
			 * @type {STU.Actor}
			 */
            this.actor = iActor !== undefined ? iActor : null;
        };

        MotionIsGoingToEvent.prototype = new Event();
        MotionIsGoingToEvent.prototype.constructor = MotionIsGoingToEvent;
        MotionIsGoingToEvent.prototype.type = 'MotionIsGoingToEvent';

        // Expose in STU namespace.
        STU.MotionIsGoingToEvent = MotionIsGoingToEvent;
        EventServices.registerEvent(MotionIsGoingToEvent);

	    /**
		 * This event is thrown when an actor begins to follow a path
		 *
		 * @exports MotionIsfollowingEvent
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 * @alias STU.MotionIsfollowingEvent
		 */
        var MotionIsfollowingEvent = function (iPath, iActor) {
            Event.call(this);


	        /**
			 * The path that the STU.Actor will follow
			 * @public
			 * @type {STU.PathActor}
			 */
            this.path = iPath !== undefined ? iPath : null;

	        /**
			 * The STU.Actor that has started following the path
			 * @public
			 * @type {STU.Actor}
			 */
            this.actor = iActor !== undefined ? iActor : null;

        };

        MotionIsfollowingEvent.prototype = new Event();
        MotionIsfollowingEvent.prototype.constructor = MotionIsfollowingEvent;
        MotionIsfollowingEvent.prototype.type = 'MotionIsfollowingEvent';

        // Expose in STU namespace.
        STU.MotionIsfollowingEvent = MotionIsfollowingEvent;
        EventServices.registerEvent(MotionIsfollowingEvent);

	    /**
		 * This event is thrown when an actor has reached the end of a path
		 *
		 * @exports MotionHasCompletedEvent
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 * @alias STU.MotionHasCompletedEvent
		 */
        var MotionHasCompletedEvent = function (iPath, iActor) {
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

        MotionHasCompletedEvent.prototype = new Event();
        MotionHasCompletedEvent.prototype.constructor = MotionHasCompletedEvent;
        MotionHasCompletedEvent.prototype.type = 'MotionHasCompletedEvent';

        // Expose in STU namespace.
        STU.MotionHasCompletedEvent = MotionHasCompletedEvent;
        EventServices.registerEvent(MotionHasCompletedEvent);



	    /**
		 * This event is thrown when an actor has reached the end of a path
		 *
		 * @exports MotionHasLookedAtEvent
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 * @alias STU.MotionHasLookedAtEvent
		 */
        var MotionHasLookedAtEvent = function (iActor) {
            Event.call(this);

	        /**
			 * The STU.Actor that has been looked at 
			 *
			 * @type {STU.Actor}
			 * @public
			 * @default
			 */
            this.targetActor = iActor !== undefined ? iActor : null;
        };

        MotionHasLookedAtEvent.prototype = new Event();
        MotionHasLookedAtEvent.prototype.constructor = MotionHasLookedAtEvent;
        MotionHasLookedAtEvent.prototype.type = 'MotionHasLookedAtEvent';

        // Expose in STU namespace.
        STU.MotionHasLookedAtEvent = MotionHasLookedAtEvent;
        EventServices.registerEvent(MotionHasLookedAtEvent);

	    /**
		 * Describe a Motion behavior
		 *
		 * @exports Motion
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
         * @alias STU.Motion
		 */
        var Motion = function () {

            Behavior.call(this);
            this.name = 'Motion';

            this.associatedTask;

	        /**
			 * Motion speed in m/s
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
            this.speed = 1.7;

            this.lookAtSpeed = 3.1415926; // 1.5708; //0.78; //1.5708;
            this.direction = 0; // { 0: "x", 1: "-x", 2: "y", 3: "-y", 4: "z", 5: "-z"}
            this.smooth = true;

	        /**
			 * Target to reach
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
            this._goToTarget = null;

	        /**
			 * Target to look at
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
            this._lookAtTarget = null;


	        /**
			 * go to pause indicator
			 *
			 * @member
			 * @private
			 * @type {Boolean}
			 */
            this._goToPaused = false;

	        /**
			 * Target to lookat position
			 *
			 * @member
			 * @private
			 * @type {DSMath.Vector3D}
			 */
            this._lookAtPosition = null;

	        /**
			 * Scalar used during the look at transition
			 *
			 * @member
			 * @private
			 * @type {Number}
			 */
            this._lookAtStartAngle = 0;
            this._lookAtTimeAmount = 0;
            this._lookAtTargetQuat = [0, 0, 0, 0];


	        /**
			 * LookAt pause indicator
			 *
			 * @member
			 * @private
			 * @type {Boolean}
			 */
            this._lookAtPaused = false;

	        /**
			 * Follow path target
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
            this._pathTarget = null;

	        /**
			 * Follow path pause indicator
			 *
			 * @member
			 * @private
			 * @type {Boolean}
			 */
            this._followPathPaused = false;

	        /**
			 * Amount of path already done [0:1]
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
            this._pathAmount = 0;

	        /**
			 * Scalar used during path transition
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
            this._pathTransition = 0;


	        /**
			 * Define if the path is a PathActor or an array of point
			 *
			 * @member
			 * @private
			 * @type {Boolean}
			 */
            this._pathIsAnArray = false;

	        /**
			 * Define the index of the pathArray's current point
			 *
			 * @member
			 * @private
			 * @type {Number}
			 */
            this._currentPoint = 0;

	        /**
			 * Define the current time beetwen 2 point of the pathArray
			 *
			 * @member
			 * @private
			 * @type {Number}
			 */
            this._currentTime = 0;

	        /**
			 * Temporary variable wich contains the last right vector of the object(follow path)
			 *
			 * @member
			 * @private
			 * @type {DSMath.Vector3D}
			 */
            this._previousRightVector = null;
            this._frameStepBuffer = [];
        };



        Motion.prototype = new Behavior();
        Motion.prototype.constructor = Motion;
        Motion.prototype.protoId = 'D06B03E2-FFBF-4ACA-9752-7EE3D2B7836E';
        Motion.prototype.pureRuntimeAttributes = ['_goToTarget', '_lookAtTarget', '_lookAtPosition',
            '_pathTarget', '_pathAmount', '_pathTransition'
        ].concat(Behavior.prototype.pureRuntimeAttributes);


	    /**
		 * Brings the actor holding the motion behavior to another actor.
		 * Note that the transition is done linearly
		 *
		 * @method
		 * @public
		 * @param   {STU.Actor3D} iTarget Target to reach
		 */
        Motion.prototype.goTo = function (iTarget) {
            if (iTarget instanceof STU.Actor3D) {
                this._goToTarget = iTarget;
            } else {
                this._goToTarget = null;
            }

        };

	    /**
		 * Returns true when the actor holding the motion behavior is currently going to the given actor.
		 *
		 * @public
		 * @param  {STU.Actor3D}  iActor
		 * @return {Boolean}
		 */
        Motion.prototype.isGoingTo = function (iTarget) {
            return iTarget !== undefined && iTarget !== null && iTarget === this._goToTarget;
        };

	    /**
		 * Returns true when the actor holding the motion behavior is currently going to somewhere.
		 *
		 * @public
		 * @return {Boolean}
		 */
        Motion.prototype.isGoingSomewhere = function () {
            return this._goToTarget !== undefined && this._goToTarget !== null;
        };
	    /**
		 * Put the go to action in pause
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.pauseGoTo = function () {
            this._goToPaused = true;
        };

	    /**
		 * Put the go to action in play after a pause
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.resumeGoTo = function () {
            this._goToPaused = false;
        };

	    /**
		 * stop the go to action
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.stopGoTo = function () {
            this._goToPaused = false;
            this._goToTarget = null;
            this._goToPosition = null;
        };

	    /**
		 * Turns the actor holding the motion behavior toward another actor.
		 * Note that the transition is done linearly
		 *
		 * @method
		 * @public
		 * @param   {STU.Actor3D} iTarget Target to look at
		 */
        Motion.prototype.lookAt = function (iTarget) {

            if (iTarget instanceof STU.Actor3D) {
                this._lookAtTarget = iTarget;
                this._lookAtPosition = iTarget.getPosition();
            } else {
                this._lookAtTarget = null;
            }
        };

	    /**
		 * Returns true when the actor is looking at something
		 *
		 * @method
		 * @public
		 * @return {Boolean}
		 */
        Motion.prototype.isLookingAt = function () {
            return this._lookAtTarget !== undefined && this._lookAtTarget !== null && this._lookAtPosition !== undefined && this._lookAtPosition !== null;
        };

	    /**
		 * Put the look at action in pause
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.pauseLookAt = function () {
            this._lookAtPaused = true;
        };

	    /**
		 * Put the look at action in play after a pause
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.resumeLookAt = function () {
            this._lookAtPaused = false;
        };

	    /**
		 * stop the look at action
		 *
		 * @method
		 * @public
		 */
        Motion.prototype.stopLookAt = function () {
            this._lookAtPaused = false;
            this._lookAtTarget = null;
            this._lookAtPosition = null;
        };

	    /**
		 * Makes the actor holding the motion behavior follow a path
		 *
		 * @method
		 * @public
		 * @param   {(STU.PathActor | DSMath.Point[] | DSMath.Vector3D[])}    iPath Path to follow 
		 * 
		 */
        Motion.prototype.followPath = function (iPath) {

            if (iPath instanceof STU.PathActor) {
                this._pathTarget = iPath;
            }
            else if (Array.isArray(iPath)) {
                var valid = true;
                iPath.forEach(function (currentValue) {
                    var goodType = currentValue instanceof DSMath.Vector3D || currentValue instanceof DSMath.Point;
                    if (!goodType) {
                        valid = false;
                    }
	                /*var rm = STU.RenderManager.getInstance();
	                var t = new DSMath.Transformation();
	                t.vector = currentValue;
	                rm.createSphere({ position: t, color: new STU.Color(255, 0, 0), alpha: 128, size: 0, radius: 250, lifetime: -1 });*/
                }, this);
                this._pathTarget = valid ? iPath : null;
                this._pathIsAnArray = valid;
                if (valid === false) {
                    console.error("[Motion] All element of the array should be instance of DSMath.Vector3D or DSMath.Point");
                }
            }
            else {
                this._pathTarget = null;
                console.error("[Motion] Path undefined");
            }

            this._pathAmount = 0;
        };

	    /**
		 * Returns true when the motion behavior is currently following a given path.
		 *
		 * @public
		 * @param  {STU.PathActor}  iPath
		 * @return {Boolean}
		 */
        Motion.prototype.isFollowing = function (iPath) {
            return iPath !== undefined && iPath !== null && iPath === this._pathTarget;
        };

	    /**
		 * Returns true when the motion behavior is currently following a path.
		 *
		 * @public
		 * @return {Boolean}
		 */
        Motion.prototype.isFollowingAPath = function () {
            if (this._pathIsAnArray) {
                return this._pathTarget !== undefined && this._pathTarget !== null && this._currentPoint !== undefined && this._currentPoint >= 0;
            }
            else {
                return this._pathTarget !== undefined && this._pathTarget !== null && this._pathAmount !== undefined && this._pathAmount > 0;
            }
        };

	    /**
		 * Put the follow path action in pause
		 *
		 * @public
		 */
        Motion.prototype.pauseFollowPath = function () {
            this._followPathPaused = true;
        };

	    /**
		 * Put the follow path action in play after a pause
		 *
		 * @public
		 */
        Motion.prototype.resumeFollowPath = function () {
            this._followPathPaused = false;
        };

	    /**
		 * Stop following path
		 *
		 * @public
		 */
        Motion.prototype.stopFollowPath = function () {
            this._pathTarget = null;
            this._followPathPaused = false;
        };




	    /**
		 * Compute the look at transform from the front vector and the actor transform
		 *
		 * @method
		 * @private
		 * @param   {DSMath.Vector3D}      iFront Vector pointing the actor look at
		 * @param   {STU.Actor3D}                       iActor Actor to look at
		 */
        Motion.prototype._computeLookAtTransform = function (iFront, iActor) {

            var dir = iFront.clone();
            // dir.subVectorFromVector(actorPosition);
            dir.normalize();

            // projecting the new sight direction on the ground to get a right direction parallel to the ground
            var dirOnGround = dir.clone();
            dirOnGround.z = 0;
            dirOnGround.normalize();

            // computing the right direction using the ground-projected sight direction
            //var ZWorld = new DSMath.Vector3D(0, 0, 1);
            var scene = this.actor.getLocation();
            var ZWorld = (scene !== null && scene !== undefined) ? scene.getTransform().matrix.getThirdColumn().normalize() : new DSMath.Vector3D(0, 0, 1);

            var right = DSMath.Vector3D.cross(ZWorld, dirOnGround);
            right.normalize();

            //[IR-462100] To avoid changing the right vector orientation when the next direction is the opposite of the current direction.
            if (this._previousRightVector !== null && this._previousRightVector !== undefined) {
                var angle = this._previousRightVector.getAngleTo(right);
                if (angle >= Math.PI) {
                    right = this._previousRightVector.clone();
                }
            }
            this._previousRightVector = right.clone();


            // computing the up direction as usual
            var up = DSMath.Vector3D.cross(dir, right);
            up.normalize();

            // updating the transform
            var transform = iActor.getTransform();
            var matrix = transform.matrix;
            var actorScale = matrix.getFirstColumn().norm();

            var qCurrent = new DSMath.Quaternion();
            matrix.getQuaternion(qCurrent);

            var mTargetLook = new DSMath.Matrix3x3();
	        /*mTargetLook.setFromArray([
				dir.x, right.x, up.x,
				dir.y, right.y, up.y,
				dir.z, right.z, up.z
	        ]);*/

            if (this.direction === 0) { // X
                mTargetLook.setFromArray([
                    dir.x, right.x, up.x,
                    dir.y, right.y, up.y,
                    dir.z, right.z, up.z
                ]);
            }
            else if (this.direction === 1) { // -X
                mTargetLook.setFromArray([
                    -dir.x, -right.x, up.x,
                    -dir.y, -right.y, up.y,
                    -dir.z, -right.z, up.z
                ]);
            }
            else if (this.direction === 2) { // Y
                mTargetLook.setFromArray([
                    -right.x, dir.x, up.x,
                    -right.y, dir.y, up.y,
                    -right.z, dir.z, up.z
                ]);
            }
            else if (this.direction === 3) { // -Y
                mTargetLook.setFromArray([
                    right.x, -dir.x, up.x,
                    right.y, -dir.y, up.y,
                    right.z, -dir.z, up.z
                ]);
            }
            else if (this.direction === 4) { // Z
                mTargetLook.setFromArray([
                    right.x, up.x, dir.x,
                    right.y, up.y, dir.y,
                    right.z, up.z, dir.z
                ]);
            }
            else if (this.direction === 5) { // -Z
                mTargetLook.setFromArray([
                    -right.x, up.x, -dir.x,
                    -right.y, up.y, -dir.y,
                    -right.z, up.z, -dir.z
                ]);
            }

            var qTargetLook = new DSMath.Quaternion();
            mTargetLook.getQuaternion(qTargetLook);

            qTargetLook.getMatrix(transform.matrix);


            if (Math.abs(actorScale - 1) > 10e-10) {
                transform.matrix.multiplyScalar(actorScale);
            }

            iActor.setTransform(transform);
        };

        //Unused function, put it under comment to improve the coverage
	    /*Motion.prototype.getCorrespondingTime = function (iValue, iEasingEnum, iBeginning, iChangeInValue, iDuration) {
	        var maxLoop = 100;
	        var eps = 0.001;

	        var startTime = 0;
	        var endTime = iDuration;

	        var isIncreasing = iChangeInValue >= 0 ? true : false;

	        var currentTime = 0;
	        var res = -1;
	        do {
	            currentTime = (startTime + endTime) / 2;
	            res = STU.ease(iEasingEnum, currentTime, iBeginning, iChangeInValue, iDuration);
	            if (Math.abs(res - iValue) <= eps) {
	                break;
	            } else if (isIncreasing && res > iValue ||
					!isIncreasing && res < iValue) {
	                endTime = currentTime;
	            } else {
	                startTime = currentTime;
	            }
	        } while (--maxLoop > 0);

	        return currentTime;
	    };*/

	    /**
		 * Update method called each frames
		 *
		 * @method
		 * @private
		 * @param   {Number} iElapsedTime Time elapsed since last frame
		 */
        Motion.prototype.update = function (iElapsedTime) {

            //Go to
            if (undefined !== this._goToTarget && null !== this._goToTarget && !this._goToPaused) {
                var actor = this.getActor();
                var scale = actor.getScale("World");
                var frameStep = this.speed * 1000 * iElapsedTime * scale;
                //console.log(scale);

                var actorPos = actor.getPosition("World");
                var targetPos = this._goToTarget.getPosition("World");

                var actorToTarget = DSMath.Vector3D.sub(targetPos, actorPos);
                var actorToTargetD2 = actorToTarget.squareNorm();

                if (actorToTargetD2 > frameStep * frameStep) {
                    actorToTarget.multiplyScalar(frameStep / Math.sqrt(actorToTargetD2)); // normalize and scale
                    actorPos.add(actorToTarget);
                    actor.setPosition(actorPos, "World");
                    //return; // M1Q : why return here ? it blocks multiple capacities running in parallel for motion
                } else { // target reached
                    var evt = new MotionHasReachedEvent(this._goToTarget, actor);

                    actor.setPosition(targetPos, "World");
                    this._goToTarget = null;

                    actor.dispatchEvent(evt);

                    // Send event service finished
                    this.dispatchEvent(new STU.ServiceStoppedEvent("goesTo", this));
                }
            }

            //Look at
            if (undefined !== this._lookAtTarget && null !== this._lookAtTarget && !this._lookAtPaused) {
                //var ZWorld = new DSMath.Vector3D(0, 0, 1);
                var scene = this.actor.getLocation();
                var ZWorld = (scene !== null && scene !== undefined) ? scene.getTransform().matrix.getThirdColumn().normalize() : new DSMath.Vector3D(0, 0, 1);

                var actor = this.getActor();
                var actorPosition = actor.getPosition();
                var targetPos = this._lookAtTarget.getPosition();

                var dir = targetPos.clone();
                dir.sub(actorPosition);
                dir.normalize();

                //checking that the actor is far enough from the target to compute referential 
                if (isFinite(dir.x) && !isNaN(dir.x) &&
                    isFinite(dir.y) && !isNaN(dir.y) &&
                    isFinite(dir.z) && !isNaN(dir.z)) {

                    var lookAtDirection = this.direction; //{ 0: "x", 1: "-x", 2: "y", 3: "-y", 4: "z", 5: "-z"}

                    if (actor instanceof STU.Camera) {
                        //Cameras are looking to -x
                        this.direction = 1;
                        dir.negate();
                    } else if (lookAtDirection % 2 === 1) { // An axis has to be inverted ; odd index
                        dir.negate();
                    }

                    // projecting the new sight direction on the ground to get a right direction parallel to the ground
                    var dirOnGround = dir.clone();
                    dirOnGround.z = 0;
                    dirOnGround.normalize();

                    // computing the right direction using the ground-projected sight direction
                    var right = DSMath.Vector3D.cross(ZWorld, dirOnGround);
                    right.normalize();

                    // computing the up direction as usual
                    var up = DSMath.Vector3D.cross(dir, right);
                    up.normalize();

                    // updating the transform
                    var transform = actor.getTransform();
                    var matrix = transform.matrix;
                    var actorScale = matrix.getFirstColumn().norm();
                    if (Math.abs(actorScale - 1) > 10e-10) {
                        matrix.multiplyScalar(1 / actorScale);
                    }

                    var qCurrent = new DSMath.Quaternion();
                    matrix.getQuaternion(qCurrent);//qCurrent.rotMatrixToQuaternion(matrix);

                    var mTargetLook = new DSMath.Matrix3x3();

                    //{ 0: "x", 1: "-x", 2: "y", 3: "-y", 4: "z", 5: "-z"}
                    if (lookAtDirection <= 1) { // X axis
                        mTargetLook.setFromArray([
                            dir.x, right.x, up.x,
                            dir.y, right.y, up.y,
                            dir.z, right.z, up.z,
                        ]);
                    } else if (lookAtDirection <= 3) { // Y axis
                        mTargetLook.setFromArray([
                            up.x, dir.x, right.x,
                            up.y, dir.y, right.y,
                            up.z, dir.z, right.z,
                        ]);
                    } else { // Z axis
                        mTargetLook.setFromArray([
                            right.x, up.x, dir.x,
                            right.y, up.y, dir.y,
                            right.z, up.z, dir.z,
                        ]);
                    }

                    var qTargetLook = new DSMath.Quaternion();
                    mTargetLook.getQuaternion(qTargetLook);//qTargetLook.rotMatrixToQuaternion(mTargetLook);

                    var q1Array = qCurrent.getArray();
                    var q2Array = qTargetLook.getArray();
                    var angle = Math.acos(q1Array[0] * q2Array[0] + q1Array[1] * q2Array[1] + q1Array[2] * q2Array[2] + q1Array[3] * q2Array[3]) * 2;

                    angle = angle > Math.PI ? 2 * Math.PI - angle : angle;

                    var speed = this.lookAtSpeed / angle;
                    var step = iElapsedTime * speed;

                    var targetQuat = this._lookAtTargetQuat;
                    if (this.smooth === true) {
                        if (this._lookAtStartAngle === 0 ||
                            q2Array[0] !== targetQuat[0] || q2Array[1] !== targetQuat[1] ||
                            q2Array[2] !== targetQuat[2] || q2Array[3] !== targetQuat[3]) {

                            this._lookAtStartAngle = angle;
                            this._lookAtTimeAmount = 0;
                            this._lookAtTargetQuat = q2Array;
                        }
                        var duration = 2 * this._lookAtStartAngle / this.lookAtSpeed; // ! \\ Specific to STU.eEasing.OutQuad 

                        var currentTime = (this._lookAtTimeAmount += iElapsedTime);
                        var nextAngle = this._lookAtStartAngle - STU.ease(STU.eEasing.OutQuad, currentTime, 0, this._lookAtStartAngle, duration);
                        step = (angle - nextAngle) / angle;
                    }
                    step = Math.min(1, step);

                    if (isNaN(step) || step === 1 || Math.abs(angle) < 0.001 || step < 0) {
                        // Notify listeners the end of lookAt transition 
                        var evt = new MotionHasLookedAtEvent(this._lookAtTarget);
                        actor.dispatchEvent(evt);
                        if (undefined === this._pathTarget || null === this._pathTarget) { //[IR-671873] In case where we combine the look at fcapacity with the follow path capacity
                            this._lookAtTarget = null;
                        }
                        this._lookAtStartAngle = 0;
                        this._lookAtTimeAmount = 0;
                        step = 1;
                        this.dispatchEvent(new STU.ServiceStoppedEvent("lookAt", this));
                    }

                    // No slerp when using with a follow path
                    // if (undefined === this._pathTarget || null === this._pathTarget) {
                    //transform.matrix = DSMath.Quaternion.slerp(qCurrent, qTargetLook, step).quaternionToRotMatrix();
                    var tmpQ = DSMath.Quaternion.slerp(qCurrent, qTargetLook, step);
                    tmpQ.getMatrix(transform.matrix);
                    // } else {
                    //     transform.matrix = qTargetLook.quaternionToRotMatrix();
                    // }

                    if (Math.abs(actorScale - 1) > 10e-10) {
                        transform.matrix.multiplyScalar(actorScale);
                    }

                    actor.setTransform(transform);
                } else {
                    this._lookAtTarget = null;
                    this.dispatchEvent(new STU.ServiceStoppedEvent("lookAt"));
                }

            }

            //Follow path (PathActor)
            if (undefined !== this._pathTarget && null !== this._pathTarget && !this._followPathPaused && !this._pathIsAnArray) {
                var actor = this.getActor();
                var scale = actor.getScale("World");
                var pathLength = this._pathTarget.getLength();
                var frameStep = this.speed * 1000 * iElapsedTime;

                //begining of path folowing
                if (this._pathAmount === 0) {
                    var evt = new MotionIsfollowingEvent(this._pathTarget, actor);

                    actor.dispatchEvent(evt);
                }

                this._pathAmount = Math.min(1, this._pathAmount + frameStep / pathLength);

                //var actorPos = this._pathTarget.getValue(this._pathAmount);
                //actor.setPosition(actorPos, "World");
                //On check si l'on est sous une location
                var scene = this.actor.getLocation();

                //position world (en mm) -> to be fixed in pathActor binding
                var pathPoint = (scene !== null && scene !== undefined) ? this._pathTarget.getValue(this._pathAmount, scene) : this._pathTarget.getValue(this._pathAmount);

	            /*if (scene !== null && scene !== undefined) {
	                //var actorTransformScene = scene.getTransform();                // dans le repere scene
	                var sceneTransformWorld = scene.getTransform("World");         // pos de la scene dans le repere monde
	                var SceneToWorldScaling = sceneTransformWorld.getScaling().scale; // / actorTransformScene.getScaling().scale;
	                if (SceneToWorldScaling <= 0.0) {
	                    SceneToWorldScaling = 1.0;
	                }

	                //console.log(SceneToWorldScaling);
	                //position world (en m) : vrai position world
	                
	                var pathPointPosScaled = pathPoint.multiplyScalar(SceneToWorldScaling);
	                var invSceneTransformWorld = sceneTransformWorld.getInverse();
	                var Mypt = new DSMath.Point(pathPointPosScaled.x, pathPointPosScaled.y, pathPointPosScaled.z);
	                Mypt.applyTransformation(invSceneTransformWorld);
	                pathPoint.setFromPoint(Mypt);

	            }*/

                actor.setPosition(pathPoint);

                //set front vector tangent to path if no look at has been defined
                if (undefined === this._lookAtTarget || null === this._lookAtTarget) {
                    //var actorPosEps = this._pathTarget.getValue(Math.min(1, this._pathAmount + 10 * frameStep / pathLength));
                    //var frontVect = DSMath.Vector3D.sub(actorPosEps, actorPos);

                    //Checking that we are or not in a globe coontext
                    var scene = this.actor.getLocation();
                    var actorPosWorld = (scene !== null && scene !== undefined) ? this._pathTarget.getValue(this._pathAmount, scene) : this._pathTarget.getValue(this._pathAmount);
                    //var actorPosEpsWorld = (scene !== null && scene !== undefined) ? this._pathTarget.getValue(Math.min(1, this._pathAmount + (10 * scale * frameStep) / pathLength), scene) : this._pathTarget.getValue(Math.min(1, this._pathAmount + 10 * frameStep / pathLength));

                    // [IR-678953] Look at position is calculated in function of the speed of our actor that is frame dependent. 
                    // The value seems to be multiply by in order to estimate the position of the actor in ten unit of time
                    // In Globe, the duration of each frame can vary a lot, that leads to weird behavior as we doesn't look at the same distance each frame.
                    // In order to correct that we smooth the computed value, until we solve our performance issue on globe. 
                    var smoothIteration = 10;

                    var step = (scene !== null && scene !== undefined) ? (10 * scale * frameStep) : (10 * frameStep);
                    this._frameStepBuffer.push(step);

                    if (this._frameStepBuffer.length > smoothIteration) {
                        this._frameStepBuffer.pop();
                    }
                    var averageStepValue = 0;
                    for (var i = 0; i < this._frameStepBuffer.length; i++) {
                        averageStepValue += this._frameStepBuffer[i];
                    }
                    averageStepValue = averageStepValue / this._frameStepBuffer.length;
                    var actorPosEpsWorld = (scene !== null && scene !== undefined) ? this._pathTarget.getValue(Math.min(1, this._pathAmount + averageStepValue / pathLength), scene) : this._pathTarget.getValue(Math.min(1, this._pathAmount + averageStepValue / pathLength));


                    var frontVect = DSMath.Vector3D.sub(actorPosEpsWorld, actorPosWorld);

                    if (frontVect.squareNorm() > 10e-4) {
                        this._computeLookAtTransform(frontVect, actor);
                    }
                }

                //Path end
                if (this._pathAmount === 1) {
                    var evt = new MotionHasCompletedEvent(this._pathTarget, actor);
                    actor.dispatchEvent(evt);
                    this._pathAmount = 0;
                    this._pathTarget = null;
                    this.dispatchEvent(new STU.ServiceStoppedEvent("followPath", this));
                }
            }

            //Follow path (Array of point)
            if (undefined !== this._pathTarget && null !== this._pathTarget && !this._followPathPaused && this._pathIsAnArray) {
                var actor = this.getActor();

                //begining of path folowing
                if (this._currentTime === 0 && this._currentPoint === 0) {
                    //console.log("Start");
                    var evt = new MotionIsfollowingEvent(this._pathTarget, actor);
                    actor.dispatchEvent(evt);
                }

                this._currentTime += iElapsedTime;

                var time;
                if (this._currentPoint < this._pathTarget.length - 1) {
                    var v1 = new DSMath.Vector3D(this._pathTarget[this._currentPoint].x, this._pathTarget[this._currentPoint].y, this._pathTarget[this._currentPoint].z);
                    var v2 = new DSMath.Vector3D(this._pathTarget[this._currentPoint + 1].x, this._pathTarget[this._currentPoint + 1].y, this._pathTarget[this._currentPoint + 1].z);

                    var distance = DSMath.Vector3D.sub(v2, v1).norm();
                    time = (distance / this.speed) * 0.001;

                    //set front vector tangent to path if no look at has been defined
                    if (undefined === this._lookAtTarget || null === this._lookAtTarget) {
                        var actorDirection = actor.getTransform().matrix.getFirstColumn().clone().normalize();
                        var direction = DSMath.Vector3D.sub(v2, actor.getPosition()).normalize();
                        var frontVect = DSMath.Vector3D.lerp(actorDirection, direction, this._currentTime / time);
                        this._computeLookAtTransform(frontVect, actor);
                    }

                    //Movement
                    var actorPos = DSMath.Vector3D.lerp(v1, v2, this._currentTime / time);
                    actor.setPosition(actorPos);
                }

                if (this._currentTime > time) {
                    if (this._currentPoint < this._pathTarget.length - 1) {
                        this._currentTime = 0;
                        this._currentPoint++;
                    }
                    else {
                        this._currentTime = time;
                    }
                }

                //Path end
                if (this._currentTime === 0 && this._currentPoint === this._pathTarget.length - 1) {
                    var evt = new MotionHasCompletedEvent(this._pathTarget, actor);
                    actor.dispatchEvent(evt);
                    this._pathAmount = 0;
                    this._pathTarget = null;
                    this.dispatchEvent(new STU.ServiceStoppedEvent("followPath", this));
                    //console.log("Stop");
                }
            }
        };

	    /**
		 * Process executed when STU.Motion is activating
		 * @private
		 * @method
		 */
        Motion.prototype.onActivate = function () {
            Behavior.prototype.onActivate.call(this);

            this.associatedTask = new MotionTask(this);
            TaskPlayer.addTask(this.associatedTask);
        };

	    /**
		 * Process executed when STU.Motion is deactivating
		 * @private
		 * @method
		 */
        Motion.prototype.onDeactivate = function () {
            TaskPlayer.removeTask(this.associatedTask);
            delete this.associatedTask;

            Behavior.prototype.onDeactivate.call(this);
        };


        // Expose in STU namespace.
        STU.Motion = Motion;

        return Motion;
    });

define('StuMiscContent/StuMotion', ['DS/StuMiscContent/StuMotion'], function (Motion) {
    'use strict';

    return Motion;
});

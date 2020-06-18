/*
* * @quickReview IBS 17:04:21 GetExperienceScaleFactor bindé 
*						+ RenderManager fonctionne en repère world
*						+ clickablestate sur les roues (cas des roues primitives)
*
*/

/* global define */
define('DS/StuMiscContent/StuCarController', [
		'DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent',
        'MathematicsES/MathsDef', 'DS/EPInputs/EPKeyboardEvent', 'DS/EPInputs/EPGamepadEvent', 'DS/EPInputs/EPKeyboard'],
	function (STU, EP, Behavior, Task, EventServices, Event, DSMath) {
	    'use strict';

	    var CarControllerTask = function (iCarController) {
	        Task.call(this);
	        this.beh = iCarController;
	    };


	    CarControllerTask.prototype = new Task();
	    CarControllerTask.prototype.constructor = CarControllerTask;

	    /**
		 * Method called each frame by the task manager
		 *
		 * @method
		 * @private
		 * @param  iExContext Execution context
		 */
	    CarControllerTask.prototype.onExecute = function (iExContext) {
	        this.beh.executeOneFrame(iExContext.getDeltaTime() / 1000);
	    };

	    /**
		 * Process executed when CarControllerTask is started
		 * @private
		 */
	    CarControllerTask.prototype.onStart = function () {

	        if (this.beh === undefined || this.beh === null) {
	            console.error('CarControllerTask onStart task has an invalid component');
	            return;
	        }

	        var actor = this.beh.getActor();
	        if (actor === null || actor === undefined) {
	            // we are on a component prototype, we should not run a task
	            return;
	        }

	        var nbWheels = 0;
	        var wheels = {};

	        wheels.WheelFL = this.beh.frontLeftWheel;
	        wheels.WheelFR = this.beh.frontRightWheel;
	        wheels.WheelBL = this.beh.backLeftWheel;
	        wheels.WheelBR = this.beh.backRightWheel;

	        this.beh.__internal__.Wheels = wheels;

	        for (var w in wheels) {
	            if (wheels[w] !== undefined && wheels[w] !== null) {
	                nbWheels++;
	            }
	        }

	        if (nbWheels === 4) {
	            this.beh.__internal__.HasWheels = true;
	        } else {
	            this.beh.__internal__.HasWheels = false;
	        }
	    };

	    /**
		 * Process executed when CarControllerTask is stoped
		 *
		 * @private
		 */
	    CarControllerTask.prototype.onStop = function () { };



	    /**
		 * This event is thrown when the Car has reached the end of a path
		 *
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends EP.Event
		 * @memberof STU
		 */
	    var CarHasCompletedEvent = function (iPath, iActor) {
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

	    CarHasCompletedEvent.prototype = new Event();
	    CarHasCompletedEvent.prototype.constructor = CarHasCompletedEvent;
	    CarHasCompletedEvent.prototype.type = 'CarHasCompletedEvent';

	    // Expose in STU namespace.
	    STU.CarHasCompletedEvent = CarHasCompletedEvent;
	    EP.EventServices.registerEvent(CarHasCompletedEvent);






	    /**
		 * Describe a car controller behavior
		 *
		 * @exports CarController
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
	     * @alias STU.CarController
		 */
	    var CarController = function () {
	        Behavior.call(this);
	        this.name = 'CarController';

	        this.associatedTask;

	        //////////////////////////////////////////////////////////////////////////
	        // Properties that should NOT be visible in UI
	        //////////////////////////////////////////////////////////////////////////

	        // Internal properties
	        /**
			 * Object for storing internals properties
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__ = {};

	        /**
			 * Current speed of the car
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
	        this.__internal__.CurrentSpeed = 0;

	        /**
			 * Speed to reach for the car
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
	        this.__internal__.TargetSpeed = 0;

	        /**
			 * List of the wheels
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.Wheels = {};

	        /**
			 * True if all wheels were correctly configured
			 *
			 * @member
			 * @private
			 * @type {Boolean}
			 */
	        this.__internal__.HasWheels = false;

	        /**
			 * Current front wheels direction
			 * 1  if front wheels are turned right
			 * -1 if front wheels are turned left
			 * 0  if front wheels are not turned
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
	        this.__internal__.CurrentWheelDirection = 1;

	        /** 
			 * The amount of front wheels rotation
			 *
			 * @member
			 * @private
			 * @type {number}
			 */
	        this.__internal__.CurrentWheelRotationAmount = 0;

	        /**
			 * List of each wheels radius
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.Radius = {}; // radius of each wheels

	        /**
			 * List of each wheels bounding spheres
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.BoundingSphere = {};

	        /**
			 * Init flag
			 * @private
			 * @type {Boolean}
			 */
	        this.__internal__.Init = false;

	        /**
			 * Change of basis matrix for going from car basis to each wheel's basis
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.P13w = {};

	        /**
			 * Transforms of each wheels in the car referential
			 *
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.transforms = {};

	        /**
			 * Array containing the state of each keys
			 * @member
			 * @private
			 * @type {Object}
			 */
	        this.__internal__.keyState = {
	            moveForward: 0,
	            moveBackward: 0,
	            turnRight: 0,
	            turnLeft: 0,
	            brake: 0,
	        };

	        this.__internal__.timeInTheAir = 0;

	        this.__internal__.cleanGamePadAxis = false;

	        this.__internal__.target = null;

	        this.__internal__.isFollowingPath = false;

	        this.__internal__.pathLength = false;

	        this.__internal__.currentDistanceFollowPath = 0;

            this.__internal__.upVec = new DSMath.Vector3D(0, 0, 1);

	        this.__internal__.trafficManagerOverride = false;

	        this.__internal__.carLength = 0;

	        this.__internal__.gravity = new DSMath.Vector3D(0, 0, -1);

	        //////////////////////////////////////////////////////////////////////////
	        // Properties that should be visible in UI
	        //////////////////////////////////////////////////////////////////////////

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
			 * Mapped key for turning right
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
	        this.turnRight = EP.Keyboard.EKey.eRight;
	        /**
			 * Mapped key for turning left
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
	        this.turnLeft = EP.Keyboard.EKey.eLeft;

	        /**
			 * Mapped key for braking
			 *
			 * @member
			 * @public
			 * @type {EP.Keyboard.EKey}
			 */
	        this.brake = EP.Keyboard.EKey.eSpace;

	        /**
			 * Speed of the car in km/h
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
	        this.speed = 50.0; // km / h

	        /**
			 * Time in seconds for the car to go from 0 to Speed
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
	        this.acceleration = 5.0; // s
	        /**
			 * Time in seconds for the car to go from Speed to 0
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
	        this.deceleration = 1.0; // s

	        /**
			 * Maximum turning angle of front wheels in radians
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
	        this.steeringAngle = 0.785398163; //45.0 * Math.DegreeToRad

	        /**
			 * Time in seconds for front wheels to go from 0 to TurningRadius
			 *
			 * @member
			 * @public
			 * @type {number}
			 */
	        this.steeringTime = 1.5;

	        /**
			 * Front left wheel actor
			 *
			 * @member
			 * @private
			 * @type {STU.Actor3D}
			 */
	        this.frontLeftWheel = null;

	        /**
			 * Front right wheel actor
			 *
			 * @member
			 * @private
			 * @type {STU.Actor3D}
			 */
	        this.frontRightWheel = null;

	        /**
			 * Back left wheel actor
			 *
			 * @member
			 * @private
			 * @type {STU.Actor3D}
			 */
	        this.backLeftWheel = null;

	        /**
			 * Back right wheel actor
			 *
			 * @member
			 * @private
			 * @type {STU.Actor3D}
			 */
	        this.backRightWheel = null;

	        /**
			 * Align the car with the ground geometry
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
	        this.keepOnGround = true;


	    };

	    CarController.prototype = new Behavior();
	    CarController.prototype.constructor = CarController;
	    CarController.prototype.pureRuntimeAttributes = ['__internal__'].concat(Behavior.prototype.pureRuntimeAttributes);

	    CarController.prototype.computeGravityForce = function (oMoveVec, iDeltaTime, iActor, iUpActorVec) {
	        if (this.__internal__.HasWheels === true) {

	            var wheels = this.__internal__.Wheels;
	            var actorTransformScene = this.getActor().getTransform();                // dans le repere scene
	            var actorTransformWorld = this.getActor().getTransform("World");         // dans le repere monde

	            // IBS : plus nécessaire, scale globe géré dans Actor3D / RenderManager
	            //          on ne devrait plus que travailler en repère world ou location
	            // SceneToWorldScaling = 0.001 dans le cas usuel globe
	            // mesure distance dans le repere scene * SceneToWorldScaling = mesure distance equivalente dans le repère monde
	            // mesure distance dans le repere world  / SceneToWorldScaling = mesure distance equivalente dans le repèrescene
	            var SceneToWorldScaling = actorTransformWorld.getScaling().scale / actorTransformScene.getScaling().scale;
	            if (SceneToWorldScaling <= 0.0) {
	                SceneToWorldScaling = 1.0;
	            }

	            var renderManager = STU.RenderManager.getInstance();

	            var gravityDirectionWorld = new DSMath.Vector3D(0.0, 0.0, -1.0);

	            var scene = this.actor.getLocation();
	            if (scene !== null && scene !== undefined) {
	                gravityDirectionWorld = this.actor.getLocation().getTransform("World").matrix.getThirdColumn().clone().normalize().negate();
	            }
	            else {
	                gravityDirectionWorld = renderManager.getGravityVector(this.getActor(), "World"); // dans le repere monde
	            }

	            // sceneWorldTransform * actorSceneTransform = actorWorldTransform
	            var invActorTransformScene = actorTransformScene.getInverse();
	            var sceneTransformWorld = DSMath.Transformation.multiply(actorTransformWorld, invActorTransformScene);
	            var invSceneTransformWorld = sceneTransformWorld.getInverse();

	            var avgDstWorld = 0;
	            var avgNormalWorld = new DSMath.Vector3D();
	            var nbImpacts = 0;

	            //save state and deactivate pickablity of the car iActor
	            var carClickableState = iActor.clickable;
	            iActor.clickable = false;

	            var wheelCenterAvgPosWorld = new DSMath.Point();
	            var intersections = {};

	            for (var w in wheels) { /*jshint -W089 */
	                //compute wheel center position
	                var wheelClickableState = wheels[w].clickable;
	                wheels[w].clickable = false;

	                var wheelCenterPositionWorld = DSMath.Transformation.multiply(actorTransformWorld, this.__internal__.P13w[w]).vector; // dans le repere monde

	                var rayVect = new STU.Ray();

	                // this.__internal__.Radius est dans le repere scene, il y a SceneToWorldScaling à ajouter pour passer au monde
	                rayVect.origin.x = wheelCenterPositionWorld.x - this.__internal__.Radius[w] * 4 * gravityDirectionWorld.x; // dans le repere monde, plus besoin de *SceneToWorldScaling
	                rayVect.origin.y = wheelCenterPositionWorld.y - this.__internal__.Radius[w] * 4 * gravityDirectionWorld.y;
	                rayVect.origin.z = wheelCenterPositionWorld.z - this.__internal__.Radius[w] * 4 * gravityDirectionWorld.z;

	                wheelCenterAvgPosWorld.addVector(wheelCenterPositionWorld); // dans le repere monde

	                rayVect.direction.x = gravityDirectionWorld.x; // dans le repere monde
	                rayVect.direction.y = gravityDirectionWorld.y;
	                rayVect.direction.z = gravityDirectionWorld.z;

	                rayVect.setLength(10000000000); // <-- big length  



	                /*var params = {position: rayVect.origin,
			                 		 reference: null,
					                 pickGeometry: true,
					                 pickTerrain: true,
					                 pickWater: false,
									};*/

	                //intersectArray[0].point = renderManager._pickGroundFromPosition();
	                //if (true) {
	                //nbImpacts++;
	                // var intersectedActor = intersectArray[0].getActor();
	                var params = {
	                    position: rayVect.origin,
	                    reference: null,
	                    pickGeometry: true,
	                    pickTerrain: true,
	                    pickWater: false,
	                };

	                //var intersect = renderManager._pickGroundFromPosition(params);

	                //var intersectedPoint = intersect.point;//intersectArray[0].getPoint();    // dans le repere monde
	                //var intersectedNormal = intersect.normal;  // dans le repere monde

	                //var intersectedPoint = renderManager._pickGroundFromPosition(params).point;//intersectArray[0].getPoint();    // dans le repere monde

	                var intersect = renderManager._pickGroundFromPosition(params);
	                if (intersect !== null && intersect !== undefined) {

	                    nbImpacts++;
	                    var intersectedPoint = intersect.point;
	                    /*if(intersectArray[0].normal === null || intersectArray[0].normal === undefined){
                            intersectArray[0].normal = gravityDirectionWorld.clone().negate();
                        }*/
	                    //var intersectedNormal = intersectArray[0].getNormal();  // dans le repere monde

	                    var MyDst = Math.sqrt((intersectedPoint.x - rayVect.origin.x) * (intersectedPoint.x - rayVect.origin.x) + (intersectedPoint.y - rayVect.origin.y) * (intersectedPoint.y -
                            rayVect.origin.y) + (intersectedPoint.z - rayVect.origin.z) * (intersectedPoint.z - rayVect.origin.z));

	                    avgDstWorld += MyDst;

	                    //avgNormalWorld.add(intersectedNormal);
	                    /*var intersectArray = renderManager._pickFromRay(rayVect, true, true);
                        if(intersectArray[0] !== null && intersectArray[0] !== undefined && intersectArray[0].normal !== null && intersectArray[0].normal !== undefined){
                            avgNormalWorld.add(intersectArray[0].normal);
                        }*/

	                    intersections[w] = intersectedPoint;
	                }
	                else {
	                    var intersectArray = renderManager._pickFromRay(rayVect, true, true);
	                    if (intersectArray[0] !== null && intersectArray[0] !== undefined && intersectArray[0].normal !== null && intersectArray[0].normal !== undefined) {
	                        avgNormalWorld.add(intersectArray[0].normal);
	                    }
	                }

	                // debug
	                /*var MyColor1 = new STU.Color(0, 255, 0);
	                var MyPos1 = DSMath.Transformation.multiply(actorTransformWorld, this.__internal__.P13w[w]); // dans le repere monde
                    var Params1 = {
                        radius: 500,
                        screenSize: 0,
                        position: MyPos1,
                        referential:"World",
                        color: MyColor1,
                        alpha: 200,
                        lifetime: 1
                    };
                    renderManager._createSphere(Params1);

                    //Debug
                    var MyColor2 = new STU.Color(255, 0, 0);
                    var MyPos2 = new DSMath.Transformation();  
                    MyPos2.vector = intersectedPoint;//.multiplyScalar(0.001);
                    var Params2 = {
                        radius: 500,
                        screenSize: 0,
                        position: MyPos2,
                        referential: "World",
                        color: MyColor2,
                        alpha: 200,
                        lifetime: 1
                    };
                    renderManager._createSphere(Params2);*/
	                //}

	                wheels[w].clickable = wheelClickableState;
	            }

	            iActor.clickable = carClickableState;
	            wheelCenterAvgPosWorld.multiplyScalar(0.25); // dans le repere monde
	            if (nbImpacts > 0) {
	                avgDstWorld /= nbImpacts;
	                if (nbImpacts === 4) {
	                    var rightVec = DSMath.Vector3D.sub(intersections.WheelBR, intersections.WheelBL).normalize(); // dans le repere monde
	                    var frontVec = DSMath.Vector3D.sub(intersections.WheelFL, intersections.WheelBL).normalize(); // dans le repere monde

	                    avgNormalWorld = DSMath.Vector3D.cross(rightVec, frontVec); // dans le repere monde
	                } else {
	                    avgNormalWorld.multiplyScalar(1 / nbImpacts);
	                }
	                avgNormalWorld.normalize(); // dans le repere monde

	                // la direction de la gravité dans le repère de la scene de l'actor ?
	                //var gravityDirectionScene = DSMath.Transformation.multiply(invSceneTransformWorld, gravityDirectionWorld);
	                var gravityDirectionScene = gravityDirectionWorld.clone();
	                gravityDirectionScene.applyTransformation(invSceneTransformWorld);
	                gravityDirectionScene.normalize();

	                // avgNormalWorld dans le repere scene
	                //var avgNormalScene = DSMath.Transformation.multiply(invSceneTransformWorld, avgNormalWorld);
	                var avgNormalScene = avgNormalWorld.clone();
	                avgNormalScene.applyTransformation(invSceneTransformWorld);
	                avgNormalScene.normalize();

	                // wheelCenterAvgPosWorld dans le repere scene
	                //var wheelCenterAvgPosScene = DSMath.Transformation.multiply(invSceneTransformWorld, wheelCenterAvgPosWorld);
	                var wheelCenterAvgPosScene = wheelCenterAvgPosWorld.clone();
	                wheelCenterAvgPosScene.applyTransformation(invSceneTransformWorld);

	                var avgDstScene = avgDstWorld;
	                if (avgDstScene > ((10 + this.__internal__.Radius.WheelFR * 5) * SceneToWorldScaling)) {
	                    oMoveVec.x += (9.81) * this.__internal__.timeInTheAir * 10 * gravityDirectionScene.x; // dans le repere scene
	                    oMoveVec.y += (9.81) * this.__internal__.timeInTheAir * 10 * gravityDirectionScene.y;
	                    oMoveVec.z += (9.81) * this.__internal__.timeInTheAir * 10 * gravityDirectionScene.z;
	                    this.__internal__.timeInTheAir += iDeltaTime;
	                } else {
	                    var diffScene = (this.__internal__.Radius.WheelFR * 5 * SceneToWorldScaling) - avgDstScene; // dans repere scene
	                    if (Math.abs(diffScene) > 10 * SceneToWorldScaling) {
	                        var diffVecScene = DSMath.Vector3D.multiplyScalar(avgNormalScene, diffScene);// dans le repere scene

	                        iActor.translate(diffVecScene);

	                    }
	                    this.__internal__.timeInTheAir = 0;
	                    this.alignWithTheGround(iActor, iUpActorVec, avgNormalScene, wheelCenterAvgPosScene);
	                }
	            }
	        }
	    };

	    // essaye de rendre colinéaire iGroundZ et iUpActorVector
	    // iUpActorVector dans repere scene 
	    // iGroundZ dans repere scene
	    // iWheelCenterAvgPosScene dans repere scene
	    CarController.prototype.alignWithTheGround = function (iActor, iUpActorVector, iGroundZ, iWheelCenterAvgPosScene) {
	        if (iUpActorVector === undefined || iUpActorVector === null) {
	            console.error('iUpActorVector == null');
	            return;
	        }
	        if (iGroundZ === undefined || iGroundZ === null) {
	            console.error('iGroundZ == null');
	            return;
	        }

	        var orth = DSMath.Vector3D.cross(iGroundZ, iUpActorVector);

	        // collinear test 
	        if (orth.squareNorm() > 0.0001) {
	            orth.normalize();
	            var dot = iGroundZ.dot(iUpActorVector);
	            var angle = -Math.acos(dot);

	            this.rotateAround(iActor, iWheelCenterAvgPosScene, orth, angle);
	        }
	    };


	    CarController.prototype.followPath = function (path, percentage) {
	        console.debug('Follow Path trigger + ' + this.getActor().name);
	        if (this.__internal__.target !== path || (this.__internal__.target === path && this.__internal__.isFollowingPath === false)) {

	            this.__internal__.target = path;
	            this.__internal__.isFollowingPath = true;
	            this.__internal__.pathLength = path.getLength();
	            this.__internal__.currentDistanceFollowPath = 0;

	            if (this.__internal__.HasWheels) {
	                if (!this.__internal__.Init)
	                    this.init(this.getActor());
	                this.__internal__.CurrentSpeed = this.speed * 277.777778 / 3;
	            }

	            var pathStartValue = 0;
	            if (percentage !== undefined && percentage !== null && percentage >= 0.0 && percentage <= 1) {
	                this.__internal__.currentDistanceFollowPath = this.__internal__.pathLength * percentage;
	                pathStartValue = percentage;
	            }

	            var scene = this.actor.getLocation();
	            var pathStart = path.getValue(pathStartValue, scene).clone();
	            var moveToPath = null;
	            var carFrontVector = null;
	            var carCenter = null;
	            if (this.__internal__.HasWheels) {
	                moveToPath = pathStart.sub(this.getWheelCenter());
	                carFrontVector = this.getCarFrontVector();
	                carCenter = this.getWheelCenter();
	            } else {
	                moveToPath = pathStart.sub(this.getActor().getPosition());
	                carFrontVector = this.getActor().getTransform().matrix.getFirstColumn();
	                carCenter = this.getActor().getPosition();
	            }
	            this.getActor().translate(moveToPath);

	            //ASO4: Not necessary, cause this is done in the updateFollowPath function
	            //this.__internal__.upVec = new DSMath.Vector3D(0, 0, 1);
	            //if ((this.__internal__.currentDistanceFollowPath + 100) < this.__internal__.pathLength) {
	            //    //var updatePosition = this.__internal__.target.getValue((this.__internal__.currentDistanceFollowPath + 100) / this.__internal__.pathLength);
	            //    var updatePosition = this.__internal__.target.getValue(100 / this.__internal__.pathLength, scene);
	            //    var updatePosition2 = this.__internal__.target.getValue(0, scene);
	            //    updatePosition.sub(updatePosition2);
	            //    var angle = this.getAngleBetweenVectorsInXY(carFrontVector, updatePosition);
	            //    if (!isNaN(angle)) {
	            //        this.getActor().rotateAround(carCenter, this.__internal__.upVec, angle);
	            //    }
	            //}

	        }
	    };

	    CarController.prototype.updateFollowPath = function (iDeltaTime) {
	        var actor = this.getActor();
	        this.__internal__.CurrentSpeed = this.speed * 277.777778 / 3;
	        if (this.__internal__.currentDistanceFollowPath < this.__internal__.pathLength) {
	            this.__internal__.currentDistanceFollowPath += this.__internal__.CurrentSpeed * iDeltaTime;
	        }
	        if (this.__internal__.currentDistanceFollowPath > this.__internal__.pathLength) {
	            this.__internal__.currentDistanceFollowPath = this.__internal__.pathLength;
	            this.__internal__.isFollowingPath = false;
	            this._target = null;
	            var evt = new CarHasCompletedEvent(this.__internal__.target, actor);
	            actor.dispatchEvent(evt);
	            console.debug('Car ' + this.getActor().name + ' has completed following path');
	            this.dispatchEvent(new STU.ServiceStoppedEvent("followPath", this));
	            this.__internal__.CurrentSpeed = 0;
	        }

	        var carFrontVector = null;
	        var carCenter = null;
	        if (this.__internal__.HasWheels) {
	            carFrontVector = this.getCarFrontVector();
	            carCenter = this.getWheelCenter();
	        } else {
	            carFrontVector = this.getActor().getTransform().matrix.getFirstColumn();
	            carCenter = this.getActor().getPosition();
	        }

	        var scene = this.actor.getLocation();
	        var updatePosition = this.__internal__.target.getValue(this.__internal__.currentDistanceFollowPath / this.__internal__.pathLength, scene);
	        updatePosition.sub(carCenter);
	        var angle = this.getAngleBetweenVectorsInXY(carFrontVector, updatePosition);
	        if (updatePosition.norm() < 1 || isNaN(angle)) {
	            return;
	        }
	        actor.rotateAround(carCenter, this.__internal__.upVec, angle);
	        updatePosition.z = 0;
	        if (carFrontVector.z < 0) {
	            var pitch = this.getAngleBetweenVectors(carFrontVector, updatePosition);
	            if (!isNaN(pitch) && pitch !== undefined && Math.abs(pitch) < 0.7) {
	                updatePosition.z = -updatePosition.norm() * Math.tan(pitch);
	            }
	        }
	        actor.translate(updatePosition);


	    };

	    CarController.prototype.isFollowingPath = function (path) {
	        if (path === this.__internal__.target) {
	            return this.__internal__.isFollowingPath;
	        }
	        return false;
	    };


	    CarController.prototype.getWheelCenter = function () {
	        var actorTransform = this.getActor().getTransform(); // dans le repere scene
	        var middle = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector.clone();
	        middle.add(DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFR).vector);
	        middle.add(DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector);
	        middle.add(DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBR).vector);
	        middle.multiplyScalar(0.25);
	        return middle;
	    };

	    CarController.prototype.setCarPosition = function (vector) {
	        var carCenter = this.getWheelCenter(); // dans le repere scene
	        var destination = vector.clone();
	        destination.sub(carCenter);
	        this.getActor().translate(destination); // dans le repere scene
	    };

	    CarController.prototype.getCarFrontVector = function () {
	        var actorTransform = this.getActor().getTransform(); // dans le repere scene
	        var FLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	        var BLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;
	        FLwheelCenterPosition.sub(BLwheelCenterPosition);
	        FLwheelCenterPosition.normalize();
	        return FLwheelCenterPosition;
	    };

	    CarController.prototype.getCarRightVector = function () {
	        var actorTransform = this.getActor().getTransform(); // dans le repere scene
	        var BRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBR).vector;
	        var BLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;
	        BRwheelCenterPosition.sub(BLwheelCenterPosition);
	        BRwheelCenterPosition.normalize();
	        return BRwheelCenterPosition;
	    };

	    CarController.prototype.getCarLeftVector = function () {
	        var actorTransform = this.getActor().getTransform(); // dans le repere scene
	        var BRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBR).vector;
	        var BLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;
	        BLwheelCenterPosition.sub(BRwheelCenterPosition);
	        BLwheelCenterPosition.normalize();
	        return BLwheelCenterPosition;
	    };

	    CarController.prototype.getAngleBetweenVectorsInXY = function (vector1, vector2) {
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

	    CarController.prototype.getAngleBetweenVectors = function (vector1, vector2) {
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

	    CarController.prototype.setTrafficManagerOverride = function () {
	        this.__internal__.trafficManagerOverride = true;
	        if (this.__internal__.HasWheels) {
	            this.init(this.getActor());
	            var actorTransform = this.getActor().getTransform();
	            var FLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	            var BLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;
	            var BRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBR).vector;
	            FLwheelCenterPosition.sub(BLwheelCenterPosition);
	            BRwheelCenterPosition.sub(BLwheelCenterPosition);
	            this.__internal__.carLength = FLwheelCenterPosition.norm();
	            this.__internal__.carWidth = BRwheelCenterPosition.norm();
	            return true;
	        }
	        else {
	            return false;
	        }
	    };

	    CarController.prototype.setTrafficManagerOverrideByCopy = function (iModelBeh) {
	        this.__internal__.trafficManagerOverride = true;
	        if (this.__internal__.HasWheels) {
	            for (var w in this.__internal__.Wheels) {
	                this.__internal__.Radius[w] = iModelBeh.__internal__.Radius[w];
	                this.__internal__.P13w[w] = iModelBeh.__internal__.P13w[w].clone();
	                this.__internal__.BoundingSphere[w] = iModelBeh.__internal__.BoundingSphere[w];
	                this.__internal__.transforms[w] = iModelBeh.__internal__.transforms[w].clone();
	            }

	            this.__internal__.carLength = iModelBeh.__internal__.carLength;
	            this.__internal__.carWidth = iModelBeh.__internal__.carWidth;
	            this.__internal__.Init = true;
	            return true;
	        }
	        else {
	            return false;
	        }
	    };

	    CarController.prototype.pointToVector = function (point) {
	        var vector = new DSMath.Vector3D();
	        vector.set(point.x, point.y, point.z);
	        return vector;
	    };


	    CarController.prototype.copyTransform = function (transform) {
	        var t = new DSMath.Transformation();
	        t.matrix = transform.matrix.clone();
	        t.vector = transform.vector.clone();
	        return t;
	    };

	    CarController.prototype.reajustCenter = function (wheelsIntersection) {
	        var carCenter = this.getWheelCenter();
	        var computedCenter = new DSMath.Vector3D();
	        computedCenter.set(0, 0, 0);
	        var computedNormal = new DSMath.Vector3D();
	        computedNormal.set(0, 0, 0);
	        var radius = 0;
	        var wheels = this.__internal__.Wheels;
	        for (var w in wheels) { /*jshint -W089 */
	            var intersect = wheelsIntersection[w];
	            if (intersect === 0 || intersect === undefined) {
	                return 0;
	            }
	            computedCenter.add(this.pointToVector(intersect.point));
	            computedNormal.add(intersect.normal);
	            radius += this.__internal__.Radius[w];
	        }
	        computedCenter.multiplyScalar(0.25);
	        computedNormal.normalize();
	        computedNormal.multiplyScalar(radius / 4);
	        computedCenter.add(computedNormal);
	        var carCenterModification = DSMath.Vector3D.sub(computedCenter, carCenter);
	        this.getActor().translate(carCenterModification);
	    };

	    CarController.prototype.trafficManagerUpdate = function (wheelsIntersection, iDeltaTime, speed, rotateWheels, iAngle) {
	        this.reajustCenter(wheelsIntersection);
	        var gravityVector = new DSMath.Vector3D();
	        var actor = this.getActor();
	        var actorTransform = actor.getTransform();
	        var upVec = new DSMath.Vector3D();
	        var P03 = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL);
	        var matrixCoeff = P03.matrix.getArray();
	        upVec.set(matrixCoeff[1], matrixCoeff[4], matrixCoeff[7]);
	        var wheels = this.__internal__.Wheels;
	        var avgDst = 0;
	        var avgNormal = new DSMath.Vector3D();
	        var nbImpacts = 0;
	        var wheelCenterAvgPos = new DSMath.Vector3D();
	        var intersections = {};
	        var carFrontVector = this.getCarFrontVector();
	        var carCenter = this.getWheelCenter();
	        var direction = new DSMath.Vector3D();

	        var wheelsCenter = new DSMath.Vector3D();
	        var intersectionCenter = new DSMath.Vector3D();

	        // Rotate the wheels
	        if (rotateWheels) {
	            var LeftVectWheel = new DSMath.Vector3D();
	            LeftVectWheel.set(matrixCoeff[0], matrixCoeff[3], matrixCoeff[6]);
	            var FRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFR).vector;


	            var wheelCenterPosition = actor.getPosition();
	            for (var w in wheels) { /*jshint -W089 */
	                wheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w[w]).vector;
	                var rotationAngle = speed * (1000 * iDeltaTime) / this.__internal__.Radius[w];
	                // this.rotateAround(wheels[w], wheelCenterPosition, LeftVectWheel, rotationAngle);
	                // wheels[w].setTransform(DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w[w]));
	                wheels[w].setTransform(this.__internal__.transforms[w], actor);
	                wheels[w].rotateAround(wheelCenterPosition, LeftVectWheel, rotationAngle);
	                this.__internal__.transforms[w] = wheels[w].getTransform(actor);
	            }

	            var wheelRotation = iAngle;
	            var FLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	            wheels.WheelFL.rotateAround(FLwheelCenterPosition, upVec, wheelRotation);

	            var FRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFR).vector;
	            wheels.WheelFR.rotateAround(FRwheelCenterPosition, upVec, wheelRotation);
	        }


	        // Rotate the car to match the wheels
	        if (wheelsIntersection.WheelFR !== 0 && wheelsIntersection.WheelBR !== 0) {
	            direction.x = wheelsIntersection.WheelFR.point.x - wheelsIntersection.WheelBR.point.x;
	            direction.y = wheelsIntersection.WheelFR.point.y - wheelsIntersection.WheelBR.point.y;
	            direction.z = wheelsIntersection.WheelFR.point.z - wheelsIntersection.WheelBR.point.z;

	            intersectionCenter.add(wheelsIntersection.WheelFR.point);
	            intersectionCenter.add(wheelsIntersection.WheelBR.point);
	            intersectionCenter.add(wheelsIntersection.WheelFL.point);
	            intersectionCenter.add(wheelsIntersection.WheelBL.point);
	            intersectionCenter.multiplyScalar(1 / 4);

	            var angle = this.getAngleBetweenVectorsInXY(carFrontVector, direction);
	            if (direction.norm() > 1 && !isNaN(angle) && Math.abs(angle) > 0.0001) {
	                this.rotateAround(actor, carCenter, upVec, angle);
	            }
	        }

	        for (var w in wheels) { /*jshint -W089 */
	            //compute wheel center position
	            var wheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w[w]).vector;
	            wheelsCenter.add(wheelCenterPosition);
	            wheelCenterPosition.z += this.__internal__.Radius[w] * 4;
	            wheelCenterAvgPos.x += wheelCenterPosition.x;
	            wheelCenterAvgPos.y += wheelCenterPosition.y;
	            wheelCenterAvgPos.z += wheelCenterPosition.z;
	            if (wheelsIntersection[w] !== 0) {
	                nbImpacts++;
	                var intersectedPoint = wheelsIntersection[w].getPoint();
	                var intersectedNormal = wheelsIntersection[w].getNormal();
	                avgDst += Math.sqrt((intersectedPoint.x - wheelCenterPosition.x) * (intersectedPoint.x - wheelCenterPosition.x) + (intersectedPoint.y - wheelCenterPosition.y) *
						(intersectedPoint.y - wheelCenterPosition.y) + (intersectedPoint.z - wheelCenterPosition.z) * (intersectedPoint.z - wheelCenterPosition.z));
	                avgNormal.add(intersectedNormal);
	                intersections[w] = intersectedPoint;
	            }
	        }

	        wheelCenterAvgPos.x /= 4;
	        wheelCenterAvgPos.y /= 4;
	        wheelCenterAvgPos.z /= 4;

	        wheelsCenter.multiplyScalar(1 / 4);
	        var inAir = wheelsCenter.z - this.__internal__.Radius.WheelFR * 2 > intersectionCenter.z;

	        if (nbImpacts > 0) {
	            avgDst /= nbImpacts;
	            if (nbImpacts === 4) {
	                var rightVec = DSMath.Vector3D.sub(intersections.WheelBR, intersections.WheelBL).normalize();
	                var frontVec = DSMath.Vector3D.sub(intersections.WheelFL, intersections.WheelBL).normalize();
	                avgNormal = DSMath.Vector3D.cross(rightVec, frontVec);
	            } else {
	                avgNormal.multiplyScalar(1 / nbImpacts);
	            }

	            //if (avgDst > 10 + this.__internal__.Radius.WheelFR * 5) {
	            if (inAir) {
	                gravityVector.z -= 9.81 * this.__internal__.timeInTheAir * 10;
	                this.__internal__.timeInTheAir += iDeltaTime;
	            } else {
	                /*var diff = this.__internal__.Radius.WheelFR * 5 - avgDst;
	                if (Math.abs(diff) > 10) {
	                    var diffVec = DSMath.Vector3D.multiplyScalar(avgNormal, diff);
	                    actor.translate(diffVec);
	                }*/
	                this.__internal__.timeInTheAir = 0;
	                this.alignWithTheGround(actor, upVec, avgNormal, wheelCenterAvgPos);
	            }
	        }
	        if (gravityVector.z !== 0) {
	            actor.translate(gravityVector);
	        }
	    };

	    /**
		 * Main method executed each frames
		 *
		 * @method
		 * @private
		 * @param  {Number} iDeltaTime Time elapsed since last frame (in seconds)
		 */
	    CarController.prototype.executeOneFrame = function (iDeltaTime) {
	        // We might not be in a ring yet thus test !!

	        var actor = this.getActor();
	        if (actor === undefined || actor === null || !(actor instanceof STU.Actor3D)) {
	            return this;
	        }

	        if (this.__internal__.isFollowingPath) {
	            this.updateFollowPath(iDeltaTime);
	            //return;
	        }
	        if (this.__internal__.trafficManagerOverride) {
	            return;
	        }

	        var keyState = this.__internal__.keyState;

	        var newSpeed = this.__internal__.CurrentSpeed;
	        var speed = this.speed * 277.777778; // km/h to mm/s

	        this.handleGamepadAxis();


	        if (this.speed > 0) {
	            // No Move
	            if (keyState.moveForward === 0 && keyState.moveBackward === 0 && keyState.brake === 0) {
	                if (this.acceleration > 0) {
	                    var t = this.__internal__.CurrentSpeed / speed * this.acceleration;
	                    if (t > 0) {
	                        t = Math.max(t - iDeltaTime, 0);
	                    } else if (t < 0) {
	                        t = Math.min(t + iDeltaTime, 0);
	                    } else {
	                        t = 0;
	                    }
	                    newSpeed = speed / this.acceleration * t;
	                } else {
	                    newSpeed = 0;
	                }
	            }

	                // MoveForward
	            else if (keyState.moveForward !== 0 && keyState.moveBackward === 0 && keyState.brake === 0) {
	                if (this.acceleration > 0 && this.deceleration > 0) {
	                    if (this.__internal__.CurrentSpeed < 0) {
	                        var t = this.__internal__.CurrentSpeed / speed * this.deceleration;
	                        t = Math.min(t + iDeltaTime, this.deceleration);
	                        newSpeed = speed / this.deceleration * t;
	                    } else {
	                        var t = this.__internal__.CurrentSpeed / speed * this.acceleration;
	                        t = Math.min(t + iDeltaTime, this.acceleration);
	                        newSpeed = speed / this.acceleration * t;
	                    }
	                } else {
	                    newSpeed = speed;
	                }
	                newSpeed *= keyState.moveForward;
	            }
	                // MoveBackward
	            else if (keyState.moveForward === 0 && keyState.moveBackward !== 0 && keyState.brake === 0) {
	                if (this.acceleration > 0 && this.deceleration > 0) {

	                    if (this.__internal__.CurrentSpeed > 0) {
	                        var t = this.__internal__.CurrentSpeed / speed * this.deceleration;
	                        t = Math.max(t - iDeltaTime, -this.deceleration);
	                        newSpeed = speed / this.deceleration * t;
	                    } else {
	                        var t = this.__internal__.CurrentSpeed / speed * this.acceleration;
	                        t = Math.max(t - iDeltaTime, -this.acceleration);
	                        newSpeed = speed / this.acceleration * t;
	                    }
	                } else {
	                    newSpeed = -speed;
	                }
	                newSpeed *= keyState.moveBackward;
	            }

	                // Brake
	            else if (keyState.brake !== 0) {
	                if (this.deceleration > 0) {
	                    var t = this.__internal__.CurrentSpeed / speed * this.deceleration;
	                    if (this.__internal__.CurrentSpeed > 0.1) {
	                        t = Math.max(t - iDeltaTime, 0);
	                    } else if (this.__internal__.CurrentSpeed < -0.1) {
	                        t = Math.min(t + iDeltaTime, 0);
	                    } else {
	                        t = 0;
	                    }
	                    newSpeed = speed / this.deceleration * t;
	                } else {
	                    newSpeed = 0;
	                }
	            }
	        } else { //no speed or negative speed 
	            newSpeed = 0;
	        }

	        this.__internal__.CurrentSpeed = newSpeed;

	        var moveVec = new DSMath.Vector3D();

	        //in case wheels are not set we still move and turn the car 
	        if (this.__internal__.HasWheels === false) {
	            // moving the car according to the current speed
	            if (this.__internal__.CurrentSpeed !== 0 && this.__internal__.isFollowingPath !== true) {
	                moveVec.set(this.__internal__.CurrentSpeed * iDeltaTime, 0, 0);
	                actor.translate(moveVec, actor);

	                // Turn Right or turn left  
	                if (keyState.turnLeft !== 0 || keyState.turnRight !== 0) {
	                    var RotateAngle = (this.steeringAngle * iDeltaTime);
	                    if (keyState.turnRight !== 0) {
	                        RotateAngle *= -keyState.turnRight;
	                    } else {
	                        RotateAngle *= keyState.turnLeft;
	                    }
	                    //in case we are going backwards, we inverse the rotation angle
	                    if (this.__internal__.CurrentSpeed < 0) {
	                        RotateAngle *= -1;
	                    }

	                    var rotationVec = new DSMath.Vector3D();
	                    rotationVec.set(0, 0, RotateAngle);

	                    actor.rotate(rotationVec, actor);
	                }
	            }

	        }
	            //wheels are set 
	        else {
	            //frist we are going to compute the basis of each wheels
	            var wheels = this.__internal__.Wheels;
	            var upVec = new DSMath.Vector3D();
	            upVec.set(0, 0, 1);


	            if (this.__internal__.Init === false) {
	                this.init(actor);
	            } else {
	                //reset tranforms
	                for (var w in wheels) { /*jshint -W089 */
	                    wheels[w].setTransform(this.__internal__.transforms[w], actor);
	                }
	            }

	            var actorTransform = actor.getTransform();  // referentiel scene

	            var P03 = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL);
	            var matrixCoeff = P03.matrix.getArray();
	            upVec.set(matrixCoeff[1], matrixCoeff[4], matrixCoeff[7]);
	            this.__internal__.upVec = upVec;

	            // moving the car according to the current speed
	            if (this.__internal__.CurrentSpeed !== 0) {
	                // move the car 
	                // compute the front vector

	                moveVec.set(matrixCoeff[2], matrixCoeff[5], matrixCoeff[8]);
	                moveVec.normalize();

	                var LeftVectWheel = new DSMath.Vector3D();
	                LeftVectWheel.set(matrixCoeff[0], matrixCoeff[3], matrixCoeff[6]);

	                moveVec.multiplyScalar(this.__internal__.CurrentSpeed * iDeltaTime);

	                if (!this.__internal__.isFollowingPath) {
	                    actor.translate(moveVec);
	                }
	                actorTransform = actor.getTransform();

	                for (var w in wheels) {
	                    //compute wheel center position
	                    var wheelCenterPosition = actor.getPosition();
	                    wheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w[w]).vector;

	                    var rotationAngle = this.__internal__.CurrentSpeed * iDeltaTime / this.__internal__.Radius[w];

	                    this.rotateAround(wheels[w], wheelCenterPosition, LeftVectWheel, rotationAngle);

	                    //save wheels tranforms
	                    this.__internal__.transforms[w] = wheels[w].getTransform(actor);
	                }
	            }

	            if (this.keepOnGround === true) {
	                var gravityVector = new DSMath.Vector3D();

	                this.computeGravityForce(gravityVector, iDeltaTime, actor, upVec);

	                if (gravityVector.z !== 0) {
	                    actor.translate(gravityVector);
	                }
	            }

	            // Turn Right, turn left  
	            if (keyState.turnLeft !== 0 || keyState.turnRight !== 0 || this.__internal__.CurrentWheelRotationAmount > 0) {
	                var currentWheelDirection = this.__internal__.CurrentWheelDirection;
	                var timeToTurnWheels = this.steeringTime;
	                var turningRadius = this.steeringAngle;

	                var rotationSign;
	                var currentWheelRotationAmount = this.__internal__.CurrentWheelRotationAmount;
	                var wheelRotation;

	                var actorTransform = actor.getTransform();
	                var maxSpeed = this.speed * 277.777778;
	                var velocityContraint = (3 * maxSpeed - this.__internal__.CurrentSpeed) / (3 * maxSpeed);
	                if (keyState.turnLeft !== 0 || keyState.turnRight !== 0) {
	                    if (keyState.turnRight > 0) {
	                        rotationSign = -keyState.turnRight;
	                    } else {
	                        rotationSign = keyState.turnLeft;
	                    }

	                    // last frame direction was different from current frame direction
	                    if (currentWheelDirection !== rotationSign) {
	                        currentWheelRotationAmount -= 3 * iDeltaTime;
	                        if (currentWheelRotationAmount < 0) {
	                            currentWheelDirection = rotationSign;
	                            currentWheelRotationAmount *= -1;
	                        }
	                        wheelRotation = currentWheelDirection * currentWheelRotationAmount * turningRadius / timeToTurnWheels;
	                    } else {
	                        if (timeToTurnWheels > 0) {
	                            currentWheelRotationAmount = Math.min(currentWheelRotationAmount + iDeltaTime * velocityContraint, timeToTurnWheels);
	                            wheelRotation = currentWheelDirection * currentWheelRotationAmount * turningRadius / timeToTurnWheels;
	                        } else {
	                            currentWheelRotationAmount = 0;
	                            wheelRotation = currentWheelDirection * turningRadius;
	                        }
	                    }

	                } else {
	                    if (timeToTurnWheels > 0) {
	                        currentWheelRotationAmount = Math.max(this.__internal__.CurrentWheelRotationAmount - 2 * iDeltaTime, 0);
	                        wheelRotation = currentWheelDirection * currentWheelRotationAmount * (turningRadius) / timeToTurnWheels;
	                    } else {
	                        currentWheelRotationAmount = 0;
	                        wheelRotation = currentWheelDirection * turningRadius;
	                    }
	                }
	                // rotate the car
	                if (this.__internal__.CurrentSpeed !== 0) {
	                    var quat = new DSMath.Quaternion();
	                    quat.makeRotation(upVec, wheelRotation);
	                    var motionPt = moveVec.applyQuaternion(quat);//quat.rotate(moveVec);

	                    //first we compute the center of the roation for the car                    
	                    if (keyState.turnLeft > 0) {
	                        var FLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	                        var BLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;

	                        var carRotationAngle = Math.atan2((motionPt.y + FLwheelCenterPosition.y) - BLwheelCenterPosition.y, (motionPt.x + FLwheelCenterPosition.x) - BLwheelCenterPosition.x) -
                                                   Math.atan2(FLwheelCenterPosition.y - BLwheelCenterPosition.y, FLwheelCenterPosition.x - BLwheelCenterPosition.x);
	                        this.rotateAround(actor, BLwheelCenterPosition, upVec, carRotationAngle);


	                    } else {
	                        var FRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	                        var BRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL).vector;

	                        var carRotationAngle = Math.atan2((motionPt.y + FRwheelCenterPosition.y) - BRwheelCenterPosition.y, (motionPt.x + FRwheelCenterPosition.x) - BRwheelCenterPosition.x) -
                                                   Math.atan2(FRwheelCenterPosition.y - BRwheelCenterPosition.y, FRwheelCenterPosition.x - BRwheelCenterPosition.x);
	                        this.rotateAround(actor, BRwheelCenterPosition, upVec, carRotationAngle);
	                    }
	                    actorTransform = actor.getTransform();
	                }

	                //save rotation amount and wheel direction
	                this.__internal__.CurrentWheelRotationAmount = currentWheelRotationAmount;
	                this.__internal__.CurrentWheelDirection = currentWheelDirection;

	                //rotate left front wheel
	                var FLwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFL).vector;
	                this.rotateAround(wheels.WheelFL, FLwheelCenterPosition, upVec, wheelRotation);

	                //rotate right front wheel
	                var FRwheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelFR).vector;
	                this.rotateAround(wheels.WheelFR, FRwheelCenterPosition, upVec, wheelRotation);




	                // var mySphere = STU.Experience.getCurrent().getActorByName("Sphere 1");
	                // if (mySphere !== undefined && mySphere !== null || (mySphere instanceof STU.Actor3D)) {

	                //     mySphere.setPosition(FLwheelCenterPosition);

	                // }

	                //  mySphere = STU.Experience.getCurrent().getActorByName("Sphere 2");
	                // if (mySphere !== undefined && mySphere !== null || (mySphere instanceof STU.Actor3D)) {

	                //     mySphere.setPosition(FRwheelCenterPosition);

	                // }
	            }
	        }
	    };

	    /**
		 * Computes the wheels transformation matrix in the actor frame
		 *
		 * @method
		 * @private
		 * @param  {STU.Actor3D} iActor  Car actor
		 */
	    CarController.prototype.init = function (iActor) {
	        this.__internal__.Init = true;
	        var wheels = this.__internal__.Wheels;

	        //wheels bounding shpere
	        var wheelBS = this.__internal__.BoundingSphere;

	        //actor transform 
	        var P01 = iActor.getTransform();

	        for (var w in wheels) { /*jshint -W089 */
	            //save tranforms
	            this.__internal__.transforms[w] = wheels[w].getTransform(iActor);

	            // As Actor3D.getBoundingSphere can't be trusted cf IR-330971 
	            // I use the bounding box to compute the bounding sphere
	            var box = wheels[w].getBoundingBox();
	            wheelBS[w] = {
	                center: {
	                    x: (box.high.x + box.low.x) * 0.5,
	                    y: (box.high.y + box.low.y) * 0.5,
	                    z: (box.high.z + box.low.z) * 0.5
	                },
	                radius: Math.abs(box.high.z - box.low.z) * 0.5
	            };
	        }

	        var frontVec = DSMath.Vector3D.sub(wheelBS.WheelFR.center, wheelBS.WheelBR.center);
	        frontVec.normalize();

	        var leftVec = DSMath.Vector3D.sub(wheelBS.WheelBL.center, wheelBS.WheelBR.center);
	        leftVec.normalize();

	        var upVec = DSMath.Vector3D.cross(frontVec, leftVec);

	        var coeff = [leftVec.x, upVec.x, frontVec.x,
				leftVec.y, upVec.y, frontVec.y,
				leftVec.z, upVec.z, frontVec.z
	        ];


	        //save state and deactivate pickablity of the car iActor
	        var carClickableState = iActor.clickable;
	        iActor.clickable = true;

	        for (var w in wheels) {
	            var P03 = new DSMath.Transformation();
	            var A = wheelBS[w].center;

	            //we compute the radius of each wheels as the bounding sphere radius cannot be trusted  
	            this.__internal__.Radius[w] = this.computeWheelRadius(wheelBS[w], wheels[w]);

	            P03.matrix.setFromArray(coeff);
	            P03.vector.set(A.x, A.y, A.z);

	            var P30 = P03.getInverse();
	            var P31 = DSMath.Transformation.multiply(P30, P01);
	            var P13 = P31.getInverse();
	            this.__internal__.P13w[w] = P13;
	        }

	        var actor = this.getActor();
	        var actorTransform = actor.getTransform();

	        var P03 = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w.WheelBL);
	        var matrixCoeff = P03.matrix.getArray();
	        var LeftVectWheel = new DSMath.Vector3D();
	        LeftVectWheel.set(matrixCoeff[0], matrixCoeff[3], matrixCoeff[6]);

	        for (var w in wheels) {
	            var wheelCenterPosition = actor.getPosition();
	            wheelCenterPosition = DSMath.Transformation.multiply(actorTransform, this.__internal__.P13w[w]).vector;
	            this.rotateAround(wheels[w], wheelCenterPosition, LeftVectWheel, 0.0001);
	            this.__internal__.transforms[w] = wheels[w].getTransform(actor);
	        }

	        iActor.clickable = carClickableState;
	    };

	    /**
		 * Rotate an Actor around a vector
		 *
		 * @method
		 * @private
		 * @param  {STU.Actor3D} iActor  Actor to rotate
		 * @param  {DSMath.Vector3D} iOrigin Center of the rotation
		 * @param  {DSMath.Vector3D} iVector Vector to rotate around
		 * @param  {Number} iAngle  Angle in radian
		 */
	    CarController.prototype.rotateAround = function (iActor, iOrigin, iVector, iAngle) {
	        var actorCenterToOrigin = new DSMath.Vector3D();

	        var quat = new DSMath.Quaternion();
	        //quat = DSMath.Quaternion.makeRotation(vectClone, iAngle);
	        quat.s = Math.cos(iAngle / 2);
	        quat.x = iVector.x * Math.sin(iAngle / 2);
	        quat.y = iVector.y * Math.sin(iAngle / 2);
	        quat.z = iVector.z * Math.sin(iAngle / 2);

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
		 * Callback called when a keyboard key is hit
		 * @method
		 * @private
		 */
	    CarController.prototype.onKeyboardEvent = function (iKeyboardEvent) {
	        var isPressed = 0;
	        if (iKeyboardEvent.constructor === EP.KeyboardPressEvent) {
	            var isPressed = 1;
	        } else if (iKeyboardEvent.constructor === EP.KeyboardReleaseEvent) {
	            var isPressed = 0;
	        } else {
	            return;
	        }

	        switch (iKeyboardEvent.getKey()) {
	            case this.moveForward:
	                this.__internal__.keyState.moveForward = isPressed;
	                break;

	            case this.moveBackward:
	                this.__internal__.keyState.moveBackward = isPressed;
	                break;

	            case this.turnRight:
	                this.__internal__.keyState.turnRight = isPressed;
	                break;

	            case this.turnLeft:
	                this.__internal__.keyState.turnLeft = isPressed;
	                break;

	            case this.brake:
	                this.__internal__.keyState.brake = isPressed;
	                break;
	        }
	    };


	    CarController.prototype.onGamepadEvent = function (iGamepadEvent) {
	        var isPressed = 0;

	        if (iGamepadEvent.constructor === EP.GamepadPressEvent) {
	            isPressed = 1;
	        } else if (iGamepadEvent.constructor === EP.GamepadReleaseEvent) {
	            isPressed = 0;
	        } else {
	            return;
	        }

	        switch (iGamepadEvent.button) {
	            case EP.Gamepad.EButton.eDPadUp:
	            case EP.Gamepad.EButton.eA:
	                this.__internal__.keyState.moveForward = isPressed;
	                break;

	            case EP.Gamepad.EButton.eDPadDown:
	                this.__internal__.keyState.moveBackward = isPressed;
	                break;

	            case EP.Gamepad.EButton.eDPadRight:
	                this.__internal__.keyState.turnRight = isPressed;
	                break;

	            case EP.Gamepad.EButton.eDPadLeft:
	                this.__internal__.keyState.turnLeft = isPressed;
	                break;

	            case EP.Gamepad.EButton.eX:
	                this.__internal__.keyState.brake = isPressed;
	                break;
	        }
	    };

	    CarController.prototype.handleGamepadAxis = function () {
	        var gp = EP.Devices.getGamepad();
	        if (gp === undefined || gp === null) {
	            return;
	        }

	        var gpAxisValueX = gp.getAxisValue(EP.Gamepad.EAxis.eRSX);
	        var gpAbsAxisValueX = Math.abs(gpAxisValueX);

	        var gpAxisValueY = gp.getAxisValue(EP.Gamepad.EAxis.eLSY);
	        var gpAbsAxisValueY = Math.abs(gpAxisValueY);

	        if (gpAbsAxisValueX <= 0.1 && gpAbsAxisValueY <= 0.1 && !gp.isButtonPressed(EP.Gamepad.EButton.eA)) {
	            if (this.__internal__.cleanGamePadAxis === false) {
	                this.__internal__.keyState.moveForward = 0;
	                this.__internal__.keyState.moveBackward = 0;
	                this.__internal__.keyState.turnRight = 0;
	                this.__internal__.keyState.turnLeft = 0;
	                this.__internal__.cleanGamePadAxis = true;
	            }
	            return;
	        }

	        /*		var strenghtAmount = Math.sqrt(gpAxisValueX*gpAxisValueX + gpAxisValueY*gpAxisValueY);
			 */
	        this.__internal__.cleanGamePadAxis = false;
	        if (gpAxisValueX > 0) {
	            this.__internal__.keyState.turnRight = gpAbsAxisValueX;
	            this.__internal__.keyState.turnLeft = 0;
	        } else {
	            this.__internal__.keyState.turnLeft = gpAbsAxisValueX;
	            this.__internal__.keyState.turnRight = 0;
	        }

	        if (gpAxisValueY > 0) {
	            this.__internal__.keyState.moveForward = 1;
	            this.__internal__.keyState.moveBackward = 0;
	        }
	        else if (gpAxisValueY < 0) {
	            this.__internal__.keyState.moveForward = 0;
	            this.__internal__.keyState.moveBackward = 1;
	        }
	    };

	    /**
		 * Process executed when STU.CarController is activating
		 *
		 * @method
		 * @private
		 */
	    CarController.prototype.onActivate = function () {
	        Behavior.prototype.onActivate.call(this);

	        this.associatedTask = new CarControllerTask(this);
	        EP.TaskPlayer.addTask(this.associatedTask);

	        this.keyboardCb = STU.makeListener(this, 'onKeyboardEvent');
	        EP.EventServices.addListener(EP.KeyboardEvent, this.keyboardCb);

	        this.gamepadCB = STU.makeListener(this, 'onGamepadEvent');
	        EP.EventServices.addListener(EP.GamepadEvent, this.gamepadCB);

	        /*		this.gamepadAxisCB = STU.makeListener(this, 'onGamepadAxisEvent');
		EP.EventServices.addListener(EP.GamepadAxisEvent, this.gamepadAxisCB);*/
	    };

	    /**
		 * Process executed when STU.CarController is deactivating
		 *
		 * @method
		 * @private
		 */
	    CarController.prototype.onDeactivate = function () {
	        EP.EventServices.removeListener(EP.KeyboardEvent, this.keyboardCb);
	        delete this.keyboardCb;

	        EP.EventServices.removeListener(EP.GamepadEvent, this.gamepadCB);
	        delete this.gamepadCB;

	        /*		EP.EventServices.removeListener(EP.GamepadAxisEvent, this.gamepadAxisCB);
		delete this.gamepadAxisCB;*/

	        EP.TaskPlayer.removeTask(this.associatedTask);
	        delete this.associatedTask;

	        Behavior.prototype.onDeactivate.call(this);
	    };

	    /**
		 * TODO : to be commented
		 *
		 * @method
		 * @private
		 */
	    CarController.prototype.computeWheelRadius = function (iWheelBS, iWheel) {
	        var oWheelRadius = -1;

	        var renderManager = STU.RenderManager.getInstance();

	        //save state and activate pickablity of the wheel subActor
	        var wheelClickableState = iWheel.clickable;
	        iWheel.clickable = true;

	        //We are going to launch a ray from the top of the bounding sphere to the wheel center,
	        //this way, we'll be able to compute the exact radius of the wheel

	        var wheelBSCenter = iWheelBS.center;
	        var wheelBSRadius = iWheelBS.radius;
	        var rayVect = new STU.Ray();

	        rayVect.origin.x = wheelBSCenter.x;
	        rayVect.origin.y = wheelBSCenter.y;
	        rayVect.origin.z = wheelBSCenter.z + wheelBSRadius + 10;

	        rayVect.direction.x = 0;
	        rayVect.direction.y = 0;
	        rayVect.direction.z = -1;

	        rayVect.setLength(wheelBSRadius * 2 + 20);

	        // conversion rayvec de location -> world
	        var scene = this.actor.getLocation();
	        var intersectArray = renderManager._pickFromRay(rayVect, false, false, scene);
	        var nbImpacts = intersectArray.length;

	        for (var i = 0; i < nbImpacts; i++) {
	            if (intersectArray[i].actor !== null && intersectArray[i].actor !== undefined && intersectArray[i].actor.name === iWheel.name) {
	                var intersectedPoint = intersectArray[i].getPoint();
	                oWheelRadius = intersectedPoint.z - wheelBSCenter.z;
	                break;
	            }
	        }

	        if (oWheelRadius === -1) {
	            console.error('Wheel Radius should have been computed, something went wrong');

	            // le radius de la roue c'est l'amplitude en z de la bbox orientée dans le repère de la voiture
	            var MyCar = this.getActor();
	            var WheelPosInCarReferrential = iWheel.getTransform(MyCar);

	            // on se place dans le repère du Car :
	            iWheel.setTransform(WheelPosInCarReferrential, "Location"); // in world / scene
	            var BBoxInCarReferrential = iWheel.getBoundingBox(); // in world / scene

	            // on restaure la position initiale
	            iWheel.setTransform(WheelPosInCarReferrential, MyCar);

	            // on a la BBox de la roue dans le repère de la voiture. Il manque le scaling voiture -> scene
	            var CarScaleRelToScene = MyCar.getTransform("Location").getScaling().scale;
	            if (CarScaleRelToScene <= 0.0) {
	                CarScaleRelToScene = 1.0;
	            }

	            oWheelRadius = 0.5 * (BBoxInCarReferrential.high.z - BBoxInCarReferrential.low.z) * CarScaleRelToScene;
	            if (oWheelRadius < 0) {
	                oWheelRadius = -oWheelRadius;
	            }
	            console.error('fallback radius : ');
	            console.error(oWheelRadius);
	        }

	        iWheel.clickable = wheelClickableState;
	        return oWheelRadius;
	    };

	    CarController.prototype.noEpsilon = function (iValue, iEps) {
	        if (Math.abs(iValue) < iEps) {
	            return 0.0;
	        }
	        return iValue;
	    };

	    CarController.prototype.dumpPos = function (iPos) {
	        var NbDigits = 6;
	        var Epsilon = 1e-10;
	        var dumpLoc = "----- Pos : (NbDigits :" + NbDigits + " eps :" + Epsilon + ")" + "\n";

	        var Ux = this.noEpsilon(iPos.matrix.coef[0], Epsilon);
	        var Uy = this.noEpsilon(iPos.matrix.coef[1], Epsilon);
	        var Uz = this.noEpsilon(iPos.matrix.coef[2], Epsilon);

	        var Vx = this.noEpsilon(iPos.matrix.coef[3], Epsilon);
	        var Vy = this.noEpsilon(iPos.matrix.coef[4], Epsilon);
	        var Vz = this.noEpsilon(iPos.matrix.coef[5], Epsilon);

	        var Wx = this.noEpsilon(iPos.matrix.coef[6], Epsilon);
	        var Wy = this.noEpsilon(iPos.matrix.coef[7], Epsilon);
	        var Wz = this.noEpsilon(iPos.matrix.coef[8], Epsilon);

	        var Tx = this.noEpsilon(iPos.vector.x, Epsilon);
	        var Ty = this.noEpsilon(iPos.vector.y, Epsilon);
	        var Tz = this.noEpsilon(iPos.vector.z, Epsilon);

	        dumpLoc = dumpLoc + "     Matrix : " + "\n";
	        dumpLoc = dumpLoc + "          " + Ux.toExponential(NbDigits) + " , " + Uy.toExponential(NbDigits) + " , " + Uz.toExponential(NbDigits) + "\n";
	        dumpLoc = dumpLoc + "          " + Vx.toExponential(NbDigits) + " , " + Vy.toExponential(NbDigits) + " , " + Vz.toExponential(NbDigits) + "\n";
	        dumpLoc = dumpLoc + "          " + Wx.toExponential(NbDigits) + " , " + Wy.toExponential(NbDigits) + " , " + Wz.toExponential(NbDigits) + "\n";

	        dumpLoc = dumpLoc + "     Vector : " + "\n";
	        dumpLoc = dumpLoc + "          " + Tx.toExponential(NbDigits) + " , " + Ty.toExponential(NbDigits) + " , " + Tz.toExponential(NbDigits) + "\n";
	        return dumpLoc;
	    };

	    CarController.prototype.vector2String = function (iVector) {
	        var NbDigits = 10;
	        var Epsilon = 1e-10;
	        var Tx = this.noEpsilon(iVector.x, Epsilon);
	        var Ty = this.noEpsilon(iVector.y, Epsilon);
	        var Tz = this.noEpsilon(iVector.z, Epsilon);

	        return "{ " + Tx.toExponential(NbDigits) + " ; " + Ty.toExponential(NbDigits) + " ; " + Tz.toExponential(NbDigits) + " }";
	    }

	    

	    // Expose in STU namespace.
	    STU.CarController = CarController;

	    return CarController;
	});

define('StuMiscContent/StuCarController', ['DS/StuMiscContent/StuCarController'], function (CarController) {
    'use strict';

    return CarController;
});

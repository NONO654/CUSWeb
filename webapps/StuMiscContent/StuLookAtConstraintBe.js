define('DS/StuMiscContent/StuLookAtConstraintBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef'],
	function (STU, Behavior, Task, EP, DSMath) {
	    'use strict';

	    
	    var LookAtConstraintTask = function (iComp) {
	        Task.call(this);
	        this.comp = iComp;
	    };

	    LookAtConstraintTask.prototype = new Task();
	    LookAtConstraintTask.prototype.constructor = LookAtConstraintTask;
	    LookAtConstraintTask.prototype.onExecute = function (iExContext) {

	        if (this.comp === undefined || this.comp === null) {
	            return;
	        }
	        this.comp._deltaTime = iExContext.getDeltaTime() / 1000;
	        this.comp.update();

		};
		
		

	    /////////////////////////////
	    //LookAt Constraint
	    /////////////////////////////
	    /**
		 * Behavior that allows the user to orientate an object toward another in such way that it seems like to look at the other object
		 *
		 * @exports LookAt
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
		 * @alias STU.LookAt
		 */
	    var LookAt = function () {

	        Behavior.call(this);
	        this.name = 'Look At';
	        this.componentInterface = this.protoId;

	        //////////////////////////////////////////////////////////////////////////
	        // Properties that should be visible in UI
	        //////////////////////////////////////////////////////////////////////////

	        /**
			 * The target that actor will look at
			 * @public
			 * @type {STU.Actor3D}
			 */
	        this.target = null;

	        /**
			 * The axis used to look at the target
			 * {0=X, 1=-X, 2=Y, 3=-Y, 4=Z, 5=-Z}
			 * @public
			 * @type {STU.LookAt.EAxis}
			 */
	        this.direction = 0;

	        /**
			 * The smoothness coefficient applied on the actor movement
			 * @public
			 * @type {Number}
			 */
	        this.smoothness = 100;

	        //private
	        this._active = true;
	        //this._durationEnd = 0;
	        this._scale = 1;

	        this._restoringOrientation = false;
	        this._startQuaternion = null;
	        this._lastQuaternion = null;

	        this._preferY = false;
	    };

	    /////////////////////////////////////////////////////////////////////////

	    LookAt.prototype = new Behavior();
	    LookAt.prototype.constructor = LookAt;
	    LookAt.prototype.protoId = '84C60302-5B4A-410C-8F1A-1798BA7E3C0A';

		/**
         * An enumeration of supported axes</br>
         *
         * @enum {number}
         * @public         
         */
        LookAt.EAxis = {
			eX0: 0,
	        eX1: 1,
	        eY0: 2,
	        eY1: 3,
	        eZ0: 4,
	        eZ1: 5
        };

	    /**
		 * Process to execute when this STU.LookAt is activating. 
		 * @private
		 */
	    LookAt.prototype.onActivate = function () {
	        Behavior.prototype.onActivate.call(this);
	        //console.log("activation LookAt");

	        this.myTask = new LookAtConstraintTask(this);
	        EP.TaskPlayer.addTask(this.myTask);

	        this.durationDone = 0;

	        //this.direction
	        if (this.smoothness <= 0) {
	            this.smoothness = 1;
	            console.warn("[Look At] Smmothness value should not be equals or under zero");
	        }

	        this._scale = this.actor.getScale();
	        this._startQuaternion = this.actor.getTransform().clone().matrix.getQuaternion();
	    };

	    /**
		 * Process to execute when this STU.LookAt is deactivating. 	
		 * @private
		 */
	    LookAt.prototype.onDeactivate = function () {
	        Behavior.prototype.onDeactivate.call(this);
	        //console.log("deactivation LookAt");

	    };
	    ////////////////////////////////////////////////////
	    LookAt.prototype.switchDirection = function () {

	        var direction;
	        switch (this.direction) {
	            case LookAt.EAxis.eX0:
	                direction = "x";
	                break;
	            case LookAt.EAxis.eX1:
	                direction = "-x";
	                break;
	            case LookAt.EAxis.eY0:
	                direction = "y";
	                break;
	            case LookAt.EAxis.eY1:
	                direction = "-y";
	                break;
	            case LookAt.EAxis.eZ0:
	                direction = "z";
	                break;
	            case LookAt.EAxis.eZ1:
	                direction = "-z";
	                break;
	            default:
	                break;
	        }
	        return direction;
	    };
	    ////////////////////////////////////////////////////
	    ////////////////////////////////////////////////////   

	    /* 
		 * Compute the target position from the Object's Forward direction
		 * and the last distance to target computed.
		 *
		 * @method
		 * @public
		 * @return {DSMath.Vector3D} 
		 */
	    LookAt.prototype.getTargetPosition = function () {
	        var targetPos = DSMath.multiplyScalar(this.getForward(), this.distanceToTarget);
	        targetPos.add(this.getPosition());
	        return targetPos;
	    };

	    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

	    LookAt.prototype.update = function () {

	        /*if (this.reference !== null && this.reference !== undefined) {
			    this.lookAt(this.reference);
			}*/

	        if (this.target !== null && this.target !== undefined && this._restoringOrientation === false) {
	            this.lookAt(this.target);
	        } else if (this._restoringOrientation === true) {
	            this.updateRestoreOrientation();
	        }

	    };

	    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	    /* 
		 * Make the Object look at the given position or node
		 *
		 * This method preserves the roll angle by keeping
		 * the right direction parallel to the ground.
		 *
		 * @method
		 * @public
		 * @param {DSMath.Vector3D|STU.Actor3D} iTarget
		 */
	    LookAt.prototype.lookAt = function (iTarget) {
	        if (!this._active) {
	            return;
	        }
	        var direction = this.switchDirection();

	        //var easeFinished = (this.durationDone / this.smoothness) > 0.95;
	        var myActor = this.getActor();
	        if (!(myActor instanceof STU.Actor3D)) {
	            return;
	        }

	        var targetPos;
	        if (iTarget instanceof STU.Actor3D) {
	            targetPos = iTarget.getPosition();
	        } else if (iTarget instanceof DSMath.Vector3D) {
	            targetPos = iTarget.clone();
	        }

	        // computing the new sight direction using current eye position and the position of the target
	        var dir = myActor.getPosition();
	        dir.sub(targetPos);
	        dir.normalize();

	        var transform = myActor.getTransform();
	        var myActorMatrix = transform.matrix.getArray();

	        var myActorDir = new DSMath.Vector3D();
	        //Switch Direction
	        if (direction === "-x") {
	            myActorDir.set(myActorMatrix[0], myActorMatrix[3], myActorMatrix[6]);
	        } else if (direction === "x") {
	            myActorDir.set(-myActorMatrix[0], -myActorMatrix[3], -myActorMatrix[6]);
	        } else if (direction === "y") {
	            myActorDir.set(-myActorMatrix[1], -myActorMatrix[4], -myActorMatrix[7]);
	        } else if (direction === "-y") {
	            myActorDir.set(myActorMatrix[1], myActorMatrix[4], myActorMatrix[7]);
	        } else if (direction === "z") {
	            myActorDir.set(-myActorMatrix[2], -myActorMatrix[5], -myActorMatrix[8]);
	        } else if (direction === "-z") {
	            myActorDir.set(myActorMatrix[2], myActorMatrix[5], myActorMatrix[8]);
	        }
	        //-------------------------------------------------
	        myActorDir.normalize();
	        //-------------------------------------------------
	        var vectEquals = myActorDir.isEqual(dir, 0.0001);
	        if (vectEquals) {
	            return;
	        }
	        var oppositeVectEquals = myActorDir.isEqual(dir.clone().negate(), 0.0001);
	        var cosAlpha = oppositeVectEquals ? -1 : myActorDir.dot(dir);
	        //var cosAlpha = myActorDir.dot(dir);
	        var alpha = Math.acos(cosAlpha);

	        var rotVector;
	        if (cosAlpha === -1) {
	            if (direction === "x" || direction === "-x") {
	                rotVector = new DSMath.Vector3D(myActorMatrix[1], myActorMatrix[4], myActorMatrix[7]);
	            } else if (direction === "y" || direction === "-y") {
	                rotVector = new DSMath.Vector3D(myActorMatrix[2], myActorMatrix[5], myActorMatrix[8]);
	            } else if (direction === "z" || direction === "-z") {
	                rotVector = new DSMath.Vector3D(myActorMatrix[0], myActorMatrix[3], myActorMatrix[6]);
	                //rotVector = new DSMath.Vector3D(-myActorMatrix[1], -myActorMatrix[4], -myActorMatrix[7]);
	            }
	        } else {
	            rotVector = DSMath.Vector3D.cross(myActorDir, dir);
	            rotVector.normalize();
	        }

	        /*if (rotVector.x === 0 && rotVector.y === 0 && rotVector.z === 0) {
			    rotVector = Z.clone();
			}*/

	        var ZLocal;
	        if (direction === "x" || direction === "-x") {
	            ZLocal = new DSMath.Vector3D(myActorMatrix[2], myActorMatrix[5], myActorMatrix[8]);
	        } else if (direction === "y" || direction === "-y") {
	            ZLocal = new DSMath.Vector3D(myActorMatrix[2], myActorMatrix[5], myActorMatrix[8]);
	        } else if (direction === "z" || direction === "-z") {
	            if (!this._preferY) {
	                ZLocal = new DSMath.Vector3D(myActorMatrix[0], myActorMatrix[3], myActorMatrix[6]);
	            }
	            else {
	                ZLocal = new DSMath.Vector3D(-myActorMatrix[1], -myActorMatrix[4], -myActorMatrix[7]);
	            }
	        }
	        var ZWorld = DSMath.Vector3D.zVect;

	        var loc = this.actor.getLocation();
	        //if we are in a globe context
	        if (loc !== null && loc !== undefined) {
	            ZWorld = loc.getTransform().matrix.getThirdColumn().normalize();
	        }

	        this.durationDone += this._deltaTime;
	        this.durationDone = this.durationDone % this.smoothness;

	        var Z = DSMath.Vector3D.lerp(ZLocal, ZWorld, this.durationDone / this.smoothness);
	        Z.normalize();

	        //var ease = STU.EasingMethods.linear(this.durationDone / this.smoothness);
	        var ease = this.durationDone / this.smoothness;

	        var quat = new DSMath.Quaternion();

	        quat.makeRotation(rotVector, alpha * ease);


	        var motionPt = myActorDir.applyQuaternion(quat); //var motionPt = quat.rotate(myActorDir);
	        var finalDir = new DSMath.Vector3D(motionPt.x, motionPt.y, motionPt.z);
	        //finalDir.set(motionPt.x, motionPt.y, motionPt.z);
	        finalDir.normalize();
	        //-------------------------------------------------

	        // projecting the new sight direction on the ground to get a right direction parallel to the ground
	        //var dirOnGround = DSMath.Vector3D.cross(Z, DSMath.Vector3D.cross(finalDir, Z));
	        var dirOnGround = DSMath.Vector3D.cross(Z, DSMath.Vector3D.cross(finalDir, Z)); //DSMath.Vector3D.cross(finalDir, Z) ==> RightVector after rotation

	        dirOnGround.normalize();

	        // computing the right direction using the ground-projected sight direction
	        var right = DSMath.Vector3D.cross(Z, dirOnGround);
	        right.normalize();

	        // computing the up direction as usual
	        var up = DSMath.Vector3D.cross(finalDir, right);
	        up.normalize();

	        // updating the transform

	        var newTransformMatrix = new DSMath.Matrix3x3();
	        if (direction === "-x") {
	            newTransformMatrix.setFromArray([finalDir.x, right.x, up.x,
					finalDir.y, right.y, up.y,
					finalDir.z, right.z, up.z
	            ]);
	        } else if (direction === "x") {
	            newTransformMatrix.setFromArray([-finalDir.x, -right.x, up.x, -finalDir.y, -right.y, up.y, -finalDir.z, -right.z, up.z]);
	        } else if (direction === "y") {
	            newTransformMatrix.setFromArray([right.x, -finalDir.x, up.x,
												right.y, -finalDir.y, up.y,
												right.z, -finalDir.z, up.z
	            ]);
	            /*newTransformMatrix.setFromArray([up.x, -finalDir.x, right.x,
				                            up  .y, -finalDir.y, right.y,
				                                up.z, -finalDir.z, right.z]);*/
	            //console.log(finalDir);
	        } else if (direction === "-y") {
	            newTransformMatrix.setFromArray([-right.x, finalDir.x, up.x, -right.y, finalDir.y, up.y, -right.z, finalDir.z, up.z]);
	        } else if (direction === "z") {
	            if (!this._preferY) {
	                newTransformMatrix.setFromArray([up.x, right.x, -finalDir.x,
													 up.y, right.y, -finalDir.y,
													 up.z, right.z, -finalDir.z
	                ]);
	            }
	            else {
	                newTransformMatrix.setFromArray([right.x, -up.x, -finalDir.x,
												 	 right.y, -up.y, -finalDir.y,
												 	 right.z, -up.z, -finalDir.z
	                ]);
	            }

	        } else if (direction === "-z") {
	            if (!this._preferY) {
	                newTransformMatrix.setFromArray([up.x, -right.x, finalDir.x,
													 up.y, -right.y, finalDir.y,
													 up.z, -right.z, finalDir.z
	                ]);
	            }
	            else {
	                newTransformMatrix.setFromArray([right.x, -up.x, finalDir.x,
													 right.y, -up.y, finalDir.y,
													 right.z, -up.z, finalDir.z
	                ]);
	            }
	        }
	        //-------------------------------------------------

	        //var scaleMatrx = new DSMath.Matrix3x3();
	        //scaleMatrx.makeScaling(3);
	        //console.log(this.actor.getScale());
	        newTransformMatrix.multiplyScalar(Math.abs(this.actor.getScale()));
	        transform.matrix = newTransformMatrix;

	        // applying new transform to the actor        
	        myActor.setTransform(transform);
	    };

	    /////////////////////////////////////////////////////
	    /**
		 * Make the actor looks at the given actor
		 * @method
		 * @param {STU.Actor3D} iTarget the target that the actor will look at.
		 * @public
		 */
	    LookAt.prototype.startsLookingAt = function (iTarget) {
	        //if (!this._active) {
	        if (iTarget !== null && iTarget !== undefined) {
	            this.target = iTarget;
	        }
	        this._active = true;
	        this.durationDone = 0;
	        //}
	    };

	    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    /**
		 * Make the actor stops looking at it's target
		 * @method
		 * @public
		 */
	    LookAt.prototype.stopsLookingAt = function () {
	        if (this._active) {
	            this._active = false;
	        }
	    };

	    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    /**
		 * Return true is looking at the given target
		 * @method
		 * @param {STU.Actor3D} iTarget the given target.
		 * @return {Boolean}
		 * @public
		 */
	    LookAt.prototype.isLookingAt = function (iTarget) {
	        return this._active && iTarget === this.target;
	    };

	    /**
		 * Enable the condition to make the actor retrieve it's original orientation
		 * @method
		 * @private
		 */
	    LookAt.prototype.restoreOrientation = function () {
	        if (this._restoringOrientation === false) {
	            this._restoringOrientation = true;
	            this._lastQuaternion = this.actor.getTransform().clone().matrix.clone().getQuaternion();
	            this.durationDone = 0;
	        }
	    };

	    /**
		 * Update function which permit to the actor to retrieve its original orientation
		 * @method
		 * @private
		 */
	    LookAt.prototype.updateRestoreOrientation = function () {
	        this.durationDone += this._deltaTime;
	        //this.durationDone = this.durationDone % 1;

	        var t = new DSMath.Transformation();
	        t.vector = this.actor.getTransform().vector;

	        var q = DSMath.Quaternion.slerp(this._lastQuaternion, this._startQuaternion, this.durationDone);
	        t.matrix = q.getMatrix();

	        this.actor.setTransform(t);

	        if (this.durationDone >= 1) {
	            this._restoringOrientation = false;
	            this.target = null;
	            this.durationDone = 0;
	        }
	    };


	    // Expose in STU namespace.
	    STU.LookAt = LookAt;

	    return LookAt;
	});

define('StuMiscContent/StuLookAtConstraintBe', ['DS/StuMiscContent/StuLookAtConstraintBe'], function (LookAt) {
    'use strict';

    return LookAt;
});

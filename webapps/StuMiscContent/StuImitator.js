define('DS/StuMiscContent/StuImitator', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'MathematicsES/MathsDef'], function (STU, EP, Behavior, Task, DSMath) {
    'use strict';

    var ImitatorTask = function (iComp) {
        Task.call(this);
        this.comp = iComp;
    };

    ImitatorTask.prototype = new Task();
    ImitatorTask.prototype.constructor = ImitatorTask;

    /**
     * Method called each frame by the task manager
     *
     * @method
     * @private
     * @param  iExContext Execution context
     */
    ImitatorTask.prototype.onExecute = function (iExContext) {
        if ('executeOneFrame' in this.comp) {
            this.comp.executeOneFrame(iExContext);
        }
    };


    /**
    * Imitate a target
    *
    * @exports Imitate
    * @class 
    * @constructor
    * @noinstancector
    * @public
    * @extends {STU.Behavior}
    * @memberOf STU
    * @alias STU.Imitate
    */
    var Imitate = function () {
        Behavior.call(this);
        this.name = 'Imitate';
        this.associatedTask;

        // Public
        /**
         * The target of the Imitate
            * @public
         * @type {STU.Actor3D}
         */
        this.target = null;

        /**
        * True if you want to imitate the translation
            * @public
        * @type {Boolean}
        */
        this.imitateTranslation = true;

        /**
        * True if you want to imitate the rotation
            * @public
        * @type {Boolean}
        */
        this.imitateRotation = true;

        /**
        * True if you want to imitate the scale of the target
            * @public
        * @type {Boolean}
        */
        this.imitateScale = false;

        /**
        * The position offset of the actor compared with its target position
            * @public
            * @type {DSMath.Vector3D}
        */
        this.positionOffset = null;

        /**
        * The orientation offset of the actor compared with its target orientation
            * @public
            * @type {DSMath.Vector3D}
        */
        this.orientationOffset = null;

        /**
        * Permit to apply transformations on the world or local coordinate {0:LOCAL 1:WORLD}
        * @public
        * @type {STU.Imitate.eOffsetMode}
        */
        this.offsetMode = 0;//this.useGlobalFrameOffset = false;

        /**
        * True if you want the object's current transformation overwrite the position and orientation offset.
            * @public
        * @type {Boolean}
        */
        this.keepInitialOffsets = true;//this.useStartOffset = true;

        /**
        * Smoothing coefficient on the translation movement
            * @public
        * @type {Number}
        */
        this.translationSmoothness = 0.0;

        /**
        * Smoothing coefficient on the rotation movement
            * @public
        * @type {Number}
        */
        this.rotationSmoothness = 0.0;


        //Advanced 
        /**
            * Object containing 3 boolean that permit to enable respectively the imitation on the X, Y and Z axis.
            * @public
            * @type {STU.BooleanXYZ}
            */
        this.enableTranslationAxis = null;

        /**
            * Object containing 3 boolean that permit to enable respectively the imitation on the X, Y and Z axis.
            * @public
            * @type {STU.BooleanXYZ}
            */
        this.enableRotationAxis = null;


        // Private
        /**
         * The Vector representing the Offset
         * @private
             * @type {DSMath.Vector3D}
             */
        this._offsetVector = new DSMath.Vector3D();

        /**
         * Array storing the target's transformation for stabilization
         * @private
         * @type {Array}
         */
        this._queueStabilisator = [];

        /**
         * Array storing the target's transformation duration for stabilization
         * @private
         * @type {Array}
         */
        this._queueStabilisatorDuration = [];

        /**
        * Array storing the target's transformation for rotation stabilization
        * @private
        * @type {Array}
        */
        this._queueRotationStabilisator = [];

        /**
        * Array storing the target's transformation duration for rotation stabilization
        * @private
        * @type {Array}
        */
        this._queueRotationStabilisatorDuration = [];

        /**
         * Store the target's scale
         * @private
         * @type {Number}
         */
        this._targetScale = 1;

        /**
         * Store the initial scale of this actor
         * @private
         * @type {Number}
         */
        this._myScale = 1;

        /**
         * True if the target is defined
         * @private
         * @type {Boolean}
         */
        this._isTargetDefined = true;

        /**
         * The initial quaternion of this actor
         * @private
             * @type {DSMath.Quaternion}
             */
        this._initialQuat = new DSMath.Quaternion();

        /**
        * Define if the behavior is activated or not
        * @private
        * @type {Boolean}
        */
        this._activated = true;

    };

    Imitate.prototype = new Behavior();
    Imitate.prototype.constructor = Imitate;
    //Imitate.prototype.pureRuntimeAttributes = ['_zoom'].concat(Behavior.prototype.pureRuntimeAttributes);


    /**
     * An enumeration of all the supported offset mode.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    Imitate.eOffsetMode = {
        eLocal: 0,
        eWorld: 1
    };

    /**
    * Process executed when STU.Imitate is activating
    *
    * @method
    * @private
    */
    Imitate.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this.associatedTask = new ImitatorTask(this);
        EP.TaskPlayer.addTask(this.associatedTask);

        // Init
        this.checkTarget();
        if (!this._isTargetDefined) {
            return;
        }

        if (this.keepInitialOffsets) {
            this.setStartOffset();
        }

        //this._offsetVector.set(this.offsetX,this.offsetY,this.offsetZ);
        this._offsetVector = this.positionOffset.clone();

        //if (!this.enableTranslationAxis.x){
        //  this._offsetVector.x = 0;
        //}
        //if (!this.enableRotationAxis.y){
        //  this._offsetVector.y = 0;
        //}
        //if (!this.enableRotationAxis.z){
        //  this._offsetVector.z = 0;
        //}

        /*if(this.target == undefined || this.target == null){
          console.warn('Imitate Behavior has no target');
          this._isTargetDefined = false;
        }*/

        if (this.keepInitialOffsets) {
            var m = this.target.getTransform().matrix.clone();
            m.multiply(this.getActor().getTransform().matrix.clone());
            m.getQuaternion(this._initialQuat);
        }
        else {
            var t = new DSMath.Transformation();
            //var v = [this.rotatingOffsetX,this.rotatingOffsetY,this.rotatingOffsetZ];
            //var v = [this.orientationOffset.x, this.orientationOffset.y, this.orientationOffset.z];
            var v = [this.orientationOffset.z, this.orientationOffset.x, this.orientationOffset.y];
            t.setRotationFromEuler(v);
            var m = t.matrix.clone();
            m.getQuaternion(this._initialQuat);
        }

    };

    /**
    * Check if the target is defined and if register its transform properties
    * @method
    * @private
    */
    Imitate.prototype.checkTarget = function () {
        if (this.target !== null && this.target !== undefined) {
            this._targetScale = this.target.getScale();
            this._myScale = this.getActor().getScale();
            this._isTargetDefined = true;
        }
        else {
            this._isTargetDefined = false;
            console.warn("[Imitate Behavior]: Target undefined");
        }
    };

    /**
    * Use the current distance of the actor to the target to set the offset values
    * @method
    * @private
    */
    Imitate.prototype.setStartOffset = function () {
        var targetVector = this.target.getTransform().vector.clone();
        var thisVector = this.getActor().getTransform().vector.clone();
        thisVector.sub(targetVector);
        if (this.offsetMode === Imitate.eOffsetMode.eLocal) {// Si translo local 
            var m = this.target.getTransform().matrix.clone();
            thisVector = thisVector.applyMatrix3x3(m);
        }
        /*this.offsetX = thisVector.x;
        this.offsetY = thisVector.y;
        this.offsetZ = thisVector.z;*/
        this.positionOffset = thisVector.clone();

        //orientation
        var euler = this.getActor().getTransform().getEuler();
        var x = euler[1];
        var y = euler[2];
        var z = euler[0];
        this.orientationOffset = new DSMath.Vector3D(x, y, z);
    };



    /**
     * Process executed when STU.Imitate is deactivating
     * @method
     * @private
     */
    Imitate.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;
        Behavior.prototype.onDeactivate.call(this);
    };

    /**
    * Redefine the target of the behavior
    * @method
    * @private
    */
    Imitate.prototype.setTarget = function (target) {
        this.target = target;
    };

    /**
    * Get the average transform of the target
    * @method
    * @private
    */
    Imitate.prototype.getAverageTransform = function () {
        var averageTransform = new DSMath.Transformation();
        var totalTimeUsed = 0;
        var totalTimeRotationUsed = 0;

        averageTransform.vector.set(0, 0, 0);
        averageTransform.matrix.setFromArray([0, 0, 0, 0, 0, 0, 0, 0, 0]);

        var totalQuaternion = new DSMath.Quaternion();
        //totalQuaternion.rotMatrixToQuaternion(this._queueRotationStabilisator[this._queueRotationStabilisator.length - 1].matrix.clone()); //la rotation de fin est la rotation de la frame courante
        this._queueRotationStabilisator[this._queueRotationStabilisator.length - 1].matrix.clone().getQuaternion(totalQuaternion);

        //#############################################################################
        //                                  NEW METHOD
        //#############################################################################
        var quaternion = new DSMath.Quaternion();
        for (var i = this._queueRotationStabilisator.length - 1; i >= 0; i--) {

            if (totalTimeRotationUsed * 1.1 > this.rotationSmoothness * 1000) {
                this._queueRotationStabilisator.shift();
                this._queueRotationStabilisatorDuration.shift();
                //console.log("Test: "+this._queueRotationStabilisator.length);
                continue;
            }
            else {
                totalTimeRotationUsed += this._queueRotationStabilisatorDuration[i];
                var m = this._queueRotationStabilisator[i].matrix.clone().multiplyScalar(1 / this._targetScale);
                //quaternion.rotMatrixToQuaternion(this._queueRotationStabilisator[i].matrix.clone().multiplyMatrix(1 / this._targetScale));
                m.getQuaternion(quaternion);
            }
        }
        totalQuaternion = this.lerpQuaternion(quaternion, totalQuaternion, 0.5);
        //#############################################################################
        //                                  NEW METHOD
        //#############################################################################



        if (this.rotationSmoothness > 0) {
            totalQuaternion.getMatrix(averageTransform.matrix);
        }
        else {
            averageTransform.matrix = this._queueRotationStabilisator[this._queueRotationStabilisator.length - 1].matrix.clone();
        }

        for (var i = this._queueStabilisator.length - 1; i >= 0; i--) {
            //var quaternion = new ThreeDS.Mathematics.Quaternion();
            if (totalTimeUsed * 1.1 > this.translationSmoothness * 1000) {
                this._queueStabilisator.shift();
                this._queueStabilisatorDuration.shift();
                continue;
            }
            var localTime = this._queueStabilisatorDuration[i];

            var localVector = this._queueStabilisator[i].vector.clone();
            localVector.multiplyScalar(localTime);
            averageTransform.vector.add(localVector);

            totalTimeUsed += localTime;
        }
        if (this.translationSmoothness > 0) {
            averageTransform.vector.multiplyScalar(1 / totalTimeUsed);
        }
        else {
            averageTransform.vector = this._queueStabilisator[this._queueStabilisator.length - 1].vector.clone();
        }


        return averageTransform;
    };

    /**
    * Executed at each frame
    * @method
    * @private
    */
    Imitate.prototype.executeOneFrame = function (context) {
        if (!this._isTargetDefined || !this._activated) {
            return;
        }

        var actor = this.getActor();
        var currentTransform = actor.getTransform().clone();
        currentTransform.matrix.multiplyScalar(1 / actor.getScale());

        if (this.translationSmoothness >= 0 && this.rotationSmoothness >= 0) {
            var targetTransform = this.target.getTransform();

            //Translation Queue
            this._queueStabilisator.push(targetTransform);
            this._queueStabilisatorDuration.push(context.deltaTime);

            //Rotation Queue
            this._queueRotationStabilisator.push(targetTransform.clone());
            this._queueRotationStabilisatorDuration.push(context.deltaTime);

            var averageTransform = this.getAverageTransform();

            // Position Imitation
            if (this.imitateTranslation) {
                var v = currentTransform.vector.clone();
                var vecOffset = this._offsetVector.clone();

                var res = vecOffset.applyMatrix3x3(targetTransform.matrix.clone());
                vecOffset.x = res.x;
                vecOffset.y = res.y;
                vecOffset.z = res.z;

                if (this.enableTranslationAxis.x === false) {
                    averageTransform.vector.x = v.x;
                }
                else {
                    if (this.offsetMode === Imitate.eOffsetMode.eLocal) {
                        averageTransform.vector.x += vecOffset.x;
                    }
                    else if (this.offsetMode === Imitate.eOffsetMode.eWorld) {
                        averageTransform.vector.x += this._offsetVector.x;
                    }
                }

                if (this.enableTranslationAxis.y === false) {
                    averageTransform.vector.y = v.y;
                }
                else {
                    if (this.offsetMode === Imitate.eOffsetMode.eLocal) {
                        averageTransform.vector.y += vecOffset.y;
                    }
                    else if (this.offsetMode === Imitate.eOffsetMode.eWorld) {
                        averageTransform.vector.y += this._offsetVector.y;
                    }
                }

                if (!this.enableTranslationAxis.z) {
                    averageTransform.vector.z = v.z;
                }
                else {
                    if (this.offsetMode === Imitate.eOffsetMode.eLocal) {
                        averageTransform.vector.z += vecOffset.z;
                    }
                    else if (this.offsetMode === Imitate.eOffsetMode.eWorld) {
                        averageTransform.vector.z += this._offsetVector.z;
                    }
                }
            }
            else {
                averageTransform.vector = currentTransform.vector.clone();
            }

            // Rotation
            /*
            if (this.imitateRotation) {
              if (this.keepInitialOffsets === false) {
                var t = new DSMath.Transformation();
                var v = [this.orientationOffset.z, this.orientationOffset.x, this.orientationOffset.y];
                t.setRotationFromEuler(v);
                var m0 = t.matrix.clone();
                //this._initialQuat.rotMatrixToQuaternion(m0);
      
                //var m = this._initialQuat.quaternionToRotMatrix();
                averageTransform.matrix.multiply(m0);
              }
              else {
                var m = this._initialQuat.getMatrix();
                averageTransform.matrix.multiply(m);
              }
            }*/
            if (this.imitateRotation) {
                var euler = averageTransform.getEuler();
                if (!this.enableRotationAxis.y) {
                    euler[2] = 0;
                }
                if (!this.enableRotationAxis.x) {
                    euler[1] = 0;
                }
                if (!this.enableRotationAxis.z) {
                    euler[0] = 0;
                }
                averageTransform.setRotationFromEuler(euler);

                var t = new DSMath.Transformation();
                var v;
                if (this.keepInitialOffsets) {
                    v = [this.orientationOffset.z, this.orientationOffset.x, this.orientationOffset.y];
                }
                else {
                    //value from property view are in degree 
                    v = [(this.orientationOffset.z * Math.PI) / 180, (this.orientationOffset.x * Math.PI) / 180, (this.orientationOffset.y * Math.PI) / 180];
                }
                t.setRotationFromEuler(v);
                //var m0 = t.matrix.clone();
                //averageTransform.matrix.multiply(m0);
                var initialRot = new DSMath.Transformation();
                initialRot.setRotationFromEuler(euler);
                t.multiply(initialRot);
                averageTransform.matrix = t.matrix;
            }
            else {
                averageTransform.matrix = currentTransform.matrix.clone();
            }


            //Scaling
            if (!this.imitateScale && this._targetScale !== 0) {
                averageTransform.matrix.multiplyScalar(this._myScale);
            }
            else {
                averageTransform.matrix.multiplyScalar(this._targetScale);
            }

            actor.setTransform(averageTransform);
        }

    };

    /**
    * Linear interpolation between 2 quaternion
    * @method
    * @private
    */
    Imitate.prototype.lerpQuaternion = function (q1, q2, t) {
        var quaternion = new DSMath.Quaternion();
        var t_ = 1 - t;
        var arrayOfQ1 = q1.getArray(1);
        var arrayOfQ2 = q2.getArray(1);

        var s = t_ * q1.s + t * q2.s;

        var s = t_ * arrayOfQ1[0] + t * arrayOfQ2[0];
        var x = t_ * arrayOfQ1[1] + t * arrayOfQ2[1];
        var y = t_ * arrayOfQ1[2] + t * arrayOfQ2[2];
        var z = t_ * arrayOfQ1[3] + t * arrayOfQ2[3];

        var newCoef = [s, x, y, z];
        quaternion.setFromArray(newCoef, 1);
        quaternion.normalize();

        return quaternion;
    };

    /**
    * Start to imitate the target defined in argument
    * @param {STU.Actor3D} iTarget - The actor3D that will be used as target to imitate
    * @method 
    * @public
    */
    Imitate.prototype.startsImitation = function (iTarget) {
        console.log("Start Imitation");
        this._activated = true;
        this.target = iTarget;

        this.checkTarget();
        if (!this._isTargetDefined) {
            this._activated = false;
            return;
        }

        if (this.keepInitialOffsets) {
            this.setStartOffset();
        }

        this._offsetVector = this.positionOffset.clone();

        if (!this.enableTranslationAxis.x) {
            this._offsetVector.x = 0;
        }
        if (!this.enableRotationAxis.y) {
            this._offsetVector.y = 0;
        }
        if (!this.enableRotationAxis.z) {
            this._offsetVector.z = 0;
        }

        if (this.keepInitialOffsets) {
            var m = this.target.getTransform().matrix.clone();
            m.multiply(this.getActor().getTransform().matrix.clone());
            m.getQuaternion(this._initialQuat);
        }
        else {
            var t = new DSMath.Transformation();
            //var v = [this.orientationOffset.x, this.orientationOffset.y, this.orientationOffset.z];
            var v = [this.orientationOffset.z, this.orientationOffset.x, this.orientationOffset.y];
            t.setRotationFromEuler(v);
            var m = t.matrix.clone();
            m.getQuaternion(this._initialQuat);
        }
    };

    /**
    * Stop the imitation behavior
    * @method
    * @public
    */
    Imitate.prototype.stopsImitation = function () {
        this._activated = false;
        console.log("Stops Imitation");
    };

    /**
    * Return true if the object is currently imitating it's target. Else return false.
    * @method
    * @public
	* @return {Boolean}
    */
    Imitate.prototype.isImitating = function () {
        console.log("is imitating func");
        return this._activated;
    };

    STU.Imitate = Imitate;
    return Imitate;

});

define('StuMiscContent/StuImitator', ['DS/StuMiscContent/StuImitator'], function (Imitate) {
    'use strict';

    return Imitate;
});

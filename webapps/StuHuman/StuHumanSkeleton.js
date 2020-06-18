
define('DS/StuHuman/StuHumanSkeleton',
    ['DS/StuCore/StuContext', 'MathematicsES/MathsDef'],
    function (STU, DSMath) {
        'use strict';

        /**
        * Describe a STU.Actor3D which represents a Human created or imported in the experience.<br/>
        * 
        * To use it, you must have the following role: CHA - Marketing Content Animator
        *
        * @exports HumanSkeleton
        * @class 
        * @constructor
        * @noinstancector
        * @public
        * @param {STU.Human} iActor - Human actor
        * @memberof STU
        * @alias STU.HumanSkeleton
        */
        var HumanSkeleton = function (iActor) {
            //Instance.call(this);
            this.name = 'HumanSkeleton';

            /**
             * Human actor.
             *
             * Note: This property is in read access only.
             *
             * @member
             * @instance
             * @name actor
             * @public
		     * @readOnly
             * @type {STU.Human}
             * @memberOf STU.HumanSkeleton
             */
            this._actor = iActor;
            Object.defineProperty(this, 'actor', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this.getActor();
                }
            });
        };

        //////////////////////////////////////////////////////////////////////////////
        //                           Prototype definitions                          //
        //////////////////////////////////////////////////////////////////////////////
        //HumanSkeleton.prototype = new Instance();
        HumanSkeleton.prototype.constructor = HumanSkeleton;

        /**
        * Return the STU.Actor.
        *
        * @method
        * @public
        * @return {STU.Actor} instance object corresponding to the actor
        */
        HumanSkeleton.prototype.getActor = function () {
            return this._actor;
        };

        /**
        * Return the list of joint names.
        *
        * @method
        * @public
        * @return {Array<String>} A list of the joints names
        */
        HumanSkeleton.prototype.getJointNames = function () {
            var names = [];
            this._actor.CATRTHumanSkeleton.GetJointNameList(names);

            return names;
        };

        /**
        * Return the joint as world transformation.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Transformation}
        */
        HumanSkeleton.prototype.getJointWorldTransform = function (iName, iRef) {
            var transform = new DSMath.Transformation();
            this._actor.CATRTHumanSkeleton.GetJointWTransform(iName, transform);

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else { invRefTransform = iRef.getInverse(); }

                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
            /////////

            return transform;
        };

        /**
        * Return the joint as local transformation.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @return {DSMath.Transformation}
        */
        HumanSkeleton.prototype.getJointLocalTransform = function (iName) {
            var transform = new DSMath.Transformation();
            this._actor.CATRTHumanSkeleton.GetJointLTransform(iName, transform);

            return transform;
        };

        /**
        * Return the joint flexion as world vector.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Vector3D}
        */
        HumanSkeleton.prototype.getJointWorldFlexionVector = function (iName, iRef) {
            var vector = new DSMath.Vector3D();
            this._actor.CATRTHumanSkeleton.GetJointWFlexionVector(iName, vector);

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else { invRefTransform = iRef.getInverse(); }

                vector = vector.applyTransformation(invRefTransform);
            }

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            vector = vector.applyTransformation(tmpTr);
            /////////

            return vector;
        };

        /**
        * Return the joint abduction as world vector.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Vector3D}
        */
        HumanSkeleton.prototype.getJointWorldAbductionVector = function (iName, iRef) {
            var vector = new DSMath.Vector3D();
            this._actor.CATRTHumanSkeleton.GetJointWAbductionVector(iName, vector);

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else { invRefTransform = iRef.getInverse(); }

                vector = vector.applyTransformation(invRefTransform);
            }

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            vector = vector.applyTransformation(tmpTr);
            /////////

            return vector;
        };

        /**
        * Return the joint pronation as world vector.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Vector3D}
        */
        HumanSkeleton.prototype.getJointWorldPronationVector = function (iName, iRef) {
            var vector = new DSMath.Vector3D();
            this._actor.CATRTHumanSkeleton.GetJointWPronationVector(iName, vector);

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else { invRefTransform = iRef.getInverse(); }

                vector = vector.applyTransformation(invRefTransform);
            }

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            vector = vector.applyTransformation(tmpTr);
            /////////

            return vector;
        };

        /**
        * Get ZXY euler angles of a joint.
        *
        * @method
        * @public
        * @param {String} iName - joint name
        * @return {number[]}
        */
        HumanSkeleton.prototype.getJointLocalEulerAngles = function (iName) {
            var eulerAngles = [];
            this._actor.CATRTHumanSkeleton.GetJointLEulerAngles(iName, eulerAngles);

            return eulerAngles;
        };

        /**
        * Get all joints local euler angles
        *
        * @method
        * @public
        * @returns {number[]}
        */
        HumanSkeleton.prototype.getAllJointsLocalEulerAngles = function () {
            var result = [];

            this._actor.CATRTHumanSkeleton.GetAllJointLEulerAngles(result);

            return result;
        };

        /**
        * Set all joints local euler angles
        *
        * @method
        * @public
        * @param {number[]} iEulerAngles - array of ZXY euler angles
        * @param {boolean} [iUpdateSkinning=true] - to update the skinning
        * @returns {boolean}
        */
        HumanSkeleton.prototype.setAllJointsLocalEulerAngles = function (iEulerAngles, iUpdateSkinning) {
            var result = this._actor.CATRTHumanSkeleton.SetAllJointLEulerAngles(iEulerAngles);

            if (typeof iUpdateSkinning !== 'boolean' || iUpdateSkinning === true) {
                this._actor.CATRTHuman.UpdateSkinning();
            }

            return result;
        };

        /**
        * An enumeration for all IK members.
        *
        * @enum {number}
        * @public
        */
        HumanSkeleton.EIKMember = { eLeftArm: 0, eRightArm: 1, eLeftLeg: 2, eRightLeg: 3 };

        /**
        * Get a member IK transformation.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Transformation}
        */
        HumanSkeleton.prototype.getIKTransform = function (iMember, iRef) {
            var transform = new DSMath.Transformation();
            this._actor.CATRTHumanSkeleton.GetIKTransform(iMember, transform);

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
            /////////

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else { invRefTransform = iRef.getInverse(); }

                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }

            return transform;
        };

        /**
        * Set a member IK transformation.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {DSMath.Transformation} iTransform - IK transform
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @param {Boolean} [iUpdateSkinning=true] - to update the skinning
        * @return {STU.HumanSkeleton}
        */
        HumanSkeleton.prototype.setIKTransform = function (iMember, iTransform, iRef, iUpdateSkinning) {
            var transform = iTransform;

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform().getInverse();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
            /////////

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var refTransform;
                if (iRef instanceof STU.Actor3D) {
                    refTransform = iRef.getTransform();
                }
                else {
                    refTransform = iRef;
                }
                transform = DSMath.Transformation.multiply(refTransform, transform);
            }

            this._actor.CATRTHumanSkeleton.SetIKTransform(iMember, transform);

            if (typeof iUpdateSkinning !== 'boolean' || iUpdateSkinning === true) {
                this._actor.CATRTHuman.UpdateSkinning();
            }

            return this;
        };

        /**
        * Get a member IK position.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Vector3D}
        */
        HumanSkeleton.prototype.getIKPosition = function (iMember, iRef) {
            var transform = this.getIKTransform(iMember, iRef);

            return transform.vector.clone();
        };

        /**
        * Set a member IK position.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {DSMath.Vector3D} iPos - instance object corresponding to the new position in 3D
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @param {Boolean} [iUpdateSkinning=true] - to update the skinning
        * @return {STU.HumanSkeleton}
        */
        HumanSkeleton.prototype.setIKPosition = function (iMember, iPos, iRef, iUpdateSkinning) {
            //         var transform = this.getIKTransform(iMember, iRef);
            //
            //         transform.vector = iPos.clone();
            //         this.setIKTransform(iMember, transform, iRef, iUpdateSkinning);
            //
            //         return this;
            var transform = new DSMath.Transformation();
            transform.vector = iPos;

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform().getInverse();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
            /////////

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var refTransform;
                if (iRef instanceof STU.Actor3D) {
                    refTransform = iRef.getTransform();
                }
                else {
                    refTransform = iRef;
                }
                transform = DSMath.Transformation.multiply(refTransform, transform);
            }

            this._actor.CATRTHumanSkeleton.SetIKPosition(iMember, transform.vector);

            if (typeof iUpdateSkinning !== 'boolean' || iUpdateSkinning === true) {
                this._actor.CATRTHuman.UpdateSkinning();
            }

            return this;
        };

        /**
        * Get a member IK rotation euler.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {number[]} - ZXY euler angles
        */
        HumanSkeleton.prototype.getIKRotationEuler = function (iMember, iRef) {
            var transform = this.getIKTransform(iMember, iRef);
            // Begin Set Scale to 1.0
            var currentScale = this._actor.getScale();

            var coefScale = 1.0 / currentScale;

            var matrix3x3 = transform.matrix;
            var coefMatrix3x3 = matrix3x3.getArray();
            for (var i = 0; i < coefMatrix3x3.length; i++) {
                coefMatrix3x3[i] *= coefScale;
            }
            matrix3x3.setFromArray(coefMatrix3x3);
            transform.matrix = matrix3x3;
            // End Set Scale to 1.0

            var euler = transform.getEuler();

            return euler;
        };

        /**
        * Set a member IK rotation from euler.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {number[]} iEulerAngles – ZXY euler angles
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @param {Boolean} [iUpdateSkinning=true] - to update the skinning
        * @return {STU.HumanSkeleton}
        */
        HumanSkeleton.prototype.setIKRotationFromEuler = function (iMember, iEulerAngles, iRef, iUpdateSkinning) {
            var transform = this.getIKTransform(iMember, iRef);
            var currentScale = 1;

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                if (iRef instanceof STU.Actor3D) {
                    currentScale = iRef.getScale();
                }
                else if (iRef instanceof DSMath.Transformation) {
                    var scale3 = iRef.matrix.determinant();
                    currentScale = Math.pow(Math.abs(scale3), 1 / 3);
                    if (scale3 < 0) {
                        currentScale = -currentScale;
                    }
                }
            }

            transform.setRotationFromEuler(iEulerAngles);

            // Begin Set Scale
            var coefScale = currentScale / transform.getScaling().scale;
            var matrix3x3 = transform.matrix;
            var coefMatrix3x3 = matrix3x3.getArray();
            for (var i = 0; i < coefMatrix3x3.length; i++) {
                coefMatrix3x3[i] *= coefScale;
            }
            matrix3x3.setFromArray(coefMatrix3x3);
            transform.matrix = matrix3x3;
            // End Set Scale

            this.setIKTransform(iMember, transform, iRef, iUpdateSkinning);

            return this;
        };

        /**
        * Set a member IK rotation.
        *
        * @method
        * @public
        * @param {STU.HumanSkeleton.EIKMember} iMember - IK member
        * @param {DSMath.Vector3D} iAxis - the axis of the rotation.
        * @param {Number} iAngle - the angle of the rotation
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @param {Boolean} [iUpdateSkinning=true] - to update the skinning
        * @return {STU.HumanSkeleton}
        */
        HumanSkeleton.prototype.setIKRotation = function (iMember, iAxis, iAngle, iRef, iUpdateSkinning) {
            var transform = this.getIKTransform(iMember, iRef);
            var currentScale = 1;

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                if (iRef instanceof STU.Actor3D) {
                    currentScale = iRef.getScale();
                }
                else if (iRef instanceof DSMath.Transformation) {
                    var scale3 = iRef.matrix.determinant();
                    currentScale = Math.pow(Math.abs(scale3), 1 / 3);
                    if (scale3 < 0) {
                        currentScale = -currentScale;
                    }
                }
            }

            transform.matrix.makeRotation(iAxis, iAngle);

            // Begin Set Scale
            var coefScale = currentScale / transform.getScaling().scale;
            var matrix3x3 = transform.matrix;
            var coefMatrix3x3 = matrix3x3.getArray();
            for (var i = 0; i < coefMatrix3x3.length; i++) {
                coefMatrix3x3[i] *= coefScale;
            }
            matrix3x3.setFromArray(coefMatrix3x3);
            transform.matrix = matrix3x3;
            // End Set Scale

            this.setIKTransform(iMember, transform, iRef, iUpdateSkinning);

            return this;
        };

        /**
        * Get LookAt target position.
        *
        * @method
        * @public
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @return {DSMath.Vector3D}
        */
        HumanSkeleton.prototype.getLookAtPosition = function (iRef) {
            var vector = new DSMath.Vector3D();
            this._actor.CATRTHumanSkeleton.GetLookAtPosition(vector);

            var transform = new DSMath.Transformation();
            transform.vector = vector.clone();

            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
            /////////

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var invRefTransform;
                if (iRef instanceof STU.Actor3D) {
                    invRefTransform = iRef.getTransform().getInverse();
                }
                else {
                    invRefTransform = iRef.getInverse();
                }

                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }

            vector = transform.vector.clone();

            return vector;
        };

        /**
        * Set LookAt target position.
        *
        * @method
        * @public
        * @param {DSMath.Vector3D} iPos - instance object corresponding to the target position in 3D
        * @param {STU.Actor3D|DSMath.Transformation} [iRef] - referential
        * @param {Boolean} [iUpdateSkinning=true] - to update the skinning
        * @return {STU.HumanSkeleton}
        */
        HumanSkeleton.prototype.setLookAtPosition = function (iPos, iRef, iUpdateSkinning) {
            // hack! get actor transform as first ref
            var tmpTr = this._actor.getTransform().getInverse();
            var transform1 = new DSMath.Transformation();
            transform1.vector = iPos.clone();
            transform1 = DSMath.Transformation.multiply(tmpTr, transform1);
            var pos = transform1.vector.clone();
            /////////

            if (iRef !== undefined && iRef !== null && iRef !== this) {
                var transform = new DSMath.Transformation();
                transform.vector = pos.clone();

                var refTransform;
                if (iRef instanceof STU.Actor3D) {
                    refTransform = iRef.getTransform();
                }
                else {
                    refTransform = iRef;
                }

                transform = DSMath.Transformation.multiply(refTransform, transform);

                pos = transform.vector.clone();
            }

            this._actor.CATRTHumanSkeleton.SetLookAtPosition(pos);

            if (typeof iUpdateSkinning !== 'boolean' || iUpdateSkinning === true) {
                this._actor.CATRTHuman.UpdateSkinning();
            }

            return this;
        };

        // Expose only those entities in STU namespace.
        STU.HumanSkeleton = HumanSkeleton;

        return HumanSkeleton;
    });

define('StuHuman/StuHumanSkeleton', ['DS/StuHuman/StuHumanSkeleton'], function (HumanSkeleton) {
    'use strict';

    return HumanSkeleton;
});

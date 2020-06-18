
define('DS/StuHuman/StuHumanMotion',
    ['DS/StuCore/StuContext', 'DS/StuHuman/StuHumanNa', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer', 'MathematicsES/MathsDef',
    'DS/StuHuman/StuHumanManagerNa'],
    function (STU, Human, Behavior, Task, TaskPlayer, DSMath) {
    'use strict';


    /**
    * Describe a STU.Behavior which represents a set of behavior for Human actor created or imported in the experience.
    * This object is animate by default, but can also be inanimate in order to keep a posture set in authoring.
    *
    * To get notified from goTo and followPath processes, you need to add a listener as STU.HumanEvent type on the corresponding STU.Actor.
	* STU.HumanEvent is dispatched locally on their own parent STU.Actor.
	*
	* Events currently managed:
	* {@link STU.HumanGoToEvent}, {@link STU.HumanReachEvent}, {@link STU.HumanFollowPathEvent}, {@link STU.HumanPathCompletedEvent}.<br/>
    * 
    * To use it, you must have the following role: CHA - Marketing Content Animator
    *
    * @exports HumanMotion
    * @class 
    * @constructor
    * @noinstancector
    * @public
    * @extends {STU.Behavior}
    * @memberof STU
    * @alias STU.HumanMotion
    */
    var HumanMotion = function () {
        Behavior.call(this);
        this.name = 'HumanMotion';

        this.associatedTask;

        this.CATICXPHumanMotion;

        /**
         * True if HumanMotion is animate, false otherwise.
         *
         * @member
         * @instance
         * @name animate
         * @public
         * @type {boolean}
         * @memberOf STU.HumanMotion
         */
        this._animate;
        Object.defineProperty(this, 'animate', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._animate;
            },
            set: function (iAnimate) {
                if (typeof this._animate !== 'boolean') {
                    // first case: set _animate and let the manager perform the animation activation on register
                    this._animate = iAnimate;
                    return;
                }

                if (iAnimate === this._animate) {
                    return;
                }

                if (iAnimate === true) {
                    this._animate = true;
                    this.CATICXPHumanMotion.ActivateAnimation();
                } else {
                    this.CATICXPHumanMotion.DeactivateAnimation();
                    this._animate = false;
                }
            }
        });
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    HumanMotion.prototype = new Behavior();
    HumanMotion.prototype.constructor = HumanMotion;

    /**
    * For NL Scenario
    *
    * @method
    * @private
    */
    HumanMotion.prototype.animateNLDriver = function () {
        if (!this._animate) {
            this.animate = true;
        }
    };

    /**
    * For NL Scenario
    *
    * @method
    * @private
    */
    HumanMotion.prototype.unanimateNLDriver = function () {
        if (this._animate) {
            this.animate = false;
        }
    };

    /**
    * For NL Scenario
    *
    * @method
    * @private
    */
    HumanMotion.prototype.animateNLSensor = function () {
        return this._animate;
    };

    /**
    * For NL Scenario
    *
    * @method
    * @private
    */
    HumanMotion.prototype.unanimateNLSensor = function () {
        return !this._animate;
    };


    /**
    * Set Human location
    * By default, the function uses the World referential.
    *
    * @method
    * @public
    * @param {DSMath.Transformation} iTransform instance object corresponding to the matrix transformation
    * @param {STU.Actor3D|STU.HumanMotion} [iRef] instance object corresponding to the referential
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#getLocation
    */
    HumanMotion.prototype.setLocation = function (iTransform, iRef) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        if (!(iTransform instanceof DSMath.Transformation)) {
            throw new TypeError('iTransform argument is not a DSMath.Transformation');
        }

        var transform = iTransform;

        if (iRef !== undefined && iRef !== null) {
            var refTransform;
            if (iRef instanceof STU.HumanMotion) {
                refTransform = iRef.getLocation();
                transform = DSMath.Transformation.multiply(refTransform, transform);
            }
            else if (iRef instanceof STU.Actor3D) {
                refTransform = iRef.getTransform();
                transform = DSMath.Transformation.multiply(refTransform, transform);
            }
            else if (iRef instanceof DSMath.Transformation) {
                transform = DSMath.Transformation.multiply(iRef, transform);
            }
        }

        var tr_actorOnly = transform.clone();

        // hack! limited to local reference, check if no parent actor!
        var parentActor = this.getActor().getParent();
        if (parentActor instanceof STU.Actor3D === true) {
            var tmpTr = parentActor.getTransform().computeInverse();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
        }
        /////////

        this.CATICXPHumanMotion.SetLocation(transform);

        // update actor position from location
        var humanActor = this.getActor();
        humanActor.setTransform_ActorOnly(tr_actorOnly);
        humanActor.CATRTHuman.UpdateSkinning();

        return this;
    };

    /**
    * Get location
    * By default, the function uses the World referential.
    *
    * @method
    * @public
    * @param {STU.Actor3D|STU.HumanMotion} [iRef] instance object corresponding to the referential
    * @return {DSMath.Transformation} instance object corresponding to the matrix transformation
    * @see STU.HumanMotion#setLocation
    */
    HumanMotion.prototype.getLocation = function (iRef) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        var transform = new DSMath.Transformation();

        this.CATICXPHumanMotion.GetLocation(transform);

        if (iRef !== undefined && iRef !== null) {
            var invRefTransform;
            if (iRef instanceof STU.HumanMotion) {
                invRefTransform = iRef.getLocation().getInverse();
                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }
            else if (iRef instanceof STU.Actor3D) {
                invRefTransform = iRef.getTransform().getInverse();
                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }
            else if (iRef instanceof DSMath.Transformation) {
                invRefTransform = iRef.getInverse();
                transform = DSMath.Transformation.multiply(invRefTransform, transform);
            }
        }

        // hack! limited to local reference, check if no parent actor!
        var parentActor = this.getActor().getParent();
        if (parentActor instanceof STU.Actor3D === true) {
            var tmpTr = parentActor.getTransform();
            transform = DSMath.Transformation.multiply(tmpTr, transform);
        }
        /////////

        return transform;
    };

    /**
    * Idle
    * Can stop all human animations and behaviors such as followPath and goTo
    *
    * @method
    * @public
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#isIdle
    */
    HumanMotion.prototype.idle = function () {
        if (this.isGoingTo()) {
            this.stopGoTo();
        }
        else if (this.isFollowingPath()) {
            this.stopFollowPath();
        }
        else if (this.isMoving()) {
            var vecNull = new DSMath.Vector2D();
            this.move(vecNull, vecNull);
        }

        return this;
    };

    /**
    * Is idle
    *
    * @method
    * @public
    * @return {Boolean}
    * @see STU.HumanMotion#idle
    */
    HumanMotion.prototype.isIdle = function () {
        if (!this.isMoving()) {
            return true;
        }

        return false;
    };

    /**
    * Move human through 2D vectors (commonly used to control human through devices)
    * Used by HumanController behavior
    *
    * @method
    * @public
    * @param {DSMath.Vector2D} iDirection Human wished direction
    * @param {DSMath.Vector2D} iOrientation Human wished orientation
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#isMoving
    */
    HumanMotion.prototype.move = function (iDirection, iOrientation) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        var moveParams = { direction: iDirection, orientation: iOrientation };

        this.CATICXPHumanMotion.Move(moveParams);

        return this;
    };

    /**
    * Is moving
    *
    * @method
    * @public
    * @return {Boolean}
    * @see STU.HumanMotion#move
    */
    HumanMotion.prototype.isMoving = function () {
        var msgList = this.getCurrentMsgList();
        var i;
        for (i=0; i < msgList.length; i++) {
            var currentMsg = msgList[i];

            if (currentMsg.name === '__CharacterControl__') {
                if (undefined !== currentMsg.orientation && null !== currentMsg.orientation) {
                    if (currentMsg.orientation instanceof DSMath.Vector2D) {
                        if (currentMsg.orientation.x !== 0.0 || currentMsg.orientation.y !== 0.0) {
                            return true;
                        }
                    }
                }
            } else if (this.isFollowingPath() || this.isGoingTo()) {
                return true;
            }
        }

        return false;
    };

    /**
    * Follow a path
    *
    * @method
    * @public
    * @param {Array<DSMath.Point>|STU.PathActor} iPath Path to follow
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#isFollowingPath
    * @see STU.HumanMotion#stopFollowPath
    */
    HumanMotion.prototype.followPath = function (iPath) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        var obj = {};

        if (iPath instanceof Array) {
            obj.path = iPath;
        } else if (iPath instanceof STU.PathActor) {
            obj.path = iPath;
        }
        else {
            return this;
        }

        obj.startAnim = 'walk';
        obj.endAnim = 'idle';

        this.CATICXPHumanMotion.FollowPath(obj);

        return this;
    };

    /**
    * Stop to follow a path
    *
    * @method
    * @public
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#followPath
    * @see STU.HumanMotion#isFollowingPath
    */
    HumanMotion.prototype.stopFollowPath = function () {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        this.CATICXPHumanMotion.StopFollowPath();

        return this;
    };

    /**
    * Is following a path
    *
    * @method
    * @public
    * @param {?(Array<DSMath.Point>|STU.PathActor)} iPath Path followed. Can be undefined or null.
    * @return {Boolean}
    * @see STU.HumanMotion#followPath
    * @see STU.HumanMotion#stopFollowPath
    */
    HumanMotion.prototype.isFollowingPath = function (iPath) {
        var msgList = this.getCurrentMsgList();
        var i;
        for (i=0; i < msgList.length; i++) {
            var currentMsg = msgList[i];

            if (currentMsg.name === '__FollowPath__') {
                if (currentMsg.status === 'STARTED') {
                    if (undefined !== iPath && null !== iPath && undefined !== currentMsg.path && null !== currentMsg.path) {
                        if (iPath === currentMsg.path) {
                            return true;
                        }
                        if (iPath instanceof Array === true && currentMsg.path instanceof Array === true) {
                            var count = iPath.length;
                            if (count !== currentMsg.path.length) {
                                return false;
                            }

                            for (var j = 0; j < count; j++) {
                                if (iPath[j] instanceof DSMath.Point !== true || currentMsg.path[j] instanceof DSMath.Point !== true) {
                                    return false;
                                }

                                if (iPath[j].x !== currentMsg.path[j].x || iPath[j].y !== currentMsg.path[j].y || iPath[j].z !== currentMsg.path[j].z) {
                                    return false;
                                }
                            }

                            return true;
                        }
                    }
                    else {
                        return true;
                    }
                }
            }
        }

        return false;
    };

    /**
    * Go to location
    *
    * @method
    * @public
    * @param {DSMath.Point|STU.PointActor} iPoint Point to reach
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#isGoingTo
    * @see STU.HumanMotion#stopGoTo
    */
    HumanMotion.prototype.goTo = function (iPoint) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        var obj = {};

        if (iPoint instanceof DSMath.Point) {
            obj.point = iPoint;
        } else if (iPoint instanceof STU.PointActor) {
            obj.point = iPoint;
        }
        else {
            return this;
        }

        obj.startAnim = 'walk';
        obj.endAnim = 'idle';

        this.CATICXPHumanMotion.GoTo(obj);

        return this;
    };

    /**
    * Stop to go to location
    *
    * @method
    * @public
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#goTo
    * @see STU.HumanMotion#isGoingTo
    */
    HumanMotion.prototype.stopGoTo = function () {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        this.CATICXPHumanMotion.StopGoTo();

        return this;
    };

    /**
    * Is going to
    *
    * @method
    * @public
    * @param {?(DSMath.Point|STU.PointActor)} iPoint Point to be reached. Can be undefined or null.
    * @return {Boolean}
    * @see STU.HumanMotion#goTo
    * @see STU.HumanMotion#stopGoTo
    */
    HumanMotion.prototype.isGoingTo = function (iPoint) {
        var msgList = this.getCurrentMsgList();
        var i;
        for (i=0; i < msgList.length; i++) {
            var currentMsg = msgList[i];

            if (currentMsg.name === '__GoTo__') {
                if (currentMsg.status === 'STARTED') {
                    if (undefined !== iPoint && null !== iPoint && undefined !== currentMsg.point && null !== currentMsg.point) {
                        if (iPoint === currentMsg.point) {
                            return true;
                        }
                        if (iPoint instanceof DSMath.Point === true && currentMsg.point instanceof DSMath.Point === true) {
                            if (iPoint.x !== currentMsg.point.x || iPoint.y !== currentMsg.point.y || iPoint.z !== currentMsg.point.z) {
                                return false;
                            }
                            return true;
                        }
                    }
                    else {
                        return true;
                    }
                }
            }
        }

        return false;
    };

    /**
    * DEPRECATED
    * Execute an action message.
    * Used to send message allowing to animate the human.
    *
    *   Note: use methods such as idle, move, ... to animate the human instead.
    *
    * @method
    * @private
    * @param {String|STU.HumanMsg} [iHumanMsg] Message to execute
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#getCurrentMsgList
    */
    HumanMotion.prototype.executeActionMsg = function (iHumanMsg) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        if ((undefined === iHumanMsg) || (null === iHumanMsg)) {
            return this;
        }
        else if (typeof iHumanMsg === 'string') {
            this.CATICXPHumanMotion.ExecuteActionMsg(iHumanMsg);
            return this;
        }
        else if ((iHumanMsg instanceof STU.HumanMsg) === false) {
            //console.log('[STU.HumanMotion.executeActionMsg] Msg sent is not a string or STU.HumanMsg object');
            return this;
        }

        if (iHumanMsg.isEmptyParams()) {
            this.CATICXPHumanMotion.ExecuteActionMsg(iHumanMsg.getMsg());
        }
        else {
            this.CATICXPHumanMotion.ExecuteAdaptedActionMsg(iHumanMsg.getMsg(), iHumanMsg.getParams());
        }

        return this;
    };

    /**
    * Get Current Message List.
    * Provide a list of current executed messages.
    *
    *   Note: use existing methods/events to get a message status instead.
    *
    * @method
    * @private
    * @return {Array}
    * @see STU.HumanMotion#executeActionMsg
    */
    HumanMotion.prototype.getCurrentMsgList = function () {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        var result = [];

        this.CATICXPHumanMotion.GetCurrentMsgList(result);

        return result;
    };

    /**
    * Set Speed Factor.
    *
    * @method
    * @public
    * @param {number} iSpeedFactor Speed factor
    * @return {STU.HumanMotion}
    * @see STU.HumanMotion#getSpeedFactor
    */
    HumanMotion.prototype.setSpeedFactor = function (iSpeedFactor) {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        if (typeof iSpeedFactor !== 'number') {
            //console.log('[STU.HumanMotion.setSpeedFactor] Speed factor is not a number.');
            return this;
        }

        this.CATICXPHumanMotion.SetHumanSpeedFactor(iSpeedFactor);

        return this;
    };

    /**
    * Get Speed Factor.
    *
    * @method
    * @public
    * @return {number}
    * @see STU.HumanMotion#setSpeedFactor
    */
    HumanMotion.prototype.getSpeedFactor = function () {
        if (undefined === this.CATICXPHumanMotion || null === this.CATICXPHumanMotion) {
            throw new TypeError('HumanMotion undefined');
        }

        return this.CATICXPHumanMotion.GetHumanSpeedFactor();
    };

    /**
    * Process to execute after this STU.HumanMotion is activated.
    *
    * @method
    * @private
    * @see STU.HumanMotion#onDeactivate
    */
    HumanMotion.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);

        STU.HumanManager.getInstance().addHumanMotion(this);
    };

    /**
    * Process to execute after this STU.HumanMotion is deactivated.
    *
    * @method
    * @private
    * @see STU.HumanMotion#onActivate
    */
    HumanMotion.prototype.onDeactivate = function () {
        STU.HumanManager.getInstance().removeHumanMotion(this);

        this.CATICXPHumanMotion.DeactivateAnimation();

        Behavior.prototype.onDeactivate.call(this);
    };

    // Expose only those entities in STU namespace.
    STU.HumanMotion = HumanMotion;

    return HumanMotion;
});

define('StuHuman/StuHumanMotion', ['DS/StuHuman/StuHumanMotion'], function (HumanMotion) {
    'use strict';

    return HumanMotion;
});

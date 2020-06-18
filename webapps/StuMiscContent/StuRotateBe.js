
define('DS/StuMiscContent/StuRotateBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef'], function (STU, Behavior, Task, EP, DSMath) {
    'use strict';

    var RotateTask = function (iRotate) {
        Task.call(this);
        this.comp = iRotate;
    };


    RotateTask.prototype = new Task();
    RotateTask.prototype.constructor = RotateTask;

    RotateTask.prototype.onExecute = function (iExContext) {
        if ("doRotate" in this.comp) {
            this.comp.doRotate(iExContext);
        }
    };

    /**
     * Behavior that permit to make a rotation on an actor
     *
     * @exports Rotate
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.Behavior}
     * @memberOf STU
     * @alias STU.Rotate
     */
    var Rotate = function () {

        Behavior.call(this);

        this.componentInterface = this.protoId;

        this.name = "Rotate";

        /**
        * maximum speed in rad/s
        *
        * @member
        * @public
        * @type {Number}
        */
        this.maximumSpeed = 0.1;

        /**
        * acceleration in radian per square second
        *
        * @member
        * @public
        * @type {Number}
        */
        this.acceleration = 0;

        /**
        * The rotation Axis
        * {X:eXPositive, -X:eXNegative, Y:eYPositive, -Y:eYNegative, Z:eZPositive, -Z:eZNegative}
        * @member
        * @public
        * @type {STU.Rotate.eAxis}
        */
        this.rotationAxis = 0;

        /**
        * The rotation's reference 
        * {Local:eLocal, World:eWorld}
        * @member
        * @public
        * @type {STU.Rotate.eReference}
        */
        this.reference = 0;

        /**
        * The behavior's event of activation
        * {Mouse Click:eMouseClick, Mouse Over:eMouseOver, Key Pressed:eKeyPressed, Experience Start:eExperienceStart, No Activation:eNoActivation}
        * @member
        * @public
        * @type {STU.Rotate.eActivation}
        */
        this.activateOn = undefined;
        this._activateOn = undefined;
        Object.defineProperty(this, 'activateOn', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._activateOn;
            },
            set: function (value) {
                if (value !== undefined && value !== null) {
                    if (value >= 0) {
                        if (this.associatedTask !== null && this.associatedTask !== undefined) {
                            this.removeListeners();
                            this.addListeners(value);
                        }
                        this._activateOn = value;
                    }
                }
            }
        });

        /**
        * The mapped key used to activate the behavior
        * @member
        * @public
        * @type {EP.Keyboard.EKey}
        */
        this.activationKey = 0;

        this._actor;
        this._active = false;
        this._currentSpeed = 0;
        this._maximumSpeedInRadS = 0;

        this.associatedTask;
        this.clickablePressCb;
    };

    /**
	 * An enumeration of all the supported event of activation.<br/>
	 * It allows to refer in the code to a specific key.
	 *
	 * @enum {number}
	 * @public
	 */
    Rotate.eActivation = {
        eMouseClick: 0,
        eMouseOver: 1,
        eKeyPressed: 2,
        eExperienceStart: 3,
        eNoActivation: 4
    };

    /**
	 * An enumeration of all the supported reference of rotation (World Space/ Local Space).<br/>
	 * It allows to refer in the code to a specific key.
	 *
	 * @enum {number}
	 * @public
	 */
    Rotate.eReference = {
        eLocal: 0,
        eWorld: 1
    };

    /**
	 * An enumeration of all the supported axis of rotation.<br/>
	 * It allows to refer in the code to a specific key.
	 *
	 * @enum {number}
	 * @public
	 */
    Rotate.eAxis = {
        eXPositive: 0,
        eXNegative: 1,
        eYPositive: 2,
        eYNegative: 3,
        eZPositive: 4,
        eZNegative: 5,
    };

    Rotate.prototype = new Behavior();
    Rotate.prototype.constructor = Rotate;
    Rotate.prototype.protoId = "9627EEA6-C228-45B2-A216-C5350C1EB1F9";

    Rotate.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this._actor = this.getActor();

        //add listeners based on input method
        this.associatedTask = new RotateTask(this);
        EP.TaskPlayer.addTask(this.associatedTask);

        this.addListeners(this._activateOn);

        //storage unit = turn per min
        //this._maximumSpeedInRadS = (Math.abs(this.maximumSpeed) * 2 * Math.PI) / 60;
        //console.log("maximumSpeed: " + this.maximumSpeed + " tr/min");
        //console.log("maximumSpeed in radian: " + this._maximumSpeedInRadS + " rad/s");
        //console.log("Test:" + Rotate.eActivation.eMouseClick);
        //console.log(this.maximumSpeed);
    };

    Rotate.prototype.onDeactivate = function () {
        this.removeListeners();

        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;

        Behavior.prototype.onDeactivate.call(this);
    };

    Rotate.prototype.setSpeed = function (iSpeed) {
        if (iSpeed !== undefined && typeof iSpeed === 'number') {
            this.maximumSpeed = iSpeed;
        }
        return this;
    };

    Rotate.prototype.getSpeed = function () {
        return this.maximumSpeed;
    };

    Rotate.prototype.doRotate = function (iContext) {
        //storage unit = turn per min
        //this._maximumSpeedInRadS = (Math.abs(this.maximumSpeed) * 2 * Math.PI) / 60;
        //this._maximumSpeedInRadS = this.maximumSpeed;
        var actor = this._actor;
        // We might not be in a ring yet thus test !!
        if (actor === undefined || actor === null) {
            return this;
        }

        if (this._active || this._currentSpeed > 0) {
            if (this._active) {
                this._currentSpeed += Math.abs(this.acceleration) * iContext.deltaTime * 0.001;
            }
            else {
                //this._currentSpeed -= this.maximumSpeed * iContext.deltaTime * 0.001;
                //Behavioral Comitee: On tient compte de l’acceleration pour stopper la rotation
                this._currentSpeed -= Math.abs(this.acceleration) * iContext.deltaTime * 0.001;
            }
            if (this._currentSpeed > this.maximumSpeed) {
                this._currentSpeed = this.maximumSpeed;
            }
            else if (this._currentSpeed < 0) {
                this._currentSpeed = 0;
            }

            var rot = new DSMath.Vector3D();

            if (this.rotationAxis === Rotate.eAxis.eXPositive) {
                rot.x = this._currentSpeed * iContext.deltaTime * 0.001;//rot.x = this.maximumSpeed;
            }
            if (this.rotationAxis === Rotate.eAxis.eXNegative) {
                rot.x = this._currentSpeed * iContext.deltaTime * 0.001;//rot.x = this.maximumSpeed;
                rot.negate();
            }
            else if (this.rotationAxis === Rotate.eAxis.eYPositive) {
                rot.y = this._currentSpeed * iContext.deltaTime * 0.001;//rot.y = this.maximumSpeed;
            }
            else if (this.rotationAxis === Rotate.eAxis.eYNegative) {
                rot.y = this._currentSpeed * iContext.deltaTime * 0.001;//rot.y = this.maximumSpeed;
                rot.negate();
            }
            else if (this.rotationAxis === Rotate.eAxis.eZPositive) {
                rot.z = this._currentSpeed * iContext.deltaTime * 0.001;//rot.z = this.maximumSpeed;
            }
            else if (this.rotationAxis === Rotate.eAxis.eZNegative) {
                rot.z = this._currentSpeed * iContext.deltaTime * 0.001;//rot.z = this.maximumSpeed;
                rot.negate();
            }
            var ref = (this.reference === Rotate.eReference.eLocal) ? actor : null;
            actor.rotate(rot, ref);
        }
        return this;
    };

    /**
	 * Capacity function which permit to start the rotation 
	 * @method
	 * @public
	 */
    Rotate.prototype.startsRotation = function () {
        this._active = true;
    };

    /**
	 * Capacity function which permit to stop the rotation 
	 * @method
	 * @public
	 */
    Rotate.prototype.stopsRotation = function () {
        this._active = false;
        this.dispatchEvent(new STU.ServiceStoppedEvent("rotate", this));
    };

    /**
	 * Function that said if the actor is currently rotating
	 * @method
	 * @public
	 * @return {Boolean}
	 */
    Rotate.prototype.isRotating = function () {
        return this._currentSpeed > 0;
    };

    /**
	 * Callback called on a mouse click
	 * @method
	 * @private
	 */
    Rotate.prototype.onClickablePress = function () {
        if (this._active === false) {
            this.startsRotation();//this._active = true;
        }
        else {
            this.stopsRotation();//this._active = false;
        }
    };

    /**
	 * Callback called when a keyboard key is hit
	 * @method
	 * @private
	 */
    Rotate.prototype.onKeyboardPressEvent = function (iKeyboardPressEvent) {
        if (iKeyboardPressEvent.getKey() === this.activationKey) {
            if (this._active === false) {
                this.startsRotation();//this._active = true;
            }
            else {
                this.stopsRotation();//this._active = false;
            }
        }
    };

    /**
	 * Callback called on a mouse over event
	 * @method
	 * @private
	 */
    Rotate.prototype.onMouseOverEvent = function (iEvent) {
        if (this._active === false) {
            this._active = true;
        }
    };

    /**
	 * Callback called on a mouse exit event
	 * @method
	 * @private
	 */
    Rotate.prototype.onMouseExitEvent = function (iEvent) {
        if (this._active === true) {
            this._active = false;
        }
    };

    Rotate.prototype.addListeners = function (eType) {
        if (eType !== undefined && eType !== null) {
            switch (eType) {
                case Rotate.eActivation.eKeyPressed:
                    EP.EventServices.addObjectListener(EP.KeyboardPressEvent, this, 'onKeyboardPressEvent');
                    break;
                case Rotate.eActivation.eMouseClick:
                    this.actor.addObjectListener(STU.ClickablePressEvent, this, 'onClickablePress');
                    break;
                case Rotate.eActivation.eMouseOver:
                    this.actor.addObjectListener(STU.ClickableEnterEvent, this, 'onMouseOverEvent');
                    this.actor.addObjectListener(STU.ClickableExitEvent, this, 'onMouseExitEvent');
                    this._active = false;
                    break;
                case Rotate.eActivation.eExperienceStart:
                    this._active = true;
                    break;
                case Rotate.eActivation.eNoActivation:
                    break;
            }
        }
    };

    Rotate.prototype.removeListeners = function () {
        //remove all listeners
        if (this._activateOn === Rotate.eActivation.eMouseClick) {
            this.actor.removeObjectListener(STU.ClickablePressEvent, this, 'onClickablePress');
        }
        else if (this._activateOn === Rotate.eActivation.eMouseOver) {
            this.actor.removeObjectListener(STU.ClickableEnterEvent, this, 'onMouseOverEvent');
            this.actor.removeObjectListener(STU.ClickableExitEvent, this, 'onMouseExitEvent');
        }
        else if (this._activateOn === Rotate.eActivation.eKeyPressed) {
            EP.EventServices.removeObjectListener(EP.KeyboardPressEvent, this, 'onKeyboardPressEvent');
        }
    };

    // Expose in STU namespace.
    STU.Rotate = Rotate;

    return Rotate;
});

define('StuMiscContent/StuRotateBe', ['DS/StuMiscContent/StuRotateBe'], function (Rotate) {
    'use strict';

    return Rotate;
});

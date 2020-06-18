
define('DS/StuHuman/StuHumanController',
    ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer', 'DS/EPInputs/EPKeyboard', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent', 'MathematicsES/MathsDef'],
    function (STU, Behavior, Task, TaskPlayer, Keyboard, EPEventServices, Event, DSMath) {
    'use strict';

    /**
	* The task allow to control the human through keyboard input device.
	* It is activated
	*
	* @exports HumanCtrlTask
	* @class 
	* @constructor
	* @private
	* @extends EP.Task
	* @param {STU.HumanController} iHumanCtrlHdl, Human controller behavior
	* @memberof STU
	*/
    var HumanCtrlTask = function (iHumanCtrlHdl) {
        Task.call(this);

        /**
	    * Human controller handler.
	    *
	    * @member
	    * @private
	    * @type {STU.Human}
	    */
        this._humanCtrlHdl = iHumanCtrlHdl;

        /**
	    * Human current direction.
	    *
	    * @member
	    * @private
	    * @type {DSMath.Vector2D}
	    */
        //this._direction = new DSMath.Vector2D();

        /**
	    * Human current orientation.
	    *
	    * @member
	    * @private
	    * @type {DSMath.Vector2D}
	    */
        //this._orientation = new DSMath.Vector2D();

        /**
	    * Human first orientation.
	    *
	    * @member
	    * @private
	    * @type {DSMath.Vector2D}
	    */
        this._firstHeading = null;

        /**
	    * Controller is in use.
        * Allows to not deactivate GoTo or FollowPath if Human is not controlled.
	    *
	    * @member
	    * @private
	    * @type {boolean}
	    */
        this._inUse = false;
    };

    HumanCtrlTask.prototype = new Task();
    HumanCtrlTask.constructor = HumanCtrlTask;

    /**
	* Get Human heading vector.
	*
	* @method
	* @private
	* @return {DSMath.Vector2D} instance object corresponding to the heading vector
	*/
    HumanCtrlTask.prototype.getHeadingVector = function () {
        var resultVec = new DSMath.Vector2D();

        var human = this._humanCtrlHdl.getActor();
        if (undefined === human || null === human) { return resultVec; }

        var humanBe = human.getBehaviorByType(STU.HumanMotion);
        if (undefined === humanBe || null === humanBe) { return resultVec; }

        var transform = humanBe.getLocation();

        // Begin Set Scale to 1.0
        var matrix3x3 = transform.matrix;
        var coefMatrix3x3 = matrix3x3.getArray();

        var currentScale = Math.sqrt(coefMatrix3x3[0] * coefMatrix3x3[0] + coefMatrix3x3[3] * coefMatrix3x3[3] + coefMatrix3x3[6] * coefMatrix3x3[6]);

        var coefScale = 1.0 / currentScale;

        for (var i = 0; i < coefMatrix3x3.length; i++) {
            coefMatrix3x3[i] *= coefScale;
        }
        matrix3x3.setFromArray(coefMatrix3x3);
        transform.matrix = matrix3x3;
        // End Set Scale to 1.0

        var euler = transform.getEuler();
        var zRot = euler[0];

        resultVec.x = Math.cos(zRot);
        resultVec.y = Math.sin(zRot);

        return resultVec;
    };

    /**
	* This is the classic run method of any task.
	*
	* @method
	* @private
	* @param {Object} iExContext, the context of execution passed to any task on it's run.
	*/
    HumanCtrlTask.prototype.onExecute = function () {
        if (undefined === this._humanCtrlHdl || null === this._humanCtrlHdl) { return this; }

        var human = this._humanCtrlHdl.getActor();
        if (undefined === human || null === human) { return this; }

        var humanBe = human.getBehaviorByType(STU.HumanMotion);
        if (undefined === humanBe || null === humanBe) { return this; }

        var keyState = this._humanCtrlHdl.__internal__.keyState;
        //if (undefined === this._humanCtrlHdl.__internal__.keyState.constructor === Array) { return this; }

        var direction = new DSMath.Vector2D();
        var locomotion = new DSMath.Vector2D();

        var runFactor = 1.0;
        if (keyState.run !== 0) {
            runFactor = 3.0;
        }

        var vecNull;

        this._humanCtrlHdl.handleGamepadAxis();

        if (keyState.moveLeft === 0 && keyState.moveRight === 0) {
            if (keyState.moveForward !== 0) { locomotion.y = 1.0; }
            else if (keyState.moveBackward !== 0) { locomotion.y = -1.0; }
            else {
                if (!this._inUse) {
                    return this;
                }

                this._inUse = false;

                vecNull = new DSMath.Vector2D();
                humanBe.move(vecNull, vecNull);
                return this;
            }

            if (this._firstHeading === null) {
                var tmpDir = this.getHeadingVector();
                if (isNaN(tmpDir.x) || isNaN(tmpDir.y)) {
                    return this;
                }

                this._firstHeading = tmpDir;
            }

            this._inUse = true;

            direction.x = this._firstHeading.x;
            direction.y = this._firstHeading.y;
            locomotion.x = locomotion.y * this._firstHeading.x;
            locomotion.y = locomotion.y * this._firstHeading.y;
            locomotion.normalize();

            locomotion.x = locomotion.x * runFactor;
            locomotion.y = locomotion.y * runFactor;

            humanBe.move(direction, locomotion);
        }
        else {
            if (this._firstHeading !== null) {
                delete this._firstHeading;
                this._firstHeading = null;
            }

            this._inUse = true;

            var rightVect = new DSMath.Vector2D();
            var dirVect = new DSMath.Vector2D();

            dirVect = this.getHeadingVector();

            rightVect.x = dirVect.y;
            rightVect.y = -dirVect.x;

            if (keyState.moveRight !== 0) { locomotion.x = 1.0; }
            else { locomotion.x = -1.0; }

            var desiredLoco;

            if (keyState.moveForward !== 0) { locomotion.y = 1.0; }
            else if (keyState.moveBackward !== 0) { locomotion.y = -1.0; }
            else {
                vecNull = new DSMath.Vector2D();

                locomotion.y = 1.0;
                direction = dirVect;

                desiredLoco = new DSMath.Vector2D();
                desiredLoco.x = dirVect.x * locomotion.y + rightVect.x * locomotion.x;
                desiredLoco.y = dirVect.y * locomotion.y + rightVect.y * locomotion.x;
                desiredLoco.normalize();
                desiredLoco.x = desiredLoco.x * 0.45;
                desiredLoco.y = desiredLoco.y * 0.45;

                humanBe.move(vecNull, desiredLoco);

                return this;
            }

            direction = dirVect;

            desiredLoco = new DSMath.Vector2D();
            desiredLoco.x = dirVect.x * locomotion.y + rightVect.x * locomotion.x;
            desiredLoco.y = dirVect.y * locomotion.y + rightVect.y * locomotion.x;
            desiredLoco.normalize();

            desiredLoco.x = desiredLoco.x * runFactor;
            desiredLoco.y = desiredLoco.y * runFactor;

            humanBe.move(direction, desiredLoco);
        }

        return this;

        //GetCameraViewPlan();
        // 	       var direction = new DSMath.Vector2D();
        //         var orientation = new DSMath.Vector2D();
        //
        //         if (Math.abs(this._humanCtrlHdl._inputManager.axis1.y) < 1)
        //             direction.x = 0.0;
        //         else direction.x = this._humanCtrlHdl._inputManager.axis1.y;
        //         if (Math.abs(this._humanCtrlHdl._inputManager.axis1.x) < 1)
        //             orientation.y = 0.0;
        //         else orientation.y = this._humanCtrlHdl._inputManager.axis1.x;
        //
        //         if (orientation.y != 0) orientation.x = 1;
        //
        //         if (this._humanCtrlHdl._inputManager.buttonsState[STU.eInputTrigger.eTrigger1]) {
        //             if (direction.x == 1) direction.x = 2;
        //         }
        //
        //         if ((this._direction.x != direction.x) || (this._direction.y != direction.y)
        //             || (this._orientation.x != orientation.x) || (this._orientation.y != orientation.y)) {
        //             human.move(direction, orientation);
        //             this._direction = direction;
        //             this._orientation = orientation;
        //         }
    };


    /**
     * Describe a human controller.<br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
     *
     * @exports HumanController
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.Behavior}
     * @memberOf STU
     * @alias STU.HumanController
     */
    var HumanController = function () {

        Behavior.call(this);
        this.name = 'HumanController';

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
			 * Array containing the state of each keys
			 * @member
			 * @private
			 * @type {Object}
			 */
        this.__internal__.keyState = {
            moveForward: 0,
            moveBackward: 0,
            moveLeft: 0,
            moveRight: 0,
            run: 0,
        };

        this.__internal__.cleanGamePadAxis = false;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////

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
         * @default [EP.Keyboard.EKey.eLeft]
         * @memberOf STU.HumanController
         */
        this.moveLeft = Keyboard.EKey.eLeft;


        /**
         *  Mapped key for moving right
         *
         * @member
         * @instance
         * @name moveRight
         * @public
         * @type {EP.Keyboard.EKey}
         * @default [EP.Keyboard.EKey.eRight]
         * @memberOf STU.HumanController
         */
        this.moveRight = Keyboard.EKey.eRight;

        /**
         *  Mapped key for moving forward
         *
         * @member
         * @instance
         * @name moveForward
         * @public
         * @type {EP.Keyboard.EKey}
         * @default [EP.Keyboard.EKey.eUp]
         * @memberOf STU.HumanController
         */
        this.moveForward = Keyboard.EKey.eUp;

        /**
         * Mapped key for moving backward
         *
         * @member
         * @instance
         * @name moveBackward
         * @public
         * @type {EP.Keyboard.EKey}
         * @default [EP.Keyboard.EKey.eDown]
         * @memberOf STU.HumanController
         */
        this.moveBackward = Keyboard.EKey.eDown;

        /**
         * Mapped key to activate turbo
         *
         * @member
         * @instance
         * @name run
         * @public
         * @type {EP.Keyboard.EKey}
         * @default [EP.Keyboard.EKey.eShift]
         * @memberOf STU.HumanController
         */
        this.run = Keyboard.EKey.eShift;
    };

    HumanController.prototype.GetCameraViewPlan = function () {

        var objOut = { cameraUP: 0, cameraRight: 0 };

        var rm = STU.RenderManager.getInstance();
        if (typeof rm === 'undefined' || rm === null) {
            //console.log('Unable to retrieve Render Manager.');
            return objOut;
        }

        // Get the active Viewpoint (instead of the active camera to avoid probleme when this is no camera)
        var main3DViewpoint = rm.main3DViewpoint;

        if (typeof main3DViewpoint === 'undefined' || main3DViewpoint === null) {
            //console.log('main3DViewpoint is undefined or null');
            return objOut;
        }

        var cameraDir = new DSMath.Vector3D();
        main3DViewpoint.__stu__GetSightDirection(cameraDir);

        var cameraUP = new DSMath.Vector3D();
        main3DViewpoint.__stu__GetUpDirection(cameraUP);

        // compute the Right vector based on the CrossProduct of the Up and front vector
        var cameraRight = DSMath.cross(cameraDir, cameraUP);

        objOut.cameraUP = cameraUP;
        objOut.cameraRight = cameraRight;

        return objOut;
    };

    HumanController.prototype = new Behavior();
    HumanController.prototype.constructor = HumanController;

    /**
     * Process executed when STU.HumanController is activating
     *
     * @method
     * @private
     */
    HumanController.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);

        this.associatedTask = new HumanCtrlTask(this);
        TaskPlayer.addTask(this.associatedTask);

        this.keyboardCb = STU.makeListener(this, 'onKeyboardEvent');
        EP.EventServices.addListener(EP.KeyboardEvent, this.keyboardCb);

        this.gamepadCB = STU.makeListener(this, 'onGamepadEvent');
        EP.EventServices.addListener(EP.GamepadEvent, this.gamepadCB);

        return this;
    };

    /**
     * Process executed when STU.HumanController is deactivating
     *
     * @method
     * @private
     */
    HumanController.prototype.onDeactivate = function () {
        EP.EventServices.removeListener(EP.KeyboardEvent, this.keyboardCb);
        delete this.keyboardCb;

        EP.EventServices.removeListener(EP.GamepadEvent, this.gamepadCB);
        delete this.gamepadCB;

        TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;

        Behavior.prototype.onDeactivate.call(this);
    };

    /**
     * Callback called when a keyboard key is hit
	 * @method
	 * @private
	 */
    HumanController.prototype.onKeyboardEvent = function (iKeyboardEvent) {
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

            case this.moveRight:
                this.__internal__.keyState.moveRight = isPressed;
                break;

            case this.moveLeft:
                this.__internal__.keyState.moveLeft = isPressed;
                break;

            case this.run:
                this.__internal__.keyState.run = isPressed;
                break;
        }
    };

    /**
     * Callback called when a gamepad is hit
     * @method
     * @private
     */
    HumanController.prototype.onGamepadEvent = function (iGamepadEvent) {
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
                this.__internal__.keyState.moveForward = isPressed;
                break;

            case EP.Gamepad.EButton.eDPadDown:
                this.__internal__.keyState.moveBackward = isPressed;
                break;

            case EP.Gamepad.EButton.eDPadRight:
                this.__internal__.keyState.moveRight = isPressed;
                break;

            case EP.Gamepad.EButton.eDPadLeft:
                this.__internal__.keyState.moveLeft = isPressed;
                break;

            case EP.Gamepad.EButton.eX:
                this.__internal__.keyState.run = isPressed;
                break;
        }
    };

    /**
     * allows to handle gamepad axis (called by the task)
     * @method
     * @private
     */
    HumanController.prototype.handleGamepadAxis = function () {
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
                this.__internal__.keyState.moveRight = 0;
                this.__internal__.keyState.moveLeft = 0;
                this.__internal__.cleanGamePadAxis = true;
            }
            return;
        }

        /*		var strenghtAmount = Math.sqrt(gpAxisValueX*gpAxisValueX + gpAxisValueY*gpAxisValueY);
         */
        this.__internal__.cleanGamePadAxis = false;
        if (gpAxisValueX > 0) {
            this.__internal__.keyState.moveRight = gpAbsAxisValueX;
            this.__internal__.keyState.moveLeft = 0;
        } else {
            this.__internal__.keyState.moveLeft = gpAbsAxisValueX;
            this.__internal__.keyState.moveRight = 0;
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

    // Expose in STU namespace.
    STU.HumanController = HumanController;

    return HumanController;
});

define('StuHuman/StuHumanController', ['DS/StuHuman/StuHumanController'], function (HumanController) {
    'use strict';

    return HumanController;
});

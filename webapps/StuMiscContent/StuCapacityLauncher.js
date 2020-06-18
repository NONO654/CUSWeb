define('DS/StuMiscContent/StuCapacityLauncher', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef',
    'DS/StuMiscContent/StuVisuServices', 'DS/EPInputs/EPMouse', 'DS/EPInputs/EPMouseClickEvent', 'DS/StuCameras/StuInputManager'
], function (STU, Behavior, Task, EP, DSMath, StuVisuServices) {
    'use strict';

    var CapacityLauncherTask = function (iCapacityLauncher) { 
        Task.call(this);
        this.comp = iCapacityLauncher;
        this.mousePos;
        this.panel;
    };

    CapacityLauncherTask.prototype = new Task();
    CapacityLauncherTask.prototype.constructor = CapacityLauncherTask;

    /**
     * Process executed when CapacityLauncherTask is started
     * @private
     */
    CapacityLauncherTask.prototype.onStart = function () {
        var stuVisuServices = new StuVisuServices().build();
        // mouse pos in 3D world
        var viewerSize = this.comp._renderManager.getViewerSize();
        var axis = this.comp._inputManager.axis1;
        var x = (-axis.x + 1) / 2 * viewerSize.x;
        var y = (-axis.y - 1) / -2 * viewerSize.y;
        this.mousePos = new DSMath.Vector2D();
        this.mousePos.set(x, y);
        var mouseWorld = this.comp.getMouseInWorld(this.mousePos);
        this.offset = new DSMath.Point();
        this.offset.set(1, 1, 0);
        var actor = this.comp.getActor();
        var excludedCapacities = this.comp.Capacity;
        var blocks = this.comp.blocksBuild;
        var buttons = [];
        var thatTask = this;
        var caps = this.comp.getCapacities();
        
        for (var i = 0; i < caps.length; i++) {
            var excluded = false;
            if (excludedCapacities !== undefined && excludedCapacities !== null) {
                for (var y = 0; y < excludedCapacities.length; y++) {
                    if (excludedCapacities[y] === caps[i]) {
                        excluded = true;
                    }
                }
            }

            if (!excluded) {
                // get capacity
                var capacity = actor.getCapacityByID(caps[i]);

                // get common value of capacities (icon)
                var icon = "";
                var iconPI;
                var capAlias = "";
                // console.log(capacity._naturalLanguageInfo);
                if (capacity._naturalLanguageInfo !== undefined && capacity._naturalLanguageInfo !== null ) {
                    if (capacity._naturalLanguageInfo._icon !== undefined && capacity._naturalLanguageInfo._icon !== null)
                        icon = capacity._naturalLanguageInfo._icon;
                    if (capacity._naturalLanguageInfo._iconPI !== undefined && capacity._naturalLanguageInfo._iconPI !== null)
                        iconPI = capacity._naturalLanguageInfo._iconPI !== undefined ? capacity._naturalLanguageInfo._iconPI.getPixelImage() : "";
                    if (capacity._naturalLanguageInfo._alias !== undefined && capacity._naturalLanguageInfo._alias !== null)
                        capAlias = capacity._naturalLanguageInfo._alias
                }

                if (capacity !== undefined && capacity !== null) {
                    var button = this.comp.createElement("CATVidCtlButton", {
                        Dimension: "150 50",
                        VisibleFlag: 1,
                        FocusableFlag: 0,
                        Icon: icon,
 						IconPixelImage: iconPI,
                        IconDimension: "20 20",
                        Label: capacity.name,
                        Name: capacity.name
                    });
                    console.log(button);
                    var capacityButtonCallback = this.comp.setButtonCallback(button, capacity, thatTask, actor);            
                    var eventName = this.comp.setClickEventName();
                    button.addEventListener(eventName, capacityButtonCallback);
                    buttons.push(button);
                }
            }
        }
            
        if (!this.panel) {
            this.panel = this.comp.createCapacityPanel(buttons,this.offset);
             this.panel.Name = "Capacity Launcher";
             stuVisuServices.AnnotationDisplay(mouseWorld, this.panel, this.offset);
             this.comp.setVisibility(this.panel, true);
        } else {
            this.comp.toggleVisibility(this.panel);
        }
    };


    /**
     * Method called each frame by the task manager
     *
     * @method
     * @private
     * @param  iExContext Execution context
     */
    CapacityLauncherTask.prototype.onExecute = function (iExContext) {
    };
    
    /**
     * Process executed when CapacityLauncherTask is stoped
     * @private
     */
    CapacityLauncherTask.prototype.onStop = function () {
        console.log("clickout");
        this.comp.toggleVisibility(this.panel);

    };

   
    //// task2: text annotation

    
    /**
     * Describe a Capacity Launcher behavior
     *
     * @exports CapacityLauncher
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.Behavior}
     * @memberOf STU
	 * @alias STU.CapacityLauncher
     */
    var CapacityLauncher = function () {
        Behavior.call(this);
        this.componentInterface = this.protoId;
        this.name = "CapacityLauncher";
        /**
         * Highlight mode on mouse over
         *
         * @member
         * @public
         * @type number
         */
        this.HighlightOnMouseover = 0;
        this.associatedTask;
        this.blocksBuild = [];
        this._renderManager;
        this._inputManager = null;
        // /*UNUSED*/ this.mouseOverTask;
        this.capacities;
    };

    CapacityLauncher.prototype = new Behavior(this);
    CapacityLauncher.prototype.constructor = CapacityLauncher;

    /**
     * Process executed when STU.CapacityLauncher is activating
     *
     * @method
     * @private
     */
    CapacityLauncher.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this._renderManager = STU.RenderManager.getInstance();

        this.associatedTask = new CapacityLauncherTask(this);
        EP.EventServices.addObjectListener(EP.MouseClickEvent, this, 'onClickableGlobal');
        // /*UNUSED*/ this.mouseOverTask = new IconDisplayTask(this);
        this.getActor().addObjectListener(STU.ClickableMoveEvent, this, 'onMouseMoveOverSomeActor');
        this.getActor().addObjectListener(STU.ClickableExitEvent, this, 'onExitSomeActor');
        this.viewer = new StuVisuServices().build();
        this._inputManager = new STU.InputManager();
        if (this._inputManager === undefined || this._inputManager === null) {
            return this;
        }
        this._inputManager.initialize();
        this._inputManager.activate();
        this._inputManager.useMouse = true;
        this._inputManager.mouseAxis = 1;
        this._inputManager.mouseInvertY = false;
    };

    /**
     * Process executed when STU.CapacityLauncher is deactivating
     *
     * @method
     * @private
     */
    CapacityLauncher.prototype.onDeactivate = function () {
        if (this._inputManager !== undefined && this._inputManager !== null) {

            this._inputManager.deactivate();
            this._inputManager.dispose();
            this._inputManager = null;
        }
        EP.EventServices.removeObjectListener(EP.MouseClickEvent, this, 'onClickableGlobal');
        this.getActor().removeObjectListener(STU.ClickableMoveEvent, this, 'onMouseMoveOverSomeActor');
        this.getActor().removeObjectListener(STU.ClickableExitEvent, this, 'onExitSomeActor');
        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;
        // /*UNUSED*/ EP.TaskPlayer.removeTask(this.mouseOverTask);
        // /*UNUSED*/ delete this.mouseOverTask;
        delete this.viewer;
        Behavior.prototype.onDeactivate.call(this);

    };

    /**
 * Callback called when a left mouse button is hit
 * @method
 * @private
 */
    CapacityLauncher.prototype.onClickableGlobal = function (iEvent) {
        if (iEvent.getButton() === EP.Mouse.EButton.eLeft) {
            var actor;
            //var isVid = new Boolean(false);
            var intersectArray = this._renderManager._pickFromPosition(iEvent.position);
            if (intersectArray.length > 0) {
                actor = intersectArray[0].getActor();
                if (actor === this.getActor()) {
                    if (this.associatedTask.isPlaying()) {
                        this.associatedTask.stop();
                        EP.TaskPlayer.removeTask(this.associatedTask);
                    } else {
                        EP.TaskPlayer.addTask(this.associatedTask);
                        this.associatedTask.start();
                        // /*UNUSED*/ this.mouseOverTask.stop();
                        // /*UNUSED*/ EP.TaskPlayer.removeTask(this.mouseOverTask);
                    }
                    
                }
                else {
                    if (this.associatedTask.isPlaying()) {
                        this.associatedTask.stop();
                        EP.TaskPlayer.removeTask(this.associatedTask);
                    }
                }
            }
            else {
                if (this.associatedTask.isPlaying() ) {
                    this.associatedTask.stop();
                    EP.TaskPlayer.removeTask(this.associatedTask);
                }
            }
        }
    };

    /**
     * Callback called when a mouse enters on actor
     * @method
     * @private
     */
    CapacityLauncher.prototype.onMouseMoveOverSomeActor = function () {

        if (!this.associatedTask.isPlaying()) {
            // /*UNUSED*/ EP.TaskPlayer.addTask(this.mouseOverTask);
            // /*UNUSED*/ this.mouseOverTask.start();
            var currentActor = this.getActor();
            if (this.HighlightOnMouseover === 1) {
                this._renderManager.preHighlight(currentActor, 1);
            }
            if (this.HighlightOnMouseover === 2) {
                this._renderManager.highlight(currentActor, 1);
            }
        }

    };

    /**
    * Callback called when a mouse exits an actor
    * @method
    * @private
    */
    CapacityLauncher.prototype.onExitSomeActor = function () {
        // /*UNUSED*/ this.mouseOverTask.stop();
        // /*UNUSED*/ EP.TaskPlayer.removeTask(this.mouseOverTask);

        var currentActor = this.getActor();
        if (this.HighlightOnMouseover === 1) {
            this._renderManager.preHighlight(currentActor, 0);
        }
        if (this.HighlightOnMouseover === 2) {
            this._renderManager.highlight(currentActor, 0);
        }
    };
   
    CapacityLauncher.prototype.projectPoint = function (iLine, iVectOrigin, iMyActor) {
        var origin = iLine.origin;
        var direction = iLine.direction;
        direction.normalize();
        var xMouse = direction.clone();
        xMouse.z = 0;
        xMouse.normalize();
        var cosAlpha = xMouse.dot(direction);
        var alpha = Math.acos(cosAlpha);
        var d = origin.z;
        var mouseDistance = (d / Math.sin(alpha));
        direction.multiplyScalar(mouseDistance);
        iVectOrigin.set(origin.x, origin.y, origin.z);
        iVectOrigin.add(direction);
    };

    /**
    * Get the mouse position in world co-ordinate
    *
    * @method
    * @private
    * @param  {mousePoint} mouse point in x, y
    */
    CapacityLauncher.prototype.getMouseInWorld = function (mousePoint) {

        var point = new DSMath.Vector2D();
        point.set(mousePoint.x, mousePoint.y);

        var vectOrigin = new DSMath.Vector3D();

        var line = this._renderManager.getLineFromPosition(point);

        var myActor = this.getActor();
        if (!(myActor instanceof STU.Actor3D)) {
            return;
        }

        var intersectArray = this._renderManager._pickFromLine(line);
        if (intersectArray.length > 0) {
            if (intersectArray[0].getActor() === myActor) {
                if (intersectArray.length > 1) {
                    vectOrigin.set(intersectArray[1].point.x, intersectArray[1].point.y, intersectArray[1].point.z);
                    return vectOrigin;
                }
                else {
                    this.projectPoint(line, vectOrigin, myActor);
                    return vectOrigin;
                }
            }
            else {
                vectOrigin.set(intersectArray[0].point.x, intersectArray[0].point.y, intersectArray[0].point.z);
                return vectOrigin;
            }
        }
        else {
            this.projectPoint(line, vectOrigin, myActor);
            return vectOrigin;
        }
    };

    CapacityLauncher.prototype.setButtonCallback = function (myButton, myCapacity, myTask) {
        var callback;
        if (myCapacity instanceof STU.Service) {
            callback = function (e) {
                var service = myTask.comp.actor.getCapacityByID(myButton.Name);
                service.onInitialize();
                service.setContext(myTask.comp.getActor());
                service.start();
            }
        }
        else if (myCapacity instanceof STU.Function) {
            callback = function (e) {
                myCapacity.execute();
            }
        }
        return callback;
    };

    // Expose in STU namespace
    STU.CapacityLauncher = CapacityLauncher;
    return CapacityLauncher;
});

define('StuMiscContent/StuCapacityLauncher', ['DS/StuMiscContent/StuCapacityLauncher'], function (CapacityLauncher) {
    'use strict';

    return CapacityLauncher;
});


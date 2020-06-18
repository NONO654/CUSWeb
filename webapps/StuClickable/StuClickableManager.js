define('DS/StuClickable/StuClickableManager', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer',
	'DS/StuClickable/StuClickableEvent',
	'DS/StuClickable/StuClickableEnterEvent',
	'DS/StuClickable/StuClickableExitEvent',
	'DS/StuClickable/StuClickableMoveEvent',
	'DS/StuClickable/StuClickablePressEvent',
	'DS/StuClickable/StuClickableReleaseEvent',
	'DS/StuClickable/StuClickableDoubleClickEvent',
	'DS/EPInputs/EPMousePressEvent',
	'DS/EPInputs/EPMouseReleaseEvent',
	'DS/EPInputs/EPMouseDoubleClickEvent',
	'DS/EPInputs/EPMouseMoveEvent',
], function (STU, Manager, Task, TaskPlayer) {
    'use strict';

    /**
    * Describe a task which manages the STU.RenderManager execution.
    *
    * @exports ClickableManagerPostProcessTask
    * @class
    * @constructor
    * @private
    * @extends EP.Task
    */
    var ClickableManagerPostProcessTask = function (iClickableManager) {
        Task.call(this);
        this.name = 'ClickableManagerPostProcessTask';
        this.clickableManager = iClickableManager;
    };

    ClickableManagerPostProcessTask.prototype = new Task();
    ClickableManagerPostProcessTask.prototype.constructor = ClickableManagerPostProcessTask;

    /**
	 * Process to execute when this STU.ClickableManagerPostProcessTask is executing.
	 *
	 * @method
	 * @private
	 */
    ClickableManagerPostProcessTask.prototype.onExecute = function () {
        this.clickableManager.lastPickingResult = null;
        this.clickableManager.isPickingCacheActive = false;
    };

    /**
	 * Describe a STU.Manager which provides the possibility to interact with a STU.Node3D through a mouse device.
	 * It is mostly managing a list of STU.Clickable.
	 * It registers listeners on the EP.EventServices to get notified from user action on the mouse device.
	 * It will mainly perform a ray casting when the mouse is moving in order to check if the mouse cursor is in the clickable zone.
	 * The clickable zone is corresponding to the projection of a STU.Actor3D on the screen in 2D.
	 * This area defines the necessary position to click on a STU.Actor3D.
	 * To correctly work, a STU.Clickable needs to be added on a STU.Actor3D.
	 * In order to get notified, you need to add a listener as STU.ClickableEvent type on the corresponding STU.Actor or on the EP.EventServices.
	 * STU.ClickableEvent is dispatched globally on the EP.EventServices and locally on their own parent STU.Actor.
	 *
	 * Events currently managed :
	 * ClickableMoveEvent, ClickablePressEvent, ClickableReleaseEvent, ClickableDoubleClickEvent, ClickableEnterEvent, ClickableExitEvent.
	 *
	 * @exports ClickableManager
	 * @class
	 * @constructor
	 * @private
	 * @extends Manager
	 * @memberof STU
	 */
    var ClickableManager = function () {

        Manager.call(this);

        this.name = 'ClickableManager';

        /**
		 * The array listing the clickable of this STU.ClickableManager.
		 *
		 * @member
		 * @private
		 * @type {Array.<STU.Actor3D>}
		 */
        this.clickablesActors = [];

        /**
		 * The STU.Clickable which the mouse cursor in its zone.
		 *
		 * @member
		 * @private
		 * @type {STU.Actor3D}
		 */
        this.clickableActor = null;

        /**
		 * Save an actor on press event.
		 * @private
		 * @type {STU.Actor3D}
		 */
        this.lastActorPressed = null;

        /**
		 * Object holding the picking cache within a frame
		 * @private
		 * @type {STU.Clickable}
		 */
        this.lastPickingResult = null;

        /**
		 * True if a picking has already be done within a frame
		 * @private 
		 * @type {boolean}
		 */
        this.isPickingCacheActive = false;
    };

    ClickableManager.prototype = new Manager();
    ClickableManager.prototype.constructor = ClickableManager;

    /**
	 * Process to execute when this STU.ClickableManager is initializing.
	 *
	 * @method
	 * @private
	 */
    ClickableManager.prototype.onInitialize = function () {

        this.clickablesActors = [];

        this.mousePressCb = STU.makeListener(this, 'onMousePress');
        this.mouseReleaseCb = STU.makeListener(this, 'onMouseRelease');
        this.mouseDoubleClickCb = STU.makeListener(this, 'onMouseDoubleClick');
        this.mouseMoveCb = STU.makeListener(this, 'onMouseMove');

        var eventServices = EP.EventServices;
        eventServices.addListener(EP.MousePressEvent, this.mousePressCb);
        eventServices.addListener(EP.MouseReleaseEvent, this.mouseReleaseCb);
        eventServices.addListener(EP.MouseDoubleClickEvent, this.mouseDoubleClickCb);
        eventServices.addListener(EP.MouseMoveEvent, this.mouseMoveCb);

        this.associatedTask = new ClickableManagerPostProcessTask(this);
        TaskPlayer.addTask(this.associatedTask, STU.getTaskGroup(STU.ETaskGroups.ePostProcess));
    };

    /**
	 * Process to execute when this STU.ClickableManager is disposing.
	 *
	 * @method
	 * @private
	 */
    ClickableManager.prototype.onDispose = function () {

        var eventServices = EP.EventServices;
        eventServices.removeListener(EP.MousePressEvent, this.mousePressCb);
        eventServices.removeListener(EP.MouseReleaseEvent, this.mouseReleaseCb);
        eventServices.removeListener(EP.MouseDoubleClickEvent, this.mouseDoubleClickCb);
        eventServices.removeListener(EP.MouseMoveEvent, this.mouseMoveCb);

        delete this.mousePressCb;
        delete this.mouseReleaseCb;
        delete this.mouseDoubleClickCb;
        delete this.mouseMoveCb;

        STU.clear(this.clickablesActors);
        delete this.clickablesActors;
        delete this.clickableActor;

        TaskPlayer.removeTask(this.associatedTask);
    };

    /**
	 * Add a STU.Clickable on this STU.ClickableManager.
	 *
	 * @method
	 * @private
	 * @param {STU.Clickable} iClickable instance object corresponding to the clickable to add
	 */
    ClickableManager.prototype.addClickable = function (iClickable) {
        STU.pushUnique(this.clickablesActors, iClickable);
    };

    /**
	 * Remove a STU.Clickable from this STU.ClickableManager.
	 *
	 * @method
	 * @private
	 * @param {STU.Clickable} iClickable instance object corresponding to the clickable to remove
	 */
    ClickableManager.prototype.removeClickable = function (iClickable) {
        STU.remove(this.clickablesActors, iClickable);
    };

    /**
	 * Find a STU.Clickable from a viewer position in 2D.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Vector2D} iPosition
	 * @return {STU.Clickable} instance object
	 */
    ClickableManager.prototype.getClickableFromPosition = function (iPosition) {
        if (this.isPickingCacheActive) {
            return this.lastPickingResult;
        }
        else {
            this.isPickingCacheActive = true;
        }

        var clickable;

        if (this.clickablesActors.length === 0) {
            this.lastPickingResult = clickable;
            return clickable;
        }

        var intersections = STU.RenderManager.getInstance()._pickFromPosition(iPosition);
        var firstIntersection = intersections[0];
        if (firstIntersection === undefined || firstIntersection === null) {
            this.lastPickingResult = clickable;
            return clickable;
        }

        var actor = firstIntersection.getActor();


        while (actor !== undefined && actor !== null) {
            if (this.clickablesActors.indexOf(actor) >= 0) {
                clickable = actor;
                break;
            }
            actor = actor.findParent(STU.Actor);
        }
        this.lastPickingResult = clickable;
        return clickable;
    };

    /**
	 * Handler for mouse press event.
	 *
	 * @method
	 * @private
	 * @param {EP.MousePressEvent} iMouseEvent instance object
	 */
    ClickableManager.prototype.onMousePress = function (iMouseEvent) {
        var clickable = this.getClickableFromPosition(iMouseEvent.getPosition());

        if (clickable !== undefined && clickable !== null) {
            this._sendClickableEvent(new STU.ClickablePressEvent(), iMouseEvent, clickable);
            this.lastActorPressed = clickable;
        }
    };

    /**
	 * Handler for mouse release event.
	 *
	 * @method
	 * @private
	 * @param {EP.MouseReleaseEvent} iMouseEvent instance object
	 */
    ClickableManager.prototype.onMouseRelease = function (iMouseEvent) {
        var clickable = this.getClickableFromPosition(iMouseEvent.getPosition());
        if (this.clickableActor !== undefined && this.clickableActor !== null && clickable === this.lastActorPressed) {
            this._sendClickableEvent(new STU.ClickableReleaseEvent(), iMouseEvent, clickable);
        }
        this.lastActorPressed = null;
    };

    /**
	 * Handler for mouse double click event.
	 *
	 * @method
	 * @private
	 * @param {EP.MouseDoubleClickEvent} iMouseEvent instance object
	 */
    ClickableManager.prototype.onMouseDoubleClick = function (iMouseEvent) {
        var clickable = this.getClickableFromPosition(iMouseEvent.getPosition());
        if (clickable !== undefined && clickable !== null) {
            this._sendClickableEvent(new STU.ClickableDoubleClickEvent(), iMouseEvent, clickable);
        }
    };

    /**
	 * Handler for mouse move event.
	 *
	 * @method
	 * @private
	 * @param {EP.MouseMoveEvent} iMouseEvent instance object
	 */
    ClickableManager.prototype.onMouseMove = function (iMouseEvent) {
        var newClickable = this.getClickableFromPosition(iMouseEvent.getPosition());

        if (newClickable !== this.clickableActor) {
            if (newClickable !== undefined && newClickable !== null) {
                this._sendClickableEvent(new STU.ClickableEnterEvent(), iMouseEvent, newClickable);
            }
            if (this.clickableActor !== undefined && this.clickableActor !== null) {
                this._sendClickableEvent(new STU.ClickableExitEvent(), iMouseEvent, this.clickableActor);
            }
        } else if (newClickable !== undefined && newClickable !== null) {
            this._sendClickableEvent(new STU.ClickableMoveEvent(), iMouseEvent, newClickable);
        }

        this.clickableActor = newClickable;
    };

    ClickableManager.prototype._sendClickableEvent = function (iClickableEvent, iMouseEvent, iActor) {
        if (iActor !== undefined && iActor !== null && iClickableEvent !== undefined && iClickableEvent !== null) {
            iClickableEvent.setActor(iActor);

            if (typeof iMouseEvent.getButton === 'function') {
                iClickableEvent.setButton(iMouseEvent.getButton());
            }

            iActor.dispatchEvent(iClickableEvent);
        }
    };

    STU.registerManager(ClickableManager);

    // Expose in STU namespace.
    STU.ClickableManager = ClickableManager;

    return ClickableManager;
});

define('StuClickable/StuClickableManager', ['DS/StuClickable/StuClickableManager'], function (ClickableManager) {
    'use strict';

    return ClickableManager;
});

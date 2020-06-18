
define('DS/StuClickable/StuClickablePressEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent', 'DS/EPInputs/EPMouse'], function (STU, ClickableEvent) {
	'use strict';

	/**
	 * Describe a STU.ClickableEvent triggered by a {@link STU.Actor3D}.
	 * Require a {@link STU.Actor3D} containing a STU.Clickable.<br/>
	 * 
	 * The clickable zone is corresponding to the projection of a STU.Actor3D on the screen.
	 * This area defines the necessary position to click on a {@link STU.Actor3D}.<br/>
	 * 
	 * This event is dispatched globally on the EP.EventServices and locally on their own parent STU.Actor.
	 * In order to get notified, you need to add a listener as {@link STU.ClickablePressEvent} type on the corresponding {@link STU.Actor} or on the {@link EP.EventServices}.<br/>
	 *
	 * @example
     * beScript.onStart = function () {
     *      //Call 'onMousePressOverSomeActor' method of beScript on each {@link STU.ClickablePressEvent}
     *      EP.EventServices.addObjectListener(STU.ClickablePressEvent, beScript, 'onMousePressOverSomeActor');
     *      //Call 'onMousePressOverParentActor' method of beScript each time a {@link STU.ClickablePressEvent} is triggered by {@link STU.Actor3D}
     *      var actor = this.getActor();
     *      actor.addObjectListener(STU.ClickablePressEvent, beScript, 'onMousePressOverParentActor');
     * };
     * 
     * beScript.onStop = function () {
     *      // unregister globally {@link STU.ClickablePressEvent}
     *      EP.EventServices.removeObjectListener(STU.ClickablePressEvent, beScript, 'onMousePressOverSomeActor');
     *      // unregister localy {@link STU.ClickablePressEvent}
     *      var actor = this.getActor();
     *      actor.removeObjectListener(STU.ClickablePressEvent, beScript, 'onMousePressOverParentActor');
     * };
     * 
     * beScript.onMousePressOverSomeActor = function (iEvent) {
     *     console.log("The mouse has been pressed over some 3d actor");
     * };
     * 
     * beScript.onMousePressOverParentActor = function (iEvent) {
     *      console.log("The mouse has been  pressed over my parent actor");
     * };
     *
	 * 
	 * @exports ClickablePressEvent
	 * @class	 
	 * @constructor
     * @noinstancector
	 * @public
	 * @see STU.ClickableEvent
	 * @extends STU.ClickableEvent
	 * @memberof STU
     * @alias STU.ClickablePressEvent
	 */
	var ClickablePressEvent = function () {
	
	    ClickableEvent.call(this);

	    /**
         * Mouse Button ID.
         * 
         * @member
		 * @private
         * @type {EP.Mouse.EButton}
         */
	    this.button = EP.Mouse.EButton.eNone;
		
	};
	
	ClickablePressEvent.prototype = new ClickableEvent();
	ClickablePressEvent.prototype.constructor = ClickablePressEvent;
	ClickablePressEvent.prototype.type = 'ClickablePressEvent';

	/**
	 * Set the Mouse Button ID.
	 * 
	 * @method
	 * @private
	 * @param {EP.Mouse.EButton} iMouseButton
	 */
	ClickablePressEvent.prototype.setButton = function (iMouseButton) {
		this.button = iMouseButton;
	};

	/**
	 * Return the Mouse Button ID.
	 * 
	 * @method
	 * @public
	 * @return {EP.Mouse.EButton}
	 */
	ClickablePressEvent.prototype.getButton = function () {
		return this.button;
	};

	// Expose in STU namespace.
	STU.ClickablePressEvent = ClickablePressEvent;

	EP.EventServices.registerEvent(ClickablePressEvent);

	return ClickablePressEvent;
});

define('StuClickable/StuClickablePressEvent', ['DS/StuClickable/StuClickablePressEvent'], function (ClickablePressEvent) {
    'use strict';

    return ClickablePressEvent;
});

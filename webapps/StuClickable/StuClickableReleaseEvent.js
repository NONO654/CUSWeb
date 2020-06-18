
define('DS/StuClickable/StuClickableReleaseEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent'], function (STU, ClickableEvent) {
	'use strict';

	/**
	 * Describe a STU.ClickableEvent triggered by a {@link STU.Actor3D}.
	 * Require a {@link STU.Actor3D} containing a {@link STU.Clickable}.<br/>
	 * 
	 * The clickable zone is corresponding to the projection of a {@link STU.Actor3D} on the screen.
	 * This area defines the necessary position to click on a {@link STU.Actor3D}.<br/>
	 * 
	 * This event is dispatched globally on the EP.EventServices and locally on their own parent {@link STU.Actor}.
	 * In order to get notified, you need to add a listener as {@link STU.ClickableReleaseEvent} type on the corresponding {@link STU.Actor} or on the {@link EP.EventServices}.<br/>
	 *
	 * @example
     * beScript.onStart = function () {
     *      //Call 'onMouseReleasedOverSomeActor' method of beScript on each {@link STU.ClickableReleaseEvent}
     *      EP.EventServices.addObjectListener(STU.ClickableReleaseEvent, beScript, 'onMouseReleasedOverSomeActor');
     *      //Call 'onMouseReleasedOverParentActor' method of beScript each time a {@link STU.ClickableReleaseEvent} is triggered by {@link STU.Actor3D}
     *      var actor = this.getActor();
     *      actor.addObjectListener(STU.ClickableReleaseEvent, beScript, 'onMouseReleasedOverParentActor');
     * };
     * 
     * beScript.onStop = function () {
     *      // unregister globally {@link STU.ClickableReleaseEvent}
     *      EP.EventServices.removeObjectListener(STU.ClickableReleaseEvent, beScript, 'onMouseReleasedOverSomeActor');
     *      // unregister localy {@link STU.ClickableReleaseEvent}
     *      var actor = this.getActor();
     *      actor.removeObjectListener(STU.ClickableReleaseEvent, beScript, 'onMouseReleasedOverParentActor');
     * };
     * 
     * beScript.onMouseReleasedOverSomeActor = function (iEvent) {
     *     console.log("The mouse has been released over some 3d actor");
     * };
     * 
     * beScript.onMouseReleasedOverParentActor = function (iEvent) {
     *      console.log("The mouse has been released over my parent actor");
     * };
	 *
	 * 
	 * @exports ClickableReleaseEvent
	 * @class
	 * @constructor
     * @noinstancector
	 * @public
	 * @see STU.ClickableEvent
	 * @extends STU.ClickableEvent
	 * @memberof STU
     * @alias STU.ClickableReleaseEvent
	 */
	var ClickableReleaseEvent = function () {
	
	    ClickableEvent.call(this);

	    /**
         * Mouse Button ID
         * 
         * @member
		 * @private
         * @type {EP.Mouse.EButton}
         */
	    this.button = EP.Mouse.EButton.eNone;
		
	};
	
	ClickableReleaseEvent.prototype = new ClickableEvent();
	ClickableReleaseEvent.prototype.constructor = ClickableReleaseEvent;
	ClickableReleaseEvent.prototype.type = 'ClickableReleaseEvent';

	/**
	 * Set the Mouse Button ID.
	 * 
	 * @method
	 * @private
	 * @param {EP.Mouse.EButton} iMouseButton
	 */
	ClickableReleaseEvent.prototype.setButton = function (iMouseButton) {
		this.button = iMouseButton;
	};

	/**
	 * Return the Mouse Button ID.
	 * 
	 * @method
	 * @public
	 * @return {EP.Mouse.EButton}
	 */
	ClickableReleaseEvent.prototype.getButton = function () {
		return this.button;
	};

	// Expose in STU namespace.
	STU.ClickableReleaseEvent = ClickableReleaseEvent;

	EP.EventServices.registerEvent(ClickableReleaseEvent);

	return ClickableReleaseEvent;
});

define('StuClickable/StuClickableReleaseEvent', ['DS/StuClickable/StuClickableReleaseEvent'], function (ClickableReleaseEvent) {
    'use strict';

    return ClickableReleaseEvent;
});

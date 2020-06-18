
define('DS/StuClickable/StuClickableDoubleClickEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent'], function (STU, ClickableEvent) {
	'use strict';

	/**
	 * Describe a {@link STU.ClickableEvent} triggered by a {@link STU.Actor3D}.
	 * It occurs when a mouse button is double clicked with the cursor on the clickable zone.<br/>
	 * 
	 * This event is dispatched globally on the {@link  EP.EventServices} and locally on their own parent {@link STU.Actor}.
	 * In order to get notified, you need to add a listener as {@link STU.ClickableDoubleClickEvent} type on the corresponding {@link STU.Actor} or on the {@link EP.EventServices}.<br/>
	 *
	 * @example
	 *	beScript.onStart = function () {
	 *	     //Call 'onDoubleClickOnActor3d' method of beScript on each {@link STU.ClickableDoubleClickEvent}
	 *	     EP.EventServices.addObjectListener(STU.ClickableDoubleClickEvent, beScript, 'onDoubleClickOnActor3d');
	 *	     //Call 'onDoubleClickOnParentActor' method of beScript each time a {@link STU.ClickableDoubleClickEvent} is triggered by {@link STU.Actor3D}
	 *	     var actor = this.getActor();
	 *	     actor.addObjectListener(STU.ClickableDoubleClickEvent, beScript, 'onDoubleClickOnParentActor');
	 *	};
	 *	
	 *	beScript.onStop = function () {
	 *	     // unregister globally {@link STU.ClickableDoubleClickEvent}
	 *	     EP.EventServices.removeObjectListener(STU.ClickableDoubleClickEvent, beScript, 'onDoubleClickOnActor3d');
	 *	     // unregister localy {@link STU.ClickableDoubleClickEvent}
	 *	     var actor = this.getActor();
	 *	     actor.removeObjectListener(STU.ClickableDoubleClickEvent, beScript, 'onDoubleClickOnParentActor');
	 *	};
	 *	
	 *	beScript.onDoubleClickOnActor3d = function (iEvent) {
	 *	    console.log("Some actor has been doubled clicked");
	 *	};
	 *	
	 *	beScript.onDoubleClickOnParentActor = function (iEvent) {
	 *	     console.log("My parent actor has been double clicked");
	 *	};
	 *
	 * @exports ClickableDoubleClickEvent
	 * @class	 
	 * @constructor
	 * @noinstancector
	 * @private
	 * @see STU.ClickableEvent
	 * @extends STU.ClickableEvent
	 * @memberof STU
     * @alias STU.ClickableDoubleClickEvent
	 */
	var ClickableDoubleClickEvent = function () {
	
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
	
	ClickableDoubleClickEvent.prototype = new ClickableEvent();
	ClickableDoubleClickEvent.prototype.constructor = ClickableDoubleClickEvent;
	ClickableDoubleClickEvent.prototype.type = 'ClickableDoubleClickEvent';

	/**
	 * Set the Mouse Button ID.
	 * 
	 * @method
	 * @private
	 * @param {EP.Mouse.EButton} iMouseButton
	 */
	ClickableDoubleClickEvent.prototype.setButton = function (iMouseButton) {
		this.button = iMouseButton;
	};

	/**
	 * Return the Mouse Button ID.
	 * 
	 * @method
	 * @private
	 * @return {EP.Mouse.EButton}
	 */
	ClickableDoubleClickEvent.prototype.getButton = function () {
		return this.button;
	};

	// Expose in STU namespace.
	STU.ClickableDoubleClickEvent = ClickableDoubleClickEvent;

	EP.EventServices.registerEvent(ClickableDoubleClickEvent);

	return ClickableDoubleClickEvent;
});

define('StuClickable/StuClickableDoubleClickEvent', ['DS/StuClickable/StuClickableDoubleClickEvent'], function (ClickableDoubleClickEvent) {
    'use strict';

    return ClickableDoubleClickEvent;
});

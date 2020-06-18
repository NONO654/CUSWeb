define('DS/StuClickable/StuClickableExitEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent'], function (STU, ClickableEvent) {
    'use strict';

    /**
     * Describe a STU.ClickableEvent triggered by a {@link STU.Actor3D}.
     * It occurs when the mouse cursor exits from the clickable zone.<br/>
     *
     * The clickable zone is corresponding to the projection of a {@link STU.Actor3D} on the screen.
     * This area defines the necessary position to click on a {@link STU.Actor3D}.<br/>
     *
     * This event is dispatched globally on the EP.EventServices and locally on their own parent {@link STU.Actor}.
     * In order to get notified, you need to add a listener as STU.ClickableExitEvent type on the corresponding {@link STU.Actor} or on the EP.EventServices.<br/>
     *
     * @example
     * beScript.onStart = function () {
     *      //Call 'onExitSomeActor' method of beScript on each {@link STU.ClickableExitEvent}
     *      EP.EventServices.addObjectListener(STU.ClickableExitEvent, beScript, 'onExitSomeActor');
     *      //Call 'onExitParentActor' method of beScript each time a {@link STU.ClickableExitEvent} is triggered by {@link STU.Actor3D}
     *      var actor = this.getActor();
     *      actor.addObjectListener(STU.ClickableExitEvent, beScript, 'onExitParentActor');
     * };
     * 
     * beScript.onStop = function () {
     *      // unregister globally {@link STU.ClickableExitEvent}
     *      EP.EventServices.removeObjectListener(STU.ClickableExitEvent, beScript, 'onExitSomeActor');
     *      // unregister localy {@link STU.ClickableExitEvent}
     *      var actor = this.getActor();
     *      actor.removeObjectListener(STU.ClickableExitEvent, beScript, 'onExitParentActor');
     * };
     * 
     * beScript.onExitSomeActor = function (iEvent) {
     *     console.log("The mouse cursor has entered some 3d actor");
     * };
     * 
     * beScript.onExitParentActor = function (iEvent) {
     *      console.log("The mouse cursor has entered some my parent actor");
     * };
     *
     * @exports ClickableExitEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @see STU.ClickableEvent
     * @extends STU.ClickableEvent
     * @memberof STU
     * @alias STU.ClickableExitEvent
     */
    var ClickableExitEvent = function () {

        ClickableEvent.call(this);
    };

    ClickableExitEvent.prototype = new ClickableEvent();
    ClickableExitEvent.prototype.constructor = ClickableExitEvent;
    ClickableExitEvent.prototype.type = 'ClickableExitEvent';

    // Expose in STU namespace.
    STU.ClickableExitEvent = ClickableExitEvent;

    EP.EventServices.registerEvent(ClickableExitEvent);

    return ClickableExitEvent;
});

define('StuClickable/StuClickableExitEvent', ['DS/StuClickable/StuClickableExitEvent'], function (ClickableExitEvent) {
    'use strict';

    return ClickableExitEvent;
});

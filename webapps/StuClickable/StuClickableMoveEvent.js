define('DS/StuClickable/StuClickableMoveEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent'], function (STU, ClickableEvent) {
    'use strict';

    /**
     * Describe a STU.ClickableEvent triggered by a {@link STU.Actor3D}.
     * It occurs when the mouse cursor moves on the clickable zone.<br/>
     *
     * The clickable zone is corresponding to the projection of a  {@link STU.Actor3D} on the screen in 2D.
     * This area defines the necessary position to click on a  {@link STU.Actor3D}.<br/>
     *
     * This event is dispatched globally on the EP.EventServices and locally on their own parent  {@link STU.Actor}.
     * In order to get notified, you need to add a listener as STU.ClickableMoveEvent type on the corresponding  {@link STU.Actor} or on the EP.EventServices.<br/>
     *
     * @example
     * beScript.onStart = function () {
     *      //Call 'onMouseMoveOverSomeActor' method of beScript on each {@link STU.ClickableExitEvent}
     *      EP.EventServices.addObjectListener(STU.ClickableExitEvent, beScript, 'onMouseMoveOverSomeActor');
     *      //Call 'onMouseMoveOverParentActor' method of beScript each time a {@link STU.ClickableExitEvent} is triggered by {@link STU.Actor3D}
     *      var actor = this.getActor();
     *      actor.addObjectListener(STU.ClickableExitEvent, beScript, 'onMouseMoveOverParentActor');
     * };
     * beScript.onStop = function () {
     *      // unregister globally {@link STU.ClickableExitEvent}
     *      EP.EventServices.removeObjectListener(STU.ClickableExitEvent, beScript, 'onMouseMoveOverSomeActor');
     *      // unregister localy {@link STU.ClickableExitEvent}
     *      var actor = this.getActor();
     *      actor.removeObjectListener(STU.ClickableExitEvent, beScript, 'onMouseMoveOverParentActor');
     * };
     * beScript.onMouseMoveOverSomeActor = function (iEvent) {
     *     console.log("The mouse has moved over some 3d actor");
     * };
     * beScript.onMouseMoveOverParentActor = function (iEvent) {
     *      console.log("The mouse has moved over my parent actor");
     * };
     *
     * @exports ClickableMoveEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @see STU.ClickableEvent
     * @extends STU.ClickableEvent
     * @memberof STU
     * @alias STU.ClickableMoveEvent
     */
    var ClickableMoveEvent = function () {

        ClickableEvent.call(this);
    };

    ClickableMoveEvent.prototype = new ClickableEvent();
    ClickableMoveEvent.prototype.constructor = ClickableMoveEvent;
    ClickableMoveEvent.prototype.type = 'ClickableMoveEvent';

    // Expose in STU namespace.
    STU.ClickableMoveEvent = ClickableMoveEvent;

    EP.EventServices.registerEvent(ClickableMoveEvent);

    return ClickableMoveEvent;
});

define('StuClickable/StuClickableMoveEvent', ['DS/StuClickable/StuClickableMoveEvent'], function (ClickableMoveEvent) {
    'use strict';

    return ClickableMoveEvent;
});

define('DS/StuClickable/StuClickableEnterEvent', ['DS/StuCore/StuContext', 'DS/StuClickable/StuClickableEvent'], function (STU, ClickableEvent) {
    'use strict';

    /**
     * Describe a STU.ClickableEvent triggered by a {@link STU.Actor3D}.
     * It occurs when the mouse cursor enters on the clickable zone.<br/>
     *
     * The clickable zone is corresponding to the projection of a STU.Actor3D on the screen.
     * This area defines the necessary position to click on a STU.Actor3D.<br/>
     *
     * This event is dispatched globally on the EP.EventServices and locally on their own parent STU.Actor.<br/>
     * In order to get notified, you need to add a listener as STU.ClickableEnterEvent type on the corresponding STU.Actor or on the EP.EventServices.<br/>
     *
     *   @example
     *   beScript.onStart = function () {
     *        //Call 'onEnterSomeActor' method of beScript on each {@link STU.ClickableEnterEvent}
     *        EP.EventServices.addObjectListener(STU.ClickableEnterEvent, beScript, 'onEnterSomeActor');
     *        //Call 'onEnterParentActor' method of beScript each time a {@link STU.ClickableEnterEvent} is triggered by {@link STU.Actor3D}
     *        var actor = this.getActor();
     *        actor.addObjectListener(STU.ClickableEnterEvent, beScript, 'onEnterParentActor');
     *   };
     *
     *   beScript.onStop = function () {
     *        // unregister globally {@link STU.ClickableEnterEvent}
     *        EP.EventServices.removeObjectListener(STU.ClickableEnterEvent, beScript, 'onEnterSomeActor');
     *        // unregister locally {@link STU.ClickableEnterEvent}
     *        var actor = this.getActor();
     *        actor.removeObjectListener(STU.ClickableEnterEvent, beScript, 'onEnterParentActor');
     *   };
     *
     *   beScript.onEnterSomeActor = function (iEvent) {
     *          console.log("The mouse cursor has exited some 3d actor");
     *   };
     *
     *   beScript.onExitParentActor = function (iEvent) {
     *      console.log("The mouse cursor has exited some my parent actor");
     *   };
     *
     *
     * @exports ClickableEnterEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @see STU.ClickableEvent
     * @extends STU.ClickableEvent
     * @memberof STU
     * @alias STU.ClickableEnterEvent
     */
    var ClickableEnterEvent = function () {

        ClickableEvent.call(this);
    };

    ClickableEnterEvent.prototype = new ClickableEvent();
    ClickableEnterEvent.prototype.constructor = ClickableEnterEvent;
    ClickableEnterEvent.prototype.type = 'ClickableEnterEvent';

    // Expose in STU namespace.
    STU.ClickableEnterEvent = ClickableEnterEvent;

    EP.EventServices.registerEvent(ClickableEnterEvent);

    return ClickableEnterEvent;
});

define('StuClickable/StuClickableEnterEvent', ['DS/StuClickable/StuClickableEnterEvent'], function (ClickableEnterEvent) {
    'use strict';

    return ClickableEnterEvent;
});

define('DS/StuClickable/StuClickableEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent'], function (STU, Event) {
    'use strict';

    /**
     * <p>Describe an event generated from a {@link STU.Actor3D}.<br/>
     * It occurs when a mouse action is performed on a clickable zone.<br/>
     * In order to trigger clickable events, {@link STU.Actor3D} need to have their <em>Clickable</em> parameter checked.<br/></p>
     *
     * <p>Note: Some actors inheriting from {@link STU.Actor3D} may not have <em>Clickable</em> parameter. In that case, they won't throw Clickable events.</p>
     *
     * <p>The clickable zone is the projection of a {@link STU.Actor3D} on the screen.<br/>
     * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on their own parent STU.Actor.<br/>
     * In order to get notified, you need to add a listener of {@link STU.ClickableEvent} type on the corresponding {@link STU.Actor} or on the {@link EP.EventServices}.<br/><p>
     *
     * @example
     * beScript.onStart = function () {
     *      //Call 'onGlobalClickable' method of beScript on each {@link STU.ClickableEvent}
     *      EP.EventServices.addObjectListener(STU.ClickableEvent, beScript, 'onGlobalClickable');
     *
     *      //Call 'onLocalClickable' method of beScript each time a {@link STU.ClickableEvent} is triggered by {@link STU.Actor3D}
     *      var actor = this.getActor();
     *      actor.addObjectListener(STU.ClickableEvent, beScript, 'onLocalClickable');
     * };
     *
     * beScript.onStop = function () {
     *      // unregister globally {@link STU.ClickableEvent}
     *      EP.EventServices.removeObjectListener(STU.ClickableEvent, beScript, 'onGlobalClickable');
     *
     *      // unregister localy {@link STU.ClickableEvent}
     *      var actor = this.getActor();
     *      actor.removeObjectListener(STU.ClickableEvent, beScript, 'onLocalClickable');
     * };
     *
     * beScript.onGlobalClickable = function (iEvent) {
     *     console.log("Global clickable event");
     * };
     *
     * beScript.onLocalClickable = function (iEvent) {
     *      console.log("Local clickable event");
     *      console.log("My parent actor is :" + iEvent.getActor().getName());
     * };
     * 
     * @exports ClickableEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends EP.Event
     * @memberof STU
     * @alias STU.ClickableEvent
     */
    var ClickableEvent = function () {

        Event.call(this);

        /**
         * The target actor, containing the STU.Clickable.
         *
         * @member
         * @private
         * @type {STU.Actor}
         */
        this.actor;

    };

    ClickableEvent.prototype = new Event();
    ClickableEvent.prototype.constructor = ClickableEvent;
    ClickableEvent.prototype.type = 'ClickableEvent';

    /**
     * Set the target actor, containing the STU.Clickable.
     *
     * @method
     * @private
     * @param {STU.Actor3D} iActor
     */
    ClickableEvent.prototype.setActor = function (iActor) {
        this.actor = iActor;
    };

    /**
     * Return the target actor, containing the STU.Clickable.
     *
     * @method
     * @public
     * @return {STU.Actor3D}
     */
    ClickableEvent.prototype.getActor = function () {
        return this.actor;
    };

    // Expose in STU namespace.
    STU.ClickableEvent = ClickableEvent;

    EP.EventServices.registerEvent(ClickableEvent);

    return ClickableEvent;
});

define('StuClickable/StuClickableEvent', ['DS/StuClickable/StuClickableEvent'], function (ClickableEvent) {
    'use strict';

    return ClickableEvent;
});

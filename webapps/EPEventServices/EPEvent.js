define('DS/EPEventServices/EPEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices'], function (EP, EventServices) {
	'use strict';

	/**
	 * <p>Describe an object containing event information.</br>
	 * This event class is specific to Experience Play. It is not working like the javascript basic event class.</br>
	 * It represents an action or a change detected during the experience.</br>
	 * EP.Event class can be extended in order to distinguish all different type of event.</p>
	 *
	 * <p>You can register a listener for a specific event class to get notified when an event, from this type or any type which extends it, occurs.</br>
	 * It's possible to get notified with the EP.EventServices.</br>
	 * The constructor function of the class is used to identify the event type.</br>
	 * It means that when you want to register for a specific event type you need to use it as argument.</br>
	 * You can also check if an object is a specific EP.Event object with instanceof function and the constructor function.</p>
	 *
	 * <p>For example, when an action or a change occurs it will send an EP.Event through the EP.EventServices.</br>
	 * If you register a listener only on a specific EP.Event, you will only get notified for this type of event.</p>
	 *
	 * @constructor
	 * @alias EP.Event
	 * @public
	 * @example
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 */
	var Event = function () {
		/**
         * The time when this event occurs.
         * The number of milliseconds elapsed since 1 january 1970 00:00:00 UTC.
         *
		 * @private
         * @type {number}
         */
		this.time = Date.now();
	};

	Event.prototype.constructor = Event;
	Event.prototype.type = 'Event';

    /**
	 * Return the event type.
	 *
	 * @public
	 * @return {string}
	 * @example
	 * var objectListener = {};
	 * objectListener.onEvent = function (iEvent) {
	 *	// an event occurred
	 *	var type = iEvent.getType();
	 * };
	 */
	Event.prototype.getType = function () {
	    return this.type;
	};

	/**
	 * Return the Date corresponding to the time when this event occurs.
	 *
	 * @public
	 * @return {Date}
	 * @example
	 * var objectListener = {};
	 * objectListener.onEvent = function (iEvent) {
	 *	// an event occurred
	 *	var date = iEvent.getDate();
	 * };
	 */
	Event.prototype.getDate = function () {
	    return new Date(this.time);
	};

	// Expose in EP namespace.
	EP.Event = Event;

	EventServices.registerEvent(Event);

	return Event;
});

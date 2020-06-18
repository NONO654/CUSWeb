define('DS/EPEventServices/EPEventServices', ['DS/EP/EP', 'DS/EPEventServices/EPEventTarget'], function (EP, EventTarget) {
	'use strict';

	/**
	 * Describe an object which provides services for events.</br>
	 * It can dispatch global events and have listeners for them.</br>
	 * User can add and remove listener in order to get notified when a specific type of event occurs.</br>
	 * Callbacks on listeners are done synchronously.
	 *
	 * @namespace
	 * @alias EP.EventServices
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
	var EventServices = {};

	/**
	 * The list of all registered type event.</br>
	 * Object which is a list of EP.Event constructor function associated to a string corresponding to the type.
	 *
	 * @private
	 * @type {!Object.<string, EP.Event>}
	 * @see EP.EventServices.registerEvent
	 */
	var eventsByType = {};

	/**
	 * The list of all extended class from EP.Event.</br>
	 * It contains arrays, one for each EP.Event type represented by a string which has extended class.</br>
	 * Each array is a list of direct extended class from the corresponding EP.Event type.
	 *
	 * @private
	 * @type {Object.<string, Array.<EP.Event>>}
	 * @see EP.EventServices.registerEvent
	 */
	var eventsByProtoType = {};

	/**
	 * The event target aggregated by the event services.
	 *
	 * @private
	 * @type {EP.EventTarget}
	 */
	var eventTarget = new EventTarget();

	/**
	 * Initialize the event services.
	 *
	 * @private
	 * @see EP.EventServices.dispose
	 */
	EventServices.initialize = function () {

	};

	/**
	 * Dispose the event services.
	 *
	 * @private
	 * @see EP.EventServices.initialize
	 */
	EventServices.dispose = function () {
	    eventTarget = new EventTarget();
	};

	/**
	 * Register an event class.</br>
	 * Check its prototypal inheritance in order to register it as an extension of its prototype.</br>
	 * By default, the constructor name will be used as Event type, but you can override it with the property type on the prototype.
	 *
	 * @public
	 * @param {EP.Event} iEventCtor constructor function
	 * @example
	 * var MyEvent = function () {
	 *	EP.Event.Call(this);
	 * }
	 * MyEvent.prototype = new EP.Event();
	 * MyEvent.prototype.constructor = MyEvent;
	 * MyEvent.prototype.type = 'MyEvent';
	 * EP.EventServices.registerEvent(MyEvent);
	 */
	EventServices.registerEvent = function (iEventCtor) {
		if (iEventCtor.prototype instanceof EP.Event) {
			if (!iEventCtor.prototype.hasOwnProperty('type')) {
				iEventCtor.prototype.type = iEventCtor.name;
			}
			var eventType = iEventCtor.prototype.type;
			if (EventServices.getEventByType(eventType) !== undefined) {
				throw new TypeError('iEventCtor argument is already registered');
			}

			var eventProtoType = Object.getPrototypeOf(iEventCtor.prototype).type;
			if (eventsByProtoType[eventProtoType] === undefined) {
				eventsByProtoType[eventProtoType] = [];
			}

			if (eventsByProtoType[eventProtoType].indexOf(iEventCtor) === -1) {
				eventsByProtoType[eventProtoType].push(iEventCtor);
			}

			eventsByType[eventType] = iEventCtor;
		}
		else if (iEventCtor === EP.Event) {
			eventsByType[iEventCtor.prototype.type] = iEventCtor;
		}
		else {
			throw new TypeError('iEventCtor argument is not a EP.Event extended class constructor');
		}
	};

    /**
	 * Unregister an event class.</br>
	 * Check its prototypal inheritance in order to unregister it as an extension of its prototype.
	 *
	 * @public
	 * @param {EP.Event} iEventCtor constructor function
	 * @example
	 * var MyEvent = function () {
	 *	EP.Event.Call(this);
	 * }
	 * MyEvent.prototype = new EP.Event();
	 * MyEvent.prototype.constructor = MyEvent;
	 * MyEvent.prototype.type = 'MyEvent';
	 * EP.EventServices.registerEvent(MyEvent);
     * // MyEvent is registered
     * EP.EventServices.unregisterEvent(MyEvent);
	 */
	EventServices.unregisterEvent = function (iEventCtor) {
	    if (iEventCtor.prototype instanceof EP.Event) {
	    	var eventType = iEventCtor.prototype.type;
	    	if (EventServices.getEventByType(eventType) !== iEventCtor) {
	    		throw new TypeError('iEventCtor argument is not registered');
	    	}

	    	var eventProtoType = Object.getPrototypeOf(iEventCtor.prototype).type;
	        var index = eventsByProtoType[eventProtoType].indexOf(iEventCtor);
	        if (index !== -1) {
	            eventsByProtoType[eventProtoType].splice(index, 1);
	        }

	        delete eventsByType[eventType];
	    }
	    else {
	        throw new TypeError('iEventCtor argument is not a EP.Event extended class constructor');
	    }
	};

	/**
	 * Return a EP.Event constructor function from a corresponding event type.
	 *
	 * @public
	 * @param {string} iEventType the corresponding event type
	 * @return {EP.Event} constructor function
	 * @see EP.EventServices.registerEvent
	 * @example
	 * var myEventCtor = EP.EventServices.getEventByType('MyEvent');
	 */
	EventServices.getEventByType = function (iEventType) {
		if (typeof iEventType !== 'string') {
			throw new TypeError('iEventType argument is not a string');
		}
		return eventsByType[iEventType];
	};

	/**
	 * Return an array of all event type.
	 *
	 * @private
	 * @return {Array.<string>} the list of all event type
	 * @see EP.EventServices.registerEvent
	 * @example
	 * var eventsByType = EP.EventServices.getEventTypeList();
	 * for(var i=0; i&lt;eventsByType.length; i++) {
	 *	// eventsByType[i] is an event
	 * }
	 */
	EventServices.getEventTypeList = function () {
		return Object.keys(eventsByType);
	};

	/**
	 * Return an array of direct extended class from a corresponding event type.
	 *
	 * @private
	 * @param {string} iEventType the corresponding event type
	 * @return {Array.<EP.Event>} the list of extended class
	 * @see EP.EventServices.registerEvent
	 * @example
	 * var eventsByProtoType = EP.EventServices.getEventListByProtoType('MyEvent');
	 * for(var i=0; i&lt;eventsByProtoType.length; i++) {
	 *	// the prototype of eventsByProtoType[i] is MyEvent
	 * }
	 */
	EventServices.getEventListByProtoType = function (iEventType) {
		if (typeof iEventType !== 'string') {
			throw new TypeError('iEventType argument is not a string');
		}

		if (eventsByProtoType[iEventType] === undefined) {
			return [];
		}

		return eventsByProtoType[iEventType].slice(0);
	};

	/**
	 * Add a function listener to get notified for a specific event type.</br>
	 * When the provided event type occurs, the event services will callback the function listener.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {function(EP.Event)} iListener the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventServices.removeListener
	 * @example
	 * var onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addListener(EP.MyEvent, onMyEvent);
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeListener(EP.MyEvent, onMyEvent);
	 */
	EventServices.addListener = function (iEventCtor, iListener) {
		eventTarget.addListener(iEventCtor, iListener);
	};

	/**
	 * Remove a function listener to stop getting notified when the event type specified occurs.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {function(EP.Event)} iListener the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventServices.addListener
	 * @example
	 * var onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addListener(EP.MyEvent, onMyEvent);
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeListener(EP.MyEvent, onMyEvent);
	 */
	EventServices.removeListener = function (iEventCtor, iListener) {
		eventTarget.removeListener(iEventCtor, iListener);
	};

	/**
	 * Add an object listener to get notified when the event type specified occurs.</br>
	 * When the provided event type occurs, the event services will callback the function on the object listener.
	 *
	 * @public
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {Object} iObj the object listener which has the function to get callback
	 * @param {string} iFctName name of the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventServices.removeObjectListener
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
	EventServices.addObjectListener = function (iEventCtor, iObj, iFctName) {
		eventTarget.addObjectListener(iEventCtor, iObj, iFctName);
	};

	/**
	 * Remove an object listener to stop getting notified when the event type specified occurs.
	 *
	 * @public
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {Object} iObj the object listener which has the function to get callback
	 * @param {string} iFctName name of the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventServices.addObjectListener
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
	EventServices.removeObjectListener = function (iEventCtor, iObj, iFctName) {
		eventTarget.removeObjectListener(iEventCtor, iObj, iFctName);
	};

	/**
	 * Check if it has listeners for the event type specified.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @return {boolean}
	 * @see EP.EventServices.addListener
	 * @see EP.EventServices.removeListener
	 * @see EP.EventServices.addObjectListener
	 * @see EP.EventServices.removeObjectListener
	 * @example
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Check if it has listeners
	 * var hasListeners = EP.EventServices.hasListeners(EP.MyEvent);
	 */
	EventServices.hasListeners = function (iEventCtor) {
		return eventTarget.hasListeners(iEventCtor);
	};

	/**
	 * Dispatch synchronously an event in a global context.</br>
	 * All listeners registered on this event type will be notified.
	 *
	 * @public
	 * @param {EP.Event} iEvent instance object
	 * @example
	 * var myEvent = new MyEvent();
	 * EP.EventServices.dispatchEvent(myEvent);
	 */
	EventServices.dispatchEvent = function (iEvent) {
		eventTarget.dispatchEvent(iEvent);
	};

	// Expose in EP namespace.
	EP.EventServices = EventServices;

	return EventServices;
});

define('DS/EPEventServices/EPEventTarget', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * Describe an object which can dispatch local events and have listeners for them.</br>
	 * User can add and remove listener in order to get notified when a specific type of event occurs.</br>
	 * Callbacks on listeners are done synchronously.
	 *
	 * @constructor
	 * @alias EP.EventTarget
	 * @private
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Remove Listener when you don't need it anymore
	 * eventTarget.removeObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 */
	var EventTarget = function () {
		/**
		 * The list of all function listener.</br>
		 * It contains arrays, one for each event type.</br>
		 * Each array is a list of function listener associated to an event type.
		 *
		 * @private
		 * @type {Object.<string, Array.<function(EP.Event)>>}
		 * @see EP.EventTarget#addListener
		 * @see EP.EventTarget#removeListener
		 */
		this.listeners = {};

		/**
		 * The list of all object listener.</br>
		 * It contains arrays, one for each event type.</br>
		 * Each array is a list of object listener associated to an event type.</br>
		 * An object listener has two properties : obj and fctName.
		 *
		 * @private
		 * @type {Object.<string, Array.<{obj: Object, fctName: string}>>}
		 * @see EP.EventTarget#addObjectListener
		 * @see EP.EventTarget#removeObjectListener
		 */
		this.objListeners = {};
	};

	EventTarget.prototype.constructor = EventTarget;

	/**
	 * Add a function listener to get notified for a specific event type.</br>
	 * When the provided event type occurs, the event handler will callback the function listener.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {function(EP.Event)} iListener the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventTarget#removeListener
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addListener(EP.MyEvent, onMyEvent);
	 * // Remove Listener when you don't need it anymore
	 * eventTarget.removeListener(EP.MyEvent, onMyEvent);
	 */
	EventTarget.prototype.addListener = function (iEventCtor, iListener) {
		if (typeof iEventCtor !== 'function') {
			throw new TypeError('iEventCtor argument is not a function');
		}

		var eventType = iEventCtor.prototype.type;
		if (EP.EventServices.getEventByType(eventType) !== iEventCtor) {
			throw new TypeError('iEventCtor argument is not a valid EP.Event type');
		}

		if (typeof iListener !== 'function') {
			throw new TypeError('iListener argument is not a function');
		}

		if (this.listeners[eventType] === undefined) {
			this.listeners[eventType] = [];
		}

		// Add listener for each derived event from eventType
		var eventsArray = EP.EventServices.getEventListByProtoType(eventType);
		for (var i = 0; i < eventsArray.length; i++) {
			this.addListener(eventsArray[i], iListener);
		}

		// Add listener for eventType
		if (this.listeners[eventType].indexOf(iListener) === -1) {
			this.listeners[eventType].push(iListener);
		}
	};

	/**
	 * Remove a function listener to stop getting notified when the event type specified occurs.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {function(EP.Event)} iListener the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventTarget#addListener
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addListener(EP.MyEvent, onMyEvent);
	 * // Remove Listener when you don't need it anymore
	 * eventTarget.removeListener(EP.MyEvent, onMyEvent);
	 */
	EventTarget.prototype.removeListener = function (iEventCtor, iListener) {
		if (typeof iEventCtor !== 'function') {
			throw new TypeError('iEventCtor argument is not a function');
		}

		var eventType = iEventCtor.prototype.type;
		if (EP.EventServices.getEventByType(eventType) !== iEventCtor) {
			throw new TypeError('iEventCtor argument is not a valid EP.Event type');
		}

		if (typeof iListener !== 'function') {
			throw new TypeError('iListener argument is not a function');
		}

		// remove listener for each derived event from eventType
		var eventsArray = EP.EventServices.getEventListByProtoType(eventType);
		for (var i = 0; i < eventsArray.length; i++) {
			this.removeListener(eventsArray[i], iListener);
		}

		if (this.listeners[eventType] !== undefined) {
			// Remove listener for eventType
			var index = this.listeners[eventType].indexOf(iListener);
			if (index !== -1) {
				this.listeners[eventType].splice(index, 1);
			}
		}
	};

	/**
	 * Add an object listener to get notified when the event type specified occurs.</br>
	 * When the provided event type occurs, the event handler will callback the function on the object listener.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {Object} iObj the object listener which has the function to get callback
	 * @param {string} iFctName name of the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventTarget#removeObjectListener
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Remove Listener when you don't need it anymore
	 * eventTarget.removeObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 */
	EventTarget.prototype.addObjectListener = function (iEventCtor, iObj, iFctName) {
		if (typeof iEventCtor !== 'function') {
			throw new TypeError('iEventCtor argument is not a function');
		}

		var eventType = iEventCtor.prototype.type;
		if (EP.EventServices.getEventByType(eventType) !== iEventCtor) {
			throw new TypeError('iEventCtor argument is not a valid EP.Event type');
		}

		if (!(iObj instanceof Object)) {
			throw new TypeError('iObj argument is not an Object');
		}

		if (typeof iFctName !== 'string') {
			throw new TypeError('iFctName argument is not a string');
		}

		if (typeof iObj[iFctName] !== 'function') {
			throw new TypeError('iObj argument has no function ' + iFctName);
		}

		if (this.objListeners[eventType] === undefined) {
			this.objListeners[eventType] = [];
		}

		// Add listener for each derived event from eventType
		var eventsArray = EP.EventServices.getEventListByProtoType(eventType);
		for (var i = 0; i < eventsArray.length; i++) {
			this.addObjectListener(eventsArray[i], iObj, iFctName);
		}

		// Add listener for eventType
		var objListenersArray = this.objListeners[eventType];
		for (var j = 0; j < objListenersArray.length; j++) {
			if (objListenersArray[j].obj === iObj && objListenersArray[j].fctName === iFctName) {
				return;
			}
		}

		var objListener = { obj : iObj, fctName : iFctName };
		objListenersArray.push(objListener);
	};

	/**
	 * Remove an object listener to stop getting notified when the event type specified occurs.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @param {Object} iObj the object listener which has the function to get callback
	 * @param {string} iFctName name of the function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with iEventCtor argument
	 * @see EP.EventTarget#addObjectListener
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Remove Listener when you don't need it anymore
	 * eventTarget.removeObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 */
	EventTarget.prototype.removeObjectListener = function (iEventCtor, iObj, iFctName) {
		if (typeof iEventCtor !== 'function') {
			throw new TypeError('iEventCtor argument is not a function');
		}

		var eventType = iEventCtor.prototype.type;
		if (EP.EventServices.getEventByType(eventType) !== iEventCtor) {
			throw new TypeError('iEventCtor argument is not a valid EP.Event type');
		}

		if (!(iObj instanceof Object)) {
			throw new TypeError('iObj argument is not an Object');
		}

		if (typeof iFctName !== 'string') {
			throw new TypeError('iFctName argument is not a string');
		}

		if (typeof iObj[iFctName] !== 'function') {
			throw new TypeError('iObj argument has no function ' + iFctName);
		}

		// remove listener for each derived event from eventType
		var eventsArray = EP.EventServices.getEventListByProtoType(eventType);
		for (var i = 0; i < eventsArray.length; i++) {
			this.removeObjectListener(eventsArray[i], iObj, iFctName);
		}

		if (this.objListeners[eventType] !== undefined) {
			// Remove listener for eventType
			var objListenersArray = this.objListeners[eventType];
			for (var j = 0; j < objListenersArray.length; j++) {
				if (objListenersArray[j].obj === iObj && objListenersArray[j].fctName === iFctName) {
					objListenersArray.splice(j, 1);
					return;
				}
			}
		}
	};

	/**
	 * Check if it has listeners for the event type specified.
	 *
	 * @private
	 * @param {EP.Event} iEventCtor constructor function corresponding to the specific event type
	 * @return {boolean}
	 * @see EP.EventTarget#addListener
	 * @see EP.EventTarget#removeListener
	 * @see EP.EventTarget#addObjectListener
	 * @see EP.EventTarget#removeObjectListener
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var objectListener = {};
	 * objectListener.onMyEvent = function (iMyEvent) {
	 *	// my event occurred
	 * };
	 * // Add Listener to get notified
	 * eventTarget.addObjectListener(EP.MyEvent, objectListener, 'onMyEvent');
	 * // Check if it has listeners
	 * var hasListeners = eventTarget.hasListeners(EP.MyEvent);
	 */
	EventTarget.prototype.hasListeners = function (iEventCtor) {
		var eventType = iEventCtor.prototype.type;
		var listeners = this.listeners[eventType];
		var objListener = this.objListeners[eventType];
		return ((listeners !== undefined && listeners.length > 0) || (objListener !== undefined && objListener.length > 0));
	};

	/**
	 * Dispatch synchronously a EP.Event in a local context.</br>
	 * All listeners registered on this event type will be notified.
	 *
	 * @private
	 * @param {EP.Event} iEvent instance object
	 * @example
	 * var eventTarget = new EP.EventTarget();
	 * var myEvent = new MyEvent();
	 * eventTarget.dispatchEvent(myEvent);
	 */
	EventTarget.prototype.dispatchEvent = function (iEvent) {

		if (iEvent instanceof EP.Event) {
			var eventType = iEvent.type;

			if (this.listeners !== undefined) {
			    var listenersArray = this.listeners[eventType];
				if (listenersArray !== undefined) {
				    listenersArray = listenersArray.slice(0);
					for (var i = 0; i < listenersArray.length; i++) {
						try {
							listenersArray[i](iEvent);
						}
						catch (runtimeError) {
							console.error(runtimeError.stack);
						}
					}
				}
			}

			if (this.objListeners !== undefined) {
			    var objListenersArray = this.objListeners[eventType];
				if (objListenersArray !== undefined) {
				    objListenersArray = objListenersArray.slice(0);
					var objListener;
					for (var j = 0; j < objListenersArray.length; j++) {
						objListener = objListenersArray[j];
						if (objListener.obj !== undefined && typeof objListener.obj[objListener.fctName] === 'function') {
							try {
								objListener.obj[objListener.fctName](iEvent);
							}
						    catch (runtimeError) {
						        var objectStr = '';
						        var object = objListener.obj;
						        while (object !== undefined) {
						            var name = object.name;
						            if (name !== undefined && name !== null) {
						                if (objectStr === '') {
						                    objectStr = name + '\n';
						                }
						                else {
						                    objectStr = name + ' / ' + objectStr;
						                }
						            }
						            object = object.parent;
						        }
						        console.error(objectStr + runtimeError.stack);
						    }
						}
					}
				}
			}
		}
		else {
			throw new TypeError('iEvent argument is not a EP.Event instance');
		}
	};

	// Expose in EP namespace.
	EP.EventTarget = EventTarget;

	return EventTarget;
});

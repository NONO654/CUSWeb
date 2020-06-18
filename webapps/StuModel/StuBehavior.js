define('DS/StuModel/StuBehavior', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/StuModel/StuBehaviorActivateEvent', 'DS/StuModel/StuBehaviorDeactivateEvent'], function (STU, Instance) {
	'use strict';

	/**
	 * Describe an STU.Instance which represents one aspect of its parent STU.Actor.
	 * A STU.Behavior can have several properties which affects the STU.Actor.
	 * It can also process a specific behavior through interactions with the STU.Actor and the others STU.Behavior.
	 * In general, it describes the capacity of its parent STU.Actor.
	 * STU.Behavior is an abstract class, it has to be extended.
	 * Every Creative Experience behavior must extends this class.
	 *
	 * @exports Behavior
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Instance
	 * @memberof STU
	 * @alias STU.Behavior
	 */
	var Behavior = function () {

		Instance.call(this);

		this.name = 'Behavior';

		/**
		 * Object holding the list of auto registered functions
		 * @private
		 * @member
		 * @type {Object}
		 */
		this._autoListeners = {};

		/**
		 * Array holding the list of auto registered functions on 3d actors
		 * @private
		 * @member
		 * @type {Array}
		 */
		this._autoActorsListeners = [];

		/**
		 * Set holding auto registered function names, local or global
		 * It is used to make sure we don't register twice the same function  
		 * @private
		 */
		this._listenersNameSet = new Set();

		/**
		 * Actor hosting that behavior.
		 *
		 * Note: This property is in read access only.
		 *
		 * @member
		 * @instance
		 * @name actor
		 * @readOnly
		 * @public
		 * @type {STU.Actor}
		 * @memberOf STU.Behavior
		 */
		Object.defineProperty(this, 'actor', {
			enumerable: true,
			configurable: true,
			get: function () {
				return this.getActor();
			},			
		});

	};

	Behavior.prototype = new Instance();
	Behavior.prototype.constructor = Behavior;
	Behavior.prototype.featureCatalog = 'StudioModel.feat';
	Behavior.prototype.featureStartup = 'CXPBehavior_Spec';
	Behavior.prototype.protoId = 'C2A5EC31-2958-43BC-B4FA-50D940710EE7';
	Behavior.prototype.pureRuntimeAttributes = ['_autoListeners', '_autoActorsListeners', 'actor'].concat(STU.Instance.prototype.pureRuntimeAttributes);



	/**
	 * Return the parent STU.Actor containing this STU.Behavior.<br/>
	 * You can also access to the actor by typing "this.actor"
	 *
	 * @method
	 * @public
	 * @return {STU.Actor} instance object corresponding to the parent actor
	 */
	Behavior.prototype.getActor = function () {
		return this.getParent();
	};
	
	/**
	 * Find a STU.Behavior, corresponding to a specific type, in the behaviors list of the parent STU.Actor.<br/>
	 * You can also get iType by typing "this.NameOfBehavior" e.g. this.CarController
	 *
	 * @method
	 * @public
	 * @param {STU.Behavior} iType constructor function corresponding to the asked behavior type
	 * @return {STU.Behavior} instance object corresponding to the found behavior
	 */
	Behavior.prototype.getBehaviorByType = function (iType) {
		var parent = this.getParent();
		if (parent === undefined) {
			return;
		}
		return parent.getBehaviorByType(iType);
	};

	/**
	 * Return the experience
	 * @method
	 * @public
	 * @return {STU.Experience} instance object corresponding to the experience
	 */
	Behavior.prototype.getExperience = function () {
	    return STU.Experience.getCurrent();
	};	

	/**
	 * Check if this STU.Behavior is activable.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Behavior.prototype.isActivable = function () {
		return (Instance.prototype.isActivable.call(this) &&
			this.parent !== undefined && this.parent !== null &&
			(this.parent.getActivationState() === STU.eActivationState.eActivating ||
				this.parent.getActivationState() === STU.eActivationState.eActive));
	};

	/**
	 * Process to execute when this STU.Behavior is activating. 
	 *
	 * @method
	 * @private
	 */
	Behavior.prototype.onActivate = function () {
		Instance.prototype.onActivate.call(this);
		this.registerAutoListeners();
	};

	/**
	 * Automatically register methods starting with 'onall' or 'on' as listener  
	 * @private
	 */
	Behavior.prototype.registerAutoListeners = function () {
		var listOfEvt = EP.EventServices.getEventTypeList();
		var beh = this;

		var listOfFn = Object.getOwnPropertyNames(this).filter(
			function (property) {
				return (typeof beh[property] === 'function' && property.substring(0, 2) === 'on');
			}
		);

		var parentActor = this.getActor();

		for (var i = 0; i < listOfFn.length; i++) {
			var fnName = listOfFn[i];

			// Skip to next item if a listener is already registered  
			if(this._listenersNameSet.has(fnName)){
				continue;
			}

			var isGlobal = (fnName.substring(0, 5) === 'onAll');
			var isLocal = (isGlobal || fnName.substring(0, 2) === 'on');

			if (isGlobal) {
				var evnName = fnName.substring(5) + 'Event';
				
				var eventCtor = EP.EventServices.getEventByType(evnName);
				if (eventCtor !== undefined && eventCtor !== null) {
					EP.EventServices.addObjectListener(eventCtor, this, fnName);
					//save for deactivation
					this._autoListeners[evnName] = fnName;
					//if it's global it's not local
					isLocal = false;
					this._listenersNameSet.add(fnName);
				}
			}

			if (isLocal) {
				var evnName = fnName.substring(2) + 'Event';
				var eventCtor = EP.EventServices.getEventByType(evnName);
				if (eventCtor !== undefined && eventCtor !== null) {
					parentActor.addObjectListener(eventCtor, this, fnName);
					//save for deactivation
					this._autoActorsListeners.push([parentActor, eventCtor, fnName]);
					this._listenersNameSet.add(fnName);
				}
			}
		}
	};

	/**
	 * Remove listeners automatically registered
	 * @private
	 */
	Behavior.prototype.unregisterAutoListeners = function () {
		for (var evt in this._autoListeners) {
			EP.EventServices.removeObjectListener(EP.EventServices.getEventByType(evt), this, this._autoListeners[evt]);
		}
		this._autoListeners = {};

		var arraySize = this._autoActorsListeners.length;
		for (var i = 0; i < arraySize; ++i) {
			var item = this._autoActorsListeners[i];
			var actor = item[0];
			
			if (actor !== undefined && actor !== null) {
				actor.removeObjectListener(item[1], this, item[2]);
			}
		}
		this._autoActorsListeners = [];
		this._listenersNameSet.clear();
	};	

	/**
	 * Process to execute when this STU.Behavior is deactivating.
	 *
	 * @method
	 * @private
	 */
	Behavior.prototype.onDeactivate = function () {
		this.unregisterAutoListeners();

		Instance.prototype.onDeactivate.call(this);
	};

	/**
	 * Process to execute after this STU.Behavior is activated.
	 *
	 * @method
	 * @private
	 */
	Behavior.prototype.onPostActivate = function () {
		var newEvt = new STU.BehaviorActivateEvent();
		newEvt.setBehavior(this);
		this.dispatchEvent(newEvt);
	};

	/**
	 * Process to execute after this STU.Behavior is deactivated.
	 *
	 * @method
	 * @private
	 */
	Behavior.prototype.onPostDeactivate = function () {
		var newEvt = new STU.BehaviorDeactivateEvent();
		newEvt.setBehavior(this);
		this.dispatchEvent(newEvt);
	};

	
	// Expose in STU namespace.
	STU.Behavior = Behavior;

	return Behavior;
});

define('StuModel/StuBehavior', ['DS/StuModel/StuBehavior'], function (Behavior) {
    'use strict';

    return Behavior;
});

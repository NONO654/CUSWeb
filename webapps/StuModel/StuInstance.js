
define('DS/StuModel/StuInstance', ['DS/StuCore/StuContext', 'DS/StuCore/StuBridge', 'DS/StuCore/StuTools', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEventTarget',
    'DS/StuModel/StuInstanceActivateEvent', 'DS/StuModel/StuInstanceDeactivateEvent'], function (STU, Bridge, Tools) {
	'use strict';

	/**
	* An enumeration for all possible activation state.
	* 
	* @private
	* @enum {number}
    * @memberOf STU
	*/
	STU.eActivationState = { 
		/**
		 * Activating
		 * @private
		 */
		"eActivating": 0,
		/**
		 * Active
		 * @private
		 */
	 	"eActive": 1,
	 	/**
	 	 * Deactivating
	 	 * @private
	 	 */
	 	"eDeactivating": 2,
	 	/**
	 	 * Inactive
	 	 * @private
	 	 */
	 	"eInactive": 3 
	};

	/**
	 * Describes the highest class in the experience world's hierarchy. 
	 * Most of experience world's objects (cubes, lights...) descend from the STU.Instance parent.
	 * Basic functions can be accessed with this class: activation, naming, and parenting.
	 *
	 * @exports Instance
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @memberof STU
	 * @alias STU.Instance
	 */
	var Instance = function () {

		/**
		* Reversed path for services mapping in STU.ServicesManager
		* Unique identity of the object. 
		*
		* @member
		* @private
		* @type {string}
		*/
		this._path = "";

		/**
		 * Name of the Instance.
		 *
		 * @member
		 * @public
		 * @type {string}
		 * @see STU.Instance#getName
		 * @see STU.Instance#setName
		*/
		if (STU.isEKIntegrationActive()) {
			Object.defineProperty(this, "name", {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._varName;
				},
				set: function (iName) {
					this._varName = iName;
				}
			});
		}

		this.name = 'Object';
			
		/**
		* Unique identity of the object. This property is of prime importance, don't tamper with it! It is used to physically reference a specific
		* STU.Instance. For the first instance created while loading JS sources and referenced in the STU.Bridge, this property takes the same value
		* as the protoId.
		*
		* @member
		* @private
		* @type {string}
		*/
		//this.stuId = ""; //STU.GUID();

		/**
		* Parent Instance
		*
		* @member
		* @private
		* @type {STU.Instance}
		* @see STU.Instance#setParent
		* @see STU.Instance#getParent
		*/
		this.parent;

		/**
		* Activation state of this STU.Instance.
		*
		* @member
		* @private
		* @type {STU.eActivationState}
		*/
		this.activationState = STU.eActivationState.eInactive;

		/**
	     * Initialization state of this STU.Instance.
	     *
	     * @member
	     * @private
	     * @type {boolean}
		 * @see STU.Instance#isInitialized
	     */
		this.initialized = false;
		
	};

	Instance.prototype.constructor = Instance;

    /**
	* The protoId is an important information for any STU.Instance. It allows you to specify which is the most specific
	* user defined constructor function that you want to use to build a specific STU.Instance. This is important because JS implements
	* prototypal inheritance through the indirection of constructor function.
	*
	* This information is used to build original prototypes, the first instance takes as stuId this protoId to indicates it's a proto
	* defined in JS source code.
	*
	* Please note that Instance built from other instances that are themselves built from those constructor functions written in JS source
	* are in fact instances built from constructor function built on the fly from the right instances that they use as proto.
	*
	* This property is a GUID string, for example "74E4AF4C-8CCD-495A-BE17-0B4B4559440B" for a raw instance.
	*
	* @member
	* @private
	* @type {string}
	*/
	Instance.prototype.protoId = '74E4AF4C-8CCD-495A-BE17-0B4B4559440B';

	Instance.prototype.featureCatalog = '3DExperience.feat';
	Instance.prototype.featureStartup = 'Experience';
	Instance.prototype.pureRuntimeAttributes = ['parent', 'activationState', 'initialized', '_varName'];

	/**
	 * !! INTERNAL !! You should not have to mess with this one, it is used internally to build back prototypal
	 * inheritance chain as expressed in JSON experience description!
	 *
	 * @method
	 * @private
	 * @return {STU.Instance} a new instance which constructor function has been built on the fly to have 'this'
	 * as prototype. This is through this mechanism that we can really express reuse through prototypal inheritance
	 * coming from authoring side.
	 */
	Instance.prototype.protoNew = function () {
		function _protoNew () {}
		_protoNew.prototype = this;
		_protoNew.prototype.constructor = _protoNew;
		return new _protoNew();
	};

	/**
	 * Returns the name of this STU.Instance. 
	 *
	 *
	 * @method
	 * @public
	 * @return {string} the name.
	 * @see STU.Instance#setName
	 */
	Instance.prototype.getName = function () {
		return this.name;
	};

	/**
	 * Sets a new name for this STU.Instance.
	 * 
	 *
	 * @method
	 * @public
	 * @param {string} iName the new name.
	 * @see STU.Instance#getName
	 */
	Instance.prototype.setName = function (iName) {
		this.name = iName;
	};

	/**
	 * Returns the direct parent of this STU.Instance. 
	 *
	 * @method
	 * @public
	 * @return {STU.Instance} Instance corresponding to the direct parent.
	 * @example 
	 *	// Gets the experience object in the cube instance hierarchy
	 *	var experience = myCubeInstance.findParent(STU.Experience);
	 */
	Instance.prototype.getParent = function () {
		return this.parent;
	};

	/**
	 * Finds an object of the given input type in the parent hierarchy.
	 *
	 * @method
	 * @public
	 * @param {STU.Instance} iInstanceCtor Constructor function corresponding to the chosen type.
	 * @return {STU.Instance} Instance corresponding to the found parent.
	 */
	Instance.prototype.findParent = function (iInstanceCtor) {

		if(iInstanceCtor === undefined || iInstanceCtor === null || !(iInstanceCtor.prototype instanceof STU.Instance || iInstanceCtor === STU.Instance)) {
			throw new TypeError('iInstanceCtor is not a STU.Instance constructor or a extended constructor from it');
		}

		if(this.parent === undefined || this.parent instanceof iInstanceCtor) {
			return this.parent;
		}
		else {
			return this.parent.findParent(iInstanceCtor);
		}
	};

	/**
	 * Sets a new direct parent for this STU.Instance.
	 *
	 * @method
	 * @private
	 * @param {STU.Instance} instance Object corresponding to the new parent.
	 * @see STU.Instance#getParent
	 */
	Instance.prototype.setParent = function (iParent) {
		this.parent = iParent;
	};

	/**
	 * Adds a function listener to get notified for a specific event type.
	 * When the provided event type occurs, the instance will callback the function listener.
	 *
	 * @method
	 * @private
	 * @param {EP.Event} iEventCtor Constructor function corresponding to the specific event type.
	 * @param {function} iListener Function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with the iEventCtor argument.
	 * @see STU.Instance#removeListener
	 */
	Instance.prototype.addListener = function (iEventCtor, iListener) {
		this._eventTarget.addListener(iEventCtor, iListener);
	};

	/**
	 * Removes a function listener to stop getting notified when the event type specified occurs.
	 *
	 * @method
	 * @private
	 * @param {EP.Event} iEventCtor Constructor function corresponding to the specific event type.
	 * @param {function} iListener Function which will be called with a {@link EP.Event} instance object as argument, corresponding to the event type specified with the iEventCtor argument.
	 * @see STU.Instance#addListener
	 */
	Instance.prototype.removeListener = function (iEventCtor, iListener) {
		this._eventTarget.removeListener(iEventCtor, iListener);
	};

	/**
	 * When a given event occurs, calls the functions that can be defined thanks to userscripts.
	 *
	 * @method
	 * @public
	 * @param {EP.Event} iEventCtor Constructor function corresponding to the chosen event.
	 * @param {object} iObj Object instance which has the function to call.
	 * @param {string} iFctName Name of the function which will be called with a {@link EP.Event} instance as argument, corresponding to the event type specified with the iEventCtor argument.
	 * @see STU.Instance#removeObjectListener
	 */
	Instance.prototype.addObjectListener = function (iEventCtor, iObj, iFctName) {
		this._eventTarget.addObjectListener(iEventCtor, iObj, iFctName);
	};

	/**
	 * When a given event occurs, removes an object listener to stop being notified.
	 *
	 * @method
	 * @public
	 * @param {EP.Event} iEventCtor Constructor function corresponding to the chosen event.
	 * @param {object} iObj Object instance which has the function to call.
	 * @param {string} iFctName Name of the function which will be called with a {@link EP.Event} instance as argument, corresponding to the event type specified with the iEventCtor argument.
	 * @see STU.Instance#addObjectListener
	 */
	Instance.prototype.removeObjectListener = function (iEventCtor, iObj, iFctName) {
		this._eventTarget.removeObjectListener(iEventCtor, iObj, iFctName);
	};

	/**
	 * Dispatch synchronously an event in a local context.
	 * All listeners registered on this event type will be notified.
     * By default events are dispatched globally.
	 *
	 * @method
	 * @private
	 * @param {EP.Event} iEvent instance object
     * @param {boolean} [iGlobalDispatch=true] Dispatch events globally
	 */
	Instance.prototype.dispatchEvent = function (iEvent, iGlobalDispatch) {
	    this._eventTarget.dispatchEvent(iEvent);

	    if (!(iGlobalDispatch !== undefined && iGlobalDispatch !== null && iGlobalDispatch === false)) {
	        EP.EventServices.dispatchEvent(iEvent);
	    }
	};

	/**
	 * Builds a new instance of an object using information from iSrcObj. If iSrcObj is the image of a serialized
	 * STU.Instance it will contain information regarding it's protypal inheritance chain. The makeNewFromObj method
	 * will use that information to identify (or build) the most specific constructor function that it should call to build
	 * the new object! Then all the property values within the iSrcObj will be applied to the newly built object. While doing so
	 * all properties that are themselves instances deriving from STU.Instance will be built back from their constructor, values and
	 * finalization! It is worth noting that Scene finalization is a little peculiar and will trigger onSceneFinalize on the tree of
	 * instances. At the end of the process you should get back a new instance aggregating all the functional objects that were specified
	 * by the information within iSrcObj. If iScrObj math with the description of a scene, scene finalization has been called on all objects
	 * and thus you should have again a whole graph (aggregation tree + weak references) for your scene.
	 *
	 * Don't override this method. To tweak the revive process you should override finalize and onSceneFinale instead !!
	 *
	 * @method
	 * @private
	 * @param {object} iSrcObj, the source object from which we want to get a 'complete' object ! Let's detail this a little more. The iSrcObject might
	 * not be complete in the sense that it contains data that express it's prototype values and all but as a JS Object he might not have it's prototypal
	 * chain all in place with all the methods and code associated with him. To get that back the makeNewFromObject builds a new object with the appropriate
	 * constructor function (or a newly built one) so that the method return a 'complete' object in the sense that it benefits again from everything associated
	 * with it's JS source definition, it's constructor, it's methods and all...
	 * @return {STU.Instance} returns a 'complete' object (see above) for all the data contained in iSrcObj.
	 */
	Instance.prototype.makeNewFromObj = function (iSrcObj) {

		var aNewOne = null;
        if(this.stuId===this.protoId) {
            // Then we are on a base prototype
            // let's just use the ctor luke!
            aNewOne = new this.constructor();
        } else {
            // Let's be a little more tricky
            aNewOne = this.protoNew();
        }

        if(aNewOne===null) {
            return null;
        }

		if(iSrcObj.stuId!==undefined) {
			aNewOne.stuId = iSrcObj.stuId;
		}

		// If there is a bridge we need to register
		// the new play instance !
		var bridge = STU.Bridge.getInstance();
		// we don't want to register Attribute (weakRef)
		if(bridge !== undefined && bridge !== null && iSrcObj.Value !== "weakPtr") {
			bridge.registerPlayInstance(aNewOne);
		}

		for(var propName in iSrcObj) {
			// we don't want to set the prototype property to the new instance
			if(iSrcObj.hasOwnProperty(propName) && propName !== "prototype") {
				aNewOne[propName] = iSrcObj[propName];
				if(aNewOne[propName]!==null && propName!=="__interactiveCmds") {
					aNewOne[propName] = this.reviveIndistinct(aNewOne[propName]);
				}
			}
		}

		//console.log("makeNewFromObj");
		return aNewOne.finalize();
	};

	/**
	 * Revive indisting bears some similarities with makeNewFromObj in some situations. In fact it does rely on makeNewFromObj for one of it's call path.
	 * This method is one level higher than makeNewFromObj, if you have an incomplete object (check makeNewFromObj to get more info on this notion) and that
	 * you want to get a 'complete' one for it you should call reviveIndistinct. That method will check the system to see if we already have a live instance
	 * for the provided value/object (iValue) and if we have will just update it (check updateFromObj). If there no such instance yet it will call makeNewFromObj
	 * and return it's result. Thus if there is no live instances yet, this method as the same external behavior as makeNewFromObject. On the other hand if there
	 * are already live instances they will get updated instead !!
	 *
	 * Don't override this method. To tweak the revive process you should override finalize and onSceneFinale instead !!
	 *
	 * @method
	 * @private
	 * @param {object} iValue, the source object from which we want to get a 'complete' object !
	 * @return {STU.Instance} returns a 'complete' object (see above) for all the data contained in iValue.
	 */
	Instance.prototype.reviveIndistinct = function (iValue) {

		if(Array.isArray(iValue)) {

			var l = iValue.length;
			for(var i=0; i<l; i +=1) {
				iValue[i] = this.reviveIndistinct(iValue[i]);
			}

			return iValue;
		}

		if(typeof iValue==="object" && (iValue.ready===undefined||iValue.ready!==true)) {
			// Then we have something to do !!
			// And it might depend of the associated
			// proto !
			var tmpObj = iValue;
			var instance = iValue;
            var bridge = STU.Bridge.getInstance();
            var lookup;

			if(tmpObj.weakRef!==undefined) {
				if(bridge!==undefined&&bridge!==null) {
					lookup = bridge.giveMeInstanceFromId(tmpObj.weakRef.stuId);
					if(lookup!==undefined&&lookup!==null) {
						instance = lookup;
					}
				}
			} else if(tmpObj.liveLink!==undefined) {
				if(bridge!==undefined&&bridge!==null) {
					lookup = bridge.giveMeLiveLink(tmpObj.liveLink.stuId);
					if(lookup===undefined||lookup===null) {
						// Let's try uci
						lookup = bridge.giveMeInstanceFromUci(tmpObj.liveLink.uci);
					}
					if(lookup!==undefined&&lookup!==null) {
						instance = lookup;
					}
				}
			} else {
                if(tmpObj.stuId!==undefined&&tmpObj.stuId!==null&&bridge!==undefined&&bridge!==null) {
                    instance = bridge.giveMeInstanceFromId(tmpObj.stuId);
                }

                var newInstance;
                if(instance!==undefined&&instance!==null) {
                    if(instance.updateFromObj!==undefined) {
                        instance.updateFromObj(tmpObj);
                    } else {
                        STU.trace ( function () { return "Oh man if you end up here you have a big problem!!"; }, STU.eTraceMode.eVerbose, "Bridge");
                    }
                } else if(tmpObj.prototype===undefined||tmpObj.prototype===null) {
					newInstance = new Instance();
					instance = newInstance.makeNewFromObj(tmpObj);
				} else {
					var baseProto = tmpObj.prototype;
					// We have a proto but is it a weakRef?
					if(tmpObj.prototype.weakRef!==undefined) {
						// It is!
						var weakRef = tmpObj.prototype.weakRef;
						var baseProtoId = weakRef.stuId;
						if(bridge!==undefined&&bridge!==null) {
							baseProto = bridge.giveMeInstanceFromId(baseProtoId);
						}
					}


					if(baseProto===undefined||baseProto===null) {
						newInstance = new Instance();
						instance = newInstance.makeNewFromObj(tmpObj);
					} else {

						if(baseProto.makeNewFromObj!==undefined&&baseProto.makeNewFromObj!==null) {
							instance = baseProto.makeNewFromObj(tmpObj);
						} else {
							console.log("Error in STU.Instance.reviveIndistinct, lookup proto has no makeNewFromObj!");
						}
					}
				}
			}
			return instance;
		}

		return iValue;
	};

	/**
	 * updateFromObj works along with makeNewFromObj and reviveIndistinct. To get a good grasp of what it does and in what it is involve you should read first
	 * the documentation for makeNewFromObj. To give a rough idea of what updateFromObj does we should say that basically if you have a this which is already
	 * a complete object and that you get an update of its value though a JS object iSrcObj than updateFromObj will perform and update of the values !
	 *
	 * Please note that this method will also call finalize on all objects that it revives ! Thus if you are processing a scene you will also send down the
	 * tree a onSceneFinalize !
	 *
	 * Don't override this method. To tweak the revive process you should override finalize and onSceneFinale instead !!
	 *
	 * @method
	 * @private
	 * @param {object} iSrcObj, the source object which contains the values we want to update our 'this' with.
	 * @return {STU.Instance} returns a 'complete' object (see above) for all the data contained in iValue.
	 */
    Instance.prototype.updateFromObj = function (iSrcObj) {
        //console.log("updateFromObj");
		for(var propName in iSrcObj) {
			if(iSrcObj.hasOwnProperty(propName)) {
				if(propName in this && (typeof this[propName]==='object') && (this[propName]!==undefined&&this[propName]!==null) && ("updateFromObj" in this[propName] ) )  {
					this[propName] = this[propName].updateFromObj(iSrcObj[propName]);
				} else {
					this[propName] = iSrcObj[propName];
				}
			}
            if(this.hasOwnProperty(propName)) {
                if(this[propName]!==null) {
                    this[propName]=this.reviveIndistinct(this[propName]);
                }
            }
		}

		// We should try
		// to turn all indistinct objects
		// into something more meaningfull!
		/*for(var propName in iSrcObj) {
			if(this.hasOwnProperty(propName)) {
				if(this[propName]!==null) {
					this[propName] = this.reviveIndistinct(this[propName]);
				}
			}
		}*/

		//console.log("updateFromObj");
		return this.finalize();
	};

	/*
	 * We don't do much here for instances for
	 * other types of instances might need the opportunity
	 * to finalize themselves... to take some action
	 * on an instance of themselves that has just been
	 * built from raw data or that has been updated!!
	 * To put it another way all objects will have a data
	 * part that is the exposed view of the abstraction. when
	 * these data are modified some more complex state associated
	 * with the object might need updating. finalize should be overridden
	 * to perform that part.
	 * Canonical example is the node3D that should update it's renderable
	 * transform based on its data for position, rotation, scale.
	 *
	 * When CPP part pushed thing to JS side we ensure this method is called.
	 * On JS side we expect dev to call methods instead of modifying data directly
	 * or if they modify data directly we expect them to call finalize themselves when they
	 * see fit. Calling finalize once after a transaction of several updates can be seen
	 * as of form of optimization.
	 *
	 * !! WARNING !! It should be noted though that in finalize you should take only
	 * local actions. Don't regenerate links that point up the scene structure here. If you
	 * need to perform such action choose onSceneFinalize instead !!
	 *
	 * @method
	 * @private
	 * @return {Object} returns this after finalization !
	 */
	Instance.prototype.finalize = function () {
        //console.log("finalize: " + this.name);
		return this;
	};

	/**
	 * Check if this STU.Instance is initialized.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Instance.prototype.isInitialized = function () {
		return this.initialized;
	};
	
	/**
	 * Initialize this STU.Instance.
	 *
	 * @method
	 * @private
	 * @see STU.Instance#dispose
	 */
	Instance.prototype.initialize = function () {
		if(!this.initialized) {
			this.onInitialize();
			this.initialized = true;
		}
	};
	
	/**
	 * Dispose this STU.Instance.
	 *
	 * @method
	 * @private
	 * @see STU.Instance#initialize
	 */
	Instance.prototype.dispose = function () {
		if(this.initialized) {
			this.onDispose();
			this.initialized = false;
		}
	};

	/**
	 * Process to execute when this STU.Instance is initializing.
	 *
	 * @method
	 * @private
	 * @see STU.Instance#onDispose
	 */
	Instance.prototype.onInitialize = function () {
		this._eventTarget = new EP.EventTarget();

		// Build reversed path for services mapping in STU.ServicesManager
		if (this.parent !== undefined && this.parent !== null)
			this._path = this.name + "/" + this.parent._path;
		else
			this._path = this.name;

		//console.log(this._path);
	};
	
	/**
	 * Process to execute when this STU.Instance is disposing.
	 *
	 * @method
	 * @private
	 * @see STU.Instance#onInitialize
	 */
	Instance.prototype.onDispose = function () {
		delete this._eventTarget;
	};

	/**
	 * Return the activation state of this STU.Instance.
	 *
	 * @method
	 * @private
	 * @return {STU.eActivationState}
	 */
	Instance.prototype.getActivationState = function () {
		return this.activationState;
	};

	/**
	 * Returns true if this STU.Instance is active.
	 *
	 * @method
	 * @public
	 * @return {boolean} true if this STU.Instance is active.<br/>
	 * 					 false otherwise.
	 */
	Instance.prototype.isActive = function () {
		return this.activationState === STU.eActivationState.eActive;
	};

	/**
	 * Check if this STU.Instance is activable.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Instance.prototype.isActivable = function () {
		return this.activationState === STU.eActivationState.eInactive;
	};

	/**
	 * Check if this STU.Instance is deactivable.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Instance.prototype.isDeactivable = function () {
		return this.activationState === STU.eActivationState.eActive;
	};

	/**
	 * Activates this STU.Instance.
	 * If it is already active, this will have no effect. By default, all objects are active.<br/>
	 *
	 * Activation is also performed on all object's children (behaviors, subactors ...).
	 * 
	 * @method
	 * @public
	 */
	Instance.prototype.activate = function () {
		if(this.isActivable()) {
			this.activationState = STU.eActivationState.eActivating;
			this.onActivate();
			this.activationState = STU.eActivationState.eActive;
			this.onPostActivate();
		}	
	};

	/**
	 * Deactivates this STU.Instance. (For example, it stops the execution of behaviors).
	 * If it is already inactive, this will have no effect.<br/>
	 *
	 * Deactivation is also performed on all object's children (behaviors, subactors ...).<br/>
	 * Deactivation does not remove callback functions. A deactivated object can still be called back on an event.
	 *
	 * @method
	 * @public
	 */
	Instance.prototype.deactivate = function () {
		if(this.isDeactivable()) {
			this.activationState = STU.eActivationState.eDeactivating;
			this.onDeactivate();
			this.activationState = STU.eActivationState.eInactive;
			this.onPostDeactivate();
		}	
	};

	/**
	 * Process to execute when this STU.Instance is activating. 
	 *
	 * @method
	 * @private
	 */
	Instance.prototype.onActivate = function () {

	};

	/**
	 * Process to execute when this STU.Instance is deactivating.
	 *
	 * @method
	 * @private
	 */
	Instance.prototype.onDeactivate = function () {

	};

	/**
	 * Process to execute after this STU.Instance is activated. 
	 *
	 * @method
	 * @private
	 */
	Instance.prototype.onPostActivate = function () {
		var newEvt = new STU.InstanceActivateEvent();
		newEvt.setInstance(this);
	    this.dispatchEvent(newEvt);
	    EP.EventServices.dispatchEvent(newEvt);
	};

	/**
	 * Process to execute after this STU.Instance is deactivated.
	 *
	 * @method
	 * @private
	 */
	Instance.prototype.onPostDeactivate = function () {
		var newEvt = new STU.InstanceDeactivateEvent();
		newEvt.setInstance(this);
	    this.dispatchEvent(newEvt);
	    EP.EventServices.dispatchEvent(newEvt);
	};

    /**
     * Perform a prop value copy not a deep copy!
     *
     * @method
	 * @private
	 * @return {STU.Instance} instance object corresponding to the clone
     */
    Instance.prototype.clone = function () {
        var aNewOne = new this.constructor();

        for(var propName in this) {
            if(this.hasOwnProperty(propName) && propName!=="stuId") {
                aNewOne[propName] = this[propName];
            }
        }

        return aNewOne;
    };

    /**
     * Gives an opportunity to supercharge the default stringification
     * process per families of objects. This method will be checked and called
     * by StuDefaultReplacer.
     *
     * By default the only thing we do is checking for weakRef attributes
     * and replacing values by weak references !! When overriding this method
     * you should better take care of several things:
     * Call your prototype version of it.
     * This will be used for GUI exposition as well as for schematic thus you
     * should avoid riping out of your object representation stuff that
     * might be usefull for either of these two usage!
     *
     * @method
	 * @private
	 * @return {Object} returns this or the modified object!
     */
    Instance.prototype.replacer = function() {

        var modifiedObj = this.clone(this);
        modifiedObj.stuId = this.stuId;

        for(var propName in modifiedObj) {
            if(typeof this[propName] === 'object') {
                if (STU.isWeakRef(this, propName)) {
                    // TODO : UnComment below line and comment the one after
                    // as soon as C++ can process weakRef info.
                    //modifiedObj[propName] = new STU.WeakRef(this[propName].stuId, this[propName].name);
                    delete modifiedObj[propName];
					console.log("WeakRef detected on replacer:" + propName);
                }
            }
			
			var blackList = this.pureRuntimeAttributes;
			if (modifiedObj.hasOwnProperty(propName) && blackList.indexOf(propName) !== -1) {
				delete modifiedObj[propName];
			}			
        }

		return modifiedObj;
    };
	
	//Bridge.getInstance().registerPrototype(Instance.prototype);

	// Expose in STU namespace.
	STU.Instance = Instance;

	return Instance;
});

define('StuModel/StuInstance', ['DS/StuModel/StuInstance'], function (Instance) {
    'use strict';

    return Instance;
});

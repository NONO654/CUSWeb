
define('DS/StuCore/StuBridge', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager'], function (STU, Manager) {
	'use strict';

	/*
	 * The bridge is one of the main object on JS side involved in CPP <-> JS communications. It serve several purposes. It bears 
	 * the methods used to serialize STU.Instances in a way that is usable by the CPP side (JSON format + Studio's specific annotations
	 * to support our specific semantic on top of JSON ), it also offers all the method to look up on the JS side JS instances based on their
	 * GUID or based on their name. It does maintain the list of JS prototypes that need to be accessed by the CPP side to populate the
	 * CPP type manager and to finish with it is the root of parsing process for a scene exported/pushed as JSON string by the CPP side.
	 *
	 * The bridge is the equivalent on the CPP side of the StuIESWorld implementation which manage the CPP side of the conversation
	 * between the two. It is worth noting that at the moment it is the CPP side which takes the initiative of the communication
	 * and manages the exchange with the JS side bridge. The implementation with have of StuIESWorld knows about JS world and about the
	 * bridge. The bridge is ignorant of the CPP side and offer functionalities in a way so that thy can be used independently of it.
	 * 
	 * To some extend this might allow an easier path to playing content from a persisted JSON string or one handled through the network.
	 * Some information like live links should be given a persisted view in case we want one day to use the JSON form as a persistence
	 * mechanism or as a cross process communication support.
	 *
	 * Except for getJSONForNaParser you should not have to interact yourself with the bridge too often. If you happen to have a lot
	 * of interaction with the bridge please let us know this might imply that we need to provide some form of service elsewhere. By
	 * essence the bridge is meant to be used mainly for CPP <-> JS communications and all this should happen without you in the middle
	 * so you should not have to use the bridge much unless your are providing some 'infrastructure' functionalities along these lines.
	 *
	 * @exports Bridge
	 * @class
	 * @constructor
	 * @private
	 * @extends Manager 
	 * @memberof STU
	 */
	var Bridge = function ( ) {
	
		Manager.call(this);
	
		this.name = 'Bridge';
	
	    /**
		 * Hash of all the objects containing the JS prototype
		 * The key is the protoId (the UUID) of the prototype defined in JS.
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
	    this.objPrototypes = {};
	
		/**
		 * Hash of all the proto JS instances that need to be consumed by CPP side.
		 * The key is the protoId (the UUID) of the prototype defined in JS.
		 * The value is the first instance of it that has been created upon initialization!
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
		this.protoInstances = {};
	
	    
        this.blockDefinitions = {};

		/**
		 * Hash containing all live STU.Instance. The key is the stuId (UUID) of these instances
		 * and the value is the instance itself. This collection is used to revive objects and
		 * re generate references to object that are not aggregations.
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
		this.playInstances;
	
		/**
		 * Hash containing all instances of CPP constructs that are accessible through bindings.
		 * Again the key is the stuId of the live instance and the value is the pointer itself.
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
		this.liveLinks;
	};
	
	Bridge.prototype = new Manager();
	Bridge.prototype.constructor = Bridge;
	
	/**
	 * Process to execute when this STU.Bridge is initializing.
	 *
	 * @method
	 * @private
	 */
	Bridge.prototype.onInitialize = function () {
	
	    this.playInstances = {};
	    this.liveLinks = {};
	};
	
	/**
	 * Process to execute when this STU.Bridge is disposing.
	 *
	 * @method
	 * @private
	 */
	Bridge.prototype.onDispose = function () {
	
	    delete this.playInstances;
	    delete this.liveLinks;
	};
	
	/**
	 * Communicating a graph is always tricky business at least to some extend. Most of the time
	 * you need to be able to serialize the information contained within the graph. This involve
	 * traversing the graph. In our case we have two types of link within the graph, aggregated sub
	 * objects and objects that are referenced without being aggregated.
	 * You can view the graph as a tree if you keep only aggregation relations. getJSONForNaParser
	 * will serialize that tree in a JSON string. Specific annotations are used to handle
	 * a few Studio specificities. Among other things we put in the serialization annotations
	 * for references that are not aggregation.
	 *
	 * Although the method is already in use, some annotations in the resulting serialization 
	 * are still missing because we had no time to handle them properly on the CPP side yet.
	 *
	 * @method
	 * @private
	 * @param {Object} iObject the object that need to be serialized in a way that can be processed
	 * by the CPP side (aka the StuIESWorld implementation in use at this point).
	 * @return {string} a JSON string with Studio specific annotations.
	 */
	Bridge.prototype.getJSONForNaParser = function (iObject) {
		var defaultReplacer = new STU.DefaultReplacer();
		var dumpStr = JSON.stringify(iObject, defaultReplacer.getReplacer());
		return dumpStr;
	};
	
	/**
	 * This method will return the specified STU.Instance (aka the one with stuId = iInstanceID) if it has been registered
	 * with the bridge earlier on.
	 * giveMeInstanceFromId will follow these steps in order to resolve your query:
	 *      1. It will try to lookup the instance in the proto table.
	 *		2. It will then search live instances that are not declared to the platform as prototypes.
	 *		3. In last resort if it has not found anything it will dig in the list of CPP construct instances
	 *			known to the bridge.
	 * At each step if it does find something it will return it.
	 *
	 * @method
	 * @private
	 * @param {string} iInstanceID the stuId  of the instance that you want to retrieve.
	 * @return {Object} the instance with the specified stuId if it was registered with the bridge. Won't return
	 * anything useful if there is no instance with that stuId registered with the bridge. 
	 */
	Bridge.prototype.giveMeInstanceFromId = function (iInstanceID) {
		var instance = this.protoInstances[iInstanceID];
		STU.trace ( function () { return "Bridge.giveMeInstanceFromId:  On Id: " + iInstanceID; }, STU.eTraceMode.eVerbose, "Bridge");
		if(instance===undefined||instance===null) {
			instance = this.playInstances[iInstanceID];
			STU.trace ( function () { return "Bridge.giveMeInstanceFromId: Retrieving play instance of: " + iInstanceID; }, STU.eTraceMode.eVerbose, "Bridge");
		}
		if(instance===undefined||instance===null) {
			instance = this.giveMeLiveLink(iInstanceID);
			STU.trace ( function () { return "Bridge.giveMeInstanceFromId: Retrieving live link of: " + iInstanceID; }, STU.eTraceMode.eVerbose, "Bridge");
		}
		return instance;
	};
	
	
	/**
	 * This method will do it's best to found what you are looking for from the provided uci.
	 * At the moment this method only attempts to resolve livelink that way by relying on the resource
	 * manager.
	 *
	 * @method
	 * @private
	 * @param {string} iUci the uci to use for the look up.
	 * @return {Object} the instance that match the uci if one was found.
	 */
	Bridge.prototype.giveMeInstanceFromUci = function (iUci) {
		return this.giveMeLiveLinkFromUci(iUci);
	};
	
	/**
	 * This method will return a live link. Aka an object representant of a CPP ADT exposed to JS through JS bindings. When such entities are manipulated
	 * on the CPP side in authoring they are usually encoded as livelinks (please note that livelinks are used for weak (non aggregating) references also.
	 * These livelinks are handled by StuIESWorld implementation in a special way to that these pointers to live CPP ADT instances are communicated 
	 * to JS side with information on the binding that there is to use to manipulate them. In the process the bridge keep track of these so that
	 * when processing the JSON string coming from the CPP side references to these instances of CPP objects can be revived ! At the end of the 
	 * revive process all objects pointing to such CPP objects on authoring side should have been projected in JS objects having under the same property
	 * name a JS representant of the CPP object. giveMeLiveLink is used to relink these properties.
	 *
	 * @method
	 * @private
	 * @param {string} iID the stuId  of live link that you are trying to retrieve.
	 * @return {Object} reprensentant of the binded C++ object that you have specified through the iID.
	 */
	Bridge.prototype.giveMeLiveLink = function (iID) {
		return this.liveLinks[iID];
	};
	
	/**
	 * This method will return a live link. Aka an object representant of a CPP ADT exposed to JS through JS bindings. When such entities are manipulated
	 * on the CPP side in authoring they are usually encoded as livelinks (please note that livelinks are used for weak (non aggregating) references also.
	 * These livelinks are handled by StuIESWorld implementation in a special way to that these pointers to live CPP ADT instances are communicated 
	 * to JS side with information on the binding that there is to use to manipulate them. In the process the bridge keep track of these so that
	 * when processing the JSON string coming from the CPP side references to these instances of CPP objects can be revived ! At the end of the 
	 * revive process all objects pointing to such CPP objects on authoring side should have been projected in JS objects having under the same property
	 * name a JS representant of the CPP object. giveMeLiveLink is used to relink these properties.
	 * In case giveMeLiveLink is not successful giveMeInstanceFromId will fail and the client code might attempt to resolve it through an uci
	 * if one is provided (which is the case on live links). For live link that request will end up here, where we will attempt to perform something
	 * using the resource manager.
	 *
	 * @method
	 * @private
	 * @param {string} iUci the uci to use to attempt resolution.
	 * @return {Object} a live link if one was found.
	 */
	Bridge.prototype.giveMeLiveLinkFromUci = function (iUci) {
		var resMan = STU.ResourceManager.getInstance();
		if(resMan===undefined||resMan===null) {
			STU.trace ( function () { return "Bridge.giveMeLiveLinkFromUci: could not get any resource manager, aborting search"; }, STU.eTraceMode.eWarning, "Bridge");
		}
		var instance = resMan.getModelFromUci(iUci);
		if(resMan===undefined||resMan===null) {
			STU.trace ( function () { return "Bridge.giveMeLiveLinkFromUci: could not found any match for uci: " + iUci; }, STU.eTraceMode.eWarning, "Bridge");
		}
		return instance;
	};
	
	/**
	 * This method will update the specified instance (iInstanceID) with the data contained in the provided string (iValueAsJSON).
	 * To achieve that it will first look up the instance within the bridge based on it's uuid (iInstanceID). Once found it will
	 * process the provided string, apply the values contained in it on the instance and will revive the whole aggregated tree.
	 * If no instance with the given id is found in the Bridge the method will create a new instance using proto information contained
	 * within the provided string. At the end of the process the whole tree of objects aggregated under the specified instance should be
	 * built back and if there were weak references (cycles...) these references should also be back if a scene was part of the tree. If no
	 * scene was contained in the tree, no onSceneFinalized is sent in the tree and thus depending on what you do in your objects in finalize
	 * or onSceneFinalize not all links might be back there. To summarize finalize is called on elements of the tree but not onSceneFinalize.
	 *
	 * @method
	 * @private
	 * @param {string} iInstanceID the id of the instance that you want to update.
	 * @param {string} iValuesAsJSON the JSON string containing the values to apply back on the object.
	 * @return {Object} a new instance having the specified prototype as prototype.
	 */
	Bridge.prototype.updateInstance = function (iInstanceID, iValuesAsJSON) {
		
		var tmpObj = JSON.parse(iValuesAsJSON);
		STU.trace ( function () { return "Bridge.updateInstance: on: " + iInstanceID + " with: " + tmpObj.toString(); }, STU.eTraceMode.eVerbose, "Bridge");
	    if(tmpObj.stuId===undefined) {
	        tmpObj.stuId = iInstanceID;
	    }
		var instance = this.giveMeInstanceFromId(iInstanceID);
		if(instance===undefined||instance===null) {
			// Let's try uci!
			if(tmpObj.uci!==undefined&&tmpObj.uci!==null) {
				instance = this.giveMeInstanceFromUci(tmpObj.uci);
			}
		}
	
		if(instance===undefined||instance===null) {
			STU.trace ( function () { return " Bridge.updateInstance: no instance found for: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
			if(tmpObj.prototype===undefined||tmpObj.prototype===null) {
				STU.trace ( function () { return " Bridge.updateInstance: (no prototype) from: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
				instance = new STU.Instance();
				instance.updateFromObj(tmpObj);
				this.registerPlayInstance(instance);
			} else {
				STU.trace ( function () { return " Bridge.updateInstance: (prototype found) from: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
				var baseProto = tmpObj.prototype;
				// We have a proto but is it a weakRef?
				if(tmpObj.prototype.weakRef!==undefined) {
					// It is!
					STU.trace ( function () { return " Bridge.updateInstance: (weakref prototype) from: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
					baseProto = this.giveMeInstanceFromId(tmpObj.prototype.weakRef.stuId);
					if (baseProto ===undefined)
					{
						STU.trace ( function () { return " Bridge.updateInstance: Failed to retrieve prototype from: " + tmpObj.prototype.weakRef.stuId; }, STU.eTraceMode.eError, "Bridge");
					}
				}
	
				
				if(baseProto===undefined||baseProto===null) {
					STU.trace ( function () { return " Bridge.updateInstance: Create object with no prototype from: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
					instance = new STU.Instance();
					instance.updateFromObj(tmpObj);
					this.registerPlayInstance(instance);
				} else {
					STU.trace ( function () { return " Bridge.updateInstance: Create object with prototype from: " + tmpObj.stuId; }, STU.eTraceMode.eVerbose, "Bridge");
					instance = baseProto.makeNewFromObj(tmpObj);
					//useless, already doing it in makeNewFromObj
					//this.registerPlayInstance(instance);
				}
			}
		} else {
			STU.trace ( function () { return " Bridge.updateInstance: instance found for: " + tmpObj.stuId + ". Updating..."; }, STU.eTraceMode.eVerbose, "Bridge");
			instance.updateFromObj(tmpObj);
		}
		STU.trace ( function () { return " Bridge.updateInstance: instance updated: " + instance.toString(); }, STU.eTraceMode.eVerbose, "Bridge");
		return instance;
	};
	
	/**
	 * This method is a convenience offered by the bridge to the CPP side so that CPP code can call easily a method on a JS object. This
	 * is used among other blocks by the GUI using the interactive commands defined in JS source files.
	 *
	 * @method
	 * @private
	 * @param {string} iObjID the id of the instance/object on which you want to call a method.
	 * @param {string} iMethodName the method name.
	 * @param {string} iArgsAsJSON the JSON string containing the arguments to use on the method call in JSON form.
	 * @return {Object} a new instance having the specified prototype as prototype.
	 */
	Bridge.prototype.callMethod = function (iObjID, iMethodName, iArgsAsJSON) {
	    var that = this;
	
	    STU.trace(function () { return "STU.Bridge.callMethod with iMethodName=<" + iMethodName + "> and iArgsAsJSON=<" +iArgsAsJSON + ">";}, STU.eTraceMode.eVerbose);
	
	    var ourObj=this.giveMeInstanceFromId(iObjID);
	    if(ourObj===undefined||ourObj===null) {
	        STU.trace ( function () { return "STU.Bridge.callMethod: Failed to retrieve object from id: " + iObjID + "."; }, STU.eTraceMode.eVerbose, "Bridge");
	        return null;
	    }
	
	    var ourCmds=ourObj.__interactiveCmds;
	    if(ourCmds===undefined||ourCmds===null) {
	        STU.trace ( function () { return "STU.Bridge.callMethod: Failed to retrieve interactive command from id: " + iObjID + "."; }, STU.eTraceMode.eVerbose, "Bridge");
	        return null;
	    }
	
	    if(ourCmds[iMethodName]===undefined) {
	        STU.trace ( function () { return "STU.Bridge.callMethod: Failed to retrieve method " + iMethodName + " from id: " + iObjID + "."; }, STU.eTraceMode.eVerbose, "Bridge");
	        return null;
	    }
	
	    // Using a dummy guid, always the same :)
	    var ourArgs = this.updateInstance("D268C64C-EF7C-44bc-8A4D-9BB4810C02A6", iArgsAsJSON);
	    if(ourArgs===undefined||ourArgs===null) {
	        STU.trace ( function () { return "STU.Bridge.callMethod: Could not build arguments " + iArgsAsJSON + "."; }, STU.eTraceMode.eVerbose, "Bridge");
	        return null;
	    } else {
	        STU.trace(function () { return "STU.Bridge.callMethod: ourArgs=<" + that.getJSONForNaParser(ourArgs) + ">";}, STU.eTraceMode.eVerbose);
	    }
	
	    var argsArr = [];
	    for(var propName in ourArgs) {
	        if(propName==="that"||propName==="name"||propName==="prototype"||propName==="stuId"||propName==="ready"||propName==="protoId") {
	            continue;
	        } else {
	            if(ourArgs[propName]!==null) {
	                argsArr.push(ourArgs[propName]);
	            }
	        }
	    }
	    STU.trace(function () { return "STU.Bridge.callMethod: argsArr=<" + that.getJSONForNaParser(argsArr) + ">";}, STU.eTraceMode.eVerbose);
	
	    return ourCmds[iMethodName].apply(ourObj, argsArr);
	};
	
	/**
	 * This method offers a convenient way to register the object containing the JS prototype
	 *
	 * @method
	 * @private
	 * @param {Object} iPrototype the prototype object to be registered.
	 */
	Bridge.prototype.registerPrototype = function (iPrototype)
	{
	    if(iPrototype.constructor) {
			console.debug("registerPrototype: Registering:"+iPrototype.protoId);
			if (this.objPrototypes[iPrototype.protoId] !== undefined) {
				console.error("registerPrototype: ERROR: Proto already registered Registering:"+iPrototype.protoId);
			}
			this.objPrototypes[iPrototype.protoId]=iPrototype;
		}
		else {
			console.error("registerPrototype: Registering Failed, Invalid Constructor: "+iPrototype.protoId);
		}
	};
	
	/**
	 * The bridge maintains a list of instances that are part of the scene to be played. This method offer a convenient way to register
	 * such an instance against the bridge.
	 *
	 * @method
	 * @private
	 * @param {STU.Instance} iInstance the instance that we want to register within the bridge.
	 */
	Bridge.prototype.registerPlayInstance = function (iInstance) {
		if(iInstance instanceof STU.Instance) {
			STU.trace ( function () { return "registerPlayInstance: Registering:" + iInstance.stuId + "."; }, STU.eTraceMode.eVerbose, "Bridge");
			this.playInstances[iInstance.stuId] = iInstance;
		}
	};
	
	/**
	 * The bridge maintains a list of live instances (aka of object representant of binded C++ ADT), if you need to register one against
	 * the bridge you might use this method. This method is used by the BuildJS process.
	 *
	 * @method
	 * @private
	 * @param {string} iID the uuid of the livelink to register within the bridge. That uuid is of crucial importance as it is used
	 * to get back back the livelink.
	 * @param {Object} iLiveLink the representant for the binded C++ ADT.
	 * @return {Object} 
	 */
	Bridge.prototype.registerLiveLink = function (iID, iLiveLink) {
		this.liveLinks[iID] = iLiveLink;
		return this.liveLinks[iID];
	};
	
	/**
	 * Method used to initialize the various prototypes that we want to register against the bridge. This method creates a nominal
	 * instance of the prototype and ensures that it's stuId will be equal to the protoId.
	 *
	 * @method
	 * @private
	 * @return {boolean} if everything went all right. 
	 */
	Bridge.prototype.initPrototypes = function () {  
	
	    var protoId;
	    var protoInstance;
	
	    for ( protoId in this.objPrototypes ) {
	        if(this.objPrototypes.hasOwnProperty(protoId)) {
	            if(this.protoInstances.hasOwnProperty(protoId)) {
	                protoInstance = this.protoInstances[protoId];
	            }
	            else {
	                protoInstance = new this.objPrototypes[protoId].constructor();
	                protoInstance.stuId = protoId;
	                this.protoInstances[protoId] = protoInstance;
	            }
	        }
	    }
	        
	    return true;
	};

    Bridge.prototype.registerBlockDefinition = function (iBlockDefinition) {
        if (iBlockDefinition !== null) {
            console.debug("registerBlockDefinition: Registering:"+iBlockDefinition.name);
            if (this.blockDefinitions[iBlockDefinition.name] !== undefined) {
                console.error('registerBlockDefinition: ERROR: block definition already registered: ' + iBlockDefinition.name);
            }
            this.blockDefinitions[iBlockDefinition.name] = iBlockDefinition;
        }
        else {
            console.error('registerBlockDefinition: Registering Failed, invalid block definition!');
        }
    };
	
	STU.registerManager(Bridge);

	// Expose in STU namespace.
	STU.Bridge = Bridge;

	return Bridge;
});

define('StuCore/StuBridge', ['DS/StuCore/StuBridge'], function (Bridge) {
    'use strict';

    return Bridge;
});

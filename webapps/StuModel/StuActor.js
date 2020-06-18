define('DS/StuModel/StuActor', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/StuModel/StuActorActivateEvent', 'DS/StuModel/StuActorDeactivateEvent', 'DS/StuModel/StuExperience'], function (STU, Instance) {
	'use strict';

	/**
	 * Describes a logical entity of the experience and can aggregate behaviors (describing their capabilities and data). <br/>
	 * Warning: An actor can only have one behavior of a given type.
	 *
	 * @exports Actor
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Instance
	 * @memberof STU
     * @alias STU.Actor
	 */
	var Actor = function () {

		Instance.call(this);

		this.name = 'actor' + this.stuId;

		/**
		 * This is the collection of behaviors contained within the actor.
		 * If you want to keep it safe don't mess directly with that collection. Instead play with the addBehavior, removeBehavior and getBehaviors methods.
		 *
		 * @member
		 * @private
		 * @type {Array.<STU.Behavior>}
		 * @see STU.Actor#addBehavior
		 * @see STU.Actor#removeBehavior
		 * @see STU.Actor#getBehaviors
		 * @see STU.Actor#getBehaviorByType
		 */
		this.behaviors = [];

		/**
		 * This is the collection of children contained within the actor.
		 * If you want to keep it safe don't mess directly with that collection. Instead play with the addSubActor, removeSubActor and getSubActors methods.
		 *
		 * @member
		 * @private
		 * @type {Array.<STU.Actor>}
		 * @see STU.Actor#addSubActor
		 * @see STU.Actor#removeSubActor
		 * @see STU.Actor#getSubActors
		 * @see STU.Actor#getSubActorByName
		 */
		this.subActors = [];
	};

	Actor.prototype = new Instance();
	Actor.prototype.constructor = Actor;
	Actor.prototype.protoId = '30FB5355-2860-4651-A9A8-190670E3D1D7';
	Actor.prototype.featureCatalog = 'StudioModel.feat';
	Actor.prototype.featureStartup = 'StuActor_Spec';

	/**
	 * Add a STU.Behavior on this STU.Actor.
	 *
	 * @method
	 * @private
	 * @param {STU.Behavior} iBehavior instance object corresponding to the behavior to add
	 * @see STU.Actor#removeBehavior
	 * @see STU.Actor#getBehaviors
	 * @see STU.Actor#getBehaviorByType
	 */
	Actor.prototype.addBehavior = function (iBehavior) {
		STU.pushUnique(this.behaviors, iBehavior);

		this.addBehaviorShortcut(iBehavior);		

		iBehavior.setParent(this);
		iBehavior.initialize();
		iBehavior.activate();
	};

	/**
	 * Remove a STU.Behavior from this STU.Actor.
	 *
	 * @method
	 * @private
	 * @param {STU.Behavior} iBehavior instance object corresponding to the behavior to remove
	 * @see STU.Actor#addBehavior
	 * @see STU.Actor#getBehaviors
	 * @see STU.Actor#getBehaviorByType
	 */
	Actor.prototype.removeBehavior = function (iBehavior) {
		iBehavior.deactivate();
		iBehavior.dispose();
		iBehavior.setParent();

		this.removeBehaviorShortcut(iBehavior);
		
		STU.remove(this.behaviors, iBehavior);
	};

	/**
	 * Returns all the behaviors that have been added to this STU.Actor.
	 * 
	 *
	 * @method
	 * @public
	 * @return {Array.<STU.Behavior>} Array containing all the behavior instances.
	 * @see STU.Actor#getBehaviorByType
	 */
	Actor.prototype.getBehaviors = function () {
		return this.behaviors.slice(0);
	};

    /**
	 * Returns the experience root.
	 * @method
	 * @public
	 * @return {STU.Experience} Instance of the STU.Experience.
	 */
	Actor.prototype.getExperience = function () {
	    return STU.Experience.getCurrent();
	};

	/**
	 * Add a STU.Actor, as sub actor, on this STU.Actor.
	 *
	 * @method
	 * @private
	 * @param {STU.Actor} iActor instance object corresponding to the sub actor to add
	 * @see STU.Actor#removeSubActor
	 * @see STU.Actor#getSubActors
	 * @see STU.Actor#getSubActorByName
	 */
	Actor.prototype.addSubActor = function (iActor) {
		STU.pushUnique(this.subActors, iActor);
		iActor.setParent(this);
		iActor.initialize();
		iActor.activate();
	};

	/**
	 * Remove a STU.Actor, as sub actor, from this STU.Actor.
	 *
	 * @method
	 * @private
	 * @param {STU.Actor} iActor instance object corresponding to the sub actor to remove
	 * @see STU.Actor#addSubActor
	 * @see STU.Actor#getSubActors
	 * @see STU.Actor#getSubActorByName
	 */
	Actor.prototype.removeSubActor = function (iActor) {
		iActor.deactivate();
		iActor.dispose();
		iActor.setParent();
		STU.remove(this.subActors, iActor);
	};

	/**
	 * Returns an array containing the direct children of this STU.Actor.
	 * 
	 *
	 * @method
	 * @public
	 * @return {Array.<STU.Actor>} Array containing the direct children of this STU.Actor.
	 * @see STU.Actor#getSubActorByName
	 */
	Actor.prototype.getSubActors = function () {
		return this.subActors.slice(0);
	};

    /**
     * Returns an array containing all the subactors under this STU.Actor, not just the direct children.
	 * 
     *
     * @method
     * @public
     * @return {Array.<STU.Actor>} Array containing all the subactors under this STU.Actor.
     * @see STU.Actor#getSubActorByName
     */
	Actor.prototype.getAllSubActors = function () {
	    var subActors = this.getSubActors();

	    var allSubActors = new Array();
	    allSubActors = allSubActors.concat(subActors);

	    var actorCount = subActors.length;
	    for (var i = 0; i < actorCount; ++i) {
	        var actor = subActors[i];

	        allSubActors = allSubActors.concat(actor.getAllSubActors());
	    }

	    return allSubActors;
	}

	/**
	 * Returns a subactor, with a given name, in the subactors list of this STU.Actor.
	 * You can check the whole hierarchy with the iRecursive input.
	 *
	 * @method
	 * @public
	 * @param {string} iName the subactor's name.
	 * @param {boolean} [iRecursive=false] false: only the direct children are browsed.
	 * 									   true: all the children in the hierarchy are browsed.
	 * @return {STU.Actor} Instance corresponding to the chosen subactor.
	 * @see STU.Actor#getSubActors
	 */
	Actor.prototype.getSubActorByName = function (iName, iRecursive) {
		var count = this.subActors.length;
		for (var i = 0; i < count; i += 1) {
			var subActor = this.subActors[i];
			if (subActor !== undefined && subActor !== null) {
				if (iName === subActor.name) {
					return subActor;
				} else if (iRecursive) {
					var resActor = subActor.getSubActorByName(iName, iRecursive);
					if (resActor !== undefined && resActor !== null) {
						return resActor;
					}
				}
			}
		}
		return;
	};

	/**
	 * Checks if this STU.Actor is a child of another STU.Actor.
	 *
	 * @method
	 * @public
	 * @return {Boolean} true if this STU.Actor is a child of another STU.Actor. <br/>
	 * 					 false otherwise.
	 */
	Actor.prototype.isSubActor = function () {
		return (this.getParent() instanceof STU.Actor);
	};

	/**
	 * Returns the instance of the given behavior type if it has been added to this STU.Actor.<br/>
	 * You can also get iType by typing "this.NameOfBehavior" e.g. this.CarController
	 *
	 * @method
	 * @public
	 * @param {STU.Behavior} iType Constructor function corresponding to the chosen behavior type.
	 * @return {STU.Behavior} Behavior instance object corresponding to the chosen behavior type.
	 * @see STU.Actor#getBehaviors
	 * @example
	 * // Using getBehaviorByType
	 * var carControllerInstance = myActor.getBehaviorByType(STU.CarController);
	 * 
	 * // Using shortcut
	 * var carControllerInstance = myActor.CarController;
	 */
	Actor.prototype.getBehaviorByType = function (iType) {
		var count = this.behaviors.length;
		for (var i = 0; i < count; i++) {
			if (this.behaviors[i] instanceof iType) {
				return this.behaviors[i];
			}
		}
		return;
	};

	/**
	 * Get a capacity, corresponding to the specified name, in the behaviors list of this STU.Actor and the actor itself
	 *
	 * @method
	 * @private
	 * @param {String} iCapacityID ID of capacity to retrieve
	 * @return {Object} instance object corresponding to the found capacity (can be a STU.Service, a STU.Event or a Function)
	 * @see STU.Actor#getCapacityByID
	 */
	Actor.prototype.getCapacityByID = function (iCapacityID) {

		var behaviors = this.getBehaviors();
		var returnCapacity;
		var objectsHavingCapacities = [this];
		for (var i = 0; i < behaviors.length; i++) {
			objectsHavingCapacities.push(behaviors[i]);
		}

		for (var indI = 0; indI < objectsHavingCapacities.length; indI++) {

			if (objectsHavingCapacities[indI]["_functions"] !== undefined && objectsHavingCapacities[indI]["_functions"] !== null ){
				for (var i = 0; i < objectsHavingCapacities[indI]["_functions"].length; i++) {
					if (objectsHavingCapacities[indI]["_functions"][i].name == iCapacityID){
						if (returnCapacity !== undefined && returnCapacity !== null)
							console.warning("capacity with id : '"+iCapacityID+"'' exists more than once under actor : '"+this.name+"' (keep first found) ");
						else
							returnCapacity = objectsHavingCapacities[indI]["_functions"][i];
					}
				}
			}
			// get service capacities
			
			if (objectsHavingCapacities[indI]["_services"] !== undefined && objectsHavingCapacities[indI]["_services"] !== null ){
				for (var i = 0; i < objectsHavingCapacities[indI]["_services"].length; i++) {
					if (objectsHavingCapacities[indI]["_services"][i].name == iCapacityID){
						if (returnCapacity !== undefined && returnCapacity !== null)
							console.warning("capacity with id : '"+iCapacityID+"'' exists more than once under actor : '"+this.name+"' (keep first found)");
						else
							returnCapacity = objectsHavingCapacities[indI]["_services"][i];
					}
				}
			}
			
			// get event capacities
			if (objectsHavingCapacities[indI]["_events"] !== undefined && objectsHavingCapacities[indI]["_events"] !== null ){
				for (var i = 0; i < objectsHavingCapacities[indI]["_events"].length; i++) {
					if (objectsHavingCapacities[indI]["_events"][i].name == iCapacityID){
						if (returnCapacity !== undefined && returnCapacity !== null)
							console.warning("capacity with id : '"+iCapacityID+"'' exists more than once under actor : '"+this.name+"' (keep first found)");
						else
							returnCapacity = objectsHavingCapacities[indI]["_events"][i];
					}
				}
			}
		}
		
		return returnCapacity;
	};

	/**
	 * Process to execute when this STU.Actor is initializing.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onInitialize = function () {
		Instance.prototype.onInitialize.call(this);

		/*if (STU.isEKIntegrationActive()) {
			if (this.actors !== undefined) {
				this.subActors = this.subActors.concat(this.actors);
			}
			if (this.overrides !== undefined) {
				this.subActors = this.subActors.concat(this.overrides);
			}
		}*/


		if (STU.isEKIntegrationActive()){
			var domainStreamers = this.$assets;
			if (domainStreamers !== undefined) {
				var nbStream = domainStreamers.length;
				for (var i = 0; i < nbStream; i++) {
					var streamerOfDomain = domainStreamers[i];
					if (streamerOfDomain !== undefined && streamerOfDomain.$domain === "ECMAScript") {
						var subActJSONStr = streamerOfDomain.$reference;
						var subActJSONObj = JSON.parse(subActJSONStr);
						var listSubActorPathsStr = subActJSONObj.subActors;
						var nbElemInSubActorPath = listSubActorPathsStr.length;
						for (var j = 0; j < nbElemInSubActorPath; j++) {
							var subActorPath = listSubActorPathsStr[j];
							var subActorPathConverted = subActorPath.replace('Objects', 'STU.Experience.getCurrent()');
							var theSubActor = eval(subActorPathConverted);

							STU.pushUnique(this.subActors, theSubActor);
							theSubActor.setParent(this);
						}
					}
				}
			}
		}


		
		for (var i = 0; i < this.behaviors.length; i++) {
			var behavior = this.behaviors[i];

			this.addBehaviorShortcut(behavior);
			
			this.behaviors[i].initialize();
		}

		for (var i = 0; i < this.subActors.length; i++) {
			this.subActors[i].initialize();
		}

		var expAnims = this.animations;
		if (expAnims !== undefined && expAnims !== null) {
			for (var i = 0; i < expAnims.length; i++) {
				expAnims[i].initialize();
			}
		}

		var prdAnims = this._productAnimations;
		if (prdAnims !== undefined && prdAnims !== null) {
			for (var i = 0; i < prdAnims.length; i++) {
				prdAnims[i].initialize();
			}
		}
	};


	//if (STU.isEKIntegrationActive()) {
		/**
		 * finalize is executed after all objects have been created and just before the OnInitialize.
		 *
		 * @method
		 * @private
		*/
		/*Actor.prototype.finalize = function () {
			var domainStreamers = this.$assets;
			if (domainStreamers !== undefined) {
				var nbStream = domainStreamers.length;
				for (var i=0;i<nbStream;i++)
				{
					var streamerOfDomain = domainStreamers[i];
					if (streamerOfDomain!==undefined && streamerOfDomain.$domain === "ECMAScript")
					{
						var subActJSONStr = streamerOfDomain.$reference;
						var subActJSONObj = JSON.parse(subActJSONStr);
						var listSubActorPathsStr = subActJSONObj.subActors;
						var nbElemInSubActorPath = listSubActorPathsStr.length;
						for (var j=0;j<nbElemInSubActorPath;j++)
						{	
							var subActorPath = listSubActorPathsStr[j];
							var subActorPathConverted = subActorPath.replace('Objects', 'STU.Experience.getCurrent()');
							var theSubActor = eval(subActorPathConverted);

							STU.pushUnique(this.subActors,theSubActor);
							theSubActor.setParent(this);
						}
					}
				}
			}
		};
	}*/


	/**
	 * Process to execute when this STU.Actor is disposing.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onDispose = function () {
		
		var prdAnims = this._productAnimations;
		if (prdAnims !== undefined && prdAnims !== null) {
			for (var i = 0; i < prdAnims.length; i++) {
				prdAnims[i].dispose();
			}
		}

		var expAnims = this.animations;
		if (expAnims !== undefined && expAnims !== null) {
			for (var i = 0; i < expAnims.length; i++) {
				expAnims[i].dispose();
			}
		}


		for (var i = 0; i < this.behaviors.length; i++) {
			this.behaviors[i].dispose();
		}

		for (var i = 0; i < this.subActors.length; i++) {
			this.subActors[i].dispose();
		}

		Instance.prototype.onDispose.call(this);
	};

	/**
	 * Check if this STU.Actor is activable.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Actor.prototype.isActivable = function () {
		return (Instance.prototype.isActivable.call(this) &&
			this.parent !== undefined && this.parent !== null &&
			(this.parent.getActivationState() === STU.eActivationState.eActivating ||
				this.parent.getActivationState() === STU.eActivationState.eActive));
	};

	/**
	 * Process to execute when this STU.Actor is activating.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onActivate = function () {
		Instance.prototype.onActivate.call(this);

		for (var i = 0; i < this.behaviors.length; i++) {
			this.behaviors[i].activate();
		}

		for (var i = 0; i < this.subActors.length; i++) {
			this.subActors[i].activate();
		}

		var anims = this.animations;
		if (anims !== undefined && anims !== null) {
			for (var i = 0; i < anims.length; i++) {
				anims[i].activate();
			}
		}

		var prdAnims = this._productAnimations;
		if (prdAnims !== undefined && prdAnims !== null) {
			for (var i = 0; i < prdAnims.length; i++) {
				prdAnims[i].activate();
			}
		}
	};

	/**
	 * Process to execute when this STU.Actor is deactivating.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onDeactivate = function () {
		var prdAnims = this._productAnimations;
		if (prdAnims !== undefined && prdAnims !== null) {
			for (var i = 0; i < prdAnims.length; i++) {
				prdAnims[i].deactivate();
			}
		}

		var anims = this.animations;
		if (anims !== undefined && anims !== null) {
			for (var i = 0; i < anims.length; i++) {
				anims[i].deactivate();
			}
		}

		for (var i = 0; i < this.behaviors.length; i++) {
			this.behaviors[i].deactivate();
		}

		for (var i = 0; i < this.subActors.length; i++) {
			this.subActors[i].deactivate();
		}

		Instance.prototype.onDeactivate.call(this);
	};

	/**
	 * Process to execute after this STU.Actor is activated.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onPostActivate = function () {
		var newEvt = new STU.ActorActivateEvent();
		newEvt.setActor(this);
		this.dispatchEvent(newEvt);
	};

	/**
	 * Process to execute after this STU.Actor is deactivated.
	 *
	 * @method
	 * @private
	 */
	Actor.prototype.onPostDeactivate = function () {
		var newEvt = new STU.ActorDeactivateEvent();
		newEvt.setActor(this);
		this.dispatchEvent(newEvt);
	};

    /**
     * Returns true if this actor is in a given collection.
     *
     * @method
     * @public
     * @param {STU.Collection} iCollection Target collection
     * @return {boolean} true if this STU.Actor is available in STU.Collection.<br/>
	 * 					 false otherwise.
     */
	Actor.prototype.isInCollection = function (iCollection) {
	    return iCollection.contains(this);
	};

    /**
     * Adds this STU.Actor to a given collection.
     *
     * @method
     * @public
     * @param {STU.Collection} iCollection Target collection.     
     */
	Actor.prototype.addToCollection = function (iCollection) {
	    iCollection.addObject(this);
	};

    /**
     * Removes this STU.Actor from a given collection.
     *
     * @method
     * @public
     * @param {STU.Collection} iCollection Target collection.
     */
	Actor.prototype.removeFromCollection = function (iCollection) {
	    iCollection.removeObject(this);
	};

    /**
     * Returns all the collections containing this STU.Actor.
     *
     * @method
     * @public
     * @return {Array.<STU.Collection>} Array of collections.
     */
	Actor.prototype.getCollections = function () {
	    var retCols = [];
	    
	    var cols = STU.Experience.getCurrent().getCollections();
	    for (var c = 0; c < cols.length; ++c) {
	        var col = cols[c];

	        if (col.contains(this)) {
	            retCols.push(col);
	        }
	    }

	    return retCols;
	};

    /**
     * Create a quick access property for the given behavior.
     *
     * @method
     * @private
     * @param {STU.Behavior} registered behavior
     */
	Actor.prototype.addBehaviorShortcut = function (iBehavior) {
	    if(typeof iBehavior.name === 'string'){
	    	var behName = iBehavior.name.replace("_instance","");
	    	if (behName.length > 0) {
	        	this[behName] = iBehavior;
	    	}
	    }
	};

    /**
     * Create the quick access property for the given behavior.
     *
     * @method
     * @private
     * @param {STU.Behavior} unregistered behavior
     */
	Actor.prototype.removeBehaviorShortcut = function (iBehavior) {
		if(typeof iBehavior.name === 'string'){
	    	var behName = iBehavior.name.replace("_instance","");
	    	if (behName.length > 0) {
	        	delete this[behName];
	    	}
	    }
	};

    /**
	 * Returns true if this STU.Actor has been instantiated from this STU.ActorTemplate.
	 *
	 * @method
	 * @public
	 * @return {boolean} true if this STU.Actor has been instantiated from this STU.ActorTemplate. <br/>
	 * 					 false otherwise.
	 */
	Actor.prototype.isDynamicInstance = function () {
	    var result = this.CATI3DExperienceObject.IsDynamicInstance();
	    return result;
	};

    /**
    * Function called if the actor has been successfully deleted.
    *
    * @public
    * @callback STU.Actor~DeleteSuccessCallback
    * @see STU.Actor#delete
    */

    /**
    * Deletes this STU.Actor if it has been instantiated from this STU.ActorTemplate.
    *
    * @method
    * @public
    * @param {object}                   iParams Callback functions called after the deletion.
    * @param {STU.Actor~DeleteSuccessCallback}    iParams.onSuccess   Function called after the actor has been successfully deleted. 
    * @param {STU.Actor~DeleteFailureCallback}    iParams.onFailure   Function called if something went wrong during the deletion.
	* @example
	*	var dynamicActor = this.actor;
	*	dynamicActor.delete({
	*		onSuccess: () => {
	*			console.log("Actor successfully removed");
	*		}, onFailure: (iErrorMsg) => {
	*			console.log("Something went wrong with deletion " + iErrorMsg);
	*		}
	*	});
    */
    Actor.prototype.delete = function (iParams) {
        if (this.isDynamicInstance) {
            if (this._originTemplate !== null && this._originTemplate !== undefined) {
                this._originTemplate._removeDynamicInstance(this);
            }
            this.CATI3DExperienceObject.delete(iParams);
        }
        else {
            console.warn("Only dynamic actors can be deleted");
        }
    };

    /**
    * Function called if something went wrong during the deletion.
    *
    * @public
    * @callback STU.Actor~DeleteFailureCallback
    * @param {String} iMsg - Information about the error.
    * @see STU.Actor#delete
    */


	// Animation API

	/**
	* Returns an animation local to this actor, with the given name
	*
	* @method
	* @public
	* @param {string}   
	* @return {STU.Animation}
	*/
    Actor.prototype.getAnimationByName = function (iName) {
    	if (this.animations !== undefined && this.animations !== null) {
    		var count = this.animations.length;
    		for (var i = 0; i < count; i++) {
    			var anim = this.animations[i];
    			if (anim !== undefined) {
    				if (iName === anim.name) {
    					return anim;
    				}
    			}
    		}
		}
		if (this._productAnimations !== undefined && this._productAnimations !== null) {
			var count = this._productAnimations.length;
    		for (var i = 0; i < count; i++) {
    			var anim = this._productAnimations[i];
    			if (anim !== undefined) {
    				if (iName === anim.name) {
    					return anim;
    				}
    			}
    		}
		}
    	return null;
    };

	/**
	 * Returns all animations local to this actor
	 *
	 * @method
	 * @public
	 * @return {Array.<STU.Animation>}
	 */
    Actor.prototype.getAnimations = function () {
		var prdAnim = (this._productAnimations !== undefined && this._productAnimations !== null) ? this._productAnimations : [] ;
		var expAnim = (this.animations != undefined && this.animations !== null) ? this.animations : [] ;
    	return prdAnim.concat(expAnim);
    };


	// Expose in STU namespace.
	STU.Actor = Actor;

	return Actor;
});

define('StuModel/StuActor', ['DS/StuModel/StuActor'], function (Actor) {
    'use strict';

    return Actor;
});

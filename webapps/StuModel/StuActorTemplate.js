define('DS/StuModel/StuActorTemplate', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
	'use strict';

	/**
	 * Describe a template actor object.
	 *
	 * @exports ActorTemplate
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Instance
	 * @memberof STU
	 * @alias STU.ActorTemplate
	 */
	var ActorTemplate = function (iActor) {
		Instance.call(this);
		//this.name = 'actor' + this.stuId;

	    /**
         * This is the collection of actor instanced using this template.
         *
         * @member
         * @private
         * @type {Array.<STU.Actor>}
         */
		this.dynamicInstances = [];

	    /**
         * This is the actor prototype used for this to create this template.
         *
         * @member
         * @private
         * @type {STU.Actor}
         */
		this.templatedActor = iActor;

		if (iActor !== null && iActor !== undefined) {
		    this.name = iActor.name;
		}
		this._actorType = null;
	};

	ActorTemplate.prototype = new Instance();
	ActorTemplate.prototype.constructor = ActorTemplate;


    /**
     * Callback called if actor has been instantiated successfully.
     *
	 * @public
     * @callback STU.ActorTemplate~onInstantiationSuccess
     * @param {STU.Actor3D} iInstantiatedObj - The freshly created actor
     * @see STU.ActorTemplate#createDynamicInstance
     */

    /**
     * Callback called if actor creation has failed.
     *
	 * @public
     * @callback STU.ActorTemplate~onFailure
     * @param {String} iMsg - Information about the error.
     * @see STU.ActorTemplate#createDynamicInstance
     */

    /**
     * Callback called if actor creation AND activation has succeeded.
     *
	 * @public
     * @callback STU.ActorTemplate~onActivationSuccess
     * @param {STU.Actor3D} iInstantiatedObj - The freshly activated actor
     * @see STU.ActorTemplate#createDynamicInstance
     */

    /**
    * Create an actor using this template  
    *
    * @example
    * // creates 10 instances of MyActorTemplate with incremental names 
    * // and log their name upon creation
    * var tpl = STU.Experience.getCurrent().getActorTemplateByName("MyActorTemplate");
	* for (var i = 0; i < 10; ++i) {
	*    tpl.createDynamicInstance({
	*       name: "MyActor" + i,
	*	    onInstantiationSuccess: function (actor) {
	* 			console.log("Successfully created: " + actor.name);
	*    	}
	*    });
	* }
    *
    * @public
    * @param {object}           iParams The characteristics of the instantiation
    * @param {STU.Actor3D}      [iParams.parent] Parent the dynamic actor will be created as children of the specified actor, if not specified then the dynamic actor will be created at the root of the experience.
    * @param {String}           [iParams.name] The name of the dynamic actor, if not specified the name is automatically compute to be unique
    * 
    * @param {Boolean}          [iParams.incrementName] Automatically concatenate the name the last incremented number. This argument is false by default.
    * 
    * @param {STU.ActorTemplate~onInstantiationSuccess}      [iParams.onInstantiationSuccess]   function called when actor has been created but not activated. Not called if null.
    * @param {STU.ActorTemplate~onActivationSuccess}         [iParams.onActivationSuccess]   function called when actor has been created AND activated (and so on for its sub-actors and behaviors). Not called if null.
    * @param {STU.ActorTemplate~onFailure}                   [iParams.onFailure]   function called if creation has failed, with a given message. Not called if null.
    * 
    */
	ActorTemplate.prototype.createDynamicInstance = function (iParams) {	    
	    this.CATI3DExperienceObject.createDynamicInstance(iParams, this, this.onDynamicInstanciation);
	};

	ActorTemplate.prototype.onDynamicInstanciation = function (iActor) {
	    if (iActor !== undefined && iActor !== null) {
	        this.dynamicInstances.push(iActor);
	        iActor._originTemplate = this;
	    }
	};

	ActorTemplate.prototype._removeDynamicInstance = function (iActor) {
	    //
	    var index = this.dynamicInstances.indexOf(iActor);
	    if (index > -1) {
	        this.dynamicInstances.splice(index, 1);
	    }
	};
      
    /**
	 * Delete all created actor instantiated from this template by calling the function {@link STU.Actor#delete|Delete} on each instance.  
     *
	 * @param {object}           iParams The characteristics of the deletion
     * @param {STU.Actor~DeleteSuccessCallback}    iParams.onSuccess   function called when the actor has been deleted successfully. Not called if null.
     * @param {STU.Actor~DeleteFailureCallback}    iParams.onFailure - The callback called if deletion has failed, with a given message. Not called if null.
     * @see STU.Actor#delete
	 * @method
	 * @public
	 */
	ActorTemplate.prototype.deleteDynamicInstances = function (iParams) {
	    if (this.dynamicInstances !== null) {
	        var tmpArray = this.getDynamicInstances();
	        var count = tmpArray.length;
	        for (var i = 0; i < count; i++) {
	            tmpArray[i].delete(iParams);
	        }
	    }
	};

    /**
     * Return an array listing the all dynamic actors created using this template.
     * The returned array is a copy of the internal sub actors list.
     *
     * @method
     * @public
     * @return {Array.<STU.Actor>} Array of STU.Actor instance object
     */
	ActorTemplate.prototype.getDynamicInstances = function () {
	    return this.dynamicInstances.slice();
	};


    /**
	 * Process to execute when this STU.ActorTemplate is disposing.
	 *
	 * @method
	 * @private
	 */
	ActorTemplate.prototype.onDispose = function () {
	    Instance.prototype.onDispose.call(this);
	};

    /**
	 * Check if this STU.ActorTemplate is activable.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	ActorTemplate.prototype.isActivable = function () {
	    return Instance.prototype.isActivable.call(this);
	};

    /**
	 * Process to execute when this STU.ActorTemplate is activating.
	 *
	 * @method
	 * @private
	 */
	ActorTemplate.prototype.onActivate = function () {
	    Instance.prototype.onActivate.call(this);
	};

    /**
	 * Process to execute when this STU.ActorTemplate is deactivating.
	 *
	 * @method
	 * @private
	 */
	ActorTemplate.prototype.onDeactivate = function () {
	    Instance.prototype.onDeactivate.call(this);
	};


	// Expose in STU namespace.
	STU.ActorTemplate = ActorTemplate;

	return ActorTemplate;
});

define('StuModel/StuActorTemplate', ['DS/StuModel/StuActorTemplate'], function (ActorTemplate) {
    'use strict';

    return ActorTemplate;
});

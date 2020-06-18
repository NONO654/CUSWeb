
define('DS/StuRenderEngine/StuProductActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
	'use strict';
	
	/**
	 * Describe a STU.Actor3D which represents a Product imported in the experience.
	 * This object has a geometric representation which is required by some specific STU.Behavior.
	 *
     * @exports ProductActor
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Actor3D
	 * @memberof STU
	 * @alias STU.ProductActor
	 */
	var ProductActor = function () {
	
		Actor3D.call(this);

		/**
		 * Override of opacity from STU.Actor3D
		 * as STU.ProductActor doesn't have opacity.
		 *
		 * @member
		 * @instance
		 * @name opacity
		 * @private
		 * @type {number}
		 * @memberOf STU.ProductActor
		 */
		Object.defineProperty(this, "opacity", {
		    enumerable: true,
		    configurable: true,
		    get: function () {
		        return 0;
		    },
		    set: function (iOpacity) {
		        // console.warn('There is no opacity on STU.ProductActor');
		    }
		});
	};

	ProductActor.prototype = new Actor3D();
	ProductActor.prototype.constructor = ProductActor;

	/**
	 * Apply the configuration to the product actor
	 *
	 * @method
	 * @private
	 * @param {String} [iConfName] configuration name to apply
	 */
	ProductActor.prototype.applyConfiguration = function (iConfName) {

		var confServices = new CXPConfServices()
		confServices.ApplyConf(this.CATI3DExperienceObject , iConfName)
	};

	/**
	 * Remove the currently applied configuration to the product actor
	 *
	 * @method
	 * @private
	 */
	ProductActor.prototype.removeConfiguration = function () {

		var confServices = new CXPConfServices()
		confServices.RemoveConf(this.CATI3DExperienceObject)
	};

	/**
	 * List all configuration available for a given prodct actor
	 *
	 * @method
	 * @private
	 * @returns Array String
	 */
	ProductActor.prototype.listConfigurations = function () {

		var confServices = new CXPConfServices()
		return confServices.ListConf(this.CATI3DExperienceObject)
	};

	/**
	 * Get currently applied configuration for a given prodct actor
	 *
	 * @method
	 * @private
	 * @returns String
	 */
    // /!\ Note : Don't expose this today, it needs product configuration to be variable driven 
	//            since it may create variable asset at play (which is forbiden)
	//ProductActor.prototype.getCurrentConfiguration = function () {
    //
	//	var confServices = new CXPConfServices()
	//	return confServices.GetCurrentConf(this.CATI3DExperienceObject)
	//};

	// Expose in STU namespace.
	STU.ProductActor = ProductActor;

	return ProductActor;
});

define('StuRenderEngine/StuProductActor', ['DS/StuRenderEngine/StuProductActor'], function (ProductActor) {
    'use strict';

    return ProductActor;
});

define('DS/StuRenderEngine/StuSubProductActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
	'use strict';
	
	/**
	 * Describe a STU.Actor3D which represents a subpart of a product which a has exposed in the experience.
	 * This object has a geometric representation which is required by some specific STU.Behavior.
	 *
     * @exports SubProductActor
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Actor3D
	 * @memberof STU
	 * @alias STU.SubProductActor
	 */
	var SubProductActor = function () {
		Actor3D.call(this);

		/**
		 * Override of opacity from STU.Actor3D
		 * as STU.SubProductActor doesn't have opacity.
		 *
		 * @member
		 * @instance
		 * @name opacity
		 * @private
		 * @type {number}
		 * @memberOf STU.SubProductActor
		 */
		Object.defineProperty(this, 'opacity', {
		    enumerable: true,
		    configurable: true,
		    get: function () {
		        // console.error('there is no opacity on STU.SubProductActor');
		        return 0;
		    },
		    set: function () {
		        // console.error('there is no opacity on STU.SubProductActor');
		    }
		});
	};

	SubProductActor.prototype = new Actor3D();
	SubProductActor.prototype.constructor = SubProductActor;

	// Expose in STU namespace.
	STU.SubProductActor = SubProductActor;

	return SubProductActor;
});

define('StuRenderEngine/StuSubProductActor', ['DS/StuRenderEngine/StuSubProductActor'], function (SubProductActor) {
    'use strict';

    return SubProductActor;
});

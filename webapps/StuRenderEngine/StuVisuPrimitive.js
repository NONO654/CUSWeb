define('DS/StuRenderEngine/StuVisuPrimitive', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describes an object representing a visualization primitive created by STU.RenderManager.
	 *
	 *
	 * @exports VisuPrimitive
	 * @class
	 * @constructor
	 * @noinstancector
	 * @public
	 * @memberof STU
	 * @alias STU.VisuPrimitive
	 */
	var VisuPrimitive = function () {

	    /**
		* Id of the created primitive.
		*
		* @member
		* @private
		* @type {number}
		*/
	    this.id = 0;
	};

	VisuPrimitive.prototype.constructor = VisuPrimitive;

    	
	// Expose in STU namespace.
	STU.VisuPrimitive = VisuPrimitive;

	return VisuPrimitive;
});

define('StuRenderEngine/StuVisuPrimitive', ['DS/StuRenderEngine/StuVisuPrimitive'], function (VisuPrimitive) {
    'use strict';

    return VisuPrimitive;
});

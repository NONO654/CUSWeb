define('DS/StuGeometricPrimitives/StuPrimitiveActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
	'use strict';
	
	/**
	 * Describe a STU.Actor3D which represents a primitive object of the experience.
	 *
     * @exports PrimitiveActor
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Actor3D
	 * @memberof STU
	 * @alias STU.PrimitiveActor
	 */
	var PrimitiveActor = function () {
		Actor3D.call(this);
	};

	PrimitiveActor.prototype = new Actor3D();
	PrimitiveActor.prototype.constructor = PrimitiveActor;

	// Expose in STU namespace.
	STU.PrimitiveActor = PrimitiveActor;

	return PrimitiveActor;
});

define('StuGeometricPrimitives/StuPrimitiveActor', ['DS/StuGeometricPrimitives/StuPrimitiveActor'], function (PrimitiveActor) {
    'use strict';

    return PrimitiveActor;
});

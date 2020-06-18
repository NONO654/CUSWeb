
define('DS/StuGeometricPrimitives/StuSphereActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
* Describe a sphere object.
*
* @exports SphereActor
* @class
* @constructor
* @noinstancector
* @public
* @extends STU.PrimitiveActor
* @memberof STU
* @alias STU.SphereActor
*/
    var SphereActor = function () {

        PrimitiveActor.call(this);
        this.name = 'SphereActor';

        /**
        * Get/Set sphere radius
        *
        * @member
        * @instance
        * @name radius
        * @public
        * @type {number}
        * @memberOf STU.SphereActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'radius', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('radius');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('radius', value);
        			}
        		}
        	});
        }
        else {
        	this.radius;
        }
    };

    SphereActor.prototype = new PrimitiveActor();
    SphereActor.prototype.constructor = SphereActor;


    // Expose in STU namespace.
    STU.SphereActor = SphereActor;

    return SphereActor;
});

define('StuGeometricPrimitives/StuSphereActor', ['DS/StuGeometricPrimitives/StuSphereActor'], function (SphereActor) {
    'use strict';

    return SphereActor;
});

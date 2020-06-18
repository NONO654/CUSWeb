
define('DS/StuGeometricPrimitives/StuPlaneActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
     * Describe a plane object.
     *
     * @exports PlaneActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.PrimitiveActor
     * @memberof STU
     * @alias STU.PlaneActor
     */
    var PlaneActor = function () {

        PrimitiveActor.call(this);
        this.name = 'PlaneActor';

        /**
        * Get/Set plane length
        *
        * @member
        * @instance
        * @name length
        * @public
        * @type {number}
        * @memberOf STU.PlaneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'length', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('length');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('length', value);
        			}
        		}
        	});
        }
        else {
        	this.length;
        }

        /**
        * Get/Set cylinder width
        *
        * @member
        * @instance
        * @name width
        * @public
        * @type {number}
        * @memberOf STU.PlaneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'width', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('width');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('width', value);
        			}
        		}
        	});
        }
        else {
        	this.width;
        }

    };

    PlaneActor.prototype = new PrimitiveActor();
    PlaneActor.prototype.constructor = PlaneActor;

    // Expose in STU namespace.
    STU.PlaneActor = PlaneActor;

    return PlaneActor;
});

define('StuGeometricPrimitives/StuPlaneActor', ['DS/StuGeometricPrimitives/StuPlaneActor'], function (PlaneActor) {
    'use strict';

    return PlaneActor;
});

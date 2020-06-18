
define('DS/StuGeometricPrimitives/StuConeActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
     * Describe a cone object.
     *
     * @exports ConeActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.PrimitiveActor
     * @memberof STU
     * @alias STU.ConeActor
     */
    var ConeActor = function () {

        PrimitiveActor.call(this);
        this.name = 'ConeActor';

        /**
        * Get/Set cone height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.ConeActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'height', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('height');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('height', value);
        			}
        		}
        	});
        }
        else {
        	this.height;
        }

        /**
        * Get/Set cone radius
        *
        * @member
        * @instance
        * @name radius
        * @public
        * @type {number}
        * @memberOf STU.ConeActor
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

    ConeActor.prototype = new PrimitiveActor();
    ConeActor.prototype.constructor = ConeActor;


    // Expose in STU namespace.
    STU.ConeActor = ConeActor;

    return ConeActor;
});

define('StuGeometricPrimitives/StuConeActor', ['DS/StuGeometricPrimitives/StuConeActor'], function (ConeActor) {
    'use strict';

    return ConeActor;
});

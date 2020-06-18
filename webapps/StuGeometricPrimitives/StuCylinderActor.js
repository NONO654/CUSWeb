
define('DS/StuGeometricPrimitives/StuCylinderActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
     * Describe a cylinder object.
     *
     * @exports CylinderActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.PrimitiveActor
     * @memberof STU
     * @alias STU.CylinderActor
     */
    var CylinderActor = function () {

        PrimitiveActor.call(this);
        this.name = 'CylinderActor';

        /**
        * Get/Set cylinder height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.CylinderActor
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
        * Get/Set cylinder radius
        *
        * @member
        * @instance
        * @name radius
        * @public
        * @type {number}
        * @memberOf STU.CylinderActor
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

    CylinderActor.prototype = new PrimitiveActor();
    CylinderActor.prototype.constructor = CylinderActor;


    // Expose in STU namespace.
    STU.CylinderActor = CylinderActor;

    return CylinderActor;
});

define('StuGeometricPrimitives/StuCylinderActor', ['DS/StuGeometricPrimitives/StuCylinderActor'], function (CylinderActor) {
    'use strict';

    return CylinderActor;
});

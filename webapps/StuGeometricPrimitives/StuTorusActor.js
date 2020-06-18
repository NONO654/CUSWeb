
define('DS/StuGeometricPrimitives/StuTorusActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
* Describe a torus object.
*
* @exports TorusActor
* @class
* @constructor
* @noinstancector
* @public
* @extends STU.PrimitiveActor
* @memberof STU
* @alias STU.TorusActor
*/
    var TorusActor = function () {

        PrimitiveActor.call(this);
        this.name = 'TorusActor';

        /**
        * Get/Set torus main radius
        *
        * @member
        * @instance
        * @name radius1
        * @public
        * @type {number}
        * @memberOf STU.TorusActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'radius1', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('radius1');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('radius1', value);
        			}
        		}
        	});
        }
        else {
        	this.radius1;
        }

        /**
        * Get/Set torus secondary radius
        *
        * @member
        * @instance
        * @name radius2
        * @public
        * @type {number}
        * @memberOf STU.TorusActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'radius2', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('radius2');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('radius2', value);
        			}
        		}
        	});
        }
        else {
        	this.radius2;
        }
    };

    TorusActor.prototype = new PrimitiveActor();
    TorusActor.prototype.constructor = TorusActor;

    // Expose in STU namespace.
    STU.TorusActor = TorusActor;

    return TorusActor;
});

define('StuGeometricPrimitives/StuTorusActor', ['DS/StuGeometricPrimitives/StuTorusActor'], function (TorusActor) {
    'use strict';

    return TorusActor;
});

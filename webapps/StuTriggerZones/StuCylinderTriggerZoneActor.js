
define('DS/StuTriggerZones/StuCylinderTriggerZoneActor', ['DS/StuCore/StuContext', 'DS/StuTriggerZones/StuTriggerZoneActor'], function (STU, TriggerZoneActor) {
    'use strict';

    /**
* Describe a cylinder trigger zone.
*
* @exports CylinderTriggerZoneActor
* @class
* @constructor
* @noinstancector 
* @public
* @extends STU.TriggerZoneActor
* @memberof STU
* @alias STU.CylinderTriggerZoneActor
*/
    var CylinderTriggerZoneActor = function () {

        TriggerZoneActor.call(this);
        this.name = "CylinderTriggerZoneActor";

        /**
        * Get/Set cylinder height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.CylinderTriggerZoneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, "height", {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName("height");
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName("height", value);
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
        * @memberOf STU.CylinderTriggerZoneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, "radius", {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName("radius");
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName("radius", value);
        			}
        		}
        	});
        }
        else {
        	this.radius;
        }
    };

    CylinderTriggerZoneActor.prototype = new TriggerZoneActor();
    CylinderTriggerZoneActor.prototype.constructor = CylinderTriggerZoneActor;


    // Expose in STU namespace.
    STU.CylinderTriggerZoneActor = CylinderTriggerZoneActor;

    return CylinderTriggerZoneActor;
});

define('StuTriggerZones/StuCylinderTriggerZoneActor', ['DS/StuTriggerZones/StuCylinderTriggerZoneActor'], function (CylinderTriggerZoneActor) {
    'use strict';

    return CylinderTriggerZoneActor;
});


define('DS/StuTriggerZones/StuSphereTriggerZoneActor', ['DS/StuCore/StuContext', 'DS/StuTriggerZones/StuTriggerZoneActor'], function (STU, TriggerZoneActor) {
    'use strict';

    /**
* Describe a sphere trigger zone.
*
* @exports SphereTriggerZoneActor
* @class
* @constructor
* @noinstancector 
* @public
* @extends STU.TriggerZoneActor
* @memberof STU
* @alias STU.SphereTriggerZoneActor
*/
    var SphereTriggerZoneActor = function () {

        TriggerZoneActor.call(this);
        this.name = "SphereTriggerZoneActor";


        /**
        * Get/Set sphere radius
        *
        * @member
        * @instance
        * @name radius
        * @public
        * @type {number}
        * @memberOf STU.SphereTriggerZoneActor
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

    SphereTriggerZoneActor.prototype = new TriggerZoneActor();
    SphereTriggerZoneActor.prototype.constructor = SphereTriggerZoneActor;

    // Expose in STU namespace.
    STU.SphereTriggerZoneActor = SphereTriggerZoneActor;

    return SphereTriggerZoneActor;
});

define('StuTriggerZones/StuSphereTriggerZoneActor', ['DS/StuTriggerZones/StuSphereTriggerZoneActor'], function (SphereTriggerZoneActor) {
    'use strict';

    return SphereTriggerZoneActor;
});


define('DS/StuTriggerZones/StuCapsuleTriggerZoneActor', ['DS/StuCore/StuContext', 'DS/StuTriggerZones/StuTriggerZoneActor'], function (STU, TriggerZoneActor) {
    'use strict';

    /**
 * Describe a capsule trigger zone.
 *
 * @exports CapsuleTriggerZoneActor
 * @class
 * @constructor
 * @noinstancector 
 * @public
 * @extends STU.TriggerZoneActor
 * @memberof STU
 * @alias STU.CapsuleTriggerZoneActor
 */
    var CapsuleTriggerZoneActor = function () {

        TriggerZoneActor.call(this);
        this.name = "CapsuleTriggerZoneActor";

        /**
        * Get/Set capsule height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.CapsuleTriggerZoneActor
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
        * Get/Set capsule radius
        *
        * @member
        * @instance
        * @name radius
        * @public
        * @type {number}
        * @memberOf STU.CapsuleTriggerZoneActor
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

    CapsuleTriggerZoneActor.prototype = new TriggerZoneActor();
    CapsuleTriggerZoneActor.prototype.constructor = CapsuleTriggerZoneActor;


    // Expose in STU namespace.
    STU.CapsuleTriggerZoneActor = CapsuleTriggerZoneActor;

    return CapsuleTriggerZoneActor;
});

define('StuTriggerZones/StuCapsuleTriggerZoneActor', ['DS/StuTriggerZones/StuCapsuleTriggerZoneActor'], function (CapsuleTriggerZoneActor) {
    'use strict';

    return CapsuleTriggerZoneActor;
});

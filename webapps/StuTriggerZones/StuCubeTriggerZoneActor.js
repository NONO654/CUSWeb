
define('DS/StuTriggerZones/StuCubeTriggerZoneActor', ['DS/StuCore/StuContext', 'DS/StuTriggerZones/StuTriggerZoneActor'], function (STU, TriggerZoneActor) {
    'use strict';

/**
* Describe a cube trigger zone.
*
* @exports CubeTriggerZoneActor
* @class
* @constructor
* @noinstancector 
* @public
* @extends STU.TriggerZoneActor
* @memberof STU
* @alias STU.CubeTriggerZoneActor
*/
    var CubeTriggerZoneActor = function () {

        TriggerZoneActor.call(this);
        this.name = "CubeTriggerZoneActor";

        /**
        * Get/Set cube length
        *
        * @member
        * @instance
        * @name length
        * @public
        * @type {number}
        * @memberOf STU.CubeTriggerZoneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, "length", {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName("length");
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName("length", value);
        			}
        		}
        	});
        }
        else {
        	this.length;
        }

        /**
        * Get/Set cube width
        *
        * @member
        * @instance
        * @name width
        * @public
        * @type {number}
        * @memberOf STU.CubeTriggerZoneActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, "width", {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName("width");
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName("width", value);
        			}
        		}
        	});
        }
        else {
        	this.width;
        }

        /**
        * Get/Set cube height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.CubeTriggerZoneActor
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
    };

    CubeTriggerZoneActor.prototype = new TriggerZoneActor();
    CubeTriggerZoneActor.prototype.constructor = CubeTriggerZoneActor;

    // Expose in STU namespace.
    STU.CubeTriggerZoneActor = CubeTriggerZoneActor;

    return CubeTriggerZoneActor;
});

define('StuTriggerZones/StuCubeTriggerZoneActor', ['DS/StuTriggerZones/StuCubeTriggerZoneActor'], function (CubeTriggerZoneActor) {
    'use strict';

    return CubeTriggerZoneActor;
});


// pour débugger (script ne marche pas au moment où j'écris cette ligne) :
/*var CubeTriggerZoneActorTask = function (iCube) {
EP.Task.call(this);
this.actor = iCube;
};
CubeTriggerZoneActorTask.prototype = new EP.Task();
CubeTriggerZoneActorTask.prototype.constructor = CubeTriggerZoneActorTask;
CubeTriggerZoneActorTask.prototype.onStart = function (iExContext) {
console.log("length : " + this.actor.length);
};
CubeTriggerZoneActorTask.prototype.onExecute = function (iExContext) {
var rot = new ThreeDS.Mathematics.Vector3D();
rot.x = 0.1;
this.actor.rotate(rot);
if(this.actor.length>=100)
{
this.actor.length = this.actor.length-10;
}
    
};
CubeTriggerZoneActor.prototype.onActivate = function () {
STU.Actor3D.prototype.onActivate.call(this);

this.associatedTask = new CubeTriggerZoneActorTask(this);
EP.TaskPlayer.addTask(this.associatedTask);
};
CubeTriggerZoneActor.prototype.onDeactivate = function () {    
EP.TaskPlayer.removeTask(this.associatedTask);
delete this.associatedTask;

STU.Actor3D.prototype.onDeactivate.call(this);
};*/



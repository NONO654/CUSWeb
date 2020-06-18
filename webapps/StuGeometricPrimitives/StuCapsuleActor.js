
define('DS/StuGeometricPrimitives/StuCapsuleActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
* Describe a capsule object.
*
* @exports CapsuleActor
* @class
* @constructor
* @noinstancector
* @public
* @extends STU.PrimitiveActor
* @memberof STU
* @alias STU.CapsuleActor
*/
var CapsuleActor = function () {

 PrimitiveActor.call(this);
 this.name = 'CapsuleActor';


    /**
    * Get/Set capsule height
    *
    * @member
    * @instance
    * @name height
    * @public
    * @type {number}
    * @memberOf STU.CapsuleActor
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
    * Get/Set capsule radius
    *
    * @member
    * @instance
    * @name radius
    * @public
    * @type {number}
    * @memberOf STU.CapsuleActor
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

CapsuleActor.prototype = new PrimitiveActor();
CapsuleActor.prototype.constructor = CapsuleActor;


// Expose in STU namespace.
STU.CapsuleActor = CapsuleActor;

return CapsuleActor;
});

define('StuGeometricPrimitives/StuCapsuleActor', ['DS/StuGeometricPrimitives/StuCapsuleActor'], function (CapsuleActor) {
    'use strict';

    return CapsuleActor;
});

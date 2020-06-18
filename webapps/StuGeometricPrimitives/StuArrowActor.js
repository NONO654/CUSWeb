
define('DS/StuGeometricPrimitives/StuArrowActor', ['DS/StuCore/StuContext', 'DS/StuGeometricPrimitives/StuPrimitiveActor'], function (STU, PrimitiveActor) {
    'use strict';

    /**
* Describe an arrow object.
*
* @exports ArrowActor
* @class
* @constructor
* @noinstancector
* @public
* @extends STU.PrimitiveActor
* @memberof STU
* @alias STU.ArrowActor
*/
    var ArrowActor = function () {

        PrimitiveActor.call(this);
        this.name = 'ArrowActor';

        /**
        * Get/Set arrow length
        *
        * @member
        * @instance
        * @name length
        * @public
        * @type {number}
        * @memberOf STU.ArrowActor
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
        * Get/Set arrow width
        *
        * @member
        * @instance
        * @name width
        * @public
        * @type {number}
        * @memberOf STU.ArrowActor
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

        /**
        * Get/Set arrow head length
        *
        * @member
        * @instance
        * @name headLength
        * @public
        * @type {number}
        * @memberOf STU.ArrowActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'headLength', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('headLength');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('headLength', value);
        			}
        		}
        	});
        }
        else {
        	this.headLength;
        }

        /**
        * Get/Set arrow head width
        *
        * @member
        * @instance
        * @name headWidth
        * @public
        * @type {number}
        * @memberOf STU.ArrowActor
        */
        if (!STU.isEKIntegrationActive()) {
        	Object.defineProperty(this, 'headWidth', {
        		enumerable: true,
        		configurable: true,
        		get: function () {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				return this.CATI3DExperienceObject.GetValueByName('headWidth');
        			}
        		},
        		set: function (value) {
        			if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
        				this.CATI3DExperienceObject.SetValueByName('headWidth', value);
        			}
        		}
        	});
        }
        else {
        	this.headWidth;
        }

    };


    ArrowActor.prototype = new PrimitiveActor();
    ArrowActor.prototype.constructor = ArrowActor;


    // Expose in STU namespace.
    STU.ArrowActor = ArrowActor;

    return ArrowActor;
});

define('StuGeometricPrimitives/StuArrowActor', ['DS/StuGeometricPrimitives/StuArrowActor'], function (ArrowActor) {
    'use strict';

    return ArrowActor;
});

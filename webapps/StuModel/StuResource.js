
define('DS/StuModel/StuResource', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
     * Describes the base object for all resources.
     * A resource is generally an object that is not active in the experience, but that is used 
     * by actors or behaviors (image, sound, material, ...).
     * 
	 * @exports Resource
	 * @class
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends STU.Instance
	 * @memberof STU
	 * @alias STU.Resource
	 */
    var Resource = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "Resource";
    };

    Resource.prototype = new Instance();
    Resource.prototype.constructor = Resource;

    /**
    * Return the experience
    * @method
    * @public
    * @return {STU.Experience} instance object corresponding to the experience
    */
    Resource.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    
    
    // Expose in STU namespace.
    STU.Resource = Resource;

    return Resource;
});

define('StuModel/StuResource', ['DS/StuModel/StuResource'], function (Resource) {
    'use strict';

    return Resource;
});

define('DS/StuSound/StuSoundResource', ['DS/StuCore/StuContext', 'DS/StuModel/StuResource'], function (STU, Resource) {
	'use strict';

    /**
     * Describes the Sound resource object.
     * 
     * @exports SoundResource
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Resource
     * @memberOf STU
	 * @alias STU.SoundResource
     */
	var SoundResource = function () {

	    Resource.call(this);
		this.name = "SoundResource";
	};

	SoundResource.prototype = new Resource();
	SoundResource.prototype.constructor = SoundResource;

	// Expose in STU namespace.
	STU.SoundResource = SoundResource;

	return SoundResource;
});

define('StuSound/StuSoundResource', ['DS/StuSound/StuSoundResource'], function (SoundResource) {
    'use strict';

    return SoundResource;
});

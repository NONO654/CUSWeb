
define('DS/StuRenderEngine/StuMaterialApplication', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describe an Object representing a material application on an actor.
	 *
	 * @exports MaterialApplication
	 * @class
	 * @constructor
	 * @private
	 * @memberof STU
	 */
	var MaterialApplication = function () {
	    this.name = 'MaterialApplication';


	    /**
		 * native object CATICXPMaterialApplication
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
	    this.CATICXPMaterialApplication = null; // ca c'est valué par CATECXPMaterialApplication_StuIBuilder::Build
	};

	MaterialApplication.prototype.constructor = MaterialApplication;



	// Expose in STU namespace.
	STU.MaterialApplication = MaterialApplication;

	return MaterialApplication;
});

define('StuRenderEngine/StuMaterialApplication', ['DS/StuRenderEngine/StuMaterialApplication'], function (MaterialApplication) {
    'use strict';

    return MaterialApplication;
});

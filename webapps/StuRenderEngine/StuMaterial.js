
define('DS/StuRenderEngine/StuMaterial', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describe an Object representing a material
	 *
	 * @exports Material
	 * @class
	 * @constructor
     * @noinstancector
	 * @public
	 * @memberof STU
     * @alias STU.Material
	 */
	var Material = function () {
	    this.name = 'Material';

	    /**
		 * native object CATICXPMaterial
		 *
		 * @member
		 * @private
		 * @type {Object}
		 */
	    this.CATICXPMaterial = null; // ca c'est valué par CATECXPMaterial_StuIBuilder::Build
	};

	Material.prototype.constructor = Material;

	/**
	 * Return true if this material is applied to the actor
	 * @param  {STU.Actor3D}  iActor3D
	 * @return {Boolean}
	 * @private
	 */
	Material.prototype.isAppliedTo = function (iActor3D) {
		return this == iActor3D.getMaterial();
	}

	/**
	 * Apply this material to the actor
	 * @param  {STU.Actor3D}  iActor3D
	 * @return {Boolean}
	 * @private
	 */
	Material.prototype.appliesTo = function (iActor3D) {
		iActor3D.setMaterial(this);
	}

	// Expose in STU namespace.
	STU.Material = Material;

	return Material;
});

define('StuRenderEngine/StuMaterial', ['DS/StuRenderEngine/StuMaterial'], function (Material) {
    'use strict';

    return Material;
});

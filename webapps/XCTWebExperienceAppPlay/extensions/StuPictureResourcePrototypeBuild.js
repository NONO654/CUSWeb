/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuPictureResourcePrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuPictureResourcePrototypeBuild',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATICXPPictureResource'
],

// Declaration
function (
	UWA,
    StuEExperienceBasePrototypeBuild,
	StuCATICXPPictureResource
	) {
    'use strict';

    /**
	 * StuPictureResourcePrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuPictureResourcePrototypeBuild
	 * @constructor
	 */

    var StuPictureResourcePrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuPictureResourcePrototypeBuild.prototype **/
	{

	    _Fill: function (iPictureResource) {
	        iPictureResource.CATICXPPictureResource = new StuCATICXPPictureResource(this.GetObject(), iPictureResource);
	        return this._parent(PictureResource);
	    },
	});

    return StuPictureResourcePrototypeBuild;
});


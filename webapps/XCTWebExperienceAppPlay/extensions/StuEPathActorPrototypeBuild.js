/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEPathActorPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuEPathActorPrototypeBuild',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/extensions/StuE3DActorPrototypeBuild',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuVIAIIxpVirtualPath'
],

// Declaration
function (
	UWA,
	StuE3DActorPrototypeBuild,
    StuVIAIIxpVirtualPath
	) {
    'use strict';

    /**
	 * StuEPathActorPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEPathActorPrototypeBuild
	 * @constructor
	 */

    var StuEPathActorPrototypeBuild = StuE3DActorPrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuEPathActorPrototypeBuild.prototype **/
	{

	    _Fill: function (iPathActor) {
	        iPathActor.VIAIIxpVirtualPath = new StuVIAIIxpVirtualPath(this.GetObject(), iPathActor);
	        return this._parent(iPathActor);
	    },
	});

    return StuEPathActorPrototypeBuild;
});

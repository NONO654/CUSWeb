/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEVector3DPrototypeBuild
*/ 
define('DS/XCTWebExperienceAppPlay/extensions/StuEVector3DPrototypeBuild',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
	'MathematicsES/MathsDef'
],

// Declaration
function (
    UWA,
    StuEExperienceBasePrototypeBuild,
	DSMath
    ) {
	'use strict';

    /**
	 * StuEVector3DPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEVector3DPrototypeBuild
	 * @constructor
	 */

	var StuEVector3DPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
    /** @lends DS/XCTWebExperienceAppPlay/extensions/StuEVector3DPrototypeBuild.prototype **/
    {
		_Create: function () {
			var vector = new DSMath.Vector3D();
			this._instance = vector;
			return this._Fill(vector).done(function () {
				return vector;
			});
		},

	});

	return StuEVector3DPrototypeBuild;
});



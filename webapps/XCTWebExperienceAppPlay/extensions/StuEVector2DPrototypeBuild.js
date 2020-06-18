 /**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEVector2DPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuEVector2DPrototypeBuild',
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
	 * StuEVector2DPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEVector2DPrototypeBuild
	 * @constructor
	 */

	var StuEVector2DPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
    /** @lends DS/XCTWebExperienceAppPlay/extensions/StuEVector2DPrototypeBuild.prototype **/
    {
		_Create: function () {
			var vector = new DSMath.Vector2D();
			this._instance = vector;
			return this._Fill(vector).done(function () {
				return vector;
			});
		},

	});

	return StuEVector2DPrototypeBuild;
});



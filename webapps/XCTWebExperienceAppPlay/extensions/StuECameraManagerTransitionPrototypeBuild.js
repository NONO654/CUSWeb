/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerTransitionPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerTransitionPrototypeBuild',
[
	'UWA/Core',
	'DS/StuCore/StuContext',
    'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
	'DS/StuCameras/StuCameraManager'
],

// Declaration
function (
    UWA,
	STU,
    StuEExperienceBasePrototypeBuild
    ) {
	'use strict';

    /**
	 * StuECameraManagerTransitionPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerTransitionPrototypeBuild
	 * @constructor
	 */

	var StuECameraManagerTransitionPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
    /** @lends DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerTransitionPrototypeBuild.prototype **/
    {
		_Create: function () {
			var transition = new STU.CameraManagerTransition();
			this._instance = transition;
			return this._Fill(transition).done(function () {
				return transition;
			});
		},

	});

	return StuECameraManagerTransitionPrototypeBuild;
});

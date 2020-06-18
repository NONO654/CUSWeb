/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerSequencePrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerSequencePrototypeBuild',
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
	 * StuECameraManagerSequencePrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerSequencePrototypeBuild
	 * @constructor
	 */

	var StuECameraManagerSequencePrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
    /** @lends DS/XCTWebExperienceAppPlay/extensions/StuECameraManagerSequencePrototypeBuild.prototype **/
    {
		_Create: function () {
			var sequence = new STU.CameraManagerSequence();
			this._instance = sequence;
			return this._Fill(sequence).done(function () {
				return sequence;
			});
		},

	});

	return StuECameraManagerSequencePrototypeBuild;
});

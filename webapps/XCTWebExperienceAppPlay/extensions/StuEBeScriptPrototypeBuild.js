/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEBeScriptPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/extensions/StuEBeScriptPrototypeBuild',
[
	'UWA/Core',
	'DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild'
],

// Declaration
function (
	UWA,
	StuEExperienceBasePrototypeBuild
	) {
	'use strict';

	/**
	 * StuEBeScriptPrototypeBuild
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEBeScriptPrototypeBuild
	 * @constructor
	 */

	var StuEBeScriptPrototypeBuild = StuEExperienceBasePrototypeBuild.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuEBeScriptPrototypeBuild.prototype **/
	{
		_Fill: function (iScript) {
			var self = this;
			return this._parent(iScript).done(function () {
				if (UWA.is(self._instance.scriptinstance)) {
					self._instance.updateCode();
				}
				iScript.__proto__['name'] = self.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName');
				//self._DefineProperty(self.QueryInterface('CATI3DExperienceObject'), iScript.__proto__, '_varName', 'name');
			});
		},
	});

	return StuEBeScriptPrototypeBuild;
});

/* global define */
define('DS/XCTWebExperienceAppPlay/StuUIActor', ['DS/StuCID/StuUIActor', 'DS/XCTWebExperienceAppPlay/StuUIBinder'], function (UIActor, UIBinder) {
	'use strict';

	UIActor.prototype.getUIBinder = function () {
		return new UIBinder();
	};

	UIActor.prototype.getCtl = function () {
		return {
			Data: this.data
		};
	};

	UIActor.prototype.__parseProperties = function (iObject, iData) {
		for (var propertyName in iData) {
		    if (iData.hasOwnProperty(propertyName) && !UWA.is(iObject[propertyName])){
				(function (iObject, iPropertyName) {
					Object.defineProperty(iObject, iPropertyName, {
						enumerable: true,
						configurable: true,
						get: function () {
						    return iData.CATI3DExperienceObject.GetValueByName(iPropertyName);
						},
						set: function (value) {
						    iData.CATI3DExperienceObject.SetValueByName(iPropertyName, value);
						}
					});
				})(iObject, propertyName);
			}
		}
	};

	return UIActor;
});

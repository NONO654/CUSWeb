/**
 * @exports DS/XCTWebExperienceAppPlay/CXPWebAppPlayModelExtension
*/
define('DS/XCTWebExperienceAppPlay/CXPWebAppPlayModelExtension',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModelExtensionImpl',
	'DS/CAT3DExpModel/CAT3DXModel',

	'text!DS/XCTWebExperienceAppPlay/assets/CXPWebAppPlayInterfaces.json',
	'text!DS/XCTWebExperienceAppPlay/assets/CXPWebAppPlayExtensions.json',
    'text!DS/XCTWebExperienceAppPlay/assets/CXPWebAppPlayManagers.json'
],

// Declaration
function (
	UWA,
	CAT3DXModelExtensionImpl,
	CAT3DXModel,

	CXPWebAppPlayInterfaces,
	CXPWebAppPlayExtensions,
    CXPWebAppPlayManagers
	//CXPWebAppPlayPrototypeBuild
	) {
	'use strict';

	var CXPWebAppPlayModelExtension = CAT3DXModelExtensionImpl.extend(
	/** @lends DS/XCTWebExperienceAppPlay/CXPWebAppPlayModelExtension.prototype **/
	{
	    /**
        * @public
        */
		GetInterfaces: function () {
		    return [JSON.parse(CXPWebAppPlayInterfaces)];
		},

	    /**
        * @public
        */
		GetExtensions: function () {
		    return [JSON.parse(CXPWebAppPlayExtensions)];
		},

	    /**
        * @public
        */
		GetManagers: function () {
		    return [JSON.parse(CXPWebAppPlayManagers)];
		}
	});

	return CXPWebAppPlayModelExtension;
}
);


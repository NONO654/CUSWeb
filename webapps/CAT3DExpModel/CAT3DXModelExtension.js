/**
 * @exports DS/CAT3DExpModel/CAT3DXModelExtension
*/
define('DS/CAT3DExpModel/CAT3DXModelExtension',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModelExtensionImpl',

	'text!DS/CAT3DExpModel/assets/CAT3DExpModelInterfaces.json',
    'text!DS/CAT3DExpModel/assets/CAT3DExpManagers.json'
],

// Declaration
function (
	UWA,
	CAT3DXModelExtensionImpl,

	CAT3DExpModelInterfaces,
    CAT3DExpManagers
	) {
	'use strict';


	/**
	* @name DS/CAT3DExpModel/CAT3DXModelExtension
	* @description 
	* 1st level of Extension to load CXP Model
	* @constructor
	* @augments DS/CAT3DExpModel/CAT3DXModelExtensionImpl
	*/

	var CAT3DXModelExtension = CAT3DXModelExtensionImpl.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXModelExtension.prototype **/
	{
		GetInterfaces: function () {
		    return [JSON.parse(CAT3DExpModelInterfaces)];
		},

		GetManagers: function () {
		    return [JSON.parse(CAT3DExpManagers)];
		}
	});

	return CAT3DXModelExtension;
}
);


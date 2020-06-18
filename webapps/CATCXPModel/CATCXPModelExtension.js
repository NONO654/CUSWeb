/**
 * @exports DS/CXPApp/CXPModelExtension
*/
define('DS/CATCXPModel/CATCXPModelExtension',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModelExtensionImpl',

    'text!DS/CATCXPModel/assets/CATCXPModel.json',
	'text!DS/CATCXPModel/assets/CATCXPModelAddIn.json',
	'text!DS/CATCXPModel/assets/CATCXPModelInterfaces.json',
	'text!DS/CATCXPModel/assets/CATCXPModelExtensions.json',
	'text!DS/CATCXPLightModel/assets/CATCXPLightModelExtensions.json',
	'text!DS/CATCXPLightModel/assets/CATCXPLightModelInterfaces.json'
],

// Declaration
function (
	UWA,
	CAT3DXModelExtensionImpl,

    CATCXPModel,
    CATCXPModelAddIn,
    CATCXPModelInterfaces,
    CATCXPModelExtensions,
    CATCXPLightModelExtensions,
    CATCXPLightModelInterfaces
	) {
    'use strict';

    var CATCXPModelExtension = CAT3DXModelExtensionImpl.extend(
	/** @lends DS/CXPApp/CXPAppModelExtension.prototype **/
	{
	    /**
        * @public
        */
	    GetInterfaces: function () {
	        return [JSON.parse(CATCXPModelInterfaces), JSON.parse(CATCXPLightModelInterfaces)];
	    },

	    /**
        * @public
        */
	    GetExtensions: function () {
	        return [JSON.parse(CATCXPModelExtensions), JSON.parse(CATCXPLightModelExtensions)];
	    },

	    /**
        * @public
        */
	    GetComponents: function () {
	        return [JSON.parse(CATCXPModel), JSON.parse(CATCXPModelAddIn)];
	    }

	});

    return CATCXPModelExtension;
}
);


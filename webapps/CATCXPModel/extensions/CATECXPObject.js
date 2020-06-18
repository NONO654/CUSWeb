/**
 * CATECXPObject
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPObject
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPObject CATICXPObject}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPObject',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

// Declaration
function (
    UWA, CAT3DXInterfaceImpl
    ) {
    'use strict';

    var CATECXPObject = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPObject.prototype **/
    {
    	init: function () {
    		this._parent();
    	},

		destroy: function () {
			this._parent();
		},
        // interface CATICXPObject
        /**  
        * @public
        */
	    GetRootFather: function () {
	    	console.log('CATECXPObject.GetRootFather WARNING : not Implemented yet!');
	        return undefined;
	    },

        /**  
        * @public
        */
	    GetFatherObject: function () {        
	        return this.GetObject()._parent;
	    }
	});

    return CATECXPObject;
}
);


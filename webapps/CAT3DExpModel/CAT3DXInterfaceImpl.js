/**
 * @exports DS/CAT3DExpModel/CAT3DXInterfaceImpl
*/
define('DS/CAT3DExpModel/CAT3DXInterfaceImpl',
[
	'UWA/Core'
],

// Declaration
function (
    UWA
    ) {
	'use strict';


	/**
	* @name DS/CAT3DExpModel/CAT3DXInterfaceImpl
	* @description 
	* Base Class of interface implementation for the Web Object Modeler.
	* @constructor
	*/

	var CAT3DXInterfaceImpl = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXInterfaceImpl.prototype **/
    {
        /**  
        * @public
        */
        init: function () {
        },

        /**  
        * @public
        */
        destroy: function () {
            //console.log('destroy Interface');
        }
    });

	return CAT3DXInterfaceImpl;
}
);


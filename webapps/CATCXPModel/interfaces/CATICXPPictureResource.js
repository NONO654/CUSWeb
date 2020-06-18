/**
 * @exports DS/CATCXPModel/interfaces/CATICXPPictureResource
*/
define('DS/CATCXPModel/interfaces/CATICXPPictureResource',
// dependencies
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface) {
	'use strict';

	/**
    * @category Interface
	* @name DS/CATCXPModel/interfaces/CATICXPPictureResource
    * @interface
	* @description 
    * Interface to manage resources on the component.
	*/

	var CATICXPPictureResource = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPPictureResource.prototype **/
    {

    	interfaceName: 'CATICXPPictureResource',

    	/**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPPictureResource.prototype
        */
    	required: {

    		GetPictureSizeInPixel: function () {
    		}
    	},

    	optional: {
    	}
    });

	return CATICXPPictureResource;
});

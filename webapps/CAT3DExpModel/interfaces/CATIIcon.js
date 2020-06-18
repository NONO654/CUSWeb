/**
 * @exports DS/CAT3DExpModel/interfaces/CATIIcon
*/
define('DS/CAT3DExpModel/interfaces/CATIIcon',
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
	* @name DS/CAT3DExpModel/interfaces/CATIIcon
    * @interface
	* @description 
    * Interface to get/set component icon on user interface.
	*/

    var CATIIcon = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATIIcon.prototype **/
    {

        interfaceName: 'CATIIcon',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATIIcon.prototype
        */
        required: {

            /**
            * Get image name
            * @public
            * @returns {String} image name
            */
            GetIconName: function () {
                return undefined;
            },

            /**
            * Set image name
            * @public
            * @param {String} iName - the image name
            */
            SetIconName: function (iName) {
                console.log("interface using these variables : " + iName);
            }
        },

        optional: {

        }
    });

    return CATIIcon;
});


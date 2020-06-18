/**
 * @exports DS/CAT3DExpModel/interfaces/CATIAlias
*/
define('DS/CAT3DExpModel/interfaces/CATIAlias',
// dependencies
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface)
{
    'use strict';

    /**
    * @category Interface
	* @name DS/CAT3DExpModel/interfaces/CATIAlias
    * @interface
	* @description 
    * Interface to manage the component name.
	*/

    var CATIAlias = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATIAlias.prototype **/
    {

        	interfaceName: 'CATIAlias',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATIAlias.prototype
        */
        	required: {
        	/**
            * Get component name
            * @public
            * @returns {String} component name
            */
        	GetAlias: function () {
        	    return undefined;
        	},

            /**
            * Set component name
            * @public
            * @param {String} iName - the name to set
            */
        	SetAlias: function (iName) {
        	    console.log("interface using these variables : " + iName);
        	}
        },

        optional: {

        }
    });

    return CATIAlias;
});

/**
 * @exports DS/CATCXPModel/interfaces/CATICXPEnvironment
*/
define('DS/CATCXPModel/interfaces/CATICXPEnvironment',
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
	* @name DS/CATCXPModel/interfaces/CATICXPEnvironment
    * @interface
	* @description 
    * Interface to manage the activation and deactivation of an environment
	*/

	var CATICXPEnvironment = CATWebInterface.singleton(
	/** @lends  DS/CATCXPModel/interfaces/CATICXPEnvironment.prototype **/
    {
    	interfaceName: 'CATICXPEnvironment',

    	/**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPEnvironment.prototype
        */
    	required: {

    		/**
            * Activate environment
            * @public
            */
    		Activate: function () {
    		},

    		/**
            * Deactivate environment
            * @public
            */
    		Deactivate: function () {
    		}
    	},

    	optional: {

    	}
    });

	return CATICXPEnvironment;
});

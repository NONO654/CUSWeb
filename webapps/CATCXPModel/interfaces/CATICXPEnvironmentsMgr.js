/**
 * @exports DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr',
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
	* @name DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr
    * @interface
	* @description 
    * Interface to manage environments of the component.
	*/

	var CATICXPEnvironmentsMgr = CATWebInterface.singleton(
	/** @lends  DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr.prototype **/
    {
    	interfaceName: 'CATICXPEnvironmentsMgr',

    	/**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr.prototype
        */
    	required: {

    		/**
			* Add environment
			* @public
			* @param {Object} environment - the environment to add
			*/
    		AddEnvironment: function (ihNewEnv) {
    		},

    		/**
			* Remove environment
			* @public
			* @param {Object} environment - the environment to remove
			*/
    		RemoveEnvironment: function (ihEnv) {
    		},

    		/**
			* List environments
			* @public
			* @param {Object[]} environments - environments array
			*/
    		ListEnvironments: function (ohEnvs) {
    		},

    		/**
            * Set current environment.
            * @public
            * @param {Object} environment - environment to activate at the start (play)
            */
    		SetCurrentEnvironment: function (ihEnv) {
    		},

    		/**
            * Get the current environment.
            * @public
            * @returns {Object} environment - startup environment (play)
            */
    		GetCurrentEnvironment: function () {
    		},

    		/**
            * Set the active environment.
            * @public
            * @param {Object} environment - environment to activate
            */
    		SetActiveEnvironment: function (ihEnv) {
    		},

    		/**
            * Get the active environment.
            * @public
            * @returns {Object} environment - active environment
            */
    		GetActiveEnvironment: function () {
    		},

    		/**
			* Create an environment from asset and add it.
			* @public
			* @param {String} iName - the environment name
			* @param {String} iAsset - environment asset
			*/
    		CreateAndAddEnvironmentFromAsset: function (iName, iAsset) {
    		}
    	},

    	optional: {

    	}
    });

	return CATICXPEnvironmentsMgr;
});

/**
 * @exports DS/CATCXPModel/interfaces/CATICXPResourcesMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPResourcesMgr',
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
	* @name DS/CATCXPModel/interfaces/CATICXPResourcesMgr
    * @interface
	* @description 
    * Interface to manage resources on the component.
	*/

    var CATICXPResourcesMgr = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPResourcesMgr.prototype **/
    {

    	    interfaceName: 'CATICXPResourcesMgr',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPResourcesMgr.prototype
        */
    	    required: {
    	        /**
            * Create and add a resource to the component.
            * @public
            * @param {String} resource name - name of the resource
            * @param {String} resource name - name of the resource
            * @returns {Object} created resource
            */
    		    CreateAndAddResourceFromAsset: function (iResourceName, iResourceInfo) {
    		    },

    	        /**
            * Add a resource to the component
            * @public
            * @param {Object} resource - the resource to add
            */
    		    AddResource: function (iResource) {
    		    },

    	        /**
            * Remove a resource from the component
            * @public
            * @param {Object} resource - the resource to remove
            */
    		    RemoveResource: function (iResource) {
    		    },

    	        /**
            * List resources
            * @public
            * @returns {Object[]} resources hold on the component
            */
    		    ListResources: function () {
    		    },

    	        /**
            * Get count of resources hold by the component
            * @public
            * @returns {Int} number of resources
            */
    		    Count: function () {
    		    },

    	        /**
            * Get a resource according to its name
            * @public
            * @param {String} resource name - the resource name
            */
    		    GetResource: function (iResourceName) {
    		    }
        },

        optional: {
        }
    });

    return CATICXPResourcesMgr;
});

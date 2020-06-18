/**
 * @exports DS/CATCXPModel/interfaces/CATICXPScenesMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPScenesMgr',
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
	* @name DS/CATCXPModel/interfaces/CATICXPScenesMgr
    * @interface
	* @description 
    * Interface to manage scenes on the component.
	*/

    var CATICXPScenesMgr = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPScenesMgr.prototype **/
    {

        	interfaceName: 'CATICXPScenesMgr',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPScenesMgr.prototype
        */
        	required: {

        	    /**
            * Create a Scene and attach to component.
            * @public
            * @param {String} name - the scene name
            * @returns {Object} the created scene
            */
        	    CreateAndAddScene: function (iSceneName) {
        	    },

        	    /**
            * Add a scene to the component
            * @public
            * @param {Object} scene - the scene to add
            */
        	    AddScene: function (iScene) {
        	    },

        	    /**
            * Remove a scene from the component
            * @public
            * @param {Object} scene - the scene to remove
            */
        	    RemoveScene: function (iScene) {
        	    },

        	    /**
            * List scenes
            * @public
            * @returns {Object[]} scenes attached to the component
            */
        	    ListScenes: function () {
        	    }

        },

        optional: {

        }
    });

    return CATICXPScenesMgr;
});

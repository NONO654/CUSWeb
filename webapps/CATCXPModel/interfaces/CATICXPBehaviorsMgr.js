/**
 * @exports DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr',
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
	* @name DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr
    * @interface
	* @description 
    * Interface to manage behaviors attached to the component.
	*/

    var CATICXPBehaviorsMgr = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr.prototype **/
    {

        interfaceName: 'CATICXPBehaviorsMgr',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr.prototype
        */
        required: {

            /**
            * List behaviors
            * @public
            * @param {Object[]} behaviors - component behaviors
            */
            ListBehaviors : function(oBehaviorsList) {
            },

            /**
            * Remove a sub behavior
            * @public
            * @param {Object} behavior - the behavior to detach
            */
            RemoveBehavior : function(iBehavior){
            },

            /**
            * Attach a behavior to the component
            * @public
            * @param {Object} behavior - the behavior to attach
            */
            AddBehavior:function(iBehavior){
            },

            CreateAndAddBehavior: function (iBehaviorName, iProto) {
            }
        },

        optional: {

        }
    });

    return CATICXPBehaviorsMgr;
});

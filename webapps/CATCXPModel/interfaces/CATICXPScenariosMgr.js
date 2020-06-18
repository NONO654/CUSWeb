/**
 * @exports DS/CATCXPModel/interfaces/CATICXPScenariosMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPScenariosMgr',
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
	* @name DS/CATCXPModel/interfaces/CATICXPScenariosMgr
    * @interface
	* @description 
    * Interface to manage scenarios on the component.
	*/

    var CATICXPScenariosMgr = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPScenariosMgr.prototype **/
    {

        interfaceName: 'CATICXPScenariosMgr',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPScenariosMgr.prototype
        */
        required: {
            /**
            * Create a Scenario and attach to component.
            * @public
            * @param {String} scenario name - the scenario name
            * @returns {Object} created scenario object
            */
            CreateAndAddScenario : function(iScenarioName){
            },

            /**
            * Add a scenario to the component
            * @public
            * @param {Object} scenario - the scenario to add
            */
            AddScenario : function(iScenario){
            },

            /**
            * Remove a scenario from the component
            * @public
            * @param {Object} scenario - the scenario to remove
            */
            RemoveScenario : function(iScenario){
            },

            /**
            * List scenarios
            * @public
            * @returns {Object[]} scenarios
            */
            ListScenarios : function (){
            },

            /**
            * Set scenario as the experience startup scenario.
            * @public
            * @param {Object} Scenario - scenario to set as startup
            */
            SetStartupScenario : function (iScenario){
            },

            /**
            * Get the experience startup scenario.
            * @public
            * @returns {Object} startup scenario component
            */
            GetStartupScenario : function (){
            },

            /**
            * Is it the startup scenario ?
            * @public
            * @param {Object} Scenario - scenario to test
            * @returns {boolean} true if startup scenario, false otherwise
            */
            IsStartupScenario : function(iScenario){
            }
        },

        optional: {

        }
    });

    return CATICXPScenariosMgr;
});

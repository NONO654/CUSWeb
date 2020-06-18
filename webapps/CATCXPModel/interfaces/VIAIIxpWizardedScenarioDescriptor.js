/**
 * @exports DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor
*/
define('DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor',
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
	* @name DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor
    * @interface
	* @description 
    * Interface to manage acts.
	*/

    var VIAIIxpWizardedScenarioDescriptor = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor.prototype **/
    {

    	interfaceName: 'VIAIIxpWizardedScenarioDescriptor',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor.prototype
        */
        required: {

        	/**
            * Clear all acts on the component
            * @public
            */
        	Clear: function () {
        	},


        	/**
            * Create a new act and add it to the component
            * @public
            * @param {String} act name - act name
            * @returns {Object} created act
            */
        	NewAct: function (iActName) {
        	},

        	/**
            * Add the given act to the scenario.
            * @public
            * @param {Object} act - Act component to add
            */
        	AddAct: function (iAct) {
        	},

        	/**
            * Remove the given act from the scenario.
            * @public
            * @param {Object} act - Act component to remove
            */
        	RemoveAct: function (iAct) {
        	},

        	/**
            * Get acts
            * @public
            * @returns {Object[]} acts
            */
        	GetActs: function () {
        	},


        	/**
            * Return acts count.
            * @public
            * @returns {Int} acts count
            */
        	GetActCount: function () {
        	},

        	/**
            * Get the experience startup act.
            * @public
            * @returns {Object} startup act component
            */
        	GetStartupAct: function () {
        	},

        	/**
            * Set startup act.
            * @public
            * @param {Object} Act - act to set as startup
            */
        	SetStartupAct: function (iAct) {
        	},

        	GetActByIndex: function (iIndex) {
        	},
        	GetActIndex: function (iAct) {
        	},
        	MoveActToPosition: function (iAct, iPos) {
        	},
        	MoveActBeforeOtherAct: function (iAct, iOtherAct) {
        	},
        	MoveActAfterOtherAct: function (iAct, iOtherAct) {
        	},
        	MoveUpAct: function (iAct) {
        	},
        	MoveDownAct: function (iAct) {
        	}

        },

        optional: {
        }
    });

    return VIAIIxpWizardedScenarioDescriptor;
});

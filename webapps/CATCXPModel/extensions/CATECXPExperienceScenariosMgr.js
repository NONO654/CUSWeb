/**
 * CATECXPExperienceScenariosMgr
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPExperienceScenariosMgr
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPScenariosMgr CATICXPScenariosMgr}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPExperienceScenariosMgr',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModel',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

// Declaration
function (
	UWA, CAT3DXModel, CAT3DXInterfaceImpl
	) {
	'use strict';

	var CATECXPExperienceScenariosMgr = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPExperienceScenariosMgr.prototype **/
	{
		init: function () {
			this._parent();
		},

		destroy: function () {
			this._parent();
		},

		// --- Interface CATICXPScenariosMgr
		/**  
		* @public
		*/
		CreateAndAddScenario: function (iScenarioName) {
			return CAT3DXModel.CreateScenario(iScenarioName).done(function (iScenario) {
			    return UWA.Promise.resolve(iScenario);
			});
		},

		/**  
		* @public
		*/
		AddScenario: function (iScenario) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var scenarios = experienceObject.GetValueByName('scenarios');
			var idx = scenarios.indexOf(iScenario);

			if (idx < 0) {
				scenarios.push(iScenario);
				experienceObject.SetValueByName('scenarios', scenarios);
			}
		},

		/**  
		* @public
		*/
		RemoveScenario: function (iScenario) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var scenarios = experienceObject.GetValueByName('scenarios');
			var idx = scenarios.indexOf(iScenario);

			if (idx >= 0) {
				scenarios.splice(idx, 1);
				experienceObject.SetValueByName('scenarios', scenarios);
			}
		},

		/**  
		* @public
		*/
		ListScenarios: function () {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			return experienceObject.GetValueByName('scenarios');
		},

		/**  
		* @public
		*/
		SetStartupScenario: function (iScenario) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var playSettings = experienceObject.GetValueByName('PlaySettings');
			if ((playSettings) && (playSettings.QueryInterface('CATI3DExperienceObject'))) {
				playSettings.QueryInterface('CATI3DExperienceObject').SetValueByName('startupScenario', iScenario);
			}
		},

		/**  
		* @public
		*/
		GetStartupScenario: function () {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var playSettings = experienceObject.GetValueByName('PlaySettings');
			if ((playSettings) && (playSettings.QueryInterface('CATI3DExperienceObject'))) {
				return playSettings.QueryInterface('CATI3DExperienceObject').GetValueByName('startupScenario');
			}
			return undefined;
		},

		/**  
		* @public
		*/
		IsStartupScenario: function (iScenario) {
			if (this.GetStartupScenario() === iScenario) {
				return true;
			}
			return false;
		}
	});

	return CATECXPExperienceScenariosMgr;
});

/**
 * VIAEIxpWizardedScenarioDescriptor
 * @category Extension
 * @name DS/CATCXPModel/extensions/VIAEIxpWizardedScenarioDescriptor
 * @description Implements {@link DS/CATCXPModel/interfaces/VIAIIxpWizardedScenarioDescriptor VIAIIxpWizardedScenarioDescriptor}
 * @constructor
 */
define('DS/CATCXPModel/extensions/VIAEIxpWizardedScenarioDescriptor',
[
	'UWA/Core',
	'MathematicsES/MathsDef',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'DS/CAT3DExpModel/CAT3DXModel',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],

// Declaration
function (
    UWA,
	DSMath,
	CAT3DXInterfaceImpl,
	CAT3DXModel,
    Events,
    Listener
    ) {
    'use strict';

    var VIAEIxpWizardedScenarioDescriptor = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
	/** @lends DS/CATCXPModel/extensions/VIAEIxpWizardedScenarioDescriptor.prototype **/
    {
    	init: function () {
    		this._parent();
		},

    	destroy: function () {
    		this._parent();
    		this.stopListening();
    	},


		Build: function () {
			var self = this;
			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'acts.CHANGED', function (iActs) {
				self.dispatchEvent('ACTS.CHANGED', [iActs]);
			});
			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'startupAct.CHANGED', function (iStartupAct) {
				self.dispatchEvent('STARTUPACT.CHANGED', [iStartupAct]);
			});
		},

    	// --- Interface VIAIIxpWizardedScenarioDescriptor
        /**  
        * @public
        */
		Clear: function () {
		    var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
		    scenarioExpObj.SetValueByName('acts', []);
		},

        /**  
        * @public
        */
		NewAct: function (iActName) {
		    return CAT3DXModel.CreateAct(iActName, this.GetObject());
		},

        /**  
        * @public
        */
		AddAct: function (iAct) {
		    var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
		    if (!UWA.is(scenarioExpObj)) {
		        UWA.log('ERROR on AddAct, unable to retrieve CATI3DExperienceObject !');
		        return;
		    }
		    var acts = scenarioExpObj.GetValueByName('acts');
		    acts.push(iAct);
		    scenarioExpObj.SetValueByName('acts', acts);
		    if (acts.length === 1) {
		        this.SetStartupAct(iAct);
		    }
		},

        /**  
        * @public
        */
		RemoveAct: function (iAct) {
		    if (!UWA.is(iAct)) {
		        UWA.log('ERROR RemoveAct : invalid parameter !');
		        return;
		    }
		    var acts = this.GetActs();
		    var idx = acts.indexOf(iAct);
		    if (idx >= 0) {
		    	acts.splice(idx, 1);
		    	var experienceObject = this.QueryInterface('CATI3DExperienceObject');
		    	experienceObject.SetValueByName('acts', acts);
		    	if (this.GetStartupAct() === iAct) {
		    		if (acts.length > 0) {
		    			this.SetStartupAct(acts[0]);
		    		}
		    		else {
		    			this.SetStartupAct(undefined);
		    		}
		    	}
		    }
		    else {
		    	var actExpObj = iAct.QueryInterface('CATI3DExperienceObject');
		    	var actName = actExpObj.GetValueByName('_varName');
		    	UWA.log('ERROR RemoveAct : unable to find act named : ' + actName);
		    }
		},

        /**  
        * @public
        */
		GetActs: function () {
		    var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
		    if (!UWA.is(scenarioExpObj)) {
		        UWA.log('ERROR on GetActs, unable to retrieve CATI3DExperienceObject !');
		        return undefined;
		    }
		    var acts = scenarioExpObj.GetValueByName('acts');
		    if (!UWA.is(acts)) {
		        UWA.log('ERROR on GetActs, unable to get acts !');
		        return undefined;
		    }
		    return acts;
		},

        /**  
        * @public
        */
		GetActCount:function() {
		    var acts = this.GetActs();
		    if (!UWA.is(acts)) {
		        UWA.log('ERROR on GetActCount, unable to get acts !');
		        return null;
		    }
		    return acts.length;
		},

        /**  
        * @public
        */
		SetStartupAct: function (iAct) {
		    var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
		    if (!UWA.is(scenarioExpObj)) {
		        UWA.log('ERROR on SetStartupAct, unable to retrieve CATI3DExperienceObject !');
		        return;
		    }
		    scenarioExpObj.SetValueByName('startupAct', iAct);
		},

        /**  
        * @public
        */
		GetStartupAct: function () {
		    var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
		    if (!UWA.is(scenarioExpObj)) {
		        UWA.log('ERROR on GetStartupAct, unable to retrieve CATI3DExperienceObject !');
		        return undefined;
		    }
		    var act = scenarioExpObj.GetValueByName('startupAct');
		    if (!UWA.is(act)) {
		        UWA.log('WARNING on GetStartupAct, startup act not set !');
		        return undefined;
		    }
		    return act;
		},

		GetActByIndex: function (iIndex) {
			var acts = this.GetActs();

			if (iIndex < 0 || iIndex >= acts.length) {
			    return undefined;
			}
			return acts[iIndex];
		},

		GetActIndex: function (iAct) {
			var acts = this.GetActs();
			return acts.indexOf(iAct);
		},

		MoveActToPosition: function (iAct, iPos) {
			var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
			var acts = scenarioExpObj.GetValueByName('acts');

			var idx = this.GetActIndex(iAct);
			if (idx >= 0) {
				acts.splice(idx, 1);
			}

			if (iPos < 0 || iPos > acts.length) {
				return;
			}

			acts.splice(iPos, 0, iAct);
			scenarioExpObj.SetValueByName('acts', acts);
		},

		MoveActBeforeOtherAct: function (iAct, iOtherAct) {
			var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
			var acts = scenarioExpObj.GetValueByName('acts');
			var iOldPos = this.GetActIndex(iAct);
			if (iOldPos >= 0) {
				acts.splice(iOldPos, 1);
			}

			var iNewPos = this.GetActIndex(iOtherAct);
			if (iNewPos < 0) {
				return;
			}
			acts.splice(iNewPos, 0, iAct);
			scenarioExpObj.SetValueByName('acts', acts);
		},

		MoveActAfterOtherAct: function (iAct, iOtherAct) {
			var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
			var acts = scenarioExpObj.GetValueByName('acts');
			var iOldPos = this.GetActIndex(iAct);
			if (iOldPos >= 0) {
				acts.splice(iOldPos, 1);
			}

			var iNewPos = this.GetActIndex(iOtherAct);
			if (iNewPos < 0) {
				return;
			}
			acts.splice(iNewPos + 1, 0, iAct);
			scenarioExpObj.SetValueByName('acts', acts);
		},

		MoveUpAct: function (iAct) {
			var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
			var acts = scenarioExpObj.GetValueByName('acts');

			var iPos = this.GetActIndex(iAct);
			iPos--;
			if (iPos < 0) {
				return;
			}
			acts.splice(iPos + 1, 1);
			acts.splice(iPos, 0, iAct);
			scenarioExpObj.SetValueByName('acts', acts);
		},

		MoveDownAct: function (iAct) {
			var scenarioExpObj = this.QueryInterface('CATI3DExperienceObject');
			var acts = scenarioExpObj.GetValueByName('acts');

			var iPos = this.GetActIndex(iAct);

			if (iPos < 0 || iPos === acts.length - 1) {
				return;
			}
			iPos++;
			acts.splice(iPos - 1, 1);
			acts.splice(iPos, 0, iAct);
			scenarioExpObj.SetValueByName('acts', acts);
		}
	});

    return VIAEIxpWizardedScenarioDescriptor;
});

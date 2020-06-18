/**
 * CATECXPEnvironmentsMgr
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPEnvironmentsMgr
 * @description Implements {@link  DS/CATCXPModel/interfaces/CATICXPEnvironmentsMgr CATICXPEnvironmentsMgr}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPEnvironmentsMgr',
// dependencies
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/CAT3DExpModel/CAT3DXModel'
],

function (
    UWA,
	CAT3DXInterfaceImpl,
    CAT3DXModel
    ) {
	'use strict';

	var CATECXPEnvironmentsMgr = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPEnvironmentsMgr.prototype **/
    {
    	init: function () {
    		this._parent();
    		this._activeEnvironment = null;
    	},

    	destroy: function () {
    		this._parent();
    		this._activeEnvironment = null;
    	},

    	/**  
		* @public
		*/
    	AddEnvironment: function (ihNewEnv) {
    		var environments = this.QueryInterface('CATI3DExperienceObject').GetValueByName('environments');
    		environments.push(ihNewEnv);
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('environments', environments);
    	},

    	/**  
		* @public
		*/
    	RemoveEnvironment: function (ihEnv) {
    		var environments = this.QueryInterface('CATI3DExperienceObject').GetValueByName('environments');

    		environments.splice(environments.indexOf(ihEnv), 1);
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('environments', environments);

    		if (ihEnv === this.GetActiveEnvironment()) {
    			this.SetActiveEnvironment();
    		}
    		if (ihEnv === this.GetCurrentEnvironment()) {
    			this.SetCurrentEnvironment();
    		}
    	},

    	/**  
		* @public
		*/
    	ListEnvironments: function (ohEnvs) {
    		if (!Array.isArray(ohEnvs)) {
    			console.error('ohenvs must be an array!');
    			return undefined;
    		}
    		var environments = this.QueryInterface('CATI3DExperienceObject').GetValueByName('environments');
    		ohEnvs.splice(0, ohEnvs.length);
    		ohEnvs.length = environments.length;
    		var i = environments.length;
    		while (i--) { ohEnvs[i] = environments[i]; }
    		return environments;
    	},

    	/**  
		* @public
		*/
    	SetCurrentEnvironment: function (ihEnv) {
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('currentEnvironment', ihEnv);
    	},

    	/**  
		* @public
		*/
    	GetCurrentEnvironment: function () {
    		return this.QueryInterface('CATI3DExperienceObject').GetValueByName('currentEnvironment');
    	},

    	/**  
		* @public
		*/
    	SetActiveEnvironment: function (ihEnv) {
    		this._activeEnvironment = this.GetActiveEnvironment();
    		if (this._activeEnvironment) {
    			this._activeEnvironment.QueryInterface('CATICXPEnvironment').Deactivate();
    		}

    		if (ihEnv) {
    			ihEnv.QueryInterface('CATICXPEnvironment').Activate();
    			this._activeEnvironment = ihEnv;
    		}
    		else {
    			this._activeEnvironment = null;
    		}
    	},

    	/**  
		* @public
		*/
    	GetActiveEnvironment: function () {
    		return this._activeEnvironment;
    	},

    	/**  
		* @public
		*/
    	CreateAndAddEnvironmentFromAsset: function (iName, iAsset) {
    		CAT3DXModel.CreateEnvironment('SampleEnvironment_Spec', iName); //CAT3DXModel.CreateEnvironmentFromAsset?
    	}
    });

	return CATECXPEnvironmentsMgr;
}
);


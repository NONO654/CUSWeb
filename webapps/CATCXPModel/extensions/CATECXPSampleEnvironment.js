/**
 * CATECXPSampleEnvironment
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPSampleEnvironment
 * @description Implements {@link  DS/CATCXPModel/interfaces/CATICXPEnvironment CATICXPEnvironment}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPSampleEnvironment',
// dependencies
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

function (
	UWA, CAT3DXInterfaceImpl
	) {
	'use strict';

	var CATECXPSampleEnvironment = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPSampleEnvironment.prototype **/
    {
    	init: function () {
    		this._parent();
    	},

    	/**  
		* @public
		*/
    	Activate: function () {
    		var viewer = this.GetObject()._experienceBase.webApplication.viewer;
    		viewer.setBackgroundColor(this.QueryInterface('CATI3DExperienceObject').GetValueByName('color'));

    	},

    	/**  
		* @public
		*/
    	Deactivate: function () {
    		var viewer = this.GetObject()._experienceBase.webApplication.viewer;
    		viewer.setBackgroundColor('#ffffff');
    	}

    });
	return CATECXPSampleEnvironment;
});

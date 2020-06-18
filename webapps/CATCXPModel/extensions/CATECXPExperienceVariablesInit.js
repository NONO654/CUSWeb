/**
 * CATECXPExperienceVariablesInit
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPExperienceVariablesInit
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPVariablesInit CATICXPVariablesInit}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPExperienceVariablesInit', [
        'UWA/Core',
		'DS/CATCXPModel/extensions/CATECXPVariablesInit',
        'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject'
    ],

    // Declaration
    function (
        UWA,
		CATECXPVariablesInit,
        CATI3DExperienceObject
    ) {
    	'use strict';

    	var CATECXPExperienceVariablesInit = CATECXPVariablesInit.extend(
            /** @lends DS/CATCXPModel/extensions/CATECXPExperienceVariablesInit.prototype **/
            {
            	/**
                 * @public
                 */
            	Init: function () {
            		var self = this;
            		return this._parent().done(function () {
            		    return self.CreateComponent('CXPPlaySettings', 'PlaySettings');
            		}).done(function (iPlaySettings) {
            		    self.QueryInterface('CATI3DExperienceObject').SetValueByName('PlaySettings', iPlaySettings, CATI3DExperienceObject.SetValueMode.NoCheck);
            		});
            	}
            });

    	return CATECXPExperienceVariablesInit;
    });

/**
* CATECXPLightVariablesInit
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATECXPLightVariablesInit
* @description Implements {@link DS/CATCXPModel/interfaces/CATICXPVariablesInit CATICXPVariablesInit}
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATECXPLightVariablesInit', [
        'UWA/Core',
		'DS/CATCXPModel/extensions/CATECXPModelVariablesInit',
        'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject'
],

    // Declaration
    function (
        UWA,
		CATECXPModelVariablesInit,
        CATI3DExperienceObject
    ) {
        'use strict';

        var CATECXPLightVariablesInit = CATECXPModelVariablesInit.extend(
		/** @lends DS/CATCXPLightModel/extensions/CATECXPLightVariablesInit.prototype **/
        {

            Init: function () {
                var self = this;
                return this._parent().done(function () {
                	return self.CreateComponent('Color_Spec', 'diffuseColor');
                }).done(function (diffuseColor) {
                    self.QueryInterface('CATI3DExperienceObject').SetValueByName('diffuseColor', diffuseColor, CATI3DExperienceObject.SetValueMode.NoCheck);
                    diffuseColor.QueryInterface('CATI3DExperienceObject').SetValueByName('r', 255);
                    diffuseColor.QueryInterface('CATI3DExperienceObject').SetValueByName('g', 255);
                    diffuseColor.QueryInterface('CATI3DExperienceObject').SetValueByName('b', 255);
                });
            }
        });

        return CATECXPLightVariablesInit;
    });

/**
* CATECXPLight
* @category Extension
* @name DS/CATCXPLightModel/extensions/CATECXPLight
* @description Implements {@link DS/CATCXPLightModel/interfaces/CATICXPLight CATICXPLight}
* @constructor
*/
define('DS/CATCXPLightModel/extensions/CATECXPLight',
// dependencies
[
    'UWA/Class',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

function (
    UWA,
    CAT3DXInterfaceImpl
    ) {
    'use strict';

    var CATECXPLight = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPLightModel/extensions/CATECXPLight.prototype **/
    {
        init: function () {
            this._parent();
        },

        SetIntensity: function (intensity) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName('power', intensity);
        },

        GetIntensity: function () {
            return this.QueryInterface('CATI3DExperienceObject').GetValueByName('power');
        },

        SetColor: function (r, g, b) {
            var diffuseColor = this.QueryInterface('CATI3DExperienceObject').GetValueByName('diffuseColor');
            var diffuseColorEo = diffuseColor.QueryInterface('CATI3DExperienceObject');
            diffuseColorEo.SetValueByName('r', r);
            diffuseColorEo.SetValueByName('g', g);
            diffuseColorEo.SetValueByName('b', b);
            this.QueryInterface('CATI3DExperienceObject').SetValueByName('diffuseColor', diffuseColor);
        },

        GetRed: function () {
            var diffuseColor = this.QueryInterface('CATI3DExperienceObject').GetValueByName('diffuseColor');
            return diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('r');
        },

        GetGreen: function () {
            var diffuseColor = this.QueryInterface('CATI3DExperienceObject').GetValueByName('diffuseColor');
            return diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('g');
        },

        GetBlue: function () {
            var diffuseColor = this.QueryInterface('CATI3DExperienceObject').GetValueByName('diffuseColor');
            return diffuseColor.QueryInterface('CATI3DExperienceObject').GetValueByName('b');
        }

    });

    return CATECXPLight;
});

/**
 * CATECXPModelVariablesInit
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPModelVariablesInit
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPVariablesInit CATICXPVariablesInit}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPModelVariablesInit', [
        'UWA/Core',
		'DS/CATCXPModel/extensions/CATECXPVariablesInit',
        'DS/VCXWebProperties/VCXPropertyValueColor',
        'DS/VCXWebProperties/VCXColor',
        'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject'
    ],

    // Declaration
    function (
        UWA,
		CATECXPVariablesInit,
        VCXPropertyValueColor,
        VCXColor,
        CATI3DExperienceObject
    ) {
    	'use strict';

    	var CATECXPModelVariablesInit = CATECXPVariablesInit.extend(
            /** @lends DS/CATCXPModel/extensions/CATECXPExperienceVariablesInit.prototype **/
            {
                /**
                 * @public
                 */
                Init: function () {
                    var self = this;

                    // TODO create color as a VCXPropertyValue (see JSONReader)
                    var propertyValueColor = new VCXPropertyValueColor();
                    propertyValueColor.SetValue(new VCXColor().FromRGBA(124/255, 146/255, 167/255, 1));

                    return this._parent().done(function () {
                        self.QueryInterface('CATI3DExperienceObject').SetValueByName('color', propertyValueColor, CATI3DExperienceObject.SetValueMode.NoCheck);
                    });
                }
            });

    	return CATECXPModelVariablesInit;
    });

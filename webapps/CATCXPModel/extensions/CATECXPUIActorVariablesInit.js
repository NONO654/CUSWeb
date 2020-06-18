/**
 * CATECXPUIActorVariablesInit
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPUIActorVariablesInit
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPVariablesInit CATICXPVariablesInit}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPUIActorVariablesInit', [
        'UWA/Core',
		'DS/CATCXPModel/extensions/CATECXPVariablesInit',
		'DS/CAT3DExpModel/CAT3DXModel',
		'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
		'DS/CAT3DExpModel/interfaces/CATI3DXUIRep',
        'DS/VCXWebProperties/VCXPropertyValueColor',
        'DS/VCXWebProperties/VCXColor'
    ],

    // Declaration
    function (
        UWA,
		CATECXPVariablesInit,
		CAT3DXModel,
		CATI3DExperienceObject,
		CATI3DXUIRep,
        VCXPropertyValueColor,
        VCXColor
    ) {
    	'use strict';

    	var CATECXPUIActorVariablesInit = CATECXPVariablesInit.extend(
            /** @lends DS/CATCXPModel/extensions/CATECXPExperienceVariablesInit.prototype **/
            {
            	/**
                 * @public
                 */
            	Init: function () {
            	    var self = this;

            	    return this._parent()
                    .done(function () {
                        self.CreateVariable(null, 'visible', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
                        self.QueryInterface('CATI3DExperienceObject').SetValueByName('visible', true, CATI3DExperienceObject.SetValueMode.NoCheck);
                        self.CreateVariable(null, 'opacity', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
                        self.QueryInterface('CATI3DExperienceObject').SetValueByName('opacity', 255, CATI3DExperienceObject.SetValueMode.NoCheck);
                        self.CreateVariable(null, 'enable', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
                        self.QueryInterface('CATI3DExperienceObject').SetValueByName('enable', true, CATI3DExperienceObject.SetValueMode.NoCheck);

                        self.CreateVariable(null, 'offset', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
                        self.CreateVariable(null, 'minimumDimension', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
                        self.CreateVariable(null, 'attachment', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

            		    return self.CreateComponent('Vector2D_Spec', 'offset');
            		}).done(function (iOffset) {
            		    self.QueryInterface('CATI3DExperienceObject').SetValueByName('offset', iOffset, CATI3DExperienceObject.SetValueMode.NoCheck);
            		    iOffset.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 250, CATI3DExperienceObject.SetValueMode.NoCheck);
            		    iOffset.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 250, CATI3DExperienceObject.SetValueMode.NoCheck);

            			return self.CreateComponent('Dimension_Spec', 'minimumDimension');
            		}).done(function (iMinimumDimension) {
            		    self.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', iMinimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);

            			return self.CreateComponent('Attachment_Spec', 'attachment');
            		}).done(function (iAttachment) {
            		    iAttachment.QueryInterface('CATI3DExperienceObject').SetValueByName('side', CATI3DXUIRep.Attachment.ESide.eTopLeft, CATI3DExperienceObject.SetValueMode.NoCheck);
            		    self.QueryInterface('CATI3DExperienceObject').SetValueByName('attachment', iAttachment, CATI3DExperienceObject.SetValueMode.NoCheck);

            			return self.CreateComponent('CXPUIDataModel_Spec', 'data');
            		}).done(function (iData) {
            		    self.QueryInterface('CATI3DExperienceObject').SetValueByName('data', iData, CATI3DExperienceObject.SetValueMode.NoCheck);
            		    self.CreateVariable(iData, '__configurationName__', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
            		});
            	}
            });

    	return CATECXPUIActorVariablesInit;
    });

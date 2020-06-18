/**
 * CATECXPUIActor
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPUIActor
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPUIActor CATICXPUIActor}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPUIActor',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

// Declaration
function (
	UWA, CAT3DXInterfaceImpl
	) {
	'use strict';

	var CATECXPUIActor = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPUIActor.prototype **/
    {
    	/**  
        * @public
        */
    	SetOffset: function (iOffset) {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var offset = expObject.GetValueByName('offset');
    		var offsetEo = offset.QueryInterface('CATI3DExperienceObject');
    		offsetEo.SetValueByName('x', iOffset.x);
    		offsetEo.SetValueByName('y', iOffset.y);
    		expObject.SetValueByName('offset', offset);
    	},

    	/**  
        * @public
        */
    	GetOffset: function () {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var offset = expObject.GetValueByName('offset');
    		var offsetEO = offset.QueryInterface('CATI3DExperienceObject');
    		return {
    			x: offsetEO.GetValueByName('x'),
    			y: offsetEO.GetValueByName('y')
    		};
    	},

    	/**  
        * @public
        */
    	SetMinimumDimension: function (iWidth, iHeight, iMode) {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var dim = expObject.GetValueByName('minimumDimension');
    		var dimEo = dim.QueryInterface('CATI3DExperienceObject');
    		dimEo.SetValueByName('width', iWidth);
    		dimEo.SetValueByName('height', iHeight);
    		if (iMode) {
    		    dimEo.SetValueByName('mode', iMode);
    		}
    		expObject.SetValueByName('minimumDimension', dim);
    	},

    	/**  
        * @public
        */
    	GetMinimumDimension: function () {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var dim = expObject.GetValueByName('minimumDimension');
    		var dimEO = dim.QueryInterface('CATI3DExperienceObject');
    		return {
    			width: dimEO.GetValueByName('width'),
    			height: dimEO.GetValueByName('height'),
    			mode: dimEO.GetValueByName('mode')
    		};
    	},

    	/**  
        * @public
        */
    	GetDimension: function () {
    		var uiRep = this.QueryInterface('CATI3DXUIRep');
    		var rep = uiRep.Get();

    		return {
    			width: rep.clientWidth,
    			height: rep.clientHeight
    			//mode: dimEO.GetValueByName('mode'),
    		};
    	},

    	/**  
	   * @public
	   */
    	SetAttachment: function (iSide, iTarget) {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var attachment = expObject.GetValueByName('attachment');
    		var attachmentEo = attachment.QueryInterface('CATI3DExperienceObject');
    		attachmentEo.SetValueByName('side', iSide);
    		attachmentEo.SetValueByName('target', iTarget);
    		expObject.SetValueByName('attachment', attachment);
    	},

    	GetAttachment: function () {
    		var expObject = this.QueryInterface('CATI3DExperienceObject');
    		var attachment = expObject.GetValueByName('attachment');
    		var attachmentEO = attachment.QueryInterface('CATI3DExperienceObject');
    		return {
    			side : attachmentEO.GetValueByName('side'),
    			target: attachmentEO.GetValueByName('target')
    		};
    	},

    	/**  
	   * @public
	   */
    	SetEnable: function (iEnable) {
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('enable', iEnable);
    	},

        /**  
	   * @public
	   */
    	GetEnable: function () {
    	    return this.QueryInterface('CATI3DExperienceObject').SetValueByName('enable', iEnable);
    	},

    	/**  
	   * @public
	   */
    	SetOpacity: function (iOpacity) {
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('opacity', iOpacity * 255);
    	},

        /**  
        * @public
        */
    	GetOpacity: function () {
    	    return this.QueryInterface('CATI3DExperienceObject').GetValueByName('opacity' / 255);
    	},

    	/**  
	   * @public
	   */
    	SetVisible: function (iVisible) {
    		this.QueryInterface('CATI3DExperienceObject').SetValueByName('visible', iVisible);
    	},

    	GetVisible: function () {
    		return this.QueryInterface('CATI3DExperienceObject').GetValueByName('visible');
    	}

    });
	return CATECXPUIActor;
});

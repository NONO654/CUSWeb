define('DS/CATCXPModel/extensions/CATE3DX3DActorGraphicalProperties',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/VCXWebProperties/VCXColor',
    'DS/VCXWebProperties/VCXPropertyValueColor'
],

// Declaration
function (
    UWA, CAT3DXInterfaceImpl, VCXColor, VCXPropertyValueColor
    ) {
    'use strict';


    var CATE3DX3DActorGraphicalProperties = CAT3DXInterfaceImpl.extend(
    {

    	init: function () {
    		this._parent();
    	},

        // --- Interface CATI3DXGraphicalProperties 
        /** CATI3DXGraphicalProperties 
        * @public
        */
        GetPickMode: function () {
            var clickable = this.QueryInterface('CATI3DExperienceObject').GetValueByName("clickable");
            if (undefined === clickable) { // if not defined, set pickability to true
                clickable = true;
            }
            return clickable;
        },

        /**  
        * @public
        */
        SetPickMode: function (iClickable) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName("clickable", iClickable);
        },

        /**  
        * @public
        */
        GetShowMode: function () {
            var visible = this.QueryInterface('CATI3DExperienceObject').GetValueByName("visible");
            if (undefined === visible) { // if not defined, set visibility to true
                visible = true;
            }
            return visible;
        },

        /**  
        * @public
        */
        SetShowMode: function (iVisible) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName("visible", iVisible);
        },

        /**  
        * @public
        */
        GetOpacity: function () {
            var opacity = this.QueryInterface('CATI3DExperienceObject').GetValueByName("opacity");
            if (undefined === opacity) { // if not defined, set opacity to 255
                opacity = 255;
            }
            return opacity;
        },

        /**  
        * @public
        */
        SetOpacity: function (iOpacity) {
            this.QueryInterface('CATI3DExperienceObject').SetValueByName("opacity", iOpacity);
        },

        /**  
        * @public
        */
        GetRed: function () {
            var color = this.QueryInterface('CATI3DExperienceObject').GetValueByName("color");
            if (!color) {
                return;
            }
            color = color.GetValue();
            return Math.ceil(color.r * 255);
        },

        /**  
        * @public
        */
        GetGreen: function () {
            var color = this.QueryInterface('CATI3DExperienceObject').GetValueByName("color");
            if (!color) {
                return;
            }
            color = color.GetValue();
            return Math.ceil(color.g * 255);
        },

        /**  
        * @public
        */
        GetBlue: function () {
            var color = this.QueryInterface('CATI3DExperienceObject').GetValueByName("color");
            if (!color) {
                return;
            }
            color = color.GetValue();
            return Math.ceil(color.b * 255);
        },

        GetThreeColor: function() {
            var color = this.QueryInterface('CATI3DExperienceObject').GetValueByName("color");
            if (!color) {
                return;
            }
            color = color.GetValue();
            var threeColor = color.GetThreeColor();
            /*threeColor.r = threeColor.r * 255;
            threeColor.g = threeColor.g * 255;
            threeColor.b = threeColor.b * 255;*/
            return threeColor;
        },

        /**  
        * @public
        */
        SetColor: function (iRed, iGreen, iBlue) {
            var color = new VCXColor().FromRGBA(iRed/255, iGreen/255, iBlue/255, 1);
            var propertyValue = this.QueryInterface('CATI3DExperienceObject').GetValueByName("color");
            if (!propertyValue) { // case not set
                propertyValue = new VCXPropertyValueColor();
            }
            propertyValue.SetValue(color);
            this.QueryInterface('CATI3DExperienceObject').SetValueByName("color", propertyValue);
        },

    });

    return CATE3DX3DActorGraphicalProperties;
});


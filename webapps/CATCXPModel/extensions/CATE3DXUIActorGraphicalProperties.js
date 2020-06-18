define('DS/CATCXPModel/extensions/CATE3DXUIActorGraphicalProperties',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

// Declaration
function (
    UWA, CAT3DXInterfaceImpl
    ) {
	'use strict';


	var CATE3DXUIActorGraphicalProperties = CAT3DXInterfaceImpl.extend(
    {

    	init: function () {
    		this._parent();
    	},

    	GetShowMode: function () {
    	    return this.QueryInterface('CATI3DExperienceObject').GetValueByName('visible');
    	},

    	SetShowMode: function (iVisible) {
    	    this.QueryInterface('CATI3DExperienceObject').SetValueByName('visible', iVisible);
    	},

    	GetOpacity: function () {
    	    var opacity = this.QueryInterface('CATI3DExperienceObject').GetValueByName("opacity");
    	    if (undefined === opacity) { // if not defined, set opacity to 255
    	        opacity = 255;
    	    }
    	    return opacity;
    	},

    	SetOpacity: function (iOpacity) {
    	    this.QueryInterface('CATI3DExperienceObject').SetValueByName('opacity', iOpacity);
    	},

    	//not implement in C++
    	GetRed: function () {
    	},

    	GetGreen: function () {
    	},

    	GetBlue: function () {
    	},

    	SetColor: function (iRed, iGreen, iBlue) {
    	},

    	GetPickMode: function () {
    	},

    	SetPickMode: function (iClickable) {
    	}

    });

	return CATE3DXUIActorGraphicalProperties;
});


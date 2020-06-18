define('DS/CATCXPModel/extensions/CATECXPCameraModifiable',
[
	'UWA/Core',
	'DS/CATCXPModel/extensions/CATECXP3DActorModifiable'
],

function (
    UWA,
	CATECXP3DActorModifiable
    ) {
	'use strict';

	var CATECXPCameraModifiable = UWA.Class.extend(CATECXP3DActorModifiable,
    {

    	init: function () {
    		this._parent();
    	},


    	_getVCXPropertyValue: function (iVariableName) {
    	    var propertyValue = this._parent(iVariableName);
    		if (UWA.is(propertyValue)) {
    			return propertyValue;
    		}
    		switch (iVariableName) {

    			case 'zoom':
    			    return this._toVCXFloat(iVariableName);

    			case 'viewAngle':
    			    return this._toVCXFloat(iVariableName);

    			case 'nearClip':
    			    return this._toVCXFloat(iVariableName);

    			case 'farClip':
    			    return this._toVCXFloat(iVariableName);

    		    default:
    		        return undefined;
    		}
    	},

    	_getVariableValue: function (iPropertyName, iPropertyValue) {
    		var variableValue = this._parent(iPropertyName, iPropertyValue);
    		if (UWA.is(variableValue)) {
    			return variableValue;
    		}
    		switch (iPropertyName) {
    			case 'zoom':
    				return iPropertyValue.GetValue();

    			case 'viewAngle':
    				return iPropertyValue.GetValue();

    			case 'nearClip':
    				return iPropertyValue.GetValue();

    			case 'farClip':
    			    return iPropertyValue.GetValue();

                default:
                    return undefined;
    		}
    	}

    });

	return CATECXPCameraModifiable;
});


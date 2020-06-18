define('DS/CATCXPModel/extensions/CATECXPConeModifiable',
[
	'UWA/Core',
	'DS/CATCXPModel/extensions/CATECXP3DActorModifiable'
],

function (
    UWA,
	CATECXP3DActorModifiable
    ) {
	'use strict';

	var CATECXPConeModifiable = UWA.Class.extend(CATECXP3DActorModifiable,
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

    			case 'radius':
    			    return this._toVCXFloat(iVariableName);

    			case 'height':
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
    			case 'radius':
    				return iPropertyValue.GetValue();

    			case 'height':
    			    return iPropertyValue.GetValue();

                default:
                    return undefined;
    		}
    	}

    });

	return CATECXPConeModifiable;
});


define('DS/CATCXPModel/extensions/CATECXP3DActorOverrideModifiable',
[
	'UWA/Core',
	'DS/CAT3DExpModel/extensions/CATEModifiable'
],

function (
    UWA,
	CATEModifiable
    ) {
	'use strict';

	var CATECXP3DActorOverrideModifiable = CATEModifiable.extend(
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

    			case 'scale':
    			    return this._toVCXFloat(iVariableName);

    			case '_varposition':
    			    return this._toVCXLocation(iVariableName);
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
    			case 'scale':
    				return iPropertyValue.GetValue();
    			case '_varposition':
    				return this._fromVCXLocation(iPropertyValue);
    		    default:
    		        return undefined;
    		}
    	}

    });

	return CATECXP3DActorOverrideModifiable;
});


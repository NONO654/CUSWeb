define('DS/CATCXPModel/extensions/CATECXP3DActorModifiable',
[
	'UWA/Core',
	'DS/CAT3DExpModel/extensions/CATEModifiable'
],

function (
    UWA,
	CATEModifiable
    ) {
	'use strict';

	var CATECXP3DActorModifiable = CATEModifiable.extend(
    {

    	init: function () {
    		this._parent();
    	},


    	_getVCXPropertyValue: function (iVariableName) {
    	    var propertyValue = this._parent(iVariableName);
    		if (UWA.is(propertyValue)) {
    			return propertyValue;
    		}
    		if (iVariableName === '_varposition') {
    		    return this._toVCXLocation(iVariableName);
    		}
    		return undefined;
    	},

    	_getVariableValue: function (iPropertyName, iPropertyValue) {
    		var variableValue = this._parent(iPropertyName, iPropertyValue);
    		if (UWA.is(variableValue)) {
    			return variableValue;
    		}
    		if (iPropertyName === '_varposition') {
    			return this._fromVCXLocation(iPropertyValue);
    		}
    		return undefined;
    	}

    });

	return CATECXP3DActorModifiable;
});


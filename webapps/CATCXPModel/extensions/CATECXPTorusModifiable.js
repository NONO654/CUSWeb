define('DS/CATCXPModel/extensions/CATECXPTorusModifiable',
[
	'UWA/Core',
	'DS/CATCXPModel/extensions/CATECXP3DActorModifiable'
],

function (
    UWA,
	CATECXP3DActorModifiable
    ) {
	'use strict';

	var CATECXPTorusModifiable = UWA.Class.extend(CATECXP3DActorModifiable,
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

    			case 'radius1':
    			    return this._toVCXFloat(iVariableName);

    			case 'radius2':
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
    			case 'radius1':
    				return iPropertyValue.GetValue();

    			case 'radius2':
    			    return iPropertyValue.GetValue();

    		    default:
    		        return undefined;
    		}
    	}

    });

	return CATECXPTorusModifiable;
});


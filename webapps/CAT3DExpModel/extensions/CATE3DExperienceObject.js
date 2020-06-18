/**
* CATE3DExperienceObject
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DExperienceObject
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DExperienceObject CATI3DExperienceObject}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DExperienceObject',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/CAT3DExpModel/CAT3DXModel',
    'DS/CAT3DExpModel/CAT3DXVariable',
    'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'UWA/Class/Events'
],
function (
	UWA,
	CAT3DXInterfaceImpl,
    CAT3DXModel,
    CAT3DXVariable,
    CATI3DExperienceObject,
    Events
	) {
    'use strict';

    var CATE3DExperienceObject = UWA.Class.extend(CAT3DXInterfaceImpl, Events,
	/** @lends DS/CAT3DExpModel/extensions/CATE3DExperienceObject.prototype **/
	{
	    init: function () {
	        this._onlyVolatile = false;
	    },

	    /**
		 * Add model variables
		 * @public
		 **/
	    Build: function () {
	        var component = this.GetObject();
	        if (component._variables) {
	            console.error('_variables will be override on component');
	        }
	        component._variables = {};

	        var variables = CAT3DXModel.GetVariables(component.GetType());
	        if (UWA.is(variables)) {
	            for (var index = 0; index < variables.length; index++) {
	                var variable = variables[index];
	                var variableType = parseInt(variable.type);

	                this.AddVariable(variable.name, variableType,
						parseInt(variable.maxNumberOfValues), parseInt(variable.valuationMode), variable.restrictiveTypes ? variable.restrictiveTypes.split(',') : undefined);

	                if (parseInt(variable.maxNumberOfValues) !== 1) {
	                    var value = [];
	                    if (Array.isArray(variable.value)) {
	                        for (var i = 0; i < variable.value.length; i++) {
	                            if (variableType === CATI3DExperienceObject.VarType.String) {
	                                value.push(variable.value[i]);
	                            } else if (variableType === CATI3DExperienceObject.VarType.Integer) {
	                                value.push(parseInt(variable.value[i]));
	                            } else if (variableType === CATI3DExperienceObject.VarType.Double) {
	                                value.push(parseFloat(variable.value[i]));
	                            } else if (variableType === CATI3DExperienceObject.VarType.Boolean) {
	                                var varBool;
	                                if (variable.value[i] === 'true') {
	                                    varBool = true;
	                                }
	                                else {
	                                    varBool = false;
	                                }
	                                value.push(varBool);
	                            }
	                        }
	                    }
	                    this.SetValueByName(variable.name, value, CATI3DExperienceObject.SetValueMode.NoCheck);
	                }
	                else {
	                    if (variableType === CATI3DExperienceObject.VarType.String) {
	                        this.SetValueByName(variable.name, variable.value, CATI3DExperienceObject.SetValueMode.NoCheck);
	                    } else if (variableType === CATI3DExperienceObject.VarType.Integer) {
	                        this.SetValueByName(variable.name, parseInt(variable.value), CATI3DExperienceObject.SetValueMode.NoCheck);
	                    } else if (variableType === CATI3DExperienceObject.VarType.Double) {
	                        this.SetValueByName(variable.name, parseFloat(variable.value), CATI3DExperienceObject.SetValueMode.NoCheck);
	                    } else if (variableType === CATI3DExperienceObject.VarType.Boolean) {
	                        var varBool;
	                        if (variable.value === 'true') {
	                            varBool = true;
	                        }
	                        else {
	                            varBool = false;
	                        }
	                        this.SetValueByName(variable.name, varBool, CATI3DExperienceObject.SetValueMode.NoCheck);
	                    }
	                }
	            }
	        }
	    },

	    destroy: function () {
	        var component = this.GetObject();
	        for (var variableName in component._variables) {
	            if (component._variables.hasOwnProperty(variableName)) {
	                var variable = component._variables[variableName];
	                if (variable._type === CATI3DExperienceObject.VarType.Object &&
						variable._valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
	                    var value = variable._volatileValue;
	                    if (Array.isArray(value)) {
	                        for (var j = 0; j < value.length; j++) {
	                            if (value[j].destroy) {
	                                value[j].destroy();
	                            }
	                        }
	                    }
	                    else if (UWA.is(value) && value.destroy) {
	                        value.destroy();
	                    }
	                }
	            }
	        }
	        component._variables = {};
	        component._parent = undefined;
	    },

	    _GetVariable: function (iName) {
	        var component = this.GetObject();
	        var variable = component._variables[iName];
	        if (!UWA.is(variable)) {
	            console.error('Variable ' + iName + ' doesnt exist');
	        }
	        return variable;
	    },

	    ListVariables: function (o3DExpVariables, iVarType) {
	        if (!(o3DExpVariables instanceof Array)) {
	            o3DExpVariables = [];
	        }
	        if (!UWA.is(iVarType)) {
	            iVarType = CATI3DExperienceObject.VarType.All;
	        }
	        o3DExpVariables.length = 0;
	        var component = this.GetObject();
	        for (var key in component._variables) {
	            if (component._variables.hasOwnProperty(key)) {
	                if (CATI3DExperienceObject.VarType.All === iVarType || component._variables[key]._type === iVarType) {
	                    o3DExpVariables.push(key);
	                }
	            }
	        }
	        return o3DExpVariables;
	    },

	    HasVariable: function (iVarName) {
	        var component = this.GetObject();
	        return component._variables.hasOwnProperty(iVarName);
	    },

	    AddVariable: function (iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes) {
	        var component = this.GetObject();
	        if (iVariableName in component._variables) {
	            UWA.log('CAT3DXBaseImpl.AddVariable ERROR : variable name already exist ! ' + iVariableName);
	        }
			else {
	        	component._variables[iVariableName] = new CAT3DXVariable(component, iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes);
			}
	    },

	    GetValueByName: function (iName) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            return variable._volatileValue;
	        }
	        return undefined;
	    },

	    SetValueByName: function (iName, iValue, iMode) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            this._SetVolatileValue(variable, iValue);

	            if (this._onlyVolatile) {
	                iMode = CATI3DExperienceObject.SetValueMode.OnlyVolatile;
	            }

	            if (CATI3DExperienceObject.SetValueMode.OnlyVolatile !== iMode) {
	                if (CATI3DExperienceObject.SetValueMode.NoCheck === iMode) {
	                    variable._persistentValue = iValue;
	                } else {
	                    CAT3DXModel.SetVariableValues(this.GetObject(), iName, iValue);
	                }
	            }
	        }
	    },

	    _SetVolatileValue: function (iVariable, iValue) {
	        iVariable._volatileValue = iValue;
	        if (iVariable._type === CATI3DExperienceObject.VarType.Object && iVariable._valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
	            this._setChildrenFather(iValue);
	        }
	        this.dispatchEvent('VARIABLE_CHANGED', [iVariable._name, iValue]);
	        this.dispatchEvent(iVariable._name + '.CHANGED', [iValue]);
	    },

	    _setChildrenFather: function (iValue) {
	        if (Array.isArray(iValue)) {
	            for (var ic = 0; ic < iValue.length; ic++) {
	                iValue[ic]._parent = this.GetObject();
	            }
	        } else if (iValue && iValue.QueryInterface) {
	            iValue._parent = this.GetObject();
	        }
	    },

	    GetVariableInfo: function (iName) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            return {
	                name: variable._name,
	                type: variable._type,
	                valuationMode: variable._valuationMode,
	                maxNumberOfValues: variable._maxNumberOfValues,
	                restrictiveTypes: variable._restrictiveTypes,
	                id: variable._id
	            };
	        }
	        return undefined;
	    },

	    GetVariableType: function (iName) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            return variable._type;
	        }
	    },

	    SetVariableID: function (iName, iID) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            variable._id = iID;
	        }
	    },

	    GetVariableID: function (iName) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            if (!variable._id) {
	                variable._id = this.GetObject().GetID() + ',' + variable._name; //debug
	            }
	            return variable._id;
	        }
	        return undefined;
	    },

	    SetVolatile: function (iOnOff) {
	        this._onlyVolatile = iOnOff;
	    },

	    RestorePersistent: function () {
	        var component = this.GetObject();
	        for (var key in component._variables) {
	            if (component._variables.hasOwnProperty(key)) {
	                this._SetVolatileValue(component._variables[key], component._variables[key]._persistentValue);
	            }
	        }
	    },

	    RestorePersistentValueByName: function (iName) {
	        var variable = this._GetVariable(iName);
	        if (variable) {
	            this._SetVolatileValue(variable, variable._persistentValue);
	        }
	    }
	});

    return CATE3DExperienceObject;
});

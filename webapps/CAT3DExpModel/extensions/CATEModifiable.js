/**
* CATEModifiable
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATEModifiable
* @description Implements VCXImodifiable
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATEModifiable',
[
	'UWA/Core',

    'DS/VCXWebProperties/VCXProperty',
	'DS/VCXWebProperties/VCXPropertySet',
    'DS/VCXWebProperties/VCXPropertyInfo',
	'DS/VCXWebProperties/VCXPropertyValue',
	'DS/VCXWebProperties/VCXPropertyValueFloat',
	'DS/VCXWebProperties/VCXPropertyValueInt',
	'DS/VCXWebProperties/VCXPropertyValueString',
	'DS/VCXWebProperties/VCXPropertyValueBoolean',
	'DS/VCXWebProperties/VCXPropertyValueColor',
	'DS/VCXWebProperties/VCXPropertyValueFrame',
	'DS/VCXWebProperties/VCXPropertyValueLocation',
	'DS/VCXWebModifiables/VCXModifiable',
	'DS/VCXWebProperties/VCXColor',

	'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'DS/Visualization/ThreeJS_DS'
],

function (
	UWA,

	VCXProperty,
	VCXPropertySet,
	VCXPropertyInfo,
	VCXPropertyValue,
	VCXPropertyValueFloat,
	VCXPropertyValueInt,
	VCXPropertyValueString,
	VCXPropertyValueBoolean,
	VCXPropertyValueColor,
	VCXPropertyValueFrame,
	VCXPropertyValueLocation,
	VCXModifiable,
	VCXColor,

	CATI3DExperienceObject,
	THREE
	) {

	'use strict';

	var CATEModifiable = VCXModifiable.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATEModifiable.prototype **/
	{

		init: function () {
			this._parent();
			this.VCXProperties = {};
		},

		GetType: function () {
			return this._type;
		},


		GetProperties: function () {
			var propSet = new VCXPropertySet();
			var D3ExpObj = this.QueryInterface('CATI3DExperienceObject');
			var variableList = [];
			var propSet = new VCXPropertySet();

			D3ExpObj.ListVariables(variableList);
			for (var i = 0; i < variableList.length; ++i) {
			    var prop = this.GetProperty(variableList[i]);
				if (prop && prop._propertyValue) {
					propSet.AddOrModifyProperty(prop);
				}
			}

			return propSet;
		},

		GetProperty: function (strPropertyName) {
			var D3ExpObj = this.QueryInterface('CATI3DExperienceObject');

			if (UWA.is(D3ExpObj)) {
				var variableInfo = D3ExpObj.GetVariableInfo(strPropertyName);
				// exclude ref
				if (variableInfo.valuationMode !== CATI3DExperienceObject.ValuationMode.AggregatingValue) {
					return null;
				}

				// Get Value
				var VCXValue = this._getVCXPropertyValue(strPropertyName);

				// set property value
				if (!UWA.is(this.VCXProperties[strPropertyName])) {
					var VCXInfo = new VCXPropertyInfo(strPropertyName, 0, true, 'VCXWebModifiables/VCXWebModifiables');
					this.VCXProperties[strPropertyName] = new VCXProperty(VCXInfo, VCXValue);
				}
				else {
					this.VCXProperties[strPropertyName].SetPropertyValue(VCXValue);
				}
			}
			return this.VCXProperties[strPropertyName];
		},

		OnChangeProperty: function (strPropertyName, propertyValue) {
		    var expValue = this.QueryInterface('CATI3DExperienceObject').GetValueByName(strPropertyName);
			var variableValue = this._getVariableValue(strPropertyName, propertyValue);
			if (UWA.is(variableValue)) {
			    if (expValue !== variableValue) {
			        this.QueryInterface('CATI3DExperienceObject').SetValueByName(strPropertyName, variableValue);
				}
			}
		},

		_getVCXPropertyValue: function (iVariableName) {
		    switch (iVariableName) {
				case '_varName':
				    return this._toVCXString(iVariableName);
			    default :
			        return undefined;
			}
		},

		_getVariableValue:function(iPropertyName, iPropertyValue) {
			switch (iPropertyName) {
				case '_varName':
					return iPropertyValue.GetValue();
                default:
                    return undefined;
			}
		},

		_toVCXInt: function (iVariableName) {
		    return new VCXPropertyValueInt(this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName));
		},

		_toVCXFloat: function (iVariableName) {
		    return new VCXPropertyValueFloat(this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName));
		},

		_toVCXString: function (iVariableName) {
		    return new VCXPropertyValueString(this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName));
		},

		_toVCXBool: function (iVariableName) {
		    return new VCXPropertyValueBoolean(this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName));
		},

		_toVCXLocation: function (iVariableName) {
		    var obj = this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
			var mat = new THREE.Matrix4(obj[0], obj[3], obj[6], obj[9],
							obj[1], obj[4], obj[7], obj[10],
							obj[2], obj[5], obj[8], obj[11],
							0.0, 0.0, 0.0, 1.0);
			var loc = new VCXPropertyValueLocation();
			loc.SetFrame(new VCXPropertyValueFrame(mat));
			loc.SetPivot(new VCXPropertyValueFrame(mat));
			return loc;
		},

		_fromVCXLocation: function (iPropertyValue) {
			var obj = iPropertyValue.GetValue();

			var e = obj[0]._value.elements;
			return [e[0], e[1], e[2],
					e[4], e[5], e[6],
					e[8], e[9], e[10],
					e[12], e[13], e[14]];
		},

		_toVCXColor: function (iVariableName) {
		    var obj = this.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
			var c = new VCXColor();
			c.SetRGB((obj.GetRed() ? obj.GetRed() : 0) / 255,
						(obj.GetGreen() ? obj.GetGreen() : 0) / 255,
						(obj.GetBlue() ? obj.GetBlue() : 0) / 255);
			return new VCXPropertyValueColor(c);
		},

		_fromVCXColor: function () {
			var obj = iVariable.GetValue();
			var threeColor = obj.GetThreeColor();
			var color = {}; // basic object for now, should supprot GraphicalProperties
			color.r = Math.floor(threeColor.r * 255);
			color.g = Math.floor(threeColor.g * 255);
			color.b = Math.floor(threeColor.b * 255);
			return color;
		}


	});

	return CATEModifiable;

});

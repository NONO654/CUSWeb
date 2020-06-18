define('DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DExperienceObject',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy',
    'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'DS/StuRenderEngine/StuColor'
],

function (
    UWA,
    StuProxy,
    CATI3DExperienceObject,
    StuColor
    ) {
    'use strict';


    var StuCATI3DExperienceObject = StuProxy.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelCATI3DExperienceObject = iModelObject.QueryInterface('CATI3DExperienceObject');
        },

        GetValueByName: function (iName) {
            var type = this._modelCATI3DExperienceObject.GetVariableType(iName)
            if (type === CATI3DExperienceObject.VarType.Object) {
                return this._GetValueByNameObject(iName);
            } else if (type === CATI3DExperienceObject.VarType.Color) {
                return this._GetValueByNameColor(iName);
            }
            else {
                return this._modelCATI3DExperienceObject.GetValueByName(iName);
            }
        },

        _GetValueByNameObject: function (iName) {
            var valueModel = this._modelCATI3DExperienceObject.GetValueByName(iName);
            if (!valueModel) {
                return;
            } else if (Array.isArray(valueModel)) {
                var value = [];
                for (var i = 0; i < valueModel.length; i++) {
                    if (valueModel[i].QueryInterface('StuIPrototypeBuild')) {
                        value.push(valueModel[i].QueryInterface('StuIPrototypeBuild').GetSync());
                    }
                }
                return value;
            } else {
                if (valueModel.QueryInterface('StuIPrototypeBuild')) {
                    return valueModel.QueryInterface('StuIPrototypeBuild').GetSync();
                }
            }
        },

        _GetValueByNameColor: function (iName) {
            var valueModel = this._modelCATI3DExperienceObject.GetValueByName(iName);
            if (valueModel) {
                var threeColor = valueModel.GetThreeColor();
                var color = new StuColor(threeColor.r * 255, threeColor.g * 255, threeColor.b * 255);
                return color;
            }
        },



        SetValueByName: function (iName, iValue) {
            var type = this._modelCATI3DExperienceObject.GetVariableType(iName)
            if (type === CATI3DExperienceObject.VarType.Object) {
                return this._SetValueByNameObject(iName, iValue);
            } else if (type === CATI3DExperienceObject.VarType.Color) {
                return this._SetValueByNameColor(iName, iValue);
            }
            else {
                this._modelCATI3DExperienceObject.SetValueByName(iName, iValue, CATI3DExperienceObject.SetValueMode.OnlyVolatile);
            }
        },

        _SetValueByNameObject: function (iName, iValue) {
            if (!iValue) {
                this._modelCATI3DExperienceObject.SetValueByName(iName, iValue, CATI3DExperienceObject.SetValueMode.OnlyVolatile);
            } else if (Array.isArray(iValue)) {
                var valueModel = [];
                for (var i = 0; i < iValue.length; i++) {
                    valueModel.push(iValue[i].CATI3DExperienceObject.getModelObject());
                }
                this._modelCATI3DExperienceObject.SetValueByName(iName, valueModel, CATI3DExperienceObject.SetValueMode.OnlyVolatile);
            } else {
                this._modelCATI3DExperienceObject.SetValueByName(iName, iValue.CATI3DExperienceObject.getModelObject(), CATI3DExperienceObject.SetValueMode.OnlyVolatile);
            }
        },

        _SetValueByNameColor: function (iName, iValue) {
            //Should not be use for now
            console.log('not implemented');
        },


        //TODO dynamic actors

    });

    return StuCATI3DExperienceObject;
});


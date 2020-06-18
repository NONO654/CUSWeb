define('DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DXGraphicalProperties',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy'
],

function (
    UWA,
    StuProxy
    ) {
    'use strict';

    var StuCATI3DXGraphicalProperties = StuProxy.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelCATI3DXGraphicalProperties = iModelObject.QueryInterface('CATI3DXGraphicalProperties');
        },

        GetPickMode: function () {
            return this._modelCATI3DXGraphicalProperties.GetPickMode();
        },

        SetPickMode: function (iClickable) {
            this._modelCATI3DXGraphicalProperties.SetPickMode(iClickable);
        },

        GetShowMode: function () {
            return this._modelCATI3DXGraphicalProperties.GetShowMode();
        },

        SetShowMode: function (iVisible) {
            this._modelCATI3DXGraphicalProperties.SetShowMode(iVisible);
        },

        GetOpacity: function () {
            return this._modelCATI3DXGraphicalProperties.GetOpacity();
        },

        SetOpacity: function (iOpacity) {
            this._modelCATI3DXGraphicalProperties.SetOpacity(iOpacity);
        },

        GetRed: function () {
            return this._modelCATI3DXGraphicalProperties.GetRed();
        },

        GetGreen: function () {
            return this._modelCATI3DXGraphicalProperties.GetGreen();
        },

        GetBlue: function () {
            return this._modelCATI3DXGraphicalProperties.GetBlue();
        },

        SetColor: function (iRed, iGreen, iBlue) {
            this._modelCATI3DXGraphicalProperties.SetColor(iRed, iGreen, iBlue);
        },

    });

    return StuCATI3DXGraphicalProperties;
});


define('DS/XCTWebExperienceAppPlay/StuProxy/StuCATICXPUIActor',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy'
],

function (
    UWA,
    StuProxy
    ) {
    'use strict';


    var StuCATICXPUIActor = StuProxy.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelCATICXPUIActor = iModelObject.QueryInterface('CATICXPUIActor');
        },

        setOffset: function (iX, iY) {
            this._modelCATICXPUIActor.SetOffset({
                x: iX,
                y: iY
            });
        },

        getOffset: function () {
            var offset = this._modelCATICXPUIActor.GetOffset();
            return [offset.x, offset.y];
        },

        setMinimumDimension: function (iWidth, iHeight, iMode) {
            this._modelCATICXPUIActor.SetMinimumDimension(iWidth, iHeight, iMode);
        },

        getMinimumDimension: function () {
            var minDimension = this._modelCATICXPUIActor.GetMinimumDimension();
            return [
                minDimension.width,
                minDimension.height,
                minDimension.mode
            ];
        },

        setAttachment: function (iSide, iTarget) {
            this._modelCATICXPUIActor.SetAttachment(iSide, iTarget);
        },
    
        setEnable: function (iEnable) {
            this._modelCATICXPUIActor.SetEnable(iEnable);
        },

        getEnable:function(){
            return this._modelCATICXPUIActor.GetEnable();
        },

        setOpacity: function (iOpacity) {
            this._modelCATICXPUIActor.SetOpacity(iOpacity);
        },

        getOpacity: function () {
            return this._modelCATICXPUIActor.GetOpacity();
        },

        setVisible: function (iVisible) {
            this._modelCATICXPUIActor.SetVisible(iVisible);
        },

        getVisible: function () {
            return this._modelCATICXPUIActor.GetVisible();
        },

        setESObject: function (iSdkObject) {
        },

        instantiateView: function () {
        }

    });

    return StuCATICXPUIActor;
});


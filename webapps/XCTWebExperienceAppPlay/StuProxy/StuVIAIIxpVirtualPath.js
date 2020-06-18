define('DS/XCTWebExperienceAppPlay/StuProxy/StuVIAIIxpVirtualPath',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy'
],

function (
    UWA,
    StuProxy
    ) {
    'use strict';


    var StuVIAIIxpVirtualPath = StuProxy.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelVIAIIxpVirtualPath = iModelObject.QueryInterface('VIAIIxpVirtualPath');
        },

        GetLength:function(){
            return this._modelVIAIIxpVirtualPath.GetLength();
        },

        GetValue: function (iCurvParam, iRelativePositionObject, oValue) {
            this._modelVIAIIxpVirtualPath.GetValue(iCurvParam, iRelativePositionObject, oValue);
        },

        GetDiscretization: function () {
            console.log('not implemented');
            //TODO
        }

    });

    return StuVIAIIxpVirtualPath;
});


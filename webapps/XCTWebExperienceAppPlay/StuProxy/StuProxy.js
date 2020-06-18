define('DS/XCTWebExperienceAppPlay/StuProxy/StuProxy',
[
	'UWA/Core'
],

function (
    UWA
    ) {
    'use strict';


    var StuProxy = UWA.Class.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._modelObject = iModelObject;
            this._stuObject = iStuObject;
        },

        getModelObject: function () {
            return this._modelObject;
        },

        getStuObject: function () {
            return this._stuObject;
        }
    });

    return StuProxy;
});


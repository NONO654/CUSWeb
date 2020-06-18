define('DS/XCTWebExperienceAppPlay/StuVisuServices', ['DS/StuMiscContent/StuVisuServices'], function (StuVisuServices) {
    'use strict';

    StuVisuServices.prototype.buildViewer = function (expObject) {
        return {
            GetPLMProperties:function (expObject) {
                return ["toto"];
            },

            GetPLMPropValue:function (expObject, propName) {
            },

            AnnotationDisplay:function (mouseWorld, panel, offset) {
            }
        };
    };

    return StuVisuServices;
});


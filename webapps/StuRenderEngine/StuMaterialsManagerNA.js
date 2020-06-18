/*global define*/
define('DS/StuRenderEngine/StuMaterialsManagerNA', ['DS/StuRenderEngine/StuMaterialsManager'], function (StuMaterialsManagerJS) {
    'use strict';
    
    /*var fakeMaterialsManager = function () {
        return new StuMaterialsManager();
    }
    StuMaterialsManagerJS.prototype = new StuMaterialsManagerJS();
    StuMaterialsManagerJS.prototype.constructor = fakeMaterialsManager;*/

    StuMaterialsManagerJS.prototype.build = function () {
        return new StuMaterialsManager();
    }
           
});

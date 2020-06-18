require({
    //baseUrl: '../'
},
    // -- Module Dependancies --
    [
    ],
    // -- Main function with aliases for loaded modules
    function () {
    	'use strict';
    	define('DS/StuRenderEngine/StuRenderManagerNA', ['DS/XCTWebExperienceAppPlay/CXPWebRenderManager'], function (CXPWebRenderManager) {
    		return CXPWebRenderManager;
        });
    });

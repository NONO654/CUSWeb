require({
    //baseUrl: '../'
},
    // -- Module Dependancies --
    [
    ],
    // -- Main function with aliases for loaded modules
    function () {
    	'use strict';
    	define('DS/StuCameras/StuNavigationNA', ['DS/XCTWebExperienceAppPlay/StuNavigation'], function (NavigationWeb) {
            return NavigationWeb;
        });
    });

require({
	//baseUrl: '../'
},
    // -- Module Dependancies --
    [
    ],
    // -- Main function with aliases for loaded modules
    function () {
    	'use strict';
    	define('DS/StuTriggerZones/StuTriggerZoneManagerNA',
			[
				'DS/XCTWebExperienceAppPlay/StuTriggerZoneManager',
				'DS/StuTriggerZones/StuTriggerZoneActor' //VMN3 Fix Manager missing require
			], function (TriggerZoneWeb) {
    		return TriggerZoneWeb;
    	});
    });

/* global define */
define('DS/StuTriggerZones/StuTriggerZoneManagerNA', ['DS/StuTriggerZones/StuTriggerZoneManager'], function (TriggerZoneManager) {
	'use strict';

	TriggerZoneManager.prototype.getTriggerZoneManager = function () {
		return stu__TriggerZoneManager.__stu__GetTriggerZoneManager();
	};

	TriggerZoneManager.prototype.deleteTriggerZoneManager = function () {
		stu__TriggerZoneManager.__stu__DeleteTriggerZoneManager();
	};

	return TriggerZoneManager;
});


define('StuTriggerZones/StuTriggerZoneManagerNA', ['DS/StuTriggerZones/StuTriggerZoneManagerNA'], function (TriggerZoneManager) {
    'use strict';

    return TriggerZoneManager;
});

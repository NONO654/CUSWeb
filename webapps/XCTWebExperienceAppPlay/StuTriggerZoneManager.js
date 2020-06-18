/* global define */
define('DS/XCTWebExperienceAppPlay/StuTriggerZoneManager', ['DS/StuTriggerZones/StuTriggerZoneManager', 'DS/XCTWebExperienceAppPlay/StuTriggerZoneManagerWeb'], function (TriggerZoneManager, TriggerZoneManagerWeb) {
	'use strict';

	TriggerZoneManager.prototype.getTriggerZoneManager = function () {
		return new TriggerZoneManagerWeb();
	};

	TriggerZoneManager.prototype.deleteTriggerZoneManager = function () {
	};

	return TriggerZoneManager;
});

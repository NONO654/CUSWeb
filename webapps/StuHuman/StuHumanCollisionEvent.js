
define('DS/StuHuman/StuHumanCollisionEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanEvent.
	 * It occurs when a human is colliding.
	 *
	 * @exports HumanCollisionEvent
     * @class
	 * @constructor
     * @private
	 * @extends STU.HumanEvent
     * @memberof STU
	 */
	var HumanCollisionEvent = function () {

	    HumanEvent.call(this);
	};

	HumanCollisionEvent.prototype = new HumanEvent();
	HumanCollisionEvent.prototype.constructor = HumanCollisionEvent;
	HumanCollisionEvent.prototype.type = 'HumanCollisionEvent';

	// Expose in STU namespace.
	STU.HumanCollisionEvent = HumanCollisionEvent;

	EventServices.registerEvent(HumanCollisionEvent);

	return HumanCollisionEvent;
});

define('StuHuman/StuHumanCollisionEvent', ['DS/StuHuman/StuHumanCollisionEvent'], function (HumanCollisionEvent) {
    'use strict';

    return HumanCollisionEvent;
});

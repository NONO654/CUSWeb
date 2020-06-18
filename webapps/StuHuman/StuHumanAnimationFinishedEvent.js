
define('DS/StuHuman/StuHumanAnimationFinishedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanAnimationStoppedEvent'],
    function (STU, EventServices, HumanAnimationStoppedEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanAnimationFinishedEvent.
	 * It occurs when a human animation task is finished.
	 *
	 * @exports HumanAnimationFinishedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.HumanAnimationStoppedEvent
     * @memberof STU
	 */
	var HumanAnimationFinishedEvent = function (animationName) {

	    HumanAnimationStoppedEvent.call(this);

	    this.animation = animationName;

	};

	HumanAnimationFinishedEvent.prototype = new HumanAnimationStoppedEvent();
	HumanAnimationFinishedEvent.prototype.constructor = HumanAnimationFinishedEvent;
	HumanAnimationFinishedEvent.prototype.type = 'HumanAnimationFinishedEvent';

	// Expose in STU namespace.
	STU.HumanAnimationFinishedEvent = HumanAnimationFinishedEvent;

	EventServices.registerEvent(HumanAnimationFinishedEvent);

	return HumanAnimationFinishedEvent;
});

define('StuHuman/StuHumanAnimationFinishedEvent', ['DS/StuHuman/StuHumanAnimationFinishedEvent'], function (HumanAnimationFinishedEvent) {
    'use strict';

    return HumanAnimationFinishedEvent;
});

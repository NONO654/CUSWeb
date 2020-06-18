
define('DS/StuHuman/StuHumanEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'],
    function (STU, EventServices, Event) {
	'use strict';

	 /**
	 * Describe an event.
     * Container of all human type events.<br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends EP.Event
     * @memberof STU
     * @alias STU.HumanEvent
	 */
	var HumanEvent = function () {

	    Event.call(this);

		/**
         * Human actor
         *
         * @member
	     * @private
         * @type {STU.Human}
         * @default undefined
         */
	    this.human;
	};

	HumanEvent.prototype = new Event();
	HumanEvent.prototype.constructor = HumanEvent;
	HumanEvent.prototype.type = 'HumanEvent';

    /**
     * Set the human actor.
     *
     * @method
     * @private
     * @param {STU.Human} iHuman
     */
	HumanEvent.prototype.setHuman = function (iHuman) {
	    this.human = iHuman;
	};

    /**
     * Return the human actor.
     *
     * @method
     * @public
     * @return {STU.Human}
     */
	HumanEvent.prototype.getHuman = function () {
	    return this.human;
	};

	// Expose in STU namespace.
	STU.HumanEvent = HumanEvent;

	EventServices.registerEvent(HumanEvent);

	return HumanEvent;
});

define('StuHuman/StuHumanEvent', ['DS/StuHuman/StuHumanEvent'], function (HumanEvent) {
    'use strict';

    return HumanEvent;
});

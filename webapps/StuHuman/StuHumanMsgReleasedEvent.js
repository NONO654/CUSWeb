
define('DS/StuHuman/StuHumanMsgReleasedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanEvent.
	 * It occurs when a human message is released.
	 *
	 * @exports HumanMsgReleasedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.HumanEvent
     * @memberof STU
	 */
	var HumanMsgReleasedEvent = function () {

	    HumanEvent.call(this);

		/**
         * Message Object
         *
         * @member
	     * @private
         * @type {Object}
         * @default undefined
         */
	    this.message;
	};

	HumanMsgReleasedEvent.prototype = new HumanEvent();
	HumanMsgReleasedEvent.prototype.constructor = HumanMsgReleasedEvent;
	HumanMsgReleasedEvent.prototype.type = 'HumanMsgReleasedEvent';

    /**
     * Set the message.
     *
     * @method
     * @private
     * @param {Object} iMessage
     */
	HumanMsgReleasedEvent.prototype.setMessage = function (iMessage) {
	    this.message = iMessage;
	};

    /**
     * Return the message.
     *
     * @method
     * @private
     * @return {Object}
     */
	HumanMsgReleasedEvent.prototype.getMessage = function () {
	    return this.message;
	};

	// Expose in STU namespace.
	STU.HumanMsgReleasedEvent = HumanMsgReleasedEvent;

	EventServices.registerEvent(HumanMsgReleasedEvent);

	return HumanMsgReleasedEvent;
});

define('StuHuman/StuHumanMsgReleasedEvent', ['DS/StuHuman/StuHumanMsgReleasedEvent'], function (HumanMsgReleasedEvent) {
    'use strict';

    return HumanMsgReleasedEvent;
});

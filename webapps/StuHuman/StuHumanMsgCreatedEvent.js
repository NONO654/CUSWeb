
define('DS/StuHuman/StuHumanMsgCreatedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanEvent.
	 * It occurs when a human message is created.
	 *
	 * @exports HumanMsgCreatedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.HumanEvent
     * @memberof STU
	 */
	var HumanMsgCreatedEvent = function () {

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

	HumanMsgCreatedEvent.prototype = new HumanEvent();
	HumanMsgCreatedEvent.prototype.constructor = HumanMsgCreatedEvent;
	HumanMsgCreatedEvent.prototype.type = 'HumanMsgCreatedEvent';

    /**
     * Set the message.
     *
     * @method
     * @private
     * @param {Object} iMessage
     */
	HumanMsgCreatedEvent.prototype.setMessage = function (iMessage) {
	    this.message = iMessage;
	};

    /**
     * Return the message.
     *
     * @method
     * @private
     * @return {Object}
     */
	HumanMsgCreatedEvent.prototype.getMessage = function () {
	    return this.message;
	};

	// Expose in STU namespace.
	STU.HumanMsgCreatedEvent = HumanMsgCreatedEvent;

	EventServices.registerEvent(HumanMsgCreatedEvent);

	return HumanMsgCreatedEvent;
});

define('StuHuman/StuHumanMsgCreatedEvent', ['DS/StuHuman/StuHumanMsgCreatedEvent'], function (HumanMsgCreatedEvent) {
    'use strict';

    return HumanMsgCreatedEvent;
});

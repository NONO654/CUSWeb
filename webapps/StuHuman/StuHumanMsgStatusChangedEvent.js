
define('DS/StuHuman/StuHumanMsgStatusChangedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanEvent.
	 * It occurs when a human message status is updated.
	 *
	 * @exports HumanMsgStatusChangedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.HumanEvent
     * @memberof STU
	 */
	var HumanMsgStatusChangedEvent = function () {

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

	HumanMsgStatusChangedEvent.prototype = new HumanEvent();
	HumanMsgStatusChangedEvent.prototype.constructor = HumanMsgStatusChangedEvent;
	HumanMsgStatusChangedEvent.prototype.type = 'HumanMsgStatusChangedEvent';

    /**
     * Set the message.
     *
     * @method
     * @private
     * @param {Object} iMessage
     */
	HumanMsgStatusChangedEvent.prototype.setMessage = function (iMessage) {
	    this.message = iMessage;
	};

    /**
     * Return the message.
     *
     * @method
     * @private
     * @return {Object}
     */
	HumanMsgStatusChangedEvent.prototype.getMessage = function () {
	    return this.message;
	};

	// Expose in STU namespace.
	STU.HumanMsgStatusChangedEvent = HumanMsgStatusChangedEvent;

	EventServices.registerEvent(HumanMsgStatusChangedEvent);

	return HumanMsgStatusChangedEvent;
});

define('StuHuman/StuHumanMsgStatusChangedEvent', ['DS/StuHuman/StuHumanMsgStatusChangedEvent'], function (HumanMsgStatusChangedEvent) {
    'use strict';

    return HumanMsgStatusChangedEvent;
});

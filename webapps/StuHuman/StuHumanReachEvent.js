
define('DS/StuHuman/StuHumanReachEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanReachEvent.
	 * It occurs when human have finished a goTo.<br/>
	 * 
	 * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanReachEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends STU.HumanEvent
     * @memberof STU
     * @alias STU.HumanReachEvent
	 */
	var HumanReachEvent = function () {

	    HumanEvent.call(this);

        /**
         * Location
         *
         * @member
	     * @private
         * @type {DSMath.Point|STU.PointActor}
         * @default undefined
         */
	    this.loc;
	};

	HumanReachEvent.prototype = new HumanEvent();
	HumanReachEvent.prototype.constructor = HumanReachEvent;
	HumanReachEvent.prototype.type = 'HumanReachEvent';

    /**
     * Set the location.
     *
     * @method
     * @private
     * @param {DSMath.Point|STU.PointActor} iLocation
     */
	HumanReachEvent.prototype.setLocation = function (iLocation) {
	    this.loc = iLocation;
	};

    /**
     * Return the location.
     *
     * @method
     * @public
     * @return {DSMath.Point|STU.PointActor}
     */
	HumanReachEvent.prototype.getLocation = function () {
	    return this.loc;
	};

	// Expose in STU namespace.
	STU.HumanReachEvent = HumanReachEvent;

	EventServices.registerEvent(HumanReachEvent);

	return HumanReachEvent;
});

define('StuHuman/StuHumanReachEvent', ['DS/StuHuman/StuHumanReachEvent'], function (HumanReachEvent) {
    'use strict';

    return HumanReachEvent;
});


define('DS/StuHuman/StuHumanGoToEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
    'use strict';

    /**
	 * Describe a STU.HumanGoToEvent.
	 * It occurs on human goTo call.<br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanGoToEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends STU.HumanEvent
     * @memberof STU
     * @alias STU.HumanGoToEvent
	 */
    var HumanGoToEvent = function () {

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

	HumanGoToEvent.prototype = new HumanEvent();
	HumanGoToEvent.prototype.constructor = HumanGoToEvent;
	HumanGoToEvent.prototype.type = 'HumanGoToEvent';

    /**
     * Set the location.
     *
     * @method
     * @private
     * @param {DSMath.Point|STU.PointActor} iLocation
     */
	HumanGoToEvent.prototype.setLocation = function (iLocation) {
	    this.loc = iLocation;
	};

    /**
     * Return the location.
     *
     * @method
     * @public
     * @return {DSMath.Point|STU.PointActor}
     */
	HumanGoToEvent.prototype.getLocation = function () {
	    return this.loc;
	};

	// Expose in STU namespace.
	STU.HumanGoToEvent = HumanGoToEvent;

	EventServices.registerEvent(HumanGoToEvent);

	return HumanGoToEvent;
});

define('StuHuman/StuHumanGoToEvent', ['DS/StuHuman/StuHumanGoToEvent'], function (HumanGoToEvent) {
    'use strict';

    return HumanGoToEvent;
});

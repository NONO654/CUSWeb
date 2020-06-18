
define('DS/StuHuman/StuHumanPathCompletedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanPathCompletedEvent.
	 * It occurs when human have finished to follow a path.<br/>
	 * 
	 * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanPathCompletedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends STU.HumanEvent
     * @memberof STU
     * @alias STU.HumanPathCompletedEvent
	 */
	var HumanPathCompletedEvent = function () {

	    HumanEvent.call(this);

        /**
         * Path
         *
         * @member
	     * @private
         * @type {Array<DSMath.Point>|STU.PathActor}
         * @default undefined
         */
	    this.path;
	};

	HumanPathCompletedEvent.prototype = new HumanEvent();
	HumanPathCompletedEvent.prototype.constructor = HumanPathCompletedEvent;
	HumanPathCompletedEvent.prototype.type = 'HumanPathCompletedEvent';

    /**
     * Set the path.
     *
     * @method
     * @private
     * @param {Array<DSMath.Point>|STU.PathActor} iPath
     */
	HumanPathCompletedEvent.prototype.setPath = function (iPath) {
	    this.path = iPath;
	};

    /**
     * Return the path.
     *
     * @method
     * @public
     * @return {Array<DSMath.Point>|STU.PathActor}
     */
	HumanPathCompletedEvent.prototype.getPath = function () {
	    return this.path;
	};

	// Expose in STU namespace.
	STU.HumanPathCompletedEvent = HumanPathCompletedEvent;

	EventServices.registerEvent(HumanPathCompletedEvent);

	return HumanPathCompletedEvent;
});

define('StuHuman/StuHumanPathCompletedEvent', ['DS/StuHuman/StuHumanPathCompletedEvent'], function (HumanPathCompletedEvent) {
    'use strict';

    return HumanPathCompletedEvent;
});

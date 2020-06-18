
define('DS/StuHuman/StuHumanFollowPathEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
    'use strict';

    /**
	 * Describe a STU.HumanFollowPathEvent.
	 * It occurs on human followPath call.<br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanFollowPathEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends STU.HumanEvent
     * @memberof STU
     * @alias STU.HumanFollowPathEvent
	 */
	var HumanFollowPathEvent = function () {

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

	HumanFollowPathEvent.prototype = new HumanEvent();
	HumanFollowPathEvent.prototype.constructor = HumanFollowPathEvent;
	HumanFollowPathEvent.prototype.type = 'HumanFollowPathEvent';

    /**
     * Set the path.
     *
     * @method
     * @private
     * @param {Array<DSMath.Point>|STU.PathActor} iPath
     */
	HumanFollowPathEvent.prototype.setPath = function (iPath) {
	    this.path = iPath;
	};

    /**
     * Return the path.
     *
     * @method
     * @public
     * @return {Array<DSMath.Point>|STU.PathActor}
     */
	HumanFollowPathEvent.prototype.getPath = function () {
	    return this.path;
	};

	// Expose in STU namespace.
	STU.HumanFollowPathEvent = HumanFollowPathEvent;

	EventServices.registerEvent(HumanFollowPathEvent);

	return HumanFollowPathEvent;
});

define('StuHuman/StuHumanFollowPathEvent', ['DS/StuHuman/StuHumanFollowPathEvent'], function (HumanFollowPathEvent) {
    'use strict';

    return HumanFollowPathEvent;
});

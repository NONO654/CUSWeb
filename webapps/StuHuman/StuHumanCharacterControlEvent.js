
define('DS/StuHuman/StuHumanCharacterControlEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanCharacterControlEvent.
	 * It occurs on human move call. <br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
	 *
	 * @exports HumanCharacterControlEvent
     * @class
	 * @constructor
     * @noinstancector
     * @public
	 * @extends STU.HumanEvent
     * @memberof STU
     * @alias STU.HumanCharacterControlEvent
	 */
	var HumanCharacterControlEvent = function () {

	    HumanEvent.call(this);

        /**
         * Direction
         *
         * @member
	     * @private
         * @type {DSMath.Vector2D}
         * @default undefined
         */
	    this.direction;

		/**
         * Orientation
         *
         * @member
	     * @private
         * @type {DSMath.Vector2D}
         * @default undefined
         */
	    this.orientation;
	};

	HumanCharacterControlEvent.prototype = new HumanEvent();
	HumanCharacterControlEvent.prototype.constructor = HumanCharacterControlEvent;
	HumanCharacterControlEvent.prototype.type = 'HumanCharacterControlEvent';

    /**
     * Set the direction.
     *
     * @method
     * @private
     * @param {DSMath.Vector2D} iDirection
     */
	HumanCharacterControlEvent.prototype.setDirection = function (iDirection) {
	    this.direction = iDirection;
	};

    /**
     * Return the direction.
     *
     * @method
     * @public
     * @return {DSMath.Vector2D}
     */
	HumanCharacterControlEvent.prototype.getDirection = function () {
	    return this.direction;
	};

    /**
     * Set the orientation.
     *
     * @method
     * @private
     * @param {DSMath.Vector2D} iHuman
     */
	HumanCharacterControlEvent.prototype.setOrientation = function (iOrientation) {
	    this.orientation = iOrientation;
	};

    /**
     * Return the orientation.
     *
     * @method
     * @public
     * @return {DSMath.Vector2D}
     */
	HumanCharacterControlEvent.prototype.getOrientation = function () {
	    return this.orientation;
	};

	// Expose in STU namespace.
	STU.HumanCharacterControlEvent = HumanCharacterControlEvent;

	EventServices.registerEvent(HumanCharacterControlEvent);

	return HumanCharacterControlEvent;
});

define('StuHuman/StuHumanCharacterControlEvent', ['DS/StuHuman/StuHumanCharacterControlEvent'], function (HumanCharacterControlEvent) {
    'use strict';

    return HumanCharacterControlEvent;
});

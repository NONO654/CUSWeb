
define('DS/StuHuman/StuHumanAnimationStoppedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
	'use strict';

	/**
	 * Describe a STU.HumanAnimationStoppedEvent.
	 * It occurs when a human animation task is stopped.
	 *
	 * @exports HumanAnimationStoppedEvent
     * @class
	 * @constructor
     * @noinstancector
     * @private
	 * @extends STU.HumanEvent
     * @memberof STU
	 */
	var HumanAnimationStoppedEvent = function () {

	    HumanEvent.call(this);

        /**
         * Animation
         *
         * @member
	     * @private
         * @type {number}
         * @default undefined
         */
	    this.animation;

	    /**
         * Animation finished
         *
         * @member
	     * @private
         * @type {Boolean}
         * @default false
         */
	    this.finished = false;
	};

	HumanAnimationStoppedEvent.prototype = new HumanEvent();
	HumanAnimationStoppedEvent.prototype.constructor = HumanAnimationStoppedEvent;
	HumanAnimationStoppedEvent.prototype.type = 'HumanAnimationStoppedEvent';

     /**
     * Set finished state.
     *
     * @method
     * @private
     * @param {Boolean} iFinished
     */
	HumanAnimationStoppedEvent.prototype.setFinished = function (iFinished) {
	    this.finished = iFinished;
	};

    /**
    * Get finished state.
    *
    * @method
    * @private
    * @return {Boolean}
    */
	HumanAnimationStoppedEvent.prototype.isFinished = function () {
	    return this.finished;
	};

    /**
     * Set the animation.
     *
     * @method
     * @private
     * @param {number} iAnimation
     */
	HumanAnimationStoppedEvent.prototype.setAnimation = function (iAnimation) {
	    this.animation = iAnimation;
	};

    /**
     * Return the animation.
     *
     * @method
     * @private
     * @return {number}
     */
	HumanAnimationStoppedEvent.prototype.getAnimation = function () {
	    return this.animation;
	};

	// Expose in STU namespace.
	STU.HumanAnimationStoppedEvent = HumanAnimationStoppedEvent;

	EventServices.registerEvent(HumanAnimationStoppedEvent);

	return HumanAnimationStoppedEvent;
});

define('StuHuman/StuHumanAnimationStoppedEvent', ['DS/StuHuman/StuHumanAnimationStoppedEvent'], function (HumanAnimationStoppedEvent) {
    'use strict';

    return HumanAnimationStoppedEvent;
});

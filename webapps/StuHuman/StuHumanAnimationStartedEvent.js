
define('DS/StuHuman/StuHumanAnimationStartedEvent',
    ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEventServices', 'DS/StuHuman/StuHumanEvent'],
    function (STU, EventServices, HumanEvent) {
    'use strict';

    /**
        * Describe a STU.HumanAnimationStartedEvent.
        * It occurs when a human animation task is Started.
        *
        * @exports HumanAnimationStartedEvent
        * @class
        * @constructor
        * @noinstancector
        * @private
        * @extends STU.HumanEvent
        * @memberof STU
        */
    var HumanAnimationStartedEvent = function () {

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
            * Animation blended
            *
            * @member
	        * @private
            * @type {Boolean}
            * @default false
            */
        this.blended = false;
    };

    HumanAnimationStartedEvent.prototype = new HumanEvent();
    HumanAnimationStartedEvent.prototype.constructor = HumanAnimationStartedEvent;
    HumanAnimationStartedEvent.prototype.type = 'HumanAnimationStartedEvent';

    /**
        * Set the animation.
        *
        * @method
        * @private
        * @param {number} iAnimation
        */
    HumanAnimationStartedEvent.prototype.setAnimation = function (iAnimation) {
        this.animation = iAnimation;
    };

    /**
        * Return the animation.
        *
        * @method
        * @private
        * @return {number}
        */
    HumanAnimationStartedEvent.prototype.getAnimation = function () {
        return this.animation;
    };

    /**
    * Set blended state.
    *
    * @method
    * @private
    * @param {Boolean} iFinished
    */
    HumanAnimationStartedEvent.prototype.setBlended = function (iFinished) {
        this.blended = iFinished;
    };

    /**
    * Get blended state.
    *
    * @method
    * @private
    * @return {Boolean}
    */
    HumanAnimationStartedEvent.prototype.isBlended = function () {
        return this.blended;
    };

    // Expose in STU namespace.
    STU.HumanAnimationStartedEvent = HumanAnimationStartedEvent;

    EventServices.registerEvent(HumanAnimationStartedEvent);

    return HumanAnimationStartedEvent;
});

define('StuHuman/StuHumanAnimationStartedEvent', ['DS/StuHuman/StuHumanAnimationStartedEvent'], function (HumanAnimationStartedEvent) {
    'use strict';

    return HumanAnimationStartedEvent;
});

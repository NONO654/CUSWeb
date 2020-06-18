/// <amd-module name="DS/StuMiscContent/StuExperienceAnimation"/>
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
define("DS/StuMiscContent/StuExperienceAnimation", ["require", "exports", "DS/StuCore/StuContext", "DS/StuModel/StuAnimation"], function (require, exports, STU, Animation) {
    "use strict";
    /**
    *
    * @exports ExperienceAnimation
    * @class
    * @private
    * @extends STU.Animation
    * @memberof STU
    * @alias STU.ExperienceAnimation
    */
    var ExperienceAnimation = (function (_super) {
        __extends(ExperienceAnimation, _super);
        function ExperienceAnimation() {
            var _this = _super !== null && _super.apply(this, arguments) || this;
            _this.name = 'ExperienceAnimation';
            _this.featureCatalog = '3DExperience.feat';
            _this.featureStartup = 'Animation_Spec';
            return _this;
        }
        Object.defineProperty(ExperienceAnimation.prototype, "duration", {
            /**
            * Get duration
            *
            * @member
            * @instance
            * @name duration
            * @private
            * @type {number}
            * @memberOf STU.ExperienceAnimation
            */
            get: function () {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    return this.CATICXPAnimation.getDuration();
                }
            },
            set: function (iDuration) { },
            enumerable: true,
            configurable: true
        });
        /**
        * Plays the animation. <br/>
        * If already playing, does nothing. <br/>
        * It takes into account the various parameters defined on.
        *
        * @method
        * @private
        */
        ExperienceAnimation.prototype.play = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                this.CATICXPAnimation.play();
            }
        };
        ;
        /**
        * Pauses the animation if playing.
        *
        * @method
        * @private
        */
        ExperienceAnimation.prototype.pause = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                this.CATICXPAnimation.pause();
            }
        };
        ;
        /**
        * Stops the animation.
        *
        * @method
        * @private
        */
        ExperienceAnimation.prototype.stop = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                this.CATICXPAnimation.stop();
            }
        };
        ;
        /**
         * Tells if the animation is playing
         *
         * @private
         * @return {boolean}
         */
        ExperienceAnimation.prototype.isPlaying = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                return this.CATICXPAnimation.isPlaying();
            }
        };
        ;
        /**
         * Tells if the animation is paused
         *
         * @private
         * @return {boolean}
         */
        ExperienceAnimation.prototype.isPaused = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                return this.CATICXPAnimation.isPaused();
            }
        };
        ;
        /**
         * Tells if the animation is playing backward
         *
         * @private
         * @return {boolean}
         */
        ExperienceAnimation.prototype.isRewinding = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                return this.CATICXPAnimation.isRewinding();
            }
        };
        /**
         * Moves the animation cursor to the given time
         *
         * @private
         * @param {number} iTime in seconds
         */
        ExperienceAnimation.prototype.setTime = function (iTime) {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                this.CATICXPAnimation.setTime(iTime);
            }
        };
        /**
         * Gets the current animation time
         *
         * @private
         * @return {number}
         */
        ExperienceAnimation.prototype.getTime = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                return this.CATICXPAnimation.getTime();
            }
        };
        /**
        * Returns the list of impacted objects
        *
        * @method
        * @private
        * @return {Array.<STU.Actor>}
        */
        ExperienceAnimation.prototype.getAnimatedObjects = function () {
            if (this.CATICXPAnimation !== undefined && this.CATICXPAnimation !== null) {
                return this.CATICXPAnimation.getAnimatedObjects();
            }
        };
        ;
        ExperienceAnimation.prototype.doDispatchEvent = function (iEventName) {
            var event = new STU[iEventName + "Event"]();
            this.dispatchEvent(event);
        };
        return ExperienceAnimation;
    }(Animation));
    STU["ExperienceAnimation"] = ExperienceAnimation;
    return ExperienceAnimation;
});

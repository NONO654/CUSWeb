/// <amd-module name="DS/StuModel/StuAnimation"/>
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
define("DS/StuModel/StuAnimation", ["require", "exports", "DS/StuCore/StuContext", "DS/StuModel/StuInstance"], function (require, exports, STU, Instance) {
    "use strict";
    /**
     * Base class for animation classes.
     *
     * <p>It is used for STU.ProductAnimation.</p>
     *
     * @public
     * @exports Animation
     * @memberof STU
     * @class
     * @extends {STU.Instance}
     * @alias STU.Animation
     * @constructor
     * @noinstancector
     */
    var Animation = (function (_super) {
        __extends(Animation, _super);
        function Animation() {
            var _this = _super.call(this) || this;
            /**
             * Animation duration in seconds starting from 0.
             * Duration is given regardless of speed factor
             *
             * @public
             * @type {number}
             * @name STU.Animation#duration
             */
            _this.duration = 0;
            /**
             * If true, the animation will play backward, from the end the beginning
             *
             * @public
             * @type {boolean}
             * @name STU.Animation#reverse
             */
            _this._reverse = false;
            /**
             * If true, the animation will play forward and then backward once
             * (or reverse if the reverse property is true)
             *
             * @public
             * @type {boolean}
               * @name STU.Animation#bounce
             */
            _this._bounce = false;
            /**
             * If true, the animation will play until it is stopped
             *
             * @public
             * @type {boolean}
               * @name STU.Animation#loop
             */
            _this._loop = false;
            /**
             * Speed factor applied to the animation during a play.
             * Must be > 0
             *
             * A value of 1 will play at normal speed
             * A value of 2 will play twice faster than normal speed
             *
             * @public
             * @type {number}
               * @name STU.Animation#speedFactor
             */
            _this._speedFactor = 1.0;
            return _this;
        }
        Object.defineProperty(Animation.prototype, "reverse", {
            get: function () {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    return this.CATI3DExperienceObject.GetValueByName("reverse");
                }
            },
            set: function (iReverse) {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    this.CATI3DExperienceObject.SetValueByName("reverse", iReverse);
                }
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Animation.prototype, "bounce", {
            get: function () {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    return this.CATI3DExperienceObject.GetValueByName("bounce");
                }
            },
            set: function (iBounce) {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    this.CATI3DExperienceObject.SetValueByName("bounce", iBounce);
                }
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Animation.prototype, "loop", {
            get: function () {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    return this.CATI3DExperienceObject.GetValueByName("loop");
                }
            },
            set: function (iLoop) {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    this.CATI3DExperienceObject.SetValueByName("loop", iLoop);
                }
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Animation.prototype, "speedFactor", {
            get: function () {
                if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                    return this.CATI3DExperienceObject.GetValueByName("speedFactor");
                }
            },
            set: function (iSpeed) {
                if (iSpeed > 0) {
                    if (this.CATI3DExperienceObject !== undefined && this.CATI3DExperienceObject !== null) {
                        this.CATI3DExperienceObject.SetValueByName("speedFactor", iSpeed);
                    }
                }
            },
            enumerable: true,
            configurable: true
        });
        /**
        * Plays the animation. <br/>
        * If already playing, does nothing. <br/>
        * It takes into account the various parameters defined on.
        *
        * @public
        * @name STU.Animation#play
        * @function
        */
        Animation.prototype.play = function () { throw new Error("not implemented"); };
        ;
        /**
        * Pauses the animation if playing.
        *
        * @public
        * @name STU.Animation#pause
        * @function
        */
        Animation.prototype.pause = function () { throw new Error("not implemented"); };
        ;
        /**
        * Stops the animation.
        *
        * @public
        * @name STU.Animation#stop
        * @function
        */
        Animation.prototype.stop = function () { throw new Error("not implemented"); };
        ;
        /**
         * Tells if the animation is playing
         *
         * @public
         * @return {boolean}
         * @name STU.Animation#isPlaying
         * @function
         */
        Animation.prototype.isPlaying = function () { throw new Error("not implemented"); };
        ;
        /**
         * Tells if the animation is paused
         *
         * @public
         * @return {boolean}
           * @name STU.Animation#isPaused
         * @function
         */
        Animation.prototype.isPaused = function () { throw new Error("not implemented"); };
        ;
        /**
         * Tells if the animation is playing backward
         *
         * @public
         * @return {boolean}
           * @name STU.Animation#isPlayingBackward
         * @function
         */
        Animation.prototype.isPlayingBackward = function () { throw new Error("not implemented"); };
        ;
        /**
         * Returns the current time of the animation in seconds
         *
         * @public
         * @return {number}
           * @name STU.Animation#getTime
         * @function
         */
        Animation.prototype.getTime = function () { throw new Error("not implemented"); };
        ;
        /**
         * Sets the current time of the animation to the given time
         *
         * @public
         * @param {number} iTime the new time of the animation (in seconds)
           * @name STU.Animation#setTime
         * @function
         */
        Animation.prototype.setTime = function (iTime) { throw new Error("not implemented"); };
        ;
        /**
        * Returns the list of impacted objects
        *
        * @public
        * @return {Array.<STU.Actor>}
        * @name STU.Animation#getAnimatedObjects
        * @function
        */
        Animation.prototype.getAnimatedObjects = function () { throw new Error("not implemented"); };
        ;
        return Animation;
    }(Instance));
    STU["Animation"] = Animation;
    return Animation;
});

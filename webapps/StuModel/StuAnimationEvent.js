/// <amd-module name="DS/StuModel/StuAnimationEvent"/>
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
define("DS/StuModel/StuAnimationEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEvent"], function (require, exports, STU, Event) {
    "use strict";
    /**
     * Base class of animation events
     *
     * @public
     * @exports AnimationEvent
     * @memberof STU
     * @class
     * @extends {EP.Event}
     * @constructor
     * @noinstancector
     * @alias STU.AnimationEvent
     */
    var AnimationEvent = (function (_super) {
        __extends(AnimationEvent, _super);
        function AnimationEvent(iAnimation) {
            var _this = _super.call(this) || this;
            /**
             * Product animation related to the animation event
             *
             * @public
             * @type {STU.Animation}
             * @name STU.AnimationEvent#name
             */
            _this.animation = null;
            _this.animation = iAnimation;
            return _this;
        }
        return AnimationEvent;
    }(Event));
    AnimationEvent.prototype.type = "AnimationEvent";
    STU["AnimationEvent"] = AnimationEvent;
    return AnimationEvent;
});

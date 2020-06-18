/// <amd-module name="DS/StuModel/StuAnimationResumedEvent"/>
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
define("DS/StuModel/StuAnimationResumedEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEventServices", "DS/StuModel/StuAnimationEvent"], function (require, exports, STU, EPEventServices, AnimationEvent) {
    "use strict";
    /**
     * Event fired when an animation is resumed from a paused state
     *
     * @public
     * @class AnimationResumedEvent
     * @extends {STU.AnimationEvent}
     * @memberof STU
     * @constructor
     * @noinstancector
     */
    var AnimationResumedEvent = (function (_super) {
        __extends(AnimationResumedEvent, _super);
        function AnimationResumedEvent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AnimationResumedEvent;
    }(AnimationEvent));
    AnimationResumedEvent.prototype.type = "AnimationResumedEvent";
    EPEventServices.registerEvent(AnimationResumedEvent);
    STU["AnimationResumedEvent"] = AnimationResumedEvent;
    return AnimationResumedEvent;
});

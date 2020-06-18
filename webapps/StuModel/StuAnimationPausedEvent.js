/// <amd-module name="DS/StuModel/StuAnimationPausedEvent"/>
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
define("DS/StuModel/StuAnimationPausedEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEventServices", "DS/StuModel/StuAnimationEvent"], function (require, exports, STU, EPEventServices, AnimationEvent) {
    "use strict";
    /**
     * Event fired when an animation is paused
     *
     * @public
     * @class
     * @extends {STU.AnimationEvent}
     * @memberof STU
     * @exports AnimationPausedEvent
     * @constructor
     * @noinstancector
     * @alias STU.AnimationPausedEvent
     */
    var AnimationPausedEvent = (function (_super) {
        __extends(AnimationPausedEvent, _super);
        function AnimationPausedEvent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AnimationPausedEvent;
    }(AnimationEvent));
    AnimationPausedEvent.prototype.type = "AnimationPausedEvent";
    EPEventServices.registerEvent(AnimationPausedEvent);
    STU["AnimationPausedEvent"] = AnimationPausedEvent;
    return AnimationPausedEvent;
});

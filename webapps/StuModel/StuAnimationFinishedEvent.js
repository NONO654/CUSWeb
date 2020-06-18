/// <amd-module name="DS/StuModel/StuAnimationFinishedEvent"/>
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
define("DS/StuModel/StuAnimationFinishedEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEventServices", "DS/StuModel/StuAnimationEvent"], function (require, exports, STU, EPEventServices, AnimationEvent) {
    "use strict";
    /**
     * Event fired when an animation has finished to play
     *
     * @public
     * @class
     * @extends {STU.AnimationEvent}
     * @memberof STU
     * @exports AnimationFinishedEvent
     * @constructor
     * @noinstancector
     * @alias STU.AnimationFinishedEvent
     */
    var AnimationFinishedEvent = (function (_super) {
        __extends(AnimationFinishedEvent, _super);
        function AnimationFinishedEvent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AnimationFinishedEvent;
    }(AnimationEvent));
    AnimationFinishedEvent.prototype.type = "AnimationFinishedEvent";
    EPEventServices.registerEvent(AnimationFinishedEvent);
    STU["AnimationFinishedEvent"] = AnimationFinishedEvent;
    return AnimationFinishedEvent;
});

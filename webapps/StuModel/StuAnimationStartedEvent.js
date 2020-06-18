/// <amd-module name="DS/StuModel/StuAnimationStartedEvent"/>
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
define("DS/StuModel/StuAnimationStartedEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEventServices", "DS/StuModel/StuAnimationEvent"], function (require, exports, STU, EPEventServices, AnimationEvent) {
    "use strict";
    /**
     * Event fired when an animation starts to play
     *
     * @public
     * @class
     * @extends {STU.AnimationEvent}
     * @memberof STU
     * @exports AnimationStartedEvent
     * @constructor
     * @noinstancector
     * @alias STU.AnimationStartedEvent
     */
    var AnimationStartedEvent = (function (_super) {
        __extends(AnimationStartedEvent, _super);
        function AnimationStartedEvent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AnimationStartedEvent;
    }(AnimationEvent));
    AnimationStartedEvent.prototype.type = "AnimationStartedEvent";
    EPEventServices.registerEvent(AnimationStartedEvent);
    STU["AnimationStartedEvent"] = AnimationStartedEvent;
    return AnimationStartedEvent;
});

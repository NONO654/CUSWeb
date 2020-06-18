/// <amd-module name="DS/StuModel/StuAnimationStoppedEvent"/>
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
define("DS/StuModel/StuAnimationStoppedEvent", ["require", "exports", "DS/StuCore/StuContext", "DS/EPEventServices/EPEventServices", "DS/StuModel/StuAnimationEvent"], function (require, exports, STU, EPEventServices, AnimationEvent) {
    "use strict";
    /**
     * Event fired when an animation is stopped
     *
     * @public
     * @class
     * @extends {STU.AnimationEvent}
     * @memberof STU
     * @exports AnimationStoppedEvent
     * @constructor
     * @noinstancector
     * @alias STU.AnimationStoppedEvent
     */
    var AnimationStoppedEvent = (function (_super) {
        __extends(AnimationStoppedEvent, _super);
        function AnimationStoppedEvent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AnimationStoppedEvent;
    }(AnimationEvent));
    AnimationStoppedEvent.prototype.type = "AnimationStoppedEvent";
    EPEventServices.registerEvent(AnimationStoppedEvent);
    STU["AnimationStoppedEvent"] = AnimationStoppedEvent;
    return AnimationStoppedEvent;
});

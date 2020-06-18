
define('DS/StuCID/StuImageButton3DActor', ['DS/StuCore/StuContext',
                                            'DS/StuCID/StuUIActor3D',
                                            'DS/EPEventServices/EPEvent',
                                            'DS/EP/EP'], function (STU, UIActor3D, Event, EP) {
    'use strict';

    var geterSeter = function (self, varName) {
        if (!STU.isEKIntegrationActive()) {
            Object.defineProperty(self, varName, {
                enumerable: true,
                configurable: true,
                get: function () {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        return self.CATI3DExperienceObject.GetValueByName(varName);
                    }
                },
                set: function (value) {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        self.CATI3DExperienceObject.SetValueByName(varName, value);
                    }
                }
            });
        }
    };


    /*
    * @private
    * DoubleReleaseEvent
    */
    var UIDoubleReleaseEvent = function () {
        Event.call(this);
    };
    UIDoubleReleaseEvent.prototype = new Event();
    UIDoubleReleaseEvent.prototype.constructor = UIDoubleReleaseEvent;
    UIDoubleReleaseEvent.prototype.type = 'UIDoubleReleaseEvent';
    // Expose in STU namespace.
    STU.UIDoubleReleaseEvent = UIDoubleReleaseEvent;
    EP.EventServices.registerEvent(UIDoubleReleaseEvent);

    /*
    * @private
    * RightClickEvent
    */
    var UIRightClickEvent = function () {
        Event.call(this);
    };
    UIRightClickEvent.prototype = new Event();
    UIRightClickEvent.prototype.constructor = UIRightClickEvent;
    UIRightClickEvent.prototype.type = 'UIRightClickEvent';
    // Expose in STU namespace.
    STU.UIRightClickEvent = UIRightClickEvent;
    EP.EventServices.registerEvent(UIRightClickEvent);

    /**
    * The UIDoubleClick event is sent when the user double clicks on a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * <br>Note: when the user double clicks on a UI Actor, both UIClick (for the first click) and UIDoubleClick (for the second click) are sent.
    *
    * @example
    * beScript.onUIDoubleClick = function(event) {
	*   console.log("doubleclick");
    * }
    *
    * @exports UIDoubleClickEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIDoubleClickEvent
    */
    var UIDoubleClickEvent = function () {
        Event.call(this);
    };
    UIDoubleClickEvent.prototype = new Event();
    UIDoubleClickEvent.prototype.constructor = UIDoubleClickEvent;
    UIDoubleClickEvent.prototype.type = 'UIDoubleClickEvent';
    // Expose in STU namespace.
    STU.UIDoubleClickEvent = UIDoubleClickEvent;
    EP.EventServices.registerEvent(UIDoubleClickEvent);


    /**
    * The UIClick event is sent when the user clicks on a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIClick = function(event) {
	*   console.log("click");
    * }
    *
    * @exports UIClickEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIClickEvent
    */
    var UIClickEvent = function () {
        Event.call(this);
    };

    UIClickEvent.prototype = new Event();
    UIClickEvent.prototype.constructor = UIClickEvent;
    UIClickEvent.prototype.type = 'UIClickEvent';

    // Expose in STU namespace.
    STU.UIClickEvent = UIClickEvent;
    EP.EventServices.registerEvent(UIClickEvent);


    /**
    * The UIPress event is sent when the left mouse button is pressed over a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIPress = function(event) {
	*   console.log("press");
    * }
    *
    * @exports UIPressEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIPressEvent
    */
    var UIPressEvent = function () {
        Event.call(this);
    };

    UIPressEvent.prototype = new Event();
    UIPressEvent.prototype.constructor = UIPressEvent;
    UIPressEvent.prototype.type = 'UIPressEvent';

    // Expose in STU namespace.
    STU.UIPressEvent = UIPressEvent;
    EP.EventServices.registerEvent(UIPressEvent);


   /**
    * The UIRelease event is sent when the left mouse button is released over a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIRelease = function(event) {
	*   console.log("release");
    * }
    *
    * @exports UIReleaseEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIReleaseEvent
    */
    var UIReleaseEvent = function () {
        Event.call(this);
    };

    UIReleaseEvent.prototype = new Event();
    UIReleaseEvent.prototype.constructor = UIReleaseEvent;
    UIReleaseEvent.prototype.type = 'UIReleaseEvent';

    // Expose in STU namespace.
    STU.UIReleaseEvent = UIReleaseEvent;
    EP.EventServices.registerEvent(UIReleaseEvent);


    /**
    * The UIEnter event is sent when the mouse cursor is getting over a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIEnter = function(event) {
	*   console.log("enter");
    * }
    *
    * @exports UIEnterEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIEnterEvent
    */
    var UIEnterEvent = function () {
        Event.call(this);
    };

    UIEnterEvent.prototype = new Event();
    UIEnterEvent.prototype.constructor = UIEnterEvent;
    UIEnterEvent.prototype.type = 'UIEnterEvent';

    // Expose in STU namespace.
    STU.UIEnterEvent = UIEnterEvent;
    EP.EventServices.registerEvent(UIEnterEvent);


    /**
    * The UIExit event is sent when the mouse cursor is getting out of a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIExit = function(event) {
	*   console.log("exit");
    * }
    *
    * @exports UIExitEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIExitEvent
    */
    var UIExitEvent = function () {
        Event.call(this);
    };

    UIExitEvent.prototype = new Event();
    UIExitEvent.prototype.constructor = UIExitEvent;
    UIExitEvent.prototype.type = 'UIExitEvent';

    // Expose in STU namespace.
    STU.UIExitEvent = UIExitEvent;
    EP.EventServices.registerEvent(UIExitEvent);


    /**
    * The UIHover event is sent when the mouse cursor is moving over a UI Actor.
    *
    * This event is dispatched globally on the EP.EventServices and locally on the involved {@link STU.UIActor3D}.
    *
    * @example
    * beScript.onUIHover = function(event) {
	*   console.log("hover");
    * }
    *
    * @exports UIHoverEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIHoverEvent
    */
    var UIHoverEvent = function () {
        Event.call(this);
    };
    UIHoverEvent.prototype = new Event();
    UIHoverEvent.prototype.constructor = UIHoverEvent;
    UIHoverEvent.prototype.type = 'UIHoverEvent';

    // Expose in STU namespace.
    STU.UIHoverEvent = UIHoverEvent;
    EP.EventServices.registerEvent(UIHoverEvent);


    /**
    * Describe a button in the 3D with a customizable representation : a different image can be associated to the disabled, pressed, hovered and normal states. <br/>
    * The image button actor emits the following events : {@link STU.UIClickEvent}, {@link STU.UIDoubleClickEvent}, {@link STU.UIEnterEvent}, 
    * {@link STU.UIExitEvent}, {@link STU.UIPressEvent}, {@link STU.UIReleaseEvent}, {@link STU.UIHoverEvent}.
    *
    * @exports ImageButton3DActor
    * @class
    * @constructor
    * @noinstancector 
    * @public
    * @extends STU.UIActor3D
    * @memberof STU
    * @alias STU.ImageButton3DActor
    */
    var ImageButton3DActor = function () {

        UIActor3D.call(this);
        this.name = "ImageButton3DActor";

        /**
        * Get/Set normalImage
        *
        * @member
        * @instance
        * @name normalImage
        * @public
        * @type {STU.PictureResource}
        * @memberOf STU.ImageButton3DActor
        */
        geterSeter(this, "normalImage");

        /**
        * Get/Set disabledImage
        *
        * @member
        * @instance
        * @name disabledImage
        * @public
        * @type {STU.PictureResource}
        * @memberOf STU.ImageButton3DActor
        */
        geterSeter(this, "disabledImage");

        /**
        * Get/Set hoveredImage
        *
        * @member
        * @instance
        * @name hoveredImage
        * @public
        * @type {STU.PictureResource}
        * @memberOf STU.ImageButton3DActor
        */
        geterSeter(this, "hoveredImage");

        /**
        * Get/Set pressedImage
        *
        * @member
        * @instance
        * @name pressedImage
        * @public
        * @type {STU.PictureResource}
        * @memberOf STU.ImageButton3DActor
        */
        geterSeter(this, "pressedImage");

    };

    ImageButton3DActor.prototype = new UIActor3D();
    ImageButton3DActor.prototype.constructor = ImageButton3DActor;

    // Expose in STU namespace.
    STU.ImageButton3DActor = ImageButton3DActor;

    return ImageButton3DActor;
});

define('StuCID/StuImageButton3DActor', ['DS/StuCID/StuImageButton3DActor'], function (ImageButton3DActor) {
    'use strict';

    return ImageButton3DActor;
});



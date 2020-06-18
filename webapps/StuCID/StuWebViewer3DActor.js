define('DS/StuCID/StuWebViewer3DActor', ['DS/StuCore/StuContext',
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

    /**
    * @exports UIWebMessageReceivedEvent
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends {EP.Event}
    * @memberOf STU
    * @alias STU.UIWebMessageReceivedEvent
    * @see STU.WebViewer3DActor
    */
    var UIWebMessageReceivedEvent = function (iMessage) {
        Event.call(this);
        this.message = iMessage;
    };

    UIWebMessageReceivedEvent.prototype = new Event();
    UIWebMessageReceivedEvent.prototype.constructor = UIWebMessageReceivedEvent;
    UIWebMessageReceivedEvent.prototype.type = 'UIWebMessageReceivedEvent';

    // Expose in STU namespace.
    STU.UIWebMessageReceivedEvent = UIWebMessageReceivedEvent;
    EP.EventServices.registerEvent(UIWebMessageReceivedEvent);

    /**
    * Describe a web viewer in the 3D. <br/>
    * The web viewer actor emits the {@link STU.UIWebMessageReceivedEvent} event.
    *
    * @exports WebViewer3DActor
    * @class
    * @constructor
    * @noinstancector 
    * @public
    * @extends STU.UIActor3D
    * @memberof STU
    * @alias STU.WebViewer3DActor
    */
    var WebViewer3DActor = function () {

        UIActor3D.call(this);
        this.name = "WebViewer3DActor";
        this.CATICXPWebViewer;

        /**
        * Get/Set url
        *
        * @member
        * @instance
        * @name url
        * @public
        * @type {string}
        * @memberOf STU.WebViewer3DActor
        */
        geterSeter(this, "url");

    };

    WebViewer3DActor.prototype = new UIActor3D();
    WebViewer3DActor.prototype.constructor = WebViewer3DActor;


    /**
    * Execute a JS script in the web viewer
    *
    * @method
    * @public
    * @param {string} iScript script to execute in the web viewer
    */
    WebViewer3DActor.prototype.executeScript = function (iScript) {
        if (this.CATICXPWebViewer !== null && this.CATICXPWebViewer !== undefined) {
            this.CATICXPWebViewer.executeScript(iScript);
        }
    };

    // Expose in STU namespace.
    STU.WebViewer3DActor = WebViewer3DActor;

    return WebViewer3DActor;
});

define('StuCID/StuWebViewer3DActor', ['DS/StuCID/StuWebViewer3DActor'], function (WebViewer3DActor) {
    'use strict';

    return WebViewer3DActor;
});


define('DS/StuModel/StuEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
     * @exports Event
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Instance
     * @memberof STU
	 * @alias STU.Event
     */
    var Event = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "Event";
    };

    Event.prototype = new Instance();
    Event.prototype.constructor = Event;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} instance object corresponding to the experience
    */
    Event.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };

    /**
     * @private
     */
    Event.prototype.activate = function () {
    };

        

    // Expose in STU namespace.
    STU.Event = Event;

    return Event;
});

define('StuModel/StuEvent', ['DS/StuModel/StuEvent'], function (Event) {
    'use strict';

    return Event;
});

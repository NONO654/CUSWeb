define('DS/StudioIV/StuARMarkerActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
    'use strict';

    /**
     * Describes a augmented reality marker.<br/>
     * 
     * To use it, you must have the following role: VRS - Marketing Experience Scripter
     *
     * @exports ARMarkerActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Actor3D
     * @memberof STU
	 * @alias STU.ARMarkerActor
     */
    var ARMarkerActor = function () {

        Actor3D.call(this);

        /**
         * Marker size in millimeters 
         * @public
         * @type {number}
         */
        this.size = 180;

        /**
         * Pattern to track
         * @public
         * @type {STU.ARMarkerActor.Patterns}
         */
        this.pattern = 0;
    };

    /**
    * An enumeration of supported patterns<br/>
    * @public
    * @enum {number}
    */
    ARMarkerActor.Patterns = {
        'CreativeExperience':0,
        '3DSCompass':1,
        '3DXPlatform':2,
        'Imagine':3
    };


    ARMarkerActor.prototype = new Actor3D();
    ARMarkerActor.prototype.constructor = ARMarkerActor;

    // Expose in STU namespace.
    STU.ARMarkerActor = ARMarkerActor;

    return ARMarkerActor;
});

define('StudioIV/StuARMarkerActor', ['DS/StudioIV/StuARMarkerActor'], function (ARMarkerActor) {
    'use strict';

    return ARMarkerActor;
});

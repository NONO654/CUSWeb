define('DS/StuMiscContent/StuStreamBasedActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function(STU, Actor3D) {
    'use strict';

    var geterSeter = function(self, varName) {
        if (!STU.isEKIntegrationActive()) {
            Object.defineProperty(self, varName, {
                enumerable: true,
                configurable: true,
                get: function() {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        return self.CATI3DExperienceObject.GetValueByName(varName);
                    }
                },
                set: function(value) {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        self.CATI3DExperienceObject.SetValueByName(varName, value);
                    }
                }
            });
        }
    };

    /**
     * Describe an actor loading its 3D representation from a file.
     *
     * @exports StreamBasedActor
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Actor3D
     * @memberof STU
     * @alias STU.StreamBasedActor
     */
    var StreamBasedActor = function() {

        Actor3D.call(this);
        this.name = 'StreamBasedActor';

        /**
         * Enable or disable the light actor
         *
         * @member
         * @instance
         * @name _powered
         * @private
         * @type {number}
         * @memberOf STU.StreamBasedActor
         */
        geterSeter(this, "filePath");
    };

    StreamBasedActor.prototype = new Actor3D();
    StreamBasedActor.prototype.constructor = StreamBasedActor;


    // Expose in STU namespace.
    STU.StreamBasedActor = StreamBasedActor;

    return StreamBasedActor;
});

define('StuMiscContent/StuStreamBasedActor', ['DS/StuMiscContent/StuStreamBasedActor'], function(StreamBasedActor) {
    'use strict';

    return StreamBasedActor;
});

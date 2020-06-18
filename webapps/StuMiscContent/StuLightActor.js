define('DS/StuMiscContent/StuLightActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D'], function(STU, Actor3D) {
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
     * Describe a light object.
     *
     * @exports LightActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.Actor3D
     * @memberof STU
     * @alias STU.LightActor
     */
    var LightActor = function() {

        Actor3D.call(this);
        this.name = 'LightActor';

        /**
         * Enable or disable the light actor
         *
         * @member
         * @instance
         * @name _powered
         * @private
         * @type {number}
         * @memberOf STU.LightActor
         */
        geterSeter(this, "_powered");
    };

    LightActor.prototype = new Actor3D();
    LightActor.prototype.constructor = LightActor;


    /**
     * @return {boolean}
     * @private
     */
    LightActor.prototype.powerOn = function() {
        console.log("LightActor.prototype.powerOn");
        this._powered = true;
    };
    /**
     * @return {boolean}
     * @private
     */
    LightActor.prototype.powerOff = function() {
        console.log("LightActor.prototype.powerOff");
        this._powered = false;
    };
    /**
     * @return {boolean}
     * @private
     */
    LightActor.prototype.isOn = function() {
        console.log("LightActor.prototype.isOn");
        return this._powered;
    };
    /**
     * @return {boolean}
     * @private
     */
    LightActor.prototype.isOff = function() {
        console.log("LightActor.prototype.isOff");
        return !this._powered;
    };

    // Expose in STU namespace.
    STU.LightActor = LightActor;

    return LightActor;
});

define('StuMiscContent/StuLightActor', ['DS/StuMiscContent/StuLightActor'], function(LightActor) {
    'use strict';

    return LightActor;
});

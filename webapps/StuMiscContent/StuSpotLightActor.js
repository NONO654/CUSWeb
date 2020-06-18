define('DS/StuMiscContent/StuSpotLightActor', ['DS/StuCore/StuContext', 'DS/StuMiscContent/StuLightActor', 'DS/StuRenderEngine/StuColor'], function(STU, LightActor, Color) {
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
     * @exports SpotLightActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.LightActor 
     * @memberof STU
     * @alias STU.SpotLightActor
     */
    var SpotLightActor = function() {
        LightActor.call(this);
        this.name = 'SpotLightActor';

        this._props = [];


        /**
         * Get/Set spot light outer angle in degrees
         *
         * @member
         * @instance
         * @name outerAngle
         * @public
         * @type {number}
         * @memberOf STU.SpotLightActor
         */
        geterSeter(this, "outerAngle");

        /**
         * Get/Set spot inner angle in degrees
         *
         * @member
         * @instance
         * @name innerAngle
         * @public
         * @type {number}
         * @memberOf STU.SpotLightActor
         */
        geterSeter(this, "innerAngle");

        /**
         * Get/Set spot power 
         *
         * @member
         * @instance
         * @name power
         * @public
         * @type {number}
         * @memberOf STU.SpotLightActor
         */
        geterSeter(this, "power");

        /**
         * Get/Set cast shadows flag 
         *
         * @member
         * @instance
         * @name castShadows
         * @public
         * @type {boolean}
         * @memberOf STU.SpotLightActor
         */
        geterSeter(this, "castShadows");

        /**
         * Get/Set physical flag 
         *
         * @member
         * @instance
         * @name physical
         * @public
         * @type {boolean}
         * @memberOf STU.SpotLightActor
         */
        geterSeter(this, "physical");

        /**
         * Get/Set light diffuseColor 
         *
         * @member
         * @instance
         * @name diffuseColor
         * @public
         * @type {STU.Color}
         * @memberOf STU.SpotLightActor
         */
        if (!STU.isEKIntegrationActive()) {
            this._diffuseColor = null;
            Object.defineProperty(this, "diffuseColor", {
                enumerable: true,
                configurable: true,
                get: function() {
                    var diffuseColor = this._diffuseColor;

                    if (diffuseColor !== undefined && diffuseColor !== null &&
                        diffuseColor.CATI3DExperienceObject !== undefined && diffuseColor.CATI3DExperienceObject !== null) {
                        var r = diffuseColor.CATI3DExperienceObject.GetValueByName("r");
                        var g = diffuseColor.CATI3DExperienceObject.GetValueByName("g");
                        var b = diffuseColor.CATI3DExperienceObject.GetValueByName("b");

                        return new Color(r, g, b);
                    }
                },
                set: function(value) {
                    // Should only be called when building the object
                    if (this._diffuseColor === null && value instanceof Color) {
                        this._diffuseColor = value;
                    }

                    var diffuseColor = this._diffuseColor;
                    if (diffuseColor !== undefined && diffuseColor !== null &&
                        diffuseColor.CATI3DExperienceObject !== undefined && diffuseColor.CATI3DExperienceObject !== null) {

                        diffuseColor.CATI3DExperienceObject.SetValueByName("r", value.getRed());
                        diffuseColor.CATI3DExperienceObject.SetValueByName("g", value.getGreen());
                        diffuseColor.CATI3DExperienceObject.SetValueByName("b", value.getBlue());
                    }
                }
            });
        }
    };

    SpotLightActor.prototype = new LightActor();
    SpotLightActor.prototype.constructor = SpotLightActor;

    // Expose in STU namespace.
    STU.SpotLightActor = SpotLightActor;

    return SpotLightActor;
});

define('StuMiscContent/StuSpotLightActor', ['DS/StuMiscContent/StuSpotLightActor'], function(SpotLightActor) {
    'use strict';

    return SpotLightActor;
});

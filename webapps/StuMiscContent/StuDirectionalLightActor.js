define('DS/StuMiscContent/StuDirectionalLightActor', ['DS/StuCore/StuContext', 'DS/StuMiscContent/StuLightActor', 'DS/StuRenderEngine/StuColor'], function(STU, LightActor, Color) {
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
     * @exports DirectionalLightActor
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends STU.LightActor
     * @memberof STU
     * @alias STU.DirectionalLightActor
     */
    var DirectionalLightActor = function() {

        LightActor.call(this);
        this.name = 'DirectionalLightActor';

        this._props = [];

        /**
         * Get/Set Sun power 
         *
         * @member
         * @instance
         * @name power
         * @public
         * @type {number}
         * @memberOf STU.DirectionalLightActor
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
         * @memberOf STU.DirectionalLightActor
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
         * @memberOf STU.DirectionalLightActor
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
         * @memberOf STU.DirectionalLightActor
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

    DirectionalLightActor.prototype = new LightActor();
    DirectionalLightActor.prototype.constructor = DirectionalLightActor;

    // Expose in STU namespace.
    STU.DirectionalLightActor = DirectionalLightActor;

    return DirectionalLightActor;
});

define('StuMiscContent/StuDirectionalLightActor', ['DS/StuMiscContent/StuDirectionalLightActor'], function(DirectionalLightActor) {
    'use strict';

    return DirectionalLightActor;
});

define('DS/StudioIV/StuViveTrackerActor',
    ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D', 'DS/StudioIV/StuViveManager'],
    function (STU, Actor3D, ViveManager) {
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
         * Describes a HTC Vive Tracker actor.</br>
         * 
         * To use it, you must have the following role: VRS - Virtual Reality Animator
         *
         * @exports ViveTrackerActor
         * @class
         * @constructor
         * @noinstancector
         * @public
         * @extends STU.Actor3D
         * @memberof STU
         * @alias STU.ViveTrackerActor
         */
        var ViveTrackerActor = function () {
            Actor3D.call(this);

          /**
             * Geometry of the tracker
             *
             * @member
             * @instance
             * @name geometry
             * @public
             * @type {STU.ViveTrackerActor.Geometries}
             * @memberOf STU.ViveTrackerActor
             */
            geterSeter(this, "geometry");

            this._deviceName = "";
        };

        /**
         * An enumeration of supported geometries</br>
         *
         * @enum {number}
         * @public
         *
         */
        ViveTrackerActor.Geometries = {
            'None': 0,
            'HTC': 1,
        };

        ViveTrackerActor.prototype = new Actor3D();
        ViveTrackerActor.prototype.constructor = ViveTrackerActor;

        // Expose in STU namespace.
        STU.ViveTrackerActor = ViveTrackerActor;

        return ViveTrackerActor;
    }
);

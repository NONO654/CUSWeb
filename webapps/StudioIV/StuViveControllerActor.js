define('DS/StudioIV/StuViveControllerActor',
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
         * Describes a HTC Vive Controller actor.<br/>
         * 
         * To use it, you must have the following role: VRS - Virtual Reality Animator
         *
         * @exports ViveControllerActor
         * @class
         * @constructor
         * @noinstancector
         * @public
         * @extends STU.Actor3D
         * @memberof STU
         * @alias STU.ViveControllerActor
         */
        var ViveControllerActor = function () {
            Actor3D.call(this);

            /**
             * Geometry of the controller
             *
             * @member
             * @instance
             * @name geometry
             * @public
             * @type {STU.ViveControllerActor.Geometries}
             * @memberOf STU.ViveControllerActor
             */
            geterSeter(this, "geometry");

            // /**
            //  * Name of the device associate with the Vive Controller Actor
            //  * @member
            //  * @instance
            //  * @name deviceName
            //  * @public
            //  * @type {STU.ViveManager.EController}
            //  * @memberOf STU.ViveControllerActor
			//  */
            // this._deviceName = "";
			// Object.defineProperty(this, 'deviceName', {
			// 	enumerable: true,
			// 	configurable: true,
			// 	get: function() {
            //         return this._deviceName;
			// 	},
			// 	set: function(iDeviceName) {
            //         if (iDeviceName == ViveManager.EController.controllerTracker_1 || iDeviceName == ViveManager.EController.controllerTracker_2) {
            //             this._deviceName = iDeviceName;
            //         }
            //         else {
            //             console.error("Invalid device name, should be " + ViveManager.EController.controllerTracker_1 + " or " + ViveManager.EController.controllerTracker_2);
            //         }
			// 	}
			// });
        };

        /**
         * An enumeration of supported geometries<br/>
         *
         * @enum {number}
         * @public
         *
         */
        ViveControllerActor.Geometries = {
            'None': 0,
            'HTC': 1,
        };

        ViveControllerActor.prototype = new Actor3D();
        ViveControllerActor.prototype.constructor = ViveControllerActor;

        /**
         * Associates a device name with this Vive Controller Actor
         * 
         * @public
         * @param {STU.ViveManager.EController} iDeviceName 
         */
        ViveControllerActor.prototype.setDeviceName = function (iDeviceName) {
            if (iDeviceName == ViveManager.EController.controllerTracker_1 || iDeviceName == ViveManager.EController.controllerTracker_2) {
                this._deviceName = iDeviceName;
            }
            else {
                console.error("Invalid device name, should be " + ViveManager.EController.controllerTracker_1 + " or " + ViveManager.EController.controllerTracker_2);
            }
        };

        /**
         * Vibrates the controller during a specified number of milliseconds 
         * 
         * @public
         * @param {Number} iDuration Number of milliseconds the controller will vibrate (should be lower than 65535ms).
         */
        ViveControllerActor.prototype.vibrate = function (iDuration) {
            var viveMgr = STU.ViveManager.getInstance();
            var wrapper = viveMgr._wrapper;
            if (wrapper == null || wrapper == undefined) {
                console.error("Unable to get wrapper, vibrate won't work");
                return false;
            }

            if (this._deviceName == ViveManager.EController.controllerTracker_1) {
                wrapper.hapticPulse(1, iDuration, 1.0);
            }
            else if (this._deviceName == ViveManager.EController.controllerTracker_2) {
                wrapper.hapticPulse(2, iDuration, 1.0);
            }
            else {
                console.error("You need to set the device name using setDeviceName before calling vibrate");
            }
            return true;
        };

        /**
         * Vibrates the controller during a specified number of seconds 
         * It is used as a capacity in NL
         * 
         * @private 
         * @param {Number} iDuration Number of seconds the controller will vibrate
         */
        ViveControllerActor.prototype._vibrateSeconds = function (iDuration) {
            return this.vibrate(iDuration * 1000);
        };

        // Expose in STU namespace.
        STU.ViveControllerActor = ViveControllerActor;

        return ViveControllerActor;
    });

define('StudioIV/StuViveControllerActor', ['DS/StudioIV/StuViveControllerActor'], function (ViveControllerActor) {
    'use strict';

    return ViveControllerActor;
});

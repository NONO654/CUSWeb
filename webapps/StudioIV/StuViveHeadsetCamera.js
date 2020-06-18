define('DS/StudioIV/StuViveHeadsetCamera',
    ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuCameraNa', 'DS/StudioIV/StuViveManager', 'DS/EPEventServices/EPEvent', 'DS/EPEventServices/EPEventServices'],
    function (STU, Camera, ViveManager, Event, EventServices) {
        'use strict';

        /**
        * This event is thrown when the headset is taken off the user head
        *
        * @exports HeadsetTakenOffEvent
        * @class
        * @constructor
        * @noinstancector
        * @public
        * @extends EP.Event
        * @memberof STU
        */
        var HeadsetTakenOffEvent = function () {
            Event.call(this);
        };

        HeadsetTakenOffEvent.prototype = new Event();
        HeadsetTakenOffEvent.prototype.constructor = HeadsetTakenOffEvent;
        HeadsetTakenOffEvent.prototype.type = 'HeadsetTakenOffEvent';

        // Expose in STU namespace.
        STU.HeadsetTakenOffEvent = HeadsetTakenOffEvent;
        EventServices.registerEvent(HeadsetTakenOffEvent);

        /**
        * This event is thrown when the headset is put on the user head
        *
        * @exports HeadsetPutOnEvent
        * @class
        * @constructor
        * @noinstancector
        * @public
        * @extends EP.Event
        * @memberof STU
        */
        var HeadsetPutOnEvent = function () {
            Event.call(this);
        };

        HeadsetPutOnEvent.prototype = new Event();
        HeadsetPutOnEvent.prototype.constructor = HeadsetPutOnEvent;
        HeadsetPutOnEvent.prototype.type = 'HeadsetPutOnEvent';

        // Expose in STU namespace.
        STU.HeadsetPutOnEvent = HeadsetPutOnEvent;
        EventServices.registerEvent(HeadsetPutOnEvent);


        /**
         * Describes a HTC Vive Headset Camera.<br/>
         * 
         * To use it, you must have the following role: VRS - Marketing Experience Scripter
         *
         * @exports ViveHeadsetCamera
         * @class
         * @constructor
         * @noinstancector
         * @public
         * @extends STU.Camera
         * @memberof STU
         * @alias STU.ViveHeadsetCamera
         */
        var ViveHeadsetCamera = function () {
            Camera.call(this);
            
            
            this._headsetWornButtonName = "bHeadsetWorn";
        };

        ViveHeadsetCamera.prototype = new Camera();
        ViveHeadsetCamera.prototype.constructor = ViveHeadsetCamera;

        /**
         * True when the headset is on top of the user head, false otherwise 
         * 
         * @public
         * @return {Boolean}
         */
        ViveHeadsetCamera.prototype.isWorn = function () {
            var viveDevice = ViveManager.getInstance().getDevice();
            return viveDevice.isButtonNamePressed(this._headsetWornButtonName);
        };
        /**
         * Registers listeners for headset state
         * @private
         * 
         */
        ViveHeadsetCamera.prototype.onActivate = function () {
            Camera.prototype.onActivate.call(this);
            // Add Listener to get notified
            EventServices.addObjectListener(EP.DevicePressEvent, this, '_onDevicePressEvent');
            EventServices.addObjectListener(EP.DeviceReleaseEvent, this, '_onDeviceReleaseEvent');

	        // this.viewAngle = 65; // HTC Vive View angle is 110 degrees
            /*var cameraWrapper = stu__EnvironmentModifier;
            if(cameraWrapper != undefined && cameraWrapper != null){
                var flags = 1; 
                cameraWrapper.Modify(this.CATI3DExperienceObject, flags);
            }*/
        };

        /**
         * Unregisters listeners for headset state
         * @private
         * 
         */
        ViveHeadsetCamera.prototype.onDeactivate = function () {
            // Remove Listener when you don't need it anymore
            EventServices.removeObjectListener(EP.DevicePressEvent, this, '_onDevicePressEvent');
            EventServices.removeObjectListener(EP.DeviceReleaseEvent, this, '_onDeviceReleaseEvent');
            Camera.prototype.onDeactivate.call(this);
        };

        ViveHeadsetCamera.prototype._onDevicePressEvent = function (iEvent) {
            if (iEvent.buttonName !== this._headsetWornButtonName) {
                return;
            }
            this.dispatchEvent(new HeadsetPutOnEvent());
        };

        ViveHeadsetCamera.prototype._onDeviceReleaseEvent = function (iEvent) {
            if (iEvent.buttonName !== this._headsetWornButtonName) {
                return;
            }
            this.dispatchEvent(new HeadsetTakenOffEvent());
        };

        // Expose in STU namespace.
        STU.ViveHeadsetCamera = ViveHeadsetCamera;

        return ViveHeadsetCamera;
    });

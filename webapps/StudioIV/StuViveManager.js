define('DS/StudioIV/StuViveManager', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager', 'MathematicsES/MathsDef', 'DS/EP/EP', 'DS/StuRenderEngine/StuRenderManager', 'DS/StuRenderEngine/StuColor', 'DS/EPInputs/EPDevices'],
    function(STU, Manager, DSMath, EP, RenderManager, Color, EPDevices) {
        'use strict';


        /**
         * The Vive manager is the way of interacting with the HTC Vive device <br/>
         * 
         * To use it, you must have the following role: VRS - Marketing Experience Scripter
         *
         * @exports ViveManager
         * @class
         * @constructor
         * @noinstancector
         * @public
         * @extends STU.Manager
         * @memberof STU
	     * @alias STU.ViveManager
         */
        var ViveManager = function() {

            Manager.call(this);

            this.name = "ViveManager";

            this._wrapper = null;

            this._interactionCtxActor = null;

            this._steamVRToV6Transform = new DSMath.Transformation();
            this._steamVRToV6Transform.matrix.set(
                1, 0, 0,
                0, 0, -1,
                0, 1, 0);
            
            this._ViveDevice = null;
        };

        ViveManager.prototype = new Manager();
        ViveManager.prototype.constructor = ViveManager;


        /**
         * An enumeration of all the supported keys.<br/>
         * It allows to refer in the code to a specific key.
         *
         * @readonly
         * @enum {String}
         * @public
         */
        /* jshint camelcase:false */
        ViveManager.EKey = {
            aHorizontal_1: "aHorizontal_1",
            aVertical_1: "aVertical_1",
            aTrigger_1: "aTrigger_1",
            bSystem_1: "bSystem_1",
            bMenu_1: "bMenu_1",
            bGrip_1: "bGrip_1",
            bCenter_1: "bCenter_1",
            bTrigger_1: "bTrigger_1",

            aHorizontal_2: "aHorizontal_2",
            aVertical_2: "aVertical_2",
            aTrigger_2: "aTrigger_2",
            bSystem_2: "bSystem_2",
            bMenu_2: "bMenu_2",
            bGrip_2: "bGrip_2",
            bCenter_2: "bCenter_2",
            bTrigger_2: "bTrigger_2",
        };

        /**
         * An enumeration of all the controllers id.<br/>
         * It allows to refer in the code to a specific key.
         * 
         *
         * @readonly
         * @enum {String}
         * @public
         */
        ViveManager.EController = {
            controllerTracker_1: "controllerTracker_1",
            controllerTracker_2: "controllerTracker_2",
        };

        /**
         * An enumeration of all the trackers id.<br/>
         * It allows to refer in the code to a specific key.
         * 
         * @readonly
         * @enum {String}
         * @public
         */
        ViveManager.ETracker = {
            viveTracker_1: "viveTracker_1",
            viveTracker_2: "viveTracker_2",
            viveTracker_3: "viveTracker_3",
            viveTracker_4: "viveTracker_4",
            viveTracker_5: "viveTracker_5",
            viveTracker_6: "viveTracker_6",
            viveTracker_7: "viveTracker_7",
            viveTracker_8: "viveTracker_8",
            viveTracker_9: "viveTracker_9",
            viveTracker_10: "viveTracker_10",
            viveTracker_11: "viveTracker_11",
        };

        /**
         * Process to execute when this STU.ViveManager is initializing.
         *
         * @method
         * @private
         * @see STU.ViveManager#onDispose
         */
        ViveManager.prototype.onInitialize = function() {
            Manager.prototype.onInitialize.call(this);

            if (this.buildHMDWrapper !== null && this.buildHMDWrapper !== undefined) { // jshint ignore:line
                this._wrapper = this.buildHMDWrapper(); // jshint ignore:line
            }

            if(this._wrapper === undefined || this._wrapper === null) {
                console.error("Native binding is not available");
            }
        };

        /**
         * Process to execute when this STU.ViveManager is disposing.
         *
         * @method
         * @private
         * @see STU.ViveManager#onInitialize
         */
        ViveManager.prototype.onDispose = function() {
            if (this._wrapper !== null) {
                this._wrapper = null;
            }

            Manager.prototype.onDispose.call(this);
        };

        /**
         * Start the HTC Vive engine
         * 
         * @method
         * @public
         */
        ViveManager.prototype.startViveViewer = function() {
            if (this._wrapper !== null) {
                // TODO to be removed once we have defined what to do with this
                this.setRepresentationVisibility(false);

                // The viewpoint parameters have to be setup BEFORE the engine start because there are read only once during init
                RenderManager.getInstance().onPostExecute();

                //Native engine start
                this._wrapper.start(this._interactionCtxActor.CATI3DExperienceObject);

                // After the Vive viewer start, the interaction context transform needs to be initialized
                this.setInteractionCtxTransform(this._interactionCtxActor.getTransform());
            } else {
                console.error("Native binding is not available");
            }
        };

        /**
         * Interaction context transform coming from the HTC Vive engine
         *
         * @method
         * @public
         * 
         * @return {DSMath.Transformation} Interaction context transform 
         */
        ViveManager.prototype.getInteractionCtxTransform = function() {
            var interactionCtxTransfo = new DSMath.Transformation();
            if (this._wrapper !== null) {
                this._wrapper.getInteractionCtxTransform(interactionCtxTransfo);

                var tmpMat = interactionCtxTransfo.matrix.clone();
                interactionCtxTransfo.matrix.setSecondColumn(tmpMat.getThirdColumn().negate());
                interactionCtxTransfo.matrix.setThirdColumn(tmpMat.getSecondColumn());
            } 
            return interactionCtxTransfo;
        };

        /**
         * Set the interaction context transform of the HTC Vive engine
         *
         * @public
         * 
         * @param {DSMath.Transformation} iTransform New transform of the interaction context
         */
        ViveManager.prototype.setInteractionCtxTransform = function(iTransform) {
            if (this._wrapper !== null) {
                var newTransform = iTransform.clone();

                var matrix = iTransform.matrix;
                newTransform.matrix.setSecondColumn(matrix.getThirdColumn());
                newTransform.matrix.setThirdColumn(matrix.getSecondColumn().negate());

                this._wrapper.setInteractionCtxTransform(newTransform);
            } 
        };

        /**
         * Hide / show the controller representation coming from SteamVR
         * It has to be called before starting the HTC Vive engine 
         *
         * @private
         * @param {Boolean} iRepVisibility 
         */
        ViveManager.prototype.setRepresentationVisibility = function(iRepVisibility) {
            if (this._wrapper !== null) {
                this._wrapper.setRepresentationVisibility(iRepVisibility);
            } 
        };

        /**
         * Deactivate the refresh of the main viewer 
         * Useful to increase rendering performances 
         *
         * @public
         */
        ViveManager.prototype.deactivateMainViewerRefresh = function() {
            if (this._wrapper !== null) {
                this._wrapper.deactivateMainViewerRefresh();
            } 
        };

        /**
         * Returns a reference to the interaction context actor
         *
         * @public
         * 
         * @return {STU.ViveInteractionContextActor} 
         */
        ViveManager.prototype.getInteractionContextActor = function() {
            return this._interactionCtxActor;
        };

        var pickPath = null;
        var Interactions;
        (function(Interactions) {
            Interactions[(Interactions["Press"] = 0)] = "Press";
            Interactions[(Interactions["Release"] = 1)] = "Release";
            Interactions[(Interactions["Drag"] = 2)] = "Drag";
            Interactions[(Interactions["Move"] = 3)] = "Move";
        })(Interactions || (Interactions = {}));

        ViveManager.prototype.interactions = Interactions;

        
        /**
         *
         * @private
         * @param {DSMath.Transformation} iTransform Transform of the controller sending the event
         * @param {STU.Intersection} iPickResult Picking result of STU.RenderManager pickFromRay 
         * @param {STU.ViveManager.Interactions} iInteractionType The type of interaction to send to the UI element
         */
        ViveManager.prototype.dispatchPickingToUi= function(iTransform, iPickResult, iInteractionType) {
            if (this._wrapper !== null) {
                if( (iPickResult !== null) && ('_pickPath' in iPickResult) && (iPickResult._pickPath !== null)){
                    pickPath = iPickResult._pickPath;
                }
                switch(iInteractionType){
                    case Interactions.Press: 
                    this._wrapper.launchPicking(iTransform, pickPath);
                    break;

                    case Interactions.Release: 
                    this._wrapper.stopPicking(iTransform);
                    break;

                    case Interactions.Drag: 
                    this._wrapper.continuePicking(iTransform, pickPath, true);
                    break;

                    case Interactions.Move: 
                    this._wrapper.continuePicking(iTransform, pickPath, false);
                    break;
                }
            }
        };

        /**
         * Activate the refresh of the main viewer 
         * It can impact the framerate as the rendering will be performed 
         * for the main viewer and for the HTC Vive headset
         *
         * @public 
         */
        ViveManager.prototype.activateMainViewerRefresh = function() {
            if (this._wrapper !== null) {
                this._wrapper.activateMainViewerRefresh();
            } 
        };
        
        /** 
         * Names of the connected device trackers.
         * Because of the way SteamVR works there is no guarantees regarding the id of devices name between two runs of an experience.
         *  
         * This means that the mapping between a vive tracker and its device name has to be handled using a UserScript.
         * UserScript ViveServicesScript provides a ready to use heuristic. 
         *  
         * @public
         * @return {string[]} Array of connected vive tracker devices name  
         */
        ViveManager.prototype.getConnectedViveTrackerDevicesName = function() {
            if (this._wrapper !== null) {
                let devicesName = [];
                this._wrapper.getConnectedViveTrackerDevicesName(devicesName);
                return devicesName;
            } 
            return [];
        };

        /**
         * Controller device transform in the device interaction context referential
         *
         * @public
         * 
         * @param  {STU.ViveManager.EController} iControllerId Controller enum to return 
         * @return {DSMath.Transformation} Transform of the controller in the interaction context referential 
         */
        ViveManager.prototype.getControllerTransform = function(iControllerId) {
            var device = this.getDevice();
            if(device === null){ // Case where Vive isn't connected to the computer
                return new DSMath.Transformation();
            }

            var trackerTransform = device.getTrackerNameValue(iControllerId);
            
            var localTransform = ThreeDS.Mathematics.multiplyTransfo(this._steamVRToV6Transform, trackerTransform);
            return localTransform;
        };

        /**
         * Tracker or controller transform in the interaction context referential
         *
         * @public
         * 
         * @param  {STU.ViveManager.ETracker | STU.ViveManager.EController} iDeviceId Tracker or controller enum to return 
         * @return {DSMath.Transformation} Transform of the tracker/controller in the interaction context referential 
         */
        ViveManager.prototype.getDeviceTransform = function(iDeviceId) {
            return this.getControllerTransform(iDeviceId);
        };

        /**
         * Headset device transform in the device interaction context referential
         *
         * @public
         * @return {DSMath.Transformation} Transform of the headset device
         */
        ViveManager.prototype.getHeadsetTransform = function() {
            var device = this.getDevice();
            if(device === null){ // Case where Vive isn't connected to the computer
                return new DSMath.Transformation();
            }

            var headsetTransform = device.getTrackerNameValue("headTracker");

            var transformInCamRef = headsetTransform.clone();

            transformInCamRef.matrix.setFirstColumn(headsetTransform.matrix.getThirdColumn());
            transformInCamRef.matrix.setSecondColumn(headsetTransform.matrix.getFirstColumn());
            transformInCamRef.matrix.setThirdColumn(headsetTransform.matrix.getSecondColumn());

            return ThreeDS.Mathematics.multiplyTransfo(this._steamVRToV6Transform, transformInCamRef);
        };

        /**
         * Create a ray primitive  
         *
         * @public
         * @param {object}           iParams The characteristics of the ray
         * @param {number}           iParams.length Ray length in mm  
         * @param {number}           iParams.width Ray width 
         * 
         * @param {object}           iParams.color Color of the ray 
         * @param {number}           iParams.color.r Red component color between [0-255]
         * @param {number}           iParams.color.g Green component color between [0-255]
         * @param {number}           iParams.color.b Blue component color between [0-255] 
         * @param {number}           iParams.color.a Alpha component color between [0-255], 0 : transparent, 255 : opaque
         * 
         * @param {DSMath.Point}     iParams.startPoint  Point where the ray begins
         * @param {DSMath.Vector3D}  iParams.direction   Pointing direction of the ray  
         * 
         */
        ViveManager.prototype.createRay = function(iParams) {
            this.rayParams = {
                length: this.rayLength,
                width: 2,
                color: {
                    r: 0,
                    g: 86,
                    b: 134,
                    a: 255
                },
                startPoint: new DSMath.Point(0, 0, 0),
                direction: new DSMath.Vector3D(1, 0, 0),
            };

            if(iParams.hasOwnProperty("lifetime") ===  false){
                iParams.lifetime = 1;
            }

            if(iParams.hasOwnProperty("nbDivs") ===  false){
                iParams.nbDivs = 12;
            }

            RenderManager.getInstance()._createLine(iParams);
        };

        /**
         * Displays axis using debug primitives for a given transform
         * Usefull for debugging 
         *
         * @private
         * @param  {DSMath.Transformation} t Transform to display
         * @param  {Number} alpha Transparency level ;  255 -> fully opaque, 0 -> invisible 
         */
        ViveManager.prototype.debugTransfo = function(t, alpha) {
            if (alpha === undefined) {
                alpha = 255;
            }

            var dir = t.matrix.getFirstColumn();
            var right = t.matrix.getSecondColumn();
            var up = t.matrix.getThirdColumn();


            var rm = RenderManager.getInstance();

            rm._createVector({
                length: 200,
                startPoint: t.vector,
                direction: dir,
                color: new Color(255, 0, 0),
                alpha: alpha,
                lifetime: 1
            });
            rm._createVector({
                length: 200,
                startPoint: t.vector,
                direction: right,
                color: new Color(0, 255, 0),
                alpha: alpha,
                lifetime: 1
            });
            rm._createVector({
                length: 200,
                startPoint: t.vector,
                direction: up,
                color: new Color(0, 0, 255),
                alpha: alpha,
                lifetime: 1
            });
        };

        /**
         * Return the Vive device
         * @private
         * @return {EP.Device}
         */
        ViveManager.prototype.getDevice = function() {
            if(this._ViveDevice === null){
                var devicesList = EPDevices.getDeviceList();
                // if there is only one device we suppose it is the Vive Device
                if(devicesList.length == 1){
                    this._ViveDevice = devicesList[0];
                }
                else{
                    for (var i = 0; i < devicesList.length; i++) {
                        var device = devicesList[i];
                        // ["headTracker", "controllerTracker_1", "controllerTracker_2"]
                        if("headTracker" in device.trackerNames){
                            this._ViveDevice = device;
                            break;
                        }
                    }
                }
            }
            return this._ViveDevice;
        };

        // Expose in STU namespace.
        STU.ViveManager = ViveManager;

        return ViveManager;
    });

define('StudioIV/StuViveManager', ['DS/StudioIV/StuViveManager'], function (ViveManager) {
    'use strict';

    return ViveManager;
});

/*
* @quickReview IBS 18:01:11 IR-571616 IR-571579 lock raytrace functions while planet environment is active
*/
define('DS/StuRaytrace/StuRaytrace', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer'
], function (STU, Behavior, Task, TaskPlayer) {
    'use strict';

    var RaytraceTask = function (iRaytraceBeh) {
        Task.call(this);

        this.beh = iRaytraceBeh;
    };


    RaytraceTask.prototype = new Task();
    RaytraceTask.prototype.constructor = RaytraceTask;
    RaytraceTask.prototype.onExecute = function (iExContext) {
        this.beh.onExecute(iExContext);
    };

    /**
	 * Describe a behavior attached to a Camera to control raytracing capacities.<br/>
     * 
     * To use it, you must have the following role: RDS - Marketing Media Producer
	 *
	 * @exports Raytrace
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
     * @extends STU.Behavior
	 * @memberOf STU
     * @alias STU.Raytrace
	 */
    var Raytrace = function () {
        Behavior.call(this);

        this.name = 'Raytrace';
        this.associatedTask;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should NOT be visible in UI
        //////////////////////////////////////////////////////////////////////////
        ///   //!\\ Order matters here :
        ///         stu__StudioRaytraceWrapper must be instanciated BEFORE Object.defineProperty

        this._wrapper = this.buildWrapper();//new stu__StudioRaytraceWrapper(); // jshint ignore:line
        this._recording = false;
        this._isActiveCamera = false;
        this._parentActor = null;

        this._renderEngine = 0; //[IR-654136] Animations will be supported in FD02 only, therefore you must disable the recording command when the batch renderer is Stellar.

        /**
		 * The aperture specifies the amount of light you want on your object.<br/>
		 * The value lies between 1 to &infin;. The higher the value, the sharper the image. The lower the value, the more blurred the objects out of the focus.<br/>
		 * Use Raytrace.InfinityAperture to set aperture to infinity.
		 *
		 * @member
		 * @instance
		 * @name  aperture
		 * @public
		 * @type {Number}
		 * @memberOf STU.Raytrace
		 */
        this._aperture = 1.0;
        Object.defineProperty(this, 'aperture', {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this._parentActor !== null && this._parentActor != undefined) {
                    return this._parentActor.aperture;
                }
                else {
                    return this._aperture;
                }
            },
            set: function (iAperture) {
                //this._aperture = 
                //console.log("test: " + iAperture);
                this._aperture = (iAperture < 1 && iAperture !== 0) ? 1 : iAperture;
                if (this._parentActor != null && this._parentActor != undefined)
                    this._parentActor.aperture = this._aperture;//(iAperture < 1 && iAperture !== 0) ? 1 : iAperture;
                //this._aperture = 5;
                //this._aperture = this._parentActor.aperture = iAperture;

                if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                    this._wrapper.setAperture(this._parentActor.aperture);
                }
            }
        });

        /**
		 * The speed refers to the shutter speed. <br/>
		 * The value lies between 1/4000s and 1s. The higher the value, the darker the image.
		 *
		 * @member
		 * @instance
		 * @name  speed
		 * @public
		 * @type {Number}
		 * @memberOf STU.Raytrace
		 */
        this._speed = 1.0;
        Object.defineProperty(this, 'speed', {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this._parentActor !== null && this._parentActor !== undefined) {
                    //console.log(this._parentActor.speed);
                    return this._parentActor.speed;
                }
                else {
                    return this._speed;
                }
            },
            set: function (iSpeed) {
                this._speed = Math.min(Math.max(iSpeed, 0.0025), 1);
                //console.log(this._speed);
                if (this._parentActor != null && this._parentActor != undefined)
                    this._parentActor.speed = this._speed;

                if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                    this._wrapper.setSpeed(this._parentActor.speed);
                }
            }
        });

        /**
		 * The exposure allows you to control the amount of light that determines the brightness of the image. <br/>
		 * The value lies between -9 and 9.
		 *
		 * @member
		 * @instance
		 * @name  exposure
		 * @public
		 * @type {Number}
		 * @memberOf STU.Raytrace
		 */
        this._exposure = 0.0;
        Object.defineProperty(this, 'exposure', {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this._parentActor !== null && this._parentActor !== undefined) {
                    return this._parentActor.exposure;
                }
                else {
                    return this._exposure;
                }
            },
            set: function (iExposure) {
                this._exposure = Math.min(Math.max(iExposure, -9), 9);
                //console.log(this._speed);
                if (this._parentActor != null && this._parentActor != undefined)
                    this._parentActor.exposure = this._exposure;

                if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                    this._wrapper.setExposure(this._parentActor.exposure);
                }
            }
        });

        /** 
         * distance property
         *
		 * @member
		 * @instance
		 * @name  distance
		 * @public
		 * @type {Number}
		 * @memberOf STU.Raytrace
		 */
        this._distance = 0.0;
        Object.defineProperty(this, 'distance', {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this._parentActor !== null && this._parentActor !== undefined) {
                    return this._parentActor.focusDistance;
                }
                else {
                    return this._distance;
                }
            },
            set: function (iDistance) {
                this._distance = iDistance >= 0 ? iDistance : 0;
                if (this._parentActor !== null && this._parentActor !== undefined) {
                    this._parentActor.focusDistance = this._distance;
                }

                if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                    this._wrapper.setFocusDistance(this._parentActor.focusDistance);
                }
            }
        });

        this._target = null;
        Object.defineProperty(this, 'target', {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this._parentActor !== null && this._parentActor !== undefined && this._parentActor.Autofocus !== null && this._parentActor.Autofocus !== undefined) {
                    return this._parentActor.Autofocus.focusTarget;
                }
                else {
                    return this._target;
                }
            },
            set: function (iTarget) {
                this._target = iTarget;

                if (this._parentActor !== null && this._parentActor !== undefined) {
                    if (this._parentActor.Autofocus !== null && this._parentActor.Autofocus !== undefined) {
                        this._parentActor.Autofocus.focusTarget = iTarget;
                    }
                }
            }
        });

        /**
		 * 0 : manual
		 * 1 : centered
		 * 2 : target
		 *
		 * @member
		 * @instance
		 * @name  focusMode
		 * @public
		 * @type {STU.Raytrace.FocusModes}
		 * @memberOf STU.Raytrace
		 */
        this._focusMode = 0;
        Object.defineProperty(this, 'focusMode', {
            enumerable: true,
            configurable: true,
            get: function () {
                //Focus Mode is now linked to the Autofocus behavior set on the Camera Actor 
                if (this._parentActor !== null && this._parentActor !== undefined && this._parentActor.Autofocus !== null && this._parentActor.Autofocus !== undefined) {
                    return this._parentActor.Autofocus.focusMode;
                }
                else {
                    return this._focusMode;
                }
                //return this._focusMode;
            },
            set: function (iFocusMode) {
                this._focusMode = iFocusMode;
                if (this._parentActor !== null && this._parentActor !== undefined) {
                    if (this._parentActor.Autofocus !== null && this._parentActor.Autofocus !== undefined) {
                        this._parentActor.Autofocus.focusMode = iFocusMode;
                    }
                }

                if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                    this._wrapper.setAutoFocusMode(this._focusMode); // 0=manual, 1=auto, 2=target

                    switch (iFocusMode) {
                        case 0:
                            this._wrapper.setFocusDistance(this.distance);
                            break;

                        case 2:
                            if (!!this.target) {
                                var center = this.target.getBoundingSphere().center;
                                this._wrapper.setFocusPoint(center.x, center.y, center.z);
                            } else {
                                this._wrapper.setAutoFocusMode(this._focusMode);
                                this._wrapper.setFocusDistance(this._distance);
                            }
                            break;
                    }
                }
            }
        });



        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////

    };





    /**
	 * Enumeration of all focus modes.<br/>
	 *
	 * @enum {number}
	 * @public
	 *
	 */
    Raytrace.FocusModes = {
        eManual: 0,
        eCentred: 1,
        eTarget: 2
    };

    /**
	 * Infinity value for aperture
	 * @type {Number}
	 * @public
	 */
    Raytrace.InfinityAperture = 0;

    Raytrace.prototype = new Behavior();
    Raytrace.prototype.constructor = Raytrace;
    Raytrace.prototype.protoId = '1BDC56DE-FF11-4E4D-A5B6-B2B2C23B2F69';
    Raytrace.prototype.pureRuntimeAttributes = [].concat(Behavior.prototype.pureRuntimeAttributes);


    /**
	 * Executed when the behavior is activating
	 * @private
	 */
    Raytrace.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this._parentActor = this.getParent();
        this._isActiveCamera = this._parentActor.isCurrent();

        // For[IR-654136]
        this._renderEngine = this._wrapper.getRenderEngine();

        this.associatedTask = new RaytraceTask(this);
        TaskPlayer.addTask(this.associatedTask);
    };

    /**
	 * Executed when the behavior is activating
	 * @private
	 */
    Raytrace.prototype.onDeactivate = function () {
        if (this._recording) {
            console.warn('A capture was started but never ended');
        }

        TaskPlayer.removeTask(this.associatedTask);
        this.associatedTask = null;

        this._wrapper = null;

        //Will be called on experience stop.
        Behavior.prototype.onDeactivate.call(this);
    };

    /**
	 * Called each frame during a recording
	 * @private
	 */
    Raytrace.prototype.onExecute = function () {
        if (this._parentActor.isCurrent()) {
            this.checkAndApplyCameraModification();
            if (this._isActiveCamera === false) {
                this._isActiveCamera = true;
                this.forceWrapperValuesUpdate();
            }
        } else {
            this._isActiveCamera = false;
        }

        if (this._recording === true) {
            this.captureFrame();
        }
    };

    Raytrace.prototype.beginAnimation = function () {

        var PlanetsEnvIsActive = false;
        var renderManager = STU.RenderManager.getInstance();
        if (renderManager !== null && renderManager !== undefined) {
            var activeEnvironment = renderManager.getActiveEnvironment();
            PlanetsEnvIsActive = (activeEnvironment instanceof STU.Planets);
        }
        if (PlanetsEnvIsActive) {
            console.error('cannot begin animation while a planets environment is active');
            return;
        }

        //[IR-654136] Animations will be supported in FD02 only, therefore you must disable the recording command when the batch renderer is Stellar.
        if (this._renderEngine === 1) {
            console.error("Raytraced video recording is not supported with Stellar yet. Please change rendering engine in your preferences");
            return;
        }

        if (!this._recording) {
            this.forceWrapperValuesUpdate();
            this._wrapper.setProduceVideo(true);
            this._wrapper.begin();
            this._recording = true;
        } else {
            console.warn('beginAnimation has already been called');
        }
    };

    Raytrace.prototype.captureFrame = function () {

        var PlanetsEnvIsActive = false;
        var renderManager = STU.RenderManager.getInstance();
        if (renderManager !== null && renderManager !== undefined) {
            var activeEnvironment = renderManager.getActiveEnvironment();
            PlanetsEnvIsActive = (activeEnvironment instanceof STU.Planets);
        }
        if (PlanetsEnvIsActive) {
            console.error('cannot capturing frames while a planets environment is active');
            return;
        }

        if (this._recording) {
            if (this._focusMode === 1) {
                this.focusMode = 1; // force refresh of bounding sphere position
            }
        } else {
            console.error('You must call beginAnimation before capturing frames');
        }
    };

    Raytrace.prototype.endAnimation = function () {
        if (this._recording) {
            this._wrapper.end();
            this._recording = false;
        } else {
            console.warn('No recording is active');
        }
    };

    Raytrace.prototype.isRecording = function () {
        var recordState = this._wrapper.isRecording();
        if (recordState !== this._recording) {
            console.error('There is a state mismatch between the engine and the behavior');
        }

        return recordState;
    };

    Raytrace.prototype.setIteration = function (iter) {
        if (!isNaN(iter) && iter >= 0) {
            this._wrapper.setIteration(iter);
        } else {
            console.error('setIteration parameter must be a positive number');
        }
    };

    /**
	 * Capacity: capture a photo of the experience
	 * @public
	 */
    Raytrace.prototype.capturePhoto = function () {

        var PlanetsEnvIsActive = false;
        var renderManager = STU.RenderManager.getInstance();
        if (renderManager !== null && renderManager !== undefined) {
            var activeEnvironment = renderManager.getActiveEnvironment();
            PlanetsEnvIsActive = (activeEnvironment instanceof STU.Planets);
        }
        if (PlanetsEnvIsActive) {
            console.error('cannot capture photo while a planets environment is active');
            return;
        }

        if (!this._recording) {
            this.forceWrapperValuesUpdate();
            this._wrapper.shotSingleFrame();
        } else {
            console.error('You can\'t call capturePhoto while recording');
        }
    };

    /**
	 * Capacity : start the recording
	 * @public
	 */
    Raytrace.prototype.startRecording = function () {
        this.beginAnimation();

    };

    /**
	 * Capacity : stop the recording
	 * @public
	 */
    Raytrace.prototype.stopRecording = function () {

        this.endAnimation();
        this.dispatchEvent(new STU.ServiceStoppedEvent("record", this));
    };

    Raytrace.prototype.focusOn = function (iActor) {
        if (iActor !== undefined && iActor instanceof STU.Actor3D) {
            this.target = iActor;
        } else {
            console.error('iActor is not a STU.Actor3D');
        }
    };

    Raytrace.prototype.forceWrapperValuesUpdate = function () {
        var recordingState = this._recording;
        this._recording = true;

        //not usefull since those properties are linked to the parent properties
        //this.aperture = this._aperture;
        //this.speed = this._speed;
        //this.exposure = this._exposure;
        //this.distance = this._distance;
        //this.focusMode = this._focusMode;

        var updateFlag = STU.Camera.RaytraceOption.eAperture | STU.Camera.RaytraceOption.eExposure | STU.Camera.RaytraceOption.eSpeed | STU.Camera.RaytraceOption.eFocus | STU.Camera.RaytraceOption.eFocusMode;
        this.updateWrapperValues(updateFlag);

        this._recording = recordingState;
    };

    Raytrace.prototype.updateWrapperValues = function (iParam) {
        if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
            if ((iParam & STU.Camera.RaytraceOption.eAperture) != 0) {
                //console.log("Wrapper: SetAperture");
                this._wrapper.setAperture(this._parentActor.aperture);
            }
            if ((iParam & STU.Camera.RaytraceOption.eExposure) != 0) {
                //console.log("Wrapper: SetExposure");
                this._wrapper.setExposure(this._parentActor.exposure);
            }
            if ((iParam & STU.Camera.RaytraceOption.eSpeed) != 0) {
                //console.log("Wrapper: SetSpeed");
                this._wrapper.setSpeed(this._parentActor.speed);
            }
            if ((iParam & STU.Camera.RaytraceOption.eFocus) != 0) {
                //console.log("Wrapper: SetFocus");
                this._wrapper.setFocusDistance(this._parentActor.focusDistance);
            }
            if ((iParam & STU.Camera.RaytraceOption.eFocusMode) != 0) {
                //console.log("Wrapper: SetAutofocusMode");
                this._wrapper.setAutoFocusMode(this.focusMode);
                switch (this.focusMode) { //If we check focusMode, is that we have obviously an Autofocus Behavior on Camera actor
                    case 0:
                        this._wrapper.setFocusDistance(this.distance); //Autofocus modifiying camera's focusDistance too
                        //console.log("Wrapper: setFocusDistance");
                        break;
                    case 2:
                        if (!!this.target) {
                            var center = this.target.getBoundingSphere().center;
                            this._wrapper.setFocusPoint(center.x, center.y, center.z);
                            //console.log("Wrapper: setFocusPoint");
                        } else {
                            this._wrapper.setAutoFocusMode(0);//this._wrapper.setAutoFocusMode(this.focusMode); // Reset To Manual
                            this._wrapper.setFocusDistance(this.distance);
                            //console.log("Wrapper: setFocusPoint Failed");
                        }
                        break;
                }
            }
        }
    };

    Raytrace.prototype.checkAndApplyCameraModification = function () {
        //Should be always true...
        if (this._parentActor instanceof STU.Camera) {
            if (this._parentActor.hasUpdatedRaytraceValue()) {
                this.updateWrapperValues(this._parentActor.getRaytraceFlag());
                this._parentActor.restoreRaytraceFlag();
            }
        }
    };


    // Expose in STU namespace.
    STU.Raytrace = Raytrace;

    return Raytrace;
});

define('StuRaytrace/StuRaytrace', ['DS/StuRaytrace/StuRaytrace'], function (Raytrace) {
    'use strict';

    return Raytrace;
});

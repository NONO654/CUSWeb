define('DS/StuMiscContent/StuAutofocus', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer'
], function (STU, Behavior, Task, TaskPlayer) {
    'use strict';

    var AutofocusTask = function (iAutofocusBeh) {
        Task.call(this);

        this.beh = iAutofocusBeh;
    };


    AutofocusTask.prototype = new Task();
    AutofocusTask.prototype.constructor = AutofocusTask;
    AutofocusTask.prototype.onExecute = function (iExContext) {
        this.beh.onExecute(iExContext);
    };

    /**
	 * Describe a behavior attached to a Camera to control it's focus property.<br/>
     * 
	 *
	 * @exports Autofocus
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
     * @extends STU.Behavior
	 * @memberOf STU
     * @alias STU.Autofocus
	 */
    var Autofocus = function () {
        Behavior.call(this);

        this.name = 'Autofocus';
        this.associatedTask;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should NOT be visible in UI
        //////////////////////////////////////////////////////////////////////////
        this._isActiveCamera = false;
        this._parentActor = null;
        this._focusDistance = null;
        this._autofocusingTimer = 0.0;
        this._autofocusingDuration = 250; //milliseconds
        this.isODT = false;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////

        /**
         * Target object when focus mode is set to Target. The focus is done on the center of target's bounding sphere
		 *
		 * @member
		 * @instance
		 * @name  focusTarget
		 * @public
	     * @type {STU.Actor3D}
		 * @memberOf STU.Autofocus
		 */
        this.focusTarget = null;


        /**
		 * 0 : manual
		 * 1 : centered
		 * 2 : target
		 *
		 * @member
		 * @instance
		 * @name  focusMode
		 * @public
		 * @type {STU.Autofocus.FocusModes}
		 * @memberOf STU.Autofocus
		 */
        this._focusMode = 0;
        Object.defineProperty(this, 'focusMode', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._focusMode;
            },
            set: function (iFocusMode) {
                this._focusMode = iFocusMode;

                //if ((this._recording === true || this._isActiveCamera === true) && !!this._wrapper) {
                //    this._wrapper.setAutoFocusMode(this._focusMode); // 0=manual, 1=auto, 2=target
                //
                //    switch (iFocusMode) {
                //        case 0:
                //            this._wrapper.setFocusDistance(this.distance);
                //            break;
                //
                //        case 2:
                //            if (!!this.target) {
                //                var center = this.target.getBoundingSphere().center;
                //                this._wrapper.setFocusPoint(center.x, center.y, center.z);
                //            } else {
                //                this._wrapper.setAutoFocusMode(this._focusMode);
                //                this._wrapper.setFocusDistance(this._distance);
                //            }
                //            break;
                //    }
                //}
                //console.log(this._parentActor);
                if (this._parentActor instanceof STU.Camera) {
                    this._parentActor.AddRaytraceFlag(STU.Camera.RaytraceOption.eFocusMode);
                    //console.log("Save in Wrapper: OK");
                }
            }
        });

    };



    /**
	 * Enumeration of all focus modes.<br/>
	 *
	 * @enum {number}
	 * @public
	 *
	 */
    Autofocus.FocusModes = {
        eManual: 0,
        eCentred: 1,
        eTarget: 2
    };

    Autofocus.prototype = new Behavior();
    Autofocus.prototype.constructor = Autofocus;
    Autofocus.prototype.protoId = '1BDC56DE-FF11-4E4D-A5B6-B2B2C23B2F69';
    Autofocus.prototype.pureRuntimeAttributes = [].concat(Behavior.prototype.pureRuntimeAttributes);


    /**
	 * Executed when the behavior is activating
	 * @private
	 */
    Autofocus.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this._parentActor = this.getParent();
        this._isActiveCamera = this._parentActor.isCurrent();

        this._parentActor.enableDepthOfField = true; // forcing DOF

        this.associatedTask = new AutofocusTask(this);
        TaskPlayer.addTask(this.associatedTask);

        /* global STUTST*/
        if (typeof STUTST === 'object' && typeof STUTST.JSDumpOdt === 'function') {
            this._isODT = true;
            this._autofocusingDuration = 500;
        }
    };

    /**
	 * Executed when the behavior is activating
	 * @private
	 */
    Autofocus.prototype.onDeactivate = function () {
        TaskPlayer.removeTask(this.associatedTask);
        this.associatedTask = null;

        //Will be called on experience stop.
        Behavior.prototype.onDeactivate.call(this);
    };

    /**
	 * Called each frame during a recording
	 * @private
	 */
    Autofocus.prototype.onExecute = function (iDelta) {
        if (this._parentActor.isCurrent()) {
            if (this._isActiveCamera === false) {
                //this._isActiveCamera = true;
                //this.forceWrapperValuesUpdate();
                //console.log(this.actor.name + " : Execute");
            }
            if (this.focusMode === Autofocus.FocusModes.eManual) {
                //console.log("Manual");
            }
            if (this.focusMode === Autofocus.FocusModes.eTarget) {
                if (this.focusTarget != null && this.focusTarget != undefined) {
                    var targetPosition = this.focusTarget.getPosition();
                    var camPosition = this.actor.getPosition();
                    var v2 = targetPosition.sub(camPosition);
                    var distance = v2.norm();

                    //console.log(distance);
                    if (this._focusDistance !== distance) {
                        this._parentActor.focusDistance = distance;
                        this._focusDistance = distance;
                    }
                }
            }
            if (this.focusMode === Autofocus.FocusModes.eCentred) {

                // in order to not be too much frame expensive we do not modify the focus distance each frame.
                // Instead we modify the this distance at a specified frequency.
                if (this._autofocusingTimer < this._autofocusingDuration) {
                    this._autofocusingTimer += iDelta.deltaTime;
                    return;
                }
                else {
                    this._autofocusingTimer = 0.0;
                }

                var rm = STU.RenderManager.getInstance();
                var viewerSize = rm.getViewerSize();
                viewerSize.multiplyScalar(0.5);
                var intersections = rm._pickFromPosition(viewerSize, true, true);
                if (intersections.length !== 0) {
                    var intersect = intersections[0];
                    var targetPosition = new DSMath.Vector3D();
                    targetPosition.setFromPoint(intersect.point);
                    var camPosition = this.actor.getPosition();
                    var v2 = targetPosition.sub(camPosition);
                    var distance = v2.norm();

                    //console.log(distance);
                    if (this._focusDistance !== distance) {
                        this._parentActor.focusDistance = distance;
                        this._focusDistance = distance;
                    }

                }
            }
        } else {
            this._isActiveCamera = false;
        }
    };

    // Expose in STU namespace.
    STU.Autofocus = Autofocus;

    return Autofocus;
});

define('StuMiscContent/StuAutofocus', ['DS/StuMiscContent/StuAutofocus'], function (Autofocus) {
    'use strict';

    return Autofocus;
});


define('DS/StuCameras/StuCameraManager', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef'],
    function (STU, Instance, Behavior, Task, EP, DSMath) { 	
	'use strict';

    /**
     * CAMERA TRANSITION
     * @private
     * @extends {STU.Instance}
     * @param {STU.Camera} targetCameraActor [description]
     * @param {number} duration          [description]
     */
    var CameraManagerTransition = function (targetCameraActor, duration) {

		Instance.call(this);

		this.name = "CXPCameraManagerTransition_Spec";

        // The camera toward which the active camera will be moved.
        this.targetCameraActor = targetCameraActor;

        this.startTransfo = null;
        this.endTransfo = null;

        this.startViewAngle = null;
        this.endViewAngle = null;

        this.duration = duration;
        this.percent = 0;
    };

    CameraManagerTransition.prototype = new Instance();
    CameraManagerTransition.prototype.constructor = CameraManagerTransition;
    CameraManagerTransition.prototype.protoId = "8A134F89-2F59-42F5-8F1C-A723CD65D550";

    /**
     * Takes the transition one step forward.
     * @param  {STU.Camera} activeCameraActor Camera that is currently active on the camera manager.
     * @param  {number} deltaTime         Time elapsed since last step.
     * @private
     */
    CameraManagerTransition.prototype.stepForward = function (activeCameraActor, deltaTime) {
        if (this.duration > 0) {
            this.percent = deltaTime / (this.duration * 1000);
        }
        else {
            console.debug("stepForward: duration is equal to 0 -> skip step");
            this.percent = 1;
            this.duration = 0;
        }

        if (this.percent > 1) {
            console.debug("stepForward: percent > 1 -> skip step");
            this.percent = 1;
            return;
        }

        if (typeof activeCameraActor === "undefined" || activeCameraActor === null) {
            console.log("Invalid active camera actor");
            return;
        }

        var deltaTransfo = new DSMath.Transformation();

        // Lerp position
		var startPos = this.startTransfo.vector.clone();
		var endPos = this.endTransfo.vector.clone();
		var deltaPos = DSMath.Vector3D.lerp(startPos, endPos, this.percent);
		deltaTransfo.vector = deltaPos;

        // Slerp rotation
        var startQuat = new DSMath.Quaternion();
        this.startTransfo.matrix.getQuaternion(startQuat);
        var endQuat = new DSMath.Quaternion();
        this.endTransfo.matrix.getQuaternion(endQuat);
		var deltaQuat = DSMath.Quaternion.slerp(startQuat, endQuat, this.percent);
		deltaTransfo.matrix = deltaQuat.getMatrix();

        // Lerp View Angle
		var deltaViewAngle = this.startViewAngle + this.percent * (this.endViewAngle - this.startViewAngle);

        activeCameraActor.setTransform(deltaTransfo);
        activeCameraActor.viewAngle = deltaViewAngle;

    };

	// Expose in STU namespace.
	STU.CameraManagerTransition = CameraManagerTransition;



    /**
    * CAMERA MANAGER SEQUENCE.
    * @private
    */

    var CameraManagerSequence = function () {

        Instance.call(this);
        this.name = "CXPCameraManagerSequence_Spec";
        this.trigger = 0;
        this.mode = 0;
        this.transitions = {};
        this.transitionIndex = 0;

        this.task = null;
    };

    CameraManagerSequence.prototype = new Instance();
    CameraManagerSequence.prototype.constructor = CameraManagerSequence;
    CameraManagerSequence.prototype.protoId = "9943847D-90B1-457A-8AB2-4784C73619E3";


	// Expose in STU namespace.
	STU.CameraManagerSequence = CameraManagerSequence;


    /**
     * CAMERA MANAGER TASK.
     * @private
     */
    var CameraManagerTask = function (manager) {

        Task.call(this);
        this.cameraManager = manager;

        this.deltaTime = null;

        this.sequence = null;
    };

    CameraManagerTask.prototype = new Task();
    CameraManagerTask.prototype.constructor = CameraManagerTask;


    // ON START
    CameraManagerTask.prototype.onStart = function () {
        this.onTransitionStart();
    };

    // ON EXECUTE
    CameraManagerTask.prototype.onExecute = function (iContext) {

        // Invalid input
        if (typeof this.sequence === "undefined" || this.sequence === null || !Array.isArray(this.sequence.transitions) || this.sequence.transitions.length === 0) {
            console.debug("Invalid input");
            this.cameraManager.onTaskEnd();
            return this;
        }

        // Invalid index 
        if (this.sequence.transitionIndex < 0 || this.sequence.transitionIndex >= this.sequence.transitions.length) {
            console.debug("Invalid index");
            this.cameraManager.onTaskEnd();
            return this;
        }

        // Invalid transition.
        if (typeof this.sequence.transitions[this.sequence.transitionIndex] === "undefined" || this.sequence.transitions[this.sequence.transitionIndex] === null) {
            console.debug("Invalid transition");
            this.cameraManager.onTaskEnd();
            return this;
        }

        if (this.sequence.transitions[this.sequence.transitionIndex].percent >= 1) {
            if (this.sequence.mode === 1) {
                // mode play
                if (this.next()) {
                    this.onTransitionStart();
                    console.debug("Mode play.");
                }
            }
            else if (this.sequence.mode === 2) {
                // mode loop
                if (this.next()) {
                    this.onTransitionStart();
                    console.debug("Mode loop.");
                }
            }
            else {
                // step by step mode
                this.next();
                this.cameraManager.onTaskEnd();
                console.debug("Mode step by step.");
            }

        }
        else {
            this.deltaTime += iContext.getDeltaTime();
            this.sequence.transitions[this.sequence.transitionIndex].stepForward(this.cameraManager.activeCameraActor, this.deltaTime);
        }
         
        return this;
    };


    // ON TRANSITION START
    CameraManagerTask.prototype.onTransitionStart = function () {
        if (typeof this.sequence === "undefined" || this.sequence === null || 
            typeof this.sequence.transitions === "undefined" || this.sequence.transitions === null || 
            typeof this.sequence.transitionIndex === "undefined" || this.sequence.transitionIndex === null) {
            // task not initialized yet
            return this;
        }

        this.sequence.transitions[this.sequence.transitionIndex].startTransfo = null;
        this.sequence.transitions[this.sequence.transitionIndex].endTransfo = null;
        this.sequence.transitions[this.sequence.transitionIndex].startViewAngle = null;
        this.sequence.transitions[this.sequence.transitionIndex].endViewAngle = null;
        this.sequence.transitions[this.sequence.transitionIndex].percent = 0;

        this.deltaTime = 0;

        if (typeof this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor === "undefined" || this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor === null) {
            console.debug("targetCameraActor is undefined or null");
            return;
        }

        // Update active camera on RenderManager
        var rm = STU.RenderManager.getInstance();
        if (typeof rm === "undefined" || rm === null) {
            console.log("Unable to retrieve Render Manager.");
            return;
        }
        
        this.cameraManager.activeCameraActor = rm.getCurrentCamera();
        
        if (typeof this.cameraManager.activeCameraActor === "undefined" || this.cameraManager.activeCameraActor === null) {
            console.debug("activeCameraActor is undefined or null");
            return;
        }

        this.sequence.transitions[this.sequence.transitionIndex].startTransfo = this.cameraManager.activeCameraActor.getTransform();
        this.sequence.transitions[this.sequence.transitionIndex].endTransfo = this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor.getTransform();
        this.sequence.transitions[this.sequence.transitionIndex].startViewAngle = this.cameraManager.activeCameraActor.viewAngle;
        this.sequence.transitions[this.sequence.transitionIndex].endViewAngle = this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor.viewAngle;

        var coeff1 = this.sequence.transitions[this.sequence.transitionIndex].startTransfo.getArray();
        var coeff2 = this.sequence.transitions[this.sequence.transitionIndex].endTransfo.getArray();
        var i, isEqual = true;
        for(i=0; i<coeff1.length ; ++i){
            if(coeff1[i] !== coeff2[i]){
                isEqual=false;
                i = coeff1.length;
            }
        }
        

        if (isEqual){
            console.log("Origin camera is equal to target camera -> skip step");
            this.sequence.transitions[this.sequence.transitionIndex].percent = 1;
            return;
        }

        rm.setCurrentCamera(this.cameraManager.activeCameraActor);
    };


    /**
    * A call-back invoked at the end of each transition.
    * Resets ending transition (start/end transfo, percent).
    * @private
    */
    CameraManagerTask.prototype.onTransitionEnd = function () {
        // Update active camera on RenderManager
        var rm = STU.RenderManager.getInstance();
        if (typeof rm === "undefined" || rm === null) {
            return;
        }

        if (this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor === null) {
            return;
        }
        
        // Set render manager camera with the target camera actor
        rm.setCurrentCamera(this.sequence.transitions[this.sequence.transitionIndex].targetCameraActor);

        // Reset active camera actor
        this.cameraManager.activeCameraActor.setTransform(this.sequence.transitions[this.sequence.transitionIndex].startTransfo);
        this.cameraManager.activeCameraActor.viewAngle = this.sequence.transitions[this.sequence.transitionIndex].startViewAngle;

        // Reset transition settings
        this.sequence.transitions[this.sequence.transitionIndex].startTransfo = null;
        this.sequence.transitions[this.sequence.transitionIndex].endTransfo = null;
        this.sequence.transitions[this.sequence.transitionIndex].startViewAngle = null;
        this.sequence.transitions[this.sequence.transitionIndex].endViewAngle = null;
        this.sequence.transitions[this.sequence.transitionIndex].percent = 0;
    };


    // NEXT
    CameraManagerTask.prototype.next = function () {
        // End current transition
        this.onTransitionEnd();

        // Finished last transition.
        if (typeof this.sequence === "undefined" || this.sequence === null || 
            typeof this.sequence.transitions[this.sequence.transitionIndex + 1] === "undefined" || this.sequence.transitions[this.sequence.transitionIndex + 1] === null) {
            this.sequence.transitionIndex = 0;
            if (this.sequence.mode !== 2) {
                this.cameraManager.onTaskEnd();
                return false;
            }
            return true;
        }

        // Prepare to play next transition.
        ++this.sequence.transitionIndex;

        return true;
    };



























    /**
     * Describes a CameraManager behavior<br/>
     * 
     *
     * @exports CameraManager
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Behavior
     * @memberof STU
     * @alias STU.CameraManager
     */
    var CameraManager = function () {
        //var self;

        Behavior.call(this);
        this.name = "CameraManager";
        this.activeCameraActor = null;
    	//For EP integration : launchTable is define as undefined array of integer in model, but with this line
			//it is reprojected as object, that cause issue of type modification at the JSToStore Synchro.
        //this.launchTable = {};
        this.sequences = {};

        this.keyboardCb = null;
        this.task = null;
    };

    CameraManager.prototype = new Behavior();
    CameraManager.prototype.constructor = CameraManager;
    CameraManager.prototype.protoId = "72F70765-8559-44C6-AC74-536BED91BE20";

    CameraManager.prototype.onKeyboardEvent = function (iKeyboardEvent) {
        var i = 0;
        var found = false;

        while (!found && i < this.sequences.length) {
            if (typeof this.sequences[i] !== "undefined" && this.sequences[i] !== null && this.sequences[i].trigger === iKeyboardEvent.getKey()) {
                console.debug("Play sequence");
                this.play(this.sequences[i]);
            }
            i++;
        }
    };

    CameraManager.prototype.onActivate = function () {
		Behavior.prototype.onActivate.call(this);

        this.keyboardCb = STU.makeListener(this, 'onKeyboardEvent');
        EP.EventServices.addListener(EP.KeyboardPressEvent, this.keyboardCb);
    };

	CameraManager.prototype.onDeactivate = function () {
	    EP.EventServices.removeListener(EP.KeyboardPressEvent, this.keyboardCb);

	    // H53 - CameraManagerRTTask not used anymore
		// EP.TaskPlayer.removeTask(this.associatedTask);
		// delete this.associatedTask;

		Behavior.prototype.onDeactivate.call(this);
	};

    /**
    * Register given set of transition to be triggered on given key.
    * @param key is the trigger for the given transitions.
    * @param transitions is the set of transition that will be played when the key is hit.
    * @return this.
    */
    // { //useless bracket TO REMOVE
    //    CameraManager.prototype.register = function (key, transitions, mode) {
    //        var concat = [];
    //
    //        // Multiple transitions.
    //        if (Array.isArray(transitions)) {
    //            concat = transitions;
    //        }
    //
    //        // Single transition.
    //        else if (transitions instanceof CameraManagerTransition) {
    //            concat = [transitions];
    //        }
    //
    //        // Valid input.
    //        if (concat.length !== 0) {
    //            // No previously registered translation for given trigger.
    //            if (typeof this.launchTable[key] === "undefined" || this.launchTable[key] === null || !Array.isArray(this.launchTable[key])) {
    //                var trigger_sequence = {};
    //                trigger_sequence.mode = mode;
    //                trigger_sequence.transitionIndex = 0;
    //                trigger_sequence.transitions = concat;
    //                this.launchTable[key] = trigger_sequence; // concat;
    //            }
    //            else {
    //                this.launchTable[key].mode = mode;
    //                this.launchTable[key].transitionIndex = 0;
    //                this.launchTable[key].transitions = this.launchTable[key].transitions.concat(concat);
    //            }
    //        }
    //
    //        return this;
    //    };
    // }  //useless bracket TO REMOVE


    /**
    * Instantly plays given set of transition, if no other is already running.
    * @param {Array}
    * @private
    */
    CameraManager.prototype.play = function (sequence) {
        var taskmanager;

        console.log("Play");

        // check trigger sequence
        if (typeof sequence === "undefined" || sequence === null) {
            console.error("CameraManager: sequence is undefined.");
            return this;
        }

        // retrieve task manager
        taskmanager = EP.TaskPlayer;
        if (typeof taskmanager === "undefined" || taskmanager === null) {
            console.error("CameraManager: no task manager.");
            return this;
        }

        // No current task. Create task.
        if (typeof this.task === "undefined" || this.task === null) {
            this.task = new CameraManagerTask(this);
            this.task.sequence = sequence;
            taskmanager.addTask(this.task);
            this.onTaskStart();
            return this;
        }

        // Task is already running.
        else if (this.task.isPlaying()) {
            if (sequence.trigger === this.task.sequence.trigger) {
                console.info("CameraManager: this task is already running.");
                return this;
            }
            else {
                console.info("CameraManager: interruption of the current task.");
                this.task.onTransitionEnd();
                // End task, it will destroy the task
                this.onTaskEnd();

                // Recreate task (it should not be running).
                this.task = new CameraManagerTask(this);
                this.task.sequence = sequence;
                taskmanager.addTask(this.task);
                this.onTaskStart();

                return this;
            }
        }

        // Task exist, but not running (Task ended previously).
        else {
            this.task.sequence = sequence;
            this.onTaskStart();
            return this;
        }
    };

    // ON TASK START
    CameraManager.prototype.onTaskStart = function () {
        if (typeof this.task === "undefined" || this.task === null) {
            console.error("No task on camera manager");
            return;
        }

        var rm;
        rm = STU.RenderManager.getInstance();
        if (typeof rm === "undefined" || rm === null) {
            console.log("No render manager");
            return;
        }

        if (typeof rm.getCurrentCamera() === "undefined" || rm.getCurrentCamera() === null) {
            console.log("No current camera");
            return;
        }

        this.activeCameraActor = rm.getCurrentCamera();
        this.task.start();
    };



    // ON TASK END
    CameraManager.prototype.onTaskEnd = function () {
        if (typeof this.task === "undefined" || this.task === null || 
            typeof this.task.sequence === "undefined" || this.task.sequence === null || 
            typeof this.sequences === "undefined" || this.sequences === null) {
            console.debug("this.task.sequence is undefined or null");
            return;
        }

        var i;
        for (i = 0; i < this.sequences.length; i++) {
            if (this.sequences[i].trigger === this.task.sequence.trigger) {
                this.sequences[i].transitionIndex = this.task.sequence.transitionIndex;
            }
        }

        // Stop task ... stop task this is not very effective
        this.task.stop();
        
        // Rmoeve task from task manager ... much more effective
        var taskmanager = EP.TaskPlayer;
        if (typeof taskmanager === "undefined" || taskmanager === null) {
            console.error("CameraManager: no task manager.");
            return this;
        }

        taskmanager.removeTask(this.task);
        this.task = null;

    };

	// Expose in STU namespace.
	STU.CameraManager = CameraManager;


	return CameraManager;
    });

define('StuCameras/StuCameraManager', ['DS/StuCameras/StuCameraManager'], function (CameraManager) {
    'use strict';

    return CameraManager;
});


define('DS/StuHuman/StuHumanManagerNa',
    ['DS/StuCore/StuContext', 'DS/StuCore/StuManager', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer', 'MathematicsES/MathsDef', 'DS/StuHuman/CATCXPHumanManager'],
    function (STU, Manager, Task, TaskPlayer, DSMath, CATCXPHumanManager) {
	'use strict';

    /**
    * The task allows to animate a Human.
    *
    * @exports HumanAnimationTask
    * @class
    * @constructor
    * @private
    * @extends EP.Task
    * @param {STU.HumanManager} iHumanManager
    * @memberof STU
    */
	var HumanManagerTask = function (iHumanManager) {
	    Task.call(this);

	    this._attachedMng = iHumanManager;
	    this._humanList = [];
	    this.collisionTreeCpp = null;
	};

	HumanManagerTask.prototype = new Task();
	HumanManagerTask.constructor = HumanManagerTask;

    /**
    * This is the classic run method of any task.
    *
    * @method
    * @private
    * @param {Object} iExContext, the context of execution passed to any task on it's run.
    */
	HumanManagerTask.prototype.onExecute = function (iExContext) {
	    this._attachedMng.humanManCpp.ExecuteSolverFrame(iExContext.getElapsedTime());
	    this._updateAllHumanTransforms();

	    return this;
	};

	HumanManagerTask.prototype.onStart = function () {
// 	    var motionBeCount = this._attachedMng._HumanMotions.length;
// 	    if (0 == motionBeCount) return this;
//
// 	    for (var i = 0; i < motionBeCount; i++) {
// 	        var humanMotion = this._attachedMng._HumanMotions[i];
// 	        var humanActor = humanMotion.getActor();
//
// 	        this._attachedMng.humanManCpp.RegisterHumanMotionBe(humanMotion.CATICXPHumanMotion);
// 	    }

	    this.collisionTreeCpp = this._attachedMng.humanManCpp.CreateAllCollisionTree();

	    this._attachedMng.humanManCpp.ExecuteSolverFrame(0.0);
	    this._updateAllHumanTransforms();

	    return this;
	};

	HumanManagerTask.prototype.onStop = function () {
	    var motionBeCount = this._attachedMng._HumanMotions.length;

	    for (var i = 0; i < motionBeCount; i++) {
	        var humanMotion = this._attachedMng._HumanMotions[i];
	        this._attachedMng.humanManCpp.UnregisterHumanMotionBe(humanMotion.CATICXPHumanMotion);
	    }
        
	    this._attachedMng.humanManCpp.DestroyAllCollisionTree();
        
        // eb7: why?!
	    /*for (var i = 0; i < motionBeCount; i++) {
	        var humanMotion = this._attachedMng._HumanMotions[i];
	        var humanActor = humanMotion.getActor();
	    }*/

	    return this;
	};

	HumanManagerTask.prototype._updateAllHumanTransforms = function () {
	    var motionBeCount = this._attachedMng._HumanMotions.length;
        for (var i = 0; i < motionBeCount; i++) {
            var humanMotion = this._attachedMng._HumanMotions[i];
            if (humanMotion._animate) {
                var humanActor = humanMotion.getActor();
                
                var transform = humanMotion.getLocation();

                humanActor.setTransform_ActorOnly(transform);
                humanActor.CATRTHuman.UpdateSkinning();
            }
	    }

	    return this;
	};

	/**
	 * The Human Manager provides the list of instancied humans
	 *
	 * @exports HumanManager
     * @class
	 * @constructor
     * @private
	 * @extends STU.Manager
     * @memberof STU
	 */
	var HumanManager = function () {

		Manager.call(this);

		this.name = 'HumanManager';

	    /**
	     * The array listing the human of this STU.HumanManager.
	     *
	     * @member
	     * @private
	     * @type {Array.<STU.HumanMotion>}
	     */
		this._HumanMotions = [];

		this.humanMsgCreated = null;
		this.humanMsgStatusChanged = null;
		//this.humanMsgReleased = null;
	};

	HumanManager.prototype = new Manager();
	HumanManager.prototype.constructor = HumanManager;

	/**
	 * Process to execute when this STU.HumanManager is initializing.
	 *
	 * @method
	 * @private
     * @see STU.HumanManager#onDispose
	 */
	HumanManager.prototype.onInitialize = function () {
	    Manager.prototype.onInitialize.call(this);

	    this._HumanMotions = [];

	    this.humanManCpp = CATCXPHumanManager.CATGetHumanManager();
	};

	/**
	 * Process to execute when this STU.HumanManager is disposing.
	 *
	 * @method
	 * @private
     * @see STU.HumanManager#onInitialize
	 */
	HumanManager.prototype.onDispose = function () {
	    if (this.associatedTask instanceof HumanManagerTask === true) {
	        TaskPlayer.removeTask(this.associatedTask);

	        delete this.associatedTask;
	        this.associatedTask = null;
	    }

	    STU.clear(this._HumanMotions);
	    delete this._HumanMotions;

	    Manager.prototype.onDispose.call(this);
	};

    /**
	 * Add a STU.HumanMotion on this STU.HumanManager.
	 *
	 * @method
	 * @private
	 * @param {STU.HumanMotion} iHumanMotion, instance object corresponding to the human motion behavior to add
	 */
	HumanManager.prototype.addHumanMotion = function (iHumanMotion) {
	    STU.pushUnique(this._HumanMotions, iHumanMotion);

	    if (this.associatedTask instanceof HumanManagerTask === false) {
            this.associatedTask = new HumanManagerTask(this);
	        TaskPlayer.addTask(this.associatedTask, STU.getTaskGroup(STU.ETaskGroups.eProcess));
	    }

	    this.humanManCpp.RegisterHumanMotionBe(iHumanMotion.CATICXPHumanMotion);

	    if (typeof iHumanMotion._animate === 'boolean') {
	        if (iHumanMotion._animate) {
	            iHumanMotion.CATICXPHumanMotion.ActivateAnimation();

	            // be sure to update actor transform here
	            // as transform is managed by the task, we resolved an issue if animate is set as false just after initialization
	            this.humanManCpp.ExecuteSolverFrame(0.0);

	            var humanActor = iHumanMotion.getActor();
	            var transform = iHumanMotion.getLocation();
                humanActor.setTransform_ActorOnly(transform);
                humanActor.CATRTHuman.UpdateSkinning();
	        } else {
	            iHumanMotion.CATICXPHumanMotion.DeactivateAnimation();
	        }
	    }
	};

    /**
	 * Remove a STU.HumanMotion from this STU.HumanManager.
	 *
	 * @method
	 * @private
	 * @param {STU.HumanMotion} iHumanMotion, instance object corresponding to the human motion behavior to remove
	 */
	HumanManager.prototype.removeHumanMotion = function (iHumanMotion) {
	    STU.remove(this._HumanMotions, iHumanMotion);
	};

    /**
	 * Human Message Created Event Handler
	 * Called by the Manager when a human message is created
	 *
	 * @method
	 * @private
	 * @param {Object} iHumanEvent, human created information
	 */
	HumanManager.prototype.onHumanMsgCreated = function (iHumanEvent) {
	    var humanActor = STU.resolveElementFromPath(iHumanEvent.humanAsPath);
	    if (humanActor !== undefined && humanActor !== null) {
	        var newEvt = new STU.HumanMsgCreatedEvent();

	        newEvt.setHuman(humanActor);
	        newEvt.setMessage(iHumanEvent.humanMsg);

	        this._resolveHumanMsgEvent(newEvt);
	    }
	};

	/**
	 * Human Message Status Changed Event Handler
	 * Called by the Manager when the status of a human message change
	 *
	 * @method
	 * @private
	 * @param {Object} iHumanEvent, human status information
	 */
	HumanManager.prototype.onHumanMsgStatusChanged = function (iHumanEvent) {
	    var humanActor = STU.resolveElementFromPath(iHumanEvent.humanAsPath);
	    if (humanActor !== undefined && humanActor !== null) {
	        var newEvt = new STU.HumanMsgStatusChangedEvent();

	        newEvt.setHuman(humanActor);
	        newEvt.setMessage(iHumanEvent.humanMsg);

	        this._resolveHumanMsgEvent(newEvt);
	    }
	};

    /**
	 * Human Message Released Event Handler
	 * Called by the Manager when a human message is released
	 *
	 * @method
	 * @private
	 * @param {Object} iHumanEvent, human released information
	 */
	HumanManager.prototype.onHumanMsgReleased = function (iHumanEvent) {
// 	    var humanActor = STU.resolveElementFromPath(iHumanEvent.humanAsPath);
// 	    if (humanActor !== undefined && humanActor !== null) {
// 	        var newEvt = new STU.HumanMsgReleasedEvent();
//
// 	        newEvt.setHuman(humanActor);
// 	        newEvt.setMessage(iHumanEvent.humanMsg);
//
// 	        this._resolveHumanMsgEvent(newEvt);
// 	    }

	};

    /**
	 * Human Collision Event Handler
	 * Called by the Manager when a human collide
	 *
	 * @method
	 * @private
	 * @param {Object} iHumanEvent, human created information
	 */
// 	HumanManager.prototype.onHumanCollision = function (iHumanEvent) {
// 	    var newEvt = new STU.HumanCollisiondEvent(iHumanEvent.human);
// 	    EventServices.dispatchEvent(newEvt);
//
// 	    this._resolveHumanMsgEvent(iHumanEvent);
// 	};

    /**
	 * Human Send Event
	 *
	 * @method
	 * @private
	 * @param {Object} iHumanEvent, human created information
	 */
	HumanManager.prototype._sendHumanEvent = function (iHumanEvent) {
	    if (iHumanEvent !== undefined && iHumanEvent !== null) {
	        var humanActor = iHumanEvent.getHuman();
	        if (humanActor !== undefined && humanActor !== null) {
	            humanActor.dispatchEvent(iHumanEvent);
	        }
	    }
	};


	HumanManager.prototype._resolveHumanMsgEvent = function (iHumanEvent) {
	    var newEvt;
	    if (iHumanEvent !== undefined && iHumanEvent !== null) {
	        if (iHumanEvent.human !== undefined && iHumanEvent.human !== null) {
	            if (iHumanEvent.message !== undefined && iHumanEvent.message !== null) {
	                if (iHumanEvent.message.name === '__GoTo__') {
	                    if (iHumanEvent.message.status === 'STARTED') {
	                        newEvt = new STU.HumanGoToEvent();
	                        newEvt.setHuman(iHumanEvent.human);
	                        newEvt.setLocation(iHumanEvent.message.point);
	                        this._sendHumanEvent(newEvt);
	                    }
	                    else if (iHumanEvent.message.status === 'DONE') {
	                        newEvt = new STU.HumanReachEvent();
	                        newEvt.setHuman(iHumanEvent.human);
	                        newEvt.setLocation(iHumanEvent.message.point);
	                        this._sendHumanEvent(newEvt);
	                        EP.EventServices.dispatchEvent(new STU.ServiceStoppedEvent('goTo', iHumanEvent.human));
	                    }
	                }
	                else if (iHumanEvent.message.name === '__FollowPath__') {
	                    if (iHumanEvent.message.status === 'STARTED') {
	                        newEvt = new STU.HumanFollowPathEvent();
	                        newEvt.setHuman(iHumanEvent.human);
	                        newEvt.setPath(iHumanEvent.message.path);
	                        this._sendHumanEvent(newEvt);
	                    }
	                    else if (iHumanEvent.message.status === 'DONE') {
	                        newEvt = new STU.HumanPathCompletedEvent();
	                        newEvt.setHuman(iHumanEvent.human);
	                        newEvt.setPath(iHumanEvent.message.path);
	                        this._sendHumanEvent(newEvt);
	                        EP.EventServices.dispatchEvent(new STU.ServiceStoppedEvent('followPath', iHumanEvent.human));
	                    }
	                }
	                else if (iHumanEvent.message.name === '__CharacterControl__') {
	                    if (iHumanEvent.message.status === 'STARTED') {
	                        newEvt = new STU.HumanCharacterControlEvent(iHumanEvent.human, iHumanEvent.message.direction, iHumanEvent.message.orientation);
	                        newEvt.setHuman(iHumanEvent.human);
	                        newEvt.setDirection(iHumanEvent.message.direction);
	                        newEvt.setOrientation(iHumanEvent.message.orientation);
	                        this._sendHumanEvent(newEvt);
	                    }
	                }
	            }
	        }
	    }
	};

	STU.registerManager(HumanManager);

	// Expose in STU namespace.
	STU.HumanManager = HumanManager;

	return HumanManager;
});

define('StuHuman/StuHumanManagerNa', ['DS/StuHuman/StuHumanManagerNa'], function (HumanManager) {
    'use strict';

    return HumanManager;
});

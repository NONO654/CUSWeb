// define('DS/StuSound/StuSoundManager', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager', 'DS/StuSound/StuSoundListener', 'DS/StuSound/StuSoundPlayer', 'DS/EPTaskPlayer/EPTask'], function (STU, Manager, SoundListener, SoundPlayer, Task) {
// 	'use strict';


// 	/**
// 	 * SoundListener HANDLER TASK.
// 	 */

// 	var SoundManagerTask = function (sndHandler) {
// 		Task.call(this);
// 		this.sndHandler = sndHandler;
// 	};

// 	SoundManagerTask.prototype = new Task();
// 	SoundManagerTask.constructor = SoundManagerTask;

// 	/**
// 	 * Method called each frame by the task manager
// 	 *
// 	 * @method
// 	 * @private
// 	 * @param  iExeCtx Execution context
// 	 */
// 	SoundManagerTask.prototype.onExecute = function () {

// 		if (this.sndHandler === undefined || this.sndHandler === null) {
// 			return this;
// 		}
// 		var sndHandler = this.sndHandler;

// 		sndHandler.update();
// 	};



// 	var SoundManager = function () {

// 		Manager.call(this);

// 		this.name = 'SoundManager';


// 		this.soundSources = [];

// 		this.soundListeners = [];

// 		this.activeListener = null;
// 		this.soundListenerWrapper = null;
// 	};

// 	SoundManager.prototype = new Manager();
// 	SoundManager.prototype.constructor = SoundManager;


// 	SoundManager.prototype.onInitialize = function () {
		

// 		this.associatedTask = new SoundManagerTask(this);
// 		EP.TaskPlayer.addTask(this.associatedTask);
// 	};


// 	SoundManager.prototype.onDispose = function () {
// 		delete this.soundListenerWrapper;
// 	};

// 	SoundManager.prototype.update = function () {
// 	    if ((this.soundListenerWrapper === undefined || this.soundListenerWrapper === null) && this.soundSources.length >0) {
// 	        this.soundListenerWrapper = new stu__SoundListenerWrapper();
// 	        this.soundListenerWrapper.setVolume(1.0);
// 	        this.soundListenerWrapper.setPosition({ x: 0, y: 0, z: 0 });
// 	        this.soundListenerWrapper.setOrientation({ x: 1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
// 	    }

// 	    if (this.activeListener !== undefined && this.activeListener !== null) {
// 			var wrapper = this.soundListenerWrapper;
// 			var lsner = this.activeListener;

// 			wrapper.setVolume(lsner.volume);
// 			wrapper.setPosition(lsner._position.multiplyScalar(0.001)); // cxp unit is mm sound engine is m
// 			wrapper.setOrientation(lsner._forward, lsner._up);
// 		}
// 	};

// 	//useless for now but will serve on day 
// 	SoundManager.prototype.addSource = function (iSource) {
// 		STU.pushUnique(this.soundSources, iSource);
// 	};


// 	SoundManager.prototype.removeSource = function (iSource) {
// 		STU.remove(this.soundSources, iSource);
// 	};


// 	//only one Listener can be alive at a given time 
// 	SoundManager.prototype.addListener = function (iListener) {
// 		STU.pushUnique(this.soundListeners, iListener);

// 		if (this.activeListener === undefined || this.activeListener === null) {
// 			this.activeListener = iListener;
// 		}
// 	};

// 	SoundManager.prototype.removeListener = function (iListener) {
// 		STU.remove(this.soundListeners, iListener);

// 		if (this.activeListener === iListener) {

// 			if (this.soundListeners.length > 0) {
// 				this.activeListener = this.soundListeners[0];
// 			} else {
// 				this.activeListener = null;
// 			}
// 		}
// 	};


// 	STU.registerManager(SoundManager);

// 	// Expose in STU namespace.
// 	STU.SoundManager = SoundManager;

// 	return SoundManager;
// });

//define('StuSound/StuSoundManager', ['DS/StuSound/StuSoundManager'], function (SoundManager) {
//    'use strict';

//   return SoundManager;
//});

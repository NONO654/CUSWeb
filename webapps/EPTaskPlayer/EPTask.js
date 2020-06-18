define('DS/EPTaskPlayer/EPTask', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * <p>Describe an object which can be instantiate and added to the task player.</br>
	 * Its methods start, pause, resume and stop are called by the task player.</br>
	 * These callbacks are indirectly link to the UI play compass action.</p>
	 *
	 * <p>After a start or a resume, the task is executed each frame in order to perform scripting code.</br>
	 * After a pause or a stop, the execution is disabled.</p>
	 *
	 * @constructor
	 * @alias EP.Task
	 * @private
	 * @example
	 * var MyTask = function () {
	 *	EP.Task.Call(this);
	 * }
	 * MyTask.prototype = new EP.Task();
	 * MyTask.prototype.constructor = MyTask;
	 * MyTask.prototype.onStart = function () {
	 *	// called when the experience is starting
	 * };
	 * MyTask.prototype.onStop = function () {
	 *	// called when the experience is stopping
	 * };
	 * MyTask.prototype.onExecute = function (iPlayerContext) {
	 *	// code to execute
	 * };
	 */
	var Task = function () {

	    /**
	     * Play state of this task.
	     *
	     * @private
	     * @type {EP.Task.EPlayState}
	     */
	    this.playState = Task.EPlayState.eStopped;
	};

	/**
	 * An enumeration for all possible play state.
	 *
	 * @enum {number}
	 * @private
	 * @example
	 * var myTask = new MyTask();
	 * if(myTask.getPlayState() === EP.Task.EPlayState.eStopped) {
	 *	// my task is stopped
	 * }
	 */
	Task.EPlayState = { eStarting: 0, eStarted: 1, ePausing: 2, ePaused: 3, eResuming: 4, eResumed: 5, eStopping: 6, eStopped: 7, eExecuting: 8, eExecuted: 9 };
	Object.freeze(Task.EPlayState);

	Task.prototype.constructor = Task;

	/**
	 * Return the play state of this task.
	 *
	 * @private
	 * @return {EP.Task.EPlayState}
	 * @example
	 * var myTask = new MyTask();
	 * if(myTask.getPlayState() === EP.Task.EPlayState.eStopped) {
	 *	// my task is stopped
	 * }
	 */
	Task.prototype.getPlayState = function () {
		return this.playState;
	};

	/**
	 * Check if this task is playing.
	 *
	 * @private
	 * @return {boolean}
	 * @example
	 * if(myTask.isPlaying()) {
	 *	// my task is playing
	 * }
	 */
	Task.prototype.isPlaying = function () {
		return (this.playState === Task.EPlayState.eStarted ||
				this.playState === Task.EPlayState.eResumed ||
				this.playState === Task.EPlayState.eExecuted ||
				this.playState === Task.EPlayState.eExecuting);
	};

	/**
	 * Check if this task is executable.
	 *
	 * @private
	 * @return {boolean}
	 */
	Task.prototype.isExecutable = function () {
		return (this.playState === Task.EPlayState.eStarted ||
				this.playState === Task.EPlayState.eResumed ||
				this.playState === Task.EPlayState.eExecuted);
	};

	/**
	 * Check if this task is startable.
	 *
	 * @private
	 * @return {boolean}
	 */
	Task.prototype.isStartable = function () {
		return (this.playState === Task.EPlayState.eStopped);
	};

	/**
	 * Check if this task is resumable.
	 *
	 * @private
	 * @return {boolean}
	 */
	Task.prototype.isResumable = function () {
		return (this.playState === Task.EPlayState.ePaused);
	};

	/**
	 * Check if this task is pausable.
	 *
	 * @private
	 * @return {boolean}
	 */
	Task.prototype.isPausable = function () {
		return (this.playState === Task.EPlayState.eStarted ||
				this.playState === Task.EPlayState.eResumed ||
				this.playState === Task.EPlayState.eExecuted);
	};

	/**
	 * Check if this task is stoppable.
	 *
	 * @private
	 * @return {boolean}
	 */
	Task.prototype.isStoppable = function () {
		return (this.playState === Task.EPlayState.eStarted ||
			    this.playState === Task.EPlayState.eResumed ||
				this.playState === Task.EPlayState.ePaused ||
				this.playState === Task.EPlayState.eExecuted);
	};

	/**
	 * Execute this task.
	 *
	 * @private
	 * @param {EP.PlayerContext} iPlayerContext
	 * @return {boolean} true: success, false: failure
	 */
	Task.prototype.execute = function (iPlayerContext) {
		var result = false;
		if (this.isExecutable()) {
			this.playState = Task.EPlayState.eExecuting;
			try {
				this.onExecute(iPlayerContext);
			}
			catch (error) {
				console.error(error.stack);
			}
			this.playState = Task.EPlayState.eExecuted;
			result = true;
		}
		return result;
	};

	/**
	 * Start this task.
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTask = new MyTask();
	 * myTask.start();
	 */
	Task.prototype.start = function () {
		var result = false;
	    if (this.isStartable()) {
			this.playState = Task.EPlayState.eStarting;
	    	try {
	    		this.onStart();
	    	}
	    	catch (error) {
	    		console.error(error.stack);
	    	}
			this.playState = Task.EPlayState.eStarted;
			result = true;
	    }
	    return result;
	};

	/**
	 * Resume this task.
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @example
	 * myTask.resume();
	 */
	Task.prototype.resume = function () {
		var result = false;
		if (this.isResumable()) {
			this.playState = Task.EPlayState.eResuming;
			try {
				this.onResume();
			}
			catch (error) {
				console.error(error.stack);
			}
			this.playState = Task.EPlayState.eResumed;
			result = true;
		}
		return result;
	};

	/**
	 * Pause this task.
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @example
	 * myTask.pause();
	 */
	Task.prototype.pause = function () {
		var result = false;
		if (this.isPausable()) {
			this.playState = Task.EPlayState.ePausing;
			try {
				this.onPause();
			}
			catch (error) {
				console.error(error.stack);
			}
			this.playState = Task.EPlayState.ePaused;
			result = true;
		}
		return result;
	};

	/**
	 * Stop this task.
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @example
	 * myTask.stop();
	 */
	Task.prototype.stop = function () {
		var result = false;
	    if (this.isStoppable()) {
			this.playState = Task.EPlayState.eStopping;
	    	try {
	    		this.onStop();
	    	}
	    	catch (error) {
	    		console.error(error.stack);
	    	}
			this.playState = Task.EPlayState.eStopped;
			result = true;
	    }
	    return result;
	};

	/**
	 * Synchronize this task with a play state.
	 *
	 * @private
	 * @param {EP.Task.EPlayState} iPlayState
	 * @example
	 * myTask.synchronize(EP.Task.EPlayState.eExecuting);
	 */
	Task.prototype.synchronize = function (iPlayState) {
		if (iPlayState === this.playState) {
			return;
		}

		switch (iPlayState) {
			case EP.Task.EPlayState.eStarting:
				{
					this.start();
					break;
				}
			case EP.Task.EPlayState.eStarted:
				{
					this.start();
					break;
				}
			case EP.Task.EPlayState.ePausing:
				{
					this.start();
					this.pause();
					break;
				}
			case EP.Task.EPlayState.ePaused:
				{
					this.start();
					this.pause();
					break;
				}
			case EP.Task.EPlayState.eResuming:
				{
					this.start();
					this.pause();
					this.resume();
					break;
				}
			case EP.Task.EPlayState.eResumed:
				{
					this.start();
					this.pause();
					this.resume();
					break;
				}
			case EP.Task.EPlayState.eStopping:
				{
					this.stop();
					break;
				}
			case EP.Task.EPlayState.eStopped:
				{
					this.stop();
					break;
				}
			case EP.Task.EPlayState.eExecuting:
				{
					this.start();
					break;
				}
			case EP.Task.EPlayState.eExecuted:
				{
					this.start();
					break;
				}
		}
	};

	/**
	 * Process to execute when this task is executing.
	 *
	 * @private
	 * @param {EP.PlayerContext} iPlayerContext
	 */
	Task.prototype.onExecute = function () {

	};

	/**
	 * Process to execute when this task is starting.
	 *
	 * @private
	 */
	Task.prototype.onStart = function () {

	};

	/**
	 * Process to execute when this task is resuming.
	 *
	 * @private
	 */
	Task.prototype.onResume = function () {

	};

	/**
	 * Process to execute when this task is pausing.
	 *
	 * @private
	 */
	Task.prototype.onPause = function () {

	};

	/**
	 * Process to execute when this task is stopping.
	 *
	 * @private
	 */
	Task.prototype.onStop = function () {

	};

	// Expose in EP namespace.
	EP.Task = Task;

	return Task;
});

define('EPTaskPlayer/EPTask', ['DS/EPTaskPlayer/EPTask'], function (Task) {
	'use strict';

	return Task;
});

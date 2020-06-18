define('DS/EPTaskPlayer/EPTaskGroup', ['DS/EP/EP', 'DS/EPTaskPlayer/EPTask'], function (EP, Task) {
	'use strict';

	/**
	 * <p>Describe a task which can be instantiate and added to the task player.</br>
	 * It manages the play of tasks during the experience.</br>
	 * It has a list of tasks on which it performs a start, pause, resume and stop method call.</br>
	 * These callbacks are indirectly link to the UI play compass action.</p>
	 *
	 * <p>After a start or a resume, every task is executed each frame in order to perform scripting code.</br>
	 * After a pause or a stop, the execution is disabled.</p>
	 *
	 * @constructor
	 * @alias EP.TaskGroup
	 * @private
	 * @extends EP.Task
	 */
	var TaskGroup = function () {

		Task.call(this);

		/**
		 * The array listing the tasks of this task group.
		 *
		 * @private
		 * @type {Array.<EP.Task>}
		 */
		this.tasks = [];

		/**
		 * The array listing the tasks to call of this task group.
		 *
		 * @private
		 * @type {Array.<EP.Task>}
		 */
		this.tasksToCall = [];
	};

	TaskGroup.prototype = Object.create(Task.prototype);
	TaskGroup.prototype.constructor = TaskGroup;

	/**
	 * Add a task on this task group.
	 *
	 * @private
	 * @param {EP.Task} iTask instance object corresponding to the task to add
	 * @param {boolean} [iSynchronize=true] to synchronize the task with his task group to make it playable, by default: true
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTask = new Task();
	 * // Add Task to execute code
	 * taskGroup.addTask(myTask);
	 * // Remove Task when you don't need it anymore
	 * taskGroup.removeTask(myTask);
	 */
	TaskGroup.prototype.addTask = function (iTask, iSynchronize) {
		var result = false;
		if (iSynchronize === undefined) {
			iSynchronize = true;
		}

		if (this.tasks.indexOf(iTask) === -1) {
			if (iSynchronize) {
				iTask.synchronize(this.playState);
			}
			this.tasks.push(iTask);
			result = true;
		}

		return result;
	};

	/**
	 * Remove a task from this task group.
	 *
	 * @private
	 * @param {EP.Task} iTask instance object corresponding to the task to remove
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTask = new Task();
	 * // Add Task to execute code
	 * taskGroup.addTask(myTask);
	 * // Remove Task when you don't need it anymore
	 * taskGroup.removeTask(myTask);
	 */
	TaskGroup.prototype.removeTask = function (iTask) {
		var result = false;

		var index = this.tasks.indexOf(iTask);
		if (index !== -1) {
			this.tasks.splice(index, 1);
			index = this.tasksToCall.indexOf(iTask);
			if (index !== -1) {
				this.tasksToCall.splice(index, 1);
			}
			result = true;
		}

		return result;
	};

	/**
	 * Return an array listing the tasks of this task group.</br>
	 * The returned array is a copy of the internal task list.</br>
	 * Do not expect to modify it to add or remove a task.
	 *
	 * @private
	 * @return {Array.<EP.Task>} Array of EP.Task instance object
	 * @example
	 * var tasks = taskGroup.getTasks();
	 * for(var i=0; i&lt;tasks.length; i++) {
	 *	// tasks[i] has been added on this task group
	 * }
	 */
	TaskGroup.prototype.getTasks = function () {
		return this.tasks.slice(0);
	};

	/**
	 * Process to execute when this task group is executing.</br>
	 * Perform one execute on all the task registered in this task group.
	 *
	 * @private
	 * @param {EP.PlayerContext} iPlayerContext
	 */
	TaskGroup.prototype.onExecute = function (iPlayerContext) {
		this.tasksToCall = this.getTasks();
		while (this.tasksToCall.length > 0) {
			this.tasksToCall.shift().execute(iPlayerContext);
		}
	};

	/**
	 * Process to execute when this task group is executing.</br>
	 * Perform one start on all the task registered in this task group.
	 *
	 * @private
	 */
	TaskGroup.prototype.onStart = function () {
		this.tasksToCall = this.getTasks();
		while (this.tasksToCall.length > 0) {
			this.tasksToCall.shift().start();
		}
	};

	/**
	 * Process to execute when this task group is executing.</br>
	 * Perform one resume on all the task registered in this task group.
	 *
	 * @private
	 */
	TaskGroup.prototype.onResume = function () {
		this.tasksToCall = this.getTasks();
		while (this.tasksToCall.length > 0) {
			this.tasksToCall.shift().resume();
		}
	};

	/**
	 * Process to execute when this task group is executing.</br>
	 * Perform one pause on all the task registered in this task group.
	 *
	 * @private
	 */
	TaskGroup.prototype.onPause = function () {
		this.tasksToCall = this.getTasks();
		while (this.tasksToCall.length > 0) {
			this.tasksToCall.pop().pause();
		}
	};

	/**
	 * Process to execute when this task group is executing.</br>
	 * Perform one stop on all the task registered in this task group.
	 *
	 * @private
	 */
	TaskGroup.prototype.onStop = function () {
		this.tasksToCall = this.getTasks();
		while (this.tasksToCall.length > 0) {
			this.tasksToCall.pop().stop();
		}
	};

	// Expose in EP namespace.
	EP.TaskGroup = TaskGroup;

	return TaskGroup;
});

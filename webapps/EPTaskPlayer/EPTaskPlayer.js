define('DS/EPTaskPlayer/EPTaskPlayer', [
	'DS/EP/EP',
	'DS/EPTaskPlayer/EPTask',
	'DS/EPTaskPlayer/EPTaskGroup',
	'DS/EPTaskPlayer/EPPlayerContext'
], function (EP, Task, TaskGroup, PlayerContext) {
	'use strict';

	/**
	 * <p>Describe an object which manages the play of tasks during the experience.</br>
	 * It has a list of tasks on which it performs a start, pause, resume and stop method call.</br>
	 * These callbacks are indirectly link to the UI play compass action.</p>
	 *
	 * <p>After a start or a resume, every task is executed each frame in order to perform scripting code.</br>
	 * After a pause or a stop, the execution is disabled.</p>
	 *
	 * <p>The task player can be used with two different ways. </br>
	 * It is possible to add directly tasks to the task player. </br>
	 * But it is also possible to add task groups to manage the play order of the tasks. </br>
	 * The play order of these task groups is corresponding to the list order of them. </br>
	 * Then, each task can be added to one of these task groups. </br>
	 * But the user can't use the task player with the two ways in the same time. </br>
	 * If someone add a new task directly to the task player, then it will not be possible to add task group. </br>
	 * If someone add a new task group to the task player, then when someone adds a new task it will be assign automatically to a default task group. </br>
	 * The default task group is the first task group added to the task player. But it is possible to set a new default task group later. </p>
	 *
	 * @namespace
	 * @alias EP.TaskPlayer
	 * @private
	 * @example
	 * var myPreTaskGroup = new TaskGroup();
	 * // Add Pre Task Group
	 * EP.TaskPlayer.addTaskGroup(myPreTaskGroup);
	 * var myPostTaskGroup = new TaskGroup();
	 * // Add Post Task Group
	 * EP.TaskPlayer.addTaskGroup(myPostTaskGroup);
	 * var myMainTaskGroup = new TaskGroup();
	 * // Add Main Task Group
	 * EP.TaskPlayer.addTaskGroup(myMainTaskGroup, myPostTaskGroup);
	 * // Set Main Task Group as default
	 * EP.TaskPlayer.setDefaultTaskGroup(myMainTaskGroup);
	 * var myPreTask = new Task();
	 * // Add Pre Task
	 * EP.TaskPlayer.addTask(myPreTask, myPreTaskGroup);
	 * var myMainTask = new Task();
	 * // Add Main Task
	 * EP.TaskPlayer.addTask(myMainTask);
	 * var myPostTask = new Task();
	 * // Add Post Task
	 * EP.TaskPlayer.addTask(myPostTask, myPostTaskGroup);
	 * // Execute code
	 * // Remove Post Task
	 * EP.TaskPlayer.removeTask(myPostTask, myPostTaskGroup);
	 * // Remove Main Task
	 * EP.TaskPlayer.removeTask(myMainTask, myMainTaskGroup);
	 * // Remove Pre Task
	 * EP.TaskPlayer.removeTask(myPreTask, myPreTaskGroup);
	 * // Remove Post Task Group
	 * EP.TaskPlayer.removeTask(myPostTaskGroup);
	 * // Remove Main Task Group
	 * EP.TaskPlayer.removeTask(myMainTaskGroup);
	 * // Remove Pre Task Group
	 * EP.TaskPlayer.removeTask(myPreTaskGroup);
	 */
	var TaskPlayer = {};

	/**
	 * The default task group of the task player.
	 *
	 * @private
	 * @type {EP.TaskGroup}
	 */
	var defaultTaskGroup = new TaskGroup();

	/**
	 * The root task group containing the task groups of the task player.
	 *
	 * @private
	 * @type {Array.<EP.TaskGroup>}
	 */
	var rootTaskGroup = new TaskGroup();
	rootTaskGroup.tasks[0] = defaultTaskGroup;

	/**
	 * Process to execute when the task player is initializing.
	 *
	 * @private
	 * @see EP.TaskPlayer.dispose
	 */
	TaskPlayer.initialize = function () {

	};

	/**
	 * Process to execute when the task player is disposing.
	 *
	 * @private
	 * @see EP.TaskPlayer.initialize
	 */
	TaskPlayer.dispose = function () {
		defaultTaskGroup = new TaskGroup();
		rootTaskGroup = new TaskGroup();
		rootTaskGroup.tasks[0] = defaultTaskGroup;
	};

	/**
	 * Add a task group on the task player. </br>
	 * By default, it will be the last one in the list order. </br>
	 * But it is possible to add it before another one. </p>
	 * The first task group added will be set as default task group. </br>
	 * To change the default task group use the appropriate API.
	 *
	 * @private
	 * @param {EP.TaskGroup} iTaskGroup instance object corresponding to the task group to add
	 * @param {EP.TaskGroup} [iPostTaskGroup] instance object corresponding to the task group which will be after the task group to add
	 * @param {boolean} [iSynchronize=true] to synchronize the task with his task group to make it playable, by default: true
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTaskGroup = new TaskGroup();
	 * // Add Task Group to order your execution
	 * EP.TaskPlayer.addTaskGroup(myTaskGroup, myPostTaskGroup);
	 * // Remove Task Group when you don't need it anymore
	 * EP.TaskPlayer.removeTaskGroup(myTaskGroup);
	 */
	TaskPlayer.addTaskGroup = function (iTaskGroup, iPostTaskGroup, iSynchronize) {
		var result = false;
		if (iSynchronize === undefined) {
			iSynchronize = true;
		}

		if (!(iTaskGroup instanceof TaskGroup)) {
			throw new TypeError('iTaskGroup argument is not a EP.TaskGroup');
		}

		if (iPostTaskGroup !== undefined) {
			if (!(iPostTaskGroup instanceof TaskGroup)) {
				throw new TypeError('iPostTaskGroup argument is not a EP.TaskGroup');
			}

			var index = rootTaskGroup.tasks.indexOf(iPostTaskGroup);
			if (index === -1) {
				throw new TypeError('iPostTaskGroup argument has not been added to the task player');
			}

			if (rootTaskGroup.tasks.indexOf(iTaskGroup) === -1) {
				if (iSynchronize) {
					iTaskGroup.synchronize(rootTaskGroup.playState);
				}
				rootTaskGroup.tasks.splice(index, 0, iTaskGroup);
				result = true;
			}
		}
		else {
			if (rootTaskGroup.tasks.length === 1 && defaultTaskGroup.tasks.length !== 0) {
				throw new TypeError('Tasks have already been added to the task player without any task group');
			}

			result = rootTaskGroup.addTask(iTaskGroup, iSynchronize);
			if (rootTaskGroup.tasks.length === 2) {
				defaultTaskGroup = iTaskGroup;
			}
		}

		return result;
	};

	/**
	 * Remove a task group from the task player. </br>
	 * If the task group to remove is the default task group then the new default task group will be the first in the list order. </br>
	 * If the task group to remove is the last one, then there is no default task group anymore. </br>
	 * Then, the new tasks will be added directly to the task player as before when there wasn't any task group.
	 *
	 * @private
	 * @param {EP.TaskGroup} iTaskGroup instance object corresponding to the task group to remove
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTaskGroup = new TaskGroup();
	 * // Add Task Group to order your execution
	 * EP.TaskPlayer.addTaskGroup(myTaskGroup, myOtherTaskGroup);
	 * // Remove Task Group when you don't need it anymore
	 * EP.TaskPlayer.removeTaskGroup(myTaskGroup);
	 */
	TaskPlayer.removeTaskGroup = function (iTaskGroup) {
		var result = false;

		if (!(iTaskGroup instanceof TaskGroup)) {
			throw new TypeError('iTaskGroup argument is not a EP.TaskGroup');
		}

		result = rootTaskGroup.removeTask(iTaskGroup);
		if (defaultTaskGroup === iTaskGroup) {
			defaultTaskGroup = rootTaskGroup.tasks[1] || rootTaskGroup.tasks[0];
		}

		return result;
	};

	/**
	 * Set the default task group of the task player. </br>
	 * This task group has to be already added to the task player. </br>
	 * By default, the task player hasn't any default task group, and the tasks are added to the task player directly. </br>
	 * Once the user set a default task group, the tasks will be added to this task group by default, when there is no task group specified.
	 *
	 * @private
	 * @param {EP.TaskGroup} iTaskGroup instance object corresponding to the default task group
	 * @return {boolean} true: success, false: failure
	 * @example
	 * EP.TaskPlayer.setDefaultTaskGroup(myDefaultTaskGroup);
	 */
	TaskPlayer.setDefaultTaskGroup = function (iTaskGroup) {
		var result = false;

		if (!(iTaskGroup instanceof TaskGroup)) {
			throw new TypeError('iTaskGroup argument is not a EP.TaskGroup');
		}

		if (rootTaskGroup.tasks.indexOf(iTaskGroup) === -1) {
			throw new TypeError('iTaskGroup argument has not been added to the task player');
		}

		if (iTaskGroup !== defaultTaskGroup) {
			defaultTaskGroup = iTaskGroup;
			result = true;
		}

		return result;
	};

	/**
	 * Return an array listing the task groups of the task player.</br>
	 * The returned array is a copy of the internal task group list.</br>
	 * Do not expect to modify it to add or remove a task group.
	 *
	 * @private
	 * @return {Array.<EP.TaskGroup>} Array of EP.TaskGroup instance object
	 * @example
	 * var taskGroups = EP.TaskPlayer.getTaskGroups();
	 * for(var i=0; i&lt;taskGroups.length; i++) {
	 *	// taskGroups[i] has been added on the task player
	 * }
	 */
	TaskPlayer.getTaskGroups = function () {
		return rootTaskGroup.tasks.slice(1);
	};

	/**
	 * Add a task on the task player. </br>
	 * It is possible to specify a task group which will contain the task to add. </br>
	 * By default, if there is no task group specified, the task will be added to the default task group. </br>
	 * If there is no default task group, the task will be added directly to the task player.
	 *
	 * @private
	 * @param {EP.Task} iTask instance object corresponding to the task to add
	 * @param {EP.TaskGroup} [iTaskGroup] instance object corresponding to the task group which will contain the task to add
	 * @param {boolean} [iSynchronize=true] to synchronize the task with his task group to make it playable, by default: true
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTask = new Task();
	 * // Add Task to execute code
	 * EP.TaskPlayer.addTask(myTask, myTaskGroup);
	 * // Remove Task when you don't need it anymore
	 * EP.TaskPlayer.removeTask(myTask, myTaskGroup);
	 */
	TaskPlayer.addTask = function (iTask, iTaskGroup, iSynchronize) {
		var result = false;

		if (!(iTask instanceof Task)) {
			throw new TypeError('iTask argument is not a EP.Task');
		}

		if (iTaskGroup !== undefined) {
			if (!(iTaskGroup instanceof TaskGroup)) {
				throw new TypeError('iTaskGroup argument is not a EP.TaskGroup');
			}

			if (rootTaskGroup.tasks.indexOf(iTaskGroup) === -1) {
				throw new TypeError('iTaskGroup argument has not been added to the task player');
			}

			result = iTaskGroup.addTask(iTask, iSynchronize);
		}
		else {
			result = defaultTaskGroup.addTask(iTask, iSynchronize);
		}

		return result;
	};

	/**
	 * Remove a task from the task player. </br>
	 * It is possible to specify the task group containing the task to remove. </br>
	 * By default, if there is no task group specified, the function will find the corresponding task group and then remove the task from it.
	 *
	 * @private
	 * @param {EP.Task} iTask instance object corresponding to the task to remove
	 * @param {EP.TaskGroup} [iTaskGroup] instance object corresponding to the task group containing the task to remove
	 * @return {boolean} true: success, false: failure
	 * @example
	 * var myTask = new Task();
	 * // Add Task to execute code
	 * EP.TaskPlayer.addTask(myTask, myTaskGroup);
	 * // Remove Task when you don't need it anymore
	 * EP.TaskPlayer.removeTask(myTask, myTaskGroup);
	 */
	TaskPlayer.removeTask = function (iTask, iTaskGroup) {
		var result = false;

		if (!(iTask instanceof Task)) {
			throw new TypeError('iTask argument is not a EP.Task');
		}

		if (iTaskGroup !== undefined) {
			if (!(iTaskGroup instanceof TaskGroup)) {
				throw new TypeError('iTaskGroup argument is not a EP.TaskGroup');
			}

			if (rootTaskGroup.tasks.indexOf(iTaskGroup) === -1) {
				throw new TypeError('iTaskGroup argument has not been added to the task player');
			}

			result = iTaskGroup.removeTask(iTask);
		}
		else {
			for (var i = 0; !result && i < rootTaskGroup.tasks.length; i++) {
				result = rootTaskGroup.tasks[i].removeTask(iTask);
			}
		}

		return result;
	};

	/**
	 * Return an array listing all the tasks of the task player.</br>
	 * The returned array is a copy of the internal task list.</br>
	 * Do not expect to modify it to add or remove a task.
	 *
	 * @private
	 * @return {Array.<EP.Task>} Array of EP.Task instance object
	 * @example
	 * var tasks = EP.TaskPlayer.getTasks();
	 * for(var i=0; i&lt;tasks.length; i++) {
	 *	// tasks[i] has been added on the task player
	 * }
	 */
	TaskPlayer.getTasks = function () {
		var tasks = [];

		for (var i = 0; i < rootTaskGroup.tasks.length; i++) {
			tasks = tasks.concat(rootTaskGroup.tasks[i].getTasks());
		}

		return tasks;
	};

	/**
	 * Return the play state of the task player.
	 *
	 * @private
	 * @return {EP.Task.EPlayState}
	 * @example
	 * if(EP.TaskPlayer.getPlayState() === EP.Task.EPlayState.eStarting) {
	 *	// the task player is starting
	 * }
	 */
	TaskPlayer.getPlayState = function () {
		return rootTaskGroup.getPlayState();
	};

	/**
	 * Check if the task player is playing.
	 *
	 * @private
	 * @return {boolean}
	 * @example
	 * if(EP.TaskPlayer.isPlaying()) {
	 *	// the task player is playing
	 * }
	 */
	TaskPlayer.isPlaying = function () {
		return rootTaskGroup.isPlaying();
	};

	/**
	 * Execute the task player.
	 *
	 * @private
	 * @param {Object} iExContext
	 */
	TaskPlayer.execute = function (iExContext) {
		var playerContext = new PlayerContext();
		playerContext.deltaTime = iExContext.deltaTime;
		playerContext.elapsedTime = iExContext.elapsedTime;
		rootTaskGroup.execute(playerContext);
	};

	/**
	 * Start the task player.
	 *
	 * @private
	 */
	TaskPlayer.start = function () {
		rootTaskGroup.start();
	};

	/**
	 * Resume the task player.
	 *
	 * @private
	 */
	TaskPlayer.resume = function () {
		rootTaskGroup.resume();
	};

	/**
	 * Pause the task player.
	 *
	 * @private
	 */
	TaskPlayer.pause = function () {
		rootTaskGroup.pause();
	};

	/**
	 * Stop the task player.
	 *
	 * @private
	 */
	TaskPlayer.stop = function () {
		rootTaskGroup.stop();
	};

	// Expose in EP namespace.
	EP.TaskPlayer = TaskPlayer;

	return TaskPlayer;
});

define('EPTaskPlayer/EPTaskPlayer', ['DS/EPTaskPlayer/EPTaskPlayer'], function (TaskPlayer) {
	'use strict';

	return TaskPlayer;
});

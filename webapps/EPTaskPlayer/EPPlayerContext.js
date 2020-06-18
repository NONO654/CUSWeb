define('DS/EPTaskPlayer/EPPlayerContext', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * Describe an object containing information about the time and the context of the player execution.
	 *
	 * @constructor
	 * @alias EP.PlayerContext
	 * @noinstancector
	 * @private
	 * @example
	 * var MyTask = function () {
	 *	EP.Task.Call(this);
	 * }
	 * MyTask.prototype = new EP.Task();
	 * MyTask.prototype.constructor = MyTask;
	 * MyTask.prototype.onExecute = function (iPlayerContext) {
	 *	var deltaTime = iPlayerContext.getDeltaTime();
	 *	var elapsedTime = iPlayerContext.getElapsedTime();
	 * };
	 */
	var PlayerContext = function () {

		this.deltaTime = 0.0;
		this.elapsedTime = 0.0;
	};

	PlayerContext.prototype.constructor = PlayerContext;

	/**
	 * Return the delta time of this player context.</br>
	 * Value is in millisecond.
	 *
	 * @private
	 * @return {number}
	 * @example
	 * MyTask.prototype.onExecute = function (iPlayerContext) {
	 *	var deltaTime = iPlayerContext.getDeltaTime();
	 * };
	 */
	PlayerContext.prototype.getDeltaTime = function () {
		return this.deltaTime;
	};

	/**
	 * Return the elapsed time of this player context.</br>
	 * Value is in millisecond.
	 *
	 * @private
	 * @return {number}
	 * @example
	 * MyTask.prototype.onExecute = function (iPlayerContext) {
	 *	var elapsedTime = iPlayerContext.getElapsedTime();
	 * };
	 */
	PlayerContext.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	// Expose in EP namespace.
	EP.PlayerContext = PlayerContext;

	return PlayerContext;
});

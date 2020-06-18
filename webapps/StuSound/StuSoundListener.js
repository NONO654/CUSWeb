define('DS/StuSound/StuSoundListener', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EPTaskPlayer/EPTaskPlayer', 'MathematicsES/MathsDef'],
    function (STU, Behavior, Task, TaskPlayer, DSMath) {
	'use strict';

	/**
	 * SoundListener HANDLER TASK.
	 * @class 
	 * @private
	 */
	var SoundListenerTask = function(behHandler) {
		Task.call(this);
		this.behHandler = behHandler;
	};

	SoundListenerTask.prototype = new Task();
	SoundListenerTask.constructor = SoundListenerTask;

	/**
	 * Method called each frame by the task manager
	 *
	 * @method
	 * @private
	 * @param  iExeCtx Execution context
	 */
	SoundListenerTask.prototype.onExecute = function(iExeCtx) {
		if (this.behHandler === undefined || this.behHandler === null) {
			return this;
		}
		var behHandler = this.behHandler;

		behHandler.update(iExeCtx.getDeltaTime() / 1000);
	};


	/**
	 * Describe a SoundListener behavior
	 *
	 * @exports SoundListener
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends {STU.Behavior}
	 * @memberOf STU
     * @alias STU.SoundListener
	 */
	var SoundListener = function() {
		Behavior.call(this);
		this.name = 'SoundListener';

		this.associatedTask;

		this._isSpatialized = false;
		this._position;
		this._forward;
		this._up;

		this._soundListenerWrapper = null;


		this._volume = 1.0;
		Object.defineProperty(this, 'volume', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (!!this._soundListenerWrapper) {
					return this._soundListenerWrapper.getVolume();
				} else
					return this._volume;
			},
			set: function(iVolume) {
				this._volume = Math.min(Math.max(iVolume, 0), 1);

				if (!!this._soundListenerWrapper) {
					this._soundListenerWrapper.setVolume(this._volume);
				}
			}
		});
	};



	SoundListener.prototype = new Behavior();
	SoundListener.prototype.constructor = SoundListener;
	SoundListener.prototype.protoId = 'BEDFDD1F-CBD5-4748-93AB-82FD4E01DDBE';
	SoundListener.prototype.pureRuntimeAttributes = [
		'_isSpatialized', '_position', '_forward', '_up'
	].concat(Behavior.prototype.pureRuntimeAttributes);

	/**
	 * The wrapper is shared between all sound Listener instance
	 * @private
	 * @type {Object}
	 */
	SoundListener._wrapper = null;

	/**
	 * Set the listener as the current one
	 *
	 * @method
	 * @public
	 */
	SoundListener.prototype.setAsCurrent = function() {
		//Remove of previous tasks 
		var tasks = TaskPlayer.getTasks();
		for (var i = tasks.length - 1; i >= 0; i--) {
			var task = tasks[i];

			if (task instanceof SoundListenerTask) {
				TaskPlayer.removeTask(task);
			}
		}

		// update volume level 
		this.volume = this._volume;

		TaskPlayer.addTask(this.associatedTask);
	};

	/**
	 * True if this listener is the current one
	 *
	 * @method 
	 * @public
	 * @return {Boolean}
	 */
	SoundListener.prototype.isCurrentListener = function() {
		var tasks = TaskPlayer.getTasks();
		for (var i = tasks.length - 1; i >= 0; i--) {
			if (tasks[i] === this.associatedTask) {
				return true;
			}
		}

		return false;
	};

	/**
	 * Update method called each frames
	 *
	 * @method
	 * @private
	 */
	SoundListener.prototype.update = function() {
		var wrapper = this._soundListenerWrapper;

		if (true) {
			var parent = this.getActor();
			var transfo = parent.getTransform();

			this._position = transfo.vector.multiplyScalar(0.001); // cxp unit is mm sound engine is m
			this._forward = transfo.matrix.getFirstColumn();
			this._up = transfo.matrix.getThirdColumn();

			//Cameras are looking to -x
			if (parent instanceof STU.Camera) {
				this._forward.negate();
			}

			wrapper.setPosition(this._position);
			wrapper.setOrientation(this._forward, this._up);
		}
	};

	/**
	 * Process executed when STU.SoundListener is activating
	 *
	 * @method
	 * @private
	 */
	SoundListener.prototype.onActivate = function() {
		Behavior.prototype.onActivate.call(this);

		var parent = this.getParent();
		this._isSpatialized = parent instanceof STU.Actor3D;

		this.associatedTask = new SoundListenerTask(this);

		//By default the first SoundListener is activated
		if (SoundListener._wrapper === null || SoundListener._wrapper === undefined) {
			SoundListener._wrapper = this.buildWrapper(); // jshint ignore:line
			this._soundListenerWrapper = SoundListener._wrapper;
		} else {
			// other SoundListener 
			return;
		}
		this._soundListenerWrapper.setVolume(1.0);
		this._soundListenerWrapper.setPosition({
			x: 0,
			y: 0,
			z: 0
		});

		this._soundListenerWrapper.setOrientation({
			x: 1,
			y: 0,
			z: 0
		}, {
			x: 0,
			y: 0,
			z: 1
		});


		TaskPlayer.addTask(this.associatedTask);
	};

	/**
	 * Process executed when STU.SoundListener is deactivating
	 *
	 * @method
	 * @private
	 */
	SoundListener.prototype.onDeactivate = function() {
		TaskPlayer.removeTask(this.associatedTask);
		delete this.associatedTask;
		delete SoundListener._wrapper;

		Behavior.prototype.onDeactivate.call(this);
	};


	// Expose in STU namespace.
	STU.SoundListener = SoundListener;

	return SoundListener;
});

define('StuSound/StuSoundListener', ['DS/StuSound/StuSoundListener'], function (SoundListener) {
    'use strict';

    return SoundListener;
});

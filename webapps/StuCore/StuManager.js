
define('DS/StuCore/StuManager', ['DS/StuCore/StuContext'], function (STU) {
	'use strict';

	/**
	 * Describe an Interface with basic API for any Creative Experience manager.
	 * Every Creative Experience manager must extends this class.
	 *
	 * @exports Manager
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @memberof STU
	 * @alias STU.Manager
	 */
	var Manager = function () {
		
		/**
	     * Initialization state of this STU.Manager.
	     *
	     * @member
	     * @private
	     * @type {boolean}
		 * @see STU.Manager#isInitialized
	     */
		this.initialized = false;
	};
	
	/**
	 * Return the unique instance of the corresponding manager.
	 * STU.Manager instances are singleton. 
	 * It's a static method, you need to use it on the corresponding manager constructor function.
	 *
	 * @method
	 * @public
	 * @return {STU.Manager} instance object of the manager
	 */
	Manager.getInstance = function () {

	};
	
	Manager.prototype.constructor = Manager;

	/**
	 * Check if this STU.Manager is initialized.
	 *
	 * @method
	 * @private
	 * @return {boolean}
	 */
	Manager.prototype.isInitialized = function () {
		return this.initialized;
	};
	
	/**
	 * Initialize this STU.Manager.
	 *
	 * @method
	 * @private
	 * @see STU.Manager#dispose
	 */
	Manager.prototype.initialize = function () {
		if(!this.initialized) {
			this.onInitialize();
			this.initialized = true;
		}
	};
	
	/**
	 * Dispose this STU.Manager.
	 *
	 * @method
	 * @private
	 * @see STU.Manager#initialize
	 */
	Manager.prototype.dispose = function () {
		if(this.initialized) {
			this.onDispose();
			this.initialized = false;
		}
	};

	/**
	 * Process to execute when this STU.Manager is initializing.
	 *
	 * @method
	 * @private
	 * @see STU.Manager#onDispose
	 */
	Manager.prototype.onInitialize = function () {

	};
	
	/**
	 * Process to execute when this STU.Manager is disposing.
	 *
	 * @method
	 * @private
	 * @see STU.Manager#onInitialize
	 */
	Manager.prototype.onDispose = function () {

	};

	// Expose in STU namespace.
	STU.Manager = Manager;

	return Manager;
});

define('StuCore/StuManager', ['DS/StuCore/StuManager'], function (Manager) {
    'use strict';

    return Manager;
});

/**
 * Describe a namespace container for every existing class and tools in Creative Experience.
 * All public classes are declared in STU namespace.
 * All public enumeration are declared in STU namespace.
 * Use STU static class to access these objects.
 *
 * @namespace STU
 * @public
 */
var STU;

var stuContextRequires = ['DS/EPTaskPlayer/EPTaskPlayer', 'DS/EPTaskPlayer/EPTaskGroup'] ; 
if (typeof (window) === 'undefined') {
    stuContextRequires.push('binary!StudioModelRT');
}

/* global define */
define('DS/StuCore/StuContext',stuContextRequires, function(TaskPlayer, TaskGroup) {
	'use strict';

	STU = {};
	STU.REVISION = '00';
	STU.NAMESPACEGUID = '2571984B-F70A-4600-8D09-B3FEDB8851E4';

	// For Web
	var main3DView;

	STU.setMain3DView = function(iMain3DView) {
		main3DView = iMain3DView;
	};

	STU.getMain3DView = function() {
		return main3DView;
	};

	// Managers
	var managers = [];

	/**
	 * An enumeration of supported task groups.<br/>
     * They are executed in the same order as in the enumeration.<br/>
     * When adding a task in the TaskPlayer without specifying the task group, eProcess group will be used by default.
     * 
	 * TODO: find a service class to host that enum, otherwise documentation not working well
	 * 
     * @private
     * 
     * @example
     * // add a task in ePostProcess group
     * EP.TaskPlayer.addTask(myTask, STU.getTaskGroup(STU.ETaskGroups.ePostProcess));
     *
     * // add a task in default eProcess group
     * EP.TaskPlayer.addTask(myTask);
     * 
	 * @enum {number}
     * @memberOf STU
	 * 	 
	 */
	STU.ETaskGroups = {
		/** @private */
		ePreProcess: 0,
		/** @private */
		eProcess: 1,
		/** @private */
		ePostProcess: 2,
	};

	var taskGroups = [];

    /**
     * Returns the task group corresponding to the input task group enumeration.<br/>
     * @param  {STU.ETaskGroups} iETaskGroup Task group enumeration
     * @return {EP.TaskGroup}             Corresponding task group.
     * @private
     * @static
     */
	STU.getTaskGroup = function(iETaskGroup) {
		return taskGroups[iETaskGroup];
	};

	/**
	 * Register the manager from his constructor object.
	 * Instantiate the singleton manager.
	 * Implement getInstance method.
	 *
	 * @function registerManager
	 * @private
	 * @static
	 * @param {STU.Manager} iManagerCtor constructor function
	 * @memberof STU
	 */
	STU.registerManager = function(iManagerCtor) {
		// make sure we register managers only once
		if (managers.indexOf(iManagerCtor) === -1){
			managers.push(iManagerCtor);
			
			var instance = new iManagerCtor();
			iManagerCtor.getInstance = function() {
				return instance;
			};
		}
	};

	/**
	 * Init context.
	 *
	 * @function initContext
	 * @private
	 * @static
	 * @see STU.disposeContext
	 * @memberof STU
	 */
	STU.initContext = function() {
		// task groups creation 
		for (var taskGroupName in STU.ETaskGroups) { /*jshint -W089 */
			var taskgroup = new TaskGroup();
			taskGroups[STU.ETaskGroups[taskGroupName]] = taskgroup;
			TaskPlayer.addTaskGroup(taskgroup);
		}
		TaskPlayer.setDefaultTaskGroup(taskGroups[STU.ETaskGroups.eProcess]);

		initManagers();
	};

	/**
	 * Dispose context.
	 *
	 * @function disposeContext
	 * @private
	 * @static
	 * @see STU.initContext
	 * @memberof STU
	 */
	STU.disposeContext = function() {
		var exp = STU.Experience.getCurrent();
		if (exp !== undefined && exp !== null) {
			exp.deactivate();
			exp.dispose();
		}
		disposeManagers();

		// task groups destruction 
		for (var taskGroupId = 0; taskGroupId < taskGroups.length; taskGroupId++) { /*jshint -W089 */
			TaskPlayer.removeTaskGroup(taskGroups[taskGroupId]);
		}
        taskGroups = [];
	};

	/**
	 * Init all the registered managers.
	 *
	 * @function initManagers
	 * @private
	 * @static
	 * @see disposeManagers
	 */
	var initManagers = function() {
		for (var i = 0; i < managers.length; i++) {
			managers[i].getInstance().initialize();
		}
	};

	/**
	 * Dispose all the registered managers.
	 *
	 * @function disposeManagers
	 * @private
	 * @static
	 * @see initManagers
	 */
	var disposeManagers = function() {
		for (var i = managers.length - 1; i >= 0; i--) {
			managers[i].getInstance().dispose();
		}
	};

	/**
	 * True if experience kernel is activated
	 *
	 * @function
	 * @private
	 * @static
	 */
	STU.isEKIntegrationActive = function() {
        var IsActive = false;

        if (typeof (DevFlags) === 'undefined') {
            return false;
        }
        if (!DevFlags.EKIntegrationOFF()) {
	        IsActive = true;
        }
        return IsActive;
	};

    /**
    * True always (for test)
    *
    * @function
    * @private
    * @static
    */
	STU.InstantiateTemplate = function (nameProto, nameInstance) {
	    var IsActive = false;

	    if (typeof (FactoryPlay) === 'undefined') {
	        return false;
	    }
	    if (!FactoryPlay.InstantiateTemplate(nameProto, nameInstance)) {
	        IsActive = true;
	    }
	    return IsActive;
	};

/**
* True always (for test)
*
* @function
* @private
* @static
*/
	STU.DeleteActor = function (nameInstance) {
	    var IsActive = false;

	    if (typeof (FactoryPlay) === 'undefined') {
	        return false;
	    }

	    if (!FactoryPlay.DeleteActor(nameInstance)) {
	        IsActive = true;
	    }
	    return IsActive;
	};



	return STU;
});

define('StuCore/StuContext', ['DS/StuCore/StuContext'], function (STU) {
    'use strict';

    return STU;
});

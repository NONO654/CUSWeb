define('DS/StuModel/StuLogicalActor', ['DS/StuCore/StuContext', 'DS/StuModel/StuActor'], function (STU, Actor) {
	'use strict';
	
	/**
	 * Describe a STU.LogicalActor which represents an actor with usually a behavioral script attached with it.
	 *
     * @exports LogicalActor
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.Actor
	 * @memberof STU
	 * @alias STU.LogicalActor
	 */
	var LogicalActor = function () {
		Actor.call(this);
	};

	LogicalActor.prototype = new Actor();
	LogicalActor.prototype.constructor = LogicalActor;

	// Expose in STU namespace.
	STU.LogicalActor = LogicalActor;

	return LogicalActor;
});

define('StuModel/StuLogicalActor', ['DS/StuModel/StuLogicalActor'], function (LogicalActor) {
    'use strict';

    return LogicalActor;
});

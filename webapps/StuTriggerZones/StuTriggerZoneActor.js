define('DS/StuTriggerZones/StuTriggerZoneActor', ['DS/StuCore/StuContext', 'DS/StuRenderEngine/StuActor3D', 'DS/StuTriggerZones/StuTriggerZoneManager'], function (STU, Actor3D) {
	'use strict';

	/**
	* Describe a generic trigger zone.<br/>
	* If a {@link STU.Actor3D} enters/exits a {@link STU.TriggerZoneEnterEvent}/{@link STU.TriggerZoneExitEvent} is dispatched.<br/>  
	*
	* @exports TriggerZoneActor
	* @class
	* @constructor
	* @noinstancector 
	* @public
	* @extends STU.Actor3D
	* @memberof STU
	* @alias STU.TriggerZoneActor
	*/
	var TriggerZoneActor = function () {

		Actor3D.call(this);
		this.name = 'TriggerZoneActor';

		/**
		* defines the objects which trigger an event when entering the trigger zone
		* if null / undefined : all the objects in the experience trigger an event
		*
		* @member
		* @public
		* @type {STU.Actor3D}
		*/
		this.objectFilter = null;

		/**
		* defines the target of the events sent by the trigger zone when an object enters or exists the trigger zone.
		* if null / undefined : the actor hosting the trigger zone will receive the events
		*
		* @member
		* @public
		* @type {STU.Actor3D}
		*/
		this.eventTarget = null;

		//
		// A trigger zone is NOT clickable
		// This Object.defineProperty is intended to overwrite Actor3D.clickable
		//
		Object.defineProperty(this, 'clickable', {
			enumerable: true,
			configurable: true,
			get: function () {
				return false;
			},
			set: function () {}
		});

		//
		// A trigger zone has no color
		// This Object.defineProperty is intended to overwrite Actor3D.color
		//
		Object.defineProperty(this, 'color', {
			enumerable: true,
			configurable: true,
			get: function () {
				return new STU.Color(0, 0, 0);
			},
			set: function () {}
		});

		this.TriggerZoneEntry = function () {
			console.debug('TriggerZone TriggerZoneEntry ' + this.stuId);
		};
		this.TriggerZoneExit = function () {
			console.debug('TriggerZone TriggerZoneExit ' + this.stuId);
		};

	};

	TriggerZoneActor.prototype = new Actor3D();
	TriggerZoneActor.prototype.constructor = TriggerZoneActor;

	TriggerZoneActor.prototype.onActivate = function () {
		Actor3D.prototype.onActivate.call(this);

		var MyManager = STU.TriggerZoneManager.getInstance();
		this.myID = MyManager.registerTriggerZone(this);
	};

	TriggerZoneActor.prototype.onDeactivate = function () {
		Actor3D.prototype.onDeactivate.call(this);

		var MyManager = STU.TriggerZoneManager.getInstance();
		if(this.myID !== undefined && this.myID !== null)
			MyManager.unRegisterTriggerZone(this.myID);
	};

	// method used by trigger zone to get the visu object
	TriggerZoneActor.prototype.getVisuObject = function () {
		return this.CATI3DGeoVisu;
	};

	// Expose in STU namespace.
	STU.TriggerZoneActor = TriggerZoneActor;

	return TriggerZoneActor;
});

define('StuTriggerZones/StuTriggerZoneActor', ['DS/StuTriggerZones/StuTriggerZoneActor'], function (TriggerZoneActor) {
    'use strict';

    return TriggerZoneActor;
});

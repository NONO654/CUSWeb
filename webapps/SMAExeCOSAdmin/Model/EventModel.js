define('DS/SMAExeCOSAdmin/Model/EventModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';
	var EventModel = UWAModel.extend({
		defaults: {
			id: '',
			eventClass: '',
			date: '',
			level: '',
			logger: '',
			message: '',
			method: '',
			millis: '',
			sequence: 0,
			clusterId: '',
			thread: ''
		},
	    setup: function(){
	    }
	});
	return EventModel;
});

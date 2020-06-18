define('DS/SMAExeCOSAdmin/Model/DriveModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';
	var DriveModel = UWAModel.extend({
		defaults: {
			id: '',
			driveName: '',
			path: '',
			description: ''
		},
	    setup: function(){
	    }
	});
	return DriveModel;
});


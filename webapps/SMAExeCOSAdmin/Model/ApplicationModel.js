define('DS/SMAExeCOSAdmin/Model/ApplicationModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';
	var ApplicationModel = UWAModel.extend({
		defaults: {
			id: '',
			appName: '',
			version: '',
			path: ''
		},
	    setup: function(){
	    }
	});
	return ApplicationModel;
});


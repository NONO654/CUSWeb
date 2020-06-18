define('DS/SMAExeCOSAdmin/Model/StationModel',
	[
	 	'UWA/Class/Model'
	],
function(UWAModel) {
	'use strict';
	var StationModel = UWAModel.extend({
		defaults: {
			id: '',
			allowedUsers: '',
			group: '',
			os: '',
			drm: '',
			serverName: '',
			useCount:'0'
		},
	    setup: function(){
	    }
	});
	return StationModel;
});


define('DS/SMAExeCOSAdmin/Model/ServerStationModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';
	var ServerStationModel = UWAModel.extend({
		defaults: {
			id: '',
			type: '',
			proxyServerUrl: '',
			eedwsUri: '',
			eedUrl: '',
			fullCosUrl: '',
			publicKey: '',
			privatePorts: '',
			allowedUsers: '',
			group:'',
			os: '',
			drm: '',
			serverName: '',
			useCount:'0',
			serverDrms:[],
			deployType:'',
			serverPropId: ''
		},
	    setup: function(){
	    }
	});
	return ServerStationModel;
});


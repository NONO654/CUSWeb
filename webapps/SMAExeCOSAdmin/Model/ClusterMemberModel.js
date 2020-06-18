define('DS/SMAExeCOSAdmin/Model/ClusterMemberModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';
	var ClusterMemberModel = UWAModel.extend({
		defaults: {
			clusterMemberId: '',
			serverState: '',
			hostName: '',
			startdate: ''
		},
	    setup: function(){
	    }
	});
	return ClusterMemberModel;
});


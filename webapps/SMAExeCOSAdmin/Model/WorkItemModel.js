define('DS/SMAExeCOSAdmin/Model/WorkItemModel',
	[
	 	'UWA/Class/Model'
	],
function( UWAModel) {
	'use strict';

	var WorkItemModel = UWAModel.extend({
		defaults: {
			id: '',
			userName: '',
			adapterType: '',
			adapterPath: '',
			jobName: '',
			jobOID: '',
			simulationId: '',
			simulationName: '',
			duration: ''
		},
	    setup: function(){
	    }
	});
	return WorkItemModel;
});

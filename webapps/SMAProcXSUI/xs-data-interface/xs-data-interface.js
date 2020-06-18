/* global Polymer */
(function () {
	'use strict';
	var DATA = {}, DATA_ADAPTERS, DATA_ADAPTER_PATH;
	DATA_ADAPTER_PATH = '../../SMAProcXSUI/{data}/{data}.html';
	DATA_ADAPTERS = {
		Simulation: 'xs-wg-simulation-data',
		PipeLinePilot: 'xs-pipeline-pilot-data-adapter'
	};

	window.Polymer({
		is: 'xs-data-interface',

		//instance of data adapter should be created before calling getData on it
		getData: function(identifier, callback){
			return DATA[identifier.oid].getData(identifier, callback);
		},

		clearDataSource: function(uid) {
			delete DATA[uid];
		},

		addDataSource: function(type, uid, callback) {
			if (DATA[uid] === undefined) {
				Polymer.Base.importHref([this.resolveUrl(DATA_ADAPTER_PATH.replace(/\{data\}/g, DATA_ADAPTERS[type]))], function() {
					DATA[uid] = document.createElement(DATA_ADAPTERS[type]);
					DATA[uid].uid= uid;
					this.$.dataholder.appendChild(DATA[uid]);
					callback(DATA[uid]);
				}.bind(this));
			}
		},

		getDataSource: function(uid) {
			return DATA[uid];
		}
	});
}(this));

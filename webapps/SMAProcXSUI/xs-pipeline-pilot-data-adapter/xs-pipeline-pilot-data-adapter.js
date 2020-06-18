/* global DS */
(function () {
	'use strict';
	var PROTOCOL_PARAM_CAHCE =[];
	window.Polymer({
		is: 'xs-pipeline-pilot-data-adapter',

		properties: {
			isInitialized: {
				type: Boolean,
				notifu: true
			},
			// For Pipeline Polot id is its protocol name
			uid: {
				observe: '_protocolChanged'
			},

			bioviaserverurl: {
				//harcoded here, need to find a way to get correct URL
				value: 'https://apk2win7plp:9943'
			}
		},

		_protocolChanged: function(value) {
			this.isInitialized = false;
			this.getAllParamters(this.bioviaserverurl, value, true);
		},

		attached: function(){
			this.getAllParamters(this.bioviaserverurl, this.uid, true).then(this._processParameters.bind(this));
		},

		//Overridden
		getData: function(identifier, callback) {
			//method should be overriden with data for that identifier
			//data returned to callback function will have update function which will update that data to db
			this.onDataInitialized(function(){
				callback(PROTOCOL_PARAM_CAHCE[this.uid][identifier.path]);
			}, this);
		},


		// for the object id pased, it returns the content info, for document it returns file info
		getAllParamters: function (serverlurl, protocol, fromcache) {
			if (fromcache && PROTOCOL_PARAM_CAHCE[protocol] !== undefined) {
				return Promise.resolve(PROTOCOL_PARAM_CAHCE[protocol]);
			}

			return new Promise(function (resolve, reject) {
				var onComplete = function (httpRequest) {

						resolve(httpRequest.response);
					},

					onError = function (httpRequest) {
						reject(httpRequest);
					},

					options = {
						verb: 'GET',
						headers: {
							Accept: 'json',
							pragma: 'no-cache',
							Authorization: 'Basic ' + btoa('apk2:apk2') //Authentication should not be required as 3DPassport is used.
						},
						uri: serverlurl + '/xinfo/api/v1/ws/' + protocol + '?format=json&allowcache=false&all=false',
						onComplete: onComplete,
						onError: onError
					};

				this.$.mcsService.sendRequest(options);
			}.bind(this));
		},

		_processParameters:  function(response) {
			// Do some processing on params to give it in a format, so that it is available for
			var params = {};
			JSON.parse(response).parameters.forEach(function(param){
				var param1 = {};
				param1.title = param.name;
				if (param.cadinality === 'scalar') {
					param1.valuetype = 'single';
				}
				if (param.type === 'StringType') {
					param1.datatype = 'string';
				} else if (param.type === 'BoolType') {
					param1.datatype = 'boolean';
				}
				param1.choices = param['legal-values'];
				param1.value = param.value;
				params[param1.title] = param1;
			});
			PROTOCOL_PARAM_CAHCE[this.uid] = params;
			this.clearCallBackQueue();

		},


		//Overridden
		isDataInitialized: function() {
			return this.isInitialized;
		},

		behaviors: [DS.SMAProcXSUI.XSDataBase]
	});
}(this));

define('DS/dsbaseUIServices/GraphUIDebugServices', [
	'DS/WAFData/WAFData',
	'UWA/Utils',
	'DS/dstoolsUIServices/dsbaseServices',
	'DS/dsbaseUIServices/UpdateServices',
	'DS/dsbaseUIServices/OperationServices'
], function (
	WAFData,
	Utils,
	commonServices,
	UpdateServices,
	OperationServices
) {
	/**
	 * @private
	 * @summary operation graph accelerators for client-side APIs
	 * @module DS/dsbaseUIServices/GraphUIDebugServices
	 */

	'use strict';

	var DEFAULT_TIMEOUT = 7200000; // 2h

	// var WEB_SERVICE_URI = 'rdfQL?query=invoke ';
	// var WEB_SERVICE_URI = 'v0/invoke/';
	// function asArray(variable) {
	// 	var toReturn = variable;
	// 	if (!Array.isArray(toReturn)) {
  //           toReturn = [variable];
	// 	}
	// 	return toReturn;
	// }

	// // available in dsbaseServices

    // function escapeSpaces(url) {
	// 	return url.replace(/\s/g, '%20');
	// }

    // function bracketIfNeeded(uri) {
	// 	// If the URI is a long URI => bracket
	// 	// un autre beau specimen de hack
	// 	var shouldBracket = false;
	// 	if(typeof uri === 'undefined' || uri === null) {
	// 		return 'null';
	// 	}
	// 	if (uri.startsWith("http://") || uri.startsWith("uuid:"))
	// 		shouldBracket = true;
	// 	if (shouldBracket)
	// 		return "<" + uri + ">";
	// 	return uri;
	// }
	// function prepareForPost(uri) {
	// 	var toReturn = bracketIfNeeded(uri);
	// 	return encodeURIComponent(toReturn);
	// }

	var graphUIDebugServices = {
		/**
	  * @private
		* @summary Returns an instance of GraphUIDebugServices
		* @memberof module:DS/dsbaseUIServices/GraphUIDebugServices
		* @returns {DS/dsbaseUIServices/GraphUIDebugServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/GraphUIDebugServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serverURL) {
			return new GraphUIDebugServicesTools(serverURL);
		},
		
		// available in dsbaseServices

		getURLParams: commonServices.getURLParams
		// function() {
		// 	var qs = window.location.search.substring(1);
		// 	qs = qs.split('+').join(' ');
	  
		// 	var params = {},
		// 	  tokens,
		// 	  re = /[?&]?([^=]+)=([^&]*)/g;
	  
		// 	while (tokens = re.exec(qs)) {
		// 	  params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
		// 	}
	  
		// 	return params;
		// }
	};

	/**
	* @private
	* @summary GraphUIDebugServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/GraphUIDebugServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/GraphUIDebugServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function GraphUIDebugServicesTools(serviceId,context) {
		this.opServices = OperationServices.getHandle("ODTService@"+serviceId);
		this.updateServices = UpdateServices.getHandle("ODTService@"+serviceId);
	}


	// OPTIONS for monitoring / debug
	function getUpdateMonitoringOptions(sessionID) {
		return { monitoring: {
				sessionID: sessionID
			}
			// optimized : { }; // TODO !
		};
	}
	function getRunMonitoringOptions(sessionID) {
		return { monitoring: { "dataflow-monitoring": {
			"connector-id"  : "dataflow-monitoring-ws",
			"connector-args": [sessionID]
		}}
		// optimized : { }; // TODO !
	};
	}
	function getUpdateDebugOptions(sessionID, breakpoints) {
		var opts = getUpdateMonitoringOptions(sessionID);
		opts.monitoring.debug = 'pause';
		if (breakpoints !== undefined && breakpoints !== null)
			opts.monitoring.breakpoints = breakpoints;

		return opts;
	}
	function getRunDebugOptions(sessionID, breakpoints) {
		var opts = getRunMonitoringOptions(sessionID);
		var bkpts = [];
		if (breakpoints !== undefined && breakpoints !== null)
			bkpts = breakpoints;

		var debugOptions = opts.monitoring["dataflow-monitoring"]["connector-args"];
		debugOptions.push("pause");
		debugOptions.push(bkpts);
		
		return opts;
	}
	


	GraphUIDebugServicesTools.prototype =  {
		monitoredUpdate: function( resourceURI, sessionID, successCB, failureCB ) {
			var options = getUpdateMonitoringOptions(sessionID);
			
			return this.updateServices.update({
				resourcesURI: resourceURI,
				options     : options,
				timeout     : DEFAULT_TIMEOUT,
				cbObject    : {
					onComplete: successCB,
					onFailure : failureCB
				}
			});
		},
		monitoredRun: function( compositeVersionURI, inputs, sessionID, successCB, failureCB ) {
			var options = getRunMonitoringOptions(sessionID);
			
			return this.opServices.run({
				operationVersionURI: compositeVersionURI,
				inputs             : inputs,
				options            : options,
				timeout            : DEFAULT_TIMEOUT,
				cbObject : {
					onComplete: successCB,
					onFailure : failureCB
				}
			});
		},
		debugUpdate: function( resourceURI, sessionID, breakpoints, successCB, failureCB ) {
			var options = getUpdateDebugOptions(sessionID,breakpoints);
			
			return this.updateServices.update({
				resourcesURI: resourceURI,
				options     : options,
				timeout     : DEFAULT_TIMEOUT,
				cbObject : {
					onComplete: successCB,
					onFailure : failureCB
				}
			});
		},
		debugRun: function( compositeVersionURI, inputs, sessionID, breakpoints, successCB, failureCB ) {
			var options = getRunDebugOptions(sessionID, breakpoints);
			
			return this.opServices.run({
				operationVersionURI: compositeVersionURI,
				inputs             : inputs,
				options            : options,
				timeout            : DEFAULT_TIMEOUT,
				cbObject : {
					onComplete: successCB,
					onFailure : failureCB
				}
			});
		}
	};
	GraphUIDebugServicesTools.prototype.constructor = GraphUIDebugServicesTools;
	return graphUIDebugServices;
});

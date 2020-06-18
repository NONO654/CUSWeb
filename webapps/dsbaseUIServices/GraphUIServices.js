define('DS/dsbaseUIServices/GraphUIServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	'DS/WAFData/WAFData',
	'UWA/Utils'], function (commonServices,WAFData,Utils) {
		/**
		* @summary operation graph accelerators for client-side APIs
		* @module DS/dsbaseUIServices/GraphUIServices
		*/

	'use strict';
	// var WEB_SERVICE_URI = 'service/rdfQL?query=invoke ';
	// var WEB_SERVICE_URI = 'v0/invoke/';
	// function asArray(variable) {
	// 	var toReturn = variable
	// 	if (!Array.isArray(toReturn)) {
  //           toReturn = [variable];
	// 	}
	// 	return toReturn;
	// }

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

	var graphUIServices = {
		/**
		* @summary Returns an instance of GraphUIServices
		* @memberof module:DS/dsbaseUIServices/GraphUIServices
		* @returns {DS/dsbaseUIServices/GraphUIServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/GraphUIServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId,context) {
			return new GraphUIServicesTools("ODTService@"+serviceId,context);
		}
	};
	
	/**
	* @summary GraphUIServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/GraphUIServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/GraphUIServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function GraphUIServicesTools(serviceId,context) {
		this.serviceId          = serviceId;
		this.contextInfos       = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
	}

	//INVOKE dsbase:getUpdataeGraphAsJSON dscust:myComposer;

	GraphUIServicesTools.prototype =  {
		/**
		 * Gets all the known Operations libraries
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  parameters - an object containing the following fields:
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getOperationLibraries: function(parameters) {
			var params = (parameters === undefined || parameters === null) ? {} : parameters;
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getOperationLibraries"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		},
		/**
		 * Gets the graph of a resource (composite operation / updatable)
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *            - resourceURI : the resource holding the graph (mandatory)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getGraphAsJSON: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [params.resourceURI];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getGraphAsJSON"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		},
		/**
		 * Gets the update graph of an updatable resource
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *            - resourceURI : the resource holding the graph (mandatory)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getUpdateGraphAsJSON: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [params.resourceURI];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getUpdateGraphAsJSON"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		},
		/**
		 * Gets the graph of a composite operation
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *            - compositeVersionURI : the resource holding the graph (mandatory)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getCompositeGraphAsJSON: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [params.compositeVersionURI];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getCompositeGraphAsJSON"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		},
		/**
		 * Gets the update graph of an updatable resource (Generative Graph serialization)
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *            - resourceURI : the resource holding the graph (mandatory)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getUpdateGraphAsJSONForGG: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [params.resourceURI];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getUpdateGraphAsJSONForGG"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		},
		/**
		 * Gets the graph of a composite operation (Generative Graph serialization)
		 * @memberof DS/dsbaseUIServices/GraphUIServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *            - compositeVersionURI : the resource holding the graph (mandatory)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		 */
		getCompositeGraphAsJSONForGG: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [params.compositeVersionURI];
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getCompositeGraphAsJSONForGG"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) {
						data.value = JSON.parse(data.value);
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data.value);
					},
					onFailure: function(data, status, error){
						if(params.cbObject !== undefined) {
							params.cbObject.onFailure(data, status, error);
						}
						reject(error);
					},
					timeout: params.timeout
				});
			});
			return promise;
		} 
		//,
		// ------------------------------------------------------------------------------
		// for debug purposes: COMMENTED FOR NOW
		//
		// /**
		//  * Dumps the update graph of a resource
		//  *
		//  * @param  {Object}  params - an object containing the following fields:
		//  *            - resourceURI : the resource holding the graph (mandatory)
		//  *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		//  * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		//  */
		// dumpUpdateGraphAsJSON: function(params) {
		// 	if(params.timeout === undefined) {
		// 		params.timeout = 300000;
		// 	}
		// 	var payload = [params.resourceURI];
		// 	var dataArray = JSON.stringify(payload);
		// 	var WAFReq = this.WAFRequestFunction;
		// 	var contextInfos = this.contextInfos;
		// 	var promise = new Promise(function (resolve, reject) {
		// 		WAFReq(commonServices.buildURL(contextInfos,"dsbase:dumpUpdateGraphAsJSON"),{
		// 			method: 'POST',
		// 			type: 'json',
		// 			headers: { 'Content-Type':'application/json'},
		// 			data: dataArray,
		// 			onComplete: function(data, status) {
		// 				data.value = JSON.parse(data.value);
		// 				if(params.cbObject !== undefined) {
		// 					params.cbObject.onComplete(data,status); 
		// 				}
		// 				resolve(data.value);
		// 			},
		// 			onFailure: function(data, status, error){
		// 				if(params.cbObject !== undefined) {
		// 					params.cbObject.onFailure(data, status, error);
		// 				}
		// 				reject(error);
		// 			},
		// 			timeout: params.timeout
		// 		});
		// 	});
		// 	return promise;
		// },
		// /**
		//  * Dumps the graph of a composite operation
		//  *
		//  * @param  {Object}  params - an object containing the following fields:
		//  *            - compositeVersionURI : the resource holding the graph (mandatory)
		//  *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		//  * @return {Array} an object containing the list of Operations libraries - through the onComplete callback!
		//  */
		// dumpCompositeGraphAsJSON: function(params) {
		// 	if(params.timeout === undefined) {
		// 		params.timeout = 300000;
		// 	}
		// 	var payload = [params.compositeVersionURI];
		// 	var dataArray = JSON.stringify(payload);
		// 	var WAFReq = this.WAFRequestFunction;
		// 	var contextInfos = this.contextInfos;
		// 	var promise = new Promise(function (resolve, reject) {
		// 		WAFReq(commonServices.buildURL(contextInfos,"dsbase:dumpCompositeGraphAsJSON"),{
		// 			method: 'POST',
		// 			type: 'json',
		// 			headers: { 'Content-Type':'application/json'},
		// 			data: dataArray,
		// 			onComplete: function(data, status) {
		// 				data.value = JSON.parse(data.value);
		// 				if(params.cbObject !== undefined) {
		// 					params.cbObject.onComplete(data,status); 
		// 				}
		// 				resolve(data.value);
		// 			},
		// 			onFailure: function(data, status, error){
		// 				if(params.cbObject !== undefined) {
		// 					params.cbObject.onFailure(data, status, error);
		// 				}
		// 				reject(error);
		// 			},
		// 			timeout: params.timeout
		// 		});
		// 	});
		// 	return promise;
		// }
	};
	GraphUIServicesTools.prototype.constructor = GraphUIServicesTools;
	return graphUIServices;
});

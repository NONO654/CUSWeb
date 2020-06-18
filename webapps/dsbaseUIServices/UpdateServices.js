define('DS/dsbaseUIServices/UpdateServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	'DS/WAFData/WAFData',
	'UWA/Utils'], function (commonServices,WAFData,Utils) {
		/**
		* @summary Reactive corpus accelerators for client-side APIs
		* @module DS/dsbaseUIServices/UpdateServices
		*/

	'use strict';
	var WEB_SERVICE_URI = 'v0/invoke/';
	function asArray(variable) {
		var toReturn = variable
		if (!Array.isArray(toReturn)) {
            toReturn = [variable];
		}
		return toReturn;
	}
	var updateServices = {
		/**
		* @summary Returns an instance of UpdateServices
		* @memberof module:DS/dsbaseUIServices/UpdateServices
		* @returns {DS/dsbaseUIServices/UpdateServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/UpdateServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId,context) {
			return new UpdateServicesTools(serviceId,context);
		}
	};
	
	/**
	* @summary UpdateServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/UpdateServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/UpdateServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function UpdateServicesTools(serviceId,context) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
	}

	UpdateServicesTools.prototype =  {
		/**
		 * Updates the given resource(s) and returns the impacted characteristics
		 * @memberof DS/dsbaseUIServices/UpdateServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- resourcesURI : the resource(s) to update (mandatory)
		 * 						- options : options for the udpate (optional)
		 *            - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the impacted characteristics of each resources - through the onComplete callback!
		 */
		update: function(params) {
			if(params.timeout === undefined) {
				params.timeout = 300000;
			}
			var payload = [JSON.stringify(asArray(params.resourcesURI))];
			if (params.options !== undefined)
				payload.push(JSON.stringify(params.options));
			
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:update"),{
					method: 'POST',
					type: 'json',
					headers: { 'Content-Type':'application/json'},
					data: dataArray,
					onComplete: function(data, status) { 
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
		 * Computes the update status of the given resources
		 * @memberof DS/dsbaseUIServices/UpdateServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- resourcesURI : the resource(s) to check (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the update status of each resources - through the onComplete callback!
		 */
		isUpToDate: function(params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.resourcesURI))]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:isUpToDate"),{
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
					timeout:300000
				});
			});
			return promise;
		},
		/**
		 * returns a list of the impacting characteristic for the given characteristic
		 * @memberof DS/dsbaseUIServices/UpdateServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- resourcesURI : the resource holding the characteristic (mandatory)
		 * 						- charID : the characteristic (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing the update status of each resources - through the onComplete callback!
		 */
		getComputeInfos: function(params) {
			if (params.resourceURI === undefined || params.resourceURI === null ||
				params.charID === undefined || params.charID === null
			) {
				var errMsg = 'Missing parameter. Parameters "resourceURI" & "charID" are mandatory';
				if(params.cbObject !== undefined) {
					params.cbObject.onFailure(null, 500, errMsg);
				}
				return Promise.reject(errMsg);
			}
			
			var dataArray = JSON.stringify([params.resourceURI, params.charID]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:getComputeInfos"),{
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
					timeout:300000
				});
				return false;
			});
			return promise;
		}
	};
	UpdateServicesTools.prototype.constructor = UpdateServicesTools;
	return updateServices;
});

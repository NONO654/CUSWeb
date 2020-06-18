define('DS/dsbaseUIServices/BaseServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	'DS/WAFData/WAFData',
	'UWA/Utils'], function (commonServices,WAFData,Utils) {
		/**
		* @summary dsbase accelerators for client-side APIs
		* @module DS/dsbaseUIServices/BaseServices
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
	var baseServices = {
		/**
		* @summary Returns an instance of BaseServices
		* @memberof module:DS/dsbaseUIServices/BaseServices
		* @returns {DS/dsbaseUIServices/BaseServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/BaseServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId/* ,context */) {
			return new BaseServicesTools(serviceId/* ,context */);
		}
	};

	/**
	* @summary BaseServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/BaseServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/BaseServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function BaseServicesTools(serviceId/* ,context */) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(/* context */);
	}

	BaseServicesTools.prototype =  {
		/**
		 * Gets meta information about a given resource
		 * @memberof DS/dsbaseUIServices/BaseServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- resourcesURI (String or Array of Strings) : the resource(s) to analyze (mandatory)
		 * 						- toFetch (Array of Strings): information to retrieve (mandatory) Only one possible value for now: Type
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an object containing requested information - through the onComplete callback!
		 */
		getMetaInfos: function(params) {
			if(params.timeout === undefined)
				params.timeout = 30000;
				
			var payload = [JSON.stringify(asArray(params.resourcesURI)), JSON.stringify(asArray(params.toFetch))];
			
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsbase:getMetaInfos"),{
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
						data.value = JSON.parse(data.value);
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
	};
	BaseServicesTools.prototype.constructor = BaseServicesTools;
	return baseServices;
});

define('DS/dstoolsUIServices/dsaccessServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	'DS/WAFData/WAFData',
	'UWA/Utils'], function (commonServices,WAFData,Utils) {

	'use strict';
	var WEB_SERVICE_URI = 'v0/invoke/';
	
	var accessServices = {
		getHandle: function(serviceId,context) {
			return new AccessServices(serviceId,context);
		}
	}
	function AccessServices(serviceId,context) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
	}

	AccessServices.prototype =  {
		/**
		 * Checks the access for the current user on a given dsaccess:Operation
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- operationURI (String) : the dsaccess:Operation URI to check
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Promise} true if the operation is granted, false otherwise
		 */
		isOperationGranted: function(params) {
				
			var payload = [params.operationURI];
			
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,"dsaccess:responsibility.isOperationGrantedToUser"),{
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
        },
        /**
		 * Checks the capacity to run a standalone dsbase:Operation or a dsbase:Operation as a method on a specific resource
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- operationURI (String) : the dsbase:Operation URI to check
         *                      - resourceURI (String) : for method only, the resource on which the method is applied
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Promise} true if the operation is granted, false otherwise
		 */
		isRunGranted: function(params) {
            var URL = "dsaccess:responsibility.runStandAloneOperationAuthorized";
			var payload = [params.operationURI];
			if(params.resourceURI !== undefined) {
                payload = [params.resourceURI,params.operationURI];
                URL = "dsaccess:responsibility.runMethodOperationAuthorized";
            }
			var dataArray = JSON.stringify(payload);
			var WAFReq = this.WAFRequestFunction;
            var contextInfos = this.contextInfos;
            
			var promise = new Promise(function (resolve, reject) {
				WAFReq(commonServices.buildURL(contextInfos,URL),{
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
	AccessServices.prototype.constructor = AccessServices;
	return accessServices;
});

define('DS/dsbaseUIServices/CharacteristicServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	'UWA/Utils'], function (commonServices,Utils) {
		/**
		* @summary characteristics accelerators for client-side APIs
		* @module DS/dsbaseUIServices/CharacteristicServices
		*/

	'use strict';
	function asArray(variable) {
		var toReturn = variable
		if (!Array.isArray(toReturn)) {
            toReturn = [variable];
		}
		return toReturn;
	}
	var charServices = {
		/**
		* @summary Returns an instance of CharacteristicServices
		* @memberof module:DS/dsbaseUIServices/CharacteristicServices
		* @returns {DS/dsbaseUIServices/CharacteristicServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/CharacteristicServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId,context) {
			return new CharacteristicServicesTools(serviceId,context);
		}
	};

	/**
	* @summary CharacteristicServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/CharacteristicServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/CharacteristicServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function CharacteristicServicesTools(serviceId,context) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
	}

	CharacteristicServicesTools.prototype =  {
		/**
		 * Gets the value of one (or several) characteristic on a resource (or several)
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURIs : the resource(s) holding the characteristic(s) (mandatory)
		 * 						- charNames : the characteristic(s) to retrieve can be  (mandatory)
		 *                      - format : the format of the value to retrieve: default is "Display", possible values are "Primtive" (returns a value in JS language is appliable), "Raw" (returns a RDF Literal value as a string)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (optional)
		 *                      - withNLS : for translated values, returns also the translated value
		 * @return {Promise} resolve/onComplete will be called with the retrieved values
		 */
		getValue: function(params) {
			var options = {
				format:"Display"
			};
			if(params.format !== undefined) {
				options.format =  params.format;
			}
			
			if(params.withNLS === true) {
				options.nlsTranslation = true;
			}

			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs)),JSON.stringify(asArray(params.charNames)),JSON.stringify(options)]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.getValue"),{
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
		 * Sets the value of one (or several) characteristic on a resource (or several)
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURIs : the resource(s) holding the characteristic(s) (mandatory)
		 * 						- charNames : the characteristic(s) to retrieve can be  (mandatory)
		 * 						- charValues : the value(s) to set  (mandatory)
		 *                      - hasUnit : indicates if the value is given as a string with unit, in which case it will be parsed (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (optional)
		 * @return {Promise} resolve/onComplete will be called with the retrieved values
		 */
		setValue: function(params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs)),JSON.stringify(asArray(params.charNames)),JSON.stringify(asArray(params.charValues)),JSON.stringify(params.hasUnit)]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.setValue"),{
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
		 * Lists all characteristics for a resource (or several)
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURIs : the resource(s) to introspect (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (optional)
		 * @return {Promise} resolve/onComplete will be called with the retrieved values
		 */
		list: function(params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs))]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.list"), {
					method: 'POST',
					headers: { 'Content-Type':'application/json'},
					type: 'json',
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
		 * Returns the informations indicated for a given characteristic
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURIs : the resource(s) to introspect (mandatory)
		 * 						- charNames : the characteristic(s) to retrieve  (mandatory)
		 * 						- toFetch : a list of the infos to retrieved from the list ('AuthorizedValues','AuthorizedValuesNls','MinMax','Value','ReadOnly','User','Type','Comment') (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * @return {Array} an array containing the association between the characteristics and their infos - through the onComplete callback!
		 */
		getInfos: function(params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs)),JSON.stringify(asArray(params.charNames)),JSON.stringify(asArray(params.toFetch))]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.getInfos"), {
					method: 'POST',
					headers: { 'Content-Type':'application/json'},
					type: 'json',
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
		 * Deletes a characteristic on a resource
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURIs : the resource(s) to handle (mandatory)
		 * 						- charNames : the characteristic(s) to delete (mandatory)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 */
		delete: function( params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs)),JSON.stringify(asArray(params.charNames))]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.delete"), {
					method: 'POST',
					headers: { 'Content-Type':'application/json'},
					type: 'json',
					data: dataArray,
					onComplete: function(data, status) { 
						if(params.cbObject !== undefined) {
							params.cbObject.onComplete(data,status); 
						}
						resolve(data);
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
		 * Checks the validity of a characteristic value for a resource
		 * @memberof DS/dsbaseUIServices/CharacteristicServicesTools#
		 *
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- rscURI : the resource(s) to check on (mandatory)
		 * 						- charNames : the characteristic(s) to test for (mandatory)
		 * 						- charValues : the value(s) to test for
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 */
		isValueValid: function(params) {
			// FIXME: no unit handling here...
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.rscURIs)),JSON.stringify(asArray(params.charNames)),JSON.stringify(asArray(params.charValues))]);
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:characteristic.isValueValid"),{
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
		}

	};
	CharacteristicServicesTools.prototype.constructor = CharacteristicServicesTools;
	return charServices;
});

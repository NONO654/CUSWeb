/* eslint strict: "off" */

define('DS/dsbaseUIServices/TemplateServices', [
	"DS/dstoolsUIServices/dsbaseServices",
	"DS/dsbaseUIServices/OperationServices",
	'UWA/Utils'], function (commonServices,operationToolbox,Utils) {
		/**
		* @summary Template corpus accelerators for client-side APIs
		* @module DS/dsbaseUIServices/TemplateServices
		*/
		

	'use strict';
	function asArray(variable) {
		var toReturn = variable
		if (!Array.isArray(toReturn)) {
            toReturn = [variable];
		}
		return toReturn;
	}
	var templateServices = {
		/**
		* @summary Returns an instance of TemplateServices
		* @memberof module:DS/dsbaseUIServices/TemplateServices
		* @returns {DS/dsbaseUIServices/TemplateServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/TemplateServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId,context) {
			return new TemplateServicesTools(serviceId,context);
		}
	};
	
	/**
	* @summary TemplateServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/TemplateServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/TemplateServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function TemplateServicesTools(serviceId,context) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.operationServices = operationToolbox.getHandle(serviceId,context);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
		
	}
	TemplateServicesTools.prototype =  {
		/**
		 * Remotely executes an Operation Version on the provided inputs and returns the execution result
		 * @memberof DS/dsbaseUIServices/TemplateServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- templateURI : the template to instantiate (mandatory)
		 * 						- inputs : the inputs values under the form {"inputName":"value", ...} (mandatory)
		 *                      - instanceURI : URI of the created instance (optional, will use a UUID if not provided)
		 * 						- asNextVersionOf : URI of the previous DSLC version if any (optional)
		 *                      - cbObject : and object containing the onComplete and onFailure callbacks (mandatory)
		 * 						- parentURI : currently unused (optional)
		 * @return {String} a URI for the created instance - through the onComplete callback!
		 */
		instantiate: function(params/*templateURI, inputs, instanceURI, parentURI, asNextVersionOf,cbObject*/) {
			return this.operationServices.run({operationVersionURI:'dsop:new_V1', inputs:{
				template:{'@id':params.templateURI},
				inputs:JSON.stringify(params.inputs),
				instanceURI:params.instanceURI,
				asNextVersionOf:params.asNextVersionOf,
				parentURI:params.parentURI // FOR NOW
			}, cbObject:params.cbObject, timeout:100000});
		},
		/** 
		 * Lists the Templates available to create a resource individual of a given set of classes
		 * @memberof DS/dsbaseUIServices/TemplateServicesTools#
		 *
		 * @param {Object} params - an object containing the following fields:
		 * 			- classURIs   : the class(es) for which you want to create individuals - can be an array
		 *      - optionSetURI: The URI of the option set to consider when searching for instantiable templates 
		 * @return {Array} a map giving a list of templates that can create the individuals of each class
		 */
		listTemplatesForClasses: function(params) {
			var dataArray = JSON.stringify([JSON.stringify(asArray(params.classURIs))]);
			if(params.optionSetURI !== undefined && params.optionSetURI !== null) {
				dataArray = JSON.stringify([JSON.stringify(asArray(params.classURIs)),params.optionSetURI]);
			}
			var WAFReq = this.WAFRequestFunction;
			var contextInfos = this.contextInfos;
			var promise = new Promise(function (resolve, reject) {
				WAFReq (commonServices.buildURL(contextInfos,"dsbase:listTemplatesForClass"),{
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
	TemplateServicesTools.prototype.constructor = TemplateServicesTools;
	return templateServices;
});

define('DS/dsbaseUIServices/BusinessRuleServices', [
		"DS/dsbaseUIServices/OperationServices",
	"DS/dstoolsUIServices/dsbaseServices",
	'UWA/Utils'], function (operationToolbox, commonServices, Utils) {
		/**
		* @summary customization accelerators for client-side APIs
		* @module DS/dsbaseUIServices/BusinessRuleServices
		*/

	'use strict';
	function asArray(variable) {
		var toReturn = variable
		if (!Array.isArray(toReturn)) {
            toReturn = [variable];
		}
		return toReturn;
	}
	var businessRuleServices = {
		/**
		* @summary Returns an instance of BusinessRuleServices
		* @memberof module:DS/dsbaseUIServices/BusinessRuleServices
		* @returns {DS/dsbaseUIServices/BusinessRuleServicesTools}
		*
		* @param {String} serviceId - the serviceId for MyApps
		*
		* @example
		*    define('DS/MyMwebModule/MyAMDFile',
		*           ['DS/dsbaseUIServices/BusinessRuleServices'], function (services) () {
		*         ...
		*         var myInstance = services.getHandle('myServiceId');
		*         ...
		*    }
		*/
		getHandle: function(serviceId,context) {
			return new BusinessRuleServicesTools(serviceId,context);
		}
	};

	/**
	* @summary BusinessRuleServices constructor
	* @desc
	* <p> An instance  is returned by the  
	* {@link module:DS/dsbaseUIServices/BusinessRuleServices#getHandle}   method. </p>
	* @class DS/dsbaseUIServices/BusinessRuleServicesTools
	* @global
	*
	* @param {String} serviceId - the serviceId for MyApps
	*/
	function BusinessRuleServicesTools(serviceId, context) {
		this.serviceId = serviceId;
		this.contextInfos = commonServices.getInfosFromServiceId(serviceId);
		this.WAFRequestFunction = commonServices.getRequestFunction(context);
		this.opServices = operationToolbox.getHandle(serviceId, context);
	}

	BusinessRuleServicesTools.prototype = {
		/**
		 * Executes a business rule
		 * @memberof DS/dsbaseUIServices/BusinessRuleServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 * 						- BusinessRuleURI : the URI of the DS business rule to invoke
		 * 						- ThisObjectURI : the URI of the resource on which the business rule is executed
		 * 						- InputParameters : a JSON object to pass input parameters
		 * @return {Promise} resolve/onComplete will be called with the retrieved values
		 */
	    execute: function (params) {

	       var parametersOfOperation = {
			    "BusinessRule":params.BusinessRuleURI,
			    "ThisObject":params.ThisObjectURI,
			    "InputParameters":params.InputParameters
			};
            
	       return this.opServices.run({ operationVersionURI: 'dsbusinessrule:executeBusinessRule_V1', inputs: parametersOfOperation, cbObject: params.cbObject });
		},

		/**
		 * Retrieves an option set
		 * @memberof DS/dsbaseUIServices/BusinessRuleServicesTools#
		 *
		 * @param  {Object}  params - an object containing the following fields:
		 *          			- OptionSetURI : the URI of the DS option set to retrieve
		 * @return {Promise} resolve/onComplete will be called with the retrieved values
		 */
		retrieveOptionSet: function (params) {

		     var parametersOfOperation = {
		         "OptionSet":params.OptionSetURI
              };
            
		     return this.opServices.run({ operationVersionURI: 'dsbusinessrule:retrieveOptionSet_V1', inputs: parametersOfOperation, cbObject: params.cbObject });
		}
	};
	BusinessRuleServicesTools.prototype.constructor = BusinessRuleServicesTools;
	return businessRuleServices;
});

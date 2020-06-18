/**
 * @exports DS/CATCXPModel/interfaces/CATICXPVariablesInit
*/
define('DS/CATCXPModel/interfaces/CATICXPVariablesInit',
// dependencies
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface) {
	'use strict';

	/**
    * @category Interface
	* @name DS/CATCXPModel/interfaces/CATICXPVariablesInit
    * @interface
	* @description
    * Interface to provide specific variables initialisation
	*/

	var CATICXPVariablesInit = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPVariablesInit.prototype **/
    {

    	interfaceName: 'CATICXPvariablesInit',

    	/**
        * required methods
        * @lends DS/CATCXPModel/interfaces/CATICXPVariablesInit.prototype
        */
    	required: {

    		Init: function () {
    		}
    	},

    	optional: {
    	},

    	init:function(){
    	    this._specNLXML = {};
    	},

    	AddNLXMLNodeBySpec: function (iSpecName, iNode) {
    	    this._specNLXML[iSpecName] = iNode;
    	},

        /**
		* Get Natural language from an actor type
		* @public
		* @param {string} SpecName - object type
		* @return {XML} xml node of Natural language
		*/
    	GetNLXMLNodeBySpec: function (iSpecName) {
    	    return this._specNLXML[iSpecName];
    	},

        //**
        /* Clear reference on loaded Natural Language nodes. The nodes are loaded in the LoadDependencies()
        /* @public
        /*/
    	ClearNLXML: function () {
    	    this._specNLXML = {};
    	}
    });

	return CATICXPVariablesInit;
});

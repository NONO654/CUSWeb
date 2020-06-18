/**
 * @exports DS/CAT3DExpModel/CAT3DXVariable
*/
define('DS/CAT3DExpModel/CAT3DXVariable',
[
	'UWA/Core'
],
function (
	UWA
	) {
    'use strict';

    /**
	* @name DS/CAT3DExpModel/CAT3DXVariable
	* @description 
	* Variable Class.
	* @constructor
	* @augments UWA/Class/Events
	*/
    var CAT3DXVariable = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXVariable.prototype **/
	{
	    _holder: null,
	    _name: 'NONAME',
	    _type: null,
	    _restrictiveTypes: undefined,
	    _maxNumberOfValues: 0,   // array or value storage 
	    _valuationMode: undefined,    
	    _persistentValue: undefined,
	    _volatileValue: undefined,
	    _id: undefined,


	    /**
		* Variable constructor
		* @public
		* @param {Object} iHolder - holder on which set the variable
		* @param {string} iName - variable name
		* @param {string} iType - Type of variable
		* @param {number} iMaxNumberOfValues - 0 for array
		* @param {string} iMode - mode
		* @param {boolean} iRestrictiveTypes - restrictive type
		*/
	    init: function (iHolder, iName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes) {
	        this._holder = iHolder.QueryInterface('CATI3DExperienceObject');
	        this._name = iName;
	        this._type = iType;
	        this._maxNumberOfValues = iMaxNumberOfValues;
	        this._valuationMode = iMode;

	        if (iMaxNumberOfValues !== 1) {
	            this._persistentValue = [];
	            this._volatileValue = [];
	        }
	        this._restrictiveTypes = iRestrictiveTypes;
	    },
	});

    return CAT3DXVariable;
});



/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DExperienceObject
*/
define('DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DExperienceObject
	* @interface
	* @description 
	* Interface to get/set the component variables. 
	* <p>They are automatically created when the model dictionary is loaded. A default value could be set during component initialization in the impl code.</p>
	* <p> variable <b>Types</b> are :</p>
		<ol start="0">
		<li>Integer</li>
		<li>Double</li>
		<li>String</li>
		<li>Object</li>
		<li>Boolean</li>
		<li>All</li>
		</ol>
	* <p> valuation mode is the way a variable is stored in the component. <b>Mode</b> are :</p>
		<ol start="0">
		<li>AggregatingValue : Value are aggregated by variable, deleting the variable also delete the values</li>
		<li>ReferencingValue : Only available for variable Object. Values are pointed by the variable. Link can be a path(not available yet) or direct link</li>
		<li>PointingVariable : Point a variable of the same type, pointed variable can also point a variable(Loop is forbidden). Values are hold by the last variable</li>
		<li>Undef : valuationMode is not defined</li>
		</ol>
	* @category Interface
	*/
	var CATI3DExperienceObject = CATWebInterface.singleton(
	/** @lends DS/CAT3DExpModel/interfaces/CATI3DExperienceObject.prototype **/
	{
		interfaceName: 'CATI3DExperienceObject',

		/**
		* required methods 
		* @lends DS/CAT3DExpModel/interfaces/CATI3DExperienceObject.prototype
		*/
		required: {

			/**
			* List all the component variables including local variables defined on the component level in the model dictionary
			* and inherited variables from prototypal chain.
			* @public
			* @param {Object[]} i3DExpVariables - an array to be filled
			* @param {int} iVarType - variable Type, see list above.
			*/
		    ListVariables: function (i3DExpVariables, iVarType) {
		        console.log("interface using these variables : " + i3DExpVariables + iVarType);
			},

			/**
			 * Returns a boolean indicating if the current experience object has a variable with name iVarName on its 
			 * prototype instance chain.
			 * @param {string} iVarName - Input name of the variable
			 * @return {Boolean} true or false
			 */
		    HasVariable: function (iVarName) {
		        console.log("interface using these variables : " + iVarName);
		        return false;
			},

			/**
			* Add a variable on the component.
			* @public
			* @param {String} iVariableName - Variable Name
			* @param {int} iType - variable Type, see list above.
			* @param {int} iMaxNumberOfValues - maximum number of values, 0 if array
					<ol start="0">
					<li>variable can hold an unlimited number of values</li>
					<li>variable can hold 1 value at most(no value/1 value)</li>
					<li> variable can hold 2 values at most(no value / 1 value / 2 values)</li>
					</ol>
			* @param {int} iMode - valuation mode, see list above.
			* @param {Object} osp3DExpVariable - the created variable.
			*/
		    AddVariable: function (iVariableName, iType, iMaxNumberOfValues, iMode, osp3DExpVariable) {
		        console.log("interface using these variables : " + iVariableName + iType + iMaxNumberOfValues + iMode + osp3DExpVariable);
			},

			/**
			* Get variable value from its name
			* @public
			* @param {String} iName - the variable name
			* @returns {Object} variable value.
			*/
		    GetValueByName: function (iName) {
		        console.log("interface using these variables : " + iName);
		        return undefined;
			},

			/**
			* Set a variable value
			* @public
			* @param {String} iName - the variable name
			* @param {Object} iValue - variable value to set.
			*/
		    SetValueByName: function (iName, iValue) {
		        console.log("interface using these variables : " + iName  + iValue);
		    },

		    GetVariableInfo: function (iName) {},

		    GetVariableType: function (iName) {},
		},

		/**
		* optional methods 
		* @lends DS/CAT3DExpModel/interfaces/CATI3DExperienceObject.prototype
		*/
		optional: {			
		}
	});

	CATI3DExperienceObject.VarType = {
	    Integer: 0,
	    Double: 1,
	    String: 2,
	    Object: 3,
	    Boolean: 4,
	    Color: 5,
	    All: 6
	};

	CATI3DExperienceObject.ValuationMode = {
	    AggregatingValue: 0,
	    ReferencingValue: 1,
	    PointingVariable: 2
	};

	CATI3DExperienceObject.SetValueMode = {
	    OnlyVolatile: 0,
	    NoCheck: 1
	};

	return CATI3DExperienceObject;
});




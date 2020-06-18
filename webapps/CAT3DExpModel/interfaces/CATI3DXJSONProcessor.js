/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXJSONProcessor
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXJSONProcessor',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DXJSONProcessor
	* @interface
	* @description 
	* @category Interface
	*/

	var CATI3DXJSONProcessor = CATWebInterface.singleton(
	/** @lends DS/CAT3DExpModel/interfaces/CATI3DXJSONProcessor.prototype **/
	{

	    interfaceName: 'CATI3DXJSONProcessor',

		/**
		* required methods 
		* @lends DS/CAT3DExpModel/interfaces/CATI3DXJSONProcessor.prototype
		*/
		required: {

			/**
			* @public
			*/
		    Process: function () {
			},

		},

		optional: {

		}



	});

	return CATI3DXJSONProcessor;
});

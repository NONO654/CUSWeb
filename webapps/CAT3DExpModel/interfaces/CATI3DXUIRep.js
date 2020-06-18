/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXUIRep
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXUIRep',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DXUIRep
	* @interface
	* @description 
	* Interface to get representation of 2D Actors
	* @category Interface
	*/

	var CATI3DXUIRep = CATWebInterface.singleton(
	/** @lends DS/CAT3DExpModel/interfaces/CATI3DXUIRep.prototype **/
	{

	    Attachment:{
	        ESide: {
	            eTopLeft: 0,
	            eTop: 1,
	            eTopRight: 2,
	            eLeft: 3,
	            eCenter: 4,
	            eRight: 5,
	            eBottomLeft: 6,
	            eBottom: 7,
	            eBottomRight: 8,
	            e3DActor: 9
	        }
	    },

		interfaceName: 'CATI3DXUIRep',

		/**
		* required methods 
		* @lends DS/CAT3DExpModel/interfaces/CATI3DXUIRep.prototype
		*/
		required: {

			/**
			*  Get the 2D rep of an UIActor
			* @public
			* @returns {div} the div holding the 2D representation and its children
			*/
		    Get: function () {
		        return undefined;
			}
		},

		optional: {

		}



	});

	return CATI3DXUIRep;
});

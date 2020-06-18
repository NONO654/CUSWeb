/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy
	* @interface
	* @description 
	* Interface to manage variable parent hierarchy in 3D
	*/

  var CATI3DXVisuHierarchy = CATWebInterface.singleton(
  /** @lends DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy.prototype **/
  {

    interfaceName: 'CATI3DXVisuHierarchy',

  	/**
	* required methods 
	* @lends DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy.prototype
	*/
    required: {

        /** 
		* Get 3D Visu Parent
		* @public
		* @returns {Object} parent visu actor
		*/
        GetVisuParent: function () {
            return undefined;
    	}
    },

    optional: {

    }
  });

  return CATI3DXVisuHierarchy;
});

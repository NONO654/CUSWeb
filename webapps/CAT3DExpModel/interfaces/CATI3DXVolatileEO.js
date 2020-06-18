/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO
    * @interface
	* @description 
    * Interface to manage variable values during play.
	*/

	var CATI3DXVolatileEO = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO.prototype **/
    {

    	interfaceName: 'CATI3DXVolatileEO',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO.prototype
        */
    	    required: {

    	        /** 
            * Set 'useOnlyVolatile' flag to true for each component variable. So values won't be persistent during volatile mode.
            * Used before play, this method is called recursively on all children.
            * @public
            */
    		    setVolatile: function () {
    		    },

    	        /** 
            * Set 'useOnlyVolatile' flag to false for each component variable. This restores persistence on variables and reset values.
            * This method is called recursively on all children
            * @public
            */
    		    restorePersistent: function () {
    		    }
    	    },

    	    optional: {
    	    }
    });

	return CATI3DXVolatileEO;
});

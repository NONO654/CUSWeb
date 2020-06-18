/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder',
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
	* @name DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder
    * @interface
	* @description 
    * Interface to manage Assets according to a link context.
    * @category Interface
	*/

	var CATI3DXAssetHolder = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder.prototype **/
    {

    	interfaceName: 'CATI3DXAssetHolder',

    	/**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder.prototype
        */
    	required: {

    		/**
		    * set link context of the asset holder
		    * @public
		    * @param {object} iLinkContext - the link context
		    */
    	    setLinkContext: function (iLinkContext) {
    	        console.log("interface using these variables : " + iLinkContext);
    		},

    		/**
		    * Get link context
		    * @public
		    * @returns {Object} current link context
		    */
    	    getLinkContext: function () {
    	        return undefined;
    		},

    		/**
		    * set link description
		    * @public
		    * @param {string} iLinkDescription - the link description
		    */
    	    setLinkDescription: function (iLinkDescription) {
    	        console.log("interface using these variables : " + iLinkDescription);
    		},

    		/**
		    * return link description
		    * @public
		    * @returns {string} current link description
		    */
    	    getLinkDescription: function () {
    	        return undefined;
    		},

    		/**
		    * set cache
		    * @public
		    * @param {object} iCache - the cache to set
		    */
    	    setCache: function (iCache) {
    	        console.log("interface using these variables : " + iCache);
    		},

    		/**
		    * return the cache
		    * @public
		    * @returns {object} cache
		    */
    	    getCache: function () {
    	        return undefined;
    		},

    		/**
		    * Process asset resolution according to its linkcontext
		    * @public
		    */
    		resolveAsset: function () {
    		},

    		/**
		    * Is asset resolved ?
		    * @public
		    * @returns {boolean} true if resolved, false otherwise
		    */
    		isResolved: function () {
    		    return undefined;
    		}

    	},

    	optional: {

    	}
    });

	return CATI3DXAssetHolder;
});

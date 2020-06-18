/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DGeoVisu
*/
define('DS/CAT3DExpModel/interfaces/CATI3DGeoVisu',
// dependencies
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface)
{
    'use strict';

    /**
	* @name DS/CAT3DExpModel/interfaces/CATI3DGeoVisu
    * @interface
	* @description 
    * Interface to get a graphic representation of Actors 3D in web visualization.
    * @category Interface
	*/

    var CATI3DGeoVisu = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATI3DGeoVisu.prototype **/
    {

        interfaceName: 'CATI3DGeoVisu',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATI3DGeoVisu.prototype
        */
        required: {

            /**
            * Get web visualization node
            * @public
            * @returns {Node3D} the node holding the 3D representation and its children
            */
            GetNode: function () {
                return undefined;
            },

        	/**
            * Get path element
            * @public
            * @returns {Object} the path Element
            */
            GetPathElement: function () {
                return undefined;
            },

        	/**
            * Get override
            * @public
            * @returns {Object} the override
            */
            GetOverride: function () {
                return undefined;
            },

            /**
            * Get web visualization representation
            * @public
            * @returns {Node3D} the node holding the 3D representation without its children
            */
            GetLocalNodes: function () {
                return undefined;
            },

            /**
            * Update visualization node : children, position, visibility, color, etc...
            * @public
            */
            Refresh: function () {
            },

        	/**
            * Request a refresh of the 3D visu to the visu manager
            * @public
            */
            RequestVisuRefresh: function () {
            },

            /**
            * Get readiness of web visualization
            * @public
            * @returns {boolean} true if ready to be shown, false otherwise.
            */
            isReady: function () {
                return false;
            },

            /**
            * Set readiness of web visualization
            * @public
            * @param {boolean} iReady - true if ready, false otherwise.
            */
            setReady: function (iReady) {
                console.log("interface using these variables : " + iReady);
            },

            /**
            * Get axis aligned bounding box of the node and its children.
            * @public
            * @returns {THREEDS.Core.Box3} the bounding box
            */
            GetBoundingBox: function () {
                return undefined;
            },

            /**
            * Get bounding sphere of the node and its children.
            * @public
            * @returns {THREEDS.Core.Sphere} the bounding sphere
            */
            GetBoundingSphere: function () {
                return undefined;
            }
        },

        optional: {

        }
    });

    return CATI3DGeoVisu;
});

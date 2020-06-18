/**
 * @exports DS/CAT3DExpModel/interfaces/CATIMovable
*/
define('DS/CAT3DExpModel/interfaces/CATIMovable',
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
	* @name DS/CAT3DExpModel/interfaces/CATIMovable
    * @interface
	* @description 
    * Interface to get or set the component position.
    * @category Interface
	*/

    var CATIMovable = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATIMovable.prototype **/
    {

        interfaceName: 'CATIMovable',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATIMovable.prototype
        */
        required: {

            /**
            * Get local position
            * @public
            * @param {DSMath.Transformation} oTransform - a matrix to fill
            */
            GetLocalPosition: function (oTransform) {
                console.log("interface using these variables : " + oTransform);
            },

            /**
            * Set local position
            * @public
            * @param {Object} iMovable - the movable context from which set the position
            * @param {DSMath.Transformation} iTransform - the transform matrix
            */
            SetLocalPosition: function (iMovable, iTransform) {
                console.log("interface using these variables : " + iMovable + iTransform);
            },

            /**
            * Get absolute position
            * @public
            * @param {DSMath.Transformation} iTransform - a matrix to fill
            */
            GetAbsPosition: function (iTransform) {
                console.log("interface using these variables : "  + iTransform);
            },

            /**
            * Set absolute position
            * @public
            * @param {DSMath.Transformation} iTransform - the transform matrix
            */
            SetAbsPosition: function (iTransform) {
                console.log("interface using these variables : " + iTransform);
            },
        },

        optional: {

        }
    });

    return CATIMovable;
});

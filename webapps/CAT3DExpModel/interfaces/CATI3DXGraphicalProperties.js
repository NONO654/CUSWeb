/**
 * @exports DS/CAT3DExpModel/interfaces/CATI3DXGraphicalProperties
*/
define('DS/CAT3DExpModel/interfaces/CATI3DXGraphicalProperties',
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
    * @name DS/CAT3DExpModel/interfaces/CATI3DXGraphicalProperties
    * @interface
    * @description 
    * Interface to manage color, visibility and opacity of the component.
    * @category Interface
    */

    var CATI3DXGraphicalProperties = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATI3DXGraphicalProperties.prototype **/
    {

        interfaceName: 'CATI3DXGraphicalProperties',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATI3DXGraphicalProperties.prototype
        */
        required: {

            /**
            * Get pick mode
            * @public
            * @returns {boolean} true if pickable, false otherwise. 
            */
            GetPickMode: function () {
                return undefined;
            },

            /**
            * Set pick mode
            * @public
            * @param {boolean} iClickable - true to set pickable, false otherwise
            */
            SetPickMode: function (iClickable) {
                console.log("interface using these variables : " + iClickable);
            },

            /**
            * Get show mode
            * @public
            * @returns {boolean} true if visible, false otherwise. 
            */
            GetShowMode: function () {
                return undefined;
            },

            /**
            * Set show mode
            * @public
            * @param {boolean} iVisible - true to set visible, false otherwise
            */
            SetShowMode: function (iVisible) {
                console.log("interface using these variables : " + iVisible);
            },

            /**
            * Get opacity 
            * @public
            * @returns {int} a value between 0 and 255. 
            */
            GetOpacity: function () {
                return undefined;
            },

            /**
            * Set opacity
            * @public
            * @param {int} iOpacity - from 0 transparent to 255 opaque
            */
            SetOpacity: function (iOpacity) {
                console.log("interface using these variables : " + iOpacity);
            },

            /**
            * Get the Red component of the representation color. Not the material color, the override one.
            * @public
            * @returns {int} red value from 0 to 255
            */
            GetRed: function () {
                return undefined;
            },

            /**
            * Get the Green component of the representation color. Not the material color, the override one.
            * @public
            * @returns {int} green value from 0 to 255
            */
            GetGreen: function () {
                return undefined;
            },

            /**
            * Get the Blue component of the representation color. Not the material color, the override one.
            * @public
            * @returns {int} blue value from 0 to 255
            */
            GetBlue: function () {
                return undefined;
            },

            /**
            * Set color of the 3D representation.
            * @public
            * @param {int} iRed - from 0 to 255
            * @param {int} iGreen - from 0 to 255
            * @param {int} iBlue - from 0 to 255
            */
            SetColor: function (iRed, iGreen, iBlue) {
                console.log("interface using these variables : " + iRed + iGreen + iBlue);
            }
        },

        optional: {

        }
    });

    return CATI3DXGraphicalProperties;
});

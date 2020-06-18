/**
 * @exports DS/CATCXPLightModel/interfaces/CATICXPLight
*/
define('DS/CATCXPLightModel/interfaces/CATICXPLight',
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
	* @name DS/CATCXPLightModel/interfaces/CATICXPLight
    * @interface
	* @description 
    * Interface to get and set a light.
    * @category Interface
	*/

    var CATICXPLight = CATWebInterface.singleton(
    /** @lends DS/CATCXPLightModel/interfaces/CATICXPLight.prototype **/
    {

        interfaceName: 'CATICXPLight',

    	/**
        * required methods 
        * @lends DS/CATCXPLightModel/interfaces/CATICXPLight.prototype
        */
        required: {
            /**
            * Set intensity of the light
            * @public
            * @param {float} intensity light intensity
            */
            SetIntensity: function (intensity) {
                console.log("interface using these variables : " + intensity);
            },

            /**
            * Get intensity of the light
            * @public
            * @returns {float} intensity
            */
            GetIntensity: function () {
                return undefined;
            },

            /**
            * Set the diffuse color of the light
            * @public
            * @param {int} red - from 0 to 255
            * @param {int} green - from 0 to 255
            * @param {int} blue - from 0 to 255
            */
            SetColor: function (red, green, blue) {
                console.log("interface using these variables : " + red + green + blue);
            },

            /**
            * Get the Red component of the diffuse color of the light.
            * @public
            * @returns {int} red value from 0 to 255
            */
            GetRed: function () {
                return undefined;
            },

            /**
            * Get the Green component of the the diffuse color of the light.
            * @public
            * @returns {int} green value from 0 to 255
            */
            GetGreen: function () {
                return undefined;
            },

            /**
            * Get the Blue component of the diffuse color of the light.
            * @public
            * @returns {int} blue value from 0 to 255
            */
            GetBlue: function () {
                return undefined;
            }
        },

        optional: {

        }
    });

    return CATICXPLight;
});

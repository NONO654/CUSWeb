/**
 * @exports DS/CATCXPLightModel/interfaces/CATICXPSpotLight
*/
define('DS/CATCXPLightModel/interfaces/CATICXPSpotLight',
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
	* @name DS/CATCXPLightModel/interfaces/CATICXPSpotLight
    * @interface
	* @description 
    * Interface to get and set a spotlight.
    * @category Interface
	*/

    var CATICXPSpotLight = CATWebInterface.singleton(
    /** @lends DS/CATCXPLightModel/interfaces/CATICXPSpotLight.prototype **/
    {

        interfaceName: 'CATICXPSpotLight',

    	/**
        * required methods 
        * @lends DS/CATCXPLightModel/interfaces/CATICXPSpotLight.prototype
        */
        required: {
             /**
             * Set the position of the target of the light
             * @public
             * @param {DSMath.Transformation} targetPosition - a matrix to fill
             */
            SetTargetPosition: function (targetPosition) {
                console.log("interface using these variables : " + targetPosition);
            },

            /**
            * Get the position of the target of the light
            * @public
            * @returns {DSMath.Transformation} targetPosition - a matrix to fill
            */
            GetTargetPosition: function () {
                return undefined;
            },

            /**
            * If true the target is attached as a child of the light and has relative position and rotation.
            * @public
            * @param {boolean} attached true the target is attached, false the target isn't
            */
            AttachTargetToLight: function (attached) {
                console.log("interface using these variables : " + attached);
            },

            /**
             * Maximum angle of light dispersion from its direction
             * @public
             * @param {float} angle 0 - 360
             */
            SetOuterAngle: function (angle) {
                console.log("interface using these variables : " + angle);
            },

            /**
             * Maximum angle of light dispersion from its direction
             * @public
             * @returns {float} angle 0 - 360
             */
            GetOuterAngle: function () {
                return undefined;
            },

            /**
             * Percent of the spotlight cone that is attenuated due to penumbra
             * @public
             * @param {float} penumbra 0 - 1
             */
            SetPenumbra: function (penumbra) {
                console.log("interface using these variables : " + penumbra);
            },

            /**
             * Percent of the spotlight cone that is attenuated due to penumbra
             * @public
             * @returns {float} 0 - 1
             */
            GetPenumbra: function () {
                return undefined;
            },

            /**
            * Set if the light will cast shadows.
            * @public
            * @param {boolean} castShadow true the light casts shadow, false the light doesn't
            */
            SetCastShadow: function (castShadow) {
                console.log("interface using these variables : " + castShadow);
            },

            /**
            * Get if the light will cast shadows.
            * @public
            * @returns {boolean} true the light casts shadow, false the light doesn't
            */
            GetCastShadow: function () {
                return undefined;
            }
        },

        optional: {
        }
    });

    return CATICXPSpotLight;
});

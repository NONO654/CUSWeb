/**
 * @exports DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight
*/
define('DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight',
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
	* @name DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight
    * @interface
	* @description 
    * Interface to get and set a Directional light.
    * @category Interface
	*/

    var CATICXPDirectionalLight = CATWebInterface.singleton(
    /** @lends DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight.prototype **/
    {

        interfaceName: 'CATICXPDirectionalLight',

    	/**
        * required methods 
        * @lends DS/CATCXPLightModel/interfaces/CATICXPDirectionalLight.prototype
        */
        required: {
            /**
            * Set the direction of the light
            * @public
            * @param {DSMath.Vector3D} direction - light direction
            */
            SetDirection: function (direction) {
                console.log("interface using these variables : " + direction);
            },

            /**
            * Get intensity of the light
            * @public
            * @returns {DSMath.Vector3D} direction
            */
            GetDirection: function () {
                return undefined;
            },

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
           
        },

        optional: {

        }
    });

    return CATICXPDirectionalLight;
});

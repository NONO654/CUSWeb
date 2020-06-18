/**
 * @exports DS/CATCXPModel/interfaces/CATICXPObject
*/
define('DS/CATCXPModel/interfaces/CATICXPObject',
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
	* @name DS/CATCXPModel/interfaces/CATICXPObject
    * @interface
	* @description 
    * Interface to manage component hierarchy.
	*/

    var CATICXPObject = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPObject.prototype **/
    {
        interfaceName: 'CATICXPObject',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPObject.prototype
        */
        required: {


            /**
            * Retrieves the root experience object.
            * @public
            * @returns {Object} root experience
            */   	
            GetRootFather: function(){
            },

            /**
            * Retrieves the direct father aggregating this object.
            * @public
            * @returns {Object}CATI3DExperienceObject interface of father if found, undefined otherwise
            */
            GetFatherObject: function () {
            }
        },

        optional: {

        }
    });

    return CATICXPObject;
});

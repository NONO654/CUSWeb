/**
 * @exports DS/XCTWebExperienceAppPlay/interfaces/StuIPrototypeBuild
*/
define('DS/XCTWebExperienceAppPlay/interfaces/StuIPrototypeBuild',
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface) {
    'use strict';

    /**
	* @name DS/XCTWebExperienceAppPlay/interfaces/StuIPrototypeBuild
    * @interface
	* @description 
    * This interface maps model objects with Creative SDK "play" instances.
    * @category Interface
	* @constructor
	*/

    var StuIPrototypeBuild = CATWebInterface.singleton(
    /** @lends DS/XCTWebExperienceAppPlay/interfaces/StuIPrototypeBuild.prototype **/
    {

    	interfaceName: 'StuIPrototypeBuild',

        /**
        * required methods 
        * @lends DS/XCTWebExperienceAppPlay/interfaces/StuIPrototypeBuild.prototype
        */
        required:
        {
            /**
            * Get built object
            * @public
            * @returns {Object} the built instance
            */
            Get: function () {
            },

            /** 
		    * Destroy _instance object and listener.
		    * This method is called recursively on all children	
            * @public
		    */
            Free: function () {
            }
        },

        /*
        * optional methods 
        */
        optional: {

        }
    });

    return StuIPrototypeBuild;
});

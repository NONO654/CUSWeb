/**
 * @exports DS/CATCXPModel/interfaces/CATICXPUIActor
*/
define('DS/CATCXPModel/interfaces/CATICXPUIActor',
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
    * @category Interface
	* @name DS/CATCXPModel/interfaces/CATICXPUIActor
    * @interface
	* @description 
    * Interface to manage 2D properties on the component.
	*/

    var CATICXPUIActor = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/CATICXPUIActor.prototype **/
    {

        interfaceName: 'CATICXPUIActor',
        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/CATICXPUIActor.prototype
        */

        required: {

        	/**
            * Set ui actor offset position
            * @public
            * @param {DSMath.Vector2D} offset - offset to set
            */
        	SetOffset: function (iOffset) { },

        	/**
            * Get  ui actor offset position
            * @public
            * @returns {DSMath.Vector2D} offset
            */
        	GetOffset: function () { },

        	/**
            * Set ui actor minimum dimension
            * @public
            * @param {float} width - minimum width
            * @param {float} height - minimum height
            */
        	SetMinimumDimension: function (iWidth, iHeight) { },

        	/**
            * Get ui actor minimum dimension
            * @public
            * @returns {StuDimension} widget minimum dimension
            */
        	GetMinimumDimension: function () { },

        	/**
            * Get ui actor dimension
            * @public
            * @returns {StuDimension} widget dimension
            */
        	GetDimension: function () { },

        	/**
            * Set ui actor attachment
            * @public
            * @returns {integer} attachment
            */
        	SetAttachment: function (iSide, iTarget) { },

        	/**
            * Enable/Disable ui actor
            * @public
            */
        	SetEnable: function (iEnable) { },

            /**
            * Get ui actor enable
            * @public
            * @returns {boolean} 
            */
        	GetEnable: function () { },

        	/**
            * Set ui actor opacity
            * @public
            */
        	SetOpacity: function (iOpacity) { },

            /**
            * Get ui actor opacity
            * @public
            * @returns {Integer} opacity
            */
        	GetOpacity: function (iOpacity) { },

        	/**
            * Set ui actor visibility
            * @public
            * @returns {boolean} visibility
            */
        	SetVisible: function (iVisible) { },

            /**
            * Get ui actor visibility
            * @public
            * @returns {boolean} visibility
            */
        	GetVisible: function (iVisible) { },
        },

        optional: {
        }
    });

    return CATICXPUIActor;
});

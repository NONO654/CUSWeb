/**
 * @exports DS/CATCXPModel/interfaces/VIAIIxpVirtualPath
*/
define('DS/CATCXPModel/interfaces/VIAIIxpVirtualPath',
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
    * @category Interface
	* @name DS/CATCXPModel/interfaces/VIAIIxpVirtualPath
    * @interface
	* @description 
    * Interface to manage path on the component.
	*/

	var VIAIIxpVirtualPath = CATWebInterface.singleton(
    /** @lends DS/CATCXPModel/interfaces/VIAIIxpVirtualPath.prototype **/
    {

    	interfaceName: 'VIAIIxpVirtualPath',

        /**
        * required methods 
        * @lends DS/CATCXPModel/interfaces/VIAIIxpVirtualPath.prototype
        */
    	    required: {
    	        /**
            * Add a point on the path
            * @public
            * @param {Object} point - the point to add
            * @param {Object} relativePositionObject - object where the point is positioned to
            */
    		    AddPoint: function (iPoint,  iRelativePositonObject) {
    		    },

    	        /**
            * Remove a point on the path
            * @public
            * @param {Int} Index - Index of the point to remove
            */
    		    RemovePoint: function (iIndex) {
    		    },

    	        /**
            * Insert a point on the path
            * @public
            * @param {Object} point - the point to add
            * @param {Int} Index - index of the path where to add the point
            * @param {Object} relativePositionObject - object where the point is positioned to
            */
    		    InsertPoint: function (iPoint, iIndex, iRelativePositonObject) {
    		    },

    	        /**
            * Get path points
            * @public
            * @param {Object[]} points - the array to fill with points
            */
    		    GetDefinePoints: function (oDefinePoints) {
    		    },

    	        /**
            * Get path point
            * @public
            * @param {Int} Index - index of the path point
            * returns {Object} the point
            */
    		    GetPointAtIndex: function (iIndex) {
    		    },

    	        /**
            * Get points count
            * @public
            * @returns {Int} points count
            */
    		    GetNumberOfPoint:function(){
    		    },

    	        /**
            * Get path length
            * @public
            * @returns {float} path length
            */
    		    GetLength: function () {
    		    },

    	        /**
            * Get point on the path
            * @public
            * @param {float} curveParam - from 0 to 1, position on the curve
            * @param {Object} relativePositionObject - object where the point is positioned to
            * @param {Point} value - computed position on the curve
            */
    		    GetValue: function (iCurvParam, iRelativePositonObject, oValue ) {
    		    }

    	    },

        /**
        * optional methods 
        * @lends DS/CATCXPModel/interfaces/VIAIIxpVirtualPath.prototype
        */
    	    optional: {
    	        /**
            * <b>OPTIONAL<b/>
            * Get Discretized points
            * @public
            */
    	        Discretize: function (iSag, oDicretePoints, iRelativePositonObject) {
    	        },

    	        /**
            * <b>OPTIONAL<b/>
            * Set Interpolation Mode
            * @public
            */
    	        SetInterpolationMode: function (iInterpolationType) {
    	        },

    	        /**
            * <b>OPTIONAL<b/>
            * Get Interpolation Mode
            * @public
            */
    	        GetInterpolationMode: function () {
    	        }

    	    }
    });

	return VIAIIxpVirtualPath;
});

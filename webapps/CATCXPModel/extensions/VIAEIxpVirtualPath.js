/**
 * VIAEIxpVirtualPath
*  @category Extension
 * @name DS/CATCXPModel/extensions/VIAEIxpVirtualPath
 * @description Implements {@link DS/CATCXPModel/interfaces/VIAIIxpVirtualPath StuVIAIIxpVirtualPath}
 * @constructor
 */
define('DS/CATCXPModel/extensions/VIAEIxpVirtualPath',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef',
    'DS/CATCXPModel/extensions/VIAEIxpLinearPath',
    'DS/CATCXPModel/extensions/VIAEIxpCubicPath'
],

// Declaration
function (
    UWA,
	CAT3DXInterfaceImpl,
	THREE,
	DSMath,
    VIAEIxpLinearPath,
    VIAEIxpCubicPath
    ) {
	'use strict';

	var VIAEIxpVirtualPath = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/VIAEIxpVirtualPath.prototype **/
	{
	    _getLinearImpl:function(){
	        if (!this._linearImpl) {
	            this._linearImpl = new VIAEIxpLinearPath(this);
	        }
	        return this._linearImpl;
	    },

	    _getCubicImpl:function(){
	        if (!this._cubicImpl) {
	            this._cubicImpl = new VIAEIxpCubicPath(this);
	        }
	        return this._cubicImpl;
	    },
		/**  
        * @public
        */
		AddPoint: function (iPoint, iRelativePositonObject) {
			console.error('Not Implemented');
		},

	    /**  
        * @public
        */
		RemovePoint: function (iIndex) {
			console.error('Not Implemented');
		},

	    /**  
        * @public
        */
		InsertPoint: function (iPoint, iIndex, iRelativePositonObject) {
			console.error('Not Implemented');
		},

	    /**  
        * @public
        */
		GetDefinePoints: function (oDefinePoints) {
			if (!Array.isArray(oDefinePoints)) {
				UWA.log('VIAEIxpVirtualPath.GetDefinePoints ERROR : unable to fill parameters, not an array !');
				return;
			}
			oDefinePoints.length = 0;
			var pointsList = this.QueryInterface('CATI3DExperienceObject').GetValueByName('pointslist');
			for (var i = 0; i < pointsList.length; i++) {
				oDefinePoints.push(pointsList[i]);
			}
		},

	    /**  
        * @public
        */
		GetPointAtIndex: function (iIndex) {
		    var pointsLists = this.QueryInterface('CATI3DExperienceObject').GetValueByName('pointslist');
		    return pointsLists[iIndex];
		},

	    /**  
        * @public
        */
		GetNumberOfPoint: function () {
		    return this.QueryInterface('CATI3DExperienceObject').GetValueByName('pointslist').length;
		},

	    /**  
        * @public
        */
		GetLength: function () {
		    if (this.QueryInterface('CATI3DExperienceObject').GetValueByName('interpolationType') === 0) { //linear
		        return this._getLinearImpl().GetLength();
		    }
		    else { //cubic
		        return this._getCubicImpl().GetLength();
		    }
		},		

	    /**  
        * @public
        */
		GetValue: function (iCurvParam, iRelativePositionObject, oValue) {
		    if (this.QueryInterface('CATI3DExperienceObject').GetValueByName('interpolationType') === 0) { //linear
		        return this._getLinearImpl().GetValue(iCurvParam, iRelativePositionObject, oValue);
		    }
		    else { //cubic
		        return this._getCubicImpl().GetValue(iCurvParam, iRelativePositionObject, oValue);
		    }
		},	

	});

	return VIAEIxpVirtualPath;
});

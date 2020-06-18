/**
 * VIAEIxpLinearPath
 * @name DS/CATCXPModel/extensions/VIAEIxpLinearPath
 * @constructor
 */
define('DS/CATCXPModel/extensions/VIAEIxpLinearPath',
[
	'UWA/Core',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef'
],

// Declaration
function (
    UWA,
	THREE,
	DSMath
    ) {
	'use strict';

	var VIAEIxpLinearPath = UWA.Class.extend(
	/** @lends DS/CATCXPModel/extensions/VIAEIxpLinearPath.prototype **/
	{

	    init:function(iPathExtension){
	        this._pathExtension = iPathExtension;
	    },

	    /**  
        * @public
        */
		GetLength: function () {
			var pointslist = [];
			this._pathExtension.GetDefinePoints(pointslist);
			var length = 0;
			if (pointslist.length < 2) {
				return length;
			}
			for (var i = 0; i < pointslist.length -1; i++) {
				length += this._getSubSectionLength(pointslist[i], pointslist[i + 1]);
			}
			return length;
		},

		_getSubSectionLength: function (iPoint1, iPoint2) {
			var pos1 = iPoint1.QueryInterface('CATI3DExperienceObject').GetValueByName('position');
			var pos2 = iPoint2.QueryInterface('CATI3DExperienceObject').GetValueByName('position');
			var vec3 = new THREE.Vector3(pos2[0] - pos1[0], pos2[1] - pos1[1], pos2[2] - pos1[2]);
			return vec3.length();
		},

	    /**  
        * @public
        */
		GetValue: function (iCurvParam, iRelativePositonObject, oValue) {
			if ((iCurvParam > 1) || (iCurvParam < 0)) {
				UWA.log('VIAEIxpVirtualPath.GetValue ERROR : iCurvParam not in the range[0,1] !');
				return;
			}
			var pointslist = [];
			this._pathExtension.GetDefinePoints(pointslist);
			if (pointslist.length < 2) {
				return;
			}

			var curveParamLength = iCurvParam * this._pathExtension.GetLength();
			var length = 0;
			var idxPts = 0;
			var subSectionLength = 0;
			while (((length + subSectionLength) <= curveParamLength) && (idxPts < pointslist.length - 1)) {
				length+= subSectionLength;
				var subSectionLength = this._getSubSectionLength(pointslist[idxPts], pointslist[idxPts + 1]);
				idxPts++;
			}

			var pos1 = pointslist[idxPts -1].QueryInterface('CATI3DExperienceObject').GetValueByName('position');
			var pos2 = pointslist[idxPts].QueryInterface('CATI3DExperienceObject').GetValueByName('position');
			var curveParamLengthInSection = curveParamLength - length;
			var curbeparamInSection = curveParamLengthInSection / subSectionLength;

			var vec3 = new DSMath.Vector3D(pos1[0] + (pos2[0] - pos1[0]) * curbeparamInSection, pos1[1] + (pos2[1] - pos1[1]) * curbeparamInSection,
				pos1[2] + (pos2[2] - pos1[2]) * curbeparamInSection);

			if (UWA.is(iRelativePositonObject)) {
				console.ward('not implemented yet TODO');
			}
			else {
				var transform = new DSMath.Transformation();
				this._pathExtension.QueryInterface('CATIMovable').GetAbsPosition(transform);
				oValue.x = transform.vector.x + vec3.x;
				oValue.y = transform.vector.y + vec3.y;
				oValue.z = transform.vector.z + vec3.z;
			}
		}

	});

	return VIAEIxpLinearPath;
});

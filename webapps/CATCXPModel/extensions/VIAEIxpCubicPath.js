/**
 * CPR4: works same way as SVV path in win but the integration computation to get the length of a portion of the curve isn't implemented 
 * and threejs CubicBezierCurve is used instead in CATEVirtualPathActor3DGeoVisu
 * VIAEIxpCubicPath
 * @name DS/CATCXPModel/extensions/VIAEIxpVirtualPath
 * @constructor
 */
define('DS/CATCXPModel/extensions/VIAEIxpCubicPath',
[
	'UWA/Core',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef',
    'DS/CATCXPModel/extensions/VIAEIxpCubicSubSectionPath'
],

// Declaration
function (
    UWA,
	THREE,
	DSMath,
    VIAEIxpCubicSubSectionPath
    ) {
	'use strict';

	var VIAEIxpCubicPath = UWA.Class.extend(
	/** @lends DS/CATCXPModel/extensions/VIAEIxpVirtualPath.prototype **/
	{
	    init: function (iPathExtension) {
	        this._pathExtension = iPathExtension;
	        this._subSections = {};
	    },

	    GetLength: function () {
	        var pointslist = [];
	        this._pathExtension.GetDefinePoints(pointslist);
	        var length = 0;
	        if (pointslist.length < 2) {
	            return length;
	        }
	        for (var i = 0; i < pointslist.length - 1; i++) {
	            length += this._getSubSection(pointslist[i], pointslist[i + 1]).getLength();
	        }
	        return length;
	    },

	    _getSubSection: function (iPoint1, iPoint2) {
	        var sectionKey = iPoint1.GetID() + iPoint2.GetID();
	        if (!this._subSections[sectionKey]) {
	            this._subSections[sectionKey] = new VIAEIxpCubicSubSectionPath(new DSMath.Vector3D().setFromArray(iPoint1.QueryInterface('CATI3DExperienceObject').GetValueByName('position')),
                    new DSMath.Vector3D().setFromArray(iPoint2.QueryInterface('CATI3DExperienceObject').GetValueByName('position')), this._getTangentFromPoint('RIGHT', iPoint1), this._getTangentFromPoint('LEFT', iPoint2));
	        }
	        return this._subSections[sectionKey];
	    },

		GetValue: function (iCurvParam, iRelativePositionObject, oValue) {
			if ((iCurvParam > 1) || (iCurvParam < 0)) {
				UWA.log('VIAEIxpVirtualPath.GetValue ERROR : iCurvParam not in the range[0,1] !');
				return;
			}
			var pointslist = [];
			this._pathExtension.GetDefinePoints(pointslist);
			if (pointslist.length < 2) {
				return;
			}

			var curveParamLength = iCurvParam * this.GetLength();
			var length = 0;
			var idxPts = 0;
			var subSectionLength = 0;
			do {
			    var subSection = this._getSubSection(pointslist[idxPts], pointslist[idxPts + 1]);
			    var subSectionLength = subSection.getLength();
			    length += subSectionLength;
			    idxPts++;
			} while (length <= curveParamLength && idxPts < pointslist.length - 1);

			var vec3 = subSection.getValueFromLengthRatio((curveParamLength - length + subSectionLength) / subSectionLength);

			if (UWA.is(iRelativePositionObject)) {
				console.warn('not implemented yet TODO');
			}
			else {
				var transform = new DSMath.Transformation();
				this._pathExtension.QueryInterface('CATIMovable').GetAbsPosition(transform);
				oValue.x = transform.vector.x + vec3.x;
				oValue.y = transform.vector.y + vec3.y;
				oValue.z = transform.vector.z + vec3.z;
			}
		},

		_getTangentFromPoint: function (iTangentSide, iPoint) {
		    const epsilon = 0.0000000001; //check epsilon value
		    var tangent = new DSMath.Vector3D();
		    var isPathReversed = this._pathExtension.QueryInterface('CATI3DExperienceObject').GetValueByName("reversedDirection");
		    if(!isPathReversed){
		        if(iTangentSide === "RIGHT"){
		            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("rightTangent"));
		        }
		        else if(iTangentSide === "LEFT"){
		            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("leftTangent"));
		        }
		    }
		    else{
		        if(iTangentSide === "RIGHT"){
		            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("leftTangent"));
		        }
		        else if(iTangentSide === "LEFT"){
		            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("rightTangent"));
		        }
		    }

		    if (tangent.norm() < epsilon) {
		        tangent = this._computeDefaultTangent(iPoint);        //VIAIxpVirtualPointOfPath_PointOfPathImpl.cpp   l.961
		    }

		    return tangent;
		},

	    _computeDefaultTangent: function (iPoint) {
	        const AFTER_BEFORE_VECTOR_FACTOR = 0.5;

	        var isPathReversed = this._pathExtension.QueryInterface('CATI3DExperienceObject').GetValueByName("reversedDirection");
	        var modelOrderIndex = iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("index");
	        var currentIndex = (!isPathReversed) ? modelOrderIndex : (nbPathPoint - modelOrderIndex + 1);

	        var pointsList = [];
	        this._pathExtension.GetDefinePoints(pointsList);

	        if (currentIndex === 1) {
	            var index = 2;
	            do {
	                if (pointsList[index - 1] !== undefined) {
	                    var pointAfter = new DSMath.Vector3D().setFromArray(pointsList[index - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var pointBefore = new DSMath.Vector3D().setFromArray(pointsList[currentIndex - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var beforeAfterVector = pointAfter.subVectorFromVector(pointBefore);
	                }
	                index++;
	            } while (beforeAfterVector.norm() === 0 && index <= pointsList.length());
	        }
	        else if (currentIndex === pointsList.length) {
	            var index = pointsList.length - 1;
	            do {
	                if (pointsList[index - 1] !== undefined) {
	                    var pointAfter = new DSMath.Vector3D().setFromArray(pointsList[currentIndex - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var pointBefore = new DSMath.Vector3D().setFromArray(pointsList[index - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var beforeAfterVector = pointAfter.subVectorFromVector(pointBefore);
	                }
	                index--;
	            } while (beforeAfterVector.norm() === 0 && index >= 1);
	        }
	        else {
	            var indexBefore = currentIndex - 1;
	            var indexAfter = currentIndex + 1;
	            do {
	                if (pointsList[indexAfter - 1] !== undefined) {
	                    var pointAfter = new DSMath.Vector3D().setFromArray(pointsList[indexAfter - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var pointBefore = new DSMath.Vector3D().setFromArray(pointsList[indexBefore - 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position'));
	                    var beforeAfterVector = pointAfter.subVectorFromVector(pointBefore);
	                }
	                indexAfter++;
	            } while (beforeAfterVector.norm() === 0 && indexAfter <= pointsList.length());
	        }

	        return beforeAfterVector.multiplyScalar(AFTER_BEFORE_VECTOR_FACTOR);
	    }


	});

	return VIAEIxpCubicPath;
});

define('DS/XCTWebExperienceAppPlay/StuTriggerZoneManagerWeb',
// dependencies
[
    'UWA/Core',
	'DS/StuCore/StuContext',
	'DS/StuMath/StuBox',
	'MathematicsES/MathsDef'
],
function (UWA, STU, Box, DSMath) {

	'use strict';

	var StuTriggerZoneManager = UWA.Class.extend({
		__stu__Init: function () {
			this._uObjectID = 0;
			this._triggerZones = [];
			this._triggeringObjects = [];

			this._interactionsMap = {};
		},

		__stu__Dispose:function(){
		},

		__stu__RegisterTriggerZone: function (iStuGeoVisu) {
			this._triggerZones.push({
				id: this._uObjectID,
				stuObject: iStuGeoVisu.getStuObject()
			});
			var oId = this._uObjectID;
			this._uObjectID++;
			return oId;
		},

		__stu__RegisterTriggeringObject: function (iStuGeoVisu) {
			this._triggeringObjects.push({
				id: this._uObjectID,
				stuObject: iStuGeoVisu.getStuObject()
			});
			var oId = this._uObjectID;
			this._uObjectID++;
			return oId;
		},

		__stu__GetNbTriggerZones: function () {
			return this._triggerZones.length;
		},

		__stu__GetNbTriggeringObjects: function () {
			return this._triggeringObjects.length;
		},

		__stu__UnRegisterTriggerZone: function (iId) {
			var idx = this._triggerZones.map(function (el) { return el.id; }).indexOf(iId);
			if (idx >= 0) {
				this._triggerZones.splice(idx, 1);
			}
		},

		__stu__UnRegisterTriggeringObject: function (iId) {
			var idx = this._triggeringObjects.map(function (el) { return el.id; }).indexOf(iId);
			if (idx >= 0) {
				this._triggeringObjects.splice(idx, 1);
			}
		},

		__stu__Run: function () {
			this.refreshTransform(this._triggerZones);
			this.refreshTransform(this._triggeringObjects);

			this._computeInteractions();
		},

		refreshTransform: function (iObjectsArray) {
			for (var i = 0; i < iObjectsArray.length; i++) {
				var newTransform = iObjectsArray[i].stuObject.getTransform();
				if (!iObjectsArray[i].transform) {
					iObjectsArray[i].transfoChanged = true;
				}
				else {
					iObjectsArray[i].transfoChanged = this.areTransfoEqual(iObjectsArray[i].transform, newTransform);
				}
				iObjectsArray[i].transform = newTransform;
				if (iObjectsArray[i].transfoChanged) {
					this.refreshBB(iObjectsArray[i]);
					this.refreshOBBCornerPoints(iObjectsArray[i]);
				}
			}
		},

		refreshBB: function (iObject) {
			var bb = new Box();
			iObject.stuObject.StuIRepresentation.GetBoundingBox(bb, iObject.transform, 0);
			iObject.bb = bb;
		},

		refreshOBBCornerPoints: function (iObject) {
			var obb = new Box();
			iObject.stuObject.StuIRepresentation.GetOrientedBoundingBox(obb, { orientation: iObject.transform, excludeChildren: false }, iObject.transform);

			var length = obb.high.x - obb.low.x;
			var width = obb.high.y - obb.low.y;
			var height = obb.high.z - obb.low.z;

			var obbCornerPoints = [];
			for (var i = 0; i < 4; i++) {
				obbCornerPoints[i] = obb.low.clone();
			}
			for (var i = 0; i < 4; i++) {
				obbCornerPoints[i + 4] = obb.high.clone();
			}
			obbCornerPoints[1].x += length;
			obbCornerPoints[2].y += width;
			obbCornerPoints[3].z += height;
			obbCornerPoints[4].x -= length;
			obbCornerPoints[5].y -= width;
			obbCornerPoints[6].z -= height;

			for (var i = 0; i < 8; i++) {
				obbCornerPoints[i].applyTransformation(iObject.transform);
			}
			iObject.obbCornerPoints = obbCornerPoints;
		},

		_computeInteractions: function () {
			for (var tzIndex = 0; tzIndex < this._triggerZones.length; tzIndex++) {
				for (var toIndex = 0; toIndex < this._triggeringObjects.length; toIndex++) {
					if ((this._triggerZones[tzIndex].transfoChanged) || (this._triggeringObjects[toIndex].transfoChanged)) {
						this._computeInteraction(this._triggerZones[tzIndex], this._triggeringObjects[toIndex]);
					}
				}
			}
		},

		_computeInteraction: function (iTZ, iTO) {
			var interactionType = this.isIntersectByBoundingBox(iTZ.bb, iTO.bb);
			if (interactionType !== -1) {
				interactionType = this.isIntersectByOrientedBoundingBox(iTZ.obbCornerPoints, iTO.obbCornerPoints);
			}

			var oldInteractionType;
			if (UWA.is(this._interactionsMap[iTZ.id]) && UWA.is(this._interactionsMap[iTZ.id][iTO.id])) {
				oldInteractionType = this._interactionsMap[iTZ.id][iTO.id];
			}
			else {
				oldInteractionType = -1;
			}

			/* 0 : No inclusion
            * 1 : TriggerZone is include in an object
            * 2 : TriggerZone include an object
            */

			if (oldInteractionType !== interactionType) {
				if ((oldInteractionType < 0) && (interactionType >= 0)) {
					STU.TriggerZoneManager.getInstance().onTriggerZoneEntry(iTZ.id, iTO.id);
				}
				if ((oldInteractionType >= 0) && (interactionType < 0)) {
					STU.TriggerZoneManager.getInstance().onTriggerZoneExit(iTZ.id, iTO.id);
				}
				if ((interactionType > 0) && (oldInteractionType <= 0)) {
					STU.TriggerZoneManager.getInstance().onTriggerZoneInclusion(iTZ.id, iTO.id, interactionType);
				}
				if ((interactionType <= 0) && (oldInteractionType > 0)) {
					STU.TriggerZoneManager.getInstance().onTriggerZoneEndInclusion(iTZ.id, iTO.id, interactionType);
				}
			}

			if (!UWA.is(this._interactionsMap[iTZ.id])) {
				this._interactionsMap[iTZ.id] = {};
			}
			this._interactionsMap[iTZ.id][iTO.id] = interactionType;


		},

		isIntersectByBoundingBox: function (ibbTz, ibbTo) {
			if (ibbTz.high.x < ibbTo.low.x || ibbTz.high.y < ibbTo.low.y || ibbTz.high.z < ibbTo.low.z ||
                 ibbTo.high.x < ibbTz.low.x || ibbTo.high.y < ibbTz.low.y || ibbTo.high.z < ibbTz.low.z) {
				return -1;
			}
			return 0;
		},

		isIntersectByOrientedBoundingBox: function (iCornerPointsTZ, iCornerPointsTO) {
			var vecCornerPointsTZ = [];
			var vecCornerPointsT0 = [];

			for (var i = 0; i < 8; i++) { //DSMath.Point -> DSMath.Vector3D
				vecCornerPointsTZ.push(new DSMath.Vector3D(iCornerPointsTZ[i].x, iCornerPointsTZ[i].y, iCornerPointsTZ[i].z));
				vecCornerPointsT0.push(new DSMath.Vector3D(iCornerPointsTO[i].x, iCornerPointsTO[i].y, iCornerPointsTO[i].z));
			}

			var axesTz = [];
			var axesTo = [];

			for (var i = 1; i <= 3; i++) {
				axesTz.push(DSMath.Vector3D.sub(vecCornerPointsTZ[i], vecCornerPointsTZ[0]));
				axesTo.push(DSMath.Vector3D.sub(vecCornerPointsT0[i], vecCornerPointsT0[0]));
			}

			var interactionType = -1;
			for (var i = 0; i < 3; i++) {
				interactionType = this.projectionsAreIntersected(vecCornerPointsTZ, vecCornerPointsT0, axesTz[i], interactionType);
				if (interactionType < 0) {
					break;
				}
			}

			if (interactionType >= 0) {
				for (var i = 0; i < 3; i++) {
					interactionType = this.projectionsAreIntersected(vecCornerPointsTZ, vecCornerPointsT0, axesTo[i], interactionType);
					if (interactionType < 0) {
						break;
					}
				}
			}

			if (interactionType >= 0) {
				for (var i = 0; i < 3; i++) {
					for (var j = 0; j < 3; j++) {
						var axe = axesTz[i].clone().cross(axesTo[j]);
						interactionType = this.projectionsAreIntersected(vecCornerPointsTZ, vecCornerPointsT0, axe, interactionType);
						if (interactionType >= 0) {
							break;
						}
					}
				}
			}
			return interactionType;
		},

		projectionsAreIntersected: function (iVecCornerPointsTZ, iVecCornerPointsT0, axe, iInteractionType) {

			if (axe.isEqual(new DSMath.Vector3D(0, 0, 0), 0.000001)) {// if vector is null
				return iInteractionType;
			}
			var normalizedAxe = DSMath.normalize(axe);

			var tzMin = Number.MAX_VALUE;
			var tzMax = -Number.MAX_VALUE;
			var toMin = Number.MAX_VALUE;
			var toMax = -Number.MAX_VALUE;

			for (var i = 0; i < 8; i++) {
				var projTZ = iVecCornerPointsTZ[i].dot(normalizedAxe);
				var projTO = iVecCornerPointsT0[i].dot(normalizedAxe);
				tzMin = (projTZ < tzMin) ? projTZ : tzMin;
				tzMax = (projTZ > tzMax) ? projTZ : tzMax;
				toMin = (projTO < toMin) ? projTO : toMin;
				toMax = (projTO > toMax) ? projTO : toMax;
			}

			var interactionType;
			if (iInteractionType !== 0) {
				if (toMin < tzMin && toMax > tzMax && (iInteractionType === -1 || iInteractionType === 1)) {
					interactionType = 1;
				}
				else if (tzMin < toMin && tzMax > toMax && (iInteractionType === -1 || iInteractionType === 2)) {
					interactionType = 2;
				}
				else {
					interactionType = 0;
				}
			}
			else {
				interactionType = iInteractionType;
			}

			if (tzMax < toMin || tzMin > toMax) {
				return -1;
			}
			else {
				return interactionType;
			}
		},


		areTransfoEqual : function (t1, t2) {
			var coef1 = t1.getCoefficients();
			var coef2 = t2.getCoefficients();

			for (var i = 0; i < 12; ++i) {
				if (Math.abs(coef1[i] - coef2[i]) > 0.000001) {
					return true;
				}
			}
			return false;
		}

	});
	return StuTriggerZoneManager;
});

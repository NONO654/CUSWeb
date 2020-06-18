define('DS/CATCXPModel/extensions/CATEVirtualPathActor3DGeoVisu',
[
	'UWA/Core',
	'DS/Visualization/SceneGraphFactory',
	'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
	'DS/Visualization/ThreeJS_DS',
    'DS/Visualization/Node3D',
    'DS/Mesh/MeshUtils'
],

// Declaration
function (
    UWA,
	SceneGraphFactory,
	CATE3DActor3DGeoVisu,
	THREE,
    Node3D,
	Mesh
    ) {
	'use strict';

	var CATEVirtualPathActor3DGeoVisu = CATE3DActor3DGeoVisu.extend(
		{
		    init: function () {
		        this._parent();
		        this._pathNode = null;
		    },

		    destroy: function () {
		        this._parent();

		        if (this._pathNode) {
		            this._pathNode.removeChildren();
		            this._pathNode = null;
		        }
		    },

		    setReady: function () {
		        //Not used
		    },

		    isReady: function () {
		        return true;
		    },

		    _Fill: function (iNode3D) {
		        this._parent(iNode3D);
		        this._node3D = iNode3D;

		        var self = this;
		        this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'interpolationType.CHANGED', function () {
		            self.frameVisuChanges.push(self._RefreshPath);
		            self.RequestVisuRefresh();
		        });

		        // get dimension
		        this._pathNode = this._CreatePath();
				
		        iNode3D.addChild(this._pathNode);
		    },

		    GetLocalNodes: function () {
		        return this._pathNode;
		    },

		    _RefreshPath: function(){
		        if (UWA.is(this._pathNode)) {
		            this._node3D.removeChild(this._pathNode);
		        }
		        this._pathNode = this._CreatePath();
		        this._node3D.addChild(this._pathNode);
		    },

		    _CreatePath: function(){
		        var pathNode;
		        var expObject = this.QueryInterface('CATI3DExperienceObject');
		        var pointslist = expObject.GetValueByName('pointslist');
		        var posArray = [];

		        if (expObject.GetValueByName('interpolationType') === 0) { //linear interpolation
		            posArray = this._GetLinearPathValues(pointslist);
		        }
		        else { //cubic interpolation
		            posArray = this._GetCubicPathValues(pointslist);
		        }

		        /********D****E****B****U****G***************/
		        //var blobMesh = this._GetContourBlobMesh(pointslist);
		        //var blobNode = new Node3D();
                /*//////////////////////////////////////////*/

		        if (posArray.length !== 0) {
		            var mat = new THREE.MeshLambertMaterial({
		                color: 0xFFFFFF
		            });

		            pathNode = SceneGraphFactory.createLineNode({
		                points: posArray,
		                material: mat,
		                color: new Mesh.Color(0.5, 0.5, 0.5, 1.0),
		                layerNb: 1
		            });

		            // set name
		            pathNode.setName(expObject.GetValueByName('_varName'));
		            pathNode.pickParent = true;
		        } else {
		            pathNode = new Node3D();
		        }

		        return pathNode;
		    },

		    _GetLinearPathValues: function (pointslist) {
		        var posArray = [];
		        for (var i = 0; i < pointslist.length; i++) {
		            var posPoint = pointslist[i].QueryInterface('CATI3DExperienceObject').GetValueByName('position');
		            posArray.push(new THREE.Vector3(posPoint[0], posPoint[1], posPoint[2]));
		        }
		        return posArray;
		    },

		    _GetCubicPathValues: function (pointslist) {
		        //works with VIAEIxpCubicPath, warning : missing length computation by integral computation
		        //const nbStep = 50*pointslist.length; //checker nbStep
		        //var step = 1 / nbStep;

		        //for (var i = 0; i < nbStep + 1; ++i) {
		        //    var pos = new THREE.Vector3();
		        //    this.QueryInterface('VIAIIxpVirtualPath').GetValue(i * step, undefined, pos);
		        //    posArray.push(pos);
		        //}

		        var posArray = [];
		        var posPoint = pointslist[0].QueryInterface('CATI3DExperienceObject').GetValueByName('position');
		        var tangent = this._getTangentFromPoint("LEFT", pointslist[0], pointslist);//this._computeDefaultTangent(pointslist[0], pointslist);

		        for (var i = 0; i < pointslist.length - 1; ++i) {
		            var posPoint2 = pointslist[i + 1].QueryInterface('CATI3DExperienceObject').GetValueByName('position');
		            var tangent2 = this._getTangentFromPoint("RIGHT", pointslist[i + 1], pointslist);//this._computeDefaultTangent(pointslist[i + 1], pointslist, iNode3D);

		            var curve = new THREE.CubicBezierCurve3(
                        new THREE.Vector3(posPoint[0], posPoint[1], posPoint[2]),
                        new THREE.Vector3(posPoint[0] + tangent.x, posPoint[1] + tangent.y, posPoint[2] + tangent.z),
                        new THREE.Vector3(posPoint2[0] + tangent2.x, posPoint2[1] + tangent2.y, posPoint2[2] + tangent2.z),
                        new THREE.Vector3(posPoint2[0], posPoint2[1], posPoint2[2])
                    );

		            posArray = posArray.concat(curve.getPoints(50));

		            posPoint = posPoint2.slice();
		            tangent = this._getTangentFromPoint("LEFT", pointslist[i + 1], pointslist);;
		        }

		        return posArray;
		    },

			_getTangentFromPoint: function (iTangentSide, iPoint, pointsList) {
			    const epsilon = 0.0000000001; //check epsilon value
			    var tangent = new DSMath.Vector3D();
			    var isPathReversed = this.QueryInterface('CATI3DExperienceObject').GetValueByName("reversedDirection");
			    if (!isPathReversed) {
			        if (iTangentSide === "RIGHT") {
			            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("rightTangent"));
			        }
			        else if (iTangentSide === "LEFT") {
			            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("leftTangent"));
			        }
			    }
			    else {
			        if (iTangentSide === "RIGHT") {
			            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("leftTangent"));
			        }
			        else if (iTangentSide === "LEFT") {
			            tangent.setFromArray(iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("rightTangent"));
			        }
			    }

			    if (tangent.norm() < epsilon) {
			        tangent = this._computeDefaultTangent(iTangentSide, iPoint, pointsList);        //VIAIxpVirtualPointOfPath_PointOfPathImpl.cpp   l.961
			    }

			    return tangent;
			},

			_computeDefaultTangent: function (iTangentSide, iPoint, pointsList) {
			    const AFTER_BEFORE_VECTOR_FACTOR = 1/6;

			    var isPathReversed = this.QueryInterface('CATI3DExperienceObject').GetValueByName("reversedDirection");
			    var modelOrderIndex = iPoint.QueryInterface('CATI3DExperienceObject').GetValueByName("index");
			    var currentIndex = (!isPathReversed) ? modelOrderIndex : (nbPathPoint - modelOrderIndex + 1);

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

			    if (iTangentSide === "RIGHT") {
			        beforeAfterVector.x = -beforeAfterVector.x;
			        beforeAfterVector.y = -beforeAfterVector.y;
			        beforeAfterVector.z = -beforeAfterVector.z;
			    }
			    beforeAfterVector = beforeAfterVector.multiplyScalar(AFTER_BEFORE_VECTOR_FACTOR);
			    return beforeAfterVector;
			},

			_drawLine: function (posArray, color, iNode3D) {
			    var mat = new THREE.MeshLambertMaterial({
			        color: color
			    });

			    var node = SceneGraphFactory.createLineNode({
			        points: posArray,
			        material: mat,
			        color: new Mesh.Color(0.1, 0.0, 1.0, 1.0),
			        layerNb: 1
			    });

			    iNode3D.addChild(node);
			},

			_GetContourBlobMesh: function () {
			    posArray = _GetCubicPathValues(pointsList);
			    var geom = new THREE.ParametricGeometry(function (u, v) {
			        var value = posArray[Math.round(posArray.length * u)];
			        this.useValue = value + v;
			        //value.x = 
			    }, 100, 100);
			    var mat = new THREE.MeshPhongMaterial({ color: 0xcc3333a, side: THREE.DoubleSide, shading: THREE.FlatShading });
			    var mesh = new THREE.Mesh(geom, mat);
			    return mesh;
			},

			_computeDefaultTangentFromPointPositions: function (index, iPoint) {
			    const AFTER_BEFORE_VECTOR_FACTOR = 1 / 6;
			    var currentIndex = (!isPathReversed) ? modelOrderIndex : (nbPathPoint - modelOrderIndex + 1);

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

			    if (iTangentSide === "RIGHT") {
			        beforeAfterVector.x = -beforeAfterVector.x;
			        beforeAfterVector.y = -beforeAfterVector.y;
			        beforeAfterVector.z = -beforeAfterVector.z;
			    }
			    beforeAfterVector = beforeAfterVector.multiplyScalar(AFTER_BEFORE_VECTOR_FACTOR);
			    return beforeAfterVector;
			}
		}
	);

	return CATEVirtualPathActor3DGeoVisu;
}
);


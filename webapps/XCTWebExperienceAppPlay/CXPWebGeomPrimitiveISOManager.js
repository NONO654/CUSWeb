define('DS/XCTWebExperienceAppPlay/CXPWebGeomPrimitiveISOManager',
// dependencies
[
    'UWA/Core',
    'DS/StuCore/StuContext',
	'DS/Visualization/SceneGraphFactory',
	'DS/Visualization/ThreeJS_DS',
	'DS/Visualization/Node3D',
	'DS/Mesh/Mesh',
	'DS/SceneGraphNodes/ArrowNode',
	'DS/SceneGraphNodes/FixedSizeArrowNode',
	'DS/SceneGraphOverrides/SceneGraphOverrideSet',
	'DS/Visualization/PathElement',
	'DS/SceneGraphNodes/FixedSizeNode3D',
	'MathematicsES/MathsDef'
],
function (UWA, STU, SceneGraphFactory, THREE, Node3D, Mesh, ArrowNode, FixedSizeArrowNode, SceneGraphOverrideSet, PathElement, FixedSizeNode3D, DSMath) {

    'use strict';

    var StuGeomPrimitiveISOManagerClass = UWA.Class.extend({
        init: function () {
            this._GeomPrimitiveRootNode = new Node3D();
            this._GeomPrimitiveRootNode.pickable = false;
            this._sceneGraphOS = new SceneGraphOverrideSet(this._GeomPrimitiveRootNode);
            this._primitiveNodes = {};
            this._uIDNode = 0;
        },

        deleteAll: function () {
            this._sceneGraphOS.deleteOverrides(this._sceneGraphOS.getOverrides());
            this._GeomPrimitiveRootNode.removeChildren();
            for (var iID in this._primitiveNodes) {
                if (this._primitiveNodes.hasOwnProperty(iID)) {
                    delete this._primitiveNodes[iID];
                }
            }
            if (this._viewer) {
                this._viewer.render();
            }
        },

        setViewer: function (iViewer) {
            if (this._viewer) {
                this._viewer.removeNode(this._GeomPrimitiveRootNode);
                this._viewer.getSceneGraphOverrideSetManager().removeSceneGraphOverrideSet(this._sceneGraphOS);
            }
            this._viewer = iViewer;
            iViewer.addNode(this._GeomPrimitiveRootNode);
            this._viewer.getSceneGraphOverrideSetManager().pushSceneGraphOverrideSet(this._sceneGraphOS);
        },

        _createNewRep: function (iPrimitiveRep, iTransform, iParams) {
            var node;
            if (iParams.screenSize) {
                node = new FixedSizeNode3D({ ratio: STU.RenderManager.getInstance().getPixelDensity() });
            }
            else {
                node = new Node3D();
            }

            this._GeomPrimitiveRootNode.addChild(node);
            if (iTransform instanceof DSMath.Transformation) {
                var transformArray = iTransform.getArray();
                var mat = new THREE.Matrix4(transformArray[0], transformArray[3], transformArray[6], transformArray[9],
											transformArray[1], transformArray[4], transformArray[7], transformArray[10],
											transformArray[2], transformArray[5], transformArray[8], transformArray[11],
											0.0, 0.0, 0.0, 1.0);

                node.setMatrix(mat);
            }
            else {
                node.setMatrix(iTransform);
            }
            node.addChild(iPrimitiveRep);



            var nodeID = this._uIDNode;
            this._primitiveNodes[nodeID] = {
                node: node
            };
            this._uIDNode++;

            var opacity = UWA.is(iParams.alpha) ? iParams.alpha / 255 : 1;
            var color = iParams.color ? 'rgb(' + iParams.color.r + ',' + iParams.color.g + ',' + iParams.color.b + ')' : 'rgb(' + 150 + ',' + 150 + ',' + 150 + ')';
            var path = new PathElement([this._GeomPrimitiveRootNode, node]);
            var override = this._sceneGraphOS.createOverride(path);
            override.setOpacity(opacity, false);
            override.setColor(color, false);

            if (this._viewer) {
                this._viewer.render();
            }
            return nodeID;
        },

        createBox: function (iParams) {
            //iParams.size = 1500;

            var closed = UWA.is(iParams.closed) ? iParams.closed : false;
            var centered = Boolean(iParams.centered);

            var cornerPoint, firstAxis, secondAxis, thirdAxis;

            if (iParams.box) {
                cornerPoint = new THREE.Vector3(iParams.box.low.x, iParams.box.low.y, iParams.box.low.z);
                firstAxis = new THREE.Vector3(iParams.box.high.x - iParams.box.low.x, 0.0, 0.0);
                secondAxis = new THREE.Vector3(0.0, iParams.box.high.y - iParams.box.low.y, 0.0);
                thirdAxis = new THREE.Vector3(0.0, 0.0, iParams.box.high.z - iParams.box.low.z);
            }
            else {
                var sizeX, sizeY, sizeZ;
                if (typeof iParams.size === 'number') {
                    sizeX = iParams.size;
                    sizeY = iParams.size;
                    sizeZ = iParams.size;
                }
                else {
                    sizeX = iParams.size.x;
                    sizeY = iParams.size.y;
                    sizeZ = iParams.size.z;
                }

                if (centered) {
                    cornerPoint = new THREE.Vector3(iParams.position.vector.x - sizeX / 2, iParams.position.vector.y - sizeY / 2, iParams.position.vector.z - sizeZ / 2);
                    firstAxis = new THREE.Vector3(sizeX / 2, 0.0, 0.0);
                    secondAxis = new THREE.Vector3(0.0, sizeY / 2, 0.0);
                    thirdAxis = new THREE.Vector3(0.0, 0.0, sizeZ / 2);
                }
                else {
                    cornerPoint = new THREE.Vector3(iParams.position.vector.x, iParams.position.vector.y, iParams.position.vector.z);
                    firstAxis = new THREE.Vector3(sizeX, 0.0, 0.0);
                    secondAxis = new THREE.Vector3(0.0, sizeY, 0.0);
                    thirdAxis = new THREE.Vector3(0.0, 0.0, sizeZ);
                }
            }

            var cuboid = SceneGraphFactory.createCuboidNode({
                cornerPoint: cornerPoint,
                firstAxis: firstAxis,
                secondAxis: secondAxis,
                thirdAxis: thirdAxis,
                fill: closed
            });
            return this._createNewRep(cuboid, iParams.position, iParams);
        },

        createSphere: function (iParams) {
            var radius = iParams.radius;

            var spheroid = SceneGraphFactory.createSphereNode({
                radius: radius
            });
            return this._createNewRep(spheroid, iParams.position, iParams);
        },

        createPoint: function (iParams) {
            iParams.screenSize = true;
            iParams.radius = iParams.size;
            return this.createSphere(iParams);
        },

        createVector: function (iParams) {
            var vector = this._CreateLineOrVector(iParams, true);
            return this._createNewRep(vector.rep, vector.transform, iParams);
        },

        createLine: function (iParams) {
            var line = this._CreateLineOrVector(iParams, false);
            return this._createNewRep(line.rep, line.transform, iParams);
        },

        _CreateLineOrVector: function (iParams, isVector) {
            var length;
            var _direction = new THREE.Vector3();
            var width = iParams.width;

            if ((iParams.startPoint) && (iParams.endPoint)) {
                var direction = iParams.endPoint.clone().addScaledVector(iParams.startPoint, -1);
                _direction.set(direction.x, direction.y, direction.z);
                length = direction.clone().norm();
            }
            else {
                length = iParams.length;
                _direction.set(iParams.direction.x, iParams.direction.y, iParams.direction.z);
            }

            var _startPoint = new THREE.Vector3();
            _startPoint.set(iParams.startPoint.x, iParams.startPoint.y, iParams.startPoint.z);
            var width = width ? width : 0.01 * length;

            var head;
            if (isVector) {
                var headWidth = iParams.headWidth;
                var headLength = iParams.headLength;

                var headLength = headLength ? headLength : 0.1 * length;
                var headWidth = headWidth ? headWidth : 3 * width;
                length = length - headLength;

                head = SceneGraphFactory.createConeNode({
                    bottomCenterPoint: new THREE.Vector3(0.0, 0.0, length),
                    topCenterPoint: new THREE.Vector3(0.0, 0.0, length + headLength),
                    topRadius: 0,
                    bottomRadius: headWidth
                });
            }

            var line = SceneGraphFactory.createCylinderNode({
                bottomCenterPoint: new THREE.Vector3(0.0, 0.0, 0),
                topCenterPoint: new THREE.Vector3(0.0, 0.0, length),
                radius: width
            });

            if (head) {
                line.addChild(head);
            }

            var up = new THREE.Vector3(0, 0, 1);
            up.cross(_direction.clone());
            if (up.length() === 0) {
                up.set(0, 1, 0);
                up.cross(_direction.clone());
            }

            var matrix = new THREE.Matrix4();
            matrix.lookAt(_direction, new THREE.Vector3(), up);
            matrix.setPosition(_startPoint);
            return { rep: line, transform: matrix };
        },

        createAxis: function (iParams) {
            var size = iParams.size;

            var params = {
                startPoint: new DSMath.Vector3D(0, 0, 0),
                length: size
            };

            params.direction = new DSMath.Vector3D(1, 0, 0);
            var vectorX = this._CreateLineOrVector(params, true);

            params.direction = new DSMath.Vector3D(0, 1, 0);
            var vectorY = this._CreateLineOrVector(params, true);

            params.direction = new DSMath.Vector3D(0, 0, 1);
            var vectorZ = this._CreateLineOrVector(params, true);

            var axis = new Node3D();
            axis.addChild(vectorX.rep);
            axis.addChild(vectorY.rep);
            axis.addChild(vectorZ.rep);

            vectorX.rep.setMatrix(vectorX.transform);
            vectorY.rep.setMatrix(vectorY.transform);
            vectorZ.rep.setMatrix(vectorZ.transform);

            return this._createNewRep(axis, iParams.position, iParams);
        },

        setColor: function (iID, iRed, iGreen, iBlue, iAlpha) {
            var primitiveNode = this._primitiveNodes[iID].node;
            if (!primitiveNode) {
                return;
            }

            var opacity = UWA.is(iAlpha) ? iAlpha / 255 : 1;
            var red = UWA.is(iRed) ? iRed : 150;
            var green = UWA.is(iGreen) ? iGreen : 150;
            var blue = UWA.is(iBlue) ? iBlue : 150;
            var color = 'rgb(' + red + ',' + green + ',' + blue + ')';
            var path = new PathElement([this._GeomPrimitiveRootNode, primitiveNode]);
            var override = this._sceneGraphOS.getUniqueOverrideFromPathElement(path);
            override.setOpacity(opacity, false);
            override.setColor(color, false);
            if (this._viewer) {
                this._viewer.render();
            }
        },

        setPosition: function (iID, iTransform) {
            var primitiveNode = this._primitiveNodes[iID].node;
            if (!primitiveNode) {
                return;
            }

            if (iTransform instanceof DSMath.Transformation) {
                var array = iTransform.getArray();

                var mat = new THREE.Matrix4(array[0], array[3], array[6], array[9],
											array[1], array[4], array[7], array[10],
											array[2], array[5], array[8], array[11],
											0.0, 0.0, 0.0, 1.0);

                primitiveNode.setMatrix(mat);
            }
        },
        ExternalizeSharedTransfo: function (iPos) {
            this._sharedTransfo = iPos;
        },
        CleanSharedTransfo: function (iPos) {
            return iPos;
        },
        SetPosFromSharedTransfo: function (iID) {
            if (this._primitiveNodes.hasOwnProperty(iID)) {
                var myNode = this._primitiveNodes[iID].node;
                if (!myNode) {
                }
                else {
                    var myExtPos = this._sharedTransfo;
                    if (!myExtPos) {
                    }
                    else {
                        if (myExtPos[12] > 0.0) {
                            var mat = new THREE.Matrix4(myExtPos[0], myExtPos[3], myExtPos[6], myExtPos[9],
											myExtPos[1], myExtPos[4], myExtPos[7], myExtPos[10],
											myExtPos[2], myExtPos[5], myExtPos[8], myExtPos[11],
											0.0, 0.0, 0.0, 1.0);

                            myNode.setMatrix(mat);
                        }
                    }
                }
            }
        },

        delete: function (iID) {
            var primitiveNode = this._primitiveNodes[iID].node;
            if (!primitiveNode) {
                return;
            }

            var path = new PathElement([this._GeomPrimitiveRootNode, primitiveNode]);
            var override = this._sceneGraphOS.getUniqueOverrideFromPathElement(path);
            this._sceneGraphOS.deleteOverride(override);
            this._GeomPrimitiveRootNode.removeChild(primitiveNode);
            delete this._primitiveNodes[iID];
            if (this._viewer) {
                this._viewer.render();
            }
        }
    });

    var StuGeomPrimitiveISOManager = StuGeomPrimitiveISOManagerClass.singleton({
    });

    StuGeomPrimitiveISOManager.init();

    StuGeomPrimitiveISOManager.deleteAll();

    return StuGeomPrimitiveISOManager;
});





/**
 * CATECameraActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECameraActor3DGeoVisu
 * @description Implements : 
 * {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECameraActor3DGeoVisu',
[
	'UWA/Core',
	'DS/Visualization/SceneGraphFactory',
    'DS/Core/Events',
	'DS/Visualization/Node3D',
	'DS/Mesh/MeshUtils',
	'DS/Visualization/ThreeJS_DS',
    'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
	'DS/SceneGraphNodes/CSS3DNode'
],

// Declaration
function (
    UWA,
	SceneGraphFactory,
    WUXEvent,
	Node3D, Mesh, THREE,
	CATE3DActor3DGeoVisu,
	CSS3DNode
    ) {
    'use strict';

    var CATECameraActor3DGeoVisu = CATE3DActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATECameraActor3DGeoVisu.prototype **/
    {
        init: function () {
            this._parent();
            this._primNode = null;
        },

        destroy: function () {
        	this._parent();
        	if (this._primNode) {
        		this._primNode.removeChildren();
        		this._primNode = null;
        	}
        },

        _Fill: function (iNode3D) {
            this._parent(iNode3D);

            var self = this;
            var expObject = this.QueryInterface('CATI3DExperienceObject');
            this.listenTo(expObject, 'aspectRatio.CHANGED', function () {
            	self.frameVisuChanges.push(self._refreshCamera);
            	self.RequestVisuRefresh();
            });
            this.listenTo(expObject, 'nearClip.CHANGED', function () {
            	self.frameVisuChanges.push(self._refreshCamera);
            	self.RequestVisuRefresh();
            });
            this.listenTo(expObject, 'farClip.CHANGED', function () {
            	self.frameVisuChanges.push(self._refreshCamera);
            	self.RequestVisuRefresh();
            });
            this.listenTo(expObject, 'viewAngle.CHANGED', function () {
            	self.frameVisuChanges.push(self._refreshCamera);
            	self.RequestVisuRefresh();
            });

            iNode3D.setName(expObject.GetValueByName('_varName'));
            self.frameVisuChanges.push(self._refreshCamera);
            self.RequestVisuRefresh();
            this.setReady(true);
        },

        _createUILayer: function () {
            var myDiv2 = UWA.createElement('div');
            myDiv2.id = 'myDiv2';
            myDiv2.style.width = (this.farHeight * 2) + 'px';
            myDiv2.style.height = (this.farWidth * 2) + 'px';
            myDiv2.style.backgroundColor = 'rgba(1,1,1,0.1)';

            var editor = UWA.createElement('sbx-uiactor-editor');
            editor.options = {
            	max3DWidth: (this.farHeight * 2),
            	max3DHeight: (this.farWidth * 2)
            };
            myDiv2.appendChild(editor);
            var canvasNode = new CSS3DNode(myDiv2, 1);
            var mat = canvasNode.getMatrix();
            mat.setPosition(new THREE.Vector3(-this.farLength, 0, 0));
            mat.rotateY(Math.PI / 2);
            canvasNode.setMatrix(mat);
            canvasNode.setPickability(false);
            return canvasNode;
        },

        _createFrustrum: function () {
            var expObj = this.QueryInterface('CATI3DExperienceObject');
            var nearclip = expObj.GetValueByName('nearClip');
            var farclip = expObj.GetValueByName('farClip');
            var fov = expObj.GetValueByName('viewAngle') * 2;
            var halFovRad = (fov * (Math.PI / 180)) / 2;

            var aspect = expObj.GetValueByName('aspectRatio');
            var mat = new THREE.LineBasicMaterial({
                color: 0x002266,
                dashSize: 3,
                gapSize: 2,
                depthTest: false
            });
            mat.force = true;

            var farLength, nearLength, farWidth, nearWidth, nearHeight, farHeight, node;

            farLength = Math.min(200, farclip - 1);
            var farDistance = farLength * Math.tan(halFovRad);
            farHeight = farDistance;
            farWidth = farDistance * aspect;

            nearLength = Math.min(50, nearclip);
            var nearDistance = nearLength * Math.tan(halFovRad);

            nearHeight = nearDistance;
            nearWidth = nearDistance * aspect;


            this.farLength = farLength;
            this.farWidth = farWidth;
            this.farHeight = farHeight;
            this.nearLength = nearLength;
            this.nearWidth = nearWidth;
            this.nearHeight = nearHeight;

            var points = [
				new THREE.Vector3(-farLength, -farWidth, farHeight),		// vertex 0
				new THREE.Vector3(-nearLength, -nearWidth, nearHeight),	// vertex 1
				new THREE.Vector3(-nearLength, nearWidth, nearHeight),	// vertex 2
				new THREE.Vector3(-farLength, farWidth, farHeight),		// vertex 3
				new THREE.Vector3(-farLength, farWidth, -farHeight),	// vertex 4
				new THREE.Vector3(-nearLength, nearWidth, -nearHeight),	// vertex 5
				new THREE.Vector3(-nearLength, -nearWidth, -nearHeight),	// vertex 6
				new THREE.Vector3(-farLength, -farWidth, -farHeight)	// vertex 7
            ];
            var idx = [[0, 3, 4, 7, 0], [1, 2, 5, 6, 1], [0, 1], [7, 6], [3, 2], [4, 5]];
            var node = new Node3D();
            for (var i = 0; i < idx.length; ++i) {
                var jdx = idx[i];
                var face = jdx.map(function (it) {
                    return points[it];
                });
                var lineRep = SceneGraphFactory.createLineNode({
                    points: face, material: mat
                });
                node.addChild(lineRep);
            }
            return node;
        },

        _refreshCamera: function () {
            if (this._primNode) {
                this._node3D.removeChild(this._primNode);
            }
            this._primNode = this._createFrustrum();
            this._node3D.addChild(this._primNode);
        },

        /** 
        * @public
        */
        GetLocalNodes: function () {
            return this._primNode;
        }
    });

    return CATECameraActor3DGeoVisu;
});

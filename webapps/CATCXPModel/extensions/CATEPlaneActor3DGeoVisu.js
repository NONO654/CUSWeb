/**
 * CATEPlaneActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEPlaneActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEPlaneActor3DGeoVisu',
[
	'UWA/Core',
    'DS/Visualization/SceneGraphFactory',
    'DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu',
    'DS/Visualization/ThreeJS_DS',
    'DS/Visualization/Node3D',
    'DS/Mesh/MeshUtils'
],

// Declaration
function (
    UWA,
    SceneGraphFactory,
    CATEPrimitiveActor3DGeoVisu,
    THREE,
    Node3D,
    Mesh
    ) {
    'use strict';

    var CATEPlaneActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEPlaneActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
		    this._planeNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._planeNode) {
				this._planeNode.removeChildren();
				this._planeNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create plane
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var width = expObject.GetValueByName('width');
		    var length = expObject.GetValueByName('length');
		    var mat = this._createMaterial();
		    this._planeNode = this._createPlane(width, length, mat);
		    this._planeNode.setMaterial(mat);

            // set name
		    this._planeNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'width.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshPlane);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'length.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshPlane);
		        self.RequestVisuRefresh();
		    });
		    iNode3D.addChild(this._planeNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._planeNode;
		},

		_createPlane: function (iWidth, iLength, mat) {

		    var plane = SceneGraphFactory.createRectangleNode({
		        width: iWidth,
		        height: iLength,
		        fill: true,
		        color: new Mesh.Color(0.5, 0.5, 0.5, 1.0),
                material: mat
		    });
		    var matrix = plane.getMatrix();
		    matrix.setPosition({ x: -iWidth / 2, y: -iLength / 2, z: 0 })
		    plane.setMatrix(matrix);
		    plane.pickParent = true;
		    return plane;
		},

		_refreshPlane: function () {
		    if (UWA.is(this._planeNode)) {
		        this._node3D.removeChild(this._planeNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var width = expObject.GetValueByName('width');
		    var length = expObject.GetValueByName('length');
		    var mat = this._createMaterial();
		    this._planeNode = this._createPlane(width, length, mat);
		    this._planeNode.setMaterial(mat);
		    this._planeNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._planeNode);
		},

		_createMaterial: function ()
		{
		    var mat = new THREE.MeshPhongMaterial({
		        //clearCoat: 1,
		        //clearCoatSpecularColor: new THREE.Color(0xffffff),
		        //metalness: 1,
		        //shininess: 0.5,
                //metal: true,
		        //force: true,
		        //needsUpdate: true,
		        //reflectionCoef: 1,
		        //specular: new THREE.Color(0xffffff),
		        //ambient: new THREE.Color(0x111111)
		    });
		    return mat;
		}
	});

    return CATEPlaneActor3DGeoVisu;
});

/**
 * CATECylinderActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECylinderActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECylinderActor3DGeoVisu',
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

    var CATECylinderActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATECylinderActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
		    this._cylinderNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._cylinderNode) {
				this._cylinderNode.removeChildren();
				this._cylinderNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create cylinder
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._cylinderNode = this._createCylinder(radius, height);

            // set name
		    this._cylinderNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'radius.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCylinder);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'height.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCylinder);
		        self.RequestVisuRefresh();
		    });

		    iNode3D.addChild(this._cylinderNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._cylinderNode;
		},

		_createCylinder: function (iRadius, iHeight) {
		    var cylinder = SceneGraphFactory.createCylinderNode({
		        bottomCenterPoint: new THREE.Vector3(0.0, 0.0, -iHeight/2),
		        topCenterPoint: new THREE.Vector3(0.0, 0.0, iHeight/2),
		        radius: iRadius,
		        sag: 40,
		        color: new Mesh.Color(0.5, 0.5, 0.5, 1.0)
		    });
		    cylinder.pickParent = true;
		    return cylinder;
		},

		_refreshCylinder: function () {
		    if (UWA.is(this._cylinderNode)) {
		        this._node3D.removeChild(this._cylinderNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._cylinderNode = this._createCylinder(radius, height);
		    this._cylinderNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._cylinderNode);
		}
	});

    return CATECylinderActor3DGeoVisu;
});

/**
 * CATECapsuleActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECapsuleActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECapsuleActor3DGeoVisu',
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

    var CATECapsuleActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATECapsuleActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
			this._capsuleNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._capsuleNode) {
			    this._capsuleNode.removeChildren();
			    this._capsuleNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    // create capsule
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._capsuleNode = this._createCapsule(radius, height);

            // set name
		    this._capsuleNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'radius.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCapsule);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'height.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCapsule);
		        self.RequestVisuRefresh();
		    });

		    iNode3D.addChild(this._capsuleNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._capsuleNode;
		},

		_createCapsule: function (iRadius, iHeight) {
		    var capsule = new Node3D();

		    var cylinder = SceneGraphFactory.createCylinderNode({
		        bottomCenterPoint: new THREE.Vector3(0.0, 0.0, -iHeight / 2 + iRadius),
		        topCenterPoint: new THREE.Vector3(0.0, 0.0, iHeight/2 - iRadius),
		        radius: iRadius,
		        sag: 40,
		        color: new Mesh.Color(0.5, 0.5, 0.5, 1.0)
		    });

		    var sphere1 = SceneGraphFactory.createSphereNode({
		        matrix: new THREE.Matrix4().setPosition(new THREE.Vector3(0, 0, iHeight/2 - iRadius)),
		        radius: iRadius
		    });

		    var sphere2 = SceneGraphFactory.createSphereNode({
		        matrix: new THREE.Matrix4().setPosition(new THREE.Vector3(0, 0, -iHeight / 2 + iRadius)),
		        radius: iRadius
		    });

		    capsule.addChild(cylinder);
            capsule.addChild(sphere1);
            capsule.addChild(sphere2);
            capsule.pickParent = true;
            
            return capsule;
		},

		_refreshCapsule: function () {
		    if (UWA.is(this._capsuleNode)) {
		        this._node3D.removeChild(this._capsuleNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._capsuleNode = this._createCapsule(radius, height);
		    this._capsuleNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._capsuleNode);
		}
	});

    return CATECapsuleActor3DGeoVisu;
});

/**
 * CATEConeActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEConeActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEConeActor3DGeoVisu',
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

    var CATEConeActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEConeActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
		    this._coneNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._coneNode) {
				this._coneNode.removeChildren();
				this._coneNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create cone
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._coneNode = this._createCone(radius, height);

            // set name
		    this._coneNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'radius.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCone);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'height.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCone);
		        self.RequestVisuRefresh();
		    });
		    iNode3D.addChild(this._coneNode);
		},

		/** 
		* @public
		*/
		GetLocalNodes: function () {
		    return this._coneNode;
		},

		_createCone: function (iRadius, iHeight) {
		    var cone = SceneGraphFactory.createConeNode({
		        bottomCenterPoint: new THREE.Vector3(0.0, 0.0, 0.0),
		        topCenterPoint: new THREE.Vector3(0.0, 0.0, iHeight),
		        topRadius: 0,
		        bottomRadius: iRadius,
		        sag: 100,
		        color: new Mesh.Color(0.5, 0.5, 0.5, 1.0)
		    });
		    cone.pickParent = true;
		    return cone;
		},

		_refreshCone: function () {
		    if (UWA.is(this._coneNode)) {
		        this._node3D.removeChild(this._coneNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    var height = expObject.GetValueByName('height');
		    this._coneNode = this._createCone(radius, height);
		    this._coneNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._coneNode);
		}
	});

    return CATEConeActor3DGeoVisu;
}
);

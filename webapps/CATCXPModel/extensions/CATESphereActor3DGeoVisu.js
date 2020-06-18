/**
 * CATESphereActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATESphereActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATESphereActor3DGeoVisu',
[
	'UWA/Core',
    'DS/Visualization/SceneGraphFactory',
    'DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu',
    'DS/Visualization/ThreeJS_DS'
],

// Declaration
function (
    UWA,
    SceneGraphFactory,
    CATEPrimitiveActor3DGeoVisu,
    THREE
    ) {
    'use strict';

    var CATESphereActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATESphereActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
		    this._sphereNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._sphereNode) {
				this._sphereNode.removeChildren();
				this._sphereNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create sphere
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    this._sphereNode = this._createSpheroid(radius);

            // set name
		    this._sphereNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'radius.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshSphere);
		        self.RequestVisuRefresh();
		    });

		    iNode3D.addChild(this._sphereNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._sphereNode;
		},

		_createSpheroid: function (iRadius) {
		    var m = new THREE.Matrix4();
		    var spheroid = SceneGraphFactory.createSphereNode({
		        matrix: m,
		        radius: iRadius
		    });
		    spheroid.pickParent = true;
		    return spheroid;
		},

		_refreshSphere: function () {
		    if (UWA.is(this._sphereNode)) {
		        this._node3D.removeChild(this._sphereNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var radius = expObject.GetValueByName('radius');
		    this._sphereNode = this._createSpheroid(radius);
		    this._sphereNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._sphereNode);
		}

	});

    return CATESphereActor3DGeoVisu;
});

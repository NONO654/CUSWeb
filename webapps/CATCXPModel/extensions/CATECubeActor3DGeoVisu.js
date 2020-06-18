/**
 * CATECubeActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECubeActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECubeActor3DGeoVisu',
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

    var CATECubeActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATECubeActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
		    this._cubeNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._cubeNode) {
				this._cubeNode.removeChildren();
				this._cubeNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create cuboid
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var length = expObject.GetValueByName('length');
		    var height = expObject.GetValueByName('height');
		    var width = expObject.GetValueByName('width');
		    this._cubeNode = this._createCuboid(length, width, height);

            // set name
		    this._cubeNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;
		    this.listenTo(expObject, 'length.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCube);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'height.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCube);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'width.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshCube);
		        self.RequestVisuRefresh();
		    });
		    iNode3D.addChild(this._cubeNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._cubeNode;
		},

		_createCuboid: function (iLength, iWidth, iHeight) {
			var length = Math.abs(iLength);
			var width = Math.abs(iWidth);
			var height = Math.abs(iHeight);
			var cuboid  = SceneGraphFactory.createCuboidNode({
				cornerPoint: new THREE.Vector3(-length / 2, -width / 2, -height / 2),
				firstAxis: new THREE.Vector3(length, 0.0, 0.0),
				secondAxis: new THREE.Vector3(0.0, width, 0.0),
				thirdAxis: new THREE.Vector3(0.0, 0.0, height)
			});
			cuboid.pickParent = true;
			return cuboid;
		},

		_refreshCube: function () {
		    if (UWA.is(this._cubeNode)) {
		        this._node3D.removeChild(this._cubeNode);
		        this._cubeNode.removeChildren();
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var length = expObject.GetValueByName('length');
		    var height = expObject.GetValueByName('height');
		    var width = expObject.GetValueByName('width');
		    this._cubeNode = this._createCuboid(length, width, height);
		    this._cubeNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._cubeNode);
        }

	});

    return CATECubeActor3DGeoVisu;
});

/**
 * CATEArrowActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEArrowActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEArrowActor3DGeoVisu',
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

    var CATEArrowActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEArrowActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
			this._arrowNode = null;
		},

		destroy: function () {
		    this._parent();
			if (this._arrowNode) {
				this._arrowNode.removeChildren();
				this._arrowNode = null;
			}
		},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);

		    // create arrow
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var length = expObject.GetValueByName('length');
		    var width = expObject.GetValueByName('width');
		    var headLength = expObject.GetValueByName('headLength');
		    var headWidth = expObject.GetValueByName('headWidth');
		    this._arrowNode = this._createArrow(length, width, headLength, headWidth);

            // set name
		    this._arrowNode.setName(expObject.GetValueByName('_varName'));

		    // callbacks to refresh visu
		    var self = this;

		    this.listenTo(expObject, 'length.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshArrow);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'width.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshArrow);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'headLength.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshArrow);
		        self.RequestVisuRefresh();
		    });
		    this.listenTo(expObject, 'headWidth.CHANGED', function () {
		        self.frameVisuChanges.push(self._refreshArrow);
		        self.RequestVisuRefresh();
		    });
		    iNode3D.addChild(this._arrowNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
		    return this._arrowNode;
		},

		_createArrow: function (iLength, iWidth, iHeadLength, iHeadWidth) {
		    var arrow = new Node3D();

            var tail = SceneGraphFactory.createCylinderNode({
                bottomCenterPoint: new THREE.Vector3(0.0, 0.0, iLength),
                topCenterPoint: new THREE.Vector3(0.0, 0.0, iHeadLength),
                radius: iWidth,
                sag: 40,
                color: new Mesh.Color(0.5, 0.5, 0.5, 1.0)
            });

            var head = SceneGraphFactory.createConeNode({
                bottomCenterPoint: new THREE.Vector3(0.0, 0.0, iHeadLength),
                topCenterPoint: new THREE.Vector3(0.0, 0.0, 0),
                topRadius: 0,
                bottomRadius: iHeadWidth,
                sag: 100,
                color: new Mesh.Color(0.5, 0.5, 0.5, 1.0)
            });

            arrow.addChild(tail);
            arrow.addChild(head);
            arrow.pickParent = true;

		    return arrow;
		},

		_refreshArrow: function () {
		    if (UWA.is(this._arrowNode)) {
		        this._node3D.removeChild(this._arrowNode);
		    }
		    var expObject = this.QueryInterface('CATI3DExperienceObject');
		    var length = expObject.GetValueByName('length');
		    var width = expObject.GetValueByName('width');
		    var headLength = expObject.GetValueByName('headLength');
		    var headWidth = expObject.GetValueByName('headWidth');
		    this._arrowNode = this._createArrow(length, width, headLength, headWidth);
		    this._arrowNode.setName(expObject.GetValueByName('_varName'));
		    this._node3D.addChild(this._arrowNode);
		}
	});

    return CATEArrowActor3DGeoVisu;
}
);

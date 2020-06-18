/**
 * CATETorusActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATETorusActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATETorusActor3DGeoVisu',
[
	'UWA/Core',
    'DS/Visualization/SceneGraphFactory',
    'DS/CATCXPModel/extensions/CATEPrimitiveActor3DGeoVisu',
],

// Declaration
function (
    UWA,
    SceneGraphFactory,
    CATEPrimitiveActor3DGeoVisu
    ) {
	'use strict';

	var CATETorusActor3DGeoVisu = CATEPrimitiveActor3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATETorusActor3DGeoVisu.prototype **/
	{
		init: function () {
			this._parent();
			this._torusNode = null;
		},

		destroy: function () {
			this._parent();
			if (this._torusNode) {
				this._torusNode.removeChildren();
				this._torusNode = null;
			}
		},

		_Fill: function (iNode3D) {
			this._parent(iNode3D);

			var expObject = this.QueryInterface('CATI3DExperienceObject');
			var radius1 = expObject.GetValueByName('radius1');
			var radius2 = expObject.GetValueByName('radius2');

			// create torus
			this._torusNode = this._createTorus(radius1, radius2);
			this._torusNode.setName(expObject.GetValueByName('_varName'));
			// set name

			var self = this;
			this.listenTo(expObject, 'radius1.CHANGED', function () {
				self.frameVisuChanges.push(self._refreshTorus);
				self.RequestVisuRefresh();
			});
			this.listenTo(expObject, 'radius2.CHANGED', function () {
				self.frameVisuChanges.push(self._refreshTorus);
				self.RequestVisuRefresh();
			});

			iNode3D.addChild(this._torusNode);
		},

		/** 
        * @public
        */
		GetLocalNodes: function () {
			return this._torusNode;
		},

		_createTorus: function (iRadius1, iRadius2) {
			var torus = SceneGraphFactory.createTorusNode({
				majorRadius: iRadius1,
				minorRadius: iRadius2,
				sag: 100
			});
			torus.pickParent = true;
			return torus;
		},

		_refreshTorus: function () {
			if (UWA.is(this._torusNode)) {
				this._node3D.removeChild(this._torusNode);
			}
			var expObject = this.QueryInterface('CATI3DExperienceObject');
			var radius1 = expObject.GetValueByName('radius1');
			var radius2 = expObject.GetValueByName('radius2');
			this._torusNode = this._createTorus(radius1, radius2);
			this._torusNode.setName(expObject.GetValueByName('_varName'));
			this._node3D.addChild(this._torusNode);
		}
	});

	return CATETorusActor3DGeoVisu;
});

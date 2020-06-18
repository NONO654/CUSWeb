/**
 * CATEVPMOccurrence3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEVPMOccurrence3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEModel3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEVPMOccurrence3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATEModel3DGeoVisu',
    'DS/Visualization/PathElement',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef'
],

// Declaration
function (
    UWA,
    CATEModel3DGeoVisu,
    PathElement,
	THREE,
	DSMath
    ) {
	'use strict';

	var CATEVPMOccurrence3DGeoVisu = UWA.Class.extend(CATEModel3DGeoVisu,
	/** @lends DS/CATCXPModel/extensions/CATEVPMOccurrence3DGeoVisu.prototype **/
    {

		init: function () {
		    this._parent();
		},

		destroy: function () {
		    this._parent();
			this._modelLoaded = false;

			if (this._assetNode) {
				this._assetNode.removeChildren();
				this._assetNode = null;
			}
		},

		_CreatePathElement: function () {
		    var parentVisu = this.QueryInterface('CATI3DXVisuHierarchy').GetVisuParent();
		    var path = parentVisu.QueryInterface('CATI3DGeoVisu').GetPathElement().externalPath.slice();
		    path.push(this.GetNode());
		    this._pathElement = new PathElement(path);
		    return this._pathElement;
		},


		_Fill: function (iNode3D) {
			var self = this;
			this._parent(iNode3D);

			var assetHolder = this.QueryInterface('CATI3DXAssetHolder');
			assetHolder.resolveAsset().done(function (iAssetNode) {
				self._assetNode = iAssetNode;
				iNode3D.addChild(iAssetNode);
				self.RequestVisuRefresh();
				self._modelLoaded = true;
				self.setReady(true);
			});

			this.frameVisuChanges.push(self._addOverrideChildrenNodes);
		},

		_addOverrideChildrenNodes: function () {
			var cache = this.QueryInterface('CATI3DXAssetHolder').getCache();
			if (cache && cache.OverrideChildren) {
				for (var i = 0; i < cache.OverrideChildren.length; i++) {
					var geoVisu = cache.OverrideChildren[i].QueryInterface('CATI3DGeoVisu');
					if (UWA.is(geoVisu)) {
						var childNode = geoVisu.GetNode();
						this._node3D.addChild(childNode);
					}
				}
			}
		},

		_setRepPosition:function(iPosition){
		    var cache = this.QueryInterface('CATI3DXAssetHolder').getCache();
		    var parentTransfo = new DSMath.Transformation().setFromArray(cache.ParentPositionInAssetContext);

		    var transform = new DSMath.Transformation().setFromArray(iPosition);
		    transform = DSMath.Transformation.multiply(parentTransfo, transform);
		    var transformArray = transform.getArray();

		    var mat = new THREE.Matrix4(transformArray[0], transformArray[3], transformArray[6], transformArray[9],
									transformArray[1], transformArray[4], transformArray[7], transformArray[10],
									transformArray[2], transformArray[5], transformArray[8], transformArray[11],
									0.0, 0.0, 0.0, 1.0);

		    this.GetOverride().setPosition(mat);
		},

    	/** 
        * @public
        */
		GetLocalNodes: function () {
			return this._assetNode;
		},

		setReady: function (iReady) {
		    if (iReady === this._ready) {
		        return;
		    }
		    if (iReady && !this._modelLoaded) {
		        return;
		    }
		    this._ready = iReady;
		    this._setParentReady(iReady);
		    this.dispatchEvent('readyChanged', iReady);
		}

	});

	return CATEVPMOccurrence3DGeoVisu;
});


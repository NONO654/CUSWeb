define('DS/CATCXPModel/extensions/CATEVPMReference3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
],

// Declaration
function (
    UWA,
    CATE3DActor3DGeoVisu
    ) {
	'use strict';

	var CATEVPMReference3DGeoVisu = CATE3DActor3DGeoVisu.extend({

		init: function () {
			this._parent();
			this._modelLoaded = false;
		},

		destroy: function () {
			this._parent();
			this._modelLoaded = false;

			if (this._productNode) {
				this._productNode.removeChildren();
				this._productNode = null;
			}
		},

		_Fill: function (iNode3D) {
			var self = this;
			this._parent(iNode3D);

			var assetHolder = this.QueryInterface('CATI3DXAssetHolder');
			if (assetHolder === null) {
				console.log('not an asset holder');
			}

			assetHolder.resolveAsset().done(function (iAssetNode) {
				self._productNode = iAssetNode;
				iNode3D.addChild(iAssetNode);
				self.RequestVisuRefresh();
				self._modelLoaded = true;
				self.setReady(true);
			});
		},

		_addChildrenNodes: function () { //no listener on override children
			this._parent();

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

		GetLocalNodes: function () {
			return this._productNode;
		},

		setReady: function (iReady) {
			if (iReady === this._ready) {
				return;
			}
			if (iReady && ((!this._isAllChildrenReady()) || (!this._modelLoaded))) {
				return;
			}
			this._ready = iReady;
			this._setParentReady(iReady);
			this.dispatchEvent('readyChanged', iReady);
		},

		_isAllChildrenReady: function () {
			var actorsMgr = this.QueryInterface('CATICXPActorsMgr');
			if (actorsMgr) {
				var actors = [];
				actorsMgr.ListActors(actors);
				for (var i = 0; i < actors.length; i++) {
					var geoVisu = actors[i].QueryInterface('CATI3DGeoVisu');
					if (geoVisu) {
						if (!geoVisu.isReady()) {
							return false;
						}
					}
				}
			}

			var overrides = this.QueryInterface('CATI3DExperienceObject').GetValueByName('overrides');
			for (var i = 0; i < overrides.length; i++) {
				var geoVisu = overrides[i].QueryInterface('CATI3DGeoVisu');
				if (geoVisu) {
					if (!geoVisu.isReady()) {
						return false;
					}
				}
			}

			return true;
		}
	});

	return CATEVPMReference3DGeoVisu;
});


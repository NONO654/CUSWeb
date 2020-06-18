/**
 * CATE3DActor3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @augments DS/CATCXPModel/extensions/CATEModel3DGeoVisu
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATEModel3DGeoVisu',
    'DS/Visualization/ThreeJS_DS'
],

// Declaration
function (
    UWA,
    CATEModel3DGeoVisu,
    THREE
    ) {
    'use strict';

    var CATE3DActor3DGeoVisu = CATEModel3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATE3DActor3DGeoVisu.prototype **/
    {
    	_Fill: function (iNode3D) {
    	    this._parent(iNode3D);
    		var self = this;

    		this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'actors.CHANGED', function () {
    		    self._node3D.removeChildren();
    		    //iterate subactor get Node ? parent
    		    self.frameVisuChanges.push(self._addChildrenNodes);
    		    var local = self.GetLocalNodes();
    		    if (local) {
    		        self._node3D.addChild(local);
    		    }
    		    self.RequestVisuRefresh();
    		    self.setReady(self._ready && self._isAllChildrenReady());
    		});
    		
    		this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'opacity.CHANGED', function () {
    		    self.frameVisuChanges.push(self._RefreshOpacity);
    		    self.RequestVisuRefresh();
    		});

    		this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'color.CHANGED', function () {
    		    self.frameVisuChanges.push(self._RefreshColor);
    		    self.RequestVisuRefresh();
    		});
            
    		this.frameVisuChanges.push(self._addChildrenNodes);
    		this.frameVisuChanges.push(self._RefreshOpacity);
    		this.frameVisuChanges.push(self._RefreshColor);

    		if (this.GetObject().GetType() === 'CXP3DActor_Spec') {
    		    this.setReady(true);
            }
    	},

    	_listenGraphicalProperties: function () {
            /**     deprecated     **/
    	    this._parent();
    	},

    	/** 
        * @public
        */
    	setReady: function (iReady) {
    		if (iReady === this._ready) {
    			return;
    		}
    		if (iReady && (!this._isAllChildrenReady())) {
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
    					if (!actors[i].QueryInterface('CATI3DGeoVisu').isReady()) {
    						return false;
    					}
    				}
    			}
    		}
    		return true;
    	},

    	_addChildrenNodes: function () {
    		var subActors = this.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
    		if (UWA.is(subActors)) {
    			for (var i = 0; i < subActors.length; i++) {
    				var geoVisu = subActors[i].QueryInterface('CATI3DGeoVisu');
    				if (UWA.is(geoVisu)) {
    					var childNode = geoVisu.GetNode();
    					this._node3D.addChild(childNode);
    				}
    			}
    		}
    	},

    	_setRepPosition: function (iPosition) {
    	    var mat = new THREE.Matrix4(iPosition[0], iPosition[3], iPosition[6], iPosition[9],
										iPosition[1], iPosition[4], iPosition[7], iPosition[10],
										iPosition[2], iPosition[5], iPosition[8], iPosition[11],
										0.0, 0.0, 0.0, 1.0);
    	    this.GetOverride().setPosition(mat);
    	},

    	_RefreshOpacity: function () {
    	    var rawOpacity = this.QueryInterface('CATI3DXGraphicalProperties').GetOpacity();
    	    this.GetOverride().setOpacity(rawOpacity / 255, false);
    	},

    	_RefreshColor: function () {
    	    // ignore if color not defined
    	    if (!this.QueryInterface('CATI3DExperienceObject').GetValueByName("color")) {
    	        return;
    	    }
    	    var graphProp = this.QueryInterface('CATI3DXGraphicalProperties');
    	    var red = graphProp.GetRed();
    	    var green = graphProp.GetGreen();
    	    var blue = graphProp.GetBlue();
    	    var threeColor = 'rgb(' + red + ',' + green + ',' + blue + ')';
    	    this.GetOverride().setColor(threeColor, false);
    	}

    }); // end of CATE3DActor3DGeoVisu

    return CATE3DActor3DGeoVisu;
});


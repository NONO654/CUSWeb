/**
 * CATEExperience3DGeoVisu
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATEExperience3DGeoVisu
 * @description Implements : 
 * {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu} 
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATEExperience3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATE3DGeoVisu',
    'DS/CATCXPModel/CATCXPRenderUtils',
    'DS/Visualization/PathElement'
],

// Declaration
function (
    UWA,
    CATE3DGeoVisu,
    CATCXPRenderUtils,
    PathElement
    ) {
    'use strict';

    var CATEExperience3DGeoVisu = CATE3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEExperience3DGeoVisu.prototype **/
    {

    	init: function () {
    		this._parent();
    	},

    	_CreatePathElement: function () {
    	    this._pathElement = new PathElement([this.GetNode()]);
    	    return this._pathElement;
    	},

		_Fill: function (iNode3D) {
		    this._parent(iNode3D);
		    var self = this;
		    // store component on node3D

			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'actors.CHANGED', function () {
			    self._node3D.removeChildren();
				self.frameVisuChanges.push(self._addChildrenNodes);
				self.RequestVisuRefresh();
				self.setReady(self._isAllChildrenReady());
			});

			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'currentCamera.CHANGED', function () {
			    self.frameVisuChanges.push(self._refreshCurrentCamera);
			    self.RequestVisuRefresh();
			});

			this.frameVisuChanges.push(this._addChildrenNodes);
			this.frameVisuChanges.push(this._refreshCurrentCamera);
		    this.setReady(this._isAllChildrenReady());
		},

		_addChildrenNodes: function () {
		    var subActors = this.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		    for (var i = 0; i < subActors.length; i++) {
		    	var geoVisu = subActors[i].QueryInterface('CATI3DGeoVisu');
		    	if (UWA.is(geoVisu)) {
		    	    var childNode = geoVisu.GetNode();
		    		this._node3D.addChild(childNode);
		    	}
		    }
		},

		_refreshCurrentCamera: function () {
		    this.stopListening(null, '_varposition.CHANGED');
		    var currentCamera = this.QueryInterface('CATI3DExperienceObject').GetValueByName('currentCamera');
		    if (currentCamera) {
		        this.listenTo(currentCamera.QueryInterface('CATI3DExperienceObject'), '_varposition.CHANGED', this._refreshViewpoint.bind(this, currentCamera));
		        this._refreshViewpoint(currentCamera);
		    }          
		},

		_refreshViewpoint: function (iCurrentCamera) {
		    var viewpoint = this.GetObject()._experienceBase.webApplication.viewer.currentViewpoint;
		    CATCXPRenderUtils.setViewpointFromCamera(viewpoint, iCurrentCamera);
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
		    return true;
		},


        /**
        * @public
        */
		GetBoundingBox: function () {
		    //scene BB always in world coordinates (no _varpos on scene node)
		    var pathElement = this.GetPathElement();
		    var viewer = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer();
			var Bb;
			if (this.GetOverride().getVisibility()) {
			    Bb = pathElement.getBoundingBox(null, viewer, 'visibleSpace');
		    }
		    else {
			    Bb = pathElement.getBoundingBox(null, viewer, 'invisibleSpace');
		    }
		    return Bb;
		},

        /**
        * @public
        */
		GetBoundingSphere: function () {
		    var pathElement = this.GetPathElement();
		    var viewer = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer();
			var bS;
			if (this.GetOverride().getVisibility()) {
		        bS = pathElement.getBoundingSphere(viewer, 'visibleSpace');
		    }
		    else {
		        bS = pathElement.getBoundingSphere(viewer, 'invisibleSpace');
		    }
		    return bS;
		}


	});

    return CATEExperience3DGeoVisu;
}
);


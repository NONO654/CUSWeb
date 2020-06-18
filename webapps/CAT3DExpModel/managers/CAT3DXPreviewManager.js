/* global widget  */
/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXPreviewManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXPreviewManager',
[
	'UWA/Core',
	'UWA/Class/Events',
	'UWA/Class/Listener',
	'DS/WebApplicationBase/W3AAManager',
	'DS/Visualization/WebGLV6Viewer',
	'DS/Visualization/Viewpoint',
	'DS/CATCXPModel/CATCXPRenderUtils'
],
function (UWA, UWAEvents, Listener, W3AAManager, WebGLV6Viewer, Viewpoint, RenderUtils) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/managers/CAT3DXPreviewManager
    * @category Manager
    *
    * @description
    * Manage preview of components implementing  {@link StuModelWeb/CATI3DGeoVisu CATI3DGeoVisu} interface.
    *
    * @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
	*/
	var CAT3DXPreviewManager = UWA.Class.extend(W3AAManager, Listener, /*UWAEvents*/
	/** @lends DS/CAT3DExpModel/managers/CAT3DXPreviewManager.prototype **/
	{


		initialize: function () {
			this._nodesToPreview = [];
		},

		getUpdatePriority: function () {
			return 1;
		},

		postInitialize: function () {
		    this._createPreviewViewer();
		},

		unInitialize: function () {
		    if (this._objectsToRefresh) {
		        this._objectsToRefresh.length = 0;
		    }
		    this.stopListening();
		    this._divPreview.remove();
		    this._previewViewer = null;
		    this._divPreview = null;
		},

		getPreview: function (iGeoVisu, iCallback, iCamera) {
		    var self = this;
		    iGeoVisu.GetNode();
		    if (iGeoVisu.isReady()) {
		        this._addNodeToPreview(iGeoVisu, iCallback, iCamera);
		    }
		    else {
		        this.listenTo(iGeoVisu, 'readyChanged', function (ready) {
		            if (ready) {
		                self.stopListening(iGeoVisu, 'readyChanged');
		                self._addNodeToPreview(iGeoVisu, iCallback, iCamera);
		            }
		        });
		    }
		},

		_addNodeToPreview: function (iGeoVisu, iCallback, iCamera) {
			for (var i = 0; i < this._nodesToPreview.length; i++) {
			    if ((this._nodesToPreview[i].GeoVisu === iGeoVisu) && (String(this._nodesToPreview[i].Callback.toString()) === String(iCallback)) && (this._nodesToPreview[i].Camera === iCamera)) {
					return;
				}
			}

			this._nodesToPreview.push({
			    GeoVisu: iGeoVisu,
			    Callback: iCallback,
			    Camera: iCamera
			});
			if (this._nodesToPreview.length === 1) {
			    this._preview(this._nodesToPreview[0]);
			}
		},

		_preview: function (ev) {
			var self = this;
			this._setViewerPreviewContent(ev.GeoVisu);

			this._getPreview(ev.GeoVisu, ev.Callback, ev.Camera, function () {
				self._nodesToPreview.splice(0, 1);
				if (self._nodesToPreview.length > 0) {
					self._preview(self._nodesToPreview[0]);
				}
			});
		},


		_setViewerPreviewContent: function (iGeoVisu) {
			if (this.currentNodeViewerPreview) {
				this._previewViewer.removeNode(this.currentNodeViewerPreview);
				this._previewViewer.getSceneGraphOverrideSetManager().clear();
			}
			this.currentNodeViewerPreview = iGeoVisu.GetNode();
			this._previewViewer.addNode(this.currentNodeViewerPreview);

			var visuManager = this._experienceBase.getManager('CAT3DXVisuManager');
			var previewPath = iGeoVisu.GetPathElement();
			this._previewViewer.getSceneGraphOverrideSetManager().pushSceneGraphOverrideSet(visuManager.getOverrideSet(), { substractivePath: previewPath.getLength() > 1 ? previewPath : undefined });
		},

		_getPreview: function (iGeoVisu, iPreviewCallback, iCamera, iCallback) {
			var self = this;
			if (iCamera) {
				RenderUtils.setViewpointFromCamera(self._previewViewer.currentViewpoint, iCamera);
			}
			else {
				self._previewViewer.currentViewpoint.reframe(null, 0);
			}

			self._previewViewer.setRenderFrameCB(function () {
				self._previewViewer.setRenderFrameCB(function () {
					self._previewViewer.setRenderFrameCB(null);

					var preview = self._previewViewer.canvas.toDataURL('image/jpeg', 0.1);

					if (iPreviewCallback) {
						iPreviewCallback(preview);
					}
					if (self.currentNodeViewerPreview) {
						self._previewViewer.removeNode(self.currentNodeViewerPreview);
						self._previewViewer.getSceneGraphOverrideSetManager().clear();
						self.currentNodeViewerPreview = null;
					}
					if (iCallback) {
						iCallback();
					}
				});
				self._previewViewer.render();
			});
			self._previewViewer.render();
		},

		_createPreviewViewer: function () {
			if (!this._divPreview) {
				this._divPreview = UWA.createElement('div');
				widget.body.appendChild(this._divPreview);
				this._divPreview.style.position = 'absolute';
				this._divPreview.style.background = '#D0D0D0';
				this._divPreview.style.width = '100%';
				this._divPreview.style.height = '100%';
			   // this._divPreview.style.width = '30%';		//test
			   // this._divPreview.style.height = '30%';		//test
			   // this._divPreview.style.zIndex = '1000000';	//test
			   // this._divPreview.style.bottom = '0px';		//test
			   // this._divPreview.style.right = '0px';		//test
			}

			var appOptions;
			if (this._experienceBase.webApplication.app.getOptions){
				appOptions = this._experienceBase.webApplication.app.getOptions();
			}

			var viewerOptions =  (appOptions && appOptions.viewerOptions)? appOptions.viewerOptions : {};
			viewerOptions.div = this._divPreview;
			viewerOptions.defaultLights = false;
			viewerOptions.multiViewer = true;
			viewerOptions.multiViewerFix = true;
			this._previewViewer = new WebGLV6Viewer(viewerOptions);
			this._previewViewer.setVisuEnv('None'); //odt mode for set viewer params

			var viewpoint = new Viewpoint({ viewer: this._previewViewer });
			this._previewViewer.addViewpoint(viewpoint);
			this._previewViewer.viewerID = 'PreviewViewer';
		},

		GetType: function () {
		    return 'CAT3DXPreviewManager';
		}
	});
	return CAT3DXPreviewManager;
});


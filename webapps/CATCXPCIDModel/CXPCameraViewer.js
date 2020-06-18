/**
 * @exports DS/CATCXPCIDModel/CXPCameraViewer
 */
define('DS/CATCXPCIDModel/CXPCameraViewer',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor',
	'DS/Visualization/WebGLV6Viewer',
	'DS/Visualization/Viewpoint',
	'DS/CATCXPModel/CATCXPRenderUtils'
],
function (UWA, CXPUIActor, WebGLV6Viewer, Viewpoint, RenderUtils) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPCameraViewer
    * @description
    * Camera viewer
	* @constructor
	*/

	var CXPCameraViewer = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPCameraViewer.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._viewerContainer = UWA.createElement('div').inject(this.getContainer());
				this._viewerContainer.style.boxSizing = 'border-box';

				var appOptions;
				if (this._uiActor.GetObject()._experienceBase.webApplication.app.getOptions) {
				    appOptions = this._uiActor.GetObject()._experienceBase.webApplication.app.getOptions();
				}
				var viewerOptions = (appOptions && appOptions.viewerOptions) ? appOptions.viewerOptions : {};
				viewerOptions.div = this._viewerContainer;
				viewerOptions.multiViewer = true;
				viewerOptions.multiViewerFix = true;
				viewerOptions.highlight = {
					activated: false,
					displayHL: false
				};
				viewerOptions.defaultLights = false;
				this._cameraViewer = new WebGLV6Viewer(viewerOptions);
				this._cameraViewer.setVisuEnv('None'); //odt mode for set viewer params

				this._cameraViewer.canvas.style.pointerEvents = 'none';

				var viewpoint = new Viewpoint({ viewer: this._cameraViewer });
				this._cameraViewer.addViewpoint(viewpoint);


				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						if (this._visible) {
							this._viewerContainer.style.display = 'inherit';
						}
						else {
							this._viewerContainer.style.display = 'none';
						}
					}
				});

				Object.defineProperty(this, 'enable', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._enable;
					},
					set: function (iValue) {
						this._enable = iValue;
						if (this._enable) {
							this._viewerContainer.style.pointerEvents = 'inherit';
							this._viewerContainer.style.filter = 'none';
							if (this.camera) {
								this._update();
								var visuMgr = this.camera._experienceBase.getManager('CAT3DXVisuManager');
								if (this._liveUpdate) {
									var self = this;
									visuMgr.pushVisuRefreshCB(this._refreshVisu = function () {
										self._update();
									});
								}
							}
						}
						else {
							this._viewerContainer.style.pointerEvents = 'none';
							this._viewerContainer.style.filter = 'brightness(70%) grayscale(100%)';
							if (this.camera) {
							    var visuMgr = this.camera._experienceBase.getManager('CAT3DXVisuManager');
								visuMgr.removeVisuRefreshCB(this._refreshVisu);
							}
						}
					}
				});

				Object.defineProperty(this, 'opacity', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._opacity;
					},
					set: function (iValue) {
						this._opacity = iValue;
						this._viewerContainer.style.opacity = this._opacity/255;
					}
				});

				Object.defineProperty(this, 'minWidth', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._minWidth;
					},
					set: function (iValue) {
						this._minWidth = iValue;
						this._viewerContainer.style.width = this._minWidth + 'px';
					}
				});

				Object.defineProperty(this, 'minHeight', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._minHeight;
					},
					set: function (iValue) {
						this._minHeight = iValue;
						this._viewerContainer.style.height = this._minHeight + 'px';
					}
				});

				Object.defineProperty(this, 'liveUpdate', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._liveUpdate;
					},
					set: function (iValue) {
						this._liveUpdate = iValue;
						if (this.camera) {
						    var visuMgr = this.camera._experienceBase.getManager('CAT3DXVisuManager');
							if ((this._liveUpdate) && (this.enable)) {
								var self = this;
								self._update();
								visuMgr.pushVisuRefreshCB(this._refreshVisu = function () {
									self._update();
								});
							}
							else {
								visuMgr.removeVisuRefreshCB(this._refreshVisu);
							}
						}
					}
				});

				Object.defineProperty(this, 'camera', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._camera;
					},
					set: function (iValue) {
						this._camera = iValue;
						if (this._camera) {
						    var self = this;
						    this._cameraViewer.getSceneGraphOverrideSetManager().clear();
						    if (this._content) {
						        this._cameraViewer.removeNode(this._content.GetNode());
						    }
							var visuMgr = this._camera._experienceBase.getManager('CAT3DXVisuManager');
							this._content = visuMgr.getContent();
							this._cameraViewer.addNode(this._content.GetNode());
							var contentPath = this._content.GetPathElement();
							this._cameraViewer.getSceneGraphOverrideSetManager().pushSceneGraphOverrideSet(
                                visuMgr.getOverrideSet(),
                                { substractivePath: contentPath.getLength() > 1 ? contentPath : undefined }
                            );
							if (this.enable) {
								self._update();
							}

							if ((this.liveUpdate) && (this.enable)) {
								visuMgr.pushVisuRefreshCB(this._refreshVisu = function () {
									self._update();
								});
							}
							else {
								visuMgr.removeVisuRefreshCB(this._refreshVisu);
							}
						}
					}
				});
			},



			_update: function () {
				RenderUtils.setViewpointFromCamera(this._cameraViewer.currentViewpoint, this.camera, 0);
				this._cameraViewer.render();
			},

			// Register events for play
			registerPlayEvents: function (iSdkObject, index) {
				this._parent(iSdkObject);
				index = UWA.is(index) ? index : 0;
				if (this.camera) {
					this._update();
				}

				this._viewerContainer.addEventListener('click', this._clickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIClicked', index);
				});

				this._viewerContainer.addEventListener('dblclick', this._dblclickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIDoubleClicked', index);
				});
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._viewerContainer.removeEventListener('click', this._clickEvent);
				this._viewerContainer.removeEventListener('dblclick', this._dblclickEvent);
			}

		});
	return CXPCameraViewer;
});





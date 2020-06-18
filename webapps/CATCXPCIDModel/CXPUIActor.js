/**
 * @exports DS/CATCXPCIDModel/CXPUIActor
 */
define('DS/CATCXPCIDModel/CXPUIActor',
// dependencies
[
    'UWA/Core',
	'DS/SceneGraphNodes/CSS2DNode'
],
function (UWA, CSS2DNode) {

	'use strict';
	/**
	* @name DS/CATCXPCIDModel/CXPUIActor
    * @description
	* Create dom container for UIActor rep
	* Define top/left offset to position rep
	* Add helper functions to interact on container (inject, remove ..) 
	* @constructor
	*/


	var CXPUIActor = UWA.Class.extend(
		/** @lends DS/CATCXPCIDModel/CXPUIActor.prototype **/
		{

			init: function (iUIActor) {
				this._uiActor = iUIActor;
				this._mapper = null;
			},

			destroy: function () {
				this._container = null;
				if (this._2DNode) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().removeChild(this._2DNode);
					this._2DNode = null;
				}
				this._uiActor = null;
				if (this._mapper) {
					this._mapper.destroy();
					this._mapper = null;
				}
			},

			// @return {DOM} container
			getContainer: function () {
				if (!this._container) {
					this._container = this._createContainer();
				}
				return this._container;
			},

			setUIMapper: function (iUIMapper) {
				this._mapper = iUIMapper;
			},

			_createContainer: function () {

				this._container = UWA.createElement('div');
				this._container.style.pointerEvents = 'none';
				this._container.style.position = 'absolute';

				Object.defineProperty(this, 'left', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._left;
					},
					set: function (iValue) {
						this._left = iValue;
						this._container.style.left = this._left;
					}
				});

				Object.defineProperty(this, 'top', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._top;
					},
					set: function (iValue) {
						this._top = iValue;
						this._container.style.top = this.top;
					}
				});

				Object.defineProperty(this, 'clientWidth', {
					enumerable: true,
					get: function () {
						return this.getContainer().clientWidth;
					}
				});

				Object.defineProperty(this, 'clientHeight', {
					enumerable: true,
					get: function () {
						return this.getContainer().clientHeight;
					}
				});

				return this._container;
			},

			isAttachTo3D: function () {
				return this._3DAttached;
			},

			detachFrom3D: function () {
				this._3DAttached = false;
				if (this._2DNode) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().removeChild(this._2DNode);
					this._2DNode = undefined;
				}

				var cxpObj = this._uiActor.QueryInterface('CATICXPObject');
				var parent = cxpObj.GetFatherObject();
				var parentUIRep = parent.QueryInterface('CATI3DXUIRep');
				this.getContainer().inject(parentUIRep.Get());
			},

			attachTo3D: function (iTarget) {
				this._3DAttached = true;
				this.getContainer().remove();
				var bs = iTarget.QueryInterface('CATI3DGeoVisu').GetBoundingSphere();
				if (this._2DNode) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().removeChild(this._2DNode);
				}
				this._2DNode = new CSS2DNode({ html: this.getContainer(), name: '2DNode', position: bs.center });
				this._2DNode.setPickable(false);

				this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().addChild(this._2DNode);
			},

			get2DNode: function () {
				return this._2DNode;
			},

			show: function () {
				if (this._3DAttached) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().addChild(this._2DNode);
					if (document.getElementById('divCss2DElement')) {													  //node3D.removeChild call removeChild on domElement (divcss -> container) 
						document.getElementById('divCss2DElement').appendChild(this._2DNode.css2DNode.element);			  //node3D.addChild does not call appendChild (divcss -> container)
					}																									  //
				}
				else {
					this.getContainer().show();
				}
			},

			hide: function () {
				if (this._3DAttached) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().removeChild(this._2DNode);
				}
				else {
					this.getContainer().hide();
				}
			},

			// inject container into a parent Div
			inject: function (iParent) {
				if (this._3DAttached) {
					this._uiActor.GetObject()._experienceBase.webApplication.viewer.getRootNode().addChild(this._2DNode);
					if (document.getElementById('divCss2DElement')) {													  //node3D.removeChild call removeChild on domElement (divcss -> container) 
						document.getElementById('divCss2DElement').appendChild(this._2DNode.css2DNode.element);			  //node3D.addChild does not call appendChild (divcss -> container)
					}																									  //
				}
				else {
					this.getContainer().inject(iParent);
				}
			},

			// add child to container
			appendChild: function (iChild) {
				this.getContainer().appendChild(iChild);
			},

			// Detach container from the parent
			remove: function () {
				this.getContainer().remove();
			},

			// Register events for play
			registerPlayEvents: function (iSdkObject) {
			    this._container.style.pointerEvents = 'auto';
			    this._sdkObject = iSdkObject; // trick to avaid nounusedvars error from mkscc
			},

			// Release play events
			releasePlayEvents: function () {
				this._container.style.pointerEvents = 'none';
			}

		});
	return CXPUIActor;
});





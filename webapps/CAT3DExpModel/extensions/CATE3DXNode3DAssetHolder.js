/**
* CATE3DXNode3DAssetHolder
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DXNode3DAssetHolder
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder CATI3DXAssetHolder}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DXNode3DAssetHolder',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/extensions/CATE3DXAssetHolder',
	'DS/Visualization/ModelLoader',
	'DS/Visualization/Node3D'
],

// Declaration
function (UWA, Promise, CATE3DXAssetHolder, ModelLoader, Node3D) {

	'use strict';

	var StackLoader = UWA.Class.singleton({
		init: function () {
			this.modelLoaderVisu = new ModelLoader();
			this.models = [];
		},

		pushModel: function (iModelLoader) {
			this.models.push(iModelLoader);
			if (this.models.length === 1) {
				this.loadModel(iModelLoader);
			}
		},

		loadModel: function (iModelLoader) {
			var self = this;

			this.modelLoaderVisu.setRenderCallback(iModelLoader.renderCB);
			this.modelLoaderVisu.setOnProgressCallback(iModelLoader.onProgressCB);
			this.modelLoaderVisu.setSceneGraph(iModelLoader.targetNode);
			this.modelLoaderVisu.setOnLoadedCallback(function(){
				iModelLoader.onLoadedCB();
				self.models.splice(0, 1);
				if (self.models.length > 0) {
					self.loadModel(self.models[0]);
				}
			});
			if (iModelLoader.format) {
				this.modelLoaderVisu.setFileType(iModelLoader.format);
			}
			this.modelLoaderVisu.loadModel(iModelLoader.url);
		}

	});

	var StackModel = UWA.Class.extend({
		init: function () {
			this.renderCB = null;
			this.onProgressCB = null;
			this.targetNode = null;
			this.onLoadedCB = null;
			this.format = null;
			this.url = null;
		},

		destroy: function () {
			this.renderCB = null;
			this.onProgressCB = null;
			this.targetNode = null;
			this.onLoadedCB = null;
			this.format = null;
			this.url = null;
		},

		setRenderCallback: function (iCB) {
			this.renderCB = iCB;
		},

		setOnProgressCallback:function(iCB){
			this.onProgressCB = iCB;
		},

		setSceneGraph:function(itargetNode){
			this.targetNode = itargetNode;
		},

		setOnLoadedCallback:function(iCB){
			this.onLoadedCB= iCB;
		},

		setFileType:function(iFormat){
			this.format = iFormat;
		},

		loadModel: function (iUrl) {
			this.url = iUrl;
			StackLoader.pushModel(this);
		}

	});

	var CATE3DXNode3DAssetHolder = CATE3DXAssetHolder.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXNode3DAssetHolder.prototype **/
	{

		init: function () {
			this._parent();
			this._node3D = null;
			this._promises = [];
		},

		destroy: function () {
			this._parent();
			this._node3D = null;
			this._promises = null;
		},

		Build: function () {
		    if (!this._isResolved) {
		    	this.GetObject()._experienceBase.getManager('CAT3DXAssetHolderManager').registerAssetHolder(this);
		    }
		},

		resolveAsset: function () {
			var self = this;
			if (this._isResolved) {
				return Promise.resolve(this._node3D);
			}

			if (!this._node3D) {
				if (localStorage.getItem('Heavy_Experience') === 'true') {
					this.modelLoader = new StackModel();
				} else {
				    this.modelLoader = new ModelLoader();
				}
				var visuManager = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager');
				if (visuManager) {
					self.modelLoader.setRenderCallback(visuManager._viewer.render);
				}
				this.modelLoader.setOnProgressCallback(function (message) { console.log(message); });
				this._node3D = new Node3D();
				this.modelLoader.setSceneGraph(this._node3D);

				this._resolveLinkAsStream().done(function () {
					self.GetObject()._experienceBase.getManager('CAT3DXAssetHolderManager').assetHolderResolved(self);
					self._isResolved = true;
					self._resolvePromises();
				});
			}

			return new UWA.Promise(function (iSuccess) {
				self._promises.push(iSuccess);
			});
		},

		_resolveLinkAsStream: function () {
		    var self = this;
		    return self.getLinkContext().resolveLinkAsStream(self.getLinkDescription()).done(function (stream) {
		        return new UWA.Promise(function (resolve) {
		            self.modelLoader.setOnLoadedCallback(resolve);
		            self.modelLoader.setFileType(stream.format);
		            var url = URL.createObjectURL(stream);
		            self.modelLoader.loadModel(url, self._node3D);
		        });
		    });
		},

		_resolvePromises: function () {
			for (var i = 0; i < this._promises.length; i++) {
				this._promises[i](this._node3D);
			}
		}

	});

	return CATE3DXNode3DAssetHolder;

});

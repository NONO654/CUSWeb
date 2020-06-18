/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXVisuManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXVisuManager',
// dependencies
[
	'UWA/Core',
    'UWA/Class/Events',
	'UWA/Element',
	'DS/WebApplicationBase/W3AAManager',
	'UWA/Class/Listener',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef',
	'DS/SceneGraphOverrides/SceneGraphOverrideSet',
	'DS/Controls/ProgressBar'
],
function (
	UWA,
    UWAEvents,
	Element,
	W3AAManager,
	Listener,
	THREE,
	DSMath,
	SceneGraphOverrideSet,
	WUXProgressBar
	) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/managers/CAT3DXVisuManager
	* @category Manager
	*
	* @description
	*<p> Add/Remove 3D Nodes on the Web Viewer. </p>
	*<p> Objects should implement CATI3DGeoVisu interface to be shown !</p>
	*<p> Visu could be refreshed anytime with a SetContent()</p>
	*<p> The root to display could be a sub actor, only the sub actors will be added to the viewer.</p>
	*
	* @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
	*/
	var CAT3DXVisuManager = UWA.Class.extend(W3AAManager, Listener, UWAEvents,
	/** @lends DS/CAT3DExpModel/managers/CAT3DXVisuManager.prototype **/
	{
		/**************************************************/
		/***            W3AAManager overrides           ***/
		/**************************************************/

		getUpdatePriority: function () {
			return 1;
		},

		initialize: function () {
			this._objectsToRefresh = [];
			this._requireRefresh = false;
			this._visuRefreshCB = [];
			this._root = null;
			this._content = null;
			this._overrideSet = null;
		},

		postInitialize: function () {
			var self = this;
			this._viewer = this._experienceBase.webApplication.viewer;

			this.pushVisuRefreshCB(function () {
			    self._viewer.render();
			});
		},

		unInitialize: function () {
		    this._parent();
		    this.removeContent();
			this._objectsToRefresh.length = 0;
			this.stopListening();
		},

		update: function () {
			for (var i = 0 ; i < this._objectsToRefresh.length ; i++) {
				this._objectsToRefresh[i].Refresh();
			}
			if ((this._objectsToRefresh.length > 0) || (this._requireRefresh)) {
				for (var iCB = 0; iCB < this._visuRefreshCB.length; iCB++) {
					this._visuRefreshCB[iCB]();
				}
			}
			this._objectsToRefresh.length = 0;
			this._requireRefresh = false;
		},

	    /** 
        * Get viewer.
        * @public
        * @return {viewer} the visu manager viewer.
        */
		getViewer: function () {
		    return this._viewer;
		},

		setRoot: function (iGeoVisu) {
		    this._root = iGeoVisu;
		    this._viewer.getSceneGraphOverrideSetManager().clear();
		    if (this._root) {
		        this._overrideSet = new SceneGraphOverrideSet(iGeoVisu.GetNode());
		    }
		},

		getRoot: function () {
		    return this._root;
		},

		getOverrideSet: function () {
		    return this._overrideSet;
		},

		/***********************************/
		/***            Public           ***/
		/***********************************/

		/** 
		* Set content to the 3D WebGL viewer
        * @public
		* @param  {CATI3DGeoVisu} iGeoVisu - web visu interface of the object to display on the viewer.
		* It'll display all the subactors of the instance.
		*/
		setContent: function (iGeoVisu) {
		    if (iGeoVisu === this._content) {
				return;
		    }
		    if (!this._root) {
		        return;
		    }

		    this.removeContent();
		    this._content = iGeoVisu;
		    this._viewer.addNode(this._content.GetNode());
		    this._listenContentReady(iGeoVisu);

		    var contentPath = this._content.GetPathElement();
		    if (contentPath.getElement(0) !== this._root.GetNode()) {
		        console.warn('Content path should start with root node');
		    }
		    this._viewer.getSceneGraphOverrideSetManager().pushSceneGraphOverrideSet(this.getOverrideSet(), { substractivePath: contentPath.getLength() > 1 ? contentPath : undefined });
		},

		getContent:function(){
		    return this._content;
		},

		/** 
		* Clear content of the 3D WebGL viewer
        * @public
		*/
		removeContent: function () {
		    if (this._content) {
		        this._viewer.getSceneGraphOverrideSetManager().clear();
		        this.stopListening(this._content);
		        this._viewer.removeNode(this._content.GetNode());
		        this._content = null;
			}
		},

		setViewpointControl: function (iControls) {
			this._viewer.currentViewpoint.setDefaultController(false);
			this._viewer.currentViewpoint.control = iControls;
			this._viewer.currentViewpoint.resetCameraOrientation();
			this._viewer.currentViewpoint.onMove(this._viewer.render);
		},

		getViewpointControl: function () {
			return this._viewer.currentViewpoint.control;
		},

		forceViewerRefresh: function () {
		    this._requireRefresh = true;
		},

		refreshGeoVisu:function(iGeoVisu){
		    this._objectsToRefresh.push(iGeoVisu);
		},

		_listenContentReady: function (iGeoVisu) {
		    var self = this;
		    if (!iGeoVisu.isReady()) {
		        this._showLoadingNotification();
		    }
			this.listenTo(iGeoVisu, 'readyChanged', function (isReady) {
				if (isReady) {
				    this.forceViewerRefresh();
					self._hideLoadingNotification();
				}
				else {
					self._showLoadingNotification();
				}
			});
		},

		_showLoadingNotification: function () {
			var div = document.createElement('div');
			var progressBar = new WUXProgressBar({
				shape: 'circular',
				infiniteFlag: true
			}).inject(div);
			progressBar.elements.container.style.zoom = '0.5';
			var span = document.createElement('span');
			span.innerHTML = 'Loading...';
			span.style.marginTop = 'auto';
			span.style.marginBottom = 'auto';
			span.style.marginLeft = '20px';
			span.style.fontSize = '17px';
			div.style.display = 'flex';
			div.appendChild(span);
			this._loadingNotification = this._experienceBase.getManager('CAT3DXNotificationsManager').addNotification({
			    level: 'info',
			    title: div
			});
		},

		_hideLoadingNotification: function () {
		    this._experienceBase.getManager('CAT3DXNotificationsManager').removeNotification(this._loadingNotification);
		},

		pushVisuRefreshCB: function (iCB) {
			this._visuRefreshCB.push(iCB);
		},

		removeVisuRefreshCB: function (iCB) {
			var idx = this._visuRefreshCB.indexOf(iCB);
			if (idx >= 0) {
				this._visuRefreshCB.splice(idx, 1);
			}
		},

		GetType: function () {
		    return 'CAT3DXVisuManager';
		}
	});
	return CAT3DXVisuManager;
});


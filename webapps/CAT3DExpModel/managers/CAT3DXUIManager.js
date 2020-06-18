/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXUIManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXUIManager',
[
	'UWA/Core',
	'UWA/Element',
	'DS/Core/Events',
	'DS/WebApplicationBase/W3AAManager',
	'UWA/Class/Listener',
	'DS/WebComponentModeler/CATWebInterface',
	'DS/CATCXPCIDModel/CXPUIRepFactory'
],
function (UWA, Element, WUXEvent, W3AAManager, Listener, CATWebInterface, RepFactory) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/managers/CAT3DXUIManager
	* @category Manager
	*
	* @description
	* Manager in charge of rendering UI Actors. 
	*
	* @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
	*/

	var CAT3DXUIManager = UWA.Class.extend(W3AAManager, Listener,
	/** @lends DS/CAT3DExpModel/managers/CAT3DXUIManager.prototype **/
	{

		initialize: function () {
			this._objectsToRefresh = [];
			this._repFactory = new RepFactory();
		},

		/**
		* Return rules for snapping
		* @return {Object} ui actors rep factory 
		*/
		getFactory: function () {
			return this._repFactory;
		},

		postInitialize: function () {
			var self = this;

			this.eventUIManager = WUXEvent.subscribe({
				event: 'STU_UI_CHANGED'
			}, function (event) {
				if (event) {
					self._objectsToRefresh.push(event.CATI3DXUIRep);
				}
			});
		},

		unInitialize: function () {
			WUXEvent.unsubscribe(this.eventUIManager);
			this._objectsToRefresh.length = 0;
			this.stopListening();
		},


		_createUIRepHolder: function () {
			if (!this._UIRepHolder) {
				this._UIRepHolder = UWA.createElement('div').inject(this._experienceBase.webApplication.frmWindow.get3DUIFrame());
				this._UIRepHolder.style.position = 'absolute';
				this._UIRepHolder.style.left = '0px';
				this._UIRepHolder.style.right = '0px';
				this._UIRepHolder.style.top = '0px';
				this._UIRepHolder.style.bottom = '0px';
				this._UIRepHolder.style.pointerEvents = 'none';
			}
		},

		getUIRepHolder: function () {
			if (!this._UIRepHolder) {
				this._createUIRepHolder();
			}
			return this._UIRepHolder;
		},


		/** 
		* Set content 2D content 
        * @public
		* @param  {CATI3DXUIRep} uiRep - ui representation
		*/
		setContent: function (uiRep) {
			if (uiRep === this._uiRep) {
				return;
			}
			this.removeContent();
			this._uiRep = uiRep;
			var rep = uiRep.Get();
			rep.inject(this.getUIRepHolder());
			this._uiRep.Show();
		},

		/** 
		* Remove 2D content
		* @public
		*/
		removeContent: function () {
			if (this._uiRep) {
				var rep = this._uiRep.Get();
				rep.remove();
				this._uiRep.Hide();
				this._uiRep = undefined;
			}
		},

		update: function () {
			for (var i = 0 ; i < this._objectsToRefresh.length; i++) {
				this._objectsToRefresh[i].Refresh();
			}
		},

		postUpdate: function () {
			this._objectsToRefresh.length = 0;
		},

		GetType: function () {
		    return 'CAT3DXUIManager';
		}
	});
	return CAT3DXUIManager;
});


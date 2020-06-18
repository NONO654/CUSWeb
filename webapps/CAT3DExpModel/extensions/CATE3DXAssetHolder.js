/**
* CATE3DXAssetHolder
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DXAssetHolder
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder CATI3DXAssetHolder}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DXAssetHolder',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

function (UWA, CAT3DXInterfaceImpl) {

	'use strict';

	var CATE3DXAssetHolder = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXAssetHolder.prototype **/
	{

		init: function () {
			this._parent();
			this._linkContext = null;
			this._linkDescription = null;
			this._cache = null;
			this._isResolved = false;
		},

		destroy: function () {
			this._parent();
			this._linkContext = null;
			this._linkDescription = null;
			this._cache = null;
			this._isResolved = false;
		},

		setLinkContext: function (iLinkContext) {
			this._linkContext = iLinkContext;
			this._isResolved = false;
		},

		getLinkContext: function () {
			return this._linkContext;
		},

		setLinkDescription: function (iLinkDescription) {
			this._linkDescription = iLinkDescription;
			this._isResolved = false;
		},

		getLinkDescription: function () {
			return this._linkDescription;
		},

		setCache: function (iCache) {
			this._cache = iCache;
		},

		getCache: function () {
			return this._cache;
		},

		copyFrom: function (iSource) {
			this._linkContext = iSource._linkContext;
			this._linkDescription = iSource._linkDescription;
			this._cache = iSource._cache;
		},

		resolveAsset: function () {
			this._isResolved = true;
		},

		isResolved: function () {
			return this._isResolved;
		}

	});

	return CATE3DXAssetHolder;

});

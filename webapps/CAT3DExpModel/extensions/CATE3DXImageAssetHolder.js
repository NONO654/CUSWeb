/**
* CATE3DXImageAssetHolder
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DXImageAssetHolder
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder CATI3DXAssetHolder}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DXImageAssetHolder',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/extensions/CATE3DXAssetHolder'
],

// Declaration
function (UWA, Promise, CATE3DXAssetHolder) {

	'use strict';

	var CATE3DXImageAssetHolder = CATE3DXAssetHolder.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXImageAssetHolder.prototype **/
	{

		init: function () {
			this._parent();
			this._image = null;
		},

		destroy: function () {
			this._parent();
			this._image = null;
		},

		setLinkDescription: function (iLinkDescription) {
			this._parent(iLinkDescription);
		},

		resolveAsset: function () {
			if (this._image) {
				return UWA.Promise.resolve(this._image);
			}

			if(this._imageDeferred) {
			    return this._imageDeferred.promise;
			}		

			var linkDescription = this.getLinkDescription();		
			if (linkDescription) {
			    this._imageDeferred = UWA.Promise.deferred();
			    var self = this;
			    this.getLinkContext().resolveLinkAsStream(linkDescription).done(function (iStream) {
			        var reader = new FileReader();
			        reader.onloadend = function (e) {
			            self._image = new Image();
			            self._image.src = e.target.result;
			            self._isResolved = true;
			            self._imageDeferred.resolve(self._image);
			        };
			        reader.readAsDataURL(iStream);
			    });
			    return this._imageDeferred.promise;
			}
			else {
			    console.warn("unable to resolve image asset");
			    return UWA.Promise.resolve(null); // resolve to avoid exception, media should provide streams by R420 FD02
			}
		}

	});

	return CATE3DXImageAssetHolder;

});

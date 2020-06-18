/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXAssetHolderManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXAssetHolderManager',
[
	'UWA/Core',
	'DS/WebApplicationBase/W3AAManager',
    'UWA/Class/Events'

],
function (UWA, W3AAManager, Events) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/managers/CAT3DXAssetHolderManager
    * @category Manager
    *
    * @description
    * Manage asset holder loading. 
    *
    * @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	*/
	var CAT3DXAssetHolderManager = UWA.Class.extend(W3AAManager, Events,
	/** @lends DS/CAT3DExpModel/managers/CAT3DXAssetHolderManager.prototype **/
	{

		init: function () {
		    this._assetHolders = [];
		},

		/** 
		* register to this manager.
        * @public
		* @param  {Object} iAssetHolder - CATI3DXAssetHolder interface of the component
		*/
		registerAssetHolder: function (iAssetHolder) {
		    this._assetHolders.push(iAssetHolder);
		},

		/** 
		* Notify the manager that asset holder is resolved. If internal list is empty => send an event
        * @public
		* @param  {Object} iAssetHolder - CATI3DXAssetHolder interface of the component
		*/
		assetHolderResolved: function (iAssetHolder) {
		    for (var i = 0 ; i < this._assetHolders.length ; i++) {
		        if (iAssetHolder === this._assetHolders[i]) {
		            this._assetHolders.splice(i, 1);
		            if (this._assetHolders.length === 0) {
		                this.dispatchEvent('assetHoldersLoaded');
		            }
		            return;
		        }
		    }
		    console.warn('CAT3DXAssetHolderManager.assetHolderResolved() : unable to find asset holder in internal list ' + iAssetHolder.getID());
		},

	    /** 
        * tell if manager has registered assets
        * @public
        * @returns  {boolean} true if has at least 1 registerd asset, false otherwise
        */
		hasRegisteredAssets: function () {
		    if (this._assetHolders.length>0) {
		        return true;
		    }
		    else {
		        return false;
		    }
		},

		GetType: function () {
			return 'CAT3DXAssetHolderManager';
		}

	});
	return CAT3DXAssetHolderManager;
});

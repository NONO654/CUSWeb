/**
* CATE3DXExperienceAssetHolder
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DXExperienceAssetHolder
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXAssetHolder CATI3DXAssetHolder}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DXExperienceAssetHolder',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/extensions/CATE3DXAssetHolder'
],

// Declaration
function (UWA, Promise, CATE3DXAssetHolder) {

	'use strict';

	var CATE3DXExperienceAssetHolder = CATE3DXAssetHolder.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXExperienceAssetHolder.prototype **/
	{

		/**  
		* @public
		*/
		init: function () {
			this._parent();
			this._isResolved = true;
		}

	});

	return CATE3DXExperienceAssetHolder;

});

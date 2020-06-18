/**
 * CATECXPPictureResource
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPPictureResource
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPPictureResource CATICXPPictureResource}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPPictureResource',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],
function (
    UWA, CAT3DXInterfaceImpl) {
	'use strict';
	/**
	
	 * @category Extension
	 * @name DS/CATCXPModel/extensions/CATECXPPictureResource
	 * @constructor
	 */
	var CATECXPPictureResource = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPPictureResource.prototype **/
    {

    	GetPictureSizeInPixel: function () {
    		var self = this;
    		return new UWA.Promise(function (iSuccess) {
    			self.QueryInterface('CATI3DXAssetHolder').resolveAsset().done(function (iImage) {
    				iSuccess({
    					w: iImage.width,
    					h: iImage.height
    				});
    			});
    		});
    	}



    });

	return CATECXPPictureResource;
});


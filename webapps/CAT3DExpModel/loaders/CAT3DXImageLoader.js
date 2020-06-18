/**
 * @exports DS/CAT3DExpModel/loaders/CAT3DXImageLoader
 */
define('DS/CAT3DExpModel/loaders/CAT3DXImageLoader',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/loaders/CAT3DXLoader',
	'DS/CAT3DExpModel/CAT3DXModel'
],
function (UWA, Promise, Loader, CAT3DXModel) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/loaders/CAT3DXImageLoader
	* @description 
	* loader resolving images with a link context
    * @constructor
	* @augments  DS/CAT3DExpModel/loaders/CAT3DXLoader
	*/

	var CAT3DXImageLoader = Loader.extend(
	/** @lends DS/CAT3DExpModel/loaders/CAT3DXImageLoader **/
	{

		loadLink: function (iLink, iLinkContext) {
			// create the resource
			var imageRsc;
			return CAT3DXModel.CreateResourceFromAsset('CXPPictureResource_Spec', iLinkContext.getNameForLinkDescription(iLink), iLinkContext, iLink).done(function (iResource) {
			    imageRsc = iResource;
			    return CAT3DXModel.CreateUIImage(iLinkContext.getNameForLinkDescription(iLink));
			}).done(function (iUIActor) {
			    iUIActor.QueryInterface('CATI3DExperienceObject').GetValueByName('data').QueryInterface('CATI3DExperienceObject').SetValueByName('image', imageRsc);
				return iUIActor;
			});
		}

	});

	return CAT3DXImageLoader;

});


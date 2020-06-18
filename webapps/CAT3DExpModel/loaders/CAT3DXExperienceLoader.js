/**
 * @exports DS/CAT3DExpModel/loaders/CAT3DXExperienceLoader
 */
define('DS/CAT3DExpModel/loaders/CAT3DXExperienceLoader',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/loaders/CAT3DXLoader',
    'DS/CAT3DExpModel/CAT3DXModel'
],
function (UWA, Promise, Loader, CAT3DXModel) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/loaders/CAT3DXExperienceLoader
	* @description 
	* Model loader resolving object with a link context
    * @constructor
	* @augments  DS/CAT3DExpModel/loaders/CAT3DXLoader
	*/

	var CAT3DXExperienceLoader = Loader.extend(
	/** @lends DS/CAT3DExpModel/loaders/CAT3DXExperienceLoader **/
	{

        loadLink: function (iLink, iLinkContext) {
            return CAT3DXModel.LoadExperience(iLinkContext, iLink);
        }
    });

	return CAT3DXExperienceLoader;

});

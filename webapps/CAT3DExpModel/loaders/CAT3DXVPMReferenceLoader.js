/**
 * @exports DS/CAT3DExpModel/loaders/CAT3DXVPMReferenceLoader
 */
define('DS/CAT3DExpModel/loaders/CAT3DXVPMReferenceLoader',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/loaders/CAT3DXLoader',
	'DS/CAT3DExpModel/CAT3DXModel'

],
function (UWA, Promise, Loader, CAT3DXModel) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/loaders/CAT3DXVPMReferenceLoader
	* @description 
	* loader resolving VPM references with a link context
    * @constructor
	* @augments  DS/CAT3DExpModel/loaders/CAT3DXLoader
	*/

	var CAT3DXVPMReferenceLoader = Loader.extend(
	/** @lends DS/CAT3DExpModel/loaders/CAT3DXVPMReferenceLoader **/
	{

	    loadLink: function (iLink, iLinkContext) {
	        var experience = CAT3DXModel.GetExperience();
	        return CAT3DXModel.InsertProduct(null, experience, iLinkContext, iLink);
		}
	});

	return CAT3DXVPMReferenceLoader;
});


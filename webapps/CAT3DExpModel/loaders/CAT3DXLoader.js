/**
 * @exports DS/CAT3DExpModel/loaders/CAT3DXLoader
 */
define('DS/CAT3DExpModel/loaders/CAT3DXLoader',
[
	'UWA/Core',
	'UWA/Class/Promise'
],
function (UWA, Promise) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/loaders/CAT3DXLoader
	* @description 
	* Helper class to Load a content using link context paradigm
	* @constructor
	*/

	var CAT3DXLoader = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/loaders/CAT3DXLoader **/
	{
		/**
		* @public
		* @param {object} iExperienceBase - experience base of the web app
		*/
		init: function (iExperienceBase) {
			this._experienceBase = iExperienceBase;
		},

		/**
		* load a link from its link context
		* @public
		* @param {Object} iLink - link to load
		* @param {Object} iLinkContext - link context
        * @return {Promise} promise
		*/
		loadLink: function (iLink, iLinkContext) {
		    return Promise.reject(new Error('not yet implemented' + iLink + iLinkContext));
		}
	});


	return CAT3DXLoader;

});


/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXLoaderManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXLoaderManager',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/WebApplicationBase/W3AAManager',
    'DS/CAT3DExpModel/loaders/CAT3DXExperienceLoader',
	'DS/CAT3DExpModel/loaders/CAT3DXVPMReferenceLoader',
	'DS/CAT3DExpModel/loaders/CAT3DXImageLoader'
],
function (UWA, Promise, W3AAManager, CAT3DXExperienceLoader, CAT3DXVPMReferenceLoader, CAT3DXImageLoader) {
    'use strict';

    /**
	* @name DS/CAT3DExpModel/managers/CAT3DXLoaderManager
    * @category Manager
    *
    * @description
    * Read and Write JSON of an experience
    *
    * @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
    */
    var CAT3DXLoaderManager = W3AAManager.extend(
	/** @lends DS/CAT3DExpModel/managers/CAT3DXLoaderManager.prototype **/
	{

	    init: function () {
	        this._loaders = {};
	    },

	    postInitialize: function () {
	        this._loaders.CXPExperience_Spec = new CAT3DXExperienceLoader(this._experienceBase);
	        this._loaders.Model_VPMReference_Spec = new CAT3DXVPMReferenceLoader(this._experienceBase);
	        this._loaders.CXPPictureResource_Spec = new CAT3DXImageLoader(this._experienceBase);
	    },

	    /**
		* Register a new Loader
        * All loader must extend from DS/CAT3DExpModel/loaders/CAT3DXLoader and implement loadLink function
        * loadLink will return a component from a given type by resolving a linkDescription inside a linkContext
		* @public
		* @param {string}	iType - component type return by the new loader
		* @param {object}	LoaderPrototype - new loader class
		*/
	    registerLoader : function(iType, LoaderPrototype) {
	        this._loaders[iType] = new LoaderPrototype(this._experienceBase);
	    },

	    _getLoader: function (iType) {
	        return this._loaders[iType];
	    },

	    /**
		* LoadLink
        * Retrieve a loader and a linkDescription to create a new component from a given type
		* Warning : Method async
		* @public
		* @param {object}	iLinkContext - LinkContext in which components data must be stored
		* @param {object}	iTypesArray - types of expected components
		* @return {object}	created component
		*/
	    loadLink:function(iLinkContext, iTypesArray){
	        return this._loadLinkAsync(iLinkContext, iTypesArray,0);
	    },

	    _loadLinkAsync: function (iLinkContext, iTypesArray, iIndex) {
	        if (iIndex >= iTypesArray.length) {
	            return UWA.Promise.reject('No match between loader and links');
	        }

	        var type = iTypesArray[iIndex];
	        var loader = this._getLoader(type);
	        if (loader) {
	            var deferred = UWA.Promise.deferred();
	            var self = this;
	            iLinkContext.getLinkDescriptionByType(type).then(function (iLinkDescription) {
	                deferred.resolve(loader.loadLink(iLinkDescription, iLinkContext));
	            }).catch(function () {
	                deferred.resolve(self._loadLinkAsync(iLinkContext, iTypesArray, iIndex + 1));
	            });
	            return deferred.promise;
	        }

	        console.error('No loader for : ' + type);
	        return this._loadLinkAsync(iLinkContext, iTypesArray, iIndex + 1);
	    },

	    readLink: function (iLinkDescription, iLinkContext) {
	        return UWA.Promise.reject('DEPRECATED! use loadLink(iLinkContext, iTypesArray' + iLinkDescription + iLinkContext);
	    },

	    GetType: function () {
	    	return 'CAT3DXLoaderManager';
	    }

	});
    return CAT3DXLoaderManager;
});

/**
 * @exports DS/CAT3DExpModel/loaders/CAT3DXExperienceModelLoader
 */
define('DS/CAT3DExpModel/loaders/CAT3DXExperienceModelLoader',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpModel/loaders/CAT3DXLoader',
	'DS/CAT3DExpModel/CAT3DXJSONReader',
	'DS/CAT3DExpModel/CAT3DXModel'
],
function (UWA, Promise, Loader, JSONReader, CAT3DXModel) {
	'use strict';

	/**
	* @name DS/CAT3DExpModel/loaders/CAT3DXExperienceModelLoader
	* @description 
	* Model loader resolving object with a link context
    * @constructor
	* @augments  DS/CAT3DExpModel/loaders/CAT3DXLoader
	*/

	var CAT3DXExperienceModelLoader = Loader.extend(
	/** @lends DS/CAT3DExpModel/loaders/CAT3DXExperienceModelLoader **/
	{

        loadLink: function (iLink, iLinkContext) {
            var self = this;
            return iLinkContext.resolveLinkAsStream(iLink).done(function (iStream) {
                return self._resolveStreamAsExperienceObject(iStream, iLinkContext);
            });
        },

        _resolveStreamAsExperienceObject: function (stream, iLinkContext) {
            var self = this;
            return new UWA.Promise(function (resolve, reject) {
                var reader = new FileReader();
                reader.onloadend = function (e) {
                	var jsonReader = new JSONReader(CAT3DXModel.getFactory(), self._experienceBase.getManager('CAT3DXLinkManager'));
                    var json = JSON.parse(e.target.result);
                    if (!UWA.is(json)) {
                        reject('invalid string');
                    }
                    jsonReader.read(json, iLinkContext).done(function (iExperienceObject) {
                    	if (UWA.is(iExperienceObject)) {
                    		resolve(iExperienceObject);
                    	}
                    	else {
                    		reject('Invalid JSON');
                    	}
                    });

                };
                reader.readAsText(stream);
            });
        }

    });


    return CAT3DXExperienceModelLoader;

});

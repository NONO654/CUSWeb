/**
 * CAT3DExpRTVLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpRTVLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpRTVLinkContext',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpLinkContext/CAT3DExpLinkContext',
	'DS/WebappsUtils/WebappsUtils'
],
function (UWA, Promise, LinkContext, WebappsUtils) {

	'use strict';

	var CAT3DExpRTVLinkContext = LinkContext.extend(
	/** @lends DS/CAT3DExpLinkContext/CAT3DExpRTVLinkContext.prototype **/
    {

        getJSONDescription: function () {
			return { protocol: 'RTVContent' };
		},

		resolveLinkAsStream: function (iLink) {
			return new Promise(function (resolve, reject) {
				var xhr = new XMLHttpRequest();
				xhr.open('GET', WebappsUtils.getWebappsBaseUrl() + iLink, true);
				xhr.responseType = 'blob';
				xhr.onload = function () {
				    if (this.status === 200) {
				        var format = iLink.split('.').pop();
				        format = format !== '3dxml' ? format : 'xmlv43';
				        this.response.format = format;
				        resolve(this.response);
				    }
				    else {
				        reject(new Error('status !== 200'));
				    }
				};
				xhr.send();
			});
		}
	});

	return CAT3DExpRTVLinkContext;

});

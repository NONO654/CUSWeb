/**
 * CAT3DExpWebLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpWebLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpWebLinkContext', [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/CAT3DExpLinkContext/CAT3DExpLinkContext'
    ],
    function(UWA, Promise, LinkContext ) {

        'use strict';

        var CAT3DExpWebLinkContext = LinkContext.extend(
            /** @lends DS/CAT3DExpLinkContext/CAT3DExpWebLinkContext.prototype **/
            {
                init: function(iOptions) {
                    this._parent();
                    this._baseURL = iOptions.baseURL;
                    this._links = [];
                    this._links.push({
                        StreamName: iOptions.experienceFile
                    });
                },

                getLinkDescriptionByType: function (iType) {
                    for (var i = 0; i < this._links.length; i++) {
                        if (this._getLinkType(this._links[i]) === iType) {
                            return UWA.Promise.resolve(this._links[i]);
                        }
                    }
                    return UWA.Promise.reject();
                },

                _typeExtMap: {
                    '.json': 'CXPExperience_Spec',
                    '.cgr': 'Model_VPMReference_Spec',
                    '.3dxml': 'Model_VPMReference_Spec',
                    '.3dx': 'Model_VPMReference_Spec',
                    '.jpg': 'CXPPictureResource_Spec'
                },

                _getLinkType: function (iLink) {
                    for (var ext in this._typeExtMap) {
                        if (iLink.StreamName.endsWith(ext)) {
                            return this._typeExtMap[ext];
                        }
                    }
                    console.error('unknown link');
                    return undefined;
                },
			
                retrieveLinkDescriptions: function() {
                	return Promise.resolve(this._links);
                },             

                resolveLinkAsStream: function (iLink) {
                    var self = this;
                    return this._httpGet(this._baseURL + iLink.StreamName).done(function (iBlob) {
                        iBlob.format = self._getLinkFormat(iLink);
                        return iBlob;
                    });
                },

                _httpGet: function (iUrl) {
                    var deferred = UWA.Promise.deferred();
                    var xmlhttp = new XMLHttpRequest();
                    xmlhttp.onreadystatechange = function () {
                        if (xmlhttp.readyState === 4) {
                            if (xmlhttp.status === 200) {
                                deferred.resolve(xmlhttp.response);
                            }
                        }
                    };                  
                    xmlhttp.open("GET", iUrl, true);
                    xmlhttp.responseType = "blob";
                    xmlhttp.send();
                    return deferred.promise;
                },

                _formatExtMap: {
                    '.cgr': 'cgr',
                    '.3dxml': 'xmlv43',
                    '.3dx': '3dx',
                },

                _getLinkFormat: function (iLink) {
                    for (var ext in this._formatExtMap) {
                        if (iLink.StreamName.endsWith(ext)) {
                            return this._formatExtMap[ext];
                        }
                    }
                    return undefined;
                },

            });

        return CAT3DExpWebLinkContext;

    });

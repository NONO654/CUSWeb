/**
 * CAT3DExpPlatformMediaLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpPlatformMediaLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpPlatformMediaLinkContext', [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/CAT3DExpLinkContext/CAT3DExpLinkContext',
        'DS/WAFData/WAFData'
    ],
    function (UWA, Promise, LinkContext, WAFData) {

        'use strict';

        var CAT3DExpPlatformMediaLinkContext = LinkContext.extend(
            /** @lends DS/CAT3DExpLinkContext/CAT3DExpPlatformMediaLinkContext.prototype **/
            {
                init: function (iOptions) {
                    this._parent();
                    this._objectId = iOptions.physicalid;
                    this._3DSpaceURL = iOptions.serverurl;
                    this._securityContext = iOptions.contextid;
                },

                getLinkDescriptionByType: function (iType) {
                    if (iType !== 'CXPExperience_Spec') { //resolve only experience
                        return UWA.Promise.reject();
                    }

                    var self = this;
                    return this.retrieveLinkDescriptions().done(function (iLinks) {
                        for (var i = 0; i < iLinks.length; i++) {
                            if (self._getLinkType(iLinks[i]) === iType) {
                                return iLinks[i];
                            }
                        }
                        return UWA.Promise.reject();
                    });
                },

                _typeExtMap: {
                    '.json': 'CXPExperience_Spec',
                    '.cgr': 'Model_VPMReference_Spec',
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

                retrieveLinkDescriptions: function () {
                    if (this._links) {
                        return UWA.Promise.resolve(this._links);
                    }
                    if (this._retrieveLinksDeferred) {
                        return this._retrieveLinksDeferred.promise;
                    }

                    this._retrieveLinksDeferred = UWA.Promise.deferred();
                    var self = this;
                    this._retrieveStreamsDef().done(function (iStreamsDef) {
                        self._links = [];
                        for (var i = 0; i < iStreamsDef.length; i++) {
                            self._links.push({
                                StreamName: iStreamsDef[i].persistencyname
                            });
                        }
                        self._retrieveLinksDeferred.resolve(self._links);
                    });

                    return this._retrieveLinksDeferred.promise;
                },

                _retrieveStreamsDef: function () {
                    if (this._streamsDef) {
                        return UWA.Promise.resolve(this._streamsDef);
                    }
                    if (this._retrieveStreamsDeferred) {
                        return this._retrieveStreamsDeferred.promise;
                    }

                    this._retrieveStreamsDeferred = UWA.Promise.deferred();
                    var self = this;
                    var url = this._3DSpaceURL + '/resources/experience/medias/' + self._objectId + '/streams';
                    WAFData.authenticatedRequest(url, {
                        method: 'GET',
                        type: 'json',
                        headers: {
                            'Content-Type': 'application/json',
                            SecurityContext: this._securityContext
                        },
                        onComplete: function (data) {
                            self._streamsDef = data.results;
                            self._retrieveStreamsDeferred.resolve(self._streamsDef);
                        },
                        onFailure: function (data) {
                            self._retrieveStreamsDeferred.reject(data);
                        }
                    });
                    return this._retrieveStreamsDeferred.promise;
                },

                resolveLinkAsStream: function (iLink) {
                    var type = this._getLinkType(iLink);
                    // used to retrieve a the json stream
                    switch (type) {
                        case 'CXPExperience_Spec':
                            return this._resolveExperienceAsStream(iLink);
                        default:
                            return this._resolveMediaLinkAsBinaryStream(iLink);
                    }
                },

                _retrieveStreamDefByLink: function (iLink) {
                    return this._retrieveStreamsDef().done(function (iStreamsDef) {
                        for (var i = 0; i < iStreamsDef.length; i++) {
                            if (iStreamsDef[i].persistencyname === iLink.StreamName) {
                                return iStreamsDef[i];
                            }
                        }
                        return UWA.Promise.reject('Imposible to retrieve stream def for' + iLink.StreamName);
                    });
                },

                _resolveExperienceAsStream: function (iLink) {
                    var self = this;
                    return this._retrieveStreamDefByLink(iLink).done(function (iStreamDef) {
                        return self._retrieveStream(iStreamDef);

                    }).done(function (iStream) {
                        return new Blob([iStream], {
                            type: 'text/xml'
                        });
                    });
                },

                _resolveMediaLinkAsBinaryStream: function (iLink) {
                    var self = this;
                    return this._retrieveStreamDefByLink(iLink).done(function (iStreamDef) {
                        return self._retrieveStream(iStreamDef, {
                            type: 'arraybuffer',
                            headers: {
                                Accept: 'text/plain'
                            }
                        });
                    }).done(function (iStream) {
                        var blob = new Blob([iStream], {
                            type: 'application/octet-binary'
                        });
                        blob.format = self._getLinkFormat(iLink);
                        blob.filename = iLink.StreamName;
                        return blob;
                    });
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

                /**
                * retrieve the content of a specific stream. 
                * @method
                * @private
                * @param {Object} iStreamDef
                *    -> streaminfos.physicalid : the physicalid of the media
                *    -> streaminfos.persistencyname : the stream file name
                * @param {Object} iOptions options
                * @return {Promise} promise
                */
                _retrieveStream: function (iStreamDef, iOptions) {
                    var self = this;
                    return this._retreiveStreamInfo(iStreamDef).done(function (iStreamInfo) {
                        return self._retrieveStreamContent(iStreamInfo, iOptions);
                    });
                },

                /**
                * retrieve stream info
                * @method
                * @private
                * @param {Object} iStreamDef
                *    -> streamDef.physicalid : the physicalid of the media
                *    -> streamDef.persistencyname : the stream file name
                * @return {Promise} promise
                */
                _retreiveStreamInfo: function (iStreamDef) {
                    var deferred = UWA.Promise.deferred();
                    var url = this._3DSpaceURL + '/resources/experience/medias/' + iStreamDef.physicalid + '/streams/' + iStreamDef.persistencyname;
                    WAFData.authenticatedRequest(url, {
                        method: 'GET',
                        type: 'json',
                        headers: {
                            'Content-Type': 'application/json',
                            SecurityContext: this._securityContext
                        },
                        onComplete: function (data) {
                            deferred.resolve(data.results[0]);
                        },
                        onFailure: function (data) {
                            deferred.reject(data);
                        }
                    });
                    return deferred.promise;
                },

                /**
                * Retrieve the content of a stream descriptor
                * @method
                * @private
                * @param {object} iStreaminfos, a Json object containing the stream descriptor informations to retrieve                
                * @param {object} iOptions to set type and headers of the config object
                * @return {Promise} promise
                */
                _retrieveStreamContent: function (iStreaminfos, iOptions) {
                    var options = iOptions ? iOptions : {};

                    var deferred = UWA.Promise.deferred();

                    var config = {
                        timeout: options.timeout ? options.timeout : 100000,
                        method: options.method ? options.method : 'POST',
                        data: '__fcs__jobTicket=' + encodeURIComponent(iStreaminfos.ticket),
                        type: options.type ? options.type : 'text',
                        headers: options.headers ? options.headers : {
                            'Content-type': 'application/x-www-form-urlencoded',
                            Accept: 'text/plain'
                        },
                        onComplete: function (iStreamcontent) {
                            deferred.resolve(iStreamcontent);
                        },
                        onFailure: function (data) {
                            deferred.reject(data);
                        }
                    };

                    config.proxy = 'passport';
                    WAFData.authenticatedRequest(iStreaminfos.fcsurl, config);
                    return deferred.promise;
                }
            });

        return CAT3DExpPlatformMediaLinkContext;
    });

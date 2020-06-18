/**
 * CAT3DExpZipLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpZipLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpZipLinkContext', [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/CAT3DExpLinkContext/CAT3DExpLinkContext',
        'DS/ZipJS/zip'
    ],
    function (UWA, Promise, CAT3DExpLinkContext, zip) {

        'use strict';

        var CAT3DExpZipLinkContext = CAT3DExpLinkContext.extend(
            /** @lends DS/CAT3DExpLinkContext/CAT3DExpZipLinkContext.prototype **/
            {

                init: function (iBlob) {
                    this._blob = new Blob([iBlob], {
                        type: 'application/zip'
                    });
                    this._blobReader = new zip.BlobReader(this._blob);
                    this._links = null;
                    this._entries = null;
                },

                getLinkDescriptionByType: function (iType) {
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
                    '.jpg': 'CXPPictureResource_Spec',
                    '.bmp': 'CXPPictureResource_Spec',
                    '.png': 'CXPPictureResource_Spec'
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
                    this._retrieveEntries().done(function (iEntries) {
                        self._links = [];
                        for (var i = 0; i < iEntries.length; i++) {
                            self._links.push({
                                StreamName: iEntries[i].filename
                            });
                        }
                        self._retrieveLinksDeferred.resolve(self._links);
                    });
                    return this._retrieveLinksDeferred.promise;
                },

                _retrieveEntries: function () {
                    if (this._entries) {
                        return UWA.Promise.resolve(this._entries);
                    }
                    if (this._retrieveEntriesDeferred) {
                        return this._retrieveEntriesDeferred.promise;
                    }

                    this._retrieveEntriesDeferred = UWA.Promise.deferred();
                    var self = this;
                    zip.createReader(this._blobReader, function (reader) {
                        reader.getEntries(function (iEntries) {
                            self._entries = iEntries;
                            self._retrieveEntriesDeferred.resolve(self._entries);
                        });
                    });
                    return this._retrieveEntriesDeferred.promise;
                },

                resolveLinkAsStream: function (iLinkDescription) {
                    var self = this;
                    return this._retrieveEntries().done(function (iEntries) {
                        for (var i = 0; i < iEntries.length; i++) {
                            if (iEntries[i].filename === iLinkDescription.StreamName) {
                                var deferred = UWA.Promise.deferred();
                                iEntries[i].getData(new zip.BlobWriter(), function (blob) {
                                    blob.name = iEntries[i].filename;
                                    blob.format = self._getLinkFormat(iLinkDescription);
                                    deferred.resolve(blob);
                                });
                                return deferred.promise;
                            }                       
                        }
                        return UWA.Promise.reject('Unknown Link');
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

                getNameForLinkDescription: function (iLinkDescription) {
                    var dotPos = iLinkDescription.StreamName.lastIndexOf('.');
                    return (dotPos !== -1) ? iLinkDescription.StreamName.substr(0, dotPos) : iLinkDescription.StreamName;
                },

            });


        return CAT3DExpZipLinkContext;

    });

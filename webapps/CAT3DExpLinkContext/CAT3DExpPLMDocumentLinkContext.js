/** 
 * CAT3DExpPLMDocumentLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpPLMDocumentLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpPLMDocumentLinkContext',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpLinkContext/CAT3DExpLinkContext',
    'DS/DocumentManagement/DocumentManagement',
    'DS/WAFData/WAFData',
    'DS/CAT3DExpModel/CAT3DXModel'
],
function (UWA, Promise, CAT3DExpLinkContext, DocumentManagement, WAFData, CAT3DXModel) {
    'use strict';

    var CAT3DExpPLMDocumentLinkContext = CAT3DExpLinkContext.extend(
	/** @lends DS/CAT3DExpLinkContext/CAT3DExpPLMDocumentLinkContext.prototype **/
    {

        init: function (iOptions) {
            this._objectId = iOptions.objectId;
        },

        getLinkDescriptionByType: function (iType) {
            var deferred = UWA.Promise.deferred();
            this.retrieveLinkDescriptions().done(function (iDescriptions) {
                // check extension
                var extension = iDescriptions[0].split('.')[1];
                if (extension === "ctps" && iType === 'CityPresentation') {
                    deferred.resolve(iDescriptions[0]);
                }
                else if ((extension === "json" || extension === "ctxp") && iType === 'CIDComponentCityAsset') {
                    deferred.resolve(iDescriptions[0]);
                }
                if (extension === "exprd" && iType === 'ProductPresentation')
                {
                    deferred.resolve(iDescriptions[0]);
                }
                else {
                    deferred.reject();
                }
            });
            return deferred.promise;
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
            this._getFilesInfo().done(function (iFilesInfo) {
                self._links = iFilesInfo.map(function (el) {
                    return el.fileName;
                });
                self._retrieveLinksDeferred.resolve(self._links);
            });

            return this._retrieveLinksDeferred.promise;
        },

        _getFilesInfo: function () {
            if (this._filesInfo) {
                return UWA.Promise.resolve(this._filesInfo);
            }

            if (this._filesInfoDeferred) {
                return this._filesInfoDeferred;
            }

            this._filesInfoDeferred = UWA.Promise.deferred();
            var self = this;
            var tenant, tenantUrl;
            CAT3DXModel.getFactory().getPlatformId().done(function (iPlatformId) {
                tenant = iPlatformId;
                return CAT3DXModel.getFactory().getServerURL()
            }).done(function (iServerURL) {
                tenantUrl = iServerURL;
                return CAT3DXModel.getFactory().getSecurityContext()
            }).done(function (iSecurityContext) {
                DocumentManagement.getDocuments([self._objectId], {
                    tenant: tenant,
                    tenantUrl: tenantUrl,
                    securityContext: iSecurityContext,
                    onComplete: function (iData) {
                        if (iData.data.length < 1) {
                            self._filesInfoDeferred.reject(iData);
                            return;
                        }

                        var files = iData.data[0].relateddata.files;
                        self._filesInfo = [];
                        for (var i = 0; i < files.length; i++) {
                            self._filesInfo.push({
                                id: files[i].id,
                                fileName: files[i].dataelements.title
                            });
                        }
                        self._filesInfoDeferred.resolve(self._filesInfo);

                    },
                    onFailure: function (iData) {
                        self._filesInfoDeferred.reject(iData);
                    }
                });
            });
            return this._filesInfoDeferred.promise;
        },

        _getFileId: function (iFileName) {
            return this._getFilesInfo().done(function (iFilesInfo) {
                for (var i = 0; i < iFilesInfo.length; I++) {
                    if (iFilesInfo[i].fileName === iFileName) {
                        return iFilesInfo[i].id;
                    }
                }
                return UWA.Promise.reject();
            });
        },

        _getFileURL: function (iFileId) {
            var deferred = UWA.Promise.deferred();
            var self = this;
            var tenant, tenantUrl;
            CAT3DXModel.getFactory().getPlatformId().done(function (iPlatformId) {
                tenant = iPlatformId;
                return CAT3DXModel.getFactory().getServerURL()
            }).done(function (iServerURL) {
                tenantUrl = iServerURL;
                return CAT3DXModel.getFactory().getSecurityContext()
            }).done(function (iSecurityContext) {
                DocumentManagement.downloadDocument([self._objectId], iFileId, false, {
                    tenant: tenant,
                    tenantUrl: tenantUrl,
                    securityContext: iSecurityContext,
                    onComplete: function (iUrl) {
                        deferred.resolve(iUrl);
                    },
                    onFailure: function (iData) {
                        deferred.reject(iData);
                    }
                });
            });
            return deferred.promise;
        },

        _getFile: function (iFileName) {

            var self = this;
            return this._getFileId(iFileName).done(function (iFileId) {
                return self._getFileURL(iFileId);
            }).done(function (iFileUrl) {
                var deferred = UWA.Promise.deferred();
                WAFData.authenticatedRequest(iFileUrl, {
                    method: 'GET',
                    type: 'json',
                    headers: { 'content-type': 'application/json' },
                    proxy: 'passport',
                    onComplete: function (iDocument) {
                        deferred.resolve(new Blob([JSON.stringify(iDocument)], { type: "text/plain;charset=utf-8" }));
                    },
                    onFailure: function (iData) {
                        deferred.reject(iData);
                    }
                });

                return deferred.promise;
            });

        },

        resolveLinkAsStream: function (iLinkDescription) {
            return this._getFile(iLinkDescription).done(function (iFile) {
                return iFile;
            });
        },

        getJSONDescription: function () {
            return {
                protocol: 'PLMDoc',
                objectId: this._objectId
            };
        },

        pushStream: function (iStream) {
            var filename = iStream.name;
            var promise = new Promise(function (resolve, reject) {

                var documentInfo = {
                    title: filename,
                    type: 'Document',
                    policy: 'Document Release',
                    fileInfo: {
                        file: iStream
                    }
                };

                var tenant, tenantUrl;
                CAT3DXModel.getFactory().getPlatformId().done(function (iPlatformId) {
                    tenant = iPlatformId;
                    return CAT3DXModel.getFactory().getServerURL()
                }).done(function (iServerURL) {
                    tenantUrl = iServerURL;
                    return CAT3DXModel.getFactory().getSecurityContext()
                }).done(function (iSecurityContext) {
                    var options = {
                        tenant: tenant,
                        tenantUrl: tenantUrl,
                        securityContext: iSecurityContext,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    DocumentManagement.createDocument(documentInfo, options);
                });
            });

            return promise;
        }
    });

    return CAT3DExpPLMDocumentLinkContext;

});

/**
 * @exports DS/CAT3DExpLinkContext/CAT3DExpLinkContextFactory
 */
define('DS/CAT3DExpLinkContext/CAT3DExpLinkContextFactory', [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/CAT3DExpModel/CAT3DXModel',
        'DS/CAT3DExpLinkContext/CAT3DExpFilesLinkContext',
        'DS/CAT3DExpLinkContext/CAT3DExpLocalStorageLinkContext',
        'DS/CAT3DExpLinkContext/CAT3DExpRTVLinkContext',
        'DS/CAT3DExpLinkContext/CAT3DExpZipLinkContext',
        'DS/CAT3DExpLinkContext/CAT3DExpPLMDocumentLinkContext',
    ],
    function (UWA, Promise, CAT3DXModel,
        FilesLinkContext, LocalStorageLinkContext,
        RTVLinkContext, CXPZipLinkContext, CAT3DExpPLMDocumentLinkContext) {

        'use strict';

        /**
         * @name DS/CAT3DExpLinkContext/CAT3DExpLinkContextFactory
         * @constructor
         * @augments DS/WebApplicationBase/W3AAManager
         */

        var LinkContextFactory = UWA.Class.extend(
            /** @lends DS/CAT3DExpLinkContext/CAT3DExpLinkContextFactory.prototype **/
            {
                init: function (iExperienceBase) {
                    this._experienceBase = iExperienceBase;
                    this._dataTransferLinkContext = [{
                        constructor: LocalStorageLinkContext,
                        description: {
                            objectType: 'CAT3DExpLocalStorage'
                        }
                    }, {
                        constructor: CAT3DExpPLMDocumentLinkContext,
                        description: {
                            objectType: 'Document',
                            serviceId: '3DSpace'
                        }
                    }];
                    this._jsonDescriptionLinkContext = [{
                        constructor: LocalStorageLinkContext,
                        description: {
                            objectType: 'CAT3DExpLocalStorage'
                        }
                    },
                    {
                        constructor: CAT3DExpPLMDocumentLinkContext,
                        description: {
                            protocol: 'PLMDoc'
                        }
                    }];
                },

                registerLinkContextForDatatransfer: function (iLinkContextConstructor, iDatatransferDescription) {
                    this._dataTransferLinkContext.push({
                        constructor: iLinkContextConstructor,
                        description: iDatatransferDescription
                    });
                },

                getLinkContextFromDataTransfer: function (iDataTransfer) {
                    if (iDataTransfer.files.length > 0) {
                        // with one and only one '3dx' file, use it as the current context
                        if (iDataTransfer.files.length === 1 && iDataTransfer.files[0].name.endsWith('.3dx')) {
                            return new CXPZipLinkContext(iDataTransfer.files[0]);
                        }
                        return new FilesLinkContext(iDataTransfer.files);
                    }

                    try {
                        var dataPlainText = JSON.parse(iDataTransfer.getData('text/plain'));
                        var item = dataPlainText.data.items[0];
                        for (var i = 0; i < this._dataTransferLinkContext.length; i++) {
                            if (this._isObjectMatchDescription(item, this._dataTransferLinkContext[i].description)) {
                                return new this._dataTransferLinkContext[i].constructor(item);
                            }
                        }
                        console.error('cannot retrieve link context');
                        return undefined;
                    } catch (e) {
                        console.error('cannot compute link context : error parsing data');
                        return undefined;
                    }
                },

                _isObjectMatchDescription: function (iItem, iDescription) {
                    for (var key in iDescription) {
                        if (iItem[key] !== iDescription[key]) {
                            return false;
                        }
                    }
                    return true;
                },

                registerLinkContextForJSONDescription: function (iLinkContextConstructor, iDescription) {
                    this._jsonDescriptionLinkContext.push({
                        constructor: iLinkContextConstructor,
                        description: iDescription
                    });
                },

                getLinkContextFromJSONDescription: function (iDescription) {
                    for (var i = 0; i < this._jsonDescriptionLinkContext.length; i++) {
                        if (this._isObjectMatchDescription(iDescription, this._jsonDescriptionLinkContext[i].description)) {
                            return new this._jsonDescriptionLinkContext[i].constructor(iDescription);
                        }
                    }
                    return undefined;
                },
            });


        return LinkContextFactory;

    });

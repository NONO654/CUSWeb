/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXLinkManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXLinkManager', [
        'UWA/Core',
        'DS/CAT3DExpLinkContext/CAT3DExpLinkContextFactory',
        'DS/WebApplicationBase/W3AAManager'
    ],
    function(UWA, LinkContextFactory, W3AAManager) {

        'use strict';

        /**
         * @name DS/CAT3DExpModel/managers/CAT3DXLinkManager
         * @category Manager
         * @constructor
         * @augments DS/WebApplicationBase/W3AAManager
         */

        var CAT3DXLinkManager = UWA.Class.extend(W3AAManager,
            /** @lends DS/CAT3DExpModel/managers/CAT3DXLinkManager.prototype **/
            {

				init:function() {
					this._lcFactory = null ;
				},

				initialize: function () {
					this._lcFactory = new LinkContextFactory(this._experienceBase);
				},

				registerLinkContextForDatatransfer: function (iLinkContextConstructor, iDatatransferDescription) {
				    this._lcFactory.registerLinkContextForDatatransfer(iLinkContextConstructor, iDatatransferDescription);
				},

				registerLinkContextForJSONDescription: function (iLinkContextConstructor, iDescription) {
				    this._lcFactory.registerLinkContextForJSONDescription(iLinkContextConstructor, iDescription);
				},

				getLinkContextFromDataTransfer: function(iDataTransfer) {
					return this._lcFactory.getLinkContextFromDataTransfer(iDataTransfer);
                },

                getLinkContextFromJSONDescription: function(iDescription) {
                    return this._lcFactory.getLinkContextFromJSONDescription(iDescription);
                },

                GetType: function() {
                	return 'CAT3DXLinkManager';
                }

            });


        return CAT3DXLinkManager;

    });

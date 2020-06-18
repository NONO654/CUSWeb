/**
 * @overview Extends `UWA/Ajax` for handling passport auth redirect.
 */

/* global define:false */

define('ds/Ajax',
    [
        'UWA/Core',
        'UWA/Ajax',
        'UWA/Utils',
        'DS/PlatformAPI/PlatformAPI',
        'DS/WAFData/WAFData',
        'DS/UIKIT/SuperModal'
    ],

    /**
     * Extends `UWA/Ajax` for handling passport auth redirect.
     *
     * @module ds/Ajax
     *
     * @requires module:UWA/Core
     * @requires module:UWA/Ajax
     * @requires module:UWA/Utils
     * @requires module:ds/PlatformAPI/PlatformAPI
     * @requires module:DS/WAFData/WAFData
     * @requires module:DS/UIKIT/SuperModal
     *
     * @extends  module:UWA/Core
     */
    function (UWA, UWAAjax, Utils, PlatformAPI, WAFData, SuperModal) {

        'use strict';

        var exports = {},
            passportURL,
            errorsModalClassName = 'session-expiration-modal',
            onStateChangePrototype = UWAAjax.onStateChange,
            requestReload = function (title, message, url) {
                var env = window === window.top ? window : window.top,
                    modalAlreadyDisplayed = env && env.document.querySelector('.' + errorsModalClassName),
                    superModal;

                if (!env || modalAlreadyDisplayed) { return; }

                superModal = new SuperModal({ className: errorsModalClassName, renderTo: env.document.body });
                superModal.confirm({
                    title: title,
                    message: message.split('. ').join('.\n'),
                    callback: function (confirmed) {
                        if (confirmed) {
                            if (url) {
                                env.location = url;
                            } else {
                                env.location.reload();
                            }
                        }
                    }
                });
                superModal.modals.current.elements.container.setStyle('white-space', 'pre-line');
            };

        /**
         * Generic handling of CORS / Passport flow errors.
         * This could be called from a framed widget so be careful with the window object to use.
         */
        exports.setWAFDataErrorHandler = function () {
            // WAFData 401 / 403 Passport error : logout.
            // IMPORTANT : only if the provided Passport url is same as Widget Platform Passport.
            if (!WAFData.passportErrorHandler) {
                WAFData.setErrorHandler(function (errorMessage, authURL) {
                    var env = window === window.top ? window : window.top,
                        parsedPassportURL,
                        parsedAuthUrl,
                        samePassport;

                    passportURL = PlatformAPI.getApplicationConfiguration('app.urls.passport');
                    parsedPassportURL = passportURL && Utils.parseUrl(passportURL);
                    parsedAuthUrl = authURL && Utils.parseUrl(authURL);
                    samePassport = passportURL && parsedAuthUrl && parsedPassportURL.domain === parsedAuthUrl.domain && parsedPassportURL.port === parsedAuthUrl.port;

                    if (env && samePassport) {
                        requestReload(env.UWA.i18n('sessionExpirationTitle'), env.UWA.i18n('sessionExpirationMessage'), env.dsBaseUrl + 'logout?redirectUrl=' + encodeURIComponent(env.location.href));
                    }
                });
            }
        };

        // Set error handler for current environment
        exports.setWAFDataErrorHandler();

        UWAAjax.onStateChange = function (request, options, xhr) {
            var response,
                env = window === window.top ? window : window.top;

            if (request.readyState === 4) {
                if (request.status && !request.timedout && !request.aborted) {
                    // Proxy passport auth session/PGt error
                    if ((request.status === 403 && request.responseText === 'PGT is no more valid') ||
                        (request.status === 401 && request.responseText.indexOf('Invalid, expired or missing authenticated session.') >= 0)) {
                        requestReload(env.UWA.i18n('sessionExpirationTitle'), env.UWA.i18n('sessionExpirationMessage'));
                    }
                    // CORS Passport session/PGT error
                    if (request.status === 401) {
                        try {
                            response = JSON.parse(request.responseText);
                            if (response.error === 'invalid_client' && typeof response.x3ds_auth_url === 'string') {
                                PlatformAPI.getApplicationConfiguration('app.urls.passport');
                                passportURL = PlatformAPI.getApplicationConfiguration('app.urls.passport');
                                if (passportURL && passportURL === response.x3ds_auth_url) {
                                    if (env) {
                                        env.location = env.dsBaseUrl + 'logout';
                                    }
                                }
                                return;
                            }
                        } catch (e) {
                            // do nothing
                        }
                    }
                    // CORS Passport client
                    if (request.status === 400) {
                        var _options = options;
                        try {
                            response = JSON.parse(request.responseText);
                            if (typeof response === 'object' && response.error === 'invalid_grant' && typeof response.x3ds_auth_url === 'string') {
                                options = {};
                                // Add empty onFailure function to avoid printing error on console
                                options.onFailure = function () { };
                                UWAAjax.request(response.x3ds_auth_url, {
                                    cors: true,
                                    withCredentials: true,
                                    headers: { 'X-Requested-With': 'XMLHttpRequest' },
                                    onComplete: function (result) {
                                        var o = JSON.parse(result);
                                        if (typeof o === 'object' && o.access_token && o.x3ds_service_url) {
                                            var serviceUrl = Utils.parseUrl(o.x3ds_service_url);
                                            if (serviceUrl.query === '') {
                                                serviceUrl.query = 'ticket=' + o.access_token;
                                            } else {
                                                var queriesString = Utils.parseQuery(serviceUrl.query);
                                                queriesString.ticket = o.access_token;
                                                serviceUrl.query = Utils.toQueryString(queriesString);
                                            }
                                            UWAAjax.request(Utils.composeUrl(serviceUrl), _options);
                                        }
                                    }
                                });
                            }
                        } catch (e) {
                            // do nothing
                        }
                    }
                }
                onStateChangePrototype(request, options, xhr);
            }
        };

        return exports;
    });

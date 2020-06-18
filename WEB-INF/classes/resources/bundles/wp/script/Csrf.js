/**
 * @overview Determines the current mode (normal or debug_me mode).
 * @author t5e
 */
/*global dsCsrfOptions*/
define('ds/Csrf',
        ['UWA/Utils'],
        /**
        * Determines the current mode (normal or debug_me mode).
        * @module ds/Csrf
        */
        function (Utils) {

        'use strict';

        var started = false,
            xRequestedWithParam = 'X-Requested-With',
            options,
            exports;


        function getCookieValue(cookieName) {
            var result;
            return (result = new RegExp('(?:^|; )' + encodeURIComponent(cookieName) + '=([^;]*)').exec(document.cookie)) ? (result[1]) : null;
        }

        function getPort(port, protocol) {
            if (!port) {
                if (protocol === 'http' || protocol === 'http:') {
                    return "80";
                }
                if (protocol === 'https' || protocol === 'https:') {
                    return "443";
                }
                return "-1";
            }

            return port;
        }

        function isValidPort(port, protocol) {
            var current = getPort(document.location.port, document.location.protocol);

            if (options.domainStrict === true) {
                return current === getPort(port, protocol);
            }

            return true;
        }

        function isValidDomain(target) {
            var current = document.domain,
                result = false,
                suffix;

            if (current === target) {
                result = true;
            } else if (options.domainStrict === false) {
                if (target.charAt(0) === '.') {
                    result = current.indexOf(target, current.length - target.length) !== 1;
                } else {
                    suffix = '.' + target;
                    result = current.indexOf(suffix, current.length - suffix.length) !== 1;
                }
            }
            return result;
        }

        function isValidUrl(url) {
            var result = false,
                parsedUrl = Utils.parseUrl(url);

            if ((parsedUrl.protocol === 'http') || (parsedUrl.protocol === 'https')) {
                result = isValidDomain(parsedUrl.domain) && isValidPort(parsedUrl.port, parsedUrl.protocol);
            } else if (url.charAt(0) === '#') {
                // Skip anchor url
                result = false;
            } else if (url.indexOf('//') !== 0 && (url.charAt(0) === '/' || url.indexOf(':') === -1)) {
                // Authorize local resource
                result = true;
            }

            return result;
        }

        function refreshToken() {
            if (options !== 'undefined' && options.cookieName !== 'undefined') {
                var token = getCookieValue(options.cookieName);
                if (token && token !== options.token) {
                    options.token = token;
                }
            }
        }

        function start() {
            if (started) {
                return;
            }

            try {
                if (typeof dsCsrfOptions === 'undefined') {
                    options = window.parent.dsCsrfOptions;
                } else {
                    options = dsCsrfOptions;
                }
            } catch (e) {}

            // If not CSRF options found inside JS variable try to get it from API
            if (typeof options === 'undefined') {
                require(['DS/UWPClientCode/Data'], function (Data) {
                    Data.request({
                        url: 'api/security/csrf',
                        method: 'GET',
                        success: function (result) {
                            options = result;
                            injectToken(options);
                        }
                    });
                });
            } else {
                injectToken(options);
            }

            started = true;
        }

        function injectToken(options) {
            // Disable protection if no options is passed
            if (typeof options === 'undefined') {
                options = {};
                options.protection = false;
            }

            if (options.protection && isValidDomain(options.domainOrigin)) {
                XMLHttpRequest.prototype._open = XMLHttpRequest.prototype.open;
                XMLHttpRequest.prototype.open = function (method, url, async, user, pass) {
                    this.url = url;
                    this._open.apply(this, arguments);
                };

                XMLHttpRequest.prototype._send = XMLHttpRequest.prototype.send;
                XMLHttpRequest.prototype.send = function (data) {
                    if (isValidUrl(this.url)) {
                        // Refresh token in case of SPA
                        // I mean token is by default injected only 1 time at loading page
                        // We're now using Cookie that could be refreshed without reloading page
                        refreshToken();
                        this.setRequestHeader(xRequestedWithParam, options.xRequestedWith);
                        this.setRequestHeader(options.param, options.token);
                    }

                    this._send.call(this, data);
                };
            }
        }

        exports = {
            getOptions: function () {
                if (started) {
                    return options;
                }

                return null;
            },
            getToken: function () {
                if (started && options.protection) {
                    return options.token;
                }
                return null;
            },
            getParam: function () {
                if (started && options.protection) {
                    return options.param;
                }
                return null;
            },
            addTokenOnUrl: function (url) {
                if (started && options.protection) {
                    url = url + (url.indexOf('?') < 0 ? '?' : '&') + options.param + '=' + options.token;
                }
                return url;
            }
        };

        start();
        return exports;
    }
);

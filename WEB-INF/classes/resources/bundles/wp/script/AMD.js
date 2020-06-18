/**
 * @overview AMD's define and require extension to handle the platform bundles.
 *
 * Platform static code is packed in bundles. This mechanism has been in used before
 * we switched to AMD to modularize our code and identify dependencies.
 *
 * By convention, the first part of a AMD JS module identifier is mapped to :
 * - ds : Widget Platform core bundle ('ds')
 * - DS : static files that MKMK produces for web modules (.mweb)
 * - other : map to the corresponding bundle name (eg ifwe/a/b -> ifwe, swym/a/b -> swym)
 *
 *  We consider that if a module is required and not already defined, we first need to load
 *  its bundle to ensure all dependencies are available.
 *  We load all bundles dependencies of a bundle prior to loading the bundles itself.
 */

 /* global UWA, define:false, require:false */

define('ds/AMD',
[
    'UWA/Core',
    'require'
],

/**
 * Our mechanism for loading AMD modules by bundle.
 *
 * @module ds/AMD
 *
 * @requires module:UWA/Core
 * @requires module:UWA/Array
 * @requires module:require
 */
function (Core, _localrequire) {

    'use strict';

    var noop = function () {},
        console = window.console || { log: noop },
        // Global ds exports, defined in platform index templates.
        ds = window.ds,
        // path prefix to access the platform from the current location
        dsPrefix = window.dsPrefix || '',
        // current language code for static resources NLS
        dsLang = window.dsLang,
        // cache ID for static resources
        dsVersion = window.dsVersion,
        // map of each bundles and its dependencies
        bundles = window.bundles,

        // this variable can be set to true during debug to log extra information
        extraDebug = false,

        debugEnabled = !!(UWA && UWA.debug),

        // Keep references to original AMD methods
        _define = window._define = window.define,
        _require = window._require = window.require || window.curl,

        // Bundles that are loaded by default, null/undeclared if we are not using bundles
        loadedBundles = isUsingBundles() ? window.dsDefaultLoadedBundles : [];

    loadedBundles.push('UWA'); // UWA is delivered as part of the platform core bundle
    loadedBundles.push('DS');
    loadedBundles.push('ds'); // ds alias for the platform core bundle
    loadedBundles.push('wp'); // platform core bundle, use 'ds' instead

    function isUsingBundles () {
        // If some bundles were loaded by default, consider that we are using bundles
        // for JS code dynamic loading
        return Array.isArray(window.dsDefaultLoadedBundles);
    }

    function isLoaded (aBundleName) {
        // if no default was loaded by default, consider that all files have already been loaded
        // this will change when we change the index debug template to load only the first bundle
        return (!isUsingBundles() || !Core.owns(bundles, aBundleName)) ? true : (loadedBundles.indexOf(aBundleName) !== -1);
    }

    function isDefined (aModuleName) {
        if (['require', 'exports',  'module'].indexOf(aModuleName) !== -1) {
            return true;
        }
        if (aModuleName && aModuleName.indexOf('!') !== -1) {
            return true;
        }
        if (typeof _localrequire.defined === 'function') {
            // use requirejs public API so we don't need it to throw explicitely
            return _localrequire.defined(aModuleName);
        } else {
            var defined;
            try {
                _localrequire(aModuleName);
                defined = true;
            } catch (e) {
                defined = false;
            }
            return defined;
        }
    }

    function log (msg) {
        if (debugEnabled) {
            console.log('[ds/AMD] ' + msg);
        }
    }
    function warn (msg) {
        if (debugEnabled) {
            console.log('[ds/AMD] Warning : ' + msg);
        }
    }

    function executeIfNotLoaded (aBundleName, src) {
        if (isLoaded(aBundleName)) {
            return;
        }

        try {
            var time = new Date().getTime(),
                head = document.getElementsByTagName('head')[0],
                script = document.createElement('script');

            script.type = 'text/javascript';
            loadedBundles.push(aBundleName);
            script.text = '//# sourceURL= bundles/' + aBundleName + '.js\n' + src;
            head.appendChild(script);
            if (extraDebug) {
                log('Evaluated bundle ' + aBundleName + ' in ' + (new Date().getTime() - time) + 'ms');
            }
        } catch (eA) {
            warn('Error while evaluating bundle : ' + aBundleName);
            console.error && console.error(eA);
        }
    }

    function getBundleUrl (aBundleName) {
        return dsPrefix + 'resources/' + dsVersion + '/' + dsLang + '/' + aBundleName + '/bundle' + (!debugEnabled ? '-min' : '') + '.js';
    }

    function getBundleName (aModuleName) {
        return (aModuleName || '').split('/')[0];
    }

    function validateHttpStatusCode (request) {
        return ((request.status >= 200 && request.status <= 300) ||
                request.status === 304 || request.status === 1223);
    }

    function loadBundleDependencies (aBundleName) {
        if (!aBundleName) { return; }

        bundles[aBundleName].forEach(loadBundleDependencies);
        ds.importBundle(aBundleName);
    }

    function downloadBundle (aBundleName, callback, async) {

        var request,
            requestCallback,
            time = new Date();

        if (isLoaded(aBundleName)) {
            callback();
            return;
        }

        requestCallback = function () {
                if (async && request.readyState !== 4) { return; }

                if (validateHttpStatusCode(request)) {
                    if (extraDebug) {
                        log('Downloaded ' + aBundleName + (async ? ' a' : ' ') + 'synchronously in ' + (new Date() - time) + 'ms');
                    }
                    executeIfNotLoaded(aBundleName, request.responseText);
                    callback();
                } else {
                    log('Error while loading bundle : ' + aBundleName);
                }
            };

        try {
            request = new XMLHttpRequest();
            if (async) request.onreadystatechange = requestCallback;
            request.open('GET', getBundleUrl(aBundleName), async);
            request.send(null);
            if (!async) {
                requestCallback();
            }
        } catch (e2) {
            log('Error while creating XMLHttpRequest for loading bundle : ' + aBundleName);
        }
    }

    /**
     * Blocking function to load a bundle
     *
     * take bundles name as an argument :
     * ds.importBundle("community", "enovia");
     *
     * Beware that this method does not handle cyclic dependencies !
     *
     * @deprecated
     * @memberof ds
     */
    ds.importBundle = function () {
        var i, len;

        for (i = 0, len = arguments.length; i < len; i++) {
            downloadBundle(arguments[i], noop, false);
        }
    };

    function loadDependencies (deps, cb, async) {

        var bName, i, len, needResources = false;

        for (i = 0, len = deps.length; i < len; i++) {
            bName = getBundleName(deps[i]);

            // Load a bundle only if the module is not already defined AND the bundle hasn't been loaded yet
            // Note : a module can be defined even if the corresponding bundle has not been loaded yet
            //   * external lib such as 'when' : no corresponding bundles
            //   * modules copied from another bundle
            if (!isDefined(deps[i]) && !isLoaded(bName)) {
                needResources = true;

                loadBundleDependencies(bName);
                downloadBundle(bName, cb, async);
            }
        }

        return needResources;
    }

    function require (deps, callback, errback, optional) {
        if (extraDebug) {
            log('require(' + JSON.stringify(deps) + ')');
        }

        var needResources = false,
            config,
            requireCB = function () { require(deps, callback, errback, optional); };

        // require js args processing
        if (!Array.isArray(deps) && typeof deps !== 'string') {
            // deps is a config object
            config = deps;
            if (Array.isArray(callback)) {
                // Adjust args if there are dependencies
                deps = callback;
                callback = errback;
                errback = optional;
            } else {
                deps = [];
            }
        }
        if (Core.is(deps, 'string')) {
            if (Core.is(callback, 'function')) {
                // Curl js compatibility : if a single module is given with a callback, rewrite it as an array
                // to make it comply with the AMD spec :
                // https://github.com/amdjs/amdjs-api/blob/master/require.md#requirearray-function-
                deps = [deps];
            } else {
                // Synchronous require call so we return the module right away
                // https://github.com/amdjs/amdjs-api/blob/master/require.md#requirestring-
                return _require(deps);
            }
        }

        needResources = loadDependencies(deps, requireCB, true);

        if (!needResources) {
            if (extraDebug) log('require does not need resources, calling _require with' +
                JSON.stringify(deps) + ' and cb: ' + String(callback).substr(0, 100) +
                ' and errback: ' + String(errback).substr(0, 100));
            // the return type for this require(Array, Function) call is not specified by the AMD spec, so we do not return anything
            // https://github.com/amdjs/amdjs-api/blob/master/require.md#requirearray-function-
            _require(deps, callback, errback, optional);
        }
    }

    function define (moduleId, deps, factory) {

        var dependencies = Array.isArray(moduleId) ? moduleId :
                               Array.isArray(deps) ? deps : [];

        if (typeof moduleId !== 'string') {
            warn('Anonymous module' + (Array.isArray(deps) ? ' with dependencies : ' + deps.join(', ') : ''));
        }

        if (extraDebug) {
            log('define(' + moduleId + ', ' + JSON.stringify(deps) + ')');
        }

        loadDependencies(dependencies, noop, false);
        _define(moduleId, deps, factory);
    }

    // Exports specified AMD properties from the loader implementation

    // https://github.com/amdjs/amdjs-api/blob/master/AMD.md#defineamd-property-
    define.amd = _define.amd;
    // https://github.com/amdjs/amdjs-api/blob/master/require.md#requiretourlstring-
    require.toUrl = _require.toUrl;
    // https://github.com/amdjs/amdjs-api/blob/master/CommonConfig.md#common-config
    require.config = _require.config;
    // and export this helpful hook from RequireJS when available, used for AMD debug / analysis
    require.onResourceLoad = _require.onResourceLoad;

    // If we are using bundles, override the AMD loader define/require method with our implementation
    window.define = isUsingBundles() ? define : _define;
    window.require = isUsingBundles() ? require : _require;

    return {
        /**
         * Define a module using the AMD pattern.
         *
         * Note that contrary to the AMD spec, we currently require all modules to be
         * explicitely named, and the first part of the identifier MUST be the module's
         * bundle name.
         *
         * @method
         * @see https://github.com/amdjs/amdjs-api/wiki/AMD
         * @param {String} moduleId module identifier
         * @param {Array} dependencies Array of required module identifiers
         * @param {Function} factory factory
         */
        define: window.define,
        /**
         * Require for module using the AMD pattern
         *
         * @method
         * @see https://github.com/amdjs/amdjs-api/wiki/require
         * @param {Array} dependencies Array of required module identifiers
         * @param {Function} callback callback
         */
        require: window.require
    };
});

require(['ds/AMD'], function (AMD) {

    'use strict';

    var ds = window.ds,
        dsx = window.dsx;

    ds.define = function (id, dep, f) {
        if (dsx && dsx.warn) {
            dsx.warn('"ds.define" is deprecated, please use "define" instead');
        }
        AMD.define(id, dep, f);
    };

    ds.require = function (dep, f) {
        if (dsx && dsx.warn) {
            dsx.warn('"ds.require" is deprecated, please use "require" instead');
        }
        AMD.require(dep, f);
    };
});

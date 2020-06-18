
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Router is used to handle url navigation by setting up routes and hash codes
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/libs/router', [
        'DS/Crossroads/crossroads',
        'DS/Crossroads/hasher'
    ],

    function(crossroads, hasher) {
        'use strict';
        var Router = function() {
            /**
           @private
           @property {Object} 'router' Holds an instance of crossroads router
		 **/
            var router = crossroads.create();
            router.normalizeFn = crossroads.NORM_AS_OBJECT;
            var isSameRouteHandler = function(routerObj, newHash, oldHash) {
                if (oldHash !== undefined) {
                    var newRouteMatches = routerObj._getMatchedRoutes(newHash)[0];
                    var oldRouteMatches = routerObj._getMatchedRoutes(oldHash)[0];
                    if (newRouteMatches && oldRouteMatches) {
                        return {
                            newTargetMod: newRouteMatches.route.matched._bindings[0]._listener.listenerId,
                            oldTargetMod: oldRouteMatches.route.matched._bindings[0]._listener.listenerId
                        };
                        //return (newRouteMatches.route.matched._bindings[0]._listener.listenerId === oldRouteMatches.route.matched._bindings[0]._listener.listenerId);
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }

            };
            return {
                /**
               Creates a new route pattern and add it to crossroads routes collection

               @method addRoute

               @param {String} pattern String pattern that should be used to match against requests
               @param {Function} handler Function that should be executed when a request matches the route pattern
			 **/
                router: router,
                addRoute: function(pattern, handler) {
                    router.addRoute(pattern, handler);
                },
                /**
               Initializes the router by parsing initial hash, parsing hash changes and initializing the hasher
							 @method init
							 @param {object} options  pageNotFoundHandler
			 			 **/
                init: function(options) {
                    var that = this;
                    that.router.bypassed.add(function() {
                        options.pageNotFoundHandler(arguments[1]);
                    });

                    var parseHash = function(newHash, oldHash) {
                        that.router.parse(newHash, [isSameRouteHandler(that.router, newHash, oldHash)]);
                    };
                    hasher.initialized.add(parseHash, that); // parse initial hash
                    hasher.changed.add(parseHash, that); // parse hash changes

                    if (!hasher.isActive()) {
                        hasher.init(); // start listening for history change
                    }

                },
                navigate: function(path, options) {
                    var oldHash = hasher.getHash();
                    var newHash = path;
                    if (options && options.replace) {
                        hasher.replaceHash(path, true);
                    } else {
                        hasher.setHash(path, true);
                    }

                    this.router.parse(newHash, [isSameRouteHandler(this.router, newHash, oldHash)]);
                },
                reset: function(){
                	router.removeAllRoutes();
                	router.resetState();
                	hasher.stop();
                	router = {};
                },
                routed: router.routed

            };

        };
        return Router;
    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Extensions Manager of the xApps Scaffolding framework
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/ExtensionManager', [
        'UWA/Core',
        'UWA/Class/Promise'
    ],

    function(UWACore, Promise) {
        'use strict';
        var that;
        /**
         * Extensions Manager is used to add extension to the app
         *
         * Extensions are loaded in the app before starting modules:
         * they have direct access to the app's internals
         * they are here to add new features to the app... that are made available through the facade
         *
         * @param  {String} path of the extension
         * @return {ExtensionManager} the ExtensionManager object
         */

        function ExtensionManager(app) {
            this.extensions = [];
            this.extCopy = []; // UWACore.clone is not working for arrays with objects
            this.services = {};
            this.extDfd = Promise.deferred();
            this.logger = app.logger;
            return this;
        }

        // Public API
        ExtensionManager.prototype = {
            /**
             * Registers the extension.
             */
            add: function(ext) {
                if (this.extensions.some(function(elt) {
                        return (elt.path == ext.path)
                    })) {
                    this.logger.error('Error loading ext: ' + ext.path + ' Error: The extension is already registered. Extensions can only be added once.');
                    return;
                }

                if (this.started) {
                    throw 'Error loading ext: ' + ext.path + ' Error: Loading extensions already started';
                }

                this.extensions.push(ext);
                this.extCopy.push(ext);
            },

            start: function() {
                that = this;
                if (this.started) {
                    throw 'Start extensions already called.';
                }
                this.started = true;
                var extDfd = this.extDfd;

                (function init(extDef) {
                    if (extDef) {
                        var ext = requireExtension(extDef);
                        ext.then(function() {
                            init(that.extCopy.shift());
                        }).fail(function(err) {
                            if (!err) {
                                err = {
                                    type: 'error',
                                    message: 'Unknown error while loading an extension'
                                };
                            }
                            extDfd.reject(err);
                        });
                    } else if (that.extCopy.length === 0) {
                        extDfd.resolve(that.services);
                    }
                })(that.extCopy.shift());

                return extDfd.promise;
            }
        };

        /*!
         * Extension loading
         *
         * This method returns a promise that resolves to the actual extension
         *
         * @param {String} ext path of the extension
         * @param {Object} context Scaffolding fw object
         * @return {Object} promise object
         */

        function requireExtension(ext) {
            var dfd = Promise.deferred();
            var context = ext.context;
            var path = ext.path;

            var resolve = function(ext) {
                if (typeof ext === 'function') {
                    var res = path.split('/');
                    var id = res[res.length - 1];
                    that.services[id] = {
                        creator: ext,
                        instance: null
                    };
                    dfd.resolve(ext);
                } else {
                    // TO-DO H9M This behaviour will change
                    that.logger.error('Error loading ext: ' + path + ' Error: Extension is not a function');
                    dfd.reject({
                        type: 'error',
                        message: 'Extension: ' + path + ' is not a function'
                    });
                }
            };

            var reject = function(err) {
                var msg = 'Error while loading the extension: ' + path;
                that.logger.error(msg);
                dfd.reject({
                    type: 'error',
                    message: msg
                });
            };

            if (typeof path === 'string') {
                require([path], resolve, reject);
            }

            return dfd.promise;
        }

        return ExtensionManager;

    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Mediator of the UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/Mediator', [
        'UWA/Core'
    ],

    function(UWACore) {
        'use strict';

        var mediator = function() {

            // Private variables
            var core = this,
                handlers = {},
                slice = [].slice;

            // Public API
            return {
                registerEvent: function(topic, callback, context) {
                    var type = topic;
                    if (!handlers[type]) {
                        handlers[type] = [];
                    }
                    //Cannot be registered twice => Call remove Listener First !
                    this.removeListener(type, callback);
                    handlers[type].push({
                        context: context,
                        callback: callback
                    });
                },

                notify: function(topic) {

                    if (!handlers[topic]) {
                        return undefined;
                    }

                    var args = slice.call(arguments, 1),
                        type = topic,
                        i,
                        len,
                        msgList
                    /*,
                                       returnValue,
                                       returnValues = []*/
                    ;

                    if (handlers[type] instanceof Array) {
                        msgList = handlers[type];
                        len = msgList.length;
                        for (i = 0; i < len; i++) {
                            setTimeout(function(index, i_msgList) {
                                var msg = i_msgList[index];
                                return function() {
                                    msg.callback.apply(msg.context, args);
                                };
                            }(i, msgList), 0);
                            /* if (returnValue !== undefined) {
                                 returnValues.push(returnValue);
                             }*/
                        }
                    }

                    /* if (returnValues.length === 0) {
                         return undefined;
                     }
                     else if (returnValues.length === 1) {
                         return returnValues[0];
                     }
                     else {
                         return returnValues;
                     }*/
                },

                removeListener: function(topic, callbackFunction) {
                    var type = topic,
                        callback = callbackFunction,
                        handlersArray = handlers[type],
                        i, len, idx = null;
                    if (!callback || !(callback instanceof Function)) {
                        throw new Error('Mediator Error: callback function is mandatory !');
                    }
                    if (handlersArray instanceof Array) {
                        for (i = 0, len = handlersArray.length; i < len; i++) {
                            if (handlersArray[i].callback === callback) {
                                idx = i;
                                break;
                            }
                        }
                        if (idx !== null) {
                            handlers[type].splice(idx, 1);
                        }

                    }
                }
            };
        };

        return mediator;
    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : LayoutManager of the UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/LayoutManager', [],

    function() {
        'use strict';

        /**
       Layout Manager is used when it is required to add certain modules to the DOM
       @param {Object} scope  the DOM element within which the routes get applied
       @param {String} markup  the html markup to add to the scope
			 @returns {object} layoutmanager
	 */
        var layoutManager = function(scope, markup) {

            // Private variables
            var core = this;
            var handles = [];
            if (markup) {
                scope.addContent(markup);
            }
            // Public API
            return {
                /**
                 * Add routes
                 * @param {Array} newHandles layoutModules array
                 * Array contains items having scope, moduleId, moduleRequirePath, args
                 * @returns {Promise}
                 **/
                startLayoutModules: function(newHandles) {
                    var registerModules = function(resolve, reject) {
                        if (!newHandles || !newHandles.length) {
                            resolve();
                        }
                        if (!(newHandles instanceof Array)) {
                            newHandles = [newHandles];
                        }
                        var promises = [];
                        newHandles.forEach(function(item) {
                            handles.push(item);
                            item.container = scope;
                            promises.push(core.manager.registerModuleAndStart('layout', item, item.args));
                        });
                        Promise.all(promises).then(resolve, reject);
                    };
                    return new Promise(registerModules);
                }

            };

        };

        return layoutManager;
    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Class that holds the Facade of the UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/Facade', [],

    function() {

        'use strict';
        /**
	@constructor
	@param {object} app xapp object
	@param {object} module_domElt DOM Elemnt
	**/
        function facade(app, module_domElt) {
            this.app = app;
            this.core = app.core;
            this.element = module_domElt;
        }

        // Public API
        facade.prototype = {
            /**
             * Returns the element that represents the module.
             * @returns {UWAElement} The element representing the module.
             */
            getElement: function() {
                return this.element;
            },
            /**
             * Returns global configuration data
             * @param {string} [name] Specific config parameter
             * @returns {object} config value or the entire configuration JSON object
             *                if no name is specified (null if either not found)
             */
            getGlobalConfig: function(name) {
                return this.core.getGlobalConfig(name);
            },

            navigate: function(newPath, options) {
                if (!this.disableNavigate) {
                    return this.core.router.navigate(newPath, options);
                } else {
                    return null;
                }
            },

            layoutManager: function(scope, markup) {
                return this.core.layoutManager(scope, markup);
            },
            getService: function(serviceId) {
                return this.app.getService(serviceId);
            },
            find: function(selector) {
                return this.element.getElements(selector);
            },
            addEvent: function(element, evt, fn) {
                return element.addEvent(evt, fn);
            },
            removeEvent: function(element, evt, fn) {
                return element.addEvent(evt, fn);
            },
            notify: function(evt) { // eslint-disable-line no-unused-vars
                this.core.mediator.notify.apply(null, arguments);
            },
            listen: function(evt, callback, context) {
                this.core.mediator.registerEvent(evt, callback, context);
            },
            ignore: function(evt, callback) { // eslint-disable-line no-unused-vars
                this.core.mediator.removeListener(evt, callback);
            }
        };

        return facade;

    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Router of the UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffolding/Router', [
        'DS/ENOXAppsScaffolding/libs/router'
    ],

    function(BaseRouter) {
        'use strict';

        /**
        Router is used to trigger events when there is a url change
        @class Router
        @param {Object} options core xApp.core object
				  		{DOMElement} applicationScope parent container of the application
				  		{DOMElement} html404 {DOM Element} to be rendered if the url does not match any route
				  		{Object} resolve  to be used to call after the initial routes are loaded
				  		{function} onNavComplete to update the hash after navigation, state retention.
        **/
        var Router = function(options) {

            // Private variables
            var flag404 = false;
            var state = 0;
            var allHandles = {};
            var router = new BaseRouter();
            var applicationScope = options.applicationScope;
            var html404 = options.html404;
            var core = options.core;

            /**
		 				* Wrapper for Routes.
            @class RouteWrapper
            @private
            @param {Object} route : route metadata
						@param {Object} prereq : pre-reqs of this route
						@param {Object} container : DOM container
		 			**/
            var RouteWrapper = function(route, prereq, container, done, notdone) {
                var that = this;

                that.moduleId = route.moduleId;
                that.path = route.path;
                that.scope = route.scope;
                that.moduleRequirePath = route.moduleRequirePath;
                that.prereq = prereq;
                that.childRoutes = [];
                that.container = container;
                that.breadcrumb = route.breadcrumb;
                that.routeStart = function() {
                    var routeArgs = arguments[1];
                    var targetDetails = arguments[0];
                    if (flag404) {
                        applicationScope.getElement('#app-container').setStyle('display', 'block');
                        applicationScope.getElement('#not-found-container').setStyle('display', 'none');
                        flag404 = false;
                    }
                    var doThisFirst = function(resolve) {
                        var isOldChildOfNew = false;
                        var isNewChildOfOld = false;
                        var isSameTarget = false;
                        if (targetDetails) {
                            var matchingModuleRoutes = Object.keys(allHandles).filter(function(i) {
                                return allHandles[i].moduleId === targetDetails.oldTargetMod;
                            });
                            var i = 0;
                            for (; i < matchingModuleRoutes.length; i++) {
                                var oldRoute = allHandles[matchingModuleRoutes[i]];
                                if (oldRoute.prereq && oldRoute.prereq.moduleId === targetDetails.newTargetMod) {
                                    isOldChildOfNew = true;
                                    break;
                                }
                            }
                            matchingModuleRoutes = Object.keys(allHandles).filter(function(i) {
                                return allHandles[i].moduleId === targetDetails.newTargetMod;
                            });
                            for (i = 0; i < matchingModuleRoutes.length; i++) {
                                var newRoute = allHandles[matchingModuleRoutes[i]];
                                if (newRoute.prereq && newRoute.prereq.moduleId === targetDetails.oldTargetMod) {
                                    isNewChildOfOld = true;
                                    break;
                                }
                            }
                            isSameTarget = targetDetails.newTargetMod === targetDetails.oldTargetMod;
                        }
                        that.stopOtherModules(targetDetails.oldTargetMod, isNewChildOfOld);
                        var toOnRoute = isSameTarget || isOldChildOfNew;
                        core.manager.notifyLayoutModules({
                            url: routeArgs.request_,
                            data: routeArgs,
                            breadcrumb: that.breadcrumb
                        });
                        core.manager.registerModuleAndStart('route', that, routeArgs, toOnRoute).
                        then(function() {
                            resolve();
                            if (!state) {
                                state = 1;
                                done();
                            }
                        }, function(error) {
                            notDone(error);
                        });
                    };
                    if (typeof options.onNavComplete === 'function') {
                        options.onNavComplete();
                    }
                    return new Promise(doThisFirst);
                };
                that.routeStart.listenerId = that.moduleId;

                that.routeStop = function() {
                    core.manager.modStop(that.moduleId, that.scope);
                };
                that.stopOtherModules = function(oldModId, isNewChildOfOld) {
                    Object.keys(allHandles).forEach(function(key) {
                        if ((that.scope === allHandles[key].scope || (oldModId === allHandles[key].moduleId && !isNewChildOfOld)) && (that.moduleId !== allHandles[key].moduleId)) {
                            allHandles[key].routeStop();
                        }
                    });
                };
                that.addChildRoutes = function(cRoute) {
                    that.childRoutes.push(cRoute);
                };
            };

            return {
                /**
                 Create handler objects from each route handler using the 'Wrapper' method and add the activated handler object to the router as routes
                 @method addRoutes
                 @param {Array} routes route-handler object array
								 @returns {object} this
			 				 **/
                addRoutes: function(routes, resolve, reject) {
                    if (!routes || (routes instanceof Array && !routes.length)) {
                        throw new Error('addRoutes method require a array or object of routes');
                    }
                    if (!(routes instanceof Array)) {
                        routes = [routes];
                    }

                    var parseRoutes = function(route, prefix, prereq, container) {
                        route.path = prefix + '/' + route.path;
                        var handlerObj = new RouteWrapper(route, prereq, container, resolve, reject);
                        router.addRoute(route.path, handlerObj.routeStart);
                        allHandles[route.path] = handlerObj;
                        if (route.subroutes) {
                            for (var j = 0; j < route.subroutes.length; j++) {
                                var cont = applicationScope.getElement(handlerObj.scope);
                                handlerObj.addChildRoutes(parseRoutes(route.subroutes[j], route.path, handlerObj, cont));
                            }
                        }
                        return handlerObj;
                    };
                    for (var i = 0; i < routes.length; i++) {
                        parseRoutes(routes[i], '', null, applicationScope);
                    }
                    return this;
                },

                start: function() {
                    var pageNotFoundHandler = function(request) {
                        flag404 = true;
                        applicationScope.getElement('#app-container').setStyle('display', 'none');
                        applicationScope.getElement('#not-found-container').setStyle('display', 'block');
                    };
                    var options = {
                        pageNotFoundHandler: pageNotFoundHandler
                    };
                    router.init(options);
                },
                navigate: function(path, options) {
                    router.navigate(path, options);
                },
                stop: function() {
                    allHandles = {};
                    router.reset();
                }
            };

        };

        return Router;
    });

﻿
/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : xApps Scaffolding
 *
 * @author H9M
 */


define('DS/ENOXAppsScaffolding/xAppScaffolding', [
        'UWA/Core',
        'UWA/Utils',
        'DS/ENOXAppsScaffolding/Facade',
        'DS/ENOXAppsScaffolding/Mediator',
        'DS/ENOXAppsScaffolding/LayoutManager',
        'DS/ENOXAppsScaffolding/ExtensionManager',
        'DS/ENOXAppsScaffolding/Router',
        'DS/ENOXLogger/Logger',
        'text!DS/ENOXAppsScaffolding/assets/default404.html'
    ],

    function(UWACore, UWAUtils, Facade, Mediator, LayoutManager, ExtensionManager, Router, Logger, default404page) {
        'use strict';
        // Private variables
        var globalConfig = {}, // Global configuration
            ref = 'xAppScaffolding', // Infra name
            modules = {}, // Information about each registered module by moduleId
            services = {}, // Information about each registered service by serviceId
            extManager, // App Extension Manager
            createInstance = function(moduleId, facade) {
                var module = modules[moduleId],
                    instance;
                instance = modules[moduleId].creator.call(null, facade, module.args);
                return instance;
            };

        /**
         * xAppScaffolding constructor and main entry point
         *
         * Every instance of xAppScaffolding defines an xAppScaffolding application.
         * An xAppScaffolding application is in charge of loading the various
         * extensions that will apply to it (defined either
         * programmatically or by way of configuration).
         *
         * An xAppScaffolding application is the glue between all the extensions
         * and components inside its instance.
         *
         * Internally an xAppScaffolding application wraps important objects:
         *
         * - `config` is the object passed as the first param of the apps constructor
         * - `core`   is a container where the extensions add new features
         * - `extensions`.
         *
         * Extensions are here to provide features that will be used by the components...
         * They are meant to extend the apps' core & facade.
         * They also have access to the apps's config.
         *
         * Example of a creation of an xAppScaffolding Application:
         *
         *     var app = xAppScaffolding({ key: 'value' });
         *     app.use('ext1').use('ext2');
         *     app.run();
         *
         * @class XAppScaffolding
         * @param {Object} [config] Main App config.
         * @method constructor
         */

        var XAppScaffolding = function(config) {

            if (!(this instanceof XAppScaffolding)) {
                return new XAppScaffolding(config);
            }

            // Public API
            var app = this;
            app.ref = ref;

            // Flag whether the application has been started
            app.started = false;

            // App Logger
            app.logger = Logger;

            // App Extension manager
            extManager = new ExtensionManager(app);

            /*/ handle js exceptions
            window.onerror = function (errorMsg, url, lineNumber, column, errorObj) {
                Logger.error('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber
                + ' Column: ' + column + ' StackTrace: ' +  errorObj);
            };*/


            //----------------------------------------------------------------------
            // Global Configuration
            //----------------------------------------------------------------------

            // The App's globalConfig object
            UWACore.extend(globalConfig, config || {});

            //get url options for Production or Dev mode
            var urlOptions = {};
            if (window.location.search.length > 1) {
                UWACore.extend(urlOptions, UWAUtils.parseQuery(window.location.search));
                if (urlOptions.widgetDomain) {
                    UWACore.extend(urlOptions, UWAUtils.parseQuery(urlOptions.widgetDomain));
                }
            }

            // set logger configuration
            if ((urlOptions.hasOwnProperty('debug') && urlOptions.debug === 'true') || (urlOptions.hasOwnProperty('debug_me') && urlOptions.debug_me === 'true')) {
                globalConfig.logger = globalConfig.logger || {};
                //globalConfig.logger.loggers = globalConfig.logger.loggers.concat([{ name: app.ref, level: Logger.LEVEL.DEBUG }]);
                var loggerLevel = globalConfig.logger;
                if (loggerLevel.level) {
                    app.logger.init(globalConfig.logger);
                }
            }

            /**
             * Returns global configuration data
             * @param {string} [name] Specific config parameter
             * @returns {object} config value or the entire configuration JSON object
             *                if no name is specified (null if neither not found)
             */
            app.getGlobalConfig = function(name) {
                if (typeof name === 'undefined') {
                    return globalConfig;
                } else if (name in globalConfig) {
                    return globalConfig[name];
                } else {
                    return null;
                }
            };

            /**
             * Sets the global configuration data
             * @param {Object} config Global configuration object
             * @returns {void}
             */
            app.setGlobalConfig = function(config) {
                if (app.started) {
                    app.logger.warn('Cannot set global configuration after application start');
                    return;
                }

                for (var prop in config) {
                    if (config.hasOwnProperty(prop)) {
                        globalConfig[prop] = config[prop];
                    }
                }
            };

            /**
             * use the given extension.
             *
             * Extensions are loaded in the app before starting modules:
             * they have direct access to the app's internals
             * they are here to add new features to the app... that are made available through the facade
             *
             * This method can only be called before the App is actually started.
             * Note that the App is started when its `run` method is called.
             *
             * @method use
             * @param  {String} path of the extension
             * @return {XAppScaffolding} the xAppScaffolding app object
             */
            app.use = function(path) {
                if (typeof path === 'string') {
                    extManager.add({
                        path: path,
                        context: app
                    });
                } else {
                    throw new Error('Scaffolding framework only handles extensions with a string path.');
                }

                return app;
            };

            /**
             * Returns the requested service
             * @param {string} serviceId The name of the service to retrieve.
             * @returns {!Object} An object if the service is found or null if not.
             * @private
             */
            app.getService = function(serviceId) {
                var serviceData = services[serviceId];

                if (serviceData) {
                    if (!serviceData.instance) {
                        serviceData.instance = serviceData.creator(app.facade);
                        serviceData.instance.init();
                    }

                    return serviceData.instance;
                }

                return null;
            };

            /**
             * Starts the application.
             *
             * Loads the extensions.
             * All the extensions are loaded when `run` is called.
             * Run returns a promise that shall fail if any of the
             * extensions fails to load.
             *
             * @method run
             * @param  {Object} options: onReady & onFailure callbacks.
             */
            app.run = function(options) {
                if (app.started) {
                    var msg = 'App already started!';
                    options.onFailure.call(app, {
                        type: 'error',
                        message: msg
                    });
                    app.logger.error(msg);
                    return;
                }
                /**
                 * adds the app layout and then start the router
                 * @returns {Promise} onResolve call the onReady of the xApp
                 */
                function startApp() {
                    return new Promise(function(resolve, reject) { // eslint-disable-line no-unused-vars
                        /**
                         * starts the router
                         */
                        function kickstartRouter() {

                            if (config.routes && config.routes.length) {
                                app.core.router.addRoutes(config.routes,resolve, reject).start();
                            } else {
                                resolve();
                            }

                        }
                        var appContainer = new UWACore.Element('div', {
                            id: 'app-container',
                            styles: {
                                height: '100%'
                            }
                        });
                        var notFoundContainer = new UWACore.Element('div', {
                            id: 'not-found-container',
                            styles: {
                                display: 'none'
                            }
                        });
                        appContainer.inject(config.container);
                        notFoundContainer.inject(config.container);
                        if (config.custom404page) {
                            notFoundContainer.setHTML(config.custom404page);
                        } else {
                            notFoundContainer.setHTML(default404page);
                        }
                        app.core.layoutManager(appContainer, config.markup).
                        startLayoutModules(config.layoutModules).
                        then(kickstartRouter, reject);
                    });

                }
                extManager.start().then(
                    function success() {
                        services = arguments[0];
                        if (options.beforeStart) {
                            options.beforeStart.apply(app);
                        }
                        startApp().then(function() {
                            options.onReady.apply(app);
                        }, function(error) {
                            options.onFailure.call(null, error);
                        });
                    },
                    function fail(error) {
                        options.onFailure.call(null, error);
                    }
                );
                app.logger.info('Starting the Application');
                app.started = true;
            };

            /**
             * kills the application.
             *
             * @method kill
             * @return {void}
             */
            app.kill = function() {
                app.core.manager.destroyAll();
                app.logger.info('Modules Destroyed!');
                app.started = false;
                modules = {};
                services = {};
                config.container.empty();
                config.container.destroy();
                app.core.router.stop();
                app.logger.info('App stopped!');
            };

            // core is just a namespace used to add features to the App
            app.core = {};

            app.core.layoutManager = LayoutManager;

            app.core.router = Router({
                core: app.core,
                applicationScope: config.container,
                html404: config.html404,
                onNavComplete: config.onNavComplete
            });

            app.core.mediator = new Mediator();

            var _require = function(modulePath, modId) {
                return new Promise(function(resolve, reject) {
                    require([modulePath],
                        function(moduleR) {
                            resolve({
                                name: modId,
                                module: moduleR
                            });
                        },
                        function() {
                            reject(new Error('module not found'));
                        });
                });
            };
            //----------------------------------------------------------------------
            // Module Lifecycle
            //----------------------------------------------------------------------
            UWACore.extend(app.core, {
                manager: {
                    /**
                     * This method's job is to first require the module, register it, and then start it asyncronously
                     * @param {String} type : 'route' or 'layout'
                     * @param {Object} typeObject : {moduleId, scope, prereq, moduleRequirePath, container, isPrereq}
                     * @param {Object} routeArgs : route arguments
                     * @param {Boolean} toOnRoute : while a navigation, true implies to call the onRoute of the module instead start
                     * @returns {Promise} : to be used for sequential registration of modules
                     */
                    registerModuleAndStart: function(type, typeObject, routeArgs, toOnRoute) {
                        var that = this;
                        var moduleId = typeObject.moduleId;
                        var scope = typeObject.scope;
                        var prereq = typeObject.prereq;
                        var mod = modules[moduleId];
                        var doThisFirst = function(resolve, reject) {
                            var temp;
                            var registerMe = function() {
                                if (typeof moduleId === 'string' && typeof typeObject.moduleRequirePath === 'string') {
                                    _require(typeObject.moduleRequirePath, moduleId).
                                    then(function(result) {
                                            var creator = result.module;
                                            //instance is getting created twice, need to correct this.
                                            temp = creator(app.facade);
                                            if (temp.start && temp.stop && typeof temp.start === 'function' && typeof temp.stop === 'function') {
                                                modules[moduleId] = {
                                                    creator: creator,
                                                    instance: null,
                                                    args: routeArgs,
                                                    type: type,
                                                    state: 0
                                                };
                                                temp = null;
                                                var moduleScope = new UWACore.Element('div', {
                                                    id: moduleId + '-container'
                                                });
                                                moduleScope.setStyle('height', '100%');
                                                scope = typeObject.container.getElement(scope); //get Parent module. scope
                                                moduleScope.inject(scope);
                                                modules[moduleId].scope = moduleScope;
                                                that.modStart(result.name, moduleScope, typeObject.isPrereq, resolve);

                                            } else {
                                                app.logger.error("Module '" + moduleId + "' Registration: FAILED: instance has no start or stop functions");
                                                reject('IncorrectModuleDefinationException');
                                            }
                                        },
                                        function(err) {
                                            app.logger.error(err);
                                        });

                                } else {
                                    app.logger.error("Module '" + moduleId + "' Registration: FAILED: one or more arguments are of incorrect type");
                                    reject('IncorrectModuleDefinationException');
                                }
                            };
                            if (!mod) {
                                if (prereq && !modules[prereq.moduleId]) {
                                    prereq.isPrereq = true;
                                    prereq.routeStart(toOnRoute, routeArgs).then(registerMe);
                                } else {
                                    registerMe();
                                }

                            } else {
                                if (toOnRoute) {
                                    that.modOnRoute(moduleId, routeArgs);
                                    resolve();
                                    return;
                                }
                                /**
                                 * start the current module
                                 */
                                function startMe() {
                                    modules[moduleId].args = routeArgs;
                                    that.modStart(moduleId, scope, typeObject.isPrereq, resolve);
                                }
                                if (prereq) {
                                    prereq.isPrereq = true;
                                    prereq.routeStart(toOnRoute, routeArgs).then(startMe);
                                } else {
                                    if (!typeObject.isPrereq) {
                                        typeObject.isPrereq = false;
                                    }
                                    startMe();
                                }
                            }
                        };
                        return new Promise(doThisFirst);

                    },
                    modStart: function(moduleId, module_domElt, disableNav, resolve) {
                        app.started = true;
                        var mod = modules[moduleId];
                        if (mod) {
                            //R14: create module and start module in a different callstack/
                            setTimeout(function() {
                                try {
                                    if (!mod.instance) {
                                        var facade = new Facade(app, module_domElt);
                                        mod.instance = createInstance(moduleId, facade);
                                        mod.facade = facade;
                                    }
                                } catch (err) {
                                    app.logger.error('Module "' + moduleId + '" , Create Instance FAILED: ' + err.message);
                                }

                                try {
                                    if (mod.instance && !mod.state) {
                                        mod.facade.disableNavigate = disableNav;
                                        mod.state = 1;
                                        mod.scope.setStyle('display', 'block');
                                        /*if(typeof jasmine !== 'undefined' && jasmine){
                                        	jasmine.Ajax.install();
                                        }*/
                                        mod.instance.start(mod.args);
                                        if (mod.facade.disableNavigate) {
                                            mod.facade.disableNavigate = false;
                                        }
                                    }
                                } catch (err) {
                                    app.logger.error('Module "' + moduleId + '" , Start FAILED: ');
                                    app.logger.error(err);
                                    console.error(err);
                                }

                                resolve();
                            }, 0);
                        } else {
                            app.logger.error('Module "' + moduleId + '" , Start FAILED ');
                        }
                    },
                    modOnRoute: function(moduleId, routeArgs) {
                        var mod = modules[moduleId];
                        if (mod) {
                            setTimeout(function() {
                                if (mod.instance.onRoute) {
                                    mod.instance.onRoute(routeArgs);
                                }
                            });
                        }
                    },
                    modStop: function(moduleId) {
                        var mod = modules[moduleId];
                        if ((mod = modules[moduleId]) && mod.instance && mod.state) {
                            mod.state = 0;
                            modules[moduleId].scope.setStyle('display', 'none');
                            mod.instance.stop();
                        } else {
                            app.logger.error("Stop Module '" + moduleId + "': FAILED : module does not exist or has not been started");
                        }
                    },
                    destroyAll: function() {
                        for (var moduleId in modules) {
                            var mod = modules[moduleId];
                            if (mod.instance) {
                                try {
                                    mod.instance.stop();
                                    // R14: Potential MemoryLeak!
                                    // A fct "destroy" should be implement for transition (stopped->destroyed)
                                    if (mod.instance.destroy === 'function') {
                                        mod.instance.destroy();
                                    }
                                    mod.instance = null;
                                } catch (err) {
                                    app.logger.error(err);
                                }

                            } else {
                                app.logger.error("Destroy Module '" + moduleId + "': FAILED : module instance does not exist or has not been started");
                            }
                            mod.scope.empty();
                            mod.scope.destroy();
                            mod = null;
                        }
                    },
                    notifyLayoutModules: function(params) {
                        try {
                            for (var moduleId in modules) {
                                var mod = modules[moduleId];
                                if (mod.instance && mod.type === 'layout' && mod.instance.onRoute) {
                                    mod.instance.onRoute(params);
                                }
                            }
                        } catch (e) {
                            app.logger.error('Error while notifying layout modules - onRoute');
                            app.logger.error(e);
                        }

                    },
                    getModuleInstance: function(moduleId) {
                        return modules[moduleId].instance;
                    },
                    getModuleScope: function(moduleId) {
                        return modules[moduleId].scope;
                    }
                }
            });

            /**
             * facade is a way to implement the facade pattern on top of the features provided by `core`.
             *
             */

            app.facade = new Facade(app);
            return app;
        };

        XAppScaffolding.CONSTANTS = Logger.LEVEL;

        return XAppScaffolding;
    });


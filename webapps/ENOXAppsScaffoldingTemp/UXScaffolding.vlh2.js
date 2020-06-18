/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffoldingTemp/UXScaffolding.vlh2',
    [
        'UWA/Core',
        'DS/ENOXAppsScaffolding/Facade',
        'DS/ENOXAppsScaffolding/Mediator',
        'DS/ENOXAppsScaffoldingTemp/LayoutManager.vlh2',
        'DS/ENOXAppsScaffolding/Router',
        'DS/ENOXLogger/Logger',
        'DS/ENOXAppsScaffoldingTemp/ScaffoldingModule'
    ],

    function (UWACore, Facade, Mediator, LayoutManager, Router, Logger, ScaffoldingModule) {

        // Private variables
        var globalConfig = {},          // Global configuration
            appRef = "UXScaffolding",   // App name
            modules = {},               // Information about each registered module by moduleId
            createInstance = function (moduleId, facade) {
                var module = modules[moduleId],
                   i,
                   len,
                   args = module.args,
                   newArguments = [],
                   instance;

                newArguments.push(facade);
                for (i = 0, len = args.length; i < len; i++) {
                    newArguments.push(args[i]);
                }

                instance = modules[moduleId].creator.apply(null, newArguments);
                return instance;
            };

        /**
        * UXScaffolding constructor and main entry point
        *
        * Every instance of UXScaffolding defines an UXScaffolding application.
        * An UXScaffolding application is in charge of loading the various
        * extensions that will apply to it (defined either
        * programmatically or by way of configuration).
        *
        * An UXScaffolding application is the glue between all the extensions
        * and components inside its instance.
        *
        * Internally an UXScaffolding application wraps important objects:
        *
        * - `config` is the object passed as the first param of the apps constructor
        * - `core`   is a container where the extensions add new features
        * - `extensions` not managed yet.
        *
        * Extensions are here to provide features that will be used by the components...
        * They are meant to extend the apps' core & facade.
        * They also have access to the apps's config.
        *
        * Example of a creation of an UXScaffolding Application:
        *
        *     var app = UXScaffolding({ key: 'value' });
        *     app.use('ext1').use('ext2'); // not managed yet.
        *     app.start();
        *
        * @class UXScaffolding
        * @param {Object} [config] Main App config.
        * @method constructor
        */

        var UXScaffolding = function (config) {

            if (!(this instanceof UXScaffolding)) {
                return new UXScaffolding(config);
            }

            // Public API
            var app = this;

            // Flag whether the application has been started
            //TODO H9M not used yet
            app.started = false;

            // App Logger
            app.logger = Logger;//new Logger(appRef);

            var urlParameters = {};

            //get url parameters
            if (window.location.search.length > 1) {
              var aItKey, nKeyId = 0, aCouples = window.location.search.substr(1).split("&");
              for (nKeyId; nKeyId < aCouples.length; nKeyId++) {
                aItKey = aCouples[nKeyId].split("=");
                urlParameters[unescape(aItKey[0])] = aItKey.length > 1 ? unescape(aItKey[1]) : "";
              }
            }

            // set logger configuration
            // FIXME: test should be (urlParameters.hasOwnProperty('debug') ||&& urlParameters.debug === "true")
            //        but due to platform change of url on first loading debug becomes debug_me
            if(urlParameters.hasOwnProperty('debug') || urlParameters.hasOwnProperty('debug_me')) {
              globalConfig.logger = globalConfig.logger || {};
              var loggerLevel = globalConfig.logger;
              if (loggerLevel.level) {
                  app.logger.init(globalConfig.logger);
              }
            }

            // handle js exceptions
            window.onerror = function (errorMsg, url, lineNumber, column, errorObj) {
                Logger.error('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber
                + ' Column: ' + column + ' StackTrace: ' +  errorObj);
            };


            //----------------------------------------------------------------------
            // Global Configuration
            //----------------------------------------------------------------------

            // The App's globalConfig object
            UWACore.extend(globalConfig, config || {});

            /**
             * Returns global configuration data
             * @param {string} [name] Specific config parameter
             * @returns config value or the entire configuration JSON object
             *                if no name is specified (null if neither not found)
             */
            app.getGlobalConfig = function (name) {
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
            app.setGlobalConfig = function (config) {
                if (app.started) {
                    //TODO H9M
                    app.logger.info('Cannot set global configuration after application start');
                    return;
                }

                for (var prop in config) {
                    if (config.hasOwnProperty(prop)) {
                        globalConfig[prop] = config[prop];
                    }
                }
            };

            // core is just a namespace used to add features to the App
            app.core = {};

            app.core.layoutManager = LayoutManager;

            app.core.router = Router;

            app.core.mediator = new Mediator();

            //----------------------------------------------------------------------
            // Module Lifecycle
            //----------------------------------------------------------------------
            UWACore.extend(app.core, {
                manager: {

                	modules: {},
                	configs: {},

                	setConfig: function (idConfig, config) {
                		this.configs[idConfig] = config;
                	},

                	getConfig: function (idConfig) {
                		return this.configs[idConfig];
                	},

                    /**
                     * Registers a new module
                     * @param {String} moduleId : Unique module identifier
                     * @param {Object} module : Scaffolding compliant module
                     * @returns the module if creation is succesful, null if failed
                     */
                    registerModule: function (moduleId, module) {
                        var scaffoldingModule = null, mod = this.modules[moduleId];
                        if (!mod) {
                        	this.modules[moduleId] = function (config) {
                        		return new ScaffoldingModule(module, config);
                        	}
                        } else {
                        	app.logger.error('Registration FAILED for module ' + moduleId + ' : ID is already used by another module')
                        }
                        return this.modules[moduleId];
                    },

                    start: function (moduleId, module_domElt) {
                        app.started = true;
                        var mod = modules[moduleId];
                        if (mod) {
                            if (!mod.instance) {
                                mod.instance = createInstance(moduleId, new Facade(app, module_domElt))
                            };
                            mod.instance.start();
                        } else {
                            app.logger.error("Start Module '" + moduleId + "': FAILED : module has not been registered");
                        }
                    },

                    startAll: function () {
                        app.started = true;
                        var moduleId;
                        for (moduleId in modules) {
                            if (modules.hasOwnProperty(moduleId)) {
                                app.core.manager.start(moduleId);
                            }
                        }
                    },

                    stop: function (moduleId) {
                        app.started = true;
                        var mod = modules[moduleId];
                        if ((mod = modules[moduleId]) && mod.instance) {
                            mod.instance.stop();
                            //mod.instance = null;
                        } else {
                            app.logger.error("Stop Module '" + moduleId + "': FAILED : module does not exist or has not been started");
                        }
                    },

                    stopAll: function () {
                        app.started = false;
                        var moduleId;
                        for (moduleId in modules) {
                            if (modules.hasOwnProperty(moduleId)) {
                                app.core.manager.stop(moduleId);
                            }
                        }
                    }
                }
            });

            app.core.layoutManager = new LayoutManager(app.core.manager);

            widget.UXScaffolding = app;
            return app;
        }

        UXScaffolding.CONSTANTS = Logger.LEVEL;

        return UXScaffolding;
    });

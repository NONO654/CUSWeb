define('DS/ENOXEngineerInfra/ENOXFacade', [
  'UWA/Core',
], function(UWACore) {

    'use strict';

    function ENOXFacade(app){
      this.core = app.core;
      this._DnDManagers= [];
    }

    // Public API
  ENOXFacade.prototype = {
      /**
       * Returns the element that represents the module.
       * @returns {UWA Element} The element representing the module.
       */
      getContainer: function () {
          return this.container;
      },
      emptyContainer : function (){
        this.container.innerHTML = "";
      },
      addContent : function (content){
        this.container.innerHTML = content;
      },
      getElement: function (selector, asUWA) {

        if (asUWA) {
          return UWA.extendElement(this.container.querySelector(selector));
        }
        return this.container.querySelector(selector);
      },
      getElements: function(selector) {
        return this.container.querySelectorAll(selector);
      },
      registerDnDManager: function(options){
        console.log('implemented in ViewService');
        
      },
      unRegisterDnDManager: function(token){
        var idx = -1;
        for (var i = 0; i < this._DnDManagers.length; i++) {
          if(this._DnDManagers[i].token === token){
            idx = i;
            var that = this;
            try {
              that._DnDManagers[i].manager && that._DnDManagers[i].manager.destroy();
            } catch (error) {
              console.error(error);
            }
            
            break;
          }
        }
        if(idx>=0)
        this._DnDManagers.splice(idx,1);

      },
      unRegisterAllDnDManager: function(){
        
        for (var i = 0; i < i.length; i++) {
          const dnd = this._DnDManagers[i];
          try {
            dnd.manager && dnd.manager.destroy();
          } catch (error) {
            console.error(error);
          }
         
        }
        this._DnDManagers = null;
      },
      unsubscribeAll : function(){
        var that = this;
        this.logger.info("unsubscribeAll events ");
        var eventsObj= UWA.is(this.eventsTokens) ? this.eventsTokens : {};
        var modelEvents = this.getApplicationBroker();
        for (var events in eventsObj) {
          if (eventsObj.hasOwnProperty(events)) {
            that.logger.info("events to unsubscribe "+events);
            modelEvents.unsubscribe(eventsObj[events]);
            delete eventsObj[events];
          }
        }

      },
      stop : function(releatedModule){
        this.logger.info("stopping sandbox ");
        this.unRegisterAllDnDManager();
        this.unsubscribeAll();
        if (releatedModule) {
          this.garbageCollector(releatedModule);
        }
        this.garbageCollector(this,'container');
      },
      garbageCollector : function(object,excepts){
        // destroy remaining objects
        var keys = Object.keys(object); // will return an array of own properties
        if (UWA.is(excepts)) {
          var notDelete = excepts.split(',');
          for (var i = 0; i < notDelete.length; i++) {
            var idx = keys.indexOf(notDelete[i]);
            if (idx > -1) {
                keys.splice(idx, 1);
            }
          }
        }

        for (var i = 0; i < keys.length; i++) {
            object[keys[i]] = undefined;
        }
      }

  };


    return ENOXFacade;

});

define('DS/ENOXEngineerInfra/Interface', [], function() {

    'use strict';

    var Interface = function(name, methods) {
        if(arguments.length != 2) {
            throw new Error("Interface constructor called with " + arguments.length +
              "arguments, but expected exactly 2.");
        }
        this.name = name;
        this.methods = [];
        for(var i = 0, len = methods.length; i < len; i++) {
            if(typeof methods[i] !== 'string') {
                throw new Error("Interface constructor expects method names to be "
                    + "passed in as a string.");
            }
            this.methods.push(methods[i]);
        }
  };

    // Static class method.
  Interface.ensureImplements = function(object) {
      if(arguments.length < 2) {
          throw new Error("Function Interface.ensureImplements called with " +
            arguments.length + "arguments, but expected at least 2.");
      }
      for(var i = 1, len = arguments.length; i < len; i++) {
          var myInterface = arguments[i];
          if(myInterface.constructor !== Interface) {
              throw new Error("Function Interface.ensureImplements expects arguments"
                + "two and above to be instances of Interface.");
          }

          for(var j = 0, methodsLen = myInterface.methods.length; j < methodsLen; j++) {
              var method = myInterface.methods[j];
              if(!object[method] || typeof object[method] !== 'function') {
                    throw new Error("Function Interface.ensureImplements: object "+object
                    + "does not implement the " + myInterface.name
                    + " interface. Method ##" + method + "## was not found.");
              }
          }
      }
  };



return Interface;

});

/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Mediator Component - handling communication between components
 *
 */

define('DS/ENOXEngineerInfra/Mediator',
   [
      'DS/Core/ModelEvents',
	  'DS/PlatformAPI/PlatformAPI'
   ],

   function (
    ModelEvents, PlatformAPI) {
        'use strict';
        var _eventBroker = null;
        var mediator = function () {
            // Private variables
            _eventBroker= new ModelEvents();
        };

        /**
        * publish a topic on given channels in param, additional data may go along with the topic published
        * @param {string} eventTopic the topic to publish
        * @param {JSON} data a set of additional data (no data will be passed if null passed in param)
        * @return
        */
        mediator.prototype.publish = function (eventTopic,data) {
              _eventBroker.publish({ event: eventTopic, data: data }); // publish from ModelEvent
        };

        /**
        *
        * Subscribe to a topic
        * @param {string} eventTopic the topic to subcribe to
        * @param {function} listener the function to be called when the event fires
        * @return {ModelEventsToken}             a token to use when you want to unsubscribe
        */
        mediator.prototype.subscribe = function (eventTopic, listener) {
            return _eventBroker.subscribe({ event: eventTopic },listener);

        };

        /**
        * Unsubscribe to a topic
        * @param  {ModelEventsToken} token  the token returned by the subscribe method.
        */
        mediator.prototype.unsubscribe = function (token) {
            _eventBroker.unsubscribe(token);
        };

        /**
        * Create a new channel in the mediator. Ensures that the created channel is unique
        * @return {integer/string} channelId the id that identifies the channel created
        */
        mediator.prototype.createNewChannel = function () {
            return new ModelEvents();
        };

        mediator.prototype.getApplicationBroker = function(){
          return _eventBroker;
        };
        
        mediator.prototype.publishPlatformEvent = function(event, data){
            PlatformAPI.publish(event, data);
        };

        mediator.prototype.subscribePlatformEvent = function(event, listener){
            return PlatformAPI.subscribe(event, listener);
        };
        
        mediator.prototype.unsubscribePlatformEvent = function(token){
            return PlatformAPI.unsubscribe(token);
        };

        mediator.prototype.destroy = function(){
          _eventBroker.destroy();
        };



       return mediator;
   });

/**
 * @module DS/ENOXEgineerInfra/ENOXModulesFactory
 */
define('DS/ENOXEngineerInfra/ENOXComponentsManager', ['UWA/Core',], function(UWA) {

    'use strict';




     function ENOXComponentsManager(app){
       if (!app.componentsRepository) {
         throw new Error("componentsRepository is mandatory for components registration");
       }
       this.logger=app.core.logger.get("Components manager");
       this.componentsRepository=app.componentsRepository;
       this.componentsList = {};
       this.app = app;

     }


     //global variables
    var requireList = [];
    var CmpNameInOrder = [];
    var otherCmpList = {};



   ENOXComponentsManager.prototype.getComponent = function(cmpName) {
     return this.componentsList[cmpName] === undefined ? null : this.componentsList[cmpName];
   };


   ENOXComponentsManager.prototype.getComponentCreator = function (cmpName){
     var  component = this.getComponent(cmpName);
     if (!component) {
       this.logger.error("Component not defined");
       return null;
     }
     return  typeof component.creator !== 'function' ? null : component.creator;
   }


   ENOXComponentsManager.prototype.registerNewComponent = function(cmpName, instanceId, instance) {
     var  component = this.getComponent(cmpName);
     if (!component) {
       this.logger.error("Component not defined");
       return null;
     }
     component.instances[instanceId] = instance;
   }


   ENOXComponentsManager.prototype.deleteInstance = function(cmpName, instanceId){
     if (!this.componentsList[cmpName]) {
       return null;
     }
     delete this.componentsList[cmpName].instances[instanceId];

   }

   ENOXComponentsManager.prototype.getComponentInstance = function(cmpName, instanceId) {
     if (!this.componentsList[cmpName]) {
       return null;
     }
     return this.componentsList[cmpName].instances[instanceId] ===null || this.componentsList[cmpName].instances[instanceId] ===undefined ? null : this.componentsList[cmpName].instances[instanceId];
   };


   ENOXComponentsManager.prototype.startNewInstance = function(cmpName , container, contextData) {
     var cmpConstructor = this.getComponentCreator(cmpName);
     if (cmpConstructor === null) {
       this.logger.error("Component or constructor not defined");
       return null;
     }

     var cmpId = this.app.generateId(cmpName+'_Id_');
     var sandbox = this.app.sandboxes.create(cmpId,container);
     sandbox.getComponentName = function(){
       return cmpName;
     };


     //set some instanciation options
     sandbox.options = contextData;
     var  component = new cmpConstructor(sandbox);
     component.start();
     component.ref = cmpId;
     this.registerNewComponent(cmpName, cmpId,component );
     return component;
   }

   /**
   *cmpList e.g: [
   *                {
   *                    name :'cmp1',
   *                    container: domElement,
   *                    contextData: {data: 'bar'}
   *                  },
   *                  {
   *                     name :'cmp2',
   *                     container: domElement2,
   *                     contextData: {data: 'foo'}
   *                  }
   *            ]
   *
   **/
   ENOXComponentsManager.prototype.startInstances = function(cmpList){
     var toBeLoad = this.getUnloadedCmp(cmpList);
     var that = this;

     return  this.loadComponents(toBeLoad)
                  .then(function (){
                    // At this level all needed components are loaded
                    var instances = [];
                    for (var i = 0; i < cmpList.length; i++) {
                       var cmpDef = cmpList[i];
                       var instance = that.startNewInstance(cmpDef.name, cmpDef.container, cmpDef.contextData);
                       instances.push(instance);
                    }

                    return instances;
                  });


   }

   ENOXComponentsManager.prototype.getUnloadedCmp = function(list){
      var unloaded = {};
      for (var i = 0; i < list.length; i++) {
        var cmp = list[i];
        if ( !this.isLoaded(cmp.name) && this.isWaitingTBLoad(cmp.name) ) {
          unloaded[cmp.name] = otherCmpList[cmp.name];
          delete otherCmpList[cmp.name];
        }
      }
      return unloaded;
   }


   ENOXComponentsManager.prototype.loadComponentsCreatorsLazyLoading = function(){
    return this.loadComponents(otherCmpList)
                .then(function(){
                  otherCmpList = {};
                });
   }

   ENOXComponentsManager.prototype.loadComponentsCreatorsForBoot = function() {
       var that=this;
       return requireComponentsRepository(this.componentsRepository)
                                        .then(getStartupRequireList.bind(that))
                                        .then(requireComponents)
                                        .then(function (creatorArray) {
                                          that._buildComponentMap(creatorArray);
                                        }).catch(function(err){
                                          throw new Error("##Error loading componentsRepository : "+err);
                                        });
     };

   ENOXComponentsManager.prototype.loadComponents = function(listOFModule) {
         var that = this;

         return requireComponents(buildRequireArray(listOFModule))
                                .then(function (creatorArray) {
                                     return that._buildComponentMap(creatorArray);
                               });
    };


    function getStartupRequireList(cmpRepo) {
      var loadedCmp = cmpRepo;
      if(this.app.core.isInExperimentalLabMode()){
        loadedCmp = applyExperimentalMode(cmpRepo);
      }
       var bootCmps = loadedCmp.loadOnBoot;
       otherCmpList = loadedCmp.deffered;
        return getArrayForAMD(bootCmps);
     };

    function applyExperimentalMode (cmpRepo){
      var experimentals = cmpRepo.experimental || {};
      var expKeys = Object.keys(experimentals);
      var loadOnBoot = cmpRepo.loadOnBoot, defferedCmp = cmpRepo.deffered;

      for (var i = 0; i < expKeys.length; i++) {
        var compName  = expKeys[i];
        if(loadOnBoot[compName]){
          loadOnBoot[compName] = experimentals[compName];
          continue;
        } else if(defferedCmp[compName]){
          defferedCmp[compName] = experimentals[compName];
        }
      }

      return cmpRepo;
    };


    function buildRequireArray(componentsObj){
      if (!componentsObj) {
        throw new Error('need an object of module as input ');
      }
      return getArrayForAMD(componentsObj);
    }



    function getArrayForAMD(repObj){
      requireList = [];
      CmpNameInOrder = [];
      for (var prop in repObj) {
         if( repObj.hasOwnProperty( prop ) ) {
           requireList.push(repObj[prop]);
           CmpNameInOrder.push(prop);
         }
       }
       return requireList;
    }

    ENOXComponentsManager.prototype.isLoaded = function(cmpName){
          if (!this.componentsList[cmpName] || !this.componentsList[cmpName].creator ||  !this.componentsList[cmpName].instances) {
             return false;
          }
          return true;
    }


    ENOXComponentsManager.prototype.isWaitingTBLoad = function(cmpName){

         if( otherCmpList.hasOwnProperty( cmpName ) ) {
           return true;
         }
         return false;
    }

    ENOXComponentsManager.prototype.isAllowed = function(cmpName){
      if(this.isLoaded(cmpName) || this.isWaitingTBLoad(cmpName))
        return true;

      return false;
    }

    ENOXComponentsManager.prototype._buildComponentMap = function(listOfCreator){
         for (var i = 0; i < listOfCreator.length; i++) {
           var cmpName = CmpNameInOrder[i];
           if (!this.isLoaded(cmpName)) {
             this.componentsList[cmpName] = {};
             this.componentsList[cmpName].creator = listOfCreator[i];
             this.componentsList[cmpName].instances = {};
           }
         }
         return this.componentsList;
       };

     function requireComponentsRepository(path) {
       var that = this;
       var dfd = new Promise(function( resolve, reject){

               var resol = function (listCmp) {
                 resolve(JSON.parse(listCmp));
               };


              if (typeof path === 'string' && path.toLowerCase().endsWith("json")) {
                require(['text!'+path], resol, reject);
              }else if (typeof path === 'object') {
                resolve(path); //list of components if already provides to application
              }else {
                // in other case reject
                reject("the provided repository is not valid :( ");
              }



       });
       return dfd;
     }


     function requireComponents(requireList) {
       ///if requireList==[] then resolve promise
      return new   Promise(function( resolve, reject){
         var onSucess = function(){
           resolve(arguments);
         };
        require(requireList, onSucess, reject);
       });
     }


    return ENOXComponentsManager;
});

define('DS/ENOXEngineerInfra/router.utils',[
    'DS/Router5/js/Router5',
    'DS/Router5/js/Router5BrowserPlugin',
    'DS/Router5/js/Router5ListenersPlugin',
    'DS/Router5/js/Router5Helpers'
], function (router5, browserPlugin, listenersPlugin, helpers) {

    return {
        createRouter: function (routes, options, withListenerPlugin, withBrowserPlugin) {
            var router = router5.createRouter(routes, options);

            if (withListenerPlugin) {
                router.usePlugin(listenersPlugin());
            }
            if (withBrowserPlugin) {
                // router.usePlugin(browserPlugin({
                //     useHash: true
                // }));
            }

            return router;
        },

        listenToRouterStateChanges: function (router) {
            router.addListener(function (toState, fromState) {
                var transitionPath = helpers.transitionPath(toState, fromState);

                transitionPath.toDeactivate.forEach(function (state) {
                    if (router.routerMethods[state] !== undefined) {
                        var deactivationMethod = router.routerMethods[state].deactivate;

                        if (deactivationMethod !== undefined) {
                            deactivationMethod(toState, fromState);
                        }
                    }
                });

                transitionPath.toActivate.forEach(function (state) {
                    // If activating toState, early exit if noactivate is true (activation is handled by module)
                    if (state === toState.name && toState.params.noactivate) { return; }

                    if (router.routerMethods[state] !== undefined) {
                        var activationMethod = router.routerMethods[state].activate;

                        if (activationMethod !== undefined) {
                            activationMethod(toState, fromState);
                        }
                    }

                });
            });
        }
    };
});

/**
 * @module DS/ENOXEgineerInfra/ENOXExtensionManager
 */
define('DS/ENOXEngineerInfra/ENOXExtensionManager',
      [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/ENOXEngineerInfra/Interface',
      ],
       function(UWA,Promise,Interface) {

    'use strict';
     var _extensionsRoot = '';
    function ENOXExtensionManager(app,extRootPath){
      this._extensions=[];
      this.app = app;
      this.logger=app.core.logger;
      this.initStarted=false;
      this.initStatus= Promise.deferred();
      if (extRootPath && typeof extRootPath ==='string' && extRootPath.startsWith("DS")) {
        _extensionsRoot = extRootPath;
      }else{
        _extensionsRoot ='';
      }


    }

    var ExtensionItf=new Interface('ExtensionItf',['initialize']);



    ENOXExtensionManager.prototype.add = function(ext){

      if (this.initStarted) {
        throw new Error("Init extensions already called");
      }

      if (isExistExtension(this._extensions, ext.ref)) {

            var msg =  ext.ref.toString() + " is already registered.";
                msg += "Extensions can only be added once.";
            throw new Error(msg);
          }
          this._extensions.push(ext);
          return this;
    }

    ENOXExtensionManager.prototype.init = function(){
      var that = this;
        if (this.initStarted) {
          throw new Error("Init extensions already called");
        }

        this.initStarted = true;

        //copy of table
        var extensions    = this._extensions.slice(0);


        // for (var i = 0; i < extensions.length; i++) {
        //
        //   this._extensionsPromises.push( initExtension(extensions[i]) );
        // }

        // this.initStatus  = Promise.all(this.serialInit(extensions));

        return this.serialInit(extensions);
    };

    ENOXExtensionManager.prototype.serialInit = function(extensions){
    return  extensions.reduce(function(promise, extension){
          return new Promise(function(resolve, reject){
            promise.then(function(result){

              initExtension(extension).then(function(){
                resolve();
              }).catch(function(reason){
                reject(reason);
              });

            }).catch(function(reason){
              reject(reason);
            });
          });

      },Promise.resolve([]));
    };




    //---------------------------------------------------------------------------
    // Private API
    //---------------------------------------------------------------------------
      function isExistExtension(extArray,refExt){
        if(!refExt) throw new Error("refExt is a mandatory parameter to add extension");

        for (var i = 0; i < extArray.length; i++) {
          if (extArray[i].ref===refExt) {
            return true;
          }
        }
        return false;
      }

      /*!
       * If the value of the first argument is a function then invoke
       * it with the rest of the args, otherwise, return it.
       */
      function getVal(val) {
        if (typeof val === 'function') {
          return new val(Array.prototype.slice.call(arguments,1));
        } else {
          return val;
        }
      }

    /*!
    * Actual extension loading.
    *
    * The sequence is:
    *
    * * resolves the extension reference
    * * register and requires its dependencies if any
    * * init the extension
    *
    * This method also returns a promise that allows
    * to keep track of the app's loading sequence.
    *
    * If the extension provides a `afterAppStart` method,
    * the promise will resolve to that function that
    * will be called at the end of the app loading sequence.
    *
    * @param {String|Object|Function} extDef the reference and context of the extension
    */

    function initExtension(extDef) {

      return new Promise(function(resolve, reject){

        var ref       = extDef.ref,
            context   = extDef.context;

        var req = requireExtension(ref, context);
        req.catch(reject);
        req.then(function (ext) {

          // The extension did not return anything,
          // but probably already did what it had to do.
          if (!ext) { return resolve(); }

          try {
            Interface.ensureImplements(ext, ExtensionItf);
          } catch (e) {
            return reject(e.message);
          }

          var cstedPromise = Promise.cast(ext.initialize(context));
          cstedPromise.finally(function(){
            return resolve(true);
          });
          
        });


      })



    }

    /*!
    * Extension resolution before actual loading.
    * If `ext` is a String, it is considered as a reference
    * to an AMD module that has to be loaded.
    *
    * This method returns a promise that resolves to the actual extension,
    * With all its dependencies already required' too.
    *
    * @param {String|Object|Function} ext the reference of the extension
    * @param {Object} context the thing this extension is supposed to extend
    */

    function requireExtension(ext, context) {
      var dfd = new Promise(function( resolve, reject){

              var resol = function (Ext) {
                ext = getVal(Ext, context);
                resolve(ext);

              };

              var rej = function (err) {
                context.core.logger.error("Error loading ext:"+err);
                reject(err);
              };

              if (typeof ext === 'string') {
                require([_extensionsRoot+ext], resol, rej);
              } else {
                resol(ext);
              }

      });


      return dfd;
    }

    return ENOXExtensionManager;
});

/**
 * @summary this module is in charge to run the application
 * @desc It's initialize the application with the specified options (debug mode or not, components repository) and also the declared service aka (as known as ) extension
 * @example
 *  ENOXEngineerCore({
 *        debug: true|false, //to activate or not debug mode
 *        eagerComponentsLoading: true|false, // to specify if  we want to preload deferred components
 *        extensionsFolder:'DS/service/folder',
 *        componentsRepository: "DS/Path/to/components.json"// path to application's component declaration.
 *    }).use('path/to/service1') //service declaration
 *      .use('path/to/service2')
 *      .useRouter5({
 *         config:{
 *                   routes:[{name: 'myRoute1', path: '/home'}, //routes definition
 *                           {name: 'MyRoute2', path: '/play'}
 *                          ];
 *                   options: { //router default options https://router5.js.org/guides/router-options
 *                           defaultRoute: 'myRoute1',
 *                           defaultParams: {},
 *                           trailingSlash: false,
 *                           useTrailingSlash: undefined,
 *                           autoCleanUp: true,
 *                           strictQueryParams: true,
 *                           allowNotFound: false
 *                        }
 *        },
 *        applicationController: BootstrapController //first controller, the entrypoint of the application
 *      }).start().then(function(app){
 *        console.log('application started !!! :)');
 * });
 * 
 * 
 * @module DS/ENOXEngineerInfra/ENOXEngineerCore
 */
define('DS/ENOXEngineerInfra/ENOXEngineerCore',
        [
          'DS/ENOXEngineerInfra/Mediator',
          'DS/ENOXLogger/Logger',
          'DS/ENOXEngineerInfra/ENOXExtensionManager',
          'DS/ENOXEngineerInfra/ENOXFacade',
          'DS/ENOXEngineerInfra/ENOXComponentsManager',
          'DS/ENOXEngineerInfra/router.utils',
          'UWA/Class/Promise',
          'DS/Notifications/NotificationsManagerUXMessages',
          'DS/Notifications/NotificationsManagerViewOnScreen',
          'i18n!DS/ENOXEngineerInfra/assets/nls/xAppCore.json'
        ],
         function(Mediator,Logger,ENOXExtensionManager,ENOXFacade,ENOXComponentsManager,routerUtils,Promise,NotificationsManagerUXMessages ,NotificationsManagerViewOnScreen, nlsKeys) {

    'use strict';

    var _uniqueId=0;
    /**
    * @class ENOXEngineerCore
    * @param {Object} [config] Main App config.
    * @method constructor
    **/
    function ENOXEngineerCore(config){

      if (!(this instanceof ENOXEngineerCore)) {
        return new ENOXEngineerCore(config);
      }

      // Public API
      var app = this;

      this._notif_manager = NotificationsManagerUXMessages;
      NotificationsManagerViewOnScreen.setNotificationManager(this._notif_manager);
      NotificationsManagerViewOnScreen.setStackingPolicy(5);

      app.generateId=function(prefix){
        if(prefix===null || prefix===undefined){
          prefix=null;
        }
        return prefix===null ? ++_uniqueId : prefix+(++_uniqueId);
      };

      // Flag whether the application has been started
      app.started = false;

      //components repository management
      app.componentsRepository = config.componentsRepository;

      app.eagerComponentsLoading = config.eagerComponentsLoading;

      var logger_level;
      config.LOG_LEVEL = 'off';
      /// activate logger on debug mode
      if(config.debug)
      config.LOG_LEVEL = 'debug';
      switch(config.LOG_LEVEL.toUpperCase()){
        case 'DEBUG':
                    logger_level=Logger.LEVEL.DEBUG;
                    break;
        case 'INFO':
                    logger_level=Logger.LEVEL.INFO;
                    break;
        case 'WARN':
                    logger_level=Logger.LEVEL.WARN;
                    break;
        case 'ERROR':
                    logger_level=Logger.LEVEL.ERROR;
                    break;
        case 'OFF':
                    logger_level=Logger.LEVEL.OFF;
                    break;
        default :
                    logger_level=Logger.LEVEL.OFF;
      }


      var loggerConfig = {
                      level: logger_level
                    };

      Logger.init(loggerConfig) ;

      // core is just a namespace used to add features to the App
      app.core={}; //appCore, app.core

      app.core.isInExperimentalLabMode = function(){
        return (widget.getValue('experimentalCmp') && widget.getValue('experimentalCmp').toLowerCase() == "true") ? true : false;
      }

      app.mandatoryStartupPromises = [];
      app.optionalStartupPromises = [];


      // TODO to be refacor
      app.core.logger=Logger;
      app.core.isOnDebugMode = config.debug;
      app.logger = Logger;
      //p provided namespace
      app.core.moduleHelper = {};

      app.sandboxBase= new ENOXFacade(app);
      var extensionFolder = (config.extensionsFolder && config.extensionsFolder.length>0 ) ? config.extensionsFolder : 
                                      (config.odtExtensionRoot) ?  config.odtExtensionRoot :'DS/ENOXEngineer/'; 
      var extManager = new ENOXExtensionManager(app, extensionFolder);

      app.mediator = new Mediator();
      app.core.mediator = app.mediator;

      //components manager

      app.componentsMgt= new  ENOXComponentsManager(app);

      var bootCompLoadPromise = app.componentsMgt.loadComponentsCreatorsForBoot();



      /**
       * Tells the app to load the given extension.
       *
       * extensions are loaded in the app during init.
       * they are responsible for :
       *
       * - resolving & loading external dependencies via requirejs
       * - they have direct access to the app's internals
       * - they are here to add new features to the app... that are made available through the sandboxes to the components.
       *
       * This method can only be called before the App is actually started.
       * Note that the App is started when its `start` method is called.
       *
       * @method use
       * @param  {String} ref the reference of the extension
       * @return {ENOXEngineerCore} the ENOXEngineerCore app object
       * @chainable
       */
      app.use = function(ref) {
        extManager.add({ ref: ref, context: app });
        return app;
      }

      /**
       * Namespace for sanboxes related methods.
       *
       * @type {Object}
       */
      app.sandboxes = {};
      var appSandboxes = {};

      app.sandboxes.create = function(ref, container) {
        ref = ref || app.generateId('sandbox-');
        if (appSandboxes[ref]) {
          throw new Error("Sandbox with ref " + ref + " already exists.");
        }

        // Create a brand new sandbox based on the baseSandbox
       var sandbox = Object.create(app.sandboxBase);

       // Give it a ref
       sandbox.ref = ref || app.generateId('sandbox-');
       sandbox.container = container;



       // Attach a Logger
       sandbox.logger = app.core.logger.get(sandbox.ref);

       sandbox.eventsTokens={};
       sandbox.platformEventsTokens={};

       //mediator binding
       sandbox.publish = app.mediator.publish;
       sandbox.publishPlatformEvent = app.mediator.publishPlatformEvent;

       sandbox.getApplicationBroker = app.mediator.getApplicationBroker;

       sandbox.subscribe = function (eventTopic, listener) {
         if (sandbox.eventsTokens[eventTopic]) {
           throw new Error("Sandbox with ref " + ref + " has already subscribed to this topic "+eventTopic);
         }
          var token = app.mediator.subscribe(eventTopic,listener);
          sandbox.eventsTokens[eventTopic] = token;
       };

       sandbox.subscribePlatformEvent = function (eventTopic, listener) {
        if (sandbox.platformEventsTokens[eventTopic]) {
          throw new Error("Sandbox with ref " + ref + " has already subscribed to this platform topic "+eventTopic);
        }
         var token = app.mediator.subscribePlatformEvent(eventTopic,listener);
         sandbox.platformEventsTokens[eventTopic] = token;
      };

       sandbox.unsubscribe = function(eventTopic){
         if (!sandbox.eventsTokens[eventTopic]) {
          //  throw new Error("Sandbox with ref " + ref + " has not  subscribed to this topic "+eventTopic);
          sandbox.logger.error("Sandbox with ref " + ref + " has not  subscribed to this topic "+eventTopic);
          return null;
         }
         var token = sandbox.eventsTokens[eventTopic];
         app.mediator.unsubscribe(token);
         delete sandbox.eventsTokens[eventTopic];
       }

       sandbox.unsubscribePlatformEvent = function(eventTopic){
        if (!sandbox.platformEventsTokens[eventTopic]) {
         //  throw new Error("Sandbox with ref " + ref + " has not  subscribed to this topic "+eventTopic);
         sandbox.logger.error("Sandbox with ref " + ref + " has not  subscribed to this platform topic "+eventTopic);
         return null;
        }
        var token = sandbox.platformEventsTokens[eventTopic];
        app.mediator.unsubscribePlatformEvent(token);
        delete sandbox.platformEventsTokens[eventTopic];
      }



       // Register it in the app's sandboxes registry
       appSandboxes[sandbox.ref] = sandbox;

       return sandbox;
      }


      /**
       * Get a sandbox by reference.
       *
       * @method sandboxes.get
       * @param  {String} ref  the Sandbox ref to retreive
       * @return {Sandbox}
       */
      app.sandboxes.get = function(ref) {
        return appSandboxes[ref];
      };



      app.start = function(options) {
        if (app.started) {
          app.core.logger.error("xEngineer App already started!");
          throw new Error("xEngineer App already started!");
        }

        app.core.logger.warn("xEngineer App starting ! ");
        app.started = true;
        app._startInit= (new Date()).getTime();
        var allCoreReady = Promise.all([bootCompLoadPromise, extManager.init()]);


        return new Promise(function(resolve, reject){
                allCoreReady.then(function() {
                      var allMandRead = Promise.all( app.mandatoryStartupPromises );
                      var allOptionalsReady = Promise.allSettled(app.optionalStartupPromises );

                       if(app.eagerComponentsLoading){
                           // setTimeout(function(){
                           //   //TODO redesign lazy loading
                           //   // app.componentsMgt.loadComponentsCreatorsLazyLoading();
                           // },200);
                       }
                       allMandRead.then(function(){
                         allOptionalsReady.finally(function(){
                           if (app.mainController && typeof app.mainController.initialize === 'function') {
                             app.mainController.initialize();
                           }
                           resolve(app)
                         });
                       }).catch(function(error){
                         console.error(error);
                         app.notifyGenericIssue();
                         reject(error);
                       });
               }).catch(function(reason){
                 console.error(reason);
                 app.notifyGenericIssue();
               }); // end allCoreReady
        });

      }

      app.notifyGenericIssue = function(){
        app._notif_manager.addNotif({
          level: "error",
          message: nlsKeys.get("error.on.startup"),
          sticky: false
        });
      };

      app.stop = function() {

      }

      app.getStartupTime = function (){
        return (new Date()).getTime() - app._startInit;
      }

      app.useRouter5 = function (options) {
        //data validation
          if (!options) {
            throw new Error("options are needed to set router 5");
          }else if (!options.config || !options.applicationController) {
            throw new Error("config and applicationController are mandatory options");
          }

          var config = options.config;
          var AppController = options.applicationController;
          if (!config.routes || !config.options) {
            throw new Error("routes or options are undefined");
          }

          if (typeof AppController !== 'function') {
            throw new Error("applicationController should be a class (function) !");
          }
          // end of validation

          app.router = routerUtils.createRouter(config.routes, config.options, true, true);
          app.routerUtils = routerUtils;
          app.core.navigate = app.router.navigate;

          //Apllication controller initization
          app.mainController = new AppController(app);

          return app;
      }



    }



    return ENOXEngineerCore;

});


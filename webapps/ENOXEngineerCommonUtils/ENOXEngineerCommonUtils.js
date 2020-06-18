define('DS/ENOXEngineerCommonUtils/CancelablePromise', [
    'UWA/Promise'
], function(UWAPromise) {

    'use strict';

    var CancelablePromise = UWAPromise;

    CancelablePromise.prototype.cancelEmbeddedRequest = function(reason){
            if(this.xEngEmbeddedRequest)
                this.xEngEmbeddedRequest.cancel();
    }

    return CancelablePromise;

});

define('DS/ENOXEngineerCommonUtils/xEngAlertManager', [
  'DS/Notifications/NotificationsManagerUXMessages',
  'DS/Notifications/NotificationsManagerViewOnScreen'
], function (
  NotificationsManagerUXMessages,
  NotificationsManagerViewOnScreen,
  WUXNotificationsOnScreenFadeOutPolicy
) {

  'use strict';


  var xEngAlertManager = {
    _notif_manager: null,
    init: function (options) {

      if (this._notif_manager === null) {
        // logger.log('Initialize the notification manager');
        this._notif_manager = NotificationsManagerUXMessages;
        NotificationsManagerViewOnScreen.setNotificationManager(this._notif_manager);
        NotificationsManagerViewOnScreen.setStackingPolicy(5);
        NotificationsManagerViewOnScreen.setRemoveStackOnFirstTimeoutFlag(true);
        NotificationsManagerViewOnScreen.setFadeOutPolicy(2);
      }

    },
    errorAlert: function (message) {
      if (!this._notif_manager)
        this.init();

      this._notif_manager.addNotif({
        level: "error",
        message: message,
        sticky: false
      });
    },
    sucessAlert: function (message) {
      if (!this._notif_manager)
        this.init();

      this._notif_manager.addNotif({
        level: "success",
        message: message,
        sticky: false
      });
    },
    notifyAlert: function (message) {
      if (!this._notif_manager)
        this.init();

      this._notif_manager.addNotif({
        level: "info",
        message: message,
        sticky: false
      });
    },
    warningAlert: function (message) {
      if (!this._notif_manager)
        this.init();

      this._notif_manager.addNotif({
        level: "warning",
        message: message,
        sticky: false
      });
    }

  };

  return xEngAlertManager;

});

define('DS/ENOXEngineerCommonUtils/XENModal',
[
  'DS/ENOFloatingPanel/ENOFloatingPanel',
  // 'DS/UIKIT/Modal',
  'UWA/Core',
  'i18n!DS/ENOXEngineerCommonUtils/assets/nls/XENCommonNls.json'
], function(Modal, UWA, nlsKeys) {

    'use strict';

    function _getDefaultFooter(){
      return "<button type='button' name='okButton' class='btn btn-primary'>"+nlsKeys.get('eng.ui.button.ok')+"</button> " +
      "<button type='button' name='cancelButton' class='btn btn-default'>"+nlsKeys.get('eng.ui.button.cancel')+"</button>";
    }

    function _createModal(options){
      var modal = new Modal({
        className: options.className || '',
        closable: true,
        title: options.title,
        body:'',
        footer: '',
        animate: true,
        resizable: true,
        autocenter: true,
        visible: true,
        limitParent: true,
        overlay: true,
        persistId: options.persitId || 'XEN_dialog',
        events: options.events || {}
      });
      return modal;
    }



    /*
    *options.title
    *options.withFooter
    *options.className
    */
    function XEngineerModal(options){
      var that = this;
        this.options = {
          title : 'Dialog',
          persitId: options.persitId || 'XEN_dialog',
          withFooter : true
        };
        this.options = UWA.extend(this.options, options);

        this.options.events ={
          
          // "onResizeFloating": function(){
          //  console.warn('onResizeFloating');
           
          // },
          // "onMove": function(){
          //   console.warn('onMove');
          // },
          onClose: function(){
            if(that.options.onClose)
              that.options.onClose.apply();
            that.destroy();
          },
          onHide: function(){ // IR-495954-3DEXPERIENCER2016x
            if(that.options.onClose)
                that.options.onClose.apply();
            that.destroy();

          }
        };

        this.modal = _createModal(this.options);

        setTimeout(function(){ // import due to some asynch init
          var minWidth = 200, minHeight=200;
          if(that.options.minSize){
            if(that.options.minSize.width)
              minWidth  = that.options.minSize.width;
            if(that.options.minSize.height) 
              minHeight = that.options.minSize.height;
          }
          that.modal&& that.modal.setMinSize(minWidth,minHeight);
        },10);
        var container = widget ? widget.body : document.body;
        this.modal.inject(container);
        if(this.options.withFooter){
            if(this.options.customFooter){
              this.modal.setFooter( this.options.customFooter() );
            }else{
              this.modal.setFooter( _getDefaultFooter() );
            }
            this._bindFooterEvent();
        }

    }

    XEngineerModal.prototype.isNotDestroyed= function () {
        return (this.modal && this.options);
    };

    XEngineerModal.prototype.show = function () {
        this.modal.show();
    };
    XEngineerModal.prototype.dispose = function(){
      this.modal.hide();
    };
    XEngineerModal.prototype.injectBody = function(content){
      this.modal.setBody(content);
    };
    XEngineerModal.prototype.inject = function(content){
        this.modal.inject(content);
      };

    XEngineerModal.prototype.getBody = function(){
      return this.modal.getBody();
    };

    XEngineerModal.prototype.injectHeader = function(content){
      this.modal.setHeader(content);
    };

    XEngineerModal.prototype.injectFooter = function(content){
      this.modal.setFooter(content);
    };
    XEngineerModal.prototype._unbindFooterEvent = function(){
      
    }
    XEngineerModal.prototype._bindFooterEvent = function(){
      var that = this;

      this.modal.getFooter().getElements('.btn').forEach(function (element){
        if(element.name === 'cancelButton'){
          element.addEvent('click', function () {
            if(that.options.onClose)
                that.options.onClose.apply();
            that.destroy();
          });
        }

        if(element.name === 'okButton'){
          element.addEvent('click', function () {
              if(that.options.onValidate)
                that.options.onValidate.apply();
                that.destroy();
          });

        }
      });

    };

    XEngineerModal.prototype.getContent = function(){
      return this.modal.getContent();
    }

    XEngineerModal.prototype.destroy = function(){
      if(this.options.relatedCommand && typeof this.options.relatedCommand === 'function')
        this.options.relatedCommand.end();
      this.modal.destroy();
      var keys = Object.keys(this);
      for (var i = 0; i < keys.length; i++) {
          this[keys[i]] = undefined;
          delete this[keys[i]];
      }
    }

    return XEngineerModal;

});

define('DS/ENOXEngineerCommonUtils/XENCommonConstants', [], function() {

    'use strict';

    var XENCommonConstants = {
     /** service name */
     SERVICE_3DSPACE_NAME : "3DSpace",
     SERVICE_3DCOMPASS_NAME : "3DCompass",
     SERVICE_3DSWYM_NAME : "3DSwym",
     SERVICE_3DSEARCH_NAME : "3DSearch",
     SERVICE_3DPASSPORT_NAME : "3DPassport",
     SERVICE_6WTAGS_NAME : "6WTags",
     SERVICE_COMMENT_NAME : "comment",
     SERVICE_3DNOTIFICATIONS_NAME : "3dnotifications"
   };

   return  XENCommonConstants;
});

define('DS/ENOXEngineerCommonUtils/XENMask', [
    'UWA/Core',
    'DS/Controls/Loader',
    'i18n!DS/ENOXEngineerCommonUtils/assets/nls/XENCommonNls.json'
], function(UWA, WUXLoader,nlsKeys) {

    'use strict';

    var XENMask = {

            /**
             * Create a mask over the provided element.
             * @example
             * require(['DS/ENOXEngineerCommonUtils/XENMask'], function (Mask) {
             *     var element = UWA.createElement('div');
             *     Mask.mask(element);
             * });
             * @param {Element} element               - The DOM element to mask.
             * @param {String} [message='Loading...'] - An optional message to display.
             */
            mask: function (element, message) {

                var mask;

                if (this.isMasked(element)) {
                    this.unmask(element);
                }

                element.addClassName('masked');
                mask = UWA.createElement('div', { 'class': 'mask' });
                this.loader = new WUXLoader({text: UWA.is(message, 'string') ? message : nlsKeys.get('loading'), showButtonFlag:false});

                message = UWA.createElement('div', {
                    'class': 'mask-wrapper',
                    html: {
                        tag: 'div',
                        'class': 'mask-content',
                        html: [
                            this.loader
                        ]
                    }
                }).inject(mask);
                this.loader.on();

                mask.inject(element);
            },

            /**
             * Unmask the provided element.
             * @param {Element} element - The DOM element to unmask.
             */
            unmask: function (element) {
                var mask = element.getElement(' > .mask');
                if (mask) { mask.destroy();
                    if(this.loader){
                        this.loader.off();
                        this.loader.destroy();
                        this.loader = null;
                    }
                   
                }
                element.removeClassName('masked');
            },

            /**
             * Test if element is masked or not.
             * @param {Element} element - The DOM element to check for mask.
             * @returns {Boolean} - `true` if element is masked. False otherwise.
             */
            isMasked: function (element) {
                return element.hasClassName('masked');
            }
    };

    return XENMask;

});

define('DS/ENOXEngineerCommonUtils/PromiseUtils', [
    'UWA/Promise',
    'DS/ENOXEngineerCommonUtils/CancelablePromise'
], function(Promise, CancelablePromise) {

    'use strict';

    var PromiseUtils = {
        wrappedWithPromise : function(runnableFunction){
            return new Promise(runnableFunction);
        },
        wrappedWithCancellablePromise  : function(runnableFunction){
            return new CancelablePromise(runnableFunction);
        },
        allSettled : function(promises){
            return Promise.allSettled(promises);
        },
        all : function(promises){
            return Promise.all(promises);
        },
        /**
         * 
         * @param {*} options{
         * promise: _promise,
         * getFallback:fallback provider,
         * onSuccessFallBack: function(){}
         * } 
         */
        getResilientPromise: function(options){
            return new Promise(function(resolve, reject){
                Promise.cast(options.promise).then(function(response){
                    resolve(response);
                }).catch(function(reason){
                    Promise.cast(options.getFallback()).then(function(res){
                        options.onSuccessFallBack && options.onSuccessFallBack();
                        resolve(res);
                    }).catch(function(error){
                        console.warn('fail of callback %s', error);
                        reject(reason);
                    });
                })
            });
        }
    }
    return PromiseUtils;

});

/**
 * @module DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings
 */
define('DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings', [
  'UWA/Core',
  'UWA/Class',
  'DS/WAFData/WAFData',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineerCommonUtils/XENCommonConstants',
  /*PlatformAPI*/
  'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
  'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
  'text!DS/ENOXEngineerCommonUtils/assets/config/commonConf.json'
], function(UWA, Class, WAFData, PromiseUtils, XENCommonConstants, i3DXCompassPlatformServices, CfgAuthoringContext, commonConf) {

    'use strict';

    function platformResponseParser (respServices) {
      // ensure that we retrieve data from myApp
      if (UWA.is(respServices,"array") && respServices.length>0) {

        var platforms = {};

         respServices.forEach(function(platform){
           platforms[platform.platformId] = platform;
         });

         return platforms;
      } else {
        return null;
      }
     }

     var commonSettings =JSON.parse(commonConf);

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings
     * @param {Object} options options hash or a option/value pair.
     */
    var XENPlatform3DXSettings ={
        _isPlatformDataInitialized: false,
        _platforms: null,
        _user:null,
        _discoveringPlatformPromise:null,
        /**
         * overwritten by XEN Webapp Setting service
         * @param {*} command
         */
        getCommand: function(command){
          if (UWA.is(command,'string') && UWA.is(commonSettings['commands'][command])) {
            return commonSettings['commands'][command];
          }
          return null;
        },
        getLanguage: function () {
          if(widget.lang && widget.lang.length>1) return widget.lang;
          return 'en';
        },
        _checkRoles : function(acceptedRoles){
          var that = this;
          if(!Array.isArray(acceptedRoles) || !Array.isArray(that.roles))
            return false;
          for (var i = 0; i < acceptedRoles.length; i++) {
              for (var j = 0; j < that.roles.length; j++) {
                if(that.roles[j].id === acceptedRoles[i])
                  return true;
              }
          }

          return false;
        },
        isConfigRoleGranted : function(){
          var that = this;
          return that._checkRoles(["CDN","CFG","CH2","CH5","CMM","COD","COX","CTP","DPM","EEW","GLR","MBO","PDA","PDM","QUM","REM","SAZ","SDZ","SMZ","SPJ","SPM","SPV","TRM","UWE","UWU","UXG","InternalDS"]);
        },
        getWidgetId: function() {
          try{
              if (widget) return widget.id;
            } catch(ex){
              //we are in ODT mode
              return 'widget-odt';
            }
        },
        getPlatformId: function() {
          var that = this;
          if(that._platformId) {
            return that._platformId;
          }
          try {
            if (widget) {
              that._platformId = widget.getValue('x3dPlatformId') ? widget.getValue('x3dPlatformId') : that._getAlternativePlatformId();
            }
            return that._platformId;
          } catch(ex) {
            return 'OnPremise' ; //odt case
          }

        },
        isTenantBasedService : function(serviceId){
          return commonSettings.tenantBasedServices.indexOf(serviceId)>=0;
        },
        isCloud: function() {
          var isCloud = true;
          if(this.getPlatformId() === 'OnPremise') {
            isCloud = false;
          }
          return isCloud;
        },
        _getAlternativePlatformId : function(){
          if (this._platforms["OnPremise"]) {
            return "OnPremise";
          }else {
            //test if is a native env in cloud context
            if(this.isWebInWinEnvironment()){
              this._platformId = this.getUrlParameter("tenant") || "OnPremise";
              return this._platformId ;
            }
            //get selected one from widget
            return null;
          }
        },
        bindCommandsToABackend: function(withSC){
          var that = this;
          if(that.bindCommandPromise){
            return that.bindCommandPromise;
          }
          that.bindCommandPromise = PromiseUtils.wrappedWithPromise(function (resolve, reject){
            
            that.discoverRelated3DXPlatform().then(function(){
              if(!withSC){
                return resolve(true); // no need to retrieve preferred security context
              } 

              that.retrieveUserPreferredSC().then(function(){
                resolve(true);
              }).catch(function(error){
                console.error(error);
                reject(false);
              })

            }).catch(function(){
              reject(false);
            });
          });
          return that.bindCommandPromise;
        },
        isRelatedPlatformSet: function(){
          return this._isPlatformDataInitialized;
        },
        discoverRelated3DXPlatform: function(){
          var that = this;
          if(that._discoveringPlatformPromise){
            return that._discoveringPlatformPromise;
          }
          that._discoveringPlatformPromise = PromiseUtils.wrappedWithPromise(function (resolve, reject) {
            var promises = [];
            promises.push( that.getAllPlatforms() );
            promises.push( that.loadCurrentUserRoles() );
            promises.push( that.retrieveCurrentUser() );

            PromiseUtils.all(promises).then(function(){
              resolve(true);
              that._isPlatformDataInitialized = true;
            }).catch(reject);
          });

          return that._discoveringPlatformPromise;
        },
        retrieveUserPreferredSC: function(){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function (resolve, reject){
              that.discoverRelated3DXPlatform().then(function(){
                var cmd = (commonSettings && commonSettings.commands) ? commonSettings.commands.getPreferredSC: null;
                if(!cmd) return reject();
                if(that._preferredSC) return resolve(that._preferredSC);

                var url = that.getServiceURL(cmd.targetService) + cmd.url + "?tenant="+that.getPlatformId();
                WAFData.authenticatedRequest(url, {
                  'method'    :'GET',
                  'type'     : 'json' ,
                  'onComplete': function(data){
                      if(data){
                        that._preferredSC = data.SecurityContext;
                       return  resolve();
                      }
                      //failed to retrieve SC
                      reject();

                  },
                  'onFailure' : function() {
                    return reject();
                  }
                });
                // XENGenericHttpClient.perform(cmd).then(function(data){
                //   if(data){
                //     that._preferredSC = data.SecurityContext;
                //   }
                //   resolve();
                // }).catch(function(){
                //   reject();
                // });
              }).catch(function(){
                reject();
              });
          });
        },
        hasSecurityContext: function(){
          return (this.getSecurityContext());
        },
        setDefaultSecurityContext: function(sc){
          this._sc = sc;
        },
        getPreferredSC:  function(){
          return this._preferredSC;
        },
        /**
         * to be overwrite in XEN app, using widget pref
         */
        getSecurityContext : function() {
          return (this._sc) ? this._sc : this.getPreferredSC();
        },
        getSecurityToken: function(){
          var user = this.getCurrentUser() || {};
          return user.id + '|' + 'ctx::'+this.getSecurityContext() + '|preferred';
        },
        securityContextPromise : null,
        getDefault3DSpaceUrl:function(){
          return this.getServiceURL(XENCommonConstants.SERVICE_3DSPACE_NAME);
        },
        getDefault3DSearchUrl : function(){
          return this.getServiceURL(XENCommonConstants.SERVICE_3DSEARCH_NAME);
        },
        get3DCompassUrl : function(){
          return this.getServiceURL(XENCommonConstants.SERVICE_3DCOMPASS_NAME);
        },
        get6wTagURL : function(){
          return this.getServiceURL(XENCommonConstants.SERVICE_6WTAGS_NAME);
        },
        getDefault3DSpaceURI:function(url){
          var url3DSpace = this.getDefault3DSpaceUrl();//buggy
          return url3DSpace.substring(0,url3DSpace.indexOf("/"+XENCommonConstants.SERVICE_3DSPACE_NAME));
        },
        getServiceURL : function(serviceId, tenant){
          tenant = tenant ? tenant : this.getPlatformId();
          if (this._platforms && this._platforms[tenant] && this._platforms[tenant][serviceId]) {
            return this._platforms[tenant][serviceId];
          }else {return null;
          }
        },
        getAuthorizedChange : function(){
          if(!this.authorizedChange){
            this.authorizedChange = CfgAuthoringContext.get();
            //this.authorizedChange = this.authorizedChange.change;
          }
          return this.authorizedChange;
        },
        getCurrentUser:function(){
          return this._user;
        },
        getUserName:function(){
          var user = this._user;
          var userName = user.firstName+" "+ user.lastName;
          return userName;
        },
        getWorkUnderHeaders: function(){
           this.getAuthorizedChange(); //bind if needed workunder
          if (this.authorizedChange && this.authorizedChange.AuthoringContextHeader) {
            return Object.assign({}, this.authorizedChange.AuthoringContextHeader);
          }
          return {};
        },
        getAllPlatforms: function() {
          var that = this;
            return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
                i3DXCompassPlatformServices.getPlatformServices({
                    onComplete: function (respServices) {
                        var platformUrls = platformResponseParser(respServices);

                        if (platformUrls===null) {
                          return reject("cannot retrieve platform data");
                        }
                        that._platforms = platformUrls;
                        resolve(platformUrls);
                    },
                    onFailure: reject
                });
            });
        },
        retrieveCurrentUser:function(){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
              if(that._user && that._user.id){
                return resolve(that._user);
              }
              i3DXCompassPlatformServices.getUser({
                  onComplete:function(data){
                     that._user = {
                      id:data.id,
                      email:data.email,
                      firstName:data.firstname,
                      lastName:data.lastname
                    };
                    resolve(that._user);
                  },
                  onFailure:reject
              });
          });
        },
        loadCurrentUserRoles : function(){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            i3DXCompassPlatformServices.getGrantedRoles(function (userGrantedRoles) {
              that.roles = userGrantedRoles;
              resolve(userGrantedRoles);
             });
          });

        },
        isNatifEnvironnement: function(){
				  return typeof(dscef) !== 'undefined';
    		},
        isWebInWinEnvironment: function(){
    			return this.isCatiaV5Environment() || this.isSolidworksEnvironment();
    		},
    		isCatiaV5Environment: function(){
    			var name = this._getEnvironment();
    			return name === "catiav5";
    		},
    		isSolidworksEnvironment: function(){
    			var name = this._getEnvironment();
    			return name === "solidworks";
    		},
    		_getEnvironment: function(){
    			return this.getUrlParameter("addinmode"); //widget.getValue("addinmode");
    		},

    		getUrlParameter: function(keyParam){
    			var urlParams = this._getUrlParameters();
    			return urlParams[keyParam];
    		},
        _getUrlParameters: function(){
				if (!this.storedUrlParams){
					var queryDict = {};
					var forSearch = [window.top.location];
					if (window !== window.top) forSearch.push(window.location);

					forSearch.forEach(function(loc){
						loc.search.substr(1).split("&").forEach(function(item) {
							var itemSplitted = item.split("=");
							if (itemSplitted.length > 1)
							{
								queryDict[itemSplitted[0]] = itemSplitted[1]
							}
						});
					});
					this.storedUrlParams = queryDict;
				}
				return this.storedUrlParams;
			}
    };

    return XENPlatform3DXSettings;
});

/**
 * @module DS/ENOXEngineerCommonUtils/XENWebInWinHelper
 */
define('DS/ENOXEngineerCommonUtils/XENWebInWinHelper', [
    'UWA/Core', 
    'UWA/Class',
    'DS/WebToWinInfra/WebToWinCom',
    'DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings'], 
function(UWA, Class, WebToWinCom, XENPlatform3DXSettings ) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineerCommonUtils/XENWebInWinHelper
     * @param {Object} options options hash or a option/value pair.
     */
    var XENWebInWinHelper = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineerCommonUtils/XENWebInWinHelper
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initializeSocket: function(){
            if(XENPlatform3DXSettings.isWebInWinEnvironment()){
                this.getSocket();
            }
        },
        // =====================================================================================
        // createWebInWinSocket
        // =====================================================================================
        createWebInWinSocket : function(socketLabel) {
            var socket = WebToWinCom
                    .createSocket({
                        socket_id : socketLabel
                    });
            return socket;
        },
        getSocket: function(){
            if(this.socket) return this.socket;

            this.socket = this.createWebInWinSocket('xen_web_in_win');
            return this.socket;
        },

        // =====================================================================================
        // closePanel
        // =====================================================================================
        closePanel : function() {
            if(!XENPlatform3DXSettings.isWebInWinEnvironment()) return ;

            this.getSocket().dispatchEvent('onDispatchToWin', {
                notif_name: 'ClosePanel',
                notif_parameters:  'ClosePanel'
            }, 'xen_web_in_win');
        },
        notifyUpdatedEnterpriseItem: function( data){
            if(!XENPlatform3DXSettings.isWebInWinEnvironment()) return ;

            this.getSocket().dispatchEvent('onDispatchToWin', {
                notif_name: 'engineering/setPartNumber',
                notif_parameters:  JSON.stringify({
                    action:'engineering/setPartNumber',
                    Args:[{
                        Name :'response',
                        Value : data
                    }]
                })
            }, 'xen_web_in_win');
        },
        commandViewReady: function(){
            if(!XENPlatform3DXSettings.isWebInWinEnvironment()) return ;

            this.getSocket().dispatchEvent('onDispatchToWin', {
                notif_name: 'engineering/viewready',
                notif_parameters:  JSON.stringify({
                    action:'engineering/viewready',
                    Args:[{
                        Name :'status',
                        Value :'up' 
                    }]
                })
            }, 'xen_web_in_win');
        }

    });

    return XENWebInWinHelper;
});

/**
 * @overview Utility file for common XEN WS calls 
 * @licence Copyright 2006-2019 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXEngineerCommonUtils/XENGenericHttpClient', [
	  'DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings',
      'DS/WAFData/WAFData',
      'UWA/Json',
	  'DS/ENOXEngineerCommonUtils/PromiseUtils',
	  'DS/ENOXEngineerCommonUtils/XENCommonConstants'
  ], function (XENPlatform3DXSettings, WAFData, Json, PromiseUtils, XENCommonConstants) {
	'use strict';

	function validateRequest(req){
		if(!req  || !req.url || !req.method || !req.type || !req.targetService)
			throw new Error("the request is not valid !!");
		
			return true;
	}

	var XENGenericHttpClient = {
			buildUrl : function(cmd){
				var rootUrl = XENPlatform3DXSettings.getServiceURL(cmd.targetService);
				if(XENPlatform3DXSettings.isTenantBasedService(cmd.targetService)){
					rootUrl = this.decorateUrlWithTenant(rootUrl+cmd.url);
				}else{
					rootUrl = rootUrl+cmd.url;
				}
				return rootUrl;
			},
			decorateUrlWithTenant: function(url){
				var currentUrl = url || '';
				var containParam = currentUrl.indexOf('?');
				if (containParam > -1) {
				  currentUrl = currentUrl + "&tenant="+XENPlatform3DXSettings.getPlatformId();
				} else {
				  currentUrl = currentUrl + "?tenant="+XENPlatform3DXSettings.getPlatformId();
				}
				return currentUrl;
			},
			/**
			 * to be overwrite in XEN app 
			 */
			decorateWithAddtionnaloptions: function(fetchOpts, cmd){

				if (!cmd.noSecurityContextNeeded && cmd.targetService === XENCommonConstants.SERVICE_3DSPACE_NAME) {
							
					fetchOpts.headers.SecurityContext = encodeURIComponent('ctx::'+XENPlatform3DXSettings.getSecurityContext());
					// IR-642113-3DEXPERIENCER2018x: encode the Security context for Double byte characters
					fetchOpts.headers.SecurityToken = encodeURIComponent(XENPlatform3DXSettings.getSecurityToken());
				}
			},
			perform: function (cmd, data) {
					var that = this,
						request = null;
					var promise = PromiseUtils.wrappedWithCancellablePromise(function (resolve, reject) {
						var stringfiedData = null;
						validateRequest(cmd);
						if(cmd.type === 'file'){
							stringfiedData = data;
						}else if (UWA.is(data) && !Json.isJson(data) && !UWA.is(data, 'string')) {
							stringfiedData = Json.encode(data);
						}else{
							stringfiedData = data;
						}
						var fetchOpts = {
							method: cmd.method,
							cache: cmd.cache || false,
							type: cmd.type,
							data : stringfiedData,
							headers: {}
						}
						if (cmd.type === 'json') {
							fetchOpts.headers = {
								'Accept': 'application/json',
								'Content-Type': 'application/json',
								'Accept-Language': XENPlatform3DXSettings.getLanguage()
							};
						} else if (cmd.type === 'xml') {
							fetchOpts.headers = {
								'Accept': 'application/xml',
								'Content-Type': 'application/xml',
								'Accept-Language': XENPlatform3DXSettings.getLanguage()
							};

						}else if (cmd.type === 'octet-stream') {
							fetchOpts.headers = {
									'Content-Type': 'application/json',
									'Accept-Language': XENPlatform3DXSettings.getLanguage()
								};

						}else if (cmd.type === 'file') {
							fetchOpts.headers = {
									'Accept':'application/json',
									'Accept-Language': XENPlatform3DXSettings.getLanguage()
								};
						}

						if(cmd.timeout){
							fetchOpts.timeout = cmd.timeout;
						}

						if(cmd.customHeaders)
							fetchOpts.headers = Object.assign(fetchOpts.headers, cmd.customHeaders);

						if (cmd.noContentType){
							delete fetchOpts.headers['Content-Type'];
						}

						that.decorateWithAddtionnaloptions(fetchOpts, cmd);

						if( cmd.isChangeControlled === true){
							fetchOpts.headers = Object.assign(fetchOpts.headers, XENPlatform3DXSettings.getWorkUnderHeaders());
						}
						
						var url  = that.buildUrl(cmd);
						
						var wrappedResolve = function (response) {
							if (promise) {
								delete promise.xEngEmbeddedRequest;
							}
							request = null;
							resolve(response);
						}
						var wrappedReject = function (error, response) {
							var result = {
								error: error,
								response: response
							}
							if (promise) {
								delete promise.xEngEmbeddedRequest;
							}
							request = null;
							reject(result);
						}

						fetchOpts.onComplete = wrappedResolve;
						fetchOpts.onFailure = wrappedReject;
						fetchOpts.onCancel = wrappedReject;
						fetchOpts.onTimeout = wrappedReject;
						request = WAFData.authenticatedRequest(url, fetchOpts);
					});

					promise.xEngEmbeddedRequest = {
						cancel: function (params) {
							request && request.cancel();
							if (request && request.xhr && request.xhr.timeoutTimer)
								clearTimeout(request.xhr.timeoutTimer);
						}
					}




					return promise;
			}
	};

	return XENGenericHttpClient;
});

define('DS/ENOXEngineerCommonUtils/XENCommandsAppContextProxy', [
  'DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings',
  'DS/ENOXEngineerCommonUtils/XENGenericHttpClient',
  'DS/ENOXEngineerCommonUtils/PromiseUtils'
], function(XENPlatform3DXSettings, XENGenericHttpClient, PromiseUtils) {

    'use strict';

    var XENCommandsAppContextProxy = {
      getAppContextPromise: function(cmdInst){
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
          if(!cmdInst) return reject(null);

          if (cmdInst.options && cmdInst.options.context) { //XEN & lifecycle context
                return resolve(cmdInst.options.context);
          }

          if(!cmdInst.options){
            cmdInst.options = {};
          }

          //Case of PAD apps
          require([
            'DS/PADUtils/PADContext'
          ], function(PADContext){

            cmdInst.options.context = PADContext.get();
            resolve(cmdInst.options.context);
          }, function(error){
            reject(error);
          });
        });
      },
      loadCommandsSetting: function(){
        if(this.commandsSettingsPromise)
          return this.commandsSettingsPromise;
        var that = this;
        that.commandsSettingsPromise =  PromiseUtils.wrappedWithPromise(function(resolve, reject){
          XENPlatform3DXSettings.bindCommandsToABackend(true/*sync*/).then(function(){
            var cmd =  XENPlatform3DXSettings.getCommand('get_command_settings');
             XENGenericHttpClient.perform(cmd).then(function(res) {
               if(typeof res === 'string')
                  res = JSON.parse(res);
                return resolve(res);
            }).catch(function(errors) {
                reject(errors);
            });
        });
        });
        
        return that.commandsSettingsPromise ;
        
      }
    };

    return XENCommandsAppContextProxy;

});


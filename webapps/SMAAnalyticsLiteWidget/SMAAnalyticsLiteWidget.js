define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteComboBox',
    ['DS/Controls/ComboBox'],
    function(WUXComboBox) {
	var ComboBox;
	ComboBox = WUXComboBox.inherit({
		name: 'racombobox',
		buildView: function(){
			this._parent();
		},
		_hidePopup : function(){
			this._parent();
                // check to see if the inputBox value has changed and update
                // accordingly :)
			//console.log('update with: '+this.myInput.value);
		},
		_applyPreselectedIndex : function(force){
                // sometimes this function is called with the first argument
                // being true (force) this prevents that
			this._parent(force);
		},
		_applyProperties: function (oldValues) {
			this._parent(oldValues);
                var redoView =
                    this.isDirty('enableSearchFlag') ||
                    this.isDirty('actionOnClickFlag') ||
                    this.isDirty('mainElementVisibleFlag');
			if (redoView) {
				this.addEventListener('keyup', function (evt){
					if(evt.key === 'Enter'){
						console.log('Submit!');
					}
				});
			}
		}
	});
	return ComboBox;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsListModel',
    ['UWA/Core', 'UWA/Class/Model'],
    function(UWA, Model) {
        'use strict';
        var SMAAnalyticsListModel = Model.extend({
            caseDescriptionType: 0, // 0 - summary, 1 - last comment
            title: 'Results Analytics Cases',
            defaults: function() {
                return {
                    id: '',
                    physicalId: '',
                    name: '',
                    title: '',
                    subtitle: '',
                    description: '',
                    author: '',
                    owner: '',
                    date: '',
                    content: '',
                    image: '',
                    lastComment: '',
                    lastCommentAuthor: '',
                    enoviaURL: '',
                    reqList: [],
                    type: ''
                };
            },

            setCaseDescriptionType: function(caseDescriptionType) {
                this.set('caseDescriptionType', caseDescriptionType);
            }
        });
        return SMAAnalyticsListModel;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsCustomView',
    [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/W3DXComponents/Views/Layout/GridScrollView',
        'DS/W3DXComponents/Views/Layout/TableScrollView',
        'DS/W3DXComponents/Views/Layout/ListView',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils'
    ],
    function(
        UWA,
        Promise,
        GridScrollView,
        TableScrollView,
        ListView,
        AnalyticsUtils
    ) {
        'use strict';

        var _ADD_TO_COLLECTION_EVENT_ = 'onAddToCollectionEvent';

        var _onRender = function() {
            if (!this.hasEvent(_ADD_TO_COLLECTION_EVENT_)) {
                this.addEvent(
                		_ADD_TO_COLLECTION_EVENT_,
                    function(event) {
                        if (UWA.is(event) && UWA.is(event.detail)) {
                        	AnalyticsUtils.createNewCase(this, event.detail);
                        }
                    }.bind(this)
                );
            }
            
            // Runs the attached function when the case list collection 
            // has been sync'd.
            if (! this.collection.hasEvent('onSync')){
				this.listenTo(this.collection, { onSync: function(){
					AnalyticsUtils.collectionPostProcessing(this);
				}.bind(this) });
			}

            this._parent.apply(this, arguments);
        };
        
        var _onItemViewSelect = function(skeleton, view){
        	widget.setValue('lastactivecase',view.model.get('id'));
        };

        var CustomView = {
            AnalyticsGridScrollView: GridScrollView.extend({
                onRender: _onRender,
                onItemViewSelect: _onItemViewSelect
            }),

            AnalyticsTableScrollView: TableScrollView.extend({
                onRender: _onRender,
                onItemViewSelect: _onItemViewSelect
            }),
            AnalyticsListView: ListView.extend({
                onRender: _onRender,
                onItemViewSelect: _onItemViewSelect
            })
        };

        return CustomView;
    }
);

define('DS/SMAAnalyticsLiteWidget/pages/mapping-table/SMAAnalyticsLiteMappingTableModel', [
	'UWA/Core',
	'DS/Tree/TreeDocument',
    'DS/Tree/TreeNodeModel',
    'DS/SMAAnalyticsCommon/SMAAnalyticsCase',
    'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ], function(Core,
		TreeDocument,
		TreeNodeModel,
		AnalyticsCase,
		NLS){
	'use strict';
	var _self;
	var AnalyticsMappingTableModel = UWA.Class.extend({
		init:function(options){
			_self = this;
			_self.raeMergeUIDoc = new TreeDocument({
									useAsyncPreExpand: true});
			_self._getDataForModel(function(data){
				var root = new TreeNodeModel({
    				label: 'DataSets'
    			});
        		var productTree = _self._createModel(root,data.rowHierarchy,true);
        		var a = [];
        		var isFirst = true;
        		if(productTree && productTree.getChildren && productTree.getChildren() && productTree.getChildren().length > 0){
        			productTree.getChildren().forEach(function(p){
            			if(isFirst){
            				isFirst = false;
            				p.expandAll();
            			}
        				a.push(p);
            			
            		});
        		}
        		_self.raeMergeUIDoc.addChild(a);
        	});
		},
		_getDataForModel:function(callback){
			AnalyticsCase.getParameterMergeData().then(function(data){
				Logger.log(data);
			},function(error){
				Logger.log(error);
			});
		},
		_createModel:function(root,plmObject,rootCreated){
			 var childNode;
             if (!rootCreated && plmObject.length === undefined){
                 var childNode = new TreeNodeModel({
                     label: plmObject.name,
                     grid:{
                    	 type:(plmObject.type.toUpperCase() === "GROUP") ? "" : plmObject.type,
                         value:plmObject.value,
                         transformedValue:_self.getTransformedValue(plmObject),
                         id:plmObject.id,
                         name: (plmObject.title) ? plmObject.title : plmObject.name,
                         priority:plmObject.priority,
                         objective:plmObject.objective
                      }
                     
                 });
             }
             else{ 
            	 childNode = root; 
             }
             if (plmObject !== null && plmObject !== undefined){
                if (plmObject.length === undefined){
                    if (!rootCreated)
                        { root.addChild(childNode); }
                    this._createModel(childNode, plmObject.children, true);

                }
                else {
                    for (var i=0;i<plmObject.length;i++){
                    	if (!rootCreated){ 
                        	root.addChild(childNode); 
                        }
                        this._createModel(childNode, plmObject[i], false);
                    }
                }
             }
             else {
                 if (rootCreated === false){ 
                	 root.addChild(childNode); 
                }
             }
             return root;
		},
		getTransformedValue:function(data){
			var value= ""
			if(data && data.type && data.type.toUpperCase() !== "GROUP"){
				if(data.type === "REAL" || data.type==="INTEGER"){
					if(data.min && data.max){
						if(data.min !== data.max){
							value =  data.min  + "-" + data.max; 
						}else{
							value = data.min;
						}
					}
				}else if(data && data.type && data.type === 'STRING'){ 
					value = data.value;
				}
				
			}
			return value;
		},
		getRAEMergeUIModel:function(){
			return this.raeMergeUIDoc;
		}
	});
	return AnalyticsMappingTableModel;
});



//=========================================================================
/**
 *
 */
//=========================================================================
define(
    'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequests',
    ['UWA/Core', 'UWA/Utils', 'UWA/Class'],
    function(UWA, Utils, Class) {
        'use strict';

        var _self;
        //=========================================================================
        /**
         *
         */
        //=========================================================================
        var LiteRequests = Class.extend({
            PASSPORT_AS_PROXY: 'passport',
            init: function(args) {
                _self = this;
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "get" request
             * To cache the response, to the args add the attribute 'cache'.
             * cache : 0 => cache response forever
             * cache : -1 => never cache the response
             * cache : n => cache resposne for n seconds
             */
            //=========================================================================
            UWA_GET: function(args) {
                var _this = this;

                if (!args) {
                    return;
                }

                var url = args.url || '',
                    params = args.params || {},
                    headers = args.headers,
                    data = args.data,
                    contentType = args.type || 'json',
                    timeout = args.timeout,
                    noProxy = args.noProxy,
                    cache = args.cache || -1,
                    queryString = '?';

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'GET',
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (!noProxy) {
                        payload.proxy = _this.PASSPORT_AS_PROXY;
                    }
                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }
                    if (!isNaN(cache)) {
                        payload.cache = cache;
                    } else {
                        payload.cache = -1;
                    }

                    UWA.Data.request(url, payload);
                });
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "post" request
             */
            //=========================================================================
            UWA_POST: function(args) {
                var _this = this;

                if (!args) {
                    return;
                }

                var url = args.url || '',
                    params = args.params || {},
                    headers = args.headers,
                    data = args.data,
                    contentType = args.type || 'json',
                    timeout = args.timeout,
                    addSecCtx = args.addSecContext,
                    queryString = '';

                // All post requests need the Security Context to be provided.
                if (addSecCtx !== false) {
                    url += '?SecurityContext=' + _this.getActiveCollabSpace();
                }

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'POST',
                        proxy: _this.PASSPORT_AS_PROXY,
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }

                    UWA.Data.request(url, payload);
                });
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "put" request
             */
            //=========================================================================
            UWA_PUT: function(args) {
                var _this = this;

                if (!args) {
                    return;
                }

                var url = args.url || '',
                    params = args.params || {},
                    headers = args.headers,
                    data = args.data,
                    contentType = args.type || 'json',
                    timeout = args.timeout,
                    queryString = '';

                // All put requests need the Security Context to be provided.
                url += '?SecurityContext=' + _this.getActiveCollabSpace();

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'PUT',
                        proxy: _this.PASSPORT_AS_PROXY,
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }

                    UWA.Data.request(url, payload);
                });
            }
        });

        return LiteRequests;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteCaseModel',
    ['UWA/Core', 'UWA/Class/Model'],
    function(UWA, Model) {
        'use strict';
        var SMAAnalyticsListModel = Model.extend({
            caseDescriptionType: 0, // 0 - summary, 1 - last comment
            title: 'Results Analytics Cases',
            defaults: function() {
                return {
                    id: '',
                    physicalId: '',
                    name: '',
                    title: '',
                    subtitle: '',
                    description: '',
                    author: '',
                    owner: '',
                    date: '',
                    content: '',
                    image: '',
                    lastComment: '',
                    lastCommentAuthor: '',
                    enoviaURL: '',
                    reqList: [],
                    type: ''
                };
            },

            setCaseDescriptionType: function(caseDescriptionType) {
                this.set('caseDescriptionType', caseDescriptionType);
            }
        });
        return SMAAnalyticsListModel;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLoad',[
        'UWA/Core',
        'UWA/Utils',
        'UWA/Class/Promise',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ],
    function(Core, Utils, Promise, NLS) {
        'use strict';

        //var _APP_NAME_RAE_ = 'Results_Analytics_Essentials';
        //FIXME: until PS licenses are available on the
        //FIXME: cloud, stick with the RA license checks for RAE too
        var _APP_NAME_RAE_ = 'Results_Analytics';

        var _3DSPACE_SERVICE_NAME_ = '3DSpace';
        var _RA_PLATFORM_PREF_ = 'platform';
        var _WIDGET_PLATFORM_PREF_ = 'x3dPlatformId';
        var _COLLAB_SPACE_PREF_ = 'collabspaces';
        var _SECURITY_CONTEXT_PREF = ['collabspaces', 'collabspace'];

        var spaceUrl = '';

        var spServiceUrl = UWA.createElement('sp-serviceurl');
		var spDashboard = UWA.createElement('sp-dashboard');
        var spMcsService;

        window.widget.body.appendChild(spServiceUrl);
        window.widget.body.appendChild(spDashboard);

        var loadSPMcs = function() {
            if (!spMcsService) {
                spMcsService = document.createElement('sp-mcsservice');
            }
            window.widget.body.appendChild(spMcsService);
        };

        var loadCollabSpace = function(serverUrl) {
            var csErr = new Error(NLS.get('ERROR_PLATFORM_SC'));
            var getSecurityContext = function() {
                var context;
                if (window.widget && window.widget.getValue) {
                    _SECURITY_CONTEXT_PREF.some(function(pref) {
                        context = window.widget.getValue(pref);
                        return context;
                    });
                }
                return context;
            };
            var securityContext = getSecurityContext();
            var collabSpaces = {
                name: _COLLAB_SPACE_PREF_,
                type: 'list',
                label: NLS.get('collab_space'),
                options: [
                    {
                        value: securityContext,
                        name: securityContext
                    }
                ],
                defaultValue: securityContext
            };
            window.widget.addPreference(collabSpaces);

            return new Promise(
                function(resolve, reject) {
                    require(['DS/WAFData/WAFData'], function(WAFData) {
                        var t =
                            window.widget.getValue(_RA_PLATFORM_PREF_) ||
                            window.widget.getValue(_WIDGET_PLATFORM_PREF_);
                        WAFData.authenticatedRequest(
                            spaceUrl + '/resources/bps/cspaces?tenant=' + t,
                            {
                                type: 'json',
                                onComplete: function(data) {
                                    var cspaces = Array.isArray(data.cspaces)
                                            ? data.cspaces
                                            : [
                                                  {
                                                      name: null,
                                                      displayName:
                                                          NLS.get('NO_CS')
                                                  }
                                              ],
                                        preferredSecurityContext,
                                        cspaceExists = false;

                                    collabSpaces.options = cspaces.map(function(
                                        cspace
                                    ) {
                                        cspaceExists =
                                            cspaceExists ||
                                            cspace.name === securityContext;
                                        return {
                                            value: cspace.name,
                                            label: cspace.displayName
                                        };
                                    });

                                    if (!cspaceExists && cspaces.length > 0) {
                                        preferredSecurityContext = cspaces.filter(
                                            function(cspace) {
                                                return cspace.isDefault;
                                            }
                                        );
                                        if (
                                            preferredSecurityContext &&
                                            preferredSecurityContext.length ===
                                                1
                                        ) {
                                            collabSpaces.defaultValue =
                                                preferredSecurityContext[0].name;
                                        } else {
                                            collabSpaces.defaultValue =
                                                cspaces[0].name;
                                        }
                                    }
                                    window.widget.addPreference(collabSpaces);
                                    loadSPMcs();
                                    resolve();
                                }.bind(this),
                                onFailure: function(err) {
                                    csErr.originalError = err;
                                    reject(csErr);
                                }.bind(this)
                            }
                        );
                    }.bind(this), function(err) {
                        var wafErr = new Error(NLS.get('ERROR_NO_WAF'));
                        wafErr.originalError(err);
                        csErr.originalError = wafErr;
                        reject(csErr);
                    });
                }.bind(this)
            );
        };

        /*var loadCollabSpace = function() {
            return new Promise(
                function(resolve, reject) {
                    spDashboard
                        .addSecurityContextPreference()
                        .then(resolve.bind(this), reject);
                }.bind(this)
            );
        };*/

        var createPlatformPreference = function(
            platformList,
            onComplete,
            onError
        ) {
            if (Array.isArray(platformList) && platformList.length > 0) {
                var platformPrefList = platformList.map(function(p) {
                    return {
                        label: p.displayName,
                        value: p.platformId
                    };
                }, this);
                var platformPref = {
                    name: _RA_PLATFORM_PREF_,
                    label: NLS.get('3DEX_PLATFORM'),
                    onchange: 'preferencesChanged',
                    defaultValue: ''
                };
                if (platformPrefList.length < 2) {
                    // 0 or 1 tenant
                    platformPref.type = 'hidden';
                    platformPref.defaultValue = platformPrefList[0].value;
                } else {
                    platformPref.options = platformPrefList;
                    platformPref.type = 'list';
                }
                // Set default preference value if its already
                // available in the widget data
                var exPlatformId = widget.getValue(_WIDGET_PLATFORM_PREF_);
                var defSet = false;
                if (exPlatformId && exPlatformId.length > 0) {
                    for (var i = 0; i < platformList.length; i++) {
                        if (exPlatformId === platformList[i].platformId) {
                            platformPref.defaultValue =
                                platformList[i].platformId;
                            defSet = true;
                            break;
                        }
                    }
                }
                if (!defSet) {
                    platformPref.defaultValue = platformPrefList[0].value;
                }
                widget.addPreference(platformPref);
                if (widget.isEdit) {
                    widget.dispatchEvent('onEdit');
                }
                onComplete();
            } else {
                var noTenants = new Error(NLS.get('ERR_NO_TENANTS'));
                onError(noTenants);
            }
        };

        var checkLicenses = function() {
            return new Promise(
                function(resolve, reject) {
                    var licError = new Error(NLS.get('ERR_LIC'));

                    var licCheckUri =
                        '/resources/slmservices/license?appNames=' +
                        _APP_NAME_RAE_;
                    licCheckUri +=
                        '&SecurityContext=' + widget.getValue(_COLLAB_SPACE_PREF_);

                    var onComplete = function(httpRequest) {
                        var licenseInfo = JSON.parse(httpRequest.response);

                        if (
                            typeof licenseInfo[_APP_NAME_RAE_] !==
                                'undefined' &&
                            licenseInfo[_APP_NAME_RAE_].toLowerCase() === 'true'
                        ) {
                            var csrf = licenseInfo.csrf || {};
                            var options = {
                                serverurl: spaceUrl
                            };
                            if (
                                typeof csrf.name !== 'undefined' &&
                                (typeof csrf.value !== 'undefined' ||
                                typeof csrf.CSRFToken !== 'undefined')
                            ) {
                                options.csrf = {
                                    'name' : csrf.name,
                                    'value' : csrf.CSRFToken || csrf.value
                                };
                            }
                            resolve(options);
                        } else {
                            reject(licError);
                        }
                    };

                    var headers = { Accept: 'text/plain' },
                        options = {
                            uri: spaceUrl + licCheckUri,
                            verb: 'GET',
                            headers: headers,
                            onComplete: onComplete.bind(this),
                            onError: function(err) {
                                licError.originalError = err;
                                reject(licError);
                            }.bind(this)
                        };
                    spMcsService.sendRequest(options);
                }.bind(this)
            );
        };

        var loadPlatformTenants = function() {
            var tenantError = new Error(NLS.get('ERR_TENANT_REQ_FAIL'));
            return new Promise(
                function(resolve, reject) {
                    var options = {
                        onComplete: function(platformList) {
                            createPlatformPreference(
                                platformList,
                                resolve,
                                reject
                            );
                        }.bind(this),
                        onError: function(err) {
                            tenantError.originalError = err;
                            reject(tenantError);
                        }.bind(this)
                    };
                    spServiceUrl.
            			getPlatformList({
            				'onComplete': options.onComplete,
            				'onError': options.onError
            			});
                }.bind(this)
            );
        };

        var getSpaceUrl = function() {
            var urlError = new Error(NLS.get('ERR_SERVER_URL_FAIL'));
            return new Promise(
                function(resolve, reject) {
                    var options = {
                        serviceid: _3DSPACE_SERVICE_NAME_,
                        platformid: widget.getValue(_RA_PLATFORM_PREF_),
                        onComplete: function(sUrl) {
                            if (Utils.isValidUrl(sUrl) && sUrl.length > 0) {
                                spaceUrl = sUrl;
                                resolve(sUrl);
                            } else {
                                reject(urlError);
                            }
                        }.bind(this),
                        onError: function(e) {
                            urlError.originalError = e;
                            reject(urlError);
                        }.bind(this)
                    };
                    spServiceUrl.getUrl(options);
                }.bind(this)
            );
        };

        var refreshPlatform = function() {
            return new Promise(
                function(resolve, reject) {
                    var newTenant = widget.getValue(_RA_PLATFORM_PREF_);
                    if (Core.is(newTenant) && newTenant.length > 0) {
                        // Force to refresh collabspaces
                        _SECURITY_CONTEXT_PREF.some(function(pref) {
                            widget.deleteValue(pref);
                        }, this);
                    }

                    getSpaceUrl()
                        .then(loadCollabSpace.bind(this))
                        .then(checkLicenses.bind(this))
                        .then(initializeLiteWidget.bind(this))
                        .then(resolve, reject)
                        ['catch'](function(err) {
                            reject(err);
                        });
                }.bind(this)
            );
        };

        var loadPlatformData = function() {
            return new Promise(
                function(resolve, reject) {
                    if (Core.is(spServiceUrl)) {
                        loadPlatformTenants()
                            .then(getSpaceUrl.bind(this))
                            .then(loadCollabSpace.bind(this))
                            .then(checkLicenses.bind(this))
                            .then(initializeLiteWidget.bind(this))
                            .then(resolve, reject)
                            ['catch'](function(err) {
                                reject(err);
                            });
                    } else {
                        var spSUrlFail = new Error(
                            'failed to load sp-serviceurl'
                        );
                        reject(spSUrlFail);
                    }
                }.bind(this)
            );
        };

        var initializeLiteWidget = function(options) {
            return new Promise(
                function(resolve, reject) {
                    require([
                    	'UWA/String',
                        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
                        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteWidgetSkeleton',
                        'DS/W3DXComponents/Views/Temp/TempHandlebars',
                        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
                    ], function(
                		StringUtils,
                        WidgetProxy,
                        LiteWidgetSkeleton,
                        Handlebars,
                        NLS
                    ) {
                        // Create a handlebar helper function that translates
                        // text in the widget html templates
                        Handlebars.registerHelper('raTranslate', function(
                            word
                        ) {
                            return new Handlebars.SafeString(NLS.get(word));
                        });
                        
                        Handlebars.registerHelper('raSanitize', function(txt) {
                            if (Core.is(txt, 'string') && txt.length > 0) {
                                if (!isNaN(parseFloat(txt))) {
                                    return txt;
                                } else {
                                    if (StringUtils.escapeHTML(txt) === txt) {
                                        return txt;
                                    }
                                    return '';
                                }
                            } else if (Core.is(txt, 'number')) {
                                return txt;
                            }
                            return '';
                        });
                        
                        var csrfToken = '';
                        if (options.csrf && options.csrf.value) {
                            csrfToken = options.csrf.value;
                        }
                        WidgetProxy.initializeLiteWidget(
                            options.serverurl,
                            csrfToken
                        );

                        widget.addEvents({
                        	onResize: function(){
        						widget.setValue('lastviewsize',widget.getView().type);                    	
                            },
                            onRefresh: function() {
                                LiteWidgetSkeleton.onLoad(widget.body);
                            },
                            workerLoaded: function(args) {
                                LiteWidgetSkeleton.workerLoaded(args);
                            },
                            onRequirementsAttached: function() {
                                LiteWidgetSkeleton.onRequirementsAttached();
                            },
                            onRequirementsUpdate: function() {
                                LiteWidgetSkeleton.onRequirementsUpdate();
                            },
                            onParameterMerge: function() {
                                LiteWidgetSkeleton.onParameterMerge();
                            },
                            preferencesChanged: function(prefName, prefVal) {
                                if (prefName === 'significant_digits') {
                                    WidgetProxy.setSignificantDigits(prefVal);
                                } else if (prefName === _RA_PLATFORM_PREF_) {

                                    //widget.body.empty();

            			            var loadMsg = UWA.createElement('p', { 'id': 'loading-message' });
            			            loadMsg.textContent =  NLS.get('LOADING');
            			            loadMsg.inject(widget.body);

                                    refreshPlatform().then(
                                        LiteWidgetSkeleton.onLoad.bind(
                                            this,
                                            widget.body
                                        ), function(err) {
                                            console.error(err);
                                            loadMsg.textContent = NLS.get('ERROR_PLATFORM_LOAD');
                                        }.bind(this)
                                    );
                                }
                            }.bind(this),
                            onCheckWorker: function() {
                                LiteWidgetSkeleton.onCheckWorker();
                            }
                        });

                        LiteWidgetSkeleton.onLoad(widget.body);

                    });
                }.bind(this)
            );
        };

        var SMAAnalyticsLiteLoad = {
            loadLiteWidget: loadPlatformData,
            refreshTenant: refreshPlatform
        };

        return SMAAnalyticsLiteLoad;
    }
);

//XSS_CHECKED
define('DS/SMAAnalyticsLiteWidget/pages/mappng-table/SMAAnalyticsLiteMappingTableView',[
	'UWA/Core',
	'UWA/Element', 
	'DS/Core/Core', 
	'DS/Tree/TreeListView',
	'DS/Controls/ComboBox',
	'DS/SMAAnalyticsLiteWidget/pages/mapping-table/SMAAnalyticsLiteMappingTableModel',
	'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
	], function(Core,
			Element,
			WUX,
			TreeListView,
			ComboBox,
			MappingTableModel,
			NLS){
	'use strict';
	var _self, isNewIndex, newIndex;
	var AnalyticsMappongTableView = UWA.Class.extend({
		init : function(options){
			_self = this;
			_self.paramList = [];
			_self.paramList[0] = {
					labelItem: NLS.get('Remove_Mapping'),
					valueItem: 'REMOVE_',
					iconItem: 'minus'
			};
			_self.paramList[1] =   {
					labelItem: NLS.get('New_Parameter'),
					valueItem:'NEWPARAM_',
					iconItem: 'plus'
			};
			_self.paramsToMerge = [];
			_self.paramsToUnmerge= [];
			_self.previousSelectedVal = '';
			_self.previousSelectedLabel = '';
			_self.previousSelectedIndex = -1;
			_self.mtable = new MappingTableModel();
			_self.docModel = _self.mtable.getRAEMergeUIModel(); 
			_self.matchedNodesList = [];
			_self.mergeTableUI = new TreeListView(this.createTreeListView());
			_self.mergeTableUI.options.columns[0].text = NLS.get('Name');
			_self.mergeTableUI.options.columns[0].width = '38%';
			_self.mergeTableUI.options.columns[0].isSortable = true;
			if(options.model){
				_self.model = options.model;
			}
		},
		createTreeListView:function(){
			var that = this;
			return{
				height: 'auto',
				width: 'auto',
				enableDragAndDrop: false,
				isEditable: true,
				isSortable: true,
				infiniteScrolling: true,
				enableKeyboardNavigation: true,
				expanderStyle: 'triangle',
				resize: { 
					columns: true, 
					rows: false 
				},
				columns:[
					{
						text:'Type',
						dataIndex:'type',
						isEditable: false,
						isSortable: true,
						width: '14.5%'
					},
					{
						text: NLS.get('Values'),
						dataIndex: 'transformedValue',
						isEditable: false,
						isSortable: true,
						width: '14.5%'
					},
					{
						text: NLS.get('Parameters'),
						dataIndex: 'Parameters',
						isEditable: false,
						isSortable: true,
						width: '32%',
						onCellRequest: function(nodeInfos) {
							if (!nodeInfos.isHeader) {
								var nodeModel = nodeInfos.nodeModel;
								var manager = nodeInfos.manager;
								var selectedIndex = -1;
								var type = nodeInfos.nodeModel.options.grid.type;
								if((type && type.length > 0 && type !== 'GROUP'  && _self.paramList) || isNewIndex){
									var aParamOptions = _self.paramList;
									//Decide which one to select
									if(!isNewIndex){
										aParamOptions.some(function(parameter,index){
											// if this row is in paramsToMerge find the index in
											// the parameter

											if (
													parameter.objectId === nodeModel.options.grid.id ||
													(parameter.mergedFromVars &&
															parameter.mergedFromVars.indexOf(
																	nodeModel.options.grid.id
															) > -1)
											) {
												selectedIndex = index;
												return true;
											}
											return false;
										});
									}else{
										isNewIndex = false;
										selectedIndex = newIndex;
									}
									//Create Combobox and select the option
									var comboElem= new ComboBox({
										elementsList: aParamOptions,
										placeholder: 'Select Parameter to Map',
										selectedIndex: selectedIndex,
										enableSearchFlag: true,
										autocompleteFlag: true
									});
									var cellElement = comboElem.elements.container.getElementsByClassName(
											'wux-ui-state-undefined'
									);
									if (cellElement.length > 0) {
										cellElement[0].addClassName('wux-controls-lineeditor');
										cellElement[0].removeClassName('wux-ui-state-undefined');
									}
									comboElem.addEventListener('change', function(exportView, evt){
										evt.stopPropagation();
										evt.preventDefault();
										var dropDown = evt.dsModel;
										if(dropDown.selectedIndex === 1){
											console.log("Selected New Parameter");
											var newParamName = this.nodeModel.options.label;
											var paramId = 'NEWPARAM_' + (Object.keys(_self.paramsToMerge).length);
											var newElem = {labelItem:newParamName,valueItem:paramId,objectId:nodeModel.options.grid.id};
											//dropDown.elementsList.push(newElem);
											newIndex = UWA.clone(dropDown.elementsList.length);
											isNewIndex = true;
											var paramToMerge = {
					                                parameterName: newParamName,
					                                parameter: nodeModel.options.grid,
					                                id: UWA.clone(paramId)	
											};
											_self.paramsToMerge[nodeModel.options.grid.id] = paramToMerge;
											_self.updateParameterList();
											this.manager.updateRowView(this.virtualRowID);
										}else if(dropDown.selectedIndex === 0){
											console.log("Inside remove mapping:- mapping will be removed");
											var paramToUnMerge = {
													parameterName: _self.previousSelectedLabel,
					                                parameter: nodeModel.options.grid,
					                                id: _self.previousSelectedVal
											}
											var paramToUpdate = dropDown.elementsList[_self.previousSelectedIndex];
											var pId = nodeModel.options.grid.id;
											if(paramToUpdate && Array.isArray(paramToUpdate.mergedFromVars)){
												var i = paramToUpdate.mergedFromVars.indexOf(pId);
												if(i >= 0){
													// disconnects the variable from the parameter
													paramToUpdate.mergedFromVars.splice(i,1);
													// need to remove from rawData ....
												}
											}
											_self.paramsToUnmerge[nodeModel.options.grid.id] = paramToUnMerge;
											dropDown.selectedIndex = -1;
										}else if(dropDown.selectedIndex === -1){
											
										}else{
											//var paramId = 'NEWPARAM_' + (Object.keys(_self.paramsToMerge).length);
											if(_self.previousSelectedIndex > 1){
												//unmerge the previous selected parameter
												var paramToUnMerge = {
														parameterName: _self.previousSelectedLabel,
						                                parameter: nodeModel.options.grid,
						                                id: _self.previousSelectedVal
												}
												var paramToUpdate = dropDown.elementsList[_self.previousSelectedIndex];
												var pId = nodeModel.options.grid.id;
												if(paramToUpdate && Array.isArray(paramToUpdate.mergedFromVars)){
													var i = paramToUpdate.mergedFromVars.indexOf(pId);
													if(i >= 0){
														// disconnects the variable from the parameter
														paramToUpdate.mergedFromVars.splice(i,1);
														// need to remove from rawData ....
													}
												}
												_self.paramsToUnmerge[nodeModel.options.grid.id] = paramToUnMerge;
											}
											var paramToMerge = {
					                                parameterName: dropDown.currentLabel,
					                                parameter: nodeModel.options.grid,
					                                id: dropDown.currentValue	
											}; 
											var paramToUpdate = dropDown.elementsList
											_self.paramsToMerge[nodeModel.options.grid.id] = paramToMerge;
											_self.updateParameterList();
										}
									}.bind(nodeInfos, that));
									comboElem.addEventListener('preDropdown',function(exportView, evt){
										var dropDown = evt.dsModel;
										if(dropDown){
											_self.previousSelectedVal = dropDown.currentValue;
											_self.previousSelectedLabel = dropDown.currentLabel;
											_self.previousSelectedIndex = dropDown.selectedIndex;
										}
									}.bind(nodeInfos,that));
									comboElem.addEventListener('keyup',function(exportView, evt){
										if(evt.key === 'Enter'){
											evt.stopPropagation();
										}
									}.bind(nodeInfos, that));
									nodeInfos.cellView.getContent().setHTML(comboElem);
								}
							}
						}
					}
					],
					selection: {
						cells: false,
						rowHeaders: false,
						columnHeaders: false,
						canMultiSelect: false,
						useUnselectAllOnEmptyArea: true
					},	
					showLoaderIndicator: true,
					treeDocument: this.docModel
			};
		},
		/**
		 * Following function will take ParamList as input
		 * and convert it to WebUX friendly content. 
		 * 
		 */
		setParamList:function(parameterList){
			var paramList = [];
			paramList[0] = {
					labelItem: NLS.get('Remove_Mapping'),
					valueItem: 'REMOVE_',
					iconItem: 'minus'
			};
			paramList[1] =   {
					labelItem: NLS.get('New_Parameter'),
					valueItem:'NEWPARAM_',
					iconItem: 'plus'
			};
			parameterList.forEach(function(parameter,index){
				// we need to un-merge any parameters that are going to be
				// merged to a different parameter
				paramList.push({
					labelItem: decodeURIComponent(parameter.name),
					valueItem: parameter.id,
					objectId: parameter.id,
					mergedFromVars: parameter.mergedFromVars
				});
			},this);
			_self.paramList = paramList;
		},
		searchModel: function(value){
			var model = _self.docModel;
			_self.showAllNodes(model);
			if(value.length > 0){
				this.matchedNodesList = model.search({
			        match: function(nodeInfos) {
			            if (value && nodeInfos.nodeModel.options.label.toLowerCase().indexOf(value.toLowerCase()) !== -1) {
			                return true;
			            }
			        }
			    });
				_self.hideAllNodes(model);
				model.prepareUpdate();
				this.matchedNodesList.forEach(function(node, index){
					node.show();
					var nodeParents = node.getParents();
					nodeParents.forEach(function(parent,index){
						parent.show();
					});
					node.show();
			        //node.matchSearch();
			        node.reverseExpand();
			    });
				model.pushUpdate();
			}
		},
		showAllNodes:function(model){
			model.prepareUpdate();
			if(model && model.getAllDescendants && model.getAllDescendants() !== null){
				model.getAllDescendants().forEach(function(node,index){
					node.show();
				});
			}
			//model.expandNLevels(1);
			model.collapseAll();
			model.pushUpdate();
		},
		hideAllNodes:function(model){
			model.prepareUpdate();
			if(model && model.getAllDescendants && model.getAllDescendants() !== null){
				model.getAllDescendants().forEach(function(node,index){
					node.hide();
				});
			}
			model.pushUpdate();
		},
		updateParameterList:function(){
			Object.keys(_self.paramsToMerge).forEach(function(pId){
				var parameter = _self.paramsToMerge[pId],
					found = false;
				//Check is we alreadt added this parameter to unmergeList
				if(_self.paramsToUnmerge[pId]){
					delete _self.paramsToUnmerge[pId];
				}
				found = _self.paramList.some(function(param){
                        //                  if(param.labelItem ===
                        //                  parameter.parameterName){
					if(param.valueItem === parameter.id){
						param.mergedFromVars.push(pId);
						return true;
					}
				},this);
				if(!found){
					_self.paramList.push({
                            labelItem: parameter.parameterName,
                            valueItem: parameter.id,
                            mergedFromVars: [pId]
					});
				}
			},this);
		},
		getParamList:function(paramList){
			return _self.paramList;
		},
		getMergeUI: function(){
			return this.mergeTableUI;
		},
		getMergeCallback : function(){
            worker.evaluate(
                'mergeParameters',
                [
                    _self.paramsToMerge,
                    _self.paramsToUnmerge,
                    { caseName: _self.model.get('title') }
                ],
                function() {
			_self.paramsToMerge = {};
			_self.paramsToUnmerge = {};
			if(widget){
				widget.dispatchEvent('onParameterMerge');
			}
                }
            );
		}
	});
	return AnalyticsMappongTableView;
});



define(
    'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteStationOps',
    [
        'UWA/Core',
        'UWA/Utils',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/PlatformAPI/PlatformAPI',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequests',
        'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'
    ],
    function(
        UWA,
        Utils,
        Class,
        Promise,
        pAPI,
        SMAAnalyticsLiteRequests,
        i3DXCompassServices
    ) {
        'use strict';

        var _self;

        //=========================================================================
        /**
         * Helper class to connect to EED stations
         */
        //=========================================================================
        var LiteStationOps = Class.extend({
            _adviseLiteRequests: {},
            _mcsURL: '',
            _eedURL: '',
            _eedTicket: '',
            _eedRunAs: null,
            _eedRunAsCheckURI: '/admin/runAsEnabled',
            _stationQueryURI: '/admin/station/query',
            _cosServerID: '',
            _privateStationURI: '',
            _currentUserLogin: '',
            _stationInfo: {
                name: '',
                ip: '',
                cosID: '',
                user: '',
                isPrivate: '',
                displayName: ''
            },
            _localHostOnly: '{localhost}',
            _usersAffinity: '',
            _runAs: false,

            //=========================================================================
            /**
             * Create LiteStationOps
             */
            //=========================================================================
            init: function(args) {
                _self = this;

                _self._adviseLiteRequests = new SMAAnalyticsLiteRequests({});
                _self._spCOS = UWA.createElement('sp-cos');
                _self.widget = widget;
                _self._mcsURL = args.mcsURL;
                _self._eedURL = args.eedURL;
                _self._eedTicket = args.eedTicket;
                _self._cosServerID = args.cosServerID
                    ? args.cosServerID
                    : _self._spCOS.getDefaultServerId();
                _self._currentUserLogin = pAPI.getUser().login;
            },

            //=========================================================================
            /**
             * Returns a promise true if the EED is Run As Enabled
             */
            //=========================================================================
            getEEDRunAsStatus: function() {
                var deferred = Promise.deferred();

                if (
                    typeof _self._eedRunAs !== 'undefined' &&
                    _self._eedRunAs !== null
                ) {
                    deferred.resolve();
                    return deferred.promise;
                }

                _self._adviseLiteRequests.
                    UWA_GET({
                        url: _self._eedURL + _self._eedRunAsCheckURI,
                        headers: { EEDTicket: _self._eedTicket },
                        noProxy: true,
                        type: 'text'
                    }).
                    then(
                        function(response) {
                            _self._eedRunAs = Boolean(
                                response === 'true' ||
                                    response === true ||
                                    response === '1' ||
                                    response === 1
                            );
                            deferred.resolve();
                        },
                        function() {
                            deferred.reject({
                                message:
                                    'Unable to retrieve the EED Run As Status.'
                            });
                        }
                    );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Get a list of all available EED stations
             */
            //=========================================================================
            getAllStations: function() {
                var deferred = Promise.deferred(),
                    stationList = [];

                _self._adviseLiteRequests.
                    UWA_GET({
                        url: _self._eedURL + _self._stationQueryURI,
                        headers: { Accept: 'application/json' },
                        noProxy: true,
                        data: {
                            ActiveOnly: true,
                            AllowedUser: _self._currentUserLogin
                        }
                    }).
                    then(
                        function(response) {
                            try {
                                if (typeof response === 'string') {
                                    response = JSON.parse(response);
                                }

                                stationList = response.StationList.Station;
                                if (!Array.isArray(stationList)) {
                                    stationList = [stationList];
                                }

                                deferred.resolve(stationList);
                            } catch (ex) {
                                deferred.reject({
                                    message:
                                        'Unable to retrieve the available EED Stations.'
                                });
                            }
                        },
                        function() {
                            deferred.reject({
                                message:
                                    'Unable to retrieve the available EED Stations.'
                            });
                        }
                    );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Filters stations returned by the station query webservice
             * response by their run as status.
             * @param : runAs - true returns run as stations and false returns
             * non run as stations
             */
            //=========================================================================
            filterStationsByRunAs: function(runAs) {
                var stations = [],
                    deferred = Promise.deferred();

                _self.getAllStations().then(
                    function(stationList) {
                        var i = stationList.length;
                        while (i--) {
                            var runAsValue = (stationList[i].GeneralInfo[
                                    '@disableRunAs'
                                ] || '').
                                    toUpperCase(),
                                isRunAsStation = false;

                            if (runAsValue.length === 0) {
                                isRunAsStation = true;
                            } else if (
                                runAsValue === 'DEFAULT' ||
                                runAsValue === 'ENABLED'
                            ) {
                                isRunAsStation = true;
                            } else if (
                                runAsValue === 'DISABLED' ||
                                runAsValue === 'UNSECURED'
                            ) {
                                isRunAsStation = false;
                            }

                            if (runAs && isRunAsStation) {
                                stations.push(stationList[i]);
                            } else if (!runAs && !isRunAsStation) {
                                stations.push(stationList[i]);
                            }

                            stationList.splice(i, 1);
                        }

                        if (stations.length > 0) {
                            deferred.resolve(stations);
                        } else {
                            deferred.reject({
                                message:
                                    'Unable to retrieve the available EED Stations.'
                            });
                        }
                    },
                    function() {
                        deferred.reject({
                            message:
                                'Unable to retrieve the available EED Stations.'
                        });
                    }
                );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Get Run As Stations available to the user.
             * If EED is run as enabled, returns the Run As stations. Else
             * returns nothing.
             */
            //=========================================================================
            getRunAsStations: function() {
                var deferred = Promise.deferred();

                _self.getEEDRunAsStatus().then(
                    function() {
                        if (_self._eedRunAs) {
                            _self.filterStationsByRunAs(true).then(
                                function(response) {
                                    deferred.resolve(response);
                                },
                                function() {
                                    deferred.reject();
                                }
                            );
                        }
                    },
                    function() {
                        deferred.reject({
                            message:
                                'Unable to retrieve the available EED Run As enabled Stations.'
                        });
                    }
                );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Get Non Run As Stations available to the user.
             * If EED is run as enabled, returns the non Run As stations. Else
             * returns all the stations that are available to the user.
             */
            //=========================================================================
            getNonRunAsStations: function() {
                var deferred = Promise.deferred();

                _self.getEEDRunAsStatus().then(
                    function(data) {
                        if (_self._eedRunAs) {
                            _self.filterStationsByRunAs(false).then(
                                function(response) {
                                    deferred.resolve(response);
                                },
                                function() {
                                    deferred.reject({
                                        message:
                                            'Unable to retrieve the available EED Stations.'
                                    });
                                }
                            );
                        } else {
                            _self.getAllStations().then(
                                function(response) {
                                    deferred.resolve(response);
                                },
                                function() {
                                    deferred.reject({
                                        message:
                                            'Unable to retrieve the available EED Stations.'
                                    });
                                }
                            );
                        }
                    },
                    function() {
                        deferred.reject({
                            message:
                                'Unable to retrieve the available EED Stations.'
                        });
                    }
                );

                return deferred.promise;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            checkPrivateStation: function() {
                return new Promise(function(resolve, reject) {
                    var i, privateStation;
                    try {
                        _self._spCOS.requestCosVersionForServer(
                            _self._cosServerID,
                            {
                                onComplete: function(cosVersion) {
                                    if (
                                        _self._spCOS.utils.isCosVersionSameOrNewer(
                                            cosVersion,
                                            418,
                                            3
                                        )
                                    ) {
                                        _self._spCOS.getPrivateStationInfo({
                                            onComplete: function(
                                                privateStations
                                            ) {
                                                for (
                                                    i = 0;
                                                    i < privateStations.length;
                                                    i++
                                                ) {
                                                    if (
                                                        privateStations[i].info.
                                                            cosid ===
                                                            _self._cosServerID ||
                                                        privateStations[i].info.
                                                            cosid ===
                                                            _self._spCos.getDefaultServerId()
                                                    ) {
                                                        privateStation =
                                                            privateStations[i];
                                                        break;
                                                    }
                                                }

                                                if (privateStation) {
                                                    _self._privateStationURI =
                                                        privateStation.uri;
                                                    if (
                                                        privateStation.info.
                                                            user ===
                                                        _self._currentUserLogin
                                                    ) {
                                                        _self._stationInfo.name =
                                                            privateStation.info.name;
                                                        _self._stationInfo.ip =
                                                            privateStation.info.ip;
                                                        _self._stationInfo.cosID =
                                                            privateStation.info.cosid;
                                                        _self._stationInfo.user =
                                                            privateStation.info.user;
                                                        _self._stationInfo.isPrivate = true;
                                                        resolve();
                                                    } else {
                                                        reject({
                                                            message:
                                                                'Error accessing the private local station.'
                                                        });
                                                    }
                                                }
                                            }
                                        });
                                    }
                                },
                                onFailure: function() {
                                    reject({
                                        message:
                                            'Error accessing the private local station.'
                                    });
                                }
                            }
                        );
                    } catch (ex) {
                        reject({
                            message:
                                'Error accessing the private local station.'
                        });
                    }
                });
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            listStations: function(runAs) {
                if (runAs == true) {
                    return _self.getRunAsStations();
                } else {
                    return _self.getNonRunAsStations();
                }
            },

            //=========================================================================
            /**
             * Get details of the user selected station.
             * TODO: set prefernece to local station first
             */
            //=========================================================================
            checkLocalStations: function() {
                return new Promise(function(resolve, reject) {
                    listStations.then(function(stations) {
                        if (_self._usersAffinity.length > 0) {
                            var selectedStation = stations.filter(function(
                                station
                            ) {
                                return station['@name'] == _self._usersAffinity;
                            });

                            if (
                                typeof selectedStation === 'undefined' ||
                                selectedStation == null
                            ) {
                                reject({
                                    message:
                                        'Unable to connect to the user selected station'
                                });
                            } else {
                                _self._stationInfo.name =
                                    selectedStation['@name'];
                                _self._stationInfo.ip =
                                    selectedStation['@hostIP'];
                                _self._stationInfo.isPrivate = false;
                                resolve();
                            }
                        } else {
                            resolve();
                        }
                    });
                });
            },

            //=========================================================================
            /**
             * Selects a station for execution and returns the details of that
             * station.
             */
            //=========================================================================
            selectStationForExecution: function(stationName, runAs) {
                return new Promise(function(resolve, reject) {
                    if (stationName === _self._localHostOnly && runAs) {
                        reject({
                            message:
                                'Run As is not supported in private stations.'
                        });
                    }

                    if (stationName === _self._localHostOnly) {
                        _self.checkPrivateStation().then(resolve);
                    } else if (
                        typeof stationName !== 'undefined' &&
                        stationName !== null &&
                        stationName.length > 0
                    ) {
                        _self._usersAffinity = stationName;
                        _self._runAs = runAs;

                        _self.checkLocalStations.then(resolve, reject);
                    } else {
                        _self.
                            checkPrivateStation().
                            then(
                                _self.checkLocalStations().then(resolve, reject)
                            );
                    }
                });
            }
        });

        return LiteStationOps;
    }
);

/*
 * TODO: this is a copy of SMAAnalyticsWidget/SMAAnalyticsWidgetProxy
 * Move this to a common place and use the same in both places
 *
 */

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
    [
        'UWA/Core',
        'UWA/Utils',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/PlatformAPI/PlatformAPI',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteStationOps',
        'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/WAFData/WAFData',
        'DS/ZipJS/zip-fs',
        'DS/Notifications/NotificationsManagerUXMessages',
        'DS/Notifications/NotificationsManagerViewOnScreen',
        'DS/UIKIT/Mask'
    ],
    function(
        UWA,
        Utils,
        Class,
        Promise,
        pAPI,
        LiteStationOps,
        i3DXCompassServices,
        NLS,
        WAFData,
        ZipJS,
        WUXNotifications,
        WUXScreenNotifications,
        Mask
    ) {
        'use strict';

        var widgetProxy = Class.extend({
            StationOps: null,
            serverURL: '', //3DSpace URL
            activeCollabSpace: '',
            CASE_ID: '',
            ADVISE_SERVICE_LOC: '/resources/slmservices/advise/',
            SIMULATION_SERVICE_LOC: '/resources/slmservices/simulations/',
            BPS_SERVICE_LOC: '/resources/bps/',
            FCS_CHECKOUT_LOC: '/servlet/fcs/checkout',
            FCS_COMMIT_LOC: '/resources/slmservices/fcs/commit',
            FCS_TICKET_LOC: '/resources/slmservices/fcs/ticket',
            E6W_SERVICE_LOC: '/resources/e6w/service',
            PASSPORT_AS_PROXY: 'passport',
            ENO_CSRF_TOKEN_LOC: '/resources/slmservices/token/CSRF',
            LIFECYCLE_SERVICE_LOC: '/resources/lifecycle/',
            ENO_CSRF_TOKEN: '',
            EED_URL: '',
            EED_TICKET: '',
            EED_RUN_AS: false, // set this to true if EED has 'run as' enabled
            RA_RUN_AS: false, // set this to true if the user selects 'run as' in RA
            fileDataIndex: {}, // this is a flat object with the file url as
            // key and the file as blob as value.
            datasets: [],
            showMergeUIForKWE: false,
            soTypesList: ['VPMReference', 'Simulation', 'DesignSight'], // Add any Simulation Object types to this list.

            notifs: null,

            //=========================================================================
            /**
             * To be used by the ODTs to override ajax calls with false
             * responses
             */
            //=========================================================================
            overrideProxyMethod: function(method, fn) {
                this[method] = fn;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            htmlUnescape: function(value) {
                return String(value)
                    .replace(/&quot;/g, '"')
                    .replace(/&#39;/g, "'")
                    .replace(/&lt;/g, '<')
                    .replace(/&gt;/g, '>')
                    .replace(/&amp;/g, '&');
            },

            //=========================================================================
            /**
             * Utility function to check if something is empty
             */
            //=========================================================================
            isNotEmpty: function(obj, isString) {
                if (typeof obj !== 'undefined' && obj !== null) {
                    if (isString) {
                        return obj.length > 0;
                    }
                    return true;
                } else {
                    return false;
                }
            },

            //=========================================================================
            /**
             * FIXME : until widgetProxy is reinstantiated on every item click,
             * use this function to refresh any global objects on every case
             * load.
             */
            //=========================================================================
            flush: function() {
                this.CASE_ID = '';
                this.setKWEMergeUIFlag(false);
                this.fileDataIndex = {};
                this.datasets = [];
                this._reqData = [];
                widget.kweFileIndex = undefined;
                widget.raeFileIndex = undefined;
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "get" request
             * To cache the response, to the requestData add the attribute
             * 'cache'. cache : 0 => cache response forever cache : -1 => never
             * cache the response cache : n => cache resposne for n seconds
             */
            //=========================================================================
            uwaDataRequest_GET: function(requestData, noAuth) {
                var _this = this;

                if (!requestData) {
                    return;
                }

                var url = requestData.url || '',
                    params = requestData.params || {},
                    headers = requestData.headers,
                    data = requestData.data,
                    contentType = requestData.type || 'json',
                    timeout = requestData.timeout,
                    noProxy = requestData.noProxy,
                    cache = requestData.cache || -1,
                    queryString = '?';

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'GET',
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (!noProxy) {
                        payload.proxy = _this.PASSPORT_AS_PROXY;
                    }
                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }
                    if (!isNaN(cache)) {
                        payload.cache = cache;
                    } else {
                        payload.cache = -1;
                    }

                    if (noAuth) {
                        UWA.Data.request(url, payload);
                    } else {
                        WAFData.authenticatedRequest(url, payload);
                    }
                });
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "post" request
             */
            //=========================================================================
            uwaDataRequest_POST: function(requestData) {
                var _this = this;

                if (!requestData) {
                    return;
                }

                var url = requestData.url || '',
                    params = requestData.params || {},
                    headers = {
                        ENO_CSRF_TOKEN: _this.ENO_CSRF_TOKEN
                    }, // requestData['headers'],
                    data = requestData.data,
                    contentType = requestData.type || 'json',
                    timeout = requestData.timeout,
                    addSecCtx = requestData.addSecContext,
                    queryString = '';

                // All post requests need the Security Context to be provided.
                if (addSecCtx !== false) {
                    url += '?SecurityContext=' + _this.getActiveCollabSpace();
                }

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'POST',
                        proxy: _this.PASSPORT_AS_PROXY,
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (contentType === 'json') {
                        payload.data = JSON.stringify(payload.data);
                        headers['Content-type']='json';
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }

                    WAFData.authenticatedRequest(url, payload);
                    //				WAFData.proxifiedRequest(url,payload);
                    //				UWA.Data.request(url, payload);
                });
            },

            //=========================================================================
            /**
             * Returns a promise for UWA data "put" request
             */
            //=========================================================================
            uwaDataRequest_PUT: function(requestData) {
                var _this = this;

                if (!requestData) {
                    return;
                }

                var url = requestData.url || '',
                    params = requestData.params || {},
                    headers = {
                        ENO_CSRF_TOKEN: _this.ENO_CSRF_TOKEN
                    }, // requestData['headers'],
                    data = requestData.data,
                    contentType = requestData.type || 'json',
                    timeout = requestData.timeout,
                    queryString = '';

                // All put requests need the Security Context to be provided.
                url += '?SecurityContext=' + _this.getActiveCollabSpace();

                for (var key in params) {
                    if (params.hasOwnProperty(key)) {
                        queryString += key + '=' + params[key] + '&';
                    }
                }

                if (queryString.length > 1) {
                    url += queryString.substring(0, queryString.length - 1);
                }

                return new Promise(function(resolve, reject) {
                    var payload = {
                        type: contentType,
                        method: 'PUT',
                        proxy: _this.PASSPORT_AS_PROXY,
                        allowCrossOriginRequest: true,
                        onComplete: resolve,
                        onFailure: reject
                    };

                    if (headers) {
                        payload.headers = headers;
                    }
                    if (data) {
                        payload.data = data;
                    }
                    if (timeout) {
                        payload.timeout = timeout;
                    }

                    WAFData.authenticatedRequest(url, payload);
                    //				UWA.Data.request(url, payload);
                });
            },

            //=========================================================================
            /**
             * Get/Set the 3DSpace Url to a class level variable
             */
            //=========================================================================
            set3DSpaceURL: function(url) {
                if (this.isNotEmpty(url, true)) {
                    this.serverURL = url;
                }
            },
            get3DSpaceURL: function() {
                return this.serverURL;
            },
            getEEDURL: function() {
                return this.EED_URL;
            },

            //=========================================================================
            /**
             */
            //=========================================================================
            setKWEMergeUIFlag: function(value) {
                this.showMergeUIForKWE = value || false;
            },

            //=========================================================================
            /**
             */
            //=========================================================================
            getKWEMergeUIFlag: function() {
                console.log('showMergeUIForKWE: ' + this.showMergeUIForKWE);
                return this.showMergeUIForKWE;
            },

            //=========================================================================
            /**
             * Get the widget's Collab Space / Sec Context
             */
            //=========================================================================
            getMyCollabSpace: function() {
                //          this['activeCollabSpace'] =
                //          widget.getPreference('collabspaces').value;
                return widget.getValue('collabspaces'); //this['activeCollabSpace'];
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            setActiveCollabSpace: function(activeCollabSpace) {
                if (activeCollabSpace) {
                    var collabspaceOptions = widget.getPreference(
                        'collabspaces'
                    ).options;
                    collabspaceOptions.some(function(option) {
                        var parts = option.value.split('.');
                        if (parts[parts.length - 1] === activeCollabSpace) {
                            activeCollabSpace = option.value;
                            return true;
                        }
                    });
                    this.activeCollabSpace = activeCollabSpace;
                } else {
                    this.activeCollabSpace = widget.getValue('collabspaces');
                }
                //return this['activeCollabSpace'];
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getActiveCollabSpace: function() {
            	this.activeCollabSpace = widget.getValue('collabspaces');
                return this.activeCollabSpace;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getEEDTicket: function(caseId) {
                var _this = this;
                if (!_this.isNotEmpty(caseId, true)) {
                    return null;
                }

                return _this.uwaDataRequest_GET({
                    url:
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getEEDTicketForAnalyticsCase',
                    params: { caseid: caseId },
                    cache: 2000,
                    type: 'text'
                });
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            setEEDTicket: function(ticket) {
                this.EED_TICKET = ticket;
            },

            //=========================================================================
            /**
             * Retrive the list of Analytics Cases
             */
            //=========================================================================
            getCaseList: function() {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'listAnalyticsCases';

                return _this.uwaDataRequest_GET({ url: url });
            },

            //=========================================================================
            /**
             * Get the case launch info
             */
            //=========================================================================
            getCaseLaunchInfo: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getAnalyticsLaunchInfo';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: {
                        caseID: caseId,
                        mcsURI: encodeURIComponent(_this.get3DSpaceURL())
                    }
                });
            },

            //=========================================================================
            /**
             * Remove the selected dataset(s) from a case.
             * selectedIds: Comma separated list of dataset ids
             */
            //=========================================================================
            removeDatasetsFromAnalyticsCase: function(caseId, selectedIds) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'removeFromAnalyticsCase';

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'text',
                    data: { caseid: caseId, objectids: selectedIds }
                });
            },

            //=========================================================================
            /**
             * Retrive the list of parameters for a given Requirement Object
             */
            //=========================================================================
            getParametersList: function(requirement) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getAllParametersForRequirement';

                requirement = requirement || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: { requirements: requirement }
                });
            },

            //=========================================================================
            /**
             * Retrive the list of Requirement Objects connected to a case
             */
            //=========================================================================
            getConnectedRequirementsList: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'listAnalyticsRequirements';

                caseId = caseId || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: { caseid: caseId }
                });
            },

            //=========================================================================
            /**
             * Retrive the list of Decision Objects connected to a case
             */
            //=========================================================================
            getConnectedDecisions: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getConnectedDecisions';

                caseId = caseId || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: { caseid: caseId }
                });
            },

            //=========================================================================
            /**
             * Retrive the list of Datasets connected to a case
             */
            //=========================================================================
            getConnectedDatasets: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'listDataSets';

                caseId = caseId || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: { caseid: caseId }
                });
            },

            //=========================================================================
            /**
             * Use the i3DXCompassServices to extract the 3DSpace Url
             */
            //=========================================================================
            get3DSpaceURLFromCompass: function() {
                var _this = this;

                return new Promise(function(resolve, reject) {
                    i3DXCompassServices.getServiceUrl({
                        serviceName: '3DSpace', // you can also limit result to
                        // one URL by providing the
                        // 'platformId' option
                        onComplete: resolve,
                        onFailure: reject
                    });
                });
            },

            //=========================================================================
            /**
             * Retrieve all available Security Contexts
             */
            //=========================================================================
            getAllSecurityContexts: function() {
                var _this = this,
                    url = _this.serverURL + _this.BPS_SERVICE_LOC + 'cspaces';

                return _this.uwaDataRequest_GET({ url: url });
            },

            //=========================================================================
            /**
             * Retrieve COS info
             */
            //=========================================================================
            getEEDInfo: function() {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getEEDInfo';

                return _this.uwaDataRequest_GET({ url: url });
            },

            //=========================================================================
            /**
             * Retrieve CSRF token,
             * use for non GET requests as the only header
             * {'ENO_CSRF_TOKEN': tokenValue}
             */
            //=========================================================================
            getCSRFToken: function() {
                var _this = this,
                    url = _this.serverURL + _this.ENO_CSRF_TOKEN_LOC;
                return new Promise(function(resolve, reject) {
                    _this.uwaDataRequest_GET({ url: url, type: 'string' }).then(
                        function(tokenString) {
                            _this.ENO_CSRF_TOKEN = tokenString;
                            resolve();
                        },
                        function(err) {
                            console.error('Error Getting CSRF Token', err);
                            resolve(); // reject();
                        }
                    );
                });
            },

            //=========================================================================
            /**
             * Retrieve COS 'Run As' Status
             */
            //=========================================================================
            getEEDRunAsStatus: function() {
                var _this = this,
                    requestData = {
                        url: _this.EED_URL + '/admin/runAsEnabled',
                        noProxy: true,
                        headers: { EEDTicket: _this.EED_TICKET }
                    };

                return _this.uwaDataRequest_GET(requestData);
            },

            //=========================================================================
            /**
             * Create a widget preference for selecting the Security Context.
             * FIXME: make it more intelligent. Has to get the users preferenc
             * and set it as the default value. Also has to be in sync with the
             * sec context from other widgets.
             */
            //=========================================================================
            createSecurityContextPreference: function(data) {
                var secCtxObj = {
                    name: 'collabspaces',
                    type: 'list',
                    label: NLS.get('collab_space'),
                    options: [],
                    defaultValue: null
                };

                if (Array.isArray(data.cspaces)) {
                    data = data.cspaces;
                    for (var i = 0; i < data.length; i++) {
                        secCtxObj.options.push({
                            value: data[i].name,
                            label: data[i].displayName
                        });
                    }
                    secCtxObj.defaultValue = data[0].name;

                    widget.addPreference(secCtxObj);
                }
            },

            //=========================================================================
            /**
             * Utility function to check if a station is a 'Run As' eligible.
             * The station will not run in 'run as' mode unless the EED has 'run
             * as' enabled. By default, the 'run as' behavior of the station
             * follows the 'run as' configuration of the EED server to which the
             * station has been connected. The "fiper.station.runas" seting in
             * the SMAExeStation .properties file when set to 'disabled' forces
             * the station to run with 'run as' disabled even though the EED has
             * 'run as' enabled.
             *
             * The possible settings for "fiper.station.runas" is "enabled",
             * "disabled", "unsecured". (Case insensitive)
             * Null, empty, or "default" means use EED setting.
             */
            //=========================================================================
            isARunAsStation: function(stationInfo) {
                var runAsValue = (
                        stationInfo.GeneralInfo['@disableRunAs'] || ''
                    ).toUpperCase(),
                    isRunAsStation = false;

                if (runAsValue.length === 0) {
                    isRunAsStation = true;
                } else if (
                    runAsValue === 'DEFAULT' ||
                    runAsValue === 'ENABLED'
                ) {
                    isRunAsStation = true;
                } else if (
                    runAsValue === 'DISABLED' ||
                    runAsValue === 'UNSECURED'
                ) {
                    isRunAsStation = false;
                }

                return isRunAsStation;
            },

            //=========================================================================
            /**
             * Create a widget preference with the list of available Stations.
             */
            //=========================================================================
            createStationPreference_OLD: function(data) {
                var _this = this,
                    stationPrefList = [];

                if (typeof data === 'string') {
                    data = JSON.parse(data);
                }

                if (data && data.StationList) {
                    var stationList = data.StationList.Station;

                    stationPrefList.push({ value: '', label: '' });

                    if (!Array.isArray(stationList)) {
                        stationList = [stationList];
                    }

                    for (var i = 0; i < stationList.length; i++) {
                        var stationInfo = stationList[i];

                        if (
                            stationInfo &&
                            stationInfo['@name'] &&
                            stationInfo['@name'].length > 0 &&
                            stationInfo.GeneralInfo &&
                            stationInfo.GeneralInfo['@hostIP'] &&
                            stationInfo.GeneralInfo['@hostIP'].length > 3
                        ) {
                            // Display only 'run as' stations when RA is in run
                            // as mode. Also verify if EED is 'run as' enabled.
                            if (_this.RA_RUN_AS && _this.EED_RUN_AS) {
                                if (!_this.isARunAsStation(stationInfo)) {
                                    continue;
                                }
                            }
                            stationPrefList.push({
                                value: stationInfo['@name'],
                                label: stationInfo['@name']
                            });
                        }
                    }
                }

                widget.addPreference({
                    name: 'stations',
                    type: 'list',
                    label: NLS.get('stations'),
                    options: stationPrefList,
                    defaultValue: null
                });
            },

            //=========================================================================
            /**
             * Query the list of available Stations from COS.
             * Code to get the list of stations.
             * Gets only the stations that the user has access to. This includes
             * both private stations and public station.
             *
             * List of allowed parameters to the Query service
             *      @QueryParam("ActiveOnly") @DefaultValue("False") Boolean
             * onlyActive,
             * 		@QueryParam("OS") String OS, //Any, Windows or UNIX
             *      @QueryParam("OSName") String OSName, //Any, Linux or
             * Windows_7
             * 		@QueryParam("OSVersion") String OSVersion, //6.1
             * 		@QueryParam("AllowedUser") String allowedUser,
             * 		@QueryParam("ApplicationName") String applicationName,
             * 		@QueryParam("ApplicationVersion") String applicationVersion,
             * 		@QueryParam("DRMMode") String drmMode,
             *      @QueryParam("SubmittingHost") @DefaultValue("False") Boolean
             * localhost
             */
            //=========================================================================
            getActiveStationsList: function(data) {
                var _this = this,
                    eedUrl = data.eedUrl || '',
                    noProxy = data.noProxy || '',
                    requestData = {
                        url: eedUrl + '/admin/station/query',
                        headers: { Accept: 'application/json' },
                        data: {
                            ActiveOnly: true,
                            AllowedUser: pAPI.getUser().login
                        }
                    };

                if (noProxy.length > 0) {
                    requestData.noProxy = true;
                }

                return _this.uwaDataRequest_GET(requestData);
            },

            //=========================================================================
            /**
             * Set attribute value to the Analytics Case.
             * This is updated to take in multiple attribute value pairs and
             * carry them in request payload rather than in the url.
             */
            //=========================================================================
            setAttributesToCase: function(caseId, attribMap) {
                if (!attribMap) {
                    return null;
                }

                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'setCaseAttribute';

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'text',
                    data: {
                        oid: caseId,
                        attributes: JSON.stringify(attribMap)
                    }
                });
            },

            //=========================================================================
            /**
             * Create a new Empty Case object. Allows setting a title and
             * description
             */
            //=========================================================================
            createAnalyticsCaseObject: function(title, desc) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'createAnalyticsCaseObject',
                    data = {};

                if (_this.isNotEmpty(desc, true)) {
                    data.description = desc;
                }

                if (_this.isNotEmpty(title, true)) {
                    data.title = title;
                }

                // make sure we use the current default collab space
                this.setActiveCollabSpace(this.getMyCollabSpace());

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'text',
                    timeout: 60000,
                    data: data
                });
            },

            //=========================================================================
            /**
             * Download files as blob using FCS checkout and returns a promise
             * with the blob url. Requires a fcs ticket, file extension and the
             * fcs checkout url returned by the FCS ticket service.
             */
            //=========================================================================
            downloadFile: function(data) {
                var _this = this,
                    dldDeferred = Promise.deferred();

                if (
                    !_this.isNotEmpty(data.ticket, true) ||
                    (typeof data.fileExtension === 'undefined' &&
                        data.fileExtension === null)
                ) {
                    //! _this.isNotEmpty(data['fileExtension'],
                    //! true)){

                    dldDeferred.reject(
                        'Invalid / empty ticket for file download'
                    );
                } else {
                    var url = data.url,
                        downloadXHR = new XMLHttpRequest(),
                        payload =
                            '__fcs__jobTicket=' +
                            data.ticket +
                            '&__fcs__attachment=false';

                    if (!_this.isNotEmpty(url, true)) {
                        url = _this.FCS_CHECKOUT_LOC;
                    }

                    downloadXHR.onload = function(e) {
                        if (downloadXHR.readyState === 4) {
                            if (downloadXHR.status === 200) {
                                var blob = new Blob([this.response], {
                                        type:
                                            'application/' + data.fileExtension
                                    }),
                                    urlCreator = window.URL || window.webkitURL;

                                // returns the entire blob rather than the Blob
                                // URL
                                dldDeferred.resolve(blob);
                            } else {
                                dldDeferred.reject();
                            }
                        }
                    };

                    downloadXHR.open('POST', url, true);
                    downloadXHR.setRequestHeader('Cache-Control', 'no-cache');
                    downloadXHR.setRequestHeader(
                        'Content-type',
                        'application/x-www-form-urlencoded'
                    );
                    downloadXHR.responseType = 'arraybuffer';
                    downloadXHR.send(payload);
                }
                return dldDeferred.promise;
            },

            //=========================================================================
            /**
             * Get Analytics case info
             */
            //=========================================================================
            getCaseInfo: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL + _this.ADVISE_SERVICE_LOC + 'caseInfo';

                caseId = caseId || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: { oid: caseId },
                    type: 'xml'
                });
            },

            //=========================================================================
            /**
             * Get Result Tciket
             */
            //=========================================================================
            getResultTicket: function(oId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'simResultTicket',
                    ticketDeferred = Promise.deferred();

                _this
                    .uwaDataRequest_GET({
                        url: url,
                        params: { oid: oId },
                        type: 'text'
                    })
                    .then(
                        function(data) {
                            try {
                                var ticketResponse = {};
                                ticketResponse.ticket = data
                                    .split('<Ticket>')[1]
                                    .split('</Ticket>')[0];
                                ticketResponse.fcsUrl = data
                                    .split('<FcsUrl>')[1]
                                    .split('</FcsUrl>')[0];
                                ticketDeferred.resolve(ticketResponse);
                            } catch (e) {
                                // console.error('Error obtaining the FCS
                                // ticket', err);
                                ticketDeferred.reject({});
                            }
                        },
                        function(err) {
                            console.error(
                                'Error obtaining the FCS ticket',
                                err
                            );
                            ticketDeferred.reject({});
                        }
                    );

                return ticketDeferred.promise;
            },

            //=========================================================================
            /**
             * Get business object info
             * This can take a list of Object ids as input
             */
            //=========================================================================
            getBusinessObjectsInfo: function(oId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'objectInfo';

                oId = oId || '';

                return _this.uwaDataRequest_GET({
                    url: url,
                    params: {
                        objectIds: oId,
                        SecurityContext: _this.getActiveCollabSpace()
                    },
                    type: 'json'
                });
            },

            //=========================================================================
            /**
             * Create new plm document object. Returns the object id of the
             * case created
             */
            //=========================================================================
            createDocumentObject: function(title) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'createDocumentObjectForRA',
                    data = {};

                if (_this.isNotEmpty(title, true)) {
                    data = { title: title };
                }

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'text',
                    timeout: 60000,
                    data: data
                });
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getAttachedFilesForCase: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/listAttachedFilesForCase';

                return _this.uwaDataRequest_GET({ url: url, type: 'json' });
            },

            //=========================================================================
            /**
             * Connect business objects to Analytics Case as a dataset. Takes
             * one or more object ids
             */
            //=========================================================================
            connectDatasetsToCase: function(caseId, oIds) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'connectObjectsToAnalyticsCase',
                    data = {},
                    connectDeferred = Promise.deferred();

                if (!_this.isNotEmpty(caseId, true)) {
                    connectDeferred.reject('No analytics case was provided.');
                }
                if (!_this.isNotEmpty(oIds, true)) {
                    connectDeferred.reject('No business objects to connect.');
                }

                _this
                    .uwaDataRequest_POST({
                        url: url,
                        type: 'text',
                        data: { caseid: caseId, objectids: oIds, israe: true }
                    })
                    .then(
                        function(data) {
                            connectDeferred.resolve(data);
                        },
                        function(err) {
                            connectDeferred.reject(err);
                        }
                    );
                return connectDeferred.promise;
            },

            //=========================================================================
            /**
             * Perform a FCS commit.
             * The argument 'data' takes the response from the FCS checkin
             * service
             */
            //=========================================================================
            fcsCommit: function(data) {
                var _this = this;

                return _this.uwaDataRequest_PUT({
                    url: _this.serverURL + _this.FCS_COMMIT_LOC,
                    data: data,
                    type: 'text'
                });
            },

            //=========================================================================
            /**
             * Perform a FCS checkin.
             * Uses a XHR request rather than UWA.data.request
             */
            //=========================================================================
            fcsCheckin: function(fileData, fcsTicketData) {
                var _this = this,
                    formData = new FormData(),
                    attrs = {},
                    cInDeferred = Promise.deferred(),
                    formAttrs = UWA.extend(attrs, {
                        csrfTokenName: 'ENO_CSRF_TOKEN',
                        noOfFiles: 1,
                        parentId: fileData.oId,
                        objectId: fileData.oId,
                        __fcs__jobTicket: fcsTicketData.ticket,
                        fileName0: fileData.file.name,
                        //                              'bfile0' :
                        //                              fileData['file'],
                        //                              'file-name':
                        //                              fileData['file']['name'],
                        //'file_0' : fileData['file'],
                        'file-title': fileData.file.name,
                        'file-description': fileData.file.name,
                        format0: 'generic',
                        store: 'STORE'
                    });

                for (var key in formAttrs) {
                    if (formAttrs.hasOwnProperty(key)) {
                        formData.append(key, formAttrs[key]);
                    }
                }
                if (!(fileData.file instanceof File)) {
                    formData.append(
                        'bfile0',
                        fileData.file,
                        fileData.file.name
                    );
                } else {
                    formData.append('bfile0', fileData.file);
                }
                var request = new XMLHttpRequest();
                request.open('POST', fcsTicketData.fcsUrl);
                request.onreadystatechange = function() {
                    if (request.readyState === 4) {
                        if (request.status === 200) {
                            // that.fcsCommit(request.responseText, data,
                            // msEvt);
                            cInDeferred.resolve(request.responseText);
                        } else {
                            console.error('Error checking in the file to FCS.');
                            cInDeferred.reject(request.responseText);
                        }
                    }
                };
                request.send(formData);

                return cInDeferred.promise;
            },

            //=========================================================================
            /**
             * Get FCS ticket and Url.
             * Mandatory Parameters: action
             */
            //=========================================================================
            getFCSTicket: function(params) {
                var _this = this,
                    queryString = '?',
                    ticketDeferred = Promise.deferred();

                if (!_this.isNotEmpty(params)) {
                    ticketDeferred.reject('Missing input data for FCS ticket.');
                    return ticketDeferred.promise;
                }

                queryString +=
                    'SecurityContext=' + _this.getActiveCollabSpace();

                if (_this.isNotEmpty(params.action, true)) {
                    queryString += '&action=' + params.action;
                }
                if (_this.isNotEmpty(params.format, true)) {
                    queryString += '&fformat=' + params.format;
                }
                if (_this.isNotEmpty(params.store, true)) {
                    queryString += '&store=' + params.store;
                }
                if (_this.isNotEmpty(params.title, true)) {
                    queryString += '&fname=' + params.title;
                }
                if (_this.isNotEmpty(params.store, true)) {
                    queryString += '&store=' + params.store;
                }
                if (_this.isNotEmpty(params.oId, true)) {
                    queryString += '&oid=' + params.oId;
                }

                _this
                    .uwaDataRequest_GET({
                        url:
                            _this.serverURL +
                            _this.FCS_TICKET_LOC +
                            queryString,
                        type: 'text'
                    })
                    .then(
                        function(data) {
                            try {
                                var ticketResponse = {};
                                ticketResponse.ticket = data
                                    .split('<Ticket>')[1]
                                    .split('</Ticket>')[0];
                                ticketResponse.fcsUrl = data
                                    .split('<FcsUrl>')[1]
                                    .split('</FcsUrl>')[0];
                                ticketDeferred.resolve(ticketResponse);
                            } catch (e) {
                                // console.error('Error obtaining the FCS
                                // ticket', err);
                                ticketDeferred.reject({});
                            }
                        },
                        function(err) {
                            console.error(
                                'Error obtaining the FCS ticket',
                                err
                            );
                            ticketDeferred.reject({});
                        }
                    );
                return ticketDeferred.promise;
            },

            //=========================================================================
            /**
             * Upload a file to Enovia / 3DSpace and connect it to a PLM doc
             * object. Takes the file, object id of the file/doc and a title
             * string.
             *
             * file, oId, title, fileFormat, store
             */
            //=========================================================================
            uploadFileTo3DSpace: function(params) {
                var _this = this,
                    uploadDeferred = Promise.deferred();

                if (!_this.isNotEmpty(params)) {
                    uploadDeferred.reject(
                        'No files were identified for upload.'
                    );
                    return uploadDeferred.promise;
                }
                if (!_this.isNotEmpty(params.oId, true)) {
                    uploadDeferred.reject(
                        'No object id found to connect the file to.'
                    );
                    return uploadDeferred.promise;
                }

                var errCallback = function(err) {
                        console.error('File upload failed', err);
                        uploadDeferred.reject(err);
                    },
                    uploadCompleteCallback = function(data) {
                        console.log(
                            'File was committed successfully into the business object'
                        );
                        uploadDeferred.resolve(data);
                    };

                _this
                    .getFCSTicket({
                        action: 'checkin',
                        format: 'generic',
                        store: 'STORE',
                        title: params.title,
                        oId: params.oId
                    })
                    .then(function(ticketData) {
                        _this
                            .fcsCheckin(params, ticketData)
                            .then(function(checkinData) {
                                _this
                                    .fcsCommit(checkinData)
                                    .then(function(commitData) {
                                        /*uploadCompleteCallBack(commitData);*/
                                        uploadDeferred.resolve(commitData);
                                    }, errCallback);
                            }, errCallback);
                    }, errCallback);

                return uploadDeferred.promise;
            },

            //=========================================================================
            /**
             * Get the encrypted credentials from Enovia during launch.
             */
            //=========================================================================
            getEncryptedCredentials: function(url) {
                var _this = this;

                return _this.uwaDataRequest_GET({
                    url: url,
                    type: 'text',
                    timeout: 1000000000,
                    headers: {
                        Accept: 'text/plain; charset=utf-8',
                        'Content-Type': 'text/plain; charset=utf-8'
                    }
                });
            },

            //=========================================================================
            /**
             * Call to e6w service SMA_Contents
             */
            //=========================================================================
            getSMAContents: function(objId) {
                var _this = this,
                    queryParams =
                        '?SIMULATIONId=' +
                        objId +
                        '&containerId=' +
                        objId +
                        '&expandLevel=2';
                return _this.uwaDataRequest_GET({
                    url:
                        _this.serverURL +
                        _this.E6W_SERVICE_LOC +
                        'SMA_Content' +
                        queryParams,
                    type: 'json'
                });
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            monitorBulletinBoardForTopic: function(jobID, topic) {
                var _this = this;
                return _this.uwaDataRequest_GET(
                    {
                        url: _this.EED_URL + '/job/' + jobID + '/monitor',
                        data: { Topic: topic, TimeStamp: 0 },
                        headers: {
                            EEDTicket: _this.EED_TICKET,
                            Credentials: ''
                        },
                        type: 'xml'
                    },
                    true
                );
            },

            //=========================================================================
            /**
             * Checkout Essentials Case Data.
             * Returns a TicketWrapper object.
             */
            //=========================================================================
            checkoutEssentialsData: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/checkoutRAEData';

                return _this.uwaDataRequest_GET({ url: url, type: 'json' });
            },

            //=========================================================================
            /**
             * Checkout Essentials Case File Data.
             * Returns a TicketWrapper object.
             */
            //=========================================================================
            checkoutEssentialsFileData: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/checkoutRAEFileData';

                return _this.uwaDataRequest_GET({ url: url, type: 'json' });
            },

            //=========================================================================
            /**
             * Returns a TicketWrapper object for the supplied files.
             */
            //=========================================================================
            getDownloadTicketForFiles: function(
                caseId,
                fileNames,
                fileTypes,
                outputFileName
            ) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/getDownloadTicketForFiles';

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'json',
                    data: {
                        fileNames: fileNames,
                        fileTypes: fileTypes,
                        outputFileName: outputFileName || ''
                    }
                });
            },

            //=========================================================================
            /**
             * Returns a json with the physical id as key and plmv2id as the
             * value for all the simulation objects that are connected to the
             * case. If the object attached to the case is a variant container,
             * returns a flat list of objects connected as simulation category
             * internal data. Returns a TicketWrapper object.
             */
            //=========================================================================
            getSimObjectsForCase: function(caseId) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/getSimulationObjectsConnectedToCase';

                return _this.uwaDataRequest_GET({ url: url, type: 'json' });
            },

            //=========================================================================
            /**
             * Returns a promise with the model xml for PLM batch adapter and
             * the list of batch ids that need to be monitored in the bulletin
             * board
             */
            //=========================================================================
            createEXMLForPLMBatch: function(caseId, oIDs, containerOIDs) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        caseId +
                        '/createPLMBatchEXML';

                oIDs = Array.isArray(oIDs) ? oIDs : [oIDs];
                containerOIDs = Array.isArray(containerOIDs)
                    ? containerOIDs
                    : [containerOIDs];

                return _this.uwaDataRequest_POST({
                    url: url,
                    type: 'json',
                    data: {
                        station: widget.getValue('stations'),
                        mcsUrl: encodeURIComponent(_this.get3DSpaceURL()),
                        oIDs: oIDs.toString(),
                        containerIDs: containerOIDs.toString()
                    }
                });
            },

            //=========================================================================
            /**
             * Convert a blob into a url object
             */
            //=========================================================================
            convertBlobToURL: function(blob) {
                var _this = this,
                    urlObject =
                        typeof URL.createObjectURL === 'function'
                            ? URL
                            : window.top.URL;

                if (!_this.isNotEmpty(blob)) {
                    return '';
                }

                return urlObject.createObjectURL(blob);
            },

            //=========================================================================
            /**
             * Import zipped content stored in a Blob object.
             */
            //=========================================================================
            importBlobURLToZip: function(url) {
                var _this = this,
                    zipDef = Promise.deferred();

                if (!_this.isNotEmpty(url)) {
                    zipDef.reject();
                } else {
                    ZipJS.workerScriptsPath =
                        'scripts/ThreeDS/Visualization/zip-js/';

                    var zipFS = new ZipJS.fs.FS();

                    zipFS.importHttpContent(
                        { serverurl: '', filename: url, proxyurl: 'none' },
                        false,
                        function() {
                            zipDef.resolve(zipFS);
                        },
                        function() {
                            console.error('Failure importing to Zip FS');
                            zipDef.reject();
                        }
                    );
                }
                return zipDef.promise;
            },

            //=========================================================================
            /**
             * Import a ZipFileEntry object into a bob and returns a blob url
             * @param fileName
             * @param fileExtension
             * @param zipFileEntry
             */
            //=========================================================================
            importZipFileEntryToBlob: function(args) {
                var _this = this,
                    name = args.fileName || '',
                    fileExtension = args.fileExtension || '',
                    mimeType = _this.getMimeType(fileExtension),
                    deferred = Promise.deferred();

                try {
                    args.zipFileEntry.getBlob(mimeType, function(blob) {
                        deferred.resolve({ name: name, blob: blob });
                    });
                } catch (ex) {
                    deferred.reject(ex);
                }

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Unzip a archive supplied as a blob and retrieve the file entries
             * as blob.
             */
            //=========================================================================
            unZipArchiveAsBlob: function(zip) {
                var masterDeferred = Promise.deferred(),
                    _this = this;

                _this.getEntriesFromZip(zip).then(function(entries) {
                    _this.unZipEntries(entries).then(
                        function(data) {
                            masterDeferred.resolve(data);
                        },
                        function() {
                            masterDeferred.reject();
                        }
                    );
                });

                return masterDeferred.promise;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getEntriesFromZip: function(zip) {
                var _this = this,
                    entryDef = Promise.deferred();

                ZipJS.createReader(
                    new ZipJS.BlobReader(zip),
                    function(zipReader) {
                        zipReader.getEntries(function(entries) {
                            entryDef.resolve(entries);
                        });
                    },
                    function(err) {
                        console.error(err);
                        entryDef.reject();
                    }
                );

                return entryDef.promise;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            unZipEntries: function(entries) {
                var _this = this,
                    promises = [];
                var getEntryFile = function(entry, creationMethod) {
                    var writer = new ZipJS.BlobWriter(),
                        thisBlobDeferred = Promise.deferred();

                    entry.getData(writer, function(blob) {
                        var reader = new FileReader();
                        reader.onloadend = function(e) {
                            _this.fileDataIndex[entry.filename] = this.result;
                            thisBlobDeferred.resolve();
                        };
                        reader.readAsDataURL(blob);
                    });
                    return thisBlobDeferred.promise;
                };

                entries.map(function(entry) {
                    promises.push(getEntryFile(entry, 'Blob'));
                });

                return Promise.all(promises);
            },

            //=========================================================================
            /**
             * A fancier version of unzip from blob. Courtesy of Raphael Olivier
             * Lang
             */
            //=========================================================================
            unzip: function(zip) {
                var _this = this;

                // read all entries aynchronously and resolve when the callback
                // is done
                var getAllEntries = function(file, onEnd) {
                        return new Promise(function(resolve, reject) {
                            ZipJS.createReader(
                                new ZipJS.BlobReader(file),
                                function(zipReader) {
                                    zipReader.getEntries(function(entries) {
                                        resolve(onEnd(entries));
                                    });
                                },
                                function(err) {
                                    console.error(err);
                                    reject(err);
                                }
                            );
                        });
                    },
                    getEntryFile = function(entry, creationMethod) {
                        return new Promise(function(resolve, reject) {
                            var writer = new ZipJS.BlobWriter();
                            entry.getData(writer, function(blob) {
                                var reader = new FileReader();
                                reader.onloadend = function(e) {
                                    // do something useful here with this.result
                                    _this.fileDataIndex[
                                        entry.filename
                                    ] = this.result;
                                    resolve({
                                        name: entry.filename,
                                        content: this.result
                                    });
                                };
                                reader.readAsDataURL(blob);
                            });
                        });
                    };

                return getAllEntries(zip, function onEnd(entries) {
                    // Map all entries we find recursively to a promise that
                    // resolve when content is read
                    return Promise.all(
                        entries.map(function(entry) {
                            return getEntryFile(entry, 'Blob');
                        })
                    );
                });
            },

            //=========================================================================
            /**
             * Return mime type strings for popular file extensions
             */
            //=========================================================================
            getMimeType: function(fileExtension) {
                var mimeType = '';
                switch (fileExtension.toLowerCase()) {
                    case 'csv':
                        mimeType = 'text/csv';
                        break;
                    case 'json':
                        mimeType = 'application/json';
                        break;
                    case 'jpg':
                        mimeType = 'image/jpeg';
                        break;
                    case 'png':
                        mimeType = 'image/png';
                        break;
                    default:
                        mimeType = '';
                        break;
                }
                return mimeType;
            },

            //=========================================================================
            /**
             * Create a Widget preference with the list of available stations
             */
            //=========================================================================
            createStationPreference: function(stations) {
                var _this = this,
                    stationPrefList = [];

                stationPrefList.push({ value: '', label: '' });
                stationPrefList.push({
                    value: '{localhost}',
                    label: '{localhost}'
                });

                stations.forEach(function(station, index) {
                    if (
                        station &&
                        station['@name'] &&
                        station['@name'].length > 0 &&
                        station.GeneralInfo &&
                        station.GeneralInfo['@hostIP'] &&
                        station.GeneralInfo['@hostIP'].length > 3
                    ) {
                        stationPrefList.push({
                            value: station['@name'],
                            label: station['@name']
                        });
                    }
                }, this);

                widget.addPreference({
                    name: 'stations',
                    type: 'list',
                    //FIXME: add Default Analytics Engine to NLS
                    label: 'Default Analytics Engine', //NLS.get('stations'),
                    options: stationPrefList,
                    defaultValue: null
                });
            },

            setSignificantDigits: function(value) {
                if (parseFloat(value) === parseInt(value) && !isNaN(value)) {
                    this.significantDigits = parseInt(value);
                } else if (typeof this.significantDigits !== 'undefined') {
                    // not a valid integer, reset it to what it was before
                    widget.setValue(
                        'significantDigits',
                        this.significantDigits
                    );
                } else {
                    this.significantDigits = 6;
                    widget.setValue('significantDigits', 6);
                }
            },

            getSignificantDigits: function() {
                if (typeof this.significantDigits === 'undefined') {
                    this.setSignificantDigits();
                }
                return this.significantDigits;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            initializeLiteWidget: function(serverUrl, csrfToken) {
                this.notifs = WUXNotifications;
                WUXScreenNotifications.setNotificationManager(WUXNotifications);

                this.serverURL = serverUrl;
                this.ENO_CSRF_TOKEN = csrfToken

                // add preference for significant digits
                widget.addPreference({
                    type: 'text',
                    name: 'significant_digits',
                    label: 'Significant Digits',
                    defaultValue: 6,
                    onchange: 'preferencesChanged'
                });

                this.spDashboard = document.querySelector('sp-dashboard')

                /*this.getCSRFToken().done(function() {
                    // FIXME : This is not needed in all cases. (ie)
                    // cases that do not need a station.
                    _this.getEEDInfo().then(
                        function(data) {
                            _this.EED_URL = data.eedUrl;
                            _this.EED_TICKET = data.eedTicket;

                            //                  _this.StationOps = new
                            //                  LiteStationOps({
                            //                      'mcsURL' :
                            //                      _this.get3DSpaceURL(),
                            //						'eedURL': _this.EED_URL,
                            //                      'eedTicket':
                            //                      _this.EED_TICKET
                            //					});

                            //					_this.StationOps.getNonRunAsStations().then(function(stations){
                            //_this.createStationPreference(stations);
                            deferred.resolve();
                            //					}, function(error){
                            //                      console.error('Unable to
                            //                      connect to the Compute
                            //                      Orchestartion Server.',
                            //                      [error]);
                            //                      console.error('Unable to
                            //                      retrive the list of
                            //                      available EED Stations.',
                            //                      [error]);
                            //						deferred.resolve();
                            //					});
                        },
                        function(error) {
                            console.error(
                                'Unable to connect to the Compute Orchestartion Server.',
                                error
                            );
                            deferred.resolve();
                        }
                    );
                });*/
            },

            //=========================================================================
            /**
             * @deprecated
             */
            //=========================================================================
            /*initializeLiteWidget_OLD: function() {
                var _this = this,
                    initPromises = [],
                    initDeferred = Promise.deferred();
                var setStationPreference = function() {
                    initPromises.push(
                        _this
                            .getActiveStationsList({ eedUrl: _this.EED_URL })
                            .then(function(data) {
                                _this.createStationPreference(data);
                            })
                    );
                };
                _this.spDashboard = UWA.createElement('sp-dashboard');
                _this.set3DSpaceURL(_this.spDashboard.getMcsUri());
                _this.spDashboard.addSecurityContextPreference();
                // Set the Station list preference
                initPromises.push(
                    _this.getEEDInfo().then(
                        function(data) {
                            _this.EED_URL = data.eedUrl;
                            _this.EED_TICKET = data.eedTicket;

                            // FIXME : runas enabled WS fails because the
                            // ticket is not sent back by getEEDInfo
                            initPromises.push(
                                _this.getEEDRunAsStatus().then(
                                    function(data) {
                                        _this.EED_RUN_AS = Boolean(
                                            data === 'true' ||
                                                data === true ||
                                                data === '1' ||
                                                data === 1
                                        );
                                        setStationPreference();
                                    },
                                    function(err) {
                                        _this.EED_RUN_AS = false;
                                        setStationPreference();
                                    }
                                )
                            );
                        },
                        function(error) {
                            console.error(
                                'Unable to retrieve the list of active stations.',
                                error
                            );
                        }
                    )
                );
                Promise.all(initPromises).then(function() {
                    initDeferred.resolve();
                });

                return initDeferred.promise;
            },*/

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getTicketAndDownloadFile: function(oid, fileName, fileType) {
                var _this = this;
                var deferred = Promise.deferred();
                _this
                    .getFCSTicket({
                        action: 'download',
                        title: fileName,
                        oId: oid
                    })
                    .then(
                        function(ticketData) {
                            _this
                                .downloadFile({
                                    ticket: encodeURIComponent(
                                        ticketData.ticket
                                    ),
                                    fileExtension: fileType,
                                    url: ticketData.fcsUrl
                                })
                                .then(
                                    function(blob) {
                                        deferred.resolve(blob);
                                    },
                                    function(err) {
                                        alert(
                                            'Error downloading the Lite Json File'
                                        );
                                        deferred.reject();
                                    }
                                );
                        },
                        function(err) {
                            /*console.error('Error getting the download ticket
                            for lite json file.', err); alert('Error reading
                            saved Essential case');*/

                            console.log(
                                'No lite data was found. Initiating lite servant launch..'
                            );
                            deferred.reject();
                        }
                    );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Store the list of datasets for the active case
             */
            //=========================================================================
            storeDataSetsList: function(response) {
                var _this = this;
                if (response instanceof String) {
                    response = JSON.parse(response);
                }
                if (typeof response === 'undefined' || response === null) {
                    response = [];
                }

                if (
                    typeof response.analyticsDataSet !== 'undefined' &&
                    response.analyticsDataSet !== null
                ) {
                    if (Array.isArray(response.analyticsDataSet)) {
                        _this.datasets = response.analyticsDataSet;
                    }
                } else if (
                    response.analyticsDataSetList !== 'undefined' &&
                    response.analyticsDataSetList !== null
                ) {
                    if (Array.isArray(response.analyticsDataSetList)) {
                        _this.datasets = response.analyticsDataSetList;
                    }
                }
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getDataSetsList: function() {
                var _this = this;
                return _this.datasets || [];
            },

            //=========================================================================
            /**
             * Return a list of datasets that are simulation objects
             */
            //=========================================================================
            getSimulationObjectsConnectedToCase: function() {
                var _this = this;
                return _this.datasets.filter(function(x) {
                    return (
                        [
                            'DesignSight',
                            'VPMReference' /*,'Simulation'*/
                        ].indexOf(x.type) > -1
                    );
                });
            },

            //=========================================================================
            /**
             * Simple blob reader. Reads the supplied blob and returns a string
             * or a JSON object based on the isJSON flag provided in the args.
             */
            //=========================================================================
            blobReader: function(blob, isJSON) {
                return new Promise(function(resolve, reject) {
                    if (typeof blob === 'undefined' || blob === null) {
                        reject();
                    } else {
                        var readr = new FileReader();
                        readr.addEventListener('error', function(args) {
                            console.log(args);
                            reject();
                        });

                        readr.addEventListener('loadend', function() {
                            if (isJSON) {
                                try {
                                    var reslt = this.result
                                        .split('NaN')
                                        .join('null');
                                    resolve(JSON.parse(reslt));
                                } catch (err) {
                                    console.error(
                                        'Error parsing the provided blob. ',
                                        [err]
                                    );
                                    reject(err);
                                }
                            } else {
                                resolve(this.result);
                            }
                        });
                        readr.readAsText(blob);
                    }
                });
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            getTicketAndDownloadResultFile: function(oId) {
                var _this = this,
                    deferred = Promise.deferred();
                this.getResultTicket(oId).then(
                    function(ticketData) {
                        _this
                            .downloadFile({
                                ticket: encodeURIComponent(ticketData.ticket),
                                url: ticketData.fcsUrl
                            })
                            .then(
                                function(blob) {
                                    deferred.resolve(blob);
                                },
                                function(err) {
                                    console.error(
                                        'Error downloading result file',
                                        err
                                    );
                                    deferred.reject();
                                }
                            );
                    },
                    function(err) {
                        console.error(
                            'Error getting ticket for result file',
                            err
                        );
                        deferred.reject();
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
             * Get all the attributes and attribute groups for the provided
             * object ids.
             */
            //=========================================================================
            getAttributeAndPLMDataForObjects: function(oIdsArray) {
                var oIds = '';
                oIdsArray.forEach(function(oid) {
                    oIds += oIds.length > 0 ? ';' + oid : oid;
                });

                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'getAttributesAndPLMParameters' +
                        '?objectids=' +
                        oIds;

                return _this.uwaDataRequest_GET({
                    url: url,
                    type: 'json',
                    timeout: 20000
                });
            },

          //=========================================================================
            /**
	         * Returns object ID given physicalId
	         */
	        //=========================================================================
            getObjIdFromPhyId: function(phyId){
                var _this = this,
                url = _this['serverURL'] + _this['BPS_SERVICE_LOC'] + 'PhyIdToObjId/phyIds',
                data = {phyIds: [phyId]};
                return _this.uwaDataRequest_POST({
                      url: url,
                      timeout: 60000,
                      data: data,
                      type: 'json'
                });
            },
            
            //=========================================================================
            /**
             * Deletes Analytics case(s).
             */
            //=========================================================================
            deleteObjects: function(objectIds) {
                var _this = this,
                    url =
                        _this.serverURL +
                        _this.ADVISE_SERVICE_LOC +
                        'deleteObjects',
                    data = { objectids: objectIds };

                return _this.uwaDataRequest_POST({
                    url: url,
                    timeout: 60000,
                    data: data,
                    type: 'json'
                });
            },
            
            /**
             * Get simulation process image
             */
            getProcessImage: function(physicalIds){
            	var _this = this,
                url =
                    _this.serverURL +
                    _this.SIMULATION_SERVICE_LOC +
                    'filter',
                data = [ physicalIds ];

	            return _this.uwaDataRequest_POST({
	                url: url,
	                timeout: 60000,
	                data: data,
	                type: 'json'
	            });
            },
            
            getThumbnail: function(physicalId){
            	var _this = this;
                return _this.uwaDataRequest_GET({
                    url:
                        _this.serverURL +
                        _this.LIFECYCLE_SERVICE_LOC +
                        'revision/family',
                    params: {
                    	physicalid: physicalId,
                    	SecurityContext: _this.getActiveCollabSpace()
                	},
                	headers:{
                		'Content-Type':'application/json',
                		'SecurityContext' : _this.getActiveCollabSpace()
                	},
                    cache: 2000,
                    type: 'application/octet-stream'
                });
            },
            //=========================================================================
            /**
             *
             */
            //=========================================================================
            saveCaseFile: function(caseId, fileName, caseFile) {                

                var applicationType = 'application/json';
                if (fileName.endsWith('.tsv')) {
                        applicationType = 'application/text';
                }
                
                var data = caseFile;
                var blob = new Blob([data], { type: applicationType });
                var nFile = null;

                try {
                    nFile = new File([blob], fileName);
                } catch (e) {
                    // IE11 doesn't like the File API
                    // fake it ..
                    nFile = blob;

                    nFile.name = fileName;
                    nFile.relativePath = '';
                    nFile.lastModifiedDate = new Date();
                }
                   
                return this.uploadFileTo3DSpace({
                            oId: caseId,
                            title: fileName,
                            file: nFile
                        });

            },
            
            saveCaseData: function(caseId, caseData) {
                var savePromises = [],
                    _this = this;

                Mask.mask(widget.body, NLS.get('SAVING'));

                Object.keys(caseData).forEach(function(key) {
                   
                    savePromises.push(
                        this.saveCaseFile(caseId, key, caseData[key])
                    );
                }, this);
                return new Promise(function(resolve, reject){
                	Promise.all(savePromises).then(
            			function() {
            				Mask.unmask(widget.body);
            				resolve();
            			},
            			function() {
            				Mask.unmask(widget.body);
            				reject();
            			}
                	);
                });
            },

            showError: function(message) {
                if (typeof message === 'undefined') {
                    message = 'Error';
                }
                var notification = {
                    level: 'error',
                    message: message,
                    sticky: false
                };
                this.notifs.addNotif(notification);
            },
            showWarning: function(message) {
                if (typeof message !== 'undefined') {
                    var notification = {
                        level: 'warning',
                        message: message,
                        sticky: false
                    };
                    this.notifs.addNotif(notification);
                }
            },
            showSuccess: function(message) {
                if (typeof message === 'undefined') {
                    message = 'Action Successful';
                }
                var notification = {
                    level: 'success',
                    message: message,
                    sticky: false
                };
                this.notifs.addNotif(notification);
            },
            showMessage: function(message) {
                if (typeof message !== 'undefined') {
                    var notification = {
                        level: 'info',
                        message: message,
                        sticky: false
                    };
                    this.notifs.addNotif(notification);
                }
            },
            //=========================================================================
            /**
             * Check if the supplied type is a Simulation object type or not.
             */
            //=========================================================================
            isASimulationObjectType: function(type) {
                return this.soTypesList.indexOf(type) > -1;
            },

            setImmersiveFrame: function(iF) {
                this.immersiveFrame = iF;
            },

            getImmersiveFrame: function() {
                return this.immersiveFrame;
            },

            debounce: function(name, func, wait) {
                // _this['spDashboard'] is a Polymer component ...
                this.spDashboard.debounce(name, func, wait);
            },
            cancelDebouncer: function(name) {
                this.spDashboard.cancelDebouncer(name);
            },

            setRequirementsData: function(reqData) {
                this._reqData = reqData;
            },
            getRequirementsData: function() {
                return this._reqData || [];
            },
            setRequirementsList: function(reqList) {
                this._reqList = reqList;
            },
            getRequirementsList: function() {
                return this._reqList || [];
            }
        });

        return widgetProxy.prototype;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/pages/case-details/SMAAnalyticsLiteCaseDetailsPage',
    [
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/W3DXComponents/Views/Item/TileView',
        'text!SMAAnalyticsLiteWidget/pages/case-details/SMAAnalyticsLiteCaseDetailsPage.html',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ],
    function(UWA, Promise, View, Fragment, WidgetProxy, NLS) {
	'use strict';

        var SMAAnalyticsCaseDetailsView = View.extend({
		//fix for selectedFacet not working in the widget skeleton
		//since we need second tab by default,
		//only on first time entering this facet,
		//set the route to compare page
		isFirstTimeEntering : true,
		
		template: function() {
			return Fragment;
		},
		
		events: {
                onFacetSelect: 'onFacetSelect'
		  	//'onResizeClick': 'onResizeClick'
		},
		
		tagName: 'div',
        className: 'link-detail',
        model: null,
		
		onRender: function() {
			this._parent.apply(this, arguments);
			return true;
		},
		
		onFacetSelect: function(){
			//the route looks like '/landingpage/1234.34345.4534/?f=0'
			//change it to f=1
			if(this.isFirstTimeEntering){
				var skeleton = arguments[0];
				var route = skeleton.getRoute();
				var newRoute = route.substring(0, route.length-1) + '1';
				skeleton.setRoute(newRoute);
				this.isFirstTimeEntering = false;
			}
		},
		
		init: function(options){
			if(options && options.model) {
				var that = this;
				that.model = options.model;
				that.model.addEvent('onChange', function(){
					that.render();
				});
				// Check if this a new case
				var caseid = that.model.get('id') || '';
				if (caseid === ''){
					that.newCaseMode = true;
				}
				that.createDrop = true;
			}
			this._parent(arguments);
		},
		
		onResizeClick: function(event){
			//this.render();
            }
  	});
	
        return SMAAnalyticsCaseDetailsView;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteCaseCollection',
    [
                                                      'UWA/Core',
                                                      'UWA/Class/Model',
                                                      'UWA/Class/Collection',
                                                      'UWA/Utils',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteCaseModel',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ],
    function(
        UWA,
        Model,
        Collection,
        Utils,
        SMAAnalyticsListModel,
        WidgetProxy,
        NLS
    ) {
	'use strict';

        var SMAAnalyticsCaseCollection = Collection.extend({
            model: SMAAnalyticsListModel,
		rcImage: '',
		
		comparator: function(a, b){
			if(b.get('id') > a.get('id')){
				return 1;
			} else if(a.get('id') > b.get('id')){
				return -1;
			} else {
				return 0;
			}
		},
		
		urlRoot: WidgetProxy.get3DSpaceURL(),
		
		getModifiedInterval: function(modif) {
            try {
                var modified = new Date(modif),
                    now = Date.now(),
                    diffSec = (now - modified) / 1000;

                var diff = Math.round(diffSec / 86400);
                if (diff == 1) {
                    return (
                        diff.toString() + ' ' + NLS.get('day_ago')
                    );
                } else if (diff >= 1) {
                    return (
                        diff.toString() + ' ' + NLS.get('days_ago')
                    );
                } else if ((diff = Math.round(diffSec / 3600)) == 1) {
                    return diff.toString() + ' ' + NLS.get('hr_ago');
                } else if ((diff = Math.round(diffSec / 3600)) >= 1) {
                    return (
                        diff.toString() + ' ' + NLS.get('hrs_ago')
                    );
                } else if ((diff = Math.round(diffSec / 60)) == 1) {
                    return (
                        diff.toString() + ' ' + NLS.get('min_ago')
                    );
                } else if ((diff = Math.round(diffSec / 60)) >= 1) {
                    return (
                        diff.toString() + ' ' + NLS.get('mins_ago')
                    );
                } else {
                    return (
                        diff.toString() + ' ' + NLS.get('secs_ago')
                    );
                }
            } catch (ex) {
                return '1' + NLS.get('secs_ago');
            }
        },

		sync: function(operation,collection,options){
			switch(operation) {
				case 'read':
					WidgetProxy.getCaseList().then(
									options.onComplete,
                            options.onFailure
                        );
					break;
				default:
					options.onFailure('Unsupported Operation');
					break;
			}
                return { cancel: function() {} };
		},
		
		parse: function(resp){
			this.reset();
			var that = this,
			data = [];
		
                if (resp instanceof String) {
                    resp = JSON.parse(resp);
                }
                if (typeof resp === 'undefined' || resp === null) {
                    resp = [];
                }

                if (
                    typeof resp.analyticsCase !== 'undefined' &&
                    resp.analyticsCase !== null
                ) {
				if(Array.isArray(resp.analyticsCase)){
					data = resp.analyticsCase;
				}
                } else if (
                    resp.analyticsCaseList !== 'undefined' &&
                    resp.analyticsCaseList !== null
                ) {
				if(Array.isArray(resp.analyticsCaseList)){
					data = resp.analyticsCaseList;
				}
			}
			
			data.forEach(function (item) {
                    if (item.name) {
                        item.casename = item.name;
                    }
                    if (item.owner) {
                        item.author = item.owner;
                    }
	
				item.content = item.owner;
				item.subtitle = that.getModifiedInterval(item.time);
				item.enoviaURL = WidgetProxy.get3DSpaceURL();
				item.updatedInterval = item.time;
				item.launchadvise = true;
				item.type = 'AnalyticsCase';
	
                    if (
                        typeof item.image === 'undefined' ||
                        item.image === null ||
                        item.image === ''
                    ) {
                        item.image =
                            WidgetProxy.get3DSpaceURL() +
                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png';
                    }
                    /*if (typeof item.icon === 'undefined' || item.icon === null
                    || item.icon === ''){
                        //item.icon = WidgetProxy.get3DSpaceURL()
                    +'/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png';
                    }*/
                    if (
                        typeof item.datasetsCount !== 'undefined' &&
                        item.datasetsCount > 0
                    ) {
					item.datasets = true;
                    } else {
					item.datasets = false;
					item.datasetsCount = 0;
				}
                    if (
                        typeof item.requirementsCount !== 'undefined' &&
                        item.requirementsCount > 0
                    ) {
					item.requirements = true;
                    } else {
					item.requirements = false;
					item.requirementsCount = 0;
				}
                    if (
                        typeof item.downselected === 'undefined' ||
                        item.downselected === null
                    ) {
					item.downselected = 0;
				}
			});
			
			return data;
			}
});
        return SMAAnalyticsCaseCollection;
    }
);

/* global worker */
/* jshint -W116 */
//XSS_CHECKED
define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',
    [
        'UWA/Class',
        'UWA/Core',
        'DS/Core/Core',
        'DS/Controls/Button',
        'DS/Windows/Dialog',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils'
    ],
    function(Class, UWACore, WUXCore, WUXButton, WUXDialog, WidgetProxy, AnalyticsUtils) {
        'use strict';

        var _self = null;

        var RAEPopover = Class.extend({
            init: function(options) {
                _self = this;
                this.isReady = false;

                options = options || {};
                //          options.container = options.container ||
                //          document.body;

                // reset some defaults
                this.closeButtonFlag =
                    typeof options.closeButtonFlag === 'boolean'
                        ? options.closeButtonFlag
                        : false;
                this.resizableFlag =
                    typeof options.resizableFlag === 'boolean'
                        ? options.resizableFlag
                        : true;
                this.isModal = options.isModal || false;
                this.width = options.width || 500;
                this.height = options.height || 400;
               
                this.immersiveFrame = AnalyticsUtils.getImmersiveFrame();
                //            this.immersiveFrame = new WUXImmersiveFrame();
                //            this.immersiveFrame.inject(options.container);

                // this.visibleFlag = typeof options.visibleFlag === 'boolean' ?
                // options.visibleFlag : true,

                this.title = options.title || '';
            },
            setTitle: function(title) {
                this.title = title || this.title || '';
            },
            open: function() {
                if (this.dialog) {
                    this.dialog.visibleFlag = this.visibleFlag = true;
                  
                }
            },
            close: function() {
                if (this.dialog) {
                    this.dialog.buttons.Close.fire('click');
                    // this.dialog.visibleFlag = this.visibleFlag = false;
                }
            },
            onResize: function(resizeFunction) {
                if (this.dialog) {
                    // TODO: WebUX 'resize' listener wasn't firing.  we should
                    // use that when it starts working again
                    this.dialog.addEventListener('stopResize', function(e) {
                        //                  _self.dialogContent.style.width =
                        //                  _self.dialogContent.parentElement.scrollWidth;
                        //                  _self.dialogContent.style.height =
                        //                  _self.dialogContent.parentElement.scrollHeight;
                        if (
                            _self.dialogContent.parentNode &&
                            _self.dialogContent.parentNode.classList
                        ) {
                            _self.dialogContent.parentNode.classList.add(
                                'rae-popover-fix'
                            );
                        }
                        if (typeof resizeFunction === 'function') {
                            resizeFunction();
                        }
                        //                  _self.dialogContent.style.height =
                        //                  '';
                        //                  _self.dialogContent.style.position =
                        //                  '';
                    });

                    this.dialog.fire('stopResize');
                }
            },
            injectContent: function(contents, callbacks) {
                var body = contents ? contents.body : null,
                    footer = contents ? contents.footer : null,
                    header = contents ? contents.header : null;

                var dialogContentWrapper = document.createElement('div');
                dialogContentWrapper.classList.add('rae-popover');
                //          dialogContentWrapper.style.height = this.height +
                //          'px'; dialogContentWrapper.style.position =
                //          'relative';
                dialogContentWrapper.closeCallback = callbacks
                    ? callbacks.close
                    : null;
                dialogContentWrapper.okCallback = callbacks
                    ? callbacks.ok
                    : null;
                dialogContentWrapper.applyCallback = callbacks
                    ? callbacks.apply
                    : null;
                    
                dialogContentWrapper.confirmOnCloseCallback = callbacks 
                    ? callbacks.confirmOnCloseCallback : null;
                    
                var pmBody = document.createElement('div');
                pmBody.classList.add('rae-popover-container');

                if (header) {
                    var pmBodyTop = document.createElement('div');
                    pmBodyTop.classList.add('ra-pmui');
                    pmBodyTop.classList.add('rae-popover-head'); // TODO: refactor this classname
                    pmBodyTop.appendChild(header);
                    pmBody.appendChild(pmBodyTop);
                }

                if (body) {
                    var pmBodyMain = document.createElement('div');
                    pmBodyMain.classList.add('rae-popover-main');
                    pmBodyMain.appendChild(body);
                    pmBody.appendChild(pmBodyMain);
                }

                if (footer) {
                    var pmBodyBottom = document.createElement('div');
                    pmBodyBottom.classList.add('ra-pmui');
                    pmBodyBottom.classList.add('rae-popover-foot'); // TODO: refactor this classname
                    pmBodyBottom.appendChild(footer);
                    pmBody.appendChild(pmBodyBottom);
                }

                dialogContentWrapper.appendChild(pmBody);
                this.dialogContent = dialogContentWrapper;
                //          this.dialogContent.style.width = this.width + 'px';
                //          this.dialogContent.style.height = this.height +
                //          'px';
                // this.dialogContent = contents;

                var myButtons = {
                    Close: new WUXButton({
                        onClick: function(e) {
                            var button = e.dsModel;
                            var myDialog = button.dialog;
                            
                            if (typeof dialogContentWrapper.confirmOnCloseCallback === 'function'){
                                myDialog.__contentWrapper__.confirmOnCloseCallback().then(function(resolve){                            
                                    myDialog.close(); 
                                }, function(reject){                            
                                    // do nothing, user does not want to proceed withclose 
                                }
                             );
                                
                            }else {                            
                                myDialog.close();
                            }
                        }
                    })
                };
                

                
                if (typeof dialogContentWrapper.okCallback === 'function') {
                    myButtons.Apply = new WUXButton({
                        label: 'OK',
                        emphasize: 'primary',
                    	onClick: function(e) {
                            var button = e.dsModel;
                            var myDialog = button.dialog;
                            myDialog.__contentWrapper__.okCallback();                            
                            myDialog.close();                            
                        }
                    });
                }
                // removing Apply buttons
                //          if(typeof dialogContentWrapper.applyCallback ===
                //          'function'){
                //              myButtons.Apply = new WUXButton({
                //                  'onClick' : function(e){
                //                      var button = e.dsModel;
                //                        var myDialog = button.dialog;
                //                      myDialog.__contentWrapper__.applyCallback();
                //                  }
                //              });
                //          }
                this.dialog = new WUXDialog({
                    title: this.title,
                    content: this.dialogContent,
                    immersiveFrame: this.immersiveFrame,
                    resizableFlag: this.resizableFlag,
                    width: this.width,
                    height: this.height,
                    closeButtonFlag: true, // this.closeButtonFlag,
                    visibleFlag: true, // this.visibleFlag,
                    buttons: myButtons,
                    modalFlag:this.isModal
                });
                if(myButtons.Apply){
                	myButtons.Apply.emphasize = 'primary';
                }
                this.dialog.__contentWrapper__ = dialogContentWrapper;
                this.dialog.addEventListener('close', function() {
                    if (
                        dialogContentWrapper &&
                        typeof dialogContentWrapper.closeCallback === 'function'
                    ) {
                        dialogContentWrapper.closeCallback();
                    }
                });

                //          this.dialog.fire('resize');

                //          this.contentPanel = new Panel({
                //              title: 'My Content',
                //              content : contents,
                //              immersiveFrame : this.immersiveFrame,
                //              closeButtonFlag : false//,
                //              //currentDockArea : 4
                //          });
            } //,
            //      show : function(){
            //          if(this.isReady){
            //              this.frmWindow.getActionBar().open();
            //          }
            //      },
            //      hide : function(){
            //          if(this.isReady){
            //              this.frmWindow.getActionBar().hide();
            //          }
            //      }
        });

        return RAEPopover;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequirementsUtils',
    [
        'UWA/Core',
        'UWA/Utils',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/UIKIT/Form',
        'DS/UIKIT/Modal',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy'
    ],
    function(UWA, Utils, Class, Promise, Form, Modal, WidgetProxy) {
        'use strict';

        var _self = null;

        var RequirementsUtils = Class.extend({
            init: function(options) {
                _self = this;
                _self.caseId = options.caseId;
                // this.immersiveFrame = options.immersiveFrame;
            },

            // will return an empty div that is a dropzone for requirements
            // objects
            createDropBox: function() {
                var dropBox = null;

                // create the dropbox (will be returned and attached
                // appropriately outside of this function)
                dropBox = document.createElement('div');

                // d9u - necessary?
                // this.scopeSubtree(dropBox);

                dropBox.onclick = function() {
                    if (widget) {
                        // this will bring up the UI :)
                        widget.dispatchEvent('onRequirementsAttached');
                    }
                };

                return dropBox; // return the element to be apended :)
            },

            getRowFormulationContents: function(
                rowData,
                requirementsChangeCallback
            ) {
                var objective = rowData.objective,
                    constraints = rowData.constraints;

                var rowFormulationContents = document.createElement('div');
                rowFormulationContents.classList.add('row-formulation-button');

                if (objective || constraints) {
                    rowFormulationContents.classList.add('row-has-formulation');
                    // display the priority only if there is a
                    // constraint/objective
                    rowFormulationContents.appendChild(
                        _self.getPriorityAsHTML(rowData)
                    );

                    if (objective) {
                        var objType = rowData.objective.type;
                        var objVal = rowData.objective.value;
                        rowFormulationContents.appendChild(
                            _self.getObjectiveAsHTML(objType, objVal)
                        );
                    }
                    if (constraints) {
                        var lower = null,
                            upper = null;
                        constraints.forEach(function(constraint) {
                            if (constraint.conditions) {
                                constraint.conditions.forEach(function(
                                    condition
                                ) {
                                    if (condition.type === 'GREATER_THAN') {
                                        lower = condition.boundValue;
                                    } else if (condition.type === 'LESS_THAN') {
                                        upper = condition.boundValue;
                                    }
                                });
                            }
                        });
                        var constraintContainer = document.createElement(
                            'span'
                        );
                        constraintContainer.classList.add(
                            'ra-constraints-wrapper'
                        );

                        // TODO: this doesn't look quite right, so I'm removing
                        // it until I get around to fixing it
                        //                  var constraint =
                        //                  document.createElement('span');
                        //                  constraint.classList.add('ra-constraints-label');
                        //                  constraint.classList.add('fonticon');
                        //                  constraint.classList.add('fonticon-code');
                        //                  // <> in 16x, <...> in 17x?
                        //                  constraintContainer.appendChild(constraint);

                        var constraintElem = _self.getConstraintsAsHTML(
                            lower,
                            upper
                        );
                        constraintContainer.appendChild(constraintElem);
                        rowFormulationContents.appendChild(constraintContainer);
                    }
                } else {
                    var noReqs = document.createElement('span');
                    
                    if(rowData.source == "Dataset") {
                        noReqs.setAttribute("style", "cursor:default;");
                    }
                    else {
                        noReqs.classList.add('fonticon');
                        noReqs.classList.add('fonticon-pencil');
                        noReqs.setAttribute("title", "Edit");
                    }
                  
                    rowFormulationContents.appendChild(noReqs);
                }
                var _this = this; // for some reason _self no longer refers to
                // the same 'this' context
                //          rowFormulationContents.rowData = formulation;
                //          rowFormulationContents.onclick = function(){
                //              _this.openFormulationUI(rowData,requirementsChangeCallback);
                //              //FIXME: looking for the table here ... chagne
                //              to _self.fire ?
                ////
                ///this.parentElement.parentElement.fire('formulationcheck',rowData);
                //          };
                return rowFormulationContents;
            },

            getPriorityAsHTML: function(rowData) {
                var priorityElem = document.createElement('span');
                priorityElem.classList.add('ra-parameter-priority');
                var priorityVal = rowData.priority,
                    priorityTitle = rowData.priority;
                priorityElem.classList.add(
                    'ra-parameter-priority-' + priorityVal
                );
                if (priorityVal === 0) {
                    priorityVal = '!';
                    priorityTitle = 'Must Have';
                } else {
                    priorityTitle = 'Priority ' + priorityVal;
                }
                priorityElem.textContent = priorityVal;
                priorityElem.title = priorityTitle;

                return priorityElem;
            },

            getObjectiveAsHTML: function(objectiveType, objectiveValue) {
                var objContainer = document.createElement('span');
                objContainer.classList.add('ra-objective-wrapper');

                objectiveType = objectiveType.toUpperCase();

                var obj = document.createElement('span');
                obj.classList.add('ra-objective-label');
                obj.classList.add('fonticon');
                if (objectiveType === 'MAXIMIZE') {
                    obj.classList.add('fonticon-up-bold');
                } else if (objectiveType === 'MINIMIZE') {
                    obj.classList.add('fonticon-down-bold');
                } else if (objectiveType === 'TARGET') {
                    obj.classList.add('fonticon-target');
                }
                obj.title = objectiveType;
                objContainer.appendChild(obj);

                if (
                    objectiveType === 'TARGET' &&
                    typeof objectiveValue !== 'undefined'
                ) {
                    var objVal = document.createElement('span');
                    objVal.textContent = '=' + objectiveValue;
                    objContainer.appendChild(objVal);
                }
                return objContainer;
            },
            getConstraintsAsHTML: function(lower, upper) {
                var constraint = document.createElement('span');
                constraint.classList.add('ra-constraint-label');

                if (lower !== null && upper !== null) {
                    // upper and lower bound
                    constraint.textContent = '[' + lower + ',' + upper + ']';
                } else if (lower !== null) {
                    constraint.textContent = '> ' + lower;
                } else if (upper !== null) {
                    constraint.textContent = '< ' + upper;
                }
                return constraint;
            },

            // creates UI for manually editing the formulation on a parameter
            // not called on initialization
            createFormulationUI: function(renderTarget) {
                //          var modalHeader = document.createDocumentFragment();
                //          modalHeader.textContent = 'Requirements';
                //          _self.formulationModal = new Modal({
                //              'closable': true,
                //              'renderTo': renderTarget
                //          });
                //          _self.formulationModal.setHeader(modalHeader);
                //          return _self.formulationModal;
            },

            // opens the UI for manually editing the formulation scraped from
            // the provided rowData
            openFormulationUI: function(rowData, requirementsChangeCallback) {
                var priorityOptions = [],
                    objectiveOptions = [],
                    upperThreshold,
                    lowerThreshold;

                var priority =
                        typeof rowData.priority !== 'undefined'
                            ? rowData.priority
                            : 5,
                    objective = rowData.objective || { type: '', value: '' },
                    objectiveType = objective.type || '',
                    targetValue = objective.value || '',
                    constraints = rowData.constraints || [];

                // need to set this here because if the objective comes
                // from rowData than the parameterID won't be there
                objective.parameterID = rowData.id;

                // ------------------------
                // PRIORITY HANDLING
                // ------------------------

                // build the priority options for the dropdown
                for (var i = 0; i < 6; i++) {
                    var priorityOption = { value: i };
                    if (i === 0) {
                        priorityOption.label = 'Must Have';
                    } else {
                        priorityOption.label = String(i);
                    }
                    if (priority === i) {
                        priorityOption.selected = true;
                    }
                    priorityOptions.push(priorityOption);
                }
                // ------------------------

                // ------------------------
                // OBJECTIVE HANDLING
                // ------------------------

                // TODO: Use NLS for labels
                var objectiveOption = { value: '', label: 'None' };
                if (objectiveOption.value === objectiveType) {
                    objectiveOption.selected = true;
                }
                objectiveOptions.push(objectiveOption);
                var objectiveOption = { value: 'MAXIMIZE', label: 'Maximize' };
                if (objectiveOption.value === objectiveType) {
                    objectiveOption.selected = true;
                }
                objectiveOptions.push(objectiveOption);
                var objectiveOption = { value: 'MINIMIZE', label: 'Minimize' };
                if (objectiveOption.value === objectiveType) {
                    objectiveOption.selected = true;
                }
                objectiveOptions.push(objectiveOption);
                var objectiveOption = { value: 'TARGET', label: 'Target' };
                if (objectiveOption.value === objectiveType) {
                    objectiveOption.selected = true;
                }
                objectiveOptions.push(objectiveOption);
                // ------------------------

                // ------------------------
                // CONSTRAINT/THRESHOLD HANDLING
                // ------------------------

                constraints.forEach(function(constraint) {
                    //              var obj = document.createElement('span');
                    var less, greater;
                    if (constraint.conditions) {
                        constraint.conditions.forEach(function(condition) {
                            if (condition.type === 'GREATER_THAN') {
                                greater = condition.boundValue;
                            } else if (condition.type === 'LESS_THAN') {
                                less = condition.boundValue;
                            }
                        });
                    }
                    //              obj.classList.add('ra-constraint-label');
                    if (
                        typeof less !== 'undefined' &&
                        typeof greater === 'undefined'
                    ) {
                        upperThreshold = less;
                    } else if (
                        typeof less === 'undefined' &&
                        typeof greater !== 'undefined'
                    ) {
                        lowerThreshold = greater;
                    }
                });
                // ------------------------
                //          var formulationForm = new TypeRepFactory();
                //          formulationForm.onReady = function () {
                //              var myForm = this;
                //              // Here we create a view base on the
                //              TypeRepresentationFactory.generateView method.
                //              // To generate a view, we need:
                //              //     - the input data
                //              //     - an optional "typePath" information if
                //              the default resolved type is not the one that we
                //              want to use
                //              //     - an onViewCreated callback that will be
                //              called when the view will be fully created
                //              [
                //                // Create a string tweaker for the text
                //                property { name: 'text', typePath:
                //                'enumString', semantics: {possibleValues: []},
                //                event: 'change' },
                //                // Create a string tweaker with color
                //                representation for the background-color
                //                property
                ////                  { name: 'bgColor', typePath: 'color',
                ///event: 'liveChange' }, /                  // Create a number
                ///tweaker with integer representation for the width property /
                ///{ name: 'width', typePath: 'integer', event: 'change' }, /
                ///// Create an integer tweaker with percentage representation
                ///for the borderRadius property /                  { name:
                ///'borderRadius', typePath: 'percentage', event: 'change' }, /
                ///// Create a boolean tweaker to display shadow or not /
                ///{ name: 'displayShadow', typePath: '', event: 'change' }, /
                ///// Create a string tweaker with fontSize representation to
                ///select the fontSize property /                  { name:
                ///'fontSize', typePath: 'fontSize', event: 'change' }, /
                ///// Create a string tweaker with horizontalAlignment
                ///representation to represent the horizontalAlignment property
                ////                  { name: 'horizontalAlign', typePath:
                ///'horizontalAlignment', event: 'change' }
                //
                //              ].forEach(function (v) {
                //                  myForm.generateView(
                //                  elements.contentPane[v.name],  // the input
                //                  data to represent
                //                  {
                //                    typePath: v.typePath,  // typePath is used
                //                    to specify an alternative type
                //                    representation to override the default one
                //                    // onViewCreated callback will be called
                //                    when the view will be fully created
                //                    onViewCreated: function (createdView) {
                //                      if (createdView !== undefined) {
                //                        // In this sample, when the view is
                //                        built, we inject it in the customizer
                //                        table
                //                        createdView.inject(document.querySelector("#"
                //                        + v.name));
                //                        // And we add a listener on the
                //                        "change" or "liveChange" event to
                //                        update the demoControl property
                //                        createdView.addEventListener(v.event,
                //                        function (e) {
                //                          elements.contentPane[v.name] =
                //                          e.dsModel.value;
                //                        });
                //                      }
                //                    }
                //                  }
                //                );
                //              });
                //            };

                var formulationForm = new Form({
                    className: 'horizontal',
                    fields: [
                        {
                            type: 'select',
                            name: 'priority',
                            label: ' Priority',
                            options: priorityOptions,
                            events: {
                                onChange: function(event) {
                                    worker.evaluate(
                                        'setPriority',
                                        [
                                            {
                                                parameterID: rowData.id,
                                                priorityValue:
                                                    event.target.value
                                            }
                                        ],
                                        requirementsChangeCallback
                                    );
                                }
                            },
                            className: 'ra-formulationEditor-priority'
                        },
                        {
                            type: 'text',
                            name: 'upper',
                            label: 'Upper Threshold',
                            value:
                                typeof upperThreshold !== 'undefined'
                                    ? upperThreshold
                                    : '',
                            // TODO: implement upper threshold value
                            events: {
                                onChange: function(event) {
                                    // TODO: debounce this ...
                                    worker.evaluate(
                                        'setConstraint',
                                        [
                                            {
                                                parameterID: rowData.id,
                                                boundValue: event.target.value,
                                                type: 'LESS_THAN'
                                            }
                                        ],
                                        requirementsChangeCallback
                                    );
                                }
                            },
                            className: 'ra-formulationEditor-upper'
                        },
                        {
                            type: 'text',
                            name: 'lower',
                            label: 'Lower Threshold',
                            value:
                                typeof lowerThreshold !== 'undefined'
                                    ? lowerThreshold
                                    : '',
                            // TODO: implement lower threshold value
                            events: {
                                onChange: function(event) {
                                    // TODO: debounce this ...
                                    // TODO: implement constraint change on
                                    // worker
                                    worker.evaluate(
                                        'setConstraint',
                                        [
                                            {
                                                parameterID: rowData.id,
                                                boundValue: event.target.value,
                                                type: 'GREATER_THAN'
                                            }
                                        ],
                                        requirementsChangeCallback
                                    );
                                }
                            },
                            className: 'ra-formulationEditor-lower'
                        },
                        {
                            type: 'select',
                            name: 'objective',
                            label: 'Objective',
                            options: objectiveOptions,
                            events: {
                                onChange: function(event) {
                                    if (worker) {
                                        objective.type = event.target.value;
                                        // FIXME: shouldn't have to search the
                                        // whole document
                                        var targetValueField = document.querySelector(
                                            '.ra-formulationEditor-target'
                                        );
                                        if (targetValueField) {
                                            if (objective.type !== 'TARGET') {
                                                targetValueField.disabled =
                                                    'disabled';
                                            } else {
                                                targetValueField.disabled = false;
                                            }
                                        }
                                        // TODO: handle target objectives
                                        worker.evaluate(
                                            'setObjective',
                                            [objective],
                                            requirementsChangeCallback
                                        ); // TODO:
                                        // resize
                                        // forces
                                        // a
                                        // refresh
                                        // on
                                        // the
                                        // table,
                                        // maybe
                                        // just
                                        // write
                                        // a
                                        // refresh
                                        // function
                                        // that
                                        // skips
                                        // resizine
                                        // everything
                                    }
                                }
                            },
                            className: 'ra-formulationEditor-objective'
                        },
                        {
                            type: 'text',
                            name: 'target',
                            label: 'Target',
                            value: targetValue,
                            // TODO: implement lower threshold value
                            events: {
                                onChange: function(event) {
                                    // TODO: debounce this ...
                                    objective.value = event.target.value;
                                    // TODO: handle target objectives
                                    worker.evaluate(
                                        'setObjective',
                                        [objective],
                                        requirementsChangeCallback
                                    ); // TODO:
                                    // resize
                                    // forces a
                                    // refresh
                                    // on the
                                    // table,
                                    // maybe
                                    // just
                                    // write a
                                    // refresh
                                    // function
                                    // that
                                    // skips
                                    // resizine
                                    // everything
                                }
                            },
                            className: 'ra-formulationEditor-target'
                        }
                    ],
                    placeholder: 'Priority'
                });
                return formulationForm;
                //          this.formulationModal.setBody(formulationForm);
                //          this.formulationModal.show();
            },

            // creates UI for merging requirements objects attached to the case
            // to RAE parameters
            createRequirementsMergeUI: function() {},

            setupRequirementsForCase: function(caseId, callbackFunction) {
                var newRequirementsData = {
                    rowHierarchy: [],
                    columnData: [],
                    metaData: { numRows: 0, numAlternatives: 0 }
                };
                WidgetProxy.getConnectedRequirementsList(caseId).then(
                    function(data) {
                        var requirements = null;
                        if (data) {
                            requirements =
                                data.requirementsList ||
                                data['analytics-requirement'];
                        }
                        if (
                            typeof requirements !== 'undefined' &&
                            requirements !== null
                        ) {
                            var paramListString = '';
                            requirements.forEach(function(requirement) {
                                var reqID = requirement.id || '';
                                if (paramListString.length > 0) {
                                    paramListString += ';';
                                }
                                if (reqID.length > 0) {
                                    paramListString += reqID;
                                }
                            });
                            WidgetProxy.setRequirementsList(requirements);
                            WidgetProxy.getParametersList(
                                paramListString
                            ).done(function(reqData) {
                                //                      _self.requirements =
                                //                      reqData;
                                var requirementsList =
                                    reqData.requirementsList ||
                                    reqData['analytics-requirement'] ||
                                    [];
                                requirementsList.forEach(function(
                                    requirementsObject
                                ) {
                                    var reqObj = {};
                                    reqObj.type = 'GROUP';
                                    reqObj.id = requirementsObject.id;
                                    reqObj.name = requirementsObject.name;
                                    reqObj.title = requirementsObject.title;
                                    reqObj.children = [];

                                    var paramList =
                                        typeof requirementsObject.parametersList !==
                                        'undefined'
                                            ? requirementsObject.parametersList.
                                                  parameterList ||
                                              requirementsObject.parametersList[
                                                  'analytics-parameter'
                                              ] ||
                                              []
                                            : [];
                                    newRequirementsData.metaData.numRows +=
                                        paramList.length;
                                    reqObj.children = _self.hierarchyparsefunction(
                                        paramList
                                    );
                                    //                          paramList.forEach(function(param){
                                    //                              var
                                    //                              reqParam
                                    //                              = param;
                                    //                              // we
                                    //                              may not
                                    //                              want to
                                    //                              send all
                                    //                              of the
                                    //                              data
                                    //                              attached
                                    //                              to the
                                    //                              param
                                    //                              reqObj.children.push(this.hierarchyparsefunction(reqParams));
                                    //                          },this);
                                    // add the built requiements object to
                                    // the rowHierarchy

                                    newRequirementsData.rowHierarchy.push(
                                        reqObj
                                    );
                                });
                                // below empties the object
                                WidgetProxy.setRequirementsData(
                                    newRequirementsData
                                );

                                // automerge requirements is currently
                                // disabled (code incomplete and commented
                                // out on worker)
                                //                      worker.evaluate('autoMergeRequirements',[newRequirementsData],callbackFunction);

                                if (typeof callbackFunction === 'function') {
                                    callbackFunction(newRequirementsData);
                                }
                            }, this);
                        } else {
                            // no requirements, make the callback
                            if (typeof callbackFunction === 'function') {
                                callbackFunction();
                            }
                        }
                    },
                    function(err) {
                        console.error('Problem retrieving requirements', err);
                        if (typeof callbackFunction === 'function') {
                            callbackFunction();
                        }
                    }
                );
            },
            hierarchyparsefunction: function(reqParams) {
                var paramList = [];
                reqParams.forEach(function(reqParam) {
                    // var indexInRows = _rows.indexOf(row.id);
                    var _param = {
                        id: reqParam.id,
                        name: reqParam.title, // use the title instead of the name ...
                        type: reqParam.type,
                        min: reqParam.minimum,
                        max: reqParam.maximum,
                        objective: reqParam.objective,
                        parameterValue: reqParam.parameterValue,
                        physicalId: reqParam.physicalId,
                        priority: reqParam.priority,
                        unit: reqParam.unit
                    };
                    paramList.push(_param);
                }, this);
                return paramList;
            }
        });

        return RequirementsUtils;
    }
);

//=========================================================================
/**
 * SMAAnalyticsLiteAttribPLMParamUtils
 * Handles download of Simulation Attributes, Simulation Attribute
 * Groups and PLM Parameters from the server into RAE.
 */
//=========================================================================
define(
    'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteAttribPLMParamUtils',
    [
        'UWA/Core',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'
    ],
    function(Core, Class, Promise, WidgetProxy, NLSUtils) {
        'use strict';

        var _self,
            ServerParamsUtils = Class.extend({
                //=========================================================================
                /**
             * This is the list of PLM object types that can contain attribute
             * groups. Type 'Simulation Job' cannot directly have a attrib group
             * attached to it but its parent process can have it. So adding job
             * to this list.
             */
                //=========================================================================
                _group_from_types_: [
                    'SIMULATIONS',
                    'Simulation Document',
                    'Simulation Template',
                    'Analytics Case',
                    'Simulation',
                    'Simulation Activity',
                    'Simflow',
                    'Simflow Model',
                    'Simflow Component',
                    'Simflow Result',
                    'Simulation Document - Versioned',
                    'Simulation Document - NonVersioned',
                    'Simulation Job',
                    'DesignSight',
                    'VPMReference',
                    'Test Execution'
                ],

                //=========================================================================
                /**
             * Initialize the instance of this class
             */
                //=========================================================================
                init: function(args) {
                    _self = this;
                },

                //=========================================================================
                /**
             * Check if an attribute group can be connected to this object type
             */
                //=========================================================================
                canHaveAttributesAndPLMParams: function(type) {
                    return _self._group_from_types_.indexOf(type) > -1;
                },

                //=========================================================================
                /**
             *
             */
                //=========================================================================
                extractAttributes: function(datasetIds) {
                    return WidgetProxy.getSimulationAttributes(datasetIds);
                },

                //=========================================================================
                /**
             *
             */
                //=========================================================================
                extractAttributeGroups: function(datasetIds) {
                    return new Promise(function(resolve, reject) {});
                },

                //=========================================================================
                /**
             *
             */
                //=========================================================================
                buildAttribHierarchy: function(rawData) {
                    return new Promise(function(resolve, reject) {});
                },

                //=========================================================================
                /**
             * Returns a promise that resolves to return a tree of attributes
             * and group
             *
             * Sample dataset :{date:"7/6/2016 3:36:39 PM"
             *                  description:"Simulation Process imported as New"
             *                  id:"31040.48859.4864.54720"
             *                  name:"testywwDOE3DXUtilitiesafter6_-_Job-171467832597260"
             *                  owner:"g6h"
             *                  physicalId:"44319B561627000015597D57B9180400"
             *                  title:"test_ywwDOE_3DXUtilities-after-6-2016.Jul.06
             * 15:16:38" type:"Simulation Job"}
             */
                //=========================================================================
                extractAttribsNAttribGrps: function(datasets) {
                    return new Promise(function(resolve, reject) {
                        if (
                            typeof datasets === 'undefined' ||
                            !Array.isArray(datasets)
                        ) {
                            reject('No datasets found.');
                        }

                        var datasetIds = datasets.
                            filter(function(ds) {
                                return _self.canHaveAttributesAndPLMParams(
                                    ds.type
                                );
                            }).
                            map(function(ds) {
                                return ds.physicalId;
                            });
                        if (datasetIds.length === 0) {
                            reject(
                                'No datasets that could be used for extracting attributes or plm parameters were found.'
                            );
                            return;
                        }

                        WidgetProxy.getAttributeAndPLMDataForObjects(
                            datasetIds
                        ).then(
                            function(response) {
                                resolve(response);
                            },
                            function(err) {
                                reject();
                            }
                        );
                    });
                }
            });

        return ServerParamsUtils;
    }
);

//=========================================================================
/**
 * SMAAnalyticsLiteCaseDataDownloadOps
 * Handles all file data download required for building the case in
 * RA Essentials
 */
//=========================================================================
define(
    'DS/SMAAnalyticsLiteWidget/utils/AdviseLiteDownloadOps',
    [
        'UWA/Core',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteAttribPLMParamUtils',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'
    ],
    function(Core, Class, Promise, WidgetProxy, SrvrParamOps, NLSUtils) {
        'use strict';

        var _self;
        var DownloadOps = Class.extend({
            //=========================================================================
            /**
                   * Initialize the instance of this class.
                   */
            //=========================================================================
            init: function(args) {
                _self = this;
                _self._mcsURL = args.mcsURL || '';
                _self._caseID = args.caseID || '';
                _self.serverParamOps = new SrvrParamOps({});
                _self.caseDetails= {
                    savedCase: false,
                    hasSO: false,
                    plmBatchExecuted: false,
                    savedSOCase: false
                };
                _self.attachedFilesObject= {};
                _self.caseData= {
                    formulation: {},
                    parameterHierarchy: {},
                    rowDescriptors: {},
                    basket: {},
                    recommendedData: {}
                };
                _self.caseFileData= {};
                _self.simObjects= [];
                _self.datasets= [];
            },

            //=========================================================================
            /**
                   * Get details on what data should be expected from the client
                   */
            //=========================================================================
            getCaseDataDownloadFlags: function() {
                return _self.caseDetails;
            },

            //=========================================================================
            /**
                   * Checks a list to see the list has an entry resembling the
                   * provided name
                   */
            //=========================================================================
            hasInList: function(name, list) {
                if (!list.length > 0) {
                    return false;
                }
                return (
                    list.filter(function(x) {
                        return x.indexOf(name) > -1;
                    }).length > 0
                );
            },

            //=========================================================================
            /**
                   * Get a list of all datasets including Simulation Objects
                   */
            //=========================================================================
            indexDatasets: function() {
                return new Promise(function(resolve, reject) {
                    WidgetProxy.getConnectedDatasets(_self._caseID).then(
                        function(response) {
                            WidgetProxy.storeDataSetsList(response);

                            (_self.simObjects = WidgetProxy.getSimulationObjectsConnectedToCase()),
                                (_self.datasets = WidgetProxy.getDataSetsList());

                            resolve();
                        },
                        function(err) {
                            reject();
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   * Returns a promise that resolves to inform what sort of data
                   * is available for download.
                   * @Return
                   * {'savedCase':false,'hasSO':false,'plmBatchExecuted': false,
                   *  'savedSOCase':false};
                   */
            //=========================================================================
            getDownloadInfo: function() {
                return new Promise(function(resolve, reject) {
                    if (_self._caseID.length === 0) {
                        reject();
                    }

                    _self.indexDatasets().then(
                        function() {
                            WidgetProxy.getAttachedFilesForCase(
                                _self._caseID
                            ).then(
                                function(attchd) {
                                    _self.attachedFilesObject = attchd;
                                    attchd = Object.keys(attchd);

                                    if (attchd.length > 0) {
                                        _self.caseDetails.savedCase = _self.hasInList(
                                            'parameterHierarchy',
                                            attchd
                                        );
                                    }

                                    if (_self.simObjects.length > 0) {
                                        _self.caseDetails.hasSO = true;
                                    }

                                    if (
                                        _self.hasInList('PLMBatchDump', attchd)
                                    ) {
                                        _self.caseDetails.plmBatchExecuted = true;
                                    }

                                    if (
                                        _self.caseDetails.savedCase === true &&
                                        _self.caseDetails.plmBatchExecuted ===
                                            true
                                    ) {
                                        _self.caseDetails.savedSOCase = true;
                                    }

                                    resolve(_self.caseDetails);
                                },
                                function(err) {
                                    reject();
                                }
                            );
                        },
                        function() {
                            reject();
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   * To download just the case data including the raw(basket)
                   * data, formulation, row dsescriptors and hierarchy
                   */
            //=========================================================================
            downloadCaseData: function(caseID) {
                var _this = this,
                    deferred = Promise.deferred();

                WidgetProxy.checkoutEssentialsData(caseID).then(
                    function(ticketWrapper) {
                        // Returns a zip file as blob
                        WidgetProxy.downloadFile({
                            ticket: encodeURIComponent(
                                ticketWrapper.exportString
                            ),
                            fileExtension: 'zip',
                            url: ticketWrapper.actionURL
                        }).then(
                            function(data) {
                                // Convert the blob to url
                                var blobURL = WidgetProxy.convertBlobToURL(
                                    data
                                );

                                // Convert blob url to zipJS object
                                WidgetProxy.importBlobURLToZip(blobURL).then(
                                    function(extractedData) {
                                        // Destroy the url
                                        window.URL.revokeObjectURL(blobURL);

                                        if (
                                            WidgetProxy.isNotEmpty(
                                                extractedData
                                            )
                                        ) {
                                            var files =
                                                    extractedData.root.children,
                                                zipPromises = [],
                                                caseData = {};

                                            files.forEach(function(file) {
                                                var nameSplit = file.name.split(
                                                        '.'
                                                    ),
                                                    key = nameSplit[0],
                                                    extension = nameSplit[1];

                                                // Import all the
                                                // unzipped file
                                                // objects to blob
                                                zipPromises.push(
                                                    WidgetProxy.importZipFileEntryToBlob(
                                                        {
                                                            fileName: key,
                                                            fileExtension: extension,
                                                            zipFileEntry: file
                                                        }
                                                    )
                                                );
                                            });

                                            // Store the
                                            // individual files in
                                            // case data object
                                            if (zipPromises.length > 0) {
                                                Promise.all(zipPromises).then(
                                                    function(data) {
                                                        data.forEach(function(
                                                            entry
                                                        ) {
                                                            // FIXME : the webservice shouldnt return file_data
                                                            if (
                                                                entry.name !==
                                                                'file_data'
                                                            ) {
                                                                caseData[
                                                                    entry.name
                                                                ] =
                                                                    entry.blob;
                                                            }
                                                        });
                                                        deferred.resolve(
                                                            caseData
                                                        );
                                                    },
                                                    function(err) {
                                                        deferred.reject(err);
                                                    }
                                                );
                                            } else {
                                                deferred.reject();
                                            }
                                        } else {
                                            deferred.reject();
                                        }
                                    },
                                    function(err) {
                                        deferred.reject(err);
                                    }
                                );
                            },
                            function(err) {
                                deferred.reject();
                            }
                        );
                    },
                    function(err) {
                        deferred.reject();
                    }
                );

                return deferred.promise;
            },

            //=========================================================================
            /**
                   * To download all the file_data archives
                   */
            //=========================================================================
            downloadCaseFileData: function(caseID) {
                var _this = this,
                    deferred = Promise.deferred(),
                    fDPromises = [];

                WidgetProxy.checkoutEssentialsFileData(caseID).then(
                    function(data) {
                        if (
                            typeof data.files !== 'undefined' &&
                            data.files !== null
                        ) {
                            data.files.forEach(function(tWrp) {
                                fDPromises.push(
                                    WidgetProxy.downloadFile({
                                        ticket: encodeURIComponent(
                                            tWrp.exportString
                                        ),
                                        fileExtension: 'zip',
                                        url: tWrp.actionUrl
                                    })
                                );
                            });

                            if (fDPromises.length > 0) {
                                var unzipPromises = [];

                                Promise.all(fDPromises).then(
                                    function(data) {
                                        var blobUrls = [];
                                        data.forEach(function(blob) {
                                            // Data here is an
                                            // array of blobs

                                            unzipPromises.push(
                                                WidgetProxy.unZipArchiveAsBlob(
                                                    blob
                                                )
                                            );
                                            // unzipPromises.push(WidgetProxy.unzip(blob));

                                            Promise.all(
                                                unzipPromises
                                            ).then(function(data) {
                                                widget.raeFileIndex =
                                                    WidgetProxy.fileDataIndex;
                                                delete WidgetProxy.fileDataIndex;
                                                WidgetProxy.fileDataIndex = {};
                                                deferred.resolve();
                                            });
                                        });
                                    },
                                    function() {
                                        deferred.resolve();
                                    }
                                );
                            }
                        } else {
                            deferred.resolve();
                        }
                    },
                    function() {
                        deferred.resolve();
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
                   * Triggers download of all the necessary case files from a
                   * previously saved case.
                   */
            //=========================================================================
            downloadAllRAEData: function(caseID) {
                var _this = this,
                    promiseArray = [],
                    deferred = Promise.deferred();

                promiseArray.push(_this.downloadCaseData(caseID));
                promiseArray.push(
                    _self.serverParamOps.extractAttribsNAttribGrps(
                        WidgetProxy.datasets
                    )
                );
                promiseArray.push(_this.downloadCaseFileData(caseID));

                Promise.all(promiseArray).then(
                    function(data) {
                        // The data is an array of responses from the
                        // download case data and the download case
                        // file data promise. We have already handled
                        // the case file data. So just using the case
                        // data here
                        deferred.resolve(data);
                    },
                    function(err) {
                        console.error(
                            'Error downloading existing Analytics case data from FCS.'
                        );
                        deferred.reject(err);
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
                   * Download the images extracted from the PLM batch.
                   */
            //=========================================================================
            downloadPLMFileDataDump: function() {
                return new Promise(function(resolve, reject) {
                    WidgetProxy.getTicketAndDownloadFile(
                        _self._caseID,
                        'plmbatch_filedata.zip',
                        'generic'
                    ).then(
                        function(blob) {
                            WidgetProxy.fileDataIndex = {};
                            WidgetProxy.unZipArchiveAsBlob(blob).then(
                                function(data) {
                                    var kweFileIndex =
                                        WidgetProxy.fileDataIndex;
                                    delete WidgetProxy.fileDataIndex;
                                    resolve(kweFileIndex);
                                },
                                function() {
                                    resolve(null);
                                }
                            );
                        },
                        function() {
                            resolve(null);
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   * Download the results of a PLM Batch execution.
                   * FIXME: Handle images returned by the PLM batch
                   */
            //=========================================================================
            downloadPLMDataDump: function() {
                return new Promise(function(resolve, reject) {
                    var attachd = Object.keys(_self.attachedFilesObject),
                        fNames = '',
                        fTypes = '',
                        plmAttachd = attachd.filter(function(x) {
                            return x.indexOf('PLMBatchDump_') === 0;
                        });

                    plmAttachd.forEach(function(x) {
                        if (fNames.length > 0) {
                            fNames += ';';
                        }
                        if (fTypes.length > 0) {
                            fTypes += ';';
                        }
                        fNames += x;
                        fTypes += _self.attachedFilesObject[x];
                    });

                    if (plmAttachd.length === 1) {
                        WidgetProxy.getTicketAndDownloadFile(
                            _self._caseID,
                            fNames,
                            fTypes
                        ).then(
                            function(blob) {
                                var blobList = [],
                                    obj = {};
                                obj[plmAttachd[0]] = blob;
                                blobList.push(obj);
                                resolve(blobList);
                            },
                            function(err) {
                                reject(err);
                            }
                        );
                    } else {
                        WidgetProxy.getDownloadTicketForFiles(
                            _self._caseID,
                            fNames,
                            fTypes,
                            'plmDataDump.zip'
                        ).then(
                            function(ticketWrapper) {
                                WidgetProxy.downloadFile({
                                    ticket: encodeURIComponent(
                                        ticketWrapper.exportString
                                    ),
                                    fileExtension: 'zip',
                                    url: ticketWrapper.actionURL
                                }).then(
                                    function(data) {
                                        var blobURL = WidgetProxy.convertBlobToURL(
                                                data
                                            ),
                                            blobList = [];

                                        WidgetProxy.importBlobURLToZip(
                                            blobURL
                                        ).then(
                                            function(extractedData) {
                                                window.URL.revokeObjectURL(
                                                    blobURL
                                                );
                                                if (
                                                    WidgetProxy.isNotEmpty(
                                                        extractedData
                                                    )
                                                ) {
                                                    var files =
                                                            extractedData.root.
                                                                children,
                                                        zipPromises = [];

                                                    files.forEach(function(
                                                        file
                                                    ) {
                                                        var nameSplit = file.name.split(
                                                                '.'
                                                            ),
                                                            key = nameSplit[0],
                                                            extension =
                                                                nameSplit[1];

                                                        zipPromises.push(
                                                            WidgetProxy.importZipFileEntryToBlob(
                                                                {
                                                                    fileName: key,
                                                                    fileExtension: extension,
                                                                    zipFileEntry: file
                                                                }
                                                            )
                                                        );
                                                    });
                                                    if (
                                                        zipPromises.length > 0
                                                    ) {
                                                        Promise.all(
                                                            zipPromises
                                                        ).then(
                                                            function(data) {
                                                                data.forEach(
                                                                    function(
                                                                        entry
                                                                    ) {
                                                                        var obj = {};
                                                                        obj[
                                                                            entry.name
                                                                        ] =
                                                                            entry.blob;
                                                                        blobList.push(
                                                                            obj
                                                                        );
                                                                    }
                                                                );
                                                                resolve(
                                                                    blobList
                                                                );
                                                            },
                                                            function(err) {
                                                                reject(err);
                                                            }
                                                        );
                                                    }
                                                }
                                            },
                                            function(err) {
                                                reject(err);
                                            }
                                        );
                                    },
                                    function(err) {
                                        reject();
                                    }
                                );
                            },
                            function(err) {
                                reject();
                            }
                        );
                    }
                });
            },

            //=========================================================================
            /**
                   * Read the downloaded data dump from a previously executed
                   * CATSimBatch, set it to the worker, to be converted to
                   * meaningful case data
                   */
            //=========================================================================
            loadSavedPLMDataToWorker: function(kweData) {
                return new Promise(function(resolve, reject) {
                    Promise.all(
                        kweData.map(function(node) {
                            return WidgetProxy.blobReader(
                                node[Object.keys(node)[0]],
                                true
                            );
                        })
                    ).then(
                        function(output) {
                            window.worker.evaluate(
                                'setKWEData',
                                output,
                                function() {
                                    resolve(output);
                                }
                            );
                        },
                        function(err) {
                            reject();
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   * Read the blobs returned by the case data download call to
                   * MCS
                   */
            //=========================================================================
            readBlob: function(_key, blob) {
                return new Promise(function(resolve, reject) {
                    try {
                        var reader = new FileReader();

                        reader.addEventListener('loadend', function() {
                            var modResultString = '',
                                modResult = '';

                            if (
                                _key === 'basketData' ||
                                _key === 'recommendedData' ||
                                _key === 'rawData'
                            ) {
                                modResultString = this.result.
                                    split('NaN').
                                    join('null');
                                modResult = modResultString;
                            } else {
                                // FIXME : remove file_data from the
                                // casedata object in eno WS
                                if (_key !== 'file_data') {
                                    try {
                                        modResultString = this.result.
                                            split('NaN').
                                            join('null');
                                        modResult = JSON.parse(modResultString);
                                    } catch (e) {
                                        console.error(
                                            'Error parsing JSON string for' +
                                                _key,
                                            e
                                        );
                                        reject();
                                    }
                                }
                            }
                            window.worker.evaluate(
                                'setCaseData',
                                [_key, modResult],
                                function() {
                                    resolve();
                                }
                            );
                        });
                        reader.readAsText(blob);
                    } catch (ex) {
                        console.error(
                            'Error loading ' + _key + 'to the worker.',
                            e
                        );
                        reject();
                    }
                });
            },

            //=========================================================================
            /**
                   * Load blobs retuned by the 'readBlob' function to the worker
                   */
            //=========================================================================
            loadBlobToWorker: function(caseData, key) {
                return new Promise(function(resolve, reject) {
                    if (caseData.hasOwnProperty(key)) {
                        _self.readBlob(key, caseData[key]).then(function() {
                            // remove the blob from caseData as we're
                            // done with it
                            delete caseData[key];
                            resolve();
                        });
                    } else {
                        reject();
                    }
                });
            },

            //=========================================================================
            /**
                   * Load the data retrieved from a previously saved case to the
                   * worker.
                   */
            //=========================================================================
            loadSavedCaseDataToWorker: function(caseData) {
                return new Promise(function(resolve, reject) {
                    // Load the data in the order of their necessity in
                    // the worker.
                    var rDataPromises = []; // Any remaining data

                    _self.
                        loadBlobToWorker(caseData, 'parameterHierarchy').
                        then(function() {
                            _self.
                                loadBlobToWorker(caseData, 'rowDescriptors').
                                then(function() {
                                    _self.
                                        loadBlobToWorker(
                                            caseData,
                                            'formulation'
                                        ).
                                        then(function() {
                                            for (var rKey in caseData) {
                                                rDataPromises.push(
                                                    _self.loadBlobToWorker(
                                                        caseData,
                                                        rKey
                                                    )
                                                );
                                            }
                                            Promise.all(rDataPromises).then(
                                                resolve,
                                                reject
                                            );
                                        });
                                });
                        });
                });
            },

            //=========================================================================
            /**
                   * FIXME : Code to figure out if there are any datasets, like
                   * TSVs or CSVs that can be processed on the client side -
                   * Here
                   */
            //=========================================================================
            getDatasetsEligibleForClientSideProcessing: function(datasets) {
                return [];
            },

            //=========================================================================
            /**
                   * @param: datasets - Array of datasets connected to the case
                   * @param caseDldFlags - Case data download flags (Output of
                   * getCaseDataDownloadFlags). Denotes what sort of case data
                   * is available for download.
                   *
                   * Sets the flags which denotes how to extract the data for
                   * this case. CATSIMBATCH -  Needs a catsimbatch to extract
                   * the KWE data PLMPARAMETERS - Extract attributes and plm
                   * parameters from 3DSpace ADVISESERVANT - Start a RA servant
                   * to extract data from datasets. CLIENTSIDEPROCESSING - For
                   * datasets that can be read in the JS client
                   */
            //=========================================================================
            getDatasetsProcessingType: function(datasets, caseDldFlags) {
                var needServant = false,
                    needPLMBatch = false,
                    getParamsFromMCS = true,
                    cSideProcessing = false,
                    simObjs =
                        WidgetProxy.getSimulationObjectsConnectedToCase() || [];

                datasets =
                    datasets && datasets.length > 0
                        ? datasets
                        : WidgetProxy.datasets;
                caseDldFlags = caseDldFlags || {};

                if (
                    caseDldFlags.savedCase !== true &&
                    caseDldFlags.plmBatchExecuted !== true
                ) {
                    needServant = true;
                    getParamsFromMCS = true;
                }

                if (datasets.length > 0) {
                    if (simObjs.length === datasets.length) {
                        needServant = false;
                        needPLMBatch = true;
                    } else if (
                        simObjs.length > 0 &&
                        simObjs.length !== datasets.length
                    ) {
                        needServant = true;
                        needPLMBatch = true;
                    }

                    var cSideDatasets = this.getDatasetsEligibleForClientSideProcessing(
                        datasets
                    );
                    if (cSideDatasets.length > 0) {
                        cSideProcessing = true;
                    }
                }

                return {
                    CATSIMBATCH: needPLMBatch ? 1 : 0,
                    PLMPARAMETERS: getParamsFromMCS ? 1 : 0,
                    ADVISESERVANT: needServant ? 1 : 0,
                    CLIENTSIDEPROCESSING: cSideProcessing ? 1 : 0
                };
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            htmlUnescape: function(value) {
                return String(value).
                    replace(/&quot;/g, '"').
                    replace(/&#39;/g, "'").
                    replace(/&lt;/g, '<').
                    replace(/&gt;/g, '>').
                    replace(/&amp;/g, '&');
            },

            //=========================================================================
            /**
                   * Creates a Advise servant in the available station and
                   * returns the corresponding job id
                   */
            //=========================================================================
            createAdvServantJob: function(caseID, datasets) {
                var _this = this;
                return new Promise(function(resolve, reject) {
                    var runner = new SPRun(),
                        _this = this,
                        mcsURL = WidgetProxy.get3DSpaceURL(),
                        eedURL = WidgetProxy.getEEDURL(),
                        eedJobID = '';

                    WidgetProxy.getCaseLaunchInfo(caseID).then(
                        function(data) {
                            var station = widget.getValue('stations') || '';
                            if (station.length > 0) {
                                data.affinity = station;
                            }

                            var eXML = _this.createEXML(data, caseID),
                                appDataXML = unescape(
                                    encodeURIComponent(
                                        _this.htmlUnescape(data.encodedJobXML)
                                    )
                                );

                            runner.mcsURL = mcsURL;
                            runner.simOID = caseID;
                            runner.timeout = 20000;
                            runner.runURL = eedURL + '/execution/run';
                            runner.cosPubkeyURL = eedURL + '/execution/pubkey';
                            runner.encryptURL =
                                mcsURL +
                                '/resources/slmservices/data/getEncryptedCreds?SecurityContext=' +
                                WidgetProxy.getActiveCollabSpace();
                            runner.mcsTicketURL =
                                mcsURL +
                                '/ticket/get?SecurityContext=' +
                                WidgetProxy.getActiveCollabSpace();
                            runner.runInfo =
                                "<RunInfo logLevel='Debug' submissionHost=''></RunInfo>";
                            runner.ApplicationData = appDataXML;

                            runner.addEventListener('success', function(e) {
                                resolve(e.detail.result.EEDJobID);
                            });

                            runner.addEventListener('error', function(e) {
                                reject();
                            });
                            runner.runEXML(
                                {},
                                eXML,
                                caseID,
                                data.eedTicket,
                                false,
                                appDataXML,
                                false
                            );
                        },
                        function(err) {
                            reject();
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            createEXML: function(data, caseID) {
                var modelxml =
                    '<?xml version="1.0" encoding="utf-8"?>' +
                    '<fiper_Model version="6.216.0" majorFormat="1" timestamp="6/5/14" rootComponentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Properties modelId="6a53ba4c-811e-11e2-ae82-e9ce6b18c519" modelName="AdviseServant" modelVersion="6.216.0" />' +
                    '<Component id="812da46e-811e-11e2-ae82-e9ce6b18c519" name="AdviseServant" type="com.dassault_systemes.smacomponent.adviseservant">';

                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bd27e8af-811e-11e2-ae82-e9ce6b18c519" name="flavor" role="Parameter" structure="Scalar" mode="Input" dispName="host" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value>lite</Value>' +
                    '</Variable>';

                // client
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bb27e8af-811e-11e2-ae82-e9ce6b18c519" name="host" role="Parameter" structure="Scalar" mode="Input" dispName="host" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    window.location.protocol +
                    '//' +
                    window.location.host +
                    ']]></Value>' +
                    '</Variable>';

                // csrf
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bc27e8af-811e-11e2-ae82-e9ce6b18c519" name="token" role="Parameter" structure="Scalar" mode="Input" dispName="token" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    data.eedTicket +
                    ']]></Value>' +
                    '</Variable>';

                var stationPreference = widget.getPreference('stations');

                if (
                    typeof stationPreference !== 'undefined' &&
                    stationPreference.value
                ) {
                    modelxml =
                        modelxml +
                        '<Variable id="812da46e-811e-11e2-ae82-e9ce6b18c519:affinities" name="affinities" role="Property" structure="Aggregate" mode="Local" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                        '<Variable type="com.engineous.datatype.String" typeWrittenVersion="2.0.0" id="812da46e-811e-11e2-ae82-e9ce6b18c519:Host" name="Host" role="Property" structure="Scalar" mode="Local" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519:affinities">' +
                        '<Value><![CDATA[' +
                        stationPreference.value +
                        ']]></Value>' +
                        '</Variable>' +
                        '</Variable>';
                }

                /**
                           * Adding the caseID and MCS url here since sp-run
                           * consumes only the eXML when both eXML and the
                           * app data xml are provided.
                           * So removing dependency on the app data xml for
                           * Essentials.
                           */

                // caseID
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="be27e8af-811e-11e2-ae82-e9ce6b18c519" name="caseId" role="Parameter" structure="Scalar" mode="Input" dispName="caseId" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    caseID +
                    ']]></Value>' +
                    '</Variable>';

                // server url
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bf27e8af-811e-11e2-ae82-e9ce6b18c519" name="serverUrl" role="Parameter" structure="Scalar" mode="Input" dispName="serverUrl" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    data.mcsUrl +
                    ']]></Value>' +
                    '</Variable>';

                modelxml =
                    modelxml +
                    '</Component>' +
                    '<Component id="6a5a22ed-811e-11e2-ae82-e9ce6b18c519" name="Task1" type="com.dassault_systemes.sma.adapter.Task">' +
                    '</Component>' +
                    '</fiper_Model>';

                return modelxml;
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            waitForServantStartup: function(launchDeferred) {
                var _this = this,
                    waitLoop = setInterval(function() {
                        _this.monitorBulletinBoard(waitLoop, launchDeferred);
                    }, 2000);
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            monitorBulletinBoard: function(waitLoop, launchDeferred) {
                var _this = this;

                WidgetProxy.getEEDTicket(_this.caseID).then(
                    function(ticket) {
                        if (WidgetProxy.isNotEmpty(ticket, true)) {
                            WidgetProxy.setEEDTicket(ticket);

                            WidgetProxy.monitorBulletinBoardForTopic(
                                _this.jobID,
                                _this.messageTopic
                            ).then(
                                function(returndata) {
                                    var adviseMessages = returndata.getElementsByTagName(
                                            'Message'
                                        ),
                                        adviseMessage = '';

                                    if (adviseMessages.length > 0) {
                                        adviseMessage =
                                            adviseMessages[0].textContent;
                                    }
                                    console.info(adviseMessage);
                                    if (adviseMessage.length > 4) {
                                        if (
                                            _this.messageTopic ===
                                            'ResultsServantDowloadingFile'
                                        ) {
                                            _this.messageTopic =
                                                'ResultsLiteAdapterComplete';
                                            _this.launchCount = 0;
                                            _this.launchLimit = 900;
                                            _this.jobRunning = true;
                                        } else {
                                            clearInterval(waitLoop);
                                            launchDeferred.resolve(
                                                _this.caseID
                                            );
                                        }
                                    } else {
                                        var messageElem = returndata.getElementsByTagName(
                                                'MonitoringMessages'
                                            )[0],
                                            status = messageElem.getAttribute(
                                                'status'
                                            );

                                        console.info(messageElem);
                                        console.info(status);

                                        if (
                                            status.toLowerCase() === 'running'
                                        ) {
                                            _this.launchCount = 0;
                                            _this.jobRunning = true;
                                        } else if (
                                            status.toLowerCase() === 'done'
                                        ) {
                                            clearInterval(waitLoop);
                                            launchDeferred.reject();
                                        }
                                    }
                                },
                                function(err) {
                                    console.error('Monitoring err: ', err);
                                    launchDeferred.reject();
                                }
                            );
                        }
                    },
                    function(err) {
                        console.error('Ticket error: ', err);
                        launchDeferred.reject();
                    }
                );
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            launchLiteServant: function(caseID, datasets) {
                var _this = this,
                    launchDeferred = Promise.deferred();

                _this.createAdvServantJob.call(_this, caseID, datasets).then(
                    function(jobID) {
                        if (!WidgetProxy.isNotEmpty(jobID)) {
                            launchDeferred.reject();
                        }
                        _this.jobID = jobID;
                        _this.waitForServantStartup.call(_this, launchDeferred);
                    },
                    function(error) {
                        launchDeferred.reject();
                    }
                );
                return launchDeferred.promise;
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            launchAdviseServantForDatasets: function(datasets) {
                var _this = this;
                return new Promise(function(resolve, reject) {
                    _this.
                        launchLiteServant(_self._caseID, datasets).
                        then(function() {
                            var promises = [];
                            promises.push(
                                _this.downloadCaseData(_self._caseID)
                            );
                            promises.push(
                                _this.downloadCaseFileData(_self._caseID)
                            );
                            Promise.all(promises).then(
                                function(data) {
                                    var dataDump = Array.isArray(data)
                                        ? data
                                        : [data];
                                    _this.
                                        loadSavedCaseDataToWorker(dataDump[0]).
                                        then(
                                            function(data) {
                                                resolve(data);
                                            },
                                            function() {
                                                reject();
                                            }
                                        );
                                },
                                function() {
                                    reject();
                                }
                            );
                        });
                });
            },

            //=========================================================================
            /**
                   * Returns a promise which resolves to provide attributes and
                   * PLM parameters connected to the given dataset object.
                   */
            //=========================================================================
            downloadAttributesAndPLMParameters: function(datasets) {
                return new Promise(function(resolve, reject) {
                    _self.serverParamOps.
                        extractAttribsNAttribGrps(datasets).
                        then(
                            function(data) {
                                resolve(data.attributesData || null);
                            },
                            function(err) {
                                console.warn(
                                    'Error retrieving PLM & attributes data. ',
                                    [err]
                                );
                                reject();
                            }
                        );
                });
            },

            //=========================================================================
            /**
                   * Intiate data download for the datasets that are added once
                   * the table has loaded and merge them with existing data.
                   */
            //=========================================================================
            runDownloadForAddedDatasets: function(ndatasets) {
                var downloadedData = {},
                    _this = this;

                return new Promise(function(resolve, reject) {
                    var downloadFlags = _self.getDatasetsProcessingType(
                            ndatasets
                        ),
                        downloadPromises = [],
                        datasets = WidgetProxy.datasets,
                        simobjs = WidgetProxy.getSimulationObjectsConnectedToCase();

                    worker.evaluate(
                        'setDatasets',
                        [datasets, simobjs],
                        function() {
                            if (downloadFlags.CATSIMBATCH === 1) {
                                WidgetProxy.setKWEMergeUIFlag(true);
                            }

                            downloadPromises.push(
                                this.downloadAttributesAndPLMParameters(
                                    ndatasets
                                )
                            );

                            if (downloadFlags.ADVISESERVANT === 1) {
                                // Still under development
                                // downloadPromises.push(this.launchAdviseServantForDatasets(datasets));
                            }

                            if (downloadFlags.CLIENTSIDEPROCESSING === 1) {
                                // downloadPromises.push(.....);
                            }

                            Promise.all(downloadPromises).then(
                                function(data) {
                                    var downloadedData = {
                                        ATTRIB_PLM_DATA: null,
                                        CSIDE_DATA: null,
                                        isSavedCase:_this.caseDetails.savedCase
                                    };
                                    if (downloadFlags.PLMPARAMETERS === 1) {
                                        downloadedData.ATTRIB_PLM_DATA =
                                            data[0];
                                    }
                                    if (
                                        downloadFlags.CLIENTSIDEPROCESSING === 1
                                    ) {
                                        downloadedData.CSIDE_DATA = data[1];
                                    }
                                    worker.evaluate(
                                        'setDataFromServer',
                                        [downloadedData],
                                        function() {
                                            resolve();
                                        }
                                    );
                                },
                                function(err) {
                                    console.error(
                                        'Error retrieving data for the case. ',
                                        [err]
                                    );
                                    reject();
                                }
                            );
                        }.bind(_this)
                    );
                });
            },

            //=========================================================================
            /**
                   *
                   */
            //=========================================================================
            setPLMAttribDataToWorker: function(data) {
            	var savedCaseFlag =  _self.caseDetails.savedCase;
                return new Promise(function(resolve, reject) {
                    window.worker.evaluate(
                        'setDataFromServer',
                        [{ ATTRIB_PLM_DATA: data.attributesData, savedCase:savedCaseFlag }],
                        function() {
                            resolve(data);
                        }
                    );
                });
            },

            //=========================================================================
            /**
                   * Trigger download of case data from MCS and set it to the
                   * client side data model in the worker.
                   */
            //=========================================================================
            runDownload: function() {
                return new Promise(function(resolve, reject) {
                    _self.getDownloadInfo().then(
                        function(details) {
                            if (
                                details.savedCase === true ||
                                details.savedSOCase === true
                            ) {
                                _self.downloadAllRAEData(_self._caseID).then(
                                    function(data) {
                                        var dataDump = Array.isArray(data)
                                                ? data
                                                : [data],
                                            plmAttribData = dataDump[1],
                                            savedCaseData = dataDump[0];

                                        _self.
                                            loadSavedCaseDataToWorker(
                                                savedCaseData
                                            ).
                                            then(
                                                function(data) {
                                                    _self.
                                                        setPLMAttribDataToWorker(
                                                            plmAttribData
                                                        ).
                                                        then(
                                                            function(data) {
                                                                resolve(
                                                                    dataDump
                                                                );
                                                            },
                                                            function(err) {
                                                                reject(err);
                                                            }
                                                        );
                                                },
                                                function(err) {
                                                    reject(err);
                                                }
                                            );
                                    },
                                    function(err) {
                                        reject(err);
                                    }
                                );
                            } else if (
                                details.plmBatchExecuted &&
                                !details.savedSOCase
                            ) {
                                WidgetProxy.setKWEMergeUIFlag(true);

                                var kwePromises = [];
                                kwePromises.push(
                                    _self.serverParamOps.extractAttribsNAttribGrps(
                                        WidgetProxy.datasets
                                    )
                                );
                                kwePromises.push(_self.downloadPLMDataDump());
                                kwePromises.push(
                                    _self.downloadPLMFileDataDump()
                                );

                                Promise.all(kwePromises).then(
                                    function(data) {
                                        // FIXME:
                                        // We only load the parameter
                                        // data in the worker The file
                                        // data is stored in the
                                        // widget.kweFileIndex This
                                        // has to be fixed and moved
                                        // to the worker
                                        widget.kweFileIndex = data[2];

                                        var kweParamData = data[1],
                                            plmAttribData = data[0];

                                        _self.
                                            setPLMAttribDataToWorker(
                                                plmAttribData
                                            ).
                                            then(
                                                function(data) {
                                                    _self.
                                                        loadSavedPLMDataToWorker(
                                                            kweParamData
                                                        ).
                                                        then(
                                                            function(data) {
                                                                resolve(data);
                                                            },
                                                            function(err) {
                                                                reject(err);
                                                            }
                                                        );
                                                },
                                                function(err) {
                                                    reject(err);
                                                }
                                            );
                                    },
                                    function(err) {
                                        reject(err);
                                    }
                                );
                            } else {
                                reject();
                            }
                        },
                        function(err) {
                            reject(err);
                        }
                    );
                });
            }
        });

        return DownloadOps;
    }
);

/*
 * TODO: this is a copy of SMAAnalyticsWidget/SMAAnalyticsDNDHelper
 * Move this to a common place and use the same in both places
 * 
 */

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteDNDHelper',
    [
		'UWA/Core',
		'UWA/Class',
		'UWA/Class/Promise',
		'DS/PlatformAPI/PlatformAPI',
		'DS/DataDragAndDrop/DataDragAndDrop',
		'DS/UIKIT/Mask',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsCommon/dialogs/SMAAnalyticsCaseDialog',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils'
    ],
    function(
        Core,
        Class,
        Promise,
        pAPI,
        DND,
        Mask,
        WidgetProxy,
        NLSUtils,
        NLS,
        NewCaseDialog,
        AnalyticsUtils
    ) {
		'use strict';
		/**
		* Class that handles drag and drop events on RA widget
		* Also deals with creating plm objects using the 
		* dropped data 
		* options: {
		* 		dropZone: <element to drop objects on>,
		* 		caseId: <RA Case id to which the objects are to be connected>,
		* 		dragClass: <class to be added to the dropzone during drag>,
         *       dropPromise: <promise that would be returned when drop is
         * done>, model, type: <DATASET, REQUIREMENT, DECISION OBJECT> - Used to
         * determine what type of object is expected to be dropped. Also can be
         *               used to determine which list to be checked in case if
         * we need to check if the dropped object already exists
		*	}
		*/
		var dndHelper = Class.extend({
			dragClass: '',
			caseId: '',
			dropDeferred: null,  //FIXME : why are we not using a callback mechanism ?
			dropZone: null,
			view: null,
			type: '',
			refreshOnDrop: true,
			persistCaseId: true,
			_connectedResponse: null,
            _dsallowed: [
                'Simulation',
                'DesignSight',
                'VPMReference',
                'Test Execution'
            ],
            //          _dsallowed: [ 'Simulation', 'Document', 'Simulation
            //          Document - Versioned', 'Simulation Document -
            //          NonVersioned', 'Simulation Job', 'DesignSight',
            //          'VPMReference' ],
			_extensions: '',
            //                  '.zrf, .nrf, .3dxml, .stp, .stpz, .jpg, .jpeg,
            //                  .png, .gif,' +
            //                  '.tif, .tiff, .bmp, .flv , .avi , .mov , .wmv ,
            //                  .mpg , .mpeg , .mp4 ,' +
            //                  '.m4v , .rm , .webm , .mkv , .mp3 , .wav , .aac
            //                  , .m4a , .wma , .ra , .ogg ,' +
            //                  '.doc , .docx , .ppt , .pptx , .pps , .ppsx ,
            //                  .xls , .xlsx , .xlsm , .pdf ,' +
//					'.zip , .txt , .csv',
			_reqallowed: [ 'Requirement' ],
			_decallowed: [ 'Decision' ],
			
			getConnectedResponse: function(){
				return this._connectedResponse;
			},
			
			getExtension: function(filename) {
                if (!Core.is(filename, 'string')) {
                    return;
                }
                var matches,
                    extension = '';
                matches = filename.match(/\.([^.]+)$/);
                if (matches !== null && matches.length === 2) {
                    extension = matches[1].toLowerCase();
                }
                return extension;
            },
            
			checkExtension: function(filename) {
                return (
                    this._extensions.indexOf(this.getExtension(filename)) !== -1
                );
			},
			
			isValidDSObject: function(type){
				var index = -1;
				var checkAllowedForType = function(_type){
					var _index = -1;
					switch(_type) {
						case 'DATASET':
							_index = this._dsallowed.indexOf(type);
							break;
						case 'REQUIREMENT':
							_index = this._reqallowed.indexOf(type);
							break;
						case 'DECISION':
							_index = this._decallowed.indexOf(type);
							break;
					}
					if(_index > -1){
						index = _index;
						return true;
					}
					return false;
				};
				if(Array.isArray(this.type)){
					this.type.some(checkAllowedForType,this);
				}else{
					checkAllowedForType.call(this,this.type);
				}
				if(index > -1){
					return true;
				} else {
					return false;
				}
			},
			
			maskHandlr: function(show){
				try{
					// this is the viewport
					// the parent node is a scrollable div 
					// and its height is more than that 
					// of the viewport
					var maskArea = widget.body;
					if(show){
						Mask.mask(maskArea);
					} else {
						Mask.unmask(maskArea);
				}
				} catch(ex){}
			},
			
			resolveDropDeferred: function(success){
				if(!this.persistCaseId){
					this.caseId = ''; // reset the caseId as it is no longer needed
				}
				this.maskHandlr(false);
                if (
                    typeof this.dropDeferred !== 'undefined' &&
                    this.dropDeferred !== null
                ) {
					if(success){
						this.dropDeferred.resolve();
					} else {
						this.dropDeferred.reject();
					}
				}
			},
			
			itExists: function(objId) {
				var that = this;
				if(! that.type){
					return false;
				}
				var checkList = [];
				
				var getCheckListForType = function(_type){
					var _checkList = [];
					//var _index = -1;
					switch(_type) {
						case 'DATASET':
                            _checkList = that.view.model
                                ? that.view.model.get('datasetsList')
                                : [];
							break;
						case 'REQUIREMENT':
							// not sure if this is on the model or not
                            _checkList =
                                WidgetProxy.getRequirementsList() || [];
							break;
						case 'DECISIONS':
							// not sure if this is on the model or not
							_checkList = [];
							break;
					}
                    if (
                        typeof _checklist === 'undefined' ||
                        checkList.length === 0
                    ) {
						return false;
					}
					checkList.push.apply(checkList, _checkList);
				};
				if(Array.isArray(this.type)){
					this.type.some(getCheckListForType,this);
				}else{
					getCheckListForType.call(this,this.type);
				}
				
				// it should never be 'undefined'
                if (
                    typeof checklist === 'undefined' ||
                    checkList.length === 0
                ) {
					return false;
				}
				for(var i=0; i<checkList.length; i++){
					if(checkList[i].physicalId === objId){
						return true;
					}
				}
				return false;
			},
			
			checkJobAttach: function(rawData, connObjs){
				var that = this,
					promises = [],
					attachedJobs = {},
					caseOID = that.model ? that.model.id : that.caseId;
				
				attachedJobs[caseOID] = [];
				
				var resolveJobConnect = function(response){
					// the response comes back
					// as an array of connected objects
					// We send in only one job for this request,
					// so getting index [0] should be ok..
					attachedJobs[caseOID].push(response[caseOID][0]);
				};
				
				for(var a=0;a<connObjs.length;a++){
					var thisCO = connObjs[a],
						jobId = '';
					
                    if (thisCO.type === 'Simulation') {
                        if (thisCO.latestJobStatus !== 'Completed') {
                            var lastSuccess = thisCO.latestSuccessfulJob || '';
							// The simulation has atleast one successful job
							
							if(lastSuccess !== ''){
                                var useFailed = confirm(
                                    NLSUtils.translate('LTST_JOB1') +
                                        ' ' +
                                        thisCO.title +
                                        NLSUtils.translate('LTST_JOB2')
                                );
                                jobId = useFailed
                                    ? thisCO.latestJob
                                    : thisCO.latestSuccessfulJob;
                            } else {
                                var ifContinue = confirm(
                                    NLSUtils.translate('LTST_JOB1') +
                                        ' ' +
                                        thisCO.title +
                                        NLSUtils.translate('LTST_JOB3')
                                );
                                jobId = ifContinue ? thisCO.latestJob : '';
							}
							
							if(jobId.length > 0){
								promises.push(
                                    WidgetProxy.connectDatasetsToCase(
                                        caseOID,
                                        jobId
                                    ).then(
                                        function(data) {
											resolveJobConnect(JSON.parse(data));
                                        },
                                        function(err) {
                                            console.error(
                                                'Error attaching job to case.',
                                                err
                                            );
                                        }
                                    )
                                );
							} else {
								// nothing to connect?
								that.resolveDropDeferred(false);
							}
						}
					}
				}
				
				if(promises.length > 0){
					Promise.all(promises).then(function(){
						if(attachedJobs[caseOID].length > 0){
                            // this would be the object that has the combined
                            // list of attached jobs
                            that._connectedResponse = JSON.stringify(
                                attachedJobs
                            );
						}
						that.resolveDropDeferred(true);
					});
				}
			},
			
			connectDatasets: function(dropData, msEvt) {
				console.log('connect');
				
				if(typeof dropData === 'undefined' || dropData === null ){
					this.resolveDropDeferred(false);
					return;
				}
				
				var that = this,
                    droppd = dropData.data
                        ? dropData.data.items ? dropData.data.items : []
                        : [],
					droppdOIDs = '';
				
				droppd.forEach(function(item){
					if(! this.itExists(item.objectId)){
						if(this.isValidDSObject(item.objectType)){
							droppdOIDs += item.objectId + ';';
						} else {
							WidgetProxy.showError(item.displayName + ' ' + NLS.cannot_attach);
						}
					}
				}, this);
				
				if(droppdOIDs.length > 0){
					WidgetProxy.connectDatasetsToCase(
						that.model ? that.model.id : that.caseId,
						droppdOIDs	
					).then(
						function(response){
							var fndSim = false,
								data = JSON.parse(response);
								
							if(data){
								var connObjs = data[that.caseId];
								//VSH3 - 2018x FD02 - No need to attach job for process
									that._connectedResponse = response;
									that.resolveDropDeferred(true, connObjs);
                            } else {
								that.resolveDropDeferred(false);
							}
							if(that.refreshOnDrop){
								widget.dispatchEvent('onRefresh');
							}
						},
						function(err){
                            console.error(
                                'Error connecting the dropped objects to the case.',
                                [err]
                            );
							that.resolveDropDeferred(false);
						}					
					);
                } else {
					that.resolveDropDeferred(false);
				}
			},
			
			createCase: function(dropData, msEvt) {
				console.log('create and connect');
				var that = this;
				
				var getOut = function(resolve) {
					that.resolveDropDeferred(resolve);
				};
				
				var title = '',
					desc = '';

				if(that.view.model){
					title = that.view.model.get('title') || '';
					desc = that.view.model.get('description') || '';
					if(title === 'New Analytics Case'){
						title = '';
					}
				}
				
				NewCaseDialog.showDialog(this.dialogOptions).then(function (response) {
					WidgetProxy.createAnalyticsCaseObject(response.title,response.description).then(function(caseId) {
						that.view.model.set('id', caseId);
                        that.view.model.set('image', WidgetProxy.get3DSpaceURL() +
                                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
                        that.view.model.set('recommendedImage', WidgetProxy.get3DSpaceURL() +
                                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
                        that.view.model.set('project', WidgetProxy.setActiveCollabSpace());
						that.caseId = caseId;
						that.connectDatasets(dropData, msEvt);
					},function(err){
                        console.error('Error creating a new case.',[err]);
						getOut(false);
                    });
			    }, function(){
			    	getOut(false);
			    });
			},

			createBO: function(files, msEvt){
				var title,
					that = this,
					collabSpaceLabel = '',
					f = null;

				collabSpaceLabel = widget.getPreference('collabspaces');
				
				var createDOAndUpload = function(f, msEvt){
					var that = this;
					
					// Create a new PLM document and upload the file
                    WidgetProxy.createDocumentObject(title).then(function(
                        data
                    ) {
							var oId = data;
							WidgetProxy.uploadFileTo3DSpace({
                            oId: oId,
                            title: title,
                            file: f
                        }).then(function() {
                            var newBO = [
                                    {
                                        objectId: oId,
                                        objectType:
                                            'Simulation Document - NonVersioned',
                                        displayName: f.name
                                    }
                                ],
                                dropData = { data: { items: newBO } };
									
									if (that.caseId.length > 0){
										that.connectDatasets(dropData, msEvt);
									} else {
										that.createCase(dropData, msEvt);
									}
                        });
                    });
				};
				
				// Allowing only one file to be associated with a ticket.
                for (var i = 0; (f = files[i]); i++) {
					title = f.name;
					if (that.checkExtension(title)) {
						createDOAndUpload.call(that, f, msEvt);
					}
				}
			},
			checkForFiles: function(msEvt){
				try {
                    if (typeof msEvt !== 'undefined' && msEvt !== null) {
                        var files =
                            msEvt.dataTransfer.files || msEvt.target.files;
						if(typeof files === 'undefined' || files === null){
							return null;
						}
						if(files.length === 0){
							return null;
						}
						return files;
					}
				} catch(ex) {
					return null;
				}
			},
			
			enableDragDrop: function(){
				var that = this;
				
                if (
                    typeof that.dropZone === 'undefined' ||
                    that.dropZone === null
                ) {
					console.error('no drop zone defined');
					this.resolveDropDeferred(false);
					return;
				}
				
				DND.droppable(that.dropZone, {
					over: function() {
						WidgetProxy.cancelDebouncer('removeDragClass');
						return true;
					},
					enter: function() {
						arguments[0].classList.add(that.dragClass);
					},
					leave: function() {
						var dropEl = arguments[0];
                        WidgetProxy.debounce(
                            'removeDragClass',
                            function() {
							dropEl.classList.remove(that.dragClass);
                            },
                            10
                        );
					},
					drop: function(){
						// Show mask
						that.maskHandlr(true);
						
						try {
							var data = arguments[0],
								dropEl = arguments[1],
								msEvt = arguments[2],
								droppd = null;
                            if (data === null || typeof data === 'undefined') {
								droppd = null;
							} else {
                                droppd =
                                    data.length > 0 ? JSON.parse(data) : null;
							}
						
							dropEl.classList.remove(that.dragClass);
							
							var isValidDatasets = that._validateDroppedObjects(data);
							if(isValidDatasets === 'INVALID_DS'){
								that.resolveDropDeferred(false);
								WidgetProxy.showError(NLS.get('INVALID_DS'));
								return;
							}else if(isValidDatasets !== 'VALID_DS'){
								var caseId = isValidDatasets;
								var result = {};
								result[caseId] = [];
								that._connectedResponse = JSON.stringify(result);
								that.resolveDropDeferred(true, result);
								return;
							}
							// case exists
                            // '0000.0000.0000' is the temporary id given to new
                            // cases that hevent been persisted yet
                            if (
                                that.caseId.length > 0 &&
                                that.caseId !== '0000.0000.0000'
                            ) {
								if(droppd){
									// dropped from 3DSpace
									that.connectDatasets(droppd, msEvt);
								} else {
									// dropped from file system
									var files = that.checkForFiles(msEvt) || [];
									if(files.length > 0){
										//that.createBO(files, msEvt);
										that.createBOForFiles(files, msEvt);
									}
								}
                            } else {
                                // new case creation
								if(droppd){
									that.createCase(droppd, msEvt);
								} else {
									var files = that.checkForFiles(msEvt) || [];
									if(files.length > 0){
										//that.createBO(files, msEvt);
										that.createBOForFiles(files, msEvt);
									}
								}
							}
						} catch(ex) {
							console.error(ex);
							that.maskHandlr(false);
						}
					}
				});
				return this;
			},
			createBOForFiles: function(files, msEvt){
				var that = this,
					promises = [],
					createdObjects = [];
				
				var uploadHandler = function(title, f){
					var deferred = Promise.deferred();
                    WidgetProxy.createDocumentObject(title).then(
                        function(oid) {
                            WidgetProxy.uploadFileTo3DSpace({
                                oId: oid,
                                title: title,
                                file: f
                            }).then(
                                function() {
                                    createdObjects.push({
                                        objectId: oid,
                                        objectType:
                                            'Simulation Document - NonVersioned',
                                        displayName: f.name
                                    });
								deferred.resolve();
                                },
                                function() {
								deferred.reject();
                                }
                            );
                        },
                        function() {
						deferred.reject();
                        }
                    );
					return deferred.promise;
				};
				var caseCreateHandler = function(){
					var deferred = Promise.deferred();
					if (that.caseId.length === 0){
						NewCaseDialog.showDialog(this.dialogOptions).then(function (title) {
                                WidgetProxy.createAnalyticsCaseObject(
                            		response.title,
                                    that.view.model
                                        ? that.view.model.get('description') || response.description
                                        : ''
                                ).then(
                                    function(caseid) {
                                    
									that.caseId = caseid;
									that.view.model.set('id', caseid);
                                        that.view.model.set(
                                            'image',
                                            WidgetProxy.get3DSpaceURL() +
                                                '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png'
                                        );
                                        that.view.model.set(
                                            'recommendedImage',
                                            WidgetProxy.get3DSpaceURL() +
                                                '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png'
                                        );
                                        that.view.model.set(
                                            'project',
                                            WidgetProxy.setActiveCollabSpace()
                                        );
									deferred.resolve(that.caseId);
                                    },
                                    function() {
									deferred.reject();
                                    }
                                );
					    });
					} else {
						deferred.resolve(that.caseId);
					}
					return deferred.promise;
				};
				var attachHandler = function(){
                    that.connectDatasets(
                        { data: { items: createdObjects } },
                        msEvt
                    );
				};
				for (var i=0; i<files.length; i++){
					var file = files[i],
						title = file.name;
					if (that.checkExtension(title)){
						promises.push(uploadHandler(title, file));
					}
				}
                Promise.all(promises).then(function() {
					if(createdObjects.length > 0){
                        caseCreateHandler().then(function() {
								console.log('last step');
                            that.connectDatasets(
                                { data: { items: createdObjects } },
                                msEvt
                            );
							});
					}else{
						that.maskHandlr(false);
						var msgString = NLS.not_valid_source + '\r\n';
                        if (
                            (Array.isArray(that.type) &&
                                that.type.indexOf('DATASET') > -1) ||
                            that.type === 'DATASET'
                        ) {
                            msgString +=
                                NLS.get('allowed_dataset_types') + '.\r\n';
                        } else if (
                            (Array.isArray(that.type) &&
                                that.type.indexOf('REQUIREMENT') > -1) ||
                            that.type === 'REQUIREMENT'
                        ) {
							msgString  += NLS.get('allowed_req_types') + '. ';
						}
						WidgetProxy.showMessage(msgString);
					}
				});
			},
			
			/**
			 * physicalId: Analytics Case dropped
			 * INVALID_DS: Invalid data drop
			 * VALID_DS: Valid data drop
			 */
			_validateDroppedObjects: function(droppedData){
				var result = 'VALID_DS';
				if (Core.is(droppedData, 'string') && droppedData.length > 0){
						droppedData = JSON.parse(droppedData);
					droppedData = droppedData.data;
				} else if (Core.is(droppedData, 'object')){
					droppedData = droppedData.data;
				} else {
					droppedData = undefined;
				}
				if (Core.is(droppedData) && Array.isArray(droppedData.items)){
					var len = droppedData.items.length;
					droppedData.items.forEach(function(dd){
						if(dd.objectType === 'Analytics Case'){
							if(len>1){
								result='INVALID_DS';
							}else{
								result=dd.objectId;
							}
						}
					});
				}
				return result;
			},
			
			init: function(options, callback){
				if (! options ){
                    console.error(
                        'No options were received by the drag and drop helper'
                    );
					this.resolveDropDeferred(false);
					return;
				}
				
                this.dialogOptions = {
            		immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
                    header: NLS.get('CREATE_CASE'),
                    okButtonLabel: NLS.get('CREATE_CASE_BUTTON')	
                }
				
				if (options.dropZone){
					this.dropZone = options.dropZone;
				}
				if (options.dragClass){
					this.dragClass = options.dragClass;
				}
				if (options.dragClass){
					this.dragClass = options.dragClass;
				}
				if (options.caseId){
					this.caseId = options.caseId;
				}
				if (options.view){
					this.view = options.view;
				}
				if (options.dropDeferred){
					this.dropDeferred = options.dropDeferred;
				}
				if (options.type){
					this.type = options.type;
				}
				if (typeof options.refreshOnDrop === 'boolean'){
					this.refreshOnDrop = options.refreshOnDrop;
				}
				if(typeof options.persistCaseId === 'boolean'){
					this.persistCaseId = options.persistCaseId;
				}
				this.enableDragDrop.call(this);
			},
			
			resetDropDeferred : function(_dropDeferred){
				this.dropDeferred = _dropDeferred;
			},
			checkConnectedTypes : function(connectedObjs){
                var types = { datasets: false, requirements: false };
				connectedObjs[this.caseId].forEach(function(connectedObj){
					if(this._dsallowed.indexOf(connectedObj.type) > -1){
						types.datasets = true;
                    } else if (
                        this._reqallowed.indexOf(connectedObj.type) > -1
                    ) {
						types.requirements = true;
					}
				},this);
				return types;
			}
		});
		
		return dndHelper;
    }
);

//=========================================================================
/**
 * Helper class to launch and monitor PLMBatchAdapter to download
 * knowledgeware parameters from Simulation Objects
 */
//=========================================================================
define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsPLMBatchHelper',
    [
        'UWA/Core',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy'
    ],
    function(Core, Class, Promise, WidgetProxy) {
        'use strict';

        var _self;

        var PLMBatchHelper = Class.extend({
            _spRun: {},
            _plmObjIDs: [],
            _parentPLMObjIDs: [],
            _caseID: '',
            _mcsURL: '',
            _eedURL: '',
            _eedTicket: '',
            _appDataXML: '',
            _jobID: '',
            _batchIDs: [],
            _successfulBatches: [],
            _failedBatches: [],
            _batchRunning: true,
            _batchIdsMap: {}, // Connetcs batch Ids to Sim Objects
            _onMonitor: function() {}, // function used to interact with the Monitor

            //=========================================================================
            /**
             * create new instance of the PLMBatchHelper
             */
            //=========================================================================
            init: function(args) {
                _self = this;
                _self._plmObjIDS = args.simObjects;
                _self._parentPLMObjIDs = args.parentObjects;
                _self._mcsURL = args.mcsURL;
                _self._eedURL = args.eedURL;
                _self._eedTicket = args.eedTicket;
                _self._caseID = args.caseID;

                // Callbacks
                _self._onComplete =
                    typeof args.onComplete === 'function'
                        ? args.onComplete
                        : null;
                _self._onMonitor =
                    typeof args.onMonitor === 'function'
                        ? args.onMonitor
                        : _self._onMonitor;

                _self._runner = new SPRun();
            },

            //=========================================================================
            /**
             * Creates an EED job, to execute CATSimBatch for downloading KWE
             * parameter data from Simulation Objects. Creates its own exml
             * which is capable of running multiple PLM batches simultaneously.
             * Returns a promise that resolves to provide a eed job id.
             */
            //=========================================================================
            createJob: function() {
                return new Promise(function(resolve, reject) {
                    WidgetProxy.getEEDTicket(_self._caseID).then(function(
                        response
                    ) {
                        var eedTicketForCase = response;

                        WidgetProxy.createEXMLForPLMBatch(
                            _self._caseID,
                            _self._plmObjIDS,
                            _self._parentPLMObjIDs
                        ).then(function(response) {
                            _self._batchIdsMap = response.BatchIDs || {};

                            if (_self._batchIdsMap.length > 0) {
                                _self._batchIDs = _self._batchIdsMap.map(
                                    function(x) {
                                        return x.id;
                                    }
                                );
                            } else {
                                reject({
                                    message: 'Unable to start PLM batch'
                                });
                            }
                            _self._runner.mcsURL = _self._mcsURL;
                            _self._runner.simOID = _self._caseID;
                            _self._runner.timeout = 20000;
                            _self._runner.runURL =
                                _self._eedURL + '/execution/run';
                            _self._runner.cosPubkeyURL =
                                _self._eedURL + '/execution/pubkey';
                            _self._runner.encryptURL =
                                _self._mcsURL +
                                '/resources/slmservices/data/getEncryptedCreds?SecurityContext=' +
                                WidgetProxy.getActiveCollabSpace();
                            _self._runner.mcsTicketURL =
                                _self._mcsURL +
                                '/ticket/get?SecurityContext=' +
                                WidgetProxy.getActiveCollabSpace();
                            _self._runner.runInfo =
                                "<RunInfo logLevel='Debug' submissionHost=''></RunInfo>";

                            _self._runner.addEventListener('success', function(
                                e
                            ) {
                                resolve(e.detail.result.EEDJobID);
                            });

                            _self._runner.addEventListener('error', function(
                                e
                            ) {
                                reject({ message: 'sp-run failure.' });
                            });
                            _self._runner.runEXML(
                                {},
                                WidgetProxy.htmlUnescape(response.XML),
                                _self._caseID,
                                eedTicketForCase,
                                false,
                                _self._appDataXML,
                                false
                            );
                        });
                    });
                });
            },

            //=========================================================================
            /**
             * Utility function to get fresh eed tickets every 5000ms
             */
            //=========================================================================
            refreshEEDTickets: function() {
                _self._ticketLoop = setInterval(function() {
                    WidgetProxy.getEEDTicket(_self._caseID).then(function(
                        response
                    ) {
                        WidgetProxy.setEEDTicket(response);
                    });
                }, 5000);
            },

            //=========================================================================
            /**
             * Utility function to handle the response from KWE worker utils to
             * extract the details of successful and failed batches.
             */
            //=========================================================================
            convertBatchMap: function(id) {
                var x = {},
                    match = _self._batchIdsMap.filter(function(y) {
                        return y.id === id;
                    });
                x.id = id;
                x.objs = match[0].objs.split(',');
                return x;
            },

            //=========================================================================
            /**
             * The onComplete function that is to be executed when the
             * CATSimBatch has completed execution
             */
            //=========================================================================
            batchOnComplete: function(onComplete, onFailure) {
                if (!_self.__batchRunning) {
                    clearInterval(_self._monitorLoop);
                    clearInterval(_self._ticketLoop);

                    if (_self._successfulBatches.length > 0) {
                        if (typeof onComplete === 'function') {
                            onComplete({
                                success: _self._successfulBatches.map(
                                    _self.convertBatchMap
                                ),
                                failure: _self._failedBatches.map(
                                    _self.convertBatchMap
                                )
                            });
                        }
                    } else {
                        if (typeof onFailure === 'function') {
                            onFailure({
                                failure: _self._failedBatches.map(
                                    _self.convertBatchMap
                                )
                            });
                        }
                    }
                }
            },

            //=========================================================================
            /**
             * Individual monitoring function to track status of one workitem
             * running the CATSimBatch in the EED job.
             */
            //=========================================================================
            monitorHandler: function(jobId, batchId, index) {
                WidgetProxy.monitorBulletinBoardForTopic(
                    jobId,
                    batchId
                ).then(function(response) {
                    try {
                        // keeps track of how many messages we've gotten
                        // back from this batch so that all are prorgressed
                        var progress = _self._batchIdsMap[index].progress || 0,
                            // determine how many downloads we've done so
                            // far ...
                            dwnldProgress =
                                _self._batchIdsMap[index].dwnldProgress || 0;
                        //                          _self.dwnldProgress; //
                        //                          store the number of
                        //                          plmObjs that we're
                        //                          downloading
                        if (typeof _self.dwnldProgress === 'undefined') {
                            // figure out how many we're downloading in this
                            // batch and store the number;
                            //                          dwnldProgress =
                            //                          _self._batchIdsMap[index]['objs'].split(',').length;
                            //                          _self._batchIdsMap[index].dwnldProgress
                            //                          = dwnldProgress;
                            _self.dwnldProgress = 0; //_self._plmObjIDS.length;
                        }

                        // console.log(response);

                        var responseJSON = UWA.Json.xmlToJson(response),
                            monMsg = responseJSON.MonitoringMessages || null,
                            status =
                                monMsg.length !== null ? monMsg.status : '';

                        if (status === 'Done') {
                            clearInterval(_self._monitorLoop);
                            clearInterval(_self._ticketLoop);
                            _self._onMonitor({
                                message:
                                    'PLM Job completed / failed : ' + batchId,
                                completeness: 1.0, // FIXME: need to check this ...
                                status: 'failure'
                            });
                            // console.log ('PLM Job completed / failed : '
                            // + batchId);
                            return;
                        }
                        if (
                            !monMsg.MessageList ||
                            !monMsg.MessageList.Message
                        ) {
                            return;
                        }
                        if (!monMsg.MessageList.Message) {
                            return;
                        }

                        //                      console.log(response);
                        var advPLMMsgs = monMsg.MessageList.Message;
                        //                          messageObject =
                        //                          JSON.parse(advPLMMsgs[advPLMMsgs.length
                        //                          - 1]['nodeValue']);

                        // read all the messages that have come back to
                        // check the progress
                        while (progress < advPLMMsgs.length) {
                            var messageObject = JSON.parse(
                                    advPLMMsgs[progress].nodeValue
                                ),
                                displayedMessage = '',
                                messageStatus = '';

                            var dwnldsDropped = 0;

                            // make sure we don't read this message again
                            if (messageObject.adapter_status === 'SUCCESS') {
                                // batch succeeded

                                _self._successfulBatches.push(batchId);
                                _self._batchIDs.splice(index, 1);

                                displayedMessage =
                                    'PLM Job completed successfully : ' +
                                    batchId;
                                messageStatus = 'success';

                                //                              console.log('PLM
                                //                              Job
                                //                              completed
                                //                              successfully
                                //                              : ' +
                                //                              batchId);
                                //                              return;
                            } else if (
                                messageObject.adapter_status === 'FAILED'
                            ) {
                                // this batch failed for some reason

                                _self._failedBatches.push(batchId);
                                _self._batchIDs.splice(index, 1);

                                // mark the downloads as complete as they're
                                // not going to happen
                                var totalDwnldsInBatch = _self._batchIdsMap[
                                    index
                                ].objs.split(',').length;
                                dwnldsDropped =
                                    totalDwnldsInBatch -
                                    (_self._batchIdsMap[index].dwnldProgress ||
                                        0);

                                //                              console.log('downdropped:
                                //                              ' +
                                //                              dwnldsDropped);
                                _self.dwnldProgress += dwnldsDropped; // we dropped these
                                // when the batch
                                // failed

                                displayedMessage =
                                    'PLM Job completed failed : ' +
                                    batchId +
                                    ' | ' +
                                    messageObject.adapter_message;
                                messageStatus = 'failure';

                                //                              console.log('PLM
                                //                              Job
                                //                              completed
                                //                              failed : ' +
                                //                              batchId  +
                                //                              ' | ' +
                                //                              latestMessageObject['adapter_message']);
                            } else if (
                                messageObject.adapter_status ===
                                'DOWNLOAD_COMPLETE'
                            ) {
                                // the message from the adaptor should be an
                                // id for a plm object
                                console.log(messageObject.adapter_message);
                                messageStatus = 'inprocess';
                                _self.dwnldProgress += 1;
                                displayedMessage =
                                    _self.dwnldProgress +
                                    ' of ' +
                                    _self._plmObjIDS.length +
                                    ' Download(s) Completed';
                                _self._batchIdsMap[index].dwnldProgress += 1;
                            } else {
                                console.log(messageObject);
                            }

                            _self._batchIdsMap[index].progress = progress += 1;

                            var completedBatchesCount =
                                    _self._successfulBatches.length +
                                    _self._failedBatches.length,
                                totalBatchesCount =
                                    completedBatchesCount +
                                    _self._batchIDs.length,
                                completeness =
                                    totalBatchesCount > 0
                                        ? parseFloat(
                                              (completedBatchesCount +
                                                  _self.dwnldProgress +
                                                  dwnldsDropped) /
                                                  (totalBatchesCount +
                                                      _self._plmObjIDS.length)
                                          )
                                        : 1.0;

                            _self._onMonitor({
                                message: displayedMessage,
                                completeness: completeness,
                                status: messageStatus
                            });
                        }
                    } catch (ex) {
                        console.error(ex);
                        _self._failedBatches.push(batchId);
                        _self._batchIDs.splice(index, 1);

                        var completedBatchesCount =
                                _self._successfulBatches.length +
                                _self._failedBatches.length,
                            totalBatchesCount =
                                completedBatchesCount + _self._batchIDs.length,
                            completeness =
                                totalBatchesCount > 0
                                    ? parseFloat(
                                          completedBatchesCount /
                                              totalBatchesCount
                                      )
                                    : 1.0;

                        _self._onMonitor({
                            message: 'Error during PLM Job : ' + batchId,
                            completeness: completeness,
                            status: 'error'
                        });
                    }
                });
            },

            //=========================================================================
            /**
             * The main monitor function, that triggers monitoring for all
             * batches and keeps track of them
             */
            //=========================================================================
            monitorBatches: function(onComplete, onFailure) {
                _self._monitorLoop = setInterval(function() {
                    for (var i = 0; i < _self._batchIDs.length; i++) {
                        try {
                            _self.monitorHandler.call(
                                this,
                                _self._jobID,
                                _self._batchIDs[i],
                                i
                            );
                        } catch (ex) {
                            console.warn(ex);
                        }
                    }

                    // Executes on completion of all batches
                    if (_self._batchIDs.length === 0) {
                        clearInterval(_self._monitorLoop);
                        clearInterval(_self._ticketLoop);
                        _self.__batchRunning = false;
                        _self.batchOnComplete(onComplete, onFailure);
                    }
                }, 2000);
            },

            //=========================================================================
            /**
             * Triggers a Station Adapter that executes a CATSimBatch to
             * download Knowledgeware parameters from Simulation Object(s).
             * Accepts a callback that would be fired when the batch is
             * complete.
             */
            //=========================================================================
            executePLMBatch: function(onComplete, onFailure) {
                _self._successfulBatches = [];
                _self._failedBatches = [];
                WidgetProxy.getEEDTicket(_self._caseID).then(function(
                    response
                ) {
                    _self._eedTicket = response;

                    WidgetProxy.getCaseLaunchInfo(_self._caseID).then(function(
                        response
                    ) {
                        _self._appDataXML = unescape(
                            encodeURIComponent(
                                WidgetProxy.htmlUnescape(response.encodedJobXML)
                            )
                        );

                        _self.createJob().then(function(response) {
                            console.info(response);

                            if (
                                typeof response !== 'undefined' &&
                                response !== null
                            ) {
                                _self._jobID = response;
                            }

                            WidgetProxy.getEEDTicket(
                                _self._caseID
                            ).then(function(response) {
                                WidgetProxy.setEEDTicket(response);
                                _self.monitorBatches(onComplete, onFailure);
                                _self.refreshEEDTickets();
                            });

                            window.setTimeout(function() {
                                if (!_self.__batchRunning) {
                                    clearInterval(_self._monitorLoop);
                                    clearInterval(_self._ticketLoop);

                                    if (_self._successfulBatches.length > 0) {
                                        if (typeof onComplete === 'function') {
                                            onComplete({
                                                success: _self._successfulBatches.map(
                                                    _self.convertBatchMap
                                                ),
                                                failure: _self._failedBatches.map(
                                                    _self.convertBatchMap
                                                )
                                            });
                                        }
                                    } else {
                                        if (typeof onFailure === 'function') {
                                            onFailure({
                                                failure: _self._failedBatches.map(
                                                    _self.convertBatchMap
                                                )
                                            });
                                        }
                                    }
                                }
                            }, 900000);
                        });
                    });
                });
            }
        });

        return PLMBatchHelper;
    }
);

//=========================================================================
/**
 * Helper class to handle knowledgeware parameters from Simulation Objects
 */
//=========================================================================
define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteKWEUtils',
    [
        'UWA/Core',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsPLMBatchHelper'
    ],
    function(Core, Class, Promise, WidgetProxy, PLMBatchHelper) {
        'use strict';

        var _self,
            KWEUtils = Class.extend({
                _mcsUrl: '',
                _eedUrl: '',
                _caseId: '',
                _soTypes: ['DesignSight', 'VPMReference'],
                _batchMap: { success: [], failure: [] },
                _onMonitor: function() {},

                //=========================================================================
                /**
             * Constructor to initialize the KWEUtils class
             */
                //=========================================================================
                init: function(args) {
                    _self = this;
                    _self._mcsUrl = WidgetProxy.get3DSpaceURL();
                    _self._eedUrl = WidgetProxy.getEEDURL();
                    _self._caseId = args._caseId;
                    _self._onMonitor =
                        typeof args.onMonitor === 'function'
                            ? args.onMonitor
                            : _self._onMonitor;
                },

                //=========================================================================
                /**
             * When provided a variant container of type simulation, this
             * function returns an array of objects of type Design Sight or
             * VPMReference
             */
                //=========================================================================
                getSimObjsFromContainer: function(container) {
                    return new Promise(function(resolve, reject) {
                        WidgetProxy.getSMAContents(container.physicalID).then(
                            function(data) {
                                var dataGroups = data.datarecords.datagroups,
                                    internalData =
                                        dataGroups.filter(function(dg) {
                                            dg.busType ===
                                                'Simulation Category - Internal Data';
                                        }) || [],
                                    sOs = [];
                                if (internalData.length > 0) {
                                    // temp should return array of arrays
                                    var temp = internalData.map(function(x) {
                                        return x.children.filter(function(y) {
                                            return (
                                                _self._soTypes.indexOf(
                                                    y.busType
                                                ) > -1
                                            );
                                        });
                                    });
                                    temp.forEach(function(a) {
                                        a.forEach(function(b) {
                                            sOs.push(b);
                                        });
                                    });
                                    resolve(sOs);
                                } else {
                                    resolve(sOs);
                                }
                            },
                            function() {
                                resolve([]);
                            }
                        );
                    });
                },

                //=========================================================================
                /**
             * Returns a promise which resolves to provide an array of
             * PhysicalIDs of datasets of type DesignSight or VPMReference. If
             * the dataset is a Variant Container of type Simulation, then it is
             * run through the e6W SMA_Content service to extract the list of
             * Design Sight or VPMRef children attached to the container, which
             * is then added to the array being returned.
             */
                //=========================================================================
                setInputs: function(datasets) {
                    return new Promise(function(resolve, reject) {
                        if (
                            typeof datasets === 'undefined' ||
                            datasets === null ||
                            datasets.length === 0
                        ) {
                            reject();
                        }
                        var sOs = datasets.filter(function(x) {
                            return _self._soTypes.indexOf(x.type) > -1;
                        });
                        if (sOs.length === datasets.length) {
                            resolve(
                                sOs.map(function(x) {
                                    return x.physicalId;
                                })
                            );
                        } else {
                            var variantCont = datasets.filter(function(x) {
                                return 'Simulation' === x.type;
                            });
                            if (variantCont.length > 0) {
                                Promise.all(
                                    variantCont.map(function(container) {
                                        return _self.getSimObjsFromContainer(
                                            container
                                        );
                                    })
                                ).then(
                                    function(variants) {
                                        variants.forEach(function(a) {
                                            a.forEach(function(b) {
                                                sOs.push(b.physicalId);
                                            });
                                        });
                                        resolve(sOs);
                                    },
                                    function(err) {
                                        reject(err);
                                    }
                                );
                            }
                        }
                    });
                },

                //=========================================================================
                /**
             * Handle execution of PLM Batch to extarct parameters
             */
                //=========================================================================
                executePLMBatchForObjects: function(datasets) {
                    return new Promise(function(resolve, reject) {
                        _self.setInputs(datasets).done(
                            function(sOPhysIds) {
                                if (sOPhysIds.length > 0) {
                                    _self.plmBatchHelper = new PLMBatchHelper({
                                        simObjects: sOPhysIds,
                                        mcsURL: _self._mcsUrl,
                                        eedURL: _self._eedUrl,
                                        caseID: _self._caseId,
                                        onMonitor: _self._onMonitor
                                    });
                                    _self.plmBatchHelper.executePLMBatch(
                                        resolve,
                                        reject
                                    );
                                } else {
                                    reject();
                                }
                            },
                            function(err) {
                                reject(err);
                            }
                        );
                    });
                },

                //=========================================================================
                /**
             * Returns a promise that resolves to return an array of JSON
             * objects with the KWE Parameters returned for every dataset. The
             * dataset physical id would be the key. (ex)
             * ['4C4F4F5000000F14572B6C4600024495' : {},
             *          '4C4F4F5000000F14572B6C460002555' : {}]
             */
                //=========================================================================
                downloadKWEResults: function(success) {
                    return new Promise(function(resolve, reject) {
                        Promise.all(
                            success.map(function(batchId) {
                                return WidgetProxy.getTicketAndDownloadFile(
                                    _self._caseId,
                                    'PLMBatchDump_' + batchId.id + '.json',
                                    'generic'
                                );
                            })
                        ).then(
                            function(response) {
                                if (
                                    typeof response === 'undefined' ||
                                    response === null ||
                                    response.length === 0
                                ) {
                                    reject();
                                } else {
                                    Promise.all(
                                        response.map(function(blob) {
                                            return WidgetProxy.blobReader(
                                                blob,
                                                true
                                            );
                                        })
                                    ).then(
                                        function(data) {
                                            resolve(data); // This should be
                                            // an array of
                                            // json objects
                                            // with the
                                            // dataset id as
                                            // key.
                                        },
                                        function() {
                                            reject();
                                        }
                                    );
                                }
                            },
                            function(err) {
                                console.warn(
                                    'Failed to download KWE Parameters Dump from the server.'
                                );
                                reject(err);
                            }
                        );
                    });
                },

                //=========================================================================
                /**
             * Download the images extracted from the PLM batch.
             */
                //=========================================================================
                downloadKWEFileData: function() {
                    return new Promise(function(resolve, reject) {
                        WidgetProxy.getTicketAndDownloadFile(
                            _self._caseId,
                            'plmbatch_filedata.zip',
                            'generic'
                        ).then(
                            function(blob) {
                                WidgetProxy.fileDataIndex = {};
                                WidgetProxy.unZipArchiveAsBlob(blob).then(
                                    function() {
                                        var kweFileIndex =
                                            WidgetProxy.fileDataIndex;
                                        delete WidgetProxy.fileDataIndex;
                                        resolve(kweFileIndex);
                                    },
                                    function() {
                                        resolve(null);
                                    }
                                );
                            },
                            function() {
                                resolve(null);
                            }
                        );
                    });
                },

                //=========================================================================
                /**
             * Handles execution of PLM Batch, download of the KWE parameter
             * files attached to the case object after execution and their
             * conversion to JSON objects. Returns a promise that resolves to
             * return an array of JSON objects with the SO id as key and the
             * parameter data as the value.
             */
                //=========================================================================
                run: function(datasets) {
                    return new Promise(function(resolve, reject) {
                        _self.executePLMBatchForObjects(datasets).then(
                            function(response /*,allBatches*/) {
                                _self._batchMap.success = response.success;
                                _self._batchMap.failure = response.failure;

                                if (
                                    typeof _self._batchMap.success !==
                                        'undefined' &&
                                    _self._batchMap.success !== null &&
                                    _self._batchMap.success.length > 0
                                ) {
                                    var kwePromises = [];
                                    kwePromises.push(
                                        _self.downloadKWEResults(
                                            _self._batchMap.success
                                        )
                                    );
                                    kwePromises.push(
                                        _self.downloadKWEFileData()
                                    );
                                    Promise.all(kwePromises).then(
                                        function(response) {
                                            resolve(response);
                                        },
                                        function(err) {
                                            reject(err);
                                        }
                                    );
                                } else {
                                    reject();
                                }
                            },
                            function(err /*, allBatches*/) {
                                reject(err);
                            }
                        );
                    });
                }

                //=========================================================================
                /**
             * Function to test, SO case building without running the PLM batch
             */
                //=========================================================================
                /*testRun: function(batchID){
                return new Promise(function(resolve, reject){
                    _self._batchMap.success = [{'id':
            'Batch_1147364a-4e14-4c10-9234-95fe2679c370', 'objs':
            ['44319B56EC2D0000649751578BA20200'] }]; _self._batchMap.failure =
            [{}]; if (typeof _self._batchMap.success !== 'undefined' &&
            _self._batchMap.success !== null && _self._batchMap.success.length >
            0){ _self.downloadKWEResults(_self._batchMap.success).then(
                                function(paramObjects){
                                    resolve(paramObjects);
                                },
                                function(err){
                                    reject(err);
                                });
                    } else {
                        reject();
                    }
                });
            },*/
            });

        return KWEUtils;
    }
);

define('DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteCaseListUtils',
		[
			'UWA/Core',
			'DS/UIKIT/Mask',
	        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
	        'DS/SMAAnalyticsCommon/dialogs/SMAAnalyticsConfirmDialog',
	        'DS/SMAAnalyticsCommon/dialogs/SMAAnalyticsSaveDialog',
	        'DS/SMAAnalyticsCommon/dialogs/SMAAnalyticsNewCaseDialog',
	        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsCommonProxy'
		],function(UWA, Mask, WidgetProxy, ConfirmDialog, SaveDialog, CopyCaseDialog, NLS, AnalyticsUtils, CommonProxy){
	'use strict';
	var SMAAnalyticsCaseListViewUtils = {};
	SMAAnalyticsCaseListViewUtils.createNewCase = function(){
		UWA.log('Create New Case');
	};
	SMAAnalyticsCaseListViewUtils.collectionPostProcessing = function(){
		UWA.log('Post Processing');
	};
	SMAAnalyticsCaseListViewUtils.stopCase = function(view, skeleton){
		var that = this,
		options={
			immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
    		label: NLS.get('CASE_SAVE_MESSAGE'),
    		header: UWA.is(view) && UWA.is(view.model)?view.model.get('title'):'Analytics Case',
    		okLabel: NLS.get('Save'),
    		applyLabel: NLS.get('DONT_SAVE')
		};
		SaveDialog.showDialog(options).then(function(doSave){
			if(doSave){
                window.worker.evaluate('getSaveData', null,
                    function(caseData) {
                        WidgetProxy.saveCaseData(that._config._idCard.model.id, caseData).then(function(){
                        	AnalyticsUtils.showSuccessNotification('', NLS.get('SAVE_SUCCESS'));
                        	AnalyticsUtils.reroute('/landingpage');
                        }, function(error){
                        	AnalyticsUtils.showErrorNotification('', NLS.get('SAVE_ERROR'));
                        });
                    }
                );
			}else{
				AnalyticsUtils.reroute('/landingpage');
			}
		});
	};
	
	SMAAnalyticsCaseListViewUtils.reviseAnalyticsCase = function(view){
		var options = {
    		immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
    		label: NLS.get('CASE_REVISE_MESSAGE'),
    		header: NLS.get('ARE_YOU_SURE'),
    	};
    	ConfirmDialog.showDialog(options).then(function(){
    		CommonProxy.revise(view.model.id).then(function(response){
    			var status = response.status;
    			if(status === 'failure') {
    				var error = response.report[0].error || '';
    				AnalyticsUtils.showErrorNotification('',
    					NLS.get('CASE_REVISE_FAIL') + error);
    			} else {
    				if (response.results[0]) {
    					var objectId = response.ObjIds[0];
						_cloneAnalyticsCaseModel(objectId, view).then(function(addedModel){
							if (UWA.is(addedModel)) {
								addedModel.set('image',WidgetProxy.get3DSpaceURL() +
                                '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
		                        var skeleton = AnalyticsUtils.getSkeleton();
		                        if (UWA.is(skeleton)) {
		                            skeleton.setRoute('/landingpage/' + addedModel.id + '/?f=0');
		                        }
		                        AnalyticsUtils.showSuccessNotification('',
									NLS.get('CASE_REVISE_SUCCESS')
								);
							}else {
								AnalyticsUtils.showErrorNotification('',
									NLS.get('CASE_REVISE_FAIL')
								);
							}
						}, function(error){
							AnalyticsUtils.showErrorNotification('',
								NLS.get('CASE_REVISE_FAIL')
							);
						});
    				}
    			}
    		},function(error){
    			AnalyticsUtils.showErrorNotification('',
    				NLS.get('CASE_REVISE_FAIL') + error
    			);
    		});
    	});
	};
	
	SMAAnalyticsCaseListViewUtils.copyAnalyticsCase = function(view){
		var title = view.model.get('title');
    	var options = {
			immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
			header: NLS.get('COPY_DIALOG')+title,
			okButtonLabel: NLS.get('COPY'),
			value: title+'-'+NLS.get('COPY')
		};
    	CopyCaseDialog.showDialog(options).then(function(titleValue){
        	var frm = widget.body;
            Mask.mask(frm);
            CommonProxy.copy(view.model.id, titleValue).then(
        		function(response){
        			var status = response.status;
        			if(status === 'failed'){
        				Mask.unmask(frm);
        				AnalyticsUtils.showSuccessNotification(
                            '',
                            NLS.get('CASE_COPY_FAILED')
                        );
        			} else {
        				var objectId = response.id;
        				AnalyticsUtils.cloneAnalyticsCaseModel(objectId, view).then(
                            function(addedModel) {
                                Mask.unmask(frm);
                                if (UWA.is(addedModel)) {
                                	addedModel.set('image',WidgetProxy.get3DSpaceURL() +
                                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
                                    var skeleton = AnalyticsUtils.getSkeleton();
                                    if (UWA.is(skeleton)) {
                                        skeleton.setRoute('/landingpage/' + addedModel.id + '/?f=0');
                                    }
                                } else {
                                    AnalyticsUtils.showErrorNotification('',
                                        NLS.get(
                                            'CREATE_CASE_FAILED'
                                        )
                                    );
                                }
                            },
                            function() {
                            	Mask.unmask(frm);
                                AnalyticsUtils.showErrorNotification('',
                                    NLS.get(
                                        'CREATE_CASE_FAILED'
                                    )
                                );
                            }
                        );
        				AnalyticsUtils.showSuccessNotification(
                            '',
                            NLS.get('CASE_COPY_SUCCESS')
                        );
        			}
        		},
                function(error) {
                    Mask.unmask(frm);
                    AnalyticsUtils.showErrorNotification(
                        '',
                        NLS.get('CASE_COPY_FAILED')
                    );
                }
    		);
    	});
	};
    /**
     * Delete analytics case
     */
    SMAAnalyticsCaseListViewUtils.deleteAnalyticsCase = function(
        view,
        skeleton
    ) {
    	var that = this,
    	message = NLS.get('CASE_DELETE_MESSAGE');
    	if (Array.isArray(view)){
    		message = NLS.get('CASES_DELETE_MESSAGE');
    	}
    	var options = {
			immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
			label: message,
			header: NLS.get('ARE_YOU_SURE'),
		};
    	ConfirmDialog.showDialog(options).then(function(){
    		var caseIds = [],
            frm = widget.body,
            currCollabSpace = widget.getValue('collabspaces');
    		if (Array.isArray(view)) {
    			view.forEach(function(model) {
    				caseIds.push(model.id);
    			});
    		}else{
				caseIds.push(view.model.id);
    		}
            if (caseIds.length > 0) {
                Mask.mask(frm);
                WidgetProxy.deleteObjects(caseIds).then(
                    function(response) {
                    	var successObjectIds = response.success;
                    	var failedObjectIds = response.error;
                    	if(successObjectIds && successObjectIds.length>0){
                    		if (Array.isArray(view)) {
	                            var collection = view[0].collection;
	                            successObjectIds.forEach(function(caseId) {
	                                collection.remove(caseId);
	                            }, view);
	                            var expectedCollectionSize = collection.pages * 60;
	                            var currentCollectionSize = collection.pages * successObjectIds.length;
	                            if(expectedCollectionSize-currentCollectionSize>5 && collection.hasNextPage()){
	                            	collection.fetch();
	                            }
	                            if(failedObjectIds){
	                            	AnalyticsUtils.showWarningNotification('',
        	                            NLS.get('FEW_CASE_REM_FAIL')
        	                        );
	                            }else{
	                            	AnalyticsUtils.showSuccessNotification('',
	    	                            NLS.get('CASES_REM_SUCCESS')
	    	                        );
	                            }
	                        } else {
	                            view.model.collection.remove(successObjectIds[0]);
	                            var skeleton = AnalyticsUtils.getSkeleton();
	                            if(UWA.is(skeleton)){
	                            	 skeleton.setRoute('/landingpage/');
	                            }
	                            AnalyticsUtils.showSuccessNotification('',
    	                            NLS.get('CASE_REM_SUCCESS')
    	                        );
	                        }
                    	}else{
                    		AnalyticsUtils.showErrorNotification('',
	                            NLS.get('CASE_REM_FAIL')
	                        );
                    	}
                        Mask.unmask(frm);
                    }.bind(this),
                    function(error) {
                        Mask.unmask(frm);
                        AnalyticsUtils.showErrorNotification('',
                            NLS.get('CASE_REM_FAIL')
                        );
                    }.bind(this)
                );
            }
    	}.bind(this));
    };

    return SMAAnalyticsCaseListViewUtils;
});

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLauncher',
    [
        'UWA/Core',
        'UWA/Class/Promise',
        'DS/PlatformAPI/PlatformAPI',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteKWEUtils',
        'DS/SMAAnalyticsLiteWidget/utils/AdviseLiteDownloadOps',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteAttribPLMParamUtils',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'
    ],
    function(
        Core,
        Promise,
        pAPI,
        WidgetProxy,
        KWEUtils,
        DownloadOps,
        SrvrParamOps,
        NLSUtils
    ) {
        'use strict';

        var Launcher = {
            jobID: '',
            stationName: '',
            caseID: '',
            messageTopic: 'ResultsServantDowloadingFile',
            launchCount: 0,
            launchLimit: 60,
            jobRunning: false,
            savedCase:false,

            RAECaseData: {
                formulation: {},
                parameterHierarchy: {},
                rawData: {},
                rowDescriptors: {},
                basketData: {},
                recommendedData: {}
            },

            RAECaseFileData: {},

            //=========================================================================
            /**
             * TODO::
             * 1. Launch Sequence
             * 2. Can we cache any of the tickets
             */
            //=========================================================================

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            htmlUnescape: function(value) {
                return String(value).
                    replace(/&quot;/g, '"').
                    replace(/&#39;/g, "'").
                    replace(/&lt;/g, '<').
                    replace(/&gt;/g, '>').
                    replace(/&amp;/g, '&');
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            createEXML: function(data, caseID) {
                var modelxml =
                    '<?xml version="1.0" encoding="utf-8"?>' +
                    '<fiper_Model version="6.216.0" majorFormat="1" timestamp="6/5/14" rootComponentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Properties modelId="6a53ba4c-811e-11e2-ae82-e9ce6b18c519" modelName="AdviseServant" modelVersion="6.216.0" />' +
                    '<Component id="812da46e-811e-11e2-ae82-e9ce6b18c519" name="AdviseServant" type="com.dassault_systemes.smacomponent.adviseservant">';

                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bd27e8af-811e-11e2-ae82-e9ce6b18c519" name="flavor" role="Parameter" structure="Scalar" mode="Input" dispName="host" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value>lite</Value>' +
                    '</Variable>';

                // client
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bb27e8af-811e-11e2-ae82-e9ce6b18c519" name="host" role="Parameter" structure="Scalar" mode="Input" dispName="host" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    window.location.protocol +
                    '//' +
                    window.location.host +
                    ']]></Value>' +
                    '</Variable>';

                // csrf
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bc27e8af-811e-11e2-ae82-e9ce6b18c519" name="token" role="Parameter" structure="Scalar" mode="Input" dispName="token" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    data.eedTicket +
                    ']]></Value>' +
                    '</Variable>';

                var stationPreference = widget.getPreference('stations');

                if (
                    typeof stationPreference !== 'undefined' &&
                    stationPreference.value
                ) {
                    modelxml =
                        modelxml +
                        '<Variable id="812da46e-811e-11e2-ae82-e9ce6b18c519:affinities" name="affinities" role="Property" structure="Aggregate" mode="Local" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                        '<Variable type="com.engineous.datatype.String" typeWrittenVersion="2.0.0" id="812da46e-811e-11e2-ae82-e9ce6b18c519:Host" name="Host" role="Property" structure="Scalar" mode="Local" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519:affinities">' +
                        '<Value><![CDATA[' +
                        stationPreference.value +
                        ']]></Value>' +
                        '</Variable>' +
                        '</Variable>';
                }

                /**
                 * Adding the caseID and MCS url here since sp-run
                 * consumes only the eXML when both eXML and the
                 * app data xml are provided.
                 * So removing dependency on the app data xml for
                 * Essentials.
                 */

                // caseID
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="be27e8af-811e-11e2-ae82-e9ce6b18c519" name="caseId" role="Parameter" structure="Scalar" mode="Input" dispName="caseId" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    caseID +
                    ']]></Value>' +
                    '</Variable>';

                // server url
                modelxml +=
                    '<Variable type="com.engineous.datatype.String" id="bf27e8af-811e-11e2-ae82-e9ce6b18c519" name="serverUrl" role="Parameter" structure="Scalar" mode="Input" dispName="serverUrl" saveToDB="true" parentId="812da46e-811e-11e2-ae82-e9ce6b18c519">' +
                    '<Value><![CDATA[' +
                    data.mcsUrl +
                    ']]></Value>' +
                    '</Variable>';

                modelxml =
                    modelxml +
                    '</Component>' +
                    '<Component id="6a5a22ed-811e-11e2-ae82-e9ce6b18c519" name="Task1" type="com.dassault_systemes.sma.adapter.Task">' +
                    '</Component>' +
                    '</fiper_Model>';

                return modelxml;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            createJob: function(caseID) {
                var deferred = Promise.deferred();

                var runner = new SPRun(),
                    _this = this,
                    mcsURL = WidgetProxy.get3DSpaceURL(),
                    eedURL = WidgetProxy.getEEDURL(),
                    eedJobID = '';

                WidgetProxy.getCaseLaunchInfo(caseID).then(
                    function(data) {
                        var station = widget.getValue('stations') || '';
                        if (station.length > 0) {
                            data.affinity = station;
                        }

                        var eXML = _this.createEXML(data, caseID),
                            appDataXML = unescape(
                                encodeURIComponent(
                                    _this.htmlUnescape(data.encodedJobXML)
                                )
                            );

                        runner.mcsURL = mcsURL;
                        runner.simOID = caseID;
                        runner.timeout = 20000;
                        runner.runURL = eedURL + '/execution/run';
                        runner.cosPubkeyURL = eedURL + '/execution/pubkey';
                        runner.encryptURL =
                            mcsURL +
                            '/resources/slmservices/data/getEncryptedCreds?SecurityContext=' +
                            WidgetProxy.getActiveCollabSpace();
                        runner.mcsTicketURL =
                            mcsURL +
                            '/ticket/get?SecurityContext=' +
                            WidgetProxy.getActiveCollabSpace();
                        runner.runInfo =
                            "<RunInfo logLevel='Debug' submissionHost=''></RunInfo>";
                        runner.ApplicationData = appDataXML;

                        runner.addEventListener('success', function(e) {
                            deferred.resolve(e.detail.result.EEDJobID);
                        });

                        runner.addEventListener('error', function(e) {
                            deferred.reject('');
                        });
                        runner.runEXML(
                            {},
                            eXML,
                            caseID,
                            data.eedTicket,
                            false,
                            appDataXML,
                            false
                        );
                    },
                    function(error) {
                        deferred.reject('');
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            launchLiteServant: function(caseID) {
                var _this = this,
                    launchDeferred = Promise.deferred();

                _this.caseID = caseID;

                _this.createJob(caseID).then(
                    function(jobID) {
                        if (!WidgetProxy.isNotEmpty(jobID)) {
                            launchDeferred.reject();
                        }
                        _this.jobID = jobID;
                        _this.waitForServantStartup(launchDeferred);
                    },
                    function(error) {
                        launchDeferred.reject();
                    }
                );

                return launchDeferred.promise;
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            waitForServantStartup: function(launchDeferred) {
                var _this = this,
                    waitLoop = setInterval(function() {
                        _this.monitorBulletinBoard(waitLoop, launchDeferred);
                    }, 2000);
            },

            //=========================================================================
            /**
             *
             */
            //=========================================================================
            monitorBulletinBoard: function(waitLoop, launchDeferred) {
                var _this = this;

                WidgetProxy.getEEDTicket(_this.caseID).then(
                    function(ticket) {
                        if (WidgetProxy.isNotEmpty(ticket, true)) {
                            WidgetProxy.setEEDTicket(ticket);

                            WidgetProxy.monitorBulletinBoardForTopic(
                                _this.jobID,
                                _this.messageTopic
                            ).then(
                                function(returndata) {
                                    var adviseMessages = returndata.getElementsByTagName(
                                            'Message'
                                        ),
                                        adviseMessage = '';

                                    if (adviseMessages.length > 0) {
                                        adviseMessage =
                                            adviseMessages[0].textContent;
                                    }
                                    console.info(adviseMessage);
                                    if (adviseMessage.length > 4) {
                                        if (
                                            _this.messageTopic ===
                                            'ResultsServantDowloadingFile'
                                        ) {
                                            _this.messageTopic =
                                                'ResultsLiteAdapterComplete';
                                            _this.launchCount = 0;
                                            _this.launchLimit = 900;
                                            _this.jobRunning = true;
                                        } else {
                                            clearInterval(waitLoop);
                                            launchDeferred.resolve(
                                                _this.caseID
                                            );
                                        }
                                    } else {
                                        var messageElem = returndata.getElementsByTagName(
                                                'MonitoringMessages'
                                            )[0],
                                            status = messageElem.getAttribute(
                                                'status'
                                            );

                                        console.info(messageElem);
                                        console.info(status);

                                        if (
                                            status.toLowerCase() === 'running'
                                        ) {
                                            _this.launchCount = 0;
                                            _this.jobRunning = true;
                                        } else if (
                                            status.toLowerCase() === 'done'
                                        ) {
                                            clearInterval(waitLoop);
                                            launchDeferred.reject();
                                        }
                                    }
                                },
                                function(err) {
                                    console.error('Monitoring err: ', err);
                                    launchDeferred.reject();
                                }
                            );
                        }
                    },
                    function(err) {
                        console.error('Ticket error: ', err);
                        launchDeferred.reject();
                    }
                );
            },

            //=========================================================================
            /**
             * FIXME : Code to figure out if there are any datasets, like TSVs
             * or CSVs that can be processed on the client side - Here
             */
            //=========================================================================
            getDatasetsEligibleForClientSideProcessing: function(datasets) {
                return [];
            },

            //=========================================================================
            /**
             * Sets the flags which denotes how to extract the data for this
             * case. CATSIMBATCH -  Needs a catsimbatch to extract the KWE data
             * PLMPARAMETERS - Extract attributes and plm parameters from
             * 3DSpace ADVISESERVANT - Start a RA servant to extract data from
             * datasets. CLIENTSIDEPROCESSING - For datasets that can be read in
             * the JS client
             */
            //=========================================================================
            getExecutionType: function(caseDldFlags) {
                var needServant = false,
                    needPLMBatch = false,
                    getParamsFromMCS = true,
                    cSideProcessing = false,
                    datasets = WidgetProxy.datasets || [],
                    simObjs =
                        WidgetProxy.getSimulationObjectsConnectedToCase() || [];
                this.savedCase = caseDldFlags.savedCase;
                if (
                    caseDldFlags.savedCase !== true &&
                    caseDldFlags.plmBatchExecuted !== true
                ) {
                    
                	needServant = true;
                    getParamsFromMCS = true;
                }

                if (datasets.length > 0) {
                    if (simObjs.length === datasets.length) {
                        needServant = false;
                        needPLMBatch = true;
                    } else if (
                        simObjs.length > 0 &&
                        simObjs.length !== datasets.length
                    ) {
                        needServant = true;
                        needPLMBatch = true;
                    }

                    var cSideDatasets = this.getDatasetsEligibleForClientSideProcessing(
                        datasets
                    );
                    if (cSideDatasets.length > 0) {
                        cSideProcessing = true;
                    }
                }

                return {
                    CATSIMBATCH: needPLMBatch ? 1 : 0,
                    PLMPARAMETERS: getParamsFromMCS ? 1 : 0,
                    ADVISESERVANT: needServant ? 1 : 0,
                    CLIENTSIDEPROCESSING: cSideProcessing ? 1 : 0
                };
            },

            //=========================================================================
            /**
             * Initialize case data:
             * 1. Check if there is a essentials data, if yes, download it and
             * load the worker.
             * 2. Else start a batch servant to read case and upload the data
             *  and then trigger data download and load the worker.
             */
            //=========================================================================
            startApp: function(caseID, tryServantLaunchAgain) {
                var _this = this,
                    simObjects =
                        WidgetProxy.getSimulationObjectsConnectedToCase() || [],
                    downldOps = new DownloadOps({
                        mcsURL: WidgetProxy.get3DSpaceURL(),
                        caseID: caseID
                    }),
                    serverParamOps = new SrvrParamOps({});

                return new Promise(function(resolve, reject) {
                    downldOps.runDownload().then(
                        function(data) {
                            console.log(
                                'Retrieval of case data from MCS complete.'
                            );
                            resolve({ openMergeUI: false });
                        },
                        function(err) {
                            console.warn(
                                'Retrieval of saved analytics case data from MCS failed. Trying to extract data from the dataset..'
                            );

                            var caseDldFlags = downldOps.getCaseDataDownloadFlags(),
                                noServant = true,
                                downloadPromises = [];
                            _this.downloadFlags = downldOps.getDatasetsProcessingType(
                                [],
                                caseDldFlags
                            );

                            // TEST - REMOVE THIS - FIXME
                            //_this.downloadFlags['ADVISESERVANT'] = 0;

                            if (_this.downloadFlags.PLMPARAMETERS === 1) {
                                // Attributes and Attribute Groups Hierarchy
                                downloadPromises.push(
                                    (function() {
                                        return new Promise(function(
                                            resolve,
                                            reject
                                        ) {
                                            serverParamOps.
                                                extractAttribsNAttribGrps(
                                                    WidgetProxy.getDataSetsList()
                                                ).
                                                then(
                                                    function(data) {
                                                        var attributesData =
                                                            data.attributesData ||
                                                            null;
                                                        if (
                                                            attributesData ===
                                                                null ||
                                                            attributesData.length ===
                                                                0
                                                        ) {
                                                            resolve(null);
                                                        } else {
                                                            //************************************************************************
                                                            // FIXME : G6H :
                                                            // Uncomment the below
                                                            // line to stop adding
                                                            // sim attributes to the
                                                            // data. ALWAYS COMMENT
                                                            // THIS BEFORE PROMOTION
                                                            //************************************************************************
                                                            // attributesData.forEach(function(dataset){
                                                            // dataset.attributes =
                                                            // []; }, this);

                                                            resolve(
                                                                attributesData
                                                            );
                                                        }
                                                    },
                                                    function(err) {
                                                        console.warn(
                                                            'Error retrieving PLM data. ',
                                                            [err]
                                                        );
                                                        resolve(null);
                                                    }
                                                );
                                        });
                                    })()
                                );
                            }

                            // DO NOT DELETE _ CONTAINER CODE
                            if (
                                _this.downloadFlags.CLIENTSIDEPROCESSING === 1
                            ) {
                                /*downloadPromises.push(function(){
                                    return new Promise(function(resolve,
                                reject){
                                        WidgetProxy.getPLMParameters().then(function(data){
                                            resolve();
                                        }, function(){
                                            reject();
                                        });

                                    })
                                }());*/
                            }

                            if (
                                tryServantLaunchAgain &&
                                _this.downloadFlags.ADVISESERVANT === 1
                            ) {
                                // as of right now we don't want the servant
                                //                          downloadPromises.push((function(){
                                //                              return new
                                //                              Promise(function(resolve,
                                //                              reject){
                                //                                  _this.launchLiteServant(caseID).then(function(){
                                //                                      console.log('Advise
                                //                                      servant
                                //                                      has
                                //                                      completed
                                //                                      execution.');
                                //                                      downldOps.runDownload().then(function(data){
                                //                                          console.log('Retrieval
                                //                                          of
                                //                                          case
                                //                                          data
                                //                                          from
                                //                                          MCS
                                //                                          complete.');
                                //                                          resolve();
                                //                                      },
                                //                                      function(err){
                                //                                          console.warn('Error
                                //                                          retrieving
                                //                                          data
                                //                                          from
                                //                                          MCS.
                                //                                          ',
                                //                                          [err]);
                                //                                          reject();
                                //                                      });
                                //                                  });
                                //                              });
                                //                          }()));
                            }

                            if (_this.downloadFlags.CATSIMBATCH === 1) {
                                downloadPromises.push(
                                    (function() {
                                        return new Promise(function(
                                            resolve,
                                            reject
                                        ) {
                                            WidgetProxy.setKWEMergeUIFlag(true);
                                            if (worker) {
                                                // setup the simObjects on the
                                                // worker (without getting the kwe
                                                // params)
                                                worker.evaluate(
                                                    'setDatasets',
                                                    [simObjects],
                                                    function() {
                                                        resolve();
                                                    }
                                                );
                                            } else {
                                                resolve();
                                            }
                                        });
                                    })()
                                );
                            }

                            Promise.all(downloadPromises).then(
                                function(data) {
                                    var downloadedData = {
                                        ATTRIB_PLM_DATA: null,
                                        CSIDE_DATA: null,
                                        savedCase:_this.savedCase
                                    };
                                    // At this point of time the data from
                                    // the servant if there is some should
                                    // have been loaded to the worker.
                                    if (
                                        _this.downloadFlags.PLMPARAMETERS === 1
                                    ) {
                                        downloadedData.ATTRIB_PLM_DATA =
                                            data[0];
                                    }
                                    if (
                                        _this.downloadFlags.
                                            CLIENTSIDEPROCESSING === 1
                                    ) {
                                        downloadedData.CSIDE_DATA = data[2];
                                    }
                                    worker.evaluate(
                                        'setDataFromServer',
                                        [downloadedData],
                                        function() {
                                            resolve();
                                        }
                                    );
                                },
                                function(err) {
                                    console.error(
                                        'Error retrieving data for the case. ',
                                        [err]
                                    );
                                    reject();
                                }
                            );
                        }
                    );
                });
            },

            //=========================================================================
            /**
             * Function to download just the case data including the raw(basket)
             * data, formulation, row dsescriptors and hierarchy
             */
            //=========================================================================
            downloadCaseData: function(caseID) {
                var _this = this,
                    deferred = Promise.deferred();

                WidgetProxy.checkoutEssentialsData(caseID).then(
                    function(ticketWrapper) {
                        // Returns a zip file as blob
                        WidgetProxy.downloadFile({
                            ticket: encodeURIComponent(
                                ticketWrapper.exportString
                            ),
                            fileExtension: 'zip',
                            url: ticketWrapper.actionURL
                        }).then(
                            function(data) {
                                // Convert the blob to url
                                var blobURL = WidgetProxy.convertBlobToURL(
                                    data
                                );

                                // Convert blob url to zipJS object
                                WidgetProxy.importBlobURLToZip(blobURL).then(
                                    function(extractedData) {
                                        // Destroy the url
                                        window.URL.revokeObjectURL(blobURL);

                                        if (
                                            WidgetProxy.isNotEmpty(
                                                extractedData
                                            )
                                        ) {
                                            var files =
                                                    extractedData.root.children,
                                                zipPromises = [];

                                            files.forEach(function(file) {
                                                var nameSplit = file.name.split(
                                                        '.'
                                                    ),
                                                    key = nameSplit[0],
                                                    extension = nameSplit[1];

                                                // Import all the unzipped
                                                // file objects to blob
                                                zipPromises.push(
                                                    WidgetProxy.importZipFileEntryToBlob(
                                                        {
                                                            fileName: key,
                                                            fileExtension: extension,
                                                            zipFileEntry: file
                                                        }
                                                    )
                                                );
                                            });

                                            // Store the individual files in
                                            // case data object
                                            if (zipPromises.length > 0) {
                                                Promise.all(zipPromises).then(
                                                    function(data) {
                                                        data.forEach(function(
                                                            entry
                                                        ) {
                                                            // FIXME :
                                                            // the
                                                            // webservice
                                                            // shouldnt
                                                            // return
                                                            // file_data
                                                            if (
                                                                entry.name !==
                                                                'file_data'
                                                            ) {
                                                                _this.RAECaseData[
                                                                    entry.name
                                                                ] =
                                                                    entry.blob;
                                                            }
                                                        });
                                                        deferred.resolve();
                                                    },
                                                    function() {
                                                        deferred.reject();
                                                    }
                                                );
                                            } else {
                                                deferred.reject();
                                            }
                                        } else {
                                            deferred.reject();
                                        }
                                    },
                                    function() {
                                        deferred.reject();
                                    }
                                );
                            },
                            function(err) {
                                deferred.reject();
                            }
                        );
                    },
                    function(err) {
                        deferred.reject();
                    }
                );

                return deferred.promise;
            },

            //=========================================================================
            /**
             * Function to download all the file_data archives
             */
            //=========================================================================
            downloadCaseFileData: function(caseID) {
                var _this = this,
                    deferred = Promise.deferred(),
                    fDPromises = [];

                WidgetProxy.checkoutEssentialsFileData(caseID).then(
                    function(data) {
                        if (
                            typeof data.files !== 'undefined' &&
                            data.files !== null
                        ) {
                            data.files.forEach(function(tWrp) {
                                fDPromises.push(
                                    WidgetProxy.downloadFile({
                                        ticket: encodeURIComponent(
                                            tWrp.exportString
                                        ),
                                        fileExtension: 'zip',
                                        url: tWrp.actionUrl
                                    })
                                );
                            });

                            if (fDPromises.length > 0) {
                                var unzipPromises = [];
                                Promise.all(fDPromises).then(
                                    function(data) {
                                        var blobUrls = [];
                                        data.forEach(function(blob) {
                                            // Data here is an array
                                            // of blobs

                                            unzipPromises.push(
                                                WidgetProxy.unZipArchiveAsBlob(
                                                    blob
                                                )
                                            );
                                            // unzipPromises.push(WidgetProxy.unzip(blob));

                                            Promise.all(
                                                unzipPromises
                                            ).then(function() {
                                                widget.raeFileIndex =
                                                    WidgetProxy.fileDataIndex;
                                                delete WidgetProxy.fileDataIndex;
                                                WidgetProxy.fileDataIndex = {};
                                                deferred.resolve();
                                            });
                                        });
                                    },
                                    function() {
                                        deferred.resolve();
                                    }
                                );
                            }
                        } else {
                            deferred.resolve();
                        }
                    },
                    function() {
                        deferred.resolve();
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
             * Triggers download of all the necessary case files
             */
            //=========================================================================
            downloadAllRAEData: function(caseID) {
                var _this = this,
                    promiseArray = [],
                    deferred = Promise.deferred();

                promiseArray.push(_this.downloadCaseData(caseID));
                promiseArray.push(_this.downloadCaseFileData(caseID));

                Promise.all(promiseArray).then(
                    function(data) {
                        // G6H - This is a test method to index files for
                        // easy access from the browser. Move all this to
                        // the browser and check if there is a better way of
                        // traversing the file system provided a path.
                        //_this.IndexFiles();

                        deferred.resolve();
                    },
                    function(err) {
                        console.error(
                            'Error downloading existing Analytics case data from FCS.'
                        );
                        deferred.reject(err);
                    }
                );
                return deferred.promise;
            },

            //=========================================================================
            /**
             * G6H - This is a test method to index files for easy access from
             * the browser. Move all this to the browser and check if there is a
             * better way of traversing the file system provided a path.
             */
            //=========================================================================
            indexFiles: function() {
                var _this = this;
                widget.raeFileIndex = {};

                var isNotDir = function(x) {
                        return !x.directory;
                    },
                    doIndex = function(x) {
                        widget.raeFileIndex[x.data.filename] = x;
                    };

                for (var key in _this.RAECaseFileData) {
                    if (_this.RAECaseFileData.hasOwnProperty(key)) {
                        _this.RAECaseFileData[key].entries.
                            filter(isNotDir).
                            forEach(doIndex);
                    }
                }
            },

            //=========================================================================
            /**
             * @deprecated
             * Downloads litecase.json and returns a promise
             * Done response returns a blob
             */
            //=========================================================================
            /*downloadLiteFiles: function(caseID){
                var deferred = Promise.deferred();
                var liteFilePromises = [
                                        WidgetProxy.getTicketAndDownloadFile(caseID,
            'parameterHierarchy.json', 'json'),
                                        WidgetProxy.getTicketAndDownloadFile(caseID,
            'rowDescriptors.json', 'json'),
                                        WidgetProxy.getTicketAndDownloadFile(caseID,
            'formulation.json', 'json'),
                                        ];

                Promise.all(liteFilePromises).then(
                    function(blobs){
                        WidgetProxy.getTicketAndDownloadFile(caseID,
            'basketData.tsv', 'tsv') .then(function(blob){
                                deferred.resolve({'parameterHierarchy':
            blobs[0], 'rowDescriptors': blobs[1], 'formulation': blobs[2],
            'rawData': blob});
                            }, function(){
                                WidgetProxy.getTicketAndDownloadFile(caseID,
            'rawData.tsv', 'tsv') .then(function(blob){
                                        deferred.resolve({'parameterHierarchy':
            blobs[0], 'rowDescriptors': blobs[1], 'formulation': blobs[2],
            'rawData': blob});
                                    }, function(){
                                        alert('No data found to open the
            Analytics Case');
                                    });
                            });
                    },
                    function(err){
                        console.error('Error downloading the Lite Json File');
                        deferred.reject();
                    }
                );
                return deferred.promise;
            },*/

            //=========================================================================
            /**
             * Takes a blob object, starts the web worker and loads the data on
             * to the web worker
             * TODO: will there be multiple webworkers on this window?
             *
             * @deprecated
             */
            //=========================================================================
            /*loadCaseToWorker: function(){

                var _this = this,
                    workerDef = Promise.deferred(),
                    deferredArray = [];

                this.setupWorker();

                for(var key in _this.RAECaseData){
                    if (_this.RAECaseData.hasOwnProperty(key)){

                        var blob = _this.RAECaseData[key],
                            readBlob = function(_key, _blob){
                                var thisBlobDeferred = Promise.deferred(),
                                reader = new FileReader();

                                reader.addEventListener('loadend', function() {
                                   //reader.result contains the contents of blob
            as a typed array var modResultString = '', modResult = '';

                                    if (_key === 'rawData' || _key ===
            'basketData'){ modResultString =
            this.result.split('NaN').join('null'); modResult = modResultString;
                                    } else {
                                        // FIXME : remove file_data from the
            casedata object in eno WS if (_key !== 'file_data'){ try {
                                                modResultString =
            this.result.split('NaN').join('null'); modResult =
            JSON.parse(modResultString); } catch(e){ console.error('Error
            parsing JSON string for' + _key,e); return;
                                            }
                                        }

                                    }
                                    window.worker.evaluate('setCaseData', [_key,
            modResult], function(){ thisBlobDeferred.resolve();
                                    });
                                });
                                reader.readAsText(_blob);
                                deferredArray.push(thisBlobDeferred.promise);
                            };
                        readBlob(key, blob);
                    }
                }

                Promise.all(deferredArray).then(
                    function(values){ workerDef.resolve(); },
                    function(values){ workerDef.reject(); }
                );

                return workerDef.promise;
            },*/

            //=========================================================================
            /**
             * Initialize the RAE Web Worker
             */
            //=========================================================================
            initializeWebWorker: function(caseId, datasets) {
                return new Promise(function(resolve, reject) {
                    if (
                        typeof worker !== 'undefined' &&
                        typeof worker.terminate === 'function'
                    ) {
                        worker.terminate();
                        delete window.worker;
                    }
                    window.worker = new Worker(
                        require.toUrl(
                            'DS/SMAAnalyticsWorkers/SMAAnalyticsWorkers.js'
                        )
                    );
                    window.worker.listeners = {};

                    /**
                     * Worker function to be called on the front end. A random
                     * id is generated and posted when a call is made to the
                     * worker. The worker replies with the same ID which is then
                     * used as an identifier for the call back function.
                     * 'command' = Corresponding command on the worker.
                     * 'args' = Arguments object as needed on the worker.
                     */
                    window.worker.evaluate = function(command, args, callback) {
                        var id = new Array(36 + 1).
                            join(
                                (Math.random().toString(36) +
                                    '00000000000000000').slice(2, 18)
                            ).
                            slice(0, 36);
                        window.worker.postMessage({
                            command: command,
                            args: args,
                            id: id
                        });
                        window.worker.listeners[id] = callback;
                    };

                    window.worker.onmessage = function(event) {
                        if (window.worker.listeners[event.data.id]) {
                            window.worker.listeners[event.data.id](
                                event.data.data
                            );
                            /**
                             * If the command is "set" it is likely that meta
                             * data is updated. If meta data is returned from
                             * worker, the case data needs to be updated on the
                             * client.
                             */
                            /*if(event.data.metaData)
                               window.caseData = event.data.metaData;*/

                            delete window.worker.listeners[event.data.id];
                        }
                    };
                    
                    window.worker.onerror = function(event){
                    	var msg = event.message,
                    		msgParts = msg.split(': ');
                    	console.log(msg);
                    	console.error(event);
                    }

                    // FIXME: datasets not used by initializeWorker
                    worker.evaluate(
                        'initializeWorker',
                        [datasets, caseId],
                        function() {
                            var simobjs = WidgetProxy.getSimulationObjectsConnectedToCase();
                            worker.evaluate(
                                'setDatasets',
                                [datasets, simobjs],
                                function() {
                                    var currentUserData = pAPI.getUser(),
                                        userName =
                                            currentUserData.firstName +
                                            ' ' +
                                            currentUserData.lastName,
                                        userId = currentUserData.login;
                                    worker.evaluate(
                                        'setCurrentUser',
                                        [userName, userId],
                                        function() {
                                            resolve();
                                        }
                                    );
                                }
                            );
                        }
                    );
                });
            }

            //=========================================================================
            /**
             * create worker - @deprecated
             */
            //=========================================================================
            /*setupWorker: function(){

                // TEST CODE
                _this.zipJSUrl =
            require.toUrl('scripts/ThreeDS/Visualization/zip-js/');
                _this.amdloader = require.toUrl('DS/AmdLoader/AmdLoader.js');


                window.worker = new
            Worker(require.toUrl('DS/SMAAnalyticsWorkers/SMAAnalyticsWorkers.js'));

                *   Worker function to be called on the front end.
                *   a random id is generated and posted when call is made to the
            worker
                *   worker replies with the same ID which is then used as an
            identifier
                *   for the call back function
                *   command = corresponding command on the worker.
                *   args = an object of arguments as needed on the worker.
                *

                //list of listeners have a id: callbackFn mapping

                // TEST CODE - LOADING SCRIPTS IN WORKER
                var args = {'amdLoader' :
            require.toUrl('DS/AmdLoader/AmdLoader.js'), 'UWAStandAlone' :
            require.toUrl('DS/c/UWA/js/UWA_Standalone_Alone.js'), 'UWACore' :
            require.toUrl('DS/UWA2/js/Core.js'), 'UWAPromise':
            require.toUrl('DS/UWA2/js/Class/Promise.js'), 'ZIPJS' :
            require.toUrl('DS/ZipJS/zip-fs.js')};

                window.worker.postMessage({'command':'initializeScripts',
            'args':[args], 'id': 'x123oodssdss'})


                window.worker.listeners = {};
                window.worker.evaluate = function(command, args, callback){
                   var id = new
            Array(36+1).join((Math.random().toString(36)+'00000000000000000')
                                            .slice(2, 18)).slice(0, 36);

                   window.worker.postMessage({'command':command, 'args':args,
            'id': id});

                   //callback is mapped to the ID
                   window.worker.listeners[id] = callback;

                };

                //when the worker responds, call the callbackfunction
                window.worker.onmessage = function(event){
                       if(window.worker.listeners[event.data.id]){
                           window.worker.listeners[event.data.id](event.data.data);
                           //if the command is "set" it is likely that meta data
            is updated
                           //if meta data is returned from worker
                           //case data needs to be updated on the client
                           if(event.data.metaData){
                               window.caseData = event.data.metaData;
                           }
                           delete window.worker.listeners[event.data.id];
                       }
                };
            },*/
        };

        return Launcher;
    }
);

/* global worker */
/* jshint -W116 */
//XSS_CHECKED
define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteCommentUI',
    [
        'UWA/Class',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/UIKIT/Modal',
        'DS/Controls/Button',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',        
        'DS/Controls/Editor',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils',
        'DS/SMAAnalyticsCommon/dialogs/SMAAnalyticsConfirmDialog'
    ],
    function(Class, WidgetProxy, Modal, WUXButton, RAEPopover, WUXEditor, NLS, AnalyticsUtils, ConfirmDialog) {
        'use strict';

        var _self = null;

        var CommentUI = Class.extend({
            init: function(options) {
                _self = this;

                options = options || {};
                // this.immersiveFrame = options.immersiveFrame;

                this.target = options.target || document.body;

                // remove any old instances that are left over in the dom ...
                //          var oldUI =
                //          this.target.querySelectorAll('.ra-comment-ui');
                //          if(oldUI !== null){
                //              [].forEach.call(oldUI,function(old){
                //                  old.parentNode.removeChild(old);
                //              });
                //          }

                //          _self.modal = new Modal({
                //              'closable': true,
                //              'renderTo': _self.target,
                //              'className': 'ra-comment-ui'
                //          });
            },
            getCommentForm: function(target) {
                // if no target is defined, use the rowId as the target
                // target would be a comment id

                var footer = document.createElement('div');
                var commentTitle = NLS.get('respond_to') + ' ',
                    targetId = null,
                    response = false;
                if (typeof target === 'undefined') {
                    // comment on alternative
                    targetId = _self.activeRow.rowId;
                    commentTitle = NLS.get('leave_a_comment');
                } else {
                    targetId = target.id;
                    if (target.user && target.user.name) {
                        commentTitle += target.user.name;
                    }
                    response = true;
                }
                // else the target is a sub comment

                var commentBox = document.createElement('div');
                var commentTitleElem = document.createElement('h4');
                commentTitleElem.textContent = commentTitle;
                commentBox.appendChild(commentTitleElem);
                commentBox.classList.add('rae-comment-textarea');
                _self.textArea = new WUXEditor({
                    placeholder: NLS.get('leave_a_comment') + ' ...'
                }).inject(commentBox);
                // submit button
                var submitButton = new WUXButton({
                    value: 'Submit',
                    label: NLS.get('add_comment'),
                    //              className: 'ra-comment-submit',
                    onClick: function() {
                        // submit the comment that has been typed into the
                        // textArea
                        var text = _self.textArea.value;
                        if (worker) {
                            // FIXME: this should also refresh the compare
                            // table, ideally just the comment counter in the
                            // header
                            worker.evaluate(
                                'setCommentOnRow',
                                [_self.activeRow.rowIndex, text, targetId],
                                _self.refreshCommentForm
                            );
                        }
                    }
                }).inject(commentBox);
                if (response) {
                    var submitButton = new WUXButton({
                        value: 'Cancel',
                        label: NLS.get('cancel'),
                        //                  className: 'ra-comment-submit',
                        onClick: function() {
                            _self.refreshCommentForm();
                        }
                    }).inject(commentBox);
                }
                footer.appendChild(commentBox);
                //          if(_self.modal && typeof _self.modal.setFooter ===
                //          'function'){
                //              _self.modal.setFooter(footer); // set this form
                //              to the footer
                //          }
                return footer;
            },

            clearFooter: function() {
                // sets footer to a button requesting the user to add a comment
            },

            // display the comments ui for the given row
            showCommentsForRowId: function(row, commentChangeCallback) {
                _self.activeRow = row;

                var pmBody = document.createElement('div');
                pmBody.classList.add('ra-pmui');
                pmBody.classList.add('ra-pmui-container');

                _self.commentContainer = document.createElement('div');
                _self.commentContainer.id = 'RAE-comments-container'; // FIXME: there can be more than
                // one comment container!!!
                _self.commentContainer.classList.add('ra-popover-container');
                _self.commentContainer.classList.add('ra-comment-ui');

                _self.commentChangeCallback = commentChangeCallback;
                if (worker) {
                    worker.evaluate(
                        'getCommentsForRow',
                        [_self.activeRow.rowIndex],
                        _self.refreshCommentForm
                    );
                }

                _self.popover = new RAEPopover({
                    resizableFlag: true,
                    title: NLS.get('comments_for') + ' ' + _self.activeRow.name //,
                    //'immersiveFrame': _self.immersiveFrame
                });

                _self.commentFooter = document.createElement('div');

                _self.commentFooter.appendChild(_self.getCommentForm());

                _self.popover.injectContent({
                        body: _self.commentContainer,
                        footer: _self.commentFooter
                    }, 
                    {
                        confirmOnCloseCallback: _self.confirmCloseCommentForm
                    }
                );

                _self.popover.onResize();

                _self.popover.open();
            },
            confirmCloseCommentForm: function(){
                if( _self.textArea.value === ""){
                    return Promise.resolve(true);
                }else {                
                    var options = {
                        immersiveFrame: AnalyticsUtils.getImmersiveFrame(),
                        label: NLS.get('confirm_discard_message'),
                        header:  NLS.get('confirm_close'),
                        okLabel: NLS.get('yes_button_label'),
                        cancelLabel: NLS.get('no_button_label')
                    };
                    return ConfirmDialog.showDialog(options);
                }
            },
            
            refreshCommentForm: function(commentList) {
                _self.commentList = commentList || _self.commentList;

                if (typeof _self.commentChangeCallback === 'function') {
                    _self.commentChangeCallback();
                }
                if (
                    !Array.isArray(_self.commentList) ||
                    _self.commentList.length === 0
                ) {
                    _self.commentContainer.textContent = NLS.get('no_comments');
                } else {
                    _self.commentContainer.innerHTML = '';
                    _self.commentList.forEach(function(comment) {
                        // create the comment (not directly supplying this
                        // function so as to not pass the index and array
                        // references)
                        _self.displayComment(comment);
                    }, this);
                }

                // clear out the comment form
                if (_self.commentFooter) {
                    _self.commentFooter.innerHTML = '';
                    _self.commentFooter.appendChild(_self.getCommentForm());
                }

                if (_self.textArea) {
                    //              _self.textArea.setValue('');
                    _self.textArea.value = '';
                }
            },
            displayComment: function(comment, parentComment, depth) {
                depth = typeof depth !== 'undefined' ? depth : 0;

                // TODO: custom element?
                var commentElem = document.createElement('div');
                commentElem.classList.add('ra-comment');
                if (depth > 0) {
                    commentElem.classList.add('ra-comment-sub');
                    commentElem.classList.add('ra-comment-sub-' + depth);
                }

                var commentHeader = document.createElement('div');
                commentHeader.classList.add('ra-comment-header');
                commentHeader.classList.add('ra-comment-section');

                var commentUser = document.createElement('span');
                commentUser.classList.add('ra-comment-user');
                commentUser.textContent = comment.user.name;
                commentHeader.appendChild(commentUser);

                if (parentComment && parentComment.user) {
                    var replyToIcon = document.createElement('span');
                    replyToIcon.classList.add('wux-ui-3ds');
                    replyToIcon.classList.add('wux-ui-3ds-1x');
                    replyToIcon.classList.add('wux-ui-3ds-right');
                    replyToIcon.style.marginRight = '1em';
                    var replyTo = document.createElement('span');
                    replyTo.classList.add('ra-comment-replyto');
                    replyTo.textContent = parentComment.user.name;
                    commentHeader.appendChild(replyToIcon);
                    commentHeader.appendChild(replyTo);
                }

                var commentDate = document.createElement('span');
                commentDate.classList.add('ra-comment-date');

                var dateOfComment = new Date(Number(comment.date));
                //          var dd = dateOfComment.getDate();
                //          var mm = dateOfComment.getMonth()+1; //January is 0
                //          var yyyy = dateOfComment.getFullYear();

                commentDate.textContent =
                    dateOfComment.toLocaleDateString() +
                    ', ' +
                    dateOfComment.toLocaleTimeString(); // yyyy + '-' + mm + '-' + dd;
                commentHeader.appendChild(commentDate);

                commentElem.appendChild(commentHeader);

                var commentContent = document.createElement('div');
                commentContent.classList.add('ra-comment-content');
                commentContent.classList.add('ra-comment-section');
                commentContent.textContent = decodeURIComponent(comment.text);
                commentElem.appendChild(commentContent);
                //
                // removed till I get it working
                var commentFooter = document.createElement('div');
                commentFooter.classList.add('ra-comment-footer');
                commentFooter.classList.add('ra-comment-section');

               

                // FIXME: should be a uikit button
                var commentSub = document.createElement('span');
                commentSub.commentObj = comment;
                commentSub.classList.add('rae-comment-reply');                
                commentSub.textContent = NLS.get('reply_button_label');
                commentSub.onclick = _self.subComment;
                commentFooter.appendChild(commentSub);

                commentElem.appendChild(commentFooter);

                // append to the container
                _self.commentContainer.appendChild(commentElem);

                // cycle through subcomments to add them
                if (Array.isArray(comment.comments)) {
                    var _depth = depth + 1;
                    comment.comments.forEach(function(subComment) {
                        _self.displayComment(subComment, comment, _depth);
                    }, this);
                }
            },
           
            subComment: function() {
                // remove the form from the bottom (if present)
                // insert the comment form below the comment in question
                if (_self.commentFooter) {
                    _self.commentFooter.innerHTML = '';
                    this.parentElement.appendChild(
                        _self.getCommentForm(this.commentObj)
                    );
                }
                //          _self.modal.setFooter(footer);
            }
        });

        return CommentUI;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/components/AdviseLiteRequirementsMapUI',
    [
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'UWA/Core',
        'UWA/Utils',
        'UWA/Class',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteComboBox',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequirementsUtils',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ],
    function(WidgetProxy, UWA, Utils, Class, ComboBox, RequirementsUtils, NLS) {
        'use strict';

        var _self = null;

        var ReqMergeUI = Class.extend({
            init: function(options) {
                _self = this;

                this.active = false;

                if (options.model) {
                    this.model = options.model;
                    this.reqUtils = new RequirementsUtils({
                        caseId: this.model.id
                    });
                } else {
                    throw 'Model not provided as an option to Requirements Map UI';
                }
                this.reqsToMerge = {};

                // create the table
                this.tableRef = this.createTableElement();

                // create the columns and add them to the table
                Polymer.dom(this.tableRef).appendChild(
                    this.createRowHeaderColumn()
                );
                Polymer.dom(this.tableRef).appendChild(
                    this.createThresholdColumn()
                );
                Polymer.dom(this.tableRef).appendChild(
                    this.createObjectiveColumn()
                );
                Polymer.dom(this.tableRef).appendChild(
                    this.createParameterColumn()
                );
            },

            getTableElement: function() {
                return _self.tableRef;
            },

            createTableElement: function() {
                var table = document.createElement('ra-table-framework');

                // no non custom columns to assign to the table, just return

                return table;
            },

            createRowHeaderColumn: function() {
                var column = document.createElement('ra-table-column');
                column.setAttribute('column-id', 'rowheader');
                column.setAttribute('region', 'left');
                column.set('displayFunctions', {
                    headerDisplay: _self.displayRowHeaderTitle,
                    rowDisplay: _self.displayRowHeader
                });
                return column;
            },

            displayRowHeaderTitle: function() {
                var content = document.createDocumentFragment();
                var title = document.createElement('span');
                title.textContent = NLS.get('requirements');
                content.appendChild(title);
                return content;
            },

            displayRowHeader: function(rowValue, rowData) {
                var content = document.createDocumentFragment();
                content.textContent = rowData.name;
                return content;
            },

            ////////////////////////////////////////////////////
            createThresholdColumn: function() {
                var column = document.createElement('ra-table-column');
                column.setAttribute('column-id', 'thresholds');
                column.setAttribute('region', 'left');
                column.set('displayFunctions', {
                    headerDisplay: this.displayThresholdHeader,
                    rowDisplay: this.displayThresholdRow
                });
                return column;
            },

            displayThresholdHeader: function() {
                var content = document.createDocumentFragment();
                var title = document.createElement('span');
                title.textContent = NLS.get('Thresholds');
                content.appendChild(title);
                return content;
            },

            displayThresholdRow: function(rowValue, rowData) {
                var content = document.createDocumentFragment();

                var lower =
                        typeof rowData.min !== 'undefined' &&
                        rowData.min.length > 0
                            ? rowData.min
                            : null,
                    upper =
                        typeof rowData.max !== 'undefined' &&
                        rowData.max.length > 0
                            ? rowData.max
                            : null;
                if (lower || upper) {
                    var rowFormulationContents = _self.reqUtils.getConstraintsAsHTML(
                        lower,
                        upper
                    );
                    content.appendChild(rowFormulationContents);
                }
                return content;
            },
            ////////////////////////////////////////////////////

            ////////////////////////////////////////////////////
            createObjectiveColumn: function() {
                var column = document.createElement('ra-table-column');
                column.setAttribute('column-id', 'objectives');
                column.setAttribute('region', 'left');
                column.set('displayFunctions', {
                    headerDisplay: this.displayObjectiveHeader,
                    rowDisplay: this.displayObjectiveRow
                });
                return column;
            },

            displayObjectiveHeader: function() {
                var content = document.createDocumentFragment();
                var title = document.createElement('span');
                title.textContent = NLS.get('Objectives');
                content.appendChild(title);
                return content;
            },

            displayObjectiveRow: function(rowValue, rowData) {
                var content = document.createDocumentFragment();

                if (rowData.objective) {
                    // TODO: figure out how to get the value of the objective if
                    // the objective is a target
                    var obj = _self.reqUtils.getObjectiveAsHTML(
                        rowData.objective,
                        rowData.parameterValue
                    );
                    content.appendChild(obj);
                }

                return content;
            },
            ////////////////////////////////////////////////////

            ////////////////////////////////////////////////////
            createParameterColumn: function() {
                var column = document.createElement('ra-table-column');
                column.setAttribute('column-id', 'parameters');
                column.setAttribute('region', 'left');
                column.set('displayFunctions', {
                    headerDisplay: this.displayParamHeader,
                    rowDisplay: this.displayParamRow
                });
                return column;
            },
            displayParamHeader: function() {
                var content = document.createDocumentFragment();
                var title = document.createElement('span');
                title.textContent = NLS.get('Parameters');
                content.appendChild(title);
                return content;
            },

            displayParamRow: function(rowValue, rowData) {
                var content = document.createDocumentFragment();
                if (rowData.type !== 'GROUP') {
                    // if it's a group, we create and populate the dropdown (a
                    // lot of elements, this needs to be optimized)
                    if (_self.parameterList) {
                        var selectedIndex = -1;
                        _self.parameterList.some(function(parameter, index) {
                            if (parameter.plmParameterId) {
                                var plmId = parameter.plmParameterId.split(
                                    '#'
                                )[0];
                                if (
                                    plmId === rowData.physicalId ||
                                    plmId === rowData.id
                                ) {
                                    selectedIndex = index;
                                    return true;
                                }
                            }
                            return false;
                        });
                        var comboBoxSettings = {
                            elementsList: _self.parameterList,
                            placeholder: '...',
                            selectedIndex: selectedIndex,
                            enableSearchFlag: true,
                            generateRegexpString: function(text) {
                                return text;
                            },
                            autocompleteFlag: false
                        };

                        var selectDropdown = new ComboBox(
                            comboBoxSettings
                        ).inject(content);

                        // when a selection has been made
                        selectDropdown.addEventListener('change', function(
                            evt
                        ) {
                            var reqToMerge = {
                                requirement: rowData,
                                id: selectDropdown.currentValue
                            };

                            _self.reqsToMerge[rowData.id] = reqToMerge;
                            _self.setParameterList();
                        });
                        selectDropdown.addEventListener(
                            'preselectionChange',
                            function(evt) {
                                //_self.tableRef.debounce('changeTracker',function(){
                                console.log('SELECTION: preselect');
                                console.log(evt);
                                //},10);
                            }
                        );

                        //
                        selectDropdown.addEventListener('keyup', function(evt) {
                            //_self.tableRef.debounce('filterTable',function(){
                            if (evt.key === 'Enter') {
                                evt.stopPropagation();
                                // selectDropdown.fire('change');
                            }
                            //},10);
                        });
                    }
                }
                // new Select();
                return content;
            },
            ////////////////////////////////////////////////////
            refreshTableData: function(callbackFunction) {
                // may need to manually delete the rowHierarchy, columnData, ...
                // to not cause a mem leak (testing?)
                _self.setRequirementsData(WidgetProxy.getRequirementsData());
                if (typeof callbackFunction === 'function') {
                    callbackFunction();
                }
            },
            _getRequirementsData: function(range, callback) {
                if (
                    _self.active &&
                    _self.requirementsData &&
                    typeof callback === 'function'
                ) {
                    var rows = range.rows,
                        _rows = [];

                    var returnedData = {
                        metaData: {
                            numRows: _self.requirementsData.numRows,
                            numAlternatives: 0
                        },
                        columnData: _self.requirementsData.columnData || []
                    };

                    var hierarchyparsefunction = function(rowgroup) {
                        var rowlist = [];
                        rowgroup.forEach(function(row, rowindex) {
                            var indexInRows = _rows.indexOf(row.id);
                            var hasChildren = false;
                            var temprow = {
                                id: row.id,
                                name: row.title || row.name, // use the title instead of the
                                // name, unless it's not
                                // defined ...
                                type: row.type
                            };
                            if (row.type === 'GROUP') {
                                temprow.children = hierarchyparsefunction(
                                    row.children
                                );
                                hasChildren = temprow.children.length > 0;
                            } else {
                                temprow.min = row.min;
                                temprow.max = row.max;
                                temprow.objective = row.objective;
                                temprow.parameterValue = row.parameterValue;
                                temprow.physicalId = row.physicalId;
                                temprow.priority = row.priority;
                                temprow.unit = row.unit;
                            }
                            if (indexInRows > -1 || hasChildren) {
                                // it was there, but as it may have children,
                                // just find it again :)
                                indexInRows = _rows.indexOf(row.id);
                                rowlist.push(temprow);
                            }
                            if (indexInRows > -1) {
                                _rows.splice(indexInRows, 1);
                            }
                        });
                        return rowlist;
                    };

                    if (typeof rows === 'undefined') {
                        returnedData.rowHierarchy =
                            _self.requirementsData.rowHierarchy || [];
                    } else {
                        _rows = rows.slice();
                        returnedData.rowHierarchy = hierarchyparsefunction(
                            _self.requirementsData.rowHierarchy || []
                        );
                    }

                    callback(returnedData);
                }
            },

            setRequirementsData: function(newRequirementsData) {
                _self.requirementsData = newRequirementsData;
                _self.active = true;
                //          _self.tableRef.set('dataAccessor',{
                //              'getData': _self._getRequirementsData,
                //              'timestamp': Date.now()
                //          });

                _self.tableRef.dataAccessor = {
                    getData: _self._getRequirementsData,
                    timestamp: Date.now()
                };
                _self.tableRef.set('dataAccessor', _self.tableRef.dataAccessor);
                _self.tableRef.notifyPath(
                    'dataAccessor',
                    _self.tableRef.dataAccessor
                );
            },

            setParameterList: function(parameterList) {
                //          _self.parameterList = parameterList;
                //          _self.resize();

                var paramList = [];
                parameterList = parameterList || _self.cachedList || [];
                parameterList.forEach(function(parameter, index) {
                    paramList.push({
                        labelItem: parameter.name,
                        valueItem: parameter.physticalId || parameter.id, // note: I don't think this has a
                        // physicalId ...
                        plmParameterId: parameter.plmParameterId
                    });
                });
                Object.keys(this.reqsToMerge).forEach(function(pId) {
                    var reqObj = this.reqsToMerge[pId],
                        found = false;
                    found = paramList.some(function(param) {
                        if (param.valueItem === reqObj.id) {
                            // id of the parameter we're
                            // binding the requirement to
                            param.plmParameterId =
                                reqObj.requirement.physicalId ||
                                reqObj.requirement.id; // map the plmId of
                            // the req to the
                            // plmParameterId
                            param.plmParameterId += '#RA'; // we need to know that we're
                            // importing the requirement into
                            return true;
                        }
                        //                  if(param.labelItem ===
                        //                  parameter.parameterName){
                        //                      param.plmParameterId = pId;
                        //                      return true;
                        //                  }
                    }, this);
                    //              if(!found){
                    //                  paramList.push({
                    //                      'labelItem':
                    //                      parameter.parameterName,
                    //                      'valueItem': parameter.id,
                    //                      'plmParameterId': pId
                    //                  });
                    //              }
                }, this);

                _self.cachedList = parameterList;
                _self.parameterList = paramList;
                _self.resize();
            },
            resize: function() {
                _self.tableRef.resetHeaders();
                _self.tableRef._resetSizing();
            },
            getMergeCallback: function() {
                worker.evaluate(
                    'mergeRequirements',
                    [_self.reqsToMerge],
                    function() {
                        if (widget) {
                            widget.dispatchEvent('onRequirementsUpdate');
                        }
                    }
                );
            }
        });

        return ReqMergeUI;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLandingPage',
    [
		'UWA/Core',
		'DS/UIKIT/Mask',
		'UWA/Class/View',
		'DS/W3DXComponents/Views/Layout/GridScrollView',
		'DS/SMAAnalyticsCommon/views/SMAAnalyticsTileView',
		'UWA/Class/Promise',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLauncher',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteCaseModel',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteDNDHelper',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsPLMBatchHelper',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteKWEUtils',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
		'DS/Windows/ImmersiveFrame',
		'DS/SMAAnalyticsCommon/SMAAnalyticsUtils',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequirementsUtils'
    ],
    function(
        Core,
        Mask,
        View,
        GridScrollView,
        ItemViewTile,
        Promise,
        WidgetProxy,
        Launcher,
        CaseModel,
        DND,
        PLMBatchHelper,
        KWEUtils,
        NLS,
        WUXImmersiveFrame,
        AnalyticsUtils,
        ReqUtils
    ) {
	'use strict';
	var _self = null;

	var LandingPage = GridScrollView.extend({
		defaultOptions: {
			useInfiniteScroll : true,
			usePullToRefresh : true,
			itemView : ItemViewTile
		},
		plmBatchHelper: {},
		tagName: 'div',
		className: 'link-detail',
		model: null,
		events: {
                onResizeClick: 'onResizeClick',
                workerLoaded: 'workerLoaded'
				},

		onResizeClick: function(event){
			console.log('landing onResizeClick');
		},
		
		onRender: function() {
			_self = this;
			_self.grid = this.nestedView.children;
                var iF = new WUXImmersiveFrame({
                    identifier: 'AdviseLiteLandingPageImmersiveFrame'
                });
			iF.inject(document.body);
			WidgetProxy.setImmersiveFrame(iF);
			AnalyticsUtils.setImmersiveFrame(iF);
            this.addEvent(
                'onItemViewSelect',
                this.itemViewSelect.bind(this),
                false,
                1000000
            );
			this._parent.apply(this, arguments);
			this.injectDropBox.call(this);
			if (! this.collection.hasEvent('onSync')){
				this.listenTo(this.collection, { onSync: function(){
					var caseId = widget.getValue('lastactivecase');
					if(caseId){
						var currentActiveModel = this.collection.findWhere({id:caseId});
						this.selectItemView(currentActiveModel);
					}
				}.bind(this) });
			}
                //          widget.raContextMenu =
                //          document.createElement('ra-contextmenu');
//			this.container.appendElement();
		},
		
//		_syncHandler: function(oCollection){
//			console.log('collection synced ...');
//		},
//		
//		onItemRendered: function(){
            //          this.listenTo(this.collection, { onSync:
            //          this._syncHandler.bind(this) });
//		},
//		
		itemViewSelect: function(grid, selectedTile){
			//FIXME: reinstantiate widgetProxy here
			WidgetProxy.flush();
			
			/*_self = this;
//			_self.grid = grid;
			var selectedCase = selectedTile.model;
			widget.setValue('raactivecase',selectedCase.id);
			var activeCollabSpace = selectedCase.get('project');
			if(activeCollabSpace){
				WidgetProxy.setActiveCollabSpace(activeCollabSpace);
			}*/
			
			// The first call returns a list of datasets tied to the case.
                // This list can be used to decide if the parameter merge ui for
                // the case needs the download KWE params button or not. On
                // success the list is set to WidgetProxy to ensure that its
                // available all through the app..
                /*WidgetProxy.getConnectedDatasets(selectedCase.id).done(function(
                    response
                ) {
				WidgetProxy.storeDataSetsList(response);
				// set up the requirements
                    _self.reqUtils =
                        _self.reqUtils ||
                        new ReqUtils({ caseId: selectedCase.id });
                    _self.reqUtils.setupRequirementsForCase(
                        selectedCase.id,
                        function() {
					// initialize the WebWorker
                            Launcher.initializeWebWorker(
                                selectedCase.id,
                                WidgetProxy.datasets
                            ).then(function() {
                                Launcher.startApp(
                                    selectedCase.id,
                                    true
                                ).done(function(data) {
                                    var openMergeUI = data
                                        ? data.openMergeUI
                                        : null;
                                    widget.dispatchEvent('workerLoaded', {
                                        openMergeUI: openMergeUI
						});	
					});
				});
                        }
                    );
			});*/
			
			//Batch_1ecf6e56-bbbc-488f-9fd6-cddab6a8862b 
			/* WidgetProxy.getConnectedDatasets(selectedCase.id).done(function(response){
				WidgetProxy.storeDataSetsList(response);
				Launcher.setupWorker();

				var kweUtils = new KWEUtils({
					'_mcsUrl': WidgetProxy.get3DSpaceURL(),
					'_eedUrl': WidgetProxy.getEEDURL(),
					'_caseId': selectedCase.id
				});
							
				kweUtils.testRun().then(function(KWEData){
                        window.worker.evaluate('setKWEData', KWEData,
                function(){ alert('loaded data into the worker');
						widget.dispatchEvent('workerLoaded');
					});
					
				}, function(err){
				});
				
				kweUtils.run().then(
					function(KWEData){
                            window.worker.evaluate('setKWEData', KWEData,
                function(){ console.log('Loading of KWE Data complete...');
							widget.dispatchEvent('workerLoaded');
						});
						
					}, function(err){
                            console.error('Loading of KWE Data failed...',
                [err]);
					}
				); 
				
			}); */
			/* _this.plmBatchHelper = new PLMBatchHelper({
				'simObjects' : ['44319B56EC2D0000649751578BA20200'],
				'mcsURL': WidgetProxy.get3DSpaceURL(),
				'eedURL' : WidgetProxy.getEEDURL(),
				'caseID' : selectedCase.id
			});
	
                _this.plmBatchHelper.executePLMBatch(function(){},
                function(){}); */
		},
		
		injectDropBox: function(){
                var gridContainer = this.container.getElement(
                    '.grid-container'
                );
			if(!gridContainer){
				return;
			}
			
			var dropEl = this.container.getElement('#landing-page-dropbox'),
				that = this,
				dropBox = null,
				dndHelper = null;
			
			if(typeof dropEl === 'undefined' || dropEl === null){
				dropBox = document.createElement('div');
				var dropText = document.createElement('div');
				dropText.textContent = NLS.get('drop_datasets');
				dropBox.appendChild(dropText);
				var icon = document.createElement('span');
				icon.classList.add('fonticon');
				icon.classList.add('fonticon-upload-cloud');
				icon.classList.add('fonticon-4x');
				dropBox.appendChild(icon);
				var suppText = document.createElement('div');
				suppText.textContent = NLS.get('allowed_dataset_types');
				dropBox.appendChild(suppText);
				dropBox.setAttribute('id', 'landing-page-dropbox');
				dropBox.classList.add('rae-dropbox');
                    gridContainer.parentNode.insertBefore(
                        dropBox,
                        gridContainer
                    );
			}
			
			var createPromiseObj = function(){
				var _that = that;
				var promiseObj = Promise.deferred();
				promiseObj.id = Date.now();
                promiseObj.promise.
                then(function(that) {
                	var data = JSON.parse(dndHelper.getConnectedResponse()),
					datasetList = Object.keys(data);
					datasetList.some(function(caseId){
						var existingModel = _that.collection.findWhere({id:caseId});
						
						if(existingModel){
							_that.selectItemView(existingModel);
						} else{
							WidgetProxy.getCaseInfo(caseId).then(function(response){
								var caseInfo = UWA.Json.xmlToJson(response).CaseInfo;
								var addedModel = _that.collection.addNewCaseModel(caseInfo);
								addedModel.set('image', WidgetProxy.get3DSpaceURL()+'/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
								_that.selectItemView(addedModel);
							}.bind(_that));
						}
						dndHelper.resetDropDeferred(createPromiseObj());
						return true;
					});	
                },
                function(that) {
                	dndOptions.view.render();
                	dndOptions.view.injectDropBox();
                });
				return promiseObj;
			};
			
			var dndOptions = {
							dropZone : dropBox || dropEl,
							dragClass : 'rae-dropbox-hover',
							dropDeferred: createPromiseObj(),
							view: that,
							type: 'DATASET',
                    persistCaseId: false, // make sure this box is reserved for
                    // creating new cases, not adding to
                    // the currently running case
							refreshOnDrop: false // disable the refresh
						};
			
			dndHelper = new DND(dndOptions);
		}, 
		createNewCaseModel: function(data,caseCreatedCallback){
			var that = this;
			
			var cloneAnalyticsCaseModel = function(doc, cid){
				var modl = new CaseModel(),
					ciNode = doc.getElementsByTagName('CaseInfo')[0],
                        dsNodeList =
                            ciNode.getElementsByTagName('dataSet') || [],
					dsModlList = [];
	
				modl.set('id', cid);
				modl.set('title', ciNode.getAttribute('title'));
				modl.set('name', ciNode.getAttribute('name'));
				modl.set('casename', ciNode.getAttribute('name'));
                    modl.set(
                        'image',
                        WidgetProxy.get3DSpaceURL() +
                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png'
                    );
				modl.set('subtitle', NLS.get('ra_case'));
                    modl.set(
                        'content',
                        NLS.get('owner') + ': ' + ciNode.getAttribute('owner')
                    );
				modl.set('owner', ciNode.getAttribute('owner'));
                    modl.set(
                        'description',
                        ciNode.getElementsByTagName('description')[0].
                            textContent
                    );
				modl.set('author', ciNode.getAttribute('originator'));
				modl.set('datasets', true);
				modl.set('datasetsCount', 0);
                    modl.set(
                        'recommendedImage',
                        WidgetProxy.get3DSpaceURL() +
                            '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png'
                    );
				modl.set('enoviaURL', WidgetProxy.get3DSpaceURL());
                    //              modl.set('project',
                    //              widget.getPreferenceLabel('collabspaces'));
			
				[].forEach.call(dsNodeList, function (dsNode) {
					var newds = {
                            id: dsNode.getAttribute('plmOID'),
                            name: dsNode.getAttribute('name'),
                            title: dsNode.getAttribute('title'),
                            // 'physicalId': item.physicalId, //FIXME: this is a
                            // bug. the physicalID needs to be returned in the
                            // case info response
                            type: dsNode.getAttribute('typeName')
								};
					dsModlList.push(newds);
				});
			
				modl.set('datasetsList', dsModlList);
				
				// add the new model to the collection
				that.collection.unshift(modl);
				that.collection.fetch();
				that._opn_new_case_ = cid;
				if(typeof caseCreatedCallback === 'function'){
					caseCreatedCallback(cid);
				}
				//that.openCreatedCase.call(that);
//				that.dispatchEvent('onPostInject');
			};
			var datasetList = Object.keys(data);
			datasetList.some(function(caseId){
                    WidgetProxy.getCaseInfo(caseId).then(
                        function(data) {
					cloneAnalyticsCaseModel(data, caseId);
				},
				function(err){
					console.error('Failure in getting case info.', err);
                        }
                    );
				return true;
			});
            }
  	});
	
  	return LandingPage;
    }
);

/* global worker */
/* jshint -W116 */
define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLite3DPlayer',
    [
   	'UWA/Class',
   	'UWA/Core',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',
	'DS/SimReviewHelper/SimReviewHelper',
	'DS/3DPlayHelper/3DPlayHelper',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/3DPlay/3DPlay'
    ],
    function(
        Class,
        UWACore,
        RAEPopover,
        SimReviewHelper,
        Sim3DPlayHelper,
        WidgetProxy,
        NLS
    ) {
	'use strict';

	var _self = null;

	var RAEPlayer = Class.extend({
		init: function(options){
			_self = this;
			_self.activePlayers = {};
			options = options || {};
			//this.immersiveFrame = options.immersiveFrame;
		},
		_createPopover : function(title,plmid){
			var playerRef = 'RAE-PSR-Player-'+plmid;
			
			if(!_self.activePlayers[playerRef]){
				var psrContainer = document.createElement('div');
				psrContainer.id = playerRef; 
				psrContainer.classList.add('ra-popover-container');
				psrContainer.classList.add('ra-3dplayer-container');
				psrContainer.style.position = '100%';
				psrContainer.style.height = '100%';
				var popover = new RAEPopover({
                        resizableFlag: true,
                        title: title || NLS.get('3d_player')
                        //                  'immersiveFrame':
                        //                  this.immersiveFrame
				});
                    popover.injectContent(
                        { body: psrContainer },
                        {
                            close: function() {
						if(psrContainer && psrContainer.parentNode){
                                    psrContainer.parentNode.removeChild(
                                        psrContainer
                                    );
						}
						delete _self.activePlayers[playerRef];
					}
                        }
                    );
				
				_self.activePlayers[playerRef] = {
                        psrContainer: psrContainer,
                        popover: popover,
                        player: null
				};
				popover.onResize();
			}
			return _self.activePlayers[playerRef];
		},
		loadPlayer : function(plmID,dType,title){
			var exper = '3DPlayModelViewer';
			if(dType !== 'VPMReference'){
				exper = '3DPlayFullSimulation';
			}
			var playerDefinition = {
					experience : exper,
					asset : {
						provider : 'EV6',
						physicalid : plmID,
						serverurl : WidgetProxy.get3DSpaceURL(),
	                    dtype: dType, 
	                    requiredAuth: 'passport',
	                    tenant: 'OnPremise'
					}
				};
			var playerSettings = {
					fullScreen: false,
					loading: 'autoplay'//,
//					simNavSyncServer: simNavSyncServerID
			};
			if(dType === 'VPMReference'){
				playerSettings.mode = 'review';
			}

//			if(title){
//				this.popover.setTitle(title);
//			}
//			if(this.popover){
//				this.popover.close();
//			}
//			this._createPopover(title);
//			if(!this.popover){
//				this._createPopover(title);
//			}
			var activePlayer = this._createPopover(title,plmID);
			if(!activePlayer.player){
				if(dType === 'DesignSight'){
					activePlayer.player = new PlayerSimReviewWeb({
                            container: activePlayer.psrContainer.id,
                            input: playerDefinition,
                            options: playerSettings
					});
				}else{
					activePlayer.player = new Sim3DPlayHelper({
                            container: activePlayer.psrContainer.id,
                            input: playerDefinition,
                            options: playerSettings
					});
				}
			}else{
				activePlayer.player.load({ 
					input:{
                            asset: playerDefinition.asset,
                            experience: playerDefinition.experience
					}
				});
			}
//			this.popover.show();
		}
	});
	
	return RAEPlayer;
    }
);

/* global widget */
/* global worker */
/* global Polymer */
/* jshint -W116 */

define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteParameterMergeUI',
    [
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
	'UWA/Core',
	'UWA/Utils',
	'UWA/Class',
	'DS/UIKIT/Input/Toggle',
	'DS/Controls/LineEditor',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteKWEUtils',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteComboBox',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
    ],
    function(
        WidgetProxy,
        UWA,
        Utils,
        Class,
        Toggle,
        DSInput,
        KWEUtils,
        ComboBox,
        NLS
    ) {
	'use strict';

	var _self = null;

	var ParamMergeUI = Class.extend({
		init : function(options){
			_self = this;

			if(options.model){
				this.model = options.model;
			}else{
				throw 'Model not provided as an option to Parameter Merge UI';
			}

			// create the table
			this.tableRef = document.createElement('ra-table-framework');
			this.tableRef.setDefaultGroupExpansion(function(group){
				// FIXME: should not be filtering by name
				// FIXME: NLS
				if(group.name === 'Dataset Attributes'){
					return false; // not expanded
				}
				return true;
			});
			this.tableRef.regions = 'left top right bottom';

			// indexed by the id of the parameter to merge in
			this.paramsToMerge = {};
			this.paramsToUnmerge = {}; // id of the param -> ra param it's merged to

			// create the columns and add them to the table
                Polymer.dom(this.tableRef).appendChild(
                    this.createRowHeaderColumn()
                );
                Polymer.dom(this.tableRef).appendChild(
                    this.createValueColumn()
                );
			//Polymer.dom(this.tableRef).appendChild(this.createIncludeColumn());
                Polymer.dom(this.tableRef).appendChild(
                    this.createParamSelectColumn()
                );

			Polymer.dom(this.tableRef).appendChild(this.createButtonRow());
		},

		getTableElement : function(){
			return _self.tableRef;
		},
		getFilterBar : function(){
			return _self.filterContainer;
		},

		createFilterBar : function(){
			_self.filterContainer = document.createElement('div');
                _self.textFilter = new DSInput({
                    placeholder: NLS.get('Search') + ' ...'
                });
			_self.textFilter.inject(this.filterContainer);

			// listen the 'change' event
                // right now I'm looking at the uncommittedChange event, but I'm
                // not sure if that will continue to be exposed as it's not
                // technically documented (useful though :) )
                _self.textFilter.addEventListener(
                    'uncommittedChange',
                    function() {
                        _self.tableRef.debounce(
                            'filterTable',
                            function() {
                                //                  var value =
                                //                  _self.textFilter.valueToCommit
                                //                  || _self.textFilter.value || '';
                                var value =
                                    _self.textFilter.valueToCommit || '';
					_self.nameFilterValue = value;
					_self.refreshTableData(function(){
						_self.resize();
					});
                            },
                            500
                        );
                    }
                );
                //          _self.textFilter.addEventListener('change', function
                //          (){
//				_self.tableRef.debounce('filterTable',function(){
                ////                    var value =
                ///_self.textFilter.valueToCommit || _self.textFilter.value ||
                ///'';
//					var value = _self.textFilter.value || '';
//					_self.nameFilterValue = value;
//					_self.refreshTableData(function(){
//						_self.resize();
//					});
//				},500);
//			});
		},

		createButtonRow : function(){
			var row = document.createElement('ra-table-row');
			row.setAttribute('row-id','BUTTON');
			row.setAttribute('row-height','40');
			row.set('displayFunctions',{
				rowDisplay: function(rowValue,rowData){
					var content = document.createDocumentFragment();
					var button = document.createElement('button');
					button.textContent = NLS.get('Load_Parameters');
					button.onclick = function(){
						var id = rowData.id,
                                groupid = id
                                    ? id.substring(0, id.lastIndexOf('-'))
                                    : null;
						if(groupid){
                                worker.evaluate(
                                    'getKWEData',
                                    [groupid],
                                    function(dataset) {
                                        // When any of the "Load Parameters" button
                                        // is clicked we lauch the PLM batch for all
                                        // datasets
								var simObjs = WidgetProxy.getSimulationObjectsConnectedToCase();
								if (! simObjs || simObjs.length === 0){
									alert(NLS.get('no_sim_objs_ided'));
									return;
								}

								var kweUtils = new KWEUtils({
                                            _mcsUrl: WidgetProxy.get3DSpaceURL(),
                                            _eedUrl: WidgetProxy.getEEDURL(),
                                            _caseId: _self.model.id,
                                            onMonitor: function(messageObject) {
                                                _self.kweDetails.textContent +=
                                                    messageObject.completeness *
                                                        100 +
                                                    '% : ' +
                                                    (messageObject.message ||
                                                        'Monitoring progress of KWE Load');
                                                _self.kweDetails.textContent +=
                                                    '\n';
//										console.log('KWE MONITOR -- ' + (messageObject.message || 'Monitoring progress of KWE Load'));
//										console.log('KWE MONITOR -- Completeness: ' + messageObject.completeness);
										if(_self.progressBar){
                                                    _self.progressBar.style.width =
                                                        messageObject.completeness *
                                                            100 +
                                                        '%';
										}
									}
								});
                                        _self.progressBarWrapper.classList.add(
                                            'ra-parameter-load-active'
                                        );
                                        kweUtils.run(simObjs).then(
                                            function(KWEData) {
                                                // Using only the 0 th element in
                                                // the returned response. Index 1 is
                                                // for the file data
                                                widget.kweFileIndex =
                                                    KWEData[1];
                                                window.worker.evaluate(
                                                    'setKWEData',
                                                    KWEData[0],
                                                    function() {
                                                        _self.refreshTableData(
                                                            function() {
											_self.resize();
                                                            }
                                                        );
                                                        console.log(
                                                            'Loading of KWE Data complete...'
                                                        );
                                                    }
                                                );
                                            },
                                            function(err) {
                                                console.error(
                                                    'Loading of KWE Data failed...',
                                                    [err]
                                                );
                                            }
                                        );
                                    }
                                );
						}
					};
					content.appendChild(button);
					return content;
				}
			});
			return row;
		},

		//---------------------------------------------------------------
		// header column
		createRowHeaderColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','rowheader');
			column.setAttribute('column-width',200);
			column.setAttribute('region','left');
			column.set('displayFunctions',{
				headerDisplay: _self.displayRowHeaderTitle,
				rowDisplay: _self.displayRowHeader
			});
			return column;
		},
		displayRowHeaderTitle : function(){
			var content = document.createDocumentFragment();
			var title = document.createElement('span');
			title.textContent = NLS.get('Data');
			content.appendChild(title);
			return content;
		},
		displayRowHeader : function(rowValue,rowData){
			var content = document.createDocumentFragment();
//			if(rowData.type !== 'BUTTON'){
			var fullName = rowData.name,
				nameParts = fullName ? fullName.split('\\') : [],
				displayName = fullName;
			if(nameParts.length > 1){
                    displayName =
                        nameParts[0] +
                        '\\...\\' +
                        nameParts[nameParts.length - 1];
			}
			var textContent = document.createElement('span');
			textContent.title = fullName;
			textContent.textContent = displayName;
			content.appendChild(textContent);
//			}else{
                //              // TODO: this should be a row that takes up the
                //              full width ...
//
//			}
			return content;
		},

		//---------------------------------------------------------------

		//---------------------------------------------------------------
		// value column
		createValueColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','values');
			column.setAttribute('region','left');
			column.set('displayFunctions',{
				headerDisplay: this.displayValueHeader,
                    rowDisplay: this.displayValueRow
			});
			return column;
		},
		displayValueHeader : function(){
			var content = document.createDocumentFragment();
			var title = document.createElement('span');
			title.textContent = NLS.get('Values');
			content.appendChild(title);
			return content;
		},
		displayValueRow : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			if(rowData.type !== 'GROUP'){
				if(rowData.type === 'INTEGER' || rowData.type === 'REAL'){
                        if (
                            typeof rowData.min !== 'undefined' &&
                            typeof rowData.max !== 'undefined'
                        ) {
						if(rowData.min !== rowData.max){
                                content.textContent =
                                    rowData.min + '-' + rowData.max;
						}else{
							content.textContent = rowData.min;
						}
					}
				}else if(rowData.type === 'STRING'){
					content.textContent = rowData.value;
				}
			}
			return content;
		},

		//---------------------------------------------------------------

		//---------------------------------------------------------------
		// value column
		createIncludeColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','included');
			column.setAttribute('region','left');
			column.setAttribute('column-width',40);
			column.set('displayFunctions',{
				headerDisplay: this.displayIncludeHeader,
                    rowDisplay: this.displayIncludeRow
			});
			return column;
		},
		displayIncludeHeader : function(){
			var content = document.createDocumentFragment();
			var title = document.createElement('span');
			title.textContent = NLS.get('Included');
			content.appendChild(title);
			return content;
		},
		displayIncludeRow : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			if(rowData.type !== 'GROUP' && rowData.type !== 'BUTTON'){
                    var checkbox = new Toggle({
                        type: 'checkbox',
                        value: 'included',
                        label: ''
                    });
				if(rowData.isIncluded){
					checkbox.check();
				}
//				checkbox.onChange = function(){
//					var isChecked = this.isChecked(),
//						isDisabled = this.isDisabled();
//					console.log('checked: '+isChecked);
//					console.log(this.isDisabled());
//					if(worker){
//						worker.evaluate('setParameterAsIncluded',[{
//							'parameter':rowData,
//							'id': parameterID
//						}],function(){
//							if(widget){
//								widget.dispatchEvent('onParameterMerge');
//							}
//						});
//					}
//				};
				checkbox.inject(content);
			}
			return content;
		},

		//---------------------------------------------------------------

		//---------------------------------------------------------------
		// value column
		createParamSelectColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','parameters');
			column.setAttribute('region','left');
			column.set('displayFunctions',{
				headerDisplay: this.displayParamHeader,
                    rowDisplay: this.displayParamRow
			});
			return column;
		},
		displayParamHeader : function(){
			var content = document.createDocumentFragment();
			var title = document.createElement('span');
			title.textContent = NLS.get('Parameters');
			content.appendChild(title);
			return content;
		},
		displayParamRow : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			if(rowData.type !== 'GROUP' && rowData.type !== 'BUTTON'){
                    // if it's a group, we create and populate the dropdown (a
                    // lot of elements, this needs to be optimized)
				if(_self.parameterList){
					var selectedIndex = -1;
					_self.parameterList.some(function(parameter,index){
                            // if this row is in paramsToMerge find the index in
                            // the parameter

                            if (
                                parameter.valueItem === rowData.id ||
                                (parameter.mergedFromVars &&
                                    parameter.mergedFromVars.indexOf(
                                        rowData.id
                                    ) > -1)
                            ) {
							selectedIndex = index;
							return true;
						}
						return false;
					});
					var comboBoxSettings = {
							elementsList: _self.parameterList,
							placeholder: '...',
							selectedIndex: selectedIndex,
							enableSearchFlag: true,
							generateRegexpString: function (text) {
								return text;
							},
							autocompleteFlag: false
					};

                        var selectDropdown = new ComboBox(
                            comboBoxSettings
                        ).inject(content);

					// when a selection has been made
                        selectDropdown.addEventListener('change', function(
                            evt
                        ) {
						//_self.tableRef.debounce('changeTracker',function(){
						var parameterName = rowData.name;
                            if (
                                selectDropdown.selectedIndex === -1 &&
                                selectDropdown.myInput.value !== ''
                            ) {
							parameterName = selectDropdown.myInput.value;
						}
						console.log('name: '+parameterName);

                            // id is the RA parameter we're merging this
                            // into
						var paramToMerge = {
                                parameterName: parameterName,
                                parameter: rowData,
                                id:
                                    selectDropdown.currentValue ||
                                    'NEWPARAM_' +
                                        Object.keys(_self.paramsToMerge).length
						};

						_self.paramsToMerge[rowData.id] = paramToMerge;
						_self.setParameterList();
					});

					selectDropdown.addEventListener('keyup', function (evt){
						//_self.tableRef.debounce('filterTable',function(){
						if(evt.key === 'Enter'){
							evt.stopPropagation();
							//selectDropdown.fire('change');
						}
						//},10);
					});
                    }
			}
			//new Select();
			return content;
		},

		//---------------------------------------------------------------

		refreshTableData: function(callback){
			this.updateDataSetsList(); // force a refresh ...
			callback();
		},

		updateDataSetsList : function(){
			_self.tableRef.dataAccessor = {
                    getData: function(range, callback) {
						var options = {
							typeFilter : null,
							nameFilter : _self.nameFilterValue || ''
						};
						if(typeof worker !== 'undefined'){
                            worker.evaluate(
                                'getParameterMergeData',
                                [range, options],
                                callback
                            );
						}
					},
                    timestamp: Date.now()
				};
			_self.tableRef.set('dataAccessor',_self.tableRef.dataAccessor);
                _self.tableRef.notifyPath(
                    'dataAccessor',
                    _self.tableRef.dataAccessor
                );
		},

		// given a list of parameters either cached or from the worker,
		// create a parameterList that can be consumed by the WebUX ComboBox
		setParameterList : function(parameterList){
                // make sure the parameterList is set, either from what is
                // provided, or what is cached
			parameterList = parameterList || _self.cachedList || [];

                // first index is a new parameter that can potentially be
                // created :)
                var paramList = [
                    {
                        labelItem: NLS.get('New_Parameter'),
                        valueItem:
                            'NEWPARAM_' + Object.keys(this.paramsToMerge).length
                    }
                ];

			parameterList.forEach(function(parameter,index){
                    // we need to un-merge any parameters that are going to be
                    // merged to a different parameter
//				Object.keys(this.paramsToMerge).forEach(function(pId){
                    //                  if(Array.isArray(parameter.mergedFromVars)
                    //                  && parameter.name ===
                    //                  this.paramsToMerge[pId].parameterName){
                    //                      var i =
                    //                      parameter.mergedFromVars.indexOf(pId);
//						parameter.mergedFromVars.splice(i,1);
                    //                      this.paramsToUnmerge[pId] =
                    //                      parameter.id; // keep track of
                    //                      parameters that we need to unmerge
//					}
//				},this);
				paramList.push({
                        labelItem: decodeURIComponent(parameter.name),
                        valueItem: parameter.id,
                        mergedFromVars: parameter.mergedFromVars
				});
			},this);

                // search the params that we're merging to see if there are any
                // that are merging to the same parameter, otherwise, create the
                // object and add it to the 'mergedFromVars'
			Object.keys(this.paramsToMerge).forEach(function(pId){
				var parameter = this.paramsToMerge[pId],
					found = false;
				found = paramList.some(function(param){
                        //                  if(param.labelItem ===
                        //                  parameter.parameterName){
					if(param.valueItem === parameter.id){
						param.mergedFromVars.push(pId);
						return true;
					}
				},this);
				if(!found){
					paramList.push({
                            labelItem: parameter.parameterName,
                            valueItem: parameter.id,
                            mergedFromVars: [pId]
					});
				}
			},this);

			/* parameterList.forEach(function(parameter,index){
				paramList.push({
						'labelItem': parameter.name,
						'valueItem': parameter.id,
						'mergedFromVars': parameter.mergedFromVars
				});
			}); */

			_self.cachedList = parameterList;
			_self.parameterList = paramList;
			_self.resize();
		},
		resize : function(){
			_self.tableRef.resetHeaders();
			_self.tableRef._resetSizing();
		},

		getMergeFooter : function(){
			// container
			_self.mergeFooter = document.createElement('div');
			_self.mergeFooter.classList.add('ra-parammerge-footer');
			// top row of the container
			var topRow = document.createElement('div');
			topRow.classList.add('ra-parammerge-footer-row');
			// Progress Bar
			_self.progressBarWrapper = document.createElement('div');
			_self.progressBarWrapper.classList.add('ra-parameter-load');
//			_self.progressBarWrapper.classList.add('ra-parameter-load-active');
			_self.progressBar = document.createElement('div');
			_self.progressBar.classList.add('ra-parameter-load-progress');
			_self.progressBarWrapper.appendChild(_self.progressBar);
			topRow.appendChild(_self.progressBarWrapper);

			_self.kweDetailsBtn = document.createElement('div');
                _self.kweDetailsBtn.classList.add(
                    'ra-parameter-load-detailsBtn'
                );
			_self.kweDetailsBtn.textContent = 'Show Details';
                // TODO: setup a callback for onclick, this should be a button
                // and not a div
			_self.kweDetailsBtn.onclick = function(){
                    _self.mergeFooter.classList.toggle(
                        'ra-parameter-load-details-show'
                    );
			};
			topRow.appendChild(_self.kweDetailsBtn);

			// append the top row to the container
			_self.mergeFooter.appendChild(topRow);

			_self.kweDetails = document.createElement('div');
			_self.kweDetails.classList.add('ra-parameter-load-details');
			_self.mergeFooter.appendChild(_self.kweDetails);

			return _self.mergeFooter;
		},
		getMergeCallback : function(){
                worker.evaluate(
                    'mergeParameters',
                    [
                        _self.paramsToMerge,
                        _self.paramsToUnmerge,
                        { caseName: _self.model.get('title') }
                    ],
                    function() {
				_self.paramsToMerge = {};
				_self.paramsToUnmerge = {};
				if(widget){
					widget.dispatchEvent('onParameterMerge');
				}
                    }
                );
		}
	});

	return ParamMergeUI;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteFileUtils',
    [
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'UWA/Class',
        'UWA/Class/Promise',
        'DS/ZipJS/zip-fs'
    ],
    function(WidgetProxy, Class, Promise, Zipjs) {
        'use strict';

        var _self = null;

        var FileUtils = Class.extend({
            _thumbCache: {},
            init: function(args) {
                _self = this;
            },

            getTestExecutionThumbnail: function(plmID, callback) {
                var currentThumbUrl =
                    WidgetProxy.get3DSpaceURL() +
                    '/webapps/SMAAnalyticsLiteWidget/assets/icons/thumb_default.png';
                if (typeof callback === 'function') {
                    callback(currentThumbUrl);
                }
            },

            getThumbnailFromProcess: function(plmId, callback){
            	var that = _self,
            	url = _self._thumbCache[plmId];
            	if(url){
            		callback(url)
            	}else{
	            	WidgetProxy.getProcessImage(plmId).then(function(response){
	            		url=null;
	            		if(response[0].image){
	            			url = response[0].image;
	            		}else{
	            			url = WidgetProxy.get3DSpaceURL() +
	                            '/webapps/SMAAnalyticsLiteWidget/assets/icons/thumb_process_default.png';
	            		}
	            		that._thumbCache[plmId] = url;
	            		callback(url);
	            	});
            	}
            },
            
            getThumbnail: function(plmId, callback){
            	var that = _self,
            	url = _self._thumbCache[plmId];
            	if(url){
            		callback(url)
            	}else{
            		WidgetProxy.getThumbnail(plmId).then(function(response){
                		url=WidgetProxy.get3DSpaceURL() +
                        	'/webapps/SMAAnalyticsLiteWidget/assets/icons/thumb_default.png';
                		if(response){
                			response = JSON.parse(response);
                		}
                		if(response.data && response.data.length>0 && response.data[0].thumbnail){
                			url = response.data[0].thumbnail;
                			if(url.charAt(0)==='/'){
                				url = WidgetProxy.get3DSpaceURL()+url;
                			}
                		}
                		that._thumbCache[plmId] = url;
                		callback(url);
                	});
            	}
            },
            
            getSimObjThumb: function(plmId, callback) {
                var url = _self._thumbCache[plmId];
                if (url) {
                    callback(url);
                } else {
                    _self.getThumbnailFromSimObj(plmId, function(thumbnailUrl) {
                        if (thumbnailUrl) {
                            _self._thumbCache[plmId] = thumbnailUrl;
                        }
                        callback(thumbnailUrl);
                    });
                }
            },

            //
            getThumbnailFromSimObj: function(plmID, callback) {
                var deferred = Promise.deferred();
                WidgetProxy.getTicketAndDownloadResultFile(plmID).done(function(
                    blob
                ) {
                    if (typeof URL.createObjectURL !== 'function') {
                        URL.createObjectURL = window.top.URL.createObjectURL;
                    }
                    var url = URL.createObjectURL(blob);
                    var zipEntries = new Zipjs.fs.FS();
                    Zipjs.workerScriptsPath =
                        'scripts/ThreeDS/Visualization/zip-js/';
                    zipEntries.importHttpContent(
                        { serverurl: '', filename: url, proxyurl: 'none' },
                        false,
                        function() {
                            var filename = 'thumbnail.PNG'; // is this right?
                            var entry;

                            for (
                                var i = 0;
                                i < zipEntries.entries.length;
                                i++
                            ) {
                                entry = zipEntries.entries[i];
                                if (
                                    entry.name &&
                                    entry.name.
                                        toLowerCase().
                                        indexOf('thumbnail') > -1 &&
                                    entry.name.toLowerCase().indexOf('png') > 0
                                ) {
                                    filename = entry.name;
                                    if (
                                        filename.
                                            toLowerCase().
                                            indexOf('mises') > -1
                                    ) {
                                        break;
                                    }
                                }
                            }
                            entry = zipEntries.find(filename);
                            var mimeType = 'image/PNG';
                            var currentThumbUrl = '';
                            if (entry) {
                                entry.getBlob(mimeType, function(data) {
                                    currentThumbUrl = URL.createObjectURL(data);
                                    deferred.resolve(currentThumbUrl);
                                    if (typeof callback === 'function') {
                                        callback(currentThumbUrl);
                                    }
                                });
                            } else {
                                currentThumbUrl =
                                    WidgetProxy.get3DSpaceURL() +
                                    '/webapps/SMAAnalyticsLiteWidget/assets/icons/thumb_simObj.png';
                                deferred.resolve(currentThumbUrl);
                                if (typeof callback === 'function') {
                                    callback(currentThumbUrl);
                                }
                            }
                        }
                    );
                });
                return deferred.promise;
            },

            getThumbnailForRow: function(rowId, callback) {
                worker.evaluate('getAllFilesForRowIdAsArray', [rowId], function(
                    fileObjList
                ) {
                    var plmObjPromises = [];
                    var thumbToUse = '';
                    var plmThumb = false;
                    fileObjList.forEach(function(fileObj) {
                    	if(UWA.is(fileObj)){
                    		var type = fileObj.type,
                            thumbnailURL = fileObj.url; // no thumbs yet ...

	                        if (fileObj.type === 'PLMOBJECT') {
	                            plmObjPromises.push(
	                                _self.getThumbnailFromSimObj(fileObj.plmID)
	                            );
	                        } else if (
	                            type.toLowerCase().indexOf('3dxml') > -1 &&
	                            thumbnailURL.toLowerCase().indexOf('smaadvise') < 0
	                        ) {
	                            // use this one, should overwrite any associated
	                            // with non 3dxml files
	                            thumbToUse = thumbnailURL;
	                        } else if (thumbToUse.length === 0 && fileObj.isImage) {
	                            // no thumb found yet, use this one!
	                            thumbToUse = thumbnailURL;
	                        }
                    	}
                    });

                    var useCallback = function() {
                        if (
                            thumbToUse.length > 0 &&
                            typeof callback === 'function'
                        ) {
                            if (plmThumb) {
                                callback(thumbToUse);
                            }
                            // if widget is defined, look for the thumbnail
                            // in the raeFileIndex Object
                            if (
                                widget &&
                                typeof widget.raeFileIndex[thumbToUse] !==
                                    'undefined' &&
                                widget.raeFileIndex[thumbToUse] !== null
                            ) {
                                //                          image.src =
                                //                          widget.raeFileIndex[thumbToUse];
                                callback(thumbToUse);
                            }
                        }
                    };
                    if (plmObjPromises.length > 0) {
                        Promise.all(plmObjPromises).then(function(thumbURLs) {
                            thumbURLs.some(function(thumbURL) {
                                if (typeof thumbURL !== 'undefined') {
                                    thumbToUse = thumbURL;
                                    plmThumb = true;
                                    return true; // use the first one
                                    // that comes back
                                    // defined
                                }
                            });
                            if (thumbToUse.length > 0) {
                                useCallback();
                            }
                        }, useCallback);
                    } else {
                        useCallback();
                    }
                });
            }
        });

        return FileUtils;
    }
);

/* global worker */
/* jshint -W116 */
define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteFormulationUI',
    [
        'UWA/Class',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',
        'DS/Controls/ComboBox',
        'DS/Controls/LineEditor',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils'
    ],
    function(Class, WidgetProxy, NLS, RAEPopover, WUXComboBox, WUXLineXEditor,AnalyticsUtils) {
        'use strict';

        var _self = null;

        var FormulationUI = Class.extend({
            init: function(options) {
                _self = this;

                options = options || {};
                this.popovers = {};
                this.target = options.target || document.body;
            },

            // display the comments ui for the given row
            show: function(param, formulationChangeCallback) {
                this._createPopover(param, formulationChangeCallback);
            },
            _createPopover: function(param, callback) {
                var playerRef = 'RAE-Formulation-' + param.id;
                if (!this.popovers[playerRef]) {
                    var pmBody = document.createElement('div');
                    pmBody.classList.add('ra-pmui');
                    pmBody.classList.add('ra-pmui-container');

                    var formulationContainer = document.createElement('div');
                    formulationContainer.id = 'RAE-formulation-container'; // FIXME: there can be
                    // more than one comment
                    // container!!!
                    formulationContainer.classList.add('ra-popover-container');
                    formulationContainer.classList.add('ra-formulation-ui');

                    //              formulationContainer.formulationChangeCallback
                    //              = formulationChangeCallback;

                    var changes = { parameterId: param.id };

                    formulationContainer.appendChild(
                        _self._createFormulationUI(param, changes)
                    );

                    // FIXME: NLS for title
                    var popover =
                        _self.popover ||
                        new RAEPopover({
                            resizableFlag: true,
                            height: 300,
                            width: 250,
                            title:
                                NLS.get('requirements_for') + ' ' + param.name //,
                        });

                    popover.injectContent(
                        { body: formulationContainer },
                        {
                            ok: function() {
                                _self.updateFormulation(changes, callback);
                                changes = null;
                                delete _self.popovers[playerRef];
                            },
                            //                  'apply':function(){
                            //                      _self.updateFormulation(changes,callback);
                            //                  },
                            close: function() {
                                changes = null;
                                delete _self.popovers[playerRef];
                            }
                        }
                    );

                    this.popovers[playerRef] = {
                        ref: popover,
                        changes: changes
                    };

                    // resize and open
                    popover.onResize();
                    popover.open();
                }
            },
            _createFormulationUI: function(data, changes) {
                // FIXME: needs to handle multiple windows ...
                var content = document.createDocumentFragment(),
                    upperThreshold = null,
                    lowerThreshold = null;
                if (data.constraints) {
                    data.constraints.forEach(function(constraint) {
                        //                  var obj =
                        //                  document.createElement('span');
                        var less = null,
                            greater = null;
                        if (constraint.conditions) {
                            constraint.conditions.forEach(function(condition) {
                                if (condition.type === 'GREATER_THAN') {
                                    greater = condition.boundValue;
                                } else if (condition.type === 'LESS_THAN') {
                                    less = condition.boundValue;
                                }
                            });
                        }
                        //                  obj.classList.add('ra-constraint-label');
                        if (less !== null && greater === null) {
                            upperThreshold = less;
                        } else if (less === null && greater !== null) {
                            lowerThreshold = greater;
                        }
                    });
                }

                // setup the containers
                var rContainer = document.createElement('div');
                content.appendChild(rContainer);
                var pContainer = document.createElement('div');
                content.appendChild(pContainer);
                var utContainer = document.createElement('div');
                content.appendChild(utContainer);
                var ltContainer = document.createElement('div');
                content.appendChild(ltContainer);
                var oContainer = document.createElement('div');
                content.appendChild(oContainer);
                var targetContainer = document.createElement('div');
                if (!data.objective || data.objective.type !== 'TARGET') {
                    targetContainer.style.display = 'none';
                } else {
                    targetContainer.style.display = 'block';
                }
                content.appendChild(targetContainer);

                // range
                var label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('range') + ':';
                rContainer.appendChild(label);
                var rValue = document.createElement('span');
                if(data.min === data.max){
                    rValue.textContent = data.max;
                }else{
                    rValue.textContent = '['+data.min+' ... '+data.max+']';
                }
                rContainer.appendChild(rValue);
                
                // priority
                label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('priority') + ':';
                pContainer.appendChild(label);
                var pElem = new WUXComboBox({
                    elementsList: this._getPriorityList(),
                    currentValue:
                        typeof data.priority !== 'undefined' ? data.priority : 5
                }).inject(pContainer);
                pElem.elements.container.style.display = 'block';
                pElem.addEventListener('change', function() {
                    changes.priority = pElem.currentValue;
                });

                // upper threshold
                label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('upper_threshold') + ':';
                utContainer.appendChild(label);
                var utElem = new WUXLineXEditor({
                    value: upperThreshold
                }).inject(utContainer);
                utElem.addEventListener('change', function() {
                	var min = lowerThreshold;
                	if(typeof changes.lowerThreshold  !== 'undefined'){
                    	// use the updated lower threshold
                		min = changes.lowerThreshold;
                	}
                	
                	var nValue = parseFloat(utElem.value);
                	
                	// the undefined check may not be necessary below, null definitely is
                	if(min !== null && typeof min !== 'undefined' && nValue && nValue < min){
            			// alert the user that this is bad
        				AnalyticsUtils.showErrorNotification('',NLS.get('UPPER_LOWER_THAN_LOWER'));
        				if(typeof changes.upperThreshold !== 'undefined'){
        					utElem.value = changes.upperThreshold;
        				}else if(upperThreshold !== null){
        					utElem.value = upperThreshold;
        				}else{
        					utElem.value = '';
        				}
        				return false;
                	}else{
                        changes.upperThreshold = utElem.value;
                	}
        			// okay, we're good
                });

                // lower threshold
                label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('lower_threshold') + ':';
                ltContainer.appendChild(label);
                var ltElem = new WUXLineXEditor({
                    value: lowerThreshold
                }).inject(ltContainer);
                ltElem.addEventListener('change', function() {

                	var max = upperThreshold;
                	if(typeof changes.upperThreshold  !== 'undefined'){
                    	// use the updated lower threshold
                		max = changes.upperThreshold;
                	}
                	
                	var nValue = parseFloat(ltElem.value);
                	
                	// the undefined check may not be necessary below, null definitely is
                	if(max !== null && typeof max !== 'undefined' && nValue !== '' && nValue > max){
            			// alert the user that this is bad
        				AnalyticsUtils.showErrorNotification('',NLS.get('LOWER_HIGHER_THAN_UPPER'));
        				if(typeof changes.lowerThreshold !== 'undefined'){
        					ltElem.value = changes.lowerThreshold;
        				}else if(lowerThreshold !== null){
        					utElem.value = lowerThreshold;
        				}else{
        					ltElem.value = '';
        				}
                	}else{
                        changes.lowerThreshold = ''+ltElem.value;
                	}
                });

                // objective
                label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('objective') + ':';
                oContainer.appendChild(label);
                var oElem = new WUXComboBox({
                    elementsList: this._getObjectiveList(),
                    currentValue:
                        typeof data.objective !== 'undefined' &&
                        data.objective.type
                            ? data.objective.type
                            : ''
                }).inject(oContainer);
                oElem.elements.container.style.display = 'block';
                oElem.addEventListener('change', function() {
                    if (oElem.currentValue !== 'TARGET') {
                        targetContainer.style.display = 'none';
                    } else {
                        targetContainer.style.display = 'block';
                    }
                    changes.objective = oElem.currentValue;
                    changes.value =
                        typeof changes.value !== 'undefined'
                            ? changes.value
                            : data.objective.value;
                });
                // target (only show if objective is Target)
                label = document.createElement('label');
                label.classList.add('wux-layouts-treeview-label');
                label.textContent = NLS.get('Target') + ':';
                targetContainer.appendChild(label);
                var tElem = new WUXLineXEditor({
                    value:
                        typeof data.objective !== 'undefined' &&
                        typeof data.objective.value
                            ? data.objective.value
                            : ''
                }).inject(targetContainer);
                tElem.addEventListener('change', function() {
                    changes.objective =
                        typeof changes.objective !== 'undefined'
                            ? changes.objective
                            : data.objective.type;
                    changes.value = tElem.value;
                });
                content.appendChild(targetContainer);

                return content;
            },
            _getPriorityList: function() {
                return [
                    { labelItem: NLS.get('must_have'), valueItem: 0 },
                    { labelItem: '1', valueItem: 1 },
                    { labelItem: '2', valueItem: 2 },
                    { labelItem: '3', valueItem: 3 },
                    { labelItem: '4', valueItem: 4 },
                    { labelItem: '5', valueItem: 5 }
                ];
            },
            _getObjectiveList: function() {
                return [
                    { labelItem: 'None', valueItem: '' },
                    { labelItem: NLS.get('Maximize'), valueItem: 'MAXIMIZE' },
                    { labelItem: NLS.get('Minimize'), valueItem: 'MINIMIZE' },
                    { labelItem: NLS.get('Target'), valueItem: 'TARGET' }
                ];
            },
            updateFormulation: function(changes, somecallback) {
                // send the formulation to the worker
                worker.evaluate(
                    'setFormulationForParam',
                    [changes],
                    somecallback
                );
            }
        });

        return FormulationUI;
    }
);

define(
    'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteCompareTable',
    [
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
	'UWA/Core',
	'UWA/Utils',
	'UWA/Class',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteFileUtils',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequirementsUtils',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteCommentUI',
	'UWA/Class/Promise',
	'DS/ZipJS/zip-fs',
	'DS/UIKIT/DropdownMenu',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteDNDHelper',
	'DS/DataDragAndDrop/DataDragAndDrop',
        'DS/SMAAnalyticsLiteWidget/utils/AdviseLiteDownloadOps',
	'DS/Windows/Dialog',
	'DS/Controls/LineEditor',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLite3DPlayer',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteFormulationUI'
    ],
    function(
        WidgetProxy,
        UWA,
        Utils,
        Class,
        FileUtils,
        RequirementsUtils,
        CommentUI,
        Promise,
        Zipjs,
        DropdownMenu,
        DNDHelper,
        DSDnD,
        DownloadOps,
        DSDialog,
        DSInput,
        RAE3DPlayer,
        RAEPopover,
        NLS,
        FormulationUI
    ) {
	'use strict';

	var _self = null;
			
	var CompareTable = Class.extend({
		init : function(options){
			_self = this;
			_self.diffViewType = 'actual';
			_self.caseId = options.caseId;
			
            // this will need to be refreshed every time someone adds a new
            // siulation object into the case
			this.simObjList = WidgetProxy.getSimulationObjectsConnectedToCase();
			
			this.reqUtils = new RequirementsUtils({
                caseId: _self.caseId
			});
			
            this.commentUI = new CommentUI({});
			this.formulationUI = new FormulationUI();
			
            // TODO: when done with this class, migrate ra-table-framework
            // to ra-table then rename the element here to 'ra-table'
			this.tableRef = this.createBasicTableElement();
            Polymer.dom(this.tableRef).appendChild(
                this.createRowHeaderColumn()
            );
            Polymer.dom(this.tableRef).appendChild(
                this.createRequirementsColumn()
            );
            
			Polymer.dom(this.tableRef).appendChild(this.createFileRow());
			Polymer.dom(this.tableRef).appendChild(this.createPSRRow());
			
			this.fileUtils = new FileUtils();
		},
		getTableElement : function(){
			return _self.tableRef;
		},
		displayColumnHeader : function(rowValue,rowData){
			// create a document fragment to append the content to
			var content = document.createDocumentFragment();

			var baselineMarker = document.createElement('div');
			baselineMarker.classList.add('ra-baseline-flag');
			// only make active if you're not in the percentage view
            if (
                _self.diffViewType !== 'actual' &&
                rowValue.id === _self.baselineColumnId
            ) {
				baselineMarker.classList.add('ra-baseline-flag-active');
			}
			content.appendChild(baselineMarker);
			
			var columnHeaderElem = this;
			var imageContainer = document.createElement('div');
			imageContainer.classList.add('ra-column-header-thumb');
			imageContainer.classList.add('ra-table');
			
			if(rowValue.dType === 'DesignSight'){
                imageContainer.classList.add('ra-column-header-3dplayable-thumb');
            }
                
			
            // the mousedown/mouseup events allow for drag/drop reorder of
            // column headers the debouncer inside of this allows for click
            // events on the image (open 3dplay/psr)
			imageContainer.addEventListener('mousedown', function() {
                _self.tableRef.debounce(
                    'clickChecker',
                    function() {
                        var clickEvent = document.createEvent(
                            'MouseEvents'
                        );
				clickEvent.initEvent ('mousedown', true, true);
				columnHeaderElem.dispatchEvent (clickEvent);
                    },
                    5
                );
			});
			imageContainer.addEventListener('mouseup', function() {
				_self.tableRef.cancelDebouncer('clickChecker');
    			var clickEvent = document.createEvent ('MouseEvents'); 
				clickEvent.initEvent ('mouseup', true, true);
				columnHeaderElem.dispatchEvent (clickEvent);
			});
			
			// FIXME: need to get around the scoping constraints ...
			var image = document.createElement('img');	
			image.ondragstart = function() { return false; };
			image.draggable = false;
			image.classList.add('ra-table');
            _self.getColumnHeaderThumbnail(rowValue, function(
                    thumbnailUrl
                ) {
				if(thumbnailUrl){
					image.src = thumbnailUrl;
				}
			});
			if(typeof rowValue.PLMOID !== 'undefined' && rowValue.dType === 'DesignSight'){
                _self.setupPSR(
                    rowValue.PLMOID,
                    imageContainer,
                    rowValue.name,
                    rowValue.dType
                );
			}
			
			imageContainer.appendChild(image);
			content.appendChild(imageContainer);
			
			var headerTitle = document.createElement('div');
			headerTitle.classList.add('ra-table-header-name');
			
			var title = document.createElement('span');
			title.textContent = rowValue.name;
			title.title = rowValue.name;
			
			headerTitle.appendChild(title);
			
			var recommendDropdownText = NLS.get('Recommend'),
				recommendDropdownClass = '';
			if(rowValue.isRecommended){
				this.classList.add('ra-recommended-alt');
				recommendDropdownText = NLS.get('Recommended');
				recommendDropdownClass = 'ra-is-recommended';
				
				var recommendedTagWrapper = document.createElement('span');
				recommendedTagWrapper.classList.add('ra-recommended-tag');
				var recommendedTag = document.createElement('span');
				recommendedTag.classList.add('fonticon');
				recommendedTag.classList.add('fonticon-trophy');
				recommendedTagWrapper.appendChild(recommendedTag);
				content.appendChild(recommendedTagWrapper);
			}

                var commentText =
                    rowValue.commentCount + ' ' + NLS.get('Comment');
			if(rowValue.commentCount !== 1){
                    commentText =
                        rowValue.commentCount + ' ' + NLS.get('Comments');
			}
			
			var likeText = NLS.get('Like'),
				likeClass = '',
                    likeCount = Array.isArray(rowValue.likes)
                        ? rowValue.likes.length
                        : 0;
			
			// FIXME: less than optimal ...
			if(rowValue.liked && likeCount === 1){
				likeText = NLS.get('Liked');
				likeClass = 'ra-like-byUser';
			}else if(rowValue.liked && likeCount > 1){
				likeClass = 'ra-like-byUser';
				likeText = likeCount + ' ' + NLS.get('Likes');
			}else if(likeCount > 1){
                    (likeText = likeCount + ' ' + NLS), get('Likes');
                }

                // TODO: headerDisplay is going to be removed ... so this check
                // should be removed
			if(typeof rowValue.headerDisplay !== 'undefined'){
				var menu = document.createElement('span');
				menu.classList.add('fonticon');
				menu.classList.add('fonticon-down-open');
				menu.classList.add('header-dropdown');
				
				var menuItems = [];
				
				// we need 3dplay option only for DesignSight objects
				if(rowValue.dType === 'DesignSight'){
				    menuItems.push({
                                name: '3dplay',
                                text: "View in 3D Player",
                                fonticon: 'eye'
                            });
				}                
                menuItems.push({
                                name: 'comment',
                                text: commentText,
                                fonticon: 'comment'
                            });
                menuItems.push({
                                name: 'like',
                                text: likeText,
                                fonticon: 'thumbs-up',
                                className: likeClass
                            });
                menuItems.push({
                                name: 'recommend',
                                text: recommendDropdownText,
                                fonticon: 'trophy',
                                className: recommendDropdownClass
                            });
                            
				var dropdownmenu = new DropdownMenu({
				    target: menu,
				    items: menuItems,
				    events: {
				        onClick: function (e, item) { 
				        	if(item.name === 'recommend'){
                                    //                              rowValue.id
                                    //                              === the
                                    //                              rowId
                                    worker.evaluate(
                                        'toggleRecommendedRowId',
                                        [rowValue.rowID],
                                        function() {
				        			_self.tableRef._resetSizing();
                                        }
                                    );
				        	}else if(item.name === 'comment'){
                                    _self.commentUI.showCommentsForRowId(
                                        rowValue,
                                        function() {
				        			_self.tableRef._resetSizing();
                                        }
                                    );
				        	}else if(item.name === 'like'){
                                    worker.evaluate(
                                        'toggleLikeOnRow',
                                        [rowValue.rowIndex],
                                        function() {
				        			_self.tableRef._resetSizing();
                                        }
                                    );
                                } else if (item.name === '3dplay') {
                                    if (!_self.SimulationPlayer) {
                                        _self.SimulationPlayer = new RAE3DPlayer();
                                    }
                                    _self.SimulationPlayer.loadPlayer(rowValue.PLMOID, rowValue.dType, rowValue.name);
				        	}
			        	}
				    }
				});
				headerTitle.appendChild(menu);
				content.appendChild(headerTitle);

				if(!isNaN(rowValue.score) && rowValue.rank > -1){
					var columnMetaData = document.createElement('div');
					columnMetaData.classList.add('ra-column-meta');
					var metaContent = NLS.get('Rank') +
	                    ': ' +
	                    rowValue.rank +
	                    ' | ' +
	                    NLS.get('Score') +
	                    ': ' +
	                    Math.round(rowValue.score * 100) / 100;
                    columnMetaData.textContent = metaContent;
                    columnMetaData.title = metaContent;
					content.appendChild(columnMetaData);
				}
			}
			return content;
		},
		getColumnHeaderThumbnail : function(columnData,callback){
			if(typeof columnData.PLMOID !== 'undefined'){
				if(columnData.dType==='Simulation'){
					_self.fileUtils.getThumbnailFromProcess(
						columnData.PLMOID,
	                    callback	
					);
				}else{
					_self.fileUtils.getThumbnail(
                        columnData.PLMOID,
                        callback
                	);
				}
					/*var isSimObj = null;
					_self.simObjList.some(function(simObj){
						if(simObj.physicalId === columnData.PLMOID){
							isSimObj = simObj;
							return true;
						}
					});
					if(isSimObj !== null){
	                    _self.fileUtils.getSimObjThumb(
	                        columnData.PLMOID,
	                        callback
	                    );
					}else if(columnData.dType === 'Test Execution'){
	                    _self.fileUtils.getTestExecutionThumbnail(
	                        columnData.PLMOID,
	                        callback
	                    );
	                }
				}*/
			}else{
                _self.fileUtils.getThumbnailForRow(columnData.id, function(
                    thumbnail
                ) {
                    if (
                        typeof widget.raeFileIndex[thumbnail] !==
                            'undefined' &&
                        widget.raeFileIndex[thumbnail] !== null
                    ) {
						callback(widget.raeFileIndex[thumbnail]);
					}else{
						callback(thumbnail);
					}
				});
			}
		},
		
		displayRowInColumn : function(rowValue,rowData){
			if(rowData.type === 'FILE'){
				return _self.fileRowDisplay.call(this,rowValue, rowData);
                } else if (rowData.type === 'PLMOBJECT') {
                    // psr should check
                    // for SIMOBJECT, but
                    // it seems to come
                    // through like this
				return _self.psrDisplay.call(this,rowValue, rowData);
			}else if(rowData.type === 'REAL'){
				return _self.realRowDisplay.call(this, rowValue, rowData);
			}else if(rowData.type === 'INTEGER'){
                    return _self.integerRowDisplay.call(
                        this,
                        rowValue,
                        rowData
                    );
			}else{
				return _self.textRowDisplay.call(this,rowValue, rowData);
			}
		},
		
		// function used to display content of cells containing REAL numbers
		realRowDisplay : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			
			// get the 
			_self.sigFigs = WidgetProxy.getSignificantDigits();
                if (
                    typeof rowValue !== 'undefined' &&
                    typeof rowValue.value !== 'undefined' &&
                    !isNaN(rowValue.value)
                ) {
                    // FIXME: toLocaleString needs to check for locale, not
                    // everyone uses the . as the decimal delimiter
                    var textContent = Number(rowValue.value).
                        toPrecision(_self.sigFigs).
                        toLocaleString();
                    if (
                        _self.diffViewType !== 'percentage' &&
                        rowData.unit &&
                        rowData.unit.length > 0
                    ) {
					textContent += ' ' + rowData.unit;
				}
				content.textContent = textContent;
			
				this.classList.add('ra-number-column');
				
                    // check against the objectives and add classes
                    // appropriately
                    _self.checkAgainstObjective.call(
                        this,
                        rowData,
                        rowValue.value
                    );
	
				// check for threshold violations
				if(rowValue.thresholdViolation){
					_self.markInfeasible.call(this,content);
				}
			}
                //          if(!_self.checkThresholdViolations.call(this,
                //          rowData, rowValue)){
//				_self.markInfeasible.call(this,content);
//			}
			
			return content;
		},

            // function used to display content of cells containing INTEGER
            // numbers
		integerRowDisplay : function(rowValue, rowData){
			var content = document.createDocumentFragment();
                if (
                    typeof rowValue !== 'undefined' &&
                    typeof rowValue.value !== 'undefined' &&
                    !isNaN(rowValue.value)
                ) {
                    // FIXME: toLocaleString needs to check for locale, not
                    // everyone uses the . as the decimal delimiter
				var textContent = parseInt(rowValue.value).toLocaleString();
                    if (
                        _self.diffViewType !== 'percentage' &&
                        rowData.unit &&
                        rowData.unit.length > 0
                    ) {
					textContent += ' ' + rowData.unit;
				}
				content.textContent = textContent;
			
				this.classList.add('ra-number-column');
				
                    // check against the objectives and add classes
                    // appropriately
                    _self.checkAgainstObjective.call(
                        this,
                        rowData,
                        rowValue.value
                    );
				
				// check for threshold violations
				if(rowValue.thresholdViolation){
					_self.markInfeasible.call(this,content);
				}
                    //          if(!_self.checkThresholdViolations.call(this,
                    //          rowData, rowValue)){
	//				_self.markInfeasible.call(this,content);
	//			}
			}
			return content;
		},
		
		// default row display function
		textRowDisplay : function(rowValue, rowData){
			var content = document.createDocumentFragment();
			if(typeof rowValue !== 'undefined'){
				content.textContent = rowValue;
			}

			this.classList.add('ra-string-column');
			
			return content;
		},
		
		checkAgainstObjective : function(rowData, rowValue){
			if(_self.baselineColumnId === this.getColumnId()){
				this.classList.add('ra-is-baseline');
			}
                if (
                    _self.baselineColumnId !== this.getColumnId() &&
                    (_self.diffViewType === 'percentage' ||
                        _self.diffViewType === 'magnitude')
                ) {
				// we're not in the baseline column
//				if(_self.diffViewType === 'PERCENTAGE'){
//					content.textContent += '%';
//				}
                    if (
                        rowData.objective &&
                        rowData.objective.type === 'MAXIMIZE'
                    ) {
					if(rowValue < 0){
						this.classList.add('ra-objective-worse');
					}else if(rowValue > 0){
						this.classList.add('ra-objective-better');
					}
                    } else if (
                        rowData.objective &&
                        rowData.objective.type === 'MINIMIZE'
                    ) {
					if(rowValue > 0){
						this.classList.add('ra-objective-worse');
					}else if(rowValue < 0){
						this.classList.add('ra-objective-better');
					}
                    } else if (
                        rowData.objective &&
                        rowData.objective.type === 'TARGET'
                    ) {
					if(rowValue === 0){
						this.classList.add('ra-objective-better');
					}
					// mark non matches as worse?  provide a range?
				}
			}else{
                    if (
                        rowData.objective &&
                        Array.isArray(rowData.objective.bestRowIds)
                    ) {
					try{
                            if (
                                rowData.objective.bestRowIds.indexOf(
                                    this.parentElement.columnData.rowID
                                ) > -1
                            ) {
							this.classList.add('ra-objective-better');
						}
					}catch(e){}
				}
			}
		},
		
		checkThresholdViolations : function(rowData, rowValue){
			var isFeasible = true;
                // cycle through constraints on this row to get the conditions
                // and check for violations
			if(rowData.constraints){
				rowData.constraints.forEach(function(constraint){
					if(constraint.conditions){
						constraint.conditions.forEach(function(condition){
                                if (
                                    (condition.type === 'GREATER_THAN' &&
                                        condition.boundValue >
                                            Number(rowValue)) ||
                                    (condition.type === 'LESS_THAN' &&
                                        condition.boundValue < Number(rowValue))
                                ) {
								isFeasible = false;
							}
						},this);
					}
				},this);
			}
			return isFeasible;
		},
		
		markInfeasible : function(content){
			this.classList.add('ra-constraint-violated');
			var warn = document.createElement('span');
			warn.classList.add('fonticon');
			warn.classList.add('fonticon-attention');
			warn.classList.add('ra-constraint-violated-flag');
			warn.title = NLS.get('Threshold_Violation');
			content.insertBefore(warn,content.childNodes[0] || null);
		},
		
		fileRowDisplay : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			if(typeof rowValue !== 'undefined'){
				var image = document.createElement('img');
				image.classList.add('file-thumbnail');				
                    if (
                        typeof rowValue.thumbnail !== 'undefined' &&
                        rowValue.thumbnail !== null
                    ) {
					image.src = rowValue.thumbnail;
				} else {
					var val = rowValue;
					if(typeof val.url !== 'undefined'){
						val = val.url;
					}
					if (widget.raeFileIndex){
                            if (widget.raeFileIndex[val]) {
							image.src = widget.raeFileIndex[val];
                            }
					}else if(widget.kweFileIndex){
                            if (widget.kweFileIndex[val]) {
							image.src = widget.kweFileIndex[val];
					}
				}
                    }
				content.appendChild(image);
			}
			return content;
		},
		psrDisplay : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			var thumb = document.createElement('img');
			var dType = rowValue.dType;
			thumb.classList.add('file-thumbnail');
			content.appendChild(thumb);
			if(!rowValue || !rowValue.plmID || !WidgetProxy){
				return content;
			}

			// TODO: figure out what to feed the PSR as the title ...
                _self.setupPSR(
                    rowValue.plmID,
                    thumb,
                    rowData.displayName,
                    dType
                );
			
			_self.getThumbnailImage(rowValue.plmID,thumb);
                _self.fileUtils.getSimObjThumb(rowValue.plmID, function(
                    thumbnailUrl
                ) {
				if(thumbnailUrl){
					thumb.onload = function (){
		            	//this.onload = '';
                            // FIXME: this should fire the resize event on
                            // the cell/row, not the whole table
						if(this.parentNode){
                                if (
                                    typeof this.parentNode.fitToContent ===
                                    'function'
                                ) {
								this.parentNode.fitToContent();
							}else{
                                    if (
                                        this.parentNode.parentNode &&
                                        typeof this.parentNode.parentNode.
                                            fitToContent === 'function'
                                    ) {
									this.parentNode.parentNode.fitToContent();
								}
							}
						}
		            	this.parentNode.resize();
		        	};
		        	thumb.setAttribute('src',thumbnailUrl);
				}
			});
			
			return content;
		},
		
		// FIXME: d9u - this isn't using the PSR, this is using sp-3DPlayer
		setupPSR : function(plmID,element,title,dType){
			element.onclick = function(){
				if(!_self.SimulationPlayer){
					_self.SimulationPlayer = new RAE3DPlayer();
				}
				_self.SimulationPlayer.loadPlayer(plmID,dType,title);
			};
		},
		createBasicTableElement : function(){
			var table = document.createElement('ra-table-framework');
			table.set('displayFunctions',{
                    rowDisplay: _self.displayRowInColumn,
                    headerDisplay: _self.displayColumnHeader
			});
			return table;
		},
		
		// --------------------------------------------------
		// Setup the row header column ...
		// --------------------------------------------------
		
		createRowHeaderColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','rowheader');
			column.setAttribute('region','left');
			column.setAttribute('column-width','200');
			column.set('displayFunctions',{
				headerDisplay: _self.displayDSDropTitle,
				rowDisplay: _self.displayRowHeader
			});
			return column;
		},
//		displayRowHeaderTitle : function(columnData){
//			var content = document.createDocumentFragment();
//			content.textContent = ''; //'Parameter Names';
//			this.classList.add('ra-rowhead-colhead');
//			displayDSDropTitle
//			return content;
//		},
		editingParameterName : null,
		parameterEditUI : null,
		displayRowHeader : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			
			// create the span (not a span any more)
			var contentContainer = document.createElement('div');
			var contentSpan = document.createElement('span');
			contentSpan.classList.add('ra-paramater-display-name');
			contentSpan.textContent = rowData.name;
			contentSpan.title = rowData.name;
			contentContainer.appendChild(contentSpan);

			// single click functionality
			var singleFunc = function(){
//				if(!_self.parameterEditUI){
//
//					_self.parameterEditUI = new DSDialog({
//						title: 'Edit Parameter',
                    //                      content:
                    //                      document.createElement('div'), //
                    //                      some dummy content
//					});
//					// Listen to the close event
                    //                  _self.parameterEditUI.addEventListener('close',
                    //                  function (e) {
                    //                    console.log('Close on dialog : ' +
                    //                    e.dsModel.title);
//					});
//					
//					_self.modal = true;
//					
                    //                  // using moduleContent as the container
                    //                  positions this in teh center of the
                    //                  module, it will go on top of everything
                    //                  in the module var parentElem =
                    //                  document.querySelector('.moduleContent')
                    //                  || document.body;
//					_self.parameterEditUI.inject(parentElem);
//				}else{
                    //                  // modify the content to the parameter
                    //                  popover _self.parameterEditUI.content =
                    //                  document.createElement('div');
//					_self.parameterEditUI.show();
//				}
			};
			// doubleclick functionality
			var doubleFunc = function(){
				contentSpan.classList.add('hidden');
                var editor = new DSInput({ value: rowData.name });
				editor.addEventListener('click', function(event){
					event.stopPropagation();
				});
				var changeEvent = function (){
					var val = editor.value || '';
					if(val && val.length > 0){
						contentSpan.textContent = val;
						// TODO: send update to the worker
						if(editor){
							editor.value = val;
						}
						if(rowData){
							rowData.name = val;
						}
                        worker.evaluate('modifyParameter', [
                            { id: rowData.id, displayName: val }
                        ]);
					}
					editor.remove();
					contentSpan.classList.remove('hidden');
				};
				editor.addEventListener('change', changeEvent);
				editor.addEventListener('blur', changeEvent);
				editor.inject(contentContainer);
				editor._myInput.focus();
			};
			
			// we're editing this guy :)
			if(_self.editingParameter === rowData.id){
				doubleFunc();
			}
			
			var callingFunc = singleFunc;
			var firing = false;
			var timer = null;
			contentContainer.onclick = function(){
                    if (timer) {
                        clearTimeout(timer);
                    }
			    callingFunc = singleFunc;
			    firing = true;
			    timer = setTimeout(function() { 
			    	callingFunc();
			    	callingFunc = singleFunc;
			    	firing = false;
			    }, 250);   
			};
			contentContainer.ondblclick = function(){
				callingFunc = doubleFunc;
			};
			//contentContainer.classList.add();

			content.appendChild(contentContainer);
			return content;
		},
		
		// --------------------------------------------------
		
		createDSDropElement: function(){
			var dropBox = document.createElement('div');
			var dropText = document.createElement('div');
			dropText.textContent = NLS.get('drop_dataset_or_requirement');
			dropBox.appendChild(dropText);
			var icon = document.createElement('span');
			icon.classList.add('fonticon');
			icon.classList.add('fonticon-upload-cloud');
			icon.classList.add('fonticon-3x');
			dropBox.appendChild(icon);
//			var suppText = document.createElement('div');
                //          suppText.textContent =
                //          NLS.get('allowed_dataset_types');
//			dropBox.appendChild(suppText);
			dropBox.setAttribute('id', 'rae-addDSorReq-dropbox');
			dropBox.classList.add('rae-dropbox');

			var dndHelper = null;

			var createPromiseObj = function(){
				var promiseObj = Promise.deferred();
				promiseObj.id = Date.now();

                    promiseObj.promise.then(
                        function() {
                            WidgetProxy.getConnectedDatasets(
                                _self.caseId
                            ).done(function(response) {
						WidgetProxy.storeDataSetsList(response);
						_self.simObjList = WidgetProxy.getSimulationObjectsConnectedToCase();
						var connectedDS = dndHelper.getConnectedResponse();
                                if (
                                    typeof connectedDS !== 'undefined' &&
                                    connectedDS !== null
                                ) {
							connectedDS = JSON.parse(connectedDS);

                                    var downldOps = new DownloadOps({
                                        mcsURL: WidgetProxy.get3DSpaceURL(),
                                        caseID: _self.caseId
                                    });
                                    var typeChecker = dndHelper.checkConnectedTypes(
                                        connectedDS
                                    );
							if(typeChecker.datasets){
								// datasets were added
                                        downldOps.
                                            runDownloadForAddedDatasets(
                                                connectedDS[_self.caseId]
                                            ).
                                            then(function() {
                                                widget.dispatchEvent(
                                                    'workerLoaded'
                                                );
                                            });
                                    } else if (typeChecker.requirements) {
                                        // no datasets were added, but
                                        // requirements were ...
                                    	_self.reqUtils.setupRequirementsForCase(
                                            _self.caseId,
                                                function (requirements) {
                                                    worker.evaluate(
                                                        'autoMapRequirements',
                                                        [requirements],
									function(){
                                                            if (widget) {                                                                
                                                                widget.dispatchEvent('onRequirementsUpdate');
                                                                widget.dispatchEvent('onRequirementsAttached');
                                                            }
                                                        }
                                                );
									}
								);
							}
						}
					});

                            _self.tableRef.debounce(
                                'leavedatadrop',
                                function() {
                                    _self.tableRef.classList.remove(
                                        'ra-datadrop'
                                    );
                                    _self.tableRef.externRemoveCustomColumn(
                                        'datasetdrop'
                                    ); // TODO: this should not be
                                    // hardcoded
						// TODO: remove the column
                                },
                                10
                            );
					dndHelper.resetDropDeferred(createPromiseObj());
                        },
                        function(err) {
                            _self.tableRef.debounce(
                                'leavedatadrop',
                                function() {
                                    _self.tableRef.classList.remove(
                                        'ra-datadrop'
                                    );
                                    _self.tableRef.externRemoveCustomColumn(
                                        'datasetdrop'
                                    ); // TODO: this should not
                                    // be hardcoded
						// TODO: remove the column
                                },
                                10
                            );
					dndHelper.resetDropDeferred(createPromiseObj());
                        }
                    );
				
				return promiseObj;
			};
			
			var dndOptions = {
				dropZone : dropBox,
				dragClass : 'rae-dropbox-hover', // TODO: consider changing ...
				dropDeferred: createPromiseObj(),
				view: this,
				type: ['DATASET','REQUIREMENT'], //  we'll accept datasets or requirements
				caseId: _self.caseId,
				refreshOnDrop: false
			};
			
			dndHelper = new DNDHelper(dndOptions);
			return dropBox;
		},
		
		// --------------------------------------------------
		displayDSDropTitle: function(){
			var content = document.createDocumentFragment();
			
			// makes sure that the 'this' being passed along is the table
			var dropZone = _self.createDSDropElement();
//			fonticon fonticon-upload-cloud fonticon-4x
//			dropZone.setAttribute('id', 'rae-addDS-dropbox');
//			dropZone.textContent = 'Datasets';
			this.classList.add('rae-add-dataset-container');
			dropZone.classList.add('rae-add-dataset');
			content.appendChild(dropZone);
			return content;
		},
		createDSDropColumn: function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','datasetdrop');
			column.setAttribute('region','right');
			column.setAttribute('column-width','100');
			column.set('displayFunctions',{
				headerDisplay: _self.displayDSDropTitle,
				rowDisplay: function(){
					return document.createDocumentFragment();
				}
			});
			return column;
		},

		// --------------------------------------------------
		// Setup the requirements column ...
		// --------------------------------------------------
		
		createRequirementsColumn : function(){
			var column = document.createElement('ra-table-column');
			column.setAttribute('column-id','requirements');
			column.setAttribute('region','left');
			column.setAttribute('column-width','120');
			column.set('displayFunctions',{
				headerDisplay: _self.displayRequirementsTitle,
				rowDisplay: _self.displayRequirementsInRow
			});
			return column;
		},
		displayRequirementsTitle : function(columnData){
			var content = document.createDocumentFragment();
		
			var baselineMarker = document.createElement('div');
			baselineMarker.classList.add('ra-baseline-flag');
			baselineMarker.classList.add('ra-baseline-flag-active');
			baselineMarker.classList.add('ra-baseline-flag-label');
			var baselineLabel = document.createElement('span');
			baselineLabel.textContent = NLS.get('baseline'); // TODO: NLS
			baselineMarker.appendChild(baselineLabel);
			content.appendChild(baselineMarker);
			
			// makes sure that the 'this' being passed along is the table
			var dropZone = _self.reqUtils.createDropBox();
//			dropZone.setAttribute('id', 'ra-req-dropbox');
			dropZone.classList.add('rae-req-header-contents');
			var dropIcon = document.createElement('div');
			dropIcon.classList.add('rae-req-icon');
			dropZone.appendChild(dropIcon);
			var headerTitle = document.createElement('div');
			headerTitle.classList.add('ra-table-header-name');
			headerTitle.textContent = NLS.get('requirements');
			dropZone.appendChild(headerTitle);
			
			content.appendChild(dropZone);
			return content;
		},
		requirementsChangeCallback : function(){
			_self.resize();
		},
		displayRequirementsInRow : function(rowValue,rowData){
			var content = document.createDocumentFragment();
			if(rowData.type !== 'GROUP' && rowData.type !== 'STRING'){
                    var rowFormulationContents = _self.reqUtils.getRowFormulationContents(
                        rowData
                    );
				rowFormulationContents.onclick = function(){
                        //                  // FIXME: if you leave a case and
                        //                  this isn't closed it will still be
                        //                  there var formulationContainer = new
                        //                  RAEPopover({
//						'width': 600, // the form gets 
//						'resizableFlag':true,
                        //                      'title': rowData.name + '
                        //                      Formulation'//,
//						//'visibleFlag': false,
                        //                      //'immersiveFrame':
                        //                      _self.immersiveFrame
//					});
                        ////                    var pmBody =
                        ///document.createElement('div'); /
                        ///pmBody.classList.add('ra-pmui'); /
                        ///pmBody.classList.add('ra-pmui-container');
                        //
                        //                  var formulationUIContainer =
                        //                  document.createElement('div'); var
                        //                  elem =
                        //                  _self.reqUtils.openFormulationUI(rowData,_self.requirementsChangeCallback);
//					elem.inject(formulationUIContainer);
//			//pmBody.appendChild(pmBodyMain);
//
//					formulationContainer.injectContent({
//						'body': formulationUIContainer
//					},{
                        //// 'ok':_this.requirementsMap.getMergeCallback, /
                        ///'apply':_this.requirementsMap.getMergeCallback
//					});
//					formulationContainer.onResize();
//					formulationContainer.open();
					
                        _self.formulationUI.show(
                            rowData,
                            _self.requirementsChangeCallback
                        );
				};
				content.appendChild(rowFormulationContents);
			}
			return content;
		},
		
		createIntegerRow : function(){
			var row = document.createElement('ra-table-row');
			row.setAttribute('row-id','INTEGER');
			row.set('displayFunctions',{
				rowDisplay: function(){
					var content = document.createDocumentFragment();
					content.textContent = 'integer row ...';
					return content;
				}
			});
			return row;
		},
//		
//		createIntegerRow : function(){
//			var row = document.createElement('ra-table-row');
//			row.setAttribute('row-id','INTEGER');
//			row.set('displayFunctions',{
//				rowDisplay: function(){
//					var content = document.createDocumentFragment();
//					content.textContent = 'integer row ...';
//					return content;
//				}
//			});
//			return row;
//		},
		
		resize : function(){
			_self.tableRef._resetSizing();	
		},
		
		refresh : function(){
			if(typeof _self.tableRef.set === 'function'){
                    _self.tableRef.set(
                        'dataAccessor',
                        this.getTableDataCallbackObject()
                    );
			}
		},
		
		refreshRows : function(){
			_self.tableRef.refreshRowData();
		},
		
		setDiffViewType : function(type){
			_self.diffViewType = type.toLowerCase();
			_self.tableRef.classList.remove('ra-diffview-actual');
			_self.tableRef.classList.remove('ra-diffview-percentage');
			_self.tableRef.classList.remove('ra-diffview-magnitude');
                _self.tableRef.classList.add(
                    'ra-diffview-' + _self.diffViewType
                );
		},
		
		getTableDataCallbackObject : function(){
			return {
                    getData: function(range, callback) {
					// make sure the baseline is marked
                        _self.baselineColumnId = _self.tableRef.getColumnIdAtIndex(
                            0
                        );
					var options = {
                            baselineId: _self.baselineColumnId,
                            view: _self.diffViewType.toUpperCase()
					};
					if(typeof worker !== 'undefined'){
                            worker.evaluate(
                                'getCompareTableData',
                                [range, options],
                                callback
                            );
					}
				},
				//'caseId': this.model.get('id'),
                    timestamp: Date.now(),
                    WidgetProxy: WidgetProxy // FIXME: needed?
			};
		},
		
//		createButtonRow : function(){
//			var row = document.createElement('ra-table-row');
//			row.setAttribute('row-id','BUTTON');
//			row.setAttribute('row-height','40');
//			row.set('displayFunctions',{
//				rowDisplay: function(){
//					var content = document.createDocumentFragment();
//					var button = document.createElement('button');
//					button.textContent = 'Add Parameters';
//					button.onclick = function(){
//						if(widget){
//							widget.dispatchEvent('workerLoaded',{'force':true});
//						}
//					};
//					content.appendChild(button);
//					return content;
//				}
//			});
//			return row;
//		},
		createFileRow : function(){
			var row = document.createElement('ra-table-row');
			row.setAttribute('row-id','FILE');
			row.setAttribute('row-height','100');
			return row;
		},
		createPSRRow : function(){
			var row = document.createElement('ra-table-row');
			row.setAttribute('row-id','PLMOBJECT');
			row.setAttribute('row-height','100');
			return row;
		},
		
		showColumn : function(columnId){
			this.tableRef.showColumn(columnId);
		},
		hideColumn : function(columnId){
			this.tableRef.hideColumn(columnId);
		}
	});
	
	return CompareTable;
    }
);

//XSS_CHECKED
define(
    'DS/SMAAnalyticsLiteWidget/pages/compare/SMAAnalyticsLiteComparePage',
    [
        'UWA/Core',
        'DS/Core/Core',
        'DS/UIKIT/Mask',
        'UWA/Class/Promise',
        'DS/W3DXComponents/Views/Item/TileView',
        'text!SMAAnalyticsLiteWidget/pages/compare/SMAAnalyticsLiteComparePage.html',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsCommon/SMAAnalyticsCommonProxy',
        'DS/Panels/SidePanel',
        'DS/Controls/Expander',
        'DS/Controls/Button',
        'DS/Controls/ButtonGroup',
        'DS/UIKIT/Spinner',
        'DS/UIKIT/Modal',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteCompareTable',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLiteParameterMergeUI',
        'DS/SMAAnalyticsLiteWidget/components/AdviseLiteRequirementsMapUI',
        'DS/SMAAnalyticsLiteWidget/components/SMAAnalyticsLitePopover',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteRequirementsUtils',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLauncher',
        'DS/SMAAnalyticsLiteWidget/utils/AdviseLiteDownloadOps',
        'DS/SMAAnalyticsLiteWidget/pages/mappng-table/SMAAnalyticsLiteMappingTableView',
        'DS/SMAAnalyticsLiteWidget/pages/mapping-table/SMAAnalyticsLiteMappingTableModel',
        'DS/SMAAnalyticsLiteWidget/pages/requirements-table/SMAAnalyticsLiteRequirementsTableModel',
        'DS/SMAAnalyticsLiteWidget/pages/requirements-table/SMAAnalyticsLiteRequirementsTableView',
        'DS/Controls/LineEditor'
    ],
    function(
        UWA,
        WXCore,
        Mask,
        Promise,
        View,
        Fragment,
        WidgetProxy,
        CommonProxy,
        SidePanel,
        Expander,
        Button,
        ButtonGroup,
        Spinner,
        Modal,
        CompareTable,
        ParamMergeUI,
        ReqMapUI,
        RAEPopover,
        NLS,
        ReqUtils,
        Launcher,
        DownloadOps,
        MappingTableView,
        MappingTableModel,
        RequirementsTableModel,
        RequirementsTableView,
        WUXLineEditor
    ) {
        'use strict';

        var _this = this;

        var ComparePage = View.extend({
            template: function() {
                //          console.log('ra-page: Fragment grabbed!');
                return '';
            },
            domEvents: {
                'click fonticon-resize-full': 'onResizeClick',
                viewChanged: 'onViewChanged'
                //'onFacetUnselect':'onFacetUnselect',
                //'onDestroy':'onDestroy'
            },
            events: { workerLoaded: 'workerLoaded' },
            
            viewStateData: {'activeView':'Actual'},

            tagName: 'div',
            className: 'link-detail',
            model: null,
            onRender: function() {
                // todo: move to the widgetskeleton or widgetproxy
                // this.target.style.position = 'relative';
                // this.immersiveFrame = WidgetProxy.getImmersiveFrame();//new
                // WUXImmersiveFrame();
                //          this.immersiveFrame.inject(this.target);
                var pageElem = document.createElement('ra-compare-page');
                if (pageElem) {
                    this.container.appendChild(pageElem);
                }
                // need to call the parent's destroy function otherwise
                this._parent.apply(this, arguments);
            },
            onViewChanged: function(e) {
                var detail = e.detail || {};
                if (detail.page !== 'Compare') {
                    return false;
                }
                if (detail.action === 'onViewParameterMapping') {
                    this.dispatchEvent('onViewParameterMapping');
                } else if (detail.action === 'viewChanged') {
                    if (detail.value === 'Table') {
                        if (worker) {
                            worker.evaluate(
                                'setParameterFiltersByName',
                                [{ files: false, data: true }],
                                function() {
                                    if (_this.raTable) {
                                        _this.raTable.showColumn(
                                            'requirements'
                                        );
//                                        _this.raTable.refresh();
                                        _this.raTable.refreshRows();
                                    }
                                }
                            );
                        }
                        this.viewStateData.activeView = 'Actual'; // we are not storing previous state of table view
                        
                    } else if (detail.value === 'File') {
                        if (worker) {
                            worker.evaluate(
                                'setParameterFiltersByName',
                                [{ files: true, data: false }],
                                function() {
                                    if (_this.raTable) {
                                        _this.raTable.hideColumn(
                                            'requirements'
                                        );
//                                        _this.raTable.refresh();
                                        _this.raTable.refreshRows();
                                    }
                                }
                            );
                        }
                        this.viewStateData.activeView = detail.value;
                        
                    }
                    this.saveViewState();
                } else if (detail.action === 'diffViewChanged') {
                    // filter out the available diff view types that are
                    // applicable :)
                    if (
                        detail.value === 'Actual' ||
                        detail.value === 'Magnitude' ||
                        detail.value === 'Percentage'
                    ) {
                        this.raTable.setDiffViewType(detail.value);
                        this.raTable.resize(); // fire the resize to re-request the data
                    }
                    this.viewStateData.activeView = detail.value;
                    this.saveViewState();
                    
                }
                console.info(arguments);
                // need to call the parent's destroy function otherwise
                this._parent.apply(this, arguments);
            },
            onFacetSelect: function() {
            	var selectedCase = this.model,
            	frm = widget.body,
            	args = arguments,
            	parent = this._parent;
            	
            	//default view which will be overridden if there is view data stored
            	this.viewStateData.activeView  = 'Actual';
            	
            	selectedCase.set('image',WidgetProxy.get3DSpaceURL() +
                '/webapps/SMAAnalyticsUI/assets/icons/SMAAnalyticsWidgetIcon.png');
            	Mask.mask(frm, NLS.get('TABLE_INITIALIZING'));
            	this.container.draggable = false;
            	var datasetChanged = widget.getValue('datasetchanged');
            	//if dataset added
            	if(datasetChanged || typeof _this.raTable === 'undefined' || _this.raTable === 'null'){
	            	WidgetProxy.getConnectedDatasets(selectedCase.id).done(function(response) {
	            		WidgetProxy.storeDataSetsList(response);
	            		if (typeof _this.raTable === 'undefined' || _this.raTable === 'null') {
	            			_this.reqUtils = _this.reqUtils || new ReqUtils({ caseId: selectedCase.id });
	            			_this.reqUtils.setupRequirementsForCase(selectedCase.id,function() {
	            				Launcher.initializeWebWorker(selectedCase.id, WidgetProxy.datasets).then(function() {
	            					Launcher.startApp(selectedCase.id,true).done(function(data) {
	            						var openMergeUI = data? data.openMergeUI: null;
	            						_this.raTable = new CompareTable({
	                                        caseId: _this.model.id
	                                    });
	                                    
	                                    _this.setViewStateInfo().then(function(){
	            						     _this.setupTable(frm);
	            						     if (widget) {
	                                       	       // check to see if the worker was loaded prematurely
	                                               widget.dispatchEvent('onCheckWorker'); 
	                                           }
	                                       widget.dispatchEvent('workerLoaded', {
	                                           openMergeUI: openMergeUI
	                                       });
	                                    }, function(error){
                                        Mask.unmask(frm);
                                    });
	            					}, function(error){
	            						Mask.unmask(frm);
	            					});
	            				}, function(error){
	            					Mask.unmask(frm);
	        					});
	            			}, function(error){
	            				Mask.unmask(frm);
	            			});
	                	} else{
	                		var downldOps = new DownloadOps({
	                            mcsURL: WidgetProxy.get3DSpaceURL(),
	                            caseID: selectedCase.id
	                        });
	                		if(UWA.is(response) && UWA.is(response.analyticsDataSetList)){
	                			downldOps.runDownloadForAddedDatasets(response.analyticsDataSetList).
	                            then(function() {
	                            	_this.setupTable(frm);
//	                            	var tableRef = _this.raTable.getTableElement();
//	        						tableRef.addEvent('resize', function() {
//	                                    _this.raTable.resize();
//	                                });
//	        						var container = Polymer.dom(_this.container);
//	                                var callCounter = 0;
//	                                var attachTableFunc = function() {
//	                                    var section = container.querySelector('#mainContent section');
//	                                    if (section) {
//	                                    	section.appendChild(tableRef);
//	                                	} else if (callCounter < 5) {
//	                                        callCounter += 1;
//	                                        setTimeout(attachTableFunc, 100);
//	                                    }
//	                                };
//	                                _this.container.querySelector('#mainContent section').appendChild(tableRef);
	                                widget.dispatchEvent('workerLoaded');
	                                Mask.unmask(frm);
	                            }, function(error){
	                            	Mask.unmask(frm);
	                            });
	                		}
	                	}
	            	});
            	}else{
            		_this.setupTable(frm);
            	}
                this._parent.apply(this, arguments);
            },
            
            setupTable: function(frm){
            	var tableRef = this.raTable.getTableElement();
            	tableRef.addEvent('resize', function() {
                    _this.raTable.resize();
                });
        		var container = Polymer.dom(_this.container);
                var callCounter = 0;
                var attachTableFunc = function() {
                    var section = container.querySelector('#mainContent section');
                    if (section) {
                    	section.appendChild(tableRef);
                	} else if (callCounter < 5) {
                        callCounter += 1;
                        setTimeout(attachTableFunc, 100);
                    }
                };
                this.container.querySelector('#mainContent section').appendChild(tableRef);
               
                this.setComparePageView( this.viewStateData.activeView );
               
                 
                Mask.unmask(frm);
            },
            
            setComparePageView: function(view){            
                if (
                        view === 'Actual' ||
                        view === 'Magnitude' ||
                        view === 'Percentage'
                    ) {
                        if (worker) {
                            worker.evaluate(
                                'setParameterFiltersByName',
                                [{ files: false, data: true }],
                                function() {
                                    if (_this.raTable) {
                                        _this.raTable.showColumn(
                                            'requirements'
                                        );                                        
                                    }
                                }
                            );
                        }
                        this.raTable.setDiffViewType(view);                        
                        
                    } else if (view === 'File') {
                        if (worker) {
                            worker.evaluate(
                                'setParameterFiltersByName',
                                [{ files: true, data: false }],
                                function() {
                                    if (_this.raTable) {
                                        _this.raTable.hideColumn(
                                            'requirements'
                                        );                                        
                                    }
                                }
                            );
                        }
                        
                    }           
            },
             
             
            //      setup: function(){
            //      },
            init: function(options) {
                _this = this;
                // not sure if this is working as desired ... commenting this
                // out for now
                //          var rightPanel =
                //          UWA.extend(widget.elements.content.getElementsByClassName('right')[0]);
                //          var spinner = new
                //          Spinner().inject(rightPanel).show();
                this.model = options.model;
                this.target = options.target || document.body;
                this._parent(arguments);
               
                // ==================================================
                // Requirements Map UI

                // remove any old instances that are left over in the dom ...
                var oldReqContainer = this.target.querySelectorAll(
                    '.ra-requirementsMapUI'
                );
                if (oldReqContainer !== null) {
                    [].forEach.call(oldReqContainer, function(old) {
                        old.parentNode.removeChild(old);
                    });
                }
                // intitialized the modal window used for the requirements
                // editor

                //          this.requirementsMapContainer =
                //          this.requirementsMapContainer || new Modal({
                //              'closable': true,
                //              'renderTo': document.body,
                //              'className': 'ra-requirementsMapUI'
                //          });

                //          this.requirementsMap = new ReqMapUI({'model' :
                //          this.model}); this.requirementsMapElem =
                //          this.requirementsMap.getTableElement();
                // the getter for the requirements map is defined on the
                // requirements map
                //          this.requirementsMap =
                //          document.createElement('ra-requirements-map');
                //          this.requirementsMap.modelID = this.model.get('id');

                //          // attach the table to the modal window
                //          var headerText = document.createElement('span');
                //          headerText.textContent = 'Requirements Mapping'; //
                //          FIXME: NLS
                //
                //          this.requirementsMapContainer.setHeader(headerText);
                //          this.requirementsMapContainer.setBody(this.requirementsMapElem);

                // --------------------------------------------------
            },
            loadParameterMergeUI: function(force) {
                //          this.psrContainer.classList.add('ra-requirementsMapUI');
                //          this.psrContainer.style.width = '100%';
                //          this.psrContainer.style.height = '100%';
                if (this.parameterMergeContainer) {
                    return;
                }
                this.parameterMergeContainer =
                    this.parameterMergeContainer ||
                    new RAEPopover({
                        width: 600,
                        resizableFlag: true,
                        title: NLS.get('parameter_mapping'),
                        isModal: true
                        //              'visibleFlag': false,
                        //              'immersiveFrame': this.immersiveFrame
                    });

                //          this.parameterMergeContainer =
                //          this.parameterMergeContainer || new Modal({
                //              'closable': true,
                //              'renderTo': document.body,
                //              'className': 'ra-requirementsMapUI' // change
                //              this to not be specific
                //          });
                
                var isWebUXImpl = localStorage.getItem('SMAAdvEssOldUXParamMerge');
                if(!isWebUXImpl ){
                	//Create filter bar to inject int he UI
                	var searchDiv = document.createElement('div');
                	var editor = new WUXLineEditor({
                		placeholder: NLS.get('FILTER'),
                		selectAllOnFocus: true,
                	});
                	editor.addEventListener('change', function(e){
                		e.preventDefault();
	                	e.stopPropagation();
	                	if(_this._mtabview){
	                		_this._mtabview.searchModel(e.dsModel.value);
	                	}
	                	
                	});
					editor.inject(searchDiv);
                }else{
                	this.paramMergeUI = new ParamMergeUI({ model: this.model });
                	this.parameterMergeTable = this.paramMergeUI.getTableElement();
                    if (this.parameterList) {
                        this.paramMergeUI.setParameterList(this.parameterList);
                    }
                	this.paramMergeUI.createFilterBar();
                }
                

                //          pmBody.appendChild(pmBodyBottom);

                // attach the table to the modal window
                //          var paramHeaderText =
                //          document.createElement('span');
                //          paramHeaderText.textContent = 'Parameter Mapping';
                //          // FIXME: NLS

                //          this.parameterMergeContainer.setHeader(paramHeaderText);
                //          this.parameterMergeContainer.setBody(pmBody);
                //          this.parameterMergeContainer.setFooter(this.paramMergeUI.getMergeFooter());

                var loadDatasetsInMergeUI = function() {
                    WidgetProxy.getConnectedDatasets(
                        _this.model.get('id')
                    ).done(function(datasetsList) {
                        // for some reason it will either be one or the
                        // other (not both?)
                    	var datasets = null;
                        if(datasetsList){
                        	datasets=datasetsList.analyticsDataSet ||
                            datasetsList.analyticsDataSetList;
                        }
                        if (
                            force ||
                            (datasets && datasets.length > 1) ||
                            WidgetProxy.getKWEMergeUIFlag() === true
                        ) {
                            // open the merge ui as there is more than one
                            // dataset attached to the case ...
                            //_this.parameterMerge.set('datasets',datasets);
                           
                            
                            // this injects the content and displays the UI
                            if(!isWebUXImpl){
                            	 //var _mtabview = new MappingTableView({ model: _this.model });
                            	 _this._mtabview = new MappingTableView({ model: _this.model });
                            	 if(_this._mtabview && _this.parameterList && _this.parameterList.length >0){
                            		 _this._mtabview.setParamList(_this.parameterList);
                            	 }
                            	 _this.parameterMergeContainer.injectContent(
                                         {
                                             header: searchDiv,
                                             body: _this._mtabview.getMergeUI().getContent() //,
                                         },
                                         {
                                             ok: function() {
                                            	 _this._mtabview.getMergeCallback();
                                                 delete _this.parameterMergeContainer;
                                             },
                                             apply: _this._mtabview.getMergeCallback,
                                             close: function() {
                                                 delete _this.parameterMergeContainer;
                                             }
                                         }
                                     );
                                 _this.parameterMergeContainer.open();
                                 
                            }
                            else{
                            	_this.paramMergeUI.updateDataSetsList(datasets);
                            	_this.parameterMergeContainer.injectContent(
                            			{
                            				header: _this.paramMergeUI.getFilterBar(),
                            				body: _this.parameterMergeTable //,
                            				//'footer':
                            				//this.paramMergeUI.getMergeFooter()
                            			},
                            			{
                            				ok: function() {
                            					_this.paramMergeUI.getMergeCallback();
                            					delete _this.parameterMergeContainer;
                            				},
                            				apply: _this.paramMergeUI.getMergeCallback,
                            				close: function() {
                            					delete _this.parameterMergeContainer;
                            				}
                            			}
                            	);
                            	_this.paramMergeUI.resize();
                            	_this.parameterMergeContainer.onResize(function() {
                            		_this.paramMergeUI.resize();
                            	});
                            }
                            
                            
                        }
                    });
                };

                loadDatasetsInMergeUI();

                // I don't think we're ever going to get here, but that requires
                // further testing ....
                document.addEventListener('onViewParameterMapping', function(
                    event
                ) {
                    loadDatasetsInMergeUI();
                });
            },
            onResizeClick: function(event) {
                console.log(event);
            },
            workerLoaded: function(args) {
                console.log('DEBUG --- Compare Page notified of worker loaded');
                if (
                    typeof this.raTable === 'undefined' ||
                    this.raTable !== 'null'
                ) {
                    this.raTable.refresh();
                    // potential timing issue here?
                    worker.evaluate('getAllParametersAsArray', [], function(
                        parameters
                    ) {
                        _this.parameterList = parameters;
                        var force = typeof args !== 'undefined' &&
                		typeof args.force === 'boolean'
                        ? args.force
                        : false;
                        if (_this.requirementsMap) {
                            _this.requirementsMap.setParameterList(
                                _this.parameterList
                            );
                        }
                        if (_this.paramMergeUI) {
                            _this.paramMergeUI.setParameterList(
                                _this.parameterList
                            );
                        }
		                // if openMergeUI is one of the arguments and it's false then we
		                // won't open the merge ui
		                if (!args || typeof args.openMergeUI !== 'boolean' || args.openMergeUI) {
		                    _this.loadParameterMergeUI(true);
		                }
                        
                    });

                    // this should already be handled?
                    //              this.raTable.addEvent('resize', function(){
                    //                  this._resetSizing();
                    //              });
                } else {
                    console.log('DEBUG --- no table');
                }

                
            },
            // TODO: this shouldn't be on the compare page, but global to the
            // widget
            onRequirementsAttached: function() {
            	var isWebUXImpl = false; 
            	isWebUXImpl = localStorage.getItem('SMAAdvEssOldUXParamMerge');
            	if(!isWebUXImpl){
            		_this.createWebUXRequirementsUI();
            	}else{
            		_this.createLegacyRequirementsUI();
            	}
            },
            createLegacyRequirementsUI:function(){

                this.requirementsMap = new ReqMapUI({ model: this.model });
                if (this.parameterList) {
                    this.requirementsMap.setParameterList(this.parameterList);
                }
                this.requirementsMapElem = this.requirementsMap.getTableElement();
                this.requirementsMapContainer =
                    this.requirementsMapContainer ||
                    new RAEPopover({
                        width: 680,
                        resizableFlag: true,
                        title: NLS.get('requirements_mapping'),
                        isModal: true
                        //              'visibleFlag': false,
                        //              'immersiveFrame': this.immersiveFrame
                    });

                // need to reset the data for the table as the old data could be
                // wrong
                this.requirementsMap.refreshTableData(function() {
                    // FIXME: requirementsMapContainer.open only works the first
                    // time this opens the popover ...

                    _this.requirementsMapContainer.injectContent(
                        { body: _this.requirementsMapElem },
                        {
                            ok: _this.requirementsMap.getMergeCallback,
                            apply: _this.requirementsMap.getMergeCallback
                        }
                    );
                    _this.requirementsMapContainer.open();
                    _this.requirementsMap.resize();

                    _this.requirementsMapContainer.onResize(function() {
                        _this.requirementsMap.resize();
                    });

                    //_this.requirementsMap.resize();
                });

                // this.requirementsMapContainer.show(); // show the container
                // to do a merge
            
            },
            
            setViewStateInfo : function(){
                var _this  = this; 
                return new Promise(function(resolve,reject){
                    
                    CommonProxy.downloadFile('raeClientStateInfo.json', 'json', _this.model.id,'', true).
                        then( function(clientStateInfoBlob){
                            try {
                                var reader = new FileReader();
                                reader.addEventListener('loadend', function() {
                                    var modResultString = '',
                                        modResult = '';
                                                           
                                    try {
                                        modResultString = this.result.
                                            split('NaN').
                                            join('null');
                                        modResult = JSON.parse(modResultString);
                                        if(modResult.hasOwnProperty('activeView')){
                                            _this.viewStateData.activeView = modResult.activeView;                                            
                                        }
                                        resolve();
                                    } catch (e) {
                                        resolve();
                                    }                                
                                });
                                reader.readAsText(clientStateInfoBlob);
                            } catch (ex) {
                                resolve();
                            }                            
                        }, function(){
                            resolve();
                            }
                        );
                });                                                    
    
            },
            
            saveViewState: function(){
                        
                var viewData = JSON.stringify(this.viewStateData);
                return WidgetProxy.saveCaseFile(this.model.id, 'raeClientStateInfo.json', viewData);
                
            },            
            
            createWebUXRequirementsUI:function(){
            	 this.requirementsMapContainer =
                 this.requirementsMapContainer ||
                 new RAEPopover({
                     width: 950,
                     resizableFlag: true,
                     title: NLS.get('requirements_mapping')
                     //              'visibleFlag': false,
                     //              'immersiveFrame': this.immersiveFrame
                 });
            	 this._requirementsTabView = new RequirementsTableView({ model: _this.model });
            	 if(_this.parameterList && _this.parameterList.length > 0){
            		 this._requirementsTabView.setParamList(_this.parameterList);
            	 }
            	 this.requirementsMapContainer.injectContent(
            			{
                            //header: searchDiv,
                            body: _this._requirementsTabView.getMergeUI().getContent() //,
                        },
                        {
                            ok: function() {
                           	 _this._requirementsTabView.getMergeCallback();
                                delete _this.requirementsMapContainer;
                            },
                            apply: _this._requirementsTabView.getMergeCallback,
                            close: function() {
                                delete _this.requirementsMapContainer;
                            }
                        }
                    );
                _this.requirementsMapContainer.open();
            },
            onRequirementsUpdate: function() {
                if (this.raTable) {
                    this.raTable.resize();
                }
                worker.evaluate('getAllParametersAsArray', [], function(
                    parameters
                ) {
                    _this.parameterList = parameters;
                    if (_this.requirementsMap) {
                        _this.requirementsMap.setParameterList(
                            _this.parameterList
                        );
                        _this.requirementsMap.resize();
                    }
                });
            },
            // open the parameter mapping dialog
            onViewParameterMapping: function() {
                this.loadParameterMergeUI(true);
            },
            onParameterMerge: function() {
                if (this.raTable !== 'null') {
                	// TODO: need to make sure this doesn't break anything
//                  _this.raTable.refresh();
                    _this.raTable.refreshRows();
                    // potential timing issue here?
                    worker.evaluate('getAllParametersAsArray', [], function(
                        parameters
                    ) {
                        _this.parameterList = parameters;
                        if (_this.requirementsMap) {
                            _this.requirementsMap.setParameterList(parameters);
                        }
                        if (_this.paramMergeUI) {
                            _this.paramMergeUI.setParameterList(parameters);
                        }
                    });
                }
            },
            onFacetUnselect: function() {
                console.log('compare page is unselected');
                // need to call the parent's destroy function otherwise
                this._parent.apply(this, arguments);
            },

            destroy: function() {
                try {
                    if (this.parameterMergeContainer) {
                        this.parameterMergeContainer.close();
                    }
                    if (this.requirementsMapContainer) {
                        this.requirementsMapContainer.close();
                    }
                } catch (e) {
                    // elements.container wasn't a thing
                }
                this.stopListening();
                this.model = null;
                this._parent();
            }
            //      onDestroy: function(){
            //          console.log('case closed');
            //          // need to call the parent's destroy function otherwise
            //            this._parent.apply(this, arguments);
            //      }
        });

        return ComparePage;
    }
);

define('DS/SMAAnalyticsLiteWidget/SMAAnalyticsCaseListView',
		[
			'UWA/Core',
	        'DS/W3DXComponents/Skeleton',
	        'DS/W3DXComponents/Collections/ActionsCollection',
	        'DS/W3DXComponents/Views/Item/RowView',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsEmptyView',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsCaseCollection',
	        'DS/SMAAnalyticsCommon/views/SMAAnalyticsContentSet',
	        'DS/SMAAnalyticsCommon/views/SMAAnalyticsTileView',
	        'DS/SMAAnalyticsCommon/views/SMAAnalyticsThumbnailView',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsCaseDetail',
	        'DS/SMAAnalyticsLiteWidget/pages/compare/SMAAnalyticsLiteComparePage',
	        'DS/SMAAnalyticsCommon/SMAAnalyticsCustomView',
	        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteCaseListUtils',
	        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
	        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget'
	        
		], function(
				UWA,
				Skeleton,
				ActionsCollection,
				RowView,
				EmptyView,
				CaseCollection,
				ContentSet,
				TileView,
				ThumbnailView,
				AnalyticsUtils,
				CaseDetailPage,
				ComparePage,
				CustomView,
				CaseListUtils,
				WidgetProxy,
				NLS
			){
	'use strict';
	var SMAAnalyticsCaseListView = {},
	_onItemViewDrag = function(unknown, view, event) {
        var physicalId = view.model.get('physicalId');
        if (physicalId) {
            var analyticsCaseObject = {
                data: { items: [{ objectId: physicalId, objectType: 'Analytics Case' }] }
            };
            event.dataTransfer.setData(
                'text',
                JSON.stringify(analyticsCaseObject)
            );
        } else {
            AnalyticsUtils.showErrorNotification(
                NLS.get('ERROR_REFRESH_PAGE')
            );
        }
    },
    _onInfiniteScroll = function(scrollView){
    	var options= {
			onComplete: function(){
				if (scrollView && scrollView.scroller) {
					if (collection.hasNextPage()) {
                        scrollView.endLoading();
                        scrollView.useInfiniteScroll(true);
                    } else {
                        scrollView.useInfiniteScroll(false);
                    }
				}
			}
		}
    	var that = this,
		collection = this.collection;
    	collection.scrollView= scrollView;
		if(collection.hasNextPage()){
			collection.loadNextPage(options);
		}else{
			scrollView.useInfiniteScroll(false);
		}
    };
    
    SMAAnalyticsCaseListView.getRenderer = function() {
        return {
        	collection:CaseCollection,
        	view: ContentSet,
        	viewOptions: {
        		actions: {
        			collection: new ActionsCollection([
                        {
                            id: 'raHelp',
                            title: NLS.get('GETTING_HELP'),
                            icon: 'help-circled',
                            overflow: true
                        }
                    ]),
                    events: {
                        onActionClick: function(
                            actionBarView,
                            actionItem,
                            event
                        ) {
                        	AnalyticsUtils.showInfoNotification('', NLS.get('Documentation coming soon...'));
//                            var actionId = actionItem.model.get('id');
//                        	var language = widget.data.lang,
//                        	langOnlineStr='';
//                        	if(language==='en'){
//                        		langOnlineStr='English';
//                        	}else if(language==='fr'){
//                        		langOnlineStr='French';
//                        	}else{
//                        		langOnlineStr = 'English';
//                        	}
//                        	var currentPageURL = 'SimResaWidgetUserMap/resa-c-ov.htm',
//                        	helpURL = 'http://help.3ds.com/HelpDS.aspx?P=11&L='
//                        		+langOnlineStr
//                        		+'&V=2018x&F=' //Need to update version
//                        		+currentPageURL
//                        		+ '&contextscope=cloud';
//                            window.open(helpURL);
                        }
                    }
        		},
        		buildMultiselActions: function(){
        			var actions = [];
                    actions.push({
                    	id: 'delete',
                        text: NLS.get('DELETE_CASES'),
                        fonticon: 'trash',
                        multisel: true,
                        handler:
                        	CaseListUtils.deleteAnalyticsCase
                    });
                    return actions;
        		},
        		contents: {
        			selectionMode: 'nullToMany',
                    useInfiniteScroll: true,
                    usePullToRefresh: false,
                    headerOnEmpty: false,
                    viewtype: 'casedetails',
                    views: [
                        {
                            id: 'tile',
                            view:
                                CustomView.AnalyticsGridScrollView,
                            itemView: TileView,
                            title: 'Tile View',
                            'default': window.widget && window.widget.getValue('currentViewId') === 'tile'
                        },
                        {
                            id: 'thumbnail',
                            view:
                                CustomView.AnalyticsGridScrollView,
                            itemView: ThumbnailView,
                            title: 'Thumbnail View',
                            'default': window.widget && window.widget.getValue('currentViewId') === 'thumbnail'
                        },
                        {
                            id: 'table',
                            view:
                                CustomView.AnalyticsTableScrollView,
                            itemView: RowView,
                            title: 'Row View',
                            'default': window.widget && window.widget.getValue('currentViewId') === 'table'
                        },
                        {
                            id: 'list',
                            view: CustomView.AnalyticsListView,
                            itemView: TileView
                        }
                    ],
                    itemViewOptions: {
                        contextualActions: [
                        	{
                                text: NLS.get('COPY'),
                                fonticon: 'copy',
                                handler:
                                	CaseListUtils.copyAnalyticsCase
                            },
//                            {
//                                text: NLS.get('REVISE'),
//                                fonticon: 'flow-branch',
//                                handler:
//                                	CaseListUtils.reviseAnalyticsCase
//                            },
                            {
                                text: NLS.get('DELETE'),
                                fonticon: 'trash',
                                handler:
                                    CaseListUtils.deleteAnalyticsCase
                            }
                        ]
                    },
                    headers: [
                        {
                            property: 'title',
                            sortable: true,
                            label: NLS.get('TITLE')
                        },
                        {
                            property: 'revision',
                            sortable: true,
                            label: NLS.get('REVISION')
                        },
                        {
                            property: 'description',
                            sortable: false,
                            label: NLS.get('DESCRIPTION')
                        },
                        {
                            property: 'project',
                            sortable: true,
                            label: NLS.get('COLLAB_SPACE')
                        },
                        {
                            property: 'ownerFullName',
                            sortable: true,
                            label: NLS.get('OWNER')
                        },
                        {
                            property: 'authorFullName',
                            sortable: true,
                            label: NLS.get('AUTHOR')
                        },
                        {
                            property: 'originated',
                            sortable: true,
                            label: NLS.get('TIME')
                        }
                    ],
                    emptyView: EmptyView,
                    events: {
                        onItemViewDrag: _onItemViewDrag,
                        onInfiniteScroll: _onInfiniteScroll
                    }
        		},
        		events: {
                	onSwitch: function(a,b,viewName){
                		if(UWA.is(viewName)){
                			widget.setValue('currentViewId',viewName);
                		}
                	}
                }
        	},
        	idCardOptions: function (){
            	var facets = [
            		{
                        text: NLS.get('CASE_DET'),
                        icon: 'newspaper',
                        handler: Skeleton.getRendererHandler(CaseDetailPage)
                    },
                    {
                        text: NLS.get('compare'),
                        icon: 'list',
                        handler: Skeleton.getRendererHandler(ComparePage)
                    }
                ];
            	return {
                    title: NLS.get('RA_CASES'),
                    selectedFacet: 1,
                    facets: facets,
                    actions: [
                        {
                            text: NLS.get('save_case'),
                            icon: 'floppy',
                            handler: function() {
                                var that = this;
                                window.worker.evaluate('getSaveData', null,
                                    function(caseData) {
                                        WidgetProxy.saveCaseData(that._config._idCard.model.id, caseData).then(function(){
                                        	AnalyticsUtils.showSuccessNotification('', NLS.get('SAVE_SUCCESS'));
                                        }, function(error){
                                        	AnalyticsUtils.showErrorNotification('', NLS.get('SAVE_ERROR'));
                                        });
                                    }
                                );
                            },
                            name: 'save'
                        },
                        {
                            text: NLS.get('CLOSE'),
                            icon: 'close',
                            handler: CaseListUtils.stopCase,
                            name: 'close'
                        }
                    ]
                };
            }
        }
    }
    return SMAAnalyticsCaseListView;
});

define(
    'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteWidgetSkeleton',
    [
        'DS/W3DXComponents/Skeleton',
        'DS/SMAAnalyticsCommon/SMAAnalyticsCaseCollection',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteLandingPage',
        'DS/SMAAnalyticsCommon/SMAAnalyticsCaseDetail',
        'DS/SMAAnalyticsLiteWidget/pages/compare/SMAAnalyticsLiteComparePage',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsLiteProxy',
        'DS/SMAAnalyticsLiteWidget/utils/SMAAnalyticsLiteCaseListUtils',
        'i18n!DS/SMAAnalyticsLiteWidget/assets/nls/adviseLiteWidget',
        'DS/SMAAnalyticsCommon/SMAAnalyticsUtils',
        'DS/SMAAnalyticsLiteWidget/SMAAnalyticsCaseListView',
        'DS/Windows/ImmersiveFrame'
    ],
    function(
        Skeleton,
        CaseCollection,
        LandingPage,
        CaseDetailsPage,
        ComparePage,
        WidgetProxy,
        CaseListUtils,
        NLS,
        AnalyticsUtils,
        CaseListView,
        WUXImmersiveFrame
    ) {
        'use strict';
        var rerouteOnClose = function(skeleton){
        	this.bones.setRoute('/landingpage/');
        };
        var liteWidgetSkeleton = null;
        liteWidgetSkeleton = {
            bones: null,

            onLoad: function(targetBody) {

                if (this.bones !== null) {
                    this.bones.destroy();
                }
                
                var adivseWidgetSkeleton = new Skeleton(
                    // first argument
                    {
                    	landingpage: CaseListView.getRenderer(),
                        /*landingpage: {
                            collection: CaseCollection,
                            collectionOptions: {
                                type: 'Results Analytics Cases'
                            },
                            view: LandingPage,
                            viewOptions: {
                                useInfiniteScroll: true,
                                usePullToRefresh: false,
                                itemViewOptions: {
                                    contextualActions: [
                                    	{ className: 'divider' },
                                    	{
                                            text: NLS.get('DELETE'),
                                            fonticon: 'trash',
                                            handler:
                                            	CaseListUtils.deleteAnalyticsCase.bind(this)
                                        },
                                        { className: 'divider' }
                                    ]
                                },
                                events: {
                                    onItemViewDrag: function(unknown, view, event){
                                    	var physicalId = view.model.get('physicalId');
                                        if (physicalId) {
                                            var analyticsCaseObject = {
                                                data: { items: [{ objectId: physicalId, objectType: 'Analytics Case' }] }
                                            };
                                            event.dataTransfer.setData(
                                                'text',
                                                JSON.stringify(analyticsCaseObject)
                                            );
                                        } else {
                                            WidgetProxy.showErrorNotification(
                                                WidgetProxy.translate('ERROR_REFRESH_PAGE')
                                            );
                                        }
                                    },
                                    onInfiniteScroll: function(scrollView){
                                    	var options= {
                            				onComplete: function(){
                            					if (scrollView && scrollView.scroller) {
                            						if (collection.hasNextPage()) {
                            	                        scrollView.endLoading();
                            	                        scrollView.useInfiniteScroll(true);
                            	                    } else {
                            	                        scrollView.useInfiniteScroll(false);
                            	                    }
                            					}
                            				}
                            			}
                                    	var that = this,
                                		collection = this.collection;
                                    	collection.scrollView= scrollView;
                                		if(collection.hasNextPage()){
                                			collection.loadNextPage(options);
                                		}else{
                                			scrollView.useInfiniteScroll(false);
                                		}
                                    }
                                }
                            },
                            idCardOptions: {
                                // this selectedFacet option is not
                                // working
                                // will be fixed in 17x according to
                                // Irwin
                                selectedFacet: 1,
                                facets: function() {
                                    return [
                                        {
                                            name: 'details',
                                            text: NLS.get('case_details'),
                                            icon: 'info',
                                            handler: Skeleton.getRendererHandler(
                                                CaseDetailsPage
                                            )
                                        },
                                        {
                                            name: 'compare',
                                            text: NLS.get('compare'),
                                            icon: 'list',
                                            handler: Skeleton.getRendererHandler(
                                                ComparePage
                                            )
                                        }
                                    ];
                                },
                                actions: [
                                    {
                                        text: NLS.get('Save'),
                                        icon: 'floppy',
                                        handler: function() {
                                            var that = this;
                                            window.worker.evaluate(
                                                'getSaveData',
                                                null,
                                                function(caseData) {
                                                    WidgetProxy.saveCaseData(
                                                        that._config._idCard
                                                            .model.id,
                                                        caseData
                                                    );
                                                }
                                            );
                                        }
                                    },
                                	{
                                        text: NLS.get('CLOSE'),
                                        icon: 'close',
                                        handler: rerouteOnClose.bind(this),
                                        name: 'close'
                                    }
                                ]
                            }
                        },*/
                        casedetails: {
                            collection: CaseCollection,
                            collectionOptions: { type: 'Case Details' },
                            view: CaseDetailsPage,
                            viewOptions: {
                                useInfiniteScroll: false,
                                usePullToRefresh: false
                            },
                            idCardOptions: { facets: [] }
                        },
                        compare: {
                            view: ComparePage,
                            viewOptions: {
                                useInfiniteScroll: false,
                                usePullToRefresh: false
                            },
                            idCardOptions: { facets: [] }
                        }
                    },
                    // second argument
                    {
                        root: 'landingpage',
                        rendererOptions: {
                            swipe: false
                            // disables swiping on touch screens (was
                            // preventing side scrolling on the table)
                        },
                        events: {
                        	onSlide: function(){
                        		if(this.currentRoute === '/landingpage/'){
                        			widget.setValue('lastactivecase','');
                        		}
                        	}
                        }
                    }
                );
                liteWidgetSkeleton.bones = adivseWidgetSkeleton;
                AnalyticsUtils.initialize(adivseWidgetSkeleton, true);
                var iF = new WUXImmersiveFrame({
                    identifier: 'AdviseLiteLandingPageImmersiveFrame'
                });
                iF.inject(document.body);
                WidgetProxy.setImmersiveFrame(iF);
                AnalyticsUtils.setImmersiveFrame(iF);
                // empty the targetbody - incase of the widget there is a
                // 'loading..' even after rendering
                targetBody.innerHTML = '';
                // do the actual rendering here
                liteWidgetSkeleton.bones.render().inject(targetBody);
            },
            isWorkerLoaded: false,
            workerLoaded: function(args) {
                try {
                    var contentPanel = this.bones.getViewAt(1);
                    //                      console.log('Skeleton:
                    //                      workerloaded');
                    if (contentPanel !== null) {
                        var compareView = contentPanel.model._facetObjs[1].view;
                        compareView.dispatchEvent('workerLoaded', args);
                    } else {
                        // we'll check if the worker is loaded using
                        // 'onCheckWorker' and refire this event
                        this.isWorkerLoaded = true;
                        this.workerArgs = args;
                        console.warn(
                            'Event workerLoaded prematurely. Check back later'
                        );
                    }
                } catch (err) {
                    console.warn(err);
                }
            },
            onRequirementsAttached: function() {
                try {
                    var contentPanel = this.bones.getViewAt(1);
                    if (contentPanel !== null) {
                        var compareView = contentPanel.model._facetObjs[1].view;
                        compareView.dispatchEvent('onRequirementsAttached');
                    }
                } catch (err) {
                    console.warn(err);
                }
            },
            onRequirementsUpdate: function() {
                try {
                    var contentPanel = this.bones.getViewAt(1);
                    if (contentPanel !== null) {
                        var compareView = contentPanel.model._facetObjs[1].view;
                        compareView.dispatchEvent('onRequirementsUpdate');
                    }
                } catch (err) {
                    console.warn(err);
                }
            },
            onParameterMerge: function() {
                try {
                    var contentPanel = this.bones.getViewAt(1);
                    if (contentPanel !== null) {
                        var compareView = contentPanel.model._facetObjs[1].view;
                        compareView.dispatchEvent('onParameterMerge');
                    }
                } catch (err) {
                    console.warn(err);
                }
            },
            // check if the worker was loaded prematurely
            onCheckWorker: function() {
                if (this.isWorkerLoaded) {
                    console.log('Calling workerLoaded after premature call.');
                    var _args = this.workerArgs;
                    this.workerLoaded(_args); // call the workerLoaded method directly
                    this.isWorkerLoaded = false;
                    delete this.workerArgs;
                }
            }
        };

        return liteWidgetSkeleton;
    }
);


/**
 * @overview Platform Model.
 */

/*global define*/
define(
    'DS/PlatformManagementComponents/Model/Platform',
    [
        'UWA/Core',
        'UWA/Class/Model'
    ],
    /**
     * @module PlatformManagementComponents/Model/Platform
     *
     * @require UWA/Core
     * @require UWA/Class/Model
     *
     * @extend UWA/Class/Model
     */
    function (UWA, Model) {
        'use strict';

        return Model.extend({
            /**
             * @property {Object} defaultOptions - The default options.
             * @private
             */
            defaults: {
                displayName: '',
                free: '',
                id: '',
                platform: true,
                dp: '',
                swym: '',
                total: '',
                cstorage: ''
            },
            /**
             * Set the data to the model
             *
             * @param {Object} options
             * @param {string} options.displayName  - The name of the platform
             * @param {string} options.free         - Number of free licenses of the platform
             * @param {string} options.id           - Id of the platform
             * @param {string} options.platform     - The platform is a true platform (not a WU)
             * @param {string} options.dp           - Data privacy of the platform
             * @param {string} options.swym         - Url of swym for the platform
             * @param {string} options.total        - Number of licenses of the platform
             * @param {string} options.cstorage     - Url of cstorage for the platform
             *
             */
            set: function (options) {
                this._parent(options);
            },
            /**
             * Return the name of the platform
             */
            getName: function () {
                return this.get('displayName');
            },
            /**
             * Return the id of the platform
             */
            getId: function () {
                return this.get('id');
            },
            /**
             * Return the Cstorage url of the platform
             */
            getCstorage: function () {
                return this.get('cstorage');
            },
            /**
             * Return the Swym url of the platform
             */
            getSwym: function () {
                return this.get('swym');
            },
            hasWu: function () {
                return this.collection.hasWu;
            }
        });
    }
);

/*global define */
define(
    'DS/PlatformManagementComponents/PlatformSynchro',
    [
        'UWA/Core',
        'UWA/Utils',
        'UWA/Json',
        'UWA/Class',
        'UWA/Utils/InterCom',
        'DS/PlatformAPI/PlatformAPI'
    ],
    /**
     * @module DS/PlatformManagementComponents/Synchro
     *
     * @require UWA/Core
     * @require UWA/Utils/InterCom
     * @returns {void|*|Function}
     */
    function (UWA, Utils, Json, Class, InterCom, PlatformAPI) {
        'use strict';
        
        return Class.singleton({
            /*
             * Master mode (document)
             */
            server: null,
            serverId: 'com.ds.platform-management.platform-synchro',

            /*
             * ID for session storage
             */
            storageId: 'pmc-platform-' + Utils.getCheckSum(PlatformAPI.getUser().login),

            /*
             * Available events
             */
            events: {
                platformChange: 'onPlatformChange'
            },

            /*
             * Sockets that registered through this
             */
            sockets: {},

            getSocketId: function () {
                return 'platform-synchro-' + Utils.getUUID();
            },

            getCurrentPlatform: function (useWu) {
                var platforms = this.get();
                //UWA.log('[Platform Synchro] Get Current Platform ' + (useWu && platforms.wu ? platforms.wu : platforms.wa));
                return useWu && platforms.wu ? platforms.wu : platforms.wa;
            },

            setCurrentPlatform: function (platform) {
                var platforms = this.get();
                platforms[platform.type] = platform.id;

                if (platform.type === 'wa') {
                    platforms.wu = null;
                }
                //UWA.log('[Platform Synchro] Set current platform ' + JSON.stringify(platform));
                this.save(platforms);
            },

            /**
             * Initialize the Server. Use only in inline mode
             */
            initServer: function () {
                //UWA.log('[Platform Synchro] Init');
                // Create server
                this.server = new InterCom.Server(this.serverId, {isPublic: true});

                // Initialize saved state
                //this.save({wu: null, wa: null});
            },

            subscribe: function (options) {
                var id = this.getSocketId(),
                    socket = new InterCom.Socket(id);

                //UWA.log('[Platform Synchro] Subscribe ' + options.useWu + ' ' + id);
                socket.subscribeServer(this.serverId, window.parent);

                socket.addListener(this.events.platformChange, function (data) {
                    //UWA.log('[Platform Synchro] Receive ' + JSON.stringify(data));
                    // Call platform change cb only if listener requires it
                    if (data.type === 'wa' || (data.type === 'wu' && options.useWu)) {
                        options.onPlatformChange(data.id);
                    }
                });

                this.sockets[id] = socket;
                return id;
            },

            changePlatform: function (socketId, platform) {
                var socket = this.sockets[socketId],
                    data = {
                        id: platform.get('id'),
                        type: platform.get('platform') ? 'wa' : 'wu'
                    };
                this.setCurrentPlatform(data);

                //UWA.log('[Platform Synchro] Dispatch ' + socketId + ' ' + JSON.stringify(data));
                socket.dispatchEvent(this.events.platformChange, data);
            },

            save: function (data) {
                //UWA.log('[Platform Synchro] Save platform ' + JSON.stringify(data));

                try {
                    sessionStorage.setItem(this.storageId, Json.encode(data));
                } catch (e) {
                    UWA.log(e);
                }
            },

            get: function () {
                var data = {};
                try {
                    data = Json.decode(sessionStorage.getItem(this.storageId) || '{}');
                } catch (e) {
                    UWA.log(e);
                }
                return data;
            }
        });
    }
);

/**
 * @overview Platform Collection.
 */

/*global define*/
define(
    'DS/PlatformManagementComponents/Collection/Environment',
    [
        'UWA/Core',
        'UWA/Data',
        'UWA/Class/Collection',
        'DS/PlatformAPI/PlatformAPI',
        'DS/PlatformManagementComponents/Model/Platform'
    ],
    /**
     * @module PlatformManagementComponents/Collection/Platform
     *
     * @require UWA/Core
     * @require UWA/Class/Collection
     *
     * @extend UWA/Class/Collection
     */
    function (UWA, Data, Collection, PlatformAPI, PlatformModel) {
        'use strict';

        return Collection.extend({
            model: PlatformModel,

            platformListUrl: '{0}environment/list',
            sync: function (method, collection, options) {
                switch (method) {
                case 'read':
                    Data.request(this.platformListUrl, {
                        timeout: 15000,
                        cache: -1,
                        method: 'GET',
                        type: 'json',
                        headers: {
                            Accept: 'application/json',
                            'Accept-Language': options.lang
                        },
                        proxy: 'passport',
                        onComplete: function (data) {
                            if (options && options.onComplete) {
                                options.onComplete(data);
                            }
                        }
                    });
                    break;
                }
            },
            setup: function (options) {
                var baseUrl;

                this.lang = options.lang;
                baseUrl = '{0}/resources/AppsMngt/'.format(PlatformAPI.getApplicationConfiguration('app.urls.myapps'));

                this.platformListUrl = this.platformListUrl.format(baseUrl);
            },
            parse: function (data) {
                return data.environments;
            }
        });
    }
);

/**
 * @overview Platform Collection.
 */

/*global define*/
define(
    'DS/PlatformManagementComponents/Collection/Platform',
    [
        'UWA/Core',
        'UWA/Data',
        'UWA/Class/Collection',
        'DS/PlatformAPI/PlatformAPI',
        'DS/PlatformManagementComponents/Model/Platform',
        'DS/WAFData/WAFData'
    ],
    /**
     * @module PlatformManagementComponents/Collection/Platform
     *
     * @require UWA/Core
     * @require UWA/Class/Collection
     *
     * @extend UWA/Class/Collection
     */
    function (UWA, Data, Collection, PlatformAPI, PlatformModel, WAFData) {
        'use strict';

        var URL = '{0}/resources/AppsMngt/platform/list';

        return Collection.extend({

            model: PlatformModel,

            hasWu: false,

            sync: function (method, collection, options) {

                options.timeout = 60000;

                options.cache = -1;

                options.headers = {
                    Accept: 'application/json',
                    'Content-Type': 'application/json'
                };

                return this._parent(method, collection, UWA.merge({
                        ajax: WAFData.authenticatedRequest
                    }, options)
                );
            },

            setup: function (options) {

                this.includeWu = options.includeWu;

                this.lang = options.lang;

                this.url = URL.format(PlatformAPI.getApplicationConfiguration('app.urls.myapps'));
            },

            parse: function (data) {
                var platforms = [], that = this;

                if (data.platforms) {
                    // Remove WU platforms if not needed
                    data.platforms.forEach(function (platform) {
                        if (that.includeWu || platform.platform === true) {
                            platforms.push(platform);
                        }

                        if (platform.platform === false) {
                            that.hasWu = true;
                        }
                    });
                }

                return platforms;
            }
        });
    }
);

/*global define */
define(
    'DS/PlatformManagementComponents/View/PlatformSelector',
    [
        'UWA/Core',
        'UWA/Class/View',
        'UWA/Controls/Input',
        'DS/UIKIT/Input/Select',
        'DS/UIKIT/Tooltip',
        'DS/UIKIT/Spinner',
        'DS/PlatformManagementComponents/PlatformSynchro',
        'DS/PlatformManagementComponents/Collection/Platform',
        'DS/UIKIT/Touch',
        'UWA/Utils/Client',
        'UWA/Event',
        'i18n!PlatformManagementComponents/assets/nls/pmc',
        'css!DS/PlatformManagementComponents/PlatformManagementComponents'
    ],
    /**
     * @module PlatformManagement/Controls/PlatformSelector
     *
     * @require UWA/Core
     * @require UWA/Controls/Abstract
     * @require PlatformManagement/Controls/Loader
     * @require UWA/Controls/Input
     * @require PlatformManagement/Utils/Data
     * @require DS/UIKIT/Input/Select
     * @require DS/UIKIT/Tooltip
     * @require PlatformManagement/Model/Platform
     * @require i18n!PlatformManagementComponents/assets/nls/pmc
     * @returns {void|*|Function}
     */
    function (UWA, View, Input, Select, Tooltip, Spinner, PlatformSynchro, PlatformCollection, Touch, Client, Event, i18n) {

        'use strict';

        return View.extend({
            className: 'platform-management-toolbar-wrapper',
            /**
             * @property {Object} defaultOptions - The default controls options.
             * @private
             */
            defaultOptions: {
                menu: [],
                platformChange: function () {},
                includeWu: false,
                lang: 'en'
            },
            data: {
            },
            platformModel: null,
            socketId: null,
            getPlatform: function () {
                return this.platformModel;
            },
            /**
             * return the collection
             * @return {Collection} Platform collection
             */
            getPlatforms: function () {
                return this.platformCollection;
            },
            /**
             * @module PlatformManagement/Controls/PlatformSelector
             * This callback is displayed as part of the PlatformSelector class
             *
             * @callback PlatformManagement/Controls/PlatformSelector-onPlatformChange
             * @param {module:PlatformManagement/Model/Platform} platformModel - the platform model
             */

            /**
             * Display the platform selector with some button
             *
             * @example
             require(['PlatformManagement/Controls/PlatformSelector'], function (PlatformSelector) {

                new PlatformSelector({
                    menu: [
                        {
                            'data-title': 'My nice menu', //use a tooltip
                            'class': 'menu-grant fonticon fonticon-plus',
                            events: {
                                click: function () {
                                    UWA.log('item has been clicked');
                                }
                            }
                        },
                    ],
                    events: {
                        onPlatformChange: function (platform) {
                            UWA.log('Platform has changed:' + platform.getId())
                        }
                    }
                });
             });
             *
             * @param {Object}              options                                   - The available options.
             * @param {HTMLElement}         [options.menu]                            - An optional Array of menu item.
             * @param {Object}              [options.events]                          - Events
             * @param {Object}              [options.lang]                            - User language
             * @param {PlatformManagement/Controls/PlatformSelector-onPlatformChange}    [options.events.onPlatformChange]         - Callback when the platform changes, params PlatformManagement/Model/Platform
             *
             */

            setup: function (options) {
                this.platformCollection = new PlatformCollection({
                    includeWu: options.includeWu,
                    lang: options.lang
                });
            },
            /**
             * Refresh the component with the new options
             * @param options
             */
            refresh: function (options) {
                this.setOptions(options);
                this.options.menu = this.options.menu || [];
                return this.render();
            },
            render: function () {
                var that = this;
                this.mask();
                this.platformCollection.fetch({
                    includeWu: that.options.includeWu,
                    onComplete: function (collection) {
                        var includeWu = that.options.includeWu,
                            platformId;

                        if (!that.socketId) {
                            that.socketId = PlatformSynchro.subscribe({
                                useWu: includeWu,
                                onPlatformChange: function (platformId) {
                                    that.platformModel = that.platformCollection.get(platformId);
                                    that.platformChooser.setValue(platformId);
                                    that.dispatchEvent('onPlatformChange', that.platformModel);
                                }
                            });
                        }

                        platformId = PlatformSynchro.getCurrentPlatform(includeWu);
                        if (platformId) {
                            that.platformModel = collection.get(platformId);
                        } else {
                            that.platformModel = collection.first();
                        }

                        that.container.setContent(that.buildSkeleton());
                        that.unmask();

                        that.dispatchEvent('onPlatformChange', that.platformModel);
                    }
                });
                return this;
            },
            buildSkeleton: function () {
                return [{
                    'class': 'widget-toolbar',
                    /*styles: {
                        'min-height': this.platformCollection.size() === 1 && this.options.menu.length > 0 ? 65 : 51 //fix size of absolute menu
                    },*/
                    html: [
                        {
                            'class': 'platform-chooser-wrapper',
                            html: [
                                /*this.options.includeWu ? null : {
                                    text: i18n.selectplatform
                                },*/
                                this.buildPlatformChooser()
                            ],
                            styles: {
                                display: this.platformCollection.size() > 1 ? null : 'none'
                            }
                        },
                        {
                            'class': 'id-card ready actions',
                            styles: {
                                top: this.options.includeWu ? 0 : 15
                            },
                            html: this.buildMenu()
                        },
                        {'class': 'clear'}
                    ]
                }, {'class': 'clear'}/*, this.options.includeWu ? this.buildWUInformation() : null*/];
            },
            buildPlatformChooser: function () {
                var that = this,
                    platformOptions = this.platformCollection.map(function (platformModel) {
                        return {
                            label: platformModel.get('displayName'),
                            value: platformModel.get('id'),
                            selected: (platformModel === that.platformModel)
                        };
                    });

                this.platformChooser = new Select({
                    className: 'platform-chooser',
                    attributes: {
                        styles: {
                            'float': 'left'
                        }
                    },
                    placeholder: false,
                    options: platformOptions,
                    events: {
                        onChange: function (e) {
                            var platformModel = that.platformCollection.get(this.getValue()[0]);
                            if (platformModel !== that.platformModel) {
                                that.platformModel = platformModel;
                                that.dispatchEvent('onPlatformChange', that.platformModel);
                                PlatformSynchro.changePlatform(that.socketId, that.platformModel);
                            }
                            e.preventDefault();
                            e.stopPropagation();
                        }
                    }
                });

                return this.platformChooser;
            },
            buildMenu: function () {
                var items = [], i, menus = this.options.menu, len = menus.length;
                for (i = 0; i < len; i++) {
                    items.push(this.buildMenuItem(menus[i]));
                }
                return {
                    'class': 'actions-list',
                    html : items
                };
            },
            buildMenuItem: function (item) {
                var that = this,
                    isHidden = item['class'].contains('hidden') ? ' hidden' : '',
                    className = (item['class']) ? item['class'].replace('hidden', '') + ' menu-picture' : 'menu-picture',
                    elem =  UWA.createElement('span', {
                        'class': 'action interactive' + isHidden,
                        html: UWA.merge({
                            'class': className
                        }, item)
                    }),
                    hammer;

                if (item['data-title']) {
                    //if mobile
                    if (Client.Features.touchEvents) {
                        hammer =  new Touch(elem);

                        hammer.on('hold', function (e) {
                            Event.stop(e);
                            that.tooltip = new Tooltip({
                                position: 'bottom',
                                target: elem,
                                body: item['data-title'],
                                trigger: 'manual'
                            });
                            that.tooltip.toggle();
                        });

                        hammer.on('release', function () {
                            if (that.tooltip) {
                                that.tooltip.toggle();
                                that.tooltip = null;
                            }
                        });
                    } else {
                        that.tooltip = new Tooltip({
                            position: 'bottom',
                            target: elem,
                            body: item['data-title']
                        });
                    }
                }
                return elem;
            },
            /**
             * Build text information for WU platform
             * @private
             */
            /*buildWUInformation: function () {
                this.helpBlock = UWA.createElement('div', {
                    'class': 'help-block hidden',
                    styles: {
                        'text-align': 'center'
                    },
                    text: i18n.useoption
                });
                return this.helpBlock;
            },*/
            /**
             * Mask the Modal
             * @private
             */
            mask: function () {
                if (!this.loader) {
                    this.loader = UWA.createElement('div', {
                        'class': 'loading-mask',
                        html: {
                            'class': 'msg-wrap',
                            html: {
                                'class': 'msg-ctn',
                                html: new Spinner({visible: true})
                            }
                        }
                    }).inject(this.container);
                }
            },
            /**
             * Unmask the Modal
             * @private
             */
            unmask: function () {
                if (this.loader) {
                    this.loader.destroy();
                }
                this.loader = null;
            },

            onPlatformChange: function (platform) {
                if (this.helpBlock) {
                    this.helpBlock.toggleClassName('hidden', platform.get('platform') === true);
                }
            }

        });
    }
);


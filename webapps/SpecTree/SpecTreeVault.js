define('DS/SpecTree/SpecTreeVault', ['DS/Tree/TreeDocument', 'DS/Tree/TreeNodeModel'], function(TreeDocument, TreeNodeModel) {

    'use strict';

    // ---------------------------------
    // DEFINES
    // ---------------------------------

    var DEBUG_PROCESS_NODETYPE = false;

    var DEFAULT_APP_NS = 'default';
    var NODE_CATEGORIES = {
        MODEL: 'model',
        FAKE: 'fake',
        LAYOUT: 'layout'
    };


    /**
     * Callback function for events emmited from a SpecTreeNodeModel.
     * @callback SpecTreeVaultCB
     * @this {Undefined}
     * @param  {SpecTreeVaultCBInfos} modelEvent the model event being dispatched
     */

    /**
     *  @typedef SpecTreeVaultCBInfos
     *  @type {Object}
     *  @property  {module:DS/TreeModel/TreeNodeModel~TreeNodeModel}  nodeModel the emitter of the event responsible for this callbak for being called
     */

    /**
     *  @typedef SpecTreeVaultNotificationInfos
     *  @type {Object}
     *  @property  {Object}  icon the icon parameter to use with the service DS/Utilities/Utils.generateIcon
     *  @property  {String}  color the CSS color
     */

    /**
     *  @typedef SpecTreeVaultNotification
     *  @type {Object}
     *  @property  {SpecTreeVaultNotificationInfos}  NONE no notification
     *  @property  {SpecTreeVaultNotificationInfos}  INFO notification of kind INFO
     *  @property  {SpecTreeVaultNotificationInfos}  WARN notification of kind WARN
     *  @property  {SpecTreeVaultNotificationInfos}  ERROR notification of kind ERROR
     */
    var NOTIFICATIONS = {
        NONE: {
            icon: undefined,
            color: 'transparent'
        },
        ERROR: {
            icon: {
                fontIconFamily: WUXManagedFontIcons.FontAwesome,
                iconName: 'exclamation-circle'
            },
            color: '#EA4F37'
        },
        INFO: {
            icon: {
                fontIconFamily: WUXManagedFontIcons.FontAwesome,
                iconName: 'info-circle'
            },
            color: '#42A2DA'
        },
        WARNING: {
            icon: {
                fontIconFamily: WUXManagedFontIcons.FontAwesome,
                iconName: 'exclamation-triangle'
            },
            color: '#E87B00'
        }
    };


    function SpecTreeVault() {


        this.TYPES_VAULT = {};
        this.RESOLVED_TYPES_VAULT = {};
        this.DEFAULT_APP_NS = DEFAULT_APP_NS;
        this.NODE_CATEGORIES = NODE_CATEGORIES;
        this.NOTIFICATIONS = NOTIFICATIONS;

        return this;
    }


    /**
     *  @typedef SpecTreeVaultNodeTypeOptions
     *  @type {object}
     *  @property  {String}  [application]: the node application context (optional)
     *  @property  {String}  nodeCategory: the node category. Could be SpecTreeVault.NODE_CATEGORIES.MODEL, SpecTreeVault.NODE_CATEGORIES.FAKE or SpecTreeVault.NODE_CATEGORIES.LAYOUT
     *  @property  {String}  nodeType:  the node type could be anything, but should be unique in the JS execution context. You can use namespace using dot notation
     *  @property  {SpecTreeVaultCB}  onPreExpand:  callback being called when a node is expanded
     *  @property  {SpecTreeVaultCB}  onSelect:  callback being called when a node is selected
     *  @property  {SpecTreeVaultCB}  onUnselect:  callback being called when a node is unselected
     *  @property  {SpecTreeVaultCB}  onPreSelect:  callback being called when a node is preselected
     *  @property  {SpecTreeVaultCB}  onPreUnselect:  callback being called when a node is un-preselected
     *  @property  {SpecTreeVaultCB}  onEditLabel:  callback being called when a node label has been renamed
     *  @property  {SpecTreeVaultCB}  buildLabel:  callback being called when a node label should be displayed. You can use it to add some additional informations (i.e using parenthesis)
     *  @property  {SpecTreeVaultCB}  buildIcons:  callback being called when node icons should be displayed.
     *  @property  {SpecTreeVaultCB}  buildBadges:  callback being called when node badges/masks should be displayed. This callback must return an object with teh different badges
     *  @property  {SpecTreeVaultCB}  buildHoverBar:  callback being called when the hoverbar will be displayed. This callback should return the HoverBar menu model
     *  @property  {SpecTreeVaultCB}  buildContextualMenu:  callback being called when the contextual menu will be displayed. This callback should return the contextual menu model
     */


    // ---------------------------------
    // SPECTREEVAULT
    // ---------------------------------
    // SpecTreeVault.prototype = {

    /**
     *
     * Register a Model Node Type
     *
     * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
     *
     * @return {undefined}         nothing
     */
    SpecTreeVault.prototype.registerModelNodeType = function(options) {
        options.nodeCategory = this.NODE_CATEGORIES.MODEL;
        return this._registerNodeType(options);
    };

    /**
     *
     * Register a Fake Node Type
     *
     * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
     *
     * @return {undefined}         nothing
     */
    SpecTreeVault.prototype.registerFakeNodeType = function(options) {
        options.nodeCategory = this.NODE_CATEGORIES.FAKE;
        return this._registerNodeType(options);
    };

    /**
     *
     * Register a Fake Node Type
     *
     * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
     *
     * @return {undefined}         nothing
     */
    SpecTreeVault.prototype.registerLayoutNodeType = function(options) {
        options.nodeCategory = this.NODE_CATEGORIES.LAYOUT;
        return this._registerNodeType(options);
    };


    /**
     *
     * Register a Generic Node Type
     *
     * @private
     *
     * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
     *
     * @return {undefined}         nothing
     */
    SpecTreeVault.prototype._registerNodeType = function(options) {

        var namespace = options.application ? options.application : this.DEFAULT_APP_NS;
        var nodeType = options.nodeType;
        var nodeCategory = options.nodeCategory;


        if (!options.nodeType) {
            throw 'Cannot register a nodeType without a nodeType option specified';
        }

        if (!options.nodeCategory) {
            throw 'Cannot register a nodeCategory without a nodeCategory option specified';
        }

        if (this.doesNodeTypeExist(options) === true) {
            throw 'This node type has already been registered';
        }

        var me = this;
        var test = Object.keys(this.NODE_CATEGORIES).some(function(category) {
            return me.NODE_CATEGORIES[category] === options.nodeCategory;
        });
        if (!test) {
            throw 'Node type: "' + nodeType + '" has already been registered';
        }





        var writeTypesVaultUnit = function(currentObj, path, value) {
            if (path.length > 1) {
                var currentProp = path[0];
                if (currentObj[currentProp] === undefined) {
                    currentObj[currentProp] = {};
                }
                path.shift();
                writeTypesVaultUnit(currentObj[currentProp], path, value);
            } else {
                currentObj[path[0]] = {
                    __definition__: value
                };
                return currentObj;
            }
        };

        var me = this;
        var writeTypesVault = function(jsonPath, value) {
            var path = jsonPath.split('.');
            writeTypesVaultUnit(me.TYPES_VAULT, path, value);
        };

        // -- if nodeType has not been yet registered create its namespace --
        if (!this.getRegisteredNodeType(nodeCategory, nodeType, namespace)) {

            // -- /!\ -- DO NOT IMPLEMENT ANY DEFAULT CALLBACK,
            // IT WILL BREAK THE NAMESPACE MECHANISM
            // WHICH USE UNDEFINED CALLBACK IN ORDER
            // TO KNOW THE ONE TO INHERIT FROM

            var prefix = 'Error registering nodeType: "' + nodeType + '"';
            // -- Check if minimum callbacks has been defined
            // if (!options.buildIcons) {
            //     throw prefix + ', "buildIcons" callback has not been defined';
            // }
            if (!options.buildLabel) {
                throw prefix + ', "buildLabel" callback has not been defined';
            }
            // if (!options.buildBadges) {
            //     throw prefix + ', "buildBadges" callback has not been defined';
            // }
            var mergedOptions = options;

            writeTypesVault(namespace + '.' + nodeCategory + '.' + nodeType, mergedOptions);

        } else {
            throw 'Node type: "' + nodeType + '" has already been registered';
        }

    };

    /**
     *
     * Tell if a Node Type exists or not
     *
     * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
     *
     * @return {Boolean}         returns true if exist, false if not
     */
    SpecTreeVault.prototype.doesNodeTypeExist = function(options) {

        options.application = options.application ? options.application : this.DEFAULT_APP_NS;


        // if (this.TYPES_VAULT[options.application] && this.TYPES_VAULT[options.application][options.nodeCategory] && this.TYPES_VAULT[options.application][options.nodeCategory][options.nodeType]) {
        //     return true;
        // } else {
        //     return false;
        // }
        //
        var resolved = UWA.Json.path(this.TYPES_VAULT, '$.' + [options.application, options.nodeCategory, options.nodeType].join('.'));

        return resolved !== false;
    };


    SpecTreeVault.prototype.searchNodeType = function(options) {
        var results = UWA.Json.path(this.TYPES_VAULT, '$..' + options.nodeType, {
            resultType: 'PATH'
        });
        // console.log(results);
        if (results) {
            return results.map(function(result) {
                return JSON.parse(result.replace('$', '').replace(/\]\[/g, ',').replace(/'/g, '"'));
            });
        } else {
            return [];
        }
        // nodeType = obj ? obj.__definition__.nodeType : nodeType;
    };

    // SpecTreeVault.prototype.getRegisteredNodeTypes = function(appName, nodeCategory) {
    //     return this.TYPES_VAULT[appName][nodeCategory];
    // };


    SpecTreeVault.prototype.getResolvedNodeOptions = function(options) {
        if (this.RESOLVED_TYPES_VAULT[options.application] === undefined) {
            this.RESOLVED_TYPES_VAULT[options.application] = {};
        }

        if (this.RESOLVED_TYPES_VAULT[options.application][options.nodeCategory] === undefined) {
            this.RESOLVED_TYPES_VAULT[options.application][options.nodeCategory] = {};
        }

        if (this.RESOLVED_TYPES_VAULT[options.application][options.nodeCategory][options.nodeType] === undefined) {
            this.RESOLVED_TYPES_VAULT[options.application][options.nodeCategory][options.nodeType] = this._mergeNodeType(options.nodeCategory, options.nodeType, options.application);
        }

        return this.RESOLVED_TYPES_VAULT[options.application][options.nodeCategory][options.nodeType];

    };

    SpecTreeVault.prototype.getResolvedNodeType = function(nodeCategory, nodeType, appName) {
        return this.getResolvedNodeOptions({
            application: appName,
            nodeCategory: nodeCategory,
            nodeType: nodeType
        });

    };

    SpecTreeVault.prototype._processNodeType = function(nodeCategory, nodeType, appName, callback, grpName) {
        var out;
        var mergedOptions = {};
        var me = this;

        var initialPath = nodeType.split('.');

        var _mergeNodeTypeUnit = function(nodeCategory, currentPath, appName, merged) {
            var nodeTypeOptionsForApp = me.getRegisteredNodeType(nodeCategory, currentPath, me.DEFAULT_APP_NS);
            if (nodeTypeOptionsForApp) {
                callback({
                    nodeCategory: nodeCategory,
                    nodeType: currentPath,
                    application: me.DEFAULT_APP_NS,
                    options: nodeTypeOptionsForApp
                });
                if (DEBUG_PROCESS_NODETYPE) {
                    console.log('-->', currentPath, nodeTypeOptionsForApp);
                }
            }
            if (appName) {

                var nodeTypeOptionsForApp = me.getRegisteredNodeType(nodeCategory, currentPath, appName);
                if (nodeTypeOptionsForApp) {
                    callback({
                        nodeCategory: nodeCategory,
                        nodeType: currentPath,
                        application: appName,
                        options: nodeTypeOptionsForApp
                    });
                    if (DEBUG_PROCESS_NODETYPE) {
                        console.log('-->', currentPath, nodeTypeOptionsForApp);
                    }

                }
            }


            if (initialPath.length > 1) {
                if (DEBUG_PROCESS_NODETYPE) {
                    console.group(grpName);
                }
                initialPath.shift();
                out = _mergeNodeTypeUnit(nodeCategory, currentPath + '.' + initialPath[0], appName, merged);
                if (DEBUG_PROCESS_NODETYPE) {
                    console.groupEnd(grpName);
                }
            } else {
                out = merged;
            }
            return out;
        };

        return _mergeNodeTypeUnit(nodeCategory, initialPath[0], appName, mergedOptions);
    };

    SpecTreeVault.prototype._mergeNodeType = function(nodeCategory, nodeType, appName) {
        var mergedOptions = {};


        var initialPath = nodeType.split('.');

        var me = this;
        var _mergeNodeTypeUnit = function(nodeCategory, currentPath, appName, merged) {
            if (initialPath.length > 1) {
                var nodeTypeOptionsForApp = me.getRegisteredNodeType(nodeCategory, currentPath, appName);
                if (nodeTypeOptionsForApp) {
                    merged = UWA.extend(merged, nodeTypeOptionsForApp, true);
                }
                initialPath.shift();
                return _mergeNodeTypeUnit(nodeCategory, currentPath + '.' + initialPath[0], appName, merged);
            } else {
                var nodeTypeOptionsForApp = me.getRegisteredNodeType(nodeCategory, currentPath, appName);
                if (nodeTypeOptionsForApp) {
                    merged = UWA.extend(merged, nodeTypeOptionsForApp, true);
                }
                return merged;
            }
        };

        return _mergeNodeTypeUnit(nodeCategory, initialPath[0], appName, mergedOptions);
    };


    SpecTreeVault.prototype.getRegisteredNodeCategory = function(nodeCategory, appName) {
        if (appName === undefined) {
            appName = this.DEFAULT_APP_NS;
        }
        var query = UWA.Json.path(this.TYPES_VAULT[appName], '$' + nodeCategory);

        if (query && query.length === 1) {
            return query[0];
        } else {
            return;
        }
    };



    SpecTreeVault.prototype.getRegisteredNodeType = function(nodeCategory, nodeType, appName) {
        if (appName === undefined) {
            appName = this.DEFAULT_APP_NS;
        }

        if (this.TYPES_VAULT[appName] && this.TYPES_VAULT[appName][nodeCategory]) {
            var query = UWA.Json.path(this.TYPES_VAULT[appName][nodeCategory], '$' + nodeType + '.' + '__definition__');

            if (query && query.length === 1) {
                return query[0];
            } else {
                return;
            }
        } else {
            return;
        }
    };


    /**
     * Return notification informations such color and icon
     * @param  {SpecTreeVaultNotification} notif the notification
     * @return {SpecTreeVaultNotificationInfos}       the notification infos
     */
    SpecTreeVault.prototype.getNotificationInfos = function(notif) {
        var infos = this.NOTIFICATIONS[notif];
        if (infos) {
            return infos;
        } else {
            return {
                icon: undefined,
                color: 'transparent'
            };
        }
    };




    return SpecTreeVault;

});

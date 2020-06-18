define('DS/SpecTree/SpecTreeDocument', ['DS/SpecTree/SpecTreeVault', 'DS/Tree/TreeDocument', 'DS/Tree/TreeNodeModel'], function(SpecTreeVault, TreeDocument, TreeNodeModel) {

    'use strict';



    var DEFAULT_APP_NS = 'default';


    /**
     *  @typedef SpecTreeNodeModelOptions
     *  @type {Object}
     *  @property  {String|HTML}  label the label of the TreeNode
     *  @property  {(String[]|Object[])}  icons an array of picture urls (String) or/and object describing an icon like the service  DS/Utilities/Utils.generateIcon
     *  @property  {(null|module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel[])}  children if you want no children and no expander set it to null. If you want no children but with an expander set it to []. If you've got children set it to {@link module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel[] SpecTreeNodeModel[]} or {@link SpecTreeNodeModelOptions[]}
     *  @property {SpecTreeVaultNotification} [notification] the notification state of the node
     *  @property {String} [color] the color to display in the color column
     *  @property {String} [borderColor] the color to display in the borderColor column
     */



    function createNode(specTreeVlt, nodeCategory, options) {

        var nodeOptions;

        var appName = options.application ? options.application : DEFAULT_APP_NS;
        var nodeType = options.nodeType;
        if (nodeType) {
            var registeredType = specTreeVlt.getRegisteredNodeType(nodeCategory, nodeType, appName);
            if (registeredType) {
                nodeOptions = {
                    icons: options.icons,
                    label: options.label,
                    children: options ? options.children : null
                };
            } else {
                throw 'Cannot create node. No registered node type' + appName + ' ' + nodeCategory + ' ' + nodeType;
            }
        } else {
            nodeOptions = {
                icons: options.icons,
                label: options.label,
                children: options ? options.children : null
            };
        }

        var nodeModel = new SpecTreeNodeModel(nodeOptions);

        // -- private fields --
        nodeModel.__private__ = {
            // label: options.label,
            // icons: [],
            nodeCategory: options.nodeCategory,
            nodeType: options.nodeType,
            notification: options.notification,
            color: options.color,
            borderColor: options.borderColor
        };

        // -- public fields --
        // nodeModel.options.grid = options.grid || {};
        // nodeModel.__data__ = options.data || {};

        // -- applying nodeCategory and nodeType --
        nodeModel._setNodeCategory(nodeCategory);
        nodeModel._setNodeType(options.nodeType);

        // -- last compliance check --
        if (nodeModel._getNodeCategory() === undefined || nodeModel._getNodeType() === undefined) {
            throw 'Node is not compliant with the SpecTree Model';
        }


        return nodeModel;
    }




    /*
    ███    ██  ██████  ██████  ███████ ███    ███  ██████  ██████  ███████ ██
    ████   ██ ██    ██ ██   ██ ██      ████  ████ ██    ██ ██   ██ ██      ██
    ██ ██  ██ ██    ██ ██   ██ █████   ██ ████ ██ ██    ██ ██   ██ █████   ██
    ██  ██ ██ ██    ██ ██   ██ ██      ██  ██  ██ ██    ██ ██   ██ ██      ██
    ██   ████  ██████  ██████  ███████ ██      ██  ██████  ██████  ███████ ███████
    */


    /**
     * Create a SpecTreeNodeModel
     *
     * @module DS/SpecTree/SpecTreeNodeModel
     */

    /**
     * Create a SpecTreeNodeModel. You should not use the constructor form directly. Please use on of the available factories
     *
     * @constructor SpecTreeNodeModel
     *
     * @alias module:DS/SpecTree/SpecTreeNodeModel
     * @augments module:DS/TreeModel/TreeNodeModel~TreeNodeModel
     *
     * @param {module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel} options the TreeListView options
     *
     */
    var SpecTreeNodeModel = TreeNodeModel.extendNode({

        /**
         * @lends module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel.prototype
         */
        // -- here are stored all private members,
        // in order to avoid to store them in options
        __private__: {},

        _getContext: function() {
            var treeDoc = this.getTreeDocument();
            if (treeDoc) {
                var appName = treeDoc.getCurrentApplication();
                var nodeCategory = this._getNodeCategory();
                var nodeType = this._getNodeType();
                return {
                    treeDocument: treeDoc,
                    treeVault: treeDoc._specTreeVlt,
                    application: appName,
                    nodeCategory: nodeCategory,
                    nodeType: nodeType
                };
            }
        },

        _getResolved: function() {
            var context = this._getContext();
            if (context) {
                // - PERFS: be sure that this call does not cost too much time --
                // console.time('node resolution');
                var resolved = context.treeVault.getResolvedNodeType(context.nodeCategory, context.nodeType, context.application);
                // console.timeEnd('node resolution');

                if (resolved) {
                    this.__resolved__ = resolved;

                    return this.__resolved__;
                } else {
                    console.error(context);
                    throw 'Node context is uncorrect, check that application, nodeCategory or nodeType is correct and has been registered';
                }
            } else {
                console.log('unable to get resolved node. May be the node just have been removed');
                return {};
            }
        },

        _getResolvedAndCall: function(callbackName, fallback) {
            var resolved = this._getResolved()[callbackName];
            if (resolved) {
                return resolved({
                    nodeModel: this
                });
            } else {
                if (fallback) {
                    return fallback({
                        nodeModel: this
                    });
                }
            }
        },

        getResolved: function() {
            return this._getResolved();
        },


        getResolvedAndCall: function(callbackName, fallback) {
            return this._getResolvedAndCall(callbackName, fallback);
        },

        // /!\ -- SpecTree override, in order to ensure that only SpecTreeNodeModel are added
        addChild: function(options, index) {
            var me = this;
            if (options instanceof Array) {
                if (options.length === 0) {
                    this._parent(options, index);

                } else {
                    me.prepareUpdate();
                    options.forEach(function(nodeOptions, index2) {
                        me.addChild(nodeOptions, index + index2);
                    });
                    me.pushUpdate();
                }
            } else {
                if (options instanceof SpecTreeNodeModel) {
                    this._parent(options, index);
                } else {
                    this._parent(new SpecTreeNodeModel(options), index);
                    // throw 'Please use the SpecTeeDocument.createNode(this._specTreeVlt, ) factory';
                }
            }
        },


        getIcons: function() {
            return this.options.icons || this._getResolvedAndCall('buildIcons');
        },

        getLabel: function() {
            return this._getResolvedAndCall('buildLabel');
        },

        getBadges: function() {
            return this._getResolvedAndCall('buildBadges', function fallbackBuildBadges() {
                return {
                    topLeft: '',
                    topRight: '',
                    bottomLeft: '',
                    bottomRight: ''
                };
            });
        },

        getColor: function() {
            var resolved = this._getResolved().buildColor;
            if (resolved) {
                return resolved({
                    nodeModel: this
                });
            } else {
                return this.__private__.color || 'transparent';
            }
        },

        getBorderColor: function() {
            var resolved = this._getResolved().buildBorderColor;
            if (resolved) {
                return resolved({
                    nodeModel: this
                });
            } else {
                return this.__private__.borderColor || 'transparent';
            }
        },

        getNotification: function() {
            return this.__private__.notification;
        },

        setNotification: function(notification) {
            this.__private__.notification = notification;
        },

        // getChildren: function() {
        //     return this._parent();
        // },

        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        getPath: function() {
            return this._parent().filter(function(node) {
                return !node._isLayoutNode();
            });
        },

        _getParentModel: function() {
            var parentNode = this.getParent();
            if (parentNode.isModelNode()) {
                return parentNode;
            } else {
                return parentNode._getParentModel();
            }
        },

        getAndProcessFeatures: function(cb) {
            if (this.getChildren()) {
                return this.getChildren().filter(function(node) {
                    if (node.options.isFeature === true) {
                        cb(node);
                    }
                });
            } else {
                return [];
            }
        },


        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        select: function(unique) {

            // if (this._getNodeCategory() === this._specTreeVlt.NODE_CATEGORIES.FAKE) {
            //     return;
            // }

            // -- if is a layout node, we select all its subnodes --
            if (this._isLayoutNode('layout-horizontal')) {
                this.withTransactionUpdate(function selectSubNodes() {
                    this._parent(unique);
                    this.getChildren().forEach(function selectSubnode(subNode) {
                        subNode.select();
                    });
                });
            } else {
                var parentNode = this.getParent();
                // -- if parent node is a layout node, and all sub-nodes are selected we select the layout node too
                if (parentNode._isLayoutNode('layout-horizontal')) {
                    this.withTransactionUpdate(function() {
                        this._parent(unique);
                        if (parentNode.areAllChildrenSelected() && !parentNode.isSelected()) {
                            parentNode.select();
                        }
                    });
                }
                // -- normal behavior --
                else {
                    this._parent(unique);
                }
            }

        },

        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        unselect: function() {

            // -- if is a layout node, we unselect all its subnodes --
            if (this._isLayoutNode('layout-horizontal')) {
                this.withTransactionUpdate(function() {
                    this._parent();
                    if (this.areAllChildrenSelected()) {
                        this.getChildren().forEach(function(subNode) {
                            subNode.unselect();
                        });
                    }
                });
            } else {
                var parentNode = this.getParent();
                // -- if parent node is a layout node, and all sub-nodes are selected we select the layout node too
                if (parentNode._isLayoutNode('layout-horizontal')) {
                    this.withTransactionUpdate(function() {
                        this._parent();
                        if (!parentNode.areAllChildrenSelected() && parentNode.isSelected()) {
                            parentNode.unselect();
                        }
                    });
                }
                // -- normal behavior --
                else {
                    this._parent();
                }
            }

        },

        preExpandDone: function(options) {
            var parentPreExpandDone = this._parent;
            parentPreExpandDone.call(this, options);
        },

        _getNodeCategory: function() {
            return this.__private__.nodeCategory;
        },
        _getNodeType: function() {
            return this.__private__.nodeType;
        },

        _setNodeCategory: function(nodeCategory) {
            this.__private__.nodeCategory = nodeCategory;
        },
        _setNodeType: function(nodeType) {
            this.__private__.nodeType = nodeType;
        },

        /**
         * Returns if this node is a model node or not
         * @param  {String} [nodeType] An optional nodeType. If defined, will check if this node is a Model Node of the nodeType specified
         * @return {Boolean}          Returns true if it's a model node, false else
         */
        isModelNode: function(nodeType) {
            if (nodeType) {
                return this._getNodeCategory() === 'model' && this._getNodeType() === nodeType;
            } else {
                return this._getNodeCategory() === 'model';
            }
        },

        /**
         * Returns if this node is a fake node or not
         * @param  {String} [nodeType] An optional nodeType. If defined, will check if this node is a Fake Node of the nodeType specified
         * @return {Boolean}          Returns true if it's a fake node, false else
         */
        isFakeNode: function(nodeType) {
            return this._isFakeNode(nodeType);
        },

        _isLayoutNode: function(nodeType) {
            if (nodeType) {
                return this._getNodeCategory() === 'layout' && this._getNodeType() === nodeType;
            } else {
                return this._getNodeCategory() === 'layout';
            }
        },

        _isFakeNode: function(nodeType) {
            if (nodeType) {
                return this._getNodeCategory() === 'fake' && this._getNodeType() === nodeType;
            } else {
                return this._getNodeCategory() === 'fake';
            }
        },

        _isSubnode: function() {
            return this.getParent() && this.getParent()._isLayoutNode('layout-horizontal');
        },

        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        getNextVisibleNode: function() {
            var nextNode = TreeNodeModel.prototype.getNextVisibleNode.apply(this);
            if (nextNode) {
                if (nextNode._isLayoutNode()) {
                    return nextNode.getNextVisibleNode();
                } else {
                    return nextNode;
                }
            }
        },

        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        getPreviousVisibleNode: function() {
            var nextNode = TreeNodeModel.prototype.getPreviousVisibleNode.apply(this);
            if (nextNode) {
                if (nextNode._isLayoutNode()) {
                    return nextNode.getPreviousVisibleNode();
                } else {
                    var nextVisibleNode = this.getPreviousNode();
                    if (nextVisibleNode && nextVisibleNode.isVisible() === false) {
                        return this.getPreviousVisibleNode();
                    } else {
                        return nextVisibleNode;
                    }
                }
            }
        },

        // /!\ -- SpecTree override, in order to ignore some specific layout nodes
        collapse: function(options) {
            // return this._parent(options);
            if (!this._isLayoutNode()) {
                return TreeNodeModel.prototype.collapse.apply(this, options);
            } else {
                this.prepareUpdate();
                this._modelEvents.publish({
                    event: 'preCollapse',
                    data: {
                        // cellView: this,
                        nodeModel: this,
                        virtualRowID: this._rowID
                        // virtualColumnID: me.getVirtualCoordinates().virtualColumnID
                    },
                    context: this
                });
                this._modelEvents.publish({
                    event: 'collapse',
                    data: {
                        // cellView: this,
                        nodeModel: this,
                        virtualRowID: this._rowID
                        // virtualColumnID: me.getVirtualCoordinates().virtualColumnID
                    },
                    context: this
                });
                this._modelEvents.publish({
                    event: 'postCollapse',
                    data: {
                        // cellView: this,
                        nodeModel: this,
                        virtualRowID: this._rowID
                        // virtualColumnID: me.getVirtualCoordinates().virtualColumnID
                    },
                    context: this
                });
                this.pushUpdate();
            }
        },

        /**
         * Returns if a node is visible in the SpecTreeDocument
         * @return {Boolean} True if visible,else false
         */
        isVisibleInSpecTree: function() {
            if (this._specTreeVisibility === undefined) {
                this._specTreeVisibility = true;
            }
            return this._specTreeVisibility;
        },

        /**
         * Set the visibility of the node
         * @param  {value} value true for visible, fale for not visible
         * @return {undefined}
         */
        setVisibilityInSpecTree: function(value) {
            if (this._isLayoutNode('layout-horizontal')) {
                this.withTransactionUpdate(function selectSubNodes() {
                    // this._parent(value);
                    // console.log('Node is layout so all children will be', value);
                    this._specTreeVisibility = value;
                    this.notifyModelUpdate();
                    this.getChildren().forEach(function selectSubnode(subNode) {
                        // subNode.setVisibilityInSpecTree(value);
                        subNode._specTreeVisibility = value;
                        subNode.notifyModelUpdate();
                    });
                });
            } else {
                var parentNode = this.getParent();
                // -- if parent node is a layout node, and all sub-nodes are selected we select the layout node too
                if (parentNode._isLayoutNode('layout-horizontal')) {
                    // if (parentNode.isVisibleInSpecTree()) {
                    this.withTransactionUpdate(function() {
                        // console.log('Parent Node is layout so we check if all children are', value);
                        this._specTreeVisibility = value;
                        if (parentNode.areAllChildrenVisibleInSpecTree() === !value && parentNode.isVisibleInSpecTree() === !value) {
                            parentNode.setVisibilityInSpecTree(value);
                        }
                    });
                    // }
                }
                // -- normal behavior --
                else {
                    this.withTransactionUpdate(function() {
                        this._specTreeVisibility = value;
                        this.notifyModelUpdate();
                    });
                }
            }
        },

        areAllChildrenVisibleInSpecTree: function() {
            var nope = true;
            if (this.hasChildren()) {
                var children = this.getChildren();
                for (var i = 0; i < children.length && nope; i++) {
                    if (children[i].isVisibleInSpecTree() === false) {
                        nope = false;
                    }
                }
            }
            return nope;
        },

        isUIActive: function(isUIActive) {
            return this._isUIActive !== undefined ? this._isUIActive : false;
        },

        _setUIActive: function(isUIActive) {
            this._isUIActive = isUIActive;
        },

        _suppress: function() {
            if (this._isSuppressed() === false) {
                this.__isSuppressed = true;
                this.notifyModelUpdate();
            }
        },

        _isSuppressed: function() {
            return this.__isSuppressed !== undefined ? this.__isSuppressed : false;
        },

        _unsuppress: function() {
            if (this._isSuppressed() === true) {
                this.__isSuppressed = false;
                this.notifyModelUpdate();
            }
        },


        _afterRollbackCursor: function() {
            if (this._isAfterRollbackCursor() === false) {
                this.__isAfterRollbackCursor = true;
                this.notifyModelUpdate();
            }
        },

        _isAfterRollbackCursor: function() {
            return this.__isAfterRollbackCursor !== undefined ? this.__isAfterRollbackCursor : false;
        },

        _beforeRollbackCursor: function() {
            if (this._isAfterRollbackCursor() === true) {
                this.__isAfterRollbackCursor = false;
                this.notifyModelUpdate();
            }
        },

        // _setInWork: function(isUIActive) {
        //     this._isUIActive = isUIActive;
        // },

        matchSearch: function(focus) {
            this._isMatchingSearchFocused = focus;
            return this._parent();
        },

        unmatchSearch: function() {
            this._isMatchingSearchFocused = false;
            return this._parent();
        }

        // hasFeatures: function() {
        //     if (this._getNodeCategory() === this._specTreeVlt.NODE_CATEGORIES.MODEL && this.options.nodeSubCategory !== this._specTreeVlt.NODE_CATEGORIES.FEATURE) {
        //
        //         var appName = this.getTreeDocument().options.appName;
        //         var nodeType = this.options.nodeType;
        //         var registeredType = this._specTreeVlt.getRegisteredNodeType(nodeType, appName);
        //
        //         return registeredType.listOfFeatures.length > 0;
        //     } else {
        //         return false;
        //     }
        // }
    });


    /*
    ████████ ██████  ███████ ███████ ██████   ██████   ██████ ██    ██ ███    ███ ███████ ███    ██ ████████
       ██    ██   ██ ██      ██      ██   ██ ██    ██ ██      ██    ██ ████  ████ ██      ████   ██    ██
       ██    ██████  █████   █████   ██   ██ ██    ██ ██      ██    ██ ██ ████ ██ █████   ██ ██  ██    ██
       ██    ██   ██ ██      ██      ██   ██ ██    ██ ██      ██    ██ ██  ██  ██ ██      ██  ██ ██    ██
       ██    ██   ██ ███████ ███████ ██████   ██████   ██████  ██████  ██      ██ ███████ ██   ████    ██
    */


    /**
     * Create a TreeDocument model with typed TreeNodeModels aka SpecTreeNodeModel
     *
     * @module DS/SpecTree/SpecTreeDocument
     */

    /**
     * Create a SpecTreeDocument.
     *
     * @constructor
     *
     * @alias module:DS/SpecTree/SpecTreeDocument
     * @augments module:DS/TreeModel/TreeDocument~TreeDocument
     *
     * @param {TreeDocumentConstructorOptions} options options hash or a option/value pair.
     *
     */
    var SpecTreeDocument = TreeDocument.extend({

        /**
         * @lends module:DS/SpecTree/SpecTreeDocument~SpecTreeDocument.prototype
         */
        defaultOptions: {
            useAsyncPreExpand: true,
            shouldBeSelected: function(nodeModel) {
                if (nodeModel._getNodeCategory() === this._specTreeVlt.NODE_CATEGORIES.MODEL) {
                    return true;
                } else {
                    if (nodeModel._getNodeCategory() === this._specTreeVlt.NODE_CATEGORIES.LAYOUT && nodeModel._getNodeType() === 'layout-horizontal') {
                        return true;
                    } else {
                        return false;
                    }
                }
            },
            shouldBeEditable: function(nodeInfos) {
                return true; //nodeInfos.options.nodeType !== 'fake';
            },
            shouldAcceptDrag: function() {
                return false;
            },
            shouldAcceptDrop: function() {
                return false;
            },
            nodeModelClass: SpecTreeNodeModel
        },
        init: function(options) {
            this._parent(options);

            this._handleEvents();
            this._currentApplication = null;

            this._listOfUIActiveNodes = [];

            this._specTreeVlt = new SpecTreeVault();

            this._registerDefaultNodes();
            this._manageResolvedCallbacks();

        },

        getVault: function() {
            return this._specTreeVlt;
        },

        setVault: function(vault) {
            this._specTreeVlt = vault;
        },






        _manageResolvedCallbacks: function() {
            this.onPreExpand(function(modelEvt) {
                var currentlyExpandingNode = modelEvt.target;
                setTimeout(function() {
                    var customOnPreExpand = currentlyExpandingNode._getResolved().onPreExpand;

                    // -- if onPreExpand callback has been implemented by the node type call it --
                    if (customOnPreExpand) {
                        customOnPreExpand({
                            nodeModel: currentlyExpandingNode
                        });
                    }

                    // -- else do nothing and finish the preExpand state --
                    else {
                        currentlyExpandingNode.preExpandDone();
                    }
                }, 0);
            });

            // -- selection --
            var xso = this.getXSO();
            xso.onAdd(function(node) {
                // var lastSelectedElt = xso.get()[xso.get().length - 1];
                var resolvedCallback = node._getResolved().onSelect;
                if (resolvedCallback) {
                    resolvedCallback({
                        nodeModel: node
                    });
                }
            });
            xso.onRemove(function(node) {
                var resolvedCallback = node._getResolved().onUnselect;
                if (resolvedCallback) {
                    resolvedCallback({
                        nodeModel: node
                    });
                }
            });

            // -- preselection --
            var pxso = this.getPXSO();
            pxso.onAdd(function(node) {
                // var lastSelectedElt = xso.get()[xso.get().length - 1];
                var resolvedCallback = node._getResolved().onPreSelect;
                if (resolvedCallback) {
                    resolvedCallback({
                        nodeModel: node
                    });
                }
            });
            pxso.onRemove(function(node) {
                var resolvedCallback = node._getResolved().onPreUnselect;
                if (resolvedCallback) {
                    resolvedCallback({
                        nodeModel: node
                    });
                }
            });
        },


        _registerDefaultNodes: function() {
            if (this._specTreeVlt.doesNodeTypeExist({
                    application: this.getCurrentApplication(),
                    nodeCategory: this._specTreeVlt.NODE_CATEGORIES.FAKE,
                    nodeType: 'section'
                }) === false) {
                this._specTreeVlt.registerFakeNodeType({
                    icons: [{
                        iconName: 'expand-right'
                    }],
                    nodeType: 'section',
                    buildIcons: function(infos) {
                        return infos.nodeModel.options.icons;
                    },
                    buildLabel: function(infos) {
                        return infos.nodeModel.options.label;
                    },
                    buildBadges: function() {

                    },
                    onPreExpand: function(infos) {
                        infos.nodeModel.preExpandDone();
                    }

                });
            }

            if (this._specTreeVlt.doesNodeTypeExist({
                    application: this.getCurrentApplication(),
                    nodeCategory: this._specTreeVlt.NODE_CATEGORIES.FAKE,
                    nodeType: 'more/less'
                }) === false) {
                this._specTreeVlt.registerFakeNodeType({
                    icons: [],
                    nodeType: 'more/less',
                    buildIcons: function(infos) {
                        if (infos.nodeModel.isExpanded()) {
                            return [{
                                iconName: 'minus'
                            }];
                        } else {
                            return [{
                                iconName: 'plus'
                            }];
                        }
                    },
                    buildLabel: function(infos) {
                        var moreless;
                        if (infos.nodeModel.isExpanded()) {
                            moreless = 'less on';
                        } else {
                            moreless = 'more on';
                        }
                        return moreless + ' ' + infos.nodeModel.getParent().options.label;
                    },
                    buildBadges: function() {

                    },
                    onPreExpand: function(infos) {
                        infos.nodeModel.preExpandDone();
                    }

                });
            }

            //
            if (this._specTreeVlt.doesNodeTypeExist({
                    application: this.getCurrentApplication(),
                    nodeCategory: this._specTreeVlt.NODE_CATEGORIES.LAYOUT,
                    nodeType: 'layout-horizontal'
                }) === false) {
                this._specTreeVlt.registerLayoutNodeType({
                    icons: [{
                        iconName: 'folder'
                    }],
                    nodeType: 'layout-horizontal',
                    buildIcons: function() {
                        return [];
                    },
                    buildLabel: function() {

                    },
                    buildBadges: function() {

                    },
                    onPreExpand: function(infos) {
                        infos.nodeModel.preExpandDone();
                    }
                });
            }

            //
            if (this._specTreeVlt.doesNodeTypeExist({
                    application: this.getCurrentApplication(),
                    nodeCategory: this._specTreeVlt.NODE_CATEGORIES.LAYOUT,
                    nodeType: 'rollbackable-children'
                }) === false) {
                this._specTreeVlt.registerLayoutNodeType({
                    icons: [{
                        iconName: 'folder'
                    }],
                    nodeType: 'rollbackable-children',
                    buildIcons: function() {
                        return [];
                    },
                    buildLabel: function() {

                    },
                    buildBadges: function() {

                    },
                    onPreExpand: function(infos) {
                        infos.nodeModel.preExpandDone();
                    }
                });
            }
        },

        setCurrentApplication: function(currentApplication) {
            this._currentApplication = currentApplication;
        },
        getCurrentApplication: function() {
            if (this._currentApplication && this._currentApplication !== '') {
                return this._currentApplication;
            } else {
                return this._specTreeVlt.DEFAULT_APP_NS;
            }
        },

        _handleEvents: function() {

        },

        onPreExpand: function(callback) {
            var treeDoc = this;
            this._parent(function(modelEvt) {
                treeDoc.prepareUpdate();
                // -- 1 - Remove all child node --
                modelEvt.target.search({
                    match: function(nodeInfos) {
                        var test = nodeInfos.nodeModel.options.isFeature;
                        return test;
                    }
                }).forEach(function(node) {
                    node.remove();
                });
                // modelEvt.target.options.children = [];
                // -- 2 - Query child node --
                callback.call(this, modelEvt);
                treeDoc.pushUpdate();
            });
        },




        /**
         * Create a Model Node. This kind of nodes should be used to reflect model structure. They can be selected.
         *
         * @param  {SpecTreeNodeModelOptions} options the SpecTreeNodeModelOptions to apply to the node
         * @return {module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel}         the newly created SpecTreeNodeModel
         */
        createModelNode: function(options) {
            if (!options.nodeType) {
                throw 'A model node must have a nodeType';
            }
            // options.nodeCategory = 'model';
            var RANDOM_COLOR = ['', '', '', '#57B847', '#00B8DE', '#EA4F37'];
            options.biColor = RANDOM_COLOR[Math.floor(Math.random() * RANDOM_COLOR.length)];
            return createNode(this._specTreeVlt, this._specTreeVlt.NODE_CATEGORIES.MODEL, options);
        },

        /**
         * Create a Fake Node. This kind of node should be used for grouping nodes into sections or categories and cannot be selected
         *
         * @param  {SpecTreeNodeModelOptions} options the SpecTreeNodeModelOptions to apply to the node
         * @return {module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel}         the newly created SpecTreeNodeModel
         */
        createFakeNode: function(options) {
            // options.nodeType = 'fake';
            // options.nodeCategory = 'fake';
            return createNode(this._specTreeVlt, this._specTreeVlt.NODE_CATEGORIES.FAKE, options);
        },


        _createLayoutNode: function(options) {
            return createNode(this._specTreeVlt, this._specTreeVlt.NODE_CATEGORIES.LAYOUT, {
                nodeType: options.nodeType //'layout-horizontal'
            });
        },

        /**
         *
         * Create a set of Sub Node which are represented in the SpecTreeView as horizonally layouted nodes
         *
         * @param  {(SpecTreeNodeModelOptions[]|module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel[])} options array of SpecTreeNodeModel or SpecTreeNodeModel options
         *
         * @return {module:DS/SpecTree/SpecTreeNodeModel~SpecTreeNodeModel}         A layout node (which is not represented in the view) containing the array of child nodes
         */
        createSubNodes: function(options) {
            var me = this;
            var layoutNode = this._createLayoutNode({
                nodeType: 'layout-horizontal'
            });
            // layoutNode.__private__.hasSubNodes = true;
            var modelNodes = [];
            options.forEach(function(nodeOptions) {
                var subNode;
                if (nodeOptions instanceof SpecTreeNodeModel) {
                    subNode = nodeOptions;
                } else {
                    subNode = me.createModelNode(nodeOptions);
                }
                if (subNode.hasChildren()) {
                    throw 'A sub-node cannot have children';
                } else {
                    modelNodes.push(subNode);
                }
            });
            layoutNode.addChild(modelNodes);
            layoutNode.expand();

            return layoutNode;
        },

        createRollbackableNodes: function(options) {
            var me = this;
            var layoutNode = this._createLayoutNode({
                nodeType: 'rollbackable-children'
            });
            // layoutNode.__private__.hasSubNodes = true;
            var modelNodes = [];
            options.forEach(function(nodeOptions) {
                var subNode;
                if (nodeOptions instanceof SpecTreeNodeModel) {
                    subNode = nodeOptions;
                } else {
                    subNode = me.createModelNode(nodeOptions);
                }
                if (subNode.hasChildren()) {
                    throw 'A sub-node cannot have children';
                } else {
                    modelNodes.push(subNode);
                }
            });
            layoutNode.addChild(modelNodes);
            layoutNode.expand();

            return layoutNode;
        },

        declareInWorkNode: function(node) {
            var me = this;

            if (this._inWorkNode) {
                this._inWorkNode.notifyModelUpdate();
            }

            this._inWorkNode = node;
            node.notifyModelUpdate();

            var trueRoot = me._getTrueRoot();
            trueRoot._modelEvents.publish({
                event: 'uiActiveUpdate',
                context: me
            });
        },

        getInWorkNode: function() {
            return this._inWorkNode;
        },

        isNodeInWork: function(nodeModel) {
            return this._inWorkNode ? this._inWorkNode._getID() === nodeModel._getID() : false;
        },

        isNodeUIActive: function(nodeModel) {
            return this._uiActiveNode ? this._uiActiveNode._getID() === nodeModel._getID() : false;
        },

        unsetUIActiveNode: function() {
            while (this._listOfUIActiveNodes[0]) {
                this._listOfUIActiveNodes[0]._setUIActive(false);
                this._listOfUIActiveNodes.shift();
            }
            this._uiActiveNode = null;

            var trueRoot = this._getTrueRoot();
            trueRoot._modelEvents.publish({
                event: 'uiActiveUpdate',
                // data: trueRoot._getNodeInfos(),
                context: this
            });
        },

        getUIActiveNode: function() {
            return this._uiActiveNode;
        },

        setUIActiveNode: function(node) {
            var me = this;



            while (this._listOfUIActiveNodes[0]) {
                this._listOfUIActiveNodes[0]._setUIActive(false);
                this._listOfUIActiveNodes.shift();
            }

            if (this._uiActiveNode) {
                this._uiActiveNode.notifyModelUpdate();
            }

            this._uiActiveNode = node;
            node._setUIActive(true);
            node.notifyModelUpdate();


            this._listOfUIActiveNodes.push(node);
            node.processDescendants({
                processNode: function(nodeInfos) {
                    nodeInfos.nodeModel._setUIActive(true);
                    me._listOfUIActiveNodes.push(nodeInfos.nodeModel);
                }
            });

            var trueRoot = me._getTrueRoot();
            trueRoot._modelEvents.publish({
                event: 'uiActiveUpdate',
                // data: trueRoot._getNodeInfos(),
                context: me
            });

        },


        // -- SpecTreeVault exposition --

        /**
         *
         * Register a Fake Node Type
         *
         * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
         *
         * @return {undefined}         nothing
         */
        registerLayoutNodeType: function(options) {
            return this.getVault().registerLayoutNodeType(options);
        },

        /**
         *
         * Register a Fake Node Type
         *
         * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
         *
         * @return {undefined}         nothing
         */
        registerFakeNodeType: function(options) {
            return this.getVault().registerFakeNodeType(options);
        },

        /**
         *
         * Register a Model Node Type
         *
         * @param  {SpecTreeVaultNodeTypeOptions} options Options to set in order to describe some representations properties and some behaviors on this kind of node
         *
         * @return {undefined}         nothing
         */
        registerModelNodeType: function(options) {
            return this.getVault().registerModelNodeType(options);
        },

        /**
         * Return notification informations such color and icon
         * @param  {SpecTreeVaultNotification} notif the notification
         * @return {SpecTreeVaultNotificationInfos}       the notification infos
         */
        getNotificationInfos: function(notif) {
            return this.getVault().getNotificationInfos(notif);
        }



    });


    // -- TYPEDEFINITIONS --
    SpecTreeDocument.DEFAULT_APP_NS = DEFAULT_APP_NS;


    // -- UTILITIES --
    SpecTreeDocument._buildSpecTreeDocumentFromSearchResult = function(options) {
        var newSpecTreeModel = new SpecTreeDocument({
            shouldBeEditable: function() {
                return false;
            }
        });
        newSpecTreeModel.prepareUpdate();
        options.searchResults.forEach(function(filteredNode) {
            // var newNode = UWA.clone(filteredNode.options);
            var newNode = {};
            for (var prop in filteredNode.options) {
                if (prop !== 'children') {
                    newNode[prop] = filteredNode.options[prop];
                }
            }
            newNode._originalID = filteredNode._getID();
            newNode.path = filteredNode.getPath();
            var searchedNodeModel = new SpecTreeNodeModel(newNode);
            searchedNodeModel._setNodeCategory(filteredNode._getNodeCategory());
            searchedNodeModel._setNodeType(filteredNode._getNodeType());
            newSpecTreeModel.addChild(searchedNodeModel);
        });
        newSpecTreeModel.pushUpdate();
        return newSpecTreeModel;
    };

    return SpecTreeDocument;

});

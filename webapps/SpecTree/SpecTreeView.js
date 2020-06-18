define('DS/SpecTree/SpecTreeView', [
        'DS/Tree/TreeListView',
        'DS/SpecTree/SpecTreeDocument',
        'DS/Tree/Manager',
        'DS/Tree/TreeNodeModel',
        'DS/Tree/TreeNodeView',
        'DS/Core/PointerEvents',
        'DS/Controls/Button',
        'DS/Controls/Abstract',
        'DS/Controls/Slider',
        'DS/Controls/ComboBox',
        'DS/Utilities/Dom',
        'DS/Controls/LineEditor',
        'DS/Windows/DockingElement',
        'DS/Utilities/Utils',
        'DS/Windows/Dialog',
        'DS/TreeModel/TreeDocument',
        'DS/Controls/Toolbar',
        'DS/Controls/Breadcrumb'
    ],
    function(TreeListView,
        SpecTreeDocument,
        Manager,
        TreeNodeModel,
        TreeNodeView,
        PointerEvents,
        WUXButton,
        Abstract,
        WUXSlider,
        WUXComboBox,
        DomUtils,
        WUXLineEditor,
        WUXDockingElement,
        Utils,
        WUXDialog,
        TreeDocument,
        WUXToolbar,
        WUXBreadcrumb /*, CSOManager, HSOManager*/ ) {

        'use strict';

        /*
        ███████ ████████  █████  ████████ ██  ██████
        ██         ██    ██   ██    ██    ██ ██
        ███████    ██    ███████    ██    ██ ██
             ██    ██    ██   ██    ██    ██ ██
        ███████    ██    ██   ██    ██    ██  ██████
        */


        // -- UI VARIABLES --
        var DEBUG_CTX_ENTRIES = false;
        var SELECTION_AREA_WIDTH = 20;
        var STATIC_COLUMN_WIDTH = 20;
        var STATIC_COLUMNS_RIGHT = false;
        var DEFAULT_NODE_INCREMENTATION = 20;

        // -- Columns definition --
        var COLUMNS = {
            NOTIFICATION_COLOR: {
                text: 'notification',
                dataIndex: 'notification_color',
                isEditable: false,
                isHidden: false,
                isStatic: true,
                icon: {
                    fontIconFamily: WUXManagedFontIcons.FontAwesome,
                    iconName: 'exclamation-circle'
                },
                width: 2,
                onCellRequest: function(cellInfos) {
                    var view = cellInfos.cellView.reuseCellContent('__notificationcolor__');
                    view.style.backgroundColor = cellInfos.manager.getDocument()._specTreeVlt.getNotificationInfos([cellInfos.nodeModel.getNotification()]).color;
                }
            },

            SELECTION: {
                text: '',
                dataIndex: 'selection',
                isStatic: true,
                width: SELECTION_AREA_WIDTH,
                onCellRequest: function(cellInfos) {
                    cellInfos.cellView.reuseCellContent('_specTreeSelection');
                }
            },

            TREE: {
                dataIndex: 'tree',
                isSortable: false,
                isEditable: true,
                setValue: function(cellInfos) {
                    var nodeModel = cellInfos.nodeModel;
                    nodeModel.prepareUpdate();
                    nodeModel.updateOptions({
                        label: cellInfos.value
                    });
                    nodeModel._getResolvedAndCall('onEditLabel', function fallbackEditLabel(infos) {
                        infos.nodeModel.updateOptions({
                            label: cellInfos.value
                        });
                    });
                    nodeModel.pushUpdate();
                }
            },

            COLOR: {
                icon: {
                    iconName: 'palette'
                },
                dataIndex: 'color',
                isEditable: false,
                isHidden: false,
                isStatic: true,
                width: 20,
                onCellRequest: function(cellInfos) {
                    var nodeModel = cellInfos.nodeModel;
                    if (nodeModel._isSubnode() || nodeModel._getNodeCategory() === cellInfos.manager.getDocument()._specTreeVlt.NODE_CATEGORIES.FAKE ||
                        nodeModel._getNodeCategory() === cellInfos.manager.getDocument()._specTreeVlt.NODE_CATEGORIES.LAYOUT) {
                        cellInfos.cellView.getContent().empty();
                    } else {
                        var view = cellInfos.cellView.reuseCellContent('__color__');
                        view.style.backgroundColor = nodeModel.getColor();
                    }
                }
            },

            BORDER_COLOR: {
                text: '',
                dataIndex: 'borderColor',
                isEditable: false,
                isHidden: false,
                isStatic: true,
                width: 4,
                onCellRequest: function(cellInfos) {
                    var nodeModel = cellInfos.nodeModel;
                    if (nodeModel._isSubnode() || nodeModel._getNodeCategory() === cellInfos.manager.getDocument()._specTreeVlt.NODE_CATEGORIES.FAKE ||
                        nodeModel._getNodeCategory() === cellInfos.manager.getDocument()._specTreeVlt.NODE_CATEGORIES.LAYOUT) {
                        cellInfos.cellView.getContent().empty();
                    } else {
                        var view = cellInfos.cellView.reuseCellContent('__bordercolor__');
                        view.style.backgroundColor = nodeModel.getBorderColor();
                    }
                }
            },

            NOTIFICATION_ICON: {
                text: 'notification_icon',
                icon: {
                    fontIconFamily: WUXManagedFontIcons.FontAwesome,
                    iconName: 'exclamation-circle'
                },
                dataIndex: 'notification_icon',
                isEditable: false,
                width: STATIC_COLUMN_WIDTH,
                isStatic: true,
                isHidden: false,
                onCellRequest: function(cellInfos) {
                    var notifInfos = cellInfos.manager.getDocument()._specTreeVlt.getNotificationInfos(cellInfos.nodeModel.getNotification());
                    var notifIcon = DomUtils.generateIcon(notifInfos.icon);
                    if (notifIcon) {
                        notifIcon.style.color = notifInfos.color;
                        cellInfos.cellView.getContent().setContent(notifIcon);
                    } else {
                        cellInfos.cellView.getContent().innerText = '';
                    }
                }
            },

            HIDE_SHOW: {
                text: 'visibility',
                icon: {
                    fontIconFamily: WUXManagedFontIcons.Font3DS,
                    iconName: 'eye-off'
                },
                dataIndex: 'visibility',
                isEditable: false,
                isStatic: true,
                isHidden: false,
                width: STATIC_COLUMN_WIDTH + 6,
                onCellRequest: function(cellInfos) {
                    cellInfos.cellView.getContent().empty();
                    var view = cellInfos.cellView.reuseCellContent('__visibility__');
                    var isVisible = cellInfos.nodeModel.isVisibleInSpecTree();
                    view._reflectValue(isVisible);
                    view.value = isVisible;
                    cellInfos.cellView.getContent().setStyle('text-align', 'left');
                }
            },

            ACTION: {
                text: 'action',
                dataIndex: 'action',
                isEditable: false,
                width: STATIC_COLUMN_WIDTH,
                isStatic: true,
                isHidden: false,
                onCellRequest: function(cellInfos) {
                    cellInfos.cellView.reuseCellContent('__action__');

                }
            }
        };




        function getOffsets(e, target) {
            var target = target || (e.target || e.srcElement),
                style = target.currentStyle || window.getComputedStyle(target, null),
                borderLeftWidth = parseInt(style.borderLeftWidth, 10),
                borderTopWidth = parseInt(style.borderTopWidth, 10),
                rect = target.getBoundingClientRect(),
                offsetX = e.clientX - borderLeftWidth - rect.left,
                offsetY = e.clientY - borderTopWidth - rect.top;
            return {
                offsetX: offsetX,
                offsetY: offsetY
            };
        }

        /*
         ██████  ██████  ███    ███ ██████
        ██      ██    ██ ████  ████ ██   ██
        ██      ██    ██ ██ ████ ██ ██████
        ██      ██    ██ ██  ██  ██ ██
         ██████  ██████  ██      ██ ██
        */





        var ColumnIcon = Abstract.inherit({

            publishedProperties: {
                value: {
                    defaultValue: true,
                    type: 'boolean'
                },
                map: {
                    defaultValue: true,
                    type: 'object'
                }
            },

            _preBuildView: function() {

                this.elements.container = new UWA.Element('div', {
                    'class': 'wux-cell-icon'
                });
                var me = this;

                this.elements.container.addEvent('mouseenter', function() {
                    me._reflectPreviewValue(!me.value);
                });
                this.elements.container.addEvent('mouseleave', function() {
                    me._reflectValue(me.value);
                });

                if (window.jasmine !== undefined && !window.WEBUX_DO_NOT_TEST_SPECTREEVIEW) {
                    setInterval(function() {
                        if (me.getContent().getParent()) {
                            me.elements.container.setContent(new UWA.Element('div', {
                                html: 'DO NOT TEST THE VIEW PLEASE',
                                styles: {
                                    background: 'red',
                                    color: 'white',
                                    height: '100%',
                                    width: '100%'
                                }
                            }));
                        }
                    }, 1000);
                }
            },

            _applyProperties: function(oldValues) {
                this._applyValue();
                this._parent(oldValues);
            },

            _applyValue: function() {
                this._applyMap();
            },

            _applyMap: function() {
                this.getContent().setContent(DomUtils.generateIcon(this.map[this.value].value));
            },

            _reflectPreviewValue: function(value) {
                this.getContent().setContent(DomUtils.generateIcon(this.map[value].valuePreview));
            },
            _reflectValue: function(value) {
                this.getContent().setContent(DomUtils.generateIcon(this.map[value].value));
            }

        });


        /*
        ███    ██  ██████  ██████  ███████ ██    ██ ██ ███████ ██     ██
        ████   ██ ██    ██ ██   ██ ██      ██    ██ ██ ██      ██     ██
        ██ ██  ██ ██    ██ ██   ██ █████   ██    ██ ██ █████   ██  █  ██
        ██  ██ ██ ██    ██ ██   ██ ██       ██  ██  ██ ██      ██ ███ ██
        ██   ████  ██████  ██████  ███████   ████   ██ ███████  ███ ███
        */

        var SpecTreeNodeView = TreeNodeView.extend({
            init: function(options) {
                this._parent(options);
            },


            _buildWriteView: function() {
                this.getGridEngine()._hideHoverBar();
                return this._parent();
            },


            debouncedUpdateInternalParameters: function() {
                var cellInfos = this.getCellInfos();
                var nodeModel = cellInfos.nodeModel;

                if (cellInfos.virtualRowID > -1) {
                    this.getContent().setAttribute('node-category', nodeModel._getNodeCategory());
                    this.getContent().setAttribute('node-type', nodeModel._getNodeType());
                    this.getContent().setAttribute('node-notification', nodeModel.getNotification());
                    this.getContent().setAttribute('node-is-hidden', !nodeModel.isVisibleInSpecTree());

                    if (nodeModel.isMatchingSearch()) {
                        this.getContent().setAttribute('match-search', nodeModel._isMatchingSearchFocused);
                    } else {
                        this.getContent().removeAttribute('match-search');
                    }
                }
            },

            _isSubNode: function(nodeType) {
                var cellInfos = this.getCellInfos();
                var nodeModel = cellInfos.nodeModel;
                // !cellInfos.isHeader && cellInfos.dataIndex === 'tree' &&
                if (cellInfos.virtualRowID > -1 && nodeModel.getParent()._isLayoutNode(nodeType)) {
                    return true;
                } else {
                    return false;
                }
            },

            updateInternalParameters: function() {
                var cellInfos = this.getCellInfos();

                this._parent();

                if (this._isSubNode()) {
                    this.getContent().removeAttribute('is-hidden');
                    this.getContent().setAttribute('is-subnode', cellInfos.nodeModel.getParent()._getNodeType());
                } else {
                    this.getContent().removeAttribute('is-subnode');
                }

                if (!cellInfos.isHeader) {
                    // this.getContent().setAttribute('node-is-uiactive', cellInfos.nodeModel.isUIActive());
                    var doc = cellInfos.manager.getDocument();
                    this.getContent().setAttribute('node-is-uiactive', doc.isNodeInWork(cellInfos.nodeModel));
                    this.getContent().setAttribute('node-is-inwork', doc.isNodeInWork(cellInfos.nodeModel));

                    if (cellInfos.nodeModel._isAfterRollbackCursor()) {
                        this.getContent().setAttribute('node-is-after-rollback-cursor', true);
                    } else {
                        this.getContent().setAttribute('node-is-after-rollback-cursor', false);
                    }


                }
                this.debouncedUpdateInternalParameters();

            },


            addIcon: function(icon, iconType) {
                if (iconType === undefined) {
                    if (UWA.typeOf(icon) === 'element') {
                        var iconView = new UWA.Element('div', {
                            'class': 'wux-layouts-treeview-icon',
                            html: icon,
                            styles: {
                                display: 'inline-block'
                            }
                        });
                        iconView.inject(this.elements.iconsContainer);

                    } else {
                        this._parent(icon, iconType);
                    }
                }
            },

            _getRelativeIncrementFactor: function(depth) {
                var cellInfos = this.getCellInfos();
                var nodeModel = cellInfos.nodeModel; //this._cellModel.getCellContent();
                var path = nodeModel.getParents();
                return cellInfos.manager._getRelativeIncrementFactorForNode(path[depth]);
            },

            _setDepth: function(depth) {
                var cellInfos = this.getCellInfos();
                var nodeModel = cellInfos.nodeModel;

                if (nodeModel.getParent()._isLayoutNode('layout-horizontal') && cellInfos.dataIndex === 'tree') {
                    this.elements.linksContainer.setStyle('width', 0);
                    this.elements.nodeContainer.setStyle('left', 0);
                } else {
                    if (nodeModel.getParent()._isLayoutNode('rollbackable-children') && cellInfos.dataIndex === 'tree') {
                        depth--;
                    }
                    this._parent(depth);
                }
            },

            _getSubNodeCellWidth: function() {
                var cellInfos = this.getCellInfos();
                var manager = cellInfos.manager;

                return Math.min(60, (manager.getColumnWidth('tree') / 4));
            },

            getPosition: function() {
                var cellInfos = this.getCellInfos();
                var nodeModel = cellInfos.nodeModel;
                var manager = cellInfos.manager;

                // -- if node is a sub-node (horizontal node), we hijack the position --
                if (this._isSubNode('layout-horizontal')) {
                    return {
                        top: manager.getRowPosition(cellInfos.nodeModel.getParent()._getRowID()),
                        left: manager._getAbsoluteIncrementFactorForNode(cellInfos.nodeModel) + DEFAULT_NODE_INCREMENTATION + manager.getColumnPosition('tree') + this._getSubNodeCellWidth() * nodeModel._getLocalID()
                    };
                }
                // -- else do nothing --
                else {
                    var pos = this._parent();
                    if (this._isSubNode('rollbackable-children')) {
                        pos.top = manager.getRowPosition(cellInfos.nodeModel.getParent()._getRowID()) + manager.getRowHeight(cellInfos.nodeModel) * cellInfos.nodeModel._getLocalID();
                    }
                    return pos;
                }
            },

            getDimensions: function() {
                var cellInfos = this.getCellInfos();
                var manager = cellInfos.manager;

                if (this._isSubNode('layout-horizontal')) {
                    return {
                        width: this._getSubNodeCellWidth(),
                        height: manager.options.defaultCellHeight
                    };
                } else {
                    return this._parent();
                }
            }
        });

        /*
        ███    ███  █████  ███    ██  █████   ██████  ███████ ██████
        ████  ████ ██   ██ ████   ██ ██   ██ ██       ██      ██   ██
        ██ ████ ██ ███████ ██ ██  ██ ███████ ██   ███ █████   ██████
        ██  ██  ██ ██   ██ ██  ██ ██ ██   ██ ██    ██ ██      ██   ██
        ██      ██ ██   ██ ██   ████ ██   ██  ██████  ███████ ██   ██
        */

        var SpecTreeManager = Manager.extend({

            init: function(a, b) {
                this._parent(a, b);
                this._manageActiveNode();
            },


            _manageKeyboard: function() {
                this._parent();

                this._commandRegistry.registerCommand('goToPreviousParentNode', function(options) {
                    var event = options.event;
                    var lastSelectedElt = this.getActiveNode();
                    var manager = this;

                    event.preventDefault();
                    if (lastSelectedElt) {
                        if (lastSelectedElt.isExpanded()) {
                            options.keymapManager.wait();
                            lastSelectedElt.onPostCollapse(function() {
                                options.keymapManager.listen();
                            });
                            lastSelectedElt.collapse();
                            manager._goToNode(event, lastSelectedElt, 0);
                        } else {
                            if (!lastSelectedElt.isRoot()) {
                                var parentNode = lastSelectedElt._getParentModel();

                                if (parentNode) {
                                    manager.setActiveNode(parentNode);
                                    manager._goToNode(event, parentNode, 0);
                                }
                            } else {
                                manager._goToNode(event, lastSelectedElt, -1);
                            }
                        }
                    }
                });
            },


            loadDocument: function(treeDoc) {
                this._parent(treeDoc);
                this._manageUIActiveArea();
            },


            _updateBreadCrumb: function(breadcrumb, path) {
                var value = [];
                path.forEach(function(node) {
                    var icons = node.getIcons();
                    var icon;
                    if (icons && icons.length > 0) {
                        icon = icons[0]; //TreeNodeView._buildIcon(icons[0]);
                    }
                    value.push({
                        label: node.getLabel(),
                        icon: icon,
                        node: node
                    });
                });

                breadcrumb.value = value;
            },

            _reflectNewActiveNode: function() {
                // console.warn('---- REFLECT ACTIVE -----');
                var manager = this;
                // -- Only reflect current active node if the column headers are displayed
                var nodeModel = manager.getActiveNode();
                var cellViewDom = manager._getCellViewDom(-1, 'tree');
                if (nodeModel && cellViewDom) {
                    var cellView = cellViewDom.dsView;
                    // -- display the path breadcrumb with fake node filtered
                    var comp = cellView.reuseCellContent('__breadcrumb__');
                    comp._lock = true;
                    manager._updateBreadCrumb(comp, nodeModel.getPath().filter(function(subNode) {
                        switch (subNode._getNodeCategory()) {
                            case manager.getDocument()._specTreeVlt.NODE_CATEGORIES.FAKE:
                                if (subNode._getNodeType() === 'more/less') {
                                    return false;
                                } else {
                                    return true;
                                }
                            default:
                                return true;
                        }
                    }));
                    comp._lock = false;
                }
            },

            _manageActiveNode: function() {

                var throttledReflectActiveView = Utils.throttle(this._reflectNewActiveNode, 100).bind(this);

                // -- this reflect the new active node --
                this._modelEvents.subscribe({
                    event: 'active'
                }, this._reflectNewActiveNode.bind(this));

                // on panel resize, because the breadcrumb
                // is displayed in the column header area
                this.onGridResize(throttledReflectActiveView);
            },


            isUIActiveAreaEnabled: function() {
                return this._uiActiveAreaBGEnabled ? this._uiActiveAreaBGEnabled : false;
            },


            _manageUIActiveArea: function() {
                // -- UIActive Object --
                var me = this;
                this._uiActiveAreaBGEnabled = false;
                this._uiActiveAreaBG = null;
                this._listOfInWorkDots = {};


                var debouncedUpdateUIActiveArea = Utils.debounce(this._updateUIActiveArea.bind(this), 20);

                // -- Listen to doubleclick on nodes in order to set the active area --
                this._bindJSEventOnDocument(this.getContent(), 'dblclick', function dblclickCB(e, nodeInfos) {
                    var doc = me.getDocument();
                    if (nodeInfos && nodeInfos.isHeader === false) {
                        if (nodeInfos.dataIndex === 'tree') {

                            nodeInfos.nodeModel._getResolvedAndCall('onEdit');

                            // if (doc.isNodeUIActive(nodeInfos.nodeModel)) {
                            //     doc.unsetUIActiveNode();
                            // } else {
                            //     doc.setUIActiveNode(nodeInfos.nodeModel);
                            //     me._uiActiveAreaBGEnabled = !me._uiActiveAreaBGEnabled || doc.getUIActiveNode() !== nodeInfos.nodeModel;
                            //     if (me._uiActiveAreaBGEnabled) {
                            //         // me._lastUIActiveElement = nodeInfos.nodeModel;
                            //         debouncedUpdateUIActiveArea();
                            //     } else {
                            //         me.getContent().removeClassName('wux-ui-state-uiactive-mode');
                            //
                            //     }
                            // }
                        }
                    }
                });

                this._bindEventOnDocument('uiActiveUpdate', function(modelEvt) {
                    me.updateView();
                    debouncedUpdateUIActiveArea();
                });

                this._bindEventOnDocument('addChild', function(modelEvt) {
                    debouncedUpdateUIActiveArea();
                });

                this._bindEventOnDocument('removeChild', function(modelEvt) {
                    debouncedUpdateUIActiveArea();
                });

                this._bindEventOnDocument('postExpand', function(modelEvt) {
                    debouncedUpdateUIActiveArea();
                });

                this._bindEventOnDocument('postCollapse', function(modelEvt) {
                    debouncedUpdateUIActiveArea();
                });
            },





            _updateUIActiveArea: function(nodeInfos) {
                // var uiActiveArea;
                var manager = this;
                var doc = manager.getDocument();
                var useRollbackBar = true;


                var nodeModel = doc.getUIActiveNode();
                if (nodeModel) {
                    manager.getContent().addClassName('wux-ui-state-uiactive-mode');
                    var beginRowID = nodeModel._getRowID();

                    var currentListOfRenderedInWorkDots = {};
                    var inWorkPathHeight = 0;
                    var numberOfVisiblesNodesUnderActive = 0;

                    var nodeDescendants = nodeModel._getDescendantAndProcess([], {
                        onlyVisibleNodes: true,
                        processNode: function(nodeInfos) {
                            var currentNodeModel = nodeInfos.nodeModel;
                            var isVisible = true; //currentNodeModel.isVisible();

                            if (isVisible) {
                                numberOfVisiblesNodesUnderActive++;
                            }

                            if (!currentNodeModel._isFakeNode() && !currentNodeModel._isLayoutNode() && !currentNodeModel._isSubnode() && isVisible) {

                                // -- caching some variables --
                                var currentInWorkDot;
                                var currentNodeID = nodeInfos.nodeModel._getID();
                                var currentNodeRowID = nodeInfos.nodeModel._getRowID();

                                if (useRollbackBar === false) {
                                    // -- if dot has not been yet created, we create it --
                                    if (manager._listOfInWorkDots[currentNodeID] === undefined) {
                                        currentInWorkDot = new UWA.Element('div', {
                                            'class': 'wux-spectree-inwork-dot',
                                            events: {
                                                mousedown: function(e) {
                                                    e.stopPropagation();
                                                },
                                                click: function(e) {
                                                    e.stopPropagation();
                                                    var doc = manager.getDocument();
                                                    doc.declareInWorkNode(currentNodeModel);
                                                }
                                            }
                                        });
                                        manager.elements.poolContainerRel.appendChild(currentInWorkDot);
                                        manager._listOfInWorkDots[currentNodeID] = currentInWorkDot;
                                    }
                                    // -- else we reuse an already existing one --
                                    else {
                                        currentInWorkDot = manager._listOfInWorkDots[currentNodeID];
                                    }

                                    // -- we register the dot as being rendered --
                                    currentListOfRenderedInWorkDots[currentNodeID] = true;

                                    // -- we apply dot type depending of its inwork state --
                                    currentInWorkDot.setAttribute('inwork', doc.isNodeInWork(currentNodeModel));
                                    // -- we apply the computed position to the dot --
                                    currentInWorkDot.setStyles({
                                        top: manager.getRowPosition(currentNodeRowID) + manager.getRowHeight(currentNodeRowID) / 2,
                                        left: manager._getAbsoluteIncrementFactorForNode(nodeModel) + 18
                                    });
                                }
                            }

                        }
                    });
                    // .filter(function(node) {
                    //     return node.isVisible();
                    // });

                    // -- compute some variables in order to properly inwork and uiactive areas --
                    var endRowID = nodeDescendants.length > 0 ? nodeDescendants[nodeDescendants.length - 1]._getRowID() : beginRowID;
                    // --
                    var top = manager.getRowPosition(beginRowID);
                    var height = (manager.getRowPosition(endRowID) - manager.getRowPosition(beginRowID) + manager.getRowHeight(endRowID));






                    // -- Determining the current inwork node, and creating the corresponding dot --
                    var inWorkNode = doc.getInWorkNode();
                    var inWorkNodeVisibility = false;
                    if (inWorkNode) {

                        inWorkNodeVisibility = inWorkNode.isVisible();
                        var inWorkRef = inWorkNodeVisibility ? inWorkNode : inWorkNode.getFirstVisibleParent();

                        var inWorkNodeRowID = inWorkRef._getRowID();
                        var inWorkNodeID = inWorkRef._getID();

                        inWorkPathHeight = manager.getRowPosition(inWorkNodeRowID) + manager.getRowHeight(inWorkNodeRowID) / 2;

                        var inWorkDot = me._listOfInWorkDots[inWorkNodeID];
                        if (inWorkDot) {
                            inWorkDot.setAttribute('inwork', inWorkNodeVisibility ? 'true' : 'partial');
                        }
                    }


                    // -- Clean previously created inwork dots --
                    for (var currentNodeID in manager._listOfInWorkDots) {
                        if (currentListOfRenderedInWorkDots[currentNodeID] === undefined) {
                            manager._listOfInWorkDots[currentNodeID].destroy();
                            delete manager._listOfInWorkDots[currentNodeID];
                        }
                    }

                    // console.log('uiactive', nodeModel.options.label, top, height, nodeDescendants);




                    if (!manager._uiActiveAreaBG) {
                        manager._uiActiveAreaBG = new UWA.Element('div', {
                            'class': 'wux-spectree-uiactive-area-bg'
                        });
                        manager._uiActiveAreaBG.inject(manager.elements.poolContainerRel);
                    }
                    if (!manager._uiActiveAreaFG) {
                        manager._uiActiveAreaFG = new UWA.Element('div', {
                            'class': 'wux-spectree-uiactive-area-fg'
                        });
                        manager._uiActiveAreaFG.inject(manager.elements.poolContainerRel);
                    }

                    if (useRollbackBar === false) {
                        if (!manager._uiInWorkArea) {
                            manager._uiInWorkArea = new UWA.Element('div', {
                                'class': 'wux-spectree-inwork-area'
                            });
                            manager._uiInWorkArea.inject(manager.elements.poolContainerRel);
                        }

                        if (!manager._uiInWorkPath) {
                            manager._uiInWorkPath = new UWA.Element('div', {
                                'class': 'wux-spectree-inwork-path'
                            });
                            manager._uiInWorkPath.inject(manager.elements.poolContainerRel);
                        }
                    }


                    var inWorkAreaHeight = Math.max((manager.getRowPosition(endRowID) - manager.getRowPosition(beginRowID) - manager.getRowHeight(endRowID) / 2),
                        0);

                    inWorkPathHeight = Math.max(inWorkPathHeight - manager.getRowPosition(beginRowID) - manager.getRowHeight(endRowID) - 3, 0);


                    if (useRollbackBar === false) {
                        // -- positionning inwork areas  --
                        manager._uiInWorkPath.setStyles({
                            display: inWorkPathHeight <= height ? 'block' : 'none', //inWorkNodeVisibility ? 'block' : 'none',
                            top: top + manager.getRowHeight(nodeModel),
                            left: manager._getAbsoluteIncrementFactorForNode(nodeModel) + 18,
                            height: inWorkPathHeight
                        });

                        manager._uiInWorkArea.setStyles({
                            display: inWorkPathHeight <= height ? 'block' : 'none', //inWorkNodeVisibility ? 'block' : 'none',
                            top: top + manager.getRowHeight(nodeModel),
                            left: manager._getAbsoluteIncrementFactorForNode(nodeModel) + 18,
                            height: inWorkAreaHeight
                        });
                    }



                    var rollbackNode;
                    var childNodes = nodeModel.getChildren();

                    if (childNodes && childNodes.length > 0) {
                        for (var i = 0; rollbackNode === undefined && i < childNodes.length; i++) {
                            if (childNodes[i]._isLayoutNode('rollbackable-children')) {
                                rollbackNode = childNodes[i];
                            }
                        }



                        if (!manager._rollbackSlider) {
                            manager._rollbackSlider = new UWA.Element('div', {
                                'class': 'wux-spectree-rollback-slider'
                            });
                            manager._rollbackSliderRail = new UWA.Element('div', {
                                'class': 'wux-spectree-rollback-slider-rail'
                            }).inject(manager._rollbackSlider);
                            manager._rollbackSliderBar = new UWA.Element('div', {
                                'class': 'wux-spectree-rollback-slider-bar'
                            }).inject(manager._rollbackSliderRail);
                            manager._rollbackSliderCursor = new UWA.Element('div', {
                                'class': 'wux-spectree-rollback-slider-cursor'
                            }).inject(manager._rollbackSliderRail);



                            var sliderCellInfos;
                            manager.getContent().addEvent('mousemove', function(e) {
                                sliderCellInfos = manager._getCoordinatesFromEvent(e);
                            });


                            var rollbackSliderIsPressed = false;

                            var rollbackPointerMove = function(e) {
                                // e.preventDefault();
                                if (rollbackSliderIsPressed) {
                                    var offsets = getOffsets(e, manager._rollbackSlider);
                                    var posY = offsets.offsetY;
                                    manager._rollbackSliderBar.setStyles({
                                        height: posY
                                    });
                                    manager._rollbackSliderCursor.setStyles({
                                        top: posY
                                    });
                                    if (sliderCellInfos && rollbackNode) {
                                        var doc = manager.getDocument();
                                        doc.prepareUpdate();
                                        rollbackNode = manager.getTreeNodeModelFromRowID(sliderCellInfos.rowID).getParent();
                                        var lastChild = rollbackNode.getLastChild();
                                        if (rollbackNode && rollbackNode._isLayoutNode('rollbackable-children')) {
                                            rollbackNode._getDescendantAndProcess([], {
                                                onlyVisibleNodes: true,
                                                processNode: function(nodeInfos) {
                                                    var currentNodeModel = nodeInfos.nodeModel;
                                                    var isVisible = true; //currentNodeModel.isVisible();

                                                    if (!currentNodeModel._isFakeNode() && !currentNodeModel._isLayoutNode() && !currentNodeModel._isSubnode() && isVisible) {
                                                        if (nodeInfos.virtualRowID <= sliderCellInfos.rowID) {
                                                            currentNodeModel._beforeRollbackCursor();
                                                        } else {
                                                            if (sliderCellInfos.rowID <= lastChild._getRowID()) {
                                                                currentNodeModel._afterRollbackCursor();
                                                            }
                                                        }
                                                    }
                                                }
                                            });
                                        }
                                        doc.pushUpdate();
                                    }
                                }
                            };


                            var rollbackPointerUp = function(e) {
                                rollbackSliderIsPressed = false;
                                document.removeEventListener(PointerEvents.POINTERMOVE, rollbackPointerMove);
                                document.removeEventListener(PointerEvents.POINTERUP, rollbackPointerUp);

                                var position = manager.getRowPosition(sliderCellInfos.rowID) + manager.getRowHeight(sliderCellInfos.rowID) - manager.getRowPosition(rollbackNode._getRowID());

                                manager._rollbackSliderBar.setStyles({
                                    height: position
                                });
                                manager._rollbackSliderCursor.setStyles({
                                    top: position
                                });

                                manager.unlockUI();

                            };

                            manager._rollbackSlider.addEvent(PointerEvents.POINTERDOWN, function rollbackPointerDown(e) {
                                e.preventDefault();
                                rollbackSliderIsPressed = true;
                                document.addEventListener(PointerEvents.POINTERMOVE, rollbackPointerMove);
                                document.addEventListener(PointerEvents.POINTERUP, rollbackPointerUp);
                                manager.lockUI();
                            });

                            manager._rollbackSlider.inject(manager.elements.poolContainerRel);
                            manager._rollbackSlider.addEventListener('dragstart', function(e) {
                                e.preventDefault();
                                e.stopPropagation();
                                return false;
                            });

                        }

                        if (rollbackNode) {
                            var rollbackSliderHeight = 0;
                            var rollbackableNodes = rollbackNode.getChildren();

                            if (rollbackableNodes.length > 0) {
                                var firstRollabckableNode = rollbackableNodes[0];
                                var lastRollabckableNode = rollbackableNodes[rollbackableNodes.length - 1];
                                rollbackSliderHeight = manager.getRowPosition(lastRollabckableNode._getRowID()) + manager.getRowHeight(lastRollabckableNode._getRowID()) - manager.getRowPosition(firstRollabckableNode._getRowID());

                                manager._rollbackSlider.setStyles({
                                    display: 'block',
                                    position: 'absolute',
                                    top: manager.getRowPosition(firstRollabckableNode._getRowID()),
                                    left: manager._getAbsoluteIncrementFactorForNode(nodeModel) + 14,
                                    height: rollbackSliderHeight,
                                    zIndex: 10000000000000,
                                    overflow: 'hidden'
                                });
                            } else {
                                manager._rollbackSlider.setStyles({
                                    display: 'none'
                                });
                            }
                        }
                    }

                    // -- positionning active area  --
                    manager._uiActiveAreaFG.setStyles({
                        display: 'block',
                        top: top,
                        left: 0,
                        right: 0,
                        height: height
                    });

                    manager._uiActiveAreaBG.setStyles({
                        display: 'block',
                        top: top,
                        left: 0,
                        right: 0,
                        height: height
                    });


                }
                // -- cleanup all the UI needed for the UIActive mode --
                else {

                    manager.getContent().removeClassName('wux-ui-state-uiactive-mode');


                    if (manager._rollbackSlider) {
                        manager._rollbackSlider.hide();
                    }

                    if (manager._uiActiveAreaFG) {
                        manager._uiActiveAreaFG.hide();
                    }
                    if (manager._uiActiveAreaBG) {
                        manager._uiActiveAreaBG.hide();
                    }
                    if (manager._uiInWorkArea) {
                        manager._uiInWorkArea.hide();
                    }
                    if (manager._uiInWorkPath) {
                        manager._uiInWorkPath.hide();
                    }
                    for (var currentNodeID in manager._listOfInWorkDot) {
                        manager._listOfInWorkDot[currentNodeID].destroy();
                        delete manager._listOfInWorkDot[currentNodeID];
                    }
                }
            },


            _shoulBeSelected: function(nodeModel) {
                var treeDoc = this.getDocument();
                return treeDoc.options.shouldBeSelected.call(treeDoc, nodeModel);
            },

            selectRow: function(rowID, unselectAll) {
                if (this._shoulBeSelected(this.getTreeNodeModelFromRowID(rowID))) {
                    this._parent(rowID, unselectAll);
                }
            },

            // updateView: function(force) {
            //     this._parent(force);
            //     this._renderInWorkUI();
            // },



            _setHeadersDimensions: function(dimensions) {
                this._parent(dimensions);
                if (this._getParent().options.enableStaticColumns) {
                    if (STATIC_COLUMNS_RIGHT) {
                        DomUtils.setStyles(this.elements.rowsHeaderContainer, {
                            right: 0,
                            left: ''
                        });
                        DomUtils.setStyles(this.elements.gridHeaderContainer, {
                            right: this.elements.rowsHeaderContainer.style.width,
                            left: 0
                        });
                    }
                }
            },

            _syncRowModelWithTreeNodeModel: function(node) {
                var manager = this;

                // -- sync row header content --
                manager.updateCellView(node._getRowID(), -1);
                return this._parent(node);
            },


            _doFeaturesNeedToBeDisplayed: function(nodeModel) {
                return nodeModel.hasFeatures() && nodeModel.isExpanded();
            },

            _getAbsoluteIncrementFactorForNode: function(nodeModel) {

                var incrementFactor = 0;

                var path = nodeModel.getParents();
                for (var i = 0; i < path.length; i++) {
                    incrementFactor = incrementFactor + this._getRelativeIncrementFactorForNode(path[i]);
                }

                return incrementFactor;
            },

            _getRelativeIncrementFactorForNode: function(nodeModel) {
                var incrementFactor;
                switch (nodeModel._getNodeCategory()) {
                    case this.getDocument()._specTreeVlt.NODE_CATEGORIES.LAYOUT:
                        if (nodeModel._isLayoutNode('rollbackable-children')) {
                            incrementFactor = DEFAULT_NODE_INCREMENTATION;
                        } else {
                            incrementFactor = 0;
                        }
                        break;
                    case this.getDocument()._specTreeVlt.NODE_CATEGORIES.FAKE:
                        if (nodeModel._isFakeNode('section')) {
                            incrementFactor = 0;
                        } else {
                            incrementFactor = DEFAULT_NODE_INCREMENTATION;
                        }
                        break;
                    default:
                        incrementFactor = DEFAULT_NODE_INCREMENTATION;
                }
                return incrementFactor;
            },



            _computeStyleForActiveState: function(node) {
                var rowID = node._getRowID();
                var topPos, height;
                topPos = this.getRowPosition(rowID);
                height = this.getRowHeight(rowID);

                if (node._isSubnode('layout-horizontal')) {
                    topPos = this.getRowPosition(node.getParent()._getRowID());

                    var columnID = this.getColumnIDFromDataIndex('tree');
                    var cellViewDom = this.elements.container.querySelector('.wux-datagrid-cell[virtual-row-id="' + rowID + '"][virtual-column-id="' + columnID + '"]');

                    if (cellViewDom) {

                        var cellView = cellViewDom.dsView;
                        var cellDimensions = cellView.getDimensions();
                        return {
                            top: topPos,
                            left: cellView.getPosition().left,
                            height: cellDimensions.height,
                            width: cellDimensions.width
                        };
                    } else {
                        return this._parent(node);
                    }
                } else {
                    return {
                        top: topPos,
                        left: 0,
                        height: height,
                        right: 0
                    };
                }
            },


            _indexRowsPosition: function() {
                // -- disable indexing --
            },
            getRowPosition: function(rowID) {
                var out;
                if (rowID === -1) {
                    out = this._parent(rowID);
                } else {
                    var nodeModel = this.getTreeNodeModelFromRowID(rowID);

                    if (nodeModel && nodeModel._isSubnode('layout-horizontal')) {
                        var parentNode = nodeModel.getParent();
                        var parentNodeRowID = parentNode._getRowID();
                        if (parentNodeRowID === null) {
                            // throw 'Something wrong, rowID of node has not been computed';
                        }
                        out = this.getRowPosition(parentNodeRowID);
                    } else {
                        out = this._parent(rowID);
                    }
                }
                // console.log(out);
                return out;

            },

            getRowHeight: function(rowID) {
                if (rowID === -1) {
                    return this._parent(rowID);
                } else {
                    var nodeModel = rowID;
                    if (typeof rowID === 'number') {
                        nodeModel = this.getTreeNodeModelFromRowID(rowID);
                    }
                    if (nodeModel && nodeModel.getParent() && nodeModel.getParent()._isLayoutNode('layout-horizontal')) {
                        // return this._parent(rowID);
                        return 0;
                    } else {
                        if (nodeModel && nodeModel._isLayoutNode('rollbackable-children')) {
                            return 0;
                        } else {
                            return this._parent(rowID);
                        }
                    }
                }
            },

            _createDocument: function(doc) {
                this._parent(doc);
                this._manageHoverBar();
            },


            _manageHoverBar: function() {
                var manager = this;

                this.elements.poolContainerRel.addEvent('mouseleave', function() {
                    manager._hideHoverBar();
                });

                var lastCellInfos;
                var currentDelta = 0;
                var forceUpdate = false;
                // -- callbacks --
                var onPointerMove = function(e, cellInfos) {
                    var doc = manager.getDocument();
                    if (cellInfos) {
                        var nextNode = cellInfos.nodeModel;
                        if (cellInfos && cellInfos.virtualRowID > -1) {
                            if (lastCellInfos) {
                                if (!cellInfos.cellView.isInEditionMode()) {
                                    currentDelta = nextNode._getRowID() - lastCellInfos.nodeModel._getRowID();
                                    // -- only add/remove css class
                                    // if the pointer has moved on another row,
                                    // or if the pointer enters again (forceUpdate = true) in the row
                                    if (currentDelta !== 0 || forceUpdate === true) {
                                        manager._showHoverBar(nextNode);
                                        forceUpdate = false;
                                    }
                                } else {
                                    manager._hideHoverBar();
                                }
                            }
                            lastCellInfos = cellInfos;
                        }
                    }
                };

                // -- binding events to callbacks --
                this.addEventListener('mousemove', onPointerMove);
                this.addEventListener('mouseenter', function() {
                    forceUpdate = true;
                });
            },

            _hideHoverBar: function() {
                if (this.elements.hoverbarContainer) {
                    this.elements.hoverbarContainer.setAttribute('visibility', 'false');
                }
            },

            _showHoverBar: function(nodeModel) {
                if (this.elements.hoverbarContainer === undefined) {

                    var stopPropagation = function(e) {
                        e.stopPropagation();
                    };
                    this.elements.hoverbarContainer = new UWA.Element('div', {
                        'class': 'wux-spectree-hoverbar',
                        events: {
                            mousedown: stopPropagation,
                            touchstart: stopPropagation,
                            mouseup: stopPropagation,
                            touchend: stopPropagation
                        }
                    });
                    this.elements.hoverbarContainerRel = new UWA.Element('div', {
                        'class': 'wux-spectree-hoverbar-rel'
                    }).inject(this.elements.hoverbarContainer);
                    this.elements.hoverbarContainerBlurMask = new UWA.Element('div', {
                        'class': 'wux-spectree-hoverbar-blur'
                    }).inject(this.elements.hoverbarContainerRel);
                    this.elements.hoverbarContainer.inject(this.elements.poolContainerRel);

                    this.elements.hoverbarToolbar = new WUXToolbar({
                        overflowManagement: 'dropdown',
                        direction: 'horizontal',
                        adaptSizeToParent: true
                    }).inject(this.elements.hoverbarContainerRel);
                } else {
                    this.elements.hoverbarToolbar.clear();
                    // this.elements.hoverbarToolbar.clearPosition('near');
                    // this.elements.hoverbarToolbar.clearPosition('center');
                    // this.elements.hoverbarToolbar.clearPosition('far');
                }

                var rowID = nodeModel._getRowID();
                this.elements.hoverbarContainer.setStyles({
                    top: this.getRowPosition(rowID),
                    height: this.getRowHeight(rowID),
                    right: 0
                });

                var me = this;

                if (nodeModel) {

                    var doc = this.getDocument();
                    var nodeCategory = nodeModel._getNodeCategory();
                    var nodeType = nodeModel._getNodeType();
                    // var currentApplication = doc.getCurrentApplication();
                    var options = this._getParent().options;

                    var listOfItems = [];
                    var listOfItemsProtected = [];

                    // -- resolve --
                    doc._specTreeVlt._processNodeType(nodeCategory, nodeType, options.application, function(data) {
                        var nodeTypeOptions = data.options;
                        // -- we call buildHoverBar only if the callback is defined
                        // and if the nodeModel is not a sub-node (horizontal node)
                        if (nodeTypeOptions && nodeTypeOptions.buildHoverBar && !nodeModel._isSubnode()) {
                            listOfItems = nodeTypeOptions.buildHoverBar({
                                nodeModel: nodeModel,
                                hoverBarModel: UWA.clone(listOfItems)
                            });
                        }
                        // console.log('-->', data, ctxOptions);
                    }, 'buildHoverBar');

                    // -- Return concatenated contextual menu entries --
                    if (listOfItems instanceof Array) {

                        listOfItems.forEach(function(entryOptions) {
                            listOfItemsProtected.push(entryOptions);
                        });

                        listOfItemsProtected.forEach(function(options) {
                            var button = new WUXButton({
                                label: '',
                                displayStyle: 'icon',
                                icon: options.icon
                            });

                            //
                            var minHeight=me.getRowHeight(nodeModel)-4;
                            button.getContent().setStyle('min-height', minHeight+'px');
                            button.getContent().setStyle('line-height', (minHeight-4)+'px');

                            button.addEventListener('buttonclick', function(e) {
                                if (options.callback) {
                                    me.elements.hoverbarContainer.setStyle('PointerEvents', 'none');
                                    options.callback({
                                        nodeModel: nodeModel
                                    });
                                    setTimeout(function() {
                                        me.elements.hoverbarContainer.setStyle('PointerEvents', '');
                                        me._showHoverBar(nodeModel);
                                    }, 100);
                                }
                            });
                            me.elements.hoverbarToolbar.add('element', {
                                element: button.getContent(),
                                position: 'far'
                            });
                        });

                        if (listOfItemsProtected.length > 0) {
                            me.elements.hoverbarContainer.setAttribute('visibility', 'true');
                        } else {
                            me.elements.hoverbarContainer.setAttribute('visibility', 'false');
                            // me._hideHoverBar();
                        }
                    } else {
                        throw 'SpecTree: buildHoverBar does not return an array';
                    }
                }
            }
        });


        /*
        ███████ ██████  ███████  ██████ ████████ ██████  ███████ ███████ ██    ██ ██ ███████ ██     ██
        ██      ██   ██ ██      ██         ██    ██   ██ ██      ██      ██    ██ ██ ██      ██     ██
        ███████ ██████  █████   ██         ██    ██████  █████   █████   ██    ██ ██ █████   ██  █  ██
             ██ ██      ██      ██         ██    ██   ██ ██      ██       ██  ██  ██ ██      ██ ███ ██
        ███████ ██      ███████  ██████    ██    ██   ██ ███████ ███████   ████   ██ ███████  ███ ███
        */


        var SpecTreeView = TreeListView.extend({

            defaultOptions: {
                specTreeVault: null,
                cellClass: SpecTreeNodeView,
                managerClass: SpecTreeManager,
                application: SpecTreeDocument.APP_DEFAULT_NS,
                // treeDocument: new SpecTreeDocument(),
                expanderStyle: 'triangle',
                performances: {
                    renderingMode: 'adaptive',
                    numberOfRowsFactor: 3,
                    numberOfColumnsFactor: 1,
                    buildLinks: false,
                    preloadPool: true,
                    resizeDebounceTimeout: 10,
                    // -- /!\ reduce artefact on the row headers recycling --
                    useRequestAnimationFrameRendering: true,
                    automaticSizeTreeColumnToFit: false,
                    minimumScrollDistance: 10
                },
                apiVersion: 2,
                // show: {
                //     columnHeaders: true,
                //     rowHeaders: STATIC_COLUMNS
                // },
                show: {
                    rowHeaders: true,
                    columnHeaders: true
                },
                selection: {
                    rowHeaders: false,
                    preSelection: true,
                    nodes: true,
                    canMultiSelect: true,
                    enableListSelection: true,
                    toggle: false
                },
                defaultCellHeight: 38,
                changeColorOnFocus: false,
                showLinesSeparator: false,
                enableExpandOnDoubleClick: false,
                enableStaticColumns: true,
                isEditable: true,
                enableActiveUI: true,
                enableKeyboardNavigation: true,
                enableTreeColumnEllipsisOverflow: true,
                showScrollbarsOnHover: true,
                columns: [
                    // COLUMNS.NOTIFICATION_COLOR,
                    COLUMNS.BORDER_COLOR,
                    COLUMNS.TREE,
                    COLUMNS.NOTIFICATION_ICON,
                    COLUMNS.COLOR,
                    COLUMNS.HIDE_SHOW,
                    COLUMNS.SELECTION
                    // COLUMNS.ACTION
                ],

                // -- Manage contextual menu event --
                onContextualEvent: {
                    callback: function onContextualEvent(params) {
                        if (params && params.treeview) {
                            var options = params.treeview.manager._getParent().options;
                            if (params.treeview.virtualRowID > -1 && params.treeview.virtualColumnID > -1) {

                                var nodeCategory = params.treeview.nodeModel._getNodeCategory();
                                var nodeType = params.treeview.nodeModel._getNodeType();

                                var ctxOptions = [];
                                var ctxOptionsProtected = [];

                                // -- resolve --
                                params.treeview.manager.getDocument()._specTreeVlt._processNodeType(nodeCategory, nodeType, options.application, function(data) {
                                    var nodeTypeOptions = data.options;
                                    if (nodeTypeOptions && nodeTypeOptions.buildContextualMenu) {
                                        ctxOptions = nodeTypeOptions.buildContextualMenu({
                                            nodeModel: params.treeview.nodeModel,
                                            contextualMenuModel: ctxOptions
                                        });
                                    }
                                    // console.log('-->', data, ctxOptions);
                                }, 'buildContextualMenu');

                                // -- Return concatenated contextual menu entries --
                                ctxOptions.forEach(function(entryOptions) {
                                    if (DEBUG_CTX_ENTRIES) {
                                        entryOptions.title = '[' + (options.application ? options.application : SpecTreeDocument.DEFAULT_APP_NS) + '] ' + entryOptions.title;
                                    }
                                    // - /!\ -- only preserve entries containing a command ID,
                                    // We do not want to have js callback in the menu
                                    // if (entryOptions.commandID) {
                                    //     entryOptions.action = {
                                    //         callback: function(d) {
                                    //             CommandsManager.getCommand(entryOptions.commandID).begin();
                                    //         }
                                    //     };
                                    //     ctxOptionsProtected.push(entryOptions);
                                    // } else {
                                    //     console.error('Contextual menu item has been ignored because it doesn\'t contain a command ID');
                                    // }
                                    if (entryOptions.action) {
                                        // entryOptions.action = {
                                        //     callback: function(d) {
                                        //         CommandsManager.getCommand(entryOptions.commandID).begin();
                                        //     }
                                        // };
                                        ctxOptionsProtected.push(entryOptions);
                                    } else {
                                        console.error('Contextual menu item has been ignored because it doesn\'t contain an action callback');
                                    }
                                });

                                return ctxOptionsProtected;
                            }
                        }
                    }
                }


            },


            init: function(options) {
                options.apiVersion = 2;
                options.enableStaticColumns = options.enableStaticColumns !== undefined ? options.enableStaticColumns : true;
                options.show = UWA.extend({
                    rowHeaders: true,
                    columnHeaders: true
                }, options.show);
                // -- manage static columns --
                if (options.enableStaticColumns) {
                    options.show = {
                        rowHeaders: options.show.rowHeaders !== undefined ? options.show.rowHeaders : false,
                        columnHeaders: options.show.columnHeaders !== undefined ? options.show.columnHeaders : false
                    };
                    options.staticColumns = [];
                    var staticColumnsWidth = 0;

                    var columns = options.columns || UWA.clone(this.defaultOptions.columns);
                    // UWA.extend(UWA.clone(this.defaultOptions.columns), options.columns);
                    columns = columns.filter(function(columnOptions) {
                        if (columnOptions.isStatic) {
                            staticColumnsWidth += columnOptions.width;
                            options.staticColumns.push(UWA.clone(columnOptions));
                            return false;
                        } else {
                            return true;
                        }
                    });
                    options.columns = columns;

                    options.headersDimensions = {
                        width: options.show.rowHeaders ? staticColumnsWidth : 0,
                        height: options.show.columnHeaders ? 40 : 0
                    };
                }

                // -- define options to be used. It's a merge of user ones and TreeListView override ones
                options = UWA.extend(UWA.clone(this.defaultOptions), options);
                options.treeDocument = options.treeDocument || new SpecTreeDocument();


                // -- Calling parent constructor (TreeListView)
                this._parent(options);



                var me = this;
                var manager = this.getManager();

                // -- Customize the view with a CSS class
                this.getContent().addClassName('wux-spectreeview');

                // -- handle lines separator display --
                if (this.options.showLinesSeparator) {
                    this.elements.container.setAttribute('show-lines-separator', 'true');
                } else {
                    this.elements.container.setAttribute('show-lines-separator', 'false');
                    // this.elements.container.removeAttribute('show-lines-separator');
                }


                // -- set current application on SpecTreeModel --
                this.options.treeDocument.setCurrentApplication(this.options.application);





                this._registerReusables();

                // -- Specific Behaviors/Overides --
                if (this.options.enableStaticColumns) {
                    if (STATIC_COLUMNS_RIGHT) {
                        DomUtils.setStyles(manager.elements.rowsHeaderContainer, {
                            right: 0,
                            left: 'initial'
                        });
                        DomUtils.setStyles(manager.elements.gridHeaderContainer, {
                            right: manager.elements.rowsHeaderContainer.style.width,
                            left: 0
                        });
                    }




                    // -- Corner header --
                    var reuseContent = this.getManager()._reusableCellContentManager.use('__staticcolumns__');
                    var view = reuseContent.component;
                    me.options.staticColumns.forEach(function (columnOptions) {
                        var subCellView = view.subCells[columnOptions.dataIndex];
                        // -- resetting subcell content --
                        if (me.options.show.columnHeaders) {
                            if (columnOptions.icon) {
                                var icon = DomUtils.generateIcon(columnOptions.icon);
                                DomUtils.setContent(subCellView, icon);
                            } else {
                                DomUtils.setContent(subCellView, columnOptions.text);
                            }
                        }
                    });
                    view.inject(this.getManager().elements.corner);







                    // -- Column headers --
                    this.getManager().onColumnHeaderRequest(function updateStaticRow(cellInfos) {
                        if (cellInfos.dataIndex === 'tree') {
                            manager._reflectNewActiveNode();
                        }
                    });

                    // -- Rows headers --
                    this.getManager().onRowHeaderRequest(function updateStaticRow(cellInfos) {
                        var view = cellInfos.cellView.reuseCellContent('__staticcolumns__');
                        cellInfos.nodeModel = manager.getTreeNodeModelFromRowID(cellInfos.virtualRowID);

                        if (cellInfos.nodeModel) {
                            me.options.staticColumns.forEach(function(columnOptions) {
                                var subCellView = view.subCells[columnOptions.dataIndex];
                                var oldCellView = cellInfos.cellView;
                                // -- swapping cellview with subCellView --
                                cellInfos.manager = manager;
                                cellInfos.cellView = subCellView;
                                // -- resetting subcell content --
                                view.appendChild(subCellView);
                                // DomUtils.empty(subCellView);
                                // -- requesting each column cell request --
                                columnOptions.onCellRequest(cellInfos);
                                // -- restoring the cellview --
                                cellInfos.cellView = oldCellView;
                            });
                        }
                    });
                }


                // -- manage some behaviors --
                this._manageSelectionColumn();
                this._manageZoom();
                this._manageAutomaticResize();
                this._mapBehaviorToNodeTypes();
            },


            // TOREMOVE after DockingElement remove the destroy call in their code
            destroy: function() {

            },


            _manageAutomaticResize: function() {
                this._lastRegisteredTreeColumnWidth = 0;

                var me = this;
                var manager = this.getManager();

                // -- Force removal of horizontal scrollbar --
                me.getManager().onReady(function() {
                    // me.getManager().getScroller().getContent().setStyle('overflow-x', 'hidden');
                    var lastScroll = {
                        x: 0,
                        y: 0
                    };

                    function sizeTreeColumnToFit(cellInfos) {
                        // console.group('sizeTreeColumnToFit');
                        var newWidth = manager._computeMinimalColumnWidth('tree');
                        if (me._lastRegisteredTreeColumnWidth !== newWidth || manager.__lastScrollPos.x !== lastScroll.x) {
                            manager.prepareUpdateView();
                            manager.setColumnWidth('tree', newWidth);
                            manager.pushUpdateView();
                            me._lastRegisteredTreeColumnWidth = newWidth;
                            lastScroll = manager.__lastScrollPos;
                            console.info('sizeTreeColumnToFit');
                        }
                        // else {
                        //     console.info('energy saver');
                        // }
                        // me.getManager().sizeColumnToFit('tree');
                        // console.groupEnd('sizeTreeColumnToFit');
                    }

                    var debouncedSizeTreeColumnToFit = Utils.debounce(sizeTreeColumnToFit, 600);

                    if (me.options.performances.automaticSizeTreeColumnToFit) {

                        me.options.treeDocument.onPostExpand(debouncedSizeTreeColumnToFit);
                        me.options.treeDocument.onPostCollapse(debouncedSizeTreeColumnToFit);
                        me.getManager().getScroller().onScrollEnd(debouncedSizeTreeColumnToFit);
                    }

                });
            },

            _registerReusables: function() {
                var me = this;
                var manager = this.getManager();

                this.getManager().registerReusableCellContent({
                    id: '__staticcolumns__',
                    buildContent: function() {
                        // console.log('create static');
                        var container = new UWA.Element('div', {
                            'class': 'wux-datagrid-static-cell'
                        });

                        container.subCells = {};
                        me.options.staticColumns.forEach(function(columnOptions) {
                            var icon = new UWA.Element('div', {
                                'class': 'wux-datagrid-subcell',
                                styles: {
                                    width: columnOptions.width
                                }
                            }).inject(container);

                            container.subCells[columnOptions.dataIndex] = icon;

                            var _reusableContent;

                            icon.getContent = function() {
                                return icon;
                            };

                            icon._disposeReusableContent = function() {
                                if (_reusableContent) {
                                    _reusableContent.__disposable__.dispose();
                                    _reusableContent = undefined;
                                }
                            };

                            icon._setReusableContent = function(reusableContent) {
                                icon._disposeReusableContent();
                                _reusableContent = reusableContent;

                                icon.setContent((_reusableContent.getContent && _reusableContent.getContent()) || _reusableContent);
                            };
                            icon.reuseCellContent = function(reuseIdentifier) {
                                // var reuseContent = this._reusableCellContentManager.use(reusableID, cellView);
                                // onent);
                                // return reuseContent.component;
                                return manager._reuseCellContent(reuseIdentifier, icon);
                            };
                        });


                        return container;
                    }
                });


                // -- reusable content --
                this.getManager().registerReusableCellContent({
                    id: '__action__',
                    buildContent: function() {
                        var actionIcon = new UWA.Element('div', {
                            'class': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-menu-dot',
                            styles: {
                                display: 'block',
                                textAlign: 'center',
                                lineHeight: me.options.defaultCellHeight + 'px',
                                fontSize: 14
                            }
                        });
                        actionIcon.addEvent('click', function(e) {
                            var ev = document.createEvent('HTMLEvents');
                            ev.initEvent('contextmenu', true, false);
                            ev.pageX = e.pageX;
                            ev.pageY = e.pageY;
                            actionIcon.dispatchEvent(ev);
                        });
                        return actionIcon;
                    }
                });

                this.getManager().registerReusableCellContent({
                    id: '__visibility__',
                    buildContent: function() {
                        var actionIcon = new ColumnIcon({
                            value: true,
                            map: {
                                'false': {
                                    value: {
                                        iconName: 'eye-off'
                                    },
                                    valuePreview: {
                                        iconName: 'eye-off'
                                    }
                                },
                                'true': {
                                    valuePreview: {
                                        iconName: 'eye-off'
                                    },
                                    value: {
                                        // iconName: 'eye'
                                    }
                                }
                            }
                        });
                        actionIcon.getContent().addEvent('click', function(e) {
                            e.stopPropagation();

                            var cellInfos = manager._getCellInfosFromEventTarget(e);
                            var nodeModel = cellInfos.nodeModel;

                            actionIcon.value = !actionIcon.value;

                            nodeModel.setVisibilityInSpecTree(actionIcon.value);

                            var resolvedCallback = actionIcon.value ? 'onShow' : 'onHide';
                            nodeModel._getResolvedAndCall(resolvedCallback);

                        });
                        return actionIcon;
                    }
                });

                this.getManager().registerReusableCellContent({
                    id: '__color__',
                    buildContent: function() {
                        var biColorView = new UWA.Element('span', {
                            styles: {
                                position: 'absolute',
                                top: 10,
                                left: 4,
                                right: 4,
                                bottom: 10,
                                borderRadius: '2px'
                            }
                        });
                        return biColorView;
                    }
                });

                this.getManager().registerReusableCellContent({
                    id: '__bordercolor__',
                    buildContent: function() {
                        var biColorView = new UWA.Element('span', {
                            styles: {
                                position: 'absolute',
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0
                            }
                        });
                        return biColorView;
                    }
                });

                this.getManager().registerReusableCellContent({
                    id: '__notification__',
                    buildContent: function() {
                        var actionIcon = new ColumnIcon({
                            value: true,
                            map: {
                                'false': {
                                    valuePreview: undefined,
                                    value: undefined
                                },
                                'true': {
                                    valuePreview: {
                                        iconName: 'info'
                                    },
                                    value: {
                                        iconName: 'info'
                                    }
                                }
                            }
                        });

                        return actionIcon;
                    }
                });

                this.getManager().registerReusableCellContent({
                    id: '__notificationcolor__',
                    buildContent: function() {
                        var biColorView = new UWA.Element('div', {
                            styles: {
                                width: '100%',
                                height: '100%'
                            }
                        });
                        return biColorView;
                    }
                });



                this.getManager().registerReusableCellContent({
                    id: '__breadcrumb__',
                    buildContent: function() {
                        var breadcrumb = new WUXBreadcrumb({
                            value: [],
                        });

                        breadcrumb.displayLabels = 4;
                        breadcrumb.displayIcons = 1;

                        breadcrumb._lock = false;

                        breadcrumb.addEventListener('change', function(e) {
                            if (breadcrumb._lock === false) {
                                var node = e.dsModel.value[e.dsModel.value.length - 1].node;
                                manager.prepareUpdateView();
                                // -- select and declare as new active node --
                                node.select(true);
                                manager.setActiveNode(node);
                                // -- scroll to node --
                                manager.scrollToNode(node, 'middle');
                                manager.pushUpdateView();

                            }
                        });
                        return breadcrumb;
                    }
                });


            },


            _manageZoom: function() {
                var me = this;
                me._zoom = 1;
                // -- Zoom events --
                UWA.Element.addEvent.call(this.elements.container, 'mousewheel', function(event) {
                    var delta = UWA.Event.wheelDelta(event);
                    var ctrlKey = event.ctrlKey;
                    if (ctrlKey) {
                        event.preventDefault();
                        if (Math.abs(delta) === 1) {
                            delta = delta * 0.05;
                        }
                        // -- Thresholding zoom factor
                        var newZoom = (me._zoom + delta);
                        // console.log('new zoom', newZoom);
                        if (newZoom >= 0.55 && newZoom <= 1.5) {
                            me._zoom = newZoom;
                            me.getManager().elements.container.setStyle('zoom', me._zoom.toFixed(2));

                            me.getManager().updateView(true);
                            me.getManager().onPostUpdateViewOnce(function() {
                                me.getManager()._updateUIActiveArea();
                            });
                        }
                    }
                });

            },


            _manageSelectionColumn: function() {
                var me = this;
                // -- registering custom cell contents --
                me.getManager().registerReusableCellContent({
                    id: '_specTreeSelection',
                    buildContent: function() {
                        var toggle = new UWA.Element('div', {
                            'class': 'wux-spectreeview-selection-area',
                            html: '&nbsp;'
                        });

                        toggle.addEventListener('focus', function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                        });

                        return toggle;
                    }
                });

                var manager = me.getManager();
                var delta = 0,
                    currentDelta = 0,
                    lastEnd = -1;
                var beginRowID, endRowID;
                var lastRowID;
                var xso, treeDoc; // = treeDoc.getXSO();
                var previousListOfSelectNodes = [];
                var firstNodeWasSelected = false;

                var selectOnDrag = function(e, infos) {

                    // console.log(infos);

                    treeDoc = manager.getDocument();
                    xso = treeDoc.getXSO();

                    if (me.options.selection.canMultiSelect) {
                        if (xso.get().length === 0 && beginRowID >= 0) { //&& beginRowID >= 0
                            // console.log('empty xso');
                            var firstNode = manager.getTreeNodeModelFromRowID(beginRowID);
                            firstNode.withTransactionUpdate(function() {
                                manager.selectRow(beginRowID, false);
                                manager.setActiveNode(firstNode);
                                firstNode.select();
                                manager._preventNextUpdateView();
                            });
                        }

                        if (xso.get().length !== 0) {
                            var nextNode = manager.getTreeNodeModelFromRowID(infos.rowID);

                            delta = nextNode._getRowID() - xso.get()[0]._getRowID();
                            currentDelta = nextNode._getRowID() - lastRowID;

                            // console.log(delta, currentDelta);

                            if (currentDelta !== 0) {

                                // -- flag selection mode as multiselection and listselection
                                manager._modeIsListSel = true;
                                manager._modeIsMultiSel = true;

                                endRowID = infos.rowID;
                                lastRowID = infos.rowID;

                                manager.prepareUpdateView();

                                // - /!\ -- We need to prevent the normal view updated
                                // because else, cells content will be requested and event delegation
                                // will be broken. Hence, touch selection will not work
                                manager._preventNextUpdateView();

                                xso.empty();
                                // manager.unselectAll();
                                var selectedRows = manager.getSelectedRows();
                                while (selectedRows[0] !== undefined) {
                                    manager.unselectRow(selectedRows[0]);
                                }
                                // console.log('unselect all');

                                var begin, end;
                                if (delta > 0) {
                                    begin = beginRowID;
                                    end = endRowID;
                                } else {
                                    end = beginRowID;
                                    begin = endRowID;
                                }
                                // console.log(begin, '>', end);
                                previousListOfSelectNodes.forEach(function(node) {
                                    manager.unselectRow(node._getRowID());
                                });
                                previousListOfSelectNodes = [];
                                for (var i = begin; i <= end; i++) {
                                    var nodeModelToSelect = manager.getTreeNodeModelFromRowID(i);
                                    if (nodeModelToSelect.isSelected() === false) {
                                        nodeModelToSelect.select();
                                    }
                                    // -- force selection state (remember, view update are prevented)
                                    manager.selectRow(i, false);

                                }
                                if (lastEnd > end) {
                                    for (var i = end + 1; i <= lastEnd; i++) {
                                        var nodeModelToSelect = manager.getTreeNodeModelFromRowID(i);
                                        // -- here nodeModelToSelect could be undefined
                                        // because the rowID could be not visible
                                        if (nodeModelToSelect) {
                                            nodeModelToSelect.unselect();
                                        }
                                        // -- force unselection state (remember view update are prevented)
                                        manager.unselectRow(i);
                                    }
                                }

                                // var nodeModelToSelect = manager.getTreeNodeModelFromRowID(end);
                                manager.setActiveNode(nextNode);

                                lastEnd = end;

                                manager._modeIsListSel = false;
                                manager._modeIsMultiSel = false;

                                manager.pushUpdateView();
                            }
                        }
                    }
                };


                manager._draggable({
                    begin: function(e, infos) {
                        // console.group('drag');
                        if (infos.columnID === -1 && DomUtils.firstParentWithClass(e.target, 'wux-spectreeview-selection-area')) { //
                            e.preventDefault();
                            e.stopPropagation();
                            treeDoc = manager.getDocument();
                            xso = treeDoc.getXSO();
                            previousListOfSelectNodes = xso.get().slice();
                            // --
                            var nextNode = manager.getTreeNodeModelFromRowID(infos.rowID);
                            firstNodeWasSelected = nextNode.isSelected();
                            if (me.options.selection.canMultiSelect) {
                                nextNode.withTransactionUpdate(function() {
                                    manager.selectRow(infos.rowID, false);
                                    manager.setActiveNode(nextNode);
                                    nextNode.select();
                                    manager._preventNextUpdateView();
                                });
                            } else {
                                nextNode.withTransactionUpdate(function() {
                                    manager.setActiveNode(nextNode);
                                    nextNode.select(true);
                                });
                            }
                            // --
                            beginRowID = infos.rowID;
                            lastRowID = infos.rowID;
                        }
                    },
                    drag: function(e, infos) {
                        // console.log(manager.getScrollerPosition());
                        if (DomUtils.hasClass(e.target, 'wux-spectreeview-selection-area')) {
                            e.stopPropagation();
                        }
                        if (manager.getScrollerPosition().y < 0) {
                            e.stopPropagation();
                            e.preventDefault();
                        }
                        // if (infos.columnID === -1) {
                        if (infos.columnID === -1 && DomUtils.firstParentWithClass(e.target, 'wux-spectreeview-selection-area')) {
                            selectOnDrag(e, infos);
                        }
                    },
                    end: function(e, infos) {

                        if (infos.columnID === -1 && beginRowID !== undefined && DomUtils.firstParentWithClass(e.target, 'wux-spectreeview-selection-area')) {
                            var beginNode = manager.getTreeNodeModelFromRowID(beginRowID);
                            // infos = manager._getRowIDFromEvent
                            if (beginNode._isLayoutNode()) {
                                infos = manager._getCellInfosFromEventTarget(e);
                            }


                            if (infos.columnID === -1 && beginRowID === infos.rowID && firstNodeWasSelected) {
                                var nextNode = manager.getTreeNodeModelFromRowID(infos.rowID);
                                manager.setActiveNode(nextNode);
                                nextNode.unselect();
                            }

                            manager.updateView();

                        }
                        // console.groupEnd('drag');
                        // selectOnDrag(e, infos);
                    }
                });
            },





            _mapBehaviorToNodeTypes: function() {

                var treeDoc = this.getDocument();
                var manager = this.getManager();

                manager.addEventListener('click', function(e, nodeInfos) {
                    if (nodeInfos && nodeInfos.isHeader === false) {

                        var nodeModel = nodeInfos.nodeModel;

                        switch (nodeModel._getNodeCategory()) {
                            case treeDoc._specTreeVlt.NODE_CATEGORIES.FAKE:
                                if (nodeModel.isExpanded()) {
                                    nodeModel.collapse();
                                } else {
                                    nodeModel.expand();
                                }
                                break;
                            default:

                        }

                    }
                });
            },


            _search: function(options) {
                var specTreeDoc = this.getManager().getDocument();
                return specTreeDoc.search({
                    match: function(nodeInfos) {
                        nodeInfos.nodeModel.show();
                        nodeInfos.nodeModel.unmatchSearch();
                        if (options.value && options.value !== '' && (JSON.stringify(nodeInfos.nodeModel.options.grid) + '  ' + nodeInfos.nodeModel._getNodeType() + ' ' + nodeInfos.nodeModel.getLabel()).toLowerCase().indexOf(options.value.toLowerCase()) >= 0) {
                            // console.log('search found');
                            nodeInfos.nodeModel.matchSearch(false);
                            return true;
                        }
                    }
                });
            },


            findInterface: function(options, done) {
                options.specTreeShell.closeDrawer();
                var specTreeDoc = this.getManager().getDocument();
                specTreeDoc.prepareUpdate();
                var searchResults = this._search({
                    value: options.value
                });
                searchResults.forEach(function(node) {
                    node.matchSearch();
                });
                specTreeDoc.pushUpdate();
            },
            searchInterface: function(options) {
                options.specTreeShell.openDrawer({
                    height: 200
                });

                var me = this;

                var spectreeDocument = this.getManager().getDocument();


                var searchResults = this._search({
                    value: options.value
                });

                var newModel = SpecTreeDocument._buildSpecTreeDocumentFromSearchResult({
                    searchResults: searchResults
                });

                newModel.getXSO().onAdd(function(node) {
                    var nodes = spectreeDocument.search({
                        useTransaction: false,
                        match: function(nodeInfos) {
                            return node.options._originalID === nodeInfos.nodeModel._getID();
                        }
                    });
                    me.getManager().scrollToNode(nodes[0], 'middle', false);
                    nodes[0].select(true);
                });

                var colNotificationColor = COLUMNS.NOTIFICATION_COLOR;
                var colNotificationIcon = COLUMNS.NOTIFICATION_ICON;

                colNotificationIcon.isHidden = !options.showNotifications;
                colNotificationColor.isHidden = !options.showNotifications;

                var newFilteredTreeListView = new SpecTreeView({
                    height: 'auto',
                    enableStaticColumns: false,
                    defaultCellHeight: 40,
                    isEditable: true,
                    changeColorOnFocus: false,
                    show: {
                        rowHeaders: false,
                        columnHeaders: false
                    },
                    columns: [
                        colNotificationIcon, {
                            dataIndex: 'path',
                            width: 'auto',
                            getValue: function(nodeInfos) {
                                return nodeInfos.nodeModel.options.path;
                            },
                            setValue: function() {

                            },
                            onCellRequest: function(nodeInfos) {

                                if (nodeInfos.isHeader === false) {
                                    var comp = nodeInfos.cellView.reuseCellContent('__breadcrumb__');
                                    comp._lock = true;
                                    nodeInfos.manager._updateBreadCrumb(comp, nodeInfos.nodeModel.options.path);
                                    // comp.value = nodeInfos.nodeModel.options.path;
                                    comp._lock = false;
                                }
                            }
                        }
                    ]
                });

                // -- add some additional CSS classes to the view in order to theme it --
                newFilteredTreeListView.getContent().addClassName('wux-spectreeview');
                newFilteredTreeListView.getContent().addClassName('wux-state-filtered');
                // -- hiding the tree column because we don't need it --
                newFilteredTreeListView.getManager().hideColumn('tree');

                // -- we load the Search Results TreeDocument --
                newFilteredTreeListView.getManager().loadDocument(newModel);

                // -- appending the result view to the top docking element --
                options.specTreeShell.elements.topDockingElement.dockingZoneContent = newFilteredTreeListView.getContent();
                // displaySearchPanel();
            },
            filterInterface: function(options) {
                options.specTreeShell.closeDrawer();
                var specTreeDoc = this.getManager().getDocument();

                var searchResults = this._search({
                    value: options.value
                });

                if (options.value && options.value.length > 0) {
                    var searchResultsID = searchResults.map(function(node) {
                        return node._getID();
                    });
                    specTreeDoc.prepareUpdate();
                    specTreeDoc.search({
                        match: function(nodeInfos) {
                            nodeInfos.nodeModel.hide();
                            nodeInfos.nodeModel.unmatchSearch();
                            if (searchResultsID.indexOf(nodeInfos.nodeModel._getID()) > -1) {
                                nodeInfos.nodeModel.show();
                                nodeInfos.nodeModel.getParents().forEach(function(node) {
                                    node.show();
                                });
                                return true;
                            }
                            return false;
                        }
                    });
                    specTreeDoc.pushUpdate();
                }
            }

        });


        Object.defineProperty(SpecTreeView, 'DEFAULT_COLUMNS', {
            get: function() {
                return UWA.clone(COLUMNS);
            }
        });



        return SpecTreeView;
    });

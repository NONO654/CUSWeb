define('DS/SpecTree/SpecTreeShell', [
        'DS/SpecTree/SpecTreeView',
        'DS/SpecTree/SpecTreeDocument',
        'DS/Tree/Manager',
        'DS/Tree/TreeNodeModel',
        'DS/Tree/TreeNodeView',
        'DS/Core/PointerEvents',
        'DS/Controls/Button',
        'DS/Controls/Abstract',
        'DS/Controls/ComboBox',
        'DS/Utilities/Dom',
        'DS/Controls/LineEditor',
        'DS/Windows/DockingElement',
        'DS/Utilities/Utils',
        'DS/Windows/Dialog',
        'DS/TreeModel/TreeDocument',
        'DS/Controls/Toolbar',
        'DS/Tweakers/TypeRepresentationFactory'
        // 'DS/Selection/CSOManager',
        // 'DS/Selection/HSOManager'
    ],
    function(SpecTreeView,
        SpecTreeDocument,
        Manager,
        TreeNodeModel,
        TreeNodeView,
        PointerEvents,
        WUXButton,
        Abstract,
        WUXComboBox,
        DomUtils,
        WUXLineEditor,
        WUXDockingElement,
        Utils,
        WUXDialog,
        TreeDocument,
        WUXToolbar,
        TypeRepresentationFactory) {

        'use strict';

        var SearchField = Abstract.inherit({

            publishedProperties: {
                height: {
                    defaultValue: '',
                    type: 'string'
                },
                mode: {
                    defaultValue: 'find',
                    type: 'string'
                },
                value: {
                    defaultValue: '',
                    type: 'string'
                }
            },

            _preBuildView: function() {
                var me = this;

                this._ignoreChangeEvents = false;


                this.elements.container = new UWA.Element('div', {
                    'class': 'wux-spectreeshell-search'
                });

                this.elements.inputSearch = new WUXLineEditor({
                    placeholder: this.mode + '...',
                    value: this.value,
                    selectAllOnFocus: true,
                    autoCommitFlag: true
                }).inject(this.elements.container);

                this.elements.btnSearch = new WUXButton({
                    icon: 'search',
                    displayStyle: 'lite',
                    type: 'check'
                }).inject(this.elements.container);

                this.elements.btnFilter = new WUXButton({
                    icon: 'filter',
                    displayStyle: 'lite',
                    type: 'check'
                }).inject(this.elements.container);

                this._bindEvents();
            },


            _bindEvents: function() {
                var me = this;

                this.elements.inputSearch.addEventListener('change', function(e) {
                    me.value = e.dsModel.value;
                });

                this.elements.btnSearch.addEventListener('change', function() {
                    if (me._ignoreChangeEvents === false) {
                        if (me.elements.btnSearch.checkFlag) {
                            me.mode = 'search';
                        } else {
                            me.mode = 'find';
                        }
                    }
                });


                this.elements.btnFilter.addEventListener('change', function(e) {
                    if (me._ignoreChangeEvents === false) {
                        if (me.elements.btnFilter.checkFlag) {
                            me.mode = 'filter';
                        } else {
                            me.mode = 'find';
                        }
                    }
                });
            },

            _applyMode: function() {
                var me = this;
                this._ignoreChangeEvents = true;
                switch (this.mode) {
                    case 'find':
                        me.elements.btnSearch.checkFlag = false;
                        me.elements.btnFilter.checkFlag = false;
                        break;
                    case 'search':
                        me.elements.btnSearch.checkFlag = true;
                        me.elements.btnFilter.checkFlag = false;
                        break;
                    case 'filter':
                        me.elements.btnSearch.checkFlag = false;
                        me.elements.btnFilter.checkFlag = true;
                        break;
                    default:
                }
                this.elements.inputSearch.placeholder = this.mode + '...';
                this._ignoreChangeEvents = false;
            }
        });

        // function loadToolbarModel(parsedJSON) {
        //     var toolbarTreeDocument, root, parsedJSON;
        //     toolbarTreeDocument = new TreeDocument({});
        //     root = new TreeNodeModel({});
        //     // parsedJSON = JSON.parse(jsonFile);
        //     if (!parsedJSON.entries) {
        //         return;
        //     }
        //     // Load the toolbar items description in the treeDocument
        //     parsedJSON.entries.forEach(function(entry) {
        //         root.addChild(new TreeNodeModel(entry));
        //     });
        //     toolbarTreeDocument.addRoot(root);
        //     var result = {
        //         treeDoc: toolbarTreeDocument,
        //         typeReps: parsedJSON.typeRepresentations,
        //         enums: parsedJSON.enums
        //     };
        //     // Register enums
        //     if (result.enums) {
        //         for (var enumName in result.enums) {
        //             typeRepFactory.registerEnum(enumName, result.enums[enumName]);
        //         }
        //     }
        //     // Register external type representation
        //     if (result.typeReps) {
        //         typeRepFactory.registerTypeRepresentations(result.typeReps);
        //     }
        //     return result;
        // }



        var typeRepFactory = new TypeRepresentationFactory();



        var SpecTreeViewShell = Abstract.inherit({

            publishedProperties: {
                height: {
                    defaultValue: '',
                    type: 'string'
                },
                application: {
                    defaultValue: '',
                    type: 'string'
                },
                representations: {
                    defaultValue: [],
                    type: 'array'
                }
            },

            _preBuildView: function() {
                var me = this;
                this._enums = ['test'];
                typeRepFactory.registerEnum('Enum1', function() {
                    return me._enums;
                });

                console.warn('Please DO NOT USE this component yet');

                // -- outer container --
                this.elements.container = new UWA.Element('div', {
                    'class': 'wux-spectreeshell'
                });

                // -- header container --
                this.elements.header = new UWA.Element('div', {
                    'class': 'wux-spectreeshell-header',
                    styles: {
                        zIndex: 1000000
                    }
                }).inject(this.getContent());

                setTimeout(function() {
                    me._buildHeader();

                }, 1000);

                // -- tree selector --
                this.elements.combo = new WUXComboBox({
                    elementsList: [],
                    selectedIndex: 0,
                    enableSearchFlag: false,
                    actionOnClickFlag: true
                });

                this.elements.combo.addEventListener('change', function(e) {
                    me.elements.topDockingElement.freeZoneContent = e.dsModel.currentValue();
                });

                this.elements.searchField = new SearchField();

                this.elements.searchField.addEventListener('change', function() {
                    me._search();
                });


                // // -- search bar / prev & next buttons --
                // this.elements.inputSearch = new WUXLineEditor({
                //     placeholder: 'Search',
                //     selectAllOnFocus: true,
                //     autoCommitFlag: true
                // }).inject(this.elements.toolbarRight);
                //
                // this.elements.btnSearch = new WUXButton({
                //     icon: 'search',
                //     displayStyle: 'lite',
                //     type: 'check'
                // }).inject(this.elements.toolbarRight);
                //
                // this.elements.searchNextPreviousContainer = new UWA.Element('span').hide().inject(this.elements.toolbarRight);
                //
                // this.elements.btnPrevious = new WUXButton({
                //     icon: 'chevron-left',
                //     displayStyle: 'lite'
                // }).inject(this.elements.searchNextPreviousContainer);
                // this.elements.btnNext = new WUXButton({
                //     icon: 'chevron-right',
                //     displayStyle: 'lite'
                // }).inject(this.elements.searchNextPreviousContainer);
                //
                // this.elements.btnFilter = new WUXButton({
                //     icon: 'filter',
                //     displayStyle: 'lite',
                //     type: 'check'
                //
                // }).inject(this.elements.toolbarRight);
                //
                //
                // // -- settings button --
                // this.elements.btnSetting = new WUXButton({
                //     icon: 'cog',
                //     displayStyle: 'lite'
                // }).inject(this.elements.toolbarRight);



                // -- docking areas --
                this.elements.topDockingElement = new WUXDockingElement({
                    side: WUXDockAreaEnum.TopDockArea,
                    collapsibleFlag: false,
                    collapseDockingZoneFlag: true,
                    visibleDockingZoneFlag: false
                });
                var dockingAreaContainer = new UWA.Element('div', {
                    styles: {
                        position: 'absolute',
                        top: 40,
                        bottom: 0,
                        left: 0,
                        right: 0
                    }
                });
                this.elements.topDockingElement.inject(dockingAreaContainer);
                dockingAreaContainer.inject(this.elements.container);


                this.elements.topDockingElement.visibleDockingZoneFlag = true;
                this.elements.topDockingElement.visibleDockingZoneFlag = false;



                if (window.jasmine !== undefined && !window.WEBUX_DO_NOT_TEST_SPECTREEVIEW) {
                    setInterval(function() {
                        if (me.getContent().getParent()) {
                            // me.getConteSnt().remove();
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
                    }, 1);
                }

            },

            _buildHeader: function() {

                this.elements.toolbar = new WUXToolbar({
                    overflowManagement: 'dropdown',
                    //adaptSizeToParent: true,
                    direction: 'horizontal'
                }).inject(this.elements.header);
                this.elements.toolbar.adaptSizeToParent = true;

                // this.elements.toolbar = new WUXGeneratedToolbar({
                //     overflowManagement: 'dropdown',
                //     direction: 'horizontal',
                //     // items: result.treeDoc,
                //     typeRepresentationFactory: typeRepFactory
                // }).inject(this.elements.header);

                this.elements.toolbar.add('element', {
                    element: this.elements.combo.getContent(),
                    position: 'near'
                });

                this.elements.toolbar.add('element', {
                    element: this.elements.searchField.getContent(),
                    position: 'far'
                });

            },


            _getCurrentViewOptions: function() {
                return this.representations[this.elements.combo.selectedIndex];
            },

            _applyProperties: function(oldValues) {
                this._applyRepresentations();
                this._parent(oldValues);
            },

            _applyRepresentations: function() {

                var me = this;

                this.elements.combo.elementsList = this.representations.map(function(options) {
                    return {
                        labelItem: options.label,
                        valueItem: options.mainView,
                        iconItem: options.icon
                    };
                });

                // var possibleValues = [];
                // this._representations = {};
                // this.representations.forEach(function(options) {
                //     possibleValues.push({
                //         'value': options.label, //options.mainView,
                //         'icon': options.icon,
                //         'tooltip': {
                //             'text': options.label,
                //             'position': 'Bottom'
                //         }
                //     });
                //     me._enums[options.label] = options;
                // });

                // typeRepFactory.registerTypeRepresentations({
                //     'ToggleView': {
                //         'stdTemplate': 'comboSelector',
                //         'semantics': {
                //             'possibleValues': possibleValues
                //         }
                //     }
                // });

            },


            _search: Utils.debounce(function(options) {

                var me = this;
                var value = this.elements.searchField.value;

                switch (this.elements.searchField.mode) {
                    case 'find':
                        me._getCurrentViewOptions().onFind({
                            value: value,
                            specTreeShell: this
                        });
                        break;
                    case 'search':
                        me._getCurrentViewOptions().onSearch({
                            value: value,
                            specTreeShell: this
                        });
                        break;
                    case 'filter':
                        me._getCurrentViewOptions().onFilter({
                            value: value,
                            specTreeShell: this
                        });
                        break;
                    default:
                }
            }, 500),


            openDrawer: function(options) {
                var me = this;
                me.elements.topDockingElement.dockingZoneSize = options.height;
                me.elements.topDockingElement.visibleDockingZoneFlag = true;
                me.elements.topDockingElement.dockingZoneContent = options.content;
            },

            closeDrawer: function() {
                var me = this;
                me.elements.topDockingElement.visibleDockingZoneFlag = false;
            }

        });


        return SpecTreeViewShell;


    });

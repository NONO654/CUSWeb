//XSS_CHECKED
(function(GLOBAL, template) {
    var typeRepFactory, demoControl;
    var getTreeDocument, getTreeListView;
    var getTreeNodeModel, getTreeNodeView;

    var typeRepReady = false;
    var readyFunctions = [];

    // Set up some callbacks to execute functions when typeRepFactory is ready.
    var onTypeRepReady = function(cb) {
        if (typeRepReady) {
            cb();
        } else {
            readyFunctions.push(cb);
        }
    };

    var styleAttributeObject = function(Json) {
        var that = this;

        this.json = Json;
        this.attributes = {};
        this.attributeObjects = {};
        // this.container = container;

        onTypeRepReady(function() {
            that.initialize();
        });
    };

    styleAttributeObject.prototype.getNode = function() {
        return this.node;
    };

    styleAttributeObject.prototype.processTweakerJSON = function(json) {
        var processNode = function(node) {
            var newNode = {};

            Object.keys(node).forEach(function(key) {
                var attribute;

                // Extract contents of functions
                if (typeof node[key] === 'function') {
                    attribute = node[key]();
                } else {
                    attribute = node[key];
                }

                // Recursively process all attributes
                if (typeof attribute === 'object') {
                    newNode[key] = processNode(attribute);
                } else {
                    newNode[key] = attribute;
                }
            });

            return newNode;
        };

        return processNode(json);
    };

    styleAttributeObject.prototype.initialize = function() {
        var that = this;

        var attributeTweakerData = [];

        var nodeOptions = {
            label: this.json.label,
            data: {},
            grid: { tweakers: '' }
        };

        this.node = getTreeNodeModel(nodeOptions);

        // for(key in this.json.attributeObjects){
        Object.keys(this.json.attributeObjects).forEach(function(key) {
            that.attributeObjects[key] = new styleAttributeObject(
                that.json.attributeObjects[key],
                that.container
            );
            that.attributeObjects[key].setUpdateCallback(function(updateObj) {
                var obj = {};
                obj[key] = updateObj;

                that.update(obj);
            });

            that.node.addChild(that.attributeObjects[key].getNode());
        });

        //}

        // Json is an object, not a string!
        Object.keys(this.json.attributes).forEach(function(key) {
            var attr = that.processTweakerJSON(that.json.attributes[key]);

            attributeTweakerData.push({
                name: key,
                label: attr.label,
                data: attr.value,
                typePath: attr.typePath,
                event: attr.event || 'change',
                semantics: attr.semantics,
                displayStyle: attr.displayStyle
            });
        });

        attributeTweakerData.forEach(function(d) {
            var contentContainer = new UWA.Element('div', {
                styles: { width: '100%' }
            });

            var contentPane = new demoControl();

            var viewCreatedFunction = function(createdView) {
                if (createdView !== undefined) {
                    // In this sample, when the view is built, we inject it in the
                    // customizer table
                    createdView.inject(contentContainer);

                    // And we add a listener on the "change" or "liveChange" event
                    // to update the demoControl property
                    createdView.addEventListener(d.event, function(e) {
                        if (d.typePath === 'color') {
                            // Update color attributes so they're valid color
                            // codes...
                            e.dsModel.value = '#' + e.dsModel.value;
                        }

                        console.log(e.dsModel.value);
                        contentPane[d.name] = e.dsModel.value;

                        var updateObject = {};
                        updateObject[d.name] = e.dsModel.value;

                        that.update(updateObject);
                    });
                }
            };

            // var generateObject = {
            //  typePath: d.typePath,  // typePath is used to specify an alternative
            //  type representation to override the default one data : d.data,//
            //  onViewCreated callback will be called when the view will be fully
            //  created onViewCreated: viewCreatedFunction
            //};
            d.onViewCreated = viewCreatedFunction;

            if (d.displayStyle && d.displayStyle === 'slider') {
                d.context = 'slider';
            }

            typeRepFactory.generateView(
                d.data, // the input data to represent
                d
            );

            // that.container.appendChild(contentContainer);
            var tweakerNodeOptions = {
                label: d.label,
                data: d,
                grid: { tweakers: contentContainer }
            };

            var tweakerNode = getTreeNodeModel(tweakerNodeOptions);
            that.node.addChild(tweakerNode);
        });

        // Build associated node
    };

    styleAttributeObject.prototype.update = function(updateObject) {
        // updateObject represents a change to either an attribute or an
        // attributeObject child of this element.
        if (typeof this.updateCallback !== 'undefined') {
            this.updateCallback(updateObject);
        }
    };

    styleAttributeObject.prototype.setUpdateCallback = function(cb) {
        this.updateCallback = cb;
    };

    var stylePanelPrototype = { is: 'ra-stylepanel', behaviors: [] };

    stylePanelPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        onTypeRepReady(function() {
            var options = {};

            that.treeDocument = getTreeDocument();
            options.treeDocument = that.treeDocument;
            options.apiVersion = 2;

            options.height = 'auto';

            // RVA2: replace Tree view with TreeListView to show parameter maps
            // columns along with Parameter name
            // this.tree = new Tree(options);
            options.show = { rowHeaders: false, columnHeaders: false };

            options.columns = [
                { dataIndex: 'tree', width: 'auto' },
                {
                    dataIndex: 'tweakers',
                    width: 150,
                    onCellRequest: function(cellData) {
                        var colorShapeComponent = cellData.cellView.reuseCellContent(
                            'tweakers'
                        );

                        colorShapeComponent.setContent(
                            cellData.nodeModel.options.grid.tweakers
                        );

                        // cellData.cellModel.setCellContent(cellData.nodeModel.options.grid.tweakers);
                    }
                }
            ];

            //          options.columns = [{dataIndex: 'colorMap',
            //              onCellRequest :
            //              function(cellInfos){that.colorMapToElement(cellInfos);}},
            //              {dataIndex: 'shapeMap',
            //                  onCellRequest :
            //                  function(cellInfos){that.shapeMapToElement(cellInfos);}}];

            var addTweaker = function() {
                var colorShapeComponent = new UWA.Element('div', {
                    styles: {
                        display: 'flex',
                        /*border: '1px solid #9d9d9d',*/
                        'vertical-align': 'middle',
                        height: '100%'
                        /*'max-width': '50px'*/
                    }
                });
                return colorShapeComponent;
            };

            that.tree = getTreeListView(options);
            that.tree.
                getManager().
                registerReusableCellContent({
                    id: 'tweakers',
                    buildContent: addTweaker
                });

            /*
         * this.tree.getManager().registerReusableCellContent({
        id: 'colorShapeMapElement',
        buildContent :  that.getColorShapeMapElement
    });
         */
            that.tree.inject(that.querySelector('.styleBody'));
        });

        // GLOBAL.DS.RAObjects.createSettings(this.querySelector('.styleBody'));
    };

    stylePanelPrototype.setParameters = function(parameters) {
        var that = this;

        onTypeRepReady(function() {
            // Remove existing settings
            /*var existing = that.querySelectorAll('.tweakerContainer');
        Array.prototype.forEach.call(existing,function(node){
            node.parentElement.removeChild(node);
        });*/
            that.treeDocument.removeRoots();

            // Create new settings
            parameters.forEach(function(d) {
                that.buildTweaker(d);
            });
        });
    };

    stylePanelPrototype.buildTweaker = function(paramData) {
        var that = this;

        // var container = document.createElement('div');
        // container.classList.add('tweakerContainer');

        var styleObject = new styleAttributeObject(paramData);
        styleObject.setUpdateCallback(function(updateData) {
            var paramUpdateData = { id: paramData.id, data: {} };

            var key;
            for (key in paramData.attributes) {
                if (updateData[key]) {
                    paramUpdateData[key] = updateData[key];
                }
            }

            for (key in paramData.attributeObjects) {
                if (updateData[key]) {
                    paramUpdateData[key] = updateData[key];
                }
            }

            that.onUpdate(paramUpdateData);
        });

        var rootNode = styleObject.getNode();

        this.treeDocument.addRoot(rootNode);

        // this.querySelector('.styleBody').appendChild(container);
    };

    stylePanelPrototype.currentChart = function(chart) {
        if (chart) {
            this._currentChart = chart;
        }

        return this._currentChart;
    };

    stylePanelPrototype.setChangeCallback = function(cb) {
        this.changeCb = cb;
    };

    stylePanelPrototype.onUpdate = function(data) {
        if (this.changeCb) {
            this.changeCb(data);
        }
    };

    Polymer(stylePanelPrototype);
    GLOBAL.DS.RAComponents.stylePanelPrototype = stylePanelPrototype;

    require([
        'UWA/Core',
        'DS/Core/Core',
        'DS/Tweakers/TypeRepresentationFactory',
        'DS/Windows/DockingElement',
        'DS/Controls/Abstract',
        'DS/Tree/TreeNodeModel',
        'DS/Tree/TreeNodeView',
        'DS/Tree/TreeListView',
        'DS/Tree/TreeDocument'
    ], function(
        UWA,
        WUX,
        TypeRepFactory,
        DockingElement,
        Abstract,
        TreeNodeModel,
        TreeNodeView,
        TreeListView,
        TreeDocument
    ) {
        // Helper functions to expose tree stuff outside of require block.
        // These shouldn't be used until the type rep factory is ready.
        getTreeDocument = function(options) {
            return new TreeDocument(options);
        };

        getTreeListView = function(options) {
            return new TreeListView(options);
        };

        getTreeNodeView = function(options) {
            return new TreeNodeView(options);
        };

        getTreeNodeModel = function(options) {
            return new TreeNodeModel(options);
        };

        typeRepFactory = new TypeRepFactory();

        demoControl = Abstract.inherit({
            /*publishedProperties: {
                text:             { defaultValue: 'webUX' },
                bgColor:          { defaultValue: '#005686' },
                width:            { defaultValue: 200 },
                borderRadius:     { defaultValue: 100 },
                displayShadow:    { defaultValue: true },
                fontSize:         { defaultValue: "26pt" },
                horizontalAlign:  { defaultValue: "left" }
            },*/

            buildView: function() {
                this.elements.container.addClassName(
                    'rootContainer rootContainerShadow'
                );
                this.elements.container.setText(this.text);
            },

            _applyText: function() {
                this.elements.container.setText(this.text);
            },
            _applyBgColor: function() {
                this.elements.container.setStyle(
                    'background-color',
                    '#' + this.bgColor
                );
            },
            _applyWidth: function() {
                this.elements.container.setStyle('width', this.width + 'px');
            },
            _applyBorderRadius: function() {
                this.elements.container.setStyle(
                    'border-radius',
                    this.borderRadius * 30 / 100 + 'px'
                );
            },
            _applyDisplayShadow: function() {
                this.elements.container.toggleClassName('rootContainerShadow');
            },
            _applyFontSize: function() {
                this.elements.container.setStyle('font-size', this.fontSize);
            },
            _applyHorizontalAlign: function() {
                this.horizontalAlign === 'center'
                    ? this.elements.container.setStyles({
                          marginLeft: 'auto',
                          marginRight: 'auto'
                      })
                    : this.horizontalAlign === 'right'
                      ? this.elements.container.setStyles({
                            marginLeft: 'auto',
                            marginRight: ''
                        })
                      : this.elements.container.setStyles({
                            marginLeft: '',
                            marginRight: ''
                        });
            }
        });

        var setupTypeReps = function() {
            var typeReps = { numberslider: { stdTemplate: 'slider' } };

            typeRepFactory.registerTypeRepresentations(typeReps);
        };

        typeRepFactory.onReady = function() {
            setupTypeReps();

            typeRepReady = true;
            readyFunctions.forEach(function(fn) {
                fn();
            });
        };
    });
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */

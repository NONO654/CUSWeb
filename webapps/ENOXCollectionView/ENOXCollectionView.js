define('DS/ENOXCollectionView/ENOXCollectionView', [
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXCollectionView/Commons/Decorators',
    'DS/ENOXCollectionView/InlineEditor/js/InlineEditor',
    'DS/CollectionView/CollectionView',
    'DS/CollectionView/layouts/CollectionViewGridLayout',
    'DS/Handlebars/Handlebars',
    'text!DS/ENOXCollectionView/Commons/Section.html',
    'css!DS/ENOXCollectionView/Commons/ENOXCollectionView.css'
], function (ModelEvents, Decorators, InlineEditor, CollectionView, CollectionViewGridLayout,
        Handlebars, GroupBySectionTemplate) {

    var ROW_MAX_HEIGHT = {
        'normal': 60,
        'small': 30
    };

    var TEMPLATES = {
        taskSection: Handlebars.compile(GroupBySectionTemplate),
    };

    var ENOXCollectionView = function (container) {
        this.container = container;
        this.container.classList.add('enox-collectionview');
        this.isMinified = false;
    };

    ENOXCollectionView.prototype.init = function (treeDoc, modelEvents, customCellContentMappingFunction) {
        var that = this;
        that.modelEvents = modelEvents;
        that.activeTileID = null;

        /** Create the CollectionView */
        var layout = new CollectionViewGridLayout({
            sectionHeight: 50,
            columnMaxWidth: '100%',
            rowMaxHeight: 60,
            gutter: 0
        });
        var grid = new CollectionView({
            layout: layout,
            height: 'inherit'
        });
        that.grid = grid;

        /** Save the customCellContentMapping if passed as parameters */
        that.customCellContentMapping = customCellContentMappingFunction;

        /** Load model passed as parameter */
        that.loadModel(treeDoc);

        /** Register BaseTileView (classic and small) and ExpandableTileView (expanded and collapsed) tiles */
        Decorators.registerBaseTileView(grid);
        Decorators.registerExpandableTileView(grid);

        // TODELETE
        that.grid.elements.poolContainer.setAttribute('data-visible-attributes-columns', '3');

        that.grid.onCellRequest(function(cellInfos) {

            // Force uncheck the selection checkbox
            var checkboxElt = cellInfos.cellView.elements.container.getElement('.tile-view-checkbox');
            if (checkboxElt !== null) {
                checkboxElt.checked = false;
            }

            // Clean a remaining inline editor being left active through the corresponding decorator
            InlineEditor.cleanOnCellRequest(cellInfos);

            // Determine cell content based on cell model and isMinified boolean status
            var cellContent = cellInfos.cellModel.options.data._view;
            if (that.isMinified) {
                cellContent = 'small' + cellContent;
            }

            // Use Custom Cell Content Mapping if available or default one
            var comp = that.grid.reuseCellContent(cellContent);
            if (that.customCellContentMapping !== undefined && that.customCellContentMapping !== null) {
                that.customCellContentMapping(comp, cellInfos);
            } else {
                Decorators.defaultCellContentMapping(comp, cellInfos);
            }
            cellInfos.cellView._setReusableContent(comp);
        });

        grid.addEventListener('click', function (e, cellInfos) {
            if (cellInfos) {
                that.currentCellModel = cellInfos.cellModel;
                that.currentCellView = cellInfos.cellView;

                if (e.target.hasClassName('enox-collectionview-expand-btn')) {
                    // Expand
                    that.treeDoc.prepareUpdate();
                    cellInfos.cellModel.expand();
                    that.treeDoc.pushUpdate();
                } else if (e.target.hasClassName('enox-collectionview-collapse-btn')) {
                    // Collapse
                	that.treeDoc.prepareUpdate();
                    cellInfos.cellModel.getParent().collapse();
                    that.treeDoc.pushUpdate();
                } else if (e.target.hasClassName('enox-collectionview-checkbox')) {
                    // If click is on checkbox, toggle isSelected state of the item and trigger corresponding event
                    grid.model[cellInfos.cellID].options.data.isSelected = !grid.model[cellInfos.cellID].options.data.isSelected;
                    that.modelEvents.publish({event: 'item-selected', data: {rowID: cellInfos.cellID, isSelected: grid.model[cellInfos.cellID].options.data.isSelected}});
                } else if (e.target.hasClassName('fonticon-open-down')) {
                    // If click is on the dropdown, create a dropdown menu based on the model of the cell
                    Decorators.createDropdownMenu(e.target.getParent(), grid.model[cellInfos.cellID].options.data.dropdown, that.modelEvents);
                } else if (e.target.hasClassName('enox-collectionview-title')) {
                    // if click is on the title, create an inline editor for the name of the object
                    var tmpModelEvents = new ModelEvents();
                    var inlineEditorContainer = InlineEditor.replaceElementByInlineEditor(e.target, tmpModelEvents);
                    tmpModelEvents.subscribe({event: 'inline-editor-validated'}, function (d) {
                        inlineEditorContainer.parentNode.removeChild(inlineEditorContainer);
                        e.target.classList.remove('hidden');
                        that.modelEvents.publish({event: 'inline-editor-validated', data: d});
                    });
                    tmpModelEvents.subscribe({event: 'inline-editor-cancelled'}, function (data) {
                        inlineEditorContainer.parentNode.removeChild(inlineEditorContainer);
                        e.target.classList.remove('hidden');
                    });
                } else if(e.target.hasClassName('tile-view-warning-cue') || e.target.hasClassName('tile-view-cue-icon')){
                    that.modelEvents.publish({event: 'cue-icon-activated', data: that.grid.model[cellInfos.cellID].options.data});
                } else if (!e.target.hasClassName('inline-editor-text')) {
                    // If click is on the tile, toggle isActive state of the item and trigger corresponding event
                    if (that.activeTileID !== null) {
                        that.grid.model[that.activeTileID].options.data.isActive = false;
                    }
                    if (that.activeTileID === null || cellInfos.cellID !== that.activeTileID) {
                        that.activeTileID = cellInfos.cellID;
                        that.grid.model[that.activeTileID].options.data.isActive = true;
                    } else {
                        that.activeTileID = null;
                    }
                    that.refreshView();

                    if (that.activeTileID === null) {
                        that.modelEvents.publish({event: 'item-activated', data: {rowID: null}});
                    } else {
                        that.modelEvents.publish({event: 'item-activated', data: {model: that.grid.model[that.activeTileID], rowID: that.activeTileID}});
                    }
                }
            }
        });

        that.grid.getContent().inject(that.container);
    };

    ENOXCollectionView.prototype.toggleMinified = function () {
        this.isMinified = !this.isMinified;
        if (this.isMinified) {
            this.grid.layout.rowMaxHeight = ROW_MAX_HEIGHT.small;
        } else {
            this.grid.layout.rowMaxHeight = ROW_MAX_HEIGHT.normal;
        }
        this.refreshView();
    };

    ENOXCollectionView.prototype.loadModel = function (treeDoc) {
    	var that = this;
    	that.treeDoc = treeDoc;

        /** Parse the model to add the type of tile to be created */
        that.parseModel(treeDoc);

        /** Listen to update on model to automatically re-parse it when it changes */
        ['addChild', 'removeChild', 'hide', 'show', 'expand', 'collapse'].forEach(function (evt) {
            treeDoc.addEventListener(evt, function() {
                that.parseModel(treeDoc);
            });
        });

        that.treeDoc.flattenTreeDocument({
            onUpdate: function (infos) {
                // Remove expanded, visible root tile to only show instance tile when expanded
                var flattenedTreeDocument = infos.flattenedTreeDocument;
                flattenedTreeDocument.forEach(function (doc, idx) {
                    if (doc.options.data._view === 'collapsedtile' && doc._isExpanded && doc.isVisible()) {
                        flattenedTreeDocument.splice(idx, 1);
                    }
                });

                // update grid model and invalidate layout to trigger repaint
                that.grid.model = flattenedTreeDocument;
                if (that.grid._isReady) {
                    that.refreshView();
                }
            }
        });
    };

    ENOXCollectionView.prototype.refreshView = function () {
        this.grid._updateDimensions();
        this.grid.invalidateLayout({            
            updateCellContent: true,
            updateCellLayout: true,
            updateCellAttributes: true
        });
    };

    ENOXCollectionView.prototype.destroy = function () {
        this.grid.destroy();
    };

    ENOXCollectionView.prototype.parseModel = function (treeDoc) {
        treeDoc.getRoots().forEach(function (node) {

            if (node.getChildren() !== null) {
                // If element has childrens, create an expandable tile (collapsed tile for parent, expanded tile for childrens)
                node.options.data._view = 'collapsedtile';
                node.options.data.numberOfOccurences = node.options.data.numberOfOccurences || node.getChildren().length;
                node.getChildren().forEach(function (child, idx) {
                    UWA.merge(child.options.data, node.options.data);
                    child.options.data._view = 'expandedtile';
                    if (idx !== 0) {
                        child.options.data.numberOfOccurences = null;
                    }
                });
            } else {
                // If element has no children, create a base tile view
                node.options.data._view = 'tile';
            }
        });
    };

    return ENOXCollectionView;
});

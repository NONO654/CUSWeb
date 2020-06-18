/**
 * @licence Copyright 2006-2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0
 * @access private
 */
define('DS/ENOXCollectionViewCommons/InstanceView/InstanceView', [
    // 'DS/ENOXCollectionViewCommons/InstanceView/InstanceTileView/js/InstanceTileView',
    'DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/js/InstanceTileView',
    // 'DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/js/InstanceTileView',
    'DS/ENOXCollectionViewCommons/InstanceView/InstanceSmallTileView/js/InstanceSmallTileView',
    'DS/ENOXMultiSelManager/js/ENOXMultiSelManager',
    'DS/CollectionView/CollectionView',
    'DS/CollectionView/layouts/CollectionViewGridLayout',
    'DS/CoreEvents/ModelEvents',
    'DS/ResizeSensor/js/ResizeSensor'
], function (InstanceTileView, InstanceSmallTileView, ENOXMultiSelManager, CollectionView, CollectionViewGridLayout, ModelEvents, ResizeSensor) {
    'use strict';

    var ROW_MAX_HEIGHT = {
        'instance': 45,
        'instancesmall': 30
    };

    var InstanceView = function (container) {
        this.currentClickedRow = null;
        this.mainSelectedTileID = null;
        this.previousSelected = null;
        this.container = container;
        this.currentCellId = 'instance';
    };

    InstanceView.prototype.init = function (data, modelEvents,viewsOptions) {
        var that = this;
        that.modelEvents = modelEvents;

        /** Init CollectionView */
        var grid = new CollectionView({
            model: data,
            layout: new CollectionViewGridLayout({
                rowMaxHeight: 45,
                columnMaxWidth: '100%',
                gutter: 0,
                getLayoutAttributesForCellAt: function(cellID) {
                var attributes = this._parent(cellID);
                attributes.draggable = true;
                attributes.isDragged = this.collectionView.model[cellID].__isDragged ? 'true' : 'false';
                return attributes;
              }
            }),
            height: 'inherit'
        });
        that.grid = grid;

        /** Define reusable cell content */
        grid.registerReusableCellContent({
            id: 'instance',
            buildContent: function() {
                return new InstanceTileView();
            }
        });
        grid.registerReusableCellContent({
            id: 'instancesmall',
            buildContent: function () {
                return new InstanceSmallTileView();
            }
        });

        grid.onCellRequest(function (cellInfos) {

          // Force uncheck the selection checkbox
          var checkboxElt = cellInfos.cellView.elements.container.getElement('.instance-tile-view-checkbox');
          if (checkboxElt !== null) {
              checkboxElt.checked = false;
          }

            var comp = grid.reuseCellContent(that.currentCellId);

            comp.shading = cellInfos.cellModel.getShading();
            comp.isExpanded = cellInfos.cellModel.isExpanded();
            comp.isSelected = null; //fix for IR-571857-3DEXPERIENCER2018x
            comp.isSelected = cellInfos.cellModel.isSelected();
            comp.isCut = null;
            comp.isCut = cellInfos.cellModel.isCut();
            comp.noExpander = true;
            comp.thumbnail = cellInfos.cellModel.getThumbnail();
            comp.referenceName = cellInfos.cellModel.getReferenceName();
            comp.version = cellInfos.cellModel.getReferenceVersion();
            comp.isLastVersion = cellInfos.cellModel.isLastVersion();
            comp.referenceMainAttribute = cellInfos.cellModel.getReferenceMainAttribute();
            comp.instanceName = cellInfos.cellModel.getInstanceName();
            comp.instanceMainAttribute = cellInfos.cellModel.getInstanceMainAttribute();
            comp.attributes = cellInfos.cellModel.getAttributes();
            comp.effectivity = cellInfos.cellModel.getEffectivity();
            cellInfos.cellView._setReusableContent(comp);
        });

        var dragged = null;
        var draggedNode = null;

        var searchCellIDfDraggedNode = function(model, nodeID) {
            var test = true;
            var i;
            for (i = 0; i < model.length & test; i++) {
                if (model[i]._getID && model[i]._getID() === nodeID) {
                    test = false;
                }
            }
            return i - 1;
        };


        grid.addEventListener('dragstart', function(e, infos) {
            dragged = infos.cellModel._getID();
            draggedNode = infos.cellModel;
            infos.cellModel.__isDragged = true;
            viewsOptions.onDragStart && viewsOptions.onDragStart(e, infos);
        });

        grid.addEventListener('dragenter', function(e, infos) {
            if (infos && infos.cellID !== undefined && infos.cellModel._getID() !== dragged) {
                // var i = searchCellIDfDraggedNode(grid.model, dragged);


                // infos.cellModel.getParent().addChild(draggedNode, infos.cellModel._getID());
                // move(grid.model, i, infos.cellID);

                viewsOptions.onDragEnter && viewsOptions.onDragEnter(e, infos);

                grid.invalidateLayout({
                    freePool: false
                });
            }
        });
        //
        // grid.addEventListener('drop', function(e, infos) {
        //     var i = searchCellIDfDraggedNode(grid.model, dragged);
        //     dragged = null;
        //     grid.model[i].__isDragged = false;
        //     viewsOptions.onDrop && viewsOptions.onDrop(e, infos);
        //     // grid.invalidateLayout();
        // });

        grid.addEventListener('dragend', function(e, infos) {
            var i = searchCellIDfDraggedNode(grid.model, dragged);
            dragged = null;
            grid.model[i].__isDragged = false;
            grid.invalidateLayout({
                freePool: false
            });
            viewsOptions.onDragEnd && viewsOptions.onDragEnd(e, infos);
            // grid.invalidateLayout();
        });

        grid.addEventListener('click', function (e, cellInfos) {
            if (cellInfos) {
                that.currentClickedRow = cellInfos.cellID;
                if (e.target.hasClassName('instance-tile-view-checkbox')) {
                    // If click is on checkbox, toggle selection of the item...
                    that.updateSelection(cellInfos, e.target.checked, true);

                } else if(e.target.hasClassName('fonticon-open-down')){
                        var rect = e.target.getBoundingClientRect();
                          viewsOptions.buildDropdownMenu(rect, [cellInfos.cellModel] /* currently for monosel*/);
                          that.updateSelection(cellInfos, true, false);

                }else {

                    that.updateSelection(cellInfos, !cellInfos.cellModel.isSelected(), false);
                }
            }
        });

        grid.getContent().inject(that.container);
        grid.getContent().addClassName('wux-tree-treelistview');

        // Attach ResizeSensor and trigger first resize
        new ResizeSensor(grid.elements.poolContainer, function () {
            that.resize();
        });
        that.resize();
    };

    InstanceView.prototype.updateSelection = function(cellInfos, isForSelection, isCheckbox){
      var that = this, node = cellInfos.cellModel; //;this.grid.model[cellInfos.cellID];
      if (isForSelection) {
        if (ENOXMultiSelManager.isMultiselEnable()) {
          ENOXMultiSelManager.addSelection([node]);
          that.modelEvents.publish({event: 'item-selected', data: {id: node.id, rowID: cellInfos.cellID}});
        }else {
          if(isCheckbox){
            ENOXMultiSelManager.activate();
            ENOXMultiSelManager.addSelection([node]);
            that.modelEvents.publish({event: 'item-selected', data: {id: node.id, rowID: cellInfos.cellID}});
            if (ENOXMultiSelManager.getMonoselItem()) {
              ENOXMultiSelManager.addSelection([ENOXMultiSelManager.getMonoselItem()]);
              ENOXMultiSelManager.setMonoselItem(null);
            }
          }else {
            if (ENOXMultiSelManager.getMonoselItem()){
              ENOXMultiSelManager.getMonoselItem().unselect();
              node.select();
              that.modelEvents.publish({event: 'item-selected', data: {id: node.id, rowID: cellInfos.cellID}});
              ENOXMultiSelManager.setMonoselItem(node);
            }else{
              node.select();
              that.modelEvents.publish({event: 'item-selected', data: {id: node.id, rowID: cellInfos.cellID}});
              ENOXMultiSelManager.setMonoselItem(node);
            }
          }
        }
      } else { //deseeclection
        if (ENOXMultiSelManager.isMultiselEnable()){
          ENOXMultiSelManager.removeSelection([node]);
          that.modelEvents.publish({event: 'item-selected', data: {rowID: null}});


        }else{
          node.unselect();
          that.modelEvents.publish({event: 'item-selected', data: {rowID: null}});
          ENOXMultiSelManager.setMonoselItem(null);
        }

      }

      that.grid.invalidateLayout({
                        freePool: true
                    });
    };



    InstanceView.prototype.resize = function () {
        var that = this;
        var container = that.grid.elements.poolContainer;
        if(!container) return ;
        var width = container.offsetWidth;

        /** Hide attributes column */
        var visibleAttributeColumns = 3;    // default
        if (width < 700) {
            visibleAttributeColumns = 0;
        } else if (width < 1000) {
            visibleAttributeColumns = 1;
        } else if (width < 1300) {
            visibleAttributeColumns = 2;
        }
        container.setAttribute('data-visible-attributes-columns', visibleAttributeColumns);

        /** Hide thumnail at 400px */
        if (width < 400) {
            container.addClassName('nothumbnail');
        } else {
            container.removeClassName('nothumbnail');
        }
    };

    InstanceView.prototype.updateModel = function (data, rerender) {
        this.grid.model = data;
        if (rerender) {
            this.grid.invalidateLayout({
                        freePool: true
                    });
            // this.grid.__preventNextUpdateViewCounter = 0;
            // this.grid._renderViewport();
        }
    };

    InstanceView.prototype.switchRepresentation = function () {
        if (this.currentCellId === 'instance') {
            this.currentCellId = 'instancesmall';
        } else {
            this.currentCellId = 'instance';
        }

        this.grid.layout.rowMaxHeight = ROW_MAX_HEIGHT[this.currentCellId];
        this.grid.invalidateLayout({
                        freePool: true
                    });
        // this.grid.__preventNextUpdateViewCounter = 0;
        // this.grid._renderViewport();
    };

    InstanceView.prototype.destroy = function () {
        this.grid.destroy();
    };

    return InstanceView;
});

/**
 * @licence Copyright 2006-2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0
 * @access private
 */
define('DS/ENOXCollectionViewCommons/RefInstView/RefInstView', [
    'DS/ENOXCollectionViewCommons/RefInstView/ReferenceTileView/js/ReferenceTileView',
    'DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/js/InstanceTileView',
    'DS/CollectionView/CollectionView',
    'DS/CollectionView/layouts/CollectionViewGridLayout',
    'DS/ResizeSensor/js/ResizeSensor'
], function (ReferenceTileView, InstanceTileView, CollectionView, CollectionViewGridLayout, ResizeSensor) {
    'use strict';

    var RefInstView = function (container) {
        this.container = container;
        this.currentCellId = 'instance';
        this.mainSelectedTileID = null;
        this.init_number = 0;
        this.expanded = {};
    };

    RefInstView.prototype.addExpanded = function(node){
      if(!this.expanded[node.getUuid()]){
        this.expanded[node.getUuid()] = true;
      }
    };
    RefInstView.prototype.removeExpanded = function(node){
      delete this.expanded[node.getUuid()];
    }
    RefInstView.prototype.init = function (dataReference, modelEvents, viewsOptions) {
        var that = this;
        that.modelEvents = modelEvents;


        /** Init CollectionView */
        var grid = new CollectionView({
            model: dataReference,
            layout: new CollectionViewGridLayout({
                rowMaxHeight: 45,
                columnMaxWidth: 1900,
                gutter: 0
            }),
            height: 'inherit'
        });
        that.grid = grid;

        /** Define reusable cell content */
        grid.registerReusableCellContent({
            id: 'reference',
            buildContent: function () {
                return new ReferenceTileView();
            }
        });
        grid.registerReusableCellContent({
        	id: 'instance',
        	buildContent: function () {
        		return new InstanceTileView();
        	}
        });

        grid.onCellRequest(function (cellInfos) {
            var comp;

            comp = grid.reuseCellContent(cellInfos.cellModel.getViewType());

            if (cellInfos.cellModel.getViewType() === 'instance') {
                comp.instanceName = cellInfos.cellModel.getInstanceName();
                comp.effectivity = cellInfos.cellModel.getEffectivity();
                comp.referenceQuantity = cellInfos.cellModel.getReferenceQuantity();
                comp.isLastChild = cellInfos.cellModel.isLastChild();
            } else {
                comp.quantity = cellInfos.cellModel.getQuantity();
            }

            comp.isMainSelection = cellInfos.cellModel.isMainSelection;
            comp.isExpanded = cellInfos.cellModel.isExpanded();
            comp.isSelected = cellInfos.cellModel.isSelected();
            comp.thumbnail = cellInfos.cellModel.getThumbnail();
            comp.referenceName = cellInfos.cellModel.getReferenceName();
            comp.version = cellInfos.cellModel.getReferenceVersion();
            comp.isLastVersion = cellInfos.cellModel.isLastVersion();
            comp.attributes = cellInfos.cellModel.getAttributes();

            cellInfos.cellView._setReusableContent(comp);
        });

        grid.addEventListener('click', function (e, cellInfos) {
            if (cellInfos) {
                if (e.target.hasClassName('reference-tile-view-quantity-label') || e.target.hasClassName('reference-tile-view-quantity')) {
                    that.expandNode(cellInfos.cellModel)
                    that.updateModel(that.grid.model, true);
                } else if (e.target.hasClassName('instance-tile-view-quantity-label') || e.target.hasClassName('instance-tile-view-quantity')) {
                	var instIdx = that.grid.model.findIndex(function (el) {
                		return el.getUuid() === cellInfos.cellModel.getUuid();
                	});
                	var associatedRef =   that.grid.model[instIdx].getGroup();///that.dataReferenceOri[that.grid.model[instIdx].options.idxRef];
                  that.removeExpanded(associatedRef);

                	that.grid.model.splice(instIdx, associatedRef.getInstances().length);
                	that.grid.model.splice(instIdx, 0, associatedRef);

                    that.updateModel(that.grid.model, true);
                }else{

                  	 if(e.target.hasClassName('fonticon-open-down')){
                        var rect = e.target.getBoundingClientRect();
                		 viewsOptions.buildDropdownMenu(rect, [grid.model[cellInfos.cellID]] /* currently for monosel*/);
                		 }

                	if (that.mainSelectedTileID === null){
                		that.mainSelectedTileID = cellInfos.cellID;
                        that.grid.model[that.mainSelectedTileID].isMainSelection = true;
                	} else {

                		if (cellInfos.cellID !== that.mainSelectedTileID){
                			that.grid.model[that.mainSelectedTileID].isMainSelection = false;
                			that.mainSelectedTileID = cellInfos.cellID;
                            that.grid.model[that.mainSelectedTileID].isMainSelection = true;

                		} else if(!e.target.hasClassName('fonticon-open-down')){
                      that.grid.model[that.mainSelectedTileID].isMainSelection = false;
                      that.grid.model[that.mainSelectedTileID].toggleSelection();
                      that.mainSelectedTileID = null;
                       	 }

                	}


                  if (that.mainSelectedTileID === null) {
                      that.modelEvents.publish({event: 'item-selected', data: {rowID: null}});
                  } else {
                        if(that.grid.model[that.mainSelectedTileID].options)
                      that.modelEvents.publish({event: 'item-selected', data: {id : that.grid.model[that.mainSelectedTileID].id, rowID: that.grid.model[that.mainSelectedTileID].options.orignalIdx}});
                  }

                  that.updateModel(that.grid.model, true);
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

    RefInstView.prototype.resize = function () {
        var that = this;
        var container = that.grid.elements.poolContainer;
        var width = that.container.offsetWidth;
        console.log(width);

        // /** Hide attributes column */
        // var visibleAttributeColumns = 3;    // default
        // if (width < 550) {
        //     visibleAttributeColumns = 0;
        // } else if (width < 700) {
        //     visibleAttributeColumns = 1;
        // } else if (width < 1150) {
        //     visibleAttributeColumns = 2;
        // }
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

    RefInstView.prototype.updateModel = function (data, rerender) {
      this.init_number ++;
      // if(this.init_number<3)
        this.grid.model = data;
         //this.updateListState();
        if (rerender) {
            this.grid.invalidateLayout({
                              freePool: true
                          });
            // this.grid.__preventNextUpdateViewCounter = 0;
            // this.grid._renderViewport();
        }
    };

    RefInstView.prototype.expandNode = function(node){
      var that = this;
      var refIdx = that.grid.model.findIndex(function (el) {
        return el.getUuid() === node.getUuid() ;
      });
      if(refIdx=== -1)
      return null;
      that.addExpanded(that.grid.model[refIdx]);

      var childrens = that.grid.model[refIdx].getInstances();
      for (var i = 0; i < childrens.length; i++) {
    	  that.grid.model.splice(refIdx + i + 1, 0, childrens[i]);
      }
      that.grid.model.splice(refIdx, 1);
    };
    RefInstView.prototype.updateListState = function(){
      var that = this;
      for (var groupId in this.expanded) {
        if (this.expanded.hasOwnProperty(groupId)) {
          var idx =   that.grid.model.findIndex(function (el) {
            return el.getUuid() === groupId ;
          });
          if(idx === -1)
          continue;

          that.expandNode(that.grid.model[idx]);

        }
      }
    };

    // var instIdx = that.grid.model.findIndex(function (el) {
    //   return el.getUuid() === cellInfos.cellModel.getUuid();
    // });
    RefInstView.prototype.destroy = function () {
    	this.grid.destroy();
    };

    return RefInstView;
});

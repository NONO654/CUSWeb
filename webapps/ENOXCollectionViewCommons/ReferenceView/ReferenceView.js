/**
 * @licence Copyright 2006-2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0
 * @access private
 */
define('DS/ENOXCollectionViewCommons/ReferenceView/ReferenceView', [
                                                                    'DS/UIKIT/DropdownMenu',
                                                                    'DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/js/ReferenceTileView',
                                                                    'DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/js/ReferenceSubtileView',
                                                                    'DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/js/ReferenceSmallTileView',
                                                                    'DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/js/ReferenceSmallSubtileView',
                                                                    'DS/CollectionView/CollectionView',
                                                                    'DS/CollectionView/layouts/CollectionViewGridLayout',
                                                                    'DS/ResizeSensor/js/ResizeSensor'
                                                                    ], function (DropdownMenu, ReferenceTileView, ReferenceSubtileView, ReferenceSmallTileView, ReferenceSmallSubtileView, CollectionView, CollectionViewGridLayout, ResizeSensor) {
	'use strict';

	var ROW_MAX_HEIGHT = {
			'reference': 60,
			'referencesmall': 30
	};

	var ReferenceView = function (container) {
		this.container = container;
		this.currentCellId = 'reference';
		this.objCellInfo = {};
	};

	ReferenceView.prototype.init = function (data, modelEvents) {
		var that = this;
		that.modelEvents = modelEvents;

		/** Init CollectionView */
		var grid = new CollectionView({
			model: data,
			layout: new CollectionViewGridLayout({
				rowMaxHeight: 60,
				columnMaxWidth: 1900,
				gutter: 0
			}),
			height: 'inherit'
		});
		grid.__preventNextUpdateViewCounter = 0;
		that.grid = grid;

		/** Define reusable cell content */
		grid.registerReusableCellContent({
			id: 'reference',
			buildContent: function () {
				return new ReferenceTileView();
			}
		});
		grid.registerReusableCellContent({
			id: 'referencesmall',
			buildContent: function () {
				return new ReferenceSmallTileView();
			}
		});
		grid.registerReusableCellContent({
			id: 'referencesubtile',
			buildContent: function () {
				return new ReferenceSubtileView();
			}
		});
		grid.registerReusableCellContent({
			id: 'referencesmallsubtile',
			buildContent: function () {
				return new ReferenceSmallSubtileView();
			}
		});

		grid.onCellRequest(function (cellInfos) {
			var comp;
			that.objCellInfo[that.currentCellId + cellInfos.cellID] = cellInfos;

			if (cellInfos.cellModel) {
				if (cellInfos.cellModel.type && cellInfos.cellModel.type === 'subtile') {
					comp = grid.reuseCellContent(that.currentCellId + 'subtile');
					comp.recId = that.currentCellId+cellInfos.cellID;
					comp.isSelected = cellInfos.cellModel.isSelected;
					comp.name = cellInfos.cellModel.name;
					comp.effectivity = cellInfos.cellModel.effectivity;
					comp.isLast = cellInfos.cellModel.isLast || false;

					//test
					comp.thumbnail = cellInfos.cellModel.thumbnail;
					comp.referenceName = cellInfos.cellModel.referenceName + ' ' + cellInfos.cellModel.referenceVersion;
					comp.referenceMainAttribute = cellInfos.cellModel.referenceMainAttribute;
					comp.attributes = cellInfos.cellModel.attributes;
					comp.actions = cellInfos.cellModel.actions;
				} else {
					comp = grid.reuseCellContent(that.currentCellId);
					// comp.getContent().set('id', that.currentCellId+cellInfos.cellID);
					comp.recId = that.currentCellId+cellInfos.cellID;
					comp.shading = cellInfos.cellModel.shading;
					//comp.isExpandable = cellInfos.cellModel.isExpandable;
					comp.isExpanded = cellInfos.cellModel.isExpanded;
					comp.isSelected = cellInfos.cellModel.isSelected;
					comp.quantity = cellInfos.cellModel.quantity;
					comp.thumbnail = cellInfos.cellModel.thumbnail;
					comp.referenceName = cellInfos.cellModel.referenceName + ' ' + cellInfos.cellModel.referenceVersion;
					comp.referenceMainAttribute = cellInfos.cellModel.referenceMainAttribute;
					comp.attributes = cellInfos.cellModel.attributes;
					comp.actions = cellInfos.cellModel.actions;
				}
				cellInfos.cellView._setReusableContent(comp);
			}
		});

		grid.addEventListener('click', function (e, cellInfos) {
			if (cellInfos) {
				if (e.target.hasClassName('reference-tile-view-checkbox')) {
					// If click is on checkbox, toggle selection of the item...
					data[cellInfos.cellID].isSelected = !data[cellInfos.cellID].isSelected;

				} else {
					//if(cellInfos.cellModel.isExpandable){
					if (cellInfos.cellModel.isExpanded) {
						data.splice(cellInfos.cellID + 1, cellInfos.cellModel.expandCount);
						cellInfos.cellModel.isExpanded = false;
						grid.model = data;
						grid.invalidateLayout({
                              freePool: true
                          });
						//grid.__preventNextUpdateViewCounter = 0;
						grid._renderViewport();
					} else {
						that.modelEvents.publish({event: 'before-expand-tile', data: {cellInfos: cellInfos}});

						/*var arrChildItems = [{
                                type: 'subtile',
                                isSelected: false,
                                isLast: true,
                                name: cellInfos.cellModel.instanceName,
                                effectivity: 'Standard2'
                            },{
                                type: 'subtile',
                                isSelected: false,
                                isLast: true,
                                name: cellInfos.cellModel.instanceName,
                                effectivity: 'Standard1'
                            }];

                        	data.splice.apply(data, [cellInfos.cellID + 1, 0].concat(arrChildItems));

                            data.splice(cellInfos.cellID + 1, 0, {
                                type: 'subtile',
                                isSelected: false,
                                isLast: true,
                                name: cellInfos.cellModel.instanceName,
                                effectivity: 'Standard'
                            });
                            cellInfos.cellModel.isExpanded = true;*/
					}
					//}



				}
			}
		});

		that.modelEvents.subscribe({event: 'after-expand-tile'}, function(infoData){
			var items = infoData.items;
			var cellInfos = infoData.cellInfos;
			data.splice.apply(data, [cellInfos.cellID + 1, 0].concat(items));
			cellInfos.cellModel.isExpanded = true;
			cellInfos.cellModel.expandCount = items.length;


			grid.model = data;
			grid.invalidateLayout({
                        freePool: true
                    });
			grid.__preventNextUpdateViewCounter = 0;
			grid._renderViewport();
		});

		grid.getContent().inject(that.container);
		grid.getContent().addClassName('wux-tree-treelistview');

		grid.getContent().addEventListener('tile-menu-click', function (event) {
			console.log('tile-menu-click');
			var tileView = event.detail.itemView;
			that.showDropdown(tileView);
			//that.modelEvents.publish({event: 'attribute-click', data: {cellInfos: cellInfos, tileView: tileView}});
		});


		grid.getContent().addEventListener('attribute-click', function (event) {
			console.log('attribute-click');
			var tileView = event.detail.itemView;
			var cellInfos = that.objCellInfo[tileView.recId];
			that.modelEvents.publish({event: 'attribute-click', data: {cellInfos: cellInfos, tileView: tileView}});
		});

		// Attach ResizeSensor and trigger first resize
		new ResizeSensor(grid.elements.poolContainer, function () {
			that.resize();
		});
		that.resize();
	};

	ReferenceView.prototype.resize = function () {
		var that = this;
		var container = that.grid.elements.poolContainer;
		var width = that.container.offsetWidth;

		/** Hide attributes column */
		var visibleAttributeColumns = 3;    // default
		if (width < 500) {
			visibleAttributeColumns = 0;
		} else if (width < 700) {
			visibleAttributeColumns = 1;
		} else if (width < 900) {
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

	ReferenceView.prototype.updateModel = function (data, rerender) {
		this.grid.model = data;
		if (rerender) {
			this.grid.invalidateLayout({
                        freePool: true
                    });
			this.grid.__preventNextUpdateViewCounter = 0;
			this.grid._renderViewport();
		}
	};

	ReferenceView.prototype.switchRepresentation = function () {
		if (this.currentCellId === 'reference') {
			this.currentCellId = 'referencesmall';
		} else {
			this.currentCellId = 'reference';
		}

		this.grid.layout.rowMaxHeight = ROW_MAX_HEIGHT[this.currentCellId];
		this.grid.invalidateLayout({
                      freePool: true
                  });
		this.grid.__preventNextUpdateViewCounter = 0;
		this.grid._renderViewport();
	};

	ReferenceView.prototype.showDropdown = function (tileView, items) {
		var that = this;
		var cellInfos = that.objCellInfo[tileView.recId];
		var items = cellInfos.cellModel.actions;

		new DropdownMenu({
			target: tileView.elements.container.getElement('#dd-reference-tile'),
			items: items,
			events: {
				'onClick': function(event){
					event.preventDefault();
					event.stopImmediatePropagation();
					var actionItem = this.getItem(event.target);
					var actionId = actionItem? (actionItem.name? actionItem.name : actionItem.text) : null;
					that.modelEvents.publish({event: 'tile-action-click', data: {actionId: actionId, cellInfos: cellInfos}});
					this.destroy();
				},
				'onClickOutside': function(event){
					this.destroy();
				}
			}
		}).show();
	};

	ReferenceView.prototype.destroy = function () {
		this.grid.destroy();
	};

	return ReferenceView;
});

define('DS/ENOXCollectionView/Commons/Decorators', [
    'DS/ENOXCollectionView/BaseTileView/TileView/js/TileView',
    'DS/ENOXCollectionView/BaseTileView/SmallTileView/js/SmallTileView',
    'DS/ENOXCollectionView/ExpandableTileView/ExpandedTileView/js/ExpandedTileView',
    'DS/ENOXCollectionView/ExpandableTileView/CollapsedTileView/js/CollapsedTileView',
    'DS/ENOXCollectionView/ExpandableTileView/SmallExpandedTileView/js/SmallExpandedTileView',
    'DS/ENOXCollectionView/ExpandableTileView/SmallCollapsedTileView/js/SmallCollapsedTileView',
    'DS/UIKIT/DropdownMenu'
], function (TileView, SmallTileView, ExpandedTileView, CollapsedTileView, SmallExpandedTileView, SmallCollapsedTileView, DropdownMenu) {

    var Decorators = {
        defaultCellContentMapping: function (comp, cellInfos) {
            comp.disabled = cellInfos.cellModel.options.data.disabled;
            comp.shading = cellInfos.cellModel.options.data.shading;
            comp.isSelected = cellInfos.cellModel.options.data.isSelected;
            comp.isActive = cellInfos.cellModel.options.data.isActive;
            comp.thumbnail = cellInfos.cellModel.options.data.thumbnail;
            comp.cue = cellInfos.cellModel.options.data.cue;
            comp.typeIcon = cellInfos.cellModel.options.data.typeIcon;
            comp.title = cellInfos.cellModel.options.data.title;
            comp.version = cellInfos.cellModel.options.data.version;
            comp.primaryAttribute = cellInfos.cellModel.options.data.primaryAttribute;
            comp.secondaryAttribute = cellInfos.cellModel.options.data.secondaryAttribute;
            comp.attributes = cellInfos.cellModel.options.data.attributes;
            comp.numberOfOccurences = cellInfos.cellModel.options.data.numberOfOccurences;
        },

        createDropdownMenu: function (targetElt, dropdownOpts, modelEvents) {
            if (dropdownOpts === undefined || dropdownOpts === null) {
                return null;
            }
            dropdownOpts.target = targetElt;
            dropdownOpts.removeOnHide = true;

				// Override the handler for each items to trigger a specific event and the name (id) of the action
				this.wrapDropdownItemHandler(dropdownOpts.items, modelEvents);
				/*dropdownOpts.items.forEach(function (item) {
                item.handler = function () {
                    modelEvents.publish({event: 'dropdown-action-selected', data: {actionId: item.name}});
                }
            });*/

				var dropdownMenu = new DropdownMenu(dropdownOpts).show();
				dropdownMenu.addEventOnce('onHide', function () {
					dropdownMenu.destroy();
				});
			},

			wrapDropdownItemHandler: function(items, modelEvents){
				var that = this;
				items.forEach (function (item) {
					if (item.items) {
						that.wrapDropdownItemHandler(item.items, modelEvents);
					}

					item.handler = function () {
						modelEvents.publish({event: 'dropdown-action-selected', data: {actionId: item.name}});
					}
				});
			},

        registerBaseTileView: function (grid) {
            grid.registerReusableCellContent({
                id: 'tile',
                buildContent: function() {
                    return new TileView();
                }
            });
            grid.registerReusableCellContent({
                id: 'smalltile',
                buildContent: function() {
                    return new SmallTileView();
                }
            });
        },

        registerExpandableTileView: function (grid) {
            grid.registerReusableCellContent({
                id: 'collapsedtile',
                buildContent: function () {
                    return new CollapsedTileView();
                }
            });
            grid.registerReusableCellContent({
                id: 'expandedtile',
                buildContent: function () {
                    return new ExpandedTileView();
                }
            });
            grid.registerReusableCellContent({
                id: 'smallcollapsedtile',
                buildContent: function () {
                    return new SmallCollapsedTileView();
                }
            });
            grid.registerReusableCellContent({
                id: 'smallexpandedtile',
                buildContent: function () {
                    return new SmallExpandedTileView();
                }
            });
        }
    };

    return Decorators;
});

define('DS/ENOXCollectionView/Commons/CollectionViewSectionGridLayoutPatched', [
        'DS/Controls/Abstract',
        'DS/CollectionView/layouts/CollectionViewGridLayout'
    ],
    function(
        ControlsAbstract,
        CollectionViewGridLayout
    ) {

        'use strict';



        var CollectionViewSectionGridLayout = CollectionViewGridLayout.inherit({
            name: 'CollectionViewSectionGridLayout',
            publishedProperties: {
                sectionHeight: {
                    defaultValue: 40,
                    type: 'integer'
                }
            },




            isSectionAt: function(cellID) {
                if (this.collectionView.model.length && this.collectionView.model[cellID]) {
                    return this.collectionView.model[cellID].options && this.collectionView.model[cellID].options.nodeCategory === 'fake';
                } else {
                    return false;
                }
            },

            prepareLayout: function() {
                var layout = this;

                this._listOfSectionsReverseIndexes = {};
                this._listOfSections = [];
                this._listOfItemsInfos = [];
                this.__currentPreviousStackedSection = -1;
                this.__currentNextStackedSection = 0;
                this.__currentStackedSection = 0;

                // Compute the number of columns
                // Retrieve the viewportWidth without the scrollbar
                // (do not call the getViewportDimensions() with true as argument since it is too early to compute the contentDimensions)
                var viewportDimensions = layout.collectionView.getViewportDimensions();
                var scrollbarWidth = /*this._viewportDimensions.height > contentDimensions.height ? 0 : */ UWA.Utils.Client.getScrollbarWidth();
                var viewportDimensionsWidth = viewportDimensions.width - scrollbarWidth;

                var columnMaxWidth = layout._getColumnWidthInPixel(viewportDimensions);
                var estimatedNumberOfColumnsFloat = (viewportDimensionsWidth - layout.gutter) / (columnMaxWidth + layout.gutter);
                var numberOfColumns = Math.max(Math.round(estimatedNumberOfColumnsFloat), 1);
                var columnWidth = Math.floor((viewportDimensionsWidth - (numberOfColumns + 1) * layout.gutter) / numberOfColumns);
                if (columnWidth > columnMaxWidth) {
                    numberOfColumns++;
                    // We must recompute the column width
                    columnWidth = Math.floor((viewportDimensionsWidth - (numberOfColumns + 1) * layout.gutter) / numberOfColumns);
                }
                // Update the layout members
                layout._columnWidth = columnWidth;
                layout._numberOfColumns = numberOfColumns;

                //console.log('numberOfColumns : ' + numberOfColumns + ' viewportDimensionsWidth: ' + viewportDimensionsWidth + ' columnMaxWidth:' + columnMaxWidth + ' gutter:' + layout.gutter + ' columnWidth:' + columnWidth);

                var currentRowID = 0,
                    currentColumnID = 0,
                    sectionsBefore = 0,
                    sectionIndex = 0,
                    previousIsSection = false;
                this.collectionView.model.forEach(function(cellModel, cellID) {
                    var isSection = layout.isSectionAt(cellID);

                    if (isSection) {
                        layout._listOfSections.push({
                            cellID: cellID
                        });
                        currentColumnID = 0;
                        layout._listOfSectionsReverseIndexes[cellID] = sectionIndex;
                        sectionIndex++;

                        if (!previousIsSection && (currentRowID > 0)) {
                          currentRowID++;
                        }
                    }

                    if (!isSection) {
                        if (currentColumnID > numberOfColumns - 1) {
                            currentColumnID = 0;
                            currentRowID++;
                        }
                    }

                    //console.log('cellID(' + cellID + ') isSection: ' + isSection + ' sectionsBefore: ' + sectionsBefore + ' coordinates(' + currentRowID + ', ' + currentColumnID + ') numberOfColumns:' + numberOfColumns);

                    layout._listOfItemsInfos.push({
                        sectionsBefore: sectionsBefore,
                        coordinates: {
                            rowID: currentRowID,
                            columnID: currentColumnID
                        }
                    });

                    if (!isSection) {
                        currentColumnID++;
                    }

                    if (isSection) {
                        currentRowID++;
                        currentColumnID = 0;
                        sectionsBefore++;
                    }
                    previousIsSection = isSection;
                });

                this._parent();
            },


            getCellCoordinatesAt: function(cellID) {
                var pos;
                if (this._listOfSections.length === 0) {
                    pos = this._parent(cellID);
                } else {
                    pos = this._listOfItemsInfos[cellID].coordinates;
                }
                return pos;
            },


            _getPositionForCellAt: function(cellID) {
                var pos;
                var coords = this.getCellCoordinatesAt(cellID);
                var numberOfSectionsBefore = this._listOfItemsInfos[cellID].sectionsBefore;

                if (this.isSectionAt(cellID)) {
                    pos = {
                        left: this.gutter
                    };
                } else {
                    pos = {
                        left: this._parent(cellID).left
                    };
                }

                pos.top = (coords.rowID - numberOfSectionsBefore) * (this._getRowHeight() + this.gutter) + (numberOfSectionsBefore * (this.sectionHeight + this.gutter)) + this.gutter;

                return pos;
            },

            getPositionForCellAt: function(cellID) {
                var pos = this._parent(cellID);

                if (this.isCellSyncedAt(cellID)) {
                    pos.top = 0;
                } else {
                    var previousSectionID = this._listOfSectionsReverseIndexes[this.__currentStackedSection] - 1;
                    if (this.__currentPreviousStackedSection === cellID && this.__currentPreviousStackedSection < this.__currentStackedSection) {
                        pos.top = this._getPositionForCellAt(this.__currentStackedSection).top - this.getDimensionsForCellAt(cellID).height;
                    }
                }

                //console.log('getPositionForCellAt(' + cellID + ') name : ' + this.collectionView.model[cellID].getLabel() + ' pos = (' + pos.left + ', ' + pos.top + ')');

                return pos;
            },

            getDimensionsForCellAt: function(cellID) {
                if (this.isSectionAt(cellID)) {
                    return {
                        width: this._numberOfColumns * this._getColumnWidth() + (this._numberOfColumns) * this.gutter,
                        height: this.sectionHeight
                    };
                } else {
                    return this._parent(cellID);
                }
            },

            getContentDimensions: function() {
                var viewportDimensions = this.collectionView.getViewportDimensions();
                var lastCellID = this.collectionView.model.length - 1;
                var lastCellPosition = this.getPositionForCellAt(lastCellID);
                var lastCellDimensions = this.getDimensionsForCellAt(lastCellID);

                var scrollbarWidth = UWA.Utils.Client.getScrollbarWidth() > 0 ? (UWA.Utils.Client.getScrollbarWidth() - 2) : 0;
                var contentDimensions, width;

                if (this._listOfSections && this._listOfSections.length > 0) {
                    contentDimensions = {
                        height: lastCellPosition.top + this.gutter + lastCellDimensions.height + this.gutter,
                        width: this._numberOfColumns * (this._getColumnWidth() + this.gutter) + this.gutter
                    };
                    width = contentDimensions.height > viewportDimensions.height ? (viewportDimensions.width - scrollbarWidth) : viewportDimensions.width;

                    return {
                        width: width,
                        height: contentDimensions.height
                    };
                } else {
                    contentDimensions = {
                        height: lastCellPosition.top + this.gutter + lastCellDimensions.height + this.gutter,
                        width: lastCellPosition.left + this.gutter + lastCellDimensions.width + this.gutter,
                    };
                    width = contentDimensions.height > viewportDimensions.height ? (viewportDimensions.width - scrollbarWidth) : viewportDimensions.width;

                    if (this.direction === 'vertical') {
                        return {
                            width: width,
                            height: contentDimensions.height
                        };
                    } else {
                        var height = contentDimensions.width > viewportDimensions.width ? (viewportDimensions.height - scrollbarWidth) : viewportDimensions.height;
                        return {
                            width: contentDimensions.width,
                            height: height
                        };
                    }
                }
            },

            _computeMinCellID: function() {
                var viewportDimensions = this.collectionView.getViewportDimensions();
                var scrollerPosition = this.collectionView.getScrollerPosition();

                var props;
                if (this.direction === 'vertical') {
                    props = {
                        pos: 'top',
                        scrollPos: 'y',
                        size: 'height'
                    };
                } else {
                    props = {
                        pos: 'left',
                        scrollPos: 'x',
                        size: 'width'
                    };
                }

                var minCellID = 0;
                if (this._getPositionForCellAt(minCellID)[props.pos] <= scrollerPosition[props.scrollPos]) {
                    while (minCellID < this.collectionView.model.length - 1 && this._getPositionForCellAt(minCellID)[props.pos] < scrollerPosition[props.scrollPos]) {
                        minCellID++;
                    }
                    minCellID = Math.max(0, minCellID - this._numberOfColumns);
                } else {
                    if (this._getPositionForCellAt(minCellID)[props.pos] > scrollerPosition[props.scrollPos]) {
                        while (minCellID > 0 && this._getPositionForCellAt(minCellID)[props.pos] > scrollerPosition[props.scrollPos]) {
                            minCellID--;
                        }
                    }
                }

                return minCellID;

            },

            getListOfVisibleCellsInViewport: function(options) {

                var layout = this;

                var scrollDeltaTop = layout.collectionView.getScrollerDeltaPosition().y;
                var processedCellID = {};

                var parentRender = options.render;
                options.render = function(cellID) {
                    var top = layout._getPositionForCellAt(cellID).top;
                    var y = layout.collectionView.getScrollerPosition().y;

                    processedCellID[cellID] = true;



                    if (layout.isSectionAt(cellID)) {

                        if (scrollDeltaTop > 0) {
                            if (top < y + layout.getDimensionsForCellAt(layout.__currentStackedSection).height) {
                                if (cellID > layout.__currentStackedSection && layout.__currentStackedSection !== layout.__currentPreviousStackedSection) {
                                    layout.__currentPreviousStackedSection = layout.__currentStackedSection;
                                    layout.__currentStackedSection = cellID;
                                }
                            }
                        } else {
                            if (layout._getPositionForCellAt(layout.__currentStackedSection).top - layout.getDimensionsForCellAt(layout.__currentStackedSection).height > y) {
                                if (cellID < layout.__currentStackedSection && layout.__currentStackedSection !== layout.__currentPreviousStackedSection) {
                                    layout.__currentPreviousStackedSection = layout.__currentStackedSection;
                                    layout.__currentStackedSection = cellID;
                                }
                            }
                        }


                        // console.log(layout.__currentPreviousStackedSection, layout.__currentStackedSection);

                    } else {
                        var correspondingSectionIndex = layout._listOfItemsInfos[cellID].sectionsBefore - 1;
                        if (correspondingSectionIndex > -1) {
                            var correspondingSectionCellID = layout._listOfSections[correspondingSectionIndex].cellID;

                            if (processedCellID[correspondingSectionCellID] === undefined) {
                                options.render(correspondingSectionCellID);
                            }
                        }
                    }
                    parentRender.call(this, cellID);
                };

                if (layout.__currentPreviousStackedSection > -1) {
                    parentRender.call(this, layout.__currentPreviousStackedSection);
                }
                if (layout.__currentStackedSection !== undefined) {
                    parentRender.call(this, layout.__currentStackedSection);
                }

                this._parent(options);

            },

            _isPreviousSection: function(cellID) {
                var previousSectionID = this._listOfSectionsReverseIndexes[this.__currentStackedSection] - 1;
                return previousSectionID >= 0 && previousSectionID === cellID;
            },

            _getPreviousSectionID: function() {
                var previousSectionID = this._listOfSectionsReverseIndexes[this.__currentNextStackedSection] - 1;
                if (previousSectionID > -1) {
                    return this._listOfSections[previousSectionID].cellID;
                }
            },

            isCellSyncedAt: function(cellID) {
                var isVisible = this._getPositionForCellAt(this.__currentStackedSection).top >= this.collectionView.getScrollerPosition().y;
                var bool = this.isSectionAt(cellID) && this.__currentStackedSection === cellID && !isVisible;
                return bool;
            },

            isCellLayoutValidAt: function(cellID) {
                return true;
            },

            getCssClassesForCellAt: function() {
                return '';
            },

            getLayoutStylesForCellAt: function(cellID) {
                var layoutStyles = this._parent(cellID);
                layoutStyles.zIndex = this.isSectionAt(cellID) ? (1000000 + cellID) : '';
                return layoutStyles;
            },

            getLayoutAttributesForCellAt: function(cellID) {
                var layoutAttributes = this._parent(cellID);

                layoutAttributes.isCurrent = this.__currentStackedSection === cellID;
                layoutAttributes.isSection = this.isSectionAt(cellID);
                layoutAttributes.isStacked = this.isCellSyncedAt(cellID);
                return layoutAttributes;
            }
        });


        return CollectionViewSectionGridLayout;
    });

/**
 * @licence Copyright 2006-2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0
 * @access private
 */
define('DS/CollectionViewSample/CollectionViewSample', [
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXStandardActionbar/js/ENOXStandardActionbar',
    'DS/ENOXCollectionView/ENOXCollectionView',
    'DS/CollectionViewSample/CollectionViewSampleUtils',
    'DS/CollectionViewSample/ENOXCollectionViewConfigurableAttributes/ENOXCollectionViewConfigurableAttributes',
    'DS/CollectionViewSample/ENOXCollectionViewAdvancedFilter/ENOXCollectionViewAdvancedFilter',
    'DS/TreeModel/TreeDocument',
    'DS/TreeModel/TreeNodeModel',
    'css!DS/CollectionViewSample/CollectionViewSample.css'
], function (ModelEvents, ENOXStandardActionbar, ENOXCollectionView, CollectionViewSampleUtils, ConfigurableAttributes, ENOXCollectionViewAdvancedFilter, TreeDocument, TreeNodeModel) {
    'use strict';

    var CollectionViewSample = {

        onLoad : function (container) {
            if (container === undefined || container === null) {
                container = widget.body;
            }
            var treeDocument, collectionView, attributesSelector, advancedFilter, currentViewId = 'base';
            var modelEvents = new ModelEvents();
            container.empty();

            /**  Create two container overlapping in position absolute */
            var containerCollectionView = document.createElement('div');
            containerCollectionView.classList.add('container-enox-collection-view');
            container.appendChild(containerCollectionView);

            /** Creation of ENOXActionBar */
            var containerDiv = UWA.createElement('div', {'id' : 'containerDiv', 'styles' : {'height' : 'inherit', 'width' : 'inherit'}});
            var actionBarOptions = {
                showItemCount : false,
                searchOptions : {
                    layout : 'inline'
                },
                sortOptions :{
                    attributes:[
                        {id: 'state', text: 'State', selected: true},
                    ],
                    order : 'ASC'
                },
                actions : [{
                    id: 'resize',
                    text: 'Resize',
                    fonticon: 'resize-small',
                    disable: false,
                    handler: function () {
                        //switchShownAttributes(treeDocument);
                        collectionView.toggleMinified();
                    }
                }, {
                    id: 'groupbyeffectivity',
                    text: 'Group by effectivity',
                    fonticon: 'legal',
                    disable: false,
                    handler: function () {
                        groupBySecondaryAttribute(treeDocument);
                    }
                }, {
                    id: 'openattributesconfigurator',
                    text: 'Select shown attributes',
                    fonticon: 'zoom-selected',
                    disable: false,
                    handler: function () {
                        if (attributesSelector === undefined || attributesSelector === null) {
                            attributesSelector = new ConfigurableAttributes();
                            var localModelEvents = attributesSelector.init();
                            localModelEvents.subscribe({event: 'attributes-selected'}, function (data) {
                                // Create a custom content cell mapping
                                collectionView.customCellContentMapping = function (comp, cellInfos) {
                                    comp.disabled = cellInfos.cellModel.options.data.disabled;
                                    comp.shading = cellInfos.cellModel.options.data.shading;
                                    comp.isSelected = cellInfos.cellModel.options.data.isSelected;
                                    comp.isActive = cellInfos.cellModel.options.data.isActive;
                                    comp.thumbnail = cellInfos.cellModel.options.data.thumbnail;
                                    comp.typeIcon = cellInfos.cellModel.options.data.typeIcon;
                                    comp.title = cellInfos.cellModel.options.data.title;
                                    comp.version = cellInfos.cellModel.options.data.version;
                                    comp.primaryAttribute = (data[0].hideAttributeName) ? cellInfos.cellModel.options.data._allAttributes[data[0].index].value : cellInfos.cellModel.options.data._allAttributes[data[0].index];
                                    comp.secondaryAttribute = (data[1].hideAttributeName) ? cellInfos.cellModel.options.data._allAttributes[data[1].index].value : cellInfos.cellModel.options.data._allAttributes[data[1].index];

                                    var shownAttributes = [];
                                    data[2].forEach(function (idx) {
                                    	shownAttributes.push(cellInfos.cellModel.options.data._allAttributes[idx]);
                                    });

                                    comp.attributes = shownAttributes;
                                };
                                collectionView.grid.invalidateLayout();

                                attributesSelector.hide();
                            });
                        } else {
                            attributesSelector.show();
                        }

                    }
                }, {
                	id: 'advancedfilter',
                	text: 'Advanced filter',
                	fonticon: 'filter',
                	disable: false,
                	handler: function () {
                		if (advancedFilter === undefined || advancedFilter === null) {
                			advancedFilter = new ENOXCollectionViewAdvancedFilter();
                            var localModelEvents = advancedFilter.init();
                            localModelEvents.subscribe({event: 'advanced-filtering-criteria-changed'}, function (data) {
                            	treeDocument.prepareUpdate();
                            	treeDocument.getChildren().forEach(function (node) {
                            		if (!node.options.data.isSection) {    // Don't filter section tile
                                        var primaryAttribute = node.options.data.primaryAttribute.value || node.options.data.primaryAttribute;

                                        if (data.indexOf(primaryAttribute) !== -1) {
                                            node.show();
                                        } else {
                                            node.hide();
                                        }
                            		}
                                });
                            	treeDocument.pushUpdate();
                            	advancedFilter.hide();
                            });
                		} else {
                			advancedFilter.show();
                		}
                	}
                }],
                parentContainer : containerDiv,

                onSearch : function (d) {
                    debouncedFilterAndUpdateView(treeDocument, d.searchValue);
                },
                onSort : function (data) {
                }
            };
            new ENOXStandardActionbar(actionBarOptions);
            containerDiv.inject(container);

            treeDocument = new TreeDocument({
                useAsyncPreExpand: true
            });
            treeDocument.addChild(CollectionViewSampleUtils.createExpandableTileViewData());
            treeDocument.addChild(CollectionViewSampleUtils.createBaseTileViewData());
            collectionView = new ENOXCollectionView(containerCollectionView);
            collectionView.init(treeDocument, modelEvents);

            treeDocument.onPreExpand(function (modelEvents) {
            	console.log(modelEvents.data.nodeModel.options.data);
            	modelEvents.target.preExpandDone();
            });

            /*setTimeout(function () {
                treeDocument.prepareUpdate();
                treeDocument.addChild(new TreeNodeModel({
                    data: {
                        isSelected: false,
                        isActive: false,
                        title: 'Propeller Red T000',
                        version: 'v375',
                        primaryAttribute: 'Primary attribute TST',
                        attributes: [
                            {name: 'Owner', value: 'Brad SPACEY'}
                        ],
                        secondaryAttribute: {
                            name: 'Name Test',
                            value: 'Value Test'
                        }
                    }
                }), 2);
                treeDocument.pushUpdate();
            }, 2000);*/
        }
    };

    /** Filter model */
    function filterAndUpdateView(treeDoc, searchValue) {
        treeDoc.prepareUpdate();

        treeDoc.getChildren().forEach(function (node) {
            var primaryAttribute = node.options.data.primaryAttribute.value || node.options.data.primaryAttribute;

            if (primaryAttribute.indexOf(searchValue) != -1 || node.options.data.title.indexOf(searchValue) != -1) {
                node.show();
            } else {
                node.hide();
            }
        });

        treeDoc.pushUpdate();
    }
    var debouncedFilterAndUpdateView = debounce(filterAndUpdateView, 500);

    /** Debounce method (David Walsh one) */
    function debounce(func, wait, immediate) {
        var timeout;
        return function() {
            var context = this, args = arguments;
            var later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    }

    /** Group a tree document by secondary attribute */
    function groupBySecondaryAttribute(treeDoc) {
        var nodes = treeDoc.getChildren();
        var newnodes = [];

        var sortedNodes = nodes.reduce(function(groups, item) {
        	if (!item._isHidden) {    // Only group currently shown item
                var val = item.options.data.secondaryAttribute || 'Unclassified';
                groups[val] = groups[val] || [];
                groups[val].push(item);
        	}
            return groups;
         }, {});

        treeDoc.prepareUpdate();
        treeDoc.removeRoots();
        for (var groupname in sortedNodes) {
            newnodes.push(new TreeNodeModel({
                data: {
                    isSection: true,
                    name: groupname,
                    quantity: sortedNodes[groupname].length
                }
            }));

            for (var i = 0; i < sortedNodes[groupname].length; i++) {
                newnodes.push(sortedNodes[groupname][i]);
            }
        }
        treeDoc.addChild(newnodes);
        treeDoc.pushUpdate();
    }

    /** Switch shown attributes */
    function switchShownAttributes(treeDoc) {
        treeDoc.prepareUpdate();
        treeDoc.getChildren().forEach(function (nodeModel) {
            var oldAttr = nodeModel.options.data.attributes;
            nodeModel.options.data.attributes = nodeModel.options.data.hiddenAttributes;
            nodeModel.options.data.hiddenAttributes = oldAttr;
        });
        treeDoc.pushUpdate();
    }

    return CollectionViewSample;
});

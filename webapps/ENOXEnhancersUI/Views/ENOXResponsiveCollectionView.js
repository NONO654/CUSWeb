define('DS/ENOXEnhancersUI/Views/ENOXResponsiveCollectionView', [
    'UWA/Core',
    'UWA/Promise',
    'DS/TreeModel/TreeDocument',
    'DS/TreeModel/TreeNodeModel',
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXEnhancers/Utils/Helper',
    'DS/ENOXEnhancersUI/Utils/Helper',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXEnhancersUI/Constants/Constants',
    'DS/UIKIT/IconDropdown',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI.css'
  ],
  function (
    UWACore,
    UWAPromise,
    TreeDocument,
    TreeNodeModel,
    ModelEvents,
    Helper,
    UIHelper,
    Constants,
    EnhancersUIConstants,
    IconDropdown
  ) {
    'use strict';
    var ResponsiveCollectionView = function () {
      this._name = 'ResponsiveCollectionView';
    };

    function _prepareTreedocModelContent(that, data) {
      var viewForCustomInfoOverModels = that.options.currentView.id;
      var tree = that.responsiveCollectionView.options.treeDocument ||
        that.responsiveCollectionView.TreedocModel;
      tree.empty();
      var collection = data._models || data.data || data;
      that.modelEvents.publish({
        event: 'view-change-count-update',
        data: collection
      });

      var headers = that.responsiveCollectionView.options.columns,
        models = [];

      collection.forEach(function (item) {
        var modelData = item._attributes;

        if (!headers) {
          var actionsModels = item.actions,
            statusbarIcons = [],
            statusbarIconsTooltips = [],
            statusbarEvents = [];
          actionsModels.forEach(function (actionItems) {
            statusbarIcons.push(actionItems.icon);
            statusbarIconsTooltips.push(actionItems.title);
            statusbarEvents.push(actionItems.events);
          });
          var node = {
            label: modelData.name,
            icons: [modelData.icon],
            model: item,
            thumbnail: modelData.image,
            subLabel: modelData.subtitle,
            statusbarIcons: statusbarIcons,
            statusbarIconsTooltips: statusbarIconsTooltips,
            statusbarEvents: statusbarEvents,
            contextualMenu: [],
            propertiesList: modelData.propertiesList || [],
            data: modelData,
            renderTo: that.options.renderData,
            idCard: that.options.idCard
          };
        } else {
          var node = {
            badges: {},
            grid: {
              'physicalid': modelData.id
            },
            data: modelData,
            renderTo: that.options.renderData,
            idCard: that.options.idCard
          };
          headers.forEach(function (header) {
            if (header.dataIndex === EnhancersUIConstants.ROW_TREE) {
              node.label = modelData[header.id];
              node.icons = [modelData['icon']];
            } else if (header.type === 'date' && !Helper.isObjectEmpty(header.formatter)) {
              node.grid[header.dataIndex] = Helper.getFormattedDate(modelData[header.id],
                header.formatter);
            } else if (header.type === 'person') {

              node.grid[header.dataIndex] = modelData[header.id];
              header.onCellRequest = function (event) {
                if (!event.isHeader) {
                  var div = event.cellView.elements.container,
                    personImg = UWA.createElement('span', {
                      class: 'fonticon fonticon-user-alt'
                    });
                  div.empty();
                  personImg.inject(div);
                  var personUser = UWA.createElement('span', {
                    html: div.title
                  });
                  personUser.inject(div);
                }

              }

            } else if (header.dataIndex === "current") {
              node.grid[header.dataIndex] = modelData[header.id];
              header.onCellRequest = function (event) {
                var div = event.cellView.elements.container;
                div.empty();
                var stateSpan = UWACore.createElement('span', {
                  html: div.title
                });
                stateSpan.inject(div);
                var classname = div.title.toLowerCase();
                if (classname.contains(" ")) {
                  classname = classname.replaceAll(" ", "");
                }
                stateSpan.addClassName("doc-control-" + classname);
              };
            } else if (header.dataIndex === "ActionItemIndex") {
              var itemarrayforAction = [],
                tempOptions = that.options,
                tempModelData = modelData;
              var iconbardata = header.iconbar;
              iconbardata.forEach(function (item) {
                var individualIconData = {
                  fonticon: item.fonticon,
                  text: item.text,
                  handler: function (e, i) {
                    require([item.require],
                      function (requireData) {
                        var dataOptions = [];
                        dataOptions.e = e;
                        dataOptions.options = tempOptions;
                        dataOptions.ModelData = tempModelData;
                        dataOptions.indexofClick = i;
                        dataOptions.options = tempOptions;
                        dataOptions.ModelData = tempModelData;
                        var requireData = new requireData();
                        requireData[item.methodName](dataOptions);
                      });
                  }
                }
                itemarrayforAction.push(individualIconData);

              });

              header.onCellRequest = function (nodeInfos) {
                if (!nodeInfos.isHeader) {
                  var container = new UWA.Element('div', {
                    'class': 'fonticon fonticon-chevron-down fonticon-2x',
                    'styles': {
                      'color': '#b4b6ba',
                      'display': 'list-item'
                    }
                  });

                  new IconDropdown({
                    target: container,
                    items: itemarrayforAction
                  });
                  nodeInfos.cellView.getContent().setContent(container);
                }
              };
            } else {
              node.grid[header.dataIndex] = modelData[header.id];
            }
          });
        }
        var nodeModel = new TreeNodeModel(node);
        nodeModel.onSelect(function (event, args) {
          that.modelEvents.publish({
            event: 'onSelect',
            data: {
              event: event,
              args: args,
              renderTo: that.options.renderData
            }
          });
        });
        models.push(nodeModel);
      });

      tree.prepareUpdate();
      models.forEach(function (model) {
        tree.addRoot(model);
      });
      tree.pushUpdate();
      that.isCollectionEmpty = false;
      if (collection == null || collection == undefined || collection.length == 0) {
        that.isCollectionEmpty = true;
      }
      return data;
    }

    function _onStatusBarEvents(that, args, container) {
      var cellInfos = args.cellInfos;
      var index = args.clickedIconIndex;
      var cellView = cellInfos ? cellInfos.cellView : undefined;
      var contentView = cellView ? cellView.contentView : undefined;
      var nodeModel = cellInfos ? cellInfos.cellModel : undefined;
      if (contentView && nodeModel && index >= 0 &&
        index < contentView.statusbarIcons.length) {
        var events = nodeModel.options.statusbarEvents[index] || [],
          eventSelected = {};
        events.forEach(function (item) {
          item["onStatusbarIconPointerDown"] && UWA.is(item[
              "onStatusbarIconPointerDown"], 'function') ?
            eventSelected = item : Constants.EMPTY_STRING;
        });

        var promise = new UWAPromise(function (resolve, reject) {
          eventSelected["onStatusbarIconPointerDown"](cellInfos, index, resolve,
            reject);
        });

        promise.then(function (result) {
          result.alldata = that.responsiveCollectionView.TreedocModel.getRoots();
          that.modelEvents.publish({
            event: 'content-remove-count-update',
            data: result
          });
          if (result.title || result.subtitle) {
            UIHelper.showNotification(Constants.INFO, result.title || Constants.EMPTY_STRING,
              result.subtitle || Constants.EMPTY_STRING, '', false);
          }
        }, function (error) {
          var errorMessage = error || Helper.getMessage({
            key: '0001'
          });
          UIHelper.showNotification(Constants.ERROR, errorMessage, '', '', false);
          throw new Error(errorMessage);
        });
      }
    }

    ResponsiveCollectionView.prototype.init = function (options) {
      var that = this;
      that.options = options || {};
      that.modelEvents = options.modelEvents ? options.modelEvents : new ModelEvents();
    }

    function _getView(view) {
      if (view === 'smalltile') {
        return 'DS/CollectionView/ResponsiveTilesCollectionView';
      } else if (view === 'thumbnail') {
        return 'DS/CollectionView/ResponsiveThumbnailsCollectionView';
      } else if (view === 'largetile') {
        return 'DS/CollectionView/ResponsiveLargeTilesCollectionView';
      } else if (view === 'rowview') {
        return 'DS/Tree/TreeListView';
      } else {
        //TODO need to look in supporting custom view
        throw new Error('The view provided is not currently supported');
      }
    }

    ResponsiveCollectionView.prototype.render = function (data) {
      var that = this,
        view = that.options.currentView.id,
        viewLibrary = _getView(view);

      var responsiveContainer = UWACore.createElement('div', {
        class: 'responsive-collection-view',
        styles: {
          height: '100%'
        }
      });

      var renderingcontainer = that.options.renderTo || Constants.EMPTY_STRING;

      if (renderingcontainer) {
        responsiveContainer.inject(renderingcontainer);
      }
      responsiveContainer.empty();
      UIHelper.loadingON('Loading...', responsiveContainer);
      require([viewLibrary], function (viewClass) {
        var responsiveCollectionView;
        var treeDocument = new TreeDocument({
          useAsyncPreExpand: true
        });
        if (view === 'rowview') {
          that.options = UWA.merge(that.options, viewClass.STANDARD_CHECKBOXES);
          var headers = that.options.currentView ? that.options.currentView.headers :
            Constants.EMPTY_JSON_ARRAY;
          responsiveCollectionView = new viewClass({
            treeDocument: treeDocument,
            columns: headers
          });
        } else {
          responsiveCollectionView = new viewClass({
            model: treeDocument
          });
        }

        responsiveCollectionView.selectionBehavior = {
          unselectAllOnEmptyArea: true,
          toggle: true,
          canMultiSelect: false,
          enableShiftSelection: false,
          enableListSelection: false,
          enableFeedbackForActiveCell: true
        };

        that.responsiveCollectionView = responsiveCollectionView;
        _prepareTreedocModelContent(that, data.data);

        if (that.isCollectionEmpty) {
          var emptyCollection = new UWA.Element('div', {
            'class': 'empty-collection',
            'html': 'No Result Found'
          });
          emptyCollection.inject(responsiveContainer);
        } else {
          responsiveCollectionView.inject(responsiveContainer);
        }

        UIHelper.loadingOFF(responsiveContainer);

        // responsiveCollectionView.getManager().addEventListener('click', function(e,
        //   cellInfos)
        // {
        //   console.log("ROW_ID-COLUMN_ID: ", cellInfos.data.rowID, cellInfos.data.columnID);
        // });
        responsiveCollectionView.onStatusbarIconPointerDown = function (args) {
          _onStatusBarEvents(that, args, responsiveContainer);
        }

        return responsiveCollectionView;
      });
    }

    return ResponsiveCollectionView;

  });

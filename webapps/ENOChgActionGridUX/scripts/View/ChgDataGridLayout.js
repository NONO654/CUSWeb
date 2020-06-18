define("DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout", [
  "DS/ENOChgActionGridUX/scripts/View/ChgChangeActionDataGridView",
  "DS/ENOChgActionGridUX/scripts/Utils/ChgChangeActionUtil",
  "DS/ENOChgActionGridUX/scripts/Model/ChgChangeDataGridModel",
  "DS/ENOChgServices/scripts/services/ChgInfraService",
  "DS/ENOChgServices/scripts/services/ChgDataService",
  "DS/ENOChgServices/scripts/services/ChgDataProcess",
  "DS/UIKIT/Mask",
  "DS/ENOChgActionGridUX/scripts/View/ChgTileViewLayout",
  "DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar",
  'DS/TagNavigatorProxy/TagNavigatorProxy',
  'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS'
], function (
  ChangeActionDataGridView,
  ChgChangeActionUtil,
  ChgChangeDataGridModel,
  ChgInfraService,
  ChgDataService,
  ChgDataProcess,
  Mask,
  ChgTileViewLayout,
  ChgDataGridViewToolbar,
  TagNavigatorProxy,
  APP_NLS
) {
  "use strict";
  var taggerProxy = null;
  var facets = null;
  var ChgDataGridLayout = {
    /*
     * Method to initialize Data Grid Layout
     */

    create: function (option) {
      var that = this;
      var options = {};
      // set target location
      options = UWA.merge(options, option); // widget.body;

      Mask.mask(options.target);
      //getting the column and setting inside the options
      options.columns = ChgChangeActionUtil.getColumns();
      // creating the tree document model for data grid
      options.treeDocument = new ChgChangeDataGridModel().createTreeDocument();
      //options.sortModel = [{ dataIndex: "severity", sort: "desc" }];
      that.ChglayoutModel = options.treeDocument;
      var caGridView = new ChangeActionDataGridView(options);
      that.caGridView = caGridView;

      //hide back button in toolbar on initial load
      var backIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("back");
      if (backIcon) {
        backIcon.updateOptions({
          visibleFlag: false
        });
      }

      // calling getCASummary to get the list of Change Actions
      ChgDataService.getCASummary().then(
        function (CASummaryList) {
          var result = ChgDataProcess.processCASummaryList(CASummaryList);
          var processedCAList = result.processData;
          var memberList = result.memberList;
          ChgDataService.getUserFullName(processedCAList, memberList).then(
            function (processedListWithName) {
              // Processing the fullname for CA list details
              var processedCAListWithFullName = ChgDataProcess.processedListWithName(
                processedListWithName
              );
              var objList = ChgDataProcess.makeObjList(processedCAListWithFullName);
              ChgDataService.getTypeIcon(processedCAListWithFullName, objList).then(
                function (processedListWithNamewithIcon) {
                  var processedCAListWithFullNameIcon = processedListWithNamewithIcon.processedCAListWithFullName;
                  // creating the mao fot type and icon url
                  ChgDataProcess.createIconMap(processedListWithNamewithIcon.iconDetails);
                  // loading the list inside the data grid view
                  new ChgChangeDataGridModel().loadData(
                    options.treeDocument,
                    processedCAListWithFullNameIcon
                  );
                  caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "desc" }];
                  caGridView.reapplySortModel();
                  //Adding Events on toolbar
                  caGridView.setListnersOnToolbar();

                  if (processedCAListWithFullNameIcon.length == 0) {
                    ChgTileViewLayout.showEmptyView();
                  } else {
                    ChgTileViewLayout.hideEmptyView();
                  }

                  if (widget.body.getDimensions().width <= 400) {
                    ChgTileViewLayout.changeView();
                  } else {
                    that.changeView();
                  }

                  /*         var view = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
                           if(view){
                             view.onAttributeChange(function(model){
                               if(model.data.changedAttributeValue == "List"){
                                  ChgDataGridLayout.changeView();
                               } else if(model.data.changedAttributeValue == "Tile"){
                                  ChgTileViewLayout.changeView();
                               }
                             });
                           }*/

                  // removing the spinner from data grid view
                  Mask.unmask(options.target);
                },
                function (error) {
                  return Promise.reject(error);
                }
              );
            },
            function (error) {
              return Promise.reject(error);
            }
          );
        },
        function (error) {
          return Promise.reject(error);
        }
      );
    },

    createIndexedView: function (option) {
      var that = this;
      var options = {};
      // set target location
      options = UWA.merge(options, option); // widget.body;

      Mask.mask(options.target);
      //getting the column and setting inside the options
      options.columns = ChgChangeActionUtil.getColumns();
      // creating the tree document model for data grid
      options.treeDocument = new ChgChangeDataGridModel().createTreeDocument();

      that.ChglayoutModel = options.treeDocument;
      var caGridView = new ChangeActionDataGridView(options);
      that.caGridView = caGridView;
      var backIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("back");
      if (backIcon) {
        backIcon.updateOptions({
          visibleFlag: false
        });
      }
      ChgDataService.getCAFDData().then(
        function (CASummaryList) {
          var processedCAListIndexed = ChgDataProcess.processCAListIndexed(CASummaryList);
          new ChgChangeDataGridModel().loadDataIndexed(
            options.treeDocument,
            processedCAListIndexed
          );
          caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "desc" }];
          caGridView.reapplySortModel();
          //Adding Events on toolbar
          caGridView.setListnersOnToolbar();

          /*      if(processedCAListIndexed.length == 0){
                  ChgTileViewLayout.showEmptyView();
                } else {
                  ChgTileViewLayout.hideEmptyView();
                }*/

          if (widget.body.getDimensions().width <= 400) {
            ChgTileViewLayout.changeView();
          } else {
            that.changeView();
          }

          /*           var view = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
                     if(view){
                       view.onAttributeChange(function(model){
                         if(model.data.changedAttributeValue == "List"){
                            ChgDataGridLayout.changeView();
                         } else if(model.data.changedAttributeValue == "Tile"){
                            ChgTileViewLayout.changeView();
                         }
                       });
                     }*/

          //Set tagger in Indexed Data load.
          var taggerOptions = { "widgetId": widget.id, "filteringMode": "FilteringOnServer" };
          if (taggerProxy) {
            taggerProxy.die();
          }
          taggerProxy = TagNavigatorProxy.createProxy(taggerOptions);
          taggerProxy.addEvent('onFilterChange', function (e) {
            var refineFilter = taggerProxy.getCurrentFilter();
            ChgDataGridLayout.refreshGrid(e, refineFilter);
          });
          //Update tagger tags
          facets = CASummaryList.facets;
          taggerProxy.setTags(null, facets);

          // removing the spinner from data grid view
          Mask.unmask(options.target);
        },
        function (error) {
          return Promise.reject(error);
        }
      );
    },

    /*
     * Method to refresh the layout with required data
     */
    refreshLayout: function (data) {
      var chgLayoutModel = this.ChglayoutModel;
      ChgTileViewLayout.hideEmptyView();
      if (enoviaServerCAWidget.indexMode == "true") {
        new ChgChangeDataGridModel().updateNodeIndexed(chgLayoutModel, data);
      } else {
        // Updating the node inside the datagrid view
        new ChgChangeDataGridModel().updateNode(chgLayoutModel, data);
      }
    },
    /*
     * Method to refresh the View
   */
    refreshGrid: function (event, refine) {
      var divToMask = document.getElementById("outer-ca-div");
      Mask.mask(divToMask);
      if (enoviaServerCAWidget.indexMode == "true") {
        ChgDataService.getCAFDData(refine).then(
          function (CASummaryList) {
            var processedCAListIndexed = ChgDataProcess.processCAListIndexed(CASummaryList);
            //var memberList=ChgDataProcess.createMemberList(processedCAListIndexed);
            // ChgDataService.getUserFullName(processedCAListIndexed, memberList).then(
            //  function(processedListWithName) {

            ChgDataGridLayout.ChglayoutModel.empty();
            new ChgChangeDataGridModel().loadDataIndexed(ChgDataGridLayout.ChglayoutModel, processedCAListIndexed);
            ChgDataGridLayout.ChglayoutModel.unselectAll();
            //  caGridView.caDatagrid.sortModel = [{ dataIndex: "severity", sort: "desc" }];
            //  caGridView.reapplySortModel();
            ChgDataGridLayout.caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "desc" }];
            ChgDataGridLayout.caGridView.reapplySortModel();

            //Update tagger tags
            if (refine == "undefined" || refine == null) {
              taggerProxy.clearLocalFilter();
            }
            taggerProxy.setTags(null, CASummaryList.facets);

            Mask.unmask(divToMask);
          },
          function (error) {
            return Promise.reject(error);
          }
        );
      } else {
        ChgDataService.getCASummary().then(
          function (CASummaryList) {
            var result = ChgDataProcess.processCASummaryList(CASummaryList);
            var processedCAList = result.processData;
            var memberList = result.memberList;
            ChgDataService.getUserFullName(processedCAList, memberList).then(
              function (processedListWithName) {
                // Processing the fullname for CA list details
                var processedCAListWithFullName = ChgDataProcess.processedListWithName(
                  processedListWithName
                );
                var objList = ChgDataProcess.makeObjList(processedCAListWithFullName);
                ChgDataService.getTypeIcon(processedCAListWithFullName, objList).then(
                  function (processedListWithNamewithIcon) {
                    var processedCAListWithFullNameIcon = processedListWithNamewithIcon.processedCAListWithFullName;
                    // creating the mao fot type and icon url
                    ChgDataProcess.createIconMap(processedListWithNamewithIcon.iconDetails);

                    //emptying the model
                    ChgDataGridLayout.ChglayoutModel.empty();

                     // loading the list inside the data grid view
                    new ChgChangeDataGridModel().loadData(ChgDataGridLayout.ChglayoutModel, processedCAListWithFullNameIcon);
                    ChgDataGridLayout.ChglayoutModel.unselectAll();

                    if (processedCAListWithFullNameIcon.length == 0) {
                      ChgTileViewLayout.showEmptyView();
                    } else {
                      ChgTileViewLayout.hideEmptyView();
                    }
                    ChgDataGridLayout.caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "desc" }];
                    ChgDataGridLayout.caGridView.reapplySortModel();

                    Mask.unmask(divToMask);

                  },
                  function (error) {
                    return Promise.reject(error);
                  }
                );
              },
              function (error) {
                return Promise.reject(error);
              }
            );
          },
          function (error) {
            return Promise.reject(error);
          }
        );
      }
    },

    /*
       * Method to change view from Tile View to Grid View Layout
       */
    changeView: function () {
      ChgChangeActionUtil.changeView("GridView");
    },

    updateTitle: function (data) {
      var nodes = ChgDataGridLayout.ChglayoutModel.getChildren();
      for (var i = 0; i < nodes.length; i++) {
        var nodeId = nodes[i].options.grid.id;
        if (nodeId == data.id.slice(4, data.id.length)) {

          var dueDate = "-";
          if (nodes[i].options.grid.dueDate != null && nodes[i].options.grid.dueDate != undefined) {
            dueDate = nodes[i].options.grid.dueDate;
          }
          var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE + ": " + data.title + "\n" +
            APP_NLS.CHG_TOOLTIP_NAME + ": " + nodes[i].options.grid.name + "\n" +
            APP_NLS.CHG_TOOLTIP_SEVERITY + ": " + nodes[i].options.grid.severity + "\n" +
            APP_NLS.CHG_TOOLTIP_OWNER + ": " + nodes[i].options.grid.responsible + "\n" +
            APP_NLS.CHG_TOOLTIP_MATURITY + ": " + nodes[i].options.grid.maturity + "\n" +
            APP_NLS.CHG_TOOLTIP_DUEDATE + ": " + dueDate;

          nodes[i].updateOptions({
            label: data.title,
            grid: {
              title: data.title
            },
            customTooltip: customTooltip
          });
        }
      }
    },

    updateSeverity: function (data) {
      var nodes = ChgDataGridLayout.ChglayoutModel.getChildren();
      for (var i = 0; i < nodes.length; i++) {
        var nodeId = nodes[i].options.grid.id;
        if (nodeId == data.id.slice(4, data.id.length)) {
          var severityGrade = 0;
          var sevClass = "sevLow wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-low";
          var statusbarIcons = ["level-low"];
          var statusbarIconsTooltips = ["Low"];
          if (data.sev == "Medium") {
            severityGrade = 1;
            sevClass = "sevMed wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-medium";
            statusbarIcons = ["level-medium"];
            statusbarIconsTooltips = ["Medium"];
          } else if (data.sev == "High") {
            severityGrade = 2;
            sevClass = "sevHigh wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-level-high";
            statusbarIcons = ["level-high"];
            statusbarIconsTooltips = ["High"];
          }

          //severity
          var sevDiv = new UWA.Element("div", {});
          var sevContainer = new UWA.Element("div", {
            class: 'gridIconContainer'
          });
          var sevIcon = UWA.createElement('div', {
            class: sevClass
          });
          sevIcon.inject(sevContainer);
          var sev = UWA.createElement('span', {
            'class': 'gridIconName',
            html: data.sev
          });
          sevContainer.inject(sevDiv);
          sev.inject(sevDiv);

          var subLabel = nodes[i].options.grid.name + " | " + data.sev + " | " + nodes[i].options.grid.responsible;
          var dueDate = "-";
          if (nodes[i].options.grid.dueDate != null && nodes[i].options.grid.dueDate != undefined) {
            dueDate = nodes[i].options.grid.dueDate;
          }
          var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE + ": " + nodes[i].options.grid.title + "\n" +
            APP_NLS.CHG_TOOLTIP_NAME + ": " + nodes[i].options.grid.name + "\n" +
            APP_NLS.CHG_TOOLTIP_SEVERITY + ": " + data.sev + "\n" +
            APP_NLS.CHG_TOOLTIP_OWNER + ": " + nodes[i].options.grid.responsible + "\n" +
            APP_NLS.CHG_TOOLTIP_MATURITY + ": " + nodes[i].options.grid.maturity + "\n" +
            APP_NLS.CHG_TOOLTIP_DUEDATE + ": " + dueDate;

          nodes[i].updateOptions({
            subLabel: subLabel,
            grid: {
              severity: data.sev,
              severityGrade: severityGrade,
              sev: sevDiv.outerHTML
            },
            statusbarIcons: statusbarIcons,
            statusbarIconsTooltips: statusbarIconsTooltips,
            customTooltip: customTooltip
          });
        }
      }
    },

    updateMaturity: function (data) {
      var nodes = ChgDataGridLayout.ChglayoutModel.getChildren();
      for (var i = 0; i < nodes.length; i++) {
        var nodeId = nodes[i].options.grid.id;
        if (nodeId == data.id.slice(4, data.id.length)) {

          var dueDate = "-";
          if (nodes[i].options.grid.dueDate != null && nodes[i].options.grid.dueDate != undefined) {
            dueDate = nodes[i].options.grid.dueDate;
          }
          var desc = data.maturity + " | " + dueDate;
          var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE + ": " + nodes[i].options.grid.title + "\n" +
            APP_NLS.CHG_TOOLTIP_NAME + ": " + nodes[i].options.grid.name + "\n" +
            APP_NLS.CHG_TOOLTIP_SEVERITY + ": " + nodes[i].options.grid.severity + "\n" +
            APP_NLS.CHG_TOOLTIP_OWNER + ": " + nodes[i].options.grid.responsible + "\n" +
            APP_NLS.CHG_TOOLTIP_MATURITY + ": " + data.maturity + "\n" +
            APP_NLS.CHG_TOOLTIP_DUEDATE + ": " + dueDate;

          var stateGrade = 0;
          if (data.maturity == "In Work") {
            stateGrade = 1;
          } else if (data.maturity == "In Approval") {
            stateGrade = 2;
          } else if (data.maturity == "Approved") {
            stateGrade = 3;
          }

          nodes[i].updateOptions({
            description: desc,
            grid: {
              maturity: data.maturity,
              stateGrade: stateGrade
            },
            customTooltip: customTooltip
          });
        }
      }
    },

    updateDueDate: function (data) {
      var dueDate = "-";
      if (data.dueDate == "Unassigned") {
        data.dueDate = undefined;
      } else {
        var DATE_TAG_FORMAT = '%Y-%m-%d';
        data.dueDate = new UWA.Date(data.dueDate).strftime(DATE_TAG_FORMAT);
        dueDate = data.dueDate;
      }
      var nodes = ChgDataGridLayout.ChglayoutModel.getChildren();
      for (var i = 0; i < nodes.length; i++) {
        var nodeId = nodes[i].options.grid.id;
        if (nodeId == data.id.slice(4, data.id.length)) {

          var desc = nodes[i].options.grid.maturity + " | " + dueDate;
          var customTooltip = APP_NLS.CHG_TOOLTIP_TITLE + ": " + nodes[i].options.grid.title + "\n" +
            APP_NLS.CHG_TOOLTIP_NAME + ": " + nodes[i].options.grid.name + "\n" +
            APP_NLS.CHG_TOOLTIP_SEVERITY + ": " + nodes[i].options.grid.severity + "\n" +
            APP_NLS.CHG_TOOLTIP_OWNER + ": " + nodes[i].options.grid.responsible + "\n" +
            APP_NLS.CHG_TOOLTIP_MATURITY + ": " + nodes[i].options.grid.maturity + "\n" +
            APP_NLS.CHG_TOOLTIP_DUEDATE + ": " + dueDate;

          nodes[i].updateOptions({
            description: desc,
            grid: {
              dueDate: data.dueDate
            },
            customTooltip: customTooltip
          });
        }
      }
    },

    updateResponsibility: function (data) {
      var nodes = ChgDataGridLayout.ChglayoutModel.getChildren();
      for (var i = 0; i < nodes.length; i++) {
        var nodeId = nodes[i].options.grid.id;
        if (nodeId == data.id.slice(4, data.id.length)) {
          nodes[i].updateOptions({
            grid: {
              userRole: data.responsibility
            }
          });
        }
      }
    },

    sortBySeverity: function () {
      var caGridView = ChgDataGridLayout.caGridView;
      var view = ChgDataGridViewToolbar.toolbar.getNodeModelByID("sorting");
      var sortingIcon = ChgDataGridViewToolbar.sortingData.menu[0].fonticon.content;
      if (sortingIcon == "wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z") {
        ChgDataGridViewToolbar.sortingData.menu[0].fonticon.content = "wux-ui-3ds wux-ui-3ds-alpha-sorting-z-a";
        caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "asc" }];
      } else {
        ChgDataGridViewToolbar.sortingData.menu[0].fonticon.content = "wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z";
        caGridView.caDatagrid.sortModel = [{ dataIndex: "sev", sort: "desc" }];
      }

      caGridView.reapplySortModel();
      view.updateOptions({
        grid: {
          data: ChgDataGridViewToolbar.sortingData
        }
      });

    },

    sortByMaturity: function () {
      var caGridView = ChgDataGridLayout.caGridView;
      var view = ChgDataGridViewToolbar.toolbar.getNodeModelByID("sorting");
      var sortingIcon = ChgDataGridViewToolbar.sortingData.menu[1].fonticon.content;
      if (sortingIcon == "wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z") {
        ChgDataGridViewToolbar.sortingData.menu[1].fonticon.content = "wux-ui-3ds wux-ui-3ds-alpha-sorting-z-a";
        caGridView.caDatagrid.sortModel = [{ dataIndex: "maturity", sort: "asc" }];
      } else {
        ChgDataGridViewToolbar.sortingData.menu[1].fonticon.content = "wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z";
        caGridView.caDatagrid.sortModel = [{ dataIndex: "maturity", sort: "desc" }];
      }

      caGridView.reapplySortModel();
      view.updateOptions({
        grid: {
          data: ChgDataGridViewToolbar.sortingData
        }
      });
    },

    /*
     * Method to close ID Card on click of back icon and redirect to previous view
   */
    backToSummary: function () {
      var backIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("back");
      if (backIcon) {
        backIcon.updateOptions({
          visibleFlag: false
        });
      }

      var view = ChgChangeActionUtil.previousView;
      var icon = "";
      if (view == "Grid") {
        icon = "view-list";
        ChgDataGridLayout.changeView();
      } else {
        icon = "view-small-tile"
        ChgTileViewLayout.changeView();
      }

      var viewIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
      if (viewIcon) {
        viewIcon.updateOptions({
          grid: {
            semantics: {
              icon: {
                iconName: icon
              }
            }
          }
        });
      }

      ChgDataGridLayout.caGridView.backToSummary();
    },

    /*
     * Method to change data service from index to real
    */
    changeData: function () {
      var dataIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("data_service");
      if (dataIcon && dataIcon.options.grid.semantics.icon.iconName == "database-new") {
        dataIcon.updateOptions({
          grid: {
            semantics: {
              icon: {
                iconName: "database"
              }
            }
          },
          "tooltip": APP_NLS.CHG_TOOLTIP_INDEX_DATA
        });
        enoviaServerCAWidget.indexMode = "false";
        ChgDataGridLayout.refreshGrid();
      } else if (dataIcon && dataIcon.options.grid.semantics.icon.iconName == "database"){
        dataIcon.updateOptions({
          grid: {
            semantics: {
              icon: {
                iconName: "database-new"
              }
            }
          },
          "tooltip": APP_NLS.CHG_TOOLTIP_RECENT_DATA
        });
        enoviaServerCAWidget.indexMode = "true";
        ChgDataGridLayout.refreshGrid();
      }
    }

  };
  return ChgDataGridLayout;
});

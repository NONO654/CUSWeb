/*
 * @module 'DS/ENOChgActionGridUX/scripts/View/ChangeActionDataGridView'
 */

define("DS/ENOChgActionGridUX/scripts/View/ChgChangeActionDataGridView", [
  "UWA/Class/View",
  'DS/CoreEvents/ModelEvents',
  'DS/Core/PointerEvents',
  "DS/DataGridView/DataGridView",
  "DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar",
  "DS/ENOChgServices/scripts/services/ChgInfraService",
  "DS/ENOChgActionGridUX/scripts/View/ChgTweakerExpandInput",
  'DS/ENOChgActionGridUX/scripts/View/ChgCreateChangeAction',
  'DS/CollectionView/CollectionViewStatusBar',
  "i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS",
  'DS/CollectionView/ResponsiveTilesCollectionView',
  'DS/CollectionView/ResponsiveLargeTilesCollectionView',
  'DS/ENOChgActionGridUX/scripts/Utils/ChgChangeActionUtil',
  'DS/ENOChgActionGridUX/scripts/View/ChgTileViewLayout'
], function (
  View,
  ModelEvents,
  PointerEvents,
  DataGridView,
  ChgDataGridViewToolbar,
  ChgInfraService,
  ChgTweakerExpandInput,
  ChgCreateChangeAction,
  CollectionViewStatusBar,
  APP_NLS,
  ResponsiveTilesCollectionView,
  ResponsiveLargeTilesCollectionView,
  ChgChangeActionUtil,
  ChgTileViewLayout
) {
  "use strict";
  var chngDataGridView = View.extend({
    /*
     * init
     * @param options.treeDocument : tree document for grid view
     * @param options.columns : columns define for grid view
     * @param options.toolbar : toolbar define for grid view
     * @param options.target : destination div to inject grid view
     */
    init: function (options) {
      toolbar: null, this._parent(options);
      this._modelEvents = null;
      if (options != "undefined" && options.modelEvents != "undefined") {
        this._modelEvents = options.modelEvents;
      } else {
        this._modelEvents = new ModelEvents();
      }
      //DataGrid View
      this.caDatagridView = "";
      //if target defined, render and inject data grid view
      if (this.options.target != "undefined" && this.options.target != null) {
        this.render();
        this.caDatagridView.inject(this.options.target);
        console.log("Target Inject");
        this.caDatagridView.setStyle("width", this.options.target.offsetWidth);
      }
    },
    /*
      render function
    */
    render: function () {
      try {
        //get columns
        var columnsDeepCloned = this.processColumns();
        //create data grid view
        var dgOptions = {
          treeDocument: this.options.treeDocument, //tree document for grid view
          columns: columnsDeepCloned, //total number of columns
          //selectionMode: "cell",
          cellSelection: "none",
          rowSelection: "multiple",
          //rowDragEnabledFlag: true,
          cellDragEnabledFlag: true,
          showNodeKPIColorFlag: true,
          //showSelectionCheckBoxesFlag:false,
          placeholder: APP_NLS.CHG_Empty_DataGrid_Message,
          identifier: "width",
          //layout:"cadatagridLayout",
          defaultColumnDef: {
            width: "auto",
            resizableFlag: true,
            sortableFlag: true
          },
          onContextualEvent: function (params) {
            var menu = [];
            if (params && params.collectionView && params.cellInfos) {
              var colCount = params.collectionView.columns.length;
              var colId = params.cellInfos.columnID;
              //column title will not show the any contextual menu//
              if (colId != 0 /* && colId != 1 && colId != (colCount-1)*/) {
                menu = params.collectionView.buildDefaultContextualMenu(
                  params,
                  {
                    pin: true,
                    firstColumnsVisibility: true,
                    columnsManagement: true, //there is nothing to manage about column
                    sizeColumnToFit: false
                  }
                );
                return menu;
              }
            }

            //return menu;
          },
          filterBaseCAId: "All My Active Changes",
          onDragStartRowHeader: function (e, dndInfos) {
            ChgInfraService.readyDragContent(e, dndInfos);
            // return true;
          },
          onDragStartCell: function (e, dndInfos) {
            console.log(e);
            ChgInfraService.readyDragContent(e, dndInfos);
            //return true;
          }
        };
        dgOptions = UWA.merge(dgOptions, this.options);
        this.caDatagrid = new DataGridView(dgOptions);

        this.tilesView = new ResponsiveTilesCollectionView({
          model: this.options.treeDocument,
          height: 'inherit',
          //  width:'100%',
          displayedOptionalCellProperties: ['contextualMenu', 'description', 'propertiesList', 'activeFlag', 'statusbarIcons'],
          allowUnsafeHTMLContent: true,
          useDragAndDrop: true,
          grid: {
            selectionBehavior: {
              toggle: true,
              unselectAllOnEmptyArea: true,
              canMultiSelect: true,
              canInteractiveMultiselectWithCheckboxClick: true
            }
          },
          onDragStartCell: function (e, dndInfos) {
            ChgInfraService.readyDragContent(e, dndInfos);
          }, onDragEnterBlankDefault: function (event) { },
          onDragEnterBlank: function (event) { }

        });

        this.tilesView.onStatusbarIconPointerDown = function (args) {
          /*  	var cellInfos = args.cellInfos;
              var statusbarIconIndex = args.clickedIconIndex;
              var cellView = cellInfos ? cellInfos.cellView : undefined;
              var contentView = cellView ? cellView.contentView : undefined;
              var nodeModel = cellInfos ? cellInfos.cellModel : undefined;
  
              if (contentView && nodeModel && statusbarIconIndex >= 0 && statusbarIconIndex < contentView.statusbarIcons.length) {
                  var NewStatusbarIcons = [];
                  var NewStatusbarIconsTooltips = [];
  
                  for (var i = 0; i < contentView.statusbarIcons.length; i++) {
                    NewStatusbarIcons.push(contentView.statusbarIcons[i]);
                    NewStatusbarIconsTooltips.push(contentView.statusbarIconsTooltips[i]);
                  }
  
                  //Manage pause/resume icons
                  if (NewStatusbarIcons[statusbarIconIndex] === "pause") {
                    NewStatusbarIcons[statusbarIconIndex] = "resume";
                    NewStatusbarIconsTooltips[statusbarIconIndex] = "Resume";
                  }
                  else if (NewStatusbarIcons[statusbarIconIndex] === "resume") {
                    NewStatusbarIcons[statusbarIconIndex] = "pause";
                    NewStatusbarIconsTooltips[statusbarIconIndex] = "Hold";
                  }
  
                  //Manage thumbs-up/thumbs-down icons
                  if (NewStatusbarIcons[statusbarIconIndex] === "thumbs-down") {
                    NewStatusbarIcons[statusbarIconIndex] = "thumbs-up";
                    NewStatusbarIconsTooltips[statusbarIconIndex] = "Approve";
                  }
                  else if (NewStatusbarIcons[statusbarIconIndex] === "thumbs-up") {
                    NewStatusbarIcons[statusbarIconIndex] = "thumbs-down";
                    NewStatusbarIconsTooltips[statusbarIconIndex] = "Reject";
                  }
  
                  //Update the model.
                  nodeModel.options.statusbarIcons = NewStatusbarIcons;
                  nodeModel.options.statusbarIconsTooltips = NewStatusbarIconsTooltips;
  
                  //Update the view.
                  contentView.setProperties({
                      statusbarIcons: NewStatusbarIcons,
                      statusbarIconsTooltips: NewStatusbarIconsTooltips
                  });
                }*/
        }

        //Create Status Bar in Tile View
        this.tilesView.buildStatusBar([{
          type: CollectionViewStatusBar.STATUS.NB_ITEMS
        }, {
          type: CollectionViewStatusBar.STATUS.NB_SELECTED_ROWS
        }
        ]);
        //Set toolbar
        //customised tweaker template object
        var typeRepObject = {
          expandInput: { stdTemplate: "expandInputtemplate" }
        };

        //customised tweaker template object and AMD registration
        var expandInputtemplate = {
          expandInputtemplate: {
            path: "DS/ENOChgActionGridUX/scripts/View/ChgTweakerExpandInput",
            options: {
              displayStyle: "TextBox"
            }
          }
        };
        //debugger;
        try {
          var c = new ChgTweakerExpandInput();
        } catch (err) {
          console.log(err);
        }

        //customised representation for dropdown menu for views
        var dropDownTypeRepObject = {
          viewdropdown: {
            stdTemplate: "comboSelector",
            semantics: {
              possibleValues: [
                {
                  value: APP_NLS.CHG_VIEW_LIST,
                  icon: {
                    iconName: "view-list",
                    fontIconFamily: 1
                  }
                },
                {
                  value: APP_NLS.CHG_VIEW_TILE,
                  icon: {
                    iconName: "view-small-tile",
                    fontIconFamily: 1
                  }
                }
              ]
            }
          }
        };

        //customised representation for dropdown menu for sorting
        var dropDownTypeRepObject2 = {
          sortingdropdown: {
            stdTemplate: "functionMenuIcon",
            semantics: {
              label: "action",
              icon: "sorting"
            }
          }
        };

        //register tweakers
        this.caDatagrid.getTypeRepresentationFactory().registerTypeTemplates(expandInputtemplate);
        this.caDatagrid.getTypeRepresentationFactory().registerTypeRepresentations(typeRepObject);
        this.caDatagrid.getTypeRepresentationFactory().registerTypeRepresentations(dropDownTypeRepObject);
        this.caDatagrid.getTypeRepresentationFactory().registerTypeRepresentations(dropDownTypeRepObject2);
        //Create and set toolbar from json object
        ChgDataGridViewToolbar.toolbar = this.caDatagrid.setToolbar(ChgDataGridViewToolbar.writetoolbarDefination());
        this.toolbar = ChgDataGridViewToolbar.toolbar;
        //register types for toolbar
        this.toolbar.typeRepresentationFactory.registerTypeTemplates(expandInputtemplate);
        this.toolbar.typeRepresentationFactory.registerTypeRepresentations(typeRepObject);

        var that = this;
        //Add Events on toolbar ;
        that.toolbar.addEventListener("onReady", function (e) {
          var treeDocFilterModel = that.toolbar.getNodeModelByID("filterBaseCAId");
          if (treeDocFilterModel) {
            //callback to update the columnsHeader value when the value is changed in the toolbar
            treeDocFilterModel.onAttributeChange(function (e) {
              console.log("Need to update the view based on : " + e.data.changedAttributeValue
              );
              //that.caDatagrid.view.layout.columnsHeader = e.data.changedAttributeValue;
            });
          }

          var treeDocNewBlankCA = that.toolbar.getNodeModelByID("addNewBlankCAId");
          if (treeDocNewBlankCA) {
            //callback to update the columnsHeader value when the value is changed in the toolbar
            treeDocNewBlankCA._associatedView.registerkeyDownCallback(ChgCreateChangeAction.createBlankChangeAction);
          }

          var eyeToggle = that.toolbar.getNodeModelByID("eyeToggle");
          if (eyeToggle) {
            //debugger;
            //callback to update the columnsHeader value when the value is changed in the toolbar
            eyeToggle._associatedView.elements.internalView.elements.button.onclick = function (e) {
              that._modelEvents.publish(
                {
                  event: 'ca-DataGrid-toolbar-eyeToggle',
                  data: e,
                  context: eyeToggle
                }
              );
            }
          }

        });
        //Create Status Bar
        this.caDatagrid.buildStatusBar([{
          type: CollectionViewStatusBar.STATUS.NB_ITEMS
        }, {
          type: CollectionViewStatusBar.STATUS.NB_SELECTED_ROWS
        }]);

        //Listen for search
        this._modelEvents.subscribe({ event: 'ca-DataGrid-on-search' }, function (data) {
          var query = data.query;
          if (query) {
            that.caDatagrid.getTreeDocument().getAllDescendants().forEach(function (nodeModel) {
              if (!nodeModel.options.grid.title.contains(query) && nodeModel.isVisible()) {
                nodeModel.hide();
              }else if(nodeModel.options.grid.title.contains(query) && !nodeModel.isVisible()){
                nodeModel.show();
              }
            });
          }
        });
        //Listen for search
        this._modelEvents.subscribe({ event: 'ca-DataGrid-on-reset-search' }, function (data) {
            that.caDatagrid.getTreeDocument().getAllDescendants().forEach(function (nodeModel) {
              if (!nodeModel.isVisible()) {
                nodeModel.show();
              }
            });
        });
        //Dispatch click event on dataGrid
        that.caDatagrid.addEventListener(PointerEvents.POINTERHIT, function (e, cellInfos) {
          console.log("inside pointer ");
          console.log(e);
          onItemClick(e, cellInfos);

        });

        //Dispatch select event
        that.caDatagrid.getTreeDocument().getXSO().onAdd(function (nodeModel) {
          console.log("on add");
          that._modelEvents.publish(
            {
              event: 'ca-DataGrid-on-click',
              data: { model: nodeModel.options.grid },
              context: nodeModel
            }
          );
        });

        // Dispatch unselect event
        that.caDatagrid.getTreeDocument().getXSO().onRemove(function (nodeModel) {
          console.log("on remove");
          if (nodeModel.getTreeDocument().getSelectedNodes().length == 0) {
            console.log("on unselect all");
            that._modelEvents.publish(
              {
                event: 'ca-DataGrid-on-unselect-all',
                data: { model: nodeModel.options.grid },
                context: nodeModel
              }
            );
          } else {
            that._modelEvents.publish(
              {
                event: 'ca-DataGrid-on-unselect',
                data: { model: nodeModel },
                context: nodeModel
              }
            );
          }
        });

        //Dispatch click event on tile View
        that.tilesView.addEventListener(PointerEvents.POINTERHIT, function (e, cellInfos) {
          console.log("inside tile view pointer ");
          console.log(e);
          onItemClick(e, cellInfos);
        });

        // handle double click event
        var onItemClick = function (e, cellInfos) {
          if (cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.options.grid) {
            if (e.multipleHitCount == 2) {
              console.log('ca-DataGrid-on-dblclick');

              //show the back button in toolbar
              var backIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("back");
              if (backIcon) {
                backIcon.updateOptions({
                  visibleFlag: true
                });
              }

              ChgChangeActionUtil.previousView = ChgChangeActionUtil.currentView;

              // change to tile view on dbl click
              var viewIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
              if (viewIcon && viewIcon.options.grid.semantics.icon.iconName != "view-small-tile") {
                viewIcon.updateOptions({
                  grid: {
                    semantics: {
                      icon: {
                        iconName: "view-small-tile"
                      }
                    }
                  }
                });
                ChgTileViewLayout.changeView();
              }

              cellInfos.nodeModel.select(true);
              that._modelEvents.publish(
                {
                  event: 'ca-DataGrid-on-dblclick',
                  data: { model: cellInfos.nodeModel.options.grid },
                  context: cellInfos.nodeModel
                }
              );
            } /*else if (e.multipleHitCount == 1 && cellInfos.columnID != -1) {
                that._modelEvents.publish(
                  {
                    event: 'ca-DataGrid-on-click',
                    data: { model: cellInfos.nodeModel.options.grid },
                    context: cellInfos.nodeModel
                  }
                );
              } else if (e.multipleHitCount == 1 && cellInfos.columnID == -1 && e.srcElement.parentElement.hasClassName("wux-datagridview-selection-checkbox")) {
                if (e.srcElement.parentElement.hasAttribute("checked")) {
                  that._modelEvents.publish(
                    {
                      event: 'ca-DataGrid-on-click',
                      data: { model: cellInfos.nodeModel.options.grid },
                      context: cellInfos.nodeModel
                    }
                  );
                }
              }*/
          }
        };

        //Create Containers for toolbar and DataGrid
        this.caDatagridView = UWA.createElement("div", {
          'id': "outer-ca-div",
          styles: {
            'width': "100%",
            'height': "100%",
            'display': "inline-block"
          },
          'class': "outer-ca-div"
        });
        var toolbarDiv = UWA.createElement("div", {
          styles: {
            'width': "100%"
          },
          'class': "toolbar-ca-div"
        });
        this.toolbar.inject(toolbarDiv);

        var gridViewDiv = UWA.createElement("div", {
          styles: {
            'width': "100%",
            'height': "calc(100% - 40px)",
            'position': "relative"
          },
          'class': "content-ca-div cagridView showView nonVisible"
        });

        var tileViewDiv = UWA.createElement("div", {
          styles: {
            'width': "100%",
            'height': "calc(100% - 40px)",
            'position': "relative"
          },
          'class': "catileView hideView"
        });

        var emptyTileViewDiv = UWA.createElement("div", {
          class: "hideView",
          id: "emptyTileViewDiv"
        });

        var emptyTileViewContent = UWA.createElement("div", {
          html: APP_NLS.CHG_Empty_DataGrid_Message,
        });

        emptyTileViewContent.inject(emptyTileViewDiv);

        this.caDatagrid.inject(gridViewDiv);
        this.tilesView.inject(tileViewDiv);
        emptyTileViewDiv.inject(tileViewDiv);
        this.caDatagridView.addContent(toolbarDiv);
        this.caDatagridView.addContent(gridViewDiv);
        this.caDatagridView.addContent(tileViewDiv);
        //this.caDatagridView.showColumnsManagementDialog();
        // creating the Empty
        /*this._emptyContainer = document.createElement('div');
        this._emptyContainer.classList.add('calv-empty-container');
        gridViewDiv.appendChild(this._emptyContainer);
        var cTemplate = Handlebars.compile(EmptyCA_Template);
        this._emptyContainer.innerHTML = cTemplate();
        gridViewDiv.appendChild(this._emptyContainer);*/

        //this.toolbar.array3[0].tweaker.elements.container.firstChild.setStyle('visibility','hidden');
        //return this;
      } catch (err) { }
    },
    /*
     * Process Columns
     * adds per column functionality based on column's json
     */
    processColumns: function () {
      return this.options.columns;
    },
    reapplySortModel: function () {
      this.caDatagrid.reapplySortModel();
    },

    backToSummary: function () {
      this._modelEvents.publish(
        {
          event: 'ca-back-to-summary',
          data: {}
        }
      );
    },

    /**
     * To be called only once after initial data load to avoid duplicate event calls
     */
    setListnersOnToolbar: function () {
      var that = this;

      // var treeDocFilterModel = that.toolbar.getNodeModelByID("StatusRowsCAID");
      // if (treeDocFilterModel) {
      //   //treeDocFilterModel._associatedView.getContent().setStyle("font-weight", "600");
      //   var ca_count_text0 = APP_NLS.CHG_Header_MultiCA;
      //   var length = that.caDatagrid.getTreeDocument().getAllDescendants().length;
      //   if (length <= 1) {
      //     ca_count_text0 = APP_NLS.CHG_Header_SingleCA
      //   }
      //   treeDocFilterModel.updateOptions({
      //     grid: {
      //       data:
      //         that.caDatagrid.getTreeDocument().getAllDescendants().length + " " +
      //         ca_count_text0 + " (" + APP_NLS.CHG_Filter + ": " + APP_NLS.CHG_Filter_MyActiveCA + ")"
      //     }
      //   });
      //   //Update Toolbar item count on model change
      //   that.caDatagrid.getTreeDocument().addEventListener("modelUpdate", function (e) {
      //     //workaround till fix from datagrid
      //     var elemLength = 0;
      //     var ca_count_text = APP_NLS.CHG_Header_MultiCA
      //     var elemList = this.getAllDescendants();
      //     for (var k in elemList) {
      //       if (elemList[k]._expandState == "noExpandState") { elemLength++ }
      //     }
      //     if (elemLength <= 1) {
      //       ca_count_text = APP_NLS.CHG_Header_SingleCA
      //     }
      //     //workaround till fix from datagrid : end
      //     treeDocFilterModel.updateOptions({
      //       grid: {
      //         data:
      //           elemLength + " " + ca_count_text + " (" + APP_NLS.CHG_Filter + ": " + APP_NLS.CHG_Filter_MyActiveCA + ")"
      //       }
      //     });
      //   });


      // }

      //Publish Event on add Child
      if (that.caDatagrid.getTreeDocument() != undefined) {
        that.caDatagrid.getTreeDocument().addEventListener("addChild", function (cellInfos) {
          if (cellInfos.data && cellInfos.data.nodeModel && cellInfos.data.nodeModel.options) {
            that._modelEvents.publish({
              event: 'ca-DataGrid-on-addChild',
              data: { model: cellInfos.data.nodeModel.options.grid },
              context: cellInfos.data.nodeModel
            });
            cellInfos.data.nodeModel.select();
          }
        });
      }

      //subscribe event on change title
      that._modelEvents.subscribe({ event: 'ca-IDCard-on-change-title' }, function (data) {
        console.log("in change title subscribe");
        require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
          ChgDataGridLayout.updateTitle(data);
        });
      });

      //subscribe event on change severity
      that._modelEvents.subscribe({ event: 'ca-IDCard-on-change-severity' }, function (data) {
        console.log("in change sev subscribe");
        require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
          ChgDataGridLayout.updateSeverity(data);
        });
      });

      //subscribe event on change maturity
      that._modelEvents.subscribe({ event: 'ca-IDCard-on-change-maturity' }, function (data) {
        console.log("in change sev subscribe");
        require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
          ChgDataGridLayout.updateMaturity(data);
        });
      });

      //subscribe event on change duedate
      that._modelEvents.subscribe({ event: 'ca-IDCard-on-change-duedate' }, function (data) {
        console.log("in change sev subscribe");
        require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
          ChgDataGridLayout.updateDueDate(data);
        });
      });

      //subscribe event on change responsibility
      that._modelEvents.subscribe({ event: 'ca-IDCard-on-change-responsibility' }, function (data) {
        console.log("in change sev subscribe");
        require(['DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout'], function (ChgDataGridLayout) {
          ChgDataGridLayout.updateResponsibility(data);
        });
      });

    }
  });

  return chngDataGridView;
});

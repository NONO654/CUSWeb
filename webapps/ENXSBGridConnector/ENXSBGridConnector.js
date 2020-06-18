/**
 * Grid Connector
 * calls the gridview webservice, fetches the response,
 * process the response to a format supported by the DataGridView
 * feed the processed data to the datagrid model to render the view
 * @module DS/ENXSBGridConnector/ENXSBGridConnector
 */

define('DS/ENXSBGridConnector/ENXSBGridConnector',
  ['UWA/Core',
   'DS/Core/Core',
   'DS/Controls/Abstract',
   'UWA/Element',
   'DS/WAFData/WAFData',
   'DS/ENOFrameworkPlugins/jQuery',
   'DS/ENXDataGrid/ENXDataGrid',
   'DS/ENXSBToolbarClient/ENXSBToolbarClient',
   'DS/ENXSBGridConnector/ENXConnectorColumnManagement',
   'DS/ENXDataGrid/URLUtils',
   'DS/Windows/ImmersiveFrame',
   'DS/Windows/Panel',
   'DS/Tree/TreeDocument',
   'DS/Tree/TreeNodeModel',
   'DS/CollectionView/CollectionViewStatusBar',
   'UWA/Class',
   'DS/Tweakers/TypeRepresentationFactory',
   'DS/Tweakers/GeneratedToolbar',
   'DS/ENXSBGridConnector/StandardFunctions',
   'DS/ENXDataGrid/ENXGraphBuilder',
   'DS/ENXDataGrid/ENXThumbnailGridViewBuilder',
   'DS/Notifications/NotificationsManagerUXMessages',
   'DS/Notifications/NotificationsManagerViewOnScreen',
   'DS/Windows/Dialog',
   'DS/Controls/Button',
   'DS/Utilities/Utils',
   'DS/ENXSBGridConnector/6WTag',
   'DS/Utilities/TouchUtils',
   'DS/Controls/Loader',
   'css!DS/ENXDataGrid/ENXDataGrid.css',
   'i18n!DS/ENXDataGrid/assets/nls/message'
  ],
  function(
    UWA,
    WUX,
    Abstract,
    Element,
    WAFData,
    JQuery,
    DataGridView,
    Toolbar,
    ConnectorColumnManagement,
    URLUtils,
    WUXImmersiveFrame,
    WUXPanel,
    TreeDocument,
    TreeNodeModel,
    CollectionViewStatusBar,
    Class,
    TypeRepresentationFactory,
    WUXGeneratedToolbar,
    StandardFunctions,
    ENXGraphBuilder,
    ENXThumbnailGridViewBuilder,
    WUXNotificationsManagerUXMessages,
    WUXNotificationsManagerViewOnScreen,
    WUXDialog,
    WUXButton,
    Utils,
    Tags,
    TouchUtils,
    Loader,
    DataGridCSS,
    nlsMessageJSON
  ) {

    "use strict";

    var url = location.href;
    var _pref3DSpace = "";
    var options = {
      serviceURL: '/resources/v1/ui/gridview?',
      toolbarURL: '/resources/v1/ui/toolbar/getToolbar?',
      gridViewServiceURL: '',
      toolbarServiceURL: ''
    };
    var count = 0;
    var columnName = "",
      columns = [];
    var validateMethod, validateTypeMethod, badCharList;
    var currentValue, possibleValues = [];
    var numberOfNodesByDepth = 0;
    var immersiveFrame;
    var loader;
    var activeTimer;

    var connector = Abstract.inherit({

      name: 'ENXSBGridConnector',

      publishedProperties: {
        toolbar: {
          defaultValue: undefined,
          type: 'object'
        },
        gridView: {
          defaultValue: undefined,
          type: 'object'
        }
      },

      _preBuild: function() {
        this._parent();
        _pref3DSpace = '../..';
        this.fetchServiceResponse(_pref3DSpace, url, options);

      },

	  showLoader: function() {
	  	loader = new Loader().inject(document.body);
	  	JQuery(".wux-controls-abstract.wux-controls-progressbar").addClass("center");
	  	loader.on();
	  },

	  hideLoader: function() {
	  	if(loader) {
	  		loader.off();
	  	}
	  },

	  init6WTags: function() {
	  	try {
	  	Tags.init(StandardFunctions);
	  	//Tags.handleDrawTags();
	  	Tags.getTNWindow().jQuery(Tags.getTNWindow().document).trigger("dg_data_changed.bps_dg");
	  	} catch(err) {
	  		console.log("Not able to initialize tags");
	  	}
	  },

      /**
       * Function to make webservice requests for gridview and toolbar and pass the response to process the resulted data
       * @param {String} _pref3DSpace - string to locate up 3DSpace from the current directory
       * @param {String} url - the url of the current page
       * @param {Object} options - an object with predefined URLs that are used to request the webservice
       */
      fetchServiceResponse: function(_pref3DSpace, url, options) {
        var that = this;
        var fetchStartTime = performance.now();
        var serviceParameters = url.split("?")[1];
        this.showLoader();

        if (serviceParameters !== undefined) {
          options.gridViewServiceURL = _pref3DSpace + options.serviceURL + serviceParameters;
          options.toolbarServiceURL = _pref3DSpace + options.toolbarURL + serviceParameters;

          var toolbarQueryOptions = {
            type: 'json',
            timeout: 600000,
            onComplete: function(result) {
              var timeTakenForToolbarRequest = (new Date().getTime()) - this.start_time;
              if (typeof performanceLogs['dataServerTime'] == 'undefined') {
                performanceLogs['dataServerTime'] = 0;
              }

              performanceLogs['dataServerTime'] = performanceLogs['dataServerTime'] + timeTakenForToolbarRequest;

              Toolbar.processToolbarData(result, that);
			  var savedDisplayView = dgView.layout._getDataFromPreferences("displayView");
			  var toolbarRef = StandardFunctions.getToolbarReference();
			  if (savedDisplayView == "thumbnail" || savedDisplayView == "graph") {
				toolbarRef.getNodeModelByID("DataGridWrapCommand").updateOptions({
         			   disabled: true
				});
		}

              performanceLogs['totalTime'] = new Date().getTime() - totalTimeStart;
            }
          }

          var queryOptions = {
            type: 'json',
            timeout: 600000,
            onComplete: function(result) {
              that.hideLoader();
              var timeTakenForGridviewRequest = (new Date().getTime()) - this.start_time;
              if (typeof performanceLogs['dataServerTime'] == 'undefined') {
                performanceLogs['dataServerTime'] = 0;
              }
              performanceLogs['dataServerTime'] = performanceLogs['dataServerTime'] + timeTakenForGridviewRequest;

              that.processWebServiceData(result);

              if ('NONE' == gridType) {
                options.toolbarServiceURL += '&expandLevelFilter=false';
              }

              toolbarQueryOptions['start_time'] = new Date().getTime();
              that.init6WTags();
              WAFData.authenticatedRequest(options.toolbarServiceURL, toolbarQueryOptions);
            }
          }

          queryOptions['start_time'] = new Date().getTime();
          WAFData.authenticatedRequest(options.gridViewServiceURL, queryOptions);
        }

      },
      gridView: undefined,
      uiPanel: undefined,
      nodeModel: undefined,
      draggedItems: new Array(),
      draggable: undefined,
      dropTypesHierarchy: undefined,
      dropAction: undefined,
      dropItems: undefined,
      dropRelationshipsArray: undefined,
      dropDirectionsArray: undefined,
      thumnailGrid: undefined,

      // this process method is used by the sb grid connector to generate the grid
      process: function(container, data, cols, typeRepsArray, columnsForDisplayModes) {

        //add the tablename to the json for editing the cells
        //var tableName = URLUtils.getParameter("table");
        //dataGridViewChangeValues.push({tableName:tableName});

        immersiveFrame = new WUXImmersiveFrame().inject(container);
        console.log("result");

        //create the data model and add nodes
        var model = this.createModel(data, cols);
        this.nodeModel = model;

        displayModesColumnsArray = columnsForDisplayModes;

        if (gridType == "MULTI_ROOT_NODE" || gridType == "SINGLE_ROOT_NODE") {
          numberOfNodesByDepth = 1;
        }

        alertMessageNotification = WUXNotificationsManagerUXMessages;
        WUXNotificationsManagerViewOnScreen.setNotificationManager(alertMessageNotification);

        //create the data grid view
        var dataGridView = this.createDataGrid(model, cols, typeRepsArray, immersiveFrame);

        this.gridView = dataGridView;
        dgView = dataGridView;

        dataGridView.onReady(function(){
        	var showTouchStyle = URLUtils.getParameter("showTouchStyle");
            showTouchStyle = (showTouchStyle != undefined && showTouchStyle != "") ? (showTouchStyle == 'true') : false;
//            uncomment the below line to support touch style through url parameter
//            TouchUtils.setTouchMode(showTouchStyle);
        });


        var dataGridViewPanel;
        var savedDisplayView = dgView.layout._getDataFromPreferences("displayView");

        if (savedDisplayView == "thumbnail" || savedDisplayView == "graph") {
          dataGridViewPanel = new WUXPanel({
            immersiveFrame: immersiveFrame,
            identifier: 'DataGridViewPanel',
            showTitleFlag: false,
            titleBarVisibleFlag: false,
            resizableFlag: true,
            maximizeButtonFlag: true,
            maximizedFlag: true,
            width: '500',
            height: '500'
          });
        }

        if (savedDisplayView == "thumbnail") {
        	this.dataGridDisplayThumbnail();
        } else if (savedDisplayView == "graph") {
        	this.dataGridDisplayGraph();
        } else {
          dataGridViewPanel = this.createDataGridTable.call(this, dataGridView, model, immersiveFrame);
        }

        this.uiPanel = dataGridViewPanel;

     // CallBack for language changes to set the language on the locale
        WUX.onlanguagechange(function(){});

        return dataGridViewPanel;

      },

      createDataGridTable: function(dataGridView, model, immersiveFrame) {
        var predefinedSortModel = [];
        var columnsReverseIndexes = {};
        var filterColumns = {};
        //var displayViewColumnsArray = [], tempDisplayViewColumns = [], displayViewColumnsCount = 0;
        var ENXDataGridScope = this;
        var cols = dataGridView.layout.getLeafColumns();
        //need reference to columns for processDataElementValues call in expand callback
        columns = cols;

        for (var i = 0, len = cols.length; i < len; i++) {
          var dataIndex = cols[i].dataIndex;
          if (dataIndex !== undefined) {
            columnsReverseIndexes[dataIndex] = i;
          }

          if(cols[i].typeRepresentation == 'enumString') {
          	cols[i].getCellSemantics = function(cellInfos){
          		return ENXDataGridScope.reloadPossibleValues(cellInfos);
          	}
          }
          if (cols[i].sort === 'asc' || cols[i].sort === 'desc') {
            predefinedSortModel.push({
              dataIndex: cols[i].dataIndex,
              sort: cols[i].sort
            });
          }

          if (cols[i].filterableFlag === "true") {

            filterColumns[cols[i].dataIndex] = {
              filterId: 'set',
            };
          }

        }


        dataGridView.sortModel = predefinedSortModel;
        model.setFilterModel(filterColumns);

        var currentNodeModel = dataGridModel.getChildren();
        this.updateModelWithRowId(currentNodeModel);

        //if grouping needs to be performed
        var grpColumns = URLUtils.getParameter("rowGroupingColumnNames");
        if (grpColumns) {
          var grpOption = new Object();
          grpOption.dataIndexesToGroup = grpColumns.split(",");
          dataGridView.groupRows(grpOption);
        }

        /**TODO the below code will be removed once the datagrid has the capability for computing variable row height
         * for image column after they are rendered.
         * IR-706717-3DEXPERIENCER2019x: Techno_Firefox:Row Height is not auto-set for images.
         */
        dgView.layout.getRowHeightFunction = function (rowID) {
        	var rowHeight = dgView.layout.getRowHeightFromCellContents(rowID);
        	 for (var i = 0; i < cols.length; i++) {
        		 if(cols[i].columnType != undefined && cols[i].columnType.toLowerCase() == "image"){
        			 var nodeModel = dgView.model[rowID];
        			 if(nodeModel){
        				 var attr = (cols[i].dataIndex == 'tree') ? 'treeLabel' : cols[i].dataIndex;
        				 if (nodeModel.options.grid[attr] != "" && nodeModel.options.grid[attr] != undefined && nodeModel.options.grid[attr] != null ){
        					 rowHeight = (cols[i].cellHeight > rowHeight) ? (cols[i].cellHeight) : rowHeight;
        				 }
        			 }
        		 }
        	 }
        	 return rowHeight;
        }

        /*dataGridView.layout.getRowHeightFunction = function(rowID) {
        	var cellHeight = URLUtils.getParameter('cellHeight');
        	return (cellHeight) ? parseInt(cellHeight) : 33;
        };*/

        var headerHeight = URLUtils.getParameter('headerHeight');
        if (headerHeight) {
          dataGridView.layout.columnHeaderHeight = parseInt(headerHeight);
        }

        //listen to the change event, and store the column names to a global value

        dataGridView.addEventListener("change", function(e, cellInfos) {
          if (e.target.dsModel.possibleValues)
            possibleValues = e.target.dsModel.possibleValues;
          if (typeof cellInfos != 'undefined') {
            columnName = dataGridView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
            columnName = (columnName == 'tree') ? 'treeLabel' : columnName;
            validateMethod = dataGridView.layout.getColumnOptionValue(cellInfos.columnID, 'validate');
            validateTypeMethod = dataGridView.layout.getColumnOptionValue(cellInfos.columnID, 'validateTypeMethod');
            if (validateTypeMethod != undefined)
              badCharList = dataGridView.layout.getColumnOptionValue(cellInfos.columnID, 'badCharStr');
            if (cellInfos.nodeModel != undefined)
              currentValue = cellInfos.nodeModel.options.grid[columnName];
          }
        });

        dataGridView.addEventListener("preEdit", function(e, cellInfos) {
          model.setUseChangeTransactionMode(true);
        });

        dataGridView.addEventListener("postEdit", function(e, cellInfos) {
          model.setUseChangeTransactionMode(false);
        });

        //			create the status bar
        this.createStatusBar(dataGridView);

        //			create the data grid view panel
        var dataGridViewPanel = new WUXPanel({
          immersiveFrame: immersiveFrame,
          identifier: 'DataGridViewPanel',
          title: 'DataGridView',
          showTitleFlag: false,
          titleBarVisibleFlag: false,
          resizableFlag: true,
          maximizeButtonFlag: true,
          maximizedFlag: true,
          width: '500',
          height: '500',
          content: dataGridView
        });

        return dataGridViewPanel;
      },

      createStatusBar: function(view) {
        view.buildStatusBar([{
          type: CollectionViewStatusBar.STATUS.NB_ITEMS
        }, {
          type: CollectionViewStatusBar.STATUS.NB_SELECTED_ROWS
        }, {
          type: CollectionViewStatusBar.STATUS.NB_SELECTED_CELLS
        }, {
          type: CollectionViewStatusBar.STATUS.ACTIVE_CELL,
          position: 'far'
        }]);
      },

      getLeafColumns: function(columns) {
        var leafColumns = new Array();
        for (var i = 0; i < columns.length; i++) {
          if (columns[i].children && columns[i].children.length > 0) {
            for (var j = 0; j < columns[i].children.length; j++) {
              leafColumns.push(columns[i].children[j]);
            }
          } else {
            leafColumns.push(columns[i]);
          }
        }

        return leafColumns;
      },

      processDataElementValues: function(nodeData, cols) {
        var leafColumns = this.getLeafColumns(cols);
        for (var i = 0; i < leafColumns.length; i++) {
          var dataIndex = leafColumns[i].dataIndex;
          var columnTypeRepresentation = leafColumns[i].typeRepresentation;
          if ((columnTypeRepresentation === 'integer') || (columnTypeRepresentation === 'percentage')) {
            // Ensure the number type data is of type Number and not String
            if (typeof(nodeData[dataIndex]) === 'string') {
              var num = parseFloat(nodeData[dataIndex]);
              if (isNaN(num)) {
                nodeData[dataIndex] = undefined;
              } else {
                nodeData[dataIndex] = num;
              }
            }
          }

          // handle when there is no value in the date column
          if(columnTypeRepresentation === 'date' && nodeData[dataIndex] == ""){
        	  nodeData[dataIndex] = undefined;
          }
          else if (columnTypeRepresentation === 'date' && nodeData[dataIndex] != undefined) {
            nodeData[dataIndex] = new Date(nodeData[dataIndex]);
          }
        }
      },

      onPreExpandFunction: function(modelEvent) {
        if (!modelEvent.target._isFromOriginalModel() || modelEvent.target.options.expanded) {
          modelEvent.target.preExpandDone();
        } else {
          this.performExpand(modelEvent.target, 1);
        }
      },

      performExpand: function(nodeToExpand, expandLevel) {
        var that = this;
        var objectId = nodeToExpand.options.grid.id;
        var relId = (typeof nodeToExpand.options.grid.relId != 'undefined') ? nodeToExpand.options.grid.relId : '';
        var parentId = (typeof nodeToExpand._parentNode.options.grid.id != 'undefined') ? nodeToExpand._parentNode.options.grid.id : '';

        var urlParams = URLUtils.getParametersMap();
        if(urlParams.hasOwnProperty("objectId")){
        	urlParams["originalObjectId"] = urlParams["objectId"];
        }
        urlParams["objectId"] = objectId;
        urlParams["relId"] = relId;
        urlParams["parentId"] = parentId;
        if (urlParams.program) {
          delete urlParams.program;
        }
        if (urlParams.selectedProgram) {
          delete urlParams.selectedProgram;
        }
        if (urlParams.programMenu) {
          delete urlParams.programMenu;
        }
        var urlRetrieved = '../../resources/v1/ui/gridview/rowData?&emxExpandFilter=' + expandLevel;
        for (var param in urlParams) {
          urlRetrieved += '&' + param + '=' + urlParams[param];
        }

        var expandOptions = {
          type: 'json',
          start_time: new Date().getTime(),
          async: false,
          onComplete: function(result) {
            console.log(result);
            var requestQueryTime = (new Date().getTime() - this.start_time);
            console.log('This request took ' + requestQueryTime + ' ms');
            //					dataGridModel.setUseChangeTransactionMode(false);
            var state;
            dataGridModel.withTransactionUpdate(function() {
              state = nodeToExpand.getState();
              nodeToExpand.removeChildren();
              if (result.data[0] && result.data[0].children && result.data[0].children.length > 0) {
                that.processData(result.data[0].children, columns, nodeToExpand);
              }
              nodeToExpand.sortChildren();
              nodeToExpand.preExpandDone();
              that.updateModelWithRowId(nodeToExpand.getChildren(),nodeToExpand.options.grid.rowId);
//              dgView.reapplySortModel();
              nodeToExpand.options.expanded = true;
              //					dataGridModel.acceptChanges();
              //					dataGridModel.pushUpdate();
            });

            if ("expanding" != state) {
              if (expandLevel > 0) {
                nodeToExpand.expandNLevels({
                  numberOfLevelsToExpand: expandLevel
                });
              } else {
                nodeToExpand.expandAll();
              }
            }

            if (dgView.layout._getDataFromPreferences("displayView") == "graph") {
              ENXGraphBuilder.setGraphNodes(nodeToExpand.getChildren(), displayModesColumnsArray);
            }
          }
        };

        WAFData.authenticatedRequest(urlRetrieved, expandOptions);
      },

      updateModelWithRowId: function(currentNodeModel, parentLevel) {
			for(var level = 0; level < currentNodeModel.length; level++) {
				var gridOptions = currentNodeModel[level].options;
				gridOptions.grid['rowId'] = (typeof parentLevel != 'undefined') ? parentLevel + "," + level : ((typeof parentLevel == 'undefined' && typeof gridOptions.children == 'undefined')? "0,"+level : level);
				if(typeof gridOptions.children != 'undefined' && gridOptions.children.length > 0){
					var childNodes = gridOptions.children;
					this.updateModelWithRowId(childNodes,level);
				}
			}
		},

      // looping through all nodes is costly. keep only one method to loop through.
      processData: function(data, cols, parent) {
        for (var i = 0; i < data.length; i++) {
          var row = data[i];
          this.processDataElementValues(row.dataelements, cols);
          this.addEditAccessMap(row);
          var itsChildren = (gridType == 'NONE' || (typeof row.dataelements.hasChildren != 'undefined' && "false" == row.dataelements.hasChildren.toLowerCase())) ? undefined : [];
          var expanded = (typeof row.dataelements.expanded != 'undefined' && "true" == row.dataelements.expanded.toLowerCase()) ? true : false;
		  var typeIconArray = (typeof row.dataelements.typeIcon != 'undefined') ? new Array(row.dataelements.typeIcon) : undefined;
          var childNode = new TreeNodeModel({
            grid: row.dataelements,
            label: row.dataelements.treeLabel,
            icons: typeIconArray,
            relData: [row.relateddata],
            expanded: expanded,
            children: itsChildren
          });
          childNode.options.grid.id = row.id;
          childNode.options.grid.type = row.type;
          childNode.options.grid.relId = row.relId;
          if (childNode.options.thumbnail == undefined)
            childNode.options.thumbnail = "../ENXDataGrid/assets/icon120x80ImageNotFound.png";

          if (parent instanceof TreeNodeModel) {
            childNode.options.grid.rowId = parent.options.grid.rowId + "," + i;
            parent.addChild(childNode);
          } else {
            if (URLUtils.getParameter('hideRootSelection') == 'true' && gridType == 'SINGLE_ROOT_NODE') {
              childNode.options.grid['disableSelection'] = 'true';
            }
            if (URLUtils.getParameter('editRootNode') == 'false') {
              childNode.options.grid['dgEditNode'] = 'false';
            }
            if (gridType == 'NONE') {
              childNode.options.grid['dgEditNode'] = 'true';
            }

            childNode.options.grid.rowId = "" + i;
            parent.addRoot(childNode);
          }
          if (row.children && row.children.length > 0) {
            this.processData(row.children, cols, childNode);
          }
        }
      },

      addEditAccessMap: function(row) {
        row.dataelements['dgEditAccess'] = row.relateddata.editAccess[0].dataelements;
      },

      createModel: function(data, cols) {
        var model = new TreeDocument({
          useAsyncPreExpand: true,
          shouldBeSelected: function(nodeModel) {
            return !(nodeModel.options.grid.disableSelection == 'true');
          }
        });

        model.onNodeModelUpdate(function(modelEvent) {
          var treeNodeModel = modelEvent.data.nodeModel;
          if (treeNodeModel) {
            var attributes = modelEvent.data.attributes;
          }

          if (treeNodeModel.getChangeStates() & TreeNodeModelChangeStates.AttributesChanged) {
            console.log("the data has been modified");
            isDataModified = true;
          }

        });

        model.addEventListener("nodeModelUpdate", function(e) {
        	if(dataGridModel != undefined && dataGridModel.getUseChangeTransactionMode() == true){
        		if ('true' == e.target.options['bpsUpdateByCode'] || (columnName != 'treeLabel' && currentValue == e.data.nodeModel.options.grid[columnName])) {
                    return;
                  }

                  var oldVal = currentValue;
                  var newVal;
                  if (possibleValues.length > 0) {
                    var resultObject;
                    possibleValues.forEach(function(element) {
                      if (element.value === e.data.nodeModel.options.grid[columnName]) {
                        resultObject = element
                      }
                    });
                    possibleValues = [];
                    newVal = resultObject.actualValue;
                  } else {
                	  if(columnName == 'treeLabel'){
                		  newVal = e.data.nodeModel.options.grid.tree.label;
                	  }else{
                		  newVal = e.data.nodeModel.options.grid[columnName];
                	  }

                  }

                  activeCellColumn = columnName;
                  activeCellRow = e.data.nodeModel;
                  activeCellRow.oldValue = oldVal;
                  activeCellRow.newValue = newVal;
                  if (newVal instanceof Date) {
                   /* var month = newVal.getMonth() + 1;
                    newVal = newVal.getFullYear() + '-' + month + '-' + newVal.getDate();*/
                  }

                  if (!isNaN(newVal)) {
                    newVal = newVal.toString();
                  }
                  if (activeTimer) {
//                  	newVal = that.getNewValueOnModelUpdate(e);
                	  clearTimeout(activeTimer);
                	  activeTimer = null;
                  }

                  	  activeTimer = setTimeout(function(){
                  		if (!isNaN(newVal)) {
                            newVal = newVal.toString();
                          }
                  		  var id = e.data.nodeModel.options.grid.id;
                            var mapObject = {};
                            if (editMap.hasOwnProperty(id)) {
                              mapObject = editMap[id];
                              mapObject[columnName] = newVal; //e.data.nodeModel.options.grid[columnName];
                              editMap[id] = mapObject;
                            } else {
                              mapObject[columnName] = newVal; //e.data.nodeModel.options.grid[columnName];
                              mapObject['relId'] = e.data.nodeModel.options.grid.relId;
                              mapObject['parentId'] = StandardFunctions.getParentId(e.data.nodeModel);
                              mapObject['rowId'] = (e.data.nodeModel.options.grid.rowId != undefined) ? e.data.nodeModel.options.grid.rowId.toString() : "0," + e.data.nodeModel._rowID;
                              mapObject["markup"] = "changed";
                              editMap[id] = mapObject;
                            }

                  	  },50);



                  var isValidText = true; //holds true for columns that do not have validate setting
                  var constructValidateMethod;
                  if (validateTypeMethod) {
                    constructValidateMethod = validateTypeMethod + "(\"" + badCharList + "," + newVal + "\")";
                    //require(['DS/ENXSBGridConnector/StandardFunctions'], function(StandardFunctions) {
                    var func = StandardFunctions[validateTypeMethod];
                    var badCharFound = func.call(StandardFunctions, badCharList, newVal);
                    isValidText = (badCharFound.length > 0) ? false : true;
                    if (!isValidText) {
                      window.alert("the entered text has the following bad characters: " + badCharFound);
                      var grid = {};
                      grid[columnName] = oldVal;
                      e.data.nodeModel.updateOptions({
                        grid: grid
                      });
                    }
                    //});
                  }
                  //				if a column has a validate setting then execute the script to validate the cell value
                  if (validateMethod != null && validateMethod != "") {
                    constructValidateMethod = validateMethod + "(\"" + newVal + "\")";
                    isValidText = eval(constructValidateMethod);

                    //				if the cell is not in the valid format then do not modify the cell to
                    //				the new value instead retain the old value
                    if (!isValidText) {
                      var grid = {};
                      grid[columnName] = oldVal;
                      e.data.nodeModel.updateOptions({
                        grid: grid
                      });
                    }
                  }

                  //				only if the cell values are in valid format then save then to
                  //				the editMap which is late used to save the data in the database
                  if(!isValidText){
                	  if (activeTimer) {
//                    	newVal = that.getNewValueOnModelUpdate(e);
                		  clearTimeout(activeTimer);
                		  activeTimer = null;

                	  }
                  }
        	}
        });

        model.addEventListener("sortChildren", function(event) {
          //require(['DS/ENXSBGridConnector/StandardFunctions'], function(StandardFunctions) {
          //StandardFunctions.updateModelWithRowId(event.target.getChildren(), undefined, -1);
          //});
        });

        model.prepareUpdate();
        this.processData(data, cols, model);
        model.pushUpdate();

        // Activating the model change transaction mode
        model.setUseChangeTransactionMode(false);
        //check if the rootnode has children and only if it has then expand
        //model.getChildren()[0].options.children.length
        if (gridType == 'SINGLE_ROOT_NODE' && model.getChildren()[0].hasChildren() && model.getChildren()[0].getChildren().length > 0) {
          if (typeof emxExpandFilter != 'undefined') {
            if (emxExpandFilter == 0) {
              model.expandAll();
            } else {
              model.expandNLevels({
                numberOfLevelsToExpand: emxExpandFilter
              });
            }
          } else {
            model.expandNLevels({
              numberOfLevelsToExpand: 1
            });
          }
        }
        model.onPreExpand(this.onPreExpandFunction.bind(this));

        //TODO:
        // remove these globals settings once the global references as handled
        window.dataGridModel = model;
        window.urlUtils = URLUtils;

        return model;
      },

      createDataGrid: function(model, cols, typeRepsArray) {
        var rowSelection = URLUtils.getParameter("selection");
        if (!rowSelection) {
          rowSelection = "none";
        }

        // Create the DataGridView

        var uniqueIdentifierName = (URLUtils.getParameter("table") != undefined && URLUtils.getParameter("table") != "") ? URLUtils.getParameter("table") : URLUtils.getParameter("tableMenu");
        var that = this;
        var dataGridView = new DataGridView({
          identifier: uniqueIdentifierName,
          treeDocument: model,
          columns: cols,
          showModelChangesFlag: true,
          showTreeIconsFlag: false,
          rowSelection: rowSelection,
          defaultColumnDef: {
            width: 'auto',
            minWidth: 40,
            resizableFlag: true,
            sortableFlag: true,
            allowUnsafeHTMLContent: false,
            getCellEditableState: function(cellInfos) {
              if (!cellInfos) {
                return false;
              }
              var editableFlagFromColumn = dataGridView.layout.getColumnEditableFlag(cellInfos.columnID); // Setting 'Editable' at column level.

              var editFalseForRootNode = cellInfos.nodeModel.options.grid.dgEditNode == 'false'; // URL parameter 'editRootNode'.

              var dataIndex = this.layout.getDataIndexFromColumnIndex(this.layout.getColumnIndex(cellInfos.columnID)); // columnID can be columnIndex or dataIndex, but inside this function it will always be columnIndex.
              dataIndex = (dataIndex == "tree") ? "treeLabel" : dataIndex;
              var editableFlagAtRowLevel;
              if (cellInfos.nodeModel.options.grid.dgEditAccess != undefined)
                editableFlagAtRowLevel = cellInfos.nodeModel.options.grid.dgEditAccess[dataIndex] == 'true'; // Settings - 'Edit Access Mask' and 'Edit Access Program/Function' at row level.
              else
                editableFlagAtRowLevel = false;
              return editableFlagFromColumn && !editFalseForRootNode && editableFlagAtRowLevel;
            },
            getCellValueForExport: function(cellInfos) {
              var ret = "";
              var columnName = dataGridView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
              if (cellInfos.nodeModel.options.grid[columnName + "_export"]) {
                ret = cellInfos.nodeModel.options.grid[columnName + "_export"];
              } else if (cellInfos.cellModel.label) {
                ret = cellInfos.cellModel.label;
              } else {
                ret = cellInfos.cellModel;
              }

              return ret;
            },
          },
          rowGroupingOptions: {
            depth: numberOfNodesByDepth
          },
          onContextualEvent: that.onContextualEvent.bind(that),
          getCellTooltip: function(cellInfos) {
        	  var leafColumn = dgView.layout.getLeafColumns()[cellInfos.columnID];
            	if (cellInfos.nodeModel == undefined && cellInfos.rowID == -1 && leafColumn.icon != undefined) {
      			return {shortHelp: leafColumn.tooltip, updateModel: false};
      		  } else {
      			return dataGridView.getCellDefaultTooltip(cellInfos);
      			if(leafColumn.tooltip != undefined){
					return {shortHelp: leafColumn.tooltip, updateModel: false};
				}else{
					return dataGridView.getCellDefaultTooltip(cellInfos);
				}

      		  }
          },
          selectionMode: 'cell'
        });

		dataGridView.layout.getLeafColumns().every(function(indColumn) {
			if (indColumn.droppable/*draggable*/ === 'true' && typeof indColumn.dropRelationships != 'undefined' && typeof indColumn.dropDirections != 'undefined') {
				connector.prototype.droppable/*draggable*/ = true;
				connector.prototype.dropTypesHierarchy = indColumn.dropTypesHierarchy;
				connector.prototype.dropAction = indColumn.dropAction;
				connector.prototype.dropItems = indColumn.dropItems;
				connector.prototype.dropRelationshipsArray = indColumn.dropRelationships.split(',');
				connector.prototype.dropDirectionsArray = indColumn.dropDirections.split(',');
				return false;
			} else {
				return true;
			}
		});

		if (gridType != 'NONE' && true === connector.prototype.droppable/*draggable*/) {
			dataGridView.cellDragEnabledFlag = true;
			dataGridView.onDragStartCell = function(event, cellInfo) {
				if (StandardFunctions._privateGetSelectedNodes().length > 0) {
					connector.prototype.draggedItems = StandardFunctions._privateGetSelectedNodes();
				} else {
					connector.prototype.draggedItems = new Array(cellInfo.nodeModel);
				}

				event.dataTransfer.setData('text', 'drag started');
	            /*this.draggedItems.forEach(function(draggedItem) { //as removing dropJPO code
	            	draggedItem.options.grid['dgvDraggedFromWindow'] = window.name;
	            });*/
			};
			dataGridView.onDragOverCell = function(event, cellInfo) {
				event.preventDefault();
			};
			dataGridView.onDropCell = function(event, cellInfo) {
				//var dropTypes = dgView.layout.getLeafColumns()[0].dropTypes; //not needed

				if (connector.prototype.draggedItems.length == 0 || (connector.prototype.dropItems == "Single" && connector.prototype.draggedItems.length > 1)) {
					event.preventDefault();
					return;
				}

				for (var i = 0; i < connector.prototype.draggedItems.length; i++) {
					var draggedItem = connector.prototype.draggedItems[i];
					if(draggedItem._parentNode === cellInfo.nodeModel) {
						return false;
					}
				}

				if (typeof connector.prototype.dropTypesHierarchy != 'undefined') {
					var finalDropTypesArray = new Array();
					var finalDropRelationshipsArray = new Array();
					var finalDropDirectionsArray = new Array();

					var dropTypeNamesGroups = connector.prototype.dropTypesHierarchy.split(',');
					for (var i = 0; i < dropTypeNamesGroups.length; i++) {
						var dropTypeNamesGroup = dropTypeNamesGroups[i];
						dropTypeNamesGroup.split('->').forEach(function(dropTypeName) {
							finalDropTypesArray.push(dropTypeName);
							finalDropRelationshipsArray.push(connector.prototype.dropRelationshipsArray[i]);
							finalDropDirectionsArray.push(connector.prototype.dropDirectionsArray[i]);
						});
					}

					connector.prototype.draggedItems.forEach(function(draggedItem) {
						var found = false;

						for (var i = 0; i < finalDropTypesArray.length; i++) {
							if (finalDropTypesArray[i] == draggedItem.options.grid.type) {
			                    /*var colName = dgView.layout.getDataIndexFromColumnIndex(cellInfo.columnID); //as removing dropJPO code
			                    if(colName == 'tree') {
			                    	colName = dgView.layout.getLeafColumns()[0].clDgvColumnName;
			                    }

			                    draggedItem.options.grid['dgvDroppedOnColumnName'] = colName;*/
								draggedItem.options.grid['dgvStructChangesRelName'] = finalDropRelationshipsArray[i]; //has to be according to index of DropTypes, not DropTypesHierarchy - fix later
								draggedItem.options.grid['dgvStructChangesRelDirection'] = finalDropDirectionsArray[i]; //has to be according to index of DropTypes, not DropTypesHierarchy - fix later
								/*draggedItem.options.grid['dgvDroppedOnWindow'] = window.name;*/ //as removing dropJPO code
								found = true;
								break;
							}
						}

						if (!found) {
							event.preventDefault();
							return;
						}
					});
				}

				var commitPaste = URLUtils.getParameter('pasteCommited');
				if (StandardFunctions.isNullOrEmpty(commitPaste) || commitPaste != 'true') {
					commitPaste = false;
				} else {
					commitPaste = true;
				}

				var logsDialog = new WUXDialog({
					title: nlsMessageJSON.title,
					immersiveFrame: new WUXImmersiveFrame().inject(document.body),
					modalFlag: true,
					buttons: {
						/*actually Copy*/
						Ok: new WUXButton({
							label: nlsMessageJSON.copy,
							onClick: function(event) {
								if(typeof connector.prototype.dropAction != 'undefined' && connector.prototype.dropAction.split(',').indexOf('Copy') == -1) {
									event.preventDefault();
									return;
								}

								StandardFunctions.dropCells(connector.prototype.draggedItems, cellInfo.nodeModel, 'Copy' /*action*/ , commitPaste);
								connector.prototype.draggedItems.forEach(function(draggedItem) {
									delete draggedItem.options.grid.dgvStructChangesRelName;
									delete draggedItem.options.grid.dgvStructChangesRelDirection;
								});

								connector.prototype.draggedItems = new Array();
								event.dsModel.dialog.close();
								event.dsModel.dialog.destroy();
							}
						}),
						/*actually Move*/
						Apply: new WUXButton({
							that: this,
							label: nlsMessageJSON.move,
							onClick: function(event) {
								if(typeof connector.prototype.dropAction != 'undefined' && connector.prototype.dropAction.split(',').indexOf('Move') == -1) {
									event.preventDefault();
									return;
								}

								StandardFunctions.dropCells(connector.prototype.draggedItems, cellInfo.nodeModel, 'Move' /*action*/ , commitPaste);
								connector.prototype.draggedItems.forEach(function(draggedItem) {
									delete draggedItem.options.grid.dgvStructChangesRelName;
									delete draggedItem.options.grid.dgvStructChangesRelDirection;
								});

								connector.prototype.draggedItems = new Array();
								event.dsModel.dialog.close();
								event.dsModel.dialog.destroy();
							}
						}),
						Cancel: new WUXButton({
							label: nlsMessageJSON.cancel,
							onClick: function(event) {
								connector.prototype.draggedItems = new Array();
								event.dsModel.dialog.close();
								event.dsModel.dialog.destroy();
							}
						})
					}
				});

				event.dataTransfer.clearData();
			};
		}


		/*model.prepareUpdate();
		 //TODO push below code to another file

        var typeTemplate = {
          tweakerButtonIcon: {
            path: 'DS/ENXDataGrid/TweakerButtonIcon',
            options: {}
          },
          rmbMenuTweaker: {
            path: 'DS/ENXDataGrid/TweakerButtonIcon',
            options: {}
          }

        };
        var typeReps = {
          "actionButtonNewWindow": {
            "stdTemplate": "tweakerButtonIcon",
            "semantics": {
              "icon": "../../common/images/iconActionNewWindow.gif",
              "displayStyle": "buttonIcon"
            },
            "tooltip": {
              "text": "New Window",
              "position": "Bottom"
            }
          }
        }
        dataGridView.getTypeRepresentationFactory().registerTypeTemplates(typeTemplate);
        dataGridView.getTypeRepresentationFactory().registerTypeRepresentations(typeReps);*/

		model.withTransactionUpdate(function(){
			if (typeRepsArray) {
		          for (var i = 0; i < typeRepsArray.length; i++) {
		            var typeRepObject = {};
		            typeRepObject[typeRepsArray[i].id] = {
		              "semantics": JSON.parse(typeRepsArray[i].dataelements.semantics),
		              "stdTemplate": typeRepsArray[i].dataelements.standardTemplate
		            }
		            dataGridView.getTypeRepresentationFactory().registerTypeRepresentations(typeRepObject);
		          }
		        }
		});


        //model.pushUpdate();
        return dataGridView;
      },

      //triggered on the right click of the cell or column in
      onContextualEvent: function onContextualEvent(params) {
        var scope = this;
        return new UWA.Promise(function(resolve, reject) {
          if (URLUtils.getParameter("showRMB") != "false") {
            var menu = [];

            var cellInfos = params.cellInfos;
            if (params && params.collectionView) {


              if (cellInfos.rowID != -1) {
                var type = cellInfos.nodeModel.options.grid.type;
                var cellID = cellInfos.nodeModel.options.grid.id;

                var relId = (cellInfos.nodeModel.options.grid.relId != undefined) ? cellInfos.nodeModel.options.grid.relId : "";

                var rowId = cellInfos.nodeModel.options.grid.rowId;
                rowId = (typeof rowId === "undefined") ? cellInfos.rowID : rowId;

                var parentObject = cellInfos.nodeModel.getParent();
                var parentId;
                if (typeof parentObject != "undefined") {
                  parentId = (parentObject.options.grid.id != undefined) ? parentObject.options.grid.id : "";
                }

                var emxTableRowId = relId + "|" + cellID + "|" + parentId + "|" + rowId;
                emxTableRowId = encodeURI(emxTableRowId);

                var rmbMenuServiceURL = "../../resources/v1/ui/rmbMenu/getRMBMenu?RMB_ID=" + cellID + "&frmRMB=true&rmbTableRowId=" + emxTableRowId + "&uiType=structureBrowser&currentView=detail&sbMode=view&IsStructureCompare=FALSE";
                var supportedMenus = [];
                var dataEntries, dataModule, dataFunction;

                var queryOptions = {
                  type: 'json',
                  onComplete: function(jsonData) {

                    var entries;
                    entries = jsonData.data[0].relateddata.entries;
                    supportedMenus = scope.createSupportedMenusArray.call(scope, entries, supportedMenus);

                    supportedMenus.forEach(function(menuItem) {

                      if (menuItem.label == "separator") {
                        menu.push({
                          type: 'SeparatorItem',
                          title: ''
                        });
                      } else {

                        if (menuItem.children.length <= 0) {
                          menu.push({
                            type: 'PushItem',
                            title: menuItem.label,
                            icon: "../" + menuItem.icon,
                            action: {
                              context: {
                                cellInfos: params.cellInfos,
                                menuDetails: menuItem
                              },
                              callback: function(d) {

                                scope.rmbCallback(d);

                              }
                            }

                          })
                        }

                        scope.mySubMenuBuilder(menu, menuItem, params);
                      }


                    });

                    resolve(menu);

                  },

                  onError: function() {
                    alert("response failed");
                  }

                }
                WAFData.authenticatedRequest(rmbMenuServiceURL, queryOptions);
              } else if (cellInfos.rowID == -1) {
                menu = params.collectionView.buildDefaultContextualMenu(params);
                resolve(menu);
              }
            }

          }

        })


      },


      setHeader: function(header, isSubHeader) {
        if (this.uiPanel.header == null) {
          this.uiPanel.header = new UWA.Element('div');
        }
        if (header) {
          if (isSubHeader) {
            new UWA.Element('h3', {
              text: header
            }).inject(this.uiPanel.header);
          } else {
            new UWA.Element('h1', {
              text: header
            }).inject(this.uiPanel.header);
          }
        }
      },

      setCancelButton: function(label) {
      	JQuery(".wux-windows-immersive-frame").css("bottom", "52px");
        var cancelButton = JQuery('<button type="button" class="btn btn-default">' + label + '</button>');
        cancelButton.click(function() {
          top.close();
        });

        cancelButton.appendTo(JQuery(".modal-footer"));
      },

      setSubmitButton: function(label, url) {
      	JQuery(".wux-windows-immersive-frame").css("bottom", "52px");
        var doneButton = JQuery('<button type="button" class="btn btn-primary">' + label + '</button>');
        doneButton.click(function() {
          StandardFunctions.executeListHiddenSubmitAction({
            "href": url.replace(/%2F/gi, "/")
          });
        });
        doneButton.appendTo(JQuery(".modal-footer"));

      },


      /**
      // TODO - as setToolbar method belongs to toolbarClient, it has to be moved to ENXSBToolbarClient.js
      **/
      setToolbar: function(newToolbar) {
        var that = this;
        if (this.uiPanel.header == null) {
          this.uiPanel.header = new UWA.Element('div');
        }

        dgToolbar = this.gridView.setToolbar(newToolbar);
        dgToolbar.inject(this.uiPanel.header);

        addEventListenersTo.forEach(function(nodeModelEntry) {
          // First, we need to retrieve the nodeModel corresponding to the comboBox
          var nodeModel = dgToolbar.getNodeModelByID(nodeModelEntry.nodeModelId);

          if (typeof nodeModel != 'undefined') {
            //add callback to the nodeModel, which will be called every time an attribute is modified in the model
            nodeModel.onAttributeChange(function(e) {
              //require(['DS/ENXSBGridConnector/StandardFunctions'], function(StandardFunctions) {
              var nodeModelData = e.target.options.grid.data;

              var args = {
                context: e.target,
                href: nodeModelEntry.argument.href,
                methodArgs: nodeModelData
              };
              StandardFunctions.executeJSAction(args);
              //});
            });
          }
        });

        var customHandlersForTableViews = [tableViewEventListener, expandProgramViewEventListener];
        customHandlersForTableViews.forEach(function(viewEventListener) {
          viewEventListener.forEach(function(nodeModelEntry) {
            // First, we need to retrieve the nodeModel corresponding to the comboBox
            var nodeModel = dgToolbar.getNodeModelByID(nodeModelEntry.nodeModelId);

            if (typeof nodeModel != 'undefined') {
              //add callback to the nodeModel, which will be called every time an attribute is modified in the model
              nodeModel.onAttributeChange(function(e) {
                var nodeModelData = e.target.options.grid.data;
                var typeRepString = e.target.options.grid.typeRep;
                var possibleValues = that.gridView.getTypeRepresentationFactory().typeReps[typeRepString].semantics.possibleValues;
                var attributeActualValue;
                for (var i in possibleValues) {
                  if (nodeModelData == possibleValues[i].value) {
                    attributeActualValue = possibleValues[i].actualValue;
                  }
                }
                var executeModule = nodeModelEntry.argument.module;
                var executeFunction = nodeModelEntry.argument.func;
                var argument = nodeModelEntry.argument.urlParam;

                require([executeModule], function(requiredModule) {
                  var func = requiredModule[executeFunction];
                  if (func && typeof func === 'function') {
                    console.log(typeof func);
                    func.call(requiredModule, argument, attributeActualValue);
                  }

                });
              });
            }
          });

        });
        return dgToolbar;
      },

      mySubMenuBuilder: function(menu, menuItem, params) {

        if (menuItem.children.length > 0) {
          var subMenu = [];

          this.myMenuBuilder.call(this, subMenu, params, menuItem.children);


          menu.push({
            type: 'PushItem',
            title: menuItem.label,
            icon: "../" + menuItem.icon,
            submenu: subMenu
          })
          //		        this.mySubMenuBuilder(subMenu,);
        }

      },

      myMenuBuilder: function(menu, params, menuItems) {
        var that = this;
        for (var i = 0; i < menuItems.length; i++) {
          var menuItem = menuItems[i];
          menu.push({
            type: 'PushItem',
            title: menuItem.label,
            icon: "../" + menuItem.icon,
            action: {
              context: {
                cellInfos: params.cellInfos,
                menuDetails: menuItem
              },
              callback: function(d) {

                that.rmbCallback(d);

              }
            }

          })
        }

      },

      //	    on click of a command evaluate the params and call the method
      rmbCallback: function(value) {
        console.log("the value of this here: ");
        console.log(value);
        var executeModule = value.context.menuDetails.dataModule;
        var executeFunction = value.context.menuDetails.dataFunction;
        var argument = value.context.menuDetails.argument;
        var rowId = value.context.cellInfos.rowID;
        var id = value.context.cellInfos.nodeModel.options.grid.id;

        require([executeModule], function(requiredModule) {
          var func = requiredModule[executeFunction];
          if (func && typeof func === 'function') {
            console.log(typeof func);
            func.call(requiredModule, argument);
          }

        });
      },


      //	    iterate through the json and create an array of menus and commands for the contextual menu
      createSupportedMenusArray: function(entries, supportedMenus) {

        var that = this;
        for (var i = 0; i < entries.length; i++) {
          var children = [];
          var dataEntries = JSON.parse(entries[i].dataelements.data);
          var menu = {
            id: entries[i].id,
            typeRepresentation: entries[i].dataelements.typeRepresentation,
            label: entries[i].dataelements.label,
            icon: entries[i].dataelements.icon,
            dataModule: dataEntries.module,
            dataFunction: dataEntries.func,
            argument: dataEntries.arguments,
            href: entries[i].dataelements.href,
            children: children

          };

          supportedMenus.push(menu);

          if (entries[i].children.length != 0) {
            var children = [];
            children = that.createSupportedMenusArray(entries[i].children, children);
            menu.children = children;
          }


        }
        return supportedMenus;
      },

      saveEdits: function() {
        var url = '../../resources/v1/ui/gridview?massPromoteDemote=true&relationships=&filterGlobal=&toolbar=IssueToolBar&selection=multiple&table=IssueList&freezePane=Name,Edit,NewWindow&program=emxCommonIssue:getIssuescockpitItems&header=emxFramework.String.IssuesSummary&suiteKey=Framework&ticket=ST-60-94hsuiCZKxMHsVE6rFcZ-cas';
        var saveEditedObjects = {
          method: 'PUT',
          data: JSON.stringify(editMap),
          onComplete: function(result) {
            console.log("request sent to save" + result);
          }

        }
        WAFData.authenticatedRequest(url, saveEditedObjects);
      },

      reloadPossibleValues: function(cellInfos) {
    	var possibleValues;
    	if(cellInfos.nodeModel.options.relData != undefined && cellInfos.nodeModel.options.relData[0].reloadPossibleValues != undefined){
    		var dataelements = cellInfos.nodeModel.options.relData[0].reloadPossibleValues[0].dataelements;
            var columnName = dgView.layout.getLeafColumns()[cellInfos.columnID].id;

            if(dataelements != undefined && dataelements[columnName] != undefined){
            	possibleValues = JSON.parse(dataelements[columnName]).possibleValues;
            	if(!ifExistsInArray(cellInfos.cellModel)){
            		possibleValues.push({'actualValue':cellInfos.cellModel,"value":cellInfos.cellModel});
            	}
            return {
                  possibleValues: possibleValues
                };
            }
            else{
            	return null;
            }

           function ifExistsInArray(searchValue){
          	  for (var i = 0; i < possibleValues.length; i++) {
            		if (possibleValues[i].actualValue === searchValue) {
            			return true;
            		}
            	}
          	  return false;
            }
    	}


      },

      /**
       * This method processes the response data from the 6WFramework webservice to a format accepted by the DataGrid component
       * @param {Object} result - JSON object response from the webservice
       */
      processWebServiceData: function(result) {
        var connectorStartTime = performance.now();
        console.log(result);

        var rows = [],
          columns = [],
          columnsForDisplayModes = [],
          children = [],
          typeRepsArray = [];
        var displayViewColumnsArray = [];
        var preProcessEditableFlag, preProcessMessage, preProcessMessageType;

        var dataSize = result.data.length;
        // iterate only when the data array has more than one element
        if (dataSize >= 1) {
          var rowData, columnData;
          for (var i = 0; i < dataSize; i++) {
            rowData = result.data[i].relateddata.rowData;
            columnData = result.data[i].relateddata.columns;
            preProcessEditableFlag = (result.data[i].relateddata.preProcessDetails[0].dataelements.action == 'continue');
            preProcessMessage = result.data[i].relateddata.preProcessDetails[0].dataelements.message;
            preProcessMessageType = (preProcessEditableFlag === true) ? 'success' : 'error';
            typeRepsArray = result.data[i].relateddata.typeRepresentations;

            performanceLogs['serverLogs'] = result.data[i].relateddata.performanceLogs;
            /*
            var dateColumns = new Array();
            for (var j = 0; j < columnData.length; j++) {
              if (columnData[j].dataelements.typeRepresentation == "date" || columnData[j].dataelements.typeRepresentation == "datetime") {
                dateColumns.push(columnData[j].id);
              }
            }
			*/
            for (var j = 0; j < rowData.length; j++) {
              /*if (rowData[j].dataelements.typeIcon == undefined) {
                rowData[j].dataelements.typeIcon = ""
              }

              this.processChildsTypeIcon(rowData[j]);
*/
            	rows.push(rowData[j]);
            }

            columns = ConnectorColumnManagement.mapColumns(columnData, preProcessEditableFlag, displayViewColumnsArray);
            columnsForDisplayModes = ConnectorColumnManagement.getColumnsForDisplayModes();
          }
        }

        var connectorGridTime = (performance.now() - connectorStartTime);
        performanceLogs['clientLogs'] = {};
        performanceLogs['clientLogs']['connectorGridTime'] = connectorGridTime;
        console.log("time taken for the gridConnector:" + connectorGridTime + "ms");

        if (typeof result.data[0].dataelements.gridType != 'undefined') {
          gridType = result.data[0].dataelements.gridType;
        }

        var renderGridStartTime = performance.now();

        this.process(document.body, rows, columns, typeRepsArray, columnsForDisplayModes);
        if ("true" != URLUtils.getParameter("portalMode") || "false" != URLUtils.getParameter("showPageHeader") || URLUtils.getParameter("treeLabel").length == 0) {
          if (result.data[0].dataelements.header != "") {
            this.setHeader(result.data[0].dataelements.header, false);
          }
          if (result.data[0].dataelements.subHeader != "") {
            this.setHeader(result.data[0].dataelements.subHeader, true);
          }
        }

        var submitURL = URLUtils.getParameter("submitURL");
        if (submitURL != null && submitURL.length > 0) {
          this.setSubmitButton(result.data[0].dataelements.submitLabel, submitURL);
        }

        var cancelLabel = URLUtils.getParameter("cancelLabel");
        if (cancelLabel != null && cancelLabel.length > 0) {
          this.setCancelButton(result.data[0].dataelements.cancelLabel);
        }

        var renderGridTime = (performance.now() - renderGridStartTime);
        performanceLogs['clientLogs']['renderGridTime'] = renderGridTime;

        if (typeof preProcessMessage != 'undefined' && preProcessMessage !== null) {
          require(['DS/ENXSBGridConnector/StandardFunctions'], function(StandardFunctions) {
            StandardFunctions.showTransientMessage(preProcessMessage, preProcessMessageType);
          });
        }
      },

      // method to handle typeIcon property for the dataelements of children.
      // If there is no typeIcon property then set an empty string by default
      processChildsTypeIcon: function(rowData) {
        if (rowData.children.length > 0) {
          for (var i = 0; i < rowData.children.length; i++) {
            var childData = rowData.children[i];
            if (childData.dataelements.typeIcon == undefined) {
              childData.dataelements.typeIcon = ""
            }

            this.processChildsTypeIcon(childData);
          }
        }
      }


    });

    connector.prototype.dataGridDisplayDetails= function() {
        Utils.saveDataInLocalPreferences(dgView, "wux-collectionView-dataGridView", "displayView", "details");
        var toolbarRef = StandardFunctions.getToolbarReference();
        if (toolbarRef != undefined) {
          StandardFunctions.updateToolbarEntry("DataGridDisplayDetails", '[{"icon":"../../common/images/utilCheckboxChecked.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayThumbnail", '[{"icon":"../../common/images/iconActionThumbnail-view.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayGraph", '[{"icon":"../../common/images/iconActionGraphView.png"}]');
          toolbarRef.getNodeModelByID("DataGridWrapCommand").updateOptions({
            disabled: undefined
          }); //cannot do it with StandardFunctions.updateToolbarEntry, as undefined can't be passed in a JSON string
        }

        var immersiveFrameContainer = document.body.getElementsByClassName("wux-controls-abstract wux-windows-immersive-frame wux-ui-is-rendered");
        var tableContainer;
        if (immersiveFrameContainer.length > 1) {
//          tableContainer = immersiveFrameContainer[immersiveFrameContainer.length - 1];
          tableContainer = immersiveFrameContainer[1];
        } else {
          var tempContainer = document.body.getElementsByClassName("wux-layouts-collectionview")[0];
          if (tempContainer != undefined && tempContainer.getAttribute("layout") != "ResponsiveThumbnailsCollectionViewLayout")
            tableContainer = tempContainer
        }


        //var divTable = document.body.getElementsByClassName("wux-layouts-collectionview wux-controls-abstract wux-layouts-datagridview")[0];
        var divThumbnail = document.getElementById("divThumbnail");
        var divEGraph = document.getElementById("divEGraph");

        if (typeof tableContainer == "undefined") {
          var divTable = document.body.getElementsByClassName("wux-windows-window-content wux-element-contentbox")[0];
          var immersiveFrame = new WUXImmersiveFrame().inject(divTable);
          this.createDataGridTable(dgView, dataGridModel, immersiveFrame);
        } else {
          tableContainer.style.display = "block";
        }
        if (typeof divThumbnail != "undefined" && divThumbnail != null)
          divThumbnail.style.display = "none";
        if (typeof divEGraph != "undefined" && divEGraph != null)
          divEGraph.style.display = "none";
      },

    connector.prototype.dataGridDisplayThumbnail= function() {
        Utils.saveDataInLocalPreferences(dgView, "wux-collectionView-dataGridView", "displayView", "thumbnail");
        var toolbarRef = StandardFunctions.getToolbarReference();
        if (toolbarRef != undefined) {
          StandardFunctions.updateToolbarEntry("DataGridDisplayThumbnail", '[{"icon":"../../common/images/utilCheckboxChecked.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayGraph", '[{"icon":"../../common/images/iconActionGraphView.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayDetails", '[{"icon":"../../common/images/iconActionTreeListView.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridWrapCommand", '[{"disabled": "true"}]');
        }


        StandardFunctions.refreshColumnValues("DataGridImageTable.Image",true,false)
        .then(function(){
        	var nodes = StandardFunctions._privateGetNodesBase(true);
        	ENXThumbnailGridViewBuilder.createThumbnailGridView(displayModesColumnsArray, nodes);
        });

      },

      connector.prototype.dataGridDisplayGraph= function() {
        Utils.saveDataInLocalPreferences(dgView, "wux-collectionView-dataGridView", "displayView", "graph");
        var toolbarRef = StandardFunctions.getToolbarReference();
        if (toolbarRef != undefined) {
          StandardFunctions.updateToolbarEntry("DataGridDisplayGraph", '[{"icon":"../../common/images/utilCheckboxChecked.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayThumbnail", '[{"icon":"../../common/images/iconActionThumbnail-view.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridDisplayDetails", '[{"icon":"../../common/images/iconActionTreeListView.png"}]');
          StandardFunctions.updateToolbarEntry("DataGridWrapCommand", '[{"disabled": "true"}]');
        }


        //TODO
        // this graph is a global variable declred in ENXSBGridConnectionHTML.js.
        // It is a workaround to get the graph instance in the eGraph toolbar functions in StandardFunctions
        // this has to be modified either when the Techno provides a hook to access the graph instance in the toolbar arguments
        // or during architectural change
        StandardFunctions.refreshColumnValues("DataGridImageTable.Image",true,false)
        .then(function(){
        	var nodes = StandardFunctions._privateGetNodesBase(true);
        	ENXGraphBuilder.createGraphView(displayModesColumnsArray, nodes);
        });
      }

    return connector;

  });

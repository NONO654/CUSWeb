define('DS/ENOChgActionGridUX/scripts/Utils/ChgChangeActionUtil',
  ['DS/ENOChgServices/scripts/services/ChgInfraService',
    'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
    'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar'
  ],
  function (ChgInfraService, APP_NLS,ChgDataGridViewToolbar) {
    'use strict';
    var service = Object.create(null);
    service.currentView = "Grid";
    service.previousView = "Grid";
    // Method to define the column's definition for data grid view
    service.getColumns = function () {
      //COLUMNS SETTINGS
      var cols = [{
        "text": APP_NLS.CHG_Column_Tittle,
        "dataIndex": "tree",
        editableFlag: false,
        alwaysVisibleFlag:true,
        //icon: [],
        pinned: "left",
		    width:150
      },
  /*    {
        "text": APP_NLS.CHG_Column_Name,
        "dataIndex": "name",
        editableFlag: false
      },*/
      {
            "text": APP_NLS.CHG_Column_Name,
            "dataIndex": "ca_name",
            editableFlag: false,
            "allowUnsafeHTMLContent":true
      },
      {
        "text": APP_NLS.CHG_Column_Maturity,
        "dataIndex": "maturity",
        editableFlag: false,
        "compareFunction": function (valueA, valueB, treeNodeModelA, treeNodeModelB, dataIndex) {
          if (treeNodeModelA.options.grid.stateGrade != "undefined"
            && treeNodeModelB.options.grid.stateGrade != "undefined") {
            if (treeNodeModelA.options.grid.stateGrade == treeNodeModelB.options.grid.stateGrade) {
              return 0;
            }
            if (treeNodeModelA.options.grid.stateGrade < treeNodeModelB.options.grid.stateGrade) {
              return -1;
            }
            return 1;
          }
          return 0;
        }
      },
    /*  {
        "text": APP_NLS.CHG_Column_Severity,
        "dataIndex": "severity",
        editableFlag: false,
        "compareFunction": function (valueA, valueB, treeNodeModelA, treeNodeModelB, dataIndex) {
          if (treeNodeModelA.options.grid.severityGrade != "undefined"
            && treeNodeModelB.options.grid.severityGrade != "undefined") {
            if (treeNodeModelA.options.grid.severityGrade == treeNodeModelB.options.grid.severityGrade) {
              return 0;
            }
            if (treeNodeModelA.options.grid.severityGrade < treeNodeModelB.options.grid.severityGrade) {
              return -1;
            }
            return 1;
          }
          return 0;
        },
          "getCellKPIColor":function(cellinfo){
         var severityGrade = cellinfo.nodeModel.getAttributeValue("severityGrade");
         if(severityGrade==1){
           return "orange";
         }else if(severityGrade==2){
           return "red";
         }else{
           return "green";
         }
        }
      },*/
      {
        "text": APP_NLS.CHG_Column_Severity,
        "dataIndex": "sev",
        editableFlag: false,
        "allowUnsafeHTMLContent":true,
        "compareFunction": function (valueA, valueB, treeNodeModelA, treeNodeModelB, dataIndex) {
          if (treeNodeModelA.options.grid.severityGrade != "undefined"
            && treeNodeModelB.options.grid.severityGrade != "undefined") {
            if (treeNodeModelA.options.grid.severityGrade == treeNodeModelB.options.grid.severityGrade) {
              return 0;
            }
            if (treeNodeModelA.options.grid.severityGrade < treeNodeModelB.options.grid.severityGrade) {
              return -1;
            }
            return 1;
          }
          return 0;
        }
      },
      {
        "text": APP_NLS.CHG_Column_DueDate,
        "dataIndex": "dueDate",
        "typeRepresentation": "date",
        editableFlag: false
      },
      /*{
        "text": APP_NLS.CHG_Column_Owner,
        "dataIndex": "responsible",
        editableFlag: false
      },*/
      {
        "text": APP_NLS.CHG_Column_UserRole,
        "dataIndex": "userRole",
        editableFlag: false,
        "visibleFlag":false
      },
      /*{
        "text":APP_NLS.CHG_Column_Recent,
        "dataIndex": "recent",
        //"typeRepresentation": "icon",
        editableFlag: false,
        "visibleFlag":false
      },*/
      {
        "text":APP_NLS.CHG_Column_Assignees,
        "dataIndex": "assignees",
        editableFlag: false,
        "allowUnsafeHTMLContent":true
      },
      {
        "text":APP_NLS.CHG_Column_Reviewers,
        "dataIndex": "reviewers",
        editableFlag: false,
        "allowUnsafeHTMLContent":true
      },
      {
        "text":APP_NLS.CHG_Column_Followers,
        "dataIndex": "followers",
        editableFlag: false,
        "allowUnsafeHTMLContent":true,
        "visibleFlag":false
      },
      {
        "text":APP_NLS.CHG_Column_Responsible,
        "dataIndex": "user",
        editableFlag: false,
        "allowUnsafeHTMLContent":true
      },
	  {
        "text":APP_NLS.CHG_Column_Referential,
        "dataIndex": "referential",
        "typeRepresentation": "icon",
        editableFlag: false,
        "visibleFlag":true
      }
      ];

      return cols;
    };

    /*
       * Method to change the view
       */
    service.changeView = function(view){

      if(view == "GridView"){
         this.currentView = "Grid";
         var viewIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
         if(viewIcon && viewIcon.options.grid.semantics.icon.iconName != "view-list"){
           viewIcon.updateOptions({
             grid: {
               semantics:{
                 icon:{
                   iconName: "view-list"
                 }
               }
             }
           });
         }

        var gridViewIcon = document.querySelector(".toolbar-ca-div .wux-ui-3ds-view-list");
        if(gridViewIcon){
          gridViewIcon.addClassName("currentView");
        }

        var tileViewIcon = document.querySelector(".toolbar-ca-div .wux-ui-3ds-view-small-tile");
        if(tileViewIcon){
          tileViewIcon.removeClassName("currentView");
        }

        var gridView = document.querySelector(".cagridView");
        if(gridView){
          gridView.removeClassName("hideView");
          gridView.removeClassName("nonVisible");
          gridView.addClassName("showView");
        }

        var tileView = document.querySelector(".catileView");
        if(tileView){
          tileView.removeClassName("showView");
          tileView.addClassName("hideView");
        }

      } else if(view == "TileView"){
          this.currentView = "Tile";
          var viewIcon = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
          if(viewIcon && viewIcon.options.grid.semantics.icon.iconName != "view-small-tile"){
            viewIcon.updateOptions({
              grid: {
                semantics:{
                  icon:{
                    iconName: "view-small-tile"
                  }
                }
              }
            });
          }

        var gridViewIcon = document.querySelector(".toolbar-ca-div .wux-ui-3ds-view-list");
        if(gridViewIcon){
          gridViewIcon.removeClassName("currentView");
        }

         var tileViewIcon = document.querySelector(".toolbar-ca-div .wux-ui-3ds-view-small-tile");
         if(tileViewIcon){
           tileViewIcon.addClassName("currentView");
         }

         var gridView = document.querySelector(".cagridView");
         if(gridView){
           gridView.removeClassName("showView");
           gridView.addClassName("hideView");
         }

         var tileView = document.querySelector(".catileView");
         if(tileView){
           tileView.removeClassName("hideView");
           tileView.addClassName("showView");
         }
      }
    };

    return service;
  });

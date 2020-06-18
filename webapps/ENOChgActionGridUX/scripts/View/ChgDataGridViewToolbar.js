/*
 * @module 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar'
 */



define('DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
  ['i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS'

  ],
  function (APP_NLS) {
    var exports = Object.create(null);
    exports.toolbar = null;

    exports.sortingData = {
          menu:[
          {
            type:'PushItem',
            title: APP_NLS.CHG_Column_Severity,
            fonticon: {
              family:1,
              content:"wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z"
            },
            action: {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'sortBySeverity'
            }
          },
          {
            type:'PushItem',
            title: APP_NLS.CHG_Column_Maturity,
            fonticon: {
              family:1,
              content:"wux-ui-3ds wux-ui-3ds-alpha-sorting-a-z"
            },
            action: {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'sortByMaturity'
            }
          }
        ]};

        exports.viewData = {
              menu:[
              {
                type:'PushItem',
                title: "Grid View",
                fonticon: {
                  family:1,
                  content:"wux-ui-3ds wux-ui-3ds-view-list"
                },
                action: {
                  module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
                  func: 'changeView'
                },
                tooltip:"Grid View"
              },
              {
                type:'PushItem',
                title: "Tile View",
                fonticon: {
                  family:1,
                  content:"wux-ui-3ds wux-ui-3ds-view-small-tile"
                },
                action: {
                  module: 'DS/ENOChgActionGridUX/scripts/View/ChgTileViewLayout',
                  func: 'changeView'
                },
                tooltip:"Tile View"
              }
            ]};

    // writing the toolbar definition
    exports.writetoolbarDefination = function () {
      var defination = {
        "entries": [
          {
            "id": "back",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "home",
                "fontIconFamily": 1
              }
            },
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'backToSummary',
            },
            "category": "status",
            "tooltip": APP_NLS.CHG_TOOLTIP_HOME
          },
          {
            "id": "StatusRowsCAID",
            "dataElements": {
              "typeRepresentation": "string",
              "value": APP_NLS.CHG_Filter_MyActiveCA
              // "0 " + APP_NLS.CHG_Activity_CA +
              //   " (" + APP_NLS.CHG_Filter + ": " + APP_NLS.CHG_Filter_MyActiveCA + ")"
            },
            readOnly: true,
            "category": "status",
            disabled : true
          },
          {
            "id": "data_service",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "database-new",
                "fontIconFamily": 1
              }
            },
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'changeData',
            },
            "category": "status",
            "tooltip": APP_NLS.CHG_TOOLTIP_RECENT_DATA
          },
          /*{
            "id": "filterBaseCAId",
            "dataElements": {
              "typeRepresentation": "enumSelectionMode",
              "value":APP_NLS.CHG_Filter_MyActiveCA
            },
            "category": "filter",
          },*/
          /*{
            "id": "ID_FilterCA", //for removing OR condition in instance
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "search-similar",
                "fontIconFamily": 1
              },
              "category": "search",
              "position": "near",
              "action": {
                module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
                func: 'onsearchSimilar',
              }
            },
          },*/
          /*  {
              "id": "addNewBlankCAId",
              "className":"mucustome",
              "dataElements": {
                "typeRepresentation": "functionIcon",
                "icon": {
                  "iconName": "plus",
                  "fontIconFamily": 1
                },
                "position": "far",
                "action": {
                  module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
                  func: 'onPlusClick',
                },
                //  "disabled": true,
                "tooltip": "Quick Create"
              }
            },*/
          //DS/CfgMassVariantEffectivityEditor/scripts/CfgTweakerTristate
          {
            "id": "addNewBlankCAId",
            "dataElements": {
              "typeRepresentation": "expandInput",
              "data": "search"
            },
            "position": "far",
            "category": "create",
            "tooltip": APP_NLS.CHG_Quick_CreateCA,
          },
    /*      {
            "id": "addCAwithForm",
            "className": "menuCA",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "doc-add",
                "fontIconFamily": 1
              }
            },
            "position": "far",
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgCreateChangeAction',
              func: 'createChangeAction',
            },
            //  "disabled": true,
            "tooltip": APP_NLS.CHG_CreateCA,
            "category": "create"
          },
    */      /*{
            "id": "refreshCA",
            "className": "menuCA",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "refresh",
                "fontIconFamily": 1
              }
            },
            "position": "far",
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'refreshGrid',
            },
            "tooltip": "Refresh"
          },*/
    /*      {
           "id": "view",
           "className": "menuCA",
           "dataElements": {
             "typeRepresentation": "viewdropdown",
             "value":"List"
           },
           "position": "far",
           "tooltip": "View",
           "category": "View"
         },*/
         {
           "id": "view",
           "className": "menuCA",
           "dataElements": {
             "typeRepresentation": "sortingdropdown",
             "icon": {
               "iconName": "view-legacy-thb",
               "fontIconFamily": 1
             },
             "value":this.viewData
           },
           "position": "far",
           "tooltip": "View",
           "category": "View"
         },
         {
            "id": "sorting",
            "className": "menuCA",
            "dataElements": {
              "typeRepresentation": "sortingdropdown",
              "icon": {
                "iconName": "sorting",
                "fontIconFamily": 1
              },
			        "value":this.sortingData
            },
            "position": "far",
            "tooltip": "Sort",
            "category": "View"
          }
        /*  {
            "id": "gridView",
            "className": "menuCA",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "view-list",
                "fontIconFamily": 1
              }
            },
            "position": "far",
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
              func: 'changeView',
            },
            "tooltip": "Grid View",
            "category": "View"
          },
          {
            "id": "tileView",
            "className": "menuCA",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "view-small-tile",
                "fontIconFamily": 1
              }
            },
            "position": "far",
            "action": {
              module: 'DS/ENOChgActionGridUX/scripts/View/ChgTileViewLayout',
              func: 'changeView',
            },
            "tooltip": "Tile View",
            "category": "View"
          }*/
          // ,
          // {
          //   "id": "eyeToggle",
          //   "className": "menuCA",
          //   "dataElements": {
          //     "typeRepresentation": "functionIcon",
          //     "icon": {
          //       "iconName": "eye",
          //       "fontIconFamily": 1
          //     },
          //   },
          //   "position": "far",
          //   "category": "view"
          // }
          /*{
            "id": "ID_cancelCA", //for removing OR condition in instance
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "wrong",
                "fontIconFamily": 1
              },
              "tooltip": "Cancel",
              "category": "utility",
              "position": "far",
              "action": {
                module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
                func: 'onCancelCA',
              }
            },
          },
          {
            "id": "ID_HoldCA", //for removing OR condition in instance
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "pause",
                "fontIconFamily": 1
              },
              "category": "utility",
              "position": "far",
              "tooltip": "On Hold",
              "action": {
                module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
                func: 'onHoldCA',
              }
            },
          },
          {
            "id": "ID_HoldCA",
            "dataElements": {
              "typeRepresentation": "functionIcon",
              "icon": {
                "iconName": "database-delete",
                "fontIconFamily": 1
              },
              "category": "utility",
              "position": "far",
                "tooltip": "Delete",
              "action": {
                module: 'DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar',
                func: 'onDeleteCA',
              }
            },
          },*/

        ]
        ,
        "typeRepresentations": {
          "enumSelectionMode": {
            "stdTemplate": "comboSelector",
            "semantics": {
              "possibleValues": [
                APP_NLS.CHG_Filter_MyActiveCA,
                APP_NLS.CHG_Filter_MyActiveCAAsAssignee,
                APP_NLS.CHG_Filter_MyActiveCAAsReviewer,
                APP_NLS.CHG_Filter_MyActiveCAAsFollower,
                APP_NLS.CHG_Filter_MyAllCA
              ]
            }
          },

        }
      }
      return JSON.stringify(defination);
    },
    exports.onPlusClick = function (e) {
        console.log("Search functionality");
        //debugger ;
      }

    return exports;
  });

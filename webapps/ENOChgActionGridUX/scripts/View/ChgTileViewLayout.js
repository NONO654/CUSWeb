define("DS/ENOChgActionGridUX/scripts/View/ChgTileViewLayout",
[
  "UWA/Core",
  "DS/Controls/ResponsiveTileView",
  'DS/ENOChgServices/scripts/services/ChgServiceGlobalVariable',
  "DS/ENOChgActionGridUX/scripts/Utils/ChgChangeActionUtil",
  "DS/ENOChgActionGridUX/scripts/View/ChgDataGridViewToolbar"
], function(
  UWA,
  WUXResponsiveTileView,
  ChgServiceGlobalVariable,
  ChgChangeActionUtil,
  ChgDataGridViewToolbar
) {
  "use strict";
  var ChgTileViewLayout = {

    /*
     * Method to change view from Grid View to Tile View Layout
     */
    changeView: function(data) {
      var views = ChgDataGridViewToolbar.toolbar.getNodeModelByID("view");
  /*    views.updateOptions({
        grid: {
          data:"Tile"
        }
      });*/
      ChgChangeActionUtil.changeView("TileView");
    },

    /*
     * Method to show the message when no CA is available
     */
    showEmptyView: function(){
      var emptyTileViewDiv = document.getElementById("emptyTileViewDiv");
      if(emptyTileViewDiv){
        emptyTileViewDiv.removeClassName("hideView");
        emptyTileViewDiv.addClassName("showEmptyView");
      }
    },

    /*
     * Method to hide the empty CA message
     */
    hideEmptyView: function(){
      var emptyTileViewDiv = document.getElementById("emptyTileViewDiv");
      if(emptyTileViewDiv){
        emptyTileViewDiv.addClassName("hideView");
        emptyTileViewDiv.removeClassName("showEmptyView");
      }
    }

  };
  return ChgTileViewLayout;
});

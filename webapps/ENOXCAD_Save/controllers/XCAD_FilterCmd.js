define('DS/ENOXCAD_Save/controllers/XCAD_FilterCmd', [
    'UWA/Core', 
    'DS/ApplicationFrame/Command', 
    'DS/Core/Core', 
    'DS/ApplicationFrame/CommandCheckHeader', 
    'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function(UWA, AFRCommand, WUX, CommandCheckHeader, XCAD_InteractionsWEB_CAD) {
    //'use strict';

    var FilterCmd = {
//        _context: null,

    	_FilterButton:null,
    	
        init: function(FilterBtn) {
        	this._FilterButton=FilterBtn; 
            console.log('init : idFilterCmd'/* + this._id*/);
            //this._parent(options, {});

            //this.setState(widget.XCAD_MainController.filterNotModified, false);

            //var that = this;
            this._FilterButton.addEventListener('buttonclick', function (event){
  			  var state=typeof event.srcElement.attributes.checked != 'undefined'
  			  /*var content = {
  						filterNotModified: state
  					}
  					XCAD_InteractionsWEB_CAD.sendMessageToCad("changeFilterNotModified", '1.0', content);*/
  				widget.XCAD_MainController.ShowOnlyModifiedContentList(state);
  			});
           /* this.onStateChange(function() {
				var content = {
					filterNotModified: that.getState()
				}
				XCAD_InteractionsWEB_CAD.sendMessageToCad("changeFilterNotModified", '1.0', content);
            });*/
            
        }
    };
    return FilterCmd;
});


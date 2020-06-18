define('DS/ENOXCAD_Save/controllers/XCAD_BookmarkCmd', 
[
	'UWA/Core', 
	'DS/ApplicationFrame/Command', 
	'DS/Core/Core', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function (UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD) {
    'use strict';

    var SaveAsNewCmd = {
    		
    		_BookmarkButton:null,
    		_id:null,
             init : function(id,BookmarkBTn) {
        	this._BookmarkButton=BookmarkBTn;
        	this._id=id;
        	//this._parent(options, {});
            console.log('init : ' + this._id);
            
            widget.XCAD_MainController.actionBarCommands[this._id] = this;   
         
			var that=this
            this._BookmarkButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
        },
        execute : function() {
            console.log('execute : ' + this._id);

			var content = {
				selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('LaunchBookmark', '1.0', content);
			console.log('LaunchBookmark : ' + content);
        },        
        updateAvailability : function(selectedNodes) {
             var isEnable=true; //bookmark cmd is always available 
            // By default if some nodes are selected, the command is enable
            //var isEnable = (Object.keys(selectedNodes).length > 0);            

            // If we found at least 1 selected node not compatible, the command is disable;
            /*for (var i in selectedNodes) {
                if (selectedNodes[i]._options.grid.Status == 'I_UPSNew') {
                    isEnable = false;
                    break;
                }
            }*/
            
            if (isEnable)
				this._BookmarkButton.elements.button.dsModel.disabled=false;
			else
				this._BookmarkButton.elements.button.dsModel.disabled=true;
        } 
    };

    return SaveAsNewCmd;
});

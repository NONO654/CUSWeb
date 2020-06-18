define('DS/ENOXCAD_Save/controllers/XCAD_ExcludeCmd', 
[
	'UWA/Core', 
	'DS/ApplicationFrame/Command', 
	'DS/Core/Core', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function (UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD) {
    'use strict';

    var ExcludeCmd = {
    		
    		_ExcludeButton:null,
    		_id:null,
    		_isEnable:null,
             init : function(id,ExcludeBTn) {
            this._isEnable=false;
        	this._ExcludeButton=ExcludeBTn;
        	this._id=id;
        	//this._parent(options, {});
            console.log('init : ' + this._id);
            
            widget.XCAD_MainController.actionBarCommands[this._id] = this;   
         
			var that=this
            this._ExcludeButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
        },
        execute : function() {
            console.log('execute : ' + this._id);

			var content = {
					selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad(this._id, '1.0', content);
        },
        updateAvailability : function(selectedNodes) {
                
            // By default if some nodes are selected, the command is enable
             this._isEnable = (Object.keys(selectedNodes).length > 0);            

            // If we found at least 1 selected node not compatible, the command is disable;

            for (var i in selectedNodes) {
            	if (typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined' && selectedNodes[i]._options.grid.Available_Commands.indexOf(this._id) == -1)
                {
                    this._isEnable = false;
                    break;
                }
            }
            
            if (this._isEnable)
				this._ExcludeButton.elements.button.dsModel.disabled=false;
			else
				this._ExcludeButton.elements.button.dsModel.disabled=true;
        } 
    };

    return ExcludeCmd;
});

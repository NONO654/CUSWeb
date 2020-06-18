define('DS/ENOXCAD_Save/controllers/XCAD_NewFileNameCmd', [
    'UWA/Core', 
    'DS/ApplicationFrame/Command', 
    'DS/Core/Core', 
    'DS/ApplicationFrame/CommandCheckHeader', 
    'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function(UWA, AFRCommand, WUX, CommandCheckHeader, XCAD_InteractionsWEB_CAD) {
    //'use strict';

    var NewFileNameCmd = {
    		
        _NewFileNameButton:null,
    	_id:null,
    	_isEnable:null,
        init: function(id,newNameBtn) {
        	this._isEnable=false;
        	this._NewFileNameButton=newNameBtn;
        	this._id=id;
            console.log('init : idNewFileNameCmd'/* + this._id*/);
            //this._parent(options, {});

            // By default the command is disable
            //this.disable();
            this._NewFileNameButton.elements.button.dsModel.disabled=true;
            //this.setState(false, false);
            widget.XCAD_MainController.actionBarCommands[this._id] = this;

            var that = this;
            this._NewFileNameButton.addEventListener('buttonclick', function (event){
            	//var state=typeof event.srcElement.attributes.checked != 'undefined'
            	that.execute();
        });
            
        },
        execute :function(/*newState*/) {
        	// if the NewFileNameCmd is checked, open the left side panel with the view NewFileName
        	//if (newState) {
        		widget.XCAD_MainController.showNewFileNameSidePanel();
        	/*}
        	if the NewFileNameCmd is unchecked, close the the left side panel
        	else {
        		widget.XCAD_MainController.hideLeftSidePanel();
        	}*/
        },
        updateAvailability : function(selectedNodes) {
            
            // The command is enable if only 1 node is selected (TODO: support multi selection + rename massif with regular expression)
            this._isEnable = (Object.keys(selectedNodes).length == 1);            

            if (this._isEnable) {
	            // If we found at least 1 selected node not compatible, the command is disable;
	            for (var i in selectedNodes) {
	            	if (typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined' && selectedNodes[i]._options.grid.Available_Commands.indexOf(this._id) == -1)
	                {
	                	this._isEnable = false;
	                    break;
	                }
	            }
            }
            
            if (this._isEnable)
            	this._NewFileNameButton.elements.button.dsModel.disabled=false;
            else
            	this._NewFileNameButton.elements.button.dsModel.disabled=true;
        }
        
    };
    
    return NewFileNameCmd;
});


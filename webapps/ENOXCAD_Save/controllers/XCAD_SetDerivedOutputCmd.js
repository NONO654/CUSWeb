define('DS/ENOXCAD_Save/controllers/XCAD_SetDerivedOutputCmd', [
    'UWA/Core', 
    'DS/ApplicationFrame/Command', 
    'DS/Core/Core', 
    'DS/ApplicationFrame/CommandCheckHeader', 
    'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function(UWA, AFRCommand, WUX, CommandCheckHeader, XCAD_InteractionsWEB_CAD) {
    'use strict';

    var ENOUPSSetDerivedOutputCmd = {
    		
    	_DerivedOutpuButton:null,
    	_id:null,
    	_SaveAsNewButton:null,
    	_isEnable:null,
		init: function(id,DOBTn) {
			this._isEnable=false;
			this._id=id;
			this._DerivedOutpuButton=DOBTn;
            console.log('init : ENOUPSSetDerivedOutputCmd'+ this._id);
            //this._parent(options, {});

            // By default the command is disable
            //this.disable();
            
            //this.setState(false, false);
            widget.XCAD_MainController.actionBarCommands[this._id] = this;

            var that = this;
            this._DerivedOutpuButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
            
           /* this.onStateChange(function(newState) {
            	// if the NewFileNameCmd is checked, open the left side panel with the view NewFileName
            	if (newState) {
                    // warn the CAD
        			var content = {
        				selectedNodesId : Object.keys(widget.XCAD_MainController.selectedNodes)
        			}
        			XCAD_InteractionsWEB_CAD.sendMessageToCad('GetDerivedOutputsList', '1.0', content);
            	}
            	// if the NewFileNameCmd is unchecked, close the the left side panel
            	else {
            		widget.XCAD_MainController.hideLeftSidePanel();
            	}
            });*/
        },
        execute : function() {
            console.log('execute : ' + this._id);

			var content = {
				selectedNodesId : Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('GetDerivedOutputsList', '1.0', content);
        },        
        updateAvailability : function(selectedNodes) {
            
            // The command is enable if a least 1 node is selected
            this._isEnable = false;            
				// If we found at least 1 selected node not compatible, the command is disable;
				for ( var i in selectedNodes) {
					if (typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined' && selectedNodes[i]._options.grid.Available_Commands.indexOf(this._id) != -1){
						this._isEnable = true;
						break;
					}
				}
			
            if (this._isEnable)
            	this._DerivedOutpuButton.elements.button.dsModel.disabled=false;
            else
            	this._DerivedOutpuButton.elements.button.dsModel.disabled=true;
        }                
    };
    return ENOUPSSetDerivedOutputCmd;
});


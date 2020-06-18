define('DS/ENOXCAD_Save/controllers/XCAD_NewRevCmd', 
[
	'UWA/Core', 
	'DS/ApplicationFrame/Command', 
	'DS/Core/Core', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function (UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD) {
    'use strict';

    var NewRevCmd = {
    		
       _RevButton:null,
       _id:null,
       _isEnable:null,
        init : function(id, reviseBtn) {
        	this._isEnable=false;
        	this._RevButton=reviseBtn;
        	this._id=id;
        	//this._parent(options, {});
            console.log('init : ' + this._id);

            widget.XCAD_MainController.actionBarCommands[this._id] = this;
            var that=this
            this._RevButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
        },
        execute : function() {
            console.log('execute : ' + this._id);

			var content = {
					selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('NewRev', '1.0', content);
        },
        resetRevision : function(previousRevision) {
            console.log('ResetRevision : ' + this._id);

			var content = {
					selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes),
					prevRev: previousRevision
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('ResetRev', '1.0', content);
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
            	this._RevButton.elements.button.dsModel.disabled=false;
            else
            	this._RevButton.elements.button.dsModel.disabled=true;
        }        
    };

    return NewRevCmd;
});

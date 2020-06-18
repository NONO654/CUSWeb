define('DS/ENOXCAD_Save/controllers/XCAD_ToggleRightPanelCmd', [
    'UWA/Core', 
    'DS/ApplicationFrame/Command', 
    'DS/Core/Core', 
    'DS/ApplicationFrame/CommandCheckHeader', 
    'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD'
], function(UWA, AFRCommand, WUX, CommandCheckHeader, XCAD_InteractionsWEB_CAD) {
    'use strict';

    var ENOUPSToggleRightPanelCmd = {
    		
    	_InfoButton:null,
    	_id:null,
        init: function(id,inofbutton) {
        	this._isEnable=false;
        	this._id=id;
        	this._InfoButton=inofbutton;
            console.log('init : ENOUPSToggleRightPanelCmd'/* + this._id*/);
            //this._parent(options, {});
            
            //this.setState(true);
            widget.XCAD_MainController.actionBarCommands[this._id] = this;

            var that = this;
            var that=this
            this._InfoButton.addEventListener('buttonclick', function (event){
            	widget.XCAD_MainController.toogleRightPanel();
        });
            /*this.onStateChange(function(newState) {
        		widget.XCAD_MainController.toogleRightPanel();
            });*/
        },
        updateAvailability : function(selectedNodes) {
            // This command is always enable 
        }
    };
    return ENOUPSToggleRightPanelCmd;
});


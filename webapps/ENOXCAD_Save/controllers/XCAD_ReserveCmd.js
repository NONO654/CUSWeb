define('DS/ENOXCAD_Save/controllers/XCAD_ReserveCmd', 
[	'UWA/Core', 'DS/ApplicationFrame/Command', 'DS/Core/Core', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/ENOXCAD_Save/controllers/XCAD_ReserveServices'
], function(UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD, ENOUPSReserveServices) {
	
	'use strict';

	var ENOUPSReserveCmd = {
		_ReserveButton:null,
		_id:null,
		_isEnable:null,
		init : function(id, ReserveButton) {
			this._isEnable=false;
			///this._parent(options, {});
			this._id=id;
			this._ReserveButton=ReserveButton;
			console.log('init : ' + this._id);
			
			widget.XCAD_MainController.actionBarCommands[this._id] = this;

			// By default the command is disable
			this._ReserveButton.elements.button.dsModel.disabled=true;
			var that=this
            this._ReserveButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
		},
		execute : function() {
			console.log('execute : ' + this._id);
			//ENOUPSReserveServices.execute('reserve');

			var content = {
					selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('Reserve', '1.0', content);
		},
		updateAvailability : function(selectedNodes) {

			// The command is enable if at least 1 node is selected
			this._isEnable = (Object.keys(selectedNodes).length > 0);

			if (this._isEnable) {
				// If we found at least 1 selected node not compatible, the command is disable;
				for ( var i in selectedNodes) {
					if (typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined' && selectedNodes[i]._options.grid.Available_Commands.indexOf(this._id) == -1){
						this._isEnable = false;
						break;
					}
				}
			}

			if (this._isEnable)
				this._ReserveButton.elements.button.dsModel.disabled=false;
			else
				this._ReserveButton.elements.button.dsModel.disabled=true;
		}
	};
	return ENOUPSReserveCmd;
});

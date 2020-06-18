define('DS/ENOXCAD_Save/controllers/XCAD_UnReserveCmd', 
[	'UWA/Core', 'DS/ApplicationFrame/Command', 'DS/Core/Core', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',	'DS/ENOXCAD_Save/controllers/XCAD_ReserveServices'
], function(UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD, ENOUPSReserveServices) {
	
	'use strict';

	var ENOUPSUnReserveCmd ={
		_UnReserveButton : null,
		_id:null,
		_isEnable:null,
		init : function(id,unreserveBtn) {
			this._isEnable=false;
			this._UnReserveButton=unreserveBtn;
			this._id=id;
			//this._parent(options, {});
			console.log('init : ' + this._id);

			widget.XCAD_MainController.actionBarCommands[this._id] = this;

			// By default the command is disable
			this._UnReserveButton.elements.button.dsModel.disabled=true;
			var that=this
            this._UnReserveButton.addEventListener('buttonclick', function (event){
            	that.execute();
        });
		},
		execute : function() {
			console.log('execute : ' + this._id);
			//ENOUPSReserveServices.execute('unreserve');

			var content = {
					selectedNodesId: Object.keys(widget.XCAD_MainController.selectedNodes)
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('Unreserve', '1.0', content);
		},
		updateAvailability : function(selectedNodes) {

			// The command is enable if at least 1 node is selected
			this._isEnable = (Object.keys(selectedNodes).length > 0);

			if (this._isEnable) {
				// If we found at least 1 selected node not compatible, the command is disable;
				for ( var i in selectedNodes) {
					if (((selectedNodes[i]._options.grid.Status) &&(selectedNodes[i]._options.grid.Status.indexOf('I_UPSNew') != -1))||((typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined') 
					&&((selectedNodes[i]._options.grid.Available_Commands.indexOf('Include') != -1) || 
					(selectedNodes[i]._options.grid.Available_Commands.indexOf('Lock') != -1)))||((typeof selectedNodes[i]._options.grid.Action != 'undefined') && (selectedNodes[i]._options.grid.Action=='I_UPSSaveDuplicate'||selectedNodes[i]._options.grid.Action=='I_UPSRevise')) ){
					//((((selectedNodes[i]._options.grid.Status) &&(selectedNodes[i]._options.grid.Status.indexOf('I_UPSNew') != -1))||((typeof selectedNodes[i]._options.grid.Available_Commands != 'undefined') &&(selectedNodes[i]._options.grid.Available_Commands.indexOf('Include') != -1) || (selectedNodes[i]._options.grid.Available_Commands.indexOf('Lock') != -1))) ) {
						this._isEnable = false;
						break;
					}
				}
			}

			if (this._isEnable)
				this._UnReserveButton.elements.button.dsModel.disabled=false;
			else
				this._UnReserveButton.elements.button.dsModel.disabled=true;
		}
	};
	return ENOUPSUnReserveCmd;
});

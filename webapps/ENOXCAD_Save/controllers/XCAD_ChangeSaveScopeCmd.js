define('DS/ENOXCAD_Save/controllers/XCAD_ChangeSaveScopeCmd', [ 'UWA/Core', 'DS/ApplicationFrame/Command', 'DS/Core/Core', 'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD' ], function(UWA, AFRCommand, WUX, XCAD_InteractionsWEB_CAD) {
	'use strict';

	var ChangeSaveScopeCmd = AFRCommand.extend({
		init : function(options) {
			this._parent(options, {});
		},
		execute : function() {
			console.log('execute : ChangeSaveScopeCmd (' + this._id + ')');

			var newSaveScope = 0;
			if (this._id == 'idActiveDoc')
				newSaveScope = 0;
			else if (this._id == 'idCurrentEditor')
				newSaveScope = 1;
			else if (this._id == 'idSession')
				newSaveScope = 2;

			// Warn the CAD only if the save scope has actually changed
			if (widget.XCAD_MainController.saveScope != newSaveScope) {
				widget.XCAD_MainController.saveScope = newSaveScope;

				var content = {
					saveScope : newSaveScope
				}
				XCAD_InteractionsWEB_CAD.sendMessageToCad('changeSaveScope', '1.0', content);
			}
		}
	});

	return ChangeSaveScopeCmd;
});

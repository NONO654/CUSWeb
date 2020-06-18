define(
	'DS/CAT3DExpModel/commands/CAT3DXSaveExperienceCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand,   CAT3DXModel) {
		'use strict';

		var CAT3DXSaveExperienceCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: true
				});
			},

			beginExecute: function () {
				var self = this;
				CAT3DXModel.SaveExperience().done(function () {
				    self.end();
				});
			},

			execute: function () {
			}
		});

		return CAT3DXSaveExperienceCmd;
	});

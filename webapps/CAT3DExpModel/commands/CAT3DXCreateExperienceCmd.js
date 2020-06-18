define(
	'DS/CAT3DExpModel/commands/CAT3DXCreateExperienceCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
		'use strict';

		var CAT3DXCreateExperienceCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: true
				});
			},

			beginExecute: function () {
				var self = this;

				var experienceName;
				if (this.appOptions && UWA.is(this.appOptions.experienceName)) {
					experienceName = this.appOptions.experienceName;
				}
				else {
					experienceName = 'New Experience';
				}

				CAT3DXModel.CreateExperience(experienceName).done(function () {
				    self.end();
				});
			},

			execute: function () {
			}
		});

		return CAT3DXCreateExperienceCmd;
	});

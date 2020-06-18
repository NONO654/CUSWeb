define(
	'DS/XCTWebExperienceAppPlay/commands/XCTWebPauseCmd',
	//define - Dependencies
	['UWA/Core', 'DS/ApplicationFrame/Command', 'DS/CAT3DExpModel/CAT3DXModel'],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
		'use strict';

		var XCTWebPauseCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: false
				});
			},

			beginExecute: function () {
				var frmWindow = this.getFrameWindow();
				var experienceBase = frmWindow._experienceBase;

				var experience = CAT3DXModel.GetExperience();
				if (experience) {
				    experienceBase.getManager('CXPWebPlayManager').pause(experience);
				}
			},

			execute: function () {
			}
		});

		return XCTWebPauseCmd;
	});


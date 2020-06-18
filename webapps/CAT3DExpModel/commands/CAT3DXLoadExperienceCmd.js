define(
	'DS/CAT3DExpModel/commands/CAT3DXLoadExperienceCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand,   CAT3DXModel) {
		'use strict';

		var CAT3DXLoadExperienceCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: true
				});
			},


			beginExecute: function () {
			    var self = this;

			    if (this.appOptions) {
			        var linkContext = this.appOptions.linkContext;
			        var link = this.appOptions.link;
			    }

			    if (!link) {
			        return;
			    }

			    CAT3DXModel.LoadExperience(linkContext, link).done(function () {
			        return self.end();
			    });
			},

			execute: function () {
			}
		});

		return CAT3DXLoadExperienceCmd;
	});

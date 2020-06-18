define(
	'DS/CAT3DExpModel/commands/CAT3DXSetValueCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand,   CAT3DXModel) {
		'use strict';

		var CAT3DXSetValueCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: true
				});
			},

			beginExecute: function () {
				var self = this;
				if (this.appOptions) {
				    var component = this.appOptions.component;
				    var variableName = this.appOptions.variableName;
				    var value = this.appOptions.value;
				}

				CAT3DXModel.SetVariableValues(component, variableName, value).done(function () {
				    return self.end();
				});
			},

			execute: function () {
			}
		});

		return CAT3DXSetValueCmd;
	});

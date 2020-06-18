define(
	'DS/CAT3DExpModel/commands/CAT3DXSaveLSCmd',
	//define - Dependencies
	['UWA/Core', 'DS/ApplicationFrame/Command', 'DS/CAT3DExpLinkContext/CAT3DExpLocalStorageLinkContext', 'DS/Core/Events', 'DS/CAT3DExpModel/CAT3DXJSONWriter', 'DS/CAT3DExpModel/CAT3DXModel'],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DExpLocalStorageLinkContext, WUXEvent, CAT3DXJSONWriter, CAT3DXModel) {
		'use strict';

		var CAT3DXSaveLSCmd = AFRCommand.extend({

			init: function (options) {
				this._parent(options, {
					isAsynchronous: true
				});
			},

			beginExecute: function () {
			    var self = this;
			    var experience = CAT3DXModel.GetExperience();
			    if (!experience) {
					return;
				}

			    var name = window.prompt('Object name :', experience.QueryInterface('CATIAlias').GetAlias());
				if (UWA.is(name) && name !== '') {
				    var linkContext = new CAT3DExpLocalStorageLinkContext({ databaseName: name });
				    var writer = new CAT3DXJSONWriter();
				    writer.writeJSON(experience, linkContext).done(function (iParsedExperience) {
				        var blob = new Blob([iParsedExperience], { type: 'application/json' });
				        return linkContext.pushStream(blob);
				    }).done(function () {
				        WUXEvent.publish({
				            event: 'Refresh_localStorage_Assets'
				        });
				        self.end();
				    });
				}
			},

			execute: function () {
			}
		});

		return CAT3DXSaveLSCmd;
	});

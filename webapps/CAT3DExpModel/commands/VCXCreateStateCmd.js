define(
	'DS/CAT3DExpModel/commands/VCXCreateStateCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXCreateStateCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var neutrals, sequenceId, stateName, stateDescription;
	            if (this.appOptions) {
	                neutrals = this.appOptions.neutrals;
	                sequenceId = this.appOptions.sequenceId;
	                stateName = this.appOptions.stateName;
	                stateDescription = this.appOptions.stateDescription;
	            }
	            if (!neutrals) {
	                UWA.log("ERROR on command VCXCreateStateCmd, no neutrals");
	                return;
	            }
	            if (!sequenceId) {
	                UWA.log("ERROR on command VCXCreateStateCmd, no sequenceId");
	                return;
	            }
	            if (!stateName) {
	                UWA.log("ERROR on command VCXCreateStateCmd, no state name");
	                return;
	            }
	            if (!stateDescription) {
	                UWA.log("ERROR on command VCXCreateStateCmd, no description");
	                return;
	            }





	            CAT3DXModel.CreateState(neutrals, sequenceId, stateName, stateDescription).done(function (iState) {
	                self.iState = iState;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXCreateStateCmd;
	});


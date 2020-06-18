define(
	'DS/CAT3DExpModel/commands/VCXUpdateStateCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXUpdateStateCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var stateId, stateCollectionId, neutrals, stateDescription;
	            if (this.appOptions) {
	                stateId = this.appOptions.stateId;
	                stateCollectionId = this.appOptions.stateCollectionId;
	                neutrals = this.appOptions.neutrals;
	                stateDescription = this.appOptions.stateDescription;
	            }
	            if (!stateCollectionId) {
	                UWA.log("ERROR on command VCXUpdateStateCmd, no stateCollectionId");
	                return;
	            }
	            if (!stateId) {
	                UWA.log("ERROR on command VCXUpdateStateCmd, no state name");
	                return;
	            }
	            if (!neutrals) {
	                UWA.log("ERROR on command VCXUpdateStateCmd, no neutrals");
	                return;
	            }
	            if (!stateDescription) {
	                UWA.log("ERROR on command VCXUpdateStateCmd, no description");
	                return;
	            }

	            CAT3DXModel.VCXUpdateState(stateId, stateCollectionId, neutrals, stateDescription).done(function (iState) {
	                self.iState = iState;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXUpdateStateCmd;
	});


define(
	'DS/CAT3DExpModel/commands/VCXDeleteStateCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXDeleteStateCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var stateId, stateCollectionId;
	            if (this.appOptions) {
	                stateId = this.appOptions.stateId;
	                stateCollectionId = this.appOptions.stateCollectionId;
	            }
	            if (!stateId) {
	                UWA.log("ERROR on command VCXDeleteStateCmd, no stateId");
	                return;
	            }
	            if (!stateCollectionId) {
	                UWA.log("ERROR on command VCXDeleteStateCmd, no stateCollectionId");
	                return;
	            }

	            CAT3DXModel.DeleteState(stateId, stateCollectionId).done(function (iHResult) {
	                self.iHResult = iHResult;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXDeleteStateCmd;
	});


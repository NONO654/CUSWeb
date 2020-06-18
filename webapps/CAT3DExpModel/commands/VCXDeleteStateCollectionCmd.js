define(
	'DS/CAT3DExpModel/commands/VCXDeleteStateCollectionCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXDeleteStateCollectionCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;
	            if (this.appOptions) {
	                stateCollectionId = this.appOptions.stateCollectionId;
	            }
	            if (!stateCollectionId) {
	                UWA.log("ERROR on command VCXDeleteStateCollectionCmd, no stateCollectionId");
	                return;
	            }

	            CAT3DXModel.DeleteStateCollection(stateCollectionId).done(function (iHResult) {
	                self.iHResult = iHResult;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXDeleteStateCollectionCmd;
	});


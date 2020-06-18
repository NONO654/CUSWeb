define(
	'DS/CAT3DExpModel/commands/VCXCreateStateCollectionCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXCreateStateCollectionCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var stateCollectionName, stateCollectionId;
	            if (this.appOptions) {
	                stateCollectionName = this.appOptions.stateCollectionName;
	                stateCollectionId = this.appOptions.stateCollectionId;
	            }
	            if (!stateCollectionName) {
	                UWA.log("ERROR on command VCXCreateStateCollectionCmd, no stateCollectionName");
	                return;
	            }
	            if (!stateCollectionId) {
	                UWA.log("ERROR on command VCXCreateStateCollectionCmd, no stateCollectionId");
	                return;
	            }

	            CAT3DXModel.CreateStateCollection(stateCollectionName, stateCollectionId).done(function (iStateCollection) {
	                self.iStateCollection = iStateCollection;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXCreateStateCollectionCmd;
	});


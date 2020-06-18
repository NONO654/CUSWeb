define(
	'DS/CAT3DExpModel/commands/VCXUpdateStateCollectionCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXUpdateStateCollectionCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var stateCollectionId, stateCollectionNewName, stateCollectionNewOrder;
	            if (this.appOptions) {
	                stateCollectionId = this.appOptions.stateCollectionId;
	                stateCollectionNewName = this.appOptions.stateCollectionNewName;
	                stateCollectionNewOrder = this.appOptions.stateCollectionNewOrder;
	            }
	            if (!stateCollectionId) {
	                UWA.log("ERROR on command VCXUpdateStateCollectionCmd, no stateCollectionId");
	                return;
	            }
	            if (!stateCollectionNewName) {
	                UWA.log("ERROR on command VCXUpdateStateCollectionCmd, no stateCollectionNewName");
	                return;
	            }
	            if (!stateCollectionNewOrder) {
	                UWA.log("ERROR on command VCXUpdateStateCollectionCmd, no stateCollectionNewOrder");
	                return;
	            }





	            CAT3DXModel.UpdateStateCollection(stateCollectionId, stateCollectionNewName, stateCollectionNewOrder).done(function (iStateCollection) {
	                self.iStateCollection = iStateCollection;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXUpdateStateCollectionCmd;
	});


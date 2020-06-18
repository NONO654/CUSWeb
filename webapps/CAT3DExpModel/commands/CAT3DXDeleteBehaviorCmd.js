define(
	'DS/CAT3DExpModel/commands/CAT3DXDeleteBehaviorCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var CAT3DXDeleteBehaviorCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;

	            var behavior;
	            if (this.appOptions) {
	                behavior = this.appOptions.behavior;
	            }
	            if (!behavior) {
	                UWA.log('ERROR on command CAT3DXDeleteActorCmd, no behavior to delete');
	                return;
	            }

	            CAT3DXModel.DeleteBehavior(behavior).done(function () {
	                self.end();
	            });
	        },

	        execute: function () {
	        }
	    });

	    return CAT3DXDeleteBehaviorCmd;
	});

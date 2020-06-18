define(
	'DS/CAT3DExpModel/commands/CAT3DXDeleteActorCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var CAT3DXDeleteActorCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;

	            var actor;
	            if (this.appOptions) {
	                actor = this.appOptions.actor;
	            }
	            if (!actor) {
	                UWA.log('ERROR on command CAT3DXDeleteActorCmd, no actor to delete');
	                return;
	            }

	            CAT3DXModel.DeleteActor(actor).done(function () {
	                self.end();
	            });
	        },

	        execute: function () {
	        }
	    });

	    return CAT3DXDeleteActorCmd;
	});

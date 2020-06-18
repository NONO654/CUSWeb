define(
	'DS/CAT3DExpModel/commands/CAT3DXCreateActorCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var CAT3DXCreateActorCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;

	            var typeName, actorName, parent;
	            if (this.appOptions) {
	                typeName = this.appOptions.typeName;
	                actorName = this.appOptions.actorName;
	                parent = this.appOptions.parent;
	            }
	            if (!typeName){
	                UWA.log('ERROR on command CAT3DXCreateActorCmd, no type of actor');
	                return;
	            }
	            if (!actorName) {
	                actorName = '';
	            }
	            if (!parent) {
	                UWA.log('ERROR on command CAT3DXCreateActorCmd, no parent');
	                return;
	            }

	            CAT3DXModel.CreateActor(typeName, actorName, parent).done(function (iActor) {
	                self.actor = iActor;
	                self.end();
	            });
	        },

	        execute: function () {
	        }
	    });

	    return CAT3DXCreateActorCmd;
	});


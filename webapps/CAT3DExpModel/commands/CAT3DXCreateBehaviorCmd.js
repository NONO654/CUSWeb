define(
	'DS/CAT3DExpModel/commands/CAT3DXCreateBehaviorCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var CAT3DXCreateBehaviorCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;

	            var typeName, behaviorName, parent;
	            if (this.appOptions) {
	                typeName = this.appOptions.typeName;
	                behaviorName = this.appOptions.behaviorName;
	                parent = this.appOptions.parent;
	            }
	            if (!typeName) {
	                UWA.log('ERROR on command CAT3DXCreateBehaviorCmd, no type of behavior');
	                return;
	            }
	            if (!behaviorName) {
	                behaviorName = '';
	            }
	            if (!parent) {
	                parent = null;
	            }

	            CAT3DXModel.CreateBehavior(typeName, behaviorName, parent).done(function (iBehavior) {
	                self.behavior = iBehavior;
	                self.end();
	            });
	        },

	        execute: function () {
	        }
	    });

	    return CAT3DXCreateBehaviorCmd;
	});

define(
	'DS/CAT3DExpModel/commands/VCXCreateCityActorExternalCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXCreateCityActorExternalCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var typeName, actorName, fatherPath;
	            if (this.appOptions) {
	                typeName = this.appOptions.typeName;
	                actorName = this.appOptions.actorName;
	                fatherPath = this.appOptions.fatherPath;
	                stateDescription = this.appOptions.stateDescription;
	            }
	            if (!typeName) {
	                UWA.log("ERROR on command VCXCreateCityActorExternalCmd, no typeName");
	                return;
	            }
	            if (!actorName) {
	                UWA.log("ERROR on command VCXCreateCityActorExternalCmd, no actorName");
	                return;
	            }
	            if (!fatherPath) {
	                UWA.log("ERROR on command VCXCreateCityActorExternalCmd, no state name");
	                return;
	            }
	            if (!stateDescription) {
	                UWA.log("ERROR on command VCXCreateCityActorExternalCmd, no description");
	                return;
	            }









                CAT3DXModel.CreateCityActorExternal(typeName, actorName, fatherPath, stateDescription).done(function (iStateId) {
	                self.iStateId = iStateId;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXCreateCityActorExternalCmd;
	});


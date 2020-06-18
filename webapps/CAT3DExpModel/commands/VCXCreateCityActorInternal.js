define(
	'DS/CAT3DExpModel/commands/VCXCreateCityActorInternalCmd',
	//define - Dependencies
	[
		'UWA/Core',
		'DS/ApplicationFrame/Command',
		'DS/CAT3DExpModel/CAT3DXModel'
	],
	//define - CB load ---------------------------------------------------------------------------------------------------------------

	function (UWA, AFRCommand, CAT3DXModel) {
	    'use strict';

	    var VCXCreateCityActorInternalCmd = AFRCommand.extend({

	        init: function (options) {
	            this._parent(options, {
	                isAsynchronous: true
	            });
	        },

	        beginExecute: function () {
	            var self = this;


	            var typeName, actorName, fatherPath, link;
	            if (this.appOptions) {
	                typeName = this.appOptions.typeName;
	                actorName = this.appOptions.actorName;
	                fatherPath = this.appOptions.fatherPath;
	                link = this.appOptions.link;
	            }
	            if (!typeName) {
	                UWA.log("ERROR on command VCXCreateCityActorInternalCmd, no typeName");
	                return;
	            }
	            if (!actorName) {
	                UWA.log("ERROR on command VCXCreateCityActorInternalCmd, no actorName");
	                return;
	            }
	            if (!fatherPath) {
	                UWA.log("ERROR on command VCXCreateCityActorInternalCmd, no state name");
	                return;
	            }
	            if (!link)
	            {
	                UWA.log("ERROR on command VCXCreateCityActorInternalCmd, no description");
	                return;
	            }

	            CAT3DXModel.CreateCityActorInternal(typeName, actorName, fatherPath, link).done(function (iStateId)
	            {
	                self.iStateId = iStateId;
	                self.end();
	            });
	        },

	        execute: function () {
	        },

	    });

	    return VCXCreateCityActorInternalCmd;
	});

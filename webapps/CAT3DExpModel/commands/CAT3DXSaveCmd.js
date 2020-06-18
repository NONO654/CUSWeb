define(
    'DS/CAT3DExpModel/commands/CAT3DXSaveCmd',
    //define - Dependencies
    ['UWA/Core', 'DS/ApplicationFrame/Command', 'DS/CAT3DExpModel/CAT3DXModel'],
    //define - CB load ---------------------------------------------------------------------------------------------------------------

    function (UWA, AFRCommand, CAT3DXModel) {
    	'use strict';

    	var CAT3DXSaveCmd = AFRCommand.extend({

    		init: function (options) {
    			this._parent(options, {
    				isAsynchronous: false
    			});
    			UWA.log('Command : init ExportJSON');
    		},

    		beginExecute: function () {
    			var experienceBase = this.getFrameWindow()._experienceBase;
				// retrieve current experience 
    			var experience = CAT3DXModel.GetExperience();
    			// save experience 
    			experienceBase.getManager('CAT3DXLoaderManager').write3DX(experience);

    		},

    		execute: function () {
    		}
    	});

    	return CAT3DXSaveCmd;
    });

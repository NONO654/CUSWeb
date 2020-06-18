define("DS/ENOPartMgt/commands/CollaborateUPSToEBOMCmd/ActionBar_CollaborateToEBOMCmd",
[
'UWA/Class',
'DS/ApplicationFrame/Command',
'DS/PlatformAPI/PlatformAPI',
'DS/ENOCollabSharingCmds/commands/CommandAvailableOnSelect'
], function(Class, AFRCommand, PlatformAPI, OnSelectCommand){
    'use strict';
    var Command = Class.extend(AFRCommand, OnSelectCommand, {
    					init: function (options) {

    						var isODT = false;
    						this.options = options;
    						if (typeof options !== undefined && options !== null) { 
    							if ( options.hasOwnProperty("odtMode") )
    									isODT = options["odtmode"];
    						}
    						if ( !isODT )
    							this._setCommandEnableStatus();

    						this._parent(options, {                
    							isAsynchronous: true
    						});
    			        
    						if(typeof PlatformAPI.getUser()=="function") this.currentUser = PlatformAPI.getUser().login;  
    						else
    							this.currentUser = "";
    					},
        
    					execute: function () {
    						var that = this;
    						require(["DS/ENOPartMgt/commands/CollaborateUPSToEBOMCmd/CollaborateToEBOMCmdBase"],function(CollaborateToEBOMCmdBase){
    							CollaborateToEBOMCmdBase.execute();
    						});
				        	that.end();
    					},
    					
    			        _setCommandEnableStatus: function()
    				    {
    				         var that = this;
    				         require(['DS/PADUtils/PADContext'], function(PADContext){
    				        	    var myContext = PADContext.get();
    				        	    var isCmdEnable = 0;
    				        	    if (myContext != null)
    				        	    {
    				                    if (PADContext.get().getEditMode != undefined && PADContext.get().getEditMode() !== true) {
    				                        isCmdEnable = 0;
    				                    }
    				                    if (1 === isCmdEnable) {
    				                        that.enable();
    				                    } else {
    				                        that.disable();
    				                    }
    				        	    	
    				        	    	PADContext.get().addEvent('editModeModified', function(state) {
    				        	    		if (state === true) {
    				        	    			that.enable();
    				        	    		} else {
    				        	    			that.disable();
    				        	    		}
    				        	    	});
    				        	    }
    				            });
    				    }
        
    });

    return Command;
});

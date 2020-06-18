define('DS/SMAProcRunAbaqusUI/Collection/Session', [
    'UWA/Core',
    'UWA/Class/Collection',
    'UWA/Class/Debug',
    'DS/SMAProcRunAbaqusUI/Model/Tool',
    'DS/WebappsUtils/WebappsUtils',
    'DS/SMAProcADUI/ad-util/ADAMDUtil'
], function (UWACore, Collection, Debug, Tool, WebAppsUtils, ADAMDUtil) {

    'use strict';
    
    var Session = Collection.extend(Debug, {

    	_callComplete : function(options) {
			var tools = [], i, nextTool;
			options.onComplete(tools);
			// add Managed Data tool
			nextTool = {};
			nextTool.id = 'manageData';
			nextTool.title = 'Content';
			nextTool.ownerName = this.session.process.basics.owner;
			nextTool.lastExecuted = 'notexecutable';
			nextTool.description = '';
			nextTool.portraitIcon = 'images/Document32.png';
			nextTool.toolInstance = null;
			nextTool.session = this.session,
			nextTool.subtitle = "";			
			
			tools.push(nextTool);
			
			if (this.session.tools) {
  				for (i = 0; i < this.session.tools.length; i++) {
  					nextTool = {};
  					nextTool.id = this.session.tools[i].modelID;
  					nextTool.title = "Job: " + this.session.tools[i].name;
  					nextTool.ownerName = this.session.process.basics.owner;
  					nextTool.lastExecuted = '';
  					nextTool.description = this.session.tools[i].description;
  					nextTool.portraitIcon = 'images/I_SMAWflAbaqus.png';
  					nextTool.toolInstance = this.session.tools[i];
  					nextTool.session = this.session;  					
  					nextTool.subtitle = this.session.tools[i].configuration.getAppName();
  					nextTool.actTitle = this.session.tools[i].name;
  					tools.push(nextTool);
  					
  					this._toolNameArray.push(nextTool.title);
  					
  					var toolName = nextTool.title, namePortion = nextTool.title, numberPortion = '0', namePattern = /\x28[0-9]+\x29$/;
  			        
  			        if (namePattern.test(toolName.trim())) {
  			            // get number from tool name
  			            var startNumber = toolName.lastIndexOf('(');
  			            namePortion = toolName.substring(0, startNumber).trim();
  			            numberPortion = toolName.substring(startNumber).trim();
  			            numberPortion = numberPortion.substring(1, numberPortion.length - 1);
  			        } else {
  			            namePortion = toolName;
  			            numberPortion = '0';
  			        }

  			        var toolNameArray = this._toolNameMap[namePortion];
  			        if (!toolNameArray) {
  			        	toolNameArray = [];
  			            this._toolNameMap[namePortion] = toolNameArray;
  			        }

  			        	toolNameArray[numberPortion] = true;
  					
  				}
			}
			
  			options.onComplete(tools);  
  			
  			//window.widget.dispatchEvent('onToolsLoaded', [this.get('manageData')]);
    	},
    	
        _checkExecDirs : function () {
            var execDirs = this.session.executionDirectories, 
            	i, 
            	execDir, 
            	job, 
            	hasTransientDirectories = false,
            	options = {
            		physicalID: this.session.processID
            	};
            
            // see if there are any orphaned execution directories
            if (execDirs) {
                for (i = 0; i < execDirs.length; i++) {
                    execDir = execDirs[i];
                    if (execDir.station && !execDir.path && !execDir.creating) {
                        // An orphan directory has been created, and has no path.  If the orphan has a job that 
                    	// has either started or finished, try to initialize that directory.
                        job = this.session.findJob(execDir.mcsJobID);
                        if (job) {
                            if (job.isStarted || job.isFinished && !execDir.didFinishedJobOrphanCheck) {
                            	
                            	options.execDir = execDir;
                                this.fileMonitor.initExecDir(options);
                                
                                // only check finished jobs once
                                if (job.isFinished) {
                                    execDir.didFinishedJobOrphanCheck = true;
                                }
                            }
                        }
                    }
                    else if (execDir.removeAfterJob) {
                    	// we have transient directory, so we should check for jobs that may have finished
                    	hasTransientDirectories = true;
                    }
                }
            }
            
            if (hasTransientDirectories) {
                // see if there are any directories ready to be deleted, by having the session load jobs data
                this.session.loadJobs();
            }
            
            // re-start the timer
            this._CHECKEXECDIRS_TIMER = window.setTimeout(this._checkExecDirs.bind(this), this._CHECKEXECDIRS_DELAY);
        },

     	_loadSessionSuccess : function(options) {
    		this._sessionLoaded = true;
    		
    		if (!this._toolsLoaded) {
    			this.session.initTools(true);
    		}
    		else if (options && options.onComplete) {
    			this._callComplete(options);
  			}
    		
    		if(this.accessComponent && !this.accessComponent.haswrite){    			
    			window.widget.dispatchEvent('onNoWriteAccess');
    		}
    		
            // start the orphaned execution directory check timer
            if (this._CHECKEXECDIRS_TIMER === null) {
                this._CHECKEXECDIRS_TIMER = window.setTimeout(this._checkExecDirs.bind(this), 1);
            }

    	},

    	_loadToolsSuccess : function(options) {
    		this._toolsLoaded = true;
			
  			if (this._sessionLoaded && options && options.onComplete) {
    			this._callComplete(options);
  			}
    	},

    	_loadError : function(options) {
      		if (options && options.onFailure) {
      			options.onFailure('Session load tools error');
      		}
    	},
    	
    	_mdataRemoved: function(options){    		
    		console.log(options);
    	},    	
    	
        model: Tool,
        
        hasNextPage : function() { return false; },

        setup: function () {
        	this.log('********* DS/RunAbaqusWidget/Collection/Session setup');
        	
	  		this._sessionWCLoaded = false;
	  		this._toolManagerWCLoaded = false;
	  		this._accessWCLoaded = false;
	  		this._toolNameArray = [];
	  		this._toolNameMap = {};
	  		this._CHECKEXECDIRS_TIMER = null;
	  		this._CHECKEXECDIRS_DELAY = 30000;
	  		
	  		var importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-session/ad-session.html';
    		ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADSession', function () {
	  		 	this._sessionWCLoaded = true;
	  		}.bind(this));
    		
	  		importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcADUI/ad-tool-manager/ad-tool-manager.html';
    		ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcADUI.ADToolManager', function () {
	  		 	this._toolManagerWCLoaded = true;
	  		}.bind(this));
    		
	  		importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcSPUI/sp-access/sp-access.html';
    		ADAMDUtil.loadWebComponent(importPath, null, function () {
	  		 	this._accessWCLoaded = true;
	  		}.bind(this));
    		
	  		importPath = WebAppsUtils.getWebappsBaseUrl() + 'SMAProcSP/sp-cos-filemonitor/sp-cos-filemonitor.html';
    		ADAMDUtil.loadWebComponent(importPath, 'DS.SMAProcSP.SPCOSFileMonitor', function () {
	  		 	this._fileMonitorLoaded = true;
	  		}.bind(this));
        },
        
     	sync: function (method, collection, options) {
     		this.log('********* DS/RunAbaqusWidget/Collection/Session sync');

  			this._loadCheckTimeout = null;
  			
     		var loadCheckFunc = function() {
      			if (this._sessionWCLoaded && this._toolManagerWCLoaded) {
      				if (!this.session) {
      					// create Tool Manager component         				
      					var existingToolManager = document.getElementById("toolManager");
      					if (existingToolManager){ 
      						if(existingToolManager.destroy){      						
      							existingToolManager.destroy();
      						}else{
      						existingToolManager.parentNode.removeChild(existingToolManager);
      						}
      					}
      					
      					this.toolManager= UWACore.createElement('ad-tool-manager', {id:"toolManager"});      					
          				window.widget.body.appendChild(this.toolManager);

      					// create Session component
      					var existingSession = document.getElementById("runAbqSession");
      					if (existingSession){
      						existingSession.parentElement.removeChild(existingSession);
      					}
      					
          				this.session = UWACore.createElement('ad-session', {id: "runAbqSession"});
          				window.widget.body.appendChild(this.session);
          				
          				this.fileMonitor = UWACore.createElement('sp-cos-filemonitor', {id: "fileMonitor"});
          				this.fileMonitor.unauthenticatedStations = true;

          				this.session.addEventListener('sessionloaded', this._loadSessionSuccess.bind(this, options));
          				this.session.addEventListener('toolsloaded', this._loadToolsSuccess.bind(this, options));
           				this.session.addEventListener('error', this._loadError.bind(this, options));
           				this.session.addEventListener('mdataremoved', this._mdataRemoved.bind(this, options));           				
           				this.session.toolManager = this.toolManager;
           				this.toolManager.session = this.session;
          				this._sessionLoaded = false;
          				this._toolsLoaded = false;
        				
          				//Create access component
          				var existingAccess = document.getElementById("access");
          				if(existingAccess){
          					existingAccess.destroy();
          				}
          				this.accessComponent = UWACore.createElement('sp-access', {
          					id:"access",
          					group : "process"
          				}).inject(window.widget.body);
          				
      				}

  					if(window.widget){
  						this.session.securityContext = window.widget.getValue('collabspaces');
  						console.log(window.widget.getValue('collabspaces'));
  						
  						// The '$' part doesn't appear to always be defined at this point, so set a timer
  						// to set the security context value when '$' is ready.
  						if (this.session.$) {
  	  						this.session.$.securityContext.value = window.widget.getValue('collabspaces');
  						}
  						else {
  							var timerFunc = function() {
  		  						if (this.session.$) {
  		  	  						this.session.$.securityContext.value = window.widget.getValue('collabspaces');
  		  						}
  		  						else {
  		  							window.setTimeout(timerFunc, 10);
  		  						}
  							}.bind(this);
  							window.setTimeout(timerFunc, 1);
  						}
  						
  						this.session.queryProcessID = window.widget.getValue('processId');
  					}
       			}
      			else {
      				// re-start timer
     				this._loadCheckTimeout = window.setTimeout(loadCheckFunc, 500);
      			}
      		}.bind(this);
      		
      		var cancelFunc = function() {
      			if (this._loadCheckTimeout) {
          			window.clearTimeout(this._loadCheckTimeout);
          			this._loadCheckTimeout = null;
      			}
      		}.bind(this);
      		
      		if (this._sessionWCLoaded && this._toolManagerWCLoaded) {
      			loadCheckFunc();
      		}
      		else {
         		this._loadCheckTimeout = window.setTimeout(loadCheckFunc, 500);
      		}
      		
      		// return an obj with a dummy cancel() method,
      		// because in this implementation of sync() we synchronously
      		// call options.onComplete, cancel is a no-op.
      		return {
      			cancel: cancelFunc
      		};
      	},
      	
      	_removeToolName : function(toolName){
	        var namePortion = toolName, numberPortion = '0', namePattern = /\x28[0-9]+\x29$/;
	        
	        if (namePattern.test(toolName.trim())) {
	            // get number from tool name
	            var startNumber = toolName.lastIndexOf('(');
	            namePortion = toolName.substring(0, startNumber).trim();
	            numberPortion = toolName.substring(startNumber).trim();
	            numberPortion = numberPortion.substring(1, numberPortion.length - 1);
	        } else {
	            namePortion = toolName;
	            numberPortion = '0';
	        }
	
	        var toolNameArray = this._toolNameMap[namePortion];
	
	        if (toolNameArray && (toolNameArray.length > 0)) {
	            toolNameArray[numberPortion] = false;
	        }
      	
      	},
      	
    	_createToolInstanceName : function (originalToolName) {
    		var toolName = originalToolName, toolNameSuffix = '';
    		//check the list of tools
    		//if tool name exists append number   		
    		var toolNameArray = this._toolNameMap[toolName];
    		
    	    if (!toolNameArray) {
                // if we don't have this in our map yet, add it
                toolNameArray = [];
                this._toolNameMap[toolName] = toolNameArray;
                toolNameArray.push(true);
            } else {
                var i;
                for (i = 0; i < toolNameArray.length; i++) {
                    if (!toolNameArray[i]) {
                        if (i > 0) {
                            toolNameSuffix = ' (' + i + ')';
                        }
                        toolNameArray[i] = true;
                        break;
                    }
                }
                
                if (i === toolNameArray.length) {
                    toolNameArray.push(true);
                    toolNameSuffix = ' (' + i + ')';
                }
            }
            
            toolName = toolName + toolNameSuffix;
            
            return toolName;
    		
        },
        
        _toolCreatedSuccess : function(current, total){        	
        	if(current === total-1){        		
        		this.session.initTools(true);
        	}      
        	window.widget.dispatchEvent('onToolAdded');
        },

        _toolCreatedError : function(){  
	        var message = {};       
            message.type = "error";
            message.text = "Unable to add a new job. Please refresh the browser and try again.";
            message.autoRemove = true;
            //Trigger message event	            
            window.widget.dispatchEvent("onAppMessage", message);	
            window.widget.dispatchEvent('onToolAdded');
        },

      	addTools : function(selectedToolDefs){
      		window.widget.dispatchEvent('onToolAdded');
      		var tool = {};
      		
			tool.title = "New tool";
			tool.portraitIcon = 'images/I_SMAWflAbaqus.png';
			//this.add(tool);
			
			
      		var i, newToolName;
            for (i = 0; i < selectedToolDefs.length; i++) {
                // get unique tool name
            	newToolName = this._createToolInstanceName.call(this, selectedToolDefs[i].name);
                
            	// call tool manager to create tool            	
                this.toolManager.createToolInstance(i, selectedToolDefs.length, selectedToolDefs[i], 
                									  newToolName,
                									  {
                										onComplete: this._toolCreatedSuccess.bind(this),
                										onFailure : this._toolCreatedError.bind(this)}
                									  );                
                
             } 
      		
      	},
      	
      	removeTool : function(toolModel){     		
      		this._removeToolName.call(this, toolModel.get('title'));     		
      		this.session.removeTools([toolModel.get('toolInstance')]);
      		var allTools = this.session.tools;      		
      		for (var i=0;i<allTools.length;i++){
      			if (allTools[i].modelID === toolModel.id){
      				allTools.splice(i, 1);      				
      			}
      		}
      		this.session.tools = allTools;      		
      		toolModel.collection.remove(toolModel);
      	}
    });

    return Session;
});

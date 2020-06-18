/* globals define, widget*/
define('DS/SMAProcRunAbaqusUI/RunAbaqusWidget',
    [
     'UWA/Core',
     'UWA/Class/Model',
     'UWA/Class/Collection',
     'UWA/Class/View',
     'DS/WebappsUtils/WebappsUtils',
     'DS/PlatformAPI/PlatformAPI',
     'DS/W3DXComponents/Collections/ActionsCollection',
     'DS/W3DXComponents/Skeleton',
     'DS/W3DXComponents/Views/Layout/ListView',
     'DS/W3DXComponents/Views/Layout/GridScrollView',
     'DS/W3DXComponents/Views/Item/TileView',
     'DS/W3DXComponents/Views/Item/ThumbnailView',
     'DS/UIKIT/Spinner',
     'DS/SMAProcRunAbaqusUI/Collection/Session',
     'DS/SMAProcRunAbaqusUI/Views/ToolInputsView',
     'DS/SMAProcRunAbaqusUI/Views/ToolSettingsView',
     'DS/SMAProcRunAbaqusUI/Views/ToolOutputsView',
     'DS/SMAProcRunAbaqusUI/Views/ToolExecutionView',
     'DS/SMAProcRunAbaqusUI/Views/ManageDataView',
     'DS/SMAProcRunAbaqusUI/Views/ToolRunsView',
     'DS/SMAProcADUI/ad-execdir/ADExecDir',
	 'DS/SMAProcADUI/ad-util/ADAMDUtil'
     ], 
     function(UWACore,
    		  Model, 
			  Collection, 
			  View,
			  WebappsUtils,
			  PlatformAPI,
			  ActionsCollection, 
			  Skeleton, 
			  ListView,
			  GridScrollView,
			  TileView,
			  ThumbnailView,
			  Spinner,
			  Session, 
			  ToolInputsView, 
			  ToolSettingsView, 
			  ToolOutputsView, 
			  ToolExecutionView,
			  ManageDataView,
			  ToolRunsView,
			  ExecDir,
			  ADAMDUtil) {

        'use strict';
  	 
    	var onItemViewSelect = function() {
    		myWidget.closeStudyButton.hide();    
    	};
   	 
    	var onItemViewUnSelect = function() {
    	};
    	
    	
    	var onAddToolsAccept = function(event){
    		event.preventDefault();
    		event.stopPropagation();
    		//myWidget.loadingSpinner.show();
    		var selectedToolDefs = this._toolAddDlg.getSelectedToolDefs();    		
    		this.collection.addTools(selectedToolDefs);
    	};
    	
    	var showAppMessage = function(message){
			myWidget.appMessage = myWidget.createNotification("appMessage");
			if(widget.body.getElement("#appMessage")){
				widget.body.getElement("#appMessage").destroy();
			}
			myWidget.appMessage.inject(widget.body);
			myWidget.appMessage.logMessage(message, "appMessage"); 
    	};
    	
    	var onButtonClick = function(button, event) {
    		event.preventDefault();
    		event.stopPropagation(); 
    		
    		if(myWidget.hasWrite){    		
	        	if (!this._toolAddDlg) {
	        		this._toolAddDlg = UWACore.createElement('ad-tool-add-dialog',{showOk : false, filterAbq : true});       
	        		this._toolAddDlg.inject(widget.body);
	        	}else{
	        		this._toolAddDlg.destroy();
	        		this._toolAddDlg = UWACore.createElement('ad-tool-add-dialog',{showOk : false, filterAbq : true});       
	        		this._toolAddDlg.inject(widget.body);
	        	}
	        	
	        	this._toolAddDlg.headerText = "Select Application";
	        	this._toolAddDlg.addEventListener('accept', onAddToolsAccept.bind(this), false);        	
	        	
	        	this._toolAddDlg.showDialog();
	        	
	        	var currentSession = document.getElementById("runAbqSession");
	        	if (currentSession.hasPendingUpdates()){
	    	    	// flush pending data
	    	    	var onSuccess = function (httpRequest, isFlushComplete) {
	    	        	if (isFlushComplete) {
	    	               	this._toolAddDlg.showOk = true;
	    	        	}
	    	        }.bind(this);
	    	        
	    	    	var onError = function (httpRequest, isFlushComplete) {
	            		this._toolAddDlg.showOk = true;        		
	    	        }.bind(this);    	    	
	    	        currentSession.flushPendingUpdates(onSuccess, onError);
	        	}else{
	        		this._toolAddDlg.showOk = true;
	        	}
    		}else{
    			myWidget.onNoWriteAccess();
    		}
    	};
    	
        var onInfiniteScroll = function () {
            this.container.removeClassName('loading');
            Object.keys(this.contentsViews).map(function(value) {
                this.contentsViews[value].scrollView.useInfiniteScroll(false);
            }.bind(this));
        };        
        
        var jobCompleteEventCheckCallback = function (context, key, successCallback, errorCallback) {
            var onWSComplete, onWSError, options;

            onWSComplete = function (httpRequest) {
                var eventOccurred = false, responseJSON;
                // see if job is complete
                if (httpRequest.response) {
                    // parse response
                    responseJSON = JSON.parse(httpRequest.response);
                    // check the job status, if found
                    if (typeof responseJSON.Job_Status !== 'undefined' && responseJSON.Job_Status && responseJSON.Job_Status === 'Completed') {
                        eventOccurred = true;
                    }
                }
                // call callback, passing boolean indicating whether event occurred
                if (successCallback) {
                    successCallback(eventOccurred);
                }
            }.bind(this);

            onWSError = function (httpRequest) {
                var error = 'Job Web service error';
                if (httpRequest.response) {
                    error = httpRequest.response;
                }
                if (errorCallback) {
                    errorCallback(error);
                }
            }.bind(this);


            options = {
                verb: 'GET',
                uri: myWidget._baseURI + '/resources/slmservices/jobs' + '/' + key.mcsJobId,
                onComplete: onWSComplete,
                onError: onWSError,
            };
            myWidget.spMcsservice.sendRequest(options);
        };
        
        var onRunnerFinishedSuccess = function(occured, context, key){        	
            var jobCompletedMessage = {text:'Job <strong>' + key.activityName + '</strong> Completed', type : 'success', autoRemove : true };
    		myWidget.jobCompletedNotification = myWidget.createNotification("jobCompletedMessage");
    		if(widget.body.getElement("#jobCompletedMessage")){
    			widget.body.getElement("#jobCompletedMessage").destroy();
    		}
    		myWidget.jobCompletedNotification.inject(widget.body);
    		myWidget.jobCompletedNotification.logMessage(jobCompletedMessage, "jobCompletedMessage");
        };
        
        var onRunnerFinishedError = function(response){        	
        	//Do nothing
        };
        
    	var runSuccessHandler = function(view, event){  		
    		
            // update the tool if necessary
            if (event.detail.tool.workDir !== event.detail.execDir) {
                // save the directory if we're not deleting it
                if (!event.detail.execDir.removeAfterJob) {
                    event.detail.tool.workDir = event.detail.execDir;
                }
            }
            
            // update the execution directory if necessary
            if (event.detail.execDir) {
                event.detail.execDir.creating = false;
            }   		
    		
    		var currentJobTrackerkey = {
    				mcsJobId: event.detail.execDir.mcsJobID,
    				activityName : event.detail.tool.name    				
    		};
    		
    		var currentJobTracerEvent = currentJobTrackerkey.mcsJobId + "_" + currentJobTrackerkey.activityName;    		
    		myWidget.eventChecker.addEventCheckDef(currentJobTracerEvent, jobCompleteEventCheckCallback.bind(this));
    		myWidget.eventChecker.startListening(currentJobTracerEvent, this, currentJobTrackerkey, true, 300, 0, onRunnerFinishedSuccess.bind(this), onRunnerFinishedError.bind(this));
    		
    		var messageContent = 'Started new job <strong>' + event.detail.tool.name + '</strong>. The job can be monitored in the Job Monitor widget. Output files can be viewed in the Content section.';

            var jobStartedMessage = {text : messageContent, type : 'success', autoRemove : true, autoRemoveDelay: 10000};
    		myWidget.jobStartedNotification = myWidget.createNotification("jobStartedMessage");
    		if(widget.body.getElement("#jobStartedMessage")){
    			widget.body.getElement("#jobStartedMessage").destroy();
    		}
    		myWidget.jobStartedNotification.inject(widget.body);
    		myWidget.jobStartedNotification.logMessage(jobStartedMessage, "jobStartedMessage");
    		
            event.stopPropagation();
            event.cancelBubble = true;
            
    	};
        
    	var runErrorHandler = function(view, event){    		
    		
            // update the execution directory if necessary
            if (event.detail.execDir) {
                event.detail.execDir.creating = false;
            }
        	
        	
        	if (event.detail.error === DS.SMAProcADUI.ADRun.ERRORS.jobNotStarted) {
        		var jobFailMessage = {text:'Unable to start job <strong>' + 
        									event.detail.tool.name + 
        									'</strong>.' +
        									event.detail.message,
        									type : 'error', 
        									autoRemove : true};
        		myWidget.jobFailNotification = myWidget.createNotification("jobFailMessage");
        		if(widget.body.getElement("#jobFailMessage")){
        			widget.body.getElement("#jobFailMessage").destroy();
        		}
        		myWidget.jobFailNotification.inject(widget.body);
        		myWidget.jobFailNotification.logMessage(jobFailMessage, "jobFailMessage");                
        	}
        	else if (event.detail.error === DS.SMAProcADUI.ADRun.ERRORS.execDirNotInitialized) {
        		var jobFailMessage2 = {text:'Job <strong>' + 
        									 event.detail.tool.name + 
        									 '</strong>, started but the execution directory could not be initialized: ' + 
        									 '</strong>', 
        									 type : 'error', 
        									 autoRemove : true};
        		myWidget.jobFailNotification2 = myWidget.createNotification("jobFailMessage2");
        		if(widget.body.getElement("#jobFailMessage2")){
        			widget.body.getElement("#jobFailMessage2").destroy();
        		}
        		myWidget.jobFailNotification2.inject(widget.body);
        		myWidget.jobFailNotification2.logMessage(jobFailMessage2, "jobFailMessage2");  
        	}
            event.stopPropagation();
            event.cancelBubble = true;
    	};

    	
    	var onRunToolAccept = function(event){
    	
    		event.preventDefault();
    		event.stopPropagation(); 
	    	var view = this._view;    	
 
	       	var stationManager = document.getElementById("stationManager"), execDir, now = new Date(), formatter, dateTime, mySession = view.model.get('session');

	       	if (!myWidget._toolRunner) {
        		myWidget._toolRunner = UWACore.createElement('ad-run', {id: "toolRunner"});       
        		myWidget._toolRunner.inject(widget.body);
        	}else{
        		myWidget._toolRunner.destroy();
        		myWidget._toolRunner = UWACore.createElement('ad-run', {id: "toolRunner"});   
        		myWidget._toolRunner.inject(widget.body);
        	}
	        	
        	// set up work execution directory
        	var toolInstance = view.model.get("toolInstance");
        	if (toolInstance.workDir && toolInstance.workDir.path && (toolInstance.workDir.path.length > 0)) {
        		execDir = toolInstance.workDir;
            	execDir.removeAfterJob = toolInstance.removeWorkDir;
        	}
        	else {
        		// create new execution directory and add to tool
            	execDir = new ExecDir.ADExecDir();
            	execDir.name = view.model.get('actTitle') + ' ' + now.toLocaleString().replace(/\u200E/g, '').replace(/\u200F/g, '');
                if (toolInstance.isOnCloud()) {
                    execDir.station = null;
                	execDir.removeAfterJob = true;
                }
                else {
                    execDir.station = toolInstance.station;
                	execDir.removeAfterJob = toolInstance.removeWorkDir;
                }
            	execDir.lastModified = now.toJSON();
            	execDir.accessDisabled = true;
            	execDir.creating = true;                                      		
        	}
        	
             // if we're removing this directory after execution, we need to 
            // remove it from all tools that use it, because it could go 
            // away at any time and shouldn't be used after this particular
            // tool execution
            if (execDir.removeAfterJob) {
                for (var i = 0; i < mySession.tools.length; i++) {
                    if (mySession.tools[i].workDir === execDir) {
                    	mySession.setWorkDir(null);
                    }
                }
            }
        	
        	myWidget._toolRunner.addEventListener("success", runSuccessHandler.bind(this, view));
        	myWidget._toolRunner.addEventListener("error", runErrorHandler.bind(this, view));
        	
        	// add to station manager
        	if(!stationManager){
        		stationManager = UWACore.createElement('ad-station-manager', {id:"stationManager"});
        		stationManager.inject(window.widget.body);
        	}
        	//document.body.appendChild(this._stationManager);
        	stationManager.session = mySession;
        	stationManager.addExecDir(execDir);
        	myWidget._toolRunner.session = mySession;
        	
            formatter = new Intl.DateTimeFormat(undefined, {
                month: 'short',
                year: 'numeric',
                day: '2-digit',
                weekday: 'short',
                hour: '2-digit',
                minute: '2-digit'
            });
            
            dateTime = formatter.format(now);
            this.model.set("lastExecuted", dateTime);

            var jobStartingMessage = {text:'Starting new job <strong>' + view.model.get('actTitle') + '</strong>', type : 'info', autoRemove : true};
    		myWidget.jobStartingNotification = myWidget.createNotification("jobStartingMessage");
    		if(widget.body.getElement("#jobStartingMessage")){
    			widget.body.getElement("#jobStartingMessage").destroy();
    		}
    		myWidget.jobStartingNotification.inject(widget.body);
    		myWidget.jobStartingNotification.logMessage(jobStartingMessage, "jobStartingMessage");
    		            
        	var checkInt = window.setInterval(checkPending, 1000);
        	function checkPending(){
            	if (document.getElementById("runAbqSession").hasPendingUpdates()){
                	console.log("Pending updates...wait till they finish");          
            	}else{	            
    	            window.clearInterval(checkInt);
    	            myWidget._toolRunner.runTool(toolInstance, execDir); 
    	        } 
        	}  		
    	};
    	
        var runToolHandler = function(view){        	
        	var errorMessage  ="";
        	if(myWidget.hasWrite){        	
	        	if(!this._view){
	        		this._view = view;
	        	}
	      	 	
	        	if (!myWidget._toolRunDlg) {
	        		myWidget._toolRunDlg = UWACore.createElement('ad-tool-run-dialog',{
	        			abaqusStudyMode: true
	        		});           
	        		myWidget._toolRunDlg.inject(widget.body);
	        	}else{
	        		myWidget._toolRunDlg.destroy();
	        		myWidget._toolRunDlg = UWACore.createElement('ad-tool-run-dialog', {
	        			abaqusStudyMode: true
	        		});    
	        		myWidget._toolRunDlg.inject(widget.body);
	        	}
	        	        	
	        	myWidget._toolRunDlg.addEventListener('accept', onRunToolAccept.bind(this), false); 
	        	myWidget._toolRunDlg.tool = view.model.get("toolInstance");
	        	myWidget._toolRunDlg.session = view.model.get('session');
	        	
	        	if(myWidget._toolRunDlg.tool.isRunnable && view.model.get("isRunnable")){
	        		myWidget._toolRunDlg.showDialog();
	        	}else{
	        		if(!myWidget._toolRunDlg.tool.isRunnable){	        		
	        			errorMessage = {text: "Errors in tool configration must be corrected before proceeding with run. Please contact your administrator for help. ", type : "error"};
	        		}else if(!view.model.get("isRunnable")){
	        			errorMessage = {text: "Missing option. You must enter all required options before running the job.", type : "error"};
	        		}
	        		
	        		myWidget.badToolConfig = myWidget.createNotification("badToolConfig");
	        		if(widget.body.getElement("#badToolConfig")){
	        			widget.body.getElement("#badToolConfig").destroy();
	        		}
	        		myWidget.badToolConfig.inject(widget.body);
	        		myWidget.badToolConfig.logMessage(errorMessage, "badToolConfig");
	        	}
        	}else{
        		myWidget.onNoWriteAccess();
        	}
        
        };
        
        var onRemoveToolsAccept = function(){        	
        	myWidget.skeletonNode.slideBack();
        	if(this.model && this.model.collection){
        		this.model.collection.removeTool(this.model);
        	}
        };
        
        var deleteToolHandler = function(view){        	
        	if(myWidget.hasWrite){  
				var toolRemoveDlg = document.getElementById("toolRemoveDialog");
				if (!toolRemoveDlg){
					this._toolRemoveDlg = UWACore.createElement('ad-tool-remove-dialog', {id: "toolRemoveDialog"}).inject(widget.body);						
				}else{
					this._toolRemoveDlg = toolRemoveDlg;	        	
				}		
				
	        	var toolObject = {
	        			name : view.model.get('title'),
	        			description : view.model.get('description')
	        		};        	
	        	
	        	this._toolRemoveDlg.selectedTools = [toolObject];
	        	this._toolRemoveDlg.showDialog();
	        	
	        	this._toolRemoveDlg.addEventListener('accept', onRemoveToolsAccept.bind(this), false);
        	}else{
        		myWidget.onNoWriteAccess();
        	}
        };
        
        var closeStudyHandler = function(view){ 
        		myWidget.reload = false;
    			//hack to clear execdir auto refresh timeout. Clears all timeouts
    			var lastTimeOut = setTimeout(";");
    			for (var i = 0 ; i < lastTimeOut ; i++) {
    			    clearTimeout(i); 
    			}
        		stopMonitorFileJobs.call(this);
        		myWidget.skeletonNode.destroy();        		
       			myWidget.onLoad();        	
        };       
       
        var stopMonitorFileJobs = function () {
	        var i, 
	        	nextExecDir,
	        	currentSession = document.getElementById("runAbqSession");
       	
        	if (currentSession && myWidget.fileMonitor) {
                // iterate over execution directories, calling file monitor to stop monitor file jobs
                if (currentSession && currentSession.executionDirectories) {
                    for (i = 0; i < currentSession.executionDirectories.length; i++) {
                    	nextExecDir = currentSession.executionDirectories[i];
                    	if (nextExecDir.filemonJobID) {
                            myWidget.fileMonitor.stopFileMonitor({
        		        		execDir: nextExecDir,
                            	physicalID: currentSession.processID,
        		        		onComplete: null, // we don't care about the result
        		        		onFailure: null
        		        	});
                    	}
                    }
                }
	        }
        };
        
    	var renderers = {
		  			toolRenderer: {
						collection: Session,
			            //view: AppRootView,
		            	viewOptions : {
		                  	buttonGroup: {
		                    	buttons : [{
		                    		id: "addJobButton",
		                      		icon : 'plus',
		                      		value : 'Add Job',
		                      		className : 'default'
		                    	}]
	                  	},
                        events : {
                            onInfiniteScroll : onInfiniteScroll,
                            onClick : onButtonClick
                        },
	                    contents: {
	                      	useInfiniteScroll : true,
	                      	usePullToRefresh : false,
                            views : [
                                   {
                                       id : 'thumbnail',
                                       view : GridScrollView,
                                       itemView: ThumbnailView
                                   },
                                   {
                                       id : 'tile',
                                       view : GridScrollView,
                                       itemView : TileView
                                   },
                                   {
                                       id : 'list',
                                       view : ListView,
                                       itemView: TileView,
                                       selectionMode : 'oneToOne'
                                   }
                               ],
                       		itemViewOptions: {
                                templateHelpers: {
                                    content: function() {
                                        var data = this.description;
                                        return data;
                                    },
                                    image: function() {
                                    	return WebappsUtils.getWebappsAssetUrl('SMAProcRunAbaqusUI', this.portraitIcon);
                                    }
                                },
                        	},
	                      	events : {
	                        	onItemViewUnSelect : onItemViewUnSelect,
	                        	onItemViewSelect : onItemViewSelect
	                      	}
	                    }
					},
		                  
                	idCardOptions: {
                        actions: function () {
                     		if (this.id === 'manageData') {
                     			return [
                     			         {
        	                                text: 'Close this study',
        	                                icon: 'cancel-circled',
        	                                handler: closeStudyHandler
        	                             }];
	                    	}
                     		else {
                                return [
                                        {
                                            text: 'Run this job',
                                            icon: 'play',
                                            handler : runToolHandler
                                        },
                                        {
        	                                text: 'Delete this job',
        	                                icon: 'trash',
        	                                handler: deleteToolHandler
        	                                                     },
                                        {
        	                                text: 'Close this study',
        	                                icon: 'cancel-circled',
        	                                handler: closeStudyHandler
        	                                                     }
                                    ];
                     		}
                        },
                        attributesMapping: {
                          	date: function() {
      /*                    	  	var lastExecDate = this.get('lastExecuted');
                          	  	if (lastExecDate === 'notexecutable') {
                          	  		return '';
                          	  	}
                          	  	else if (lastExecDate && lastExecDate.length > 0) {
										return 'Last executed on ' + lastExecDate + " in this session";	                                		  
                          	  	}
                          	  	else {
                          		  	return ' This job has not been run in this session';
                          	  	}*/
                          		var description, lastExecDate = this.get('lastExecuted');
                          		if (lastExecDate === 'notexecutable'){
                          			return '';
                          		}else{
                          			description = this.get("subtitle");
	                          		if(description !== ""){
	                          			return description;
	                          		}else{
	                          			return "Unknown Application";
	                          		}
                          		}
                           	
                          	
                          	}
                       	},

                        editableElements: ['title', 'date'],
                        
                     	facets: function () {
                     		if (this.id === 'manageData') {
                     			return [
                                      {
                                          name : 'Manage Data',
                                          handler : Skeleton.getRendererHandler(ManageDataView)
                                      }
	                              ];
	                    	}
	                    	else {
	                    		return [
                                      {
                                          name : 'Options',
                                          text : 'Options',
                                          icon : 'cog',
                                          handler : Skeleton.getRendererHandler(ToolSettingsView)
                                      },
                                      {
                                          name : 'Execution',
                                          text : 'Run Options',
                                          icon : 'back-in-time',
                                          handler : Skeleton.getRendererHandler(ToolExecutionView)
                                      },
                                      {
                                          name : 'Output',
                                          text : 'Output',
                                          icon : 'database',
                                          handler : Skeleton.getRendererHandler(ToolOutputsView)
                                      },
 /*                                     {
                                          name : 'Runs',
                                          text : 'Runs',
                                          icon : 'fast-forward',
                                          handler : Skeleton.getRendererHandler(ToolRunsView)
                                      },*/
                                  ];
                        	}
                       	}
                   	}
               }
     	};
    	
     	var skeletonOptions = {
            // Renderer that is going to be used for the Root (panel 0), if not specified the first declared renderer is used
            //root: 'toolRenderer',

            useRootChannelView: widget.getValue('view') === 'channel',

            responsiveTrigger: function () {
                var viewType = widget.getView().type;

                // If channel view is active then set responsive trigger to maximize
                if (widget.getValue('view') === 'channel') {
                    return viewType === 'maximized' || viewType === 'fullscreen';
                } else {

                    // If normal view, then let the width threshold of the skeleton set the responsiveness
                    return false;
                }
            },
            events:{
            	onSlide: function(view, model){            		
            		if(!view){       			            			
            			myWidget.closeStudyButton.show();
            		}            		
            	}
            }
     	
    	};
		
		var triggerCreateEvent = function(prevInfo){
            if (document.createEvent && myWidget.addCmp.dispatchEvent) {
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("onObjectInstantiate", true, true);
                evt.detail = {
                		"processId": prevInfo.processId,
                		"processName" : prevInfo.processName
                		};
                myWidget.addCmp.dispatchEvent(evt); 
            } else if (myWidget.addCmp.fireEvent) {
            	var event = new CustomEvent("onObjectInstantiate", { "detail": {
            																	"processID": prevInfo.processId,  
            																	"processName" : prevInfo.processName
            																	} 
            														});
            	myWidget.addCmp.fireEvent(event);
            }
		};
		
    	var reloadFunc = function(prevInfo){   		
            if(prevInfo !== null && myWidget.reload){            	
            	if(myWidget.dropCmp && myWidget.dropCmp.removeDropNotes && typeof(myWidget.dropCmp.removeDropNotes) == 'function'){
            		triggerCreateEvent.call(this,prevInfo);
            	}else{
            		setTimeout(reloadFunc.bind(this, prevInfo), 100);
            	}
            }
         };
     	
    	var timerFunc = function() {
    		
    		
    		widget.setTitle("");    		
    		var securityContext = this.spDashboard.getSecurityContext();
    		if (this._uiReady && securityContext) {
                // create sp-variables
                myWidget.mcsBaseURL = UWACore.createElement('sp-variable', { name : 'mcsBaseURL' });
                myWidget.mcsBaseURL.setValue(this.spDashboard.getMcsUri());
                
                myWidget.mcsWSBaseURL = UWACore.createElement('sp-variable', { name : 'mcsWSBaseURL' });
                myWidget.mcsWSBaseURL.setValue(this.spDashboard.getMcsUri() + '/resources/slmservices');
                
                myWidget.eedBaseURL = UWACore.createElement('sp-variable', { name : 'eedBaseURL' });
                myWidget.eedBaseURL.setValue(window.location.protocol + '//' + window.location.hostname + ':446/SMAExeServer-REST');
                
                myWidget.eedBaseURL = UWACore.createElement('sp-variable', { name : 'securityContext' });
                myWidget.eedBaseURL.setValue(securityContext);

                widget.body.empty(); 

                myWidget.closeStudyButton = UWACore.createElement('button',{
                	"class" :"closeStudyButton btn btn-default",
                	value: "Close",
                	text : "Close",
                	title : "Close this study"
                });

                myWidget.closeStudyButton.addEventListener("click", closeStudyHandler.bind(this));
                
                myWidget.closeStudyButton.inject(widget.body);
                myWidget.closeStudyButton.hide();
                

                
                myWidget.dropCmp = UWACore.createElement('sp-drop');
                myWidget.dropCmp.setAttributes({
                	"drop-note-text": "Study",
                	"show-add": true,
                	"error-message": "You can drop only a single " 
                });
                
                myWidget.addCmp = UWACore.createElement('ad-add-process', {
                												templatetype: "type_Simulation", 
                												usage: "Adhoc",
                												dialogtitle: "Study"});
                
                myWidget.addCmp.inject(widget.body);                            
                myWidget.dropCmp.inject(widget.body);
                myWidget.createSpinner();                
                
                if(myWidget.dropCmp != null){
                	myWidget.dropCmp.addEventListener('onObjectDrop', function(event){
	                	
	            		event.preventDefault();
	            		event.stopPropagation();
	            		 myWidget.reload = true;
	            		 myWidget.hasWrite = true;
	            		 
	            		if (myWidget.invalidProcNotif){
	            			myWidget.invalidProcNotif.destroy();
	            		}
	            		
            			var procData = myWidget.dropCmp.objectData;
	              		widget.setValue('processId', procData.objectId);              		
	              		widget.setValue('AbaqusStudyProcessInfo',{
			              				processId: procData.objectId,
			              				processName : procData.displayName	              			
	              						});

	              		if(myWidget.loadingSpinner){
	              			myWidget.loadingSpinner.show();
	              			myWidget.spinnerOverlay.show();
	              		}
	                    
	              		var onGetProcessWSComplete = function(httpRequest){
	              			var response = JSON.parse(httpRequest.response);
                        	myWidget.loadingSpinner.hide(); 
                        	myWidget.spinnerOverlay.hide();
                        	var activities = [];
                        	if (response.attributes['Simulation Kind'] === 'adhoc'){
                        		//Check if the process has activities other than abaqus  
                        		
                        		var oncheckActivitiesWSComplete = function(httpRequest){
                        			var activities = JSON.parse(httpRequest.response), steps = [], canLoad = false;
                                	if(activities && activities.length > 0){
                                		checkActivities:
                                    	for (var i=0; i<activities.length; i++){
                                    		steps = myWidget.getSteps(activities[i]);
                                    		for(var j = 0 ; j < steps.length; j++){               		             		
                                    			//if the OS Command step's application type is not Abaqus then set isLoadable to false
                                    			var extensionName = myWidget.getExtensionName(steps[j]);                			
                                    			if (extensionName === 'com.dassault_systemes.sma.adapter.OSCommand' || extensionName === 'com.dassault_systemes.smampa.adapter.cae3dx'){
                                    				var appName = myWidget.getApplicationName(steps[j]);
                                    				if (appName && (appName.toLowerCase().indexOf('abaqus') >= 0 || appName.toLowerCase().indexOf('cae') >= 0)){
                                    					canLoad = true;
                                    				}else{
                                    					canLoad = false;
                                    					break checkActivities;
                                    				}
                                    			}
                                    		}
                                    	}
                                	}else{
                                		canLoad = true;
                                	}
                                	if(canLoad){
                                		myWidget.closeStudyButton.show();
                                		widget.setTitle(myWidget.dropCmp.objectTitle);	                                    		
		                        		myWidget.skeletonNode = myWidget.createRunAbaqusApp();
		                        		
		                        		//For FF and IE. render() method doesn't return a real html element but sp-drop requires it to be.
		                        		var container = UWA.createElement('span');
		                        		myWidget.skeletonNode.render().inject(container);
		                        		myWidget.dropCmp.injectContent(container);
	                        		}else{
		                        		var errorMessage = {text: "Abaqus Study accepts processes that only contains \"abaqus\" or \"cae\" tools. Please verify and try again.", type : "error"};
		                        		myWidget.invalidProcNotif = myWidget.createNotification("invalidProcNotif");
	    	                    		if(widget.body.getElement("#invalidProcNotif")){
	    	                    			widget.body.getElement("#invalidProcNotif").destroy();
	    	                    		}
		                        		myWidget.invalidProcNotif.inject(widget.body);
		                        		myWidget.invalidProcNotif.logMessage(errorMessage, "invalidProcNotif");
	                            		if(!myWidget.skeletonNode){
	                            			myWidget.dropCmp.revertToDrop();
    	                            		}
	                        			}
                        			
                        		}.bind(this);
                        		
                        		var oncheckActivitiesWSError = function(){
                                	console.log("Unable to get activities information");
	                        		var errorMessage = {text: "Unexpected error while retrieving process information. Please try again.", type : "error"};
	                        		myWidget.invalidProcNotif = myWidget.createNotification("invalidProcNotif");
    	                    		if(widget.body.getElement("#invalidProcNotif")){
    	                    			widget.body.getElement("#invalidProcNotif").destroy();
    	                    		}
	                        		myWidget.invalidProcNotif.inject(widget.body);
	                        		myWidget.invalidProcNotif.logMessage(errorMessage, "invalidProcNotif");
                            		if(!myWidget.skeletonNode){
                            			myWidget.dropCmp.revertToDrop();
	                            		}
                            		myWidget.closeStudyButton.hide();
                        		}.bind(this);                  
                        		
                        		var checkActivitiesWSOptions = {
                        				verb:'GET',
                        				uri: myWidget._baseURI + '/resources/slmservices/activity/'+ '?simId=' +  procData.objectId,
                        				onComplete: oncheckActivitiesWSComplete,
                        				onError: oncheckActivitiesWSError                        				
                        		};                     		
                        		                        		
                        		myWidget.spMcsservice.sendRequest(checkActivitiesWSOptions);
                        		
                        	}else{                                		
                        		var errorMessage = {text: "Abaqus Study only accepts processes of type \"adhoc\". Please verify and try again.", type : "error"};
                        		myWidget.invalidProcNotif = myWidget.createNotification("invalidProcNotif");
	                    		if(widget.body.getElement("#invalidProcNotif")){
	                    			widget.body.getElement("#invalidProcNotif").destroy();
	                    		}
                        		myWidget.invalidProcNotif.inject(widget.body);
                        		myWidget.invalidProcNotif.logMessage(errorMessage, "invalidProcNotif");
                        		if(!myWidget.skeletonNode){
                        			myWidget.dropCmp.revertToDrop();
                        		}
                        		myWidget.closeStudyButton.hide();
                        	}                    	
	              		}.bind(this);
	              		
	              		var onGetProcessWSError = function(){
                        	myWidget.loadingSpinner.hide();	   
                        	myWidget.spinnerOverlay.hide();
                        	console.error('Failed to get process information.');
                        	var errorMessage = {text: "Failed to get process information. Please try again.", type : "error"};
                    		myWidget.invalidProcNotif = myWidget.createNotification("invalidProcNotif");
                    		if(widget.body.getElement("#invalidProcNotif")){
                    			widget.body.getElement("#invalidProcNotif").destroy();
                    		}
                    		myWidget.invalidProcNotif.inject(widget.body);
                    		myWidget.invalidProcNotif.logMessage(errorMessage, "invalidProcNotif");
                    		if(!myWidget.skeletonNode){
                    			myWidget.dropCmp.revertToDrop();
                    		}
                    		myWidget.closeStudyButton.hide();
	              		}.bind(this);
	            
	              		
	              		var getProcessWSOptions = {
	              				verb: "GET",
	              				uri: myWidget._baseURI + '/resources/slmservices/simulations/' + procData.objectId,
	              				onComplete: onGetProcessWSComplete,
	              				onError: onGetProcessWSError
	              		};
	              		
	              		myWidget.spMcsservice.sendRequest(getProcessWSOptions);
	              		
	                  }); // End drop event
	                
                	myWidget.dropCmp.addEventListener("objectcreate", function(event){
	            		event.preventDefault();
	            		event.stopPropagation();
	            		myWidget.addCmp.showDialog();	            		
	                });
	                
	                myWidget.addCmp.addEventListener("onObjectInstantiate", function(event){
	            		event.preventDefault();
	            		event.stopPropagation();	
	            		myWidget.reload = true;	            		
	            		myWidget.hasWrite = true;
	            		//Check if an object exists in the database
	            		
	            		var onobjectMetaWSComplete = function(httpRequest){
	            			var metaResponse  = JSON.parse(httpRequest.response);
                        	if(metaResponse.datarecords.datagroups[0].objectId !== ""){
                        		//if response has objectId then the object exists otherwise it doesn't
			            		myWidget.dropCmp.removeDropNotes();	            		
			            		widget.setValue('processId', event.detail.processId);              		             		
			              		
			              		widget.setValue('AbaqusStudyProcessInfo',{
											              				processId: event.detail.processId,
											              				processName : event.detail.processName	              			
									              						});				            		
			            		widget.setTitle(event.detail.processName);				            		
		                		myWidget.skeletonNode = myWidget.createRunAbaqusApp();                           		                       		
		               		
		                		//For FF and IE. render() method doesn't return a real html element but sp-drop requires it to be.
		                		var container = UWA.createElement('span');
		                		myWidget.skeletonNode.render().inject(container);
		                		myWidget.dropCmp.injectContent(container);
		                		myWidget.closeStudyButton.show();
                        	}else{
                        		console.log("The study might have been delete. Verify and try again");
                        		myWidget.dropCmp.revertToDrop();
                        	}
	            		}.bind(this);
	            		
	            		var onobjectMetaWSError = function(){
                        	console.log("Web service call to find the existence of the study failed");
                        	myWidget.dropCmp.revertToDrop();
	            		}.bind(this);
	            		
	            		
	            		var objectMetaWSOptions = {
	            				verb: 'GET',
	            				uri: myWidget._baseURI + '/resources/e6w/service/SMA_MetaData?objectId=' + event.detail.processId,
	            				onComplete: onobjectMetaWSComplete,
	            				onError: onobjectMetaWSError
	            		};
	            		
	            		myWidget.spMcsservice.sendRequest(objectMetaWSOptions);	            		
	                });
	                
	                
	                myWidget.addCmp.addEventListener("toggleSpinner", function(event){
	            		event.preventDefault();
	            		event.stopPropagation();	            		
	            		myWidget.loadingSpinner.toggle();
	            		myWidget.spinnerOverlay.toggle();
	                });
	               

                }else{
                	var mainDiv = new UWA.Element('div', {
						'id': 'mainDiv',
						'src': ''
					}).inject(widget.body);
					mainDiv.innerHTML = 'Unable to load widget';
            	}   
    		}
    		else {
    			setTimeout(timerFunc.bind(this), 100);
    		}
    		
    		var prevInfo = widget.getValue("AbaqusStudyProcessInfo"); 
    		if(typeof(prevInfo) !== 'undefined'){
    			reloadFunc.call(this, prevInfo);
    		}
    	};
    	
        var myWidget = {};
        myWidget._baseURI = null;
        myWidget.runAbaqusApp = null;
        myWidget.invalidProcNotif = null;
        myWidget.jobStartingNotification = null;
        myWidget.jobStartedNotification = null;
        myWidget.jobFailNotification=null;
        myWidget.jobFailNotification2=null;        
        myWidget.loadingSpinner = null; 
        myWidget.spinnerOverlay = null;
        myWidget.addCmp = null;
        myWidget.dropCmp = null;
        myWidget.reload = true;
        myWidget.hasWrite = true;
        
        myWidget.onLoad = function () {
                myWidget.spDashboard = UWACore.createElement('sp-dashboard');
                myWidget.spDashboard.addSecurityContextPreference();                
                
                var importBasePath = WebappsUtils.getWebappsBaseUrl();
                
                ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcSP/sp-cos-filemonitor/sp-cos-filemonitor.html', 'DS.SMAProcSP.SPCOSFileMonitor', function () {
                    myWidget.fileMonitor = UWACore.createElement('sp-cos-filemonitor');
                    myWidget.fileMonitor.unauthenticatedStations = true;
  	  		  	}.bind(this));
              
                this._spDropLoaded = false;			        	  		  
                ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcSPUI/sp-drop/sp-drop.html', null, function () {
  	  			  	this._spDropLoaded = true;
  	  		  	}.bind(this));
              
              this._NotificationLoaded = false;			        	  		  
              ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcSPUI/sp-notification/sp-notification.html', null, function () {
	  			  	this._NotificationLoaded = true;
	  		  	}.bind(this));                  
  		  
	  		  this._toolRunnerLoaded = false;			        	  		  
	  		  ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-run/ad-run.html', null, function () {
	  			  	this._toolRunnerLoaded = true;
	  		  	}.bind(this));
	  		  
	  		  this._toolAddLoaded = false;			        	  		  
	  		  ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-tool-add-dialog/ad-tool-add-dialog.html', null, function () {
	  			  	this._toolAddLoaded = true;
	  		  	}.bind(this));
	  		  
	  		  this._stationManagerLoaded = false;			        	  		  
	  		  ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-station-manager/ad-station-manager.html', null, function () {
	  			  	this._stationManagerLoaded = true;
	  		  	}.bind(this));
	  		  
	  		  this._toolRemoveDialogLoaded = false;			        	  		  
	  		  ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-tool-remove-dialog/ad-tool-remove-dialog.html', null, function () {
	  			  	this._toolRemoveDialogLoaded = true;
	  		  	}.bind(this));
        
              this._toolRunDialogLoaded = false;			        	  		  
              ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-tool-run-dialog/ad-tool-run-dialog.html', null, function () {
	  			  	this._toolRunDialogLoaded = true;
	  		  	}.bind(this));
	  		  
              this._processAddDialogLoaded = false;			        	  		  
              ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-add-process/ad-add-process.html', null, function () {
	  			  	this._processAddDialogLoaded = true;
	  		  	}.bind(this));
	  		  
              this._eventCheckerLoaded = false;			        	  		  
              ADAMDUtil.loadWebComponent(importBasePath + 'SMAProcADUI/ad-app-event-checker/ad-app-event-checker.html', null, function () {
	  			  	this._eventCheckerLoaded = true;
	  		  	}.bind(this));
              
                // wait for Web components (directly and indirectly imported) that have AMD dependencies
              	myWidget._uiReady = false;
                ADAMDUtil.waitForWebComponents([
                                                //'DS.SMAProcSPUI.SPCreditsCalculator',//
                                                //'DS.SMAProcADUI.ADMDataRemoveDialog',//
                                                //'DS.SMAProcADUI.ADMDataView',//
                                                //'DS.SMAProcADUI.ADMultiviewExecdir',
                                                //'DS.SMAProcADUI.ADMultiviewFile',
                                                //'DS.SMAProcADUI.ADMultiviewFolder',
                                                //'DS.SMAProcADUI.ADMultiviewPart',
                                                //'DS.SMAProcADUI.ADPropertiesExecdir',//
                                                'DS.SMAProcADUI.ADRun',
                                                //'DS.SMAProcADUI.ADSession',//
                                                //'DS.SMAProcADUI.ADStationCredentials',//
                                                'DS.SMAProcADUI.ADStationManager',
                                                //'DS.SMAProcADUI.ADToolConfigOutputFiles',//
                                                //'DS.SMAProcADUI.ADToolConfigWhere',//
                                                //'DS.SMAProcADUI.ADToolConfigWhereCloud',//
                                                //'DS.SMAProcADUI.ADToolConfigWhereWrapper',//
                                                'DS.SMAProcADUI.ADToolManager',
                                                'DS.SMAProcADUI.ADToolRemoveDialog',
                                                'DS.SMAProcADUI.ADToolRunDialog'], function () {
                	myWidget._uiReady = true;
  	  		  	});
 	  	
	  		  var baseUri = widget.getUrl();
                  if (baseUri.indexOf('/webapps') > -1) {
      				baseUri = baseUri.substring(0, baseUri.indexOf('/webapps'));
      			  }else {
      				baseUri = PlatformAPI.getApplicationConfiguration('app.urls.myapps');
      			  }
              
              this._baseURI = baseUri;  
              myWidget._baseURI = baseUri;     	  		  
              var myAppsUrl = PlatformAPI.getApplicationConfiguration('app.urls.myapps');
              myWidget.spMcsservice = UWACore.createElement('sp-mcsservice');      
              myWidget.spWebservice = UWACore.createElement('sp-webservice');
              myWidget.setTenantId(myAppsUrl);
              widget.setValue('myAppsUrl', myAppsUrl);
              
              var onLicenseWSComplete = function(httpRequest){                	  
            	  var response = JSON.parse(httpRequest.response);                	  
                  if(response.Abaqus_Study){
            		  setTimeout(timerFunc.bind(myWidget), 1);
            	  }else{
            		widget.body.empty();
            		var errorMessage = {text: "You do not have the license required to access the selected application. Please contact your administrator.", type : "error", autoRemove : false, clickToRemove : false};	                		
            		var noLicenseTimer = setInterval(function(){
            			if(widget._NotificationLoaded){
                    		myWidget.licenseErrorNotif = myWidget.createNotification("licenseErrorNotif");
                    		myWidget.licenseErrorNotif.position = "TC";
                    		if(widget.body.getElement("#licenseErrorNotif")){
                    			widget.body.getElement("#licenseErrorNotif").destroy();
                    		}
                    		myWidget.licenseErrorNotif.inject(widget.body);
                    		myWidget.licenseErrorNotif.logMessage(errorMessage, "licenseErrorNotif");
                    		clearInterval(noLicenseTimer);
            			}	                			
            		},100);
            	} 
              }.bind(this);
              
              var onLicenseWSError = function(){
                	widget.body.empty();
                	var errorMessage = {text: "The call to the license server failed. Please try again or contact your administrator.", type : "error", autoRemove : false, clickToRemove : false};
            		var licenseWSFailtimer = setInterval(function(){
            			if(widget._NotificationLoaded){
                    		myWidget.licenseErrorNotif = myWidget.createNotification("licenseErrorNotif");
                    		myWidget.licenseErrorNotif.position = "TC";
                    		if(widget.body.getElement("#licenseErrorNotif")){
                    			widget.body.getElement("#licenseErrorNotif").destroy();
                    		}
                    		myWidget.licenseErrorNotif.inject(widget.body);
                    		myWidget.licenseErrorNotif.logMessage(errorMessage, "licenseErrorNotif");
                    		clearInterval(licenseWSFailtimer);
            			}	                			
            		},100);	
              }.bind(this);
              
              var licenseWSOptions = {
            		  verb: 'GET',
            		  uri: myWidget._baseURI + '/resources/slmservices/license?appNames=Abaqus_Study',
            		  onComplete: onLicenseWSComplete,
            		  onError: onLicenseWSError
              };
              
              myWidget.spMcsservice.sendRequest(licenseWSOptions);                  
              
              myWidget.eventChecker = UWACore.createElement('ad-app-event-checker');   
              
              window.onbeforeunload = function (event) {
            	  var message;
            	  
                  // clear any monitor file jobs
                 stopMonitorFileJobs.call(this);
                 
 	        	var currentSession = document.getElementById("runAbqSession");
		        if (currentSession && currentSession.hasPendingUpdates()) {
		        	if (currentSession.hasPendingUploads()) {
	                    message = 'Your changes are still being saved.\n\n' + 'If you leave now, your recent changes may be lost, including any files currently being uploaded.';
		        	}
		        	else {
		        		message = 'Your changes are still being saved (this should only take a moment longer).\n\n' + 'If you leave now, your recent changes may be lost.';
		        	}
		        	
		        	event.returnValue = message;
		        	return message;
		        }
              }.bind(this);
              
              window.onunload = function () {
                  // clear any monitor file jobs
                 stopMonitorFileJobs.call(this);                    
              }.bind(this);
		};	     
		
		myWidget.onRefresh = function(){			
			//hack to clear execdir auto refresh timeout. Clears all timeouts
			var lastTimeOut = setTimeout(";");
			for (var i = 0 ; i < lastTimeOut ; i++) {
			    clearTimeout(i); 
			}
			//Stop file monitor jobs
			stopMonitorFileJobs.call(this);
			
			myWidget.hasWrite = true;
			var prevInfo = widget.getValue("AbaqusStudyProcessInfo");
            if(typeof(prevInfo) !== 'undefined' && myWidget.reload){            		
                	var currentSession = document.getElementById("runAbqSession");
                	if(currentSession){
        	        	if (currentSession.hasPendingUpdates()){
        	    	    	// flush pending data
        	    	    	var onSuccess = function (httpRequest, isFlushComplete) {
        	    	        	if (isFlushComplete) {
        	    	        		if(currentSession.hasPendingUploads()){
        	    	        			if(window.confirm('The upload is still in progress. Refreshing will interrupt the current upload, and no more files will be uploaded.')){
        	    	        				triggerCreateEvent.call(this, prevInfo); 
        	    	        			}
        	    	        		}else{
        	    	        			triggerCreateEvent.call(this, prevInfo);
        	    	        		}        	    	        		       	    	        		
        	    	        	}
        	    	        }.bind(this);        	    	        
        	    	    	var onError = function (httpRequest, isFlushComplete) {        	    	    		
        	    	        }.bind(this);    	    	
        	    	        currentSession.flushPendingUpdates(onSuccess, onError);
        	        	}else{    			
        	        		triggerCreateEvent.call(this, prevInfo);        	        	
        	        	}  
                	}  
            }else{
            	myWidget.onLoad();            	
            }			
     	};

		myWidget.createNotification  = function(id){							
              	var spNotification = UWA.createElement('sp-notification');
              	spNotification.setAttributes({
              		id : id,
              		position: "TC",
              		width : "400"                		
              	});
              	
                return spNotification;
        };
		                  
		myWidget.skeletonNode =  null;    
		
		 
		myWidget.createRunAbaqusApp = function(){
             if(myWidget.skeletonNode){
                 myWidget.skeletonNode.destroy();             
                 }  
             
             var skeleton = new Skeleton(renderers, skeletonOptions);
             return skeleton;			 
		};
		
		myWidget.getSteps = function(activity){
	        var steps = [];
	        
	        if (activity) {
	            if (typeof activity.attributes !== 'undefined' && typeof activity.attributes.definition !== 'undefined' && typeof activity.attributes.definition.flowItem !== 'undefined' && typeof activity.attributes.definition.flowItem.implementations !== 'undefined' && activity.attributes.definition.flowItem.implementations.length > 0 && typeof activity.attributes.definition.flowItem.implementations[0].children !== 'undefined') {
	                steps = activity.attributes.definition.flowItem.implementations[0].children;
	            }
	        }
	        return steps;
		};
		
		myWidget.getExtensionName = function(step){
	        var extension;
        
	        if(step){
	        	if (typeof step.FlowItem !== 'undefined' && typeof step.FlowItem.stepConfig !== 'undefined'){
	        		extension = step.FlowItem.stepConfig.extensionName;
	        	}
	        	
	        }
	        return extension;
		};
		
		myWidget.getApplicationName = function(step){
			var appName;
			
			if (step){
				if(typeof step.FlowItem !== 'undefined' && 
				   typeof step.FlowItem.stepConfig !== 'undefined' && 
				   typeof step.FlowItem.stepConfig.properties !== 'undefined' && 
				   typeof step.FlowItem.stepConfig.properties.PredefinedCommandOptions !== 'undefined' && 
				   typeof step.FlowItem.stepConfig.properties.PredefinedCommandOptions.Application !== 'undefined'){
					appName = step.FlowItem.stepConfig.properties.PredefinedCommandOptions.Application.appName;
				}
			}
			
			if( typeof appName === 'undefined' && typeof step.FlowItem.name !== 'undefined'){
				appName = step.FlowItem.name;
			}
			return appName;
		};
		
		myWidget.createSpinner = function(){
			  var spinner = new Spinner({className: "large showOnTop", spin: true});
			  	myWidget.loadingSpinner = spinner;
			  	myWidget.loadingSpinner.elements.container.style.position = 'absolute';
			  	myWidget.loadingSpinner.elements.container.style.top = "30%";
			  	myWidget.loadingSpinner.elements.container.style.left = "50%";			
			  	myWidget.loadingSpinner.inject(widget.body);
			  	
			  	
			  var spinnerOverlay = UWACore.createElement("div");
			  spinnerOverlay.set('class', "spinnerOverlay");
			  
			  myWidget.spinnerOverlay = spinnerOverlay;
			  myWidget.spinnerOverlay.inject(widget.body);
			  myWidget.spinnerOverlay.hide();
			  
		};
        
		myWidget.onToolAdded = function(model){
			if(myWidget.loadingSpinner){
				myWidget.loadingSpinner.toggle();
				myWidget.spinnerOverlay.toggle();
			}
		};
		
		myWidget.onToolsLoaded = function(model){
			if(model){
				myWidget.skeletonNode.selectItem(model);
			}
		};
		
		myWidget.onNoWriteAccess = function(){
			myWidget.hasWrite = false;		
    		var noAccessMessage = {text:'You do not have write access to this simulation study in this collaborative space. Please switch to a different collaborative space in the preferences and try again.', 
					   type : 'error', 
					   autoRemove : false};
			showAppMessage(noAccessMessage);
		};
    
		myWidget.onAppMessage = function(message){
			showAppMessage(message);			
		};
		
		myWidget.onToggleSpinner = function(){
			if(myWidget.loadingSpinner){
				myWidget.loadingSpinner.toggle();
				myWidget.spinnerOverlay.toggle();
			}
		};
		
		myWidget.onUploadFilesChange = function(name, value){
			var customFilesPreference;
			//If the user selected custom list add a preference of type text
			if(value === "userCustom"){
				customFilesPreference = {
						name: "customFiles",
						type: "text",
						label: "Custom List",
						defaultValue:""
				};			
				widget.addPreference(customFilesPreference);				
			}else{
				//If the user selected default add a preference of type hidden
				customFilesPreference = {
						name: "customFiles",
						type: "hidden",						
						defaultValue:""
				};
				widget.addPreference(customFilesPreference);
			}
			
			widget.dispatchEvent('onEdit');
		};		
	
		myWidget.addFilesToBeDownloadedPreference  = function(){
			var options = [{
				value: "appDefault",
				label: "Default (*.com, *.dat, *.msg, *.sta, *.odb, *.sim, *.log)"				
			},{
				value: "userCustom",
				label: "Custom List"
			}];
			
			var uploadFilesPreference = {
					name: "uploadFiles",
					type: "list",
					label: "Files to be Uploaded",
					options: options,
					onchange: "onUploadFilesChange",
					defaultValue: "appDefault"
			};
			widget.addPreference(uploadFilesPreference);
		};
		
		myWidget.setTenantId = function(myAppsUrl){						
            var onWSComplete, onWSError, options, tenantId;

            var tenantPreference = {
            		name: "tenantId",
            		type: "list",
            		label: "Tenant for Abaqus license checkout"          		
            }
            
            onWSComplete = function (httpRequest) {
                var tenantIdList, onCloudLicenseURL, tenantPrefOptions = [];                
                if (httpRequest.response) {                	
                	tenantIdList =  httpRequest.response.split(/\n/)[0].split(/=/)[1].split(/,/);
                	onCloudLicenseURL = httpRequest.response.split(/\n/)[2].split(/=/)[1];
                	if(tenantIdList.length > 1){
	                	for(var i=0; i < tenantIdList.length; i++){                		
	                		tenantPrefOptions.push({
			            				value: tenantIdList[i],
			            				label: tenantIdList[i]
			            		});               
	                	}
	                	tenantPreference.options = tenantPrefOptions;
	                	tenantPreference.defaultValue = tenantIdList[0];
	                	widget.addPreference(tenantPreference);
                	}else{
                		widget.setValue("tenantId", tenantIdList[0]);
                	}
                	widget.setValue('licenseURL', onCloudLicenseURL);
                	//Add this after tenant preference because it adds a dynamic preference
                	myWidget.addFilesToBeDownloadedPreference();
                }
            }.bind(this);

            onWSError = function (httpRequest) {
            		var message = {
            			   text:'Unable to get Tenant ID', 
     					   type : 'error', 
     					   autoRemove : false
            		}
            		myWidget.onAppMessage(message)
            		//Add this after tenant preference because it adds a dynamic preference
            		myWidget.addFilesToBeDownloadedPreference();
            }.bind(this);

            options = {
                verb: 'GET',
                uri: myAppsUrl + '/resources/AppsMngt/licenses/whereused',
                headers:{
                	'Accept': 'text/plain'
                },
                onComplete: onWSComplete,
                onError: onWSError,
            };
            
            myWidget.spWebservice.sendRequest(options);
		};
		
        widget.addEvents({
            onLoad : myWidget.onLoad,
            onRefresh : myWidget.onRefresh,
            onToolAdded: myWidget.onToolAdded,
            onToolsLoaded: myWidget.onToolsLoaded,
            onNoWriteAccess : myWidget.onNoWriteAccess,
            onAppMessage : myWidget.onAppMessage,
            onToggleSpinner: myWidget.onToggleSpinner,
            onUploadFilesChange: myWidget.onUploadFilesChange
        });
        
        return myWidget;
   	});


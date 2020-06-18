//dummy

/**
 * 
 */

/* global define, widget */
/**
  * @overview Subscription Management
  * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
  * @version 1.0.
  * @access private
  */

define('DS/ENOSubscriptionMgmt/Views/MySubscriptionsToolbar',
[
  'UWA/Class',
  'UWA/Element',
  'DS/WAFData/WAFData',
  'DS/Controls/Button',
  'DS/Controls/ComboBox',
  'DS/Utilities/Array',
  'DS/Notifications/NotificationsManagerUXMessages',
  'DS/Notifications/NotificationsManagerViewOnScreen',
  'DS/Controls/TooltipModel',
  'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt'
],
function (
  Class,
  UWAElement,
  WAFData,
  Button,
  WUXComboBox,
  ArrayUtils,
  NotificationsManagerUXMessages,
  NotificationsManagerViewOnScreen,
  WUXTooltipModel,
  NLS
) {
  'use strict';

  /**
  * instance
  */
  var searchContainer = null;
  var searchInput = null;
  var searchInputDiv = null;
  var searchButton = null;
  var model = null;
  var treeListView = null;
  var matchedNodesList = [];
  var searchCriteria = null;
  var nextNode = null;
  var prevNode = null;
  var currentNode = null;
  var matchedNodesList1 = [];
  var typesSelected =[];
  var eventsSelected =[];
  var objTypes = [];
  var eventTypes = [];
  var searchInProcess = false;
  var windowResized = false;
  var headerContainer = null;
  var notify_manager = null;

  var MySubscriptionsToolbar = Class.extend({

    /**
    * init
    */
    init: function(modaltree)
    {
    	treeListView = modaltree;
    	model = modaltree._getTrueRoot()._treeDocument;
    },

    /**
    * buildToolbarView
    */
    buildToolbarView : function()
    {
    	var that = this;
    	that._notif_manager = NotificationsManagerUXMessages;
    	NotificationsManagerViewOnScreen.setNotificationManager(that._notif_manager);
    	
    	headerContainer = UWA.createElement('div', {
    		'class': 'filter-search-toolbar'
    	});
    	searchContainer = UWA.createElement('div', {
    		'class': 'searchContainerDiv',   
    	});
    	
    	/*searchInputDiv = UWA.createElement('div', {
    		'class': 'wux-controls-abstract wux-controls-lineeditor',   
    		'keymap-manager':'1',
    		'command-registry':'1'
    	}).inject(searchContainer);*/

    	searchInput = UWA.createElement('input', {
    		type: 'text',
    		placeholder: NLS.Find
    	}).inject(searchContainer);
      
    	that.filterTreeListView = function(){
    		if(!windowResized){
    			treeListView.getContent().childNodes[0].childNodes[1].style.minWidth =  "150px";
    			windowResized = true;
    		}
    		
    		model.prepareUpdate();  		
    		
    		if(typesSelected.length == 0 || typesSelected.length == objTypes.length ){   			
    			if(eventsSelected.length == 0 || eventsSelected.length == eventTypes.length){    	  	    	
    	  	    	ArrayUtils.optimizedForEach(model.getAllDescendants(), function(node) {   	  	    		
    	  	    		//if(node._isHidden){
    	  	    			node.show();
    	  	    		//}    	  	    			
    	  	    		//node.unmatchSearch();    	  	    		
    	  	    	});    	  	    	
    			} else {    				
    				ArrayUtils.optimizedForEach(model.getAllDescendants(), function(node) {    					
    					if(node.options.grid.event != ""){
    						if(eventsSelected.indexOf(node.options.grid.event) != -1){
    	  	    				node.show();
    	  	    				//node.matchSearch();
    	  	    				node.reverseExpand();
    	  	    				if(!node.getParent().ischildSelected){
    	  	    					node.getParent().ischildSelected = true;
    	  	    				}    	  	    				
    						} else if(!node._isHidden) {
    	  	    				node.hide(); 
    	  	    				//node.unmatchSearch();
    	  	    			}	  			
    					} 
    				});
    				
    				ArrayUtils.optimizedForEach(model.getChildren(), function(node) {
    					if(node.options.grid.event == ""){
    						if(node.ischildSelected){
    							node.show();
    							node.ischildSelected = false;
    						} else {
    							node.hide();
    						}  		  			
    					}      		  		
    				}); 				
    				
    			}      	    	
    		} else {
      	    	ArrayUtils.optimizedForEach(model.getChildren(), function(node) {      	    		
      	    		if(typesSelected.indexOf(node.options.grid.type) != -1){      	    			
      	    			ArrayUtils.optimizedForEach(node.getChildren(), function(childNode) {
      	    				if(eventsSelected.length == 0 || eventsSelected.length == eventTypes.length){    
      	    					node.show();
      	    					childNode.show();
      	    					//childNode.unmatchSearch();
      	    				} else if(eventsSelected.indexOf(childNode.options.grid.event) != -1){
    	  	    				//node.show();
      	    					node.show();
      	    					childNode.show();
      	    					//childNode.matchSearch();
      	    					childNode.reverseExpand();
      	    					if(!childNode.getParent().ischildSelected){
      	    						childNode.getParent().ischildSelected = true; 
      	    					}      	    					 	    					
    						} else if(!node._isHidden) {
    	  	    				childNode.hide(); 
    	  	    				//childNode.unmatchSearch();     				
    	  	    			}
      	    			});
      	    			
      	    			//node.show();
      	    		} else if(!node._isHidden) {
      	    			node.hide();
      	    			node.ischildSelected = false;
      	    		}      	    		     		  		
      	    	}
      	    	);
      	    }    		
    		model.pushUpdate();    		
    	};    	
    	var rows =  treeListView.getDocument().getAllDescendants();
      
    	objTypes = [];
    	eventTypes = [];
    	rows.forEach(function (row){
    		if(row.options.grid.event == "" && objTypes.indexOf(row.options.grid.type) == -1){
    			objTypes.push(row.options.grid.type);
    		} else if(row.options.grid.event != "" && eventTypes.indexOf(row.options.grid.event) == -1){
    			eventTypes.push(row.options.grid.event);
    		}    	  
    	});
     // [0].options.grid.type
      
      

      that.typeButton = new WUXComboBox({ elementsList: objTypes, placeholder: NLS.selectType, selectedIndex: -1, enableSearchFlag: false, multiSelFlag: true, actionOnClickFlag :true }).inject(headerContainer);
      that.eventButton = new WUXComboBox({ elementsList: eventTypes, placeholder: NLS.selectEvent, selectedIndex: -1, enableSearchFlag: false, multiSelFlag: true, actionOnClickFlag :true }).inject(headerContainer);
      that.typeButton.addEventListener('change', function(e) {
    	    'use strict';
      	    var indexes= e.dsModel.selectedIndexes;
      	    typesSelected =[];    	    
      	    indexes.forEach(function(evn){
      	    	typesSelected.push(e.dsModel.elementsList[evn]);
      	    });
      	    
      	    that.filterTreeListView();	    
      	    
      	}, false);
      
      that.eventButton.addEventListener('change', function(e) {
    	  'use strict';
    	  var indexes= e.dsModel.selectedIndexes;
    	  eventsSelected =[];
  	    
    	  indexes.forEach(function(evn){
    		  eventsSelected.push(e.dsModel.elementsList[evn]);
    	  });
  	    
    	  that.filterTreeListView();
    	  return;     	  
 
      }, false);
      
      searchInput.addEventListener('keypress', function(e) {
    	  'use strict';
    	  if(e.keyCode === 13){
    		  that.onFindInput();
    		  e.target.focus();
    	  }
      }, false);
      
      that.onFindInput = function(){   	
          var searchTerm = searchInput.value.trim().toLowerCase();          
          if(searchTerm.length < 4){
        	  if(searchTerm == ''){
        		  model.prepareUpdate();
        		  ArrayUtils.optimizedForEach(matchedNodesList1, function(node) {
        			  node.unmatchSearch();
        		  });
        		  model.pushUpdate(); 
        	  }				
        	  that._notif_manager.addNotif({
        		  level: 'info',
        		  message: NLS.findWarningMessage,
        		  sticky: false
        	  });				
          } else if(searchTerm.length > 3 ){
        	  if(searchTerm != searchCriteria && !searchInProcess){              	
        		  searchCriteria = searchTerm;
        		  // always done before tree action
        		  try{
        			  searchInProcess = true;
        			  model.prepareUpdate();
        			  // clear any previous search
        			  /*
                  	ArrayUtils.optimizedForEach(matchedNodesList, function(node) {
                  		node.unmatchSearch();
                  	});

                      // get matched nodes
                      matchedNodesList = model.search({
                      	shouldStop: function() {
                      		return false;
                      	},
                      	match: function(nodeInfos) {
                      		// match node label
                      		if(nodeInfos.nodeModel.options.grid.event !='' || nodeInfos.nodeModel.isVisible()){
                      			var label = nodeInfos.nodeModel.options.label.trim().toLowerCase();
                                  if(searchTerm != '' && label.indexOf(searchTerm) !== -1) {
                                    return true;
                                  }
                      		}                        
                      		return false;
                      	}
                      }); */
                      
                  	matchedNodesList1 =[];
					ArrayUtils.optimizedForEach(model.getAllDescendants(), function(node) {
						var label = node.getLabel().trim().toLowerCase();
						if( label.indexOf(searchTerm) !== -1) {
							node.reverseExpand();
                     	 	node.matchSearch();
                     	 	matchedNodesList1.push(node);
						} else{
							node.unmatchSearch();
						}
					});
                  	
					currentNode = 0;
					if(matchedNodesList1.length == 0){
						that._notif_manager.addNotif({
							level: 'info',
							message: NLS.noObjectsFound,
							sticky: false
						});
						return;
					}              		
              	} finally{
              		model.pushUpdate();              		
              		if(matchedNodesList1.length > 0){
              			var curNode = matchedNodesList1[0];
              			treeListView.getManager().scrollToNode(curNode);
              			//curNode.matchSearch();
              			curNode.show();
              		}
              		searchInProcess = false;
              	}              	
        	  } else {       		 
        		  if(!searchInProcess){
        			  try{
        				  searchInProcess = true;
        				// model.prepareUpdate();
            			  currentNode = currentNode+1;
            			  if(matchedNodesList1.length-1 <= currentNode){                		
            				  currentNode = 0;
            			  }
            			  var curNode = matchedNodesList1[currentNode];
            			  if(curNode){
            				  treeListView.getManager().scrollToNode(curNode);
            			  }
            			  if(matchedNodesList1.length == 0){
      						that._notif_manager.addNotif({
      							level: 'info',
      							message: NLS.noObjectsFound,
      							sticky: false
      						});
      						return;
      					  } 
            			  //curNode.matchSearch();  
            			  //model.pushUpdate(); 
            		  }finally{
            			  searchInProcess = false;
            		  }         		  
        		  }              	
        	  }
          }        
      }
      searchButton = new Button({
    	  icon: 'search',        
    	  onClick: function() {
    		  that.onFindInput();
    	  }        
      });
      searchButton.tooltipInfos = new WUXTooltipModel({shortHelp: NLS.FindTooltip});
      searchButton.inject(searchContainer);
      searchContainer.inject(headerContainer);
   //   buttonUnsubscribe.inject(headerContainer);
      that.clearFindfield = function(){
    	  searchCriteria = null;
    	  searchInProcess = false;
    	  windowResized = false;
      }
      that.updateEventAndTypeDropdown = function(){
    	  	var a = performance.now();    	  
			objTypes = [];
	    	eventTypes = [];
			var rows =  treeListView.getDocument().getAllDescendants();
			rows.forEach(function (row){
	    		if(row.options.grid.event == "" && objTypes.indexOf(row.options.grid.type) == -1){
	    			objTypes.push(row.options.grid.type);
	    		} else if(row.options.grid.event != "" && eventTypes.indexOf(row.options.grid.event) == -1){
	    			eventTypes.push(row.options.grid.event);
	    		}    	  
	    	});
			that.typeButton.elementsList = objTypes;
			that.eventButton.elementsList = eventTypes;
			var b = performance.now();
	    	console.log('It took ' + (b - a) + ' ms.');
		};
      return headerContainer;
    }
    
  });
  return MySubscriptionsToolbar;
});

/* global define, widget */
/**
 * @overview Subscription Management - JSON Parse utilities
 * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOSubscriptionMgmt/Utils/ParseJSONUtil',
		[
			'UWA/Class',
			'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt'
			],
			function(
					UWAClass,
					NLS
			) {
	'use strict';

	var ParseJSONUtil = UWAClass.extend({
		createDataForRequest : function(req,csrf){
			var request = {};
			if(csrf === undefined){
				csrf = widget.data.csrf;
			}
			var dataelements = {
					"dataelements" : req
					//"id" : req.id
			};
			var data = new Array();
			data.push(dataelements);
			request = {
					"csrf": csrf,
					"data": data
			}
			//console.log(request);
			return request;
		},
		createDataWithElementForRequest : function(req,csrf){
			var request = {};
			if(csrf === undefined){
				csrf = widget.data.csrf;
			}
			request = {
					"csrf": csrf,
					"data": req
			}
			//console.log(request);
			return request;
		},
		getTenantFromNode: function(node){
			if(node.tenant){
				return node.tenant;
			}else if(node.options && node.options.tenant){
				return node.options.tenant;
			}else if(node.object && node.object.tenant){
				return node.object.tenant;
			}else{
				return null;
			}
		},
		getTypeFromNode: function(node){
			if(node.type){
				return node.type;
			}else if(node.options && node.options.type){
				return node.options.type;
			}else if(node.object && node.object.type){
				return node.object.type;
			}else {
				return null;
			}
		},
		getCookie: function (name) {
	    	  var value = "; " + document.cookie;
	    	  var parts = value.split("; " + name + "=");
	    	  if (parts.length >= 2) return parts.pop().split(";").shift();
	    },
		
		getURLwithLanguage: function(url) {
			if(this.getCookie("swymlang")){
            	url = url + '?$language='+ this.getCookie("swymlang");
            }
			return url;
		}

	});


	return ParseJSONUtil;
});

/* global define, widget */
/**
  * @overview Subscribe Management - Module to disable the create route command in action bar
  * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
  * @version 1.0.
  * @access private
  */
define('DS/ENOSubscriptionMgmt/commands/CommandAvailableOnSelect', [
    'UWA/Core',
    'UWA/Class',
    'DS/PADUtils/PADContext'
], function(UWA,
    Class,
    PADContext) {

    'use strict';
    var CommandAvailableOnSelect = Class.extend({
        init: function(options, AFROptions) {
            this._parent(options, AFROptions);

        	if (PADContext.get()){
                this._check_select();
        		PADContext.get().getPADTreeDocument().getXSO().onChange(this._check_select.bind(this));
        	}
        },

        _check_select: function() {
        	var selectedObjects = PADContext.get().getPADTreeDocument().getXSO().get();
        	var numberSelection = selectedObjects.length;
            var has_selected = numberSelection && (this.options.cmd_selection_single !== true || numberSelection === 1) ? true : false; 

          /*  if((selectedObjects.length >0) && (selectedObjects[0].plmType != "Content")){
            	has_selected = false;
            }*/
            if (this.isAvailable != null) {            	
            	var that = this;
            	that.selectedObjects = selectedObjects;
            	has_selected = this.isAvailable(selectedObjects, function(available, selectedObjects){
            		if (selectedObjects == that.selectedObjects) { // to avoid later check override by earlier check in async case 
            			if (available) {
                			that.enable();
                        } else {
                        	that.disable();
                        }
            		}            		
            	});
            }
            else {
            	if (has_selected === true) {
                    this.enable();
                } else {
                    this.disable();
                } 
            }    		
        }
    });
    return CommandAvailableOnSelect;
});

/* global define, widget */
/**
 * @overview Subscription Management - Module to create Subscribe in action bar
 * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define("DS/ENOSubscriptionMgmt/Commands/Subscribe",
		['UWA/Core',
			'UWA/Class',
			'DS/ApplicationFrame/Command',
			'DS/ApplicationFrame/CommandsManager',
			'DS/Core/Core',
			'DS/Notifications/NotificationsManagerUXMessages',
			'DS/Notifications/NotificationsManagerViewOnScreen',
			'DS/WAFData/WAFData',
			'DS/PADUtils/PADContext',
			'DS/PADUtils/PADSettingsMgt',
			'DS/WidgetServices/WidgetServices',
			'DS/ENOSubscriptionMgmt/Utils/ParseJSONUtil',
			'DS/ENOSubscriptionMgmt/commands/CommandAvailableOnSelect',
			'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt'
			], function (
					UWA,
					Class,
					AFRCommand,
					CommandsManager,
					WUX,
					NotificationsManagerUXMessages,
					NotificationsManagerViewOnScreen,
					WAFData,
					PADContext,
					PADSettingsMgt,
					WidgetServices,					
					ParseJSONUtil,
					OnSelectCommand,
					NLS
			) {
	'use strict';

	// -- debug purpose only --
	// WUX.enableWUXConsole();
	var wuxConsole = WUX.getWUXConsole();
	var selected_nodes;

	var SubscribeCmd = Class.extend(AFRCommand, OnSelectCommand,{
		/**
		 * Execute a command
		 * @namespace WUX.AFR
		 * @class Command
		 * @extends UWA.Class
		 * @constructor
		 *
		 */
		init: function (options) {
			this.options = options;
			this._parent(options, {
				mode: 'exclusive',
				isAsynchronous: true
			});
		},

		beginExecute: function () {
			// -- Get the frame --
			this._frmWindow = this.getFrameWindow();			
		},

		resumeExecute: function () {
			//console.log('Resuming command:' + this._id);
		},
		
		execute: function (options) {	
			var that = this;			
			that.onCompletePlatform = function(url){
				WAFData.authenticatedRequest(url + '/resources/v1/application/E6WFoundation/CSRF', UWA.extend(that.options, {
					method : 'GET',
					url_temp:url,
					onComplete : that.onCompleteCSRF
				}, true));
			};
			
			that.onCompleteCSRF = function(csrf){
				var objThis = this;
				objThis._notif_manager = NotificationsManagerUXMessages;
				NotificationsManagerViewOnScreen.setNotificationManager(objThis._notif_manager);
				var url = this.url_temp + '/resources/v1/modeler/subscriptions';					 
				var parseJSONUtil = new ParseJSONUtil();
				url = parseJSONUtil.getURLwithLanguage(url);
				var localContext = PADContext.get();
				if (null == localContext){ 
					localContext = this.context;
					if (null == localContext){ 
						localContext = this.options.context;
					}
				};    
												
				var insideModel = localContext.model;
				if (!insideModel || !insideModel.objectId){
					selected_nodes = localContext.getSelectedNodes();
				}
				
				var resultElementSelected = [];
				var that = this;
				
				if(selected_nodes.length == 0){
					objThis._notif_manager.addNotif({
						level: 'warning',
						message: NLS.subscribeSelectError,
					    sticky: false
					});
					return;
				}
				
				if (selected_nodes.length) {
					selected_nodes.forEach(function(node) {
						//Instance has priority as it displayed both reference and instance
						var nodeID = node && typeof node.getInstID === "function" ? node.getInstID() : null;
						if (nodeID != null && Array.isArray(nodeID)){
							nodeID = nodeID.length > 0 ? nodeID[0] : null;
						}
						var defaultMetatype = nodeID ? 'relationship' : 'businessobject';
						nodeID = nodeID ? nodeID : node.getID();
						nodeID = nodeID ? nodeID : node.id;
						var metatype = node.metatype ? node.metatype: defaultMetatype;
						var source = node.source ? node.source : null;
						
						var tenant = parseJSONUtil.getTenantFromNode(node);
						var type = parseJSONUtil.getTypeFromNode(node);
						//var type = node.type ? node.type : (node.options.type ? node.options.type : null);
						if (nodeID) {
							var initModel = {
									'type' : type,
									'cestamp' : metatype,
									'relId' : nodeID,
									'id' : nodeID,
									'dataelements':{}
							};
							var tenant = tenant ? tenant : WidgetServices.getTenantID();

							if (tenant) initModel['tenant'] = tenant;
							if (source) initModel['source'] = source;
							if (type) initModel['type'] = type;
							resultElementSelected.push(initModel);
						};
					});
				}
				
				var SubscribeOptions = {
						'method' : 'POST',
						'headers' : {
			                     'Content-Type' : 'application/ds-json'					                     
						}
				};							
				
				SubscribeOptions.data = JSON.stringify(parseJSONUtil.createDataWithElementForRequest(resultElementSelected, JSON.parse(csrf).csrf));
	            	
				SubscribeOptions.onComplete = function(resp){
					var respJSONdata = JSON.parse(resp).data;
					var dataLen = respJSONdata.length;
					var typesWithEvents = "";
					var typesWithoutEvents = "";
					var typeArray=[];
					for(var i = 0; i< dataLen; i++){
						var typ_nls = respJSONdata[i].dataelements.type_nls;
						if(typeArray.indexOf(typ_nls) == -1){
							if(respJSONdata[i].dataelements.objEventList.length === 0){
								if(typesWithoutEvents.length ==0){
									typesWithoutEvents = respJSONdata[i].dataelements.type_nls;			
								} else {
									typesWithoutEvents = typesWithoutEvents + ","+ respJSONdata[i].dataelements.type_nls;	
								}
												
							}else{		
								if(typesWithEvents.length ==0){
									typesWithEvents = respJSONdata[i].dataelements.type_nls;			
								} else {
									typesWithEvents = typesWithEvents + ","+ respJSONdata[i].dataelements.type_nls;
								}
							}
							typeArray[i] = typ_nls;			
						}
					}
					if(typesWithEvents.length !=0){
						objThis._notif_manager.addNotif({
							level: 'success',
							message: NLS.subscribeEventsSuccess + typesWithEvents+".",
						    sticky: false
						});
					}
					if(typesWithoutEvents.length !=0){
						objThis._notif_manager.addNotif({
							level: 'error',
							message: NLS.errorNoEventsConfigured + typesWithoutEvents+".",
						    sticky: true
						});
					}
				};
				
				SubscribeOptions.onFailure = function(){
					objThis._notif_manager.addNotif({
						level: 'error',
						message: NLS.subscribeEventsFailure,
					    sticky: false
					});
				};
				SubscribeOptions.timeout=0;
				WAFData.authenticatedRequest(url, SubscribeOptions);								
				
			};
			
								
			require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'],function(CompassServices){
				CompassServices.getServiceUrl( { 
					serviceName: '3DSpace',
					platformId : widget.getValue("x3dPlatformId"), 
					onComplete : that.onCompletePlatform,
				});
			});		
			if(CommandsManager.getCommand( this._id )){
				CommandsManager.getCommand( this._id ).end();
			}else{
				var commandId = this._id;
				if(CommandsManager.getCommands()["[object Object]"][commandId])
				CommandsManager.getCommands()["[object Object]"][commandId].end();
			}		
			
			return that;	
		},
		endExecute: function () {
			console.log('Stop command:' + this._id);
			wuxConsole.warn('Stop command:' + this._id);
		}

	});

	return SubscribeCmd;
});

/* global define, widget */
/**
 * @overview Subscription Management - Module to create Subscribe in action bar
 * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define("DS/ENOSubscriptionMgmt/Commands/UnSubscribe",
		['UWA/Core',
			'UWA/Class',
			'DS/ApplicationFrame/Command',
			'DS/ApplicationFrame/CommandsManager',
			'DS/Core/Core',
			'DS/WAFData/WAFData',
			'DS/PADUtils/PADContext',
			'DS/PADUtils/PADSettingsMgt',
			'DS/WidgetServices/WidgetServices',
			'DS/ENOSubscriptionMgmt/Utils/ParseJSONUtil',
			'DS/Notifications/NotificationsManagerUXMessages',
		    'DS/Notifications/NotificationsManagerViewOnScreen',
		    'DS/ENOSubscriptionMgmt/commands/CommandAvailableOnSelect',
			'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt'
			], function (
					UWA,
					Class,
					AFRCommand,
					CommandsManager,
					WUX,
					WAFData,
					PADContext,
					PADSettingsMgt,
					WidgetServices,					
					ParseJSONUtil,
					NotificationsManagerUXMessages,
					NotificationsManagerViewOnScreen,
					OnSelectCommand,
					NLS
			) {
	'use strict';

	// -- debug purpose only --
	// WUX.enableWUXConsole();
	var wuxConsole = WUX.getWUXConsole();
	var container,myContent,selected_nodes;
	
	
	var UnsubscribeCmd = Class.extend(AFRCommand, OnSelectCommand,{

		/**
		 * Execute a command
		 * @namespace WUX.AFR
		 * @class Command
		 * @extends UWA.Class
		 * @constructor
		 *
		 */
		init: function (options) {
			this.options = options;
			this._parent(options, {
				mode: 'exclusive',
				isAsynchronous: true
			});
		},

		beginExecute: function () {
			// -- Get the frame --
			this._frmWindow = this.getFrameWindow();
			// -- Init variables used to execute the command --
			//console.log('Beginning command:' + this._id);
			wuxConsole.info('Beginning command:' + this._id);
			//console.log(PADSettingsMgt.getSetting('pad_security_ctx'));
		},

		resumeExecute: function () {
			//console.log('Resuming command:' + this._id);
		},
		
	
		execute: function (options) {			
			var that = this;
			
			that.onCompletePlatform = function(url){
				WAFData.authenticatedRequest(url + '/resources/v1/application/E6WFoundation/CSRF', UWA.extend(that.options, {
					method : 'GET',
					url_temp:url,
					onComplete : that.onCompleteCSRF
				}, true));
			};
			
			that.onCompleteCSRF = function(csrf){
				var objThis = this;
				objThis._notif_manager = NotificationsManagerUXMessages;
	            NotificationsManagerViewOnScreen.setNotificationManager(objThis._notif_manager);
				var url = this.url_temp + '/resources/v1/modeler/subscriptions';
				var parseJSONUtil = new ParseJSONUtil();
				url = parseJSONUtil.getURLwithLanguage(url);
								 
				var localContext = PADContext.get();
				if (null == localContext){
					localContext = this.context;
					if (null == localContext){ 
						localContext = this.options.context;    
					}
				}
								
				var insideModel = localContext.model;
				if (!insideModel || !insideModel.objectId){
					selected_nodes = localContext.getSelectedNodes();
				}
				
				var resultElementSelected = [];
				
				if (selected_nodes.length) {
					console.dir('selected_nodes : ' +selected_nodes);
					selected_nodes.forEach(function(node) {
						//Instance has priority as it displayed both reference and instance
						var nodeID = node && typeof node.getInstID === "function" ? node.getInstID() : null;
						if (nodeID != null && Array.isArray(nodeID)){
							nodeID = nodeID.length > 0 ? nodeID[0] : null;
						}
						var defaultMetatype = nodeID ? 'relationship' : 'businessobject';
						nodeID = nodeID ? nodeID : node.getID();
						nodeID = nodeID ? nodeID : node.id;
						var metatype = node.metatype ? node.metatype: defaultMetatype;
						var source = node.source ? node.source : null;
						var tenant = parseJSONUtil.getTenantFromNode(node);
						var type = parseJSONUtil.getTypeFromNode(node);
						if (nodeID) {
							var initModel = {
									'type' : type,
									'cestamp' : metatype,
									'relId' : nodeID,
									'id' : nodeID,
									'dataelements':{
										'eventsSubscribed':[]
									}
							};
							var tenant = tenant ? tenant : WidgetServices.getTenantID();

							if (tenant) initModel['tenant'] = tenant;
							if (source) initModel['source'] = source;
							if (type) initModel['type'] = type;
							resultElementSelected.push(initModel);
						};
					});
				}
				if(resultElementSelected.length === 0){
					objThis._notif_manager.addNotif({
		                 level: "warning",
		                 message: NLS.subscribeSelectError,
		                 sticky: false
		             });
					 return;
				}
				var SubscribeOptions = {};
				SubscribeOptions.method = 'PUT';
				if(this.asyncFalse){
					SubscribeOptions.async = this.asyncFalse;
				}
				SubscribeOptions.headers = {
	                     'Content-Type' : 'application/ds-json'
	                     //'Accept' : 'application/ds-json'
				};
				SubscribeOptions.data = JSON.stringify(parseJSONUtil.createDataWithElementForRequest(resultElementSelected, JSON.parse(csrf).csrf));

	            	
				SubscribeOptions.onComplete = function(resp){
					var respJSONdata = JSON.parse(resp).data;
					var dataLen = respJSONdata.length;
					var typesWithEvents = "";
					var typesWithoutEvents = "";
					var typeArray=[];
					for(var i = 0; i<dataLen; i++){
						var typ_nls = respJSONdata[i].dataelements.type_nls;
						if(typeArray.indexOf(typ_nls) == -1){
							if(respJSONdata[i].dataelements.objEventList.length === 0 ){
								if(typesWithoutEvents.length ==0){
									typesWithoutEvents = typ_nls;			
								} else {
									typesWithoutEvents = typesWithoutEvents + ","+ typ_nls;	
								}
												
							}else {		
								if(typesWithEvents.length ==0){
									typesWithEvents = typ_nls;			
								} else {
									typesWithEvents = typesWithEvents + ","+ typ_nls;
								}
							}
							typeArray[i] = typ_nls;							
						}
						
					}
					if(typesWithEvents.length !=0){
						objThis._notif_manager.addNotif({
							level: 'success',
							message: NLS.unsubscribeEventsSuccess + typesWithEvents+".",
						    sticky: false
						});
					}
					
					if(typesWithoutEvents.length !=0){
						objThis._notif_manager.addNotif({
							level: 'error',
							message: NLS.errorNoEventsConfigured + typesWithoutEvents+".",
						    sticky: true
						});
					}
				};
				
				SubscribeOptions.onFailure = function(){					 
					objThis._notif_manager.addNotif({
		                 level: "error",
		                 message: NLS.unsubscribeEventsFailure,
		                 sticky: false
		             });
				};			
				SubscribeOptions.timeout=0;
				WAFData.authenticatedRequest(url, SubscribeOptions);
			//	console.log('execute command:' + this._id);
			};
			
								
			require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'],function(CompassServices){
				
				CompassServices.getServiceUrl( { 
					serviceName: '3DSpace',
					platformId : widget.getValue("x3dPlatformId"), 
					onComplete : that.onCompletePlatform,
				});
			});			
			//CommandsManager.getCommand( this._id ).end();
			if(CommandsManager.getCommand( this._id )){
				CommandsManager.getCommand( this._id ).end();
			}else{
				var commandId = this._id;
				if(CommandsManager.getCommands()["[object Object]"][commandId])
				CommandsManager.getCommands()["[object Object]"][commandId].end();
			}
			return that;
		},
		endExecute: function () {
		//	console.log('Stop command:' + this._id);
			wuxConsole.warn('Stop command:' + this._id);
		}

	});

	return UnsubscribeCmd;
});

/* global define, widget */
/**
  * @overview Subscription Management
  * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
  * @version 1.0.
  * @access private
  */
define('DS/ENOSubscriptionMgmt/Views/ObjectMySubscriptionEvents',
[
   'DS/WAFData/WAFData',
   'UWA/Controls/Abstract',
   'DS/PADUtils/PADContext',
   'DS/WidgetServices/WidgetServices',
   'DS/ENOSubscriptionMgmt/Utils/ParseJSONUtil',
   'DS/Controls/Toggle', 
   'DS/Controls/ButtonGroup',
   'DS/Windows/Dialog',
   'DS/Windows/ImmersiveFrame',
   'DS/Controls/Button',
   'DS/Notifications/NotificationsManagerUXMessages',
   'DS/Notifications/NotificationsManagerViewOnScreen',
   'DS/Tree/TreeNodeModel',
   'DS/Tree/TreeListView',
   'DS/Tree/TreeDocument',
   'DS/ENOSubscriptionMgmt/Views/MySubscriptionsToolbar',
   'DS/Controls/TooltipModel',
   'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt',
   'css!DS/ENOSubscriptionMgmt/ENOSubscriptionMgmt'   
],
function(
	WAFData,
	Abstract,
	PADContext,
	WidgetServices,
	ParseJSONUtil,
	WUXToggle, 
	WUXButtonGroup,
    WUXDialog,
    WUXImmersiveFrame,
    WUXButton,
	NotificationsManagerUXMessages,
	NotificationsManagerViewOnScreen,
	TreeNodeModel,
	TreeListView,
	TreeDocument,
	MySubscriptionsToolbar,
	WUXTooltipModel,
	NLS	
) {
	'use strict';	
	var ObjectMySubscriptionEvents = {
		serverresponse : {},
		showMySubscriptionDialog : function() {
			var that = this;
			that.SubscriptionDialogOpened = true;
			that._notif_manager = NotificationsManagerUXMessages;
			NotificationsManagerViewOnScreen.setNotificationManager(that._notif_manager);
			var modalWidth =  Math.round(widget.getViewportDimensions().width * 0.80 > 800 ? 810 : widget.getViewportDimensions().width * 0.80) ;
			var modalHeight  =  Math.round(widget.getViewportDimensions().height * 0.80);
			
			that.onCompletePlatform = function(url){
				var options={};
				that.url = url;
				WAFData.authenticatedRequest(url + '/resources/v1/application/E6WFoundation/CSRF', UWA.extend(options, {
					method : 'GET',
					onComplete : that.onCompleteCSRF
				}, true));
			};
			/* that.customSelect = function(env){
				var parent_node = env.data.nodeModel._parentNode;
				var currentNode = env.data.nodeModel;				
				// if all child nodes are selected, then select the parent node
				if(parent_node._rowID !== null){
//					var childNodes = parent_node.getChildren();
//					var allChildrenSelected = false;
//					var childrenSelectedCount = 0;
//					childNodes.forEach(function (childNode){
//						if(childNode.isSelected()){
//							childrenSelectedCount ++;
//						}
//					});
//					if(childNodes.length === childrenSelectedCount){
//						parent_node.select();
//					}
					
					if(parent_node.areAllChildrenSelected()){
						parent_node.select();
					}else{ //if child node is selected, then partially select the parent node
						
					}
				}else{ //if the selected node is parent node then, select all children
					if(!currentNode.isExpanded()){
						currentNode.expand();
					}
					var childNodes = currentNode.getChildren();
					if(childNodes){
						childNodes.forEach(function (childNode){
							childNode.select();
						});
					}
				}
			}; */
			
			
			/* that.customUnSelect = function(env){
				var parent_node = env.data.nodeModel._parentNode;
				var currentNode = env.data.nodeModel;
				if(currentNode._rowID == null){
					return;
				}
				// if all child nodes are unselected, then unselect the parent node
				if(parent_node._rowID !== null){				
					if(parent_node.areAllChildrenUnselected()){
						that.customUnselectParent = false;
						parent_node.unselect();
					}else{ //if child node is selected, then partially unselect the parent node
						that.customUnselectParent = true;
						parent_node.unselect();
					}
				}else{
					if(that.customUnselectParent){//If only one child is unselected, don't proceed further
						that.customUnselectParent = false;
						return;
					}
					if(currentNode.isExpanded()){ //if the selected node is parent node then, unselect all children
						currentNode.collapse();
					}
					var childNodes = currentNode.getChildren();
					if(childNodes){
						childNodes.forEach(function (childNode){
							childNode.unselect();
						});
					}
				}
			}; */
			
			that.drawListViewPage = function(serverResponse){
				var response = JSON.parse(serverResponse);
				that.resposeData = response;
				if(response.data.length == 0 || (response.data.length > 0 && response.data[0].dataelements.eventsSubscribed.length === 0 )){
					 var myContent = new UWA.Element('div', { html: "<p>"+NLS.EmptySubscriptionListMsg+"</p>" });
					 that.showDialog(myContent, response.data.length);
					 return;
				}
				//Start here
				var model = new TreeDocument({
	                useAsyncPreExpand: true
	            });				
				//end here		
				
				response.data.forEach(function(dataElem) {					
					var root = new TreeNodeModel({
		                label: dataElem.dataelements.name,
		                width: 300,
		                grid: {
		                    type: dataElem.dataelements.type_nls,		                    
		                    type_en: dataElem.dataelements.type,
		                    event: '',
		                    event_en: '',
		                    id: dataElem.id,
		                    actType : dataElem.dataelements.type_nls,
		                    revision:dataElem.dataelements.revision,
		                }						
		            });
		           /* root.onSelect(function (ev) {
		            	//console.log(tree)
		            	that.customSelect(ev);
		            });
		            
		            root.onUnselect(function (ev) {
		            	//console.log(tree);	
		            	that.customUnSelect(ev);
		            }); */

					
					//var eventsAvailable = dataElem.dataelements.objEventList;
					var eventsSubscribedNLS = dataElem.dataelements.eventsSubscribed_NLS;
					var eventsSubscribed = dataElem.dataelements.eventsSubscribed;
					
					for(var i=0; i< eventsSubscribed.length; i++){
						var subs = eventsSubscribed[i];
						var subsNLS = eventsSubscribedNLS[i];
						var firstChild = new TreeNodeModel({
			                label: subsNLS,			                
			                grid: {
			                    type: dataElem.dataelements.type_nls,
			                    type_en:dataElem.dataelements.type,
			                    event: subsNLS,
			                    event_en: subs,	                    
			                    id: dataElem.id
			                }
			            });						
						root.addChild(firstChild);								
					}																				
					model.addRoot(root);
				});

				var options = TreeListView.SETTINGS.STANDARD_CHECKBOXES;
				options.show["rowHeaders"] = false;
				options.isEditable = false;	
				options.isDraggable = false;
				options.height = modalHeight - 125;
				options.enableDragAndDrop = false;
				options.width = modalWidth;
				options.columns.push({
					text: NLS.colType,
					dataIndex: 'actType',
					isDraggable: false
	            });
				options.columns.push({
					text: NLS.colRevision,
					dataIndex: 'revision',
					width : 120,
					isDraggable: false
	            });
	            options.columns.push({
	            	text: NLS.colAction,
	            	dataIndex: '',
	            	width : 60,
	            	isDraggable: false,
	            	'onCellRequest': function(cellInfos){
	            		var cell= cellInfos.cellView.getContent(),	            		
	                    commandsDiv;
	            		
	            		if (!cellInfos.isHeader) {

	                        commandsDiv = UWA.createElement('div');
	                    	var buttonUnsubscribe = new WUXButton({ 
								label: '',
								displayStyle: 'icon',															
								icon: that.url + '/webapps/ENOSubscriptionMgmt/assets/icons/32/I_ActionUnSubscribe.png',
								onClick: function(e){
									e.stopPropagation();
									e.preventDefault();
									var objId = cellInfos.nodeModel._options.grid.id;
									var objType = cellInfos.nodeModel._options.grid.type_en;
									var objEvent = cellInfos.nodeModel._options.grid.event_en;									
									var updatedData = [ {
										id: objId, 
										type: objType, 
										dataelements: {
											eventsSubscribed :[]
										}
									}
									];
									
									var subscribeOptions = {};									
									if(objEvent){
										subscribeOptions.method = 'DELETE';
										updatedData[0].dataelements.eventsSubscribed[0] = objEvent;
									}else{
										subscribeOptions.method = 'PUT';
									}
									
									subscribeOptions.headers = {
						                     'Content-Type' : 'application/ds-json',
									};
									subscribeOptions.data = JSON.stringify(new ParseJSONUtil().createDataWithElementForRequest(updatedData, that.csrf));
										
									subscribeOptions.onComplete = function(serverResponse){
										that._notif_manager.addNotif({
											level: 'success',
											message: NLS.unSubscribeMYSubscriptions,
										    sticky: false
										});
										
										if(cellInfos.nodeModel.options.grid.event == ''){
											cellInfos.nodeModel.remove();
										}else if(cellInfos.nodeModel._parentNode.options.children.length == 1){
											cellInfos.nodeModel._parentNode.remove();
										} else{
											cellInfos.nodeModel.remove();
										}
										
										dialog.title = NLS.replace(NLS.MySubscriptionsTitle, {
						            		tag1: tree.getDocument().getChildren().length
						            	});
										searchDiv.updateEventAndTypeDropdown();
																				
									};
									
									subscribeOptions.onFailure = function(){
										that._notif_manager.addNotif({
											level: 'error',
											message: NLS.unsubscribeEventsFailure,
										    sticky: true
										});
									};
									var url = that.url + '/resources/v1/modeler/subscriptions';
									url = new ParseJSONUtil().getURLwithLanguage(url);
									WAFData.authenticatedRequest(url, subscribeOptions);																
								}
							});
	                    	
	                    	buttonUnsubscribe.tooltipInfos = new WUXTooltipModel({ shortHelp: NLS.Unsubscribe});
	                    	
	                    	buttonUnsubscribe.inject(commandsDiv);

	                        setTimeout(function () {
	                            cell.setAttribute('title', '');
	                        },0);
	                        
	                        cell.setContent(commandsDiv);
	            		}
	            	}
	            });
	            
				options.treeDocument = model;
				/*model.addEventListener("select", function(e) {
			        //mainObject.listenerDiv.innerHTML += "<br>  onSelect";
					if(e.data.nodeModel._getRowID() === 5){
						return;
					}
					that.customSelect(e);
					//console.log('asdasdasd');
			      });
				model.addEventListener("unselect", function(e) {
			        //mainObject.listenerDiv.innerHTML += "<br>  onSelect";
					if(e.data.nodeModel._getRowID() === 5){
						return;
					}
					that.customUnSelect(e);
					//console.log('asdasdasd11');
			      });*/
				options.columns[1].text = NLS.name;
				
				var tree = new TreeListView(options);				

				tree.csrf = that.csrf;
				tree.url = that.url;
				var searchDiv = new MySubscriptionsToolbar(tree);	
				var treeListView = tree;
				var buttonUnsubscribe = new WUXButton({ 
					label: '',
					displayStyle: 'icon',
					emphasize : 'secondary',
					icon: treeListView.url + '/webapps/ENOSubscriptionMgmt/assets/icons/32/I_ActionUnSubscribe.png',
					onClick: function(e){
						var selectedElements = [];
						var nodesToRemove = [];
						var previousRows = [];
						var selectedRows = treeListView.getDocument().getSelectedNodes();
						if(selectedRows.length === 0){
							that._notif_manager.addNotif({
								level: 'error',
								message: NLS.UnsubscribeErrorMessage,
							    sticky: false
							});
							return;
						}
						selectedRows.forEach(function (row) { 
							if(previousRows.indexOf(row._options.grid.id) > -1){
								nodesToRemove.push(row);
								return;
							}
							previousRows.push(row._options.grid.id);
							nodesToRemove.push(row);						
							var selectedElement = {
									id: row._options.grid.id, 
									type:  row._options.grid.type_en, 
									dataelements: {
										eventsSubscribed :[]
									}	
							}
							if(row._options.grid.event){
								//logic to get all the other events which we are not unsubscribing
								var parent = row.getParent();
								if(parent!= null){
									var children = parent.getChildren();
									var childrenSelectedCount = 0;
									children.forEach(function(child){
										if(child.isSelected()){
											childrenSelectedCount ++;
										}else{
											selectedElement.dataelements.eventsSubscribed.push(child._options.grid.event_en);
										}
									});
									if(parent.getChildren().length === childrenSelectedCount ) //all child nodes are selected
										nodesToRemove.push(parent);
								}								
							}
							selectedElements.push(selectedElement);
						});
						
						var subscribeOptions = {};
						subscribeOptions.method = 'PUT';
						subscribeOptions.headers = {
			                     'Content-Type' : 'application/ds-json',
						};
						subscribeOptions.data = JSON.stringify(new ParseJSONUtil().createDataWithElementForRequest(selectedElements, treeListView.csrf));
							
						subscribeOptions.onComplete = function(serverResponse){
							that._notif_manager.addNotif({
								level: 'success',
								message: NLS.unSubscribeMYSubscriptions,
							    sticky: false
							});
							nodesToRemove.forEach(function(node){
								node.remove();
							});
							dialog.title = NLS.replace(NLS.MySubscriptionsTitle, {
			            		tag1: tree.getDocument().getChildren().length
			            	});
							searchDiv.updateEventAndTypeDropdown();
						};
						
						subscribeOptions.onFailure = function(){
							//console.log('Failure')
							that._notif_manager.addNotif({
								level: 'error',
								message: NLS.unsubscribeEventsFailure,
							    sticky: false
							});
						};
						subscribeOptions.timeout=0;
						var url = treeListView.url + '/resources/v1/modeler/subscriptions';
						url = new ParseJSONUtil().getURLwithLanguage(url);
						WAFData.authenticatedRequest(url, subscribeOptions);
					}
				});
				buttonUnsubscribe.tooltipInfos = new WUXTooltipModel({ shortHelp: NLS.Unsubscribe});
				
				var containerDiv = new UWA.Element('div');
				
				var containerDiv1 = new UWA.Element('div');
				var lineElement = new UWA.Element('div',{html: '<hr style= "width:100%; height:1px; margin:5px 0 10px 0; display:inline-block"/>' });
				buttonUnsubscribe.inject(containerDiv1);				
				searchDiv.buildToolbarView().inject(containerDiv1);
				
				lineElement.inject(containerDiv1);
				containerDiv1.inject(containerDiv);

				tree.inject(containerDiv);
				
				var immersiveFrame = new WUXImmersiveFrame();
	            immersiveFrame.inject(document.body);          
	            var dialog = new WUXDialog({
	            	title: NLS.replace(NLS.MySubscriptionsTitle, {
	            		tag1: response.data.length
	            	}),
	            	modalFlag: true,
	            	width:modalWidth,
	            	height:modalHeight,
	            	minWidth:675,
	            	minHeight:500,
	            	content: containerDiv,
	            	allowMaximizeFlag : true,
	            	resizableFlag : true,
	            	maximizeButtonFlag:false,
	            //   ensureHeightDefinitionOnHierarchy:true,
	            	immersiveFrame: immersiveFrame,
	           //    disabled:false,
	            //   activeFlag:true,
	            	buttons: {
	                   Cancel: new WUXButton({
	                	   label: NLS.close,
	                       onClick: function (e) {
	                           e.dsModel.dialog.close();
	                           that.SubscriptionDialogOpened = false;
	                       }
	                   })
	               }
	            });
	            
	            dialog.addEventListener('resize', function (e) {
	            	//console.log('Close on dialog : ' + e.dsModel.title);
                    var treeDiv = tree.getContent().getChildren()[0].getChildren()[1];
                    var modalHeight = e.dsModel.height - 125;
                    treeDiv.style.height = modalHeight +'px';
                    treeDiv.getChildren()[0].style.height = modalHeight +'px';
	            });
	            
	            dialog.addEventListener('close', function (e) {	            	
                    console.log(searchDiv.clearFindfield());
                    that.SubscriptionDialogOpened = false;
	            });
	            
			};
			
			that.onCompleteCSRF = function(csrf){
				that.csrf = JSON.parse(csrf).csrf;
				var postURL = that.url + '/resources/v1/modeler/subscriptions';
				var parseJSONUtil = new ParseJSONUtil();
				postURL = parseJSONUtil.getURLwithLanguage(postURL);
				var options = {};
				options.method = 'GET';
				options.headers = {
	                     'Content-Type' : 'application/ds-json',
				};
					
				options.onComplete = function(serverResponse){
					that.drawListViewPage(serverResponse);
				};			
				options.timeout=0;
				WAFData.authenticatedRequest(postURL, options);
				//console.log('execute command:' + this._id);				
			};
			
			that.showDialog = function(myContent, objCount){				 
				 var immersiveFrame = new WUXImmersiveFrame();
		         immersiveFrame.inject(document.body); 		         
				 var dialog = new WUXDialog({
		               title: NLS.MYSubscriptions,
		               modalFlag: true,
		               width:400,//to accomodate the filters
		               height:400,
		               content: myContent,
		               immersiveFrame: immersiveFrame,
		               buttons: {
		                   Close: new WUXButton({
		                       onClick: function (e) {
		                    	   e.dsModel.dialog.close();
		                    	   that.SubscriptionDialogOpened = false;
		                       }
		                   })
		               }
				 });
				 dialog.addEventListener('close', function (e) {
	                    that.SubscriptionDialogOpened = false;
		            });
			};
			require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'],function(CompassServices){
				CompassServices.getServiceUrl( { 
					serviceName: '3DSpace',
					platformId : widget.getValue("x3dPlatformId"), 
					onComplete : that.onCompletePlatform,
				});
			});	
			return that;
		}		
	};
	
	var ObjectMySubscriptionEventsAbs = Abstract.extend(ObjectMySubscriptionEvents);
	
	return ObjectMySubscriptionEventsAbs;
});

/* global define, widget */
/**
 * @overview Subscription Management - Module to create Mysubscription in action bar
 * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define("DS/ENOSubscriptionMgmt/Commands/MySubscriptions",
		[
			'UWA/Class',
			'DS/ApplicationFrame/Command',
			'DS/ApplicationFrame/CommandsManager',
			'DS/ENOSubscriptionMgmt/Views/ObjectMySubscriptionEvents'
], function(
		Class,
		AFRCommand,
		CommandsManager,
		ObjectMySubscriptionEvents
){
	'use strict';
	
	var wuxConsole = WUX.getWUXConsole();
	var MySubscriptionsCmd = AFRCommand.extend({

		/**
		 * Execute a command
		 * @namespace WUX.AFR
		 * @class Command
		 * @extends UWA.Class
		 * @constructor
		 *
		 */
		init: function (options) {
			this._parent(options, {
				mode: 'exclusive',
				isAsynchronous: true
			});
			this._dialogObj = {};
			this._dialogObj.SubscriptionDialogOpened = false;
		},

		beginExecute: function () {
		//	console.log('Beginning command:' + this._id);
			wuxConsole.info('Beginning command:' + this._id);
		},		

		resumeExecute: function () {
		//	console.log('Resuming command:' + this._id);

		},

		execute: function (options) {		
		//	console.log('execute command:' + this._id);			
			//CommandsManager.getCommand( this._id ).end();
			if(this._dialogObj.SubscriptionDialogOpened === false){
				this._dialogObj = new ObjectMySubscriptionEvents().showMySubscriptionDialog();
			}
			if(CommandsManager.getCommand( this._id )){
				CommandsManager.getCommand( this._id ).end();
			}else{
				var commandId = this._id;
				if(CommandsManager.getCommands()["[object Object]"][commandId])
					CommandsManager.getCommands()["[object Object]"][commandId].end();
			}
		},

		endExecute: function () {
		//	console.log('Stop command:' + this._id);
			wuxConsole.warn('Stop command:' + this._id);
		}

	});

	return MySubscriptionsCmd;
});

/* global define, widget */
/**
  * @overview Subscription Management
  * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
  * @version 1.0.
  * @access private
  */
define('DS/ENOSubscriptionMgmt/Views/ObjectSubscribeEvents',
[
   'DS/WAFData/WAFData',
   'UWA/Controls/Abstract',
   'DS/PADUtils/PADContext',
   'DS/WidgetServices/WidgetServices',
   'DS/ENOSubscriptionMgmt/Utils/ParseJSONUtil',
   'DS/Controls/Toggle', 
   'DS/Controls/ButtonGroup',
   'DS/Windows/Dialog',
   'DS/Windows/ImmersiveFrame',
   'DS/Controls/Button',
   'DS/Notifications/NotificationsManagerUXMessages',
   'DS/Notifications/NotificationsManagerViewOnScreen',
   'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt',
   'css!DS/ENOSubscriptionMgmt/ENOSubscriptionMgmt'   
],
function(
	WAFData,
	Abstract,
	PADContext,
	WidgetServices,
	ParseJSONUtil,
	WUXToggle, 
	WUXButtonGroup,
    WUXDialog,
    WUXImmersiveFrame,
    WUXButton,
	NotificationsManagerUXMessages,
	NotificationsManagerViewOnScreen,
	NLS	
) {
	'use strict';
	
	var ObjectSubscribeEvents = {
		serverresponse : {},
		showEditModalDialog : function(options) {
			var that = this;
			that.EditSubscriptionDialogOpened = true;
			that.options = options;
			that._notif_manager = NotificationsManagerUXMessages;
			NotificationsManagerViewOnScreen.setNotificationManager(that._notif_manager);
			
			that.onCompletePlatform = function(url){
				that.url = url;
				WAFData.authenticatedRequest(url + '/resources/v1/application/E6WFoundation/CSRF', UWA.extend(that.options, {
					method : 'GET',
					onComplete : that.onCompleteCSRF
				}, true));
			};
			
			that.onCompleteEdit = function(serverResponse){
				var response = JSON.parse(serverResponse);
				if(response.data[0].dataelements.objEventList.length === 0){
					 var myContent = new UWA.Element('div', { html: '<div style="display: inline-block; height: 34px; line-height: 34px;"> <p>'+ NLS.editSubscriptionsErrorMessage1+'</p>' });
					 that.showDialog(myContent, response.data.length);
					 return;
				}
				var objEventList = [], objEventNLSList = [], eventSubscriptionList = [], buttonGroup = new WUXButtonGroup({ type: 'checkbox' });
				response.data.forEach(function(dataElem) {
					var eventsAvailable = dataElem.dataelements.objEventList;
					var eventsNLSAvailable = dataElem.dataelements.objEventList_NLS;
					var eventsSubscribed = dataElem.dataelements.eventsSubscribed;
					for(var i=0; i< eventsAvailable.length; i++){
						var subs = eventsAvailable[i];
						if(eventSubscriptionList[i] == "mixedState:true"){
							//nothing
						} else if(eventSubscriptionList[i] == "checkFlag:true"){
							if(!(eventsSubscribed.indexOf(subs) > -1)){													
								eventSubscriptionList[i] = "mixedState:true";													
							}
							
						} else if(eventSubscriptionList[i] == "checkFlag:false"){
							if(eventsSubscribed.indexOf(subs) > -1){
								eventSubscriptionList[i] = "mixedState:true";													
							}
						}else {
							if(eventsSubscribed.indexOf(subs) > -1){
								eventSubscriptionList[i] = "checkFlag:true";
							}else{
								eventSubscriptionList[i] = "checkFlag:false";
							}
						}											
					}																				
					objEventList = eventsAvailable;
					objEventNLSList = eventsNLSAvailable;
				});
				
				for(var i=0; i< objEventList.length; i++){
					var checkBoxConfig = {};
					checkBoxConfig.type = 'checkbox';
					checkBoxConfig.label =  objEventNLSList[i];
					checkBoxConfig.actValue =  objEventList[i];
					var mixedstate = false;
					var checkflag = false;
					if(eventSubscriptionList[i] == "mixedState:true"){
						checkBoxConfig.mixedState = true;
						checkBoxConfig.checkFlag = true;
					} else if(eventSubscriptionList[i] == "checkFlag:true"){
						checkBoxConfig.checkFlag = true;
					} else{
						checkBoxConfig.checkFlag = false;
					}
					buttonGroup.addChild(new WUXToggle(checkBoxConfig));
				}
				var containerDiv = new UWA.Element('div', {html:'<div style="display: inline-block; height: 34px; line-height: 34px;"> <p>'+NLS.editEventsNotifyMessage+'</p> </div>'});
				var containerRight = new UWA.Element('div');
				var lineElement = new UWA.Element('div',{html: '<hr style= "width:100%; height:1px; margin:10px 0 10px 0"/>' });
				var ButtonSelectAllLabel = NLS.unSelectAll, btnCount = buttonGroup.getButtonCount();
				var emphasize = 'secondary';
				for(var cnt=0;cnt< btnCount;cnt++ ){
					if(buttonGroup.getButton(cnt).checkFlag === false){
						ButtonSelectAllLabel = NLS.selectAll;
						emphasize = 'primary';
						break;
					}
				}
				var buttonSelectAll = new WUXButton({ 
								label: ButtonSelectAllLabel,
								displayStyle: 'normal',
								emphasize:emphasize,
								onClick: function(e){			
									if(e.dsModel.label == NLS.selectAll){
										for(var cnt=0;cnt< btnCount;cnt++ ){
											buttonGroup.getButton(cnt).checkFlag=true;
											buttonGroup.getButton(cnt).mixedState=false;
										}
										e.dsModel.label = NLS.unSelectAll;
										e.dsModel.emphasize = 'secondary';
									} else{
										for(var cnt=0;cnt< btnCount;cnt++ ){
											buttonGroup.getButton(cnt).checkFlag=false;
											buttonGroup.getButton(cnt).mixedState=false;
										}
										e.dsModel.label = NLS.selectAll;
										e.dsModel.emphasize = 'primary';
									}																		
								}
							});
				buttonSelectAll.inject(containerRight);
				lineElement.inject(containerRight);
				containerRight.inject(containerDiv);
				buttonGroup.inject(containerDiv);

				var immersiveFrame = new WUXImmersiveFrame();
	            immersiveFrame.inject(document.body);          
	            that.dialog = new WUXDialog({
	               title: NLS.replace(NLS.editSubscriptionsTitle, {
	            	   			tag1: response.data.length
                   			}),
	               modalFlag: true,
	               width:400,
	               height:350,
	               content: containerDiv,
	               immersiveFrame: immersiveFrame,
	               buttons: {
	                   Cancel: new WUXButton({
	                       onClick: function (e) {
	                           e.dsModel.dialog.close();
	                           that.EditSubscriptionDialogOpened = false;
	                       }
	                   }),
	                   Ok: new WUXButton({
	                	   label: NLS.ok,
	                       onClick: function (e) {       	   					                    	   
								response.data.forEach(function(dataElem) {
									var eventsAvailable = dataElem.dataelements.objEventList;
									var eventsSubscribed = dataElem.dataelements.eventsSubscribed;
									var updatedEventList = [];
									var cnt = e.dsModel.dialog.content;
									for(var i = 0; i< eventsAvailable.length; i++){
										var subs = eventsAvailable[i];
										var btn = cnt.getChildren()[2].dsModel.getButton(i);//cnt.getButton(i); 
										if(btn.mixedState == true){
											if(eventsSubscribed.indexOf(subs) > -1){
												updatedEventList.push(subs);
											}
											//skip
										} else if(btn.mixedState == false){
											if(btn.checkFlag == true){
												updatedEventList.push(subs);
											} 
										} else {
											if(btn.checkFlag == true){
												updatedEventList.push(subs);
											} 
										}
									}
									dataElem.dataelements.eventsSubscribed = updatedEventList;	
								});
								var editSubscribeOptions = {};
								editSubscribeOptions.method = 'PUT';
								editSubscribeOptions.data = JSON.stringify(new ParseJSONUtil().createDataWithElementForRequest(response.data, that.csrf));
								editSubscribeOptions.onComplete = function(res){
									that._notif_manager.addNotif({
										level: 'success',
										message: NLS.EditsubscribeSuccess,
									    sticky: false
									});
								};
								editSubscribeOptions.onFailure = function(){
									that._notif_manager.addNotif({
										level: 'error',
										message: NLS.EditsubscribeFailure,
									    sticky: false
									});
								};	
								editSubscribeOptions.timeout=0;
								var url = that.url + "/resources/v1/modeler/subscriptions";
								url = new ParseJSONUtil().getURLwithLanguage(url);
								WAFData.authenticatedRequest(url, editSubscribeOptions);
								e.dsModel.dialog.close();
								that.EditSubscriptionDialogOpened = false;
	                       }
	                   })
	               }
	            });
	            that.dialog.addEventListener('close', function (e) {	            	
	                that.EditSubscriptionDialogOpened = false;
	            });
			};
			
			that.onCompleteCSRF = function(csrf){
				that.csrf = JSON.parse(csrf).csrf;
				var postURL = that.url + '/resources/v1/modeler/subscriptions/getSubscriptionsbyPost';
				var parseJSONUtil = new ParseJSONUtil();
				postURL = parseJSONUtil.getURLwithLanguage(postURL);
				var selected_nodes;
				var localContext = PADContext.get();
				if (null == localContext){
					localContext = that.context;
					if (null == localContext){
						localContext = that.options.context;
					}
				}
				
				var insideModel = localContext.model;
				if (!insideModel || !insideModel.objectId){ 
					selected_nodes = localContext.getSelectedNodes(); 
				}				
				var resultElementSelected = [];
				
				if (selected_nodes.length) {
					selected_nodes.forEach(function(node) {
						//Instance has priority as it displayed both reference and instance
						var nodeID = node && typeof node.getInstID === "function" ? node.getInstID() : null;
						if (nodeID != null && Array.isArray(nodeID)){
							nodeID = nodeID.length > 0 ? nodeID[0] : null;
						}
						var defaultMetatype = nodeID ? 'relationship' : 'businessobject';
						nodeID = nodeID ? nodeID : node.getID();
						nodeID = nodeID ? nodeID : node.id;
						var metatype = node.metatype ? node.metatype: defaultMetatype;
						var source = node.source ? node.source : null;
						var tenant = parseJSONUtil.getTenantFromNode(node);
						var type = parseJSONUtil.getTypeFromNode(node);
						
						if (nodeID) {
							var initModel = {
									'type' : type,
									'cestamp' : metatype,
									'relId' : nodeID,
									'id' : nodeID,
									'dataelements':{}
							};
							var tenant = tenant ? tenant : WidgetServices.getTenantID();

							if (tenant) initModel['tenant'] = tenant;
							if (source) initModel['source'] = source;
							if (type) initModel['type'] = type;
							resultElementSelected.push(initModel);
						}
					});
				}
				var previousType = resultElementSelected[0].type;
				var isDifferentType = false;
				for(var i= 1; i<resultElementSelected.length; i++){
					if(previousType != resultElementSelected[i].type){
						isDifferentType = true;
					}
					previousType = resultElementSelected[i].type;
				}
				
				if(isDifferentType){
					var myContent = new UWA.Element('div', { html: '<div style="display: inline-block; height: 34px; line-height: 20px;"><p>' + NLS.editSubscriptionsErrorMessage+'</p>' });
					that.showDialog(myContent,selected_nodes.length);
					 return;
				}
				var editSubscribeOptions = {};
				editSubscribeOptions.method = 'POST';
				editSubscribeOptions.headers = {
	                     'Content-Type' : 'application/ds-json',
				};
				editSubscribeOptions.data = JSON.stringify(new ParseJSONUtil().createDataWithElementForRequest(resultElementSelected, that.csrf));
					
				editSubscribeOptions.onComplete = function(serverResponse){
					that.onCompleteEdit(serverResponse);
				};		
				editSubscribeOptions.timeout=0;
				WAFData.authenticatedRequest(postURL,editSubscribeOptions);
			//	console.log('execute command:' + this._id);				
			};
			
			that.showDialog = function(myContent, objCount){				 
				 var immersiveFrame = new WUXImmersiveFrame();
		         immersiveFrame.inject(document.body); 		         
				 var dialog = new WUXDialog({
		               title: NLS.replace(NLS.editSubscriptionsTitle, {tag1: objCount}),
		               modalFlag: true,
		               width:400,
		               height:350,
		               content: myContent,
		               immersiveFrame: immersiveFrame,
		               buttons: {
		                   Close: new WUXButton({
		                       onClick: function (e) {
		                    	   e.dsModel.dialog.close();
		                    	   that.EditSubscriptionDialogOpened = false;
		                       }
		                   })
		               }
				 });
				 dialog.addEventListener('close', function (e) {	            	
		                that.EditSubscriptionDialogOpened = false;
		            });
			};
			
			require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'],function(CompassServices){
				CompassServices.getServiceUrl( { 
					serviceName: '3DSpace',
					platformId : widget.getValue("x3dPlatformId"), 
					onComplete : that.onCompletePlatform,
				});
			});	
			return that;
		},		
	};
	
	var ObjectSubscribeEventsAbs = Abstract.extend(ObjectSubscribeEvents);

	return ObjectSubscribeEventsAbs;
});

/* global define, widget */
/**
 * @overview Subscription Management - Module for 'Edit Subscribe' command in action bar
 * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define("DS/ENOSubscriptionMgmt/Commands/EditSubscribe",
		[	'UWA/Class',
			'DS/ApplicationFrame/Command',
			'DS/ApplicationFrame/CommandsManager',
			'DS/Core/Core',
			'DS/ENOSubscriptionMgmt/commands/CommandAvailableOnSelect',
			'DS/ENOSubscriptionMgmt/Views/ObjectSubscribeEvents',
			'i18n!DS/ENOSubscriptionMgmt/assets/nls/ENOSubscriptionMgmt'
			], function (
					Class,
					AFRCommand,
					CommandsManager,
					WUX,			
					OnSelectCommand,
					ObjectSubscribeEvents,
					NLS
			) {
	'use strict';

	// -- debug purpose only --
	// WUX.enableWUXConsole();
	var wuxConsole = WUX.getWUXConsole();
	var container,myContent,selected_nodes;


	var EditSubscribeCmd = Class.extend(AFRCommand, OnSelectCommand,{

		/**
		 * Execute a command
		 * @namespace WUX.AFR
		 * @class Command
		 * @extends UWA.Class
		 * @constructor
		 *
		 */
		init: function (options) {
			this._parent(options, {
				mode: 'exclusive',
				isAsynchronous: true
			});
			this._dialogObj = {};
			this._dialogObj.EditSubscriptionDialogOpened = false;
		},

		beginExecute: function () {
			// -- Get the frame --
			this._frmWindow = this.getFrameWindow();
			// -- Init variables used to execute the command --
		//	console.log('Beginning command:' + this._id);
			wuxConsole.info('Beginning command:' + this._id);
		},

		resumeExecute: function () {
		//	console.log('Resuming command:' + this._id);
		},
		
		execute: function (options) {
			//CommandsManager.getCommand( this._id ).end();
			if(this._dialogObj.EditSubscriptionDialogOpened === false){
				this._dialogObj = new ObjectSubscribeEvents().showEditModalDialog(this.options);
			}
			if(CommandsManager.getCommand( this._id )){
				CommandsManager.getCommand( this._id ).end();
			}else{
				var commandId = this._id;
				if(CommandsManager.getCommands()["[object Object]"][commandId])
					CommandsManager.getCommands()["[object Object]"][commandId].end();
			}
			
		},
		endExecute: function () {
		//	console.log('Stop command:' + this._id);
			wuxConsole.warn('Stop command:' + this._id);
		}

	});

	return EditSubscribeCmd;
});


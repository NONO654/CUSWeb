define(  'DS/SMAExeCOSAdmin/Views/RendererUtils',
	    ['UWA/Core',
		 'UWA/Class/Model',
		 'DS/Controls/ButtonGroup',
		 'DS/Controls/Button',
	     'DS/W3DXComponents/Skeleton',
	     'DS/W3DXComponents/Views/Layout/TableScrollView',
	     'DS/W3DXComponents/Views/Layout/ListView',
	     'DS/W3DXComponents/Views/Item/SetView',
	     'DS/W3DXComponents/Collections/ActionsCollection',
	     'DS/SMAExeCOSAdmin/Collection/StationCollection',
	     'DS/SMAExeCOSAdmin/Collection/ClusterMemberCollection',
	     'DS/SMAExeCOSAdmin/Collection/ServerStationCollection',
	     'DS/SMAExeCOSAdmin/Collection/ApplicationCollection',
	     'DS/SMAExeCOSAdmin/Collection/DriveCollection',
	     'DS/SMAExeCOSAdmin/Collection/WorkItemCollection',
	     'DS/SMAExeCOSAdmin/Views/ServerPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationAdvancedPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationComputePropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationGeneralPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationLoggingPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationResultsPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/StationROPropertiesView',
	     'DS/SMAExeCOSAdmin/Views/ServerTreeView',
	     'DS/SMAExeCOSAdmin/Forms/StationPropsEditObj',
	     'DS/SMAExeCOSAdmin/Forms/ApplicationPropsObj',
	     'DS/SMAExeCOSAdmin/Forms/DrivePropsObj',
	     'DS/SMAExeCOSAdmin/Forms/ConfirmDialog',
	     'DS/SMAExeCOSAdmin/Forms/AddStationsDialog',
	     'DS/SMAExeCOSAdmin/Forms/GetEventLogDialog',
	     'DS/SMAExeCOSAdmin/Forms/RegisterServer',
	     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	     'DS/SMAExeCOSAdmin/Forms/StationImportPanel',
		 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin',
		 'css!DS/SMAExeCOSAdmin/assets/Styles/SMAExeCOSAdmin.css'
	     ],
		/*
		 * utility class to create the various renderers for the different facets
		 */
	function (UWA,  UWAModel,  ButtonGroup,  Button,
			  Skeleton,
			  TableScrollView,
			  ListView,
			  SetView,
			  ActionsCollection,
			  StationCollection,
			  ClusterMemberCollection,
			  ServerStationCollection,
			  ApplicationCollection,
			  DriveCollection,
			  WorkItemCollection,
			  ServerPropsView,
			  StationAdvancedPropsView,
			  StationComputePropsView,
			  StationGeneralPropsView,
			  StationLoggingPropsView,
			  StationResultsPropsView,
			  StationROPropsView,
			  ServerTreeView,
			  StationPropsEditObj,
			  ApplicationPropsObj,
			  DrivePropsObj,
			  ConfirmDialog,
			  AddStationsDialog,
			  GetEventLogDialog,
			  RegisterServer,
			  WSUtils,
			  COSUtils,  COSInfo,  StationImportPanel,
			  NLS )
	{

    	'use strict';

		var RendererUtils = {

		    	// utility function when deleting a group that cleans up the station in the group
		    	// will re- parent the station nodes in the tree
		    	// clear the group field
				groupDeleteFixup : function  (node,  groupName) {

					// if we have a tree node we need to re-parent child station nodes to the server parent
					if (node) {
						var parentNode = node.getParent();
						var childNodes = node.getChildren();

						// safety check may not have child nodes
						// if deleting group and stations under group at the same time
						if (childNodes) {
							// need to copy child node array since array is changed as children are re-parented
							// which causes problems
							var childCopies = [];
							childNodes.forEach(function( chld){
								childCopies.push(chld);
							}) ;

							// iterate over tree models to clear group field
							for (var idx = 0; idx < childCopies.length; idx++){
								var child = childCopies[idx];
								var childModel = COSUtils.findModel(0,
										child.options.label + '@@' + child.options.serverName);
								if (childModel) {
									childModel.set('@group',  '');
									childModel.set('group',  '');
								}
								parentNode.addChild(child);
							}
						}
					}

					// iterate over list models to clear out group field
					var view = COSInfo.getBones().getViewAt(1);
					if (view && view.collection) {
						for (var i = 0 ; i < view.collection._models.length; i++) {
							var model = view.collection._models[i];
							if (model.get('@group')===groupName ) {
								model.set('@group',  '');
								model.set('group',  '');
							}
						}
					}
				},

		        // delete fiper and lsf groups need to wait for fiper group (if present)
			   	// to delete and then delete lsf groups so both delete do not manipulate
			   	// the UI simultaneously
				groupDeleteByMode : function  (mode,  modelToDelete,  groupsFiper,  groupsLsf) {
			   		var stationList = '';
			   		this.fiperGroups = groupsFiper;

			   		// if we have fiper groups delete them and when done delete lsf groups if any
			   		if (groupsFiper.length) {
			   			var one = true;
			   			groupsFiper.forEach(function( grp){
			   				if (one){
			   					stationList = stationList + 'stationName=' + grp;
			   					one = false;
			   				}
			   				else {
			   					stationList = stationList + '&stationName=' + grp;
			   				}
			   			});
			   			WSUtils.deleteStationList(
			   				modelToDelete.get('fullCosUrl'),
			   				modelToDelete.get('serverName'),
		   					stationList,  mode,
		   					function(data) {
		   						// if some of the groups could not be deleted
			   					// display message to user
								var message = data.split('could not');
								if (message.length > 1) {
									COSUtils.displayError(data,  true);
								}

								// process the groups that were deleted
								var good = message[0];
								var goodGrps = good.replace(/ /g, '').split('\n');
								var view = COSInfo.getBones().getViewAt(1);

								// clear group attribute in list and tree models
								for (var i = view.collection._models.length-1 ; i >=0 ; i--) {
									var model = view.collection._models[i];
									if (goodGrps.indexOf(model.get('@name')) >=1) {
										var node = COSUtils.findNode(
												model.get('@name') +'@@' + model.get('serverName') );
										RendererUtils.groupDeleteFixup(node,  model.get('@name'));

										// if we have a node in the tree
										// need to remove the node and the model from the tree collection
										if (node) {
											node.remove();
											COSUtils.removeTreeModel(model.get('@name') +'@@' +
													COSUtils.fixServer(model.get('serverName')) );
										}
										if (view.collection) {
											view.collection.remove(model);
										}
									}
								}

								if (groupsLsf.length){
									RendererUtils.groupDeleteByMode('LsfGrp',  modelToDelete,  groupsLsf,  []);
								}
			   				});
			   		}
			   		else if (groupsLsf.length) {
			   			RendererUtils.groupDeleteByMode('LsfGrp',  modelToDelete,  groupsLsf,  []);
			   		}
			   	},
			   	
			   	// method to delete any custom drm groups
				groupDeleteOther : function  (groupsOther) {
					groupsOther.forEach(function( grpModel){
						var stationList = 'stationName=' + grpModel.get('@name');
         				var genInf = grpModel.get('GeneralInfo');
           				var drmMode = genInf['@drmMode'];
						WSUtils.deleteStationList(
							grpModel.get('fullCosUrl'),
							grpModel.get('serverName'),
							stationList,  drmMode,
							function(data) {
								// if some of the groups could not be deleted
								// display message to user
								var message = data.split('could not');
								if (message.length > 1) {
									COSUtils.displayError(data,  true);
								}
								// process the groups that were deleted
								var good = message[0];
								var goodGrps = good.replace(/ /g, '').split('\n');
								var view = COSInfo.getBones().getViewAt(1);

								// clear group attribute in list and tree models
								for (var i = view.collection._models.length-1 ; i >=0 ; i--) {
									var model = view.collection._models[i];
									if (goodGrps.indexOf(model.get('@name')) >=1) {
										var node = COSUtils.findNode(
												model.get('@name') +'@@' + model.get('serverName') );
										RendererUtils.groupDeleteFixup(node,  model.get('@name'));

										// if we have a node in the tree
										// need to remove the node and the model from the tree collection
										if (node) {
											node.remove();
											COSUtils.removeTreeModel(model.get('@name') +'@@' +
													COSUtils.fixServer(model.get('serverName')) );
										}
										if (view.collection) {
											view.collection.remove(model);
										}
									}
								}
							}
					)}
				)},



			   	facetUnselect : function  (skeleton) {
		    		var view = skeleton.getViewAt(1);
		    		if ( view && view.multiselHeaderView && view.contentsViews &&
		    				view.contentsViews.table &&
							view.contentsViews.table.nestedView) {
		    		    view.contentsViews.table.nestedView.deactivateMultisel();
		    		}
		    	},

		    	// utility method to check if server model is on the cloud
		    	onTheCloud : function () {
    				var view = COSInfo.getBones().getViewAt(1);
    				var onCloud = false;
    				if (view && view.model && view.model.get('onCloud') ) {
    					onCloud = view.model.get('onCloud').toLowerCase()==='true';
    				}
    				return onCloud;
		    	},

			// create and return the various renderers base on owner role
			getRenderers:function (isOwner) {

				// allow for multi-selection if owner if not dis-allow selection
     		   var selectionType = 'nullToMany';
     		   if (!isOwner) {
     			  selectionType = 'nullToNull';
     		   }
		         // defines the renderers for the various views
		         // the root view is a tree view that has a collection of Servers,  Stations,  and Groups
		    	var renderers = {
					serverRenderer: {
						collection: ServerStationCollection,
			            view: ServerTreeView,
						viewOptions : {},

						idCardOptions: {
						    attributesMapping: {
						        title: function() {
		                      	  	var name = this.get('name');
		                      	  	if (name) {
		                      	  		return name;
		                      	  	}
		                      	  	else {
		                      		  	return this.id;
		                      	  	}
						        }
						},

						events : {
							   onFacetSelect: function () {
			                	   //var myModel = this.model;
			                	   //var actions = this.container.querySelector('.actions-list');
			                	   /* do not hide id-card action for stations for now passed in if used
		                		   if ('Stations' === facetName){
		                			   actions.hide();
		                		   }
		                		   else {
		                			   actions.show();
		                		   }
		                		   */
							   },
							   // on render function to control idCard actions based on model state
							   // model can be server,  station,  or group
							   // actions by state only relevant for owners
			                   onRender: function () {
		                		   // get model
			                	   var myModel = this.model;
			                	   // get the id of the model if has @@ means group or station
			           			   var splitName = myModel.get('id').split('@@');
			           			   
			           			   // length of 1 means no @@ so this is idCard for server
			           			   if (splitName.length === 1) {
			           				   // get the member facet for the server if we have one set it 
			           				   // if have single deploy type hide member facet
			           				   var skeleton = COSInfo.getBones();
									   var memberFacet = null;
									   if (skeleton.getActiveIdCard()) {
										   memberFacet = skeleton.getActiveIdCard()._getFacetElt(2);
										   if (memberFacet !== null && memberFacet !== undefined) {
											   COSInfo.setMemberFacet(myModel.id, memberFacet)
											   if (myModel._attributes.deployType === '' || myModel._attributes.deployType ==='single') {
												   memberFacet.hide();
											   }
										   }
									   }
			           			   }
			                	   if (isOwner) {
				                	   // get the idCard actions
				                	   var actions = this.container.querySelector('.actions-list');
				                	   var actArr = actions.children;


				           			   // length of 1 means no @@ so this is idCard for server
				           			   if (splitName.length === 1) {
				           				   
				           				   // if server is on cloud only have two action so 
				           				   // there is no pause or resume actions
				           				   if (actArr.length > 3) {
						                	   var pauseAct = actArr[2];
						                	   var playAct = actArr[3];
				     		        		   var wsUrl = myModel.get('fullCosUrl') ;
	
				     		        		   // get status of server
				     		            	   WSUtils.adminGetStatus(wsUrl,
				     			            			// if success ...display action button based on status
				     				                    function(data) {
				     				                    	var status = data;
				     				                    	if ('RUNNING' === status) {
				     				                    		playAct.hide();
				     				                    	}
				     				                    	if ('PAUSED' === status) {
				     				                    		pauseAct.hide();
				     				                    	}
				     				                    },
				     				                    // if fail display error
				     				                    function () {
				     				                    	playAct.hide();
				     				                    });
				           				   }
					                   }
				           			   // otherwise...station or group
				           			   else {
				           				  var genInf = myModel.get('GeneralInfo');
				           				  var drmMode = genInf['@drmMode'];
				           				    // only interested in station actions
				           		   			if (drmMode === 'fiper') {
				           		   				var status = myModel.get('@status');
							                	var pauseAct2 = actArr[1];
							                	var playAct2 = actArr[2];
							                	if ('Running' === status) {
							                		playAct2.hide();
							                	}
							                	if ('Suspended' === status) {
							                		pauseAct2.hide();
							                	}
							                	if ('Invalid' === status  || 'Shutdown' === status) {
							                		playAct2.hide();
							                	}
				           		   			}
				           			   }
			                	   }
			                   }
						},

						// defines actions for the selected item
						// if the item contains GeneralInfo then it is a station or group
						// define the various actions
						actions: function () {
				     		if (this.get('GeneralInfo')){
				                var actions = [];

				                if (!isOwner) {
				                	return actions;

				                }
				                // edit bring up an edit dialog with data from the current station
				                // need to be implemented for groups
		                        var edit = {
				                    id: 'edit',
				                    title: 'Edit',
				                    text: NLS.get('edit'),
				                    icon: 'pencil',
				                    handler: function(view){
				                    	if (view.model._attributes.GeneralInfo['@drmMode'].endsWith('Grp')){
				                    		var form1 = StationPropsEditObj.updateFields(
				                    				this.model, true, this.model.get('serverName'), this.model.get('fullCosUrl'), true);
				                    		if (form1) {
				                    			StationPropsEditObj.showDialog(form1,  true);
				                    		}
				                    		else {
				                    			COSUtils.displayError(NLS.get('facetErr'),  true);
				                    		}
				                    	}
				                    	else {
			                                var form2 = StationPropsEditObj.updateFields(
			                                	this.model, true, this.model.get('serverName'), this.model.get('fullCosUrl'), false);
			                                if (form2) {
			                                	StationPropsEditObj.showDialog(form2,  false);
				                    		}
				                    		else {
				                    			COSUtils.displayError(NLS.get('facetErr'),  true);
				                    		}
				                    	}
				                    }
		                        };
		                        // only support edit action for groups
		                        actions.push(edit);

		                        // add other actions if not a group
		          			    if (this.get('GeneralInfo')['@drmMode'].endsWith('Grp') === false){
		    		                // pause use COS API to call web service to pause a station
		    		                // gets a ticket from EEP and then calls the COS web service with the ticket
		    		                var pause = {
					                    id: 'pause',
					                    title: 'Pause',
					                    text: NLS.get('pause'),
					                    icon: 'pause',
					                    actionBar: true,
			     		        	    handler: function(){
			     		        		   var stationName = this.model._attributes['@name'];
			     		        		   var wsUrl = this.model.get('fullCosUrl');

			     		        		   WSUtils.suspendStation(
		     		        				   wsUrl, this.model.get('serverName'), stationName,
		     		        				   // suspend success fix UI
		     		        				   function() {
		     		        					   var view = COSInfo.getBones().getViewAt(1);
		     		        					   if (view ) {
		     		        						   view.model.set('@status', 'Suspended', {silent:true});
		     		        						   view.model.set('status', 'Suspended');
		     		        						   COSUtils.setBadgesOnNode(
		     		        								   view.model.get('name') +'@@' + view.model.get('serverName'), 'Suspended');
		     		        					   }
		     		        				}); // end success function and suspend call
		    	     		        	 }
		    			            };
		    		                // resume uses JS COS API to resume station it will
		    		                // get a ticket from EEP and then calls the COS web service with the ticket
		    		                var resume = {
		    			                    id: 'resume',
		    			                    title: 'Resume',
		    			                    text: NLS.get('resume'),
		    			                    icon: 'play',
		    	     		        	   handler: function(){
		    	     		        		   var stationName = this.model._attributes['@name'];
		    	     		        		   var wsUrl = this.model.get('fullCosUrl') ;
		    	     		        		   WSUtils.resumeStation(
		 	 	 		        				  wsUrl, this.model.get('serverName'), stationName,
		 	 	 		        				  // resume success function fix UI
		 	 		        					  function() {
		     	     		                        var view = COSInfo.getBones().getViewAt(1);
		    	     		                        if (view ) {
		    	     		                        	view.model.set('@status', 'Running', {silent:true});
		    	     		                        	view.model.set('status', 'Running');
		    	     		                        	COSUtils.setBadgesOnNode(
			    	     		                        	view.model.get('name') +'@@' + view.model.get('serverName'), 'Running');
		    	     		                        }
		     	 	 		        			}); // end success function and resume call
		    	     		        	   }
		    		                };

		    		                var restart = {
		    			                    id: 'restart',
		    			                    title: 'Restart',
		    			                    text: NLS.get('restart'),
		    			                    icon: 'reload',
		    	     		        	   handler: function(){
		    	     		        		   var stationName = this.model._attributes['@name'];
		    	     		        		   var wsUrl = this.model.get('fullCosUrl') + '/admin/station/' + stationName + '/shutdown?Restart=true';
		    	     		        		   ConfirmDialog.showDialog(this.model,  NLS.get('restartStation'),  wsUrl,  'restart');
		    	     		        	   }
		    			                };

		    		                var stop = {
		    			                    id: 'stop',
		    			                    title: 'Stop',
		    			                    text: NLS.get('stop'),
		    			                    icon: 'stop',
		    	     		        	   handler: function(){
		    	     		        		   var stationName = this.model._attributes['@name'];
		    	     		        		   var wsUrl = this.model.get('fullCosUrl') + '/admin/station/' + stationName + '/shutdown';
		    	     		        		   ConfirmDialog.showDialog(this.model,  NLS.get('stopStation'),  wsUrl,  'stop');
		    	     		        	   }
		    			                };

		          			    	actions = actions.concat([pause,  resume,  restart, stop]);
		          			    }

				                // delete calls web service to delete a station
				                // uses COS JS API which gets a ticket from EEP and then calls the COS web service with the ticket
				                // if the call is successful it will remove the station model and node from the tree
				                var trash = {
					                    id: 'trash',
					                    title: 'Delete',
					                    text: NLS.get('trash'),
					                    icon: 'trash',
		 	     		        	   handler: function(){
		 	     		        		   var stationName = this.model.get('@name');
		 	     		        		   var mode = this.model.get('GeneralInfo')['@drmMode'];
		 	     		        		   WSUtils.deleteStation(
		 	     		        				 this.model.get('fullCosUrl'),
		 	     		        				 this.model.get('serverName'),
		 	     		        				 stationName, mode,
		 	     		        				 // success function need to fix UI for deleted station (or group)
		 	     				                 function(){
		 	     				                    	// need to remove station from UI
			     	     		                        var view = COSInfo.getBones().getViewAt(1);
			    	     		                        if (view ) {
			 	     		          		        		var node = COSUtils.findNode(
			 	     		          		        				view.model.get('@name') +'@@' + view.model.get('serverName') );
			 	     		          		        		// if deleting a group,  need to reparent station nodes
			 	     		          		        		// and clear group attribute
		 	     		          		        			if (mode.endsWith('Grp')) {
		 	     		          		        			RendererUtils.groupDeleteFixup(node, view.model.get('@name')) ;
		 	     		          		        			}
		 	     		          		        			// if we have a node in the tree
		 	     		          		        			// need to remove the node and the model from the tree collection
			 	     		          		        		if (node) {
			 	     		          		        			node.remove();
			 	     		          		        			COSUtils.removeTreeModel(view.model.get('@name') +'@@' +
			 	     		          		        				COSUtils.fixServer(view.model.get('serverName')) );
			 	     		          		        		}

			 	     		          		        		// remove station model from station list
			    	      	     		        		    var collection = view.model.collection;
			    	      	     		        		    if (collection) {
			    	      	     		        		    	collection.remove(collection.get(stationName));
			    	      	     		        		    }

			 	     		    		    		       // slide back the panel since the station has been deleted
			 	     		    		    		       COSInfo.getBones().slideBack();
			    	     		                        }
		 	     				                 });// end success function and delete call
		 	     		        	   }// end handler
				                };// end trash action
		      			    	actions = actions.concat([ trash]);
				                return  actions;
				     		}
				     		// return actions for server
				     		// if not an owner only support set default and event log
				     		if (!isOwner) {
				     			var onCloud = false;
				     			if (this.model) {
				     				onCloud = this.model.get('onCloud');
				     			}
				     			else {
				     				onCloud = this.get('onCloud');				     				
				     			}
				     			
				     			// don't show event log if on cloud
				     			if ('true' === onCloud) {
				     				return [{
				     					// setAsdefault will call JS COS API which will call
				     					// EEPServices to set the server as the default server for COS execution
				     					text:  NLS.get('setDefault'),
				     					icon: 'new-create',
				     					handler: function(){
				     						var server = this.model.id;
				     						WSUtils.setDefaultServer(server,
				     								// success function clears the default server badge on all the servers
				     								// and sets it for the new default server
				     								function(data){
				     							var treeView = COSInfo.getBones().getViewAt(0);
				     							if (treeView) {
				     								treeView.treeModel.getRoots().forEach(function (model) {
				     									COSUtils.clearDefaultBadgeOnNode(model.options.label);
				     								});
				     							}
				     							COSUtils.setDefaultBadgeOnNode(data);
				     						});// end success function and set default call
				     					}
				     				}];
				     			}
				     			else {
					     			return [{
							            	// setAsdefault will call JS COS API which will call
							            	// EEPServices to set the server as the default server for COS execution
							                text:  NLS.get('setDefault'),
							                icon: 'new-create',
							                handler: function(){
							                	var server = this.model.id;
							                	WSUtils.setDefaultServer(server,
							                		// success function clears the default server badge on all the servers
							                		// and sets it for the new default server
						    		                function(data){
							                    		var treeView = COSInfo.getBones().getViewAt(0);
							                    		if (treeView) {
							        	    		        treeView.treeModel.getRoots().forEach(function (model) {
							        	    		        	COSUtils.clearDefaultBadgeOnNode(model.options.label);
							        	    		        });
							                    		}
			    	     		                    	COSUtils.setDefaultBadgeOnNode(data);
							                	});// end success function and set default call
							                }
					     			 },
					     			{
							                text:  NLS.get('eventLog'),
							                icon: 'newspaper',
							                handler: function(){
							                	var server = this.model.id;
							                	var wsUrl = this.model.get('fullCosUrl') ;
							                	var depType = this.model.get('deployType');
							                	GetEventLogDialog.showDialog(server, wsUrl, depType) ;
							                }
					     			 }];
				     			}
				     		}
				     		// if owner check if on cloud or not
				     		else {
				     			var onCloud1 = false;
				     			if (this.model) {
				     				onCloud1 = this.model.get('onCloud');
				     			}
				     			else {
				     				onCloud1 = this.get('onCloud');
				     			}
				     			// if on cloud only allow set default and unregister
				     			// cannot edit, pause,resume cloud servers
				     			if ('true' === onCloud1) {
				     				return [
							            {
							            	// setAsdefault will call JS COS API which will call
							            	// EEPServices to set the server as the default server for COS execution
							                text:  NLS.get('setDefault'),
							                icon: 'new-create',
							                handler: function(){
							                	var server = this.model.id;
							                	WSUtils.setDefaultServer(server,
							                		// success function clears the default server badge on all the servers
							                		// and sets it for the new default server
						    		                function(data){
							                    		var treeView = COSInfo.getBones().getViewAt(0);
							                    		if (treeView) {
							        	    		        treeView.treeModel.getRoots().forEach(function (model) {
							        	    		        	COSUtils.clearDefaultBadgeOnNode(model.options.label);
							        	    		        });
							                    		}
			    	     		                    	COSUtils.setDefaultBadgeOnNode(data);
							                	});// end success function and set default call
							                }
							            },
							            {
							            	// unregister a server will call JS COS API which will call
							            	// EEPServices to remove the server from the COS Configurations
							                text:  NLS.get('unregister'),
							                icon: 'trash',
							                handler: function(){
							                	var server = this.model.id;
							                	// check if trying to unregister 'global' COS server
							                	// if so(first model in list)...show error
							                	var treeView = COSInfo.getBones().getViewAt(0);
							            		if (server === treeView.collection._models[0].id) {
							   			        	COSUtils.displayError(NLS.get('unregisterErr'), true);
							            		}
							            		else {
								                	WSUtils.unregisterServer(
							                			server,
							                			// success function removes server node and model from collection
							    		                function(){
											        		    var treeView = COSInfo.getBones().getViewAt(0);
											    		        treeView.treeModel.getRoots().forEach(function (model) {
																	if (model.options.label === server){
																		COSInfo.getBones().getViewAt(0).treeModel.removeRoot(model);
																    }
											    		        });
											    		        treeView.collection.forEach(function (model) {
																		if (model.id === server){
																			COSInfo.getBones().getViewAt(0).collection.remove(model);
																	    }
											    		        });
											    		        COSInfo.getBones().slideBack();
							                			});// end success function and unregister call
							            		}
							                }
							            },
				     				]
				     			}
				     			// on premise return all the actions
							    return [
							            // edit the properties of a server.  puts up an edit dialog to modify properties
							            // on submit will call register to update the server
							            {
			    		                    id: 'edit',
			    		                    title: 'Edit',
			    		                    text: NLS.get('edit'),
			    		                    icon: 'pencil',
			    		                    handler: function(view){
			    		                    	// check if use alias flag is set and if so display edit form 
			    		                    	// with additional server prop id field
			    		                    	RegisterServer.showDialogAlias(view.model);
			    		                    }
	
							            },
							            {
							            	// setAsdefault will call JS COS API which will call
							            	// EEPServices to set the server as the default server for COS execution
							                text:  NLS.get('setDefault'),
							                icon: 'new-create',
							                handler: function(){
							                	var server = this.model.id;
							                	WSUtils.setDefaultServer(server,
							                		// success function clears the default server badge on all the servers
							                		// and sets it for the new default server
						    		                function(data){
							                    		var treeView = COSInfo.getBones().getViewAt(0);
							                    		if (treeView) {
							        	    		        treeView.treeModel.getRoots().forEach(function (model) {
							        	    		        	COSUtils.clearDefaultBadgeOnNode(model.options.label);
							        	    		        });
							                    		}
			    	     		                    	COSUtils.setDefaultBadgeOnNode(data);
							                	});// end success function and set default call
							                }
							            },
							            // pause the server uses COS API that gets ticket and calls pause webservice
					                    {
						                    id: 'pause',
						                    title: 'Pause',
						                    text: NLS.get('pause'),
						                    icon: 'pause',
						                    actionBar: true,
				     		        	    handler: function(){
				     		        		   var wsUrl = this.model.get('fullCosUrl') ;
				     		        		   WSUtils.pauseServer(
				 		        				  wsUrl, this.model.get('id'),
				 		        				  // success function dispatch on change event so latest status can be gotten
				 		        				  // update status badge on server
			 		        					  function() {
			     	     		                       var view = COSInfo.getBones().getViewAt(1);
			     	     		                       if (view ) {
			     	     		                    	   view.model.dispatchEvent('onChange');
			     	     		                           COSUtils.setBadgesOnNode(view.model.get('id'), 'PAUSED');
			     	     		                       }
				 		        			  });// end success function and pause server call
				     		        	   }
					                },
						            // resume the server uses COS API that gets ticket and calls resume webservice
					                {
					                    id: 'resume',
					                    title: 'Resume',
					                    text: NLS.get('resume'),
					                    icon: 'play',
			     		        	    handler: function(){
			     		        	    	var wsUrl = this.model.get('fullCosUrl') ;
					        				// success function dispatch on change event so latest status can be gotten
					        				// update staus badge on server
			     		        	    	WSUtils.resumeServer(
			 		        	    			wsUrl, this.model.get('id'),
			 		        	    			function() {
			 		        	    				var view = COSInfo.getBones().getViewAt(1);
			 		        	    				if (view ) {
			 		        	    					view.model.dispatchEvent('onChange');
			 		        	    					COSUtils.setBadgesOnNode(view.model.get('id'), 'RUNNING');
			 		        	    				}
			 		        	    			});// end success function and resume server call
			     		        	    }
					                },
							            {
							            	// unregister a server will call JS COS API which will call
							            	// EEPServices to remove the server from the COS Configurations
							                text:  NLS.get('unregister'),
							                icon: 'trash',
							                handler: function(){
							                	var server = this.model.id;
							                	// check if trying to unregister 'global' COS server
							                	// if so(first model in list)...show error
							                	var treeView = COSInfo.getBones().getViewAt(0);
							            		if (server === treeView.collection._models[0].id) {
							   			        	COSUtils.displayError(NLS.get('unregisterErr'), true);
							            		}
							            		else {
								                	WSUtils.unregisterServer(
							                			server,
							                			// success function removes server node and model from collection
							    		                function(){
											        		    var treeView = COSInfo.getBones().getViewAt(0);
											    		        treeView.treeModel.getRoots().forEach(function (model) {
																	if (model.options.label === server){
																		COSInfo.getBones().getViewAt(0).treeModel.removeRoot(model);
																    }
											    		        });
											    		        treeView.collection.forEach(function (model) {
																		if (model.id === server){
																			COSInfo.getBones().getViewAt(0).collection.remove(model);
																	    }
											    		        });
											    		        COSInfo.getBones().slideBack();
							                			});// end success function and unregister call
							            		}
							                }
							            },
						     			{
							                text:  NLS.get('eventLog'),
							                icon: 'newspaper',
							                handler: function(){
							                	GetEventLogDialog.showDialog(
                                                    this.model.id,
                                                    this.model.get('fullCosUrl'),
                                                    this.model.get('deployType')) ;
							                }
						     			}
							   ];
				     		}
						},

						// return the appropriate facets (tabs) based on the selected item
					facets: function () {
						// if the item has GeneralInfor a station or a group
		     		   if (this.get('GeneralInfo')){

		     			   // if a group return group facets
		     			   // need to get multiple properties facets that are now logically grouped
		     			   if (this.get('GeneralInfo')['@drmMode'].endsWith('Grp')){
		            		   return [
			        		           {
			        		        	   // declare Renderer Handler for the station properties to be displayed in a form
			        		        	   name : 'roProperties',
			        		        	   handler : Skeleton.getRendererHandler(StationROPropsView),
			        		        	   text : NLS.get('properties'),
			        		        	   icon : 'attributes'
			        		           },
			        		           {
			        		        	   // declare Renderer Handler for the station general properties to be displayed in a form
			        		        	   name : 'generalProperties',
			        		        	   handler : Skeleton.getRendererHandler(StationGeneralPropsView),
			        		        	   text : NLS.get('generalProperties'),
			        		        	   icon : 'attributes'
			        		           },
			        		           {
			        		        	   // declare Renderer Handler for the station logging properties to be displayed in a form
			        		        	   name : 'LogProperties',
			        		        	   handler : Skeleton.getRendererHandler(StationLoggingPropsView),
			        		        	   text : NLS.get('logProperties'),
			        		        	   icon : 'attributes'
			        		           },
			        		           {
			        		        	   // declare Renderer Handler for the station advanced properties to be displayed in a form
			        		        	   name : 'AdvancedProperties',
			        		        	   handler : Skeleton.getRendererHandler(StationAdvancedPropsView),
			        		        	   text : NLS.get('advancedProperties'),
			        		        	   icon : 'attributes'
			        		           },
			        		           {
			        		        	   // declare Renderer Handler for the station Physics Apps properties to be displayed in a form
			        		        	   name : 'ComputeServices',
			        		        	   handler : Skeleton.getRendererHandler(StationComputePropsView),
			        		        	   text : NLS.get('computeServices'),
			        		        	   icon : 'attributes'
			        		           },
			        		           {
			        		        	   // declare Renderer Handler for the station Result Analutics properties to be displayed in a form
			        		        	   name : 'ResultsServices',
			        		        	   handler : Skeleton.getRendererHandler(StationResultsPropsView),
			        		        	   text : NLS.get('resultsServices'),
			        		        	   icon : 'attributes'
			        		           },
		         			            {
		       				      		// declare Renderer Handler for the station list on the station group
		         			                name : 'Stations',
		         			                handler : Skeleton.getRendererHandler('stationRenderer'),
		         			                text : NLS.get('stations'),
		         			                icon : 'computer-connected'
		         			            },
		       			            {
		           				      		// declare Renderer Handler for the application list on the station group
		       			                name : 'Applications',
		       			                handler : Skeleton.getRendererHandler('applicationRenderer'),
		       			                text : NLS.get('applications'),
		       			                icon : 'app'
		       			            },
		       			            {
		       				      		// declare Renderer Handler for the shared drive list on the station group
		    			                name : 'SharedDrives',
		    			                handler : Skeleton.getRendererHandler('driveRenderer'),
		    			                text : NLS.get('sharedDrives'),
		    			                icon : 'drive'
		    			            }

		            		           ];
		     			   }
		     			   else {
		     				   // else return station facets
		        		   return [
		        		           {
		        		        	   // declare Renderer Handler for the station properties to be displayed in a form
		        		        	   name : 'roProperties',
		        		        	   handler : Skeleton.getRendererHandler(StationROPropsView),
		        		        	   text : NLS.get('properties'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the station general properties to be displayed in a form
		        		        	   name : 'generalProperties',
		        		        	   handler : Skeleton.getRendererHandler(StationGeneralPropsView),
		        		        	   text : NLS.get('generalProperties'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the station logging properties to be displayed in a form
		        		        	   name : 'LogProperties',
		        		        	   handler : Skeleton.getRendererHandler(StationLoggingPropsView),
		        		        	   text : NLS.get('logProperties'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the station advanced properties to be displayed in a form
		        		        	   name : 'AdvancedProperties',
		        		        	   handler : Skeleton.getRendererHandler(StationAdvancedPropsView),
		        		        	   text : NLS.get('advancedProperties'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the station Physics App properties to be displayed in a form
		        		        	   name : 'ComputeServices',
		        		        	   handler : Skeleton.getRendererHandler(StationComputePropsView),
		        		        	   text : NLS.get('computeServices'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the station Result Analytics properties to be displayed in a form
		        		        	   name : 'ResultsServices',
		        		        	   handler : Skeleton.getRendererHandler(StationResultsPropsView),
		        		        	   text : NLS.get('resultsServices'),
		        		        	   icon : 'attributes'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the application list on the station
		        		        	   name : 'Applications',
		        		        	   handler : Skeleton.getRendererHandler('applicationRenderer'),
		        		        	   text : NLS.get('applications'),
		        		        	   icon : 'app'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the shared drive list on the station
		        		        	   name : 'SharedDrives',
		        		        	   handler : Skeleton.getRendererHandler('driveRenderer'),
		        		        	   text : NLS.get('sharedDrives'),
		        		        	   icon : 'drive'
		        		           },
		        		           {
		        		        	   // declare Renderer Handler for the work item list on the station
		        		        	   name : 'Workitems',
		        		        	   handler : Skeleton.getRendererHandler('workItemRenderer'),
		        		        	   text : NLS.get('workItems'),
		        		        	   icon : 'list'
		        		           }

		        		           ];
		     			   }
		    		   }
		     		   // if not station or group return server facets
		     		   // if on cloud only return properties facet since station and members not applicable for cloud
		     		   // if not on cloud check deploy type
		     		   // if deploytype is single just return properties and station list facet
		     		   // otherwise also return members facet
		     		   var onCloud = false;
		     			var depType ;
		     			if (this.model) {
		     				onCloud = this.model.get('onCloud');
		     				depType = this.model.get('deployType');
		     			}
		     			else {
		     				onCloud = this.get('onCloud');				     				
		     				depType = this.get('deployType');
		     			}
		     			if ('true' === onCloud) {
		     				return [
					            {
					      		    // declare Renderer Handler for the server properties to be displayed in a from
					                name : 'Properties',
					                handler : Skeleton.getRendererHandler(ServerPropsView),
					                text : NLS.get('properties'),
					                icon : 'attributes'
					            }

					        ]
		     			}

		     			if (depType.toLocaleLowerCase()==='single') {
							return [
						            {
						      		    // declare Renderer Handler for the server properties to be displayed in a from
						                name : 'Properties',
						                handler : Skeleton.getRendererHandler(ServerPropsView),
						                text : NLS.get('properties'),
						                icon : 'attributes'
						            },
						            {
							      		// declare Renderer Handler for the station list on the server
						                name : 'Stations',
						                handler : Skeleton.getRendererHandler('stationRenderer'),
						                text : NLS.get('stations'),
						                icon : 'computer-connected'
						            }
						    ]
		     				
		     			}
		     			else {
							return [
						            {
						      		    // declare Renderer Handler for the server properties to be displayed in a from
						                name : 'Properties',
						                handler : Skeleton.getRendererHandler(ServerPropsView),
						                text : NLS.get('properties'),
						                icon : 'attributes'
						            },
						            {
							      		// declare Renderer Handler for the station list on the server
						                name : 'Stations',
						                handler : Skeleton.getRendererHandler('stationRenderer'),
						                text : NLS.get('stations'),
						                icon : 'computer-connected'
						            },
						            {
							      		// declare Renderer Handler for the list of cluster members on the server
						                name : 'Members',
						                handler : Skeleton.getRendererHandler('clusterMemberRenderer'),
						                text : NLS.get('memberInfo'),
						                icon : 'computer-server'
						            }
	 					           ];
		     			}
					}
				}
				},

				// renderers for the different facet views
				// stationRenderer renders list of stations on a server or in a group
				// will not expand further so no facets or id-card options defined
		           stationRenderer: {
		        	   collection: StationCollection,
		               view: SetView,
		               detail: {
		            	  title: 'Station List'
		               },
		               viewOptions: {
		            	   events : {
		            		   onFacetUnselect : RendererUtils.facetUnselect

		            	   },
		            	   actions: {
			               		collection: function() {
			               			if (!isOwner) {
				               			var acts = new ActionsCollection([]);
			               				return acts;
			               			}
			               			// if we have general info then this is the station renderer for a group
			               			// only have create stations
			               			if (this.model.get('GeneralInfo')) {
				               			var acts2 = new ActionsCollection([{
						                        id: 'create',
						                        title: NLS.get('createStation'),
						                        icon: 'computer-add',
						                        overflow: false
					               			}, {
						                        id: 'import',
						                        title: NLS.get('import'),
						                        icon: 'import',
						                        overflow: false
						               		}]);
				               				return acts2;
			               			}
			               			// else... this is station renderer for server
			               			// have create for groups and stations
			               			else {
				               			var acts3 = new ActionsCollection([{
						                        id: 'create',
						                        title: NLS.get('createStation'),
						                        icon: 'computer-add',
						                        overflow: false
					               			}, {
						                        id: 'createGroup',
						                        title: NLS.get('createGroup'),
						                        icon: 'computer-group-add',
						                        overflow: false
					               			}, {
						                        id: 'import',
						                        title: NLS.get('import'),
						                        icon: 'import',
						                        overflow: false
					               			}]);
				               				return acts3;
			               			}
			               			},
		                            events: {
		                                onActionClick: function(actionsView,  actionView) {
		                                      var actionId = actionView.model.get('id');
		                                      switch (actionId) {
		                                            case 'delete':
		                                                  break;
		                                            case 'create':
                                        				var onCloud = RendererUtils.onTheCloud();
                                        				if (onCloud) {
                                        					COSUtils.displayError(NLS.get('onCloud'), true);
                                        				}
                                        				else {
                                        					var form3 = StationPropsEditObj.updateFields(
		            	                                	null, false, COSInfo.getBones().getViewAt(1).model.id,
		            	                                	COSInfo.getBones().getViewAt(1).model.get('fullCosUrl'),  false);
		            	                                  	StationPropsEditObj.showDialog(form3, false);
                                        				}
		                                                break;
		                                            case 'createGroup':
                                        				if (RendererUtils.onTheCloud()) {
                                        					COSUtils.displayError(NLS.get('onCloud'), true);
                                        				}
                                        				else {
                                        					var form4 = StationPropsEditObj.updateFields(
		            	                                	null, false, COSInfo.getBones().getViewAt(1).model.id,
		            	                                	COSInfo.getBones().getViewAt(1).model.get('fullCosUrl'), true);
                                        					StationPropsEditObj.showDialog(form4, true);
                                        				}
		            	                                break;
		                                            case 'import':
		                                            	// for import show import dialog with browse button to pick
		                                            	// json file to import.  pass in OK function to process the
		                                            	// file content
                                        				if (RendererUtils.onTheCloud()) {
                                        					COSUtils.displayError(NLS.get('onCloud'), true);
                                        				}
                                        				else {
			                                            	var importPanel =  new StationImportPanel({
			                                        			importOK: function(data){
			                                        				WSUtils.processImport(data,
			                                    						COSInfo.getBones().getViewAt(1).model.id,
			                                    						COSInfo.getBones().getViewAt(1).model.get('fullCosUrl'));
			                                        			}});
			                                            	COSUtils.showDialogPanel(NLS.get('import'), importPanel);
                                        				}
			                                            break;
		                                            default:
		                								  COSUtils.displayInfo(actionId + ' is not permitted.',  true);
		                                                  break;
		                                      }
		                                }
		                          }
		            	   },
		            	   // define multi-selection actions delete,  pause resume
		            	   // pause and resume show up only if stations selected delete will also show for stations and groups
		            	   buildMultiselActions: function(selectedModels) {
		               			if (!isOwner) {
		               				return [];
		               			}
		            		   // only show pause resume for fiper stations
		            		   var bPauseResume = selectedModels.reduce(function(previous,  model) {
		            			   return previous && (model.get('GeneralInfo')['@drmMode'] === 'fiper');
		            		   },  true);

		            		   // only add stations to a group from the server station list not the group station list
		            		   // the server name for a group is in the form of group@@server
		            		   var bAddStations = selectedModels.reduce(function(previous,  model) {
		            			   return previous && (!model.get('serverName').contains('@@'));
		            		   },  true);
		            		   var actions = [];
		            		   // delete is valid for all
		            		   actions.push({
		            			   id: 'delete',
		            			   text: NLS.get('deleteStations'),
		            			   fonticon: 'trash',
		            			   multisel: true,
		            			   handler: function(models) {
		            				   var stations = [];
		            				   var groupsFiper = [];
		            				   var groupsLsf = [];
		            				   var groupsOther =  [];
		            				   // iterate over selected models to get stations,
		            				   // fiper groups,  and lsf groups so then can be
		            				   // deleted by drm type
		            				   models.forEach(function( model){
		            					  if (model.get('GeneralInfo')['@drmMode'].endsWith('Grp')) {
		            						  if (model.get('GeneralInfo')['@drmMode'] === 'fiperGrp') {
		            							  groupsFiper.push(model.get('name'));
		            						  }
		            						  else if (model.get('GeneralInfo')['@drmMode'] === 'LsfGrp') {
		            							  groupsLsf.push(model.get('name'));
		            						  }
		            						  else {
		            							  groupsOther.push(model); 
		            						  }
		            					  }
		            					  else {
		            						  stations.push(model.get('name'));
		            					  }
		            				   });
		     		        		   var stationName =  '';
		     		        		   // if we have stations,  then use JS COS API to delete fiper stations
		     		        		   if (stations.length) {
			     		        		   var first = true;
			            				   stations.forEach(function( stat){
			            					   if (first){
			            						   stationName = stationName + 'stationName=' + stat;
			            						   first = false;
			            					   }
			            					   else {
			            						   stationName = stationName + '&stationName=' + stat;
			            					   }
			            				   });
			            				   WSUtils.deleteStationList(
		            						   models[0].get('fullCosUrl'),
		            						   models[0].get('serverName'),
		            						   stationName, 'fiper',
		            						   // succes function need to handle ui changes to delete tree nodes
		            						   // and remove models from collection
		        							   function(data) {
		        								   var message = data.split('could not');
		        								   var good = message[0];
		        								   var goodStats = good.replace(/ /g, '').split('\n');

		        								   // if could not delete some station display message
		        								   if (message.length > 1) {
		        									   COSUtils.displayError(data, true);
		        								   }
		        								   var view = COSInfo.getBones().getViewAt(1);

		        									for (var i = view.collection._models.length-1 ; i >=0 ; i--) {
		        										var model = view.collection._models[i];
		        									   // if station was deleted remove node and model
		        									   if (goodStats.indexOf(model.get('@name')) >=1) {
		        										   var node = COSUtils.findNode(
		        												   model.get('@name') +'@@' + model.get('serverName') );
		        											// if we have a node in the tree
		        											// need to remove the node and the model from the tree collection
		        											if (node) {
		                										node.remove();
		                										COSUtils.removeTreeModel(model.get('@name') +'@@' +
		                												COSUtils.fixServer(model.get('serverName')) );
		        											}
		        											if (view.collection) {
		        												view.collection.remove(model);
		        											}
		        									   }
		        								   }
		        									// once stations are deleted call method to delete the groups
		        									RendererUtils.groupDeleteByMode('fiperGrp', models[0], groupsFiper, groupsLsf);

		            						   });// end success function and delete station call
		     		        		   }
		     		        		   else if (groupsFiper.length){
		     		        			  RendererUtils.groupDeleteByMode('fiperGrp', models[0], groupsFiper, groupsLsf);
		     		        		   }
		     		        		   else if (groupsLsf.length) {
		     		        			  RendererUtils.groupDeleteByMode('LsfGrp', models[0], groupsLsf, []);
		     		        		   }
		     		        		   else if (groupsOther.length) {
		     		        			  RendererUtils.groupDeleteOther(groupsOther);
		     		        		   }
		            			   }
		            		   });

		            		   actions.push({
		            			   id: 'export',
		            			   text: NLS.get('exportStations'),
		            			   fonticon: 'export',
		            			   multisel: true,
		            			   handler: function(models) {
		            				   var stationData = '[';
		            				   var cnt =0;
		            				   models.forEach(function( model){
		            					   var newMod = model.clone();
		            					   if (cnt >0) {
		            						   stationData = stationData + ', ';
		            					   }

		            					   // remove extra collection model fields
		            					   // used for uwa model/collection support
		            					   delete newMod._attributes.icon;
		            					   delete newMod._attributes.image;
		            					   delete newMod._attributes.useCount;
		            					   delete newMod._attributes.allowedUsers;
		            					   delete newMod._attributes.fullCosUrl;
		            					   delete newMod._attributes.content;
		            					   delete newMod._attributes.drm;
		            					   delete newMod._attributes.group;
		            					   delete newMod._attributes.id;
		            					   delete newMod._attributes.os;
		            					   delete newMod._attributes.name;
		            					   delete newMod._attributes.serverName;
		            					   delete newMod._attributes.status;

		            					   // stringify the model for export to json
		            					   stationData = stationData + JSON.stringify(newMod, null, '\t') + '\n';
		            					   cnt++;
		            				   });
		            				   stationData = stationData + ']';
		        					   COSUtils.download(stationData);
		            			   }
		            		   });

		            		   // if only stations selected...add pause resume actions
		            		   if (bPauseResume) {
			            		   actions.push({
			            			   id: 'pause',
			            			   text: NLS.get('pauseStations'),
			            			   fonticon: 'pause',
			            			   multisel: true,
			            			   handler: function(models) {
			     		        		   var wsUrl = '';
			     		        		   var first = true;
			            				   models.forEach(function( model){
			            					   if (first) {
			            						   wsUrl = wsUrl + 'stationName=' + model.get('name');
			            						   first =false;
			            					   }
			            					   else {
			            						   wsUrl = wsUrl + '&stationName=' + model.get('name');
			            					   }
			            				   });
			            				   WSUtils.suspendStations(
		            						   models[0].get('fullCosUrl'),
		            						   models[0].get('serverName'),  wsUrl,

		            						   // success function update ui with pause status
		 	 		        				   function(data) {
		 		        						 var message = data.split('problem');
		 		        						 var good = message[0];
		        								 var goodStats = good.replace(/ /g, '').split('\n');

		 		        						 // if could not suspend display error message
		 		        						 if (message.length > 1) {
		 		        							COSUtils.displayError(data, true);
		 		        						 }
		 	     		                         var view = COSInfo.getBones().getViewAt(1);
		 	     		                         for (var i = 0 ; i < view.collection._models.length; i++) {
		  	     		                     	    var model = view.collection._models[i];
		 	     		                        	if (goodStats.indexOf(model.get('@name')) >=1) {
		 	     		                        		// if station suspended update list and tree model
		 	     		                        		model.set('@status', 'Suspended', {silent:true});
		 	     		                        		model.set('status', 'Suspended');
		  	     		                                var modelID = model.get('@name') + '@@' + model.get('serverName');
		  	     		                                var treeModel = COSUtils.findModel(0, modelID);
		  	     		                                if (treeModel) {
		  	     		                                	treeModel.set('@status', 'Suspended', {silent:true});
		  	     		                                	treeModel.set('status', 'Suspended');
		  	     		                                }
		 	     		                                COSUtils.setBadgesOnNode(modelID, 'Suspended');
		 	     		                        	}
		 	     		                        	// need to fix selection since check-box and check-mark is removed
		 	     		                        	// when updating the station status
		 	     		                        	COSUtils.fixSelection();
		 	     		                         }
		            						});// end success function and suspend call
			            			   } // end handler
			            		   }); // end pause action and push call
			            		   actions.push({
			            			   id: 'resume',
			            			   text: NLS.get('resumeStations'),
			            			   fonticon: 'play',
			            			   multisel: true,
			            			   handler: function(models) {
			     		        		   var wsUrl = '';
			     		        		   var first = true;
			            				   models.forEach(function( model){
			            					   if (first) {
			            						   wsUrl = wsUrl + 'stationName=' + model.get('name');
			            						   first =false;
			            					   }
			            					   else {
			            						   wsUrl = wsUrl + '&stationName=' + model.get('name');
			            					   }

			            				   });

			            				   WSUtils.resumeStations(
		            						   models[0].get('fullCosUrl'),
		            						   models[0].get('serverName'),  wsUrl,
		            						   // success function update ui with resumed status
		            						   function(data) {
		            							   var message = data.split('problem');
		            							   var good = message[0];
			        							   var goodStats = good.replace(/ /g, '').split('\n');
		            							   // if stations could not be resumed...display error
		            							   if (message.length > 1) {
		            								   COSUtils.displayError(data, true);
		            							   }
		            							   var view = COSInfo.getBones().getViewAt(1);
		            							   for (var i = 0 ; i < view.collection._models.length; i++) {
		            								   var model = view.collection._models[i];
		            								   if (goodStats.indexOf(model.get('@name')) >=1) {
		            									   // if station suspended update tree and list model status
		            									   model.set('@status', 'Running', {silent:true});
		            									   model.set('status', 'Running');
		            									   var modelID = model.get('@name') + '@@' + model.get('serverName');
		     	     		                                var treeModel = COSUtils.findModel(0, modelID);
		      	     		                                if (treeModel) {
		      	     		                                	treeModel.set('@status', 'Running', {silent:true});
		      	     		                                	treeModel.set('status', 'Running');
		      	     		                                }
		            									   COSUtils.setBadgesOnNode(modelID, 'Running');
		            								   }
		            							   }
		            							   // need to fix selection since check-box and check-mark is removed
		            							   // when updating the station status
		            							   COSUtils.fixSelection();
		            					  });// end success function and resume call
			            			   } // end handler
			            		   }); // end resume action and push call
			            		   actions.push({
			            			   id: 'stop',
			            			   text: NLS.get('stopStations'),
			            			   fonticon: 'stop',
			            			   multisel: true,
			            			   handler: function(models) {
			     		        		   var wsUrl = '';
			     		        		   var first = true;
			            				   models.forEach(function( model){
			            					   if (first) {
			            						   wsUrl = wsUrl + 'stationName=' + model.get('name');
			            						   first =false;
			            					   }
			            					   else {
			            						   wsUrl = wsUrl + '&stationName=' + model.get('name');
			            					   }
			            				   });
			     		        		   ConfirmDialog.showDialog(models[0],  NLS.get('stopStations'),  wsUrl,  'stopList');
			            			   }

			            		   }); // end stop action and push call
			            		   actions.push({
			            			   id: 'restart',
			            			   text: NLS.get('startStations'),
			            			   fonticon: 'reload',
			            			   multisel: true,
			            			   handler: function(models) {
			     		        		   var wsUrl = '';
			     		        		   var first = true;
			            				   models.forEach(function( model){
			            					   if (first) {
			            						   wsUrl = wsUrl + 'stationName=' + model.get('name');
			            						   first =false;
			            					   }
			            					   else {
			            						   wsUrl = wsUrl + '&stationName=' + model.get('name');
			            					   }
			            				   });
			     		        		   ConfirmDialog.showDialog(models[0],  NLS.get('startStations'),  wsUrl,  'startList');
			            			   }
			            		   }); // end restart action and push call
			            		   if (bAddStations) {
				            		   actions.push({
				            			   id: 'addStations',
				            			   text: NLS.get('addStationsToGroup'),
				            			   fonticon: 'plus',
				            			   multisel: true,
				            			   handler: function(models) {
				            				   var groupForm = AddStationsDialog.updateFields(
				            					   models,  models[0].get('serverName'),  models[0].get('fullCosUrl'),  'add');
				     		        		   AddStationsDialog.showDialog(groupForm);
				            			   }
				            		   }); // end add station action and push call
			            		   }
			            		   actions.push({
			            			   id: 'removeStations',
			            			   text: NLS.get('removeStationsFromGroup'),
			            			   fonticon: 'minus',
			            			   multisel: true,
			            			   handler: function(models) {
			            				   var groupForm2 = AddStationsDialog.updateFields(
				            					   models,  models[0].get('serverName'),  models[0].get('fullCosUrl'),  'remove');
			            				   AddStationsDialog.processStation(groupForm2);
			            			   }
			            		   }); // end remove station action and push call
		            	   }
		            		   return actions;
		            	   },
		            	   contents: {
		            		   selectionMode: selectionType,
		            		   useInfiniteScroll: false,
		            		   usePullToRefresh: false,
		            		   views: [
		            		           {
		            		        	   id: 'table',
		            		        	   title: NLS.get('tableView'),
		            		        	   view: TableScrollView
		            		           }
		            		    ],
		            		    // column headers for table
		            		    headers: [{
		            		    	property: 'id',
		            		    	label: NLS.get('title')
		            		    }, {
		            		    	property: 'image',
		            		    	label: NLS.get('image'),
		            		    	type: 'image'
		            		    },  {
		            		    	property: 'allowedUsers',
		            		    	label: NLS.get('allowedUsers')
		            		    },  {
		            		    	property: 'group',
		            		    	label: NLS.get('group')
		            		    },  {
		            		    	property: 'os',
		            		    	label: NLS.get('os')
		            		    },  {
		            		    	property: 'drm',
		            		    	label: NLS.get('drmMode')
		            		    },   {
		            		    	property: 'useCount',
		            		    	label: NLS.get('workLoad')
		            		    },  {
		            		    	property: 'status',
		            		    	label: NLS.get('status')
		            		    }]
		            	   }
		               }
		           },

		           // list applications for a station or group
		           applicationRenderer: {
		        	   collection: ApplicationCollection,
		        	   view: SetView,
		               detail: {
		             	  title: 'Application List'
		                },
		                viewOptions : {
		                	events : {
		                		onFacetUnselect : RendererUtils.facetUnselect
		                	},
		                	actions: {
			               		collection: function() {
			               			if (!isOwner) {
				               			var acts4 = new ActionsCollection([]);
			               				return acts4;
			               			}

			               			// if we don't have a group defined allow creation of applications
			               			if (this.model.get('@group') && this.model.get('@group').length > 0) {
				               			var acts5 = new ActionsCollection([]);
			               				return acts5;
			               			}
			               			// else... this is station renderer for server
			               			// have create for groups and stations
			               			else {
				               			var acts6 = new ActionsCollection([{
				                            id: 'create',
				                            title: NLS.get('createApplication'),
				                            icon: 'plus-circled',
				                            overflow: false
					               			}]);
				               				return acts6;
			               			}
			               			},
		                      events: {
		                          onActionClick: function(actionsView,  actionView) {
		                                var actionId = actionView.model.get('id');
		                                if (actionId === 'create') {
    	                                  var form8 = ApplicationPropsObj.updateFields(
    	                                		    COSInfo.getBones().getViewAt(1).model, false, COSInfo.getBones().getViewAt(1).model.id,
            	                                	COSInfo.getBones().getViewAt(1).model.get('fullCosUrl'));
    	                                  ApplicationPropsObj.showDialog(form8);
		                                }
		                                else {
                								  COSUtils.displayInfo(actionId + ' is not permitted.',  true);
		                                }
		                          }
		                    }

		                	},
		                	buildMultiselActions: function() { // will show up delete apps menu when multiselect if not in group
		            	   		var view = COSInfo.getBones().getViewAt(1);
		                		var actions = [];
		               			if (!isOwner) {
		               				return actions;
		               			}

		                		var stationInGroup = false;
		                		if (view && view.model && view.model.get('@group') && view.model.get('@group').length > 0) {
		                			stationInGroup = true;
		                		}
		                		if (view && !stationInGroup) {
			                		actions.push({
			                			id: 'delete',
			                			text: NLS.get('deleteApplications'),
			                			fonticon: 'trash',
			                			multisel: false,
			                			handler: function(models) {
			                				var view = COSInfo.getBones().getViewAt(1);
			                				ApplicationPropsObj.deleteApplications(view, models);
			                			}
			                		});
		                		}
		                		return actions;
		                	},
		                	contents: {
		                		useInfiniteScroll : false,
		                		usePullToRefresh : false,
		                		selectionMode: selectionType,
		                		views: [
		            		        {
		            		        	id: 'table',
		            		        	title: NLS.get('tableView'),
		            		        	view: TableScrollView
		            		        }
		            		        ],
		            		        headers: [{
		            		        	property: 'appName',
		            		        	label: NLS.get('name')
		            		        },  {
		            		        	property: 'version',
		            		        	label: NLS.get('version')
		            		        },  {
		            		        	property: 'path',
		            		        	label: NLS.get('path')
		            		        }
		            		    ]
		                	}
		                }
		           },

		           // list of shared drives for a station or group
		           driveRenderer: {
		        	   collection: DriveCollection,
		        	   view: SetView,
		               detail: {
		              	  title: 'Drive List'
		                 },
		        	   viewOptions : {
		        		   events : {
		        			   onFacetUnselect : RendererUtils.facetUnselect
		        		   },
		               	   actions: {
		               		collection: function() {
		               			if (!isOwner) {
			               			var acts7 = new ActionsCollection([]);
		               				return acts7;
		               			}
		               			// if we don't have a group defined allow creation of applications
		               			if (this.model.get('@group') && this.model.get('@group').length > 0) {
			               			var acts8 = new ActionsCollection([]);
		               				return acts8;
		               			}
		               			// else... this is station renderer for server
		               			// have create for groups and stations
		               			else {
			               			var acts9 = new ActionsCollection([{
			                            id: 'create',
			                            title: NLS.get('createDrive'),
			                            icon: 'plus-circled',
			                            overflow: false
				               			}]);
			               				return acts9;
		               			}
		               			},
		                  events: {
		                      onActionClick: function(actionsView,  actionView) {
		                          var actionId = actionView.model.get('id');
		                          if (actionId === 'create') {
  	                                  var form9 = DrivePropsObj.updateFields(
                            		    COSInfo.getBones().getViewAt(1).model, false, COSInfo.getBones().getViewAt(1).model.id,
  	                                	COSInfo.getBones().getViewAt(1).model.get('fullCosUrl'));
  	                                  DrivePropsObj.showDialog(form9);
		                          }
		                          else {
      								  COSUtils.displayInfo(actionId + ' is not permitted.',  true);
		                          }
		                      }
		                  }
		            	},
		            	buildMultiselActions: function() { // will show up delete drives menu when multiselect if not in group
		            		var view = COSInfo.getBones().getViewAt(1);
		            		var actions = [];
	               			if (!isOwner) {
	               				return actions;
	               			}
		            		var stationInGroup = false;
		            		if (view && view.model && view.model.get('@group') && view.model.get('@group').length > 0) {
		            			stationInGroup = true;
		            		}
		            		if (view && !stationInGroup) {
		            			actions.push({
		            				id: 'delete',
		            				text: NLS.get('deleteDrives'),
		            				fonticon: 'trash',
		            				multisel: false,
		            				handler: function(models) {
		            					var view = COSInfo.getBones().getViewAt(1);
		            					DrivePropsObj.deleteDrives(view, models);
		            				}
		            			});
		            		}
		            		return actions;
		            	},

		            	contents: {
		            		useInfiniteScroll : false,
		            		usePullToRefresh : false,
		            		selectionMode: selectionType,
		               		views: [
		            		        {
		            		        	id: 'table',
		            		        	title: NLS.get('tableView'),
		            		        	view: TableScrollView
		            		        }
		            		        ],
		        			   headers: [{
		        				   property: 'driveName',
		        				   label: NLS.get('name')
		        			   },  {
		        				   property: 'path',
		        				   label: NLS.get('path')
		        			   },  {
		        				   property: 'description',
		        				   label: NLS.get('description')
		        			   }]
		        		   }
		        	   }
		           },

		           // list of work items for a station
		           // no actions are defined for the work item list
		           // if a single work item is selected an open work item command will be available
		           // the facet contains a table of the work item information
		           workItemRenderer: {
		        	   collection: WorkItemCollection,
		        	   view: SetView,
		               detail: {
		              	  title: 'WorkItem List'
		                 },
		        	   viewOptions : {
		            	   events : {
		            		   onFacetUnselect : RendererUtils.facetUnselect
		            	   },
		               	actions: {
		               		collection: function() {
		               			var acts10 = new ActionsCollection([]);
		               			return acts10;
		               		},
		                    events: { }
		            	},
		            	buildMultiselActions: function(selectedModels) { // will show up delete drives menu when multiselect if not in group
		            		var actions = [];
		            		if (selectedModels && selectedModels.length ===1  ) {
		            			if (selectedModels[0].get('simulationId') &&
		            					selectedModels[0].get('simulationId').length > 0) {
				            		actions.push({
				            			id: 'open',
				            			text: NLS.get('openWorkItem'),
				            			fonticon: 'popup',
				            			multisel: false,
				            			handler: function(models) {
				            				// check if admin is launched as transient widget
				            				// if so...do not launch PS since will replace admin widget
				            				var theWid = COSInfo.getWidget();
				            				// transient widgets start with preview
				            				if (theWid && theWid.id.substr(0, 8) === 'preview-') {
				            					var msg = 'To open the work item in Peformance Study,  you must pin the Station Admin app to the dashboard.';
				            					COSUtils.displayError(msg,  true);
				            				}
				            				else {
					            				var simID = models[0].get('simulationId');
					         				    COSUtils.openProcessInPS(simID);
				            				}
				            			}
				            		});
		            			}
		            		}
		            		return actions;
		            	},

		            	contents: {
		            		useInfiniteScroll : false,
		            		usePullToRefresh : false,
		            		selectionMode: 'nullToMany',
		               		views: [
		            		        {
		            		        	id: 'table',
		            		        	title: NLS.get('tableView'),
		            		        	view: TableScrollView
		            		        }
		            		        ],
		        			   headers: [{
		        				   property: 'simulationName',
		        				   label: NLS.get('simulationName')
			        			   },  {
			        				   property: 'jobName',
			        				   label: NLS.get('jobName')
			        			   },  {
			        				   property: 'userName',
			        				   label: NLS.get('userName')
			        			   },  {
			        				   property: 'adapterType',
			        				   label: NLS.get('adapterType')
			        			   },  {
			        				   property: 'adapterPath',
			        				   label: NLS.get('adapterPath')
			        			   },   {
			        				   property: 'duration',
			        				   label: NLS.get('duration')
			        			   }]
		        		   }
		        	   }
		           },
		           // list of cos servers that are member of the clustered server
		           // no actions are defined for the member list
		           // selection is not defined either this is just a view only list
		           clusterMemberRenderer: {
		        	   collection: ClusterMemberCollection,
		        	   view: SetView,
		               detail: {
		              	  title: 'Member Info'
		                 },
		        	   viewOptions : {
		            	   events : {
		            		   onFacetUnselect : RendererUtils.facetUnselect
		            	   },
		               	actions: {
		               		collection: function() {
		               			var acts12 = new ActionsCollection([]);
		               			return acts12;
		               		},
		                    events: { }
		            	},
		            	contents: {
		            		useInfiniteScroll : false,
		            		usePullToRefresh : false,
		               		views: [
		            		        {
		            		        	id: 'table',
		            		        	title: NLS.get('tableView'),
		            		        	view: TableScrollView
		            		        }
		            		        ],
		        			   headers: [{
		        				   property: 'clusterMemberId',
		        				   label: NLS.get('clusterId')
			        			   },  {
			        				   property: 'serverState',
			        				   label: NLS.get('serverState')
			        			   },  {
			        				   property: 'hostName',
			        				   label: NLS.get('hostName')
			        			   },  {
			        				   property: 'startdate',
			        				   label: NLS.get('startDate')
			        			   }]
		        		   }
		        	   }
		           }
		         };
		    	return renderers;
			}
		};
		return RendererUtils;
	});

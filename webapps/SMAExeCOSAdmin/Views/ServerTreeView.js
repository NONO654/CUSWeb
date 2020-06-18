/**
 * Created by XI2 on 7/5/2015.
 */

define('DS/SMAExeCOSAdmin/Views/ServerTreeView',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
     'UWA/Class/View',
     'DS/Tree/Tree',
     'DS/Tree/TreeDocument',
     'DS/Tree/TreeNodeModel',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	 'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
     function (WebappsUtils,    UWA,  View,
         TreeView,  TreeDocument,  TreeNodeModel, COSInfo, WSUtils, COSUtils, NLS) {

         'use strict';

     	// declare tree view
         var treeView = View.extend({
             tagName: 'div',
             className: 'myTreeView',
             render: function () {
                 var me = this;
                 me.treeModel  = new TreeDocument({
                     useAsyncPreExpand: true,
                     shouldBeEditable: function () { return false; },
                     shouldAcceptDrag: function () { return false; },
                     shouldAcceptDrop: function () { return false; }
                 });
                 if (!this._rendered) {
                	 // get the initial servers that are added to the collection
                	 // create a root node in the tree for each server
                     this.listenTo(this.collection,  {
                         onAdd: function (child) {
                             child.collection._models.forEach(function (item) {
             	            	var root = new TreeNodeModel({
             	            		label: item.id,
             	            		icons: [WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/server.png')],
             	            		children: []
             	            	});
             	            	root.fullCosUrl = item.get('fullCosUrl');
             	            	me.treeModel.addRoot(root);
             	            	WSUtils.setServerBadge(root, item.get('fullCosUrl'), item.id, true);
             	            	
             	            	// make web service call to check if server is on the cloud
             	            	// result will be save as attribute on server model
             	            	WSUtils.adminIsOnCloud(item);
             	            	
             	            	// add the custom DRMS (if any) to the server root node
             	            	WSUtils.getDrmList(item,root);
 	           	            	
             	            	WSUtils.getServerDeployType(item,root,false);
 	           	            	
             	            	if (item.get('isDefault')) {
             	            		COSUtils.setDefaultBadgeOnNode(item.id);
             	            	}
                              });
                              me.tree = new TreeView({
                                  treeDocument: me.treeModel,
                                  apiVersion: 2,
                                  height: 'auto'
                              }).inject(this.container);
         	                  me.tree.getManager().onCellClick(function (data) {
        	                     var mgr = me.tree.getManager();
        	                     var row = data.virtualRowID;
        	                     var col = data.virtualColumnID;
        	                     var cellContent = mgr.getCellContent(row, col);
        	                     var modelname = cellContent.options.label;
        	                     if (cellContent.options.serverName){
        	                    	 modelname = modelname + '@@' + cellContent.options.serverName;
        	                     }
        	                     var model = me.collection.get(modelname);
        	                        me.dispatchEvent('onItemViewSelect',  model);
        	                  });
         	                  // new servers will be added when they are registered so can stop listening
                              this.stopListening(this.collection, 'onAdd');
                         }
                     });
                     this._rendered = true;
                 }
                 // method to handle dynamic expansion of the tree
                 me.treeModel.onPreCollapse(function(modelEvent) {
                    var view = COSInfo.getBones().getViewAt(1);
                    if (view) {
                    	modelEvent.target.getAllDescendants().forEach( function (child){
                    		if (child.getLabel() === view.model.get('name')) {
                    			COSInfo.getBones().slideBack();
                    		}
                    	});
                    }
                 });
                 // method to handle dynamic expansion of the tree
                 me.treeModel.onPreExpand(function(modelEvent) {
                	// get the selected model
                	var modelId = modelEvent.target.getLabel();
                	if (modelEvent.target.options && modelEvent.target.options.serverName) {
                		modelId = modelId + '@@' + modelEvent.target.options.serverName;
                	}
                	var selectedModel = me.collection.get(modelId);

                	// if children have been defined then this is a group and the stations were already retrieved
                	if (selectedModel.get('children')) {
	                    modelEvent.target.preExpandDone();
	                    return;
                	}

                	// if this is a server need to make web service call to get the groups
                	// and another one to get the stations
                	var idx = me.collection.indexOf(selectedModel);
     	           	var newUrl = selectedModel.get('fullCosUrl');
     	           	var serverNm = selectedModel.get('id');

     	           	// clean out the current models of the server stations/groups since it will be rebuilt
    		        var nodesToRemove = [];
    		        modelEvent.target.getChildren().forEach(function (child) {
    		        	var childName = child.getLabel();
                    	if (child.options && child.options.serverName) {
                    		childName = childName + '@@' + child.options.serverName;
                    	}
    		        	var childModel = me.collection.get(childName);
    		        	if (childModel) {
	    		        	var childModelChildren = childModel.get('children');
	    		        	nodesToRemove.push(child);
	    		        	if (childModelChildren){
	    		        		childModelChildren.forEach(function (chld) {
	    		        			var chldName = chld['@name'];
	    		        			if (chld.serverName){
	    		        				chldName = chldName + '@@' + chld.serverName;
	    		        			}
	        		        		me.collection.remove(me.collection.get(chldName));
	    		        		});
	    		        	}
	    		        	else {
	    		        		me.collection.remove(childModel);
	    		        	}
    		        	}
    		        });

    		        // remove the tree nodes
    		        modelEvent.target.removeChildren(nodesToRemove);
    		        var groupOfNodes = [];
    				var cnt = 0;
    				// get the groups on the server
    				WSUtils.getAllGroups(newUrl,serverNm,
    					// get all groups succeeded call JS COS API to get stations
    					function(data) {
						var groupData=  data;
						// get the stations for the server
						WSUtils.getAllStations(newUrl,
							// getAllStations succeeded
							// create tree nodes and collection models for group/station data
	    		            function(data) {
	    						var stationData= JSON.parse(data);
	    						// process the lists to get the list of stations and groups with the children
	    						var parsedData = me.processLists(groupData,  stationData);
	    						// process the list to create the tree nodes
								parsedData.forEach(function (item) {
			                		cnt = cnt +1;
			                		item.id = item['@name'] + '@@' + serverNm;
			                		item.name = item['@name'];
			                		item.serverName = serverNm;
			                		item.fullCosUrl = newUrl;
			                		COSUtils.setPropertyMap(item);
			                		var img = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/station.png');
			                		me.collection.add(item, {at : idx + cnt, sort:false });
			                		if (item.children ) {
			                			img = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/group.png');
			                			var childNodes = [];
			                			item.children.forEach(function (grpChild){
	    			                		cnt = cnt +1;
    			                			grpChild.id = grpChild['@name']+ '@@' + serverNm;
    			                			grpChild.name = grpChild['@name'];
    			                			grpChild.serverName = serverNm;
    			                			grpChild.fullCosUrl = newUrl;
    				                		COSUtils.setPropertyMap(grpChild);
    				                		var img2 = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/station.png');
    				                		me.collection.add(grpChild, {at : idx + cnt, sort:false });
    				                		childNodes.push({
    				                            label: grpChild['@name'],
    				                            icons: [img2],
    				                            serverName: serverNm
    				                        });
			                			});
				                        groupOfNodes.push({
				                            label: item['@name'],
				                            icons: [img],
				                            children:childNodes,
				                            serverName: serverNm
				                        });
			                		}
			                		else {
				                        groupOfNodes.push({
				                            label: item['@name'],
				                            icons: [img],
				                            serverName: serverNm
				                        });
			                		}
			                 	});

    		                    modelEvent.target.addChild(groupOfNodes);
             	            	WSUtils.setServerBadge(
             	            			modelEvent.target,
             	            			me.collection.get(modelId).get('fullCosUrl'),
             	            			modelEvent.target.getLabel(), false);
	    		            }
						);
						modelEvent.target.preExpandDone();
		            }, // end get station success function
		            // get stations failed display error and end pre-expand
		            function (jqXHR,  textStatus) {
						var errMsg = NLS.get('getStationsFailed');
                        if (textStatus) {
                        	COSUtils.displayError(errMsg + textStatus, true);
                        }
						else {
							COSUtils.displayError(errMsg + jqXHR.toLocaleString());
						}
		                modelEvent.target.preExpandDone();
		            });// end get station fail function and get station call
	             });// end get group success function and get groups call
                 return this;
             },

          	// process the list of groups and the list of stations gotten from the server
             processLists : function (groupList,  stationList){
          		var dataList = [];
              	//method to add a station that is part of a group to the group's children
                var addToGroup = function (datalist,  item) {
             		var groupname = item['@group'];
             		datalist.forEach(function (grp) {
        				if (grp['@name'] === groupname){
        					grp.children.push(item) ;
        				}
        			});
             	};

          		// if we have groups add the group (with empty children) to the data list
          		// because of how JAXB is retrieved need to special case single item VS. Array of items
     			if (groupList.StationList.Station){
     				if (groupList.StationList.Station.length){
     					groupList.StationList.Station.forEach(function (item) {
     						item.children = [];
     						dataList.push(item);
     					});
     				}
     				else {
     					var item = groupList.StationList.Station;
     					item.children = [];
     					dataList.push(item);
     				}
     			}

     			// add the stations to the data list but if station is part of a group add it to the group's children
     			if (stationList.StationList.Station){
     				if (stationList.StationList.Station.length){
     					stationList.StationList.Station.forEach(function (item) {
     						if (item['@group']){
     							addToGroup(dataList,  item);
     						}
     						else if (item.GeneralInfo['@drmMode'] !== 'Lsf'){
     							dataList.push(item);
     						}
     					});
     				}
     				else {
     					var newItem = stationList.StationList.Station;
     					if (newItem['@group']){
     						addToGroup(dataList,  newItem);
     					}
     					else if (newItem.GeneralInfo['@drmMode'] !== 'Lsf'){
     						dataList.push(newItem);
     					}
     				}
     			}
          		return dataList;
          	},
             show: function () { },

             destroy: function () {
                 this.stopListening();
                 this.tree.destroy();
                 this._parent();
             }
         });

         return treeView;
     }
);



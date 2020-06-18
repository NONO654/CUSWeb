define('DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    ['UWA/Core',
     'DS/WebappsUtils/WebappsUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeJsAPI/CosAPI',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
    /* Contains utility methods to help during web service processing
     */
    function ( UWA,  WebappsUtils,  COSInfo,  COSUtils,  CosAPI,  NLS)
    {

         'use strict';
         var WebServiceUtils = {};
		 var utilServer = '';

         WebServiceUtils = {
        	    // method to set the badge for a server will make a status web service call and then
        	    // call method to get station list and set badges for the stations
        	    // if we need to do it again set the timeout function for 15 minutes to reset badges
        		setServerBadge : function (treeNode,  url,  servername,  doAgain) {
        			var myNode = treeNode;
        			var myUrl = url;
        			var myAgain = doAgain;
        			var myServer = servername;
 	            	//var statusUrl = myUrl + '/admin/status';

        			var done = true;

            		var treeView = COSInfo.getBones().getViewAt(0);
            		if (treeView) {
	    		        treeView.treeModel.getRoots().forEach(function (model) {
							if (model.options.label === servername){
								done = false;
						    }
	    		        });
            		}
            		if (!done) {

            			CosAPI.adminStatusExplicit(myUrl,  {
		                    onComplete: function(data) {
                        		COSUtils.setBadgesOnNode(myServer,  data);
                        		utilServer=myServer;
		     	            	WebServiceUtils.setStationBadge(myUrl);
		     	            	if (myAgain) {
		     	            	    setTimeout(function(){
		     	            	    	WebServiceUtils.setServerBadge(myNode,  myUrl,  myServer,  myAgain);
		     	            		},  60000*15);
		     	            	}
		                    },

		                    onFailure: function () {
                        		COSUtils.setBadgesOnNode(myServer,  'Invalid');
		                    }

            			});
	        		}
        		},

        		// method to call webservice to get station list and set badges on the stations
        		setStationBadge : function (url) {
        			CosAPI.listAllStationsByDrmModeJsonExplicit(url,  'fiper',  {
	                    onComplete: function(data) {
    						var stationData= JSON.parse(data);
	                        if (stationData && stationData.StationList) {
	                        	if (stationData.StationList.Station !== undefined){
	                        		var status = '';
		                            if (stationData.StationList.Station.length !== undefined) {
		                            	stationData.StationList.Station.forEach(function (item) {
		                            		var stationName = item['@name'];
		                            		status = item['@status'];
		                            		COSUtils.setBadgesOnNode(stationName +'@@' + utilServer,  status);
		                            	});
		                            }
		                            else {
	                            		var stationName = stationData.StationList.Station['@name'];
	                            		status = stationData.StationList.Station['@status'];
	                            		COSUtils.setBadgesOnNode(stationName+'@@' + utilServer,  status);
		                            }

	                        	}
	                        }
	                    }
        			});
        		},

        		// the following methods use the JS COS API to EEP and COS web services

        		// make web service call to get status of COS server
        		adminGetStatus: function (url,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.adminStatusExplicit(url,  {
	                    onComplete: function(data) {
	                    	onOk(data);
	                    },

	                    onFailure: function (jqXHR,  textStatus) {
	                        if (textStatus) {
	                        	COSUtils.displayError(textStatus,  false);
							}
							else {
							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
							}
	                        onErr(jqXHR,  textStatus);
	                    }

        			});
        		},

        		// make web service call to set the private station ports of COS server
        		adminSetPortConfig: function (url,  server, ports, onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.setPortconfigExplicit(url, server, ports,  {
	                    onComplete: function(data) {
	                    	onOk(data);
	                    },

	                    onFailure: function (jqXHR,  textStatus) {
	                        if (textStatus) {
	                        	COSUtils.displayError(textStatus,  false);
							}
							else {
							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
							}
	                        onErr(jqXHR,  textStatus);
	                    }

        			});
        		},

        		// make web service call to check if server is running on the cloud
        		adminIsOnCloud: function (item) {
        			var myUrl = item.get('fullCosUrl');
        			var myItem = item;
        			CosAPI.isOnCloudExplicit(myUrl,  {
	                    onComplete: function(data) {
	                    	// on success set the model's onCloud attribute to the data returned
	                    	// a string containing true or false
	                    	myItem.set('onCloud', data);
	                    },

	                    onFailure: function (jqXHR,  textStatus) {
	                        if (textStatus) {
	                        	COSUtils.displayError(textStatus,  false);
							}
							else {
							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
							}
	                        // for any failure (including web service not there
	                        // set onCloud to false and let server do check when
	                        // making future functional calls
	                    	myItem.set('onCloud', 'false');
	                    }

        			});
        		},

        		// make web service call to get latest info for a station
        		stationGetStatus: function (url,  stationName,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.retrieveStatusFullInfoOnStationJsonExplicit(url, stationName,  {
	                    onComplete: function(data) {
	                    	onOk(data);
	                    },

	                    onFailure: function (jqXHR,  textStatus) {
	                        if (textStatus) {
	                        	COSUtils.displayError(textStatus,  false);
							}
							else {
							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
							}
	                        onErr(jqXHR,  textStatus);
	                    }

        			});
        		},

        		// make webservice to EEP to get the COS configurations
        		getCOSConfigs : function (onOk,  onFail) {
        			//make sure COS JS API has initialized
           			var spaceURL = CosAPI.get3DSpaceUrl();
           			// if we have an url get configurations
           			if (spaceURL)  {
	             	    CosAPI.getCosConfigurationsJson({
	                       onComplete: onOk,
	                       onFailure: onFail
	             	   });
           			}
           			// otherwise wait a bit and then get the configurations
           			else {
           				setTimeout(function(){
           					CosAPI.getCosConfigurationsJson({
     	                       onComplete: onOk,
     	                       onFailure: onFail
     	             	     });
           				},  3000);
           			}

        		},

        		// utility method to combine lsf and fiper groups into one array
        		combineList: function(origList,  newList) {
        			if (newList.length){
        				newList.forEach(function (item) {
        					origList.push(item);
        				});
        			}
        			else {
        				origList.push(newList);
        			}
        		},
        		// utility method to get the station groups for the DRMs
        		// keeps calling the method to combine the lists for each of the DRMs
        		// and returns the combined data in the ok callback provided
        		getAGroup : function (drms,idx,groupData,listOfGroups,url,onOk,onFail) {
        			if (drms && drms.length > idx ) {
	        			CosAPI.listAllStationsByDrmModeJsonExplicit(url, drms[idx]+'Grp',{
	    		            onComplete: function(data) {
	    						var fiperGroupData= JSON.parse(data);
	    						if (fiperGroupData && fiperGroupData.StationList && fiperGroupData.StationList.Station) {
	    							WebServiceUtils.combineList(listOfGroups,  fiperGroupData.StationList.Station);
	    						}
	    						idx++;
	    						if (idx < drms.length) {
	    							WebServiceUtils.getAGroup(drms,idx,groupData,listOfGroups,url,onOk,onFail);
	    						}
	    						else {
		    	    				if (listOfGroups.length >= 1) {
		    	    					groupData.StationList.Station = listOfGroups;
		    	    				}
		    	    				onOk( groupData);
	    						}
	    		            },
							onFailure: function (jqXHR,  textStatus){
		                        if (textStatus) {
		                        	COSUtils.displayError(textStatus,  false);
								}
								else {
								    COSUtils.displayError( jqXHR.toLocaleString(),  false);
								}
		                        onFail(jqXHR,  textStatus);
							}
	        				
	        			});   
        			}
        			else {
        				onFail({},'Could not connect to the server.');
        			}
        		},
        		// method to get list of station groups
        		// call API to get groups for all the DRMs
        		// and return them in a single StationList
        		getAllGroups: function (url,  serverName, onOk,  onFail) {
        			var groupData = {};
        			var onErr = onFail?onFail: function () {};
        			groupData.StationList = {};
        			var node = COSUtils.findNode(serverName);
        			var listOfGroups = [];
        			WebServiceUtils.getAGroup(node.serverDrms,0,groupData,listOfGroups,url,onOk,onErr);
        			
        		},

        		// method to get all the fiper stations
        		getAllStations: function(url,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                    CosAPI.listAllStationsByDrmModeJsonExplicit(url,  'fiper',  {
	                      onComplete: function(data) {
	                    	  onOk(data);
	                      },
	                      onFailure: function (jqXHR,  textStatus){
	                    	  if (textStatus) {
	                    		  COSUtils.displayError(textStatus,  false);
	                    	  }
	                    	  else {
	                    		  COSUtils.displayError( jqXHR.toLocaleString(),  false);
	                    	  }
	                    	  onErr(jqXHR,  textStatus);
	                      }
                    });

        		},

        		// update the station data
        		updateStation: function (url,  server,  data,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
               	 	CosAPI.updateStationDataFromAdminExplicit(url,  COSUtils.fixServer(server),  data,  {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  true);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});

        		},

        		// use COS API to start a station on the given server
        		startStation: function (url,  server,  station,  onSuccess,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
      				CosAPI.startStationExplicit(url,  server,  station,  {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  true);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});


        		},

        		// use COS API to restart a list of stations
        		startStations: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.startListOfStationsExplicit(
    					url,  COSUtils.fixServer( server),  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to shutdown a station on the given server
        		shutdownStation: function (url,  server,  station,  onSuccess,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
      				CosAPI.shutdownStationExplicit(url,  server,  station,  {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  true);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});


        		},

        		// use COS API to shutdown a list of stations
        		shutdownStations: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.shutdownListOfStationsExplicit(
    					url,  COSUtils.fixServer( server),  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to register a server with the server data provided
        		registerServer: function(serverInfo,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.registerCosServer(serverInfo,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  false);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to validate the COS Admin license for the app
        		validateLicense: function(license,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.validateLicense(license,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to set a server as the user's default
        		setDefaultServer: function(server,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.setDefaultCosServer(server,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  false);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to unregister a server
        		unregisterServer: function(server,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.unregisterCosServer(server,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  false);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to pause a server
        		pauseServer: function(url,  server,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.pauseCOSServerExplicit(url,  server,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  true);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to resume a server
        		resumeServer: function(url,  server,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
                	CosAPI.resumeCOSServerExplicit(url,  server,
	                {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  false);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
	                });

        		},

        		// use COS API to delete a station
        		deleteStation: function (url,  server,  station,  mode,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.deleteStationByDrmModeExplicit(url,  server,  station,  mode,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},


        		// use COS API to delete a list of stations
        		deleteStationList: function (url,  server,  stationList,  mode,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
    	   			CosAPI.deleteListOfStationsByDrmModeExplicit(url,  COSUtils.fixServer( server),  stationList,  mode,
    	   			{
    	   				onComplete :function(data) {
    	   					onOk(data);
    	   				},
    	   				onFailure: function (jqXHR,  textStatus){
    	   					if (textStatus) {
    	   						COSUtils.displayError(textStatus,  false);
    	   					}
    	   					else {
    	   						COSUtils.displayError( jqXHR.toLocaleString(),  false);
    	   					}
    	   					onErr(jqXHR,  textStatus);
    	   				}
    	   			});
        		},

        		// use COS API to suspend a station
        		suspendStation: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.suspendStationPermanentlyExplicit(
    					url,  server,  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to suspend a list of stations
        		suspendStations: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.suspendListOfStationsPermanentlyExplicit(
    					url,  COSUtils.fixServer( server),  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to resume a station
        		resumeStation: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.resumeStationExplicit(
    					url,  server,  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to resume a list stations
        		resumeStations: function (url,  server,  station,  onOk,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			CosAPI.resumeListOfStationsExplicit(
    					url,  COSUtils.fixServer( server),  station,
    					{
    						onComplete :function(data) {
    							onOk(data);
    						},
    						onFailure: function (jqXHR,  textStatus){
    							if (textStatus) {
    								COSUtils.displayError(textStatus,  true);
    							}
    							else {
    								COSUtils.displayError( jqXHR.toLocaleString(),  true);
    							}
    							onErr(jqXHR,  textStatus);
    						}
    					});
        		},

        		// use COS API to get the workitems for a given station on a given server
        		getWorkItemsOnStation: function (url,  server,  station,  onSuccess,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
      				CosAPI.retrieveWorkitemDetailsRunningOnStationJsonExplicit(url,  server,  station,  {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  false);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});
        		},

        		// use COS API to get the event log on a given server
        		getEventLog: function (url,  server,  onSuccess,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
      				CosAPI.getEventLogAllJsonExplicit(url,  server,  {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});
        		},

        		// use COS API to get the event log on a given server
        		getEventLogAfter: function (url,  server,  afterMillis,  msgFilter,  memberFilter, onSuccess,  onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
      				CosAPI.getClusterMemberEventLogFilterJsonExplicit(url,  server,  afterMillis,  msgFilter, memberFilter, {
               	 		onComplete: function(data) {
               	 			onOk(data);
               	 		},
               	 		onFailure: function (jqXHR,  textStatus){
               	 			if (textStatus) {
               	 				COSUtils.displayError(textStatus,  true);
               	 			}
               	 			else {
               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
               	 			}
               	 			onErr(jqXHR,  textStatus);
               	 		}
               	 	});
        		},

        		// use COS API to get the cluster member info for a clustered server
        		// need server id for ticket
        		getClusterInfo: function(url, server, onSuccess, onFail) {
        			var onErr = onFail?onFail: function () {};
        			var onOk = onSuccess?onSuccess: function () {};
        			CosAPI.getClusterInfoJsonExplicit(url,  server, {
	                    onComplete: function(data) {
	                    	onOk(data);
	                    },

	                    onFailure: function (jqXHR,  textStatus) {
	                        if (textStatus) {
	                        	COSUtils.displayError(textStatus,  false);
							}
							else {
							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
							}
	                        onErr(jqXHR,  textStatus);
	                    }

        			});
        		},

        		// make web service call to get the custom DRMs on the server and set it on the 
        		// server model and root passed in
        		getDrmList: function (item,root) {
        			var myUrl = item.get('fullCosUrl');        			
        			if (item.get('serverDrms').length ===0 ) {
	        			CosAPI.listAllInstalledDRMsJsonExplicit(myUrl,  {
		                    onComplete: function(data) {
		                    	var theDrms = JSON.parse(data);
		                    	var modelDrms=[];
		                    	modelDrms.push('fiper');
		                    	modelDrms.push('Lsf');
		                    	if (theDrms!== undefined && theDrms.Drms !== undefined ){
		                    		if (theDrms.Drms.Drm.length) {
		                    			for (var idx in theDrms.Drms.Drm){
		                    				var aDrm = theDrms.Drms.Drm[idx]["@name"]
		                    				var aDrmLower = theDrms.Drms.Drm[idx]["@name"].toLowerCase();
		                    				if (aDrmLower !== 'fiper'&& aDrm !== 'lsf') {
		                    					modelDrms.push(aDrm);
		                    				}
		                    			}
		                    		}
		                    		else {
	                    				var aDrm1 = theDrms.Drms.Drm["@name"]
	                    				var aDrmLower1 = theDrms.Drms.Drm["@name"].toLowerCase();
	                    				if (aDrmLower1 !== 'fiper'&& aDrm1 !== 'lsf') {
	                    					modelDrms.push(aDrm);
		                    			}
		                    		}
		                    	}
            					item.set('serverDrms',modelDrms);
								root.serverDrms = modelDrms;
		                    },

		                    onFailure: function (jqXHR,  textStatus) {
		                    	if (textStatus) {
		                    		COSUtils.displayError(textStatus,  false);
		                    	}
		                    	else {
		                    		COSUtils.displayError( jqXHR.toLocaleString(),  false);
		                    	}
		                    }
	        			})

        			}
        		},


        		/* web service to get server profile
        		 * this will contain the deploy type which is used 
        		 * to show or hide members facet for server
        		 * it will also contain the server's custom domain private ports
        		 * if the serverUrl changed then need to show or hide member's facet based on deploy type
        		 * or unset the url if the web service fails
        		 */
        		getServerDeployType: function (item,root,changed) {
        			var myUrl = item.get('fullCosUrl'); 
        			var myItem = item;
        			var myRoot = root;
        			
        			// if we don't have the deploy type or the url changed 
        			// need to get the profile which contains deploy type and ports
        			if (item.get('deployType').length ===0 || changed) {
            			CosAPI.getAdminProfileExplicitJson(myUrl,  {
    	                    onComplete: function(data) {
		                    	var profile = JSON.parse(data);
		                    	
		                    	// assume deploy type is single
		                    	// get the deploy type 
		                    	var depType = 'single';
		                    	
		                    	// sanity check that data has correct format
		                    	if (profile &&
		                    			profile.ConnectionProfile &&
		                    			profile.ConnectionProfile.deployType) 
		                    	{
		                    		depType = profile.ConnectionProfile.deployType;
		                    	}
		                    		
            					item.set('deployType',depType);
								root.deployType = depType;
								
								// get the member facet and if we have one show/hide based on deploy type
								var memberFacet = COSInfo.getMemberFacet(myItem.id);
								if (depType === 'single'  &&  memberFacet !==null  && memberFacet !== undefined) {
									memberFacet.hide();
								}
								else if (depType !== 'single'  &&  memberFacet !==null && memberFacet !== undefined) {
									memberFacet.show();
								}

		        				// sanity check to make sure we have the correctly formatted object to get ports
		        				if (profile && profile.ConnectionProfile && profile.ConnectionProfile.PrivateStationConfig &&
		        						profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig &&
		        						profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig.PortNo) {
		        					var ports = '';
		            				// sanity check to make sure ports are an array
		        					// iterate to get all the ports
		        					if (profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig.PortNo.length) {
		        						profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig.PortNo.forEach(function(port) {
		        							if (ports.length > 0) {
		        								ports = ports + ', ';
		        							}
		        							ports = ports + port ;
		        						});
		        					}
		        					else if (profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig.PortNo) {
		        						ports = profile.ConnectionProfile.PrivateStationConfig.LauncherPortConfig.PortNo;
		        					}
		        					item.set('privatePorts',  ports,  true);
		        					root.privatePorts= ports;
		        				}
    	                    },

    	                    onFailure: function (jqXHR,  textStatus) {
    	                        if (textStatus) {
    	                        	COSUtils.displayError(textStatus,  false);
    							}
    							else {
    							    COSUtils.displayError( jqXHR.toLocaleString(),  false);
    							}
    	                        
    	                        // on failure hide member facet and swith facet to properties facet
    	                        // in case we were on the member's facet when doing an edit
    	                        // also clear out the deploy type since could not be retrieved
    							var memberFacet = COSInfo.getMemberFacet(myItem.id);
    							if (memberFacet!==null && memberFacet !== undefined) {
									memberFacet.hide();
									COSInfo.getBones().getActiveIdCard().selectFacet(0);
								}

								myItem.set('deployType','');
								myRoot.deployType = '';


    	                    }

            			});
        			}
        		},



        		// use COS API to get job details which will include the related simulation id and name
        		// if jobOIDs are not passed in just return empty data
        		// if an error occurs also return empty data since we still want to process the workitem data
        		// we will just skip the simulation data if there is a problem
        		getJobDetails: function (jobid,  onSuccess) {
        			var onOk = onSuccess?onSuccess: function () {};
        			if (jobid.length ===0) {
        				onOk('');
        			}
        			else {
	      				CosAPI.getJobDetailsJson(jobid,  {
	               	 		onComplete: function(data) {
	               	 			onOk(data);
	               	 		},
	               	 		onFailure: function (jqXHR,  textStatus){
	               	 			if (textStatus) {
	               	 				COSUtils.displayError(textStatus,  false);
	               	 			}
	               	 			else {
	               	 				COSUtils.displayError( jqXHR.toLocaleString(),  false);
	               	 			}
	               	 			onOk('');
	               	 		}
	               	 	});
        			}
        		},

        		// utility method to import the content of a file as a station or station group
        		// it will parse the content string data into a JSON object and then get the
        		// xml for the station and make an update station web service call to create
        		// the station data in the COS database
        		// it is passed in the file content string data,  the server and url for the cos database
	            processImport: function(data,  server,  url) {

	            	// create the station list json object
	            	var stationData = JSON.parse(data);
	            	var StationListXml = '<?xml version="1.0" encoding="utf-8"?>' + '<StationList>' ;

	            	// iterate over the list object to get the xml for each station/group
	    			for (var i = 0 ; i < stationData.length; i++) {
	    				var station = stationData[i];

	    				// do some basic error checking on the station
	          	   		COSUtils.validateStation(station,  server);

	          	   		// get the station xml and add to the xml list
	                	var stationXml = COSUtils.getStationXml(station,  '',  '',  'import');
	               		StationListXml +=stationXml;
	    			}
	    			StationListXml += '</StationList>';

	    			// make the web service call to update the COS database with the station xml
	    			// upon success collapse the tree so the model is refreshed from the updated
	    			// COS database when expanded
	            	this.updateStation(url,  server,  StationListXml,
	            			function(){
			        		var node = COSUtils.findNode(COSUtils.fixServer(COSInfo.getBones().getViewAt(1).model.id));
			        		if (node) {
			        			node.collapseAll();
			        		}
			        		COSInfo.getBones().slideBack();
				   			COSUtils.displayInfo(NLS.get('stationImported'),  true);
	           		});
	            },
	            addSecurityContext : function (onSuccess) {
        			//make sure COS JS API has initialized
           			var spaceURL = CosAPI.get3DSpaceUrl();
           			// if we have an url get configurations
           			if (spaceURL)  {
           				CosAPI.addSecurityContextPreference(onSuccess);
           			}
           			else {
           				setTimeout(function(){
               				CosAPI.addSecurityContextPreference(onSuccess);
           				},  3000);
           			}
	            },
	            getSecurityContext : function () {
	            	return CosAPI.getSecurityContext();
	            }
         };
        return WebServiceUtils;
});

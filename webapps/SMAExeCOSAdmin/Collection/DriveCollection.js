/*
* Collection for shared drives the url is the url for the station
* it will get the shared drive data from the SharedFs list that is returned as part of the station info
*/
define('DS/SMAExeCOSAdmin/Collection/DriveCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Collection',
    'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/Model/DriveModel',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/WebappsUtils/WebappsUtils'

], function (UWA, Collection, Promise, DriveModel, WSUtils, WebappsUtils) {
    'use strict';
    return Collection.extend({
        model : DriveModel,
        setup: function (models, options) {
        	// save the COS url and the station/group name
        	this.fullCosUrl = options._modelKey.get('fullCosUrl');
        	this.stationName = options._modelKey.get('@name');
        	// save the server name so it can be used to get drm information
        	// in order to get the custom drm groups
        	this.serverName = options._modelKey.get('id');
			var splitNode = this.serverName.split('@@');
			if (splitNode.length > 1){
				this.serverName = splitNode[1];
			}
			// if we have a third item in the array we are dealing with a station in a group on a server
			// the server will be the third item in the array
			if (splitNode.length > 2){
				this.serverName = splitNode[2];
			}
       },
        // method to get both stations and groups using asynchronous promise
        getStationCollection: function(){
    	   var that = this;
    	   var myResolve = {};
    	   var myReject = {};
	       return new Promise(
               function(resolve, reject){
            	   myResolve = resolve;
            	   myReject = reject;

            	   // use JS COS API to get the drm groups as single list
            	   WSUtils.getAllGroups(
    					that.fullCosUrl,that.serverName,
    			   // on success save group data and get station data
                   function(data){
                       that.url1Data = data;
                       WSUtils.getAllStations(that.fullCosUrl, myResolve, myReject);
                   },
                   // on fail call reject function
                   reject
				);
               }
	       );
        },
        sync : function(method, model, options) {
            // The getStationCollection function returns a
            // promise that when resolved calls the parse function
            // only when all the data requests are resolved.
            this.getStationCollection().then(
                   options.onComplete, // this runs for promise resolve and calls the parse method
                   options.onFailure // this runs for promise reject
            );
        },
        parse: function (data) {
            var driveArray = [];
            var stationData= JSON.parse(data);
            var myStation = null;
            var grpData= this.url1Data;

            // process the station data to see if we have a station
            if (stationData.StationList.Station !== undefined){
                if (stationData.StationList.Station.length !== undefined) {
                	for (var idx = 0; idx < stationData.StationList.Station.length; idx++) {
                		var item = stationData.StationList.Station[idx];
                		if (item['@name']===this.stationName) {
                			myStation=item;
                		}
                	}
                }
                else {
                	if (stationData.StationList.Station['@name']===this.stationName) {
            			myStation=stationData.StationList.Station;
            		}
                }
            }

            // if we didn't find a station check if we have a group
        	if (myStation===null){
                if (grpData && grpData.StationList.Station !== undefined){
                    if (grpData.StationList.Station.length !== undefined) {
                    	for (var indx = 0; indx < grpData.StationList.Station.length; indx++) {
                    		var item2 = grpData.StationList.Station[indx];
                    		if (item2['@name']===this.stationName) {
                    			myStation=item2;
                    		}
                    	}
                    }
                    else {
                    	if (grpData.StationList.Station['@name']===this.stationName) {
                			myStation=grpData.StationList.Station;
                		}
                    }
                }

        	}
            // if we found the station or group...parse the data for the applications (if any)
        	if (myStation){
        		if (myStation.SharedFSList){
        			if (myStation.SharedFSList.SharedFS.length){
        				myStation.SharedFSList.SharedFS.forEach(function (item) {
        					driveArray.push(item);
                    	});
        			}
        			else {
        				driveArray.push(myStation.SharedFSList.SharedFS);
        			}
        		}
        	}

        	driveArray.forEach(function (item) {
        		item.content = item['@Name'];
        		item.name = item['@Name'];
        		item.driveName = item['@Name'];
        		item.image = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/iconActionCompare.png');
        		item.icon = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/iconActionCompare.png');
        		item.description = item['@description'];
        		item.path = item['@Path'];
        		item.id = item.name;
        	});
    		return driveArray;
        }
    });
});

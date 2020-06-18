/*
* Collection for stations for server or group for a server it will get the station list and the list of station groups
*/
define('DS/SMAExeCOSAdmin/Collection/StationCollection', [
    'UWA/Class/Model',
    'UWA/Class/Collection',
	'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/Model/StationModel',
	'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/WebappsUtils/WebappsUtils'
], function ( Model, Collection, Promise, StationModel, COSUtils, WSUtils, WebappsUtils) {
    'use strict';

    return Collection.extend({
        model : StationModel,
        cosUrl:'',
        setup: function (models, options) {
        	this.fullCosUrl = options._modelKey.get('fullCosUrl');
        	this.serverName = options._modelKey.get('id');
        	// save the server name so it can be used to get drm information
        	// in order to get the custom drm groups
			var splitNode = this.serverName.split('@@');
			if (splitNode.length > 1){
				this.serverName = splitNode[1];
			}
			// if we have a third item in the array we are dealing with a station in a group on a server
			// the server will be the third item in the array
			if (splitNode.length > 2){
				this.serverName = splitNode[2];
			}

        	// get the COS url to get the stations on the server
            this.url = this.fullCosUrl + '/admin/station/query';
            this.groupName = '';
            if (options._modelKey.get('GeneralInfo')) {
            	this.groupName = options._modelKey.get('@name');
            }
        },

        // utility method to process stations that are part of the group
        processGroup: function (groupName, listOfStations, stationArray){
            if (listOfStations !== undefined){
                if (listOfStations.length !== undefined) {
                	listOfStations.forEach(function (item) {
                		if (item['@group'] === groupName){
                			stationArray.push(item);
                		}
                	});
                }
                else {
            		if (listOfStations['@name'] === groupName){
            			stationArray.push(listOfStations);
            		}
                }
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

            	   // use JS COS API to get the fiper and lsf groups as single list
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

        sync: function(method, model, options) {

            // The getStationCollection function returns a
            // promise that when resolved calls the parse function
            // only when all the data requests are resolved.
            this.getStationCollection().then(
                   options.onComplete, // this runs for promise resolve and calls the parse method
                   options.onFailure // this runs for promise reject
            );

        },

        // parse will organize the data to list the groups and stations in the group
        // and then list the remaining stations
        parse: function (data) {
     	   var that = this;
        	COSUtils.displayInfo(data, false);
            var stationArray = [];
            var theGroup = this.groupName;
            var myCosUrl = this.fullCosUrl;
            var myServerName = this.serverName;
            var stationData= JSON.parse(data);
            var grpData= this.url1Data;


            // iterate to find stations groups and stations in the group
            if (grpData.StationList.Station !== undefined){
                if (grpData.StationList.Station.length !== undefined) {
                	grpData.StationList.Station.forEach(function (item) {
                		stationArray.push(item);
                		that.processGroup(item['@name'], stationData.StationList.Station, stationArray);
                	});
                }
                else {
            		stationArray.push(grpData.StationList.Station);
            		that.processGroup(grpData.StationList.Station['@name'], stationData.StationList.Station, stationArray);
                }
            }

            // iterate over station to find all station not in a group and add them
            if (stationData.StationList.Station !== undefined){
                if (stationData.StationList.Station.length !== undefined) {
                	stationData.StationList.Station.forEach(function (item) {
                		if (item['@group'] === undefined || item['@group'].length === 0 ) {
                			stationArray.push(item);
                		}
                	});
                }
                else {
                	var item = stationData.StationList.Station;
            		if (item['@group'] === undefined || item['@group'].length === 0 ) {
            			stationArray.push(item);
            		}
                }
            }

    		var groupStationArray =[];
        	stationArray.forEach(function (item) {
        		item.content = item['@name'];
        		item.id = item['@name'];
        		item.name = item['@name'];
        		item.fullCosUrl = myCosUrl;
        		item.serverName = myServerName;

        		item.drm = item.GeneralInfo['@drmMode'];
        		if (item.drm.endsWith('Grp')) {
            		item.image = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/group.png');
            		item.icon = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/group.png');
        			item['@status']='';
        		}
        		else {
	        		item.image = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/station.png');
	        		item.icon = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/station.png');
        		}
        		item.allowedUsers = item.GeneralInfo['@allowedUsers'];
        		item.group = item['@group'];
        		item.status = item['@status'];
        		item.os = item.GeneralInfo['@os'];
        		item.os = item.GeneralInfo['@os'];
        		item.useCount = item.GeneralInfo['@useCount'];

        		// Call utility method to generate map for station properties
        		//  makes it easier to manipulate
        		COSUtils.setPropertyMap(item);

        	});
        	if (theGroup){
            	stationArray.forEach(function (item) {
             		if (item['@group'] === theGroup) {
             			groupStationArray.push(item);
             		}
            	});
        		return groupStationArray;
        	}
        	return stationArray;
        }
    });
});

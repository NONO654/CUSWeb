/*
* Collection with presetted URL (used as the Root renderer collection)
*/
define('DS/SMAExeCOSAdmin/Collection/WorkItemCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/Model/WorkItemModel',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils'

], function (UWA, Model, Collection, Promise, WorkItemModel, COSInfo, WSUtils) {
    'use strict';
    return Collection.extend({
        model : WorkItemModel,
        setup: function (models, options) {
        	this.cosUrl = options._modelKey.get('fullCosUrl');
        	this.stationName = options._modelKey.get('@name');
            this.url = '';
            var modelId = options._modelKey.get('id');
            var splitServer = modelId.split('@@');
            if (splitServer.length >1) {
            	this.serverName = splitServer[1];
            }
            else {
            	this.serverName = splitServer[0];
            }
        },

        // function adds simulation data for the given job
        addSimInfo: function (jobId, simId, simName) {
        	for (var idx = 0; idx < this.wiArray.length; idx++) {
        		var item = this.wiArray[idx];
        		if (item.jobOID === jobId){
        			item.simulationId = simId;
        			item.simulationName = simName;
        		}
        	}
        },

        // function adds workitem data retrieved from COS
        processItem: function (item,idx ) {
    		item.adapterPath = item['@adapterPath'];
    		item.adapterType = item['@adapterType'];
    		var diff = item['@duration'];

    		// calculate duration as HH:MM:SS:MILLI
    		var hours = Math.floor(diff/1000/60/60);
    		var minutes  = Math.floor((diff - (hours * 1000*60*60))/1000/60);
    		var seconds  = Math.floor((diff - (hours * 1000*60*60) - (minutes * 1000 * 60))/1000);
    		var milliseconds  = Math.floor(diff - (hours * 1000*60*60) - (minutes * 1000 * 60) - (seconds*1000));
    		item.duration = hours +':' + minutes + ':' + seconds + ':' + milliseconds;
    		item.userName = item['@userName'];
    		item.jobName = item['@jobName'];
    		item.id = item['@jobOID']+'.' +idx;
    		item.jobOID = item['@jobOID'];
    		return item;
        },

        // method uses the promise concept to get the work item list
        // it processes the work items to build a comma separated list of job ids
        // it then calls into the MCS to get the job details for each of the jobs
        getWorkItemCollection: function(){
     	   var that = this;
     	   var myResolve = {};
     	   var myReject = {};
 	       return new Promise(
                function(resolve, reject){
             	   myResolve = resolve;
             	   myReject = reject;

             	   // use JS COS API to get the work item list
             	   WSUtils.getWorkItemsOnStation(that.cosUrl, that.serverName, that.stationName,
     			   // on success parse the workitem list to get the job ids
                    function(data){
             		    that.wiArray = [];
                        var wiData= JSON.parse(data);
                        var jobIds = '';

                        // process the station data to see if we have a station
                        if (wiData.WorkItemList.WorkItem !== undefined){
                            if (wiData.WorkItemList.WorkItem.length !== undefined) {
                            	for (var idx = 0; idx < wiData.WorkItemList.WorkItem.length; idx++) {
                            		var item2 = that.processItem(wiData.WorkItemList.WorkItem[idx],idx+1);
                            		that.wiArray.push(item2);
                            		if (jobIds.length > 0) {
                            			jobIds = jobIds + ',';
                            		}
                            		jobIds = jobIds + item2.jobOID;
                            	}
                            }
                            else {
                        		var item3 = that.processItem(wiData.WorkItemList.WorkItem,1);
                        		that.wiArray.push(item3);
                        		jobIds=item3.jobOID;
                            }
                        }
                        WSUtils.getJobDetails(jobIds, myResolve, myReject);
                    },
                    // on fail call reject function
                    reject
 				);
                }
 	       );
         },

        sync : function(method, model, options) {
            // The getWorkItemCollection function returns a
            // promise that when resolved calls the parse function
            // only when all the data requests are resolved.
            this.getWorkItemCollection().then(
                   options.onComplete, // this runs for promise resolve and calls the parse method
                   options.onFailure // this runs for promise reject
            );
        },

        // the parse function is called after getting the job details for the work items
        // if no data is returned or the web service call failed
        // just return the work item data
        // otherwise add in the simulation data for each of the jobs
        parse: function (data) {
        	if (data && data.length > 0) {
	        	var jobDetails = JSON.parse(data);
	        	// if we got back job detail data which contains simulation info add it to the item
	        	if (jobDetails && jobDetails.length > 0) {
	            	for (var idx = 0; idx < jobDetails.length; idx++) {
	            		var simId = jobDetails[idx].physicalid;
	            		var simName = jobDetails[idx].SimulationName;
	            		var jobId = jobDetails[idx].JobOID;
	            		this.addSimInfo(jobId, simId, simName);
	            	}
	        	}
        	}
        	
        	// update the useCount in the model based on number of work items returned
        	var view1 = COSInfo.getBones().getViewAt(1);
        	if (view1 && view1.model) {
        		view1.model.set('useCount',this.wiArray.length);
        		view1.model._attributes.GeneralInfo['@useCount']=this.wiArray.length;
        		view1.model.dispatchEvent('onChange');
        	}
            return this.wiArray;
        }
    });
});

/*
* Collection for events.
* Uses COS JS API to make web service call that gets the event log for a server
*/
define('DS/SMAExeCOSAdmin/Collection/EventCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/Model/EventModel',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/WebappsUtils/WebappsUtils'
], function (UWA, Model, Collection, Promise, EventModel, WSUtils, WebappsUtils) {
    'use strict';
    return Collection.extend({
        model : EventModel,
        setup: function (models, options) {
        	this.cosUrl = options._modelKey.get('fullCosUrl');
        	this.serverName = options._modelKey.get('id');
            this.url = '';
        },

        // method uses the promise concept to get the event log for the given server
        getEventCollection: function(){
      	   var that = this;
 	       return new Promise(
                function(resolve, reject){
             	   // use JS COS API to get the event log
             	   WSUtils.getEventLog(that.cosUrl, that.serverName, resolve, reject);
                }
 	       );
         },

        sync : function(method, model, options) {
            // The getEventCollection function returns a
            // promise that when resolved calls the parse function
            // only when  the data request is resolved.
            this.getEventCollection().then(
                   options.onComplete, // this runs for promise resolve and calls the parse method
                   options.onFailure // this runs for promise reject
            );
        },

        // process the item fields add bug image for events having exception
        processItem: function (item, idx ) {
    		item.source = item.class;
    		if (item.method) {
    			item.source = item.class + ':' + item.method;
    		}
    		item.id = 'eventLog.' + idx;
    		if (item.exception) {
        		item.image = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin', 'images/errorLog.png');
    		}
    		return item;
        },
        // the parse function is called after getting the event log
        // process each event.  if the event has an exception add the bug icon
        // in order to know which rows can be selected to open a trace
        parse: function (data) {
            var eventArray = [];
            var eventData= JSON.parse(data);
            if (eventData && eventData.log && eventData.log.record){
                if (eventData.log.record.length !== undefined) {
                	for (var idx = 0; idx < eventData.log.record.length; idx++) {
                		var item2 = this.processItem(eventData.log.record[idx], idx);
                		eventArray.push(item2);
                	}
                }
                else {
            		var item3 = this.processItem(eventData.log.record, 1);
            		eventArray.push(item3);
                }
            }
            return eventArray;

        }
    });
});

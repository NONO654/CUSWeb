/*
* Collection for server/station tree use JS COS API to get the server configurations (used as the Root renderer collection)
*/
define('DS/SMAExeCOSAdmin/Collection/ServerStationCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Collection',
    'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
    'DS/SMAExeCOSAdmin/Model/ServerStationModel'

], function (UWA, Collection, Promise, COSInfo, WSUtils, COSUtils, ServerStationModel) {
    'use strict';
    return Collection.extend({
        model : ServerStationModel,
        setup: function () {
        	this.url = '';
        },

        // method to get COS Configurations using asynchronous promise
        getConfigurations: function(){
 	       return new Promise(
               function(resolve, reject){
            	   // Call JS COS API to get configurations
            	   WSUtils.getCOSConfigs(resolve, reject);
               });
        },

        sync : function(method, model, options) {
        	this.getConfigurations().then(
                    options.onComplete, // this runs for promise resolve and calls the parse method
                    options.onFailure // this runs for promise reject
             );
        },
        parse: function (data) {
            var configData= JSON.parse(data);
        	if (configData.COSConfiguration){
        		return configData.COSConfiguration;
        	}
        	else if (configData.configurations) {
        		return configData.configurations;
        	}
        	else if (configData.length){
        		return configData;
        	}
        	else {
        		COSUtils.displayError( "There is a problem with the format of the COS Configuration data",  false);
        	}
        }
    });
});

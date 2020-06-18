/*
* Collection for server/station tree use JS COS API to get the server configurations (used as the Root renderer collection)
*/
define('DS/SMAExeCOSAdmin/Collection/ClusterMemberCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Collection',
    'UWA/Class/Promise',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/SMAExeCOSAdmin/Model/ClusterMemberModel'

], function (UWA, Collection, Promise, WSUtils, ClusterMemberModel) {
    'use strict';
    return Collection.extend({
        model : ClusterMemberModel,
        setup: function (models, options) {
        	this.fullCosUrl = options._modelKey.get('fullCosUrl');
        	this.serverName = options._modelKey.get('id');

        	// get the COS url to get the stations on the server
            this.url = this.fullCosUrl + '/admin/clusterInfo';
        },

        // method to get COS Configurations using asynchronous promise
        getClusterInfo: function(){
        	var that = this;
 	       return new Promise(
               function(resolve, reject){
            	   // Call JS COS API to get configurations
            	   WSUtils.getClusterInfo(that.fullCosUrl, that.serverName, resolve, reject);
               });
        },

        sync : function(method, model, options) {
        	this.getClusterInfo().then(
                    options.onComplete, // this runs for promise resolve and calls the parse method
                    options.onFailure // this runs for promise reject
             );
        },
        parse: function (data) {
            var clusterData= JSON.parse(data);
        	if (clusterData.Members && clusterData.Members.member ){
        		return clusterData.Members.member;
        	}
        	return [];
        }
    });
});

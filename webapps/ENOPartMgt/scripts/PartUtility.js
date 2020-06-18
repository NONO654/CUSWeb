/**
 * @overview Define the 3DSpace widget.
 * @licence Copyright 2006-2014 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/PartUtility', [
    'UWA/Core',
    'DS/UIKIT/Alert',
    'DS/WAFData/WAFData',
    'UWA/Class/Promise',
    'DS/PlatformAPI/PlatformAPI',
    'DS/ENOPartMgt/scripts/TempPlatformServices',
    'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'
], function(
    UWACore,
    Alert,
    WAFData,
    Promise,
    PlatformAPI,
    PlatformServices,
    ENGNLS
) {
'use strict';
    var PartUtility = {
    		
    	collectionToFilter : null, 
         retrieveSecurityContext: function(){
 			var that = this;
 			var returnedPromise= new Promise(function (resolve, reject) {
 				WAFData.authenticatedRequest(PlatformServices.get3DSpaceURL() + '/resources/pno/person/getsecuritycontext', {
 					method: 'GET',
 					type: 'json',
 					headers : {
 						Accept: 'application/json',
 						'Content-Type': 'application/json'
 					},
 					onComplete:function(resp){
 						that._securityContext = resp.SecurityContext;
 						resolve(resp);
 					},
 					onFailure : reject,
 					onTimeout: reject
 				});
 			});
 			return returnedPromise;
 		},
 		
 		filterSummaryCollection: function (filterTagObj) {
            var filteredArrayIds = filterTagObj.filteredSubjectList;
            var bones = enoviaServerENGPartWidget.mySkeleton;
            var myCollection = bones.getCollectionAt(0);
            if (myCollection === null) return;
            if (PartUtility.collectionToFilter === null) {
                var myCollectionArr = myCollection.toArray();
                PartUtility.collectionToFilter = new UWA.Class.Collection(myCollectionArr);
            }
            if (myCollection.length != PartUtility.collectionToFilter.length) {
                myCollection.reset();
                var myCollectionArr = PartUtility.collectionToFilter.toArray();
                myCollection.add(myCollectionArr);
            }
            var filderedModels = PartUtility.filterbasedonIds(filteredArrayIds, PartUtility.collectionToFilter);
           
            var modelsToRemove = PartUtility.collectionToFilter.without(filderedModels);
            myCollection.remove(modelsToRemove);
        },
        
        filterbasedonIds: function (filteredArrayIds, collectionToFilter) {
            var filteredArr = [];
            var myCollection = null;
            for (var idx = 0; idx < filteredArrayIds.length; idx++) {
                var modelID = filteredArrayIds[idx];

                var memberModel = collectionToFilter.findWhere({ id: modelID });
                if (memberModel) filteredArr.push(memberModel);
            }
            return filteredArr;
        },
		
         activateSummaryViewTaggerProxies: function () {
             var bones = enoviaServerENGPartWidget.mySkeleton;
             if (bones) {
                 var caCollection = bones.getCollectionAt(0);
                 if (caCollection === null) return;
                 caCollection.activateTaggerProxy();
             }
         },
         
         deactivateSummaryViewTaggerProxies: function () {
 			var bones = enoviaServerENGPartWidget.mySkeleton;
 			var collection = bones.getCollectionAt(0);
 			if (collection === null || collection === undefined) return;
 			collection.deactivateTaggerProxy();
         },

         refreshTaggerProxies: function () {
        	 PartUtility.activateSummaryViewTaggerProxies();
             var bones = enoviaServerENGPartWidget.mySkeleton;
             if (bones) {
            	 var caCollection = bones.getCollectionAt(0);
         		if (caCollection != null || caCollection != undefined) return;
                 caCollection.taggerProxy.die();
             }
             widget.dispatchEvent('onLoad');
         },

         getUserInfo: function () {
             return PlatformAPI.getUser();
         },
         
         updateWidgetTitle : function (model,initialTitle) {
             var index, 
             title = (initialTitle!=undefined)?initialTitle:ENGNLS.ENG_Part_List;
                   
             if (UWA.is(model)) {
                 title = widget.title;
             }   
             return widget.setTitle(title);
         }
    };

    return PartUtility;
});

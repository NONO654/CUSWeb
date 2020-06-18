function openResultAnalytics(caseId){
	require([
		'DS/WAFData/WAFData',
		'DS/i3DXCompassServices/i3DXCompassPubSub'
		], function (WAFData, i3DXCompassPubSub) {
		var _3dspaceURL = getTopWindow().myAppsURL;
		if(!_3dspaceURL){
			_3dspaceURL = getTopWindow().opener.window.getTopWindow().myAppsURL;
		}
		var requestURL = _3dspaceURL+'/resources/AppsMngt/environment/list';
		WAFData.authenticatedRequest(requestURL,
		{
			'type' : 'json',
			'method': 'GET',
			'onComplete': function(t) {
				var dashboardURL = t.environments[0].dashboard;
				var urlToOpen = dashboardURL+'#app:SIMREII_AP';
				i3DXCompassPubSub.publish("resetObject");
                i3DXCompassPubSub.publish("resetX3DContent");
				if(caseId){
					urlToOpen+='/content:caseID='+caseId;
					window.top.location.href =urlToOpen; 					
				}else{
					window.open(urlToOpen,'_blank');
				}				
			},
			'onFailure': function(error){
				console.log(error);
			}
		});		
    }, function (error) {
    	console.log('Error '+error);
    });
}

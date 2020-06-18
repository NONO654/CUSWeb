define('DS/ENOPartMgt/scripts/TempPlatformServices',
		['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
          'UWA/Core'], 
    function(i3DXCompassPlatformServices,UWACore){
	'use strict';
	var platformServices = {};
	var ENOPlatformServices = {
        	initializePlatformServicesIdentifiers: function(onCompleteCallback){
        		i3DXCompassPlatformServices.getPlatformServices({
                    onComplete: function (data) {
                    	//Need to verify if we would be getting multiple platform values here
                    		platformServices = data[0];
                    		onCompleteCallback();
                    }
                  });
        	},
        	getPlatformServiceURL: function(service){
        		var serviceURL = "";
        		if(UWACore.owns(platformServices,service)){
        			serviceURL = platformServices[service];
        		}
        		return serviceURL;
        	},
        	get3DSpaceURL: function(){
        		return this.getPlatformServiceURL('3DSpace');
        	}
	};
	return ENOPlatformServices;
});

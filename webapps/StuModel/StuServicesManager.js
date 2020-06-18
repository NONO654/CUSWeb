
define('DS/StuModel/StuServicesManager', ['DS/StuCore/StuContext'], function (STU) {
    'use strict';

    var ServicesManager = {};

    var serviceByActor = {};


    ServicesManager.initialize = function () {    
    };
    

    ServicesManager.dispose = function () { 
    };
    

    ServicesManager.dump = function () {
        // console.log("[M1Q-ServicesManager::dump]");
        // console.log(serviceByActor);

        for(var object in serviceByActor) {
           // propertyName is what you want
           // you can get the value like this: myObject[propertyName]
           // console.log(object[0]);
        }
       
    };

    ServicesManager.registerService = function (iActor,iService) {
        // console.log("[M1Q-ServicesManager::registerService]");
        // console.log(iActor._path);
        // console.log(iService);
        if (iService instanceof STU.Service) {

            // var actorPrototype = iActor.prototype.__proto__.type;   
            if(serviceByActor[iActor._path] === undefined) {
               serviceByActor[iActor._path] = [];
            }
            // console.log(serviceByActor[iActor._path]);

            if(serviceByActor[iActor._path].indexOf(iService) === -1) {
               serviceByActor[iActor._path].push(iService);
            }
        }
        else {
            console.error('[M1Q-ServicesManager::registerService] iService is not a Service : ');
            console.error(iService);
        }

        this.dump();
    };

    
    ServicesManager.getServiceByActorAndName = function (iActor,iServiceName) {
        // console.log("[M1Q-ServicesManager::getServiceByActorAndName]");
        // console.log("[M1Q-ServicesManager::getServiceByActorAndName] search service of actor : " + iActor._path);
        // console.log("[M1Q-ServicesManager::getServiceByActorAndName] search service of name : " + iServiceName);

        // var actorPrototype = iActor._path.prototype.__proto__.type;   
        if(serviceByActor[iActor._path] === undefined) {
           return;
        }
        // console.log(serviceByActor[iActor._path]);

        for (var i = 0; i < serviceByActor[iActor._path].length; i++) {
            // console.log("[M1Q-ServicesManager::getServiceByActorAndName] has : " + serviceByActor[iActor._path][i].name);
            if (serviceByActor[iActor._path][i].name == iServiceName){
                // console.log('[M1Q-ServicesManager::getServiceByActorAndName] FOUND service :');
                // console.log(serviceByActor[iActor._path][i]);
                return serviceByActor[iActor._path][i];
            }
        }
        console.warn("[M1Q-ServicesManager::getServiceByActorAndName] did not found service " + iServiceName);
    };



    // Expose in STU namespace.
    STU.ServicesManager = ServicesManager;

    return ServicesManager;
});

define('StuModel/StuServicesManager', ['DS/StuModel/StuServicesManager'], function (ServicesManager) {
    'use strict';

    return ServicesManager;
});

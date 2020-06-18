define('DS/ENOXEnhancers/Services/WebServices', [
  'UWA/Core',
  'UWA/Promise',
  'UWA/Utils',
  'DS/ENOXEnhancers/Services/SettingsManagement',
  'DS/WAFData/WAFData',
  'DS/ENOXEnhancers/Constants/Constants',
  'DS/ENOXEnhancers/Utils/Helper',
  'DS/ENOXEnhancers/Services/Resources'
], function(
  UWA,
  UWAPromise,
  UWAUtils,
  SettingsManagement,
  WAFData,
  Constants,
  Helper,
  Resources
)
{
  'use strict';

  Array.prototype.containsItem = function(item, id)
  {
    var that = this,
      contains = false;
    for (var i = 0; i < that.length; i++)
    {
      if (that[0][id] === item[id]) return true;
    }

    return contains;
  }

  var WebServices = {
    callCustomService: function _callCustomService(options)
    {
      options.method = options.method || Constants.GET;
      options.headers = options.headers ||
      {
        Accept: Constants.ACCEPT_APPLICATION_JSON
      };
      options.proxy = options.proxy || 'passport';
      if (!options.withoutSC)
        options.SecurityContext = SettingsManagement.getSetting(
          Constants.PAD_CURRENT_SECURITY_CONTEXT);

      WAFData.authenticatedRequest(options.url, options);
    }
  };

  return WebServices;

});

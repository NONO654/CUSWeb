define('DS/ENOXEnhancers/Services/PlatformServices', [
  'UWA/Core',
  'UWA/Promise',
  'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
  'DS/ENOXEnhancers/Services/SettingsManagement',
  'DS/ENOXEnhancers/Constants/Constants'
], function(
  UWACore,
  UWAPromise,
  i3DXCompassPlatformServices,
  SettingsManagement,
  Constants
)
{
  'use strict';

  var PlatformServices = function() {};

  PlatformServices.prototype.initializePlatform = function(options)
  {
    var that = this;
    i3DXCompassPlatformServices.getPlatformServices(
    {
      onComplete: function(result)
      {
        if (result === null)
        {
          result.options = options;
          var reject = options.onFailure;
          reject("cannot retrieve platform data");
        }
        else
        {
          var data = Constants.EMPTY_JSON_OBJECT;
          that.platformurls = data.platformurls = result[0];
          SettingsManagement.addSetting(Constants.PLATFORM_SERVICES, that);
          data.options === options;
          var resolve = options.onComplete;
          resolve(data);
        }
      },
      onFailure: function(error)
      {
        var reject = options.onFailure;
        reject(error);
      }
    });
  }

  PlatformServices.prototype.get3DSpaceURL = function()
  {
    return this.getURL('3DSpace');
  }

  PlatformServices.prototype.getTenantId = function()
  {
    return this.getURL('platformId');
  }

  PlatformServices.prototype.getURL = function(key)
  {
    return this.platformurls[key] || '';
  }

  PlatformServices.prototype.getCurrentUser = function()
  {
    return new Promise(function(resolve, reject)
    {
      i3DXCompassPlatformServices.getUser(
      {
        onComplete: function(data)
        {
          resolve(
          {
            id: data.id,
            email: data.email,
            firstName: data.firstname,
            lastName: data.lastname
          });
        },
        onFailure: reject
      });
    });
  }

  return PlatformServices;
});

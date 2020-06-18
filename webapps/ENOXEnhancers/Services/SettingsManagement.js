define('DS/ENOXEnhancers/Services/SettingsManagement', [
  'UWA/Class',
  'DS/ENOXEnhancers/Constants/Constants'
], function(
  Class,
  Constants
)
{
  'use strict';

  var SettingsManagement = Class.singleton(
  {
    init: function _init()
    {
      this.isPlatformInitialized = true;
    },
    addSetting: function _addSetting(setting, value)
    {
      var that = this;
      if (!that.isPlatformInitialized) throw new Error('Platformservices not initialized');
      if (widget[setting]) console.log('Setting is already in use');
      widget[setting] = value;
    },
    getSetting: function _getSetting(setting)
    {
      return widget[setting] || '';
    },
    getPlatformURLs: function _getPlatformURLs()
    {
      return this.getSetting(Constants.PLATFORM_SERVICES);
    },
    getPlatformId: function _getPlatformId()
    {
      return this.getSetting(Constants.PLATFORM_ID);
    }
  });

  return SettingsManagement;
});

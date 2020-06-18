define('DS/ENOXEnhancersUI/Collections/ENOXWelcomePanelCollection', [
  'UWA/Class/Model',
  'UWA/Class/Collection',
  'UWA/Promise',
  'DS/ENOXEnhancersUI/Constants/Constants'
], function(UWAModel,
  UWACollection,
  UWAPromise,
  Constants
)
{
  'use strict';

  var welcomePanelCollection = {
    createCollection: function _createCollection()
    {
      return UWACollection.extend(
      {
        model: UWAModel.extend(
        {}),
        sync: function _sync(method, collection, options)
        {
          require([collection.options.panelOptions, collection.options.nls], function(
            WelcomePanelOptions, WelcomePanelNLS)
          {
            var data = {
              WelcomePanelActivities: JSON.parse(WelcomePanelOptions),
              WelcomePanelNLS: WelcomePanelNLS
            }
            options.onComplete(data);
          });
        },
        setup: function _setup(model, options)
        {
          var activitiesJsonUrl = options.panelOptions;
          var activitiesNLSUrl = options.nls;
          this.options = {};
          this.options.panelOptions = 'text!' + activitiesJsonUrl;
          this.options.nls = activitiesNLSUrl ? 'i18n!' + activitiesNLSUrl :
            Constants.EMPTY_STRING;
        },
        parse: function _parse(data, options)
        {
          var welcomePanelNLS = data.WelcomePanelNLS;
          data.WelcomePanelActivities.activities.forEach(function(item)
          {
            var actionsList = item.actions;
            actionsList.forEach(function(actionItem)
            {
              actionItem.text = welcomePanelNLS[actionItem.id];
            });
          });
          data.options = options;
          return data;
        }
      });
    }
  };

  return welcomePanelCollection

});

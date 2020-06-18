define('DS/ENOXEnhancers/Services/Favorites', [
  'UWA/Core',
  'UWA/Promise',
  'UWA/Utils',
  'DS/ENOXEnhancers/Services/SettingsManagement',
  'DS/ENOXEnhancers/Services/WebServices',
  'DS/ENOXEnhancers/Constants/Constants',
  'DS/ENOXEnhancers/Utils/Helper',
  'DS/ENOXEnhancers/Services/Resources'
], function(
  UWA,
  UWAPromise,
  UWAUtils,
  SettingsManagement,
  XEnhancersService,
  Constants,
  Helper,
  Resources
)
{
  'use strict';

  Array.prototype.containsItem = function(item, comparator)
  {
    comparator === undefined ? comparator = 'id' : Constants.EMPTY_STRING;
    for (var i = 0; i < this.length; i++)
    {
      if (this[i][comparator] === item[comparator]) return i;
    }
    return -1;
  }

  var Favorites = {
    addFavorites: function _addFavorites(options)
    {
      if (!UWA.is(options, 'object'))
      {
        throw new Error(Helper.getMessage(
        {
          key: '0004',
          appends: ['WebServices.addFavorites.options']
        }));
      }

      var that = this,
        favoritesName = options.name,
        compare = options.compare || 'id',
        json = {
          data:
          {
            protocol: options.protocol || "3DXContent",
            version: options.version || "1.0",
            source: options.source || '',
            data: options.resolvedFavorites ||
            {}
          }
        },
        localOptions = options;

      if (!options.resolvedFavorites)
      {
        json.data.data[favoritesName] = [];

        for (var i = 0; i < options.favorites.length; i++)
        {
          var favorite = options.favorites[i]['_attributes'] || options.favorites[i];
          if ((favorite.physicalid || favorite.id) && favorite.name)
          {
            var item = {
              id: favorite.physicalid || favorite.id,
              name: favorite.name
            };

            json.data.data[favoritesName].push(item);
          }
        }
      }

      var promiseGetFavorites = new UWAPromise(function(resolve, reject)
      {
        var prefOptions = {
          onComplete: resolve,
          onFailure: reject,
          name: favoritesName
        };

        that.getFavorites(prefOptions);
      });

      promiseGetFavorites.then(function(result)
      {
        var prevPrefData = result.value,
          dataArray = json.data.data[favoritesName];

        if (prevPrefData && prevPrefData.data && prevPrefData.data.data)
        {
          var favContent = prevPrefData.data.data[favoritesName];
          dataArray.forEach(function(item)
          {
            if (favContent.containsItem(item, compare) == -1)
            {
              favContent.push(item);
            }
          });

          json.data.data[favoritesName] = favContent;
        }

        if (!that._lastPrefToSave) that._lastPrefToSave = {};
        that._lastPrefToSave[options.name] = {
          name: options.name,
          value: UWAUtils.base64Encode(JSON.stringify(json))
        };

        var lastPreference = that._lastPrefToSave[options.name];
        if (lastPreference)
        {
          var servicePath = SettingsManagement.getPlatformURLs().get3DSpaceURL() +
            Resources.SET_PREFERENCE;
          localOptions.method = Constants.PUT;
          localOptions.headers = {
            Accept: Constants.ACCEPT_APPLICATION_JSON
          };
          localOptions.headers[Constants.SECURITY_CONTEXT_KEY] =
            SettingsManagement.getSetting(Constants.PAD_CURRENT_SECURITY_CONTEXT);
          localOptions.headers[Constants.CONTENT_TYPE] = Constants.APPLICATION_URL_ENCODED;
          localOptions.data = {
            name: lastPreference.name,
            value: lastPreference.value
          };
          localOptions.withoutTenant = true;
          localOptions.url = servicePath;

          XEnhancersService.callCustomService(localOptions);
          delete that._lastPrefToSave[options.name];
        }
      });
    },
    replaceFavorites: function _replaceFavorites(options)
    {
      if (!UWA.is(options, 'object'))
      {
        throw new Error(Helper.getMessage(
        {
          key: '0004',
          appends: ['WebServices.replaceFavorites.options']
        }));
      }

      var that = this,
        favoritesName = options.name,
        compare = options.compare || 'id',
        json = {
          data:
          {
            protocol: options.protocol || "3DXContent",
            version: options.version || "1.0",
            source: options.source || '',
            data: options.resolvedFavorites ||
            {}
          }
        },
        localOptions = options;

      if (!options.resolvedFavorites)
      {
        json.data.data[favoritesName] = Constants.EMPTY_JSON_ARRAY;

        for (var i = 0; i < options.favorites.length; i++)
        {
          var favorite = options.favorites[i]['_attributes'] || options.favorites[i];
          if ((favorite.physicalid || favorite.id) && favorite.name)
          {
            var item = {
              id: favorite.physicalid || favorite.id,
              name: favorite.name
            };

            json.data.data[favoritesName].push(item);
          }
        }
      }

      if (!that._lastPrefToSave) that._lastPrefToSave = {};
      that._lastPrefToSave[options.name] = {
        name: options.name,
        value: UWAUtils.base64Encode(JSON.stringify(json))
      };

      var lastPreference = that._lastPrefToSave[options.name];
      if (lastPreference)
      {
        var servicePath = SettingsManagement.getPlatformURLs().get3DSpaceURL() + Resources.SET_PREFERENCE;
        localOptions.method = Constants.PUT;
        localOptions.headers = {
          Accept: Constants.ACCEPT_APPLICATION_JSON
        };
        localOptions.headers[Constants.SECURITY_CONTEXT_KEY] =
          SettingsManagement.getSetting(Constants.PAD_CURRENT_SECURITY_CONTEXT);
        localOptions.headers[Constants.CONTENT_TYPE] = Constants.APPLICATION_URL_ENCODED;
        localOptions.data = {
          name: lastPreference.name,
          value: lastPreference.value
        };
        localOptions.withoutTenant = true;
        localOptions.url = servicePath;

        XEnhancersService.callCustomService(localOptions);
        delete that._lastPrefToSave[options.name];
      }

    },
    getFavorites: function _getFavorites(options)
    {
      if (!UWA.is(options, 'object'))
      {
        throw new Error(Helper.getMessage(
        {
          key: '0004',
          appends: ['Webservices.getFavorites.options']
        }));
      }
      var that = this,
        localOptions = options,
        onComplete = options.onComplete;

      var servicePath = SettingsManagement.getPlatformURLs().get3DSpaceURL() +
        Resources.GET_PREFERENCE + '?';
      localOptions.query = {
        'name': options.name
      };
      localOptions.method = 'GET';
      localOptions.headers = {
        Accept: Constants.ACCEPT_APPLICATION_JSON
      };
      localOptions.headers[Constants.SECURITY_CONTEXT_KEY] = SettingsManagement.getSetting(
        Constants.PAD_CURRENT_SECURITY_CONTEXT);
      localOptions.withoutTenant = true;
      var query = {
        name: options.name
      };
      localOptions.url = servicePath + UWAUtils.toQueryString(query);

      localOptions.onComplete = function(data)
      {
        var result = {};
        var resultData = UWAUtils.base64Decode(data)
        result.value = !Helper.isStringEmpty(resultData) ? JSON.parse(
            resultData) :
          Constants.EMPTY_STRING;
        result.options = options;
        onComplete(result);
      }

      localOptions.onFailure = function(error)
      {
        console.log(error);
      }
      XEnhancersService.callCustomService(localOptions);
    },
    deleteFavorites: function _deleteFavorites(options)
    {
      if (!UWA.is(options, 'object'))
      {
        throw new Error(Helper.getMessage(
        {
          key: '0004',
          appends: ['Webservices.deleteFavorites.options']
        }));
      }
      var that = this,
        localOptions = options,
        onComplete = options.onComplete,
        onFailure = options.onFailure,
        favoritesName = options.name,
        favoriteContent = options.favorites;
      var promiseGetFavorites = function()
      {
        return new UWAPromise(function(resolve, reject)
        {
          var getOptions = {
            onComplete: function(data)
            {
              var lastPrefData = data.value.data.data[favoritesName];
              favoriteContent.forEach(function(item)
              {
                var index = lastPrefData.containsItem(item, 'id');
                if (index != -1)
                {
                  lastPrefData.splice(index, 1);
                }
              });
              data.value.data.data[favoritesName] = lastPrefData;
              resolve(data.value)
            },
            onFailure: reject,
            name: favoritesName
          };
          that.getFavorites(getOptions);
        });
      }

      var promiseReplaceFavorites = function(result)
      {
        return new UWAPromise(function(resolve, reject)
        {
          var addOptions = {
            name: favoritesName,
            onComplete: resolve,
            onFailure: reject,
            protocol: result.data.protocol,
            version: result.data.version,
            source: result.data.source,
            resolvedFavorites: result.data.data
          }

          that.replaceFavorites(addOptions);
        });
      }

      promiseGetFavorites().then(function(result)
      {
        promiseReplaceFavorites(result);
      }).then(function(result)
      {
        onComplete(result);
      }, function(error)
      {
        onFailure(error)
      });
    }
  };

  return Favorites;

});

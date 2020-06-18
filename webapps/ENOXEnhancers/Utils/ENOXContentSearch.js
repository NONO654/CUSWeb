define('DS/ENOXEnhancers/Utils/ENOXContentSearch', [
    'DS/ENOXEnhancers/Services/WebServices',
    'DS/ENOXEnhancers/Services/Resources',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXEnhancers/Utils/Helper',
    'DS/ENOXEnhancers/Services/SettingsManagement'
  ],
  function(
    WebServices,
    Resources,
    Constants,
    Helper,
    SettingsManagement
  )
  {
    'use strict';

    function searchOnFailure(error)
    {
      console.log('search failed: ' + error);
    }
    var contentSearch = function() {};

    contentSearch.prototype.onSearch = function(query, idlist, options)
    {
      var options = options ||
      {};
      query = query.replace(/[/\\#*]/g, '');
      query = "*" + query + "*";
      options.data = {
        "isPhysicalIds": true,
        "searchStr": query,
        "oid_list": idlist
      };
      options.timeout = 200000;
      options.method = Constants.POST;
      options.headers = {
        'content-type': Constants.APPLICATION_URL_ENCODED,
        'Accept': Constants.ACCEPT_APPLICATION_JSON
      }
      options.onFailure = searchOnFailure;
      options.url = SettingsManagement.getPlatformURLs().get3DSpaceURL() + Resources.GET_SEARCH_RESULT;
      WebServices.callCustomService(options);
    };

    return contentSearch;

  });
